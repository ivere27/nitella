use crate::proto::common::ActionType;
use crate::proto::common::GeoInfo;
use crate::proto::process::{event, Event};
use crate::proto::proxy::ActiveConnection;
use chrono::{DateTime, Utc};
use dashmap::DashMap;
use prost_types::Timestamp;
use sqlx::{sqlite::SqlitePoolOptions, Pool, Sqlite};
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;
use tokio::sync::broadcast;
use tokio::sync::mpsc;
use tracing::info;
use tracing::warn;

#[derive(Debug)]
pub struct ActiveConnEntry {
    pub id: String,
    pub proxy_id: String,
    pub source_ip: String,
    pub source_port: u32,
    pub dest_addr: String,
    pub start_time: DateTime<Utc>,
    pub bytes_in: Arc<AtomicU64>,
    pub bytes_out: Arc<AtomicU64>,
    pub rule_id: String,
    pub action: i32,
    pub geo: Option<GeoInfo>,
}

#[derive(Default)]
struct ProxyCounters {
    total_conns: AtomicU64,
    bytes_in: AtomicU64,
    bytes_out: AtomicU64,
}

pub struct StatsService {
    active_conns: DashMap<String, Arc<ActiveConnEntry>>,
    proxy_stats: DashMap<String, Arc<ProxyCounters>>,

    // Global Counters
    total_conns: AtomicU64,
    bytes_in: AtomicU64,
    bytes_out: AtomicU64,
    blocked: AtomicU64,

    event_tx: broadcast::Sender<Event>,
    persist_tx: Option<mpsc::UnboundedSender<PersistentConnectionEvent>>,
}

impl StatsService {
    pub fn new(event_tx: broadcast::Sender<Event>) -> Self {
        Self {
            active_conns: DashMap::new(),
            proxy_stats: DashMap::new(),
            total_conns: AtomicU64::new(0),
            bytes_in: AtomicU64::new(0),
            bytes_out: AtomicU64::new(0),
            blocked: AtomicU64::new(0),
            event_tx,
            persist_tx: None,
        }
    }

    pub async fn new_with_db(event_tx: broadcast::Sender<Event>, db_path: Option<String>) -> Self {
        let mut service = Self::new(event_tx);
        let Some(path) = db_path else {
            return service;
        };
        if path.is_empty() {
            return service;
        }

        match init_stats_db(&path).await {
            Ok(pool) => {
                let (tx, mut rx) = mpsc::unbounded_channel::<PersistentConnectionEvent>();
                tokio::spawn(async move {
                    while let Some(event) = rx.recv().await {
                        if let Err(e) = persist_connection_event(&pool, event).await {
                            warn!("Failed to persist stats event: {}", e);
                        }
                    }
                });
                info!("[INFO] Statistics service enabled: {}", path);
                service.persist_tx = Some(tx);
            }
            Err(e) => {
                warn!("Failed to initialize stats service {}: {}", path, e);
            }
        }

        service
    }

