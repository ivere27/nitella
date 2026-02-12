use tonic::transport::{Channel, ClientTlsConfig, Identity};
use crate::proto::hub::node_service_client::NodeServiceClient;
use crate::proto::hub::pairing_service_client::PairingServiceClient;
use crate::proto::hub::{
    PakeMessage, CommandResponse, ReceiveCommandsRequest, CommandResult,
    EncryptedMetrics, EncryptedLogEntry, HeartbeatRequest, NodeStatus,
    SignalMessage, Metrics,
};
use crate::proto::process::{Event, event};
use crate::proto::common::{SecureCommandPayload, Alert, EncryptedPayload};
use sha2::Digest;
use crate::proto::hub::EncryptedCommandPayload;
use crate::proto::proxy::{
    CreateProxyRequest, DeleteProxyRequest, EnableProxyRequest, DisableProxyRequest,
    UpdateProxyRequest, AddRuleRequest, RemoveRuleRequest, ListRulesRequest,
    GetActiveConnectionsRequest, CloseConnectionRequest, CloseAllConnectionsRequest,
    ReloadRulesRequest,
    BlockIpRequest, AllowIpRequest, RemoveGlobalRuleRequest, ResolveApprovalRequest,
    LookupIpRequest, CancelApprovalRequest,
    ApplyProxyRequest,
    ProxyStatus, ListProxiesResponse, StatsSummaryResponse, ListRulesResponse,
    GetActiveConnectionsResponse, CloseConnectionResponse, CloseAllConnectionsResponse,
    DeleteProxyResponse,
    RestartListenersResponse,
    EnableProxyResponse, DisableProxyResponse,
    UpdateProxyResponse,
    ReloadRulesResponse,
    ActiveApproval,
    ListActiveApprovalsResponse,
    ApplyProxyResponse,
    AppliedProxyStatus, GetAppliedProxiesResponse,
};
use crate::cpace::{CPaceSession, ROLE_NODE};
use crate::manager::ProxyManager;
use crate::cert_utils;
use crate::crypto;
use anyhow::{Result, anyhow};
use tracing::{info, warn, error, debug};
use std::path::Path;
use std::sync::Arc;
use std::collections::HashMap;
use std::time::Duration;
use tokio::fs;
use tokio::sync::{RwLock, mpsc, broadcast};
use std::str::FromStr;
use tokio::time;
use tokio_stream::wrappers::ReceiverStream;
use tokio_stream::StreamExt;
use ed25519_dalek::{SigningKey, VerifyingKey};
use tonic::service::Interceptor;
use tonic::codegen::InterceptedService;

use pkcs8::DecodePrivateKey;
use prost::Message;
use serde::{Serialize, Deserialize};

// WebRTC Imports
use webrtc::api::APIBuilder;
use webrtc::api::interceptor_registry::register_default_interceptors;
use webrtc::api::media_engine::MediaEngine;
use webrtc::data_channel::data_channel_message::DataChannelMessage;
use webrtc::peer_connection::configuration::RTCConfiguration;
use webrtc::peer_connection::peer_connection_state::RTCPeerConnectionState;
use webrtc::peer_connection::sdp::session_description::RTCSessionDescription;
use webrtc::ice_transport::ice_server::RTCIceServer;
use webrtc::peer_connection::sdp::sdp_type::RTCSdpType;
use webrtc::ice_transport::ice_candidate::RTCIceCandidateInit;


#[derive(Clone)]
pub struct HubInterceptor {
    pub user_id: Option<String>,
}

impl Interceptor for HubInterceptor {
    fn call(&mut self, mut request: tonic::Request<()>) -> Result<tonic::Request<()>, tonic::Status> {
        if let Some(uid) = &self.user_id {
            if let Ok(val) = tonic::metadata::MetadataValue::from_str(uid) {
                request.metadata_mut().insert("user-id", val);
            }
        }
        Ok(request)
    }
}

/// Command type constants from hub_common.proto
mod command_types {
    pub const UNSPECIFIED: i32 = 0;
    pub const ADD_RULE: i32 = 2;
    pub const REMOVE_RULE: i32 = 3;
    pub const GET_ACTIVE_CONNECTIONS: i32 = 4;
    pub const CLOSE_CONNECTION: i32 = 5;
    pub const CLOSE_ALL_CONNECTIONS: i32 = 6;
    pub const STATS_CONTROL: i32 = 7;
    pub const LIST_PROXIES: i32 = 8;
    pub const LIST_RULES: i32 = 9;
    pub const STATUS: i32 = 10;
    pub const GET_METRICS: i32 = 11;
    pub const APPLY_PROXY: i32 = 20;
    pub const UNAPPLY_PROXY: i32 = 21;
    pub const GET_APPLIED: i32 = 22;
    pub const PROXY_UPDATE: i32 = 23;
    pub const RESOLVE_APPROVAL: i32 = 30;
    pub const CREATE_PROXY: i32 = 40;
    pub const DELETE_PROXY: i32 = 41;
    pub const ENABLE_PROXY: i32 = 42;
    pub const DISABLE_PROXY: i32 = 43;
    pub const UPDATE_PROXY: i32 = 44;
    pub const RESTART_LISTENERS: i32 = 45;
    pub const RELOAD_RULES: i32 = 46;
    pub const BLOCK_IP: i32 = 50;
    pub const ALLOW_IP: i32 = 51;
    pub const LIST_GLOBAL_RULES: i32 = 52;
    pub const REMOVE_GLOBAL_RULE: i32 = 53;
    pub const CONFIGURE_GEOIP: i32 = 60;
    pub const GET_GEOIP_STATUS: i32 = 61;
    pub const LOOKUP_IP: i32 = 62;
    pub const LIST_ACTIVE_APPROVALS: i32 = 70;
    pub const CANCEL_APPROVAL: i32 = 71;
}

/// Derive emoji fingerprint from data (matches Go's pairing.DeriveFingerprint)
fn derive_fingerprint(data: &[u8]) -> String {
    let hash = sha2::Sha256::digest(data);

    // Must match Go's qr.go emoji list exactly
    const EMOJIS: &[&str] = &[
        "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼",
        "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔",
        "🐧", "🐦", "🐤", "🦆", "🦅", "🦉", "🦇", "🐺",
        "🐗", "🐴", "🦄", "🐝", "🐛", "🦋", "🐌", "🐞",
        "🌸", "🌺", "🌻", "🌹", "🌷", "🌼", "🌿", "🍀",
        "🍎", "🍊", "🍋", "🍇", "🍓", "🍒", "🍑", "🥝",
        "🌙", "⭐", "🌟", "✨", "⚡", "🔥", "🌈", "☀️",
        "🎸", "🎹", "🎺", "🎷", "🥁", "🎻", "🎤", "🎧",
    ];

    let mut result = String::new();
    for i in 0..4 {
        let idx = (hash[i * 2] as usize) % EMOJIS.len();
        result.push_str(EMOJIS[idx]);
    }
    result
}

/// Extract CommonName from a PEM-encoded certificate
fn extract_common_name_from_pem(pem_str: &str) -> Option<String> {
    use x509_parser::prelude::FromDer;
    let pem_data = pem::parse(pem_str.as_bytes()).ok()?;
    let (_, cert) = x509_parser::prelude::X509Certificate::from_der(pem_data.contents()).ok()?;
    for rdn in cert.subject().iter() {
        for attr in rdn.iter() {
            // OID 2.5.4.3 = commonName
            if attr.attr_type().to_string() == "2.5.4.3" {
                return attr.as_str().ok().map(|s| s.to_string());
            }
        }
    }
    None
}

/// Applied proxy tracking for persistence
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct AppliedProxy {
    pub proxy_id: String,
    pub revision_num: i64,
    pub config_hash: String,
    pub applied_at: i64, // Unix timestamp
    pub status: String,
    pub error_msg: Option<String>,
    pub listener_ids: Vec<String>,
}

pub struct HubClient {
    hub_addr: String,
    data_dir: String,
    node_name: String,
    manager: Arc<ProxyManager>,
    client: Option<NodeServiceClient<InterceptedService<Channel, HubInterceptor>>>,
    applied_proxies: Arc<RwLock<HashMap<String, AppliedProxy>>>,
    signing_key: Option<SigningKey>,
    viewer_pubkey: Option<VerifyingKey>,
    ca_pubkey: Option<VerifyingKey>,
    replay_cache: HashMap<String, i64>,
    start_time: std::time::Instant,
    log_rx: Option<mpsc::Receiver<Vec<u8>>>,
    stun_server: Option<String>,
    ca_cert_path: Option<String>,
    event_rx: Option<broadcast::Receiver<Event>>,
    user_id: Option<String>,
    p2p_enabled: bool,
    /// Shared with push_metrics_loop: only push metrics when someone is actively viewing
    stats_streaming_until: Arc<RwLock<tokio::time::Instant>>,
}

impl HubClient {
    pub fn new(
        hub_addr: String, 
        data_dir: String, 
        node_name: String, 
        manager: Arc<ProxyManager>,
        stun_server: Option<String>,
        ca_cert_path: Option<String>,
        event_rx: Option<broadcast::Receiver<Event>>,
    ) -> Self {
        Self {
            hub_addr,
            data_dir,
            node_name,
            manager,
            client: None,
            applied_proxies: Arc::new(RwLock::new(HashMap::new())),
            signing_key: None,
            viewer_pubkey: None,
            ca_pubkey: None,
            replay_cache: HashMap::new(),
            user_id: None,
            p2p_enabled: true,
            stats_streaming_until: Arc::new(RwLock::new(tokio::time::Instant::now())),
            start_time: std::time::Instant::now(),
            log_rx: None,
            stun_server,
            ca_cert_path,
            event_rx,
        }
    }

