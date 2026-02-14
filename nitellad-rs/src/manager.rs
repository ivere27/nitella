use std::collections::HashMap;
use std::sync::atomic::{AtomicI32, Ordering};
use std::sync::Arc;
use tokio::sync::RwLock;
use tracing::{error, info};
use uuid::Uuid;

use crate::approval::ApprovalManager; // Added
use crate::db::Database;
use crate::geoip::GeoIPService;
use crate::process_proxy::ProcessProxyListener;
use crate::proto::common::{
    ActionType, ConditionType, FallbackAction, GeoInfo, MockPreset, Operator,
};
use crate::proto::proxy::{
    ActiveConnection, ClientAuthType, Condition, CreateProxyRequest, GlobalRule, HealthStatus,
    ProxyStatus, Rule, UpdateProxyRequest,
};
use crate::proxy::{EmbeddedListener, ProxyListener};
use crate::rules::RuleEngine;
use crate::stats::StatsService;

pub struct ManagedProxy {
    pub listener: Arc<ProxyListener>,
    pub rule_engine: Arc<RwLock<RuleEngine>>,
    abort_handle: tokio::task::AbortHandle,
    pub config: CreateProxyRequest,
    pub enabled: bool,
    start_time: std::time::Instant,
    pub health_status: Arc<AtomicI32>,
}

pub struct ProxyManager {
    pub proxies: RwLock<HashMap<String, ManagedProxy>>,
    geoip: Arc<GeoIPService>,
    global_rules: Arc<RwLock<RuleEngine>>,
    global_rule_expirations: Arc<RwLock<HashMap<String, std::time::SystemTime>>>,
    stats: Arc<StatsService>,
    db: Option<Database>,
    process_mode: bool,
    pub approval_manager: Arc<ApprovalManager>, // Added public for Admin access
}

impl ProxyManager {
    pub fn new(
        geoip: Arc<GeoIPService>,
        global_rules: Arc<RwLock<RuleEngine>>,
        stats: Arc<StatsService>,
        db: Option<Database>,
        process_mode: bool,
        approval_manager: Arc<ApprovalManager>, // Added arg
    ) -> Self {
        let manager = Self {
            proxies: RwLock::new(HashMap::new()),
            geoip,
            global_rules,
            global_rule_expirations: Arc::new(RwLock::new(HashMap::new())),
            stats,
            db,
            process_mode,
            approval_manager,
        };

        // Spawn cleanup task for global rules
        let rules = manager.global_rules.clone();
        let expirations = manager.global_rule_expirations.clone();

        tokio::spawn(async move {
            let mut interval = tokio::time::interval(std::time::Duration::from_secs(60));
            loop {
                interval.tick().await;
                let now = std::time::SystemTime::now();
                let mut rules_msg = String::new();

                let mut expired_ids = Vec::new();
                {
                    let lock = expirations.read().await;
                    for (id, exp) in lock.iter() {
                        if *exp < now {
                            expired_ids.push(id.clone());
                        }
                    }
                }

                if !expired_ids.is_empty() {
                    let mut lock = rules.write().await;
                    let mut current = lock.get_rules();
                    let before_count = current.len();
                    current.retain(|r| !expired_ids.contains(&r.id));

                    if current.len() < before_count {
                        lock.update_rules(current);

                        // Cleanup expirations map
                        let mut exp_lock = expirations.write().await;
                        for id in expired_ids {
                            exp_lock.remove(&id);
                            rules_msg.push_str(&format!("{}, ", id));
                        }
                        info!("Cleaned up expired global rules: {}", rules_msg);
                    }
                }
            }
        });

        manager
    }

    pub async fn load_state(&self) -> anyhow::Result<()> {
        if let Some(db) = &self.db {
            let proxies = db.load_proxies().await?;
            for (id, req) in proxies {
                info!("Restoring proxy {} ({})", req.name, id);
                if let Err(e) = self.start_proxy_instance(id.clone(), req, None).await {
                    error!("Failed to restore proxy: {}", e);
                    continue;
                }
                match db.load_rules(&id).await {
                    Ok(rules) => {
                        if !rules.is_empty() {
                            info!("Loaded {} rules for proxy {}", rules.len(), id);
                            if let Err(e) = self.reload_rules(&id, rules).await {
                                error!("Failed to reload rules for {}: {}", id, e);
                            }
                        }
                    }
                    Err(e) => error!("Failed to load rules for proxy {}: {}", id, e),
                }
            }

            // Load Global Rules
            if let Ok(rules) = db.load_rules("GLOBAL").await {
                info!("Loaded {} global rules", rules.len());
                let mut engine = self.global_rules.write().await;
                engine.update_rules(rules);
            }
        }
        Ok(())
    }

