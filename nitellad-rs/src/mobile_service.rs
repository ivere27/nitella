use prost::Message;
use crate::proto::local::{
    InitializeRequest, InitializeResponse, 
    Settings,
    ListNodesResponse,
    IdentityInfo,
};
use crate::proto::common::P2pMode;

pub struct MobileLogicService {
}

impl MobileLogicService {
    pub fn new(_storage_path: String) -> Self {
        Self { }
    }

    pub async fn initialize(&self) -> Result<(), String> {
        // Init logic here (DB, etc.)
        Ok(())
    }

    pub async fn invoke(&self, method: &str, data: Vec<u8>) -> Vec<u8> {
        match method {
            "/nitella.local.MobileLogicService/Initialize" => {
                self.handle_initialize(&data)
            },
            "/nitella.local.MobileLogicService/GetSettings" => {
                self.handle_get_settings(&data)
            },
             "/nitella.local.MobileLogicService/ListNodes" => {
                self.handle_list_nodes(&data)
            },
            "/nitella.local.MobileLogicService/GetIdentity" => {
                self.handle_get_identity(&data)
            },
            _ => {
                format!("Method not implemented: {}", method).into_bytes()
            }
        }
    }

    fn handle_initialize(&self, data: &[u8]) -> Vec<u8> {
        // Decode request
        let _req = match InitializeRequest::decode(data) {
            Ok(r) => r,
            Err(e) => return format!("Decode error: {}", e).into_bytes(), 
        };

        // Create response
        let resp = InitializeResponse {
            success: true,
            error: "".to_string(),
            identity_exists: false,
            identity_locked: false,
        };

        let mut buf = Vec::new();
        resp.encode(&mut buf).unwrap();
        buf
    }

    fn handle_get_settings(&self, _data: &[u8]) -> Vec<u8> {
        let resp = Settings {
            hub_address: "".to_string(),
            auto_connect_hub: false,
            p2p_mode: P2pMode::Auto as i32,
            ..Default::default()
        };
        let mut buf = Vec::new();
        resp.encode(&mut buf).unwrap();
        buf
    }
    
    fn handle_list_nodes(&self, _data: &[u8]) -> Vec<u8> {
        let resp = ListNodesResponse {
            nodes: vec![],
            total_count: 0,
            online_count: 0,
        };
        let mut buf = Vec::new();
        resp.encode(&mut buf).unwrap();
        buf
    }

    fn handle_get_identity(&self, _data: &[u8]) -> Vec<u8> {
        let resp = IdentityInfo {
            exists: false,
            locked: false,
            fingerprint: "".to_string(),
            emoji_hash: "".to_string(),
            root_cert_pem: "".to_string(),
            created_at: None,
            paired_nodes: 0,
        };
        let mut buf = Vec::new();
        resp.encode(&mut buf).unwrap();
        buf
    }
}
