use crate::cert_utils;
use crate::cpace::{CPaceSession, ROLE_NODE};
use crate::crypto;
use crate::manager::ProxyManager;
use crate::proto::common::{
    Alert, ApprovalRetentionMode, EncryptedPayload, MockPreset, SecureCommandPayload,
};
use crate::proto::hub::node_service_client::NodeServiceClient;
use crate::proto::hub::pairing_service_client::PairingServiceClient;
use crate::proto::hub::EncryptedCommandPayload;
use crate::proto::hub::{
    CommandResponse, CommandResult, EncryptedLogEntry, EncryptedMetrics, HeartbeatRequest, Metrics,
    NodeStatus, PakeMessage, ReceiveCommandsRequest, SignalMessage, StreamRevocationsRequest,
};
use crate::proto::process::{event, Event};
use crate::proto::proxy::{
    ActiveApproval, AddRuleRequest, AllowIpRequest, AppliedProxyStatus, ApplyProxyRequest,
    ApplyProxyResponse, BlockIpRequest, CancelApprovalRequest, CancelApprovalResponse,
    ClientAuthType, CloseAllConnectionsRequest, CloseAllConnectionsResponse,
    CloseConnectionRequest, CloseConnectionResponse, CreateProxyRequest, CreateProxyResponse,
    DeleteProxyRequest, DeleteProxyResponse, DisableProxyRequest, DisableProxyResponse,
    EnableProxyRequest, EnableProxyResponse, GetActiveConnectionsRequest,
    GetActiveConnectionsResponse, GetAppliedProxiesResponse, ListActiveApprovalsRequest,
    ListActiveApprovalsResponse, ListProxiesResponse, ListRulesRequest, ListRulesResponse,
    LookupIpRequest, ProxyStatus, RateLimitConfig, ReloadRulesRequest, ReloadRulesResponse,
    RemoveGlobalRuleRequest, RemoveRuleRequest, ResolveApprovalResponse, RestartListenersResponse,
    Rule, StatsSummaryResponse, UpdateProxyRequest, UpdateProxyResponse,
};
use anyhow::{anyhow, Result};
use base64::{engine::general_purpose, Engine as _};
use ed25519_dalek::{Signer, SigningKey, VerifyingKey};
use sha2::Digest;
use std::collections::HashMap;
use std::path::Path;
use std::str::FromStr;
use std::sync::Arc;
use std::time::{Duration, SystemTime, UNIX_EPOCH};
use tokio::fs;
use tokio::sync::{broadcast, mpsc, RwLock};
use tokio::time;
use tokio_stream::wrappers::ReceiverStream;
use tokio_stream::StreamExt;
use tonic::codegen::InterceptedService;
use tonic::service::Interceptor;
use tonic::transport::{Channel, ClientTlsConfig, Identity};
use tracing::{debug, error, info, warn};

use pkcs8::DecodePrivateKey;
use prost::Message;
use serde::{Deserialize, Serialize};

// WebRTC Imports
use webrtc::api::interceptor_registry::register_default_interceptors;
use webrtc::api::media_engine::MediaEngine;
use webrtc::api::APIBuilder;
use webrtc::data_channel::data_channel_message::DataChannelMessage;
use webrtc::ice_transport::ice_candidate::RTCIceCandidateInit;
use webrtc::ice_transport::ice_server::RTCIceServer;
use webrtc::peer_connection::configuration::RTCConfiguration;
use webrtc::peer_connection::peer_connection_state::RTCPeerConnectionState;
use webrtc::peer_connection::sdp::session_description::RTCSessionDescription;

const DEFAULT_APPROVAL_DURATION_SECONDS: i64 = 300;

#[derive(Clone)]
pub struct HubInterceptor {
    pub user_id: Option<String>,
}

impl Interceptor for HubInterceptor {
    fn call(
        &mut self,
        mut request: tonic::Request<()>,
    ) -> Result<tonic::Request<()>, tonic::Status> {
        if let Some(uid) = &self.user_id {
            if let Ok(val) = tonic::metadata::MetadataValue::from_str(uid) {
                request.metadata_mut().insert("user-id", val);
            }
        }
        Ok(request)
    }
}

#[derive(Debug)]
struct P2PAuthMessage {
    message_type: String,
    challenge: Vec<u8>,
    public_key: Vec<u8>,
}

#[derive(Debug, Deserialize)]
struct P2PWireMessage {
    #[serde(rename = "type")]
    message_type: String,
    #[serde(default)]
    request_id: String,
    payload: serde_json::Value,
}

#[derive(Debug, Deserialize)]
struct P2PEncryptedPayloadJson {
    #[serde(deserialize_with = "deserialize_base64")]
    ephemeral_pubkey: Vec<u8>,
    #[serde(deserialize_with = "deserialize_base64")]
    nonce: Vec<u8>,
    #[serde(deserialize_with = "deserialize_base64")]
    ciphertext: Vec<u8>,
}

#[derive(Debug, Deserialize)]
struct P2PCommandPayloadJson {
    command_type: i32,
    #[serde(deserialize_with = "deserialize_base64")]
    data: Vec<u8>,
}

fn parse_p2p_auth_message(data: &[u8]) -> Option<P2PAuthMessage> {
    let value: serde_json::Value = serde_json::from_slice(data).ok()?;
    let message_type = value.get("type")?.as_str()?.to_string();
    if !matches!(
        message_type.as_str(),
        "auth_challenge" | "auth_response" | "auth_success" | "auth_failed"
    ) {
        return None;
    }
    Some(P2PAuthMessage {
        message_type,
        challenge: decode_json_base64_field(&value, "challenge").unwrap_or_default(),
        public_key: decode_json_base64_field(&value, "public_key").unwrap_or_default(),
    })
}

fn decrypt_p2p_command_message(
    data: &[u8],
    signing_key: &SigningKey,
) -> Result<(String, i32, Vec<u8>)> {
    let wrapper: P2PWireMessage = serde_json::from_slice(data)?;
    if wrapper.message_type != "encrypted" {
        anyhow::bail!(
            "expected encrypted P2P message, got {}",
            wrapper.message_type
        );
    }

    let encrypted: P2PEncryptedPayloadJson = serde_json::from_value(wrapper.payload)?;
    let payload = EncryptedPayload {
        ephemeral_pubkey: encrypted.ephemeral_pubkey,
        nonce: encrypted.nonce,
        ciphertext: encrypted.ciphertext,
        sender_fingerprint: String::new(),
        signature: vec![],
        algorithm: 0,
    };
    let plaintext = crypto::decrypt(&payload, signing_key)?;
    let inner: P2PWireMessage = serde_json::from_slice(&plaintext)?;
    if inner.message_type != "command" {
        anyhow::bail!("expected command P2P message, got {}", inner.message_type);
    }
    let command: P2PCommandPayloadJson = serde_json::from_value(inner.payload)?;
    Ok((inner.request_id, command.command_type, command.data))
}

fn encrypt_p2p_command_response(
    request_id: &str,
    result: &CommandResult,
    peer_key: &VerifyingKey,
    signing_key: &SigningKey,
    node_fingerprint: &str,
) -> Result<Vec<u8>> {
    let response_payload = serde_json::json!({
        "request_id": request_id,
        "status": result.status,
        "error": result.error_message,
        "data": general_purpose::STANDARD.encode(&result.response_payload),
    });
    let inner = serde_json::json!({
        "type": "command_response",
        "timestamp": unix_timestamp(),
        "nonce": p2p_nonce(),
        "request_id": request_id,
        "payload": response_payload,
    });
    let encrypted = crypto::encrypt(
        inner.to_string().as_bytes(),
        peer_key,
        signing_key,
        node_fingerprint,
    )?;
    let encrypted_payload = serde_json::json!({
        "ephemeral_pubkey": general_purpose::STANDARD.encode(&encrypted.ephemeral_pubkey),
        "nonce": general_purpose::STANDARD.encode(&encrypted.nonce),
        "ciphertext": general_purpose::STANDARD.encode(&encrypted.ciphertext),
        "inner_type": "command_response",
    });
    let wrapper = serde_json::json!({
        "type": "encrypted",
        "timestamp": unix_timestamp(),
        "nonce": p2p_nonce(),
        "payload": encrypted_payload,
    });
    Ok(serde_json::to_vec(&wrapper)?)
}

fn decode_json_base64_field(value: &serde_json::Value, key: &str) -> Result<Vec<u8>> {
    let Some(raw) = value.get(key).and_then(|v| v.as_str()) else {
        return Ok(vec![]);
    };
    Ok(general_purpose::STANDARD.decode(raw)?)
}

fn deserialize_base64<'de, D>(deserializer: D) -> std::result::Result<Vec<u8>, D::Error>
where
    D: serde::Deserializer<'de>,
{
    let raw = String::deserialize(deserializer)?;
    general_purpose::STANDARD
        .decode(raw)
        .map_err(serde::de::Error::custom)
}

fn verifying_key_from_slice(bytes: &[u8]) -> Result<VerifyingKey> {
    let key: [u8; 32] = bytes
        .try_into()
        .map_err(|_| anyhow!("invalid P2P public key length: {}", bytes.len()))?;
    VerifyingKey::from_bytes(&key).map_err(|e| anyhow!("invalid P2P public key: {}", e))
}

fn sdp_from_signal_payload(payload: &str) -> String {
    serde_json::from_str::<serde_json::Value>(payload)
        .ok()
        .and_then(|value| {
            value
                .get("sdp")
                .and_then(|sdp| sdp.as_str())
                .map(str::to_string)
        })
        .unwrap_or_else(|| payload.to_string())
}

async fn load_p2p_signing_key(data_dir: &str) -> Result<SigningKey> {
    let key_path = Path::new(data_dir).join("node.key");
    let key_pem = fs::read_to_string(&key_path).await?;
    SigningKey::from_pkcs8_pem(&key_pem)
        .map_err(|e| anyhow!("Failed to parse P2P private key: {}", e))
}

fn unix_timestamp() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs() as i64
}

