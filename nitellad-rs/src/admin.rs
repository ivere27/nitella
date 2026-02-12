use tonic::{Request, Response, Status};
use tokio::sync::mpsc;
use tokio_stream::wrappers::ReceiverStream;
use std::sync::Arc;
use tokio::sync::RwLock;
use tokio::sync::broadcast;
use tracing::{info, warn, error};
use sha2::Digest;
use uuid::Uuid;

use ed25519_dalek::{SigningKey, VerifyingKey};
use prost::Message;
use crate::crypto;
use crate::proto::hub::{CommandType, EncryptedCommandPayload, CommandResult};
use crate::proto::common::{EncryptedPayload, SecureCommandPayload};
use crate::proto::process::{Event, event}; // Added Event type

use crate::proto::proxy::proxy_control_service_server::ProxyControlService;
use crate::proto::proxy::*;
use crate::manager::ProxyManager;
use crate::rules::RuleEngine;

pub struct AdminServer {
    manager: Arc<ProxyManager>,
    #[allow(dead_code)]
    #[allow(dead_code)]
    global_rules: Arc<RwLock<RuleEngine>>,
    signing_key: SigningKey,
    verifying_key: VerifyingKey,
    fingerprint: String,
    event_tx: broadcast::Sender<Event>, // Added event_tx
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
        }
    }
}