    pub fn with_user_id(mut self, user_id: Option<String>) -> Self {
        self.user_id = user_id;
        self
    }

    pub fn with_p2p(mut self, enabled: bool) -> Self {
        self.p2p_enabled = enabled;
        self
    }

    pub fn set_log_receiver(&mut self, rx: mpsc::Receiver<Vec<u8>>) {
        self.log_rx = Some(rx);
    }

    pub async fn run(&mut self, pairing_code: Option<String>) -> Result<()> {
        // Match Go's behavior: always pair when --pair is explicitly provided,
        // even if identity files already exist (re-pairing).
        if let Some(code) = &pairing_code {
            self.pair(code).await?;
        } else if !self.has_identity().await {
            return Err(anyhow!("Node not paired. Provide --pair <code>"));
        }

        // Load applied proxies from disk
        self.load_applied_proxies().await;
        
        // Load signing key
        self.signing_key = Some(self.load_private_key().await?);
        
        // Load viewer public key if available
        self.load_viewer_pubkey().await;

        // Connect with retry — after pairing, the CLI's RegisterNodeWithCert()
        // may still be in-flight. The connect() only builds the channel; auth
        // is checked on the first RPC. So we probe with a heartbeat to verify.
        for attempt in 0..5u32 {
            self.connect().await?;
            // Probe with heartbeat to check auth
            if let Some(client) = &mut self.client {
                let req = HeartbeatRequest {
                    node_id: self.node_name.clone(),
                    status: NodeStatus::Online as i32,
                    uptime_seconds: self.start_time.elapsed().as_secs() as i64,
                };
                match client.heartbeat(req).await {
                    Ok(_) => {
                        info!("[Hub] Auth probe succeeded");
                        break;
                    }
                    Err(e) => {
                        if attempt < 4 {
                            let delay = Duration::from_secs(1 << attempt);
                            warn!("[Hub] Auth probe failed (attempt {}): {}. Retrying in {:?}...", attempt + 1, e, delay);
                            self.client = None;
                            tokio::time::sleep(delay).await;
                        } else {
                            return Err(anyhow!("Hub auth failed after retries: {}", e));
                        }
                    }
                }
            }
        }

        // Start background tasks
        if let Some(client) = &self.client {
            // Heartbeat Task
            let hb_client = client.clone();
            let hb_node = self.node_name.clone();
            let start = self.start_time;
            tokio::spawn(Self::heartbeat_loop(hb_client, hb_node, start));

            // P2P Signaling Task
            if self.p2p_enabled {
                let p2p_client = client.clone();
                let p2p_node = self.node_name.clone();
                let p2p_manager = self.manager.clone();
                let p2p_stun = self.stun_server.clone();
                let p2p_applied = self.applied_proxies.clone();
                let p2p_data_dir = self.data_dir.clone();
                
                tokio::spawn(Self::p2p_signaling_loop(
                    p2p_client, 
                    p2p_node, 
                    p2p_manager, 
                    p2p_stun,
                    p2p_applied,
                    p2p_data_dir
                ));
            }
            
            // Metrics Task
            if let (Some(v_pk), Some(s_key)) = (&self.viewer_pubkey, &self.signing_key) {
                let m_client = client.clone();
                let m_manager = self.manager.clone();
                let m_node = self.node_name.clone();
                let m_vpk = v_pk.clone();
                let m_skey = s_key.clone();
                
                let fingerprint = self.get_fingerprint();
                let m_streaming = self.stats_streaming_until.clone();

                tokio::spawn(Self::push_metrics_loop(m_client, m_manager, m_node, m_vpk, m_skey, fingerprint.clone(), m_streaming));
                
                // Events Task (if receiver exists)
                if let Some(event_rx) = self.event_rx.take() {
                    let e_client = client.clone();
                    let e_node = self.node_name.clone();
                    let e_vpk = v_pk.clone();
                    let e_skey = s_key.clone();
                    let e_fingerprint = fingerprint.clone();
                    
                    tokio::spawn(Self::push_events_loop(e_client, event_rx, e_node, e_vpk, e_skey, e_fingerprint));
                }



                // Logs Task (if receiver exists)
                if let Some(log_rx) = self.log_rx.take() {
                    let l_client = client.clone();
                    let l_node = self.node_name.clone();
                    let l_vpk = v_pk.clone();
                    let l_skey = s_key.clone();
                    let l_fingerprint = fingerprint;
                    
                    tokio::spawn(Self::push_logs_loop(l_client, log_rx, l_node, l_vpk, l_skey, l_fingerprint));
                }
            }
        }

        self.command_loop().await?;
        Ok(())
    }

    // ... existing methods ...

    // === Streaming & Background Tasks ===

    pub async fn push_alert(&mut self, severity: &str, title: &str, description: &str, metadata: HashMap<String, String>) {
        // Encrypt alert content if viewer key exists (do this BEFORE borrowing client)
        let encrypted = if let (Some(viewer_pk), Some(signing_key)) = (&self.viewer_pubkey, &self.signing_key) {
            let fingerprint = self.get_fingerprint();
            // Combine title/desc for encryption (simple JSON)
            let content = serde_json::json!({
                "title": title,
                "description": description
            }).to_string();
            
            match crypto::encrypt(content.as_bytes(), viewer_pk, signing_key, &fingerprint) {
                Ok(enc) => Some(enc),
                Err(e) => {
                    warn!("[Hub] Failed to encrypt alert: {}", e);
                    None
                }
            }
        } else {
            None
        };

        if let Some(client) = self.client.as_mut() {
            let alert = Alert {
                id: uuid::Uuid::new_v4().to_string(),
                node_id: self.node_name.clone(),
                severity: severity.to_string(),
                timestamp_unix: chrono::Utc::now().timestamp(),
                acknowledged: false,
                encrypted: encrypted.map(|e| EncryptedPayload {
                    ephemeral_pubkey: e.ephemeral_pubkey,
                    nonce: e.nonce,
                    ciphertext: e.ciphertext,
                    sender_fingerprint: e.sender_fingerprint,
                    signature: e.signature,
                    algorithm: e.algorithm,
                }),
                metadata,
            };

            if let Err(e) = client.push_alert(alert).await {
                 error!("[Hub] Failed to push alert: {}", e);
            }
        }
    }

    async fn heartbeat_loop(mut client: NodeServiceClient<InterceptedService<Channel, HubInterceptor>>, node_name: String, start_time: std::time::Instant) {
        let mut interval = time::interval(Duration::from_secs(30));
        loop {
            interval.tick().await;
            
            let uptime = start_time.elapsed().as_secs() as i64;
            
            let req = HeartbeatRequest {
                node_id: node_name.clone(),
                status: NodeStatus::Online as i32,
                uptime_seconds: uptime,
            };
            
            match client.heartbeat(req).await {
                Ok(resp) => {
                    let resp = resp.into_inner();
                    if resp.config_changed {
                        info!("[Hub] Heartbeat: Config changed, requesting update...");
                    }
                },
                Err(e) => error!("[Hub] Heartbeat failed: {}", e),
            }
        }
    }

    async fn push_metrics_loop(
        mut client: NodeServiceClient<InterceptedService<Channel, HubInterceptor>>,
        manager: Arc<ProxyManager>,
        node_name: String,
        viewer_pk: VerifyingKey,
        signing_key: SigningKey,
        fingerprint: String,
        stats_streaming_until: Arc<RwLock<tokio::time::Instant>>,
    ) {
        // Use persistent stream like Go's pushMetricsLoop
        let (tx, rx) = mpsc::channel::<EncryptedMetrics>(10);
        let outbound = ReceiverStream::new(rx);

        let send_task = tokio::spawn(async move {
            if let Err(e) = client.push_metrics(outbound).await {
                error!("[Hub] PushMetrics stream failed: {}", e);
            }
        });

        let mut interval = time::interval(Duration::from_secs(5));
        loop {
            interval.tick().await;

            // Only push metrics when someone is actively viewing (matches Go's statsStreamingUntil)
            {
                let until = stats_streaming_until.read().await;
                if tokio::time::Instant::now() >= *until {
                    continue;
                }
            }

            // Gather metrics
            let proxies = manager.list_proxies().await;
            let mut active_conns: i64 = 0;
            let mut total_conns: i64 = 0;
            let mut total_in: i64 = 0;
            let mut total_out: i64 = 0;

            for p in &proxies {
                active_conns += p.active_connections;
                total_conns += p.total_connections;
                total_in += p.bytes_in;
                total_out += p.bytes_out;
            }

            // Serialize as proto Metrics (matches Go's proto.Marshal(plainMetrics))
            let plain_metrics = Metrics {
                node_id: node_name.clone(),
                timestamp: Some(prost_types::Timestamp::from(std::time::SystemTime::now())),
                connections_active: active_conns,
                connections_total: total_conns,
                bytes_in: total_in,
                bytes_out: total_out,
                ..Default::default()
            };
            let metrics_bytes = plain_metrics.encode_to_vec();

            match crypto::encrypt(&metrics_bytes, &viewer_pk, &signing_key, &fingerprint) {
                Ok(enc_payload) => {
                    let enc_metrics = EncryptedMetrics {
                        node_id: node_name.clone(),
                        timestamp: Some(prost_types::Timestamp::from(std::time::SystemTime::now())),
                        encrypted: Some(enc_payload),
                    };

                    if tx.send(enc_metrics).await.is_err() {
                        error!("[Hub] Metrics stream closed");
                        break;
                    }
                },
                Err(e) => error!("[Hub] Failed to encrypt metrics: {}", e),
            }
        }
        send_task.abort();
    }