fn p2p_nonce() -> String {
    uuid::Uuid::new_v4().simple().to_string()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::approval::ApprovalManager;
    use crate::geoip::GeoIPService;
    use crate::proto::common::{ActionType, ConditionType, Operator};
    use crate::proto::proxy::{
        Condition, GetGeoIpStatusResponse, ListActiveApprovalsRequest, ListGlobalRulesResponse,
        LookupIpResponse, RateLimitConfig, RemoveGlobalRuleResponse, Rule,
    };
    use crate::rules::RuleEngine;
    use crate::stats::StatsService;
    use serde::Serialize;
    use serde_json::{json, Value};
    use std::sync::atomic::AtomicU64;
    use tokio::io::{AsyncReadExt, AsyncWriteExt};
    use tokio::net::{TcpListener, TcpStream};
    use tokio::sync::broadcast;

    async fn test_hub_client() -> HubClient {
        let geoip = Arc::new(
            GeoIPService::new(None, None, None, None, 24, None, 3000)
                .await
                .unwrap(),
        );
        let global_rules = Arc::new(RwLock::new(RuleEngine::new(vec![])));
        let approval_manager = Arc::new(ApprovalManager::new());
        let (event_tx, _) = broadcast::channel(16);
        let stats = Arc::new(StatsService::new(event_tx));
        let manager = Arc::new(ProxyManager::new(
            geoip,
            global_rules,
            stats,
            None,
            false,
            approval_manager,
        ));
        let data_dir = std::env::temp_dir()
            .join(format!("nitellad-rs-hub-test-{}", uuid::Uuid::new_v4()))
            .to_string_lossy()
            .to_string();

        HubClient::new(
            "127.0.0.1:1".to_string(),
            data_dir,
            "test-node".to_string(),
            manager,
            None,
            None,
            None,
        )
    }

    fn create_proxy_payload(name: &str) -> Vec<u8> {
        CreateProxyRequest {
            name: name.to_string(),
            listen_addr: "127.0.0.1:0".to_string(),
            default_action: ActionType::Allow as i32,
            ..Default::default()
        }
        .encode_to_vec()
    }

    fn create_proxy_payload_with_backend(name: &str, backend: &str) -> Vec<u8> {
        CreateProxyRequest {
            name: name.to_string(),
            listen_addr: "127.0.0.1:0".to_string(),
            default_backend: backend.to_string(),
            default_action: ActionType::Allow as i32,
            ..Default::default()
        }
        .encode_to_vec()
    }

    #[tokio::test]
    async fn hub_create_proxy_returns_create_proxy_response() {
        let hub = test_hub_client().await;

        let (status, err, payload) = hub
            .handle_create_proxy(create_proxy_payload("create"))
            .await;

        assert_eq!(status, "OK");
        assert!(err.is_empty());
        let resp = CreateProxyResponse::decode(payload.as_slice()).unwrap();
        assert!(resp.success);
        assert!(!resp.proxy_id.is_empty());

        hub.manager.delete_proxy(&resp.proxy_id).await.unwrap();
    }

    #[tokio::test]
    async fn hub_proxy_update_only_checks_applied_registry() {
        let hub = test_hub_client().await;
        {
            let mut applied = hub.applied_proxies.write().await;
            applied.insert(
                "applied-proxy".to_string(),
                AppliedProxy {
                    proxy_id: "applied-proxy".to_string(),
                    revision_num: 7,
                    config_hash: "hash".to_string(),
                    applied_at: chrono::Utc::now().timestamp(),
                    status: "active".to_string(),
                    error_msg: None,
                    listener_ids: vec![],
                },
            );
        }

        let (status, err, payload) = hub
            .handle_proxy_update(
                UpdateProxyRequest {
                    proxy_id: "applied-proxy".to_string(),
                    default_backend: "127.0.0.1:9".to_string(),
                    ..Default::default()
                }
                .encode_to_vec(),
            )
            .await;

        assert_eq!(status, "OK");
        assert!(err.is_empty());
        let resp = UpdateProxyResponse::decode(payload.as_slice()).unwrap();
        assert!(resp.success);
        assert!(hub
            .manager
            .get_proxy_status("applied-proxy")
            .await
            .is_none());
    }

    #[tokio::test]
    async fn hub_block_ip_rejects_invalid_ip_or_cidr() {
        let hub = test_hub_client().await;

        let (status, err, payload) = hub
            .handle_block_ip(
                BlockIpRequest {
                    ip: "not-an-ip".to_string(),
                    duration_seconds: 0,
                    reason: String::new(),
                }
                .encode_to_vec(),
            )
            .await;

        assert_eq!(status, "ERROR");
        assert!(err.contains("invalid IP address"));
        assert!(payload.is_empty());
    }

    #[test]
    fn template_tls_rejects_partial_config() {
        let dir =
            std::env::temp_dir().join(format!("nitellad-rs-template-tls-{}", uuid::Uuid::new_v4()));
        std::fs::create_dir_all(&dir).unwrap();
        let cert_path = dir.join("cert.pem");
        std::fs::write(&cert_path, "cert").unwrap();

        let ep = crate::config::EntryPoint {
            address: "127.0.0.1:0".to_string(),
            default_action: String::new(),
            default_mock: String::new(),
            default_backend: String::new(),
            fallback_action: String::new(),
            fallback_mock: String::new(),
            tls: Some(crate::config::TlsConfig {
                cert_file: cert_path.to_string_lossy().to_string(),
                key_file: String::new(),
                client_ca: String::new(),
                client_auth: String::new(),
            }),
            rate_limit: None,
        };

        let err = resolve_template_entrypoint_tls(&ep).unwrap_err();
        assert!(err.to_string().contains("certificate and private key"));

        let _ = std::fs::remove_dir_all(dir);
    }

    #[tokio::test]
    async fn hub_legacy_apply_proxy_returns_proxy_status_and_unapplies() {
        let hub = test_hub_client().await;

        let (status, err, payload) = hub.handle_apply_proxy(create_proxy_payload("apply")).await;

        assert_eq!(status, "OK");
        assert!(err.is_empty());
        let proxy_status = ProxyStatus::decode(payload.as_slice()).unwrap();
        assert!(proxy_status.running);
        assert!(!proxy_status.proxy_id.is_empty());

        let (status, err, payload) = hub
            .handle_unapply_proxy(
                DeleteProxyRequest {
                    proxy_id: proxy_status.proxy_id.clone(),
                }
                .encode_to_vec(),
            )
            .await;

        assert_eq!(status, "OK");
        assert!(err.is_empty());
        let delete_resp = DeleteProxyResponse::decode(payload.as_slice()).unwrap();
        assert!(delete_resp.success);
        assert!(hub
            .manager
            .get_proxy_status(&proxy_status.proxy_id)
            .await
            .is_none());
    }

    #[tokio::test]
    async fn hub_add_rule_returns_marshaled_rule_with_generated_id() {
        let hub = test_hub_client().await;
        let (_, _, payload) = hub.handle_create_proxy(create_proxy_payload("rules")).await;
        let proxy = CreateProxyResponse::decode(payload.as_slice()).unwrap();

        let rule = Rule {
            name: "generated-id".to_string(),
            enabled: true,
            action: ActionType::Allow as i32,
            ..Default::default()
        };
        let req = AddRuleRequest {
            proxy_id: proxy.proxy_id.clone(),
            rule: Some(rule),
        };

        let (status, err, payload) = hub.handle_add_rule(req.encode_to_vec()).await;

        assert_eq!(status, "OK");
        assert!(err.is_empty());
        let created = Rule::decode(payload.as_slice()).unwrap();
        assert_eq!(created.name, "generated-id");
        assert!(!created.id.is_empty());

        hub.manager.delete_proxy(&proxy.proxy_id).await.unwrap();
    }

    #[tokio::test]
    async fn hub_create_proxy_bind_failure_returns_ok_with_failed_response() {
        let occupied = std::net::TcpListener::bind("127.0.0.1:0").unwrap();
        let occupied_addr = occupied.local_addr().unwrap().to_string();
        let hub = test_hub_client().await;
        let payload = CreateProxyRequest {
            name: "occupied".to_string(),
            listen_addr: occupied_addr,
            default_action: ActionType::Allow as i32,
            ..Default::default()
        }
        .encode_to_vec();

        let (status, err, payload) = hub.handle_create_proxy(payload).await;

        assert_eq!(status, "OK");
        assert!(err.is_empty());
        let resp = CreateProxyResponse::decode(payload.as_slice()).unwrap();
        assert!(!resp.success);
        assert!(!resp.error_message.is_empty());
    }

    #[tokio::test]
    async fn hub_unapply_missing_proxy_returns_ok_with_failed_response() {
        let hub = test_hub_client().await;
        let payload = DeleteProxyRequest {
            proxy_id: "missing".to_string(),
        }
        .encode_to_vec();

        let (status, err, payload) = hub.handle_unapply_proxy(payload).await;

        assert_eq!(status, "OK");
        assert!(err.is_empty());
        let resp = DeleteProxyResponse::decode(payload.as_slice()).unwrap();
        assert!(!resp.success);
        assert_eq!(resp.error_message, "proxy not applied");
    }

    #[tokio::test]
    async fn p2p_static_dispatch_routes_lifecycle_commands() {
        let hub = test_hub_client().await;

        let create = HubClient::static_dispatch(
            command_types::CREATE_PROXY,
            create_proxy_payload("p2p-create"),
            &hub.manager,
            &hub.applied_proxies,
            &hub.data_dir,
        )
        .await;

        assert_eq!(create.status, "OK");
        assert!(create.error_message.is_empty());
        let create_resp = CreateProxyResponse::decode(create.response_payload.as_slice()).unwrap();
        assert!(create_resp.success);
        assert!(!create_resp.proxy_id.is_empty());

        let list = HubClient::static_dispatch(
            command_types::LIST_PROXIES,
            vec![],
            &hub.manager,
            &hub.applied_proxies,
            &hub.data_dir,
        )
        .await;

        assert_eq!(list.status, "OK");
        let list_resp = ListProxiesResponse::decode(list.response_payload.as_slice()).unwrap();
        assert!(list_resp
            .proxies
            .iter()
            .any(|p| p.proxy_id == create_resp.proxy_id));

        let delete = HubClient::static_dispatch(
            command_types::DELETE_PROXY,
            DeleteProxyRequest {
                proxy_id: create_resp.proxy_id.clone(),
            }
            .encode_to_vec(),
            &hub.manager,
            &hub.applied_proxies,
            &hub.data_dir,
        )
        .await;

        assert_eq!(delete.status, "OK");
        let delete_resp = DeleteProxyResponse::decode(delete.response_payload.as_slice()).unwrap();
        assert!(delete_resp.success);
        assert!(
            !hub.manager
                .get_proxy_status(&create_resp.proxy_id)
                .await
                .unwrap()
                .running
        );

        hub.manager
            .delete_proxy(&create_resp.proxy_id)
            .await
            .unwrap();
    }

    #[tokio::test]
    async fn p2p_static_dispatch_routes_applied_proxy_commands() {
        let hub = test_hub_client().await;

        let apply = HubClient::static_dispatch(
            command_types::APPLY_PROXY,
            create_proxy_payload("p2p-apply"),
            &hub.manager,
            &hub.applied_proxies,
            &hub.data_dir,
        )
        .await;

        assert_eq!(apply.status, "OK");
        assert!(apply.error_message.is_empty());
        let proxy_status = ProxyStatus::decode(apply.response_payload.as_slice()).unwrap();
        assert!(proxy_status.running);
        assert!(!proxy_status.proxy_id.is_empty());

        let applied = HubClient::static_dispatch(
            command_types::GET_APPLIED,
            vec![],
            &hub.manager,
            &hub.applied_proxies,
            &hub.data_dir,
        )
        .await;

        assert_eq!(applied.status, "OK");
        let applied_resp =
            GetAppliedProxiesResponse::decode(applied.response_payload.as_slice()).unwrap();
        assert!(applied_resp
            .proxies
            .iter()
            .any(|p| p.proxy_id == proxy_status.proxy_id));

        let unapply = HubClient::static_dispatch(
            command_types::UNAPPLY_PROXY,
            DeleteProxyRequest {
                proxy_id: proxy_status.proxy_id.clone(),
            }
            .encode_to_vec(),
            &hub.manager,
            &hub.applied_proxies,
            &hub.data_dir,
        )
        .await;

        assert_eq!(unapply.status, "OK");
        let delete_resp = DeleteProxyResponse::decode(unapply.response_payload.as_slice()).unwrap();
        assert!(delete_resp.success);
        assert!(hub
            .manager
            .get_proxy_status(&proxy_status.proxy_id)
            .await
            .is_none());
    }

    #[derive(Default)]
    struct CompatIds {
        direct_proxy: String,
        applied_proxy: String,
        rule: String,
        reload_rule: String,
        extended_rule: String,
    }

    #[derive(Serialize)]
    struct CompatCase {
        name: String,
        command: String,
        status: String,
        error_message: String,
        payload_type: String,
        payload: Value,
    }

    impl CompatCase {
        fn new(
            name: &str,
            cmd_type: i32,
            result: &CommandResult,
            payload_type: &str,
            payload: Value,
        ) -> Self {
            Self {
                name: name.to_string(),
                command: command_name_compat(cmd_type).to_string(),
                status: result.status.clone(),
                error_message: result.error_message.clone(),
                payload_type: payload_type.to_string(),
                payload,
            }
        }
    }

    #[tokio::test]
    async fn compat_harness_dump_rust() {
        let Ok(out_path) = std::env::var("NITELLA_COMPAT_DUMP") else {
            return;
        };

        let hub = test_hub_client().await;
        let mut ids = CompatIds::default();
        let mut cases = Vec::new();

        cases.push(
            rust_compat_stats_case(&hub, "status_empty", command_types::STATUS, vec![], &ids).await,
        );

        let create = rust_compat_dispatch(
            &hub,
            command_types::CREATE_PROXY,
            create_proxy_payload("compat-direct"),
        )
        .await;
        let create_resp = CreateProxyResponse::decode(create.response_payload.as_slice()).unwrap();
        assert!(!create_resp.proxy_id.is_empty());
        ids.direct_proxy = create_resp.proxy_id.clone();
        cases.push(CompatCase::new(
            "create_proxy",
            command_types::CREATE_PROXY,
            &create,
            "CreateProxyResponse",
            normalize_create_proxy_response_compat(&create_resp, &ids),
        ));

        cases.push(
            rust_compat_stats_case(
                &hub,
                "status_after_create",
                command_types::STATUS,
                vec![],
                &ids,
            )
            .await,
        );
        cases.push(
            rust_compat_stats_case(
                &hub,
                "metrics_after_create",
                command_types::GET_METRICS,
                vec![],
                &ids,
            )
            .await,
        );
        cases.push(
            rust_compat_stats_case(
                &hub,
                "stats_control_after_create",
                command_types::STATS_CONTROL,
                vec![],
                &ids,
            )
            .await,
        );
        cases.push(rust_compat_list_proxies_case(&hub, "list_after_create", &ids).await);

        let add_rule_req = AddRuleRequest {
            proxy_id: ids.direct_proxy.clone(),
            rule: Some(Rule {
                name: "allow-local".to_string(),
                priority: 100,
                enabled: true,
                action: ActionType::Allow as i32,
                conditions: vec![Condition {
                    r#type: ConditionType::SourceIp as i32,
                    op: Operator::Eq as i32,
                    value: "127.0.0.1".to_string(),
                    negate: false,
                }],
                rate_limit: Some(RateLimitConfig {
                    max_connections: 2,
                    interval_seconds: 10,
                    auto_block: true,
                    block_duration_seconds: 30,
                    block_steps_seconds: vec![30, 60],
                    count_only_failures: true,
                    failure_duration_threshold: 3,
                }),
                ..Default::default()
            }),
        };
        let add_rule =
            rust_compat_dispatch(&hub, command_types::ADD_RULE, add_rule_req.encode_to_vec()).await;
        let added_rule = Rule::decode(add_rule.response_payload.as_slice()).unwrap();
        assert!(!added_rule.id.is_empty());
        ids.rule = added_rule.id.clone();
        cases.push(CompatCase::new(
            "add_rule",
            command_types::ADD_RULE,
            &add_rule,
            "Rule",
            normalize_rule_compat(&added_rule, &ids),
        ));

        let list_rules = rust_compat_dispatch(
            &hub,
            command_types::LIST_RULES,
            ListRulesRequest {
                proxy_id: ids.direct_proxy.clone(),
            }
            .encode_to_vec(),
        )
        .await;
        let list_rules_resp =
            ListRulesResponse::decode(list_rules.response_payload.as_slice()).unwrap();
        cases.push(CompatCase::new(
            "list_rules",
            command_types::LIST_RULES,
            &list_rules,
            "ListRulesResponse",
            normalize_list_rules_response_compat(&list_rules_resp, &ids),
        ));

        let disable = rust_compat_dispatch(
            &hub,
            command_types::DISABLE_PROXY,
            DisableProxyRequest {
                proxy_id: ids.direct_proxy.clone(),
            }
            .encode_to_vec(),
        )
        .await;
        let disable_resp =
            DisableProxyResponse::decode(disable.response_payload.as_slice()).unwrap();
        cases.push(CompatCase::new(
            "disable_proxy",
            command_types::DISABLE_PROXY,
            &disable,
            "DisableProxyResponse",
            normalize_disable_proxy_response_compat(&disable_resp),
        ));
        cases.push(rust_compat_list_proxies_case(&hub, "list_after_disable", &ids).await);

        let enable = rust_compat_dispatch(
            &hub,
            command_types::ENABLE_PROXY,
            EnableProxyRequest {
                proxy_id: ids.direct_proxy.clone(),
            }
            .encode_to_vec(),
        )
        .await;
        let enable_resp = EnableProxyResponse::decode(enable.response_payload.as_slice()).unwrap();
        cases.push(CompatCase::new(
            "enable_proxy",
            command_types::ENABLE_PROXY,
            &enable,
            "EnableProxyResponse",
            normalize_enable_proxy_response_compat(&enable_resp),
        ));
        cases.push(rust_compat_list_proxies_case(&hub, "list_after_enable", &ids).await);

        let update = rust_compat_dispatch(
            &hub,
            command_types::UPDATE_PROXY,
            UpdateProxyRequest {
                proxy_id: ids.direct_proxy.clone(),
                default_backend: "127.0.0.1:9".to_string(),
                ..Default::default()
            }
            .encode_to_vec(),
        )
        .await;
        let update_resp = UpdateProxyResponse::decode(update.response_payload.as_slice()).unwrap();
        cases.push(CompatCase::new(
            "update_proxy_backend",
            command_types::UPDATE_PROXY,
            &update,
            "UpdateProxyResponse",
            normalize_update_proxy_response_compat(&update_resp),
        ));

        ids.reload_rule = "compat-reload-rule".to_string();
        ids.extended_rule = "compat-extended-rule".to_string();
        let reload = rust_compat_dispatch(
            &hub,
            command_types::RELOAD_RULES,
            ReloadRulesRequest {
                rules: vec![
                    Rule {
                        id: ids.reload_rule.clone(),
                        name: "reload-block".to_string(),
                        priority: 200,
                        enabled: true,
                        action: ActionType::Block as i32,
                        conditions: vec![Condition {
                            r#type: ConditionType::SourceIp as i32,
                            op: Operator::Eq as i32,
                            value: "10.0.0.1".to_string(),
                            negate: false,
                        }],
                        ..Default::default()
                    },
                    Rule {
                        id: ids.extended_rule.clone(),
                        name: "extended-cidr-negated-rate".to_string(),
                        priority: 150,
                        enabled: true,
                        action: ActionType::Allow as i32,
                        expression: "SourceIP(`10.10.0.0/16`) && !GeoISP(`Example ISP`)"
                            .to_string(),
                        conditions: vec![
                            Condition {
                                r#type: ConditionType::SourceIp as i32,
                                op: Operator::Cidr as i32,
                                value: "10.10.0.0/16".to_string(),
                                negate: false,
                            },
                            Condition {
                                r#type: ConditionType::GeoIsp as i32,
                                op: Operator::Contains as i32,
                                value: "Example ISP".to_string(),
                                negate: true,
                            },
                            Condition {
                                r#type: ConditionType::TlsCn as i32,
                                op: Operator::Eq as i32,
                                value: "node.example".to_string(),
                                negate: false,
                            },
                        ],
                        rate_limit: Some(RateLimitConfig {
                            max_connections: 3,
                            interval_seconds: 15,
                            auto_block: true,
                            block_duration_seconds: 45,
                            ..Default::default()
                        }),
                        ..Default::default()
                    },
                ],
            }
            .encode_to_vec(),
        )
        .await;
        let reload_resp = ReloadRulesResponse::decode(reload.response_payload.as_slice()).unwrap();
        cases.push(CompatCase::new(
            "reload_rules",
            command_types::RELOAD_RULES,
            &reload,
            "ReloadRulesResponse",
            normalize_reload_rules_response_compat(&reload_resp),
        ));
        cases.push(rust_compat_list_rules_case(&hub, "list_rules_after_reload", &ids).await);

        let restart = rust_compat_dispatch(&hub, command_types::RESTART_LISTENERS, vec![]).await;
        let restart_resp =
            RestartListenersResponse::decode(restart.response_payload.as_slice()).unwrap();
        cases.push(CompatCase::new(
            "restart_listeners",
            command_types::RESTART_LISTENERS,
            &restart,
            "RestartListenersResponse",
            normalize_restart_listeners_response_compat(&restart_resp),
        ));
        cases.push(rust_compat_list_proxies_case(&hub, "list_after_restart", &ids).await);

        let get_conns = rust_compat_dispatch(
            &hub,
            command_types::GET_ACTIVE_CONNECTIONS,
            GetActiveConnectionsRequest {
                proxy_id: ids.direct_proxy.clone(),
                ..Default::default()
            }
            .encode_to_vec(),
        )
        .await;
        let get_conns_resp =
            GetActiveConnectionsResponse::decode(get_conns.response_payload.as_slice()).unwrap();
        cases.push(CompatCase::new(
            "get_active_connections_empty",
            command_types::GET_ACTIVE_CONNECTIONS,
            &get_conns,
            "GetActiveConnectionsResponse",
            normalize_get_active_connections_response_compat(&get_conns_resp),
        ));

        let close_all = rust_compat_dispatch(
            &hub,
            command_types::CLOSE_ALL_CONNECTIONS,
            CloseAllConnectionsRequest {
                proxy_id: ids.direct_proxy.clone(),
            }
            .encode_to_vec(),
        )
        .await;
        let close_all_resp =
            CloseAllConnectionsResponse::decode(close_all.response_payload.as_slice()).unwrap();
        cases.push(CompatCase::new(
            "close_all_connections_empty",
            command_types::CLOSE_ALL_CONNECTIONS,
            &close_all,
            "CloseAllConnectionsResponse",
            normalize_close_all_connections_response_compat(&close_all_resp),
        ));

        let close = rust_compat_dispatch(
            &hub,
            command_types::CLOSE_CONNECTION,
            CloseConnectionRequest {
                proxy_id: ids.direct_proxy.clone(),
                ..Default::default()
            }
            .encode_to_vec(),
        )
        .await;
        cases.push(CompatCase::new(
            "close_connection_missing_conn_id",
            command_types::CLOSE_CONNECTION,
            &close,
            "Empty",
            normalize_empty_payload_compat(&close.response_payload),
        ));

        let close_unknown = rust_compat_dispatch(
            &hub,
            command_types::CLOSE_CONNECTION,
            CloseConnectionRequest {
                proxy_id: ids.direct_proxy.clone(),
                conn_id: "missing-conn".to_string(),
            }
            .encode_to_vec(),
        )
        .await;
        cases.push(CompatCase::new(
            "close_connection_unknown_conn_id",
            command_types::CLOSE_CONNECTION,
            &close_unknown,
            "Empty",
            normalize_empty_payload_compat(&close_unknown.response_payload),
        ));

        let live_backend_addr = rust_compat_start_echo_backend().await;
        let live_create = rust_compat_dispatch(
            &hub,
            command_types::CREATE_PROXY,
            create_proxy_payload_with_backend("compat-live", &live_backend_addr),
        )
        .await;
        let live_create_resp =
            CreateProxyResponse::decode(live_create.response_payload.as_slice()).unwrap();
        assert!(!live_create_resp.proxy_id.is_empty());
        cases.push(CompatCase::new(
            "create_live_proxy",
            command_types::CREATE_PROXY,
            &live_create,
            "CreateProxyResponse",
            normalize_create_proxy_response_compat(&live_create_resp, &ids),
        ));

        let live_status = hub
            .manager
            .get_proxy_status(&live_create_resp.proxy_id)
            .await
            .unwrap();
        let mut live_stream = rust_compat_connect_and_roundtrip(&live_status.listen_addr).await;
        rust_compat_wait_for_connections(&hub, &live_create_resp.proxy_id, 1).await;

        let live_conns = rust_compat_dispatch(
            &hub,
            command_types::GET_ACTIVE_CONNECTIONS,
            GetActiveConnectionsRequest {
                proxy_id: live_create_resp.proxy_id.clone(),
                ..Default::default()
            }
            .encode_to_vec(),
        )
        .await;
        let live_conns_resp =
            GetActiveConnectionsResponse::decode(live_conns.response_payload.as_slice()).unwrap();
        assert!(!live_conns_resp.connections.is_empty());
        let live_conn_id = live_conns_resp.connections[0].id.clone();
        cases.push(CompatCase::new(
            "get_active_connections_live",
            command_types::GET_ACTIVE_CONNECTIONS,
            &live_conns,
            "GetActiveConnectionsResponse",
            normalize_active_connections_detailed_compat(&live_conns_resp),
        ));

        let close_live = rust_compat_dispatch(
            &hub,
            command_types::CLOSE_CONNECTION,
            CloseConnectionRequest {
                proxy_id: live_create_resp.proxy_id.clone(),
                conn_id: live_conn_id,
            }
            .encode_to_vec(),
        )
        .await;
        let close_live_resp =
            CloseConnectionResponse::decode(close_live.response_payload.as_slice()).unwrap();
        cases.push(CompatCase::new(
            "close_connection_live",
            command_types::CLOSE_CONNECTION,
            &close_live,
            "CloseConnectionResponse",
            normalize_close_connection_response_compat(&close_live_resp),
        ));
        rust_compat_wait_for_connections(&hub, &live_create_resp.proxy_id, 0).await;
        let _ = live_stream.shutdown().await;

        let live_after_close = rust_compat_dispatch(
            &hub,
            command_types::GET_ACTIVE_CONNECTIONS,
            GetActiveConnectionsRequest {
                proxy_id: live_create_resp.proxy_id.clone(),
                ..Default::default()
            }
            .encode_to_vec(),
        )
        .await;
        let live_after_close_resp =
            GetActiveConnectionsResponse::decode(live_after_close.response_payload.as_slice())
                .unwrap();
        cases.push(CompatCase::new(
            "get_active_connections_after_close_live",
            command_types::GET_ACTIVE_CONNECTIONS,
            &live_after_close,
            "GetActiveConnectionsResponse",
            normalize_get_active_connections_response_compat(&live_after_close_resp),
        ));
        hub.manager
            .delete_proxy(&live_create_resp.proxy_id)
            .await
            .unwrap();

        cases.push(
            rust_compat_list_active_approvals_case(&hub, "list_active_approvals_empty").await,
        );

        const APPROVAL_SOURCE_IP: &str = "192.0.2.44";
        const APPROVAL_RULE_ID: &str = "compat-approval-rule";
        let approval_bytes_in = Arc::new(AtomicU64::new(11));
        let approval_bytes_out = Arc::new(AtomicU64::new(17));
        hub.manager
            .approval_manager
            .add_to_cache_with_geo(
                APPROVAL_SOURCE_IP,
                APPROVAL_RULE_ID,
                &ids.direct_proxy,
                "",
                true,
                3600,
                "US",
                "New York",
                "Compat ISP",
            )
            .await;
        hub.manager
            .approval_manager
            .set_conn_id(
                APPROVAL_SOURCE_IP,
                APPROVAL_RULE_ID,
                "",
                "compat-approval-conn",
                approval_bytes_in,
                approval_bytes_out,
            )
            .await;
        cases.push(
            rust_compat_list_active_approvals_detailed_case(
                &hub,
                "list_active_approvals_seeded",
                &ids,
                ListActiveApprovalsRequest::default(),
            )
            .await,
        );
        cases.push(
            rust_compat_list_active_approvals_detailed_case(
                &hub,
                "list_active_approvals_filter_source",
                &ids,
                ListActiveApprovalsRequest {
                    source_ip: APPROVAL_SOURCE_IP.to_string(),
                    ..Default::default()
                },
            )
            .await,
        );
        cases.push(
            rust_compat_list_active_approvals_detailed_case(
                &hub,
                "list_active_approvals_filter_miss",
                &ids,
                ListActiveApprovalsRequest {
                    source_ip: "198.51.100.200".to_string(),
                    ..Default::default()
                },
            )
            .await,
        );

        let cancel_seed = rust_compat_dispatch(
            &hub,
            command_types::CANCEL_APPROVAL,
            CancelApprovalRequest {
                key: format!("{}\0{}", APPROVAL_SOURCE_IP, APPROVAL_RULE_ID),
                close_connections: false,
            }
            .encode_to_vec(),
        )
        .await;
        let cancel_seed_resp =
            CancelApprovalResponse::decode(cancel_seed.response_payload.as_slice()).unwrap();
        cases.push(CompatCase::new(
            "cancel_approval_seeded",
            command_types::CANCEL_APPROVAL,
            &cancel_seed,
            "CancelApprovalResponse",
            normalize_cancel_approval_response_compat(&cancel_seed_resp),
        ));
        cases.push(
            rust_compat_list_active_approvals_case(
                &hub,
                "list_active_approvals_after_cancel_seeded",
            )
            .await,
        );

        let cancel = rust_compat_dispatch(
            &hub,
            command_types::CANCEL_APPROVAL,
            CancelApprovalRequest {
                key: "bad-key".to_string(),
                close_connections: false,
            }
            .encode_to_vec(),
        )
        .await;
        let cancel_resp =
            CancelApprovalResponse::decode(cancel.response_payload.as_slice()).unwrap();
        cases.push(CompatCase::new(
            "cancel_approval_invalid_key",
            command_types::CANCEL_APPROVAL,
            &cancel,
            "CancelApprovalResponse",
            normalize_cancel_approval_response_compat(&cancel_resp),
        ));

        cases.push(rust_compat_get_geoip_status_case(&hub, "get_geoip_status_initial").await);

        let lookup = rust_compat_dispatch(
            &hub,
            command_types::LOOKUP_IP,
            LookupIpRequest {
                ip: "127.0.0.1".to_string(),
            }
            .encode_to_vec(),
        )
        .await;
        let lookup_resp = LookupIpResponse::decode(lookup.response_payload.as_slice()).unwrap();
        cases.push(CompatCase::new(
            "lookup_ip_loopback",
            command_types::LOOKUP_IP,
            &lookup,
            "LookupIPResponse",
            normalize_lookup_ip_response_compat(&lookup_resp),
        ));

        let block = rust_compat_dispatch(
            &hub,
            command_types::BLOCK_IP,
            BlockIpRequest {
                ip: "203.0.113.7".to_string(),
                duration_seconds: 60,
                ..Default::default()
            }
            .encode_to_vec(),
        )
        .await;
        cases.push(CompatCase::new(
            "block_ip",
            command_types::BLOCK_IP,
            &block,
            "Empty",
            normalize_empty_payload_compat(&block.response_payload),
        ));
        cases.push(rust_compat_list_global_rules_case(&hub, "list_global_rules_after_block").await);

        let allow = rust_compat_dispatch(
            &hub,
            command_types::ALLOW_IP,
            AllowIpRequest {
                ip: "198.51.100.9".to_string(),
                duration_seconds: 120,
            }
            .encode_to_vec(),
        )
        .await;
        cases.push(CompatCase::new(
            "allow_ip",
            command_types::ALLOW_IP,
            &allow,
            "Empty",
            normalize_empty_payload_compat(&allow.response_payload),
        ));
        cases.push(rust_compat_list_global_rules_case(&hub, "list_global_rules_after_allow").await);

        let remove_global = rust_compat_dispatch(
            &hub,
            command_types::REMOVE_GLOBAL_RULE,
            RemoveGlobalRuleRequest {
                rule_id: "global-block-203.0.113.7".to_string(),
            }
            .encode_to_vec(),
        )
        .await;
        let remove_global_resp =
            RemoveGlobalRuleResponse::decode(remove_global.response_payload.as_slice()).unwrap();
        cases.push(CompatCase::new(
            "remove_global_rule",
            command_types::REMOVE_GLOBAL_RULE,
            &remove_global,
            "RemoveGlobalRuleResponse",
            normalize_remove_global_rule_response_compat(&remove_global_resp),
        ));
        cases
            .push(rust_compat_list_global_rules_case(&hub, "list_global_rules_after_remove").await);

        let delete = rust_compat_dispatch(
            &hub,
            command_types::DELETE_PROXY,
            DeleteProxyRequest {
                proxy_id: ids.direct_proxy.clone(),
            }
            .encode_to_vec(),
        )
        .await;
        let delete_resp = DeleteProxyResponse::decode(delete.response_payload.as_slice()).unwrap();
        cases.push(CompatCase::new(
            "delete_proxy",
            command_types::DELETE_PROXY,
            &delete,
            "DeleteProxyResponse",
            normalize_delete_proxy_response_compat(&delete_resp),
        ));
        cases.push(rust_compat_list_proxies_case(&hub, "list_after_delete", &ids).await);

        let apply_req = ApplyProxyRequest {
            proxy_id: "compat-template-proxy".to_string(),
            revision_num: 7,
            config_yaml: r#"entryPoints:
  main:
    address: 127.0.0.1:0
    defaultAction: allow
tcp:
  routers:
    main:
      entryPoints: [main]
      service: backend
  services:
    backend:
      address: 127.0.0.1:9
"#
            .to_string(),
            config_hash: "compat-template-hash".to_string(),
        };
        let apply =
            rust_compat_dispatch(&hub, command_types::APPLY_PROXY, apply_req.encode_to_vec()).await;
        let apply_resp = ApplyProxyResponse::decode(apply.response_payload.as_slice()).unwrap();
        ids.applied_proxy = apply_req.proxy_id.clone();
        cases.push(CompatCase::new(
            "apply_proxy_template",
            command_types::APPLY_PROXY,
            &apply,
            "ApplyProxyResponse",
            normalize_apply_proxy_response_compat(&apply_resp),
        ));

        cases.push(rust_compat_get_applied_case(&hub, "get_applied_after_apply", &ids).await);

        let unapply = rust_compat_dispatch(
            &hub,
            command_types::UNAPPLY_PROXY,
            DeleteProxyRequest {
                proxy_id: ids.applied_proxy.clone(),
            }
            .encode_to_vec(),
        )
        .await;
        let unapply_resp =
            DeleteProxyResponse::decode(unapply.response_payload.as_slice()).unwrap();
        cases.push(CompatCase::new(
            "unapply_proxy",
            command_types::UNAPPLY_PROXY,
            &unapply,
            "DeleteProxyResponse",
            normalize_delete_proxy_response_compat(&unapply_resp),
        ));
        cases.push(rust_compat_get_applied_case(&hub, "get_applied_after_unapply", &ids).await);

        if !ids.direct_proxy.is_empty() {
            let _ = hub.manager.delete_proxy(&ids.direct_proxy).await;
        }

        let json = serde_json::to_string_pretty(&cases).unwrap() + "\n";
        std::fs::write(out_path, json).unwrap();
    }

    async fn rust_compat_dispatch(
        hub: &HubClient,
        cmd_type: i32,
        payload: Vec<u8>,
    ) -> CommandResult {
        HubClient::static_dispatch(
            cmd_type,
            payload,
            &hub.manager,
            &hub.applied_proxies,
            &hub.data_dir,
        )
        .await
    }

    async fn rust_compat_stats_case(
        hub: &HubClient,
        name: &str,
        cmd_type: i32,
        payload: Vec<u8>,
        _ids: &CompatIds,
    ) -> CompatCase {
        let result = rust_compat_dispatch(hub, cmd_type, payload).await;
        let resp = StatsSummaryResponse::decode(result.response_payload.as_slice()).unwrap();
        CompatCase::new(
            name,
            cmd_type,
            &result,
            "StatsSummaryResponse",
            normalize_stats_summary_compat(&resp),
        )
    }

    async fn rust_compat_list_proxies_case(
        hub: &HubClient,
        name: &str,
        ids: &CompatIds,
    ) -> CompatCase {
        let result = rust_compat_dispatch(hub, command_types::LIST_PROXIES, vec![]).await;
        let resp = ListProxiesResponse::decode(result.response_payload.as_slice()).unwrap();
        CompatCase::new(
            name,
            command_types::LIST_PROXIES,
            &result,
            "ListProxiesResponse",
            normalize_list_proxies_response_compat(&resp, ids),
        )
    }

    async fn rust_compat_get_applied_case(
        hub: &HubClient,
        name: &str,
        ids: &CompatIds,
    ) -> CompatCase {
        let result = rust_compat_dispatch(hub, command_types::GET_APPLIED, vec![]).await;
        let resp = GetAppliedProxiesResponse::decode(result.response_payload.as_slice()).unwrap();
        CompatCase::new(
            name,
            command_types::GET_APPLIED,
            &result,
            "GetAppliedProxiesResponse",
            normalize_get_applied_response_compat(&resp, ids),
        )
    }

    async fn rust_compat_list_rules_case(
        hub: &HubClient,
        name: &str,
        ids: &CompatIds,
    ) -> CompatCase {
        let result = rust_compat_dispatch(
            hub,
            command_types::LIST_RULES,
            ListRulesRequest {
                proxy_id: ids.direct_proxy.clone(),
            }
            .encode_to_vec(),
        )
        .await;
        let resp = ListRulesResponse::decode(result.response_payload.as_slice()).unwrap();
        CompatCase::new(
            name,
            command_types::LIST_RULES,
            &result,
            "ListRulesResponse",
            normalize_list_rules_response_compat(&resp, ids),
        )
    }

    async fn rust_compat_list_global_rules_case(hub: &HubClient, name: &str) -> CompatCase {
        let result = rust_compat_dispatch(hub, command_types::LIST_GLOBAL_RULES, vec![]).await;
        let resp = ListGlobalRulesResponse::decode(result.response_payload.as_slice()).unwrap();
        CompatCase::new(
            name,
            command_types::LIST_GLOBAL_RULES,
            &result,
            "ListGlobalRulesResponse",
            normalize_list_global_rules_response_compat(&resp),
        )
    }

    async fn rust_compat_list_active_approvals_case(hub: &HubClient, name: &str) -> CompatCase {
        let result = rust_compat_dispatch(
            hub,
            command_types::LIST_ACTIVE_APPROVALS,
            ListActiveApprovalsRequest::default().encode_to_vec(),
        )
        .await;
        let resp = ListActiveApprovalsResponse::decode(result.response_payload.as_slice()).unwrap();
        CompatCase::new(
            name,
            command_types::LIST_ACTIVE_APPROVALS,
            &result,
            "ListActiveApprovalsResponse",
            normalize_list_active_approvals_response_compat(&resp),
        )
    }

    async fn rust_compat_list_active_approvals_detailed_case(
        hub: &HubClient,
        name: &str,
        ids: &CompatIds,
        req: ListActiveApprovalsRequest,
    ) -> CompatCase {
        let result = rust_compat_dispatch(
            hub,
            command_types::LIST_ACTIVE_APPROVALS,
            req.encode_to_vec(),
        )
        .await;
        let resp = ListActiveApprovalsResponse::decode(result.response_payload.as_slice()).unwrap();
        CompatCase::new(
            name,
            command_types::LIST_ACTIVE_APPROVALS,
            &result,
            "ListActiveApprovalsResponse",
            normalize_list_active_approvals_detailed_compat(&resp, ids),
        )
    }

    async fn rust_compat_get_geoip_status_case(hub: &HubClient, name: &str) -> CompatCase {
        let result = rust_compat_dispatch(hub, command_types::GET_GEOIP_STATUS, vec![]).await;
        let resp = GetGeoIpStatusResponse::decode(result.response_payload.as_slice()).unwrap();
        CompatCase::new(
            name,
            command_types::GET_GEOIP_STATUS,
            &result,
            "GetGeoIPStatusResponse",
            normalize_get_geoip_status_response_compat(&resp),
        )
    }

    async fn rust_compat_start_echo_backend() -> String {
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let addr = listener.local_addr().unwrap().to_string();
        tokio::spawn(async move {
            loop {
                let Ok((socket, _)) = listener.accept().await else {
                    return;
                };
                tokio::spawn(async move {
                    let (mut reader, mut writer) = socket.into_split();
                    let _ = tokio::io::copy(&mut reader, &mut writer).await;
                });
            }
        });
        addr
    }

    async fn rust_compat_connect_and_roundtrip(addr: &str) -> TcpStream {
        let mut stream = TcpStream::connect(addr).await.unwrap();
        stream.write_all(b"ping").await.unwrap();
        let mut buf = [0u8; 4];
        stream.read_exact(&mut buf).await.unwrap();
        assert_eq!(&buf, b"ping");
        stream
    }

    async fn rust_compat_wait_for_connections(hub: &HubClient, proxy_id: &str, want: usize) {
        let deadline = tokio::time::Instant::now() + std::time::Duration::from_secs(2);
        loop {
            let got = hub
                .manager
                .get_active_connections(Some(proxy_id.to_string()))
                .await
                .len();
            if got == want {
                return;
            }
            assert!(
                tokio::time::Instant::now() < deadline,
                "timed out waiting for {want} active connections on {proxy_id}, got {got}"
            );
            tokio::time::sleep(std::time::Duration::from_millis(10)).await;
        }
    }

    fn normalize_stats_summary_compat(resp: &StatsSummaryResponse) -> Value {
        json!({
            "total_connections": resp.total_connections,
            "active_connections": resp.active_connections,
            "total_bytes_in": resp.total_bytes_in,
            "total_bytes_out": resp.total_bytes_out,
            "proxy_count": resp.proxy_count,
        })
    }

    fn normalize_create_proxy_response_compat(
        resp: &CreateProxyResponse,
        ids: &CompatIds,
    ) -> Value {
        json!({
            "success": resp.success,
            "error_message": resp.error_message,
            "proxy_id": canonical_proxy_id_compat(&resp.proxy_id, ids),
        })
    }

    fn normalize_delete_proxy_response_compat(resp: &DeleteProxyResponse) -> Value {
        json!({
            "success": resp.success,
            "error_message": resp.error_message,
        })
    }

    fn normalize_disable_proxy_response_compat(resp: &DisableProxyResponse) -> Value {
        json!({
            "success": resp.success,
            "error_message": resp.error_message,
        })
    }

    fn normalize_enable_proxy_response_compat(resp: &EnableProxyResponse) -> Value {
        json!({
            "success": resp.success,
            "error_message": resp.error_message,
        })
    }

    fn normalize_update_proxy_response_compat(resp: &UpdateProxyResponse) -> Value {
        json!({
            "success": resp.success,
            "error_message": resp.error_message,
        })
    }

    fn normalize_reload_rules_response_compat(resp: &ReloadRulesResponse) -> Value {
        json!({
            "success": resp.success,
            "rules_loaded": resp.rules_loaded,
            "error_message": resp.error_message,
        })
    }

    fn normalize_restart_listeners_response_compat(resp: &RestartListenersResponse) -> Value {
        json!({
            "success": resp.success,
            "restarted_count": resp.restarted_count,
            "error_message": resp.error_message,
        })
    }

    fn normalize_get_active_connections_response_compat(
        resp: &GetActiveConnectionsResponse,
    ) -> Value {
        json!({ "connections": resp.connections.len() })
    }

    fn normalize_close_all_connections_response_compat(
        resp: &CloseAllConnectionsResponse,
    ) -> Value {
        json!({
            "success": resp.success,
            "error_message": resp.error_message,
        })
    }

    fn normalize_close_connection_response_compat(resp: &CloseConnectionResponse) -> Value {
        json!({
            "success": resp.success,
            "error_message": resp.error_message,
        })
    }

    fn normalize_active_connections_detailed_compat(resp: &GetActiveConnectionsResponse) -> Value {
        let mut connections: Vec<Value> = resp
            .connections
            .iter()
            .map(|conn| {
                json!({
                    "source_ip": conn.source_ip,
                    "dest_addr": if conn.dest_addr.is_empty() { "" } else { "<dest_addr>" },
                    "bytes_in_positive": conn.bytes_in > 0,
                    "bytes_out_positive": conn.bytes_out > 0,
                })
            })
            .collect();
        connections.sort_by_key(|conn| conn["source_ip"].as_str().unwrap_or_default().to_string());
        json!({
            "connections": resp.connections.len(),
            "items": connections,
        })
    }

    fn normalize_list_active_approvals_response_compat(
        resp: &ListActiveApprovalsResponse,
    ) -> Value {
        json!({ "approvals": resp.approvals.len() })
    }

    fn normalize_list_active_approvals_detailed_compat(
        resp: &ListActiveApprovalsResponse,
        ids: &CompatIds,
    ) -> Value {
        let mut approvals: Vec<Value> = resp
            .approvals
            .iter()
            .map(|approval| {
                json!({
                    "source_ip": approval.source_ip,
                    "rule_id": approval.rule_id,
                    "proxy_id": canonical_proxy_id_compat(&approval.proxy_id, ids),
                    "allowed": approval.allowed,
                    "bytes_in": approval.bytes_in,
                    "bytes_out": approval.bytes_out,
                    "geo_country": approval.geo_country,
                    "geo_city": approval.geo_city,
                    "geo_isp": approval.geo_isp,
                    "blocked_count": approval.blocked_count,
                    "conn_ids": approval.conn_ids.len(),
                })
            })
            .collect();
        approvals.sort_by_key(|approval| {
            format!(
                "{}\0{}",
                approval["source_ip"].as_str().unwrap_or_default(),
                approval["rule_id"].as_str().unwrap_or_default()
            )
        });
        json!({
            "approvals": resp.approvals.len(),
            "items": approvals,
        })
    }

    fn normalize_cancel_approval_response_compat(resp: &CancelApprovalResponse) -> Value {
        json!({
            "success": resp.success,
            "error_message": resp.error_message,
            "connections_closed": resp.connections_closed,
        })
    }

    fn normalize_get_geoip_status_response_compat(resp: &GetGeoIpStatusResponse) -> Value {
        json!({
            "enabled": resp.enabled,
            "mode": resp.mode,
            "city_db_path": resp.city_db_path,
            "isp_db_path": resp.isp_db_path,
            "provider": resp.provider,
            "strategy": resp.strategy,
        })
    }

    fn normalize_lookup_ip_response_compat(resp: &LookupIpResponse) -> Value {
        let geo = resp.geo.as_ref();
        json!({
            "cached": resp.cached,
            "country": geo.map(|g| g.country.as_str()).unwrap_or(""),
            "city": geo.map(|g| g.city.as_str()).unwrap_or(""),
            "isp": geo.map(|g| g.isp.as_str()).unwrap_or(""),
            "country_code": geo.map(|g| g.country_code.as_str()).unwrap_or(""),
            "source": geo.map(|g| g.source.as_str()).unwrap_or(""),
        })
    }

    fn normalize_remove_global_rule_response_compat(resp: &RemoveGlobalRuleResponse) -> Value {
        json!({
            "success": resp.success,
            "error_message": resp.error_message,
        })
    }

    fn normalize_empty_payload_compat(raw: &[u8]) -> Value {
        json!({ "len": raw.len() })
    }

    fn normalize_apply_proxy_response_compat(resp: &ApplyProxyResponse) -> Value {
        json!({
            "success": resp.success,
            "error_message": resp.error_message,
        })
    }

    fn normalize_list_proxies_response_compat(
        resp: &ListProxiesResponse,
        ids: &CompatIds,
    ) -> Value {
        let mut proxies: Vec<Value> = resp
            .proxies
            .iter()
            .map(|proxy| normalize_proxy_status_compat(proxy, ids))
            .collect();
        proxies.sort_by_key(|proxy| proxy["proxy_id"].as_str().unwrap_or_default().to_string());
        json!({ "proxies": proxies })
    }

    fn normalize_proxy_status_compat(resp: &ProxyStatus, ids: &CompatIds) -> Value {
        let listen_addr = if resp.listen_addr.is_empty() {
            ""
        } else {
            "<listen_addr>"
        };
        json!({
            "proxy_id": canonical_proxy_id_compat(&resp.proxy_id, ids),
            "running": resp.running,
            "listen_addr": listen_addr,
            "default_backend": resp.default_backend,
            "default_action": resp.default_action,
            "default_mock": resp.default_mock,
            "fallback_action": resp.fallback_action,
            "fallback_mock": resp.fallback_mock,
        })
    }

    fn normalize_list_rules_response_compat(resp: &ListRulesResponse, ids: &CompatIds) -> Value {
        let mut rules: Vec<Value> = resp
            .rules
            .iter()
            .map(|rule| normalize_rule_compat(rule, ids))
            .collect();
        rules.sort_by_key(|rule| rule["id"].as_str().unwrap_or_default().to_string());
        json!({ "rules": rules })
    }

    fn normalize_rule_compat(rule: &Rule, ids: &CompatIds) -> Value {
        let mut conditions: Vec<Value> = rule
            .conditions
            .iter()
            .map(|condition| {
                json!({
                    "type": condition.r#type,
                    "op": condition.op,
                    "value": condition.value,
                    "negate": condition.negate,
                })
            })
            .collect();
        conditions
            .sort_by_key(|condition| condition["value"].as_str().unwrap_or_default().to_string());

        json!({
            "id": canonical_rule_id_compat(&rule.id, ids),
            "name": rule.name,
            "priority": rule.priority,
            "enabled": rule.enabled,
            "action": rule.action,
            "target_backend": rule.target_backend,
            "expression": rule.expression,
            "conditions": conditions,
            "rate_limit": normalize_rate_limit_compat(rule.rate_limit.as_ref()),
        })
    }

    fn normalize_rate_limit_compat(rate_limit: Option<&RateLimitConfig>) -> Value {
        match rate_limit {
            Some(rate_limit) => json!({
                "max_connections": rate_limit.max_connections,
                "interval_seconds": rate_limit.interval_seconds,
                "auto_block": rate_limit.auto_block,
                "block_duration_seconds": rate_limit.block_duration_seconds,
                "block_steps_seconds": rate_limit.block_steps_seconds,
                "count_only_failures": rate_limit.count_only_failures,
                "failure_duration_threshold": rate_limit.failure_duration_threshold,
            }),
            None => Value::Null,
        }
    }

    fn normalize_get_applied_response_compat(
        resp: &GetAppliedProxiesResponse,
        ids: &CompatIds,
    ) -> Value {
        let mut proxies: Vec<Value> = resp
            .proxies
            .iter()
            .map(|proxy| {
                json!({
                    "proxy_id": canonical_proxy_id_compat(&proxy.proxy_id, ids),
                    "revision_num": proxy.revision_num,
                    "status": proxy.status,
                    "error_message": proxy.error_message,
                })
            })
            .collect();
        proxies.sort_by_key(|proxy| proxy["proxy_id"].as_str().unwrap_or_default().to_string());
        json!({ "proxies": proxies })
    }

    fn normalize_list_global_rules_response_compat(resp: &ListGlobalRulesResponse) -> Value {
        let mut rules: Vec<Value> = resp
            .rules
            .iter()
            .map(|rule| {
                json!({
                    "id": rule.id,
                    "name": rule.name,
                    "source_ip": rule.source_ip,
                    "action": rule.action,
                    "expires": rule.expires_at.is_some(),
                })
            })
            .collect();
        rules.sort_by_key(|rule| rule["id"].as_str().unwrap_or_default().to_string());
        json!({ "rules": rules })
    }

    fn canonical_proxy_id_compat(id: &str, ids: &CompatIds) -> String {
        if id.is_empty() {
            String::new()
        } else if id == ids.direct_proxy {
            "<direct-proxy>".to_string()
        } else if id == ids.applied_proxy {
            "<applied-proxy>".to_string()
        } else {
            "<proxy>".to_string()
        }
    }

    fn canonical_rule_id_compat(id: &str, ids: &CompatIds) -> String {
        if id.is_empty() {
            String::new()
        } else if id == ids.reload_rule {
            "<reload-rule>".to_string()
        } else if id == ids.extended_rule {
            "<extended-rule>".to_string()
        } else {
            "<rule>".to_string()
        }
    }

    fn command_name_compat(cmd_type: i32) -> &'static str {
        match cmd_type {
            command_types::ADD_RULE => "COMMAND_TYPE_ADD_RULE",
            command_types::REMOVE_RULE => "COMMAND_TYPE_REMOVE_RULE",
            command_types::GET_ACTIVE_CONNECTIONS => "COMMAND_TYPE_GET_ACTIVE_CONNECTIONS",
            command_types::CLOSE_CONNECTION => "COMMAND_TYPE_CLOSE_CONNECTION",
            command_types::CLOSE_ALL_CONNECTIONS => "COMMAND_TYPE_CLOSE_ALL_CONNECTIONS",
            command_types::STATS_CONTROL => "COMMAND_TYPE_STATS_CONTROL",
            command_types::LIST_PROXIES => "COMMAND_TYPE_LIST_PROXIES",
            command_types::LIST_RULES => "COMMAND_TYPE_LIST_RULES",
            command_types::STATUS => "COMMAND_TYPE_STATUS",
            command_types::GET_METRICS => "COMMAND_TYPE_GET_METRICS",
            command_types::APPLY_PROXY => "COMMAND_TYPE_APPLY_PROXY",
            command_types::UNAPPLY_PROXY => "COMMAND_TYPE_UNAPPLY_PROXY",
            command_types::GET_APPLIED => "COMMAND_TYPE_GET_APPLIED",
            command_types::PROXY_UPDATE => "COMMAND_TYPE_PROXY_UPDATE",
            command_types::RESOLVE_APPROVAL => "COMMAND_TYPE_RESOLVE_APPROVAL",
            command_types::CREATE_PROXY => "COMMAND_TYPE_CREATE_PROXY",
            command_types::DELETE_PROXY => "COMMAND_TYPE_DELETE_PROXY",
            command_types::ENABLE_PROXY => "COMMAND_TYPE_ENABLE_PROXY",
            command_types::DISABLE_PROXY => "COMMAND_TYPE_DISABLE_PROXY",
            command_types::UPDATE_PROXY => "COMMAND_TYPE_UPDATE_PROXY",
            command_types::RESTART_LISTENERS => "COMMAND_TYPE_RESTART_LISTENERS",
            command_types::RELOAD_RULES => "COMMAND_TYPE_RELOAD_RULES",
            command_types::BLOCK_IP => "COMMAND_TYPE_BLOCK_IP",
            command_types::ALLOW_IP => "COMMAND_TYPE_ALLOW_IP",
            command_types::LIST_GLOBAL_RULES => "COMMAND_TYPE_LIST_GLOBAL_RULES",
            command_types::REMOVE_GLOBAL_RULE => "COMMAND_TYPE_REMOVE_GLOBAL_RULE",
            command_types::CONFIGURE_GEOIP => "COMMAND_TYPE_CONFIGURE_GEOIP",
            command_types::GET_GEOIP_STATUS => "COMMAND_TYPE_GET_GEOIP_STATUS",
            command_types::LOOKUP_IP => "COMMAND_TYPE_LOOKUP_IP",
            command_types::LIST_ACTIVE_APPROVALS => "COMMAND_TYPE_LIST_ACTIVE_APPROVALS",
            command_types::CANCEL_APPROVAL => "COMMAND_TYPE_CANCEL_APPROVAL",
            _ => "COMMAND_TYPE_UNSPECIFIED",
        }
    }
}

