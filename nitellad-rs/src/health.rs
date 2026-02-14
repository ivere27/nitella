use crate::manager::ProxyManager;
use crate::proto::proxy::{HealthCheckType, HealthStatus};
use std::collections::HashMap;
use std::sync::atomic::Ordering;
use std::sync::Arc;
use tokio::net::TcpStream;
use tokio::sync::RwLock;
use tokio::time::{sleep, Duration, Instant};
use tracing::{debug, info};

pub struct HealthChecker {
    manager: Arc<ProxyManager>,
    last_checks: Arc<RwLock<HashMap<String, Instant>>>,
}

impl HealthChecker {
    pub fn new(manager: Arc<ProxyManager>) -> Self {
        Self {
            manager,
            last_checks: Arc::new(RwLock::new(HashMap::new())),
        }
    }

    pub async fn run(&self) {
        info!("Health Checker started");
        loop {
            self.check_all().await;
            sleep(Duration::from_secs(1)).await; // 1s tick
        }
    }

    async fn check_all(&self) {
        let proxies = self.manager.proxies.read().await;
        let mut last_checks = self.last_checks.write().await;
        let now = Instant::now();

        for (id, p) in proxies.iter() {
            if !p.enabled {
                continue;
            }
            if let Some(hc) = &p.config.health_check {
                // Determine interval (default 5s if 0)
                let interval_ms = Self::parse_duration_str(&hc.interval);
                let interval_secs = if interval_ms > 0 {
                    interval_ms / 1000
                } else {
                    5
                };
                let interval = Duration::from_secs(interval_secs);

                if let Some(last) = last_checks.get(id) {
                    if now.duration_since(*last) < interval {
                        continue;
                    }
                }

                // Update last check time
                last_checks.insert(id.clone(), now);

                let target = p.config.default_backend.clone();
                let status_atomic = p.health_status.clone();
                let check_type =
                    HealthCheckType::try_from(hc.r#type).unwrap_or(HealthCheckType::Unspecified);
                let path = if hc.path.is_empty() {
                    "/".to_string()
                } else {
                    hc.path.clone()
                };
                let expected_status = hc.expected_status;
                let parsed_timeout = Self::parse_duration_str(&hc.timeout);
                let timeout_ms = if parsed_timeout > 0 {
                    parsed_timeout
                } else {
                    2000
                };
                let id_clone = id.clone();

                tokio::spawn(async move {
                    let result = match check_type {
                        HealthCheckType::Tcp => Self::check_tcp(&target, timeout_ms).await,
                        HealthCheckType::Http | HealthCheckType::Https => {
                            Self::check_http(&target, &path, expected_status, timeout_ms).await
                        }
                        _ => true,
                    };

                    let new_status = if result {
                        HealthStatus::Healthy as i32
                    } else {
                        HealthStatus::Unhealthy as i32
                    };

                    let old = status_atomic.swap(new_status, Ordering::Relaxed);
                    if old != new_status {
                        debug!(
                            "Health status changed for {}: {} -> {}",
                            id_clone, old, new_status
                        );
                    }
                });
            }
        }
    }

    async fn check_tcp(target: &str, timeout_ms: u64) -> bool {
        match tokio::time::timeout(
            Duration::from_millis(timeout_ms),
            TcpStream::connect(target),
        )
        .await
        {
            Ok(Ok(_)) => true,
            _ => false,
        }
    }

    async fn check_http(target: &str, path: &str, expected_status: i32, timeout_ms: u64) -> bool {
        // Simple check (assume http:// if no scheme, unless 443 port implication, but simpler to trust scheme)
        // If target has no scheme, prepend http://
        let base_url = if target.contains("://") {
            target.to_string()
        } else {
            format!("http://{}", target)
        };

        // Construct full URL (handle slash overlap)
        let url = format!(
            "{}{}",
            base_url.trim_end_matches('/'),
            if path.starts_with('/') {
                path.to_string()
            } else {
                format!("/{}", path)
            }
        );

        match reqwest::Client::builder()
            .timeout(Duration::from_millis(timeout_ms))
            .build()
        {
            Ok(client) => {
                match client.get(&url).send().await {
                    Ok(resp) => {
                        let code = resp.status().as_u16() as i32;
                        if expected_status > 0 {
                            code == expected_status
                        } else {
                            // Default success range 200-299
                            code >= 200 && code < 300
                        }
                    }
                    Err(_) => false,
                }
            }
            Err(_) => false,
        }
    }

    fn parse_duration_str(s: &str) -> u64 {
        if s.is_empty() {
            return 0;
        }

        // Simple parser: try to parse number, ignoring suffix "s" if present.
        // If suffix is "ms", we return as is (if caller expects seconds, this might be wrong, but we iterate)
        // Wait, caller of interval expects seconds. Caller of timeout expects ms.
        // If "5s", interval=5. timeout=5000.
        // Let's implement generic parse returning MS.

        // Remove whitespace
        let s = s.trim();
        let len = s.len();
        if len == 0 {
            return 0;
        }

        if s.ends_with("ms") {
            if let Ok(v) = s[..len - 2].parse::<u64>() {
                return v;
            }
        } else if s.ends_with("s") {
            if let Ok(v) = s[..len - 1].parse::<u64>() {
                return v * 1000;
            }
        } else if s.ends_with("m") {
            if let Ok(v) = s[..len - 1].parse::<u64>() {
                return v * 60 * 1000;
            }
        } else {
            // Assume seconds if no suffix? Or ms? Go assumes ns usually?
            // Go ParseDuration: "missing unit in duration" is error.
            // If we assume the config comes from Go Duration.String(), it ALWAYS has unit.
            if let Ok(v) = s.parse::<u64>() {
                return v * 1000; // Default to seconds if just number?
            }
        }
        0
    }
}
