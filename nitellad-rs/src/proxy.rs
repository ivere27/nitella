use dashmap::DashMap;
use rustls::pki_types::PrivateKeyDer;
use rustls::ServerConfig;
use std::io::{self, BufReader, Cursor, Read, Write};
use std::net::{Shutdown, SocketAddr, TcpStream as StdTcpStream};
use std::pin::Pin;
use std::sync::Arc;
use std::task::{Context, Poll};
use std::time::{Duration, Instant};
use tokio::io::{AsyncRead, AsyncReadExt, AsyncWrite, AsyncWriteExt, ReadBuf};
use tokio::net::{TcpListener, TcpStream};
use tokio::sync::{mpsc, oneshot, RwLock};
use tokio_rustls::TlsAcceptor;
use tracing::{debug, error, info, warn};
use uuid::Uuid;

use crate::approval::{ApprovalManager, ApprovalReqData};
use crate::geoip::GeoIPService;
use crate::process_proxy::ProcessProxyListener;
use crate::proto::common::{ActionType, ApprovalRetentionMode, FallbackAction, MockPreset};
use crate::proto::proxy::{ActiveConnection, ClientAuthType, MockConfig};
use crate::ratelimit::RateLimiter;
use crate::rules::{RuleEngine, TlsPeerInfo};
use crate::stats::{ActiveConnEntry, StatsService};

// Approval flow should stay near-real-time even if GeoIP remote providers are slow.
const CONNECTION_GEOIP_TIMEOUT: Duration = Duration::from_millis(250);
const MONITORED_STREAM_FLUSH_BYTES: u64 = 64 * 1024;
const USERSPACE_COPY_BUF: usize = 32 * 1024;

#[derive(Clone)]
pub enum ProxyListener {
    Embedded(Arc<EmbeddedListener>),
    Process(ProcessProxyListener),
}

impl ProxyListener {
    pub async fn run(&self) -> anyhow::Result<()> {
        match self {
            Self::Embedded(l) => l.clone().run().await,
            Self::Process(_) => std::future::pending().await,
        }
    }

    pub async fn stop(&self) -> anyhow::Result<()> {
        match self {
            Self::Embedded(_) => Ok(()),
            Self::Process(p) => p.stop().await,
        }
    }

    pub async fn get_active_connections(&self) -> anyhow::Result<Vec<ActiveConnection>> {
        match self {
            Self::Embedded(l) => Ok(l.get_active_connections()),
            Self::Process(p) => p.get_active_connections().await,
        }
    }

    pub async fn close_connection(&self, conn_id: String) -> anyhow::Result<()> {
        match self {
            Self::Embedded(l) => {
                if l.close_connection(&conn_id) {
                    Ok(())
                } else {
                    Err(anyhow::anyhow!("connection not found"))
                }
            }
            Self::Process(p) => p.close_connection(conn_id).await,
        }
    }

    pub async fn close_all_connections(&self) -> anyhow::Result<()> {
        match self {
            Self::Embedded(l) => {
                l.close_all_connections();
                Ok(())
            }
            Self::Process(p) => p.close_all_connections().await,
        }
    }
}

use crate::proto::proxy::HealthStatus;
use std::sync::atomic::{AtomicI32, Ordering};

pub struct EmbeddedListener {
    pub id: String,
    pub name: String,
    listen_addr: String,
    default_backend: String,
    tls_acceptor: Option<TlsAcceptor>,
    geoip: Arc<GeoIPService>,
    local_rules: Arc<RwLock<RuleEngine>>,
    global_rules: Arc<RwLock<RuleEngine>>,
    stats: Arc<StatsService>,
    approval_manager: Arc<ApprovalManager>,
    cancellations: Arc<DashMap<String, oneshot::Sender<()>>>,
    default_action: ActionType,
    default_mock: MockPreset,
    fallback_action: FallbackAction,
    fallback_mock: MockPreset,
    bound_addr: Arc<RwLock<Option<String>>>,
    health_status: Arc<AtomicI32>,
}

impl EmbeddedListener {
    pub fn new(
        id: String,
        name: String,
        listen_addr: String,
        default_backend: String,
        geoip: Arc<GeoIPService>,
        local_rules: Arc<RwLock<RuleEngine>>,
        global_rules: Arc<RwLock<RuleEngine>>,
        stats: Arc<StatsService>,
        approval_manager: Arc<ApprovalManager>,
        health_status: Arc<AtomicI32>,
        default_action: i32,
        default_mock: i32,
        fallback_action: i32,
        fallback_mock: i32,
    ) -> Self {
        let listen_addr = if listen_addr.starts_with(':') {
            format!("0.0.0.0{}", listen_addr)
        } else {
            listen_addr
        };

        Self {
            id,
            name,
            listen_addr,
            default_backend,
            tls_acceptor: None,
            geoip,
            local_rules,
            global_rules,
            stats,
            approval_manager,
            cancellations: Arc::new(DashMap::new()),
            default_action: {
                let da = ActionType::try_from(default_action).unwrap_or(ActionType::Allow);
                info!("Proxy default_action: {:?} (raw={})", da, default_action);
                da
            },
            default_mock: MockPreset::try_from(default_mock).unwrap_or(MockPreset::Unspecified),
            fallback_action: FallbackAction::try_from(fallback_action)
                .unwrap_or(FallbackAction::Unspecified),
            fallback_mock: MockPreset::try_from(fallback_mock).unwrap_or(MockPreset::Unspecified),
            bound_addr: Arc::new(RwLock::new(None)),
            health_status,
        }
    }

    pub async fn get_bound_addr(&self) -> String {
        let lock = self.bound_addr.read().await;
        lock.clone().unwrap_or_else(|| self.listen_addr.clone())
    }

    pub fn with_tls(
        mut self,
        cert_pem: &str,
        key_pem: &str,
        ca_pem: &str,
        client_auth: ClientAuthType,
    ) -> anyhow::Result<Self> {
        if cert_pem.is_empty() || key_pem.is_empty() {
            return Ok(self);
        }

        let certs = rustls_pemfile::certs(&mut BufReader::new(cert_pem.as_bytes()))
            .collect::<Result<Vec<_>, _>>()?;

        let key = parse_private_key_der(key_pem)?;

        let mut config = ServerConfig::builder().with_no_client_auth();

        if !ca_pem.is_empty() {
            let mut ca_reader = BufReader::new(ca_pem.as_bytes());
            let mut roots = rustls::RootCertStore::empty();
            for cert in rustls_pemfile::certs(&mut ca_reader) {
                roots.add(cert?)?;
            }

            config = match client_auth {
                ClientAuthType::ClientAuthRequire | ClientAuthType::ClientAuthAuto => {
                    let verifier =
                        rustls::server::WebPkiClientVerifier::builder(Arc::new(roots)).build()?;
                    ServerConfig::builder().with_client_cert_verifier(verifier)
                }
                ClientAuthType::ClientAuthRequest => {
                    let verifier = rustls::server::WebPkiClientVerifier::builder(Arc::new(roots))
                        .allow_unauthenticated()
                        .build()?;
                    ServerConfig::builder().with_client_cert_verifier(verifier)
                }
                _ => ServerConfig::builder().with_no_client_auth(),
            };
        } else if client_auth == ClientAuthType::ClientAuthRequire {
            return Err(anyhow::anyhow!(
                "CLIENT_AUTH_REQUIRE requested but no CA PEM provided"
            ));
        }

        let config = config.with_single_cert(certs, key)?;
        self.tls_acceptor = Some(TlsAcceptor::from(Arc::new(config)));

        Ok(self)
    }

