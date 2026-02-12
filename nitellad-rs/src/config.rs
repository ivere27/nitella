use serde::{Deserialize, Serialize};
use anyhow::Result;
use std::collections::HashMap;
use tokio::fs;

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct YamlConfig {
    pub http: Option<HttpConfig>,
    pub tcp: Option<TcpConfig>,
    pub entry_points: Option<HashMap<String, EntryPoint>>,
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct HttpConfig {
    pub routers: Option<HashMap<String, Router>>,
    pub services: Option<HashMap<String, Service>>,
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct TcpConfig {
    pub routers: Option<HashMap<String, Router>>,
    pub services: Option<HashMap<String, Service>>,
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct EntryPoint {
    pub address: String,
    #[serde(default)]
    pub default_action: String, // allow, block, mock, approval
    #[serde(default)]
    pub default_mock: String,
    #[serde(default)]
    pub default_backend: String,
    #[serde(default)]
    pub fallback_action: String, // close, mock
    #[serde(default)]
    pub fallback_mock: String,
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Router {
    pub entry_points: Vec<String>,
    pub service: String,
    pub rule: Option<String>,
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Service {
    pub load_balancer: Option<LoadBalancer>,
    pub address: Option<String>, // Direct address shorthand
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct LoadBalancer {
    pub servers: Vec<Server>,
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Server {
    #[serde(default)]
    pub address: String,
    #[serde(default)]
    pub url: String, // For HTTP/Traefik compatibility
}

pub async fn load_config(path: &str) -> Result<YamlConfig> {
    let content = fs::read_to_string(path).await?;
    let config: YamlConfig = serde_yaml::from_str(&content)?;
    Ok(config)
}
