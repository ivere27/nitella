use crate::proto::common::GeoInfo;
use crate::proto::process::{event, Event};
use crate::proto::proxy::ActiveConnection;
use chrono::{DateTime, Utc};
use dashmap::DashMap;
use prost_types::Timestamp;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;
use tokio::sync::broadcast;
use tracing::info;

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
        }
    }

    pub fn register_connection(
        &self,
        id: String,
        proxy_id: String,
        source_ip: String,
        source_port: u32,
        dest_addr: String,
        rule_id: String,
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
}
