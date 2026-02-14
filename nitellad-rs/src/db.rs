use crate::proto::common::MockPreset;
use crate::proto::proxy::{Condition, CreateProxyRequest, HealthCheckConfig, MockConfig, Rule};
use anyhow::Result;
use sqlx::{sqlite::SqlitePoolOptions, Pool, Row, Sqlite};
use std::path::Path;
use tokio::fs;

#[derive(Clone)]
pub struct Database {
    pool: Pool<Sqlite>,
}

// Helper for Enum conversion
fn mock_preset_to_string(p: i32) -> String {
    match MockPreset::try_from(p).unwrap_or(MockPreset::Unspecified) {
        MockPreset::SshSecure => "ssh-secure",
        MockPreset::SshTarpit => "ssh-tarpit",
        MockPreset::Http403 => "http-403",
        MockPreset::Http404 => "http-404",
        MockPreset::Http401 => "http-401",
        MockPreset::RedisSecure => "redis-secure",
        MockPreset::MysqlSecure => "mysql-secure",
        MockPreset::MysqlTarpit => "mysql-tarpit",
        MockPreset::RdpSecure => "rdp-secure",
        MockPreset::TelnetSecure => "telnet-secure",
        MockPreset::RawTarpit => "raw-tarpit",
        _ => "",
    }
    .to_string()
}

fn string_to_mock_preset(s: &str) -> MockPreset {
    match s {
        "ssh-secure" => MockPreset::SshSecure,
        "ssh-tarpit" => MockPreset::SshTarpit,
        "http-403" => MockPreset::Http403,
        "http-404" => MockPreset::Http404,
        "http-401" => MockPreset::Http401,
        "redis-secure" => MockPreset::RedisSecure,
        "mysql-secure" => MockPreset::MysqlSecure,
        "mysql-tarpit" => MockPreset::MysqlTarpit,
        "rdp-secure" => MockPreset::RdpSecure,
        "telnet-secure" => MockPreset::TelnetSecure,
        "raw-tarpit" => MockPreset::RawTarpit,
        _ => MockPreset::Unspecified,
    }
}

impl Database {
    pub async fn new(db_path: &str) -> Result<Self> {
        // Ensure directory exists
        if let Some(parent) = Path::new(db_path).parent() {
            fs::create_dir_all(parent).await?;
        }

        // Create file if not exists
        if !Path::new(db_path).exists() {
            fs::File::create(db_path).await?;
        }

        let conn_str = format!("sqlite://{}", db_path);
        let pool = SqlitePoolOptions::new().connect(&conn_str).await?;

        let db = Self { pool };
        db.init().await?;
        Ok(db)
    }

    async fn init(&self) -> Result<()> {
        // Go Schema: proxy_model
        sqlx::query(
            "CREATE TABLE IF NOT EXISTS proxy_model (
                id TEXT PRIMARY KEY,
                name TEXT,
                listen_addr TEXT,
                default_backend TEXT,
                default_action INTEGER DEFAULT 0,
                default_mock TEXT,
                fallback_action INTEGER DEFAULT 0,
                fallback_mock TEXT,
                enabled BOOLEAN DEFAULT 1,
                cert_pem TEXT,
                key_pem TEXT,
                ca_pem TEXT,
                client_auth_type INTEGER DEFAULT 0,
                health_check_json TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
            );",
        )
        .execute(&self.pool)
        .await?;

