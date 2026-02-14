use crate::proto::common::GeoInfo;
use anyhow::{Context, Result};
use maxminddb::Reader;
use sqlx::{sqlite::SqlitePoolOptions, Pool, Row, Sqlite};
use std::net::IpAddr;
use std::path::Path;
use std::sync::Arc;
use std::time::{Duration, SystemTime, UNIX_EPOCH};
use tokio::fs;
use tokio::sync::RwLock;
use tracing::{debug, error, info};

type MmapReader = Reader<memmap2::Mmap>;
const DEFAULT_REMOTE_LOOKUP_TIMEOUT_MS: u64 = 3000;

#[derive(Clone)]
pub struct L2Cache {
    pool: Pool<Sqlite>,
    ttl_hours: i32,
}

impl L2Cache {
    pub async fn new(path: &str, ttl_hours: i32) -> Result<Self> {
        if let Some(parent) = Path::new(path).parent() {
            fs::create_dir_all(parent).await?;
        }
        if !Path::new(path).exists() {
            fs::File::create(path).await?;
        }

        let conn_str = format!("sqlite://{}", path);
        let pool = SqlitePoolOptions::new().connect(&conn_str).await?;

        // Init Schema
        sqlx::query(
            "CREATE TABLE IF NOT EXISTS geoip_cache (
                ip TEXT PRIMARY KEY,
                country TEXT, country_code TEXT, region TEXT, region_name TEXT,
                city TEXT, zip TEXT, latitude REAL, longitude REAL, timezone TEXT,
                isp TEXT, org TEXT, as_info TEXT, source TEXT, created_at INTEGER
            );",
        )
        .execute(&pool)
        .await?;

        Ok(Self { pool, ttl_hours })
    }

    pub async fn get(&self, ip: &str) -> Option<GeoInfo> {
        let row = sqlx::query("SELECT * FROM geoip_cache WHERE ip = ?")
            .bind(ip)
            .fetch_optional(&self.pool)
            .await
            .ok()??;

        let created_at: i64 = row.get("created_at");
        if self.ttl_hours > 0 {
            let now = SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .unwrap()
                .as_secs() as i64;
            if now - created_at > (self.ttl_hours as i64 * 3600) {
                return None;
            }
        }

        Some(GeoInfo {
            country: row.get("country"),
            country_code: row.get("country_code"),
            region: row.get("region"),
            region_name: row.get("region_name"),
            city: row.get("city"),
            zip: row.get("zip"),
            latitude: row.get("latitude"),
            longitude: row.get("longitude"),
            timezone: row.get("timezone"),
            isp: row.get("isp"),
            org: row.get("org"),
            r#as: row.get("as_info"),
            source: row.get("source"),
            ..Default::default()
        })
    }

    pub async fn put(&self, ip: &str, info: &GeoInfo) {
        let now = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_secs() as i64;
        let _ = sqlx::query(
            "INSERT OR REPLACE INTO geoip_cache (
                ip, country, country_code, region, region_name, city, zip, 
                latitude, longitude, timezone, isp, org, as_info, source, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        )
        .bind(ip)
        .bind(&info.country)
        .bind(&info.country_code)
        .bind(&info.region)
        .bind(&info.region_name)
        .bind(&info.city)
        .bind(&info.zip)
        .bind(info.latitude)
        .bind(info.longitude)
        .bind(&info.timezone)
        .bind(&info.isp)
        .bind(&info.org)
        .bind(&info.r#as)
        .bind(&info.source)
        .bind(now)
        .execute(&self.pool)
        .await;
    }
}

#[derive(Clone)]
struct GeoIPState {
    city_reader: Option<Arc<MmapReader>>,
    isp_reader: Option<Arc<MmapReader>>,
    remote_providers: Vec<String>,
    l2_cache: Option<L2Cache>,
    strategy: Vec<String>,
    remote_timeout: Duration,
}

#[derive(Clone)]
pub struct GeoIPService {
    state: Arc<RwLock<GeoIPState>>,
    http_client: reqwest::Client,
}