    pub fn register_connection(
        &self,
        id: String,
        proxy_id: String,
        source_ip: String,
        source_port: u32,
        dest_addr: String,
        rule_id: String,
        action: i32,
        geo: Option<GeoInfo>,
    ) -> Arc<ActiveConnEntry> {
        self.total_conns.fetch_add(1, Ordering::Relaxed);

        // Update per-proxy stats
        let stats = self
            .proxy_stats
            .entry(proxy_id.clone())
            .or_default()
            .clone();
        stats.total_conns.fetch_add(1, Ordering::Relaxed);

        let entry = Arc::new(ActiveConnEntry {
            id: id.clone(),
            proxy_id: proxy_id.clone(),
            source_ip: source_ip.clone(),
            source_port,
            dest_addr: dest_addr.clone(),
            start_time: Utc::now(),
            bytes_in: Arc::new(AtomicU64::new(0)),
            bytes_out: Arc::new(AtomicU64::new(0)),
            rule_id: rule_id.clone(),
            action,
            geo: geo.clone(),
        });

        self.active_conns.insert(id.clone(), entry.clone());

        // Emit CONNECTED event
        let _ = self.event_tx.send(Event {
            r#type: Some(event::Type::Connection(
                crate::proto::proxy::ConnectionEvent {
                    conn_id: id,
                    // proxy_id removed
                    source_ip,
                    source_port: source_port as i32,
                    target_addr: dest_addr,
                    event_type: crate::proto::proxy::EventType::Connected as i32,
                    timestamp: Utc::now().timestamp(),
                    rule_matched: rule_id,
                    geo: geo,
                    ..Default::default()
                },
            )),
        });

        entry
    }

    pub fn unregister_connection(&self, id: &str) {
        if let Some((_, entry)) = self.active_conns.remove(id) {
            let b_in = entry.bytes_in.load(Ordering::Relaxed);
            let b_out = entry.bytes_out.load(Ordering::Relaxed);
            if entry.action != ActionType::Block as i32 {
                self.persist_connection_event(PersistentConnectionEvent {
                    source_ip: entry.source_ip.clone(),
                    source_port: entry.source_port as i32,
                    start_time: entry.start_time,
                    end_time: Utc::now(),
                    bytes_in: b_in as i64,
                    bytes_out: b_out as i64,
                    action: entry.action,
                    rule_id: entry.rule_id.clone(),
                    geo: entry.geo.clone(),
                });
            }

            // Emit CLOSED event
            let _ = self.event_tx.send(Event {
                r#type: Some(event::Type::Connection(
                    crate::proto::proxy::ConnectionEvent {
                        conn_id: entry.id.clone(),
                        // proxy_id removed
                        source_ip: entry.source_ip.clone(),
                        event_type: crate::proto::proxy::EventType::Closed as i32,
                        timestamp: Utc::now().timestamp(),
                        bytes_in: b_in as i64,
                        bytes_out: b_out as i64,
                        ..Default::default()
                    },
                )),
            });
        }
    }

    pub fn record_block(&self, ip: &str, rule: &str) {
        self.blocked.fetch_add(1, Ordering::Relaxed);
        let now = Utc::now();
        self.persist_connection_event(PersistentConnectionEvent {
            source_ip: ip.to_string(),
            source_port: 0,
            start_time: now,
            end_time: now,
            bytes_in: 0,
            bytes_out: 0,
            action: ActionType::Block as i32,
            rule_id: rule.to_string(),
            geo: None,
        });

        // Emit BLOCKED event
        let _ = self.event_tx.send(Event {
            r#type: Some(event::Type::Connection(
                crate::proto::proxy::ConnectionEvent {
                    source_ip: ip.to_string(),
                    event_type: crate::proto::proxy::EventType::Blocked as i32,
                    timestamp: Utc::now().timestamp(),
                    rule_matched: rule.to_string(),
                    ..Default::default()
                },
            )),
        });
    }

    pub fn record_approval_request(&self, ip: &str, rule: &str, proxy_id: &str, req_id: &str) {
        // Log explicitly for E2E tests (regex scanner)
        // Format: [Local] Alert generated (pending approval): <UUID> -
        info!(
            "[Local] Alert generated (pending approval): {} - proxy={} ip={} rule={}",
            req_id, proxy_id, ip, rule
        );

        // Emit PENDING_APPROVAL event
        // We act like a connection event:
        // conn_id -> req_id
        // target_addr -> proxy_id
        let _ = self.event_tx.send(Event {
            r#type: Some(event::Type::Connection(
                crate::proto::proxy::ConnectionEvent {
                    source_ip: ip.to_string(),
                    event_type: crate::proto::proxy::EventType::PendingApproval as i32,
                    timestamp: Utc::now().timestamp(),
                    rule_matched: rule.to_string(),
                    conn_id: req_id.to_string(),
                    target_addr: proxy_id.to_string(),
                    ..Default::default()
                },
            )),
        });
    }

    pub fn update_bytes(&self, id: &str, in_delta: u64, out_delta: u64) {
        if let Some(entry) = self.active_conns.get(id) {
            entry.bytes_in.fetch_add(in_delta, Ordering::Relaxed);
            entry.bytes_out.fetch_add(out_delta, Ordering::Relaxed);

            self.bytes_in.fetch_add(in_delta, Ordering::Relaxed);
            self.bytes_out.fetch_add(out_delta, Ordering::Relaxed);

            // Update per-proxy stats
            if let Some(stats) = self.proxy_stats.get(&entry.proxy_id) {
                stats.bytes_in.fetch_add(in_delta, Ordering::Relaxed);
                stats.bytes_out.fetch_add(out_delta, Ordering::Relaxed);
            }
        }
    }

    pub fn get_active_connections(&self, proxy_id: Option<&str>) -> Vec<ActiveConnection> {
        self.active_conns
            .iter()
            .filter(|e| proxy_id.is_none() || e.proxy_id == proxy_id.unwrap())
            .map(|entry| ActiveConnection {
                id: entry.id.clone(),
                source_ip: entry.source_ip.clone(),
                source_port: entry.source_port as i32,
                dest_addr: entry.dest_addr.clone(),
                start_time: Some(Timestamp {
                    seconds: entry.start_time.timestamp(),
                    nanos: entry.start_time.timestamp_subsec_nanos() as i32,
                }),
                bytes_in: entry.bytes_in.load(Ordering::Relaxed) as i64,
                bytes_out: entry.bytes_out.load(Ordering::Relaxed) as i64,
                geo: entry.geo.clone(),
            })
            .collect()
    }

    pub fn get_summary(&self, proxy_id: Option<&str>) -> (i64, i64, i64, i64) {
        // active, total, in, out
        if let Some(pid) = proxy_id {
            let active = self
                .active_conns
                .iter()
                .filter(|e| e.proxy_id == pid)
                .count() as i64;
            if let Some(stats) = self.proxy_stats.get(pid) {
                (
                    active,
                    stats.total_conns.load(Ordering::Relaxed) as i64,
                    stats.bytes_in.load(Ordering::Relaxed) as i64,
                    stats.bytes_out.load(Ordering::Relaxed) as i64,
                )
            } else {
                (active, 0, 0, 0)
            }
        } else {
            (
                self.active_conns.len() as i64,
                self.total_conns.load(Ordering::Relaxed) as i64,
                self.bytes_in.load(Ordering::Relaxed) as i64,
                self.bytes_out.load(Ordering::Relaxed) as i64,
            )
        }
    }

    fn persist_connection_event(&self, event: PersistentConnectionEvent) {
        if let Some(tx) = &self.persist_tx {
            let _ = tx.send(event);
        }
    }
}

