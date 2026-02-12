use std::net::SocketAddr;
use std::time::Duration;
use std::sync::Arc;
use tokio::net::{TcpListener, TcpStream};
use tokio::sync::{RwLock, oneshot};
use dashmap::DashMap;
use tokio::io::{AsyncRead, AsyncWrite, AsyncWriteExt, ReadBuf};
use tracing::{info, error, debug, warn};
use tokio_rustls::TlsAcceptor;
use rustls::ServerConfig;
use std::io::BufReader;
use std::pin::Pin;
use std::task::{Context, Poll};
use uuid::Uuid;

use crate::geoip::GeoIPService;
use crate::rules::RuleEngine;
use crate::stats::{StatsService, ActiveConnEntry};
use crate::proto::common::{ActionType, MockPreset, FallbackAction};
use crate::proto::proxy::{ClientAuthType, ActiveConnection, MockConfig};
use crate::process_proxy::ProcessProxyListener;
use crate::approval::{ApprovalManager, ApprovalReqData};

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
                l.close_connection(&conn_id);
                Ok(())
            },
            Self::Process(p) => p.close_connection(conn_id).await,
        }
    }
    
    pub async fn close_all_connections(&self) -> anyhow::Result<()> {
         match self {
            Self::Embedded(l) => {
                l.close_all_connections();
                Ok(())
            },
            Self::Process(p) => p.close_all_connections().await,
        }
    }
}