impl GeoIPService {
    pub async fn new(
        city_path: Option<String>,
        isp_path: Option<String>,
        remote_url: Option<String>,
        cache_path: Option<String>,
        cache_ttl: i32,
        strategy_str: Option<String>,
        remote_timeout_ms: u64,
    ) -> Result<Self> {
        let mut city_reader = None;
        if let Some(path) = city_path {
            if !path.is_empty() {
                info!("Loading GeoIP City/Country DB: {}", path);
                let reader = Reader::open_mmap(path).context("Failed to open City DB")?;
                city_reader = Some(Arc::new(reader));
            }
        }

        let mut isp_reader = None;
        if let Some(path) = isp_path {
            if !path.is_empty() {
                info!("Loading GeoIP ISP DB: {}", path);
                let reader = Reader::open_mmap(path).context("Failed to open ISP DB")?;
                isp_reader = Some(Arc::new(reader));
            }
        }

        let l2_cache = if let Some(path) = cache_path {
            if !path.is_empty() {
                match L2Cache::new(&path, cache_ttl).await {
                    Ok(c) => Some(c),
                    Err(e) => {
                        error!("Failed to init L2 Cache: {}", e);
                        None
                    }
                }
            } else {
                None
            }
        } else {
            None
        };

        let strategy = if let Some(s) = strategy_str {
            s.split(',')
                .map(|s| s.trim().to_string())
                .filter(|s| !s.is_empty())
                .collect()
        } else {
            vec![
                "l1".to_string(),
                "l2".to_string(),
                "local".to_string(),
                "remote".to_string(),
            ]
        };

        let remote_providers = if let Some(addr) = remote_url {
            vec![normalize_provider_template(&addr)]
        } else {
            vec![
                "https://ipwhois.app/json/%s".to_string(),
                "https://freeipapi.com/api/json/%s".to_string(),
            ]
        };

        let remote_timeout = if remote_timeout_ms == 0 {
            Duration::from_millis(DEFAULT_REMOTE_LOOKUP_TIMEOUT_MS)
        } else {
            Duration::from_millis(remote_timeout_ms)
        };

        let state = GeoIPState {
            city_reader,
            isp_reader,
            remote_providers,
            l2_cache,
            strategy,
            remote_timeout,
        };

        Ok(Self {
            state: Arc::new(RwLock::new(state)),
            http_client: reqwest::Client::new(),
        })
    }

    pub async fn lookup(&self, ip_str: &str) -> GeoInfo {
        self.lookup_with_remote_timeout(ip_str, None).await
    }

    pub async fn lookup_with_remote_timeout(
        &self,
        ip_str: &str,
        remote_timeout: Option<Duration>,
    ) -> GeoInfo {
        // Clone state to avoid holding lock during async remote call
        let state = { self.state.read().await.clone() };
        let remote_timeout = remote_timeout.unwrap_or(state.remote_timeout);

        for step in &state.strategy {
            match step.as_str() {
                "l1" => {}
                "l2" => {
                    if let Some(cache) = &state.l2_cache {
                        if let Some(info) = cache.get(ip_str).await {
                            return info;
                        }
                    }
                }
                "local" => {
                    if let Some(info) = self.lookup_local(&state, ip_str) {
                        // Populate caches
                        self.cache_result(&state, ip_str, &info).await;
                        return info;
                    }
                }
                "remote" => {
                    // Never call external providers for local/private addresses.
                    if is_non_public_ip(ip_str) {
                        info!("GeoIP: skip remote lookup for non-public IP {}", ip_str);
                        continue;
                    }
                    if let Some(info) = self.lookup_remote(&state, ip_str, remote_timeout).await {
                        self.cache_result(&state, ip_str, &info).await;
                        return info;
                    }
                }
                _ => {}
            }
        }
        GeoInfo::default()
    }