/// Command type constants from hub_common.proto
mod command_types {
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

fn string_to_mock_preset(s: &str) -> i32 {
    match s.to_lowercase().as_str() {
        "ssh-secure" => MockPreset::SshSecure as i32,
        "ssh-tarpit" => MockPreset::SshTarpit as i32,
        "http-403" => MockPreset::Http403 as i32,
        "http-404" => MockPreset::Http404 as i32,
        "http-401" => MockPreset::Http401 as i32,
        "redis-secure" => MockPreset::RedisSecure as i32,
        "mysql-secure" => MockPreset::MysqlSecure as i32,
        "mysql-tarpit" => MockPreset::MysqlTarpit as i32,
        "rdp-secure" => MockPreset::RdpSecure as i32,
        "telnet-secure" => MockPreset::TelnetSecure as i32,
        "raw-tarpit" => MockPreset::RawTarpit as i32,
        _ => MockPreset::Unspecified as i32,
    }
}

#[derive(Debug)]
struct TemplateSecurity {
    cert_pem: String,
    key_pem: String,
    ca_pem: String,
    client_auth_type: i32,
}

fn resolve_template_entrypoint_tls(ep: &crate::config::EntryPoint) -> Result<TemplateSecurity> {
    let Some(tls) = &ep.tls else {
        return Ok(TemplateSecurity {
            cert_pem: String::new(),
            key_pem: String::new(),
            ca_pem: String::new(),
            client_auth_type: ClientAuthType::ClientAuthNone as i32,
        });
    };

    let cert_pem = read_template_tls_file(&tls.cert_file, "entrypoint TLS certificate")?;
    let key_pem = read_template_tls_file(&tls.key_file, "entrypoint TLS private key")?;
    let ca_pem = read_template_tls_file(&tls.client_ca, "entrypoint TLS client CA")?;
    let client_auth_type = match tls.client_auth.to_lowercase().as_str() {
        "none" => ClientAuthType::ClientAuthNone as i32,
        "optional" | "request" => ClientAuthType::ClientAuthRequest as i32,
        "require" | "required" | "mtls" => ClientAuthType::ClientAuthRequire as i32,
        "" | "auto" => {
            if ca_pem.is_empty() {
                ClientAuthType::ClientAuthNone as i32
            } else {
                ClientAuthType::ClientAuthRequest as i32
            }
        }
        other => anyhow::bail!("unknown template entrypoint TLS clientAuth {other:?}"),
    };

    let security = TemplateSecurity {
        cert_pem,
        key_pem,
        ca_pem,
        client_auth_type,
    };
    let tls_requested = !tls.cert_file.is_empty()
        || !tls.key_file.is_empty()
        || !tls.client_ca.is_empty()
        || !tls.client_auth.is_empty();
    validate_template_security(&security, tls_requested)?;
    Ok(security)
}

fn validate_template_security(security: &TemplateSecurity, tls_requested: bool) -> Result<()> {
    if !tls_requested
        && security.cert_pem.is_empty()
        && security.key_pem.is_empty()
        && security.ca_pem.is_empty()
        && security.client_auth_type == ClientAuthType::ClientAuthNone as i32
    {
        return Ok(());
    }
    if security.cert_pem.is_empty() || security.key_pem.is_empty() {
        anyhow::bail!("template TLS requires both certificate and private key");
    }
    if (security.client_auth_type == ClientAuthType::ClientAuthRequire as i32
        || security.client_auth_type == ClientAuthType::ClientAuthRequest as i32)
        && security.ca_pem.is_empty()
    {
        anyhow::bail!("template TLS client certificate verification requires a CA");
    }
    Ok(())
}

fn read_template_tls_file(path: &str, label: &str) -> Result<String> {
    if path.is_empty() {
        return Ok(String::new());
    }
    std::fs::read_to_string(path).map_err(|e| anyhow!("failed to read {label} {path}: {e}"))
}

fn proxy_name_prefix(proxy_id: &str) -> &str {
    proxy_id.get(..8).unwrap_or(proxy_id)
}

async fn add_yaml_default_rule(
    manager: &Arc<ProxyManager>,
    proxy_id: &str,
    action: i32,
    default_mock: i32,
    rate_limit: RateLimitConfig,
) {
    let normalized_action = if action == crate::proto::common::ActionType::Unspecified as i32 {
        crate::proto::common::ActionType::Allow as i32
    } else {
        action
    };
    let rule = Rule {
        id: uuid::Uuid::new_v4().to_string(),
        name: "__default".to_string(),
        priority: -1000,
        enabled: true,
        action: normalized_action,
        rate_limit: Some(rate_limit),
        mock_response: if normalized_action == crate::proto::common::ActionType::Mock as i32 {
            Some(crate::proto::proxy::MockConfig {
                preset: default_mock,
                ..Default::default()
            })
        } else {
            None
        },
        ..Default::default()
    };
    if let Err(e) = manager.add_rule(proxy_id, rule).await {
        warn!(
            "Failed to add YAML rate-limited default rule to proxy {}: {}",
            proxy_id, e
        );
    }
}

async fn add_yaml_middleware_rules(
    manager: &Arc<ProxyManager>,
    proxy_id: &str,
    middleware_mocks: Vec<(String, crate::config::MockConfig)>,
    router_priority: i32,
) {
    for (name, mock) in middleware_mocks {
        let rule = Rule {
            id: uuid::Uuid::new_v4().to_string(),
            name: format!("__middleware:{}", name),
            priority: router_priority,
            enabled: true,
            action: crate::proto::common::ActionType::Mock as i32,
            mock_response: Some(crate::config::mock_config_to_proto(&mock)),
            ..Default::default()
        };
        if let Err(e) = manager.add_rule(proxy_id, rule).await {
            warn!(
                "Failed to add YAML middleware rule {} to proxy {}: {}",
                name, proxy_id, e
            );
        }
    }
}

/// Derive emoji fingerprint from data (matches Go's pairing.DeriveFingerprint)
fn derive_fingerprint(data: &[u8]) -> String {
    let hash = sha2::Sha256::digest(data);

    // Must match Go's qr.go emoji list exactly
    const EMOJIS: &[&str] = &[
        "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵",
        "🐔", "🐧", "🐦", "🐤", "🦆", "🦅", "🦉", "🦇", "🐺", "🐗", "🐴", "🦄", "🐝", "🐛", "🦋",
        "🐌", "🐞", "🌸", "🌺", "🌻", "🌹", "🌷", "🌼", "🌿", "🍀", "🍎", "🍊", "🍋", "🍇", "🍓",
        "🍒", "🍑", "🥝", "🌙", "⭐", "🌟", "✨", "⚡", "🔥", "🌈", "☀️", "🎸", "🎹", "🎺", "🎷",
        "🥁", "🎻", "🎤", "🎧",
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
            return Err(anyhow!(
                "node not paired - run with --pair <code> or --pair-offline first"
            ));
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
                            warn!(
                                "[Hub] Auth probe failed (attempt {}): {}. Retrying in {:?}...",
                                attempt + 1,
                                e,
                                delay
                            );
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

            // Revocation Task
            let rev_client = client.clone();
            let rev_node = self.node_name.clone();
            tokio::spawn(Self::stream_revocations_loop(rev_client, rev_node));

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
                    p2p_data_dir,
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

                tokio::spawn(Self::push_metrics_loop(
                    m_client,
                    m_manager,
                    m_node,
                    m_vpk,
                    m_skey,
                    fingerprint.clone(),
                    m_streaming,
                ));

                // Events Task (if receiver exists)
                if let Some(event_rx) = self.event_rx.take() {
                    let e_client = client.clone();
                    let e_node = self.node_name.clone();
                    let e_vpk = v_pk.clone();
                    let e_skey = s_key.clone();
                    let e_fingerprint = fingerprint.clone();

                    tokio::spawn(Self::push_events_loop(
                        e_client,
                        event_rx,
                        e_node,
                        e_vpk,
                        e_skey,
                        e_fingerprint,
                    ));
                }

                // Logs Task (if receiver exists)
                if let Some(log_rx) = self.log_rx.take() {
                    let l_client = client.clone();
                    let l_node = self.node_name.clone();
                    let l_vpk = v_pk.clone();
                    let l_skey = s_key.clone();
                    let l_fingerprint = fingerprint;

                    tokio::spawn(Self::push_logs_loop(
                        l_client,
                        log_rx,
                        l_node,
                        l_vpk,
                        l_skey,
                        l_fingerprint,
                    ));
                }
            }
        }

        self.command_loop().await?;
        Ok(())
    }

    // ... existing methods ...

    // === Streaming & Background Tasks ===

    pub async fn push_alert(
        &mut self,
        severity: &str,
        title: &str,
        description: &str,
        metadata: HashMap<String, String>,
    ) {
        // Encrypt alert content if viewer key exists (do this BEFORE borrowing client)
        let encrypted = if let (Some(viewer_pk), Some(signing_key)) =
            (&self.viewer_pubkey, &self.signing_key)
        {
            let fingerprint = self.get_fingerprint();
            // Combine title/desc for encryption (simple JSON)
            let content = serde_json::json!({
                "title": title,
                "description": description
            })
            .to_string();

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

    async fn heartbeat_loop(
        mut client: NodeServiceClient<InterceptedService<Channel, HubInterceptor>>,
        node_name: String,
        start_time: std::time::Instant,
    ) {
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
                }
                Err(e) => error!("[Hub] Heartbeat failed: {}", e),
            }
        }
    }

    async fn stream_revocations_loop(
        mut client: NodeServiceClient<InterceptedService<Channel, HubInterceptor>>,
        node_name: String,
    ) {
        loop {
            match client
                .stream_revocations(StreamRevocationsRequest {
                    node_id: node_name.clone(),
                })
                .await
            {
                Ok(resp) => {
                    let mut stream = resp.into_inner();
                    info!("[Hub] Revocation stream established");
                    loop {
                        match stream.message().await {
                            Ok(Some(event)) => {
                                warn!(
                                    "[Hub] Certificate revocation received: serial={} fingerprint={} reason={}",
                                    event.serial_number, event.fingerprint, event.reason
                                );
                            }
                            Ok(None) => break,
                            Err(e) => {
                                warn!("[Hub] Revocation stream error: {}", e);
                                break;
                            }
                        }
                    }
                }
                Err(e) => warn!("[Hub] Failed to start revocation stream: {}", e),
            }

            time::sleep(Duration::from_secs(30)).await;
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
                }
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
        fingerprint: String,
    ) {
        loop {
            match rx.recv().await {
                Ok(event) => {
                    // Check if it is PendingApproval
                    if let Some(event::Type::Connection(conn_event)) = event.r#type {
                        if conn_event.event_type
                            == crate::proto::proxy::EventType::PendingApproval as i32
                        {
                            // Construct Alert
                            let req_id = conn_event.conn_id;
                            let proxy_id = conn_event.target_addr; // Mapped from stats.rs
                            let rule_id = conn_event.rule_matched;
                            let source_ip = conn_event.source_ip;

                            let title = "Approval Requested";
                            let description =
                                format!("Connection from {} requires approval.", source_ip);

                            let metadata = HashMap::from([
                                ("req_id".to_string(), req_id.clone()),
                                ("proxy_id".to_string(), proxy_id),
                                ("rule_id".to_string(), rule_id),
                                ("source_ip".to_string(), source_ip),
                            ]);

                            let content = serde_json::json!({
                               "title": title,
                               "description": description
                            })
                            .to_string();

                            let encrypted = match crypto::encrypt(
                                content.as_bytes(),
                                &viewer_pk,
                                &signing_key,
                                &fingerprint,
                            ) {
                                Ok(enc) => Some(enc),
                                Err(e) => {
                                    error!("[Hub] Encrypt alert failed: {}", e);
                                    None
                                }
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
                }
                Err(broadcast::error::RecvError::Lagged(_)) => {
                    warn!("[Hub] Event loop lagged, missed messages");
                }
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
        fingerprint: String,
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
            .tls_config(tls)?
            .connect_timeout(Duration::from_secs(10))
            .connect()
            .await?;

        Ok(channel)
    }

    async fn build_node_service_client(
        &self,
    ) -> Result<NodeServiceClient<InterceptedService<Channel, HubInterceptor>>> {
        let channel = self.build_channel().await?;
        let interceptor = HubInterceptor {
            user_id: self.user_id.clone(),
        };
        Ok(NodeServiceClient::with_interceptor(channel, interceptor))
    }

    async fn connect(&mut self) -> Result<()> {
        let service = match self.build_node_service_client().await {
            Ok(client) => client,
            Err(e) => {
                error!("[Hub] Connect failed details: {:?}", e);
                return Err(anyhow!("Transport error: {}", e));
            }
        };

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
            let data = fs::read(p)
                .await
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
        info!(
            "[Hub] No Hub CA found. Probing {} for TOFU...",
            self.hub_addr
        );
        let info = crate::hubca::probe_hub_ca(&self.hub_addr)
            .await
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

        // 1. Load or generate Node Key & CSR. Go reuses node.key when present.
        info!("Preparing node identity...");
        let (_key_pem, key_pair) =
            cert_utils::load_or_generate_node_key(Path::new(&self.data_dir)).await?;
        let csr_pem = cert_utils::generate_csr(key_pair, &self.node_name)?;

        // 2. Resolve Hub CA (TOFU if needed) — matches Go's ensureHubCA()
        self.verify_cached_hub_ca_for_pairing().await;
        let hub_ca_pem = self.ensure_hub_ca().await?;

        // 3. Connect to Hub for pairing (server-TLS only, NO client cert)
        // Hub uses RequestClientCert — Go connects without client cert during pairing.
        // We must NOT set .identity() here (node doesn't have a cert yet).
        let mut addr = self.hub_addr.clone();
        if !addr.starts_with("http://") && !addr.starts_with("https://") {
            addr = format!("https://{}", addr);
        }

        let tls = ClientTlsConfig::new()
            .ca_certificate(tonic::transport::Certificate::from_pem(&hub_ca_pem));

        info!("[Pairing] Connecting to Hub at {}...", addr);
        let channel = tokio::time::timeout(
            Duration::from_secs(10),
            Channel::from_shared(addr)?
                .tls_config(tls)?
                .connect_timeout(Duration::from_secs(10))
                .connect(),
        )
        .await
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
        })
        .await?;

        let request_stream = tokio_stream::wrappers::ReceiverStream::new(rx);
        let response = client.pake_exchange(request_stream).await?;
        let mut resp_stream = response.into_inner();

        info!("[Pairing] Waiting for CLI...");

        // 6. Recv CLI Init
        let cli_msg = resp_stream
            .message()
            .await?
            .ok_or(anyhow!("Stream closed"))?;
        if cli_msg.r#type == MSG_TYPE_ERROR {
            return Err(anyhow!("CLI Error: {}", cli_msg.error_message));
        }
        session.set_peer_public(&cli_msg.spake2_data)?;

        // 7. Recv CLI Reply (Confirmation)
        let cli_reply = resp_stream
            .message()
            .await?
            .ok_or(anyhow!("Stream closed"))?;
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
        println!(
            "║  Hash:        {:<46} ║",
            &csr_hash_str[..std::cmp::min(46, csr_hash_str.len())]
        );
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
        })
        .await?;

        info!("[Pairing] CSR sent, waiting for signed certificate...");

        // 9. Recv Encrypted Cert
        let cert_msg = resp_stream
            .message()
            .await?
            .ok_or(anyhow!("Stream closed"))?;
        if cert_msg.r#type == MSG_TYPE_ERROR {
            return Err(anyhow!("CLI rejected pairing: {}", cert_msg.error_message));
        }
        let cert_pem_bytes = session.decrypt(&cert_msg.encrypted_payload, &cert_msg.nonce)?;
        cert_utils::write_cert_pem(
            &Path::new(&self.data_dir).join("node.crt"),
            &cert_pem_bytes,
            0o600,
        )
        .await?;

        // 10. Recv Encrypted CA
        let ca_msg = resp_stream
            .message()
            .await?
            .ok_or(anyhow!("Stream closed"))?;
        let ca_pem_bytes = session.decrypt(&ca_msg.encrypted_payload, &ca_msg.nonce)?;
        cert_utils::write_cert_pem(
            &Path::new(&self.data_dir).join("cli_ca.crt"),
            &ca_pem_bytes,
            0o644,
        )
        .await?;

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

    async fn verify_cached_hub_ca_for_pairing(&self) {
        let cached_path = Path::new(&self.data_dir).join("hub_ca.crt");
        let Ok(cached_data) = fs::read(&cached_path).await else {
            return;
        };

        info!(
            "[Pairing] Verifying cached Hub CA against {}...",
            self.hub_addr
        );
        match crate::hubca::probe_hub_ca(&self.hub_addr).await {
            Ok(info) => {
                let cached = String::from_utf8_lossy(&cached_data).trim().to_string();
                let probed = String::from_utf8_lossy(&info.ca_pem).trim().to_string();
                if cached != probed {
                    warn!("[Pairing] CA MISMATCH: Hub identity has changed");
                    if let Err(e) = fs::remove_file(&cached_path).await {
                        warn!("[Pairing] Failed to remove outdated cached CA: {}", e);
                    }
                } else {
                    info!("[Pairing] Cached CA is valid (matches live Hub)");
                }
            }
            Err(e) => warn!("[Pairing] Warning: Could not probe Hub CA: {}", e),
        }
    }

    async fn load_private_key(&self) -> Result<SigningKey> {
        let key_path = Path::new(&self.data_dir).join("node.key");
        let key_pem = fs::read_to_string(&key_path).await?;
        let key = SigningKey::from_pkcs8_pem(&key_pem)
            .map_err(|e| anyhow!("Failed to parse private key: {}", e))?;
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
                if let Ok((_, cert)) =
                    x509_parser::prelude::X509Certificate::from_der(pem_data.contents())
                {
                    let key_data = cert
                        .tbs_certificate
                        .subject_pki
                        .subject_public_key
                        .data
                        .as_ref();
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
            let Some(ca_pk) = &ca_pubkey else {
                error!("[SECURITY CRITICAL] Cannot verify command signature: CA key missing");
                continue;
            };
            if let Err(e) = crypto::verify_signature(enc, ca_pk) {
                error!("[SECURITY] Command signature verification failed: {}", e);
                continue;
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
            if self.replay_cache.contains_key(&secure.request_id) {
                error!("[SECURITY] Replay detected! Request ID {} already processed",
                    secure.request_id);
                continue;
            }
            self.replay_cache.insert(secure.request_id.clone(), now);

            // Unmarshal EncryptedCommandPayload
            let payload = match EncryptedCommandPayload::decode(secure.data.as_slice()) {
                Ok(p) => p,
                Err(e) => {
                    error!("[Hub] Failed to decode EncryptedCommandPayload: {}", e);
                    continue;
                }
            };

            info!("[Hub] Decrypted command type: {}", payload.r#type);

            let Some(viewer_pk) = &viewer_pubkey else {
                error!("[SECURITY CRITICAL] Cannot execute command: viewer public key not set (encrypted response impossible)");
                continue;
            };

            // Extend metrics streaming window when stats are requested (matches Go's EnableStatsStreaming)
            if payload.r#type == command_types::STATUS
                || payload.r#type == command_types::GET_METRICS
            {
                let mut until = self.stats_streaming_until.write().await;
                *until = tokio::time::Instant::now() + Duration::from_secs(30);
            }

            let result = self.dispatch_command(payload.r#type, payload.payload).await;

            // Build and send encrypted response
            let result_bytes = result.encode_to_vec();
            let encrypted_data = match crypto::encrypt(&result_bytes, viewer_pk, &signing_key, &fingerprint) {
                Ok(enc) => Some(enc),
                Err(e) => {
                    warn!("[Hub] Failed to encrypt response: {}", e);
                    None
                }
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
            command_types::STATUS => self.handle_status().await,
            command_types::GET_METRICS => self.handle_metrics().await,
            command_types::STATS_CONTROL => (
                "ERROR".to_string(),
                "unknown command: COMMAND_TYPE_STATS_CONTROL".to_string(),
                vec![],
            ),
            command_types::LIST_PROXIES => self.handle_list_proxies().await,
            command_types::LIST_RULES => self.handle_list_rules(payload).await,
            command_types::ADD_RULE => self.handle_add_rule(payload).await,
            command_types::REMOVE_RULE => self.handle_remove_rule(payload).await,
            command_types::GET_ACTIVE_CONNECTIONS => self.handle_get_connections(payload).await,
            command_types::CLOSE_CONNECTION => self.handle_close_connection(payload).await,
            command_types::CLOSE_ALL_CONNECTIONS => {
                self.handle_close_all_connections(payload).await
            }
            command_types::CREATE_PROXY => self.handle_create_proxy(payload).await,
            command_types::APPLY_PROXY => self.handle_apply_proxy(payload).await,
            command_types::DELETE_PROXY => self.handle_delete_proxy(payload).await,
            command_types::UNAPPLY_PROXY => self.handle_unapply_proxy(payload).await,
            command_types::ENABLE_PROXY => self.handle_enable_proxy(payload).await,
            command_types::DISABLE_PROXY => self.handle_disable_proxy(payload).await,
            command_types::UPDATE_PROXY => self.handle_update_proxy(payload).await,
            command_types::PROXY_UPDATE => self.handle_proxy_update(payload).await,
            command_types::RESTART_LISTENERS => self.handle_restart_listeners().await,
            command_types::RELOAD_RULES => self.handle_reload_rules(payload).await,
            command_types::RESOLVE_APPROVAL => self.handle_resolve_approval(payload).await,
            command_types::BLOCK_IP => self.handle_block_ip(payload).await,
            command_types::ALLOW_IP => self.handle_allow_ip(payload).await,
            command_types::LIST_GLOBAL_RULES => self.handle_list_global_rules().await,
            command_types::REMOVE_GLOBAL_RULE => self.handle_remove_global_rule(payload).await,
            command_types::GET_APPLIED => self.handle_get_applied().await,
            command_types::LIST_ACTIVE_APPROVALS => {
                self.handle_list_active_approvals(payload).await
            }
            command_types::CANCEL_APPROVAL => self.handle_cancel_approval(payload).await,
            command_types::CONFIGURE_GEOIP => self.handle_configure_geoip(payload).await,
            command_types::GET_GEOIP_STATUS => self.handle_get_geoip_status().await,
            command_types::LOOKUP_IP => self.handle_lookup_ip(payload).await,
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
        let mut bytes_in: i64 = 0;
        let mut bytes_out: i64 = 0;

        for s in &statuses {
            total_conns += s.total_connections;
            bytes_in += s.bytes_in;
            bytes_out += s.bytes_out;
        }

        let resp = StatsSummaryResponse {
            total_connections: total_conns,
            total_bytes_in: bytes_in,
            total_bytes_out: bytes_out,
            ..Default::default()
        };

        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
    }

    async fn handle_metrics(&self) -> (String, String, Vec<u8>) {
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
            timestamp: Some(prost_types::Timestamp::from(std::time::SystemTime::now())),
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
                if let Some(rule) = req.rule {
                    match self.manager.add_rule(&req.proxy_id, rule.clone()).await {
                        Ok(created) => {
                            info!(
                                "[Hub] Added rule {} ({}) to proxy {}",
                                created.name, created.id, req.proxy_id
                            );
                            ("OK".to_string(), "".to_string(), created.encode_to_vec())
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
                        "[Hub] Removed rule {} from proxy {}",
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

    async fn handle_get_connections(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match GetActiveConnectionsRequest::decode(payload.as_slice()) {
            Ok(req) => {
                let pid = if req.proxy_id.is_empty() {
                    None
                } else {
                    Some(req.proxy_id)
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
                if req.conn_id.is_empty() {
                    return (
                        "ERROR".to_string(),
                        "conn_id is required".to_string(),
                        vec![],
                    );
                }
                info!(
                    "[Hub] Close connection request: {} on {}",
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

    /// Handle APPLY_PROXY command - tries ApplyProxyRequest (YAML template) first,
    /// then falls back to CreateProxyRequest (legacy).
    async fn handle_apply_proxy(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        // Try proto-based ApplyProxyRequest with embedded YAML config
        if let Ok(req) = ApplyProxyRequest::decode(payload.as_slice()) {
            if looks_like_apply_proxy_template(&req) {
                info!(
                    "[Hub] ApplyProxy (template): proxy_id={}, revision={}",
                    req.proxy_id, req.revision_num
                );
                return self.apply_proxy_template(&req).await;
            }
        }
        // Fall back to legacy CreateProxyRequest
        self.handle_apply_proxy_legacy(payload).await
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
                let resolved = yaml_config.resolve_entry_point(name, ep);
                let security = match resolve_template_entrypoint_tls(ep) {
                    Ok(security) => security,
                    Err(e) => {
                        let msg = format!("Invalid TLS for entryPoint {}: {}", name, e);
                        error!("[Hub] {}", msg);
                        last_error = Some(msg);
                        continue;
                    }
                };
                let rate_limit = match crate::config::rate_limit_to_proto(&ep.rate_limit) {
                    Ok(rate_limit) => rate_limit,
                    Err(e) => {
                        let msg = format!("Invalid rateLimit for entryPoint {}: {}", name, e);
                        error!("[Hub] {}", msg);
                        last_error = Some(msg);
                        continue;
                    }
                };

                // Map action type
                let action_type = match ep.default_action.to_lowercase().as_str() {
                    "block" => crate::proto::common::ActionType::Block as i32,
                    "mock" => crate::proto::common::ActionType::Mock as i32,
                    "approval" | "require_approval" | "require-approval" => {
                        crate::proto::common::ActionType::RequireApproval as i32
                    }
                    _ => crate::proto::common::ActionType::Allow as i32,
                };

                let create_req = CreateProxyRequest {
                    name: format!("{}-{}", proxy_name_prefix(proxy_id), name),
                    listen_addr: ep.address.clone(),
                    default_backend: resolved.default_backend.clone(),
                    default_action: action_type,
                    default_mock: string_to_mock_preset(&ep.default_mock),
                    fallback_action: match ep.fallback_action.to_lowercase().as_str() {
                        "mock" => crate::proto::common::FallbackAction::Mock as i32,
                        "close" => crate::proto::common::FallbackAction::Close as i32,
                        _ => crate::proto::common::FallbackAction::Unspecified as i32,
                    },
                    fallback_mock: string_to_mock_preset(&ep.fallback_mock),
                    cert_pem: security.cert_pem,
                    key_pem: security.key_pem,
                    ca_pem: security.ca_pem,
                    client_auth_type: security.client_auth_type,
                    health_check: resolved
                        .health_check
                        .as_ref()
                        .map(crate::config::health_check_to_proto),
                    ..Default::default()
                };

                match self.manager.create_proxy(create_req).await {
                    Ok(lid) => {
                        info!(
                            "[Hub] ApplyProxy: Created listener {} for {}/{}",
                            lid, proxy_id, name
                        );
                        if let Some(rate_limit) = rate_limit {
                            add_yaml_default_rule(
                                &self.manager,
                                &lid,
                                action_type,
                                string_to_mock_preset(&ep.default_mock),
                                rate_limit,
                            )
                            .await;
                        }
                        add_yaml_middleware_rules(
                            &self.manager,
                            &lid,
                            resolved.middleware_mocks,
                            resolved.router_priority,
                        )
                        .await;
                        new_listener_ids.push(lid);
                    }
                    Err(e) => {
                        error!(
                            "[Hub] ApplyProxy: Failed to create listener for {}/{}: {}",
                            proxy_id, name, e
                        );
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
                match self.manager.create_proxy(req).await {
                    Ok(id) => {
                        let resp = CreateProxyResponse {
                            success: true,
                            error_message: String::new(),
                            proxy_id: id,
                        };
                        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                    }
                    Err(e) => {
                        let resp = CreateProxyResponse {
                            success: false,
                            error_message: e.to_string(),
                            proxy_id: String::new(),
                        };
                        ("OK".to_string(), String::new(), resp.encode_to_vec())
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

    async fn handle_apply_proxy_legacy(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match CreateProxyRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!(
                    "[Hub] Applying legacy proxy: {} on {}",
                    req.name, req.listen_addr
                );
                match self.manager.create_proxy(req.clone()).await {
                    Ok(id) => {
                        let applied = AppliedProxy {
                            proxy_id: id.clone(),
                            revision_num: 0,
                            config_hash: String::new(),
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
                        ("OK".to_string(), String::new(), status.encode_to_vec())
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

    async fn handle_delete_proxy(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match DeleteProxyRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("[Hub] Deleting proxy: {}", req.proxy_id);
                // Match Go's lifecycle DELETE_PROXY behavior: disable the proxy
                // but keep its model so it can be enabled again.
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
                        ("OK".to_string(), String::new(), resp.encode_to_vec())
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

    async fn handle_unapply_proxy(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match DeleteProxyRequest::decode(payload.as_slice()) {
            Ok(req) => {
                if req.proxy_id.is_empty() {
                    let resp = DeleteProxyResponse {
                        success: false,
                        error_message: "proxy_id is required".to_string(),
                    };
                    return (
                        "ERROR".to_string(),
                        "proxy_id is required".to_string(),
                        resp.encode_to_vec(),
                    );
                }

                let applied = {
                    let lock = self.applied_proxies.read().await;
                    lock.get(&req.proxy_id).cloned()
                };

                let Some(applied) = applied else {
                    let resp = DeleteProxyResponse {
                        success: false,
                        error_message: "proxy not applied".to_string(),
                    };
                    return ("OK".to_string(), String::new(), resp.encode_to_vec());
                };

                for listener_id in &applied.listener_ids {
                    if let Err(e) = self.manager.delete_proxy(listener_id).await {
                        warn!(
                            "[Hub] Failed to remove unapplied listener {}: {}",
                            listener_id, e
                        );
                    }
                }
                {
                    let mut lock = self.applied_proxies.write().await;
                    lock.remove(&req.proxy_id);
                }
                self.save_applied_proxies().await;

                let resp = DeleteProxyResponse {
                    success: true,
                    error_message: String::new(),
                };
                ("OK".to_string(), String::new(), resp.encode_to_vec())
            }
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
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
                    }
                    Err(e) => {
                        let resp = EnableProxyResponse {
                            success: false,
                            error_message: e.to_string(),
                        };
                        ("OK".to_string(), String::new(), resp.encode_to_vec())
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
                    }
                    Err(e) => {
                        let resp = DisableProxyResponse {
                            success: false,
                            error_message: e.to_string(),
                        };
                        ("OK".to_string(), String::new(), resp.encode_to_vec())
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
                    }
                    Err(e) => {
                        let resp = UpdateProxyResponse {
                            success: false,
                            error_message: e.to_string(),
                        };
                        ("OK".to_string(), String::new(), resp.encode_to_vec())
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

    async fn handle_proxy_update(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match UpdateProxyRequest::decode(payload.as_slice()) {
            Ok(req) => {
                if req.proxy_id.is_empty() {
                    return (
                        "ERROR".to_string(),
                        "proxy_id is required".to_string(),
                        vec![],
                    );
                }

                info!("[Hub] Proxy update notification: {}", req.proxy_id);
                let exists = {
                    let lock = self.applied_proxies.read().await;
                    lock.contains_key(&req.proxy_id)
                };
                let resp = if exists {
                    UpdateProxyResponse {
                        success: true,
                        error_message: String::new(),
                    }
                } else {
                    UpdateProxyResponse {
                        success: false,
                        error_message: "proxy not applied on this node".to_string(),
                    }
                };
                ("OK".to_string(), String::new(), resp.encode_to_vec())
            }
            Err(e) => (
                "ERROR".to_string(),
                format!("Invalid request: {}", e),
                vec![],
            ),
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
                    if let Ok(count) = self
                        .manager
                        .reload_rules(&s.proxy_id, req.rules.clone())
                        .await
                    {
                        total += count;
                    }
                }
                let resp = ReloadRulesResponse {
                    success: true,
                    rules_loaded: total,
                    ..Default::default()
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

    async fn handle_resolve_approval(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        use crate::proto::proxy::ResolveApprovalRequest;
        match ResolveApprovalRequest::decode(payload.as_slice()) {
            Ok(req) => {
                // action: 1 = ALLOW, 2 = BLOCK
                let allowed = req.action == 1;
                info!(
                    "[Hub] Resolving approval {}: allowed={}, mode={}, duration={}",
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
                        error_message: String::new(),
                        resolved_target_backend: target_backend_override.clone(),
                    };
                    ("OK".to_string(), "".to_string(), resp.encode_to_vec())
                } else {
                    (
                        "ERROR".to_string(),
                        "Approval not found".to_string(),
                        vec![],
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

    async fn handle_block_ip(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match BlockIpRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("[Hub] Block IP: {} for {}s", req.ip, req.duration_seconds);
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
                info!("[Hub] Allow IP: {} for {}s", req.ip, req.duration_seconds);
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

    async fn handle_get_applied(&self) -> (String, String, Vec<u8>) {
        let lock = self.applied_proxies.read().await;
        let statuses: Vec<AppliedProxyStatus> = lock
            .values()
            .map(|ap| AppliedProxyStatus {
                proxy_id: ap.proxy_id.clone(),
                revision_num: ap.revision_num,
                applied_at: chrono::DateTime::from_timestamp(ap.applied_at, 0)
                    .map(|dt| dt.to_rfc3339())
                    .unwrap_or_default(),
                status: ap.status.clone(),
                error_message: ap.error_msg.clone().unwrap_or_default(),
            })
            .collect();

        let resp = GetAppliedProxiesResponse { proxies: statuses };
        ("OK".to_string(), "".to_string(), resp.encode_to_vec())
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
        info!("[Hub] List active approvals: {} entries", entries.len());

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
                info!("[Hub] Cancel approval: {}", req.key);
                if req.key.split('\0').count() < 2 {
                    let resp = CancelApprovalResponse {
                        success: false,
                        error_message: "Invalid approval key format".to_string(),
                        connections_closed: 0,
                    };
                    return ("OK".to_string(), "".to_string(), resp.encode_to_vec());
                }
                let (success, connections_closed) = self
                    .manager
                    .cancel_approval_with_close(&req.key, req.close_connections)
                    .await;
                let resp = CancelApprovalResponse {
                    success,
                    error_message: if success {
                        String::new()
                    } else {
                        "Approval not found".to_string()
                    },
                    connections_closed,
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

    async fn handle_lookup_ip(&self, payload: Vec<u8>) -> (String, String, Vec<u8>) {
        match LookupIpRequest::decode(payload.as_slice()) {
            Ok(req) => {
                info!("[Hub] Lookup IP: {}", req.ip);
                let start = std::time::Instant::now();
                let info = self.manager.lookup_ip(&req.ip).await;
                let elapsed = start.elapsed().as_millis() as i64;
                use crate::proto::proxy::LookupIpResponse;
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
        use crate::proto::proxy::{ConfigureGeoIpRequest, ConfigureGeoIpResponse};

        match ConfigureGeoIpRequest::decode(payload.as_slice()) {
            Ok(req) => {
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

    async fn handle_get_geoip_status(&self) -> (String, String, Vec<u8>) {
        use crate::proto::proxy::GetGeoIpStatusResponse;
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

fn looks_like_apply_proxy_template(req: &ApplyProxyRequest) -> bool {
    let yaml = req.config_yaml.trim();
    !yaml.is_empty()
        && (yaml.contains("entryPoints")
            || yaml.contains("entry_points")
            || yaml.contains("tcp:")
            || yaml.contains("http:"))
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
        let (tx, rx) = mpsc::channel::<SignalMessage>(10);
        let outbound = ReceiverStream::new(rx);
        let peers = Arc::new(RwLock::new(HashMap::new()));

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
                            let peers = peers.clone();

                            tokio::spawn(async move {
                                if let Err(e) = Self::handle_p2p_signal(
                                    signal, tx_clone, mgr, stun, applied, ddir, node, peers,
                                )
                                .await
                                {
                                    error!("[Hub] P2P Signal handler error: {}", e);
                                }
                            });
                        }
                        Err(e) => {
                            error!("[Hub] P2P Stream error: {}", e);
                            break;
                        }
                    }
                }
            }
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
        peers: Arc<RwLock<HashMap<String, Arc<webrtc::peer_connection::RTCPeerConnection>>>>,
    ) -> Result<()> {
        if signal.r#type == "candidate" {
            let candidate: RTCIceCandidateInit = serde_json::from_str(&signal.payload)?;
            if let Some(pc) = peers.read().await.get(&signal.source_id).cloned() {
                pc.add_ice_candidate(candidate).await?;
            }
            return Ok(());
        }

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
            peers
                .write()
                .await
                .insert(signal.source_id.clone(), pc.clone());

            let tx_ice = tx.clone();
            let ice_target = signal.source_id.clone();
            let ice_source = node_name.clone();
            pc.on_ice_candidate(Box::new(move |candidate| {
                let tx = tx_ice.clone();
                let target = ice_target.clone();
                let source = ice_source.clone();
                Box::pin(async move {
                    let Some(candidate) = candidate else {
                        return;
                    };
                    let Ok(init) = candidate.to_json() else {
                        return;
                    };
                    let Ok(payload) = serde_json::to_string(&init) else {
                        return;
                    };
                    let _ = tx
                        .send(SignalMessage {
                            target_id: target,
                            source_id: source,
                            r#type: "candidate".to_string(),
                            payload,
                            source_user_id: "".to_string(),
                        })
                        .await;
                })
            }));

            let signing_key = load_p2p_signing_key(&data_dir).await?;
            let node_cert_pem = fs::read_to_string(Path::new(&data_dir).join("node.crt"))
                .await
                .unwrap_or_default();
            let node_fingerprint =
                hex::encode(sha2::Sha256::digest(signing_key.verifying_key().as_bytes()));

            let mgr = manager.clone();
            let applied = applied_proxies.clone();
            let ddir = data_dir.clone();
            let auth_node = node_name.clone();
            pc.on_data_channel(Box::new(
                move |dc: Arc<webrtc::data_channel::RTCDataChannel>| {
                    let dc_label = dc.label().to_string();
                    let mgr = mgr.clone();
                    let applied = applied.clone();
                    let ddir = ddir.clone();
                    let dc2 = dc.clone();
                    let signing_key = signing_key.clone();
                    let node_cert_pem = node_cert_pem.clone();
                    let node_fingerprint = node_fingerprint.clone();
                    let auth_node = auth_node.clone();
                    let peer_pubkey = Arc::new(RwLock::new(None));

                    Box::pin(async move {
                        debug!("[Hub] P2P DataChannel opened: {}", dc_label);
                        let dc3 = dc2.clone(); // For sending
                        dc2.on_message(Box::new(move |msg: DataChannelMessage| {
                            let mgr = mgr.clone();
                            let applied = applied.clone();
                            let ddir = ddir.clone();
                            let dc_send = dc3.clone();
                            let data = msg.data.to_vec();
                            let signing_key = signing_key.clone();
                            let node_cert_pem = node_cert_pem.clone();
                            let node_fingerprint = node_fingerprint.clone();
                            let auth_node = auth_node.clone();
                            let peer_pubkey = peer_pubkey.clone();

                            Box::pin(async move {
                                if let Err(e) = Self::handle_p2p_data_message(
                                    data,
                                    dc_send,
                                    mgr,
                                    applied,
                                    ddir,
                                    signing_key,
                                    node_cert_pem,
                                    auth_node,
                                    node_fingerprint,
                                    peer_pubkey,
                                )
                                .await
                                {
                                    warn!("[Hub] Failed to handle P2P data message: {}", e);
                                }
                            })
                        }));
                    })
                },
            ));

            let desc = RTCSessionDescription::offer(sdp_from_signal_payload(&signal.payload))?;
            pc.set_remote_description(desc).await?;

            let answer = pc.create_answer(None).await?;
            let answer_gather = answer.clone();
            pc.set_local_description(answer).await?;

            let payload = serde_json::json!({
                "type": "answer",
                "sdp": answer_gather.sdp,
            })
            .to_string();
            tx.send(SignalMessage {
                target_id: signal.source_id,
                source_id: node_name.clone(),
                r#type: "answer".to_string(),
                payload,
                source_user_id: "".to_string(),
            })
            .await?;

            let pc_clone = pc.clone();
            tokio::spawn(async move {
                let mut done = false;
                while !done {
                    tokio::time::sleep(Duration::from_secs(5)).await;
                    if pc_clone.connection_state() == RTCPeerConnectionState::Closed
                        || pc_clone.connection_state() == RTCPeerConnectionState::Failed
                    {
                        done = true;
                    }
                }
            });
        }
        Ok(())
    }

    async fn handle_p2p_data_message(
        data: Vec<u8>,
        dc_send: Arc<webrtc::data_channel::RTCDataChannel>,
        manager: Arc<ProxyManager>,
        applied_proxies: Arc<RwLock<HashMap<String, AppliedProxy>>>,
        data_dir: String,
        signing_key: SigningKey,
        node_cert_pem: String,
        node_name: String,
        node_fingerprint: String,
        peer_pubkey: Arc<RwLock<Option<VerifyingKey>>>,
    ) -> Result<()> {
        if let Some(auth) = parse_p2p_auth_message(&data) {
            match auth.message_type.as_str() {
                "auth_challenge" => {
                    let peer_key = verifying_key_from_slice(&auth.public_key)?;
                    *peer_pubkey.write().await = Some(peer_key);
                    let signature = signing_key.sign(&auth.challenge);
                    let response = serde_json::json!({
                        "type": "auth_response",
                        "user_id": node_name,
                        "public_key": general_purpose::STANDARD.encode(signing_key.verifying_key().as_bytes()),
                        "cert_pem": node_cert_pem,
                        "signature": general_purpose::STANDARD.encode(signature.to_bytes()),
                        "challenge": general_purpose::STANDARD.encode(auth.challenge),
                    });
                    dc_send
                        .send(&bytes::Bytes::from(response.to_string()))
                        .await?;
                    return Ok(());
                }
                "auth_success" => return Ok(()),
                "auth_failed" => anyhow::bail!("P2P auth failed"),
                _ => return Ok(()),
            }
        }

        let peer_key = peer_pubkey
            .read()
            .await
            .clone()
            .ok_or_else(|| anyhow!("P2P peer is not authenticated"))?;

        let (request_id, cmd_type, payload) = decrypt_p2p_command_message(&data, &signing_key)?;
        let result = Self::dispatch_secure_or_inner_command(
            cmd_type,
            payload,
            &manager,
            &applied_proxies,
            &data_dir,
        )
        .await;

        let response = encrypt_p2p_command_response(
            &request_id,
            &result,
            &peer_key,
            &signing_key,
            &node_fingerprint,
        )?;
        dc_send.send(&bytes::Bytes::from(response)).await?;
        Ok(())
    }

    async fn dispatch_secure_or_inner_command(
        fallback_cmd_type: i32,
        payload: Vec<u8>,
        manager: &Arc<ProxyManager>,
        applied_proxies: &Arc<RwLock<HashMap<String, AppliedProxy>>>,
        data_dir: &str,
    ) -> CommandResult {
        // Safe to accept the compact inner envelopes here: callers already
        // required an authenticated P2P peer and decrypted the outer wrapper.
        if let Ok(secure) = SecureCommandPayload::decode(payload.as_slice()) {
            if let Ok(inner) = EncryptedCommandPayload::decode(secure.data.as_slice()) {
                return Self::static_dispatch(
                    inner.r#type,
                    inner.payload,
                    manager,
                    applied_proxies,
                    data_dir,
                )
                .await;
            }
        }
        if let Ok(inner) = EncryptedCommandPayload::decode(payload.as_slice()) {
            return Self::static_dispatch(
                inner.r#type,
                inner.payload,
                manager,
                applied_proxies,
                data_dir,
            )
            .await;
        }
        Self::static_dispatch(
            fallback_cmd_type,
            payload,
            manager,
            applied_proxies,
            data_dir,
        )
        .await
    }

    async fn static_dispatch(
        cmd_type: i32,
        payload: Vec<u8>,
        manager: &Arc<ProxyManager>,
        applied_proxies: &Arc<RwLock<HashMap<String, AppliedProxy>>>,
        data_dir: &str,
    ) -> CommandResult {
        let mut dispatcher = Self::new(
            "p2p".to_string(),
            data_dir.to_string(),
            "p2p".to_string(),
            manager.clone(),
            None,
            None,
            None,
        );
        dispatcher.applied_proxies = applied_proxies.clone();
        dispatcher.dispatch_command(cmd_type, payload).await
    }
}