    pub async fn bind(&self) -> anyhow::Result<TcpListener> {
        let bind_addr = normalize_listen_addr(&self.listen_addr);
        let listener = TcpListener::bind(&bind_addr).await?;
        if let Ok(addr) = listener.local_addr() {
            info!("Proxy '{}' listening on {}", self.name, addr);
            *self.bound_addr.write().await = Some(addr.to_string());
        } else {
            info!("Proxy '{}' listening on {}", self.name, self.listen_addr);
        }
        Ok(listener)
    }

    pub async fn run_with_listener(self: Arc<Self>, listener: TcpListener) -> anyhow::Result<()> {
        loop {
            match listener.accept().await {
                Ok((socket, addr)) => {
                    let self_clone = self.clone();
                    tokio::spawn(async move {
                        if let Err(e) = self_clone.handle_tcp_conn(socket, addr).await {
                            debug!("Connection error from {}: {}", addr, e);
                        }
                    });
                }
                Err(e) => {
                    error!("Accept error: {}", e);
                    // Prevent tight loop on error
                    tokio::time::sleep(Duration::from_millis(100)).await;
                }
            }
        }
    }

    pub async fn run(self: Arc<Self>) -> anyhow::Result<()> {
        let listener = self.bind().await?;
        self.run_with_listener(listener).await
    }

    async fn handle_tcp_conn(&self, socket: TcpStream, addr: SocketAddr) -> anyhow::Result<()> {
        if let Some(acceptor) = &self.tls_acceptor {
            match acceptor.accept(socket).await {
                Ok(tls_stream) => {
                    let tls_info = tls_stream
                        .get_ref()
                        .1
                        .peer_certificates()
                        .and_then(|certs| certs.first())
                        .and_then(|cert| TlsPeerInfo::from_der(cert.as_ref()));
                    self.handle_stream(ClientStream::Other(tls_stream), addr, tls_info)
                        .await
                }
                Err(e) => {
                    debug!("TLS Handshake failed from {}: {}", addr, e);
                    Ok(())
                }
            }
        } else {
            self.handle_stream::<tokio::io::DuplexStream>(ClientStream::Tcp(socket), addr, None)
                .await
        }
    }