        // Go Schema: rule_model
        sqlx::query(
            "CREATE TABLE IF NOT EXISTS rule_model (
                id TEXT PRIMARY KEY,
                proxy_id TEXT,
                name TEXT,
                priority INTEGER DEFAULT 0,
                enabled BOOLEAN DEFAULT 1,
                action INTEGER,
                target_backend TEXT,
                conditions_json TEXT,
                mock_config_json TEXT,
                rate_limit_json TEXT,
                expression TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
            );",
        )
        .execute(&self.pool)
        .await?;

        // Create index for rule_model.proxy_id if not exists
        sqlx::query("CREATE INDEX IF NOT EXISTS idx_rule_model_proxy_id ON rule_model (proxy_id)")
            .execute(&self.pool)
            .await?;

        Ok(())
    }

    pub async fn save_proxy(&self, id: &str, req: &CreateProxyRequest) -> Result<()> {
        let default_mock_str = mock_preset_to_string(req.default_mock);
        let fallback_mock_str = mock_preset_to_string(req.fallback_mock);

        // Serialize HealthCheck
        let hc_json = if let Some(hc) = &req.health_check {
            serde_json::to_string(hc).unwrap_or_default()
        } else {
            String::new()
        };

        sqlx::query(
            "INSERT OR REPLACE INTO proxy_model (
                id, name, listen_addr, default_backend, default_action, default_mock, 
                fallback_action, fallback_mock, enabled, cert_pem, key_pem, ca_pem, 
                client_auth_type, health_check_json, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)",
        )
        .bind(id)
        .bind(&req.name)
        .bind(&req.listen_addr)
        .bind(&req.default_backend)
        .bind(req.default_action)
        .bind(default_mock_str)
        .bind(req.fallback_action)
        .bind(fallback_mock_str)
        .bind(&req.cert_pem)
        .bind(&req.key_pem)
        .bind(&req.ca_pem)
        .bind(req.client_auth_type)
        .bind(hc_json)
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    pub async fn delete_proxy(&self, id: &str) -> Result<()> {
        // Go Xorm delete
        sqlx::query("DELETE FROM proxy_model WHERE id = ?")
            .bind(id)
            .execute(&self.pool)
            .await?;
        // Cascade rules
        sqlx::query("DELETE FROM rule_model WHERE proxy_id = ?")
            .bind(id)
            .execute(&self.pool)
            .await?;
        Ok(())
    }

    pub async fn load_proxies(&self) -> Result<Vec<(String, CreateProxyRequest)>> {
        let rows = sqlx::query("SELECT * FROM proxy_model WHERE enabled = 1")
            .fetch_all(&self.pool)
            .await?;

        let mut result = Vec::new();
        for row in rows {
            let id: String = row.get("id");
            let name: String = row.get("name");
            let listen_addr: String = row.get("listen_addr");
            let default_backend: String = row.get("default_backend");
            let default_action: i32 = row.get("default_action");
            let default_mock_str: String = row.get("default_mock");
            let fallback_action: i32 = row.get("fallback_action");
            let fallback_mock_str: String = row.get("fallback_mock");
            let cert_pem: String = row.get("cert_pem");
            let key_pem: String = row.get("key_pem");
            let ca_pem: String = row.get("ca_pem");
            let client_auth_type: i32 = row.get("client_auth_type");
            let hc_json: String = row.get("health_check_json");

            // Deserialize HealthCheck
            let health_check: Option<HealthCheckConfig> = if !hc_json.is_empty() {
                serde_json::from_str(&hc_json).ok()
            } else {
                None
            };

            let req = CreateProxyRequest {
                name,
                listen_addr,
                default_backend,
                default_action,
                default_mock: string_to_mock_preset(&default_mock_str) as i32,
                fallback_action,
                fallback_mock: string_to_mock_preset(&fallback_mock_str) as i32,
                cert_pem,
                key_pem,
                ca_pem,
                client_auth_type,
                health_check,
                ..Default::default()
            };
            result.push((id, req));
        }
        Ok(result)
    }

    pub async fn save_rule(&self, proxy_id: &str, rule: &Rule) -> Result<()> {
        let conds_json = serde_json::to_string(&rule.conditions).unwrap_or_default();
        let mock_json = if let Some(m) = &rule.mock_response {
            serde_json::to_string(m).unwrap_or_default()
        } else {
            String::new()
        };

        sqlx::query(
            "INSERT OR REPLACE INTO rule_model (
                id, proxy_id, name, priority, enabled, action, target_backend, 
                conditions_json, mock_config_json, expression, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)",
        )
        .bind(&rule.id)
        .bind(proxy_id)
        .bind(&rule.name)
        .bind(rule.priority)
        .bind(rule.enabled)
        .bind(rule.action)
        .bind(&rule.target_backend)
        .bind(conds_json)
        .bind(mock_json)
        .bind(&rule.expression)
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    pub async fn delete_rule(&self, rule_id: &str) -> Result<()> {
        sqlx::query("DELETE FROM rule_model WHERE id = ?")
            .bind(rule_id)
            .execute(&self.pool)
            .await?;
        Ok(())
    }

    pub async fn load_rules(&self, proxy_id: &str) -> Result<Vec<Rule>> {
        let rows =
            sqlx::query("SELECT * FROM rule_model WHERE proxy_id = ? ORDER BY priority DESC")
                .bind(proxy_id)
                .fetch_all(&self.pool)
                .await?;

        let mut result = Vec::new();
        for row in rows {
            let id: String = row.get("id");
            let name: String = row.get("name");
            let priority: i32 = row.get("priority");
            let enabled: bool = row.get("enabled");
            let action: i32 = row.get("action");
            let target_backend: String = row.get("target_backend");
            let conds_json: String = row.get("conditions_json");
            let mock_json: String = row.get("mock_config_json");
            let expression: String = row.get("expression");

            let conditions: Vec<Condition> = if !conds_json.is_empty() {
                serde_json::from_str(&conds_json).unwrap_or_default()
            } else {
                Vec::new()
            };

            let mock_response: Option<MockConfig> = if !mock_json.is_empty() {
                serde_json::from_str(&mock_json).ok()
            } else {
                None
            };

            let rule = Rule {
                id,
                name,
                priority,
                enabled,
                action,
                target_backend,
                conditions,
                mock_response,
                expression,
                ..Default::default()
            };
            result.push(rule);
        }
        Ok(result)
    }
}
