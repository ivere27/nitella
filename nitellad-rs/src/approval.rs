use chrono::Utc;
use std::collections::HashMap;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::{oneshot, Mutex, RwLock};
use tracing::info;

use crate::proto::common::ApprovalRetentionMode;

// DoS protection defaults (matching Go's pkg/config/defaults.go)
const DEFAULT_MAX_PENDING: usize = 1000;
const DEFAULT_MAX_PENDING_PER_IP: usize = 10;
const DEFAULT_MAX_PENDING_PER_PROXY: usize = 200;
const MAX_CONN_IDS_PER_APPROVAL: usize = 1000;

#[derive(Clone, Debug)]
pub struct ApprovalReqData {
    pub id: String,
    pub proxy_id: String,
    pub source_ip: String,
    pub rule_id: String,
    pub info: String,
    pub created_at: i64,
}

/// Result of an approval request
#[derive(Clone, Debug)]
pub struct ApprovalResult {
    pub allowed: bool,
    pub retention_mode: i32,
    pub duration_seconds: i64,
}

struct PendingEntry {
    data: ApprovalReqData,
    tx: oneshot::Sender<ApprovalResult>,
}

/// Live byte counter pointers for an active connection.
/// Points to AtomicU64 counters owned by the connection's ActiveConnEntry.
pub struct LiveConnStats {
    pub bytes_in: Arc<AtomicU64>,
    pub bytes_out: Arc<AtomicU64>,
}

#[derive(Clone, Debug)]
pub struct ApprovalCacheEntry {
    pub key: String,
    pub source_ip: String,
    pub rule_id: String,
    pub proxy_id: String,
    pub allowed: bool,
    pub expires_at: i64,
    pub created_at: i64,

    // GeoIP info for display
    pub geo_country: String,
    pub geo_city: String,
    pub geo_isp: String,

    // Accumulated bytes from closed connections
    pub bytes_in: i64,
    pub bytes_out: i64,
    pub blocked_count: i64,
}

/// Internal cache entry that holds both cloneable data and live connection tracking
struct CacheEntryInternal {
    data: ApprovalCacheEntry,
    /// Live connections with atomic byte counter pointers
    live_conns: HashMap<String, LiveConnStats>,
}

pub struct ApprovalManager {
    pending: Arc<Mutex<PendingState>>,
    cache: Arc<RwLock<HashMap<String, CacheEntryInternal>>>,
}

struct PendingState {
    requests: HashMap<String, PendingEntry>,
    by_ip: HashMap<String, usize>,
    by_proxy: HashMap<String, usize>,
}

impl ApprovalManager {
    pub fn new() -> Self {
        let mgr = Self {
            pending: Arc::new(Mutex::new(PendingState {
                requests: HashMap::new(),
                by_ip: HashMap::new(),
                by_proxy: HashMap::new(),
            })),
            cache: Arc::new(RwLock::new(HashMap::new())),
        };
        // Start cleanup loop (matches Go's ApprovalCacheCleanupInterval = 10s)
        let cache = mgr.cache.clone();
        tokio::spawn(async move {
            loop {
                tokio::time::sleep(Duration::from_secs(10)).await;
                let now = Utc::now().timestamp();
                let mut lock = cache.write().await;
                let before = lock.len();
                lock.retain(|_, entry| now < entry.data.expires_at);
                let removed = before - lock.len();
                if removed > 0 {
                    info!("[Approval] Cleaned up {} expired cache entries", removed);
                }
            }
        });
        mgr
    }

    fn build_key(source_ip: &str, rule_id: &str) -> String {
        format!("{}\0{}", source_ip, rule_id)
    }

    /// Check if there's a cached approval decision for this source_ip + rule_id.
    /// Returns Some(result) on cache hit, None on miss.
    pub async fn check_cache(&self, source_ip: &str, rule_id: &str) -> Option<ApprovalResult> {
        let key = Self::build_key(source_ip, rule_id);
        let cache = self.cache.read().await;
        if let Some(entry) = cache.get(&key) {
            let now = Utc::now().timestamp();
            if now < entry.data.expires_at {
                return Some(ApprovalResult {
                    allowed: entry.data.allowed,
                    retention_mode: ApprovalRetentionMode::Cache as i32,
                    duration_seconds: entry.data.expires_at - now,
                });
            }
        }
        None
    }

