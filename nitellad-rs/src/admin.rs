use sha2::Digest;
use std::collections::HashMap;
use std::sync::Arc;
use std::sync::Mutex;
use tokio::sync::broadcast;
use tokio::sync::mpsc;
use tokio::sync::RwLock;
use tokio_stream::wrappers::ReceiverStream;
use tonic::{Request, Response, Status};
use tracing::{error, info, warn};
use uuid::Uuid;

use crate::crypto;
use crate::proto::common::{ApprovalRetentionMode, SecureCommandPayload};
use crate::proto::hub::{CommandResult, CommandType, EncryptedCommandPayload};
use crate::proto::process::{event, Event};
use ed25519_dalek::{SigningKey, VerifyingKey};
use prost::Message; // Added Event type

use crate::manager::ProxyManager;
use crate::proto::proxy::proxy_control_service_server::ProxyControlService;
use crate::proto::proxy::*;
use crate::rules::RuleEngine;

const REPLAY_WINDOW_SECONDS: i64 = 60;
const REPLAY_CACHE_EXPIRY_SECONDS: i64 = 300;
const MAX_REPLAY_CACHE_SIZE: usize = 10_000;
const DEFAULT_APPROVAL_DURATION_SECONDS: i64 = 300;

pub struct AdminServer {
    manager: Arc<ProxyManager>,
    #[allow(dead_code)]
    #[allow(dead_code)]
    global_rules: Arc<RwLock<RuleEngine>>,
    signing_key: SigningKey,
    #[allow(dead_code)]
    verifying_key: VerifyingKey,
    fingerprint: String,
    event_tx: broadcast::Sender<Event>, // Added event_tx
    replay_cache: Mutex<HashMap<String, i64>>,
}

impl AdminServer {
    pub fn new(
        manager: Arc<ProxyManager>,
        global_rules: Arc<RwLock<RuleEngine>>,
        signing_key: SigningKey,
        verifying_key: VerifyingKey,
        event_tx: broadcast::Sender<Event>, // Added arg
    ) -> Self {
        let mut hasher = sha2::Sha256::new();
        hasher.update(verifying_key.as_bytes());
        let fingerprint = hex::encode(hasher.finalize());

        Self {
            manager,
            global_rules,
            signing_key,
            verifying_key,
            fingerprint,
            event_tx,
            replay_cache: Mutex::new(HashMap::new()),
        }
    }

    fn validate_replay(&self, payload: &SecureCommandPayload) -> Result<(), String> {
        let now = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs() as i64;

        if payload.timestamp < now - REPLAY_WINDOW_SECONDS
            || payload.timestamp > now + REPLAY_WINDOW_SECONDS
        {
            return Err("timestamp out of range".to_string());
        }

        let mut cache = self
            .replay_cache
            .lock()
            .map_err(|_| "replay cache unavailable".to_string())?;
        cache.retain(|_, ts| now - *ts <= REPLAY_CACHE_EXPIRY_SECONDS);
        if cache.contains_key(&payload.request_id) {
            return Err("duplicate request".to_string());
        }
        if cache.len() >= MAX_REPLAY_CACHE_SIZE {
            cache.clear();
        }
        cache.insert(payload.request_id.clone(), now);
        Ok(())
    }

    fn send_command_error(message: &str) -> Response<SendCommandResponse> {
        Response::new(SendCommandResponse {
            encrypted: None,
            status: "ERROR".to_string(),
            error_message: message.to_string(),
        })
    }
}

