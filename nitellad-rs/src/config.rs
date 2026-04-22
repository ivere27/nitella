use crate::proto::common::MockPreset;
use crate::proto::proxy::{
    HealthCheckConfig, HealthCheckType, MockConfig as ProtoMockConfig,
    RateLimitConfig as ProtoRateLimitConfig,
};
use anyhow::{bail, Result};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use tokio::fs;

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct YamlConfig {
    pub http: Option<HttpConfig>,
    pub tcp: Option<TcpConfig>,
    pub entry_points: Option<HashMap<String, EntryPoint>>,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct HttpConfig {
    pub routers: Option<HashMap<String, Router>>,
    pub services: Option<HashMap<String, Service>>,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct TcpConfig {
    pub routers: Option<HashMap<String, Router>>,
    pub services: Option<HashMap<String, Service>>,
    pub middlewares: Option<HashMap<String, Middleware>>,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
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
    pub tls: Option<TlsConfig>,
    pub rate_limit: Option<YamlRateLimitConfig>,
}

#[derive(Debug, Clone, Default, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct YamlRateLimitConfig {
    pub max_connections: Option<i32>,
    pub interval_seconds: Option<i32>,
    pub auto_block: Option<bool>,
    pub block_duration_seconds: Option<i32>,
    #[serde(default)]
    pub block_steps_seconds: Vec<i32>,
    pub count_only_failures: Option<bool>,
    pub failure_duration_threshold: Option<i32>,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct TlsConfig {
    #[serde(default)]
    pub cert_file: String,
    #[serde(default)]
    pub key_file: String,
    #[serde(default)]
    pub client_ca: String,
    #[serde(default)]
    pub client_auth: String, // none, optional/request, require
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Router {
    #[serde(default)]
    pub entry_points: Vec<String>,
    #[serde(default)]
    pub service: String,
    pub rule: Option<String>,
    #[serde(default)]
    pub middlewares: Vec<String>,
    #[serde(default)]
    pub priority: i32,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Service {
    pub load_balancer: Option<LoadBalancer>,
    pub address: Option<String>, // Direct address shorthand
    pub health_check: Option<HealthCheck>,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct LoadBalancer {
    pub servers: Vec<Server>,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Server {
    #[serde(default)]
    pub address: String,
    #[serde(default)]
    pub url: String, // For HTTP/Traefik compatibility
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct HealthCheck {
    #[serde(default)]
    pub interval: String,
    #[serde(default)]
    pub timeout: String,
    #[serde(default)]
    pub r#type: String,
    #[serde(default)]
    pub path: String,
    #[serde(default)]
    pub expected_status: i32,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Middleware {
    pub mock: Option<MockConfig>,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct MockConfig {
    #[serde(default)]
    pub preset: String,
    #[serde(default)]
    pub tarpit: bool,
    #[serde(default)]
    pub delay_ms: i32,
    #[serde(default)]
    pub protocol: String,
    #[serde(default)]
    pub banner: String,
    #[serde(default)]
    pub response: String,
}

#[derive(Debug, Clone, Default)]
pub struct EntryPointResolution {
    pub default_backend: String,
    pub health_check: Option<HealthCheck>,
    pub middleware_mocks: Vec<(String, MockConfig)>,
    pub router_priority: i32,
}

impl YamlConfig {
    pub fn resolve_entry_point(&self, name: &str, ep: &EntryPoint) -> EntryPointResolution {
        let mut resolved = EntryPointResolution {
            default_backend: ep.default_backend.clone(),
            ..Default::default()
        };

        let Some(tcp) = &self.tcp else {
            return resolved;
        };
        let Some(routers) = &tcp.routers else {
            return resolved;
        };

        let mut candidates: Vec<(&String, &Router)> = routers
            .iter()
            .filter(|(_, router)| {
                router.entry_points.iter().any(|entry| entry == name) && !router.service.is_empty()
            })
            .collect();
        candidates.sort_by(|(a_name, a), (b_name, b)| {
            b.priority.cmp(&a.priority).then_with(|| a_name.cmp(b_name))
        });

        for (router_name, router) in candidates {
            let service = tcp
                .services
                .as_ref()
                .and_then(|services| services.get(&router.service));
            let Some(service) = service else {
                continue;
            };

            if resolved.default_backend.is_empty() {
                resolved.default_backend = service_backend(service);
            }
            resolved.health_check = service.health_check.clone();
            resolved.router_priority = router.priority;

            if let Some(middlewares) = &tcp.middlewares {
                for middleware_name in &router.middlewares {
                    if let Some(mock) = middlewares
                        .get(middleware_name)
                        .and_then(|middleware| middleware.mock.clone())
                    {
                        let rule_name = format!("{router_name}:{middleware_name}");
                        resolved.middleware_mocks.push((rule_name, mock));
                    }
                }
            }

            break;
        }

        resolved
    }
}

impl YamlRateLimitConfig {
    fn has_any_setting(&self) -> bool {
        self.max_connections.is_some()
            || self.interval_seconds.is_some()
            || self.auto_block.is_some()
            || self.block_duration_seconds.is_some()
            || !self.block_steps_seconds.is_empty()
            || self.count_only_failures.is_some()
            || self.failure_duration_threshold.is_some()
    }

    pub fn to_proto(&self) -> Result<Option<ProtoRateLimitConfig>> {
        if !self.has_any_setting() {
            return Ok(None);
        }

        let Some(max_connections) = self.max_connections else {
            bail!("rateLimit.maxConnections must be greater than 0");
        };
        if max_connections <= 0 {
            bail!("rateLimit.maxConnections must be greater than 0");
        }

        let interval_seconds = self.interval_seconds.unwrap_or(60);
        if interval_seconds <= 0 {
            bail!("rateLimit.intervalSeconds must be greater than 0");
        }

        let auto_block = self.auto_block.unwrap_or(true);

        for step in &self.block_steps_seconds {
            if *step < 0 {
                bail!("rateLimit.blockStepsSeconds cannot contain negative values");
            }
        }

        let mut block_duration_seconds = if auto_block && self.block_steps_seconds.is_empty() {
            600
        } else {
            0
        };
        if let Some(value) = self.block_duration_seconds {
            if value < 0 {
                bail!("rateLimit.blockDurationSeconds cannot be negative");
            }
            block_duration_seconds = value;
        }

        let count_only_failures = self.count_only_failures.unwrap_or(false);
        if self.failure_duration_threshold.is_some() && !count_only_failures {
            bail!("rateLimit.failureDurationThreshold requires rateLimit.countOnlyFailures=true");
        }

        let mut failure_duration_threshold = 0;
        if count_only_failures {
            failure_duration_threshold = self.failure_duration_threshold.unwrap_or(1);
            if failure_duration_threshold < 0 {
                bail!("rateLimit.failureDurationThreshold cannot be negative");
            }
        }

        Ok(Some(ProtoRateLimitConfig {
            max_connections,
            interval_seconds,
            auto_block,
            block_duration_seconds,
            block_steps_seconds: self.block_steps_seconds.clone(),
            count_only_failures,
            failure_duration_threshold,
        }))
    }
}

pub fn rate_limit_to_proto(
    rate_limit: &Option<YamlRateLimitConfig>,
) -> Result<Option<ProtoRateLimitConfig>> {
    match rate_limit {
        Some(rate_limit) => rate_limit.to_proto(),
        None => Ok(None),
    }
}

fn service_backend(service: &Service) -> String {
    if let Some(lb) = &service.load_balancer {
        if let Some(server) = lb.servers.first() {
            if !server.address.is_empty() {
                return server.address.clone();
            }
            return server.url.clone();
        }
    }

    service.address.clone().unwrap_or_default()
}

pub fn health_check_to_proto(health_check: &HealthCheck) -> HealthCheckConfig {
    HealthCheckConfig {
        interval: health_check.interval.clone(),
        timeout: health_check.timeout.clone(),
        r#type: match health_check.r#type.to_lowercase().as_str() {
            "tcp" => HealthCheckType::Tcp as i32,
            "http" => HealthCheckType::Http as i32,
            "https" => HealthCheckType::Https as i32,
            _ => HealthCheckType::Unspecified as i32,
        },
        path: health_check.path.clone(),
        expected_status: health_check.expected_status,
    }
}

pub fn mock_config_to_proto(mock: &MockConfig) -> ProtoMockConfig {
    let mut preset = string_to_mock_preset(&mock.preset);
    if preset == MockPreset::Unspecified as i32 && mock.tarpit {
        preset = match mock.protocol.to_lowercase().as_str() {
            "ssh" => MockPreset::SshTarpit as i32,
            "mysql" => MockPreset::MysqlTarpit as i32,
            _ => MockPreset::RawTarpit as i32,
        };
    }

    let payload = if !mock.response.is_empty() {
        mock.response.clone().into_bytes()
    } else {
        mock.banner.clone().into_bytes()
    };

    ProtoMockConfig {
        preset,
        protocol: mock.protocol.clone(),
        payload,
        delay_ms: mock.delay_ms,
    }
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

pub async fn load_config(path: &str) -> Result<YamlConfig> {
    let content = fs::read_to_string(path).await?;
    let config: YamlConfig = serde_yaml::from_str(&content)?;
    Ok(config)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::proto::common::MockPreset;
    use crate::proto::proxy::HealthCheckType;

    #[test]
    fn yaml_schema_parses_go_config_branches_and_resolves_priority() {
        let cfg: YamlConfig = serde_yaml::from_str(
            r#"
entryPoints:
  web:
    address: "127.0.0.1:8443"
    rateLimit:
      maxConnections: 3
      intervalSeconds: 60
      autoBlock: true
      blockDurationSeconds: 1800
      blockStepsSeconds: [1800, 3600]
      countOnlyFailures: true
      failureDurationThreshold: 20
    tls:
      certFile: "/tmp/cert.pem"
      keyFile: "/tmp/key.pem"
      clientCA: "/tmp/ca.pem"
      clientAuth: "require"
tcp:
  routers:
    low:
      entryPoints: ["web"]
      service: slow
      priority: 1
    high:
      entryPoints: ["web"]
      service: fast
      priority: 10
      middlewares: ["honeypot"]
  middlewares:
    honeypot:
      mock:
        preset: "ssh-tarpit"
        delayMs: 25
        protocol: "ssh"
        banner: "SSH-2.0-test"
  services:
    slow:
      address: "127.0.0.1:9001"
    fast:
      loadBalancer:
        servers:
          - address: "127.0.0.1:9002"
      healthCheck:
        interval: "10s"
        timeout: "2s"
        type: "tcp"
        expectedStatus: 204
"#,
        )
        .unwrap();

        let ep = cfg.entry_points.as_ref().unwrap().get("web").unwrap();
        let resolved = cfg.resolve_entry_point("web", ep);
        assert_eq!(resolved.default_backend, "127.0.0.1:9002");
        assert_eq!(resolved.router_priority, 10);
        assert_eq!(resolved.middleware_mocks.len(), 1);
        assert_eq!(resolved.middleware_mocks[0].1.preset, "ssh-tarpit");
        let rate_limit = rate_limit_to_proto(&ep.rate_limit).unwrap().unwrap();
        assert_eq!(rate_limit.max_connections, 3);
        assert_eq!(rate_limit.interval_seconds, 60);
        assert!(rate_limit.auto_block);
        assert_eq!(rate_limit.block_duration_seconds, 1800);
        assert_eq!(rate_limit.block_steps_seconds, vec![1800, 3600]);
        assert!(rate_limit.count_only_failures);
        assert_eq!(rate_limit.failure_duration_threshold, 20);

        let health_check = health_check_to_proto(resolved.health_check.as_ref().unwrap());
        assert_eq!(health_check.r#type, HealthCheckType::Tcp as i32);
        assert_eq!(health_check.interval, "10s");

        let mock = mock_config_to_proto(&resolved.middleware_mocks[0].1);
        assert_eq!(mock.preset, MockPreset::SshTarpit as i32);
        assert_eq!(mock.delay_ms, 25);
        assert_eq!(mock.payload, b"SSH-2.0-test");
    }

    #[test]
    fn yaml_router_defaults_match_go_zero_values() {
        let cfg: YamlConfig = serde_yaml::from_str(
            r#"
entryPoints:
  web:
    address: "127.0.0.1:8080"
tcp:
  routers:
    empty:
      rule: "GeoCountry(`KR`)"
  services: {}
"#,
        )
        .unwrap();

        let router = cfg
            .tcp
            .as_ref()
            .unwrap()
            .routers
            .as_ref()
            .unwrap()
            .get("empty")
            .unwrap();
        assert!(router.entry_points.is_empty());
        assert!(router.service.is_empty());
        assert_eq!(router.priority, 0);
    }

    #[test]
    fn yaml_rate_limit_defaults_and_validation() {
        let rate_limit = YamlRateLimitConfig {
            max_connections: Some(3),
            count_only_failures: Some(true),
            ..Default::default()
        }
        .to_proto()
        .unwrap()
        .unwrap();

        assert_eq!(rate_limit.interval_seconds, 60);
        assert!(rate_limit.auto_block);
        assert_eq!(rate_limit.block_duration_seconds, 600);
        assert_eq!(rate_limit.failure_duration_threshold, 1);

        let invalid = YamlRateLimitConfig {
            max_connections: Some(3),
            failure_duration_threshold: Some(20),
            ..Default::default()
        };
        assert!(invalid.to_proto().is_err());
    }
}