    pub async fn create_proxy(&self, mut req: CreateProxyRequest) -> anyhow::Result<String> {
        // Auto-set DefaultAction to MOCK if DefaultMock is specified but action is unspecified
        if req.default_action == ActionType::Unspecified as i32
            && req.default_mock != MockPreset::Unspecified as i32
        {
            req.default_action = ActionType::Mock as i32;
        }

        let id = if req.listen_addr.is_empty() {
            Uuid::new_v4().to_string()
        } else {
            Uuid::new_v4().to_string()
        };

        self.start_proxy_instance(id.clone(), req.clone(), None)
            .await?;

        if let Some(db) = &self.db {
            if let Err(e) = db.save_proxy(&id, &req).await {
                error!("Failed to persist proxy: {}", e);
            }
        }

        Ok(id)
    }

    async fn start_proxy_instance(
        &self,
        id: String,
        req: CreateProxyRequest,
        existing_rules: Option<Vec<Rule>>,
    ) -> anyhow::Result<()> {
        let local_rules = Arc::new(RwLock::new(RuleEngine::new(
            existing_rules.unwrap_or_default(),
        )));
        let health_status = Arc::new(AtomicI32::new(HealthStatus::Unknown as i32));
        let listener_arc: Arc<ProxyListener>;
        let abort_handle;

        if self.process_mode {
            let pl = ProcessProxyListener::new(id.clone());
            pl.start(&req).await?;
            listener_arc = Arc::new(ProxyListener::Process(pl));
            let handle = tokio::spawn(async move {
                std::future::pending::<()>().await;
            });
            abort_handle = handle.abort_handle();
        } else {
            let mut listener = EmbeddedListener::new(
                id.clone(),
                req.name.clone(),
                req.listen_addr.clone(),
                req.default_backend.clone(),
                self.geoip.clone(),
                local_rules.clone(),
                self.global_rules.clone(),
                self.stats.clone(),
                self.approval_manager.clone(),
                health_status.clone(),
                req.default_action,
                req.default_mock,
                req.fallback_action,
                req.fallback_mock,
            );

            if !req.cert_pem.is_empty() {
                let auth_type = ClientAuthType::try_from(req.client_auth_type)
                    .unwrap_or(ClientAuthType::ClientAuthNone);
                listener =
                    listener.with_tls(&req.cert_pem, &req.key_pem, &req.ca_pem, auth_type)?;
            }

            let l_wrapper = Arc::new(listener);

            // Bind synchronously to catch errors early
            let tcp_listener = l_wrapper.bind().await?;

            listener_arc = Arc::new(ProxyListener::Embedded(l_wrapper.clone()));

            let id_clone = id.clone();
            let handle = tokio::spawn(async move {
                if let Err(e) = l_wrapper.run_with_listener(tcp_listener).await {
                    error!("Proxy {} failed: {}", id_clone, e);
                }
            });
            abort_handle = handle.abort_handle();
        }

        let managed = ManagedProxy {
            listener: listener_arc,
            rule_engine: local_rules,
            abort_handle,
            config: req,
            enabled: true,
            start_time: std::time::Instant::now(),
            health_status: health_status.clone(),
        };

        let mut lock = self.proxies.write().await;
        lock.insert(id, managed);

        Ok(())
    }

    async fn remove_proxy_from_memory(&self, id: &str) -> bool {
        let mut lock = self.proxies.write().await;
        if let Some(managed) = lock.remove(id) {
            managed.abort_handle.abort();
            if let ProxyListener::Process(p) = &*managed.listener {
                let _ = p.stop().await;
            }
            true
        } else {
            false
        }
    }

    pub async fn delete_proxy(&self, id: &str) -> anyhow::Result<()> {
        if self.remove_proxy_from_memory(id).await {
            info!("Deleted proxy {}", id);
            if let Some(db) = &self.db {
                let _ = db.delete_proxy(id).await;
            }
            Ok(())
        } else {
            Err(anyhow::anyhow!("Proxy not found"))
        }
    }