    async fn handle_stream<S>(
        &self,
        mut client_stream: ClientStream<S>,
        addr: SocketAddr,
        tls_info: Option<TlsPeerInfo>,
    ) -> anyhow::Result<()>
    where
        S: AsyncRead + AsyncWrite + Unpin,
    {
        let conn_id = Uuid::new_v4().to_string();
        let conn_start = Instant::now();
        let ip = addr.ip();
        let ip_str = ip.to_string();

        let geo_info = self
            .geoip
            .lookup_with_remote_timeout(&ip_str, Some(CONNECTION_GEOIP_TIMEOUT))
            .await;
        let tls_session_id = tls_info
            .as_ref()
            .map(|info| info.fingerprint.clone())
            .unwrap_or_default();

        let geo_match = Some(geo_info.clone());
        let mut global_allowed = false;
        {
            let engine = self.global_rules.read().await;
            let global_match = if engine.is_empty() {
                None
            } else if engine.has_tls_conditions() {
                engine.evaluate_global_with_tls(ip, &geo_match, tls_info.as_ref())
            } else {
                engine.evaluate_global(ip, &geo_match)
            };

            if let Some(rule) = global_match {
                match rule.action() {
                    ActionType::Block => {
                        info!("[{}] Blocked by global rule: {}", self.name, ip_str);
                        self.stats.record_block(&ip_str, &rule.id);
                        return self
                            .handle_fallback(client_stream, self.default_backend.clone())
                            .await;
                    }
                    ActionType::Allow => {
                        global_allowed = true;
                    }
                    _ => {}
                }
            }
        }

        let matched = {
            let engine = self.local_rules.read().await;
            if engine.is_empty() {
                None
            } else if engine.has_tls_conditions() {
                engine.evaluate_with_tls_details(ip, &geo_match, tls_info.as_ref())
            } else {
                engine.evaluate_details(ip, &geo_match)
            }
        };
        let mut matched_rule = matched.as_ref().map(|m| m.rule.clone());
        let mut rate_limiter = matched.and_then(|m| m.rate_limiter);

        if let Some(limiter) = rate_limiter.clone() {
            if limiter.check(&ip_str) {
                limiter.track_connection(&ip_str);
            } else {
                if let Some(rule) = matched_rule.as_mut() {
                    rule.action = ActionType::Block as i32;
                }
                rate_limiter = None;
                info!(
                    "[{}] Rate limit blocked {} for rule {}",
                    self.name,
                    ip_str,
                    matched_rule
                        .as_ref()
                        .map(|rule| rule.id.as_str())
                        .unwrap_or("unknown")
                );
            }
        };

        let mut action = matched_rule
            .as_ref()
            .map(|r| r.action())
            .unwrap_or(self.default_action);
        let rule_id = matched_rule
            .as_ref()
            .map(|r| r.id.clone())
            .unwrap_or_else(|| "default".to_string());
        info!(
            "[{}] Connection from {} => action={:?}, default_action={:?}, rule={}",
            self.name, addr, action, self.default_action, rule_id
        );

        let mut target = self.default_backend.clone();
        let mut mock_config = None;

        if let Some(rule) = &matched_rule {
            if !rule.target_backend.is_empty() {
                target = rule.target_backend.clone();
            }
            if let Some(m) = &rule.mock_response {
                mock_config = Some(m.clone());
            }
        }

        if matched_rule.is_none() && action == ActionType::Mock && mock_config.is_none() {
            // Create mock config from default_mock
            mock_config = Some(MockConfig {
                protocol: "http".to_string(), // Default to HTTP for presets usually
                preset: self.default_mock as i32,
                payload: vec![],
                delay_ms: 0,
            });
        }

        if global_allowed && action == ActionType::Block {
            info!(
                "[{}] Global allow overriding local/default block for {}",
                self.name, ip_str
            );
            action = ActionType::Allow;
        }

        // Handle Approval (matching Go's cache-first pattern)
        let mut connection_only_max_duration: Option<i64> = None;
        let mut track_cached_approval = false;
        if action == ActionType::RequireApproval {
            // Check cache first — cached decisions skip the alert entirely
            if let Some(cached) = self
                .approval_manager
                .check_cache(&ip_str, &rule_id, &tls_session_id)
                .await
            {
                if cached.allowed {
                    info!(
                        "Approval CACHED for {} (remaining={}s)",
                        addr, cached.duration_seconds
                    );
                    track_cached_approval = true;
                    // Proceed as ALLOW
                } else {
                    info!("Approval CACHED DENY for {}", addr);
                    self.approval_manager
                        .increment_blocked_count(&ip_str, &rule_id, &tls_session_id)
                        .await;
                    action = ActionType::Block;
                }
            } else {
                // Cache miss — request approval via Hub
                let req_data = ApprovalReqData {
                    id: Uuid::new_v4().to_string(),
                    proxy_id: self.id.clone(),
                    source_ip: ip_str.clone(),
                    rule_id: rule_id.clone(),
                    tls_session_id: tls_session_id.clone(),
                    info: format!("Connection from {} to {}", addr, target),
                    created_at: chrono::Utc::now().timestamp(),
                    geo_country: geo_info.country.clone(),
                    geo_city: geo_info.city.clone(),
                    geo_isp: geo_info.isp.clone(),
                };

                info!("Requesting approval for {}...", addr);
                self.stats
                    .record_approval_request(&ip_str, &rule_id, &self.id, &req_data.id);

                match self.approval_manager.request_approval(req_data).await {
                    Err(e) => {
                        warn!("Approval rejected (rate limit): {} - {}", addr, e);
                        action = ActionType::Block;
                    }
                    Ok(result) if result.allowed => {
                        let mut retention_mode =
                            ApprovalRetentionMode::try_from(result.retention_mode)
                                .unwrap_or(ApprovalRetentionMode::Cache);
                        if retention_mode == ApprovalRetentionMode::Unspecified {
                            retention_mode = ApprovalRetentionMode::Cache;
                        }
                        info!(
                            "Approval GRANTED for {} (mode={:?}, duration={}s)",
                            addr, retention_mode, result.duration_seconds
                        );
                        if retention_mode == ApprovalRetentionMode::ConnectionOnly
                            && result.duration_seconds > 0
                        {
                            connection_only_max_duration = Some(result.duration_seconds);
                        }
                        track_cached_approval = retention_mode == ApprovalRetentionMode::Cache;
                    }
                    Ok(_) => {
                        info!("Approval DENIED for {}", addr);
                        action = ActionType::Block;
                    }
                }
            }
        }

        // Register Connection
        let conn_entry = self.stats.register_connection(
            conn_id.clone(),
            self.id.clone(),
            ip_str.clone(),
            addr.port() as u32,
            target.clone(),
            rule_id.clone(),
            action as i32,
            Some(geo_info),
        );

        // Register live byte counters with approval manager for real-time tracking
        if track_cached_approval {
            self.approval_manager
                .set_conn_id(
                    &ip_str,
                    &rule_id,
                    &tls_session_id,
                    &conn_id,
                    conn_entry.bytes_in.clone(),
                    conn_entry.bytes_out.clone(),
                )
                .await;
        }

        // Ensure unregister on drop
        let _guard = ConnectionGuard {
            conn_id: conn_id.clone(),
            stats: self.stats.clone(),
            approval_manager: if track_cached_approval {
                Some(self.approval_manager.clone())
            } else {
                None
            },
            source_ip: ip_str.clone(),
            rule_id: rule_id.clone(),
            tls_session_id: tls_session_id.clone(),
        };

        match action {
            ActionType::Block => {
                info!(
                    "Blocking connection from {} (Rule: {:?})",
                    addr,
                    matched_rule.as_ref().map(|r| &r.name)
                );
                self.stats.record_block(&ip_str, &rule_id);
                return self.handle_fallback(client_stream, target).await;
            }
            ActionType::Mock => {
                info!(
                    "Mocking connection from {} (Rule: {:?})",
                    addr,
                    matched_rule.as_ref().map(|r| &r.name)
                );
                if let Some(cfg) = mock_config {
                    self.write_mock_response(&mut client_stream, &cfg).await?;
                }
                return Ok(());
            }
            _ => {}
        }

        if target.is_empty() {
            warn!("No backend for connection from {}", addr);
            return self.handle_fallback(client_stream, target).await;
        }

        let _rate_limit_guard = RateLimitReportGuard {
            limiter: rate_limiter,
            ip: ip_str.clone(),
            start: conn_start,
        };

        // Health Check Enforcement
        let current_health = self.health_status.load(Ordering::Relaxed);
        if current_health == HealthStatus::Unhealthy as i32 {
            debug!("Backend {} is unhealthy, triggering fallback", target);
            // Fallback Logic (Deduplicated)
            return self.handle_fallback(client_stream, target).await;
        }

        // Connection with Timeout
        let backend_conn =
            match tokio::time::timeout(Duration::from_secs(3), TcpStream::connect(&target)).await {
                Ok(Ok(c)) => c,
                Ok(Err(e)) => {
                    warn!("Failed to connect to backend {}: {}", target, e);
                    return self.handle_fallback(client_stream, target).await;
                }
                Err(_) => {
                    warn!("Connection to backend {} timed out", target);
                    return self.handle_fallback(client_stream, target).await;
                }
            };

        // Cancellation handling
        let (tx, rx) = oneshot::channel();
        self.cancellations.insert(conn_id.clone(), tx);

        // CONNECTION_ONLY with duration>0 means "this connection only, max N seconds".
        if let Some(dur) = connection_only_max_duration {
            let cancellations = self.cancellations.clone();
            let cid = conn_id.clone();
            tokio::spawn(async move {
                tokio::time::sleep(Duration::from_secs(dur as u64)).await;
                if let Some((_, tx)) = cancellations.remove(&cid) {
                    info!(
                        "Connection-only approval expired after {}s, closing connection {}",
                        dur, cid
                    );
                    let _ = tx.send(());
                }
            });
        }

        #[cfg(target_os = "linux")]
        match client_stream {
            ClientStream::Tcp(client_tcp) => {
                let (bytes_in, bytes_out) = copy_bidirectional_splice_tcp(
                    client_tcp,
                    backend_conn,
                    conn_entry.clone(),
                    self.stats.clone(),
                    rx,
                )
                .await?;

                debug!(
                    "Conn {}: splice bytes_in={}, bytes_out={}",
                    addr, bytes_in, bytes_out
                );

                info!("Connection handler exiting for {}", conn_id);
                self.cancellations.remove(&conn_id);

                return Ok(());
            }
            ClientStream::Other(stream) => {
                client_stream = ClientStream::Other(stream);
            }
        }

        match client_stream {
            ClientStream::Tcp(client_tcp) => {
                let (bytes_in, bytes_out) = copy_bidirectional_blocking_tcp(
                    client_tcp,
                    backend_conn,
                    conn_entry.clone(),
                    self.stats.clone(),
                    rx,
                )
                .await?;

                debug!(
                    "Conn {}: blocking copy bytes_in={}, bytes_out={}",
                    addr, bytes_in, bytes_out
                );
                info!("Connection handler exiting for {}", conn_id);
                self.cancellations.remove(&conn_id);

                return Ok(());
            }
            ClientStream::Other(stream) => {
                client_stream = ClientStream::Other(stream);
            }
        }

        // Wrap streams to count bytes
        let mut monitored_client = MonitoredStream {
            inner: client_stream,
            entry: conn_entry.clone(),
            stats: self.stats.clone(),
            is_inbound: true,
            pending_bytes: 0,
        };

        let mut monitored_backend = MonitoredStream {
            inner: backend_conn,
            entry: conn_entry.clone(),
            stats: self.stats.clone(),
            is_inbound: false,
            pending_bytes: 0,
        };

        let copy_fut = tokio::io::copy_bidirectional_with_sizes(
            &mut monitored_client,
            &mut monitored_backend,
            USERSPACE_COPY_BUF,
            USERSPACE_COPY_BUF,
        );

        tokio::select! {
            result = copy_fut => {
                match result {
                    Ok((tx, rx)) => {
                        debug!("Conn {}: tx={}, rx={}", addr, tx, rx);
                    },
                    Err(e) => return Err(e.into()),
                }
            },
            _ = rx => {
                info!("Connection {} terminated (admin or approval expiry)", conn_id);
            }
        }

        info!("Connection handler exiting for {}", conn_id);
        self.cancellations.remove(&conn_id);

        Ok(())
    }