    /// Request approval with DoS protection.
    /// Returns Err if rate limits are exceeded.
    pub async fn request_approval(&self, data: ApprovalReqData) -> Result<ApprovalResult, String> {
        let (tx, rx) = oneshot::channel();
        {
            let mut state = self.pending.lock().await;

            // DoS protection: global limit
            if state.requests.len() >= DEFAULT_MAX_PENDING {
                return Err(format!(
                    "too many pending approval requests (max: {})",
                    DEFAULT_MAX_PENDING
                ));
            }
            // DoS protection: per-IP limit
            let ip_count = state.by_ip.get(&data.source_ip).copied().unwrap_or(0);
            if ip_count >= DEFAULT_MAX_PENDING_PER_IP {
                return Err(format!(
                    "too many pending approval requests from IP {} (max: {})",
                    data.source_ip, DEFAULT_MAX_PENDING_PER_IP
                ));
            }
            // DoS protection: per-proxy limit
            if !data.proxy_id.is_empty() {
                let proxy_count = state.by_proxy.get(&data.proxy_id).copied().unwrap_or(0);
                if proxy_count >= DEFAULT_MAX_PENDING_PER_PROXY {
                    return Err(format!(
                        "too many pending approval requests for proxy {} (max: {})",
                        data.proxy_id, DEFAULT_MAX_PENDING_PER_PROXY
                    ));
                }
                *state.by_proxy.entry(data.proxy_id.clone()).or_insert(0) += 1;
            }

            *state.by_ip.entry(data.source_ip.clone()).or_insert(0) += 1;
            state.requests.insert(
                data.id.clone(),
                PendingEntry {
                    data: data.clone(),
                    tx,
                },
            );
        }

        // Wait for approval with timeout (2 minutes, matching Go's ApprovalRequestTimeout)
        let timeout = tokio::time::sleep(Duration::from_secs(120));

        let result = tokio::select! {
            res = rx => res.unwrap_or(ApprovalResult {
                allowed: false,
                retention_mode: ApprovalRetentionMode::Unspecified as i32,
                duration_seconds: 0,
            }),
            _ = timeout => {
                ApprovalResult {
                    allowed: false,
                    retention_mode: ApprovalRetentionMode::Unspecified as i32,
                    duration_seconds: 0,
                }
            }
        };

        // Always clean up pending state (matches Go's CancelApprovalRequest)
        self.cancel_pending(&data.id).await;

        Ok(result)
    }

    /// Clean up a pending request and decrement counters
    async fn cancel_pending(&self, id: &str) {
        let mut state = self.pending.lock().await;
        if let Some(entry) = state.requests.remove(id) {
            // Decrement per-IP counter
            if let Some(count) = state.by_ip.get_mut(&entry.data.source_ip) {
                *count = count.saturating_sub(1);
                if *count == 0 {
                    state.by_ip.remove(&entry.data.source_ip);
                }
            }
            // Decrement per-proxy counter
            if !entry.data.proxy_id.is_empty() {
                if let Some(count) = state.by_proxy.get_mut(&entry.data.proxy_id) {
                    *count = count.saturating_sub(1);
                    if *count == 0 {
                        state.by_proxy.remove(&entry.data.proxy_id);
                    }
                }
            }
        }
    }

    pub async fn resolve(&self, id: &str, allowed: bool, duration_seconds: i64) -> bool {
        self.resolve_with_retention(
            id,
            allowed,
            duration_seconds,
            ApprovalRetentionMode::Cache as i32,
        )
        .await
    }

    pub async fn resolve_with_retention(
        &self,
        id: &str,
        allowed: bool,
        duration_seconds: i64,
        retention_mode: i32,
    ) -> bool {
        // Resolve pending
        let mut state = self.pending.lock().await;
        if let Some(entry) = state.requests.remove(id) {
            // Decrement counters
            if let Some(count) = state.by_ip.get_mut(&entry.data.source_ip) {
                *count = count.saturating_sub(1);
                if *count == 0 {
                    state.by_ip.remove(&entry.data.source_ip);
                }
            }
            if !entry.data.proxy_id.is_empty() {
                if let Some(count) = state.by_proxy.get_mut(&entry.data.proxy_id) {
                    *count = count.saturating_sub(1);
                    if *count == 0 {
                        state.by_proxy.remove(&entry.data.proxy_id);
                    }
                }
            }
            drop(state); // Release lock before sending

            let mode = ApprovalRetentionMode::try_from(retention_mode)
                .unwrap_or(ApprovalRetentionMode::Cache);
            let mode = if mode == ApprovalRetentionMode::Unspecified {
                ApprovalRetentionMode::Cache
            } else {
                mode
            };

            let _ = entry.tx.send(ApprovalResult {
                allowed,
                retention_mode: mode as i32,
                duration_seconds,
            });

            // CACHE mode stores follow-up decisions in cache.
            if mode == ApprovalRetentionMode::Cache {
                let key = Self::build_key(&entry.data.source_ip, &entry.data.rule_id);
                let duration = if duration_seconds > 0 {
                    duration_seconds
                } else {
                    300
                }; // Default 5m

                let cache_entry = ApprovalCacheEntry {
                    key: key.clone(),
                    source_ip: entry.data.source_ip,
                    rule_id: entry.data.rule_id,
                    proxy_id: entry.data.proxy_id,
                    allowed,
                    created_at: Utc::now().timestamp(),
                    expires_at: Utc::now().timestamp() + duration,
                    geo_country: String::new(),
                    geo_city: String::new(),
                    geo_isp: String::new(),
                    bytes_in: 0,
                    bytes_out: 0,
                    blocked_count: 0,
                };
                let mut cache_lock = self.cache.write().await;
                cache_lock.insert(
                    key,
                    CacheEntryInternal {
                        data: cache_entry,
                        live_conns: HashMap::new(),
                    },
                );
            }

            true
        } else {
            false
        }
    }