    pub async fn disable_proxy(&self, id: &str) -> anyhow::Result<()> {
        let mut lock = self.proxies.write().await;
        if let Some(managed) = lock.get_mut(id) {
            if !managed.enabled {
                return Ok(());
            }
            managed.abort_handle.abort();
            if let ProxyListener::Process(p) = &*managed.listener {
                let _ = p.stop().await;
            }

            managed.enabled = false;
            info!("Disabled proxy {}", id);
            Ok(())
        } else {
            Err(anyhow::anyhow!("Proxy not found"))
        }
    }

    pub async fn enable_proxy(&self, id: &str) -> anyhow::Result<()> {
        let config_clone;
        {
            let lock = self.proxies.read().await;
            if let Some(managed) = lock.get(id) {
                if managed.enabled {
                    return Ok(());
                }
                config_clone = managed.config.clone();
            } else {
                return Err(anyhow::anyhow!("Proxy not found"));
            }
        }

        self.start_proxy_instance(id.to_string(), config_clone, None)
            .await?;
        info!("Enabled proxy {}", id);
        Ok(())
    }

    pub async fn list_proxies(&self) -> Vec<ProxyStatus> {
        let lock = self.proxies.read().await;
        let mut results = Vec::new();
        for (id, p) in lock.iter() {
            results.push(self.get_proxy_status_internal(id, p).await);
        }
        results
    }

    pub async fn get_proxy_status(&self, id: &str) -> Option<ProxyStatus> {
        let lock = self.proxies.read().await;
        if let Some(p) = lock.get(id) {
            Some(self.get_proxy_status_internal(id, p).await)
        } else {
            None
        }
    }

    async fn get_proxy_status_internal(&self, id: &str, p: &ManagedProxy) -> ProxyStatus {
        match &*p.listener {
            ProxyListener::Process(pl) => pl.get_status().await,
            ProxyListener::Embedded(_) => {
                let (active, total, b_in, b_out) = self.stats.get_summary(Some(id));
                let health = p.health_status.load(Ordering::Relaxed);

                ProxyStatus {
                    proxy_id: id.to_string(),
                    running: p.enabled,
                    listen_addr: p.config.listen_addr.clone(),
                    default_backend: p.config.default_backend.clone(),
                    uptime_seconds: p.start_time.elapsed().as_secs() as i64,
                    active_connections: active,
                    total_connections: total,
                    bytes_in: b_in,
                    bytes_out: b_out,
                    default_action: p.config.default_action,
                    default_mock: p.config.default_mock,
                    fallback_action: p.config.fallback_action,
                    fallback_mock: p.config.fallback_mock,
                    health_status: health,
                    health_check: p.config.health_check.clone(),
                    ..Default::default()
                }
            }
        }
    }

    pub async fn add_rule(&self, proxy_id: &str, rule: Rule) -> anyhow::Result<()> {
        {
            let lock = self.proxies.read().await;
            if let Some(managed) = lock.get(proxy_id) {
                if let ProxyListener::Process(p) = &*managed.listener {
                    p.add_rule(rule.clone()).await?;
                }

                let mut engine = managed.rule_engine.write().await;
                let mut current_rules = engine.get_rules();
                current_rules.retain(|r| r.id != rule.id);
                current_rules.push(rule.clone());
                engine.update_rules(current_rules);
            } else {
                return Err(anyhow::anyhow!("Proxy not found"));
            }
        }

        if let Some(db) = &self.db {
            db.save_rule(proxy_id, &rule).await?;
        }

        Ok(())
    }