    pub fn get_active_connections(&self) -> Vec<ActiveConnection> {
        self.stats.get_active_connections(Some(&self.id))
    }

    pub fn close_connection(&self, conn_id: &str) -> bool {
        if let Some((_, tx)) = self.cancellations.remove(conn_id) {
            let _ = tx.send(());
            true
        } else {
            false
        }
    }

    pub fn close_all_connections(&self) {
        let keys: Vec<String> = self.cancellations.iter().map(|k| k.key().clone()).collect();
        info!("Closing all {} connections", keys.len());
        for k in keys {
            if let Some((_, tx)) = self.cancellations.remove(&k) {
                if tx.send(()).is_err() {
                    warn!("Failed to send close signal to {}", k);
                }
            }
        }
    }

    async fn handle_fallback<S>(&self, mut client_stream: S, _target: String) -> anyhow::Result<()>
    where
        S: AsyncRead + AsyncWrite + Unpin,
    {
        let should_mock = self.fallback_action == FallbackAction::Mock
            || (self.fallback_action == FallbackAction::Unspecified
                && self.default_mock != MockPreset::Unspecified);
        if should_mock {
            let preset = if self.fallback_mock != MockPreset::Unspecified {
                self.fallback_mock
            } else {
                self.default_mock
            };
            let cfg = MockConfig {
                preset: preset as i32,
                ..Default::default()
            };
            self.write_mock_response(&mut client_stream, &cfg).await?;
        }
        Ok(())
    }

    async fn write_mock_response<S>(&self, stream: &mut S, cfg: &MockConfig) -> anyhow::Result<()>
    where
        S: AsyncRead + AsyncWrite + Unpin,
    {
        let behavior = MockBehavior::from_config(cfg);
        if behavior.delay_ms > 0 {
            tokio::time::sleep(Duration::from_millis(behavior.delay_ms as u64)).await;
        }

        match behavior.protocol.as_str() {
            "http" => mock_http(stream, &behavior).await?,
            "ssh" => mock_ssh(stream, &behavior).await?,
            "mysql" => mock_mysql(stream, &behavior).await?,
            "mssql" => mock_mssql(stream).await?,
            "rdp" => mock_rdp(stream).await?,
            "telnet" => mock_telnet(stream, &behavior).await?,
            "redis" => mock_redis(stream, &behavior).await?,
            "smtp" => mock_smtp(stream, &behavior).await?,
            _ => mock_raw(stream, &behavior).await?,
        }
        stream.flush().await?;
        Ok(())
    }
}

enum ClientStream<S> {
    Tcp(TcpStream),
    Other(S),
}

impl<S: AsyncRead + Unpin> AsyncRead for ClientStream<S> {
    fn poll_read(
        mut self: Pin<&mut Self>,
        cx: &mut Context<'_>,
        buf: &mut ReadBuf<'_>,
    ) -> Poll<std::io::Result<()>> {
        match &mut *self {
            Self::Tcp(stream) => Pin::new(stream).poll_read(cx, buf),
            Self::Other(stream) => Pin::new(stream).poll_read(cx, buf),
        }
    }
}

impl<S: AsyncWrite + Unpin> AsyncWrite for ClientStream<S> {
    fn poll_write(
        mut self: Pin<&mut Self>,
        cx: &mut Context<'_>,
        buf: &[u8],
    ) -> Poll<std::io::Result<usize>> {
        match &mut *self {
            Self::Tcp(stream) => Pin::new(stream).poll_write(cx, buf),
            Self::Other(stream) => Pin::new(stream).poll_write(cx, buf),
        }
    }