#[derive(Clone)]
struct PersistentConnectionEvent {
    source_ip: String,
    source_port: i32,
    start_time: DateTime<Utc>,
    end_time: DateTime<Utc>,
    bytes_in: i64,
    bytes_out: i64,
    action: i32,
    rule_id: String,
    geo: Option<GeoInfo>,
}

async fn init_stats_db(path: &str) -> anyhow::Result<Pool<Sqlite>> {
    if let Some(parent) = std::path::Path::new(path).parent() {
        if !parent.as_os_str().is_empty() {
            tokio::fs::create_dir_all(parent).await?;
        }
    }
    let conn_str = format!("sqlite://{}?mode=rwc", path);
    let pool = SqlitePoolOptions::new()
        .max_connections(5)
        .connect(&conn_str)
        .await?;

    sqlx::query(
        "CREATE TABLE IF NOT EXISTS connection_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            source_ip TEXT NOT NULL,
            source_port INTEGER NOT NULL,
            first_seen TEXT NOT NULL,
            last_seen TEXT NOT NULL,
            bytes_in INTEGER NOT NULL DEFAULT 0,
            bytes_out INTEGER NOT NULL DEFAULT 0,
            duration_ms INTEGER NOT NULL DEFAULT 0,
            action INTEGER NOT NULL DEFAULT 0,
            rule_id TEXT,
            geo_country TEXT,
            geo_city TEXT,
            geo_isp TEXT
        )",
    )
    .execute(&pool)
    .await?;
    sqlx::query(
        "CREATE INDEX IF NOT EXISTS idx_connection_log_source_ip ON connection_log(source_ip)",
    )
    .execute(&pool)
    .await?;
    sqlx::query(
        "CREATE INDEX IF NOT EXISTS idx_connection_log_first_seen ON connection_log(first_seen)",
    )
    .execute(&pool)
    .await?;

    sqlx::query(
        "CREATE TABLE IF NOT EXISTS ip_stats (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            source_ip TEXT NOT NULL UNIQUE,
            first_seen TEXT NOT NULL,
            last_seen TEXT NOT NULL,
            connection_count INTEGER NOT NULL DEFAULT 0,
            total_bytes_in INTEGER NOT NULL DEFAULT 0,
            total_bytes_out INTEGER NOT NULL DEFAULT 0,
            total_duration_ms INTEGER NOT NULL DEFAULT 0,
            blocked_count INTEGER NOT NULL DEFAULT 0,
            allowed_count INTEGER NOT NULL DEFAULT 0,
            geo_country TEXT,
            geo_city TEXT,
            geo_isp TEXT
        )",
    )
    .execute(&pool)
    .await?;
    sqlx::query("CREATE INDEX IF NOT EXISTS idx_ip_stats_last_seen ON ip_stats(last_seen)")
        .execute(&pool)
        .await?;

    sqlx::query(
        "CREATE TABLE IF NOT EXISTS geo_stats (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            value TEXT NOT NULL,
            connection_count INTEGER NOT NULL DEFAULT 0,
            unique_ips INTEGER NOT NULL DEFAULT 0,
            total_bytes_in INTEGER NOT NULL DEFAULT 0,
            total_bytes_out INTEGER NOT NULL DEFAULT 0,
            blocked_count INTEGER NOT NULL DEFAULT 0,
            last_updated TEXT NOT NULL,
            UNIQUE(type, value)
        )",
    )
    .execute(&pool)
    .await?;
    sqlx::query("CREATE INDEX IF NOT EXISTS idx_geo_stats_type ON geo_stats(type)")
        .execute(&pool)
        .await?;

    sqlx::query(
        "CREATE TABLE IF NOT EXISTS stats_config (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            key TEXT NOT NULL UNIQUE,
            value TEXT NOT NULL
        )",
    )
    .execute(&pool)
    .await?;

    Ok(pool)
}