    pub async fn update_proxy(&self, req: UpdateProxyRequest) -> anyhow::Result<()> {
        let rules_to_keep: Option<Vec<Rule>>;
        let mut new_config: CreateProxyRequest;

        {
            let lock = self.proxies.read().await;
            if let Some(managed) = lock.get(&req.proxy_id) {
                let engine = managed.rule_engine.read().await;
                rules_to_keep = Some(engine.get_rules());
                new_config = managed.config.clone();
            } else {
                return Err(anyhow::anyhow!("Proxy not found"));
            }
        }

        if !self.remove_proxy_from_memory(&req.proxy_id).await {
            return Err(anyhow::anyhow!("Proxy not found during removal"));
        }

        if !req.listen_addr.is_empty() {
            new_config.listen_addr = req.listen_addr;
        }
        if !req.default_backend.is_empty() {
            new_config.default_backend = req.default_backend;
        }
        if !req.name.is_empty() {
            new_config.name = req.name;
        }
        if !req.cert_pem.is_empty() {
            new_config.cert_pem = req.cert_pem;
        }
        if !req.key_pem.is_empty() {
            new_config.key_pem = req.key_pem;
        }
        if !req.ca_pem.is_empty() {
            new_config.ca_pem = req.ca_pem;
        }
        if req.default_action != ActionType::Unspecified as i32 {
            new_config.default_action = req.default_action;
        }
        if req.default_mock != MockPreset::Unspecified as i32 {
            new_config.default_mock = req.default_mock;
        }
        if req.fallback_action != FallbackAction::Unspecified as i32 {
            new_config.fallback_action = req.fallback_action;
        }
        if req.fallback_mock != MockPreset::Unspecified as i32 {
            new_config.fallback_mock = req.fallback_mock;
        }
        if req.client_auth_type != ClientAuthType::ClientAuthAuto as i32 {
            new_config.client_auth_type = req.client_auth_type;
        }

        // Auto-set DefaultAction to MOCK if we have a preset but action is unspecified/allow
        // This handles cases where update sets mock preset but forgets action
        if new_config.default_mock != MockPreset::Unspecified as i32
            && (new_config.default_action == ActionType::Unspecified as i32
                || new_config.default_action == ActionType::Allow as i32)
        {
            // If the PREVIOUS action was Mock, it's fine. If it was Allow, we should probably upgrade it?
            // Actually, CreateProxy logic handles this for new proxies.
            // Here we are patching existing config.
        }

        self.start_proxy_instance(req.proxy_id.clone(), new_config.clone(), rules_to_keep)
            .await?;

        if let Some(db) = &self.db {
            if let Err(e) = db.save_proxy(&req.proxy_id, &new_config).await {
                error!("Failed to persist updated proxy: {}", e);
            }
        }

        Ok(())
    }

    pub async fn restart_listeners(&self) -> i32 {
        let statuses = self.list_proxies().await;
        let mut count = 0;
        for s in statuses {
            if let Some(_) = self.proxies.write().await.remove(&s.proxy_id) {
                // Wait a bit to ensure port release?
                // In EmbeddedListener, the TcpListener drop should close the socket.
                // However, tokio tasks might still be running.
            }

            // Re-create using disable/enable logic but ensuring full stop
            if let Err(e) = self.disable_proxy(&s.proxy_id).await {
                error!("Failed to disable proxy {}: {}", s.proxy_id, e);
                continue;
            }

            // Sleep briefly to allow OS to release port
            tokio::time::sleep(std::time::Duration::from_millis(100)).await;

            if let Err(e) = self.enable_proxy(&s.proxy_id).await {
                error!("Failed to enable proxy {}: {}", s.proxy_id, e);
            } else {
                count += 1;
            }
        }
        count
    }

    pub async fn resolve_approval(&self, req_id: &str, action: i32) -> bool {
        // action: 1 = ALLOW, 2 = BLOCK.
        let allow = action == 1;
        // Default duration for internal resolution (e.g. from Process)
        self.approval_manager.resolve(req_id, allow, 0).await
    }

    // Global Rules