    fn lookup_local(&self, state: &GeoIPState, ip_str: &str) -> Option<GeoInfo> {
        let ip: IpAddr = ip_str.parse().ok()?;
        let mut info = GeoInfo::default();
        let mut found = false;

        if let Some(reader) = &state.city_reader {
            match reader.lookup::<maxminddb::geoip2::City>(ip) {
                Ok(city) => {
                    info.source = "local-city".to_string();
                    if let Some(c) = city.country {
                        if let Some(iso) = c.iso_code {
                            info.country = iso.to_string();
                            info.country_code = iso.to_string();
                        }
                    }
                    if let Some(subs) = city.subdivisions {
                        if let Some(sub) = subs.get(0) {
                            if let Some(iso) = sub.iso_code {
                                info.region = iso.to_string();
                            }
                            if let Some(names) = &sub.names {
                                if let Some(n) = names.get("en") {
                                    info.region_name = n.to_string();
                                }
                            }
                        }
                    }
                    if let Some(c) = city.city {
                        if let Some(names) = &c.names {
                            if let Some(n) = names.get("en") {
                                info.city = n.to_string();
                            }
                        }
                    }
                    if let Some(l) = city.location {
                        if let Some(lat) = l.latitude {
                            info.latitude = lat;
                        }
                        if let Some(lon) = l.longitude {
                            info.longitude = lon;
                        }
                        if let Some(tz) = l.time_zone {
                            info.timezone = tz.to_string();
                        }
                    }
                    found = true;
                }
                Err(_) => {
                    if let Ok(country) = reader.lookup::<maxminddb::geoip2::Country>(ip) {
                        info.source = "local-country".to_string();
                        if let Some(c) = country.country {
                            if let Some(iso) = c.iso_code {
                                info.country = iso.to_string();
                                info.country_code = iso.to_string();
                            }
                        }
                        found = true;
                    }
                }
            }
        }

        if let Some(reader) = &state.isp_reader {
            if let Ok(isp) = reader.lookup::<maxminddb::geoip2::Isp>(ip) {
                if let Some(n) = isp.isp {
                    info.isp = n.to_string();
                }
                if let Some(o) = isp.organization {
                    info.org = o.to_string();
                }
                if let Some(a) = isp.autonomous_system_organization {
                    info.r#as = a.to_string();
                }
                found = true;
            }
        }

        if found {
            Some(info)
        } else {
            None
        }
    }

    async fn lookup_remote(
        &self,
        state: &GeoIPState,
        ip_str: &str,
        timeout: Duration,
    ) -> Option<GeoInfo> {
        for url_fmt in &state.remote_providers {
            let url = url_fmt.replace("%s", ip_str);
            debug!("GeoIP Remote lookup: {}", url);
            match tokio::time::timeout(timeout, self.http_client.get(&url).send()).await {
                Ok(Ok(resp)) => {
                    if let Ok(json) = resp.json::<serde_json::Value>().await {
                        let mut info = GeoInfo::default();
                        info.source = "remote".to_string();
                        if let Some(s) = json.get("countryCode").and_then(|v| v.as_str()) {
                            info.country_code = s.to_string();
                        }
                        if let Some(s) = json.get("country").and_then(|v| v.as_str()) {
                            info.country = s.to_string();
                        }
                        if let Some(s) = json.get("city").and_then(|v| v.as_str()) {
                            info.city = s.to_string();
                        }
                        if let Some(s) = json.get("isp").and_then(|v| v.as_str()) {
                            info.isp = s.to_string();
                        }
                        return Some(info);
                    }
                }
                _ => {}
            }
        }
        None
    }

    async fn cache_result(&self, state: &GeoIPState, ip: &str, info: &GeoInfo) {
        if let Some(cache) = &state.l2_cache {
            cache.put(ip, info).await;
        }
    }

    pub async fn set_remote_url(&self, url: String) {
        let mut state = self.state.write().await;
        state.remote_providers = vec![normalize_provider_template(&url)];
    }

    pub async fn set_strategy(&self, strategy: Vec<String>) {
        let mut state = self.state.write().await;
        state.strategy = strategy;
    }