#[tonic::async_trait]
impl ProxyControlService for AdminServer {
    async fn send_command(&self, request: Request<SendCommandRequest>) -> Result<Response<SendCommandResponse>, Status> {
        info!("Admin: Received SendCommand request");
        let req = request.into_inner();
        let enc_payload = req.encrypted.ok_or(Status::invalid_argument("Missing encrypted payload"))?;
        let viewer_pk_bytes = req.viewer_pubkey;
        
        let viewer_pk = VerifyingKey::from_bytes(viewer_pk_bytes.as_slice().try_into().map_err(|_| Status::invalid_argument("Invalid viewer key"))?)
            .map_err(|_| Status::invalid_argument("Invalid viewer key"))?;

        // Decrypt
        let decrypted = crypto::decrypt(&enc_payload, &self.signing_key)
            .map_err(|e| Status::internal(format!("Decryption failed: {}", e)))?;
            
        let secure_cmd = SecureCommandPayload::decode(decrypted.as_slice())
            .map_err(|e| Status::invalid_argument(format!("Invalid SecureCommandPayload: {}", e)))?;
            
        let cmd_payload = EncryptedCommandPayload::decode(secure_cmd.data.as_slice())
            .map_err(|e| Status::invalid_argument(format!("Invalid EncryptedCommandPayload: {}", e)))?;
            
        let (status, err_msg, data) = self.dispatch_command(cmd_payload.r#type, cmd_payload.payload).await;

        let result = CommandResult {
            status: status.clone(),
            error_message: err_msg.clone(),
            response_payload: data,
        };
        
        // Encrypt response
        let result_bytes = result.encode_to_vec();
        
        let encrypted_resp = crypto::encrypt(&result_bytes, &viewer_pk, &self.signing_key, &self.fingerprint)
            .map_err(|e| Status::internal(format!("Encryption failed: {}", e)))?;
            
        Ok(Response::new(SendCommandResponse {
            encrypted: Some(encrypted_resp),
            status,
            error_message: err_msg,
        }))
    }

    type StreamConnectionsStream = ReceiverStream<Result<EncryptedStreamPayload, Status>>;
    async fn stream_connections(&self, request: Request<StreamConnectionsRequest>) -> Result<Response<Self::StreamConnectionsStream>, Status> {
        let req = request.into_inner();
        let viewer_pk_bytes = req.viewer_pubkey;
        let viewer_pk = VerifyingKey::from_bytes(viewer_pk_bytes.as_slice().try_into().map_err(|_| Status::invalid_argument("Invalid viewer key"))?)
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
                             match crypto::encrypt(&payload_bytes, &viewer_pk, &signing_key, &fingerprint) {
                                 Ok(encrypted) => {
                                     let stream_payload = EncryptedStreamPayload {
                                         encrypted: Some(encrypted),
                                         payload_type: "ConnectionEvent".to_string(),
                                     };
                                     if tx.send(Ok(stream_payload)).await.is_err() {
                                         break; // Receiver dropped
                                     }
                                 },
                                 Err(e) => {
                                     error!("Failed to encrypt stream event: {}", e);
                                 }
                             }
                        }
                    },
                    Err(broadcast::error::RecvError::Lagged(_)) => {
                        warn!("Stream skipped lagged events");
                    },
                    Err(broadcast::error::RecvError::Closed) => {
                        break;
                    }
                }
            }
        });

        Ok(Response::new(ReceiverStream::new(rx)))
    }
    
    type StreamMetricsStream = ReceiverStream<Result<EncryptedStreamPayload, Status>>;
    async fn stream_metrics(&self, request: Request<StreamMetricsRequest>) -> Result<Response<Self::StreamMetricsStream>, Status> {
        let req = request.into_inner();
        let viewer_pk_bytes = req.viewer_pubkey;
        let viewer_pk = VerifyingKey::from_bytes(viewer_pk_bytes.as_slice().try_into().map_err(|_| Status::invalid_argument("Invalid viewer key"))?)
            .map_err(|_| Status::invalid_argument("Invalid viewer key"))?;
            
        let interval_secs = if req.interval_seconds > 0 { req.interval_seconds as u64 } else { 1 };
        
        let (tx, rx) = mpsc::channel(10);
        let manager = self.manager.clone();
        let signing_key = self.signing_key.clone();
        let fingerprint = self.fingerprint.clone();

        tokio::spawn(async move {
            let mut interval = tokio::time::interval(std::time::Duration::from_secs(interval_secs));
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

                let resp = StatsSummaryResponse {
                    total_connections: total_conns,
                    total_bytes_in: bytes_in,
                    total_bytes_out: bytes_out,
                    active_connections: active_conns,
                    proxy_count: statuses.len() as i32,
                    ..Default::default()
                };

                let payload_bytes = resp.encode_to_vec();

                match crypto::encrypt(&payload_bytes, &viewer_pk, &signing_key, &fingerprint) {
                     Ok(encrypted) => {
                         let stream_payload = EncryptedStreamPayload {
                             encrypted: Some(encrypted),
                             payload_type: "StatsSummaryResponse".to_string(), // Matches Go implementation
                         };
                         if tx.send(Ok(stream_payload)).await.is_err() {
                             break;
                         }
                     },
                     Err(e) => {
                         error!("Failed to encrypt metrics: {}", e);
                     }
                 }
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
             CommandType::Status | CommandType::GetMetrics => self.handle_status().await,
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
             CommandType::ListActiveApprovals => self.handle_list_active_approvals().await,
             CommandType::CancelApproval => self.handle_cancel_approval(payload).await,
             CommandType::ConfigureGeoip => self.handle_configure_geoip(payload).await,
             CommandType::GetGeoipStatus => self.handle_get_geoip_status(payload).await,
             CommandType::LookupIp => self.handle_lookup_ip(payload).await,
             _ => {

                 warn!("Admin: Unhandled command type: {:?}", type_enum);
                 ("ERROR".to_string(), format!("Unhandled command type: {}", cmd_type), vec![])
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
                    },
                    Err(e) => {
                         let resp = CreateProxyResponse {
                            success: false,
                            error_message: e.to_string(),
                            proxy_id: "".to_string(),
                        };
                        ("ERROR".to_string(), e.to_string(), resp.encode_to_vec())
                    }
                }
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_delete_proxy(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match DeleteProxyRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("Admin: DeleteProxy {}", req.proxy_id);
                match self.manager.delete_proxy(&req.proxy_id).await {
                    Ok(_) => {
                        let resp = DeleteProxyResponse { success: true, error_message: "".to_string() };
                        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    },
                    Err(e) => {
                        let resp = DeleteProxyResponse { success: false, error_message: e.to_string() };
                        ("ERROR".to_string(), e.to_string(), resp.encode_to_vec())
                    }
                }
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
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
                     return ("ERROR".to_string(), e.to_string(), vec![]);
                 }
                 let resp = EnableProxyResponse { success: true, error_message: "".to_string() };
                 ("OK".to_string(), "".to_string(), resp.encode_to_vec())
             },
             Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_disable_proxy(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match DisableProxyRequest::decode(payload.as_slice()) {
             Ok(req) => {
                 if let Err(e) = self.manager.disable_proxy(&req.proxy_id).await {
                     return ("ERROR".to_string(), e.to_string(), vec![]);
                 }
                 let resp = DisableProxyResponse { success: true, error_message: "".to_string() };
                 ("OK".to_string(), "".to_string(), resp.encode_to_vec())
             },
             Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_update_proxy(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match UpdateProxyRequest::decode(payload.as_slice()) {
            Ok(req) => {
                match self.manager.update_proxy(req).await {
                    Ok(_) => {
                         let resp = UpdateProxyResponse { success: true, error_message: "".to_string() };
                         ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    },
                    Err(e) => ("ERROR".to_string(), e.to_string(), vec![])
                }
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_restart_listeners(&self) -> (String, String, Vec<u8>) {
        let count = self.manager.restart_listeners().await;
        let resp = RestartListenersResponse { 
            success: true, 
            restarted_count: count, 
            error_message: "".to_string() 
        };
        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
    }

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
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_add_rule(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match AddRuleRequest::decode(payload.as_slice()) {
            Ok(req) => {
                if let Some(mut rule) = req.rule {
                    if rule.id.is_empty() {
                        rule.id = Uuid::new_v4().to_string();
                    }
                    let rule_id = rule.id.clone();
                    match self.manager.add_rule(&req.proxy_id, rule.clone()).await {
                        Ok(_) => {
                            info!("Admin: Added rule {} ({}) to proxy {}", rule.name, rule_id, req.proxy_id);
                            ("OK".to_string(), "".to_string(), rule.encode_to_vec())
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
                        info!("Admin: Removed rule {} from proxy {}", req.rule_id, req.proxy_id);
                        ("OK".to_string(), "".to_string(), vec![])
                    },
                    Err(e) => ("ERROR".to_string(), e.to_string(), vec![])
                }
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_reload_rules(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match ReloadRulesRequest::decode(payload.as_slice()) {
             Ok(req) => {
                 let statuses = self.manager.list_proxies().await;
                 let mut total_count = 0;
                 for s in statuses {
                     if let Ok(count) = self.manager.reload_rules(&s.proxy_id, req.rules.clone()).await {
                         total_count += count;
                     }
                 }
                 let resp = ReloadRulesResponse {
                     success: true,
                     rules_loaded: total_count,
                     error_message: "".to_string(),
                 };
                 ("OK".to_string(), "".to_string(), resp.encode_to_vec())
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
                info!("Admin: Remove global rule: {}", req.rule_id);
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

    async fn handle_block_ip(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match BlockIpRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("Admin: Block IP: {} for {}s", req.ip, req.duration_seconds);
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
                info!("Admin: Allow IP: {} for {}s", req.ip, req.duration_seconds);
                if let Err(e) = self.manager.allow_ip(req.ip, req.duration_seconds).await {
                    return ("ERROR".to_string(), e.to_string(), vec![]);
                }
                ("OK".to_string(), "".to_string(), vec![])
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_get_active_connections(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match GetActiveConnectionsRequest::decode(payload.as_slice()) {
            Ok(req) => {
                let pid = if req.proxy_id.is_empty() { None } else { Some(req.proxy_id.clone()) };
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
                info!("Admin: Close connection {} on proxy {}", req.conn_id, req.proxy_id);
                match self.manager.close_connection(&req.proxy_id, &req.conn_id).await {
                    Ok(_) => {
                         let resp = CloseConnectionResponse { success: true, error_message: "".to_string() };
                         ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    },
                    Err(e) => {
                        let resp = CloseConnectionResponse { success: false, error_message: e.to_string() };
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
                info!("Admin: Close all connections on proxy {}", req.proxy_id);
                match self.manager.close_all_connections(&req.proxy_id).await {
                    Ok(_) => {
                         let resp = CloseAllConnectionsResponse { success: true, error_message: "".to_string() };
                         ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    },
                    Err(e) => {
                        let resp = CloseAllConnectionsResponse { success: false, error_message: e.to_string() };
                        ("ERROR".to_string(), e.to_string(), resp.encode_to_vec())
                    }
                }
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_resolve_approval(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match ResolveApprovalRequest::decode(payload.as_slice()) {
            Ok(req) => {
                // action: 1 = ALLOW, 2 = BLOCK
                let allowed = req.action == 1; // APPROVAL_ACTION_TYPE_ALLOW
                info!("Admin: Resolving approval {}: allowed={}, duration={}", req.req_id, allowed, req.duration_seconds);
                
                let resolved = self.manager.approval_manager.resolve(&req.req_id, allowed, req.duration_seconds).await;
                if resolved {
                    let resp = ResolveApprovalResponse { success: true, error_message: "".to_string() };
                    ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                } else {
                    let resp = ResolveApprovalResponse { success: false, error_message: "Approval not found".to_string() };
                    ("ERROR".to_string(), "Approval not found".to_string(), resp.encode_to_vec())
                }
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_list_active_approvals(&self) -> (String, String, Vec<u8>) {
        let entries = self.manager.approval_manager.list_active().await;
        info!("Admin: List active approvals: {} entries", entries.len());
        
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
                info!("Admin: Cancel approval: {}", req.key);
                let success = self.manager.cancel_approval(&req.key).await;
                let resp = CancelApprovalResponse { 
                    success,
                    error_message: "".to_string(),
                    connections_closed: 0,
                };
                 ("OK".to_string(), "".to_string(), resp.encode_to_vec())
            },
            Err(e) => ("ERROR".to_string(), format!("Invalid request: {}", e), vec![])
        }
    }

    async fn handle_lookup_ip(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match LookupIpRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("Admin: Lookup IP: {}", req.ip);
                let info = self.manager.lookup_ip(&req.ip).await;
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
        match ConfigureGeoIpRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("Admin: Configure GeoIP");
                let city_db = if req.city_db_path.is_empty() { None } else { Some(req.city_db_path) };
                let isp_db = if req.isp_db_path.is_empty() { None } else { Some(req.isp_db_path) };
                
                let mut remote_url = if !req.provider.is_empty() {
                    let url = match req.provider.as_str() {
                        "ip-api" => "http://ip-api.com/json/{ip}".to_string(),
                        "ipinfo" => {
                             if !req.api_key.is_empty() {
                                 format!("https://ipinfo.io/{{ip}}?token={}", req.api_key)
                             } else {
                                 "https://ipinfo.io/{ip}".to_string()
                             }
                        },
                         // Fallback: assume custom URL or provider name to use as-is (though {ip} replacement is needed)
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

    async fn handle_get_geoip_status(&self, _payload: Vec<u8>) -> (String, String, Vec<u8>) {
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
}