    pub async fn list_global_rules(&self) -> Vec<GlobalRule> {
        let engine = self.global_rules.read().await;
        let rules = engine.get_rules();
        let expirations = self.global_rule_expirations.read().await;

        rules
            .into_iter()
            .map(|r| {
                // Reconstruct GlobalRule from Rule
                // source_ip is in conditions
                let source_ip = r
                    .conditions
                    .iter()
                    .find(|c| c.r#type == ConditionType::SourceIp as i32)
                    .map(|c| c.value.clone())
                    .unwrap_or_default();

                let expires_at = expirations.get(&r.id).map(|t| {
                    let d = t.duration_since(std::time::UNIX_EPOCH).unwrap_or_default();
                    prost_types::Timestamp {
                        seconds: d.as_secs() as i64,
                        nanos: 0,
                    }
                });

                GlobalRule {
                    id: r.id,
                    name: r.name,
                    source_ip,
                    action: r.action,
                    expires_at,
                    created_at: None, // We don't track creation time in Rule struct
                }
            })
            .collect()
    }

    pub async fn add_global_rule(&self, rule: GlobalRule) -> anyhow::Result<()> {
        let condition = Condition {
            r#type: ConditionType::SourceIp as i32,
            op: Operator::Eq as i32,
            value: rule.source_ip.clone(),
            negate: false,
        };

        let r = Rule {
            id: rule.id.clone(),
            name: rule.name.clone(),
            priority: 1000,
            enabled: true,
            conditions: vec![condition],
            action: rule.action,
            target_backend: "".to_string(),
            rate_limit: None,
            mock_response: None,
            expression: "".to_string(),
        };

        {
            let mut engine = self.global_rules.write().await;
            let mut current = engine.get_rules();
            current.retain(|x| x.id != rule.id);
            current.push(r.clone());
            engine.update_rules(current);
        }

        if let Some(ts) = rule.expires_at {
            if ts.seconds > 0 {
                let exp_time =
                    std::time::UNIX_EPOCH + std::time::Duration::from_secs(ts.seconds as u64);
                let mut lock = self.global_rule_expirations.write().await;
                lock.insert(rule.id.clone(), exp_time);

                // Temporary rule: do not persist
                return Ok(());
            }
        }

        // Permanent rule: persist
        if let Some(db) = &self.db {
            if let Err(e) = db.save_rule("GLOBAL", &r).await {
                error!("Failed to save global rule: {}", e);
            }
        }

        Ok(())
    }

    pub async fn remove_global_rule(&self, rule_id: &str) -> anyhow::Result<()> {
        {
            let mut engine = self.global_rules.write().await;
            let mut current = engine.get_rules();
            current.retain(|r| r.id != rule_id);
            engine.update_rules(current);
        }
        {
            let mut lock = self.global_rule_expirations.write().await;
            lock.remove(rule_id);
        }

        if let Some(db) = &self.db {
            let _ = db.delete_rule(rule_id).await;
        }

        Ok(())
    }

    pub async fn block_ip(&self, ip: String, duration_seconds: i64) -> anyhow::Result<()> {
        let id = format!("block-{}", ip);
        let expires_at = if duration_seconds > 0 {
            Some(prost_types::Timestamp {
                seconds: std::time::SystemTime::now()
                    .duration_since(std::time::UNIX_EPOCH)
                    .unwrap_or_default()
                    .as_secs() as i64
                    + duration_seconds,
                nanos: 0,
            })
        } else {
            None
        };

        let rule = GlobalRule {
            id,
            name: format!("Block IP {}", ip),
            source_ip: ip,
            action: ActionType::Block as i32,
            expires_at,
            created_at: Some(prost_types::Timestamp::from(std::time::SystemTime::now())),
        };
        self.add_global_rule(rule).await
    }

    pub async fn allow_ip(&self, ip: String, duration_seconds: i64) -> anyhow::Result<()> {
        let id = format!("allow-{}", ip);
        let expires_at = if duration_seconds > 0 {
            Some(prost_types::Timestamp {
                seconds: std::time::SystemTime::now()
                    .duration_since(std::time::UNIX_EPOCH)
                    .unwrap_or_default()
                    .as_secs() as i64
                    + duration_seconds,
                nanos: 0,
            })
        } else {
            None
        };

        let rule = GlobalRule {
            id,
            name: format!("Allow IP {}", ip),
            source_ip: ip,
            action: ActionType::Allow as i32,
            expires_at,
            created_at: Some(prost_types::Timestamp::from(std::time::SystemTime::now())),
        };
        self.add_global_rule(rule).await
    }

    pub async fn remove_rule(&self, proxy_id: &str, rule_id: &str) -> anyhow::Result<()> {
        {
            let lock = self.proxies.read().await;
            if let Some(managed) = lock.get(proxy_id) {
                if let ProxyListener::Process(p) = &*managed.listener {
                    p.remove_rule(rule_id.to_string()).await?;
                }

                let mut engine = managed.rule_engine.write().await;
                let mut current_rules = engine.get_rules();
                current_rules.retain(|r| r.id != rule_id);
                engine.update_rules(current_rules);
            } else {
                return Err(anyhow::anyhow!("Proxy not found"));
            }
        }

        if let Some(db) = &self.db {
            db.delete_rule(rule_id).await?;
        }

        Ok(())
    }

    pub async fn reload_rules(&self, proxy_id: &str, rules: Vec<Rule>) -> anyhow::Result<i32> {
        let count = rules.len() as i32;
        {
            let lock = self.proxies.read().await;
            if let Some(managed) = lock.get(proxy_id) {
                if let ProxyListener::Process(p) = &*managed.listener {
                    for r in &rules {
                        let _ = p.add_rule(r.clone()).await;
                    }
                }

                let mut engine = managed.rule_engine.write().await;
                engine.update_rules(rules.clone());
            } else {
                return Err(anyhow::anyhow!("Proxy not found"));
            }
        }

        if let Some(db) = &self.db {
            if let Ok(old_rules) = db.load_rules(proxy_id).await {
                for r in old_rules {
                    let _ = db.delete_rule(&r.id).await;
                }
            }
            for r in rules {
                let _ = db.save_rule(proxy_id, &r).await;
            }
        }

        Ok(count)
    }

    pub async fn get_active_connections(&self, proxy_id: Option<String>) -> Vec<ActiveConnection> {
        let mut conns = Vec::new();
        let lock = self.proxies.read().await;

        if let Some(pid) = proxy_id {
            if let Some(managed) = lock.get(&pid) {
                if let Ok(mut c) = managed.listener.get_active_connections().await {
                    conns.append(&mut c);
                }
            }
        } else {
            for managed in lock.values() {
                if let Ok(mut c) = managed.listener.get_active_connections().await {
                    conns.append(&mut c);
                }
            }
        }
        conns
    }

    pub async fn close_connection(&self, proxy_id: &str, conn_id: &str) -> anyhow::Result<()> {
        let lock = self.proxies.read().await;
        if proxy_id.is_empty() {
            // Search all proxies for the connection
            for managed in lock.values() {
                if managed
                    .listener
                    .close_connection(conn_id.to_string())
                    .await
                    .is_ok()
                {
                    return Ok(());
                }
            }
            Err(anyhow::anyhow!("Connection not found in any proxy"))
        } else if let Some(managed) = lock.get(proxy_id) {
            managed
                .listener
                .close_connection(conn_id.to_string())
                .await?;
            Ok(())
        } else {
            Err(anyhow::anyhow!("Proxy not found"))
        }
    }

    pub async fn close_all_connections(&self, proxy_id: &str) -> anyhow::Result<()> {
        let lock = self.proxies.read().await;
        if proxy_id.is_empty() {
            // Close connections on all proxies
            for managed in lock.values() {
                let _ = managed.listener.close_all_connections().await;
            }
            Ok(())
        } else if let Some(managed) = lock.get(proxy_id) {
            managed.listener.close_all_connections().await?;
            Ok(())
        } else {
            Err(anyhow::anyhow!("Proxy not found"))
        }
    }

    // --- GeoIP Management ---

    pub async fn configure_geoip(
        &self,
        city_db: Option<String>,
        isp_db: Option<String>,
        remote_url: Option<String>,
        strategy: Option<String>,
    ) -> anyhow::Result<()> {
        if let Some(url) = remote_url {
            self.geoip.set_remote_url(url).await;
        }

        if let Some(s) = strategy {
            let parts: Vec<String> = s
                .split(',')
                .map(|s| s.trim().to_string())
                .filter(|s| !s.is_empty())
                .collect();
            if !parts.is_empty() {
                self.geoip.set_strategy(parts).await;
            }
        }

        if city_db.is_some() || isp_db.is_some() {
            self.geoip.reload_local_db(city_db, isp_db).await?;
        }

        Ok(())
    }

    pub async fn get_geoip_status(&self) -> crate::geoip::GeoIpStatusStruct {
        self.geoip.get_status_struct().await
    }

    pub async fn lookup_ip(&self, ip: &str) -> GeoInfo {
        self.geoip.lookup(ip).await
    }

    // --- Approval Management ---

    pub async fn cancel_approval(&self, key: &str) -> bool {
        self.approval_manager.cancel_approval(key).await
    }
}