#[tonic::async_trait]
impl ProxyControlService for AdminServer {
    async fn send_command(
        &self,
        request: Request<SendCommandRequest>,
    ) -> Result<Response<SendCommandResponse>, Status> {
        info!("Admin: Received SendCommand request");
        let req = request.into_inner();
        let viewer_pk_bytes = req.viewer_pubkey;

        let viewer_pk = match viewer_pk_bytes.as_slice().try_into() {
            Ok(bytes) => match VerifyingKey::from_bytes(bytes) {
                Ok(key) => key,
                Err(_) => {
                    return Ok(Self::send_command_error(
                        "viewer_pubkey must be 32 bytes Ed25519",
                    ));
                }
            },
            Err(_) => {
                return Ok(Self::send_command_error(
                    "viewer_pubkey must be 32 bytes Ed25519",
                ));
            }
        };

        let enc_payload = match req.encrypted {
            Some(payload) => payload,
            None => return Ok(Self::send_command_error("encrypted payload is required")),
        };

        // Decrypt
        let decrypted = match crypto::decrypt(&enc_payload, &self.signing_key) {
            Ok(data) => data,
            Err(e) => {
                warn!("Admin: decryption failed: {}", e);
                return Ok(Self::send_command_error("decryption failed"));
            }
        };

        let secure_cmd = match SecureCommandPayload::decode(decrypted.as_slice()) {
            Ok(payload) => payload,
            Err(e) => {
                warn!("Admin: invalid secure payload: {}", e);
                return Ok(Self::send_command_error("invalid secure payload"));
            }
        };

        if let Err(err_msg) = self.validate_replay(&secure_cmd) {
            warn!("Admin: replay protection rejected command: {}", err_msg);
            return Ok(Response::new(SendCommandResponse {
                encrypted: None,
                status: "ERROR".to_string(),
                error_message: err_msg,
            }));
        }

        let cmd_payload = match EncryptedCommandPayload::decode(secure_cmd.data.as_slice()) {
            Ok(payload) => payload,
            Err(e) => {
                warn!("Admin: invalid command payload: {}", e);
                return Ok(Self::send_command_error("invalid command payload"));
            }
        };

        let (status, err_msg, data) = self
            .dispatch_command(cmd_payload.r#type, cmd_payload.payload)
            .await;

        let result = CommandResult {
            status: status.clone(),
            error_message: err_msg.clone(),
            response_payload: data,
        };

        // Encrypt response
        let result_bytes = result.encode_to_vec();

        let encrypted_resp = match crypto::encrypt(
            &result_bytes,
            &viewer_pk,
            &self.signing_key,
            &self.fingerprint,
        ) {
            Ok(payload) => payload,
            Err(e) => {
                warn!("Admin: failed to encrypt response: {}", e);
                return Ok(Self::send_command_error("failed to encrypt response"));
            }
        };

        Ok(Response::new(SendCommandResponse {
            encrypted: Some(encrypted_resp),
            status,
            error_message: String::new(),
        }))
    }

    type StreamConnectionsStream = ReceiverStream<Result<EncryptedStreamPayload, Status>>;
    async fn stream_connections(
        &self,
        request: Request<StreamConnectionsRequest>,
    ) -> Result<Response<Self::StreamConnectionsStream>, Status> {
        let req = request.into_inner();
        let viewer_pk_bytes = req.viewer_pubkey;
        let viewer_pk = VerifyingKey::from_bytes(
            viewer_pk_bytes
                .as_slice()
                .try_into()
                .map_err(|_| Status::invalid_argument("Invalid viewer key"))?,
        )
        .map_err(|_| Status::invalid_argument("Invalid viewer key"))?;

        let (tx, rx) = mpsc::channel(100);
        let mut event_rx = self.event_tx.subscribe();

        // Clone for async task
        let signing_key = self.signing_key.clone();
        let fingerprint = self.fingerprint.clone();

        tokio::spawn(async move {
            loop {
                match event_rx.recv().await {
                    Ok(event) => {
                        // Check if it's a connection event
                        if let Some(event::Type::Connection(conn_event)) = event.r#type {
                            // Serialize event
                            let payload_bytes = conn_event.encode_to_vec();

                            // Encrypt
                            match crypto::encrypt(
                                &payload_bytes,
                                &viewer_pk,
                                &signing_key,
                                &fingerprint,
                            ) {
                                Ok(encrypted) => {
                                    let stream_payload = EncryptedStreamPayload {
                                        encrypted: Some(encrypted),
                                        payload_type: "ConnectionEvent".to_string(),
                                    };
                                    if tx.send(Ok(stream_payload)).await.is_err() {
                                        break; // Receiver dropped
                                    }
                                }
                                Err(e) => {
                                    error!("Failed to encrypt stream event: {}", e);
                                }
                            }
                        }
                    }
                    Err(broadcast::error::RecvError::Lagged(_)) => {
                        warn!("Stream skipped lagged events");
                    }
                    Err(broadcast::error::RecvError::Closed) => {
                        break;
                    }
                }
            }
        });

        Ok(Response::new(ReceiverStream::new(rx)))
    }

    type StreamMetricsStream = ReceiverStream<Result<EncryptedStreamPayload, Status>>;
    async fn stream_metrics(
        &self,
        request: Request<StreamMetricsRequest>,
    ) -> Result<Response<Self::StreamMetricsStream>, Status> {
        let req = request.into_inner();
        let viewer_pk_bytes = req.viewer_pubkey;
        let viewer_pk = VerifyingKey::from_bytes(
            viewer_pk_bytes
                .as_slice()
                .try_into()
                .map_err(|_| Status::invalid_argument("Invalid viewer key"))?,
        )
        .map_err(|_| Status::invalid_argument("Invalid viewer key"))?;

        let interval_secs = if req.interval_seconds > 0 {
            req.interval_seconds as u64
        } else {
            1
        };

        let (tx, rx) = mpsc::channel(10);
        let manager = self.manager.clone();
        let signing_key = self.signing_key.clone();
        let fingerprint = self.fingerprint.clone();

        tokio::spawn(async move {
            let mut interval = tokio::time::interval(std::time::Duration::from_secs(interval_secs));
            let mut prev_bytes_in = 0;
            let mut prev_bytes_out = 0;
            let mut prev_timestamp = 0;
            loop {
                interval.tick().await;

                // Gather stats
                let statuses = manager.list_proxies().await;
                let mut total_conns = 0;
                let mut active_conns = 0;
                let mut bytes_in = 0;
                let mut bytes_out = 0;

                for s in &statuses {
                    total_conns += s.total_connections;
                    active_conns += s.active_connections;
                    bytes_in += s.bytes_in;
                    bytes_out += s.bytes_out;
                }

                let now = std::time::SystemTime::now()
                    .duration_since(std::time::UNIX_EPOCH)
                    .unwrap_or_default()
                    .as_secs() as i64;
                let mut bytes_in_rate = 0;
                let mut bytes_out_rate = 0;
                if prev_timestamp > 0 {
                    let elapsed = now - prev_timestamp;
                    if elapsed > 0 {
                        bytes_in_rate = (bytes_in - prev_bytes_in) / elapsed;
                        bytes_out_rate = (bytes_out - prev_bytes_out) / elapsed;
                    }
                }

                let resp = MetricsSample {
                    timestamp: now,
                    active_conns,
                    total_conns,
                    bytes_in_rate,
                    bytes_out_rate,
                    ..Default::default()
                };

                let payload_bytes = resp.encode_to_vec();

                match crypto::encrypt(&payload_bytes, &viewer_pk, &signing_key, &fingerprint) {
                    Ok(encrypted) => {
                        let stream_payload = EncryptedStreamPayload {
                            encrypted: Some(encrypted),
                            payload_type: "MetricsSample".to_string(),
                        };
                        if tx.send(Ok(stream_payload)).await.is_err() {
                            break;
                        }
                    }
                    Err(e) => {
                        error!("Failed to encrypt metrics: {}", e);
                    }
                }
                prev_bytes_in = bytes_in;
                prev_bytes_out = bytes_out;
                prev_timestamp = now;
            }
        });

        Ok(Response::new(ReceiverStream::new(rx)))
    }
}