    fn poll_flush(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<std::io::Result<()>> {
        match &mut *self {
            Self::Tcp(stream) => Pin::new(stream).poll_flush(cx),
            Self::Other(stream) => Pin::new(stream).poll_flush(cx),
        }
    }

    fn poll_shutdown(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<std::io::Result<()>> {
        match &mut *self {
            Self::Tcp(stream) => Pin::new(stream).poll_shutdown(cx),
            Self::Other(stream) => Pin::new(stream).poll_shutdown(cx),
        }
    }
}

#[cfg(target_os = "linux")]
async fn copy_bidirectional_splice_tcp(
    client: TcpStream,
    backend: TcpStream,
    entry: Arc<ActiveConnEntry>,
    stats: Arc<StatsService>,
    mut cancel: oneshot::Receiver<()>,
) -> io::Result<(u64, u64)> {
    let client = client.into_std()?;
    let backend = backend.into_std()?;
    let job = crate::splice::SpliceReactor::global()?.submit(
        client,
        backend,
        Some(crate::splice::SpliceStats::new(entry, stats)),
    )?;
    let cancel_handle = job.cancel_handle();

    tokio::select! {
        result = job.wait() => result,
        _ = &mut cancel => {
            cancel_handle.cancel()?;
            Ok((0, 0))
        }
    }
}

async fn copy_bidirectional_blocking_tcp(
    client: TcpStream,
    backend: TcpStream,
    entry: Arc<ActiveConnEntry>,
    stats: Arc<StatsService>,
    mut cancel: oneshot::Receiver<()>,
) -> io::Result<(u64, u64)> {
    let client = client.into_std()?;
    let backend = backend.into_std()?;
    client.set_nonblocking(false)?;
    backend.set_nonblocking(false)?;

    let client_write = client.try_clone()?;
    let backend_write = backend.try_clone()?;
    let cancel_client = client.try_clone()?;
    let cancel_backend = backend.try_clone()?;
    let (done_tx, mut done_rx) = mpsc::unbounded_channel();
    let client_to_backend_tx = done_tx.clone();
    let client_to_backend_entry = entry.clone();
    let client_to_backend_stats = stats.clone();
    std::thread::spawn(move || {
        let result = blocking_copy_one_direction(
            client,
            backend_write,
            client_to_backend_entry,
            client_to_backend_stats,
            true,
            USERSPACE_COPY_BUF,
        );
        let _ = client_to_backend_tx.send((true, result));
    });

    std::thread::spawn(move || {
        let result = blocking_copy_one_direction(
            backend,
            client_write,
            entry,
            stats,
            false,
            USERSPACE_COPY_BUF,
        );
        let _ = done_tx.send((false, result));
    });

    let mut bytes_in = None;
    let mut bytes_out = None;
    let mut first_error = None;

    for _ in 0..2 {
        tokio::select! {
            result = done_rx.recv() => {
                let (inbound, result) = result.ok_or_else(|| {
                    io::Error::other("blocking copy thread exited without a result")
                })?;

                match result {
                    Ok(bytes) if inbound => bytes_in = Some(bytes),
                    Ok(bytes) => bytes_out = Some(bytes),
                    Err(err) => {
                        let _ = cancel_client.shutdown(Shutdown::Both);
                        let _ = cancel_backend.shutdown(Shutdown::Both);
                        if first_error.is_none() {
                            first_error = Some(err);
                        }
                    }
                }
            }
            _ = &mut cancel => {
                let _ = cancel_client.shutdown(Shutdown::Both);
                let _ = cancel_backend.shutdown(Shutdown::Both);
                return Ok((0, 0));
            }
        }
    }

    if let Some(err) = first_error {
        Err(err)
    } else {
        Ok((bytes_in.unwrap_or(0), bytes_out.unwrap_or(0)))
    }
}

fn blocking_copy_one_direction(
    mut reader: StdTcpStream,
    mut writer: StdTcpStream,
    entry: Arc<ActiveConnEntry>,
    stats: Arc<StatsService>,
    inbound: bool,
    buffer_size: usize,
) -> io::Result<u64> {
    let mut buffer = vec![0_u8; buffer_size];
    let mut total = 0_u64;
    let mut pending = 0_u64;

    loop {
        match reader.read(&mut buffer) {
            Ok(0) => {
                flush_direct_copy_bytes(&entry, &stats, inbound, &mut pending);
                let _ = writer.shutdown(Shutdown::Write);
                return Ok(total);
            }
            Ok(read) => {
                writer.write_all(&buffer[..read])?;

                let read = read as u64;
                total += read;
                pending += read;

                if pending >= MONITORED_STREAM_FLUSH_BYTES {
                    flush_direct_copy_bytes(&entry, &stats, inbound, &mut pending);
                }
            }
            Err(err) if err.kind() == io::ErrorKind::Interrupted => {}
            Err(err) => {
                flush_direct_copy_bytes(&entry, &stats, inbound, &mut pending);
                let _ = writer.shutdown(Shutdown::Write);
                return Err(err);
            }
        }
    }
}

fn flush_direct_copy_bytes(
    entry: &ActiveConnEntry,
    stats: &StatsService,
    inbound: bool,
    pending: &mut u64,
) {
    let delta = std::mem::take(pending);
    if delta == 0 {
        return;
    }

    if inbound {
        stats.update_bytes(&entry.id, delta, 0);
    } else {
        stats.update_bytes(&entry.id, 0, delta);
    }
}

fn parse_private_key_der(key_pem: &str) -> anyhow::Result<PrivateKeyDer<'static>> {
    let mut reader = BufReader::new(Cursor::new(key_pem.as_bytes()));
    if let Some(key) = rustls_pemfile::pkcs8_private_keys(&mut reader).next() {
        return Ok(PrivateKeyDer::Pkcs8(key?));
    }

    let mut reader = BufReader::new(Cursor::new(key_pem.as_bytes()));
    if let Some(key) = rustls_pemfile::rsa_private_keys(&mut reader).next() {
        return Ok(PrivateKeyDer::Pkcs1(key?));
    }

    let mut reader = BufReader::new(Cursor::new(key_pem.as_bytes()));
    if let Some(key) = rustls_pemfile::ec_private_keys(&mut reader).next() {
        return Ok(PrivateKeyDer::Sec1(key?));
    }

    Err(anyhow::anyhow!("Could not parse private key"))
}

fn normalize_listen_addr(addr: &str) -> String {
    let trimmed = addr.trim();
    if trimmed.starts_with(':') {
        format!("0.0.0.0{}", trimmed)
    } else {
        trimmed.to_string()
    }
}

struct MockBehavior {
    protocol: String,
    status_code: i32,
    delay_ms: i32,
    payload: Vec<u8>,
    tarpit: bool,
    drip_banner: bool,
    drip_interval_ms: i32,
    never_complete: bool,
}

impl MockBehavior {
    fn from_config(cfg: &MockConfig) -> Self {
        let preset = MockPreset::try_from(cfg.preset).unwrap_or(MockPreset::Unspecified);
        let mut b = Self {
            protocol: if cfg.protocol.is_empty() {
                "raw".to_string()
            } else {
                cfg.protocol.clone()
            },
            status_code: 200,
            delay_ms: cfg.delay_ms,
            payload: cfg.payload.clone(),
            tarpit: false,
            drip_banner: false,
            drip_interval_ms: 0,
            never_complete: false,
        };

        match preset {
            MockPreset::SshSecure => {
                b.protocol = "ssh".to_string();
                b.payload = b"SSH-2.0-OpenSSH_9.6p1 Debian-4\r\n".to_vec();
            }
            MockPreset::SshTarpit => {
                b.protocol = "ssh".to_string();
                b.payload = b"SSH-2.0-OpenSSH_9.6p1\r\n".to_vec();
                b.delay_ms = if cfg.delay_ms > 0 {
                    cfg.delay_ms
                } else {
                    30_000
                };
                b.drip_banner = true;
                b.drip_interval_ms = 100;
                b.never_complete = true;
                b.tarpit = true;
            }
            MockPreset::Http403 => {
                b.protocol = "http".to_string();
                b.status_code = 403;
                b.delay_ms = if cfg.delay_ms > 0 { cfg.delay_ms } else { 500 };
                b.payload = HTTP_403_BODY.as_bytes().to_vec();
            }
            MockPreset::Http404 => {
                b.protocol = "http".to_string();
                b.status_code = 404;
                b.delay_ms = if cfg.delay_ms > 0 { cfg.delay_ms } else { 500 };
                b.payload = HTTP_404_BODY.as_bytes().to_vec();
            }
            MockPreset::Http401 => {
                b.protocol = "http".to_string();
                b.status_code = 401;
                b.delay_ms = if cfg.delay_ms > 0 { cfg.delay_ms } else { 500 };
                b.payload = HTTP_401_BODY.as_bytes().to_vec();
            }
            MockPreset::RedisSecure => {
                b.protocol = "redis".to_string();
                b.delay_ms = if cfg.delay_ms > 0 { cfg.delay_ms } else { 500 };
            }
            MockPreset::MysqlSecure => {
                b.protocol = "mysql".to_string();
                b.delay_ms = if cfg.delay_ms > 0 { cfg.delay_ms } else { 1500 };
            }
            MockPreset::MysqlTarpit => {
                b.protocol = "mysql".to_string();
                b.tarpit = true;
                b.drip_banner = true;
                b.drip_interval_ms = 200;
                b.never_complete = true;
            }
            MockPreset::RdpSecure => {
                b.protocol = "rdp".to_string();
                b.delay_ms = if cfg.delay_ms > 0 { cfg.delay_ms } else { 2000 };
            }
            MockPreset::TelnetSecure => {
                b.protocol = "telnet".to_string();
                b.delay_ms = if cfg.delay_ms > 0 { cfg.delay_ms } else { 500 };
            }
            MockPreset::RawTarpit => {
                b.protocol = "raw".to_string();
                b.drip_banner = true;
                b.drip_interval_ms = 1000;
                b.never_complete = true;
                b.tarpit = true;
            }
            MockPreset::Unspecified => {}
        }
        b
    }
}

const HTTP_403_BODY: &str = "<!DOCTYPE html>\n<html><head><title>403 Forbidden</title></head>\n<body><h1>403 Forbidden</h1><p>Access denied.</p></body></html>\n";
const HTTP_404_BODY: &str = "<!DOCTYPE html>\n<html><head><title>404 Not Found</title></head>\n<body><h1>404 Not Found</h1><p>The requested resource was not found.</p></body></html>\n";
const HTTP_401_BODY: &str = "<!DOCTYPE html>\n<html><head><title>401 Unauthorized</title></head>\n<body><h1>401 Unauthorized</h1><p>Authentication required.</p></body></html>\n";

async fn drain_input<S>(stream: &mut S, timeout_ms: u64)
where
    S: AsyncRead + Unpin,
{
    let mut buf = [0u8; 4096];
    let _ = tokio::time::timeout(Duration::from_millis(timeout_ms), stream.read(&mut buf)).await;
}

async fn drip_write<S>(stream: &mut S, data: &[u8], interval_ms: i32) -> anyhow::Result<()>
where
    S: AsyncWrite + Unpin,
{
    for b in data {
        stream.write_all(&[*b]).await?;
        if interval_ms > 0 {
            tokio::time::sleep(Duration::from_millis(interval_ms as u64)).await;
        }
    }
    Ok(())
}

async fn hold_open<S>(stream: &mut S) -> anyhow::Result<()>
where
    S: AsyncRead + Unpin,
{
    let mut buf = [0u8; 1024];
    loop {
        match tokio::time::timeout(Duration::from_secs(300), stream.read(&mut buf)).await {
            Ok(Ok(0)) | Ok(Err(_)) | Err(_) => return Ok(()),
            Ok(Ok(_)) => tokio::time::sleep(Duration::from_secs(1)).await,
        }
    }
}

async fn mock_raw<S>(stream: &mut S, behavior: &MockBehavior) -> anyhow::Result<()>
where
    S: AsyncRead + AsyncWrite + Unpin,
{
    let payload = if behavior.payload.is_empty() {
        b"Access Denied\n".as_slice()
    } else {
        behavior.payload.as_slice()
    };
    if behavior.drip_banner {
        drip_write(stream, payload, behavior.drip_interval_ms).await?;
    } else {
        stream.write_all(payload).await?;
    }
    if behavior.never_complete {
        hold_open(stream).await?;
    }
    Ok(())
}

async fn mock_http<S>(stream: &mut S, behavior: &MockBehavior) -> anyhow::Result<()>
where
    S: AsyncRead + AsyncWrite + Unpin,
{
    drain_input(stream, 500).await;
    if behavior.tarpit {
        let body = if behavior.payload.is_empty() {
            generate_fake_page()
        } else {
            behavior.payload.clone()
        };
        let headers = http_response_head(200, body.len(), false);
        drip_write(
            stream,
            headers.as_bytes(),
            behavior.drip_interval_ms.max(500),
        )
        .await?;
        drip_write(stream, &body, behavior.drip_interval_ms.max(500) * 2).await?;
        return Ok(());
    }

    let body = if behavior.payload.is_empty() {
        default_http_body(behavior.status_code)
    } else {
        behavior.payload.clone()
    };
    let headers = http_response_head(behavior.status_code, body.len(), true);
    stream.write_all(headers.as_bytes()).await?;
    stream.write_all(&body).await?;
    Ok(())
}

fn http_response_head(status_code: i32, len: usize, close: bool) -> String {
    let status = match status_code {
        401 => "HTTP/1.1 401 Unauthorized",
        403 => "HTTP/1.1 403 Forbidden",
        404 => "HTTP/1.1 404 Not Found",
        500 => "HTTP/1.1 500 Internal Server Error",
        _ => "HTTP/1.1 200 OK",
    };
    let date = chrono::Utc::now().format("%a, %d %b %Y %H:%M:%S GMT");
    let mut headers = format!(
        "{status}\r\nContent-Type: text/html\r\nContent-Length: {len}\r\nServer: nginx\r\nDate: {date}\r\nConnection: {}\r\n",
        if close { "close" } else { "keep-alive" }
    );
    if status_code == 401 {
        headers.push_str("WWW-Authenticate: Basic realm=\"Restricted\"\r\n");
    }
    headers.push_str("\r\n");
    headers
}

fn default_http_body(status_code: i32) -> Vec<u8> {
    match status_code {
        401 => b"<html><body><h1>401 Unauthorized</h1></body></html>".to_vec(),
        403 => b"<html><body><h1>403 Forbidden</h1></body></html>".to_vec(),
        404 => b"<html><body><h1>404 Not Found</h1></body></html>".to_vec(),
        500 => b"<html><body><h1>500 Internal Server Error</h1></body></html>".to_vec(),
        _ => b"<html><body><h1>It works!</h1></body></html>".to_vec(),
    }
}

fn generate_fake_page() -> Vec<u8> {
    let mut body = String::from(
        "<!DOCTYPE html>\n<html>\n<head>\n<title>Welcome</title>\n<meta charset=\"utf-8\">\n</head>\n<body>\n<h1>Loading...</h1>\n",
    );
    for i in 0..100 {
        body.push_str(&format!("<!-- cache-id: {:032x} -->\n", i));
        body.push_str(
            "<div style=\"display:none\"><p>00000000000000000000000000000000</p></div>\n",
        );
    }
    body.push_str(
        "<script>setTimeout(function(){location.reload()},30000);</script>\n</body>\n</html>",
    );
    body.into_bytes()
}

async fn mock_ssh<S>(stream: &mut S, behavior: &MockBehavior) -> anyhow::Result<()>
where
    S: AsyncRead + AsyncWrite + Unpin,
{
    if behavior.tarpit {
        let interval = behavior.drip_interval_ms.max(1000);
        loop {
            drip_write(stream, b"0123456789abcdef0123456789abcdef\r\n", interval).await?;
        }
    }

    let banner = if behavior.payload.is_empty() {
        b"SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.5\r\n".as_slice()
    } else {
        behavior.payload.as_slice()
    };
    if behavior.drip_banner {
        drip_write(stream, banner, behavior.drip_interval_ms).await?;
    } else {
        stream.write_all(banner).await?;
    }
    if behavior.never_complete {
        hold_open(stream).await?;
    } else {
        drain_input(stream, 5000).await;
    }
    Ok(())
}

async fn mock_mysql<S>(stream: &mut S, behavior: &MockBehavior) -> anyhow::Result<()>
where
    S: AsyncRead + AsyncWrite + Unpin,
{
    send_mysql_handshake(stream).await?;
    drain_input(stream, 30_000).await;
    if behavior.tarpit {
        let mut delay = Duration::from_millis(500);
        let messages = [
            "Access denied for user 'root'@'localhost' (using password: YES)",
            "Access denied for user 'root'@'localhost' (using password: NO)",
            "Your password has expired. To log in you must change it using a client that supports expired passwords.",
            "Access denied for user 'admin'@'localhost'",
            "Plugin 'mysql_native_password' is not loaded",
            "Host 'localhost' is blocked because of many connection errors",
            "Access denied; you need the SUPER privilege for this operation",
        ];
        let mut seq = 2u8;
        let mut idx = 0usize;
        loop {
            tokio::time::sleep(delay).await;
            send_mysql_error(stream, 1045, "28000", messages[idx % messages.len()], seq).await?;
            drain_input(stream, 60_000).await;
            delay = (delay + Duration::from_millis(500)).min(Duration::from_secs(10));
            idx += 1;
            seq = seq.wrapping_add(1);
        }
    }
    send_mysql_error(
        stream,
        1045,
        "28000",
        "Access denied for user 'root'@'localhost'",
        2,
    )
    .await
}

async fn send_mysql_handshake<S>(stream: &mut S) -> anyhow::Result<()>
where
    S: AsyncWrite + Unpin,
{
    let mut payload = vec![0x0a];
    payload.extend_from_slice(b"5.7.21-log\0");
    payload.extend_from_slice(&[0x2d, 0x00, 0x00, 0x00]);
    payload.extend_from_slice(b"nitella1\0");
    payload.extend_from_slice(&[0xff, 0xf7, 0x21, 0x02, 0x00]);
    payload.extend_from_slice(&[0; 13]);
    let len = payload.len();
    let header = [
        (len & 0xff) as u8,
        ((len >> 8) & 0xff) as u8,
        ((len >> 16) & 0xff) as u8,
        0x00,
    ];
    stream.write_all(&header).await?;
    stream.write_all(&payload).await?;
    Ok(())
}

async fn send_mysql_error<S>(
    stream: &mut S,
    code: i32,
    state: &str,
    message: &str,
    seq: u8,
) -> anyhow::Result<()>
where
    S: AsyncWrite + Unpin,
{
    let mut payload = vec![0xff, (code & 0xff) as u8, ((code >> 8) & 0xff) as u8, b'#'];
    payload.extend_from_slice(state.as_bytes());
    payload.extend_from_slice(message.as_bytes());
    let len = payload.len();
    let header = [
        (len & 0xff) as u8,
        ((len >> 8) & 0xff) as u8,
        ((len >> 16) & 0xff) as u8,
        seq,
    ];
    stream.write_all(&header).await?;
    stream.write_all(&payload).await?;
    Ok(())
}

async fn mock_mssql<S>(stream: &mut S) -> anyhow::Result<()>
where
    S: AsyncWrite + Unpin,
{
    stream
        .write_all(&[
            0x04, 0x01, 0x00, 0x1a, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x10, 0x00, 0x06, 0x01,
            0x00, 0x16, 0x00, 0x01, 0xff, 0x0e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02,
        ])
        .await?;
    Ok(())
}

async fn mock_rdp<S>(stream: &mut S) -> anyhow::Result<()>
where
    S: AsyncWrite + Unpin,
{
    stream
        .write_all(&[
            0x03, 0x00, 0x00, 0x13, 0x0e, 0xd0, 0x00, 0x00, 0x12, 0x34, 0x00, 0x02, 0x01, 0x00,
            0x01, 0x00, 0x00, 0x00, 0x00,
        ])
        .await?;
    Ok(())
}

async fn mock_telnet<S>(stream: &mut S, behavior: &MockBehavior) -> anyhow::Result<()>
where
    S: AsyncRead + AsyncWrite + Unpin,
{
    let negotiation = [
        0xff, 0xfd, 0x18, 0xff, 0xfd, 0x20, 0xff, 0xfd, 0x23, 0xff, 0xfd, 0x27,
    ];
    if behavior.drip_banner {
        drip_write(stream, &negotiation, behavior.drip_interval_ms).await?;
    } else {
        stream.write_all(&negotiation).await?;
    }
    tokio::time::sleep(Duration::from_millis(100)).await;
    if behavior.tarpit {
        stream
            .write_all(b"\r\nUser Access Verification\r\n\r\n")
            .await?;
        loop {
            stream.write_all(b"Username: ").await?;
            drain_input(stream, 120_000).await;
            stream.write_all(b"Password: ").await?;
            drain_input(stream, 120_000).await;
            stream.write_all(b"\r\n% Login invalid\r\n\r\n").await?;
            tokio::time::sleep(Duration::from_millis(500)).await;
        }
    }
    stream
        .write_all(b"\r\nUser Access Verification\r\n\r\nUsername: ")
        .await?;
    Ok(())
}

async fn mock_redis<S>(stream: &mut S, behavior: &MockBehavior) -> anyhow::Result<()>
where
    S: AsyncRead + AsyncWrite + Unpin,
{
    if behavior.tarpit {
        let mut delay = Duration::from_millis(200);
        loop {
            let cmd = read_ascii_command(stream, 120_000).await?;
            if cmd.is_empty() {
                return Ok(());
            }
            tokio::time::sleep(delay).await;
            let upper = cmd.to_ascii_uppercase();
            if upper.contains("PING") {
                stream.write_all(b"+PONG\r\n").await?;
            } else if upper.contains("INFO") {
                let info = "# Server\r\nredis_version:6.2.6\r\nredis_mode:standalone\r\nos:Linux 5.4.0-generic x86_64\r\n";
                stream
                    .write_all(format!("${}\r\n{}\r\n", info.len(), info).as_bytes())
                    .await?;
            } else if upper.contains("COMMAND") {
                stream.write_all(b"*0\r\n").await?;
            } else if upper.contains("QUIT") {
                stream.write_all(b"-ERR unknown command 'QUIT'\r\n").await?;
            } else {
                stream
                    .write_all(b"-NOAUTH Authentication required.\r\n")
                    .await?;
            }
            delay = (delay + Duration::from_millis(300)).min(Duration::from_secs(8));
        }
    }

    loop {
        let cmd = read_ascii_command(stream, 60_000).await?;
        if cmd.is_empty() {
            return Ok(());
        }
        stream
            .write_all(b"-NOAUTH Authentication required.\r\n")
            .await?;
        if cmd.to_ascii_uppercase().contains("QUIT") {
            return Ok(());
        }
    }
}

async fn mock_smtp<S>(stream: &mut S, behavior: &MockBehavior) -> anyhow::Result<()>
where
    S: AsyncRead + AsyncWrite + Unpin,
{
    let banner = b"220 mail.example.com ESMTP Postfix (Ubuntu)\r\n";
    if behavior.tarpit || behavior.drip_banner {
        drip_write(stream, banner, behavior.drip_interval_ms.max(100)).await?;
    } else {
        stream.write_all(banner).await?;
    }
    if behavior.tarpit {
        loop {
            let cmd = read_ascii_command(stream, 300_000).await?;
            if cmd.is_empty() {
                return Ok(());
            }
            let upper = cmd.to_ascii_uppercase();
            tokio::time::sleep(Duration::from_millis(300)).await;
            if upper.starts_with("EHLO") || upper.starts_with("HELO") {
                stream.write_all(b"250-mail.example.com Hello\r\n250-SIZE 52428800\r\n250-8BITMIME\r\n250-PIPELINING\r\n250-AUTH PLAIN LOGIN XOAUTH2\r\n250-STARTTLS\r\n250 SMTPUTF8\r\n").await?;
            } else if upper.starts_with("MAIL FROM") || upper.starts_with("RCPT TO") {
                stream.write_all(b"250 2.1.0 Ok\r\n").await?;
            } else if upper.starts_with("DATA") {
                stream
                    .write_all(b"354 End data with <CR><LF>.<CR><LF>\r\n")
                    .await?;
            } else if upper.starts_with("QUIT") {
                tokio::time::sleep(Duration::from_secs(2)).await;
                stream.write_all(b"221 2.0.0 Bye\r\n").await?;
                return Ok(());
            } else {
                stream
                    .write_all(b"500 5.5.1 Error: command not recognized\r\n")
                    .await?;
            }
        }
    }

    loop {
        let cmd = read_ascii_command(stream, 60_000).await?;
        if cmd.is_empty() {
            return Ok(());
        }
        let upper = cmd.to_ascii_uppercase();
        if upper.starts_with("HELO") || upper.starts_with("EHLO") {
            stream.write_all(b"250-mail.example.com\r\n250-PIPELINING\r\n250-SIZE 10240000\r\n250-VRFY\r\n250-ETRN\r\n250-AUTH PLAIN LOGIN\r\n250-ENHANCEDSTATUSCODES\r\n250-8BITMIME\r\n250 DSN\r\n").await?;
        } else if upper.starts_with("QUIT") {
            stream.write_all(b"221 2.0.0 Bye\r\n").await?;
            return Ok(());
        } else if upper.starts_with("AUTH") {
            stream
                .write_all(b"535 5.7.8 Error: authentication failed\r\n")
                .await?;
        } else {
            stream
                .write_all(b"502 5.5.2 Error: command not recognized\r\n")
                .await?;
        }
    }
}

async fn read_ascii_command<S>(stream: &mut S, timeout_ms: u64) -> anyhow::Result<String>
where
    S: AsyncRead + Unpin,
{
    let mut buf = [0u8; 1024];
    let n = match tokio::time::timeout(Duration::from_millis(timeout_ms), stream.read(&mut buf))
        .await
    {
        Ok(Ok(0)) | Ok(Err(_)) | Err(_) => return Ok(String::new()),
        Ok(Ok(n)) => n,
    };
    Ok(String::from_utf8_lossy(&buf[..n]).to_string())
}

// RAII Guard to unregister connection and approval tracking
struct RateLimitReportGuard {
    limiter: Option<Arc<RateLimiter>>,
    ip: String,
    start: Instant,
}

impl Drop for RateLimitReportGuard {
    fn drop(&mut self) {
        if let Some(limiter) = &self.limiter {
            limiter.report_result(&self.ip, self.start.elapsed());
        }
    }
}

struct ConnectionGuard {
    conn_id: String,
    stats: Arc<StatsService>,
    approval_manager: Option<Arc<ApprovalManager>>,
    source_ip: String,
    rule_id: String,
    tls_session_id: String,
}

impl Drop for ConnectionGuard {
    fn drop(&mut self) {
        self.stats.unregister_connection(&self.conn_id);
        // Accumulate final bytes into approval cache entry
        if let Some(am) = &self.approval_manager {
            let am = am.clone();
            let source_ip = self.source_ip.clone();
            let rule_id = self.rule_id.clone();
            let tls_session_id = self.tls_session_id.clone();
            let conn_id = self.conn_id.clone();
            tokio::spawn(async move {
                am.remove_conn_id(&source_ip, &rule_id, &tls_session_id, &conn_id)
                    .await;
            });
        }
    }
}

// Monitored Stream Wrapper
struct MonitoredStream<S> {
    inner: S,
    entry: Arc<ActiveConnEntry>,
    stats: Arc<StatsService>,
    is_inbound: bool,
    pending_bytes: u64,
}

impl<S> MonitoredStream<S> {
    fn record_read(&mut self, delta: u64) {
        self.pending_bytes += delta;
        if self.pending_bytes >= MONITORED_STREAM_FLUSH_BYTES {
            self.flush_pending();
        }
    }