async fn persist_connection_event(
    pool: &Pool<Sqlite>,
    event: PersistentConnectionEvent,
) -> anyhow::Result<()> {
    let start = event.start_time.to_rfc3339();
    let end = event.end_time.to_rfc3339();
    let duration_ms = (event.end_time - event.start_time)
        .num_milliseconds()
        .max(0);
    let geo_country = event
        .geo
        .as_ref()
        .map(|g| g.country.clone())
        .unwrap_or_default();
    let geo_city = event
        .geo
        .as_ref()
        .map(|g| g.city.clone())
        .unwrap_or_default();
    let geo_isp = event
        .geo
        .as_ref()
        .map(|g| g.isp.clone())
        .unwrap_or_default();
    let blocked = if event.action == ActionType::Block as i32 {
        1
    } else {
        0
    };
    let allowed = if blocked == 0 { 1 } else { 0 };

    let mut tx = pool.begin().await?;

    sqlx::query(
        "INSERT INTO connection_log (
            source_ip, source_port, first_seen, last_seen, bytes_in, bytes_out,
            duration_ms, action, rule_id, geo_country, geo_city, geo_isp
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
    )
    .bind(&event.source_ip)
    .bind(event.source_port)
    .bind(&start)
    .bind(&end)
    .bind(event.bytes_in)
    .bind(event.bytes_out)
    .bind(duration_ms)
    .bind(event.action)
    .bind(&event.rule_id)
    .bind(&geo_country)
    .bind(&geo_city)
    .bind(&geo_isp)
    .execute(&mut *tx)
    .await?;

    sqlx::query(
        "INSERT INTO ip_stats (
            source_ip, first_seen, last_seen, connection_count, total_bytes_in,
            total_bytes_out, total_duration_ms, blocked_count, allowed_count,
            geo_country, geo_city, geo_isp
        ) VALUES (?, ?, ?, 1, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(source_ip) DO UPDATE SET
            last_seen = excluded.last_seen,
            connection_count = connection_count + 1,
            total_bytes_in = total_bytes_in + excluded.total_bytes_in,
            total_bytes_out = total_bytes_out + excluded.total_bytes_out,
            total_duration_ms = total_duration_ms + excluded.total_duration_ms,
            blocked_count = blocked_count + excluded.blocked_count,
            allowed_count = allowed_count + excluded.allowed_count,
            geo_country = CASE WHEN excluded.geo_country != '' THEN excluded.geo_country ELSE geo_country END,
            geo_city = CASE WHEN excluded.geo_city != '' THEN excluded.geo_city ELSE geo_city END,
            geo_isp = CASE WHEN excluded.geo_isp != '' THEN excluded.geo_isp ELSE geo_isp END",
    )
    .bind(&event.source_ip)
    .bind(&start)
    .bind(&end)
    .bind(event.bytes_in)
    .bind(event.bytes_out)
    .bind(duration_ms)
    .bind(blocked)
    .bind(allowed)
    .bind(&geo_country)
    .bind(&geo_city)
    .bind(&geo_isp)
    .execute(&mut *tx)
    .await?;

    persist_geo_stat(
        &mut tx,
        "country",
        &geo_country,
        &event.source_ip,
        event.bytes_in,
        event.bytes_out,
        blocked,
        &end,
    )
    .await?;
    persist_geo_stat(
        &mut tx,
        "city",
        &geo_city,
        &event.source_ip,
        event.bytes_in,
        event.bytes_out,
        blocked,
        &end,
    )
    .await?;
    persist_geo_stat(
        &mut tx,
        "isp",
        &geo_isp,
        &event.source_ip,
        event.bytes_in,
        event.bytes_out,
        blocked,
        &end,
    )
    .await?;

    tx.commit().await?;
    Ok(())
}