impl AdminServer {
    async fn dispatch_command(&self, cmd_type: i32, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        let type_enum = CommandType::try_from(cmd_type).unwrap_or(CommandType::Unspecified);
        info!("Admin: Dispatching command {:?}", type_enum);

        match type_enum {
            CommandType::CreateProxy => self.handle_create_proxy(payload).await,
            CommandType::DeleteProxy => self.handle_delete_proxy(payload).await,
            CommandType::ListProxies => self.handle_list_proxies().await,
            CommandType::EnableProxy => self.handle_enable_proxy(payload).await,
            CommandType::DisableProxy => self.handle_disable_proxy(payload).await,
            CommandType::UpdateProxy => self.handle_update_proxy(payload).await,
            CommandType::RestartListeners => self.handle_restart_listeners().await,
            CommandType::Status => self.handle_status().await,
            CommandType::GetMetrics | CommandType::StatsControl => self.handle_get_metrics().await,
            CommandType::ListRules => self.handle_list_rules(payload).await,
            CommandType::AddRule => self.handle_add_rule(payload).await,
            CommandType::RemoveRule => self.handle_remove_rule(payload).await,
            CommandType::ReloadRules => self.handle_reload_rules(payload).await,
            CommandType::ListGlobalRules => self.handle_list_global_rules().await,
            CommandType::RemoveGlobalRule => self.handle_remove_global_rule(payload).await,
            CommandType::BlockIp => self.handle_block_ip(payload).await,
            CommandType::AllowIp => self.handle_allow_ip(payload).await,
            CommandType::GetActiveConnections => self.handle_get_active_connections(payload).await,
            CommandType::CloseConnection => self.handle_close_connection(payload).await,
            CommandType::CloseAllConnections => self.handle_close_all_connections(payload).await,
            CommandType::ResolveApproval => self.handle_resolve_approval(payload).await,
            CommandType::ListActiveApprovals => self.handle_list_active_approvals(payload).await,
            CommandType::CancelApproval => self.handle_cancel_approval(payload).await,
            CommandType::ConfigureGeoip => self.handle_configure_geoip(payload).await,
            CommandType::GetGeoipStatus => self.handle_get_geoip_status(payload).await,
            CommandType::LookupIp => self.handle_lookup_ip(payload).await,
            _ => {
                warn!("Admin: Unhandled command type: {:?}", type_enum);
                (
                    "ERROR".to_string(),
                    format!("Unhandled command type: {}", cmd_type),
                    vec![],
                )
            }
        }
    }

    async fn handle_create_proxy(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match CreateProxyRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("Admin: CreateProxy {}", req.name);
                match self.manager.create_proxy(req).await {
                    Ok(id) => {
                        let resp = CreateProxyResponse {
                            success: true,
                            error_message: "".to_string(),
                            proxy_id: id,
                        };
                        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    }
                    Err(e) => {
                        let resp = CreateProxyResponse {
                            success: false,
                            error_message: e.to_string(),
                            proxy_id: "".to_string(),
                        };
                        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    }
                }
            }
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
        }
    }

    async fn handle_delete_proxy(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match DeleteProxyRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("Admin: DeleteProxy {}", req.proxy_id);
                // Match Go's direct Admin API: DeleteProxy disables the proxy
                // but preserves its model for a later EnableProxy.
                match self.manager.disable_proxy(&req.proxy_id).await {
                    Ok(_) => {
                        let resp = DeleteProxyResponse {
                            success: true,
                            error_message: "".to_string(),
                        };
                        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    }
                    Err(e) => {
                        let resp = DeleteProxyResponse {
                            success: false,
                            error_message: e.to_string(),
                        };
                        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    }
                }
            }
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
        }
    }

    async fn handle_list_proxies(&self) -> (String, String, Vec<u8>) {
        let proxies = self.manager.list_proxies().await;
        let resp = ListProxiesResponse { proxies };
        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
    }

    async fn handle_enable_proxy(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match EnableProxyRequest::decode(payload.as_slice()) {
            Ok(req) => {
                if let Err(e) = self.manager.enable_proxy(&req.proxy_id).await {
                    let resp = EnableProxyResponse {
                        success: false,
                        error_message: e.to_string(),
                    };
                    return ("OK".to_string(), "".to_string(), resp.encode_to_vec());
                }
                let resp = EnableProxyResponse {
                    success: true,
                    error_message: "".to_string(),
                };
                ("OK".to_string(), "".to_string(), resp.encode_to_vec())
            }
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
        }
    }

    async fn handle_disable_proxy(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match DisableProxyRequest::decode(payload.as_slice()) {
            Ok(req) => {
                if let Err(e) = self.manager.disable_proxy(&req.proxy_id).await {
                    let resp = DisableProxyResponse {
                        success: false,
                        error_message: e.to_string(),
                    };
                    return ("OK".to_string(), "".to_string(), resp.encode_to_vec());
                }
                let resp = DisableProxyResponse {
                    success: true,
                    error_message: "".to_string(),
                };
                ("OK".to_string(), "".to_string(), resp.encode_to_vec())
            }
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
        }
    }

    async fn handle_update_proxy(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match UpdateProxyRequest::decode(payload.as_slice()) {
            Ok(req) => match self.manager.update_proxy(req).await {
                Ok(_) => {
                    let resp = UpdateProxyResponse {
                        success: true,
                        error_message: "".to_string(),
                    };
                    ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                }
                Err(e) => {
                    let resp = UpdateProxyResponse {
                        success: false,
                        error_message: e.to_string(),
                    };
                    ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                }
            },
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
        }
    }

    async fn handle_restart_listeners(&self) -> (String, String, Vec<u8>) {
        let count = self.manager.restart_listeners().await;
        let resp = RestartListenersResponse {
            success: true,
            restarted_count: count,
            error_message: "".to_string(),
        };
        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
    }

    async fn handle_status(&self) -> (String, String, Vec<u8>) {
        self.stats_summary_response().await
    }

    async fn handle_get_metrics(&self) -> (String, String, Vec<u8>) {
        self.stats_summary_response().await
    }

    async fn stats_summary_response(&self) -> (String, String, Vec<u8>) {
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

        // Use StatsSummaryResponse from hub package or common?
        // Hub uses it. It's likely in hub_common.proto
        // Let's rely on type inference or explicit path if needed.
        // Assuming imports handle it.
        // Using explicit crate::proto::hub::StatsSummaryResponse if needed.
        use crate::proto::proxy::StatsSummaryResponse;

        let resp = StatsSummaryResponse {
            total_connections: total_conns,
            total_bytes_in: bytes_in,
            total_bytes_out: bytes_out,
            active_connections: active_conns,
            proxy_count: statuses.len() as i32,
            timestamp: Some(prost_types::Timestamp::from(std::time::SystemTime::now())),
            ..Default::default()
        };

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
            }
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
        }
    }

    async fn handle_add_rule(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match AddRuleRequest::decode(payload.as_slice()) {
            Ok(req) => {
                if let Some(mut rule) = req.rule {
                    if rule.id.is_empty() {
                        rule.id = Uuid::new_v4().to_string();
                    }
                    match self.manager.add_rule(&req.proxy_id, rule.clone()).await {
                        Ok(created_rule) => {
                            info!(
                                "Admin: Added rule {} ({}) to proxy {}",
                                created_rule.name, created_rule.id, req.proxy_id
                            );
                            (
                                "OK".to_string(),
                                "".to_string(),
                                created_rule.encode_to_vec(),
                            )
                        }
                        Err(e) => ("ERROR".to_string(), e.to_string(), vec![]),
                    }
                } else {
                    ("ERROR".to_string(), "No rule provided".to_string(), vec![])
                }
            }
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
        }
    }

    async fn handle_remove_rule(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match RemoveRuleRequest::decode(payload.as_slice()) {
            Ok(req) => match self.manager.remove_rule(&req.proxy_id, &req.rule_id).await {
                Ok(_) => {
                    info!(
                        "Admin: Removed rule {} from proxy {}",
                        req.rule_id, req.proxy_id
                    );
                    ("OK".to_string(), "".to_string(), vec![])
                }
                Err(e) => ("ERROR".to_string(), e.to_string(), vec![]),
            },
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
        }
    }

    async fn handle_reload_rules(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match ReloadRulesRequest::decode(payload.as_slice()) {
            Ok(req) => {
                let statuses = self.manager.list_proxies().await;
                let mut total_count = 0;
                for s in statuses {
                    if let Ok(count) = self
                        .manager
                        .reload_rules(&s.proxy_id, req.rules.clone())
                        .await
                    {
                        total_count += count;
                    }
                }
                let resp = ReloadRulesResponse {
                    success: true,
                    rules_loaded: total_count,
                    error_message: "".to_string(),
                };
                ("OK".to_string(), "".to_string(), resp.encode_to_vec())
            }
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
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
                info!("Admin: Remove global rule: {}", req.rule_id);
                match self.manager.remove_global_rule(&req.rule_id).await {
                    Ok(_) => {
                        let resp = crate::proto::proxy::RemoveGlobalRuleResponse {
                            success: true,
                            error_message: "".to_string(),
                        };
                        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    }
                    Err(e) => ("ERROR".to_string(), e.to_string(), vec![]),
                }
            }
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
        }
    }

    async fn handle_block_ip(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match BlockIpRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("Admin: Block IP: {} for {}s", req.ip, req.duration_seconds);
                if let Err(e) = self.manager.block_ip(req.ip, req.duration_seconds).await {
                    return ("ERROR".to_string(), e.to_string(), vec![]);
                }
                ("OK".to_string(), "".to_string(), vec![])
            }
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
        }
    }

    async fn handle_allow_ip(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match AllowIpRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("Admin: Allow IP: {} for {}s", req.ip, req.duration_seconds);
                if let Err(e) = self.manager.allow_ip(req.ip, req.duration_seconds).await {
                    return ("ERROR".to_string(), e.to_string(), vec![]);
                }
                ("OK".to_string(), "".to_string(), vec![])
            }
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
        }
    }

    async fn handle_get_active_connections(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match GetActiveConnectionsRequest::decode(payload.as_slice()) {
            Ok(req) => {
                let pid = if req.proxy_id.is_empty() {
                    None
                } else {
                    Some(req.proxy_id.clone())
                };
                let conns = self.manager.get_active_connections(pid).await;
                let resp = GetActiveConnectionsResponse { connections: conns };
                ("OK".to_string(), "".to_string(), resp.encode_to_vec())
            }
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
        }
    }

    async fn handle_close_connection(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match CloseConnectionRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!(
                    "Admin: Close connection {} on proxy {}",
                    req.conn_id, req.proxy_id
                );
                match self
                    .manager
                    .close_connection(&req.proxy_id, &req.conn_id)
                    .await
                {
                    Ok(_) => {
                        let resp = CloseConnectionResponse {
                            success: true,
                            error_message: "".to_string(),
                        };
                        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    }
                    Err(e) => {
                        let resp = CloseConnectionResponse {
                            success: false,
                            error_message: e.to_string(),
                        };
                        ("ERROR".to_string(), e.to_string(), resp.encode_to_vec())
                    }
                }
            }
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
        }
    }

    async fn handle_close_all_connections(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match CloseAllConnectionsRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("Admin: Close all connections on proxy {}", req.proxy_id);
                match self.manager.close_all_connections(&req.proxy_id).await {
                    Ok(_) => {
                        let resp = CloseAllConnectionsResponse {
                            success: true,
                            error_message: "".to_string(),
                        };
                        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    }
                    Err(e) => {
                        let resp = CloseAllConnectionsResponse {
                            success: false,
                            error_message: e.to_string(),
                        };
                        ("ERROR".to_string(), e.to_string(), resp.encode_to_vec())
                    }
                }
            }
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
        }
    }

    async fn handle_resolve_approval(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match ResolveApprovalRequest::decode(payload.as_slice()) {
            Ok(req) => {
                // action: 1 = ALLOW, 2 = BLOCK
                let allowed = req.action == 1; // APPROVAL_ACTION_TYPE_ALLOW
                info!(
                    "Admin: Resolving approval {}: allowed={}, mode={}, duration={}",
                    req.req_id, allowed, req.retention_mode, req.duration_seconds
                );

                let mut retention_mode = ApprovalRetentionMode::try_from(req.retention_mode)
                    .unwrap_or(ApprovalRetentionMode::Cache);
                if retention_mode == ApprovalRetentionMode::Unspecified {
                    retention_mode = ApprovalRetentionMode::Cache;
                }
                let mut duration_seconds = req.duration_seconds;
                if retention_mode == ApprovalRetentionMode::Cache && duration_seconds <= 0 {
                    duration_seconds = DEFAULT_APPROVAL_DURATION_SECONDS;
                }
                if retention_mode == ApprovalRetentionMode::ConnectionOnly && duration_seconds < 0 {
                    duration_seconds = 0;
                }

                let target_backend_override = if allowed && !req.target_backend_override.is_empty()
                {
                    match self
                        .manager
                        .validate_approval_backend_override(
                            &req.req_id,
                            &req.target_backend_override,
                        )
                        .await
                    {
                        Ok(Some(address)) => address,
                        Ok(None) => String::new(),
                        Err(e) if e == "not_found" => {
                            let resp = ResolveApprovalResponse {
                                success: false,
                                error_message: "Approval not found".to_string(),
                                resolved_target_backend: String::new(),
                            };
                            return (
                                "ERROR".to_string(),
                                "Approval not found".to_string(),
                                resp.encode_to_vec(),
                            );
                        }
                        Err(e) => {
                            let resp = ResolveApprovalResponse {
                                success: false,
                                error_message: e.clone(),
                                resolved_target_backend: String::new(),
                            };
                            return ("OK".to_string(), String::new(), resp.encode_to_vec());
                        }
                    }
                } else {
                    String::new()
                };

                let resolved = self
                    .manager
                    .approval_manager
                    .resolve_with_retention(
                        &req.req_id,
                        allowed,
                        duration_seconds,
                        &req.reason,
                        retention_mode as i32,
                        &target_backend_override,
                    )
                    .await;
                if resolved {
                    let resp = ResolveApprovalResponse {
                        success: true,
                        error_message: "".to_string(),
                        resolved_target_backend: target_backend_override.clone(),
                    };
                    ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                } else {
                    let resp = ResolveApprovalResponse {
                        success: false,
                        error_message: "Approval not found".to_string(),
                        resolved_target_backend: String::new(),
                    };
                    (
                        "ERROR".to_string(),
                        "Approval not found".to_string(),
                        resp.encode_to_vec(),
                    )
                }
            }
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
        }
    }

    async fn handle_list_active_approvals(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        let req = if payload.is_empty() {
            ListActiveApprovalsRequest::default()
        } else {
            match ListActiveApprovalsRequest::decode(payload.as_slice()) {
                Ok(req) => req,
                Err(e) => {
                    return (
                        "ERROR".to_string(),
                        format!("Invalid request: {}", e),
                        vec![],
                    );
                }
            }
        };
        let entries = self.manager.approval_manager.list_active().await;
        info!("Admin: List active approvals: {} entries", entries.len());

        let approvals: Vec<ActiveApproval> = entries
            .into_iter()
            .filter(|e| {
                (req.proxy_id.is_empty() || e.proxy_id == req.proxy_id)
                    && (req.source_ip.is_empty() || e.source_ip == req.source_ip)
            })
            .map(|e| ActiveApproval {
                key: e.key,
                source_ip: e.source_ip,
                rule_id: e.rule_id,
                proxy_id: e.proxy_id,
                allowed: e.allowed,
                created_at: Some(prost_types::Timestamp {
                    seconds: e.created_at,
                    nanos: 0,
                }),
                expires_at: Some(prost_types::Timestamp {
                    seconds: e.expires_at,
                    nanos: 0,
                }),
                bytes_in: e.bytes_in,
                bytes_out: e.bytes_out,
                geo_country: e.geo_country,
                geo_city: e.geo_city,
                geo_isp: e.geo_isp,
                tls_session_id: e.tls_session_id,
                blocked_count: e.blocked_count,
                conn_ids: e.conn_ids,
                backend_choices: vec![],
                selected_target_backend: e.target_backend,
            })
            .collect();

        let resp = ListActiveApprovalsResponse { approvals };
        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
    }

    async fn handle_cancel_approval(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match CancelApprovalRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("Admin: Cancel approval: {}", req.key);
                let (success, connections_closed) = self
                    .manager
                    .cancel_approval_with_close(&req.key, req.close_connections)
                    .await;
                let resp = CancelApprovalResponse {
                    success,
                    error_message: if success {
                        "".to_string()
                    } else {
                        "Approval not found".to_string()
                    },
                    connections_closed,
                };
                if success {
                    ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                } else {
                    (
                        "ERROR".to_string(),
                        "Approval not found".to_string(),
                        resp.encode_to_vec(),
                    )
                }
            }
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
        }
    }

    async fn handle_lookup_ip(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match LookupIpRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("Admin: Lookup IP: {}", req.ip);
                let start = std::time::Instant::now();
                let info = self.manager.lookup_ip(&req.ip).await;
                let elapsed = start.elapsed().as_millis() as i64;
                let resp = LookupIpResponse {
                    geo: Some(info),
                    cached: elapsed < 5,
                    lookup_time_ms: elapsed,
                };
                ("OK".to_string(), "".to_string(), resp.encode_to_vec())
            }
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
        }
    }

    async fn handle_configure_geoip(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match ConfigureGeoIpRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("Admin: Configure GeoIP");
                let city_db = if req.city_db_path.is_empty() {
                    None
                } else {
                    Some(req.city_db_path)
                };
                let isp_db = if req.isp_db_path.is_empty() {
                    None
                } else {
                    Some(req.isp_db_path)
                };

                let remote_urls = if req.mode == 1 {
                    Some(
                        req.provider
                            .split(',')
                            .map(str::trim)
                            .filter(|provider| !provider.is_empty())
                            .map(ToString::to_string)
                            .collect::<Vec<_>>(),
                    )
                } else {
                    None
                };

                let strategy = match req.mode {
                    0 => Some("l1,local".to_string()),  // MODE_LOCAL_DB
                    1 => Some("l1,remote".to_string()), // MODE_REMOTE_API
                    _ => None,
                };

                match self
                    .manager
                    .configure_geoip(city_db, isp_db, remote_urls, strategy)
                    .await
                {
                    Ok(_) => {
                        let resp = ConfigureGeoIpResponse {
                            success: true,
                            error: "".to_string(),
                        };
                        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    }
                    Err(e) => ("ERROR".to_string(), e.to_string(), vec![]),
                }
            }
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
        }
    }

    async fn handle_get_geoip_status(&self, _payload: Vec<u8>) -> (String, String, Vec<u8>) {
        let status = self.manager.get_geoip_status().await;
        let resp = GetGeoIpStatusResponse {
            enabled: status.enabled,
            mode: if status.enabled {
                "embedded".to_string()
            } else {
                "disabled".to_string()
            },
            city_db_path: String::new(),
            isp_db_path: String::new(),
            provider: String::new(),
            strategy: if status.enabled {
                vec![
                    "l1".to_string(),
                    "l2".to_string(),
                    "local".to_string(),
                    "remote".to_string(),
                ]
            } else {
                vec![]
            },
            cache_hits: 0,
            cache_misses: 0,
        };
        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::approval::ApprovalManager;
    use crate::geoip::GeoIPService;
    use crate::proto::common::EncryptedPayload;
    use crate::stats::StatsService;
    use base64::{engine::general_purpose, Engine as _};

    fn signing_key(seed: u8) -> SigningKey {
        SigningKey::from_bytes(&[seed; 32])
    }

    async fn test_admin_server(signing_key: SigningKey) -> AdminServer {
        let geoip = Arc::new(
            GeoIPService::new(None, None, None, None, 24, None, 3000)
                .await
                .unwrap(),
        );
        let global_rules = Arc::new(RwLock::new(RuleEngine::new(vec![])));
        let approval_manager = Arc::new(ApprovalManager::new());
        let (event_tx, _) = broadcast::channel(16);
        let stats = Arc::new(StatsService::new(event_tx.clone()));
        let manager = Arc::new(ProxyManager::new(
            geoip,
            global_rules.clone(),
            stats,
            None,
            false,
            approval_manager,
        ));
        let verifying_key = signing_key.verifying_key();
        AdminServer::new(manager, global_rules, signing_key, verifying_key, event_tx)
    }

    fn encrypted_status_request(
        node_key: &SigningKey,
        viewer_key: &SigningKey,
        request_id: &str,
    ) -> SendCommandRequest {
        encrypted_command_request(
            node_key,
            viewer_key,
            request_id,
            CommandType::Status as i32,
            vec![],
        )
    }

    fn encrypted_command_request(
        node_key: &SigningKey,
        viewer_key: &SigningKey,
        request_id: &str,
        command_type: i32,
        payload: Vec<u8>,
    ) -> SendCommandRequest {
        let cmd = EncryptedCommandPayload {
            r#type: command_type,
            payload,
        };
        let now = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs() as i64;
        let secure = SecureCommandPayload {
            request_id: request_id.to_string(),
            timestamp: now,
            data: cmd.encode_to_vec(),
        };
        let encrypted = crypto::encrypt(
            &secure.encode_to_vec(),
            &node_key.verifying_key(),
            viewer_key,
            "viewer",
        )
        .unwrap();
        SendCommandRequest {
            viewer_pubkey: viewer_key.verifying_key().as_bytes().to_vec(),
            encrypted: Some(encrypted),
        }
    }

    #[tokio::test]
    async fn send_command_invalid_viewer_key_returns_go_style_error_response() {
        let server = test_admin_server(signing_key(1)).await;
        let resp = server
            .send_command(Request::new(SendCommandRequest {
                viewer_pubkey: vec![1, 2, 3],
                encrypted: None,
            }))
            .await
            .unwrap()
            .into_inner();

        assert_eq!(resp.status, "ERROR");
        assert_eq!(resp.error_message, "viewer_pubkey must be 32 bytes Ed25519");
        assert!(resp.encrypted.is_none());
    }

    #[tokio::test]
    async fn send_command_missing_encrypted_payload_returns_go_style_error_response() {
        let server = test_admin_server(signing_key(1)).await;
        let viewer = signing_key(2);
        let resp = server
            .send_command(Request::new(SendCommandRequest {
                viewer_pubkey: viewer.verifying_key().as_bytes().to_vec(),
                encrypted: None,
            }))
            .await
            .unwrap()
            .into_inner();

        assert_eq!(resp.status, "ERROR");
        assert_eq!(resp.error_message, "encrypted payload is required");
        assert!(resp.encrypted.is_none());
    }

    #[tokio::test]
    async fn send_command_decryption_failure_returns_go_style_error_response() {
        let server = test_admin_server(signing_key(1)).await;
        let viewer = signing_key(2);
        let resp = server
            .send_command(Request::new(SendCommandRequest {
                viewer_pubkey: viewer.verifying_key().as_bytes().to_vec(),
                encrypted: Some(EncryptedPayload::default()),
            }))
            .await
            .unwrap()
            .into_inner();

        assert_eq!(resp.status, "ERROR");
        assert_eq!(resp.error_message, "decryption failed");
        assert!(resp.encrypted.is_none());
    }

    #[tokio::test]
    async fn send_command_replay_duplicate_returns_go_style_error_response() {
        let node = signing_key(1);
        let viewer = signing_key(2);
        let server = test_admin_server(node.clone()).await;
        let req = encrypted_status_request(&node, &viewer, "duplicate-request");

        let first = server
            .send_command(Request::new(req.clone()))
            .await
            .unwrap()
            .into_inner();
        assert_eq!(first.status, "OK");
        assert!(first.encrypted.is_some());

        let second = server
            .send_command(Request::new(req))
            .await
            .unwrap()
            .into_inner();
        assert_eq!(second.status, "ERROR");
        assert_eq!(second.error_message, "duplicate request");
        assert!(second.encrypted.is_none());
    }

    #[tokio::test]
    async fn send_command_empty_request_id_is_replay_checked() {
        let node = signing_key(1);
        let viewer = signing_key(2);
        let server = test_admin_server(node.clone()).await;
        let req = encrypted_status_request(&node, &viewer, "");

        let first = server
            .send_command(Request::new(req.clone()))
            .await
            .unwrap()
            .into_inner();
        assert_eq!(first.status, "OK");
        assert!(first.encrypted.is_some());

        let second = server
            .send_command(Request::new(req))
            .await
            .unwrap()
            .into_inner();
        assert_eq!(second.status, "ERROR");
        assert_eq!(second.error_message, "duplicate request");
        assert!(second.encrypted.is_none());
    }

    #[tokio::test]
    async fn send_command_dispatch_error_stays_inside_encrypted_result() {
        let node = signing_key(1);
        let viewer = signing_key(2);
        let server = test_admin_server(node.clone()).await;
        let req = encrypted_command_request(
            &node,
            &viewer,
            "dispatch-error",
            CommandType::CloseConnection as i32,
            CloseConnectionRequest {
                proxy_id: "missing-proxy".to_string(),
                conn_id: "missing-conn".to_string(),
            }
            .encode_to_vec(),
        );

        let resp = server
            .send_command(Request::new(req))
            .await
            .unwrap()
            .into_inner();
        assert_eq!(resp.status, "ERROR");
        assert_eq!(resp.error_message, "");

        let encrypted = resp.encrypted.as_ref().unwrap();
        let plaintext = crypto::decrypt(encrypted, &viewer).unwrap();
        let result = CommandResult::decode(plaintext.as_slice()).unwrap();
        assert_eq!(result.status, "ERROR");
        assert!(!result.error_message.is_empty());
    }

    #[tokio::test]
    async fn stats_control_dispatch_returns_metrics_summary() {
        let server = test_admin_server(signing_key(1)).await;
        let (status, error_message, payload) = server
            .dispatch_command(CommandType::StatsControl as i32, vec![])
            .await;

        assert_eq!(status, "OK");
        assert_eq!(error_message, "");
        let summary = StatsSummaryResponse::decode(payload.as_slice()).unwrap();
        assert_eq!(summary.proxy_count, 0);
        assert_eq!(summary.active_connections, 0);
    }

    #[derive(serde::Deserialize)]
    struct AdminCryptoCompatFixture {
        node_seed: String,
        viewer_seed: String,
        request: AdminCryptoCompatRequest,
    }

    #[derive(serde::Deserialize)]
    struct AdminCryptoCompatRequest {
        viewer_pubkey: String,
        encrypted: AdminCryptoCompatEncryptedPayload,
    }

    #[derive(serde::Serialize)]
    struct AdminCryptoCompatResponse {
        status: String,
        error_message: String,
        encrypted: Option<AdminCryptoCompatEncryptedPayload>,
    }

    #[derive(serde::Deserialize, serde::Serialize)]
    struct AdminCryptoCompatEncryptedPayload {
        ephemeral_pubkey: String,
        nonce: String,
        ciphertext: String,
        sender_fingerprint: String,
        signature: String,
        algorithm: i32,
    }

    impl AdminCryptoCompatEncryptedPayload {
        fn to_proto(&self) -> EncryptedPayload {
            EncryptedPayload {
                ephemeral_pubkey: decode_compat_b64(&self.ephemeral_pubkey),
                nonce: decode_compat_b64(&self.nonce),
                ciphertext: decode_compat_b64(&self.ciphertext),
                sender_fingerprint: self.sender_fingerprint.clone(),
                signature: decode_compat_b64(&self.signature),
                algorithm: self.algorithm,
            }
        }

        fn from_proto(payload: &EncryptedPayload) -> Self {
            Self {
                ephemeral_pubkey: encode_compat_b64(&payload.ephemeral_pubkey),
                nonce: encode_compat_b64(&payload.nonce),
                ciphertext: encode_compat_b64(&payload.ciphertext),
                sender_fingerprint: payload.sender_fingerprint.clone(),
                signature: encode_compat_b64(&payload.signature),
                algorithm: payload.algorithm,
            }
        }
    }

    fn decode_compat_b64(encoded: &str) -> Vec<u8> {
        general_purpose::STANDARD.decode(encoded).unwrap()
    }

    fn encode_compat_b64(data: &[u8]) -> String {
        general_purpose::STANDARD.encode(data)
    }

    fn decode_compat_seed(encoded: &str) -> [u8; 32] {
        decode_compat_b64(encoded).try_into().unwrap()
    }

    #[tokio::test]
    async fn admin_crypto_compat_fixture_go_request_rust_response() {
        let fixture_path = match std::env::var("NITELLA_ADMIN_COMPAT_FIXTURE") {
            Ok(path) => path,
            Err(_) => return,
        };
        let response_path = std::env::var("NITELLA_ADMIN_COMPAT_RESPONSE").ok();

        let fixture_json = std::fs::read_to_string(&fixture_path).unwrap();
        let fixture: AdminCryptoCompatFixture = serde_json::from_str(&fixture_json).unwrap();

        let node_key = SigningKey::from_bytes(&decode_compat_seed(&fixture.node_seed));
        let viewer_key = SigningKey::from_bytes(&decode_compat_seed(&fixture.viewer_seed));
        let request_encrypted = fixture.request.encrypted.to_proto();

        crypto::verify_signature(&request_encrypted, &viewer_key.verifying_key()).unwrap();

        let request = SendCommandRequest {
            viewer_pubkey: decode_compat_b64(&fixture.request.viewer_pubkey),
            encrypted: Some(request_encrypted),
        };
        assert_eq!(
            request.viewer_pubkey,
            viewer_key.verifying_key().as_bytes().to_vec()
        );

        let server = test_admin_server(node_key.clone()).await;
        let response = server
            .send_command(Request::new(request))
            .await
            .unwrap()
            .into_inner();

        assert_eq!(response.status, "OK", "{}", response.error_message);
        let encrypted_response = response.encrypted.as_ref().unwrap();
        crypto::verify_signature(encrypted_response, &node_key.verifying_key()).unwrap();

        let plaintext = crypto::decrypt(encrypted_response, &viewer_key).unwrap();
        let result = CommandResult::decode(plaintext.as_slice()).unwrap();
        assert_eq!(result.status, "OK");
        assert_eq!(result.error_message, "");

        let stats = StatsSummaryResponse::decode(result.response_payload.as_slice()).unwrap();
        assert_eq!(stats.proxy_count, 0);
        assert_eq!(stats.active_connections, 0);

        if let Some(path) = response_path {
            let response_fixture = AdminCryptoCompatResponse {
                status: response.status,
                error_message: response.error_message,
                encrypted: response
                    .encrypted
                    .as_ref()
                    .map(AdminCryptoCompatEncryptedPayload::from_proto),
            };
            let response_json = serde_json::to_string_pretty(&response_fixture).unwrap();
            std::fs::write(path, format!("{}\n", response_json)).unwrap();
        }
    }
}