use std::sync::atomic::{AtomicI32, Ordering};
use crate::proto::proxy::HealthStatus;

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
            fallback_action: FallbackAction::try_from(fallback_action).unwrap_or(FallbackAction::Unspecified),
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
        client_auth: ClientAuthType
    ) -> anyhow::Result<Self> {
        if cert_pem.is_empty() || key_pem.is_empty() {
            return Ok(self);
        }

        let certs = rustls_pemfile::certs(&mut BufReader::new(cert_pem.as_bytes()))
            .collect::<Result<Vec<_>, _>>()?;
        
        let mut key_reader = BufReader::new(key_pem.as_bytes());
        let key = if let Ok(Some(k)) = rustls_pemfile::pkcs8_private_keys(&mut key_reader).next().transpose() {
            rustls::pki_types::PrivateKeyDer::Pkcs8(k)
        } else {
             return Err(anyhow::anyhow!("Could not parse private key"));
        };

        let mut config = ServerConfig::builder()
            .with_no_client_auth();

        if !ca_pem.is_empty() {
            let mut ca_reader = BufReader::new(ca_pem.as_bytes());
            let mut roots = rustls::RootCertStore::empty();
            for cert in rustls_pemfile::certs(&mut ca_reader) {
                roots.add(cert?)?;
            }
            
            let verifier = rustls::server::WebPkiClientVerifier::builder(Arc::new(roots)).build()?;

            config = match client_auth {
                ClientAuthType::ClientAuthRequire => ServerConfig::builder().with_client_cert_verifier(verifier),
                ClientAuthType::ClientAuthRequest | ClientAuthType::ClientAuthAuto => {
                    ServerConfig::builder().with_client_cert_verifier(verifier)
                },
                _ => ServerConfig::builder().with_no_client_auth(),
            };
        }

        let config = config.with_single_cert(certs, key)?;
        self.tls_acceptor = Some(TlsAcceptor::from(Arc::new(config)));
        
        Ok(self)
    }

    pub async fn bind(&self) -> anyhow::Result<TcpListener> {
        let listener = TcpListener::bind(&self.listen_addr).await?;
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
                Ok(tls_stream) => self.handle_stream(tls_stream, addr).await,
                Err(e) => {
                    debug!("TLS Handshake failed from {}: {}", addr, e);
                    Ok(())
                }
            }
        } else {
            self.handle_stream(socket, addr).await
        }
    }

    async fn handle_stream<S>(&self, mut client_stream: S, addr: SocketAddr) -> anyhow::Result<()> 
    where S: AsyncRead + AsyncWrite + Unpin {
        let conn_id = Uuid::new_v4().to_string();
        let ip = addr.ip();
        let ip_str = ip.to_string();

        let geo_info = self.geoip.lookup(&ip_str).await;

        let mut matched_rule = {
            let engine = self.local_rules.read().await;
            engine.evaluate(ip, &Some(geo_info.clone()))
        };
        
        if matched_rule.is_none() {
            let engine = self.global_rules.read().await;
            matched_rule = engine.evaluate(ip, &Some(geo_info.clone()));
        }

        let mut action = matched_rule.as_ref().map(|r| r.action()).unwrap_or(self.default_action);
        let rule_id = matched_rule.as_ref().map(|r| r.id.clone()).unwrap_or_else(|| "default".to_string());
        info!("[{}] Connection from {} => action={:?}, default_action={:?}, rule={}", self.name, addr, action, self.default_action, rule_id);
        
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

        // Handle Approval (matching Go's cache-first pattern)
        let mut approval_duration: Option<i64> = None;
        if action == ActionType::RequireApproval {
            // Check cache first — cached decisions skip the alert entirely
            if let Some(cached) = self.approval_manager.check_cache(&ip_str, &rule_id).await {
                if cached.allowed {
                    info!("Approval CACHED for {} (remaining={}s)", addr, cached.duration_seconds);
                    if cached.duration_seconds > 0 {
                        approval_duration = Some(cached.duration_seconds);
                    }
                    // Proceed as ALLOW
                } else {
                    info!("Approval CACHED DENY for {}", addr);
                    self.stats.record_block(&ip_str, &rule_id);
                    return Ok(());
                }
            } else {
                // Cache miss — request approval via Hub
                let req_data = ApprovalReqData {
                    id: Uuid::new_v4().to_string(),
                    proxy_id: self.id.clone(),
                    source_ip: ip_str.clone(),
                    rule_id: rule_id.clone(),
                    info: format!("Connection from {} to {}", addr, target),
                    created_at: chrono::Utc::now().timestamp(),
                };

                info!("Requesting approval for {}...", addr);
                self.stats.record_approval_request(&ip_str, &rule_id, &self.id, &req_data.id);

                match self.approval_manager.request_approval(req_data).await {
                    Err(e) => {
                        warn!("Approval rejected (rate limit): {} - {}", addr, e);
                        self.stats.record_block(&ip_str, &rule_id);
                        return Ok(());
                    }
                    Ok(result) if result.allowed => {
                        info!("Approval GRANTED for {} (duration={}s)", addr, result.duration_seconds);
                        if result.duration_seconds > 0 {
                            approval_duration = Some(result.duration_seconds);
                        }
                    }
                    Ok(_) => {
                        info!("Approval DENIED for {}", addr);
                        self.stats.record_block(&ip_str, &rule_id);
                        return Ok(());
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
            Some(geo_info),
        );
        
        // Register live byte counters with approval manager for real-time tracking
        if approval_duration.is_some() {
            self.approval_manager.set_conn_id(
                &ip_str, &rule_id, &conn_id,
                conn_entry.bytes_in.clone(),
                conn_entry.bytes_out.clone(),
            ).await;
        }

        // Ensure unregister on drop
        let _guard = ConnectionGuard {
            conn_id: conn_id.clone(),
            stats: self.stats.clone(),
            approval_manager: if approval_duration.is_some() { Some(self.approval_manager.clone()) } else { None },
            source_ip: ip_str.clone(),
            rule_id: rule_id.clone(),
        };

        match action {
            ActionType::Block => {
                info!("Blocking connection from {} (Rule: {:?})", addr, matched_rule.as_ref().map(|r| &r.name));
                self.stats.record_block(&ip_str, &rule_id);
                return Ok(());
            },
            ActionType::Mock => {
                info!("Mocking connection from {} (Rule: {:?})", addr, matched_rule.as_ref().map(|r| &r.name));
                if let Some(cfg) = mock_config {
                    if cfg.delay_ms > 0 {
                        tokio::time::sleep(std::time::Duration::from_millis(cfg.delay_ms as u64)).await;
                    }
                    if !cfg.payload.is_empty() {
                        let _ = client_stream.write_all(&cfg.payload).await;
                        let _ = client_stream.flush().await;
                    } else {
                        let preset = MockPreset::try_from(cfg.preset).unwrap_or(MockPreset::Unspecified);
                        if preset == MockPreset::Http403 {
                            let _ = client_stream.write_all(b"HTTP/1.1 403 Forbidden\r\nContent-Length: 9\r\n\r\nForbidden").await;
                        } else if preset == MockPreset::Http404 {
                            let _ = client_stream.write_all(b"HTTP/1.1 404 Not Found\r\nContent-Length: 9\r\n\r\nNot Found").await;
                        } else if preset == MockPreset::Http401 {
                            let _ = client_stream.write_all(b"HTTP/1.1 401 Unauthorized\r\nContent-Length: 12\r\n\r\nUnauthorized").await;
                        }
                        let _ = client_stream.flush().await;
                    }
                }
                return Ok(());
            },
            _ => {}
        }

        if target.is_empty() {
             warn!("No backend for connection from {}", addr);
             return Ok(());
        }

        // Health Check Enforcement
        let current_health = self.health_status.load(Ordering::Relaxed);
        if current_health == HealthStatus::Unhealthy as i32 {
             debug!("Backend {} is unhealthy, triggering fallback", target);
             // Fallback Logic (Deduplicated)
             return self.handle_fallback(client_stream, target).await;
        }

        // Connection with Timeout
        let backend_conn = match tokio::time::timeout(Duration::from_secs(3), TcpStream::connect(&target)).await {
            Ok(Ok(c)) => c,
            Ok(Err(e)) => {
                warn!("Failed to connect to backend {}: {}", target, e);
                return self.handle_fallback(client_stream, target).await;
            },
            Err(_) => {
                warn!("Connection to backend {} timed out", target);
                return self.handle_fallback(client_stream, target).await;
            }
        };

        // Wrap streams to count bytes
        let mut monitored_client = MonitoredStream {
            inner: client_stream,
            entry: conn_entry.clone(),
            stats: self.stats.clone(),
            is_inbound: true,
        };
        
        let mut monitored_backend = MonitoredStream {
            inner: backend_conn,
            entry: conn_entry.clone(),
            stats: self.stats.clone(),
            is_inbound: false,
        };

        // Cancellation handling
        let (tx, rx) = oneshot::channel();
        self.cancellations.insert(conn_id.clone(), tx);

        // Auto-close timer for approval duration
        if let Some(dur) = approval_duration {
            let cancellations = self.cancellations.clone();
            let cid = conn_id.clone();
            tokio::spawn(async move {
                tokio::time::sleep(Duration::from_secs(dur as u64)).await;
                if let Some((_, tx)) = cancellations.remove(&cid) {
                    info!("Approval expired after {}s, closing connection {}", dur, cid);
                    let _ = tx.send(());
                }
            });
        }

        let copy_fut = tokio::io::copy_bidirectional(&mut monitored_client, &mut monitored_backend);

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
    
    pub fn close_connection(&self, conn_id: &str) {
        if let Some((_, tx)) = self.cancellations.remove(conn_id) {
            let _ = tx.send(());
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
    where S: AsyncWrite + Unpin {
        if self.fallback_action == FallbackAction::Mock {
             if self.fallback_mock != MockPreset::Unspecified {
                let preset = self.fallback_mock;
                 if preset == MockPreset::Http403 {
                     let _ = client_stream.write_all(b"HTTP/1.1 403 Forbidden\r\nContent-Length: 9\r\n\r\nForbidden").await;
                 } else if preset == MockPreset::Http404 {
                     let _ = client_stream.write_all(b"HTTP/1.1 404 Not Found\r\nContent-Length: 9\r\n\r\nNot Found").await;
                 } else if preset == MockPreset::Http401 {
                     let _ = client_stream.write_all(b"HTTP/1.1 401 Unauthorized\r\nContent-Length: 12\r\n\r\nUnauthorized").await;
                 }
                 let _ = client_stream.flush().await;
            }
        }
        Ok(())
    }
}

// RAII Guard to unregister connection and approval tracking
struct ConnectionGuard {
    conn_id: String,
    stats: Arc<StatsService>,
    approval_manager: Option<Arc<ApprovalManager>>,
    source_ip: String,
    rule_id: String,
}

impl Drop for ConnectionGuard {
    fn drop(&mut self) {
        self.stats.unregister_connection(&self.conn_id);
        // Accumulate final bytes into approval cache entry
        if let Some(am) = &self.approval_manager {
            let am = am.clone();
            let source_ip = self.source_ip.clone();
            let rule_id = self.rule_id.clone();
            let conn_id = self.conn_id.clone();
            tokio::spawn(async move {
                am.remove_conn_id(&source_ip, &rule_id, &conn_id).await;
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
            if self.is_inbound {
                self.stats.update_bytes(&self.entry.id, delta, 0);
            } else {
                self.stats.update_bytes(&self.entry.id, 0, delta);
            }
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