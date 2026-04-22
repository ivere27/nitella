use crate::proto::common::P2pMode;
use crate::proto::hub::Empty;
use crate::proto::local::{
    BootstrapStage, BootstrapStateResponse, FetchHubCaRequest, FetchHubCaResponse, GetNodeRequest,
    HubStatus, IdentityInfo, InitializeRequest, InitializeResponse, ListNodesRequest,
    ListNodesResponse, NodeConnectionType, NodeInfo, P2pStatus, Settings, Theme,
    UpdateSettingsRequest,
};
use anyhow::{anyhow, Context, Result};
use base64::{engine::general_purpose, Engine as _};
use prost::Message;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::collections::HashMap;
use std::fs;
use std::path::{Path, PathBuf};
use std::sync::Mutex;
use x509_parser::pem::parse_x509_pem;
use x509_parser::prelude::*;

const IDENTITY_EMOJIS: &[&str] = &[
    "🐶",
    "🐱",
    "🐭",
    "🐹",
    "🐰",
    "🦊",
    "🐻",
    "🐼",
    "🐨",
    "🐯",
    "🦁",
    "🐮",
    "🐷",
    "🐸",
    "🐵",
    "🐔",
    "🐧",
    "🐦",
    "🐤",
    "🦆",
    "🦅",
    "🦉",
    "🦇",
    "🐺",
    "🐗",
    "🐴",
    "🦄",
    "🐝",
    "🐛",
    "🦋",
    "🐌",
    "🐞",
    "🐜",
    "🦟",
    "🦗",
    "🕷️",
    "🦂",
    "🐢",
    "🐍",
    "🦎",
    "🦖",
    "🦕",
    "🐙",
    "🦑",
    "🦐",
    "🦞",
    "🦀",
    "🐡",
    "🐠",
    "🐟",
    "🐬",
    "🐳",
    "🐋",
    "🦈",
    "🐊",
    "🐅",
    "🐆",
    "🦓",
    "🦍",
    "🦧",
    "🐘",
    "🦛",
    "🦏",
    "🐪",
    "🐫",
    "🦒",
    "🦘",
    "🐃",
    "🐂",
    "🐄",
    "🐎",
    "🐖",
    "🐏",
    "🐑",
    "🦙",
    "🐐",
    "🦌",
    "🐕",
    "🐩",
    "🦮",
    "🐕‍🦺",
    "🐈",
    "🐓",
    "🦃",
    "🦚",
    "🦜",
    "🦢",
    "🦩",
    "🕊️",
    "🐇",
    "🦝",
    "🦨",
    "🦡",
    "🦫",
    "🦦",
    "🦥",
    "🐁",
    "🐀",
    "🐿️",
    "🦔",
    "🌵",
    "🎄",
    "🌲",
    "🌳",
    "🌴",
    "🌱",
    "🌿",
    "☘️",
    "🍀",
    "🎍",
    "🎋",
    "🍃",
    "🍂",
    "🍁",
    "🍄",
    "🌾",
    "💐",
    "🌷",
    "🌹",
    "🥀",
    "🌺",
    "🌸",
    "🌼",
    "🌻",
    "🌞",
    "🌝",
    "🌛",
    "🌜",
    "🌚",
    "🌕",
    "🌖",
    "🌗",
    "🌘",
    "🌑",
    "🌒",
    "🌓",
    "🌔",
    "🌙",
    "🌎",
    "🌍",
    "🌏",
    "🪐",
    "💫",
    "⭐",
    "🌟",
    "✨",
    "⚡",
    "☄️",
    "💥",
    "🔥",
    "🌪️",
    "🌈",
    "☀️",
    "🌤️",
    "⛅",
    "🌥️",
    "☁️",
    "🌦️",
    "🌧️",
    "⛈️",
    "🌩️",
    "🌨️",
    "❄️",
    "☃️",
    "⛄",
    "🌬️",
    "💨",
    "💧",
    "💦",
    "☔",
    "☂️",
    "🌊",
    "🍏",
    "🍎",
    "🍐",
    "🍊",
    "🍋",
    "🍌",
    "🍉",
    "🍇",
    "🍓",
    "🫐",
    "🍈",
    "🍒",
    "🍑",
    "🥭",
    "🍍",
    "🥥",
    "🥝",
    "🍅",
    "🍆",
    "🥑",
    "🥦",
    "🥬",
    "🥒",
    "🌶️",
    "🫑",
    "🌽",
    "🥕",
    "🫒",
    "🧄",
    "🧅",
    "🥔",
    "🍠",
    "🥐",
    "🥯",
    "🍞",
    "🥖",
    "🥨",
    "🧀",
    "🥚",
    "🍳",
    "🧈",
    "🥞",
    "🧇",
    "🥓",
    "🥩",
    "🍗",
    "🍖",
    "🦴",
    "🌭",
    "🍔",
    "🍟",
    "🍕",
    "🫓",
    "🥪",
    "🥙",
    "🧆",
    "🌮",
    "🌯",
    "🫔",
    "🥗",
    "🥘",
    "🫕",
    "🥫",
    "🍝",
    "🍜",
    "🍲",
    "🍛",
    "🍣",
    "🍱",
    "🥟",
    "🦪",
    "🍤",
    "🍙",
    "🍚",
    "🍘",
    "🍥",
    "🥠",
    "🥮",
    "🍢",
    "🍡",
    "🍧",
    "🍨",
    "🍦",
    "🥧",
];

#[derive(Clone, Debug)]
struct MobileState {
    data_dir: PathBuf,
    cache_dir: PathBuf,
    debug_mode: bool,
    hub_addr: String,
    identity: IdentitySnapshot,
    settings: Settings,
    nodes: HashMap<String, NodeInfo>,
}

#[derive(Clone, Debug, Default)]
struct IdentitySnapshot {
    exists: bool,
    locked: bool,
    fingerprint: String,
    emoji_hash: String,
    root_cert_pem: String,
    created_at: Option<prost_types::Timestamp>,
}

#[derive(Debug, Default, Deserialize, Serialize)]
struct SettingsJson {
    hub_address: Option<String>,
    auto_connect_hub: Option<bool>,
    notifications_enabled: Option<bool>,
    approval_notifications: Option<bool>,
    connection_notifications: Option<bool>,
    alert_notifications: Option<bool>,
    p2p_mode: Option<i32>,
    require_biometric: Option<bool>,
    auto_lock_minutes: Option<i32>,
    theme: Option<serde_json::Value>,
    language: Option<String>,
    hub_ca_pem: Option<String>,
    hub_cert_pin: Option<String>,
    stun_servers: Option<Vec<String>>,
    turn_server: Option<String>,
    turn_username: Option<String>,
    turn_password: Option<String>,
    hub_invite_code: Option<String>,
}

#[derive(Debug, Default, Deserialize)]
struct NodeMetadata {
    name: Option<String>,
    tags: Option<Vec<String>>,
    pinned: Option<bool>,
    alerts_enabled: Option<bool>,
}

pub struct MobileLogicService {
    state: Mutex<MobileState>,
}

impl MobileLogicService {
    pub fn new(storage_path: String) -> Self {
        let data_dir = if storage_path.trim().is_empty() {
            PathBuf::from(".")
        } else {
            PathBuf::from(storage_path)
        };
        let cache_dir = data_dir.join("cache");
        Self {
            state: Mutex::new(MobileState {
                data_dir,
                cache_dir,
                debug_mode: false,
                hub_addr: String::new(),
                identity: IdentitySnapshot::default(),
                settings: default_settings(),
                nodes: HashMap::new(),
            }),
        }
    }

    pub async fn initialize(&self) -> Result<(), String> {
        self.reload_state(None)
            .map(|_| ())
            .map_err(|e| e.to_string())
    }

    pub async fn invoke(&self, method: &str, data: Vec<u8>) -> Result<Vec<u8>, String> {
        match method {
            "/nitella.local.MobileLogicService/Initialize" => self.handle_initialize(&data),
            "/nitella.local.MobileLogicService/Shutdown" => Ok(encode_message(&Empty {})),
            "/nitella.local.MobileLogicService/GetBootstrapState" => {
                self.handle_get_bootstrap_state()
            }
            "/nitella.local.MobileLogicService/GetSettings" => self.handle_get_settings(),
            "/nitella.local.MobileLogicService/UpdateSettings" => {
                self.handle_update_settings(&data)
            }
            "/nitella.local.MobileLogicService/ListNodes" => self.handle_list_nodes(&data),
            "/nitella.local.MobileLogicService/GetNode" => self.handle_get_node(&data),
            "/nitella.local.MobileLogicService/GetIdentity" => self.handle_get_identity(),
            "/nitella.local.MobileLogicService/GetHubStatus" => self.handle_get_hub_status(),
            "/nitella.local.MobileLogicService/GetP2PStatus" => self.handle_get_p2p_status(),
            "/nitella.local.MobileLogicService/FetchHubCA" => self.handle_fetch_hub_ca(&data).await,
            _ => Err(format!("unknown method: {}", method)),
        }
    }

    fn handle_initialize(&self, data: &[u8]) -> Result<Vec<u8>, String> {
        let req = InitializeRequest::decode(data)
            .map_err(|e| format!("failed to decode InitializeRequest: {}", e))?;

        match self.reload_state(Some(req)) {
            Ok(resp) => Ok(encode_message(&resp)),
            Err(e) => Ok(encode_message(&InitializeResponse {
                success: false,
                error: e.to_string(),
                identity_exists: key_exists(&self.state.lock().unwrap().data_dir),
                identity_locked: false,
            })),
        }
    }

    fn handle_get_bootstrap_state(&self) -> Result<Vec<u8>, String> {
        let state = self.state.lock().map_err(|_| "state lock poisoned")?;
        let identity = &state.identity;
        let stage = if !identity.exists {
            BootstrapStage::SetupNeeded
        } else if state.settings.require_biometric || identity.locked {
            BootstrapStage::AuthNeeded
        } else {
            BootstrapStage::Ready
        };
        Ok(encode_message(&BootstrapStateResponse {
            stage: stage as i32,
            identity_exists: identity.exists,
            identity_locked: identity.locked,
            require_biometric: state.settings.require_biometric,
        }))
    }

    fn handle_get_settings(&self) -> Result<Vec<u8>, String> {
        let state = self.state.lock().map_err(|_| "state lock poisoned")?;
        Ok(encode_message(&state.settings))
    }

    fn handle_update_settings(&self, data: &[u8]) -> Result<Vec<u8>, String> {
        let req = UpdateSettingsRequest::decode(data)
            .map_err(|e| format!("failed to decode UpdateSettingsRequest: {}", e))?;
        let mut state = self.state.lock().map_err(|_| "state lock poisoned")?;
        if let Some(update) = req.settings {
            if let Some(mask) = req.update_mask {
                for path in mask.paths {
                    apply_setting_path(&mut state.settings, &update, &path);
                }
            } else {
                merge_non_default_settings(&mut state.settings, &update);
            }
            if !state.settings.hub_address.trim().is_empty() {
                state.hub_addr = state.settings.hub_address.clone();
            }
            let _ = save_settings(&state.data_dir, &state.settings);
        }
        Ok(encode_message(&state.settings))
    }

    fn handle_list_nodes(&self, data: &[u8]) -> Result<Vec<u8>, String> {
        let req = ListNodesRequest::decode(data).unwrap_or_default();
        let state = self.state.lock().map_err(|_| "state lock poisoned")?;
        require_identity(&state)?;

        let mut nodes = Vec::new();
        let mut online_count = 0;
        for node in state.nodes.values() {
            if req.filter == "online" && !node.online {
                continue;
            }
            if req.filter == "offline" && node.online {
                continue;
            }
            if node.online {
                online_count += 1;
            }
            nodes.push(redact_node(node));
        }
        nodes.sort_by(|a, b| a.name.cmp(&b.name).then_with(|| a.node_id.cmp(&b.node_id)));

        Ok(encode_message(&ListNodesResponse {
            nodes,
            total_count: state.nodes.len() as i32,
            online_count,
        }))
    }

    fn handle_get_node(&self, data: &[u8]) -> Result<Vec<u8>, String> {
        let req = GetNodeRequest::decode(data)
            .map_err(|e| format!("failed to decode GetNodeRequest: {}", e))?;
        let state = self.state.lock().map_err(|_| "state lock poisoned")?;
        require_identity(&state)?;
        let node = state
            .nodes
            .get(&req.node_id)
            .ok_or_else(|| format!("node not found: {}", req.node_id))?;
        Ok(encode_message(&redact_node(node)))
    }

    fn handle_get_identity(&self) -> Result<Vec<u8>, String> {
        let state = self.state.lock().map_err(|_| "state lock poisoned")?;
        Ok(encode_message(&identity_info(&state)))
    }

    fn handle_get_hub_status(&self) -> Result<Vec<u8>, String> {
        let state = self.state.lock().map_err(|_| "state lock poisoned")?;
        Ok(encode_message(&HubStatus {
            connected: false,
            hub_address: state.hub_addr.clone(),
            ..Default::default()
        }))
    }

    fn handle_get_p2p_status(&self) -> Result<Vec<u8>, String> {
        let state = self.state.lock().map_err(|_| "state lock poisoned")?;
        Ok(encode_message(&P2pStatus {
            enabled: false,
            mode: state.settings.p2p_mode,
            active_connections: 0,
            connected_nodes: Vec::new(),
        }))
    }

    async fn handle_fetch_hub_ca(&self, data: &[u8]) -> Result<Vec<u8>, String> {
        let req = FetchHubCaRequest::decode(data)
            .map_err(|e| format!("failed to decode FetchHubCARequest: {}", e))?;
        match crate::hubca::probe_hub_ca(&req.hub_address).await {
            Ok(info) => Ok(encode_message(&FetchHubCaResponse {
                success: true,
                error: String::new(),
                ca_pem: info.ca_pem,
                fingerprint: info.fingerprint,
                emoji_hash: info.emoji_hash,
                subject: info.subject,
                expires: info.expires,
            })),
            Err(e) => Ok(encode_message(&FetchHubCaResponse {
                success: false,
                error: e.to_string(),
                ..Default::default()
            })),
        }
    }

    fn reload_state(&self, req: Option<InitializeRequest>) -> Result<InitializeResponse> {
        let mut state = self
            .state
            .lock()
            .map_err(|_| anyhow!("state lock poisoned"))?;

        if let Some(req) = req {
            if !req.data_dir.trim().is_empty() {
                state.data_dir = PathBuf::from(req.data_dir);
            }
            if !req.cache_dir.trim().is_empty() {
                state.cache_dir = PathBuf::from(req.cache_dir);
            }
            if !req.hub_address.trim().is_empty() {
                state.hub_addr = req.hub_address;
            }
            state.debug_mode = req.debug_mode;
        }

        fs::create_dir_all(&state.data_dir)
            .with_context(|| format!("failed to create data dir {}", state.data_dir.display()))?;
        fs::create_dir_all(&state.cache_dir)
            .with_context(|| format!("failed to create cache dir {}", state.cache_dir.display()))?;

        state.settings = load_settings(&state.data_dir).unwrap_or_else(|_| default_settings());
        if state.settings.stun_servers.is_empty() {
            state.settings.stun_servers = default_settings().stun_servers;
        }
        if state.hub_addr.is_empty() && !state.settings.hub_address.is_empty() {
            state.hub_addr = state.settings.hub_address.clone();
        }

        state.identity = load_identity_snapshot(&state.data_dir)?;
        state.nodes = load_nodes(&state.data_dir)?;

        Ok(InitializeResponse {
            success: true,
            error: String::new(),
            identity_exists: state.identity.exists,
            identity_locked: state.identity.locked,
        })
    }
}

fn default_settings() -> Settings {
    Settings {
        hub_address: String::new(),
        auto_connect_hub: false,
        notifications_enabled: true,
        approval_notifications: true,
        connection_notifications: false,
        alert_notifications: true,
        p2p_mode: P2pMode::Hub as i32,
        require_biometric: false,
        auto_lock_minutes: 5,
        theme: Theme::System as i32,
        language: "en".to_string(),
        hub_ca_pem: Vec::new(),
        hub_cert_pin: String::new(),
        stun_servers: vec![
            "stun:stun.l.google.com:19302".to_string(),
            "stun:stun.nitella.net:3478".to_string(),
        ],
        turn_server: String::new(),
        turn_username: String::new(),
        turn_password: String::new(),
        hub_invite_code: "NITELLA".to_string(),
    }
}

fn load_settings(data_dir: &Path) -> Result<Settings> {
    let path = data_dir.join("settings.json");
    let data = match fs::read(&path) {
        Ok(data) => data,
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => return Ok(default_settings()),
        Err(e) => return Err(e).with_context(|| format!("failed to read {}", path.display())),
    };
    let raw: SettingsJson = serde_json::from_slice(&migrate_theme_field(&data))
        .with_context(|| format!("failed to parse {}", path.display()))?;
    Ok(settings_from_json(raw))
}

fn settings_from_json(raw: SettingsJson) -> Settings {
    let mut settings = default_settings();
    if let Some(value) = raw.hub_address {
        settings.hub_address = value;
    }
    if let Some(value) = raw.auto_connect_hub {
        settings.auto_connect_hub = value;
    }
    if let Some(value) = raw.notifications_enabled {
        settings.notifications_enabled = value;
    }
    if let Some(value) = raw.approval_notifications {
        settings.approval_notifications = value;
    }
    if let Some(value) = raw.connection_notifications {
        settings.connection_notifications = value;
    }
    if let Some(value) = raw.alert_notifications {
        settings.alert_notifications = value;
    }
    if let Some(value) = raw.p2p_mode {
        settings.p2p_mode = value;
    }
    if let Some(value) = raw.require_biometric {
        settings.require_biometric = value;
    }
    if let Some(value) = raw.auto_lock_minutes {
        settings.auto_lock_minutes = value;
    }
    if let Some(value) = raw.theme {
        settings.theme = parse_theme_json(&value);
    }
    if let Some(value) = raw.language {
        settings.language = value;
    }
    if let Some(value) = raw.hub_ca_pem {
        settings.hub_ca_pem = general_purpose::STANDARD
            .decode(value.as_bytes())
            .unwrap_or_else(|_| value.into_bytes());
    }
    if let Some(value) = raw.hub_cert_pin {
        settings.hub_cert_pin = value;
    }
    if let Some(value) = raw.stun_servers {
        settings.stun_servers = value;
    }
    if let Some(value) = raw.turn_server {
        settings.turn_server = value;
    }
    if let Some(value) = raw.turn_username {
        settings.turn_username = value;
    }
    if let Some(value) = raw.turn_password {
        settings.turn_password = value;
    }
    if let Some(value) = raw.hub_invite_code {
        settings.hub_invite_code = value;
    }
    settings
}

fn save_settings(data_dir: &Path, settings: &Settings) -> Result<()> {
    let path = data_dir.join("settings.json");
    let raw = SettingsJson {
        hub_address: Some(settings.hub_address.clone()),
        auto_connect_hub: Some(settings.auto_connect_hub),
        notifications_enabled: Some(settings.notifications_enabled),
        approval_notifications: Some(settings.approval_notifications),
        connection_notifications: Some(settings.connection_notifications),
        alert_notifications: Some(settings.alert_notifications),
        p2p_mode: Some(settings.p2p_mode),
        require_biometric: Some(settings.require_biometric),
        auto_lock_minutes: Some(settings.auto_lock_minutes),
        theme: Some(serde_json::Value::from(settings.theme)),
        language: Some(settings.language.clone()),
        hub_ca_pem: (!settings.hub_ca_pem.is_empty())
            .then(|| general_purpose::STANDARD.encode(&settings.hub_ca_pem)),
        hub_cert_pin: (!settings.hub_cert_pin.is_empty()).then(|| settings.hub_cert_pin.clone()),
        stun_servers: Some(settings.stun_servers.clone()),
        turn_server: (!settings.turn_server.is_empty()).then(|| settings.turn_server.clone()),
        turn_username: (!settings.turn_username.is_empty()).then(|| settings.turn_username.clone()),
        turn_password: (!settings.turn_password.is_empty()).then(|| settings.turn_password.clone()),
        hub_invite_code: Some(settings.hub_invite_code.clone()),
    };
    let data = serde_json::to_vec_pretty(&raw)?;
    fs::write(path, data)?;
    Ok(())
}

fn migrate_theme_field(data: &[u8]) -> Vec<u8> {
    let Ok(mut raw) = serde_json::from_slice::<serde_json::Map<String, serde_json::Value>>(data)
    else {
        return data.to_vec();
    };
    if let Some(serde_json::Value::String(theme)) = raw.get("theme") {
        let enum_value = match theme.to_ascii_lowercase().as_str() {
            "light" => Some(Theme::Light as i32),
            "dark" => Some(Theme::Dark as i32),
            "system" => Some(Theme::System as i32),
            _ => None,
        };
        if let Some(value) = enum_value {
            raw.insert("theme".to_string(), serde_json::Value::from(value));
            return serde_json::to_vec(&raw).unwrap_or_else(|_| data.to_vec());
        }
    }
    data.to_vec()
}

fn parse_theme_json(value: &serde_json::Value) -> i32 {
    match value {
        serde_json::Value::Number(n) => n.as_i64().unwrap_or(Theme::System as i64) as i32,
        serde_json::Value::String(s) => match s.to_ascii_lowercase().as_str() {
            "light" => Theme::Light as i32,
            "dark" => Theme::Dark as i32,
            "system" => Theme::System as i32,
            _ => Theme::System as i32,
        },
        _ => Theme::System as i32,
    }
}

fn load_identity_snapshot(data_dir: &Path) -> Result<IdentitySnapshot> {
    if !key_exists(data_dir) {
        return Ok(IdentitySnapshot::default());
    }

    let key_pem = fs::read(data_dir.join("root_ca.key")).context("failed to read root_ca.key")?;
    let locked = is_key_encrypted(&key_pem);
    if locked {
        return Ok(IdentitySnapshot {
            exists: true,
            locked: true,
            ..Default::default()
        });
    }

    let cert_pem = fs::read(data_dir.join("root_ca.crt")).context("failed to read root_ca.crt")?;
    let parsed = parse_cert_pem(&cert_pem)?;
    Ok(IdentitySnapshot {
        exists: true,
        locked: false,
        fingerprint: fingerprint(&parsed.public_key),
        emoji_hash: emoji_hash(&parsed.public_key),
        root_cert_pem: String::from_utf8_lossy(&cert_pem).to_string(),
        created_at: parsed.not_before,
    })
}

fn key_exists(data_dir: &Path) -> bool {
    data_dir.join("root_ca.key").exists()
}

fn is_key_encrypted(key_pem: &[u8]) -> bool {
    parse_x509_pem(key_pem)
        .map(|(_, pem)| pem.label == "ENCRYPTED PRIVATE KEY")
        .unwrap_or(false)
}

fn load_nodes(data_dir: &Path) -> Result<HashMap<String, NodeInfo>> {
    let nodes_dir = data_dir.join("nodes");
    let entries = match fs::read_dir(&nodes_dir) {
        Ok(entries) => entries,
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => return Ok(HashMap::new()),
        Err(e) => return Err(e).with_context(|| format!("failed to read {}", nodes_dir.display())),
    };

    let mut nodes = HashMap::new();
    for entry in entries.flatten() {
        if entry.file_type().map(|t| t.is_dir()).unwrap_or(false) {
            continue;
        }
        let path = entry.path();
        if path.extension().and_then(|e| e.to_str()) != Some("crt") {
            continue;
        }
        let Some(node_id) = path
            .file_stem()
            .and_then(|s| s.to_str())
            .map(str::to_string)
        else {
            continue;
        };
        let cert_pem = match fs::read(&path) {
            Ok(cert) => cert,
            Err(_) => continue,
        };
        let parsed = match parse_cert_pem(&cert_pem) {
            Ok(parsed) => parsed,
            Err(_) => continue,
        };
        let metadata = load_node_metadata(data_dir, &node_id);
        nodes.insert(
            node_id.clone(),
            NodeInfo {
                node_id: node_id.clone(),
                name: metadata
                    .as_ref()
                    .and_then(|m| m.name.clone())
                    .filter(|n| !n.trim().is_empty())
                    .unwrap_or_else(|| node_id.clone()),
                fingerprint: fingerprint(&parsed.public_key),
                emoji_hash: emoji_hash(&parsed.public_key),
                online: false,
                paired_at: parsed.not_before,
                tags: metadata
                    .as_ref()
                    .and_then(|m| m.tags.clone())
                    .unwrap_or_default(),
                pinned: metadata.as_ref().and_then(|m| m.pinned).unwrap_or(false),
                alerts_enabled: metadata
                    .as_ref()
                    .and_then(|m| m.alerts_enabled)
                    .unwrap_or(false),
                conn_type: NodeConnectionType::Hub as i32,
                ..Default::default()
            },
        );
    }
    Ok(nodes)
}

fn load_node_metadata(data_dir: &Path, node_id: &str) -> Option<NodeMetadata> {
    let data = fs::read(data_dir.join("nodes").join(format!("{}.json", node_id))).ok()?;
    serde_json::from_slice(&data).ok()
}

#[derive(Debug)]
struct ParsedCert {
    public_key: Vec<u8>,
    not_before: Option<prost_types::Timestamp>,
}

fn parse_cert_pem(cert_pem: &[u8]) -> Result<ParsedCert> {
    let (_, pem) = parse_x509_pem(cert_pem).map_err(|e| anyhow!("failed to parse PEM: {}", e))?;
    let (_, cert) = X509Certificate::from_der(&pem.contents)
        .map_err(|e| anyhow!("failed to parse X509: {}", e))?;
    let public_key = cert
        .tbs_certificate
        .subject_pki
        .subject_public_key
        .data
        .as_ref()
        .to_vec();
    if public_key.is_empty() {
        return Err(anyhow!("certificate public key is empty"));
    }
    Ok(ParsedCert {
        public_key,
        not_before: Some(prost_types::Timestamp {
            seconds: cert.validity().not_before.timestamp(),
            nanos: 0,
        }),
    })
}

fn fingerprint(public_key: &[u8]) -> String {
    hex::encode(Sha256::digest(public_key))
}

fn emoji_hash(public_key: &[u8]) -> String {
    let hash = Sha256::digest(public_key);
    let mut parts = Vec::with_capacity(8);
    for byte in hash.iter().take(8) {
        parts.push(IDENTITY_EMOJIS[*byte as usize % IDENTITY_EMOJIS.len()]);
    }
    parts.join("")
}

fn identity_info(state: &MobileState) -> IdentityInfo {
    IdentityInfo {
        exists: state.identity.exists,
        locked: state.identity.locked,
        fingerprint: state.identity.fingerprint.clone(),
        emoji_hash: state.identity.emoji_hash.clone(),
        root_cert_pem: state.identity.root_cert_pem.clone(),
        created_at: state.identity.created_at.clone(),
        paired_nodes: state.nodes.len() as i32,
    }
}

fn require_identity(state: &MobileState) -> Result<(), String> {
    if !state.identity.exists || state.identity.locked {
        return Err("identity not initialized or locked".to_string());
    }
    Ok(())
}

fn redact_node(node: &NodeInfo) -> NodeInfo {
    let mut clone = node.clone();
    clone.direct_token.clear();
    clone.direct_ca_pem.clear();
    clone
}

fn apply_setting_path(target: &mut Settings, source: &Settings, path: &str) {
    match path {
        "hub_address" => target.hub_address = source.hub_address.clone(),
        "hub_invite_code" => target.hub_invite_code = source.hub_invite_code.clone(),
        "auto_connect_hub" => target.auto_connect_hub = source.auto_connect_hub,
        "notifications_enabled" => target.notifications_enabled = source.notifications_enabled,
        "approval_notifications" => target.approval_notifications = source.approval_notifications,
        "connection_notifications" => {
            target.connection_notifications = source.connection_notifications
        }
        "alert_notifications" => target.alert_notifications = source.alert_notifications,
        "p2p_mode" => target.p2p_mode = source.p2p_mode,
        "require_biometric" => target.require_biometric = source.require_biometric,
        "auto_lock_minutes" => target.auto_lock_minutes = source.auto_lock_minutes,
        "theme" => target.theme = source.theme,
        "language" => target.language = source.language.clone(),
        "hub_ca_pem" => target.hub_ca_pem = source.hub_ca_pem.clone(),
        "hub_cert_pin" => target.hub_cert_pin = source.hub_cert_pin.clone(),
        "stun_servers" => target.stun_servers = source.stun_servers.clone(),
        "turn_server" => target.turn_server = source.turn_server.clone(),
        "turn_username" => target.turn_username = source.turn_username.clone(),
        "turn_password" => target.turn_password = source.turn_password.clone(),
        _ => {}
    }
}

fn merge_non_default_settings(target: &mut Settings, source: &Settings) {
    if !source.hub_address.is_empty() {
        target.hub_address = source.hub_address.clone();
    }
    if source.auto_connect_hub {
        target.auto_connect_hub = true;
    }
    if source.notifications_enabled {
        target.notifications_enabled = true;
    }
    if source.approval_notifications {
        target.approval_notifications = true;
    }
    if source.connection_notifications {
        target.connection_notifications = true;
    }
    if source.alert_notifications {
        target.alert_notifications = true;
    }
    if source.p2p_mode != 0 {
        target.p2p_mode = source.p2p_mode;
    }
    if source.require_biometric {
        target.require_biometric = true;
    }
    if source.auto_lock_minutes != 0 {
        target.auto_lock_minutes = source.auto_lock_minutes;
    }
    if source.theme != 0 {
        target.theme = source.theme;
    }
    if !source.language.is_empty() {
        target.language = source.language.clone();
    }
    if !source.hub_ca_pem.is_empty() {
        target.hub_ca_pem = source.hub_ca_pem.clone();
    }
    if !source.hub_cert_pin.is_empty() {
        target.hub_cert_pin = source.hub_cert_pin.clone();
    }
    if !source.stun_servers.is_empty() {
        target.stun_servers = source.stun_servers.clone();
    }
    if !source.turn_server.is_empty() {
        target.turn_server = source.turn_server.clone();
    }
    if !source.turn_username.is_empty() {
        target.turn_username = source.turn_username.clone();
    }
    if !source.turn_password.is_empty() {
        target.turn_password = source.turn_password.clone();
    }
    if !source.hub_invite_code.is_empty() {
        target.hub_invite_code = source.hub_invite_code.clone();
    }
}

fn encode_message<M: Message>(message: &M) -> Vec<u8> {
    message.encode_to_vec()
}

#[cfg(test)]
mod tests {
    use super::*;
    use rcgen::{Certificate, CertificateParams, DistinguishedName, DnType, IsCa};

    fn temp_dir(name: &str) -> PathBuf {
        std::env::temp_dir().join(format!("nitella-mobile-{name}-{}", uuid::Uuid::new_v4()))
    }

    fn write_cert(dir: &Path, filename: &str, cn: &str, is_ca: bool) -> Certificate {
        let mut params = CertificateParams::new(vec![cn.to_string()]);
        params.alg = &rcgen::PKCS_ED25519;
        params.distinguished_name = DistinguishedName::new();
        params.distinguished_name.push(DnType::CommonName, cn);
        if is_ca {
            params.is_ca = IsCa::Ca(rcgen::BasicConstraints::Constrained(0));
        }
        let cert = Certificate::from_params(params).unwrap();
        fs::write(dir.join(filename), cert.serialize_pem().unwrap()).unwrap();
        cert
    }

    #[tokio::test]
    async fn initialize_loads_settings_identity_and_nodes() {
        let dir = temp_dir("state");
        let nodes_dir = dir.join("nodes");
        fs::create_dir_all(&nodes_dir).unwrap();
        let root = write_cert(&dir, "root_ca.crt", "Nitella Root CA", true);
        fs::write(dir.join("root_ca.key"), root.serialize_private_key_pem()).unwrap();
        write_cert(&nodes_dir, "node-a.crt", "node-a", false);
        fs::write(
            nodes_dir.join("node-a.json"),
            r#"{"name":"Node A","tags":["edge"],"pinned":true}"#,
        )
        .unwrap();
        fs::write(
            dir.join("settings.json"),
            r#"{"hub_address":"hub.local:443","theme":"dark","stun_servers":["stun:test"]}"#,
        )
        .unwrap();

        let service = MobileLogicService::new(dir.to_string_lossy().to_string());
        service.initialize().await.unwrap();

        let identity = IdentityInfo::decode(
            service
                .invoke("/nitella.local.MobileLogicService/GetIdentity", vec![])
                .await
                .unwrap()
                .as_slice(),
        )
        .unwrap();
        assert!(identity.exists);
        assert!(!identity.locked);
        assert_eq!(identity.paired_nodes, 1);
        assert!(!identity.fingerprint.is_empty());

        let settings = Settings::decode(
            service
                .invoke("/nitella.local.MobileLogicService/GetSettings", vec![])
                .await
                .unwrap()
                .as_slice(),
        )
        .unwrap();
        assert_eq!(settings.hub_address, "hub.local:443");
        assert_eq!(settings.theme, Theme::Dark as i32);
        assert_eq!(settings.stun_servers, vec!["stun:test"]);

        let nodes = ListNodesResponse::decode(
            service
                .invoke(
                    "/nitella.local.MobileLogicService/ListNodes",
                    ListNodesRequest {
                        filter: "all".to_string(),
                    }
                    .encode_to_vec(),
                )
                .await
                .unwrap()
                .as_slice(),
        )
        .unwrap();
        assert_eq!(nodes.total_count, 1);
        assert_eq!(nodes.nodes[0].name, "Node A");
        assert_eq!(nodes.nodes[0].tags, vec!["edge"]);

        let _ = fs::remove_dir_all(dir);
    }

    #[tokio::test]
    async fn encrypted_key_reports_locked_without_requiring_cert_parse() {
        let dir = temp_dir("locked");
        fs::create_dir_all(&dir).unwrap();
        fs::write(
            dir.join("root_ca.key"),
            "-----BEGIN ENCRYPTED PRIVATE KEY-----\nAA==\n-----END ENCRYPTED PRIVATE KEY-----\n",
        )
        .unwrap();

        let service = MobileLogicService::new(dir.to_string_lossy().to_string());
        service.initialize().await.unwrap();
        let identity = IdentityInfo::decode(
            service
                .invoke("/nitella.local.MobileLogicService/GetIdentity", vec![])
                .await
                .unwrap()
                .as_slice(),
        )
        .unwrap();

        assert!(identity.exists);
        assert!(identity.locked);

        let _ = fs::remove_dir_all(dir);
    }
}