    pub async fn reload_local_db(
        &self,
        city_path: Option<String>,
        isp_path: Option<String>,
    ) -> Result<()> {
        let mut new_city_reader = None;
        if let Some(path) = &city_path {
            if !path.is_empty() {
                info!("Reloading GeoIP City/Country DB: {}", path);
                let reader = Reader::open_mmap(path).context("Failed to open City DB")?;
                new_city_reader = Some(Arc::new(reader));
            }
        }

        let mut new_isp_reader = None;
        if let Some(path) = &isp_path {
            if !path.is_empty() {
                info!("Reloading GeoIP ISP DB: {}", path);
                let reader = Reader::open_mmap(path).context("Failed to open ISP DB")?;
                new_isp_reader = Some(Arc::new(reader));
            }
        }

        let mut state = self.state.write().await;
        if new_city_reader.is_some() {
            state.city_reader = new_city_reader;
        }
        if new_isp_reader.is_some() {
            state.isp_reader = new_isp_reader;
        }
        Ok(())
    }

    pub async fn get_status(&self) -> String {
        let state = self.state.read().await;
        let mut status = Vec::new();
        status.push(format!("Strategy: {}", state.strategy.join(",")));
        status.push(format!(
            "City DB: {}",
            if state.city_reader.is_some() {
                "Loaded"
            } else {
                "Not Loaded"
            }
        ));
        status.push(format!(
            "ISP DB: {}",
            if state.isp_reader.is_some() {
                "Loaded"
            } else {
                "Not Loaded"
            }
        ));
        status.push(format!(
            "L2 Cache: {}",
            if state.l2_cache.is_some() {
                "Enabled"
            } else {
                "Disabled"
            }
        ));
        status.push(format!(
            "Remote Providers: {}",
            state.remote_providers.len()
        ));
        status.push(format!(
            "Remote Timeout: {}ms",
            state.remote_timeout.as_millis()
        ));
        status.join("\n")
    }

    pub async fn get_status_struct(&self) -> GeoIpStatusStruct {
        let state = self.state.read().await;
        GeoIpStatusStruct {
            enabled: true,
            strategy: state.strategy.clone(),
            city_db_loaded: state.city_reader.is_some(),
            isp_db_loaded: state.isp_reader.is_some(),
            remote_providers: state.remote_providers.clone(),
            l2_cache_enabled: state.l2_cache.is_some(),
        }
    }
}

fn normalize_provider_template(provider: &str) -> String {
    if provider.contains("%s") {
        provider.to_string()
    } else {
        format!("{}/%s", provider.trim_end_matches('/'))
    }
}

fn is_non_public_ip(ip_str: &str) -> bool {
    match ip_str.parse::<IpAddr>() {
        Ok(IpAddr::V4(ip)) => {
            ip.is_private()
                || ip.is_loopback()
                || ip.is_link_local()
                || ip.is_multicast()
                || ip.is_unspecified()
        }
        Ok(IpAddr::V6(ip)) => {
            ip.is_loopback()
                || ip.is_unique_local()
                || ip.is_unicast_link_local()
                || ip.is_multicast()
                || ip.is_unspecified()
        }
        Err(_) => false,
    }
}

#[cfg(test)]
mod tests {
    use super::{is_non_public_ip, normalize_provider_template};

    #[test]
    fn normalize_provider_template_handles_base_and_template() {
        assert_eq!(
            normalize_provider_template("https://example.com/json"),
            "https://example.com/json/%s"
        );
        assert_eq!(
            normalize_provider_template("https://example.com/json/%s"),
            "https://example.com/json/%s"
        );
    }

    #[test]
    fn is_non_public_ip_detects_local_ranges() {
        assert!(is_non_public_ip("127.0.0.1"));
        assert!(is_non_public_ip("10.0.0.5"));
        assert!(is_non_public_ip("192.168.1.20"));
        assert!(is_non_public_ip("::1"));
        assert!(!is_non_public_ip("8.8.8.8"));
    }
}

pub struct GeoIpStatusStruct {
    pub enabled: bool,
    pub strategy: Vec<String>,
    pub city_db_loaded: bool,
    pub isp_db_loaded: bool,
    pub remote_providers: Vec<String>,
    pub l2_cache_enabled: bool,
}