    /// Add a decision to the cache with GeoIP info
    pub async fn add_to_cache_with_geo(
        &self,
        source_ip: &str,
        rule_id: &str,
        proxy_id: &str,
        allowed: bool,
        duration_seconds: i64,
        geo_country: &str,
        geo_city: &str,
        geo_isp: &str,
    ) {
        let key = Self::build_key(source_ip, rule_id);
        let duration = if duration_seconds > 0 {
            duration_seconds
        } else {
            300
        };
        let cache_entry = ApprovalCacheEntry {
            key: key.clone(),
            source_ip: source_ip.to_string(),
            rule_id: rule_id.to_string(),
            proxy_id: proxy_id.to_string(),
            allowed,
            created_at: Utc::now().timestamp(),
            expires_at: Utc::now().timestamp() + duration,
            geo_country: geo_country.to_string(),
            geo_city: geo_city.to_string(),
            geo_isp: geo_isp.to_string(),
            bytes_in: 0,
            bytes_out: 0,
            blocked_count: 0,
        };
        let mut cache_lock = self.cache.write().await;
        cache_lock.insert(
            key,
            CacheEntryInternal {
                data: cache_entry,
                live_conns: HashMap::new(),
            },
        );
    }

    /// Register a live connection with atomic byte counter references.
    /// Returns false if the cap is reached (MAX_CONN_IDS_PER_APPROVAL).
    pub async fn set_conn_id(
        &self,
        source_ip: &str,
        rule_id: &str,
        conn_id: &str,
        bytes_in: Arc<AtomicU64>,
        bytes_out: Arc<AtomicU64>,
    ) -> bool {
        let key = Self::build_key(source_ip, rule_id);
        let mut cache = self.cache.write().await;
        if let Some(entry) = cache.get_mut(&key) {
            if entry.live_conns.len() >= MAX_CONN_IDS_PER_APPROVAL {
                return false;
            }
            entry.live_conns.insert(
                conn_id.to_string(),
                LiveConnStats {
                    bytes_in,
                    bytes_out,
                },
            );
            true
        } else {
            false
        }
    }

    /// Remove a connection from tracking when it closes.
    /// Accumulates final byte counts into the cache entry.
    pub async fn remove_conn_id(&self, source_ip: &str, rule_id: &str, conn_id: &str) {
        let key = Self::build_key(source_ip, rule_id);
        let mut cache = self.cache.write().await;
        if let Some(entry) = cache.get_mut(&key) {
            if let Some(stats) = entry.live_conns.remove(conn_id) {
                // Accumulate final bytes from this connection
                entry.data.bytes_in += stats.bytes_in.load(Ordering::Relaxed) as i64;
                entry.data.bytes_out += stats.bytes_out.load(Ordering::Relaxed) as i64;
            }
        }
    }

    /// Increment the blocked attempt counter
    pub async fn increment_blocked_count(&self, source_ip: &str, rule_id: &str) {
        let key = Self::build_key(source_ip, rule_id);
        let mut cache = self.cache.write().await;
        if let Some(entry) = cache.get_mut(&key) {
            entry.data.blocked_count += 1;
        }
    }

    /// Get all active approvals with computed live byte stats.
    /// Includes accumulated bytes from closed connections plus real-time bytes
    /// from currently active connections.
    pub async fn list_active(&self) -> Vec<ApprovalCacheEntry> {
        let cache = self.cache.read().await;
        let now = Utc::now().timestamp();
        cache
            .values()
            .filter(|e| now < e.data.expires_at)
            .map(|entry| {
                let mut result = entry.data.clone();
                // Add live bytes from active connections
                for stats in entry.live_conns.values() {
                    result.bytes_in += stats.bytes_in.load(Ordering::Relaxed) as i64;
                    result.bytes_out += stats.bytes_out.load(Ordering::Relaxed) as i64;
                }
                result
            })
            .collect()
    }