    fn flush_pending(&mut self) {
        let delta = std::mem::take(&mut self.pending_bytes);
        if delta == 0 {
            return;
        }

        if self.is_inbound {
            self.stats.update_bytes(&self.entry.id, delta, 0);
        } else {
            self.stats.update_bytes(&self.entry.id, 0, delta);
        }
    }
}

impl<S> Drop for MonitoredStream<S> {
    fn drop(&mut self) {
        self.flush_pending();
    }
}

impl<S: AsyncRead + Unpin> AsyncRead for MonitoredStream<S> {
    fn poll_read(
        mut self: Pin<&mut Self>,
        cx: &mut Context<'_>,
        buf: &mut ReadBuf<'_>,
    ) -> Poll<std::io::Result<()>> {
        let before = buf.filled().len();
        let poll = Pin::new(&mut self.inner).poll_read(cx, buf);
        let after = buf.filled().len();

        if after > before {
            let delta = (after - before) as u64;
            self.record_read(delta);
        }
        poll
    }
}

impl<S: AsyncWrite + Unpin> AsyncWrite for MonitoredStream<S> {
    fn poll_write(
        mut self: Pin<&mut Self>,
        cx: &mut Context<'_>,
        buf: &[u8],
    ) -> Poll<std::io::Result<usize>> {
        Pin::new(&mut self.inner).poll_write(cx, buf)
    }

    fn poll_flush(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<std::io::Result<()>> {
        Pin::new(&mut self.inner).poll_flush(cx)
    }

    fn poll_shutdown(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<std::io::Result<()>> {
        Pin::new(&mut self.inner).poll_shutdown(cx)
    }
}

#[cfg(test)]
mod tests {
    use super::{normalize_listen_addr, parse_private_key_der};

    #[test]
    fn normalize_listen_addr_accepts_go_style_port_only_addr() {
        assert_eq!(normalize_listen_addr(":8080"), "0.0.0.0:8080");
        assert_eq!(normalize_listen_addr("  :8081  "), "0.0.0.0:8081");
        assert_eq!(normalize_listen_addr("127.0.0.1:8080"), "127.0.0.1:8080");
    }

    #[test]
    fn parse_private_key_der_accepts_pkcs8_keys() {
        let key = rcgen::KeyPair::generate(&rcgen::PKCS_ED25519).unwrap();
        let key_pem = key.serialize_pem();

        assert!(parse_private_key_der(&key_pem).is_ok());
    }
}