async fn persist_geo_stat(
    tx: &mut sqlx::Transaction<'_, Sqlite>,
    geo_type: &str,
    value: &str,
    _source_ip: &str,
    bytes_in: i64,
    bytes_out: i64,
    blocked: i64,
    last_updated: &str,
) -> anyhow::Result<()> {
    if value.is_empty() {
        return Ok(());
    }
    let _ = sqlx::query(
        "INSERT INTO geo_stats (
            type, value, connection_count, unique_ips, total_bytes_in,
            total_bytes_out, blocked_count, last_updated
        ) VALUES (?, ?, 1, ?, ?, ?, ?, ?)
        ON CONFLICT(type, value) DO UPDATE SET
            connection_count = connection_count + 1,
            unique_ips = unique_ips + excluded.unique_ips,
            total_bytes_in = total_bytes_in + excluded.total_bytes_in,
            total_bytes_out = total_bytes_out + excluded.total_bytes_out,
            blocked_count = blocked_count + excluded.blocked_count,
            last_updated = excluded.last_updated",
    )
    .bind(geo_type)
    .bind(value)
    .bind(1_i64)
    .bind(bytes_in)
    .bind(bytes_out)
    .bind(blocked)
    .bind(last_updated)
    .execute(&mut **tx)
    .await?;
    Ok(())
}