    pub async fn cancel_approval(&self, key: &str) -> bool {
        let mut cache_lock = self.cache.write().await;
        cache_lock.remove(key).is_some()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::time::Duration;
    use tokio::time::sleep;

    #[tokio::test]
    async fn test_approval_resolve_duration() {
        let manager = Arc::new(ApprovalManager::new());
        let req_id = "test-req-1";

        let data = ApprovalReqData {
            id: req_id.to_string(),
            proxy_id: "p1".to_string(),
            source_ip: "1.2.3.4".to_string(),
            rule_id: "r1".to_string(),
            info: "test info".to_string(),
            created_at: Utc::now().timestamp(),
        };

        let mgr_clone = manager.clone();
        let data_clone = data.clone();
        tokio::spawn(async move {
            let _ = mgr_clone.request_approval(data_clone).await;
        });

        sleep(Duration::from_millis(50)).await;

        let resolved = manager.resolve(req_id, true, 100).await;
        assert!(resolved, "Should resolve successfully");

        let cache = manager.list_active().await;
        assert_eq!(cache.len(), 1);
        let entry = &cache[0];
        assert!(entry.allowed);

        let now = Utc::now().timestamp();
        assert!(entry.expires_at > now + 90);
        assert!(entry.expires_at < now + 110);
    }

    #[tokio::test]
    async fn test_dos_protection_per_ip() {
        let manager = Arc::new(ApprovalManager::new());

        // Flood with requests from one IP
        let mut handles = vec![];
        for i in 0..DEFAULT_MAX_PENDING_PER_IP {
            let mgr = manager.clone();
            handles.push(tokio::spawn(async move {
                let data = ApprovalReqData {
                    id: format!("req-{}", i),
                    proxy_id: "p1".to_string(),
                    source_ip: "10.0.0.1".to_string(),
                    rule_id: "r1".to_string(),
                    info: "test".to_string(),
                    created_at: Utc::now().timestamp(),
                };
                mgr.request_approval(data).await
            }));
        }

        // Give time for all to register
        sleep(Duration::from_millis(100)).await;

        // Next request from same IP should be rejected
        let data = ApprovalReqData {
            id: "req-overflow".to_string(),
            proxy_id: "p1".to_string(),
            source_ip: "10.0.0.1".to_string(),
            rule_id: "r1".to_string(),
            info: "test".to_string(),
            created_at: Utc::now().timestamp(),
        };
        let result = manager.request_approval(data).await;
        assert!(result.is_err(), "Should reject due to per-IP limit");

        // Different IP should still work
        let data2 = ApprovalReqData {
            id: "req-other-ip".to_string(),
            proxy_id: "p1".to_string(),
            source_ip: "10.0.0.2".to_string(),
            rule_id: "r1".to_string(),
            info: "test".to_string(),
            created_at: Utc::now().timestamp(),
        };
        // This spawns a waiting request, so wrap in spawn
        let mgr = manager.clone();
        let h = tokio::spawn(async move { mgr.request_approval(data2).await });
        sleep(Duration::from_millis(50)).await;
        // Resolve it to clean up
        manager.resolve("req-other-ip", false, 0).await;
        let result2 = h.await.unwrap();
        assert!(result2.is_ok(), "Different IP should be accepted");
    }

    #[tokio::test]
    async fn test_live_bytes_tracking() {
        let manager = Arc::new(ApprovalManager::new());

        // Create a cached approval
        manager
            .add_to_cache_with_geo("1.2.3.4", "r1", "p1", true, 300, "US", "NYC", "ISP1")
            .await;

        // Register a live connection with byte counters
        let bytes_in = Arc::new(AtomicU64::new(0));
        let bytes_out = Arc::new(AtomicU64::new(0));
        let set = manager
            .set_conn_id(
                "1.2.3.4",
                "r1",
                "conn-1",
                bytes_in.clone(),
                bytes_out.clone(),
            )
            .await;
        assert!(set);

        // Simulate data transfer
        bytes_in.store(1000, Ordering::Relaxed);
        bytes_out.store(500, Ordering::Relaxed);

        // list_active should show live bytes
        let active = manager.list_active().await;
        assert_eq!(active.len(), 1);
        assert_eq!(active[0].bytes_in, 1000);
        assert_eq!(active[0].bytes_out, 500);

        // Remove connection (simulating close) — bytes get accumulated
        manager.remove_conn_id("1.2.3.4", "r1", "conn-1").await;

        // After removal, accumulated bytes should still show
        let active2 = manager.list_active().await;
        assert_eq!(active2[0].bytes_in, 1000);
        assert_eq!(active2[0].bytes_out, 500);
    }
}