    async fn push_events_loop(
        mut client: NodeServiceClient<InterceptedService<Channel, HubInterceptor>>,
        mut rx: broadcast::Receiver<Event>,
        node_name: String,
        viewer_pk: VerifyingKey,
        signing_key: SigningKey,
        fingerprint: String
    ) {
        loop {
             match rx.recv().await {
                 Ok(event) => {
                     // Check if it is PendingApproval
                     if let Some(event::Type::Connection(conn_event)) = event.r#type {
                         if conn_event.event_type == crate::proto::proxy::EventType::PendingApproval as i32 {
                             // Construct Alert
                             let req_id = conn_event.conn_id;
                             let proxy_id = conn_event.target_addr; // Mapped from stats.rs
                             let rule_id = conn_event.rule_matched;
                             let source_ip = conn_event.source_ip;
                             
                             let title = "Approval Requested";
                             let description = format!("Connection from {} requires approval.", source_ip);
                             
                             let metadata = HashMap::from([
                                 ("req_id".to_string(), req_id.clone()),
                                 ("proxy_id".to_string(), proxy_id),
                                 ("rule_id".to_string(), rule_id),
                                 ("source_ip".to_string(), source_ip),
                             ]);

                             let content = serde_json::json!({
                                "title": title,
                                "description": description
                             }).to_string();

                             let encrypted = match crypto::encrypt(content.as_bytes(), &viewer_pk, &signing_key, &fingerprint) {
                                 Ok(enc) => Some(enc),
                                 Err(e) => { error!("[Hub] Encrypt alert failed: {}", e); None }
                             };
                             
                             let alert = Alert {
                                 id: req_id.clone(),
                                 node_id: node_name.clone(),
                                 severity: "info".to_string(),
                                 timestamp_unix: chrono::Utc::now().timestamp(),
                                 acknowledged: false,
                                 encrypted: encrypted.map(|e| EncryptedPayload {
                                     ephemeral_pubkey: e.ephemeral_pubkey,
                                     nonce: e.nonce,
                                     ciphertext: e.ciphertext,
                                     sender_fingerprint: e.sender_fingerprint,
                                     signature: e.signature,
                                     algorithm: e.algorithm,
                                 }),
                                 metadata,
                             };
                             
                             if let Err(e) = client.push_alert(alert).await {
                                 error!("[Hub] Failed to push alert: {}", e);
                             } else {
                                 info!("[Hub] Pushed approval alert for {}", req_id);
                             }
                         }
                     }
                 },
                 Err(broadcast::error::RecvError::Lagged(_)) => {
                     warn!("[Hub] Event loop lagged, missed messages");
                 },
                 Err(broadcast::error::RecvError::Closed) => {
                     break;
                 }
             }
        }
    }

    async fn push_logs_loop(
        mut client: NodeServiceClient<InterceptedService<Channel, HubInterceptor>>,
        rx: mpsc::Receiver<Vec<u8>>,
        node_name: String,
        viewer_pk: VerifyingKey,
        signing_key: SigningKey,
        fingerprint: String
    ) {
        let outbound = ReceiverStream::new(rx).filter_map(move |log_bytes| {
            let node_name = node_name.clone();
            let viewer_pk = viewer_pk.clone();
            let signing_key = signing_key.clone();
            let fingerprint = fingerprint.clone();
            
            let content = String::from_utf8_lossy(&log_bytes).to_string();
            // Encrypt
            match crypto::encrypt(content.as_bytes(), &viewer_pk, &signing_key, &fingerprint) {
                Ok(enc) => Some(EncryptedLogEntry {
                    node_id: node_name,
                    timestamp: Some(prost_types::Timestamp::from(std::time::SystemTime::now())),
                    encrypted: Some(enc),
                }),
                Err(e) => {
                    error!("[Hub] Failed to encrypt log: {}", e);
                    None
                }
            }
        });
        
        if let Err(e) = client.push_logs(outbound).await {
             error!("[Hub] PushLogs stream failed: {}", e);
        }
    }

    async fn has_identity(&self) -> bool {
        let cert = Path::new(&self.data_dir).join("node.crt");
        let key = Path::new(&self.data_dir).join("node.key");
        cert.exists() && key.exists()
    }

    async fn build_channel(&self) -> Result<Channel> {
        let mut addr = self.hub_addr.clone();
        if !addr.starts_with("http://") && !addr.starts_with("https://") {
            addr = format!("https://{}", addr);
        }

        let cert_path = Path::new(&self.data_dir).join("node.crt");
        let key_path = Path::new(&self.data_dir).join("node.key");

        let mut tls = ClientTlsConfig::new();

        // Load client identity if available (not available during pairing)
        if cert_path.exists() && key_path.exists() {
             if let Ok(cert_pem) = fs::read(&cert_path).await {
                 if let Ok(key_pem) = fs::read(&key_path).await {
                     let identity = Identity::from_pem(cert_pem, key_pem);
                     tls = tls.identity(identity);
                 }
             }
        }

        // Load Hub TLS CA: Priority 1: Explicit flag, Priority 2: hub_ca.crt in data dir
        // NOTE: hub_ca.crt is the Hub's TLS CA (for verifying the Hub's server cert)
        //       cli_ca.crt is the CLI/admin CA (for E2E crypto, NOT for TLS)
        let effective_ca_path = if let Some(p) = &self.ca_cert_path {
            Path::new(p).to_path_buf()
        } else {
             Path::new(&self.data_dir).join("hub_ca.crt")
        };

        if effective_ca_path.exists() {
            info!("[Hub] Loading Hub TLS CA from {:?}", effective_ca_path);
            let ca_pem = fs::read(&effective_ca_path).await?;
            let ca = tonic::transport::Certificate::from_pem(ca_pem);
            tls = tls.ca_certificate(ca);
        }

        let channel = Channel::from_shared(addr)?
            .tls_config(tls.domain_name("localhost"))?
            .connect_timeout(Duration::from_secs(10))
            .connect()
            .await?;

        Ok(channel)
    }

    async fn connect(&mut self) -> Result<()> {
        let channel = match self.build_channel().await {
            Ok(c) => c,
            Err(e) => {
                 error!("[Hub] Connect failed details: {:?}", e);
                 return Err(anyhow!("Transport error: {}", e));
            }
        };

        let interceptor = HubInterceptor { user_id: self.user_id.clone() };
        let service = NodeServiceClient::with_interceptor(channel, interceptor);

        self.client = Some(service);
        info!("Connected to Hub at {}", self.hub_addr);
        info!("[Hub] Hub integration initialized with mTLS");
        info!("[Hub] Waiting for commands... (no listening ports until configured)");
        Ok(())
    }

    /// Ensure Hub TLS CA is available (matches Go's ensureHubCA).
    /// Priority: 1) Explicit --ca-cert flag, 2) Cached hub_ca.crt, 3) TOFU probe
    async fn ensure_hub_ca(&self) -> Result<Vec<u8>> {
        // 1. Explicit flag
        if let Some(p) = &self.ca_cert_path {
            let data = fs::read(p).await
                .map_err(|e| anyhow!("Failed to read CA cert from {}: {}", p, e))?;
            info!("[Hub] Using explicit CA cert: {}", p);
            return Ok(data);
        }

        // 2. Cached hub_ca.crt
        let cached_path = Path::new(&self.data_dir).join("hub_ca.crt");
        if cached_path.exists() {
            let data = fs::read(&cached_path).await?;
            info!("[Hub] Using cached Hub CA: {:?}", cached_path);
            return Ok(data);
        }

        // 3. TOFU probe
        info!("[Hub] No Hub CA found. Probing {} for TOFU...", self.hub_addr);
        let info = crate::hubca::probe_hub_ca(&self.hub_addr).await
            .map_err(|e| anyhow!("Failed to probe Hub CA: {}", e))?;

        println!();
        println!("╔══════════════════════════════════════════════════════════════╗");
        println!("║                   SECURITY WARNING (TOFU)                    ║");
        println!("╠══════════════════════════════════════════════════════════════╣");
        println!("║  Trusting Hub CA for the first time. Verify this matches!    ║");
        let fp_len = info.fingerprint.len();
        if fp_len > 46 {
            println!("║  Fingerprint: {:<46} ║", &info.fingerprint[..46]);
            println!("║               {:<46} ║", &info.fingerprint[46..]);
        } else {
            println!("║  Fingerprint: {:<46} ║", info.fingerprint);
        }
        println!("║  Emoji Hash:  {:<46} ║", info.emoji_hash);
        println!("║                                                              ║");
        println!("╚══════════════════════════════════════════════════════════════╝");
        println!();

        // Save for future use
        fs::write(&cached_path, &info.ca_pem).await?;
        info!("Saved Hub TLS CA to {:?}", cached_path);

        Ok(info.ca_pem)
    }

    async fn pair(&mut self, code: &str) -> Result<()> {
        info!("Starting Pairing with code: {}", code);

        // Ensure data dir exists
        fs::create_dir_all(&self.data_dir).await?;

        // 1. Generate Node Key & CSR
        info!("Generating node identity...");
        let (key_pem, key_pair) = cert_utils::generate_node_key()?;
        let csr_pem = cert_utils::generate_csr(key_pair, &self.node_name)?;

        // Save Private Key immediately
        fs::write(Path::new(&self.data_dir).join("node.key"), &key_pem).await?;

        // 2. Resolve Hub CA (TOFU if needed) — matches Go's ensureHubCA()
        let hub_ca_pem = self.ensure_hub_ca().await?;

        // 3. Connect to Hub for pairing (server-TLS only, NO client cert)
        // Hub uses RequestClientCert — Go connects without client cert during pairing.
        // We must NOT set .identity() here (node doesn't have a cert yet).
        let mut addr = self.hub_addr.clone();
        if !addr.starts_with("http://") && !addr.starts_with("https://") {
            addr = format!("https://{}", addr);
        }

        let tls = ClientTlsConfig::new()
            .ca_certificate(tonic::transport::Certificate::from_pem(&hub_ca_pem))
            .domain_name("localhost");

        info!("[Pairing] Connecting to Hub at {}...", addr);
        let channel = tokio::time::timeout(
            Duration::from_secs(10),
            Channel::from_shared(addr)?
                .tls_config(tls)?
                .connect_timeout(Duration::from_secs(10))
                .connect()
        ).await
        .map_err(|_| anyhow!("Connection to Hub timed out (10s)"))?
        .map_err(|e| anyhow!("Failed to connect to Hub: {}", e))?;

        info!("[Pairing] Connected to Hub");

        let mut client = PairingServiceClient::new(channel);

        // 3. Start PAKE Session
        let mut session = CPaceSession::new(ROLE_NODE, code.as_bytes(), None)?;
        let init_msg = session.get_public_value();

        // Proto message type constants (must match hub_mobile.proto)
        const MSG_TYPE_SPAKE2_INIT: i32 = 1;
        // const MSG_TYPE_SPAKE2_REPLY: i32 = 2;
        const MSG_TYPE_ENCRYPTED: i32 = 3;
        const MSG_TYPE_ERROR: i32 = 4;

        // 4. Start Bidirectional Stream
        // IMPORTANT: Pre-load the INIT message into the channel BEFORE calling pake_exchange.
        // The Hub's PakeExchange handler does stream.Recv() first (to determine role/session),
        // and only starts relaying after that. If we await pake_exchange() without sending
        // the first message, we deadlock: Hub waits for our message, we wait for Hub's response.
        let (tx, rx) = tokio::sync::mpsc::channel(10);
        tx.send(PakeMessage {
            session_code: code.to_string(),
            role: ROLE_NODE.to_string(),
            r#type: MSG_TYPE_SPAKE2_INIT,
            spake2_data: init_msg.to_vec(),
            ..Default::default()
        }).await?;

        let request_stream = tokio_stream::wrappers::ReceiverStream::new(rx);
        let response = client.pake_exchange(request_stream).await?;
        let mut resp_stream = response.into_inner();

        info!("[Pairing] Waiting for CLI...");

        // 6. Recv CLI Init
        let cli_msg = resp_stream.message().await?.ok_or(anyhow!("Stream closed"))?;
        if cli_msg.r#type == MSG_TYPE_ERROR {
             return Err(anyhow!("CLI Error: {}", cli_msg.error_message));
        }
        session.set_peer_public(&cli_msg.spake2_data)?;

        // 7. Recv CLI Reply (Confirmation)
        let cli_reply = resp_stream.message().await?.ok_or(anyhow!("Stream closed"))?;
        if cli_reply.r#type == MSG_TYPE_ERROR {
             return Err(anyhow!("CLI Error: {}", cli_reply.error_message));
        }

        // Display PAKE verification emoji (matches Go's display)
        let emoji = session.derive_confirmation_emoji();
        println!();
        println!("╔══════════════════════════════════════════════════════════════╗");
        println!("║                    PAKE VERIFICATION                          ║");
        println!("╠══════════════════════════════════════════════════════════════╣");
        println!("║    Verification emoji: {:<38}  ║", emoji);
        println!("║                                                                ║");
        println!("║    Verify this matches what the CLI displays!                 ║");
        println!("╚══════════════════════════════════════════════════════════════╝");
        println!();

        // 8. Encrypt & Send CSR
        let (enc_csr, nonce) = session.encrypt(csr_pem.as_bytes())?;

        // Display NODE IDENTITY INFO (matches Go's display)
        let csr_fingerprint = derive_fingerprint(csr_pem.as_bytes());
        let csr_hash = sha2::Sha256::digest(csr_pem.as_bytes());
        let csr_hash_str = hex::encode(csr_hash);

        println!();
        println!("╔══════════════════════════════════════════════════════════════╗");
        println!("║                  NODE IDENTITY INFO                          ║");
        println!("╠══════════════════════════════════════════════════════════════╣");
        println!("║  Fingerprint: {:<46} ║", csr_fingerprint);
        println!("║  Hash:        {:<46} ║", &csr_hash_str[..std::cmp::min(46, csr_hash_str.len())]);
        println!("╠══════════════════════════════════════════════════════════════╣");
        println!("║  Verify this matches the request on your Controller/CLI!     ║");
        println!("╚══════════════════════════════════════════════════════════════╝");
        println!();

        tx.send(PakeMessage {
            session_code: code.to_string(),
            role: ROLE_NODE.to_string(),
            r#type: MSG_TYPE_ENCRYPTED,
            encrypted_payload: enc_csr,
            nonce,
            ..Default::default()
        }).await?;

        info!("[Pairing] CSR sent, waiting for signed certificate...");

        // 9. Recv Encrypted Cert
        let cert_msg = resp_stream.message().await?.ok_or(anyhow!("Stream closed"))?;
        if cert_msg.r#type == MSG_TYPE_ERROR {
             return Err(anyhow!("CLI rejected pairing: {}", cert_msg.error_message));
        }
        let cert_pem_bytes = session.decrypt(&cert_msg.encrypted_payload, &cert_msg.nonce)?;
        fs::write(Path::new(&self.data_dir).join("node.crt"), &cert_pem_bytes).await?;

        // 10. Recv Encrypted CA
        let ca_msg = resp_stream.message().await?.ok_or(anyhow!("Stream closed"))?;
        let ca_pem_bytes = session.decrypt(&ca_msg.encrypted_payload, &ca_msg.nonce)?;
        fs::write(Path::new(&self.data_dir).join("cli_ca.crt"), &ca_pem_bytes).await?;

        // 11. Save NodeID (CommonName) from certificate
        if let Ok(cert_str) = std::str::from_utf8(&cert_pem_bytes) {
            if let Some(node_id) = extract_common_name_from_pem(cert_str) {
                let id_path = Path::new(&self.data_dir).join("node_id");
                if let Err(e) = fs::write(&id_path, &node_id).await {
                    warn!("[Pairing] Failed to save node_id file: {}", e);
                } else {
                    info!("[Pairing] Saved Node ID: {}", node_id);
                }
            }
        }

        // Registration with Hub happens on first connect() call, not during pairing
        // (matches Go's doPairingPAKE which just saves certs and exits)

        println!();
        println!("╔══════════════════════════════════════════════════════════════╗");
        println!("║                    PAIRING COMPLETE!                          ║");
        println!("╠══════════════════════════════════════════════════════════════╣");
        println!("║    Certificate saved. Node is now paired with CLI.            ║");
        println!("║                                                                ║");
        println!("║    Run nitellad without --pair to start normally.             ║");
        println!("╚══════════════════════════════════════════════════════════════╝");
        println!();

        Ok(())
    }

    async fn load_private_key(&self) -> Result<SigningKey> {
        let key_path = Path::new(&self.data_dir).join("node.key");
        let key_pem = fs::read_to_string(&key_path).await?;
        let key = SigningKey::from_pkcs8_pem(&key_pem).map_err(|e| anyhow!("Failed to parse private key: {}", e))?;
        Ok(key)
    }

    async fn load_viewer_pubkey(&mut self) {
        let path = Path::new(&self.data_dir).join("viewer_pubkey.bin");
        if let Ok(bytes) = fs::read(&path).await {
            if bytes.len() == 32 {
                let mut arr = [0u8; 32];
                arr.copy_from_slice(&bytes);
                if let Ok(key) = VerifyingKey::from_bytes(&arr) {
                    self.viewer_pubkey = Some(key);
                    info!("[Hub] Loaded viewer public key for E2E responses");
                }
            }
        }

        // Load CA public key from cli_ca.crt for signature verification
        // (matches Go: extract Ed25519 pubkey from CA certificate)
        let ca_path = Path::new(&self.data_dir).join("cli_ca.crt");
        if let Ok(ca_pem) = fs::read(&ca_path).await {
            if let Ok(pem_data) = pem::parse(&ca_pem) {
                use x509_parser::prelude::FromDer;
                if let Ok((_, cert)) = x509_parser::prelude::X509Certificate::from_der(pem_data.contents()) {
                    let key_data = cert.tbs_certificate.subject_pki.subject_public_key.data.as_ref();
                    if key_data.len() == 32 {
                        let mut arr = [0u8; 32];
                        arr.copy_from_slice(key_data);
                        if let Ok(key) = VerifyingKey::from_bytes(&arr) {
                            self.ca_pubkey = Some(key.clone());
                            // Also set as viewer pubkey if not already loaded
                            if self.viewer_pubkey.is_none() {
                                self.viewer_pubkey = Some(key);
                                info!("[Hub] Using CA pubkey as viewer pubkey");
                            }
                            info!("[Hub] Loaded CA public key for signature verification");
                        }
                    }
                }
            }
        }
    }

    fn get_fingerprint(&self) -> String {
        // Match Go: uses nodeID (certificate CN) as sender fingerprint
        self.node_name.clone()
    }

    async fn command_loop(&mut self) -> Result<()> {
        // Clone keys to avoid borrow conflicts
        let signing_key = self.signing_key.clone().ok_or(anyhow!("No signing key"))?;
        let viewer_pubkey = self.viewer_pubkey.clone();
        let ca_pubkey = self.ca_pubkey.clone();
        let fingerprint = self.get_fingerprint();

        let client = self.client.as_mut().ok_or(anyhow!("Not connected"))?;

        let stream_req = ReceiveCommandsRequest {
            node_id: self.node_name.clone(),
        };

        let mut stream = client.receive_commands(stream_req).await?.into_inner();

        // Replay cache cleanup every 60 seconds (matches Go's replayCacheCleanupLoop)
        let mut cleanup_interval = time::interval(Duration::from_secs(60));

        loop {
            tokio::select! {
                // Periodic replay cache cleanup (matches Go: every 1 min, evict >5 min old)
                _ = cleanup_interval.tick() => {
                    let now = std::time::SystemTime::now()
                        .duration_since(std::time::UNIX_EPOCH)
                        .unwrap_or_default()
                        .as_secs() as i64;
                    self.replay_cache.retain(|_, ts| now - *ts < 300);
                }
                // Process incoming commands
                msg = stream.message() => {
                    let cmd = match msg? {
                        Some(c) => c,
                        None => break, // Stream closed
                    };

            info!("[Hub] Received encrypted command ID: {}", cmd.id);

            let enc = match &cmd.encrypted {
                Some(e) => e,
                None => {
                    error!("[Hub] Received command without encryption - rejected");
                    continue;
                }
            };

            // Verify sender fingerprint
            if enc.sender_fingerprint.is_empty() {
                warn!("[SECURITY] Encrypted command missing sender fingerprint");
                continue;
            }

            // Verify signature (matches Go's VerifySignature check)
            if let Some(ca_pk) = &ca_pubkey {
                if let Err(e) = crypto::verify_signature(enc, ca_pk) {
                    error!("[SECURITY] Command signature verification failed: {}", e);
                    continue;
                }
            }

            // Decrypt
            let plaintext = match crypto::decrypt(enc, &signing_key) {
                Ok(p) => p,
                Err(e) => {
                    error!("[Hub] Failed to decrypt command {}: {}", cmd.id, e);
                    continue;
                }
            };

            // Unmarshal SecureCommandPayload
            let secure = match SecureCommandPayload::decode(plaintext.as_slice()) {
                Ok(s) => s,
                Err(e) => {
                    error!("[Hub] Failed to decode SecureCommandPayload: {}", e);
                    continue;
                }
            };

            // Timestamp validation (±60 seconds, matches Go)
            let now = std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap_or_default()
                .as_secs() as i64;
            if secure.timestamp < now - 60 || secure.timestamp > now + 60 {
                error!("[SECURITY] Replay detected! Timestamp out of range: {} (now: {})",
                    secure.timestamp, now);
                continue;
            }

            // Replay protection (RequestID dedup, matches Go)
            if !secure.request_id.is_empty() {
                if self.replay_cache.contains_key(&secure.request_id) {
                    error!("[SECURITY] Replay detected! Request ID {} already processed",
                        secure.request_id);
                    continue;
                }
                self.replay_cache.insert(secure.request_id.clone(), now);
            }

            // Unmarshal EncryptedCommandPayload
            let payload = match EncryptedCommandPayload::decode(secure.data.as_slice()) {
                Ok(p) => p,
                Err(e) => {
                    error!("[Hub] Failed to decode EncryptedCommandPayload: {}", e);
                    continue;
                }
            };

            info!("[Hub] Decrypted command type: {}", payload.r#type);

            // Extend metrics streaming window when stats are requested (matches Go's EnableStatsStreaming)
            if payload.r#type == command_types::STATUS || payload.r#type == command_types::GET_METRICS {
                let mut until = self.stats_streaming_until.write().await;
                *until = tokio::time::Instant::now() + Duration::from_secs(30);
            }

            let result = self.dispatch_command(payload.r#type, payload.payload).await;

            // Build and send encrypted response
            let result_bytes = result.encode_to_vec();
            let encrypted_data = if let Some(viewer_pk) = &viewer_pubkey {
                match crypto::encrypt(&result_bytes, viewer_pk, &signing_key, &fingerprint) {
                    Ok(enc) => Some(enc),
                    Err(e) => {
                        warn!("[Hub] Failed to encrypt response: {}", e);
                        None
                    }
                }
            } else {
                debug!("[Hub] No viewer public key - response cannot be encrypted");
                None
            };

            let response = CommandResponse {
                command_id: cmd.id.clone(),
                encrypted_data,
            };

            if let Some(client) = self.client.as_mut() {
                if let Err(e) = client.respond_to_command(response).await {
                    error!("[Hub] Failed to send response for {}: {}", cmd.id, e);
                } else {
                    debug!("[Hub] Response sent for command {}", cmd.id);
                }
            }
                } // end msg = stream.message() arm
            } // end tokio::select!
        } // end loop
        Ok(())
    }

    async fn dispatch_command(&self, cmd_type: i32, payload: Vec<u8>) -> CommandResult {
        let (status, error_message, response_payload) = match cmd_type {
            command_types::STATUS | command_types::GET_METRICS => {
                self.handle_status().await
            },
            command_types::LIST_PROXIES => {
                self.handle_list_proxies().await
            },
            command_types::LIST_RULES => {
                self.handle_list_rules(payload).await
            },
            command_types::ADD_RULE => {
                self.handle_add_rule(payload).await
            },
            command_types::REMOVE_RULE => {
                self.handle_remove_rule(payload).await
            },
            command_types::GET_ACTIVE_CONNECTIONS => {
                self.handle_get_connections(payload).await
            },
            command_types::CLOSE_CONNECTION => {
                self.handle_close_connection(payload).await
            },
            command_types::CLOSE_ALL_CONNECTIONS => {
                self.handle_close_all_connections(payload).await
            },
            command_types::CREATE_PROXY => {
                self.handle_create_proxy(payload).await
            },
            command_types::APPLY_PROXY => {
                self.handle_apply_proxy(payload).await
            },
            command_types::DELETE_PROXY | command_types::UNAPPLY_PROXY => {
                self.handle_delete_proxy(payload).await
            },
            command_types::ENABLE_PROXY => {
                self.handle_enable_proxy(payload).await
            },
            command_types::DISABLE_PROXY => {
                self.handle_disable_proxy(payload).await
            },
            command_types::UPDATE_PROXY | command_types::PROXY_UPDATE => {
                self.handle_update_proxy(payload).await
            },
            command_types::RESTART_LISTENERS => {
                self.handle_restart_listeners().await
            },
            command_types::RELOAD_RULES => {
                self.handle_reload_rules(payload).await
            },
            command_types::RESOLVE_APPROVAL => {
                self.handle_resolve_approval(payload).await
            },
            command_types::BLOCK_IP => {
                self.handle_block_ip(payload).await
            },
            command_types::ALLOW_IP => {
                self.handle_allow_ip(payload).await
            },
            command_types::LIST_GLOBAL_RULES => {
                self.handle_list_global_rules().await
            },
            command_types::REMOVE_GLOBAL_RULE => {
                self.handle_remove_global_rule(payload).await
            },
            command_types::GET_APPLIED => {
                self.handle_get_applied().await
            },
            command_types::LIST_ACTIVE_APPROVALS => {
                self.handle_list_active_approvals().await
            },
            command_types::CANCEL_APPROVAL => {
                self.handle_cancel_approval(payload).await
            },
            command_types::CONFIGURE_GEOIP => {
                self.handle_configure_geoip(payload).await
            },
            command_types::GET_GEOIP_STATUS => {
                self.handle_get_geoip_status().await
            },
            command_types::LOOKUP_IP => {
                self.handle_lookup_ip(payload).await
            },
            _ => {
                warn!("[Hub] Unhandled command type: {}", cmd_type);
                ("ERROR".to_string(), "Unhandled command".to_string(), vec![])
            }
        };
        
        CommandResult {
            status,
            error_message,
            response_payload,
        }
    }

    // === Command Handlers ===

    async fn handle_status(&self) -> (String, String, Vec<u8>) {
        let statuses = self.manager.list_proxies().await;
        
        let mut total_conns: i64 = 0;
        let mut active_conns: i64 = 0;
        let mut bytes_in: i64 = 0;
        let mut bytes_out: i64 = 0;
        
        for s in &statuses {
            total_conns += s.total_connections;
            active_conns += s.active_connections;
            bytes_in += s.bytes_in;
            bytes_out += s.bytes_out;
        }
        
        let resp = StatsSummaryResponse {
            total_connections: total_conns,
            total_bytes_in: bytes_in,
            total_bytes_out: bytes_out,
            active_connections: active_conns,
            proxy_count: statuses.len() as i32,
            ..Default::default()
        };
        
        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
    }

    async fn handle_list_proxies(&self) -> (String, String, Vec<u8>) {
        let statuses = self.manager.list_proxies().await;
        let resp = ListProxiesResponse { proxies: statuses };
        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
    }

    async fn handle_list_rules(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match ListRulesRequest::decode(payload.as_slice()) {
            Ok(req) => {
                let lock = self.manager.proxies.read().await;
                if let Some(managed) = lock.get(&req.proxy_id) {
                    let engine = managed.rule_engine.read().await;
                    let rules = engine.get_rules();
                    let resp = ListRulesResponse { rules };
                    ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                } else {
                    ("ERROR".to_string(), "Proxy not found".to_string(), vec![])
                }
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_add_rule(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match AddRuleRequest::decode(payload.as_slice()) {
            Ok(req) => {
                if let Some(rule) = req.rule {
                    let rule_id = rule.id.clone();
                    match self.manager.add_rule(&req.proxy_id, rule.clone()).await {
                        Ok(_) => {
                            info!("[Hub] Added rule {} to proxy {}", rule.name, req.proxy_id);
                            ("OK".to_string(), "".to_string(), rule_id.into_bytes())
                        },
                        Err(e) => ("ERROR".to_string(), e.to_string(), vec![])
                    }
                } else {
                    ("ERROR".to_string(), "No rule provided".to_string(), vec![])
                }
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_remove_rule(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match RemoveRuleRequest::decode(payload.as_slice()) {
            Ok(req) => {
                match self.manager.remove_rule(&req.proxy_id, &req.rule_id).await {
                    Ok(_) => {
                        info!("[Hub] Removed rule {} from proxy {}", req.rule_id, req.proxy_id);
                        ("OK".to_string(), "".to_string(), vec![])
                    },
                    Err(e) => ("ERROR".to_string(), e.to_string(), vec![])
                }
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_get_connections(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match GetActiveConnectionsRequest::decode(payload.as_slice()) {
            Ok(req) => {
                let pid = if req.proxy_id.is_empty() { None } else { Some(req.proxy_id) };
                let conns = self.manager.get_active_connections(pid).await;
                let resp = GetActiveConnectionsResponse { connections: conns };
                ("OK".to_string(), "".to_string(), resp.encode_to_vec())
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_close_connection(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match CloseConnectionRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("[Hub] Close connection request: {} on {}", req.conn_id, req.proxy_id);
                match self.manager.close_connection(&req.proxy_id, &req.conn_id).await {
                    Ok(_) => {
                         let resp = CloseConnectionResponse { 
                            success: true, 
                            error_message: "".to_string() 
                        };
                        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    },
                    Err(e) => {
                         let resp = CloseConnectionResponse { 
                            success: false, 
                            error_message: e.to_string() 
                        };
                        ("ERROR".to_string(), e.to_string(), resp.encode_to_vec())
                    }
                }
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_close_all_connections(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match CloseAllConnectionsRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("[Hub] Close all connections for proxy: {}", req.proxy_id);
                match self.manager.close_all_connections(&req.proxy_id).await {
                    Ok(_) => {
                        let resp = CloseAllConnectionsResponse {
                            success: true,
                            error_message: "".to_string(),
                        };
                        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    },
                    Err(e) => {
                        let resp = CloseAllConnectionsResponse {
                            success: false,
                            error_message: e.to_string(),
                        };
                        ("ERROR".to_string(), e.to_string(), resp.encode_to_vec())
                    }
                }
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    /// Handle APPLY_PROXY command - tries ApplyProxyRequest (YAML template) first,
    /// then falls back to CreateProxyRequest (legacy).
    async fn handle_apply_proxy(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        // Try proto-based ApplyProxyRequest with embedded YAML config
        if let Ok(req) = ApplyProxyRequest::decode(payload.as_slice()) {
            if !req.config_yaml.is_empty() {
                info!("[Hub] ApplyProxy (template): proxy_id={}, revision={}", req.proxy_id, req.revision_num);
                return self.apply_proxy_template(&req).await;
            }
        }
        // Fall back to legacy CreateProxyRequest
        self.handle_create_proxy(payload).await
    }

    /// Apply a proxy from YAML template, matching Go's applyProxyTemplate.
    async fn apply_proxy_template(&self, req: &ApplyProxyRequest) -> (String, String, Vec<u8>) {
        let proxy_id = &req.proxy_id;

        // Parse YAML config 
        let yaml_config: crate::config::YamlConfig = match serde_yaml::from_str(&req.config_yaml) {
            Ok(c) => c,
            Err(e) => {
                let msg = format!("Failed to parse YAML config: {}", e);
                error!("[Hub] {}", msg);
                return ("ERROR".to_string(), msg, vec![]);
            }
        };

        // Stop/Remove existing listeners for this proxyID
        {
            let lock = self.applied_proxies.read().await;
            if let Some(existing) = lock.get(proxy_id) {
                for lid in &existing.listener_ids {
                    if let Err(e) = self.manager.delete_proxy(lid).await {
                        warn!("[Hub] Failed to remove old listener {}: {}", lid, e);
                    }
                }
            }
        }

        let mut new_listener_ids: Vec<String> = Vec::new();
        let mut last_error: Option<String> = None;

        // Create new listeners from entrypoints
        if let Some(eps) = &yaml_config.entry_points {
            for (name, ep) in eps {
                let mut default_backend = ep.default_backend.clone();

                // Resolve backend from TCP routers
                if default_backend.is_empty() {
                    if let Some(tcp) = &yaml_config.tcp {
                        if let Some(routers) = &tcp.routers {
                            for (_, router) in routers {
                                if router.entry_points.contains(name) && !router.service.is_empty() {
                                    if let Some(services) = &tcp.services {
                                        if let Some(svc) = services.get(&router.service) {
                                            if let Some(lb) = &svc.load_balancer {
                                                if let Some(server) = lb.servers.first() {
                                                    if !server.address.is_empty() {
                                                        default_backend = server.address.clone();
                                                    } else {
                                                        default_backend = server.url.clone();
                                                    }
                                                }
                                            } else if let Some(addr) = &svc.address {
                                                default_backend = addr.clone();
                                            }
                                        }
                                    }
                                    break;
                                }
                            }
                        }
                    }
                }

                // Map action type
                let action_type = match ep.default_action.to_lowercase().as_str() {
                    "block" => crate::proto::common::ActionType::Block as i32,
                    "mock" => crate::proto::common::ActionType::Mock as i32,
                    "approval" => crate::proto::common::ActionType::RequireApproval as i32,
                    _ => crate::proto::common::ActionType::Allow as i32,
                };

                let create_req = CreateProxyRequest {
                    name: format!("{}-{}", proxy_id, name),
                    listen_addr: ep.address.clone(),
                    default_backend,
                    default_action: action_type,
                    ..Default::default()
                };

                match self.manager.create_proxy(create_req).await {
                    Ok(lid) => {
                        info!("[Hub] ApplyProxy: Created listener {} for {}/{}", lid, proxy_id, name);
                        new_listener_ids.push(lid);
                    },
                    Err(e) => {
                        error!("[Hub] ApplyProxy: Failed to create listener for {}/{}: {}", proxy_id, name, e);
                        last_error = Some(e.to_string());
                    }
                }
            }
        }

        // Track applied proxy
        let status = if last_error.is_some() && new_listener_ids.is_empty() {
            "error"
        } else if last_error.is_some() {
            "partial"
        } else {
            "active"
        };

        let applied = AppliedProxy {
            proxy_id: proxy_id.clone(),
            revision_num: req.revision_num,
            config_hash: "".to_string(),
            applied_at: chrono::Utc::now().timestamp(),
            status: status.to_string(),
            error_msg: last_error.clone(),
            listener_ids: new_listener_ids.clone(),
        };
        {
            let mut lock = self.applied_proxies.write().await;
            lock.insert(proxy_id.clone(), applied);
        }
        self.save_applied_proxies().await;

        // Match Go: if no listeners created and there was an error, return ERROR
        if new_listener_ids.is_empty() && last_error.is_some() {
            let msg = format!("failed to apply any listeners: {}", last_error.unwrap());
            return ("ERROR".to_string(), msg, vec![]);
        }

        // Return ApplyProxyResponse (matching Go's applyProxyTemplate)
        let resp = ApplyProxyResponse {
            success: true,
            error_message: String::new(),
        };
        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
    }

    async fn handle_create_proxy(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match CreateProxyRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("[Hub] Creating proxy: {} on {}", req.name, req.listen_addr);
                match self.manager.create_proxy(req.clone()).await {
                    Ok(id) => {
                        // Track as applied
                        let applied = AppliedProxy {
                            proxy_id: id.clone(),
                            revision_num: 0,
                            config_hash: "".to_string(),
                            applied_at: chrono::Utc::now().timestamp(),
                            status: "active".to_string(),
                            error_msg: None,
                            listener_ids: vec![id.clone()],
                        };
                        {
                            let mut lock = self.applied_proxies.write().await;
                            lock.insert(id.clone(), applied);
                        }
                        self.save_applied_proxies().await;
                        
                        let status = ProxyStatus {
                            proxy_id: id,
                            running: true,
                            listen_addr: req.listen_addr,
                            default_backend: req.default_backend,
                            default_action: req.default_action,
                            default_mock: req.default_mock,
                            fallback_action: req.fallback_action,
                            fallback_mock: req.fallback_mock,
                            ..Default::default()
                        };
                        ("OK".to_string(), "".to_string(), status.encode_to_vec())
                    },
                    Err(e) => ("ERROR".to_string(), e.to_string(), vec![])
                }
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_delete_proxy(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match DeleteProxyRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("[Hub] Deleting proxy: {}", req.proxy_id);
                match self.manager.delete_proxy(&req.proxy_id).await {
                    Ok(_) => {
                        {
                            let mut lock = self.applied_proxies.write().await;
                            lock.remove(&req.proxy_id);
                        }
                        self.save_applied_proxies().await;
                        
                        let resp = DeleteProxyResponse { 
                            success: true, 
                            error_message: "".to_string() 
                        };
                        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    },
                    Err(e) => {
                        let resp = DeleteProxyResponse { 
                            success: false, 
                            error_message: e.to_string() 
                        };
                        ("ERROR".to_string(), e.to_string(), resp.encode_to_vec())
                    }
                }
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_enable_proxy(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match EnableProxyRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("[Hub] Enabling proxy: {}", req.proxy_id);
                match self.manager.enable_proxy(&req.proxy_id).await {
                    Ok(_) => {
                        let resp = EnableProxyResponse {
                            success: true,
                            error_message: "".to_string(),
                        };
                        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    },
                    Err(e) => ("ERROR".to_string(), e.to_string(), vec![])
                }
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_disable_proxy(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match DisableProxyRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("[Hub] Disabling proxy: {}", req.proxy_id);
                match self.manager.disable_proxy(&req.proxy_id).await {
                    Ok(_) => {
                        let resp = DisableProxyResponse {
                            success: true,
                            error_message: "".to_string(),
                        };
                        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    },
                    Err(e) => ("ERROR".to_string(), e.to_string(), vec![])
                }
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_update_proxy(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match UpdateProxyRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("[Hub] Updating proxy: {}", req.proxy_id);
                match self.manager.update_proxy(req).await {
                    Ok(_) => {
                         let resp = UpdateProxyResponse {
                            success: true,
                            error_message: "".to_string(),
                        };
                        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    },
                    Err(e) => {
                        let resp = UpdateProxyResponse {
                            success: false,
                            error_message: e.to_string(),
                        };
                        ("ERROR".to_string(), e.to_string(), resp.encode_to_vec())
                    }
                }
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_restart_listeners(&self) -> (String, String, Vec<u8>) {
        info!("[Hub] Restarting all listeners");
        let count = self.manager.restart_listeners().await;
        
        let resp = RestartListenersResponse {
            success: true,
            restarted_count: count,
            error_message: "".to_string(),
        };
        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
    }

    async fn handle_reload_rules(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match ReloadRulesRequest::decode(payload.as_slice()) {
            Ok(req) => {
                let statuses = self.manager.list_proxies().await;
                let mut total = 0i32;
                for s in statuses {
                    if let Ok(count) = self.manager.reload_rules(&s.proxy_id, req.rules.clone()).await {
                        total += count;
                    }
                }
                let resp = ReloadRulesResponse {
                    success: true,
                    rules_loaded: total,
                    ..Default::default()
                };
                ("OK".to_string(), "".to_string(), resp.encode_to_vec())
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_resolve_approval(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        use crate::proto::proxy::ResolveApprovalRequest;
        match ResolveApprovalRequest::decode(payload.as_slice()) {
            Ok(req) => {
                // action: 1 = ALLOW, 2 = BLOCK
                let allowed = req.action == 1;
                info!("[Hub] Resolving approval {}: allowed={}, duration={}", req.req_id, allowed, req.duration_seconds);
                
                let resolved = self.manager.approval_manager.resolve(&req.req_id, allowed, req.duration_seconds).await;
                if resolved {
                    ("OK".to_string(), "".to_string(), vec![])
                } else {
                    ("ERROR".to_string(), "Approval not found".to_string(), vec![])
                }
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_block_ip(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match BlockIpRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("[Hub] Block IP: {} for {}s", req.ip, req.duration_seconds);
                if let Err(e) = self.manager.block_ip(req.ip, req.duration_seconds).await {
                    return ("ERROR".to_string(), e.to_string(), vec![]);
                }
                ("OK".to_string(), "".to_string(), vec![])
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_allow_ip(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match AllowIpRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("[Hub] Allow IP: {} for {}s", req.ip, req.duration_seconds);
                if let Err(e) = self.manager.allow_ip(req.ip, req.duration_seconds).await {
                    return ("ERROR".to_string(), e.to_string(), vec![]);
                }
                ("OK".to_string(), "".to_string(), vec![])
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_list_global_rules(&self) -> (String, String, Vec<u8>) {
        let rules = self.manager.list_global_rules().await;
        // Need ListGlobalRulesResponse
        let resp = crate::proto::proxy::ListGlobalRulesResponse { rules };
        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
    }

    async fn handle_remove_global_rule(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match RemoveGlobalRuleRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("[Hub] Remove global rule: {}", req.rule_id);
                match self.manager.remove_global_rule(&req.rule_id).await {
                    Ok(_) => {
                         let resp = crate::proto::proxy::RemoveGlobalRuleResponse {
                             success: true,
                             error_message: "".to_string(),
                         };
                         ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    },
                    Err(e) => ("ERROR".to_string(), e.to_string(), vec![])
                }
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_get_applied(&self) -> (String, String, Vec<u8>) {
        let lock = self.applied_proxies.read().await;
        let statuses: Vec<AppliedProxyStatus> = lock.values().map(|ap| {
            AppliedProxyStatus {
                proxy_id: ap.proxy_id.clone(),
                revision_num: ap.revision_num,
                applied_at: chrono::DateTime::from_timestamp(ap.applied_at, 0)
                    .map(|dt| dt.to_rfc3339())
                    .unwrap_or_default(),
                status: ap.status.clone(),
                error_message: ap.error_msg.clone().unwrap_or_default(),
            }
        }).collect();
        
        let resp = GetAppliedProxiesResponse { proxies: statuses };
        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
    }

    async fn handle_list_active_approvals(&self) -> (String, String, Vec<u8>) {
        let entries = self.manager.approval_manager.list_active().await;
        info!("[Hub] List active approvals: {} entries", entries.len());
        
        let approvals: Vec<ActiveApproval> = entries.into_iter().map(|e| {
            ActiveApproval {
                key: e.key,
                source_ip: e.source_ip,
                rule_id: e.rule_id,
                proxy_id: e.proxy_id,
                allowed: e.allowed,
                created_at: Some(prost_types::Timestamp { seconds: e.created_at, nanos: 0 }),
                expires_at: Some(prost_types::Timestamp { seconds: e.expires_at, nanos: 0 }),
                bytes_in: e.bytes_in,
                bytes_out: e.bytes_out,
                geo_country: e.geo_country,
                geo_city: e.geo_city,
                geo_isp: e.geo_isp,
                tls_session_id: "".to_string(),
                blocked_count: e.blocked_count,
                conn_ids: vec![],
            }
        }).collect();

        let resp = ListActiveApprovalsResponse { approvals };
        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
    }

    async fn handle_cancel_approval(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match CancelApprovalRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("[Hub] Cancel approval: {}", req.key);
                ("OK".to_string(), "".to_string(), vec![])
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_lookup_ip(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match LookupIpRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("[Hub] Lookup IP: {}", req.ip);
                let info = self.manager.lookup_ip(&req.ip).await;
                use crate::proto::proxy::LookupIpResponse;
                let resp = LookupIpResponse { 
                    geo: Some(info),
                    cached: false,
                    lookup_time_ms: 0,
                };
                ("OK".to_string(), "".to_string(), resp.encode_to_vec())
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_configure_geoip(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        use crate::proto::proxy::{ConfigureGeoIpRequest, ConfigureGeoIpResponse};
        
        match ConfigureGeoIpRequest::decode(payload.as_slice()) {
            Ok(req) => {
                let city_db = if req.city_db_path.is_empty() { None } else { Some(req.city_db_path) };
                let isp_db = if req.isp_db_path.is_empty() { None } else { Some(req.isp_db_path) };
                
                let remote_url = if !req.provider.is_empty() {
                    let url = match req.provider.as_str() {
                        "ip-api" => "http://ip-api.com/json/{ip}".to_string(),
                        "ipinfo" => {
                             if !req.api_key.is_empty() {
                                 format!("https://ipinfo.io/{{ip}}?token={}", req.api_key)
                             } else {
                                 "https://ipinfo.io/{ip}".to_string()
                             }
                        },
                        custom => custom.to_string(),
                    };
                    Some(url)
                } else {
                    None
                };

                let strategy = match req.mode {
                    0 => Some("local,remote".to_string()), // MODE_LOCAL_DB
                    1 => Some("remote,local".to_string()), // MODE_REMOTE_API
                    _ => None,
                };
                
                match self.manager.configure_geoip(city_db, isp_db, remote_url, strategy).await {
                    Ok(_) => {
                        let resp = ConfigureGeoIpResponse { success: true, error: "".to_string() };
                        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    },
                    Err(e) => ("ERROR".to_string(), e.to_string(), vec![])
                }
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_get_geoip_status(&self) -> (String, String, Vec<u8>) {
        use crate::proto::proxy::GetGeoIpStatusResponse;
        let status = self.manager.get_geoip_status().await;
        
         let mode = if status.strategy.contains(&"remote".to_string()) && status.strategy.contains(&"local".to_string()) {
            "hybrid".to_string()
        } else if status.strategy.contains(&"remote".to_string()) {
            "remote".to_string()
        } else if status.strategy.contains(&"local".to_string()) {
            "local".to_string()
        } else {
            "disabled".to_string()
        };

        let resp = GetGeoIpStatusResponse { 
            enabled: status.enabled, 
            mode,
            city_db_path: if status.city_db_loaded { "Loaded".to_string() } else { "".to_string() },
            isp_db_path: if status.isp_db_loaded { "Loaded".to_string() } else { "".to_string() },
            provider: status.remote_providers.first().cloned().unwrap_or_default(),
            strategy: status.strategy,
            cache_hits: 0,
            cache_misses: 0,
        };
        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
    }

    // === Persistence ===

    async fn load_applied_proxies(&self) {
        let path = Path::new(&self.data_dir).join("applied_proxies.json");
        if let Ok(data) = fs::read_to_string(&path).await {
            if let Ok(proxies) = serde_json::from_str::<HashMap<String, AppliedProxy>>(&data) {
                let mut lock = self.applied_proxies.write().await;
                *lock = proxies;
                info!("[Hub] Loaded {} applied proxies from disk", lock.len());
            }
        }
    }

    async fn save_applied_proxies(&self) {
        let lock = self.applied_proxies.read().await;
        if let Ok(json) = serde_json::to_string_pretty(&*lock) {
            let path = Path::new(&self.data_dir).join("applied_proxies.json");
            if let Err(e) = fs::write(&path, json).await {
                error!("[Hub] Failed to save applied proxies: {}", e);
            }
        }
    }
}

impl HubClient {
    async fn p2p_signaling_loop(
        mut client: NodeServiceClient<InterceptedService<Channel, HubInterceptor>>,
        node_name: String,
        manager: Arc<ProxyManager>,
        stun_server: Option<String>,
        applied_proxies: Arc<RwLock<HashMap<String, AppliedProxy>>>,
        data_dir: String,
    ) {
        let (tx, mut rx) = mpsc::channel::<SignalMessage>(10);
        let outbound = ReceiverStream::new(rx);
        
        match client.stream_signaling(outbound).await {
            Ok(resp) => {
                let mut inbound = resp.into_inner();
                info!("[Hub] P2P Signaling stream established");
                
                while let Some(msg) = inbound.next().await {
                    match msg {
                        Ok(signal) => {
                            if signal.target_id != node_name && !signal.target_id.is_empty() {
                                continue;
                            }
                            
                            let tx_clone = tx.clone();
                            let mgr = manager.clone();
                            let stun = stun_server.clone();
                            let applied = applied_proxies.clone();
                            let ddir = data_dir.clone();
                            let node = node_name.clone();
                            
                            tokio::spawn(async move {
                                if let Err(e) = Self::handle_p2p_signal(signal, tx_clone, mgr, stun, applied, ddir, node).await {
                                    error!("[Hub] P2P Signal handler error: {}", e);
                                }
                            });
                        },
                        Err(e) => {
                            error!("[Hub] P2P Stream error: {}", e);
                            break;
                        }
                    }
                }
            },
            Err(e) => error!("[Hub] Failed to start signaling stream: {}", e),
        }
    }

    async fn handle_p2p_signal(
        signal: SignalMessage,
        tx: mpsc::Sender<SignalMessage>,
        manager: Arc<ProxyManager>,
        stun_server: Option<String>,
        applied_proxies: Arc<RwLock<HashMap<String, AppliedProxy>>>,
        data_dir: String,
        node_name: String,
    ) -> Result<()> {
        if signal.r#type == "offer" {
            info!("[Hub] Received P2P Offer from {}", signal.source_id);
            
            let mut media_engine = MediaEngine::default();
            media_engine.register_default_codecs()?;
            let mut registry = webrtc::interceptor::registry::Registry::new();
            registry = register_default_interceptors(registry, &mut media_engine)?;
            let api = APIBuilder::new()
                .with_media_engine(media_engine)
                .with_interceptor_registry(registry)
                .build();
            
            let config = RTCConfiguration {
                ice_servers: vec![RTCIceServer {
                    urls: vec![stun_server.unwrap_or("stun:stun.l.google.com:19302".to_string())],
                    ..Default::default()
                }],
                ..Default::default()
            };
            
            let pc = Arc::new(api.new_peer_connection(config).await?);
            
            let mgr = manager.clone();
            let applied = applied_proxies.clone();
            let ddir = data_dir.clone();
            let node = node_name.clone();
            
            pc.on_data_channel(Box::new(move |dc: Arc<webrtc::data_channel::RTCDataChannel>| {
                let dc_label = dc.label().to_string();
                let mgr = mgr.clone();
                let applied = applied.clone();
                let ddir = ddir.clone();
                let dc2 = dc.clone();
                
                Box::pin(async move {
                    debug!("[Hub] P2P DataChannel opened: {}", dc_label);
                    let dc3 = dc2.clone(); // For sending
                    dc2.on_message(Box::new(move |msg: DataChannelMessage| {
                        let mgr = mgr.clone();
                        let applied = applied.clone();
                        let ddir = ddir.clone();
                        let dc_send = dc3.clone();
                        let data = msg.data.to_vec();
                        
                        Box::pin(async move {
                             if let Ok(payload) = EncryptedCommandPayload::decode(data.as_slice()) {
                                 let result = Self::static_dispatch(payload.r#type, payload.payload, &mgr, &applied, &ddir).await;
                                 let resp_bytes = result.encode_to_vec();
                                 if let Err(e) = dc_send.send(&bytes::Bytes::from(resp_bytes)).await {
                                     error!("[Hub] P2P Send error: {}", e);
                                 }
                             } else {
                                 if let Ok(secure) = SecureCommandPayload::decode(data.as_slice()) {
                                      if let Ok(payload) = EncryptedCommandPayload::decode(secure.data.as_slice()) {
                                            let result = Self::static_dispatch(payload.r#type, payload.payload, &mgr, &applied, &ddir).await;
                                            let resp_bytes = result.encode_to_vec();
                                            if let Err(e) = dc_send.send(&bytes::Bytes::from(resp_bytes)).await {
                                                error!("[Hub] P2P Send error: {}", e);
                                            }
                                       }
                                 }
                                 warn!("[Hub] Failed to decode P2P message");
                             }
                        })
                    }));
                })
            }));

            let desc = RTCSessionDescription::offer(signal.payload.clone())?;
            pc.set_remote_description(desc).await?;
            
            let answer = pc.create_answer(None).await?;
            let mut answer_gather = answer.clone();
            pc.set_local_description(answer).await?;
            
            let payload = answer_gather.sdp;
             tx.send(SignalMessage {
                target_id: signal.source_id,
                source_id: node_name.clone(),
                r#type: "answer".to_string(),
                payload,
                source_user_id: "".to_string(),
            }).await?;
            
            let pc_clone = pc.clone();
            tokio::spawn(async move {
                let mut done = false;
                while !done {
                    tokio::time::sleep(Duration::from_secs(5)).await;
                    if pc_clone.connection_state() == RTCPeerConnectionState::Closed || 
                       pc_clone.connection_state() == RTCPeerConnectionState::Failed {
                        done = true;
                    }
                }
            });
        }
        Ok(())
    }

    async fn static_dispatch(
        cmd_type: i32, 
        payload: Vec<u8>, 
        manager: &Arc<ProxyManager>, 
        _applied_proxies: &Arc<RwLock<HashMap<String, AppliedProxy>>>,
        _data_dir: &str
    ) -> CommandResult {
        if cmd_type == command_types::STATUS {
             let statuses = manager.list_proxies().await;
             let mut total_conns = 0;
             let mut active = 0;
             let mut total_in = 0;
             let mut total_out = 0;
             for s in &statuses {
                 total_conns += s.total_connections;
                 active += s.active_connections;
                 total_in += s.bytes_in;
                 total_out += s.bytes_out;
             }
             let resp = StatsSummaryResponse {
                 total_connections: total_conns,
                 active_connections: active,
                 total_bytes_in: total_in,
                 total_bytes_out: total_out,
                 proxy_count: statuses.len() as i32,
                 ..Default::default()
             };
             return CommandResult { status: "OK".to_string(), error_message: "".to_string(), response_payload: resp.encode_to_vec() };
        }
        
        if cmd_type == command_types::RESOLVE_APPROVAL {
            if let Ok(req) = ResolveApprovalRequest::decode(payload.as_slice()) {
                let allowed = req.action == 1;
                let resolved = manager.approval_manager.resolve(&req.req_id, allowed, req.duration_seconds).await;
                if resolved {
                     return CommandResult { status: "OK".to_string(), ..Default::default() };
                } else {
                     return CommandResult { status: "ERROR".to_string(), error_message: "Not found".to_string(), ..Default::default() };
                }
            }
        }
        
        CommandResult { status: "ERROR".to_string(), error_message: "Unimplemented in P2P".to_string(), ..Default::default() }
    }
}
