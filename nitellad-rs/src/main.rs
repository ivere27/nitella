use clap::Parser;
use ed25519_dalek::{pkcs8::DecodePrivateKey, SigningKey};
use rand::RngCore;
use std::fs as std_fs;
use std::path::Path;
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::{broadcast, RwLock};
use tonic::transport::{Identity, Server, ServerTlsConfig};
use tonic::{Request, Status};
use tracing::{error, info, warn, Level};
use tracing_subscriber::FmtSubscriber;

// Use library crate's proto and modules
use nitella::proto;
#[cfg(unix)]
use nitella::synurang;
use nitella::{
    admin, admin_security, config, db, geoip, health, hub, manager, pairing_offline, rules, stats,
};

use admin::AdminServer;
use db::Database;
use geoip::GeoIPService;
use health::HealthChecker;
use hub::HubClient;
use manager::ProxyManager;
use nitella::approval::ApprovalManager;
#[cfg(unix)]
use nitella::server::NitellaProcessServer;
use pairing_offline::{OfflinePairing, DEFAULT_PAIRING_TIMEOUT};
use proto::common::{ActionType, ConditionType, FallbackAction, MockPreset, Operator};
#[cfg(unix)]
use proto::process::process_control_server::ProcessControlServer;
use proto::proxy::proxy_control_service_server::ProxyControlServiceServer;
use proto::proxy::{
    ClientAuthType, Condition, CreateProxyRequest, MockConfig, RateLimitConfig, Rule,
};
use rules::RuleEngine;
use stats::StatsService;

/// Nitella Proxy Daemon (Rust Implementation)
#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    // --- Proxy Options ---
    /// Listen address for proxy
    #[arg(long, default_value = ":8080")]
    listen: String,

    /// Default backend address
    #[arg(long)]
    backend: Option<String>,

    /// Default action for CLI proxy: allow, block, mock, approval, require_approval
    #[arg(long, default_value = "allow")]
    default_action: String,

    /// Fallback action for blocked or failed connections: close, mock
    #[arg(long)]
    fallback_action: Option<String>,

    /// Mock preset for --fallback-action mock, e.g. ssh-tarpit, mysql-tarpit, raw-tarpit
    #[arg(long)]
    fallback_mock: Option<String>,

    /// Source IPs/CIDRs or standalone aliases (localhost, private, local) to allow
    #[arg(long, value_delimiter = ',')]
    allow_ip: Vec<String>,

    /// Source IPs/CIDRs or standalone aliases (localhost, private, local) to block
    #[arg(long, value_delimiter = ',')]
    block_ip: Vec<String>,

    /// GeoIP countries to allow as startup rules, e.g. --allow-country KR,JP
    #[arg(long, value_delimiter = ',')]
    allow_country: Vec<String>,

    /// GeoIP countries to block as startup rules, e.g. --block-country CN,RU
    #[arg(long, value_delimiter = ',')]
    block_country: Vec<String>,

    /// Maximum connections/failures per source IP in the rate-limit interval (0 = disabled)
    #[arg(long)]
    rate_limit_max_connections: Option<i32>,

    /// Rate-limit counting window in seconds
    #[arg(long)]
    rate_limit_interval: Option<i32>,

    /// Temporarily block source IPs that exceed the rate limit
    #[arg(long, num_args = 0..=1, default_missing_value = "true", value_parser = clap::value_parser!(bool))]
    rate_limit_auto_block: Option<bool>,

    /// Temporary block duration in seconds
    #[arg(long)]
    rate_limit_block_duration: Option<i32>,

    /// Comma-separated escalation block durations in seconds, e.g. 600,3600,86400
    #[arg(long)]
    rate_limit_block_steps: Option<String>,

    /// Only count connections shorter than --rate-limit-failure-threshold
    #[arg(long)]
    rate_limit_count_only_failures: bool,

    /// Short-lived failure threshold in seconds when --rate-limit-count-only-failures is set
    #[arg(long)]
    rate_limit_failure_threshold: Option<i32>,

    /// Path to YAML config file
    #[arg(long)]
    config: Option<String>,

    /// Path to SQLite database for proxy persistence (disabled by default)
    #[arg(long)]
    db_path: Option<String>,

    /// Path to statistics database
    #[arg(long)]
    stats_db: Option<String>,

    /// Run each proxy as a separate child process (for isolation)
    #[arg(long)]
    process_mode: bool,

    /// Data directory for admin API certificates
    #[arg(long)]
    admin_data_dir: Option<String>,

    // Support "child" subcommand args
    #[arg(long)]
    id: Option<String>,
    #[arg(long)]
    name: Option<String>,

    // --- Admin API Options ---
    /// Port for Admin gRPC API (0 = disabled)
    #[arg(long, default_value_t = 0)]
    admin_port: u16,

    /// Authentication token for Admin API
    #[arg(long, env = "NITELLA_TOKEN")]
    admin_token: Option<String>,

    /// Port for pprof HTTP server (ignored in Rust, for compatibility only)
    #[arg(long, default_value_t = 0)]
    pprof_port: u16,

    // --- Hub Mode Options ---
    /// Hub server address
    #[arg(long, env = "NITELLA_HUB")]
    hub: Option<String>,

    /// User ID for Hub registration
    #[arg(long, env = "NITELLA_HUB_USER_ID")]
    hub_user_id: Option<String>,

    /// Node name for Hub (default: hostname)
    #[arg(long)]
    hub_node_name: Option<String>,

    /// Hub Data Directory (default: ~/.nitella/nitellad)
    #[arg(long)]
    hub_data_dir: Option<String>,

    /// Enable P2P connections via Hub
    #[arg(long, default_value_t = false)]
    hub_p2p: bool,

    /// Path to Hub CA certificate
    #[arg(long)]
    hub_ca: Option<String>,

    /// STUN server address
    #[arg(long)]
    stun: Option<String>,

    /// Pairing Code
    #[arg(long)]
    pair: Option<String>,

    /// Offline pairing mode
    #[arg(long)]
    pair_offline: bool,

    /// Port for pairing web UI
    #[arg(long)]
    pair_port: Option<String>,

    /// Pairing timeout duration
    #[arg(long)]
    pair_timeout: Option<String>,

    // --- TLS Options ---
    /// Path to TLS Certificate
    #[arg(long)]
    tls_cert: Option<String>,

    /// Path to TLS Private Key
    #[arg(long)]
    tls_key: Option<String>,

    /// Path to TLS CA Certificate
    #[arg(long)]
    tls_ca: Option<String>,

    /// Require Client Certificates (mTLS)
    #[arg(long)]
    mtls: bool,

    // --- GeoIP Options ---
    /// Path to GeoIP2 City DB
    #[arg(long)]
    geoip_city: Option<String>,

    /// Path to GeoIP2 ISP DB
    #[arg(long)]
    geoip_isp: Option<String>,

    /// Path to GeoIP L2 Cache
    #[arg(long, default_value = "geoip_cache.db")]
    geoip_cache: Option<String>,

    /// GeoIP L2 Cache TTL in hours
    #[arg(long, default_value = "24")]
    geoip_cache_ttl: Option<i32>,

    /// Lookup strategy order
    #[arg(long, default_value = "l1,l2,local,remote")]
    geoip_strategy: Option<String>,

    /// Remote provider timeout in ms
    #[arg(long, default_value_t = 3000)]
    geoip_timeout: u64,

    /// Address of external GeoIP service
    #[arg(long)]
    geoip_addr: Option<String>,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let subscriber = FmtSubscriber::builder()
        .with_max_level(Level::INFO)
        .finish();
    tracing::subscriber::set_global_default(subscriber)?;

    // Check for "child" as the first real argument (matches Go: os.Args[1] == "child")
    let args_raw: Vec<String> = std::env::args().collect();
    let is_child = args_raw.len() > 1 && args_raw[1] == "child";

    // Remove "child" from position 1 so clap doesn't complain
    let args_clean: Vec<String> = args_raw
        .into_iter()
        .enumerate()
        .filter(|(i, a)| !(*i == 1 && a == "child"))
        .map(|(_, a)| a)
        .collect();

    let mut args = Args::parse_from(args_clean);

    // Resolve hub_data_dir default
    if args.hub_data_dir.is_none() {
        if let Ok(home) = std::env::var("HOME") {
            args.hub_data_dir = Some(format!("{home}/.nitella/nitellad"));
        } else {
            args.hub_data_dir = Some(".".to_string());
        }
    }

    if (args.pair.is_some() || args.pair_offline) && args.hub.is_none() {
        return Err("--hub address required for pairing".into());
    }

    if args.config.is_some() && cli_fallback_args_present(&args) {
        return Err("fallback CLI flags are only supported with --listen/--backend standalone mode; use entryPoints.<name>.fallbackAction/fallbackMock in YAML config".into());
    }
    let (cli_fallback_action, cli_fallback_mock) = if args.config.is_none() {
        build_cli_fallback_config(
            args.fallback_action.as_deref(),
            args.fallback_mock.as_deref(),
        )?
    } else {
        (
            FallbackAction::Unspecified as i32,
            MockPreset::Unspecified as i32,
        )
    };
    if cli_fallback_args_present(&args) && args.backend.is_none() {
        return Err("fallback CLI flags require --backend; use YAML fallbackAction/fallbackMock with --config for config-file mode".into());
    }

    if args.config.is_some() && cli_rate_limit_args_present(&args) {
        return Err("rate-limit CLI flags are only supported with --listen/--backend standalone mode; use entryPoints.<name>.rateLimit in YAML config".into());
    }
    let cli_rate_limit = if args.config.is_none() {
        build_cli_rate_limit_config(cli_rate_limit_options_from_args(&args))?
    } else {
        None
    };
    if cli_rate_limit.is_some() && args.backend.is_none() {
        return Err("rate-limit CLI flags require --backend; use YAML rateLimit with --config for config-file mode".into());
    }

    info!("Nitella Proxy Daemon (Rust) starting...");

    let cert_pem = read_optional_file(args.tls_cert.as_deref(), "TLS certificate");
    let key_pem = read_optional_file(args.tls_key.as_deref(), "TLS private key");
    let ca_pem = read_optional_file(args.tls_ca.as_deref(), "TLS CA certificate");
    let client_auth_type = if args.mtls {
        ClientAuthType::ClientAuthRequire as i32
    } else if !ca_pem.is_empty() {
        ClientAuthType::ClientAuthRequest as i32
    } else {
        ClientAuthType::ClientAuthNone as i32
    };

    // 0. Handle Offline Pairing
    if args.pair_offline {
        let node_name = args.hub_node_name.clone().unwrap_or_else(|| {
            gethostname::gethostname()
                .into_string()
                .unwrap_or_else(|_| "nitellad-node".to_string())
        });
        let pairing = OfflinePairing::new(args.hub_data_dir.clone().unwrap(), node_name);

        let port = if let Some(p_str) = args.pair_port.as_deref() {
            Some(p_str.trim_start_matches(':').parse::<u16>()?)
        } else {
            None
        };

        let timeout = match args.pair_timeout.as_deref() {
            Some(value) => {
                let parsed = parse_go_duration(value)?;
                if parsed.is_zero() {
                    DEFAULT_PAIRING_TIMEOUT
                } else {
                    parsed
                }
            }
            None => DEFAULT_PAIRING_TIMEOUT,
        };

        pairing.run(port, timeout).await?;
        info!("Offline pairing completed successfully.");
    }

    // 1. Initialize DB. Match Go nitellad: CLI mode is stateless by default;
    // --db-path opts into proxy persistence; config mode is YAML-owned and
    // child mode also does not use DB state.
    let db = if should_open_proxy_db(is_child, args.config.as_deref(), args.db_path.as_deref()) {
        let db_path = args.db_path.as_deref().unwrap_or_default();
        match Database::new(db_path).await {
            Ok(d) => Some(d),
            Err(e) => {
                warn!(
                    "Failed to init DB persistence: {}. Running in-memory only.",
                    e
                );
                None
            }
        }
    } else {
        None
    };

    // 2. Initialize Shared Services
    let geoip = Arc::new(
        GeoIPService::new(
            args.geoip_city.clone(),
            args.geoip_isp.clone(),
            args.geoip_addr.clone(),
            args.geoip_cache
                .clone()
                .or(Some("geoip_cache.db".to_string())),
            args.geoip_cache_ttl.unwrap_or(24),
            args.geoip_strategy.clone(),
            args.geoip_timeout,
        )
        .await?,
    );

    let global_rules = Arc::new(RwLock::new(RuleEngine::new(vec![])));
    let approval_manager = Arc::new(ApprovalManager::new());

    // 3. Event Bus & Stats
    let (event_tx, _) = broadcast::channel(100);
    let stats_db_path = if is_child {
        None
    } else {
        Some(resolve_stats_db_path(
            args.config.as_deref(),
            args.stats_db.as_deref(),
        ))
    };
    let stats = Arc::new(StatsService::new_with_db(event_tx.clone(), stats_db_path).await);

    // 7. Run Logic
    if is_child {
        // --- CHILD MODE ---
        info!("Mode: Child Process (IPC)");

        #[cfg(not(unix))]
        {
            error!("Child process mode requires Unix socketpair transport on this build.");
            std::process::exit(1);
        }

        #[cfg(unix)]
        {
            // In child mode, we use a dedicated local rule engine for the single proxy
            let rule_engine = Arc::new(RwLock::new(RuleEngine::new(vec![])));

            let process_server = NitellaProcessServer::new(
                rule_engine.clone(),
                geoip.clone(),
                stats.clone(),
                event_tx.clone(),
            );

            if let Some(unix_stream) = synurang::get_ipc_transport() {
                // Use a channel to create a stream that yields the connection once and then stays open
                // This prevents the server from shutting down immediately after accepting the connection
                let (tx, rx) = tokio::sync::mpsc::channel(1);
                if let Err(e) = tx.send(Ok::<_, std::io::Error>(unix_stream)).await {
                    error!("Failed to send stream to channel: {}", e);
                }

                // Spawn a task to hold the sender open indefinitely so the stream doesn't close
                tokio::spawn(async move {
                    let _tx = tx;
                    std::future::pending::<()>().await;
                });

                let stream = tokio_stream::wrappers::ReceiverStream::new(rx);
                info!("Synurang IPC: Serving gRPC process control... awaiting server");

                let serve_result = Server::builder()
                    .add_service(ProcessControlServer::new(process_server))
                    .serve_with_incoming(stream)
                    .await;

                match serve_result {
                    Ok(_) => {
                        info!("Server finished successfully (but it should have run forever?)")
                    }
                    Err(e) => error!("Server exited with error: {}", e),
                }

                // IMPORTANT: In child mode, we must exit after server finishes.
                return Ok(());
            } else {
                error!("Failed to initialize Synurang IPC.");
                std::process::exit(1);
            }
        }
    } else {
        // --- STANDALONE / FULL MODE ---
        info!("Mode: Full/Standalone");

        // 4. Initialize Proxy Manager
        let manager = Arc::new(ProxyManager::new(
            geoip.clone(),
            global_rules.clone(),
            stats.clone(),
            db.clone(),
            args.process_mode,
            approval_manager.clone(),
        ));

        // Restore state from DB only when DB mode is active. In config mode Go
        // uses the YAML file as the sole startup source.
        if db.is_some() {
            if let Err(e) = manager.load_state().await {
                error!("Failed to restore state: {}", e);
            }
        }

        // 5. Load YAML Config
        if let Some(cfg_path) = &args.config {
            match config::load_config(cfg_path).await {
                Ok(yaml) => {
                    info!("Loaded YAML config from {}", cfg_path);
                    if let Some(eps) = &yaml.entry_points {
                        for (name, ep) in eps {
                            let resolved = yaml.resolve_entry_point(name, ep);
                            let security = resolve_entrypoint_tls(
                                ep,
                                &cert_pem,
                                &key_pem,
                                &ca_pem,
                                client_auth_type,
                            );
                            let rate_limit = match config::rate_limit_to_proto(&ep.rate_limit) {
                                Ok(rate_limit) => rate_limit,
                                Err(e) => {
                                    error!("Invalid rateLimit for entryPoint {}: {}", name, e);
                                    std::process::exit(1);
                                }
                            };

                            // Map default_action string to ActionType enum
                            let action_type = action_type_from_str(&ep.default_action)
                                .unwrap_or(ActionType::Allow as i32);

                            // Map default_mock string to MockPreset enum
                            let mock_preset = string_to_mock_preset(&ep.default_mock);

                            // Map fallback_action string to FallbackAction enum
                            let fallback_action = fallback_action_from_str(&ep.fallback_action)
                                .unwrap_or(FallbackAction::Unspecified as i32);

                            let fallback_mock = string_to_mock_preset(&ep.fallback_mock);

                            info!(
                                "[Config] CreateProxy {}: Addr={}, Action={} (from YAML: {})",
                                name, ep.address, action_type, ep.default_action
                            );

                            let req = CreateProxyRequest {
                                name: name.clone(),
                                listen_addr: ep.address.clone(),
                                default_backend: resolved.default_backend.clone(),
                                default_action: action_type,
                                default_mock: mock_preset,
                                fallback_action,
                                fallback_mock,
                                cert_pem: security.cert_pem,
                                key_pem: security.key_pem,
                                ca_pem: security.ca_pem,
                                client_auth_type: security.client_auth_type,
                                health_check: resolved
                                    .health_check
                                    .as_ref()
                                    .map(config::health_check_to_proto),
                                ..Default::default()
                            };
                            match manager.create_proxy(req).await {
                                Ok(proxy_id) => {
                                    add_initial_default_rule(
                                        &manager,
                                        &proxy_id,
                                        action_type,
                                        mock_preset,
                                        rate_limit,
                                    )
                                    .await;
                                    add_yaml_middleware_rules(
                                        &manager,
                                        &proxy_id,
                                        resolved.middleware_mocks,
                                        resolved.router_priority,
                                    )
                                    .await;
                                }
                                Err(e) => {
                                    error!("Failed to start config proxy: {}", e);
                                }
                            }
                        }
                    }
                }
                Err(e) => {
                    error!("Failed to load config file: {}", e);
                    std::process::exit(1);
                }
            }
        }

        // 6. Start Health Checker
        let health_checker = HealthChecker::new(manager.clone());
        tokio::spawn(async move {
            health_checker.run().await;
        });

        // C. Start Initial Proxy from Flags before Hub startup, matching Go's
        // startup order: configured local listeners exist before hub commands
        // can observe the node.
        if args.config.is_none() {
            let cli_default_action = match action_type_from_str(&args.default_action) {
                Some(action) => action,
                None => {
                    eprintln!(
                        "Error: Invalid --default-action {} (want allow, block, mock, approval, require_approval)",
                        args.default_action
                    );
                    std::process::exit(1);
                }
            };
            let allow_ips = normalize_source_ip_values(&args.allow_ip);
            let block_ips = normalize_source_ip_values(&args.block_ip);
            let allow_countries = normalize_country_values(&args.allow_country);
            let block_countries = normalize_country_values(&args.block_country);

            if let Some(backend) = args.backend {
                let req = CreateProxyRequest {
                    name: args.name.unwrap_or("cli-default".to_string()),
                    listen_addr: args.listen.clone(),
                    default_backend: backend,
                    default_action: cli_default_action,
                    fallback_action: cli_fallback_action,
                    fallback_mock: cli_fallback_mock,
                    cert_pem,
                    key_pem,
                    ca_pem,
                    client_auth_type,
                    ..Default::default()
                };

                match manager.create_proxy(req).await {
                    Ok(proxy_id) => {
                        add_initial_default_rule(
                            &manager,
                            &proxy_id,
                            cli_default_action,
                            MockPreset::Unspecified as i32,
                            cli_rate_limit.clone(),
                        )
                        .await;
                        add_startup_ip_rules(&manager, &proxy_id, &allow_ips, &block_ips).await;
                        add_startup_country_rules(
                            &manager,
                            &proxy_id,
                            &allow_countries,
                            &block_countries,
                        )
                        .await;
                    }
                    Err(e) => {
                        error!("Failed to start initial proxy: {}", e);
                        std::process::exit(1);
                    }
                }
            } else if args.hub.is_none() {
                eprintln!(
                    "Error: No backend specified. Use --backend, --config, or --hub with pairing."
                );
                std::process::exit(1);
            }
        }

        // A. Start Hub Client
        if let Some(ref hub_addr) = args.hub {
            info!("Initializing Hub Client: {}", hub_addr);
            let node_name = args.hub_node_name.clone().unwrap_or_else(|| {
                gethostname::gethostname()
                    .into_string()
                    .unwrap_or_else(|_| "nitellad-node".to_string())
            });

            // Subscribe to events for Alerts
            let event_rx = event_tx.subscribe();

            let mut hub_client = HubClient::new(
                hub_addr.clone(),
                args.hub_data_dir.clone().unwrap(),
                node_name,
                manager.clone(),
                args.stun.clone(),
                args.hub_ca.clone(),
                Some(event_rx),
            )
            .with_user_id(args.hub_user_id.clone())
            .with_p2p(args.hub_p2p);
            let pair_code = args.pair.clone();

            tokio::spawn(async move {
                // First run: use pairing code if provided
                if let Err(e) = hub_client.run(pair_code).await {
                    error!("Hub client error: {}", e);
                }
                // Reconnect loop (matching Go's Client.Start())
                loop {
                    warn!("Hub disconnected. Reconnecting in 5s...");
                    tokio::time::sleep(std::time::Duration::from_secs(5)).await;
                    if let Err(e) = hub_client.run(None).await {
                        error!("Hub reconnect error: {}", e);
                    }
                }
            });
        }

        // B. Start Admin Server with TLS & Auth
        if args.admin_port > 0 {
            let addr = format!("0.0.0.0:{}", args.admin_port).parse()?;

            let admin_dir = if let Some(dir) = args.admin_data_dir {
                dir
            } else if let Some(db_path) = args.db_path.as_deref() {
                let p = std::path::Path::new(db_path);
                match p.parent() {
                    Some(parent) if parent.as_os_str().is_empty() => ".".to_string(),
                    Some(parent) => parent.to_string_lossy().to_string(),
                    None => ".".to_string(),
                }
            } else {
                ".".to_string()
            };

            info!("Admin Data Directory: {}", admin_dir);

            // Check for admin token (required for security)
            let token = args.admin_token.clone().unwrap_or_else(|| {
                // If not provided, generate one? Go version generates random.
                let mut bytes = [0u8; 16];
                rand::thread_rng().fill_bytes(&mut bytes);
                let t = hex::encode(bytes);
                warn!("Generated Admin Token: {}", t);
                t
            });

            match admin_security::ensure_admin_certs(&admin_dir).await {
                Ok((cert_path, key_path)) => {
                    info!("Admin API listening on {} (TLS)", addr);

                    let cert = std_fs::read(&cert_path)?;
                    let key = std_fs::read(&key_path)?;
                    let identity = Identity::from_pem(cert, key);

                    // Load Admin Identity Keys from CA key (admin_ca.key) - Client uses CA Cert Key for E2E!
                    let ca_key_path = std::path::Path::new(&admin_dir).join("admin_ca.key");
                    let key_pem_str = std_fs::read_to_string(&ca_key_path)?;
                    let signing_key = SigningKey::from_pkcs8_pem(&key_pem_str).map_err(|e| {
                        std::io::Error::new(
                            std::io::ErrorKind::InvalidData,
                            format!("Failed to parse admin_ca.key as Ed25519: {}", e),
                        )
                    })?;
                    let verifying_key = signing_key.verifying_key();

                    let admin_server = AdminServer::new(
                        manager.clone(),
                        global_rules.clone(),
                        signing_key,
                        verifying_key,
                        event_tx.clone(),
                    );
                    let token_clone = token.clone();

                    let service = ProxyControlServiceServer::with_interceptor(
                        admin_server,
                        move |req: Request<()>| {
                            // Check "Authorization: Bearer <token>" header
                            if let Some(val) = req.metadata().get("authorization") {
                                if let Ok(s) = val.to_str() {
                                    if let Some(bearer_token) = s.strip_prefix("Bearer ") {
                                        if bearer_token == token_clone {
                                            return Ok(req);
                                        }
                                    }
                                    // Also accept raw token for backwards compatibility
                                    if s == token_clone {
                                        return Ok(req);
                                    }
                                }
                            }
                            // Check custom header (mobile app)
                            if let Some(val) = req.metadata().get("x-nitella-token") {
                                if val == &token_clone {
                                    return Ok(req);
                                }
                            }
                            Err(Status::unauthenticated("Invalid token"))
                        },
                    );

                    tokio::spawn(async move {
                        if let Err(e) = Server::builder()
                            .tls_config(ServerTlsConfig::new().identity(identity))
                            .expect("Failed to config TLS")
                            .add_service(service)
                            .serve(addr)
                            .await
                        {
                            error!("Admin server error: {}", e);
                        }
                    });
                }
                Err(e) => error!("Failed to setup Admin TLS: {}", e),
            }
        }

        wait_for_shutdown().await?;
    }

    Ok(())
}

#[cfg(unix)]
async fn wait_for_shutdown() -> Result<(), Box<dyn std::error::Error>> {
    use tokio::signal::unix::{signal, SignalKind};

    let mut term = signal(SignalKind::terminate())?;

    tokio::select! {
        _ = tokio::signal::ctrl_c() => {
            info!("Received Ctrl-C, shutting down...");
        },
        _ = term.recv() => {
            info!("Received SIGTERM, shutting down...");
        }
    }
    Ok(())
}

#[cfg(not(unix))]
async fn wait_for_shutdown() -> Result<(), Box<dyn std::error::Error>> {
    tokio::signal::ctrl_c().await?;
    info!("Received Ctrl-C, shutting down...");
    Ok(())
}

/// Convert a string mock preset name to the protobuf MockPreset enum value.
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

fn fallback_action_from_str(action: &str) -> Option<i32> {
    match action.trim().to_ascii_lowercase().as_str() {
        "" => Some(FallbackAction::Unspecified as i32),
        "close" => Some(FallbackAction::Close as i32),
        "mock" => Some(FallbackAction::Mock as i32),
        _ => None,
    }
}

fn cli_fallback_args_present(args: &Args) -> bool {
    args.fallback_action.is_some() || args.fallback_mock.is_some()
}

fn build_cli_fallback_config(
    action: Option<&str>,
    mock: Option<&str>,
) -> Result<(i32, i32), Box<dyn std::error::Error>> {
    if action.is_none() && mock.is_none() {
        return Ok((
            FallbackAction::Unspecified as i32,
            MockPreset::Unspecified as i32,
        ));
    }

    let fallback_action = fallback_action_from_str(action.unwrap_or(""))
        .ok_or("--fallback-action must be close or mock")?;

    let fallback_mock = match mock {
        Some(value) if !value.trim().is_empty() => {
            let preset = string_to_mock_preset(value);
            if preset == MockPreset::Unspecified as i32 {
                return Err(format!("unknown --fallback-mock preset {value:?}").into());
            }
            preset
        }
        _ => MockPreset::Unspecified as i32,
    };

    if mock.is_some() && fallback_action != FallbackAction::Mock as i32 {
        return Err("--fallback-mock requires --fallback-action mock".into());
    }
    if fallback_action == FallbackAction::Mock as i32
        && fallback_mock == MockPreset::Unspecified as i32
    {
        return Err("--fallback-action mock requires --fallback-mock".into());
    }

    Ok((fallback_action, fallback_mock))
}

#[derive(Debug, Default)]
struct CliRateLimitOptions {
    max_connections: Option<i32>,
    interval_seconds: Option<i32>,
    auto_block: Option<bool>,
    block_duration_seconds: Option<i32>,
    block_steps_seconds: Option<String>,
    count_only_failures: bool,
    failure_duration_threshold: Option<i32>,
}

fn cli_rate_limit_options_from_args(args: &Args) -> CliRateLimitOptions {
    CliRateLimitOptions {
        max_connections: args.rate_limit_max_connections,
        interval_seconds: args.rate_limit_interval,
        auto_block: args.rate_limit_auto_block,
        block_duration_seconds: args.rate_limit_block_duration,
        block_steps_seconds: args.rate_limit_block_steps.clone(),
        count_only_failures: args.rate_limit_count_only_failures,
        failure_duration_threshold: args.rate_limit_failure_threshold,
    }
}

fn cli_rate_limit_args_present(args: &Args) -> bool {
    cli_rate_limit_options_from_args(args).has_any_setting()
}

impl CliRateLimitOptions {
    fn has_any_setting(&self) -> bool {
        self.max_connections.is_some()
            || self.interval_seconds.is_some()
            || self.auto_block.is_some()
            || self.block_duration_seconds.is_some()
            || self.block_steps_seconds.is_some()
            || self.count_only_failures
            || self.failure_duration_threshold.is_some()
    }
}

fn build_cli_rate_limit_config(
    options: CliRateLimitOptions,
) -> Result<Option<RateLimitConfig>, Box<dyn std::error::Error>> {
    if !options.has_any_setting() {
        return Ok(None);
    }

    let Some(max_connections) = options.max_connections else {
        return Err(
            "--rate-limit-max-connections must be greater than 0 when rate-limit flags are used"
                .into(),
        );
    };
    if max_connections <= 0 {
        return Err(
            "--rate-limit-max-connections must be greater than 0 when rate-limit flags are used"
                .into(),
        );
    }

    let interval_seconds = options.interval_seconds.unwrap_or(60);
    if interval_seconds <= 0 {
        return Err("--rate-limit-interval must be greater than 0".into());
    }

    let block_duration_seconds = options.block_duration_seconds.unwrap_or(600);
    if block_duration_seconds < 0 {
        return Err("--rate-limit-block-duration cannot be negative".into());
    }

    let block_steps_seconds = parse_rate_limit_block_steps(options.block_steps_seconds.as_deref())?;

    if let Some(threshold) = options.failure_duration_threshold {
        if threshold < 0 {
            return Err("--rate-limit-failure-threshold cannot be negative".into());
        }
        if !options.count_only_failures {
            return Err(
                "--rate-limit-failure-threshold requires --rate-limit-count-only-failures".into(),
            );
        }
    }

    let failure_duration_threshold = if options.count_only_failures {
        options.failure_duration_threshold.unwrap_or(1)
    } else {
        0
    };

    Ok(Some(RateLimitConfig {
        max_connections,
        interval_seconds,
        auto_block: options.auto_block.unwrap_or(true),
        block_duration_seconds,
        block_steps_seconds,
        count_only_failures: options.count_only_failures,
        failure_duration_threshold,
    }))
}

fn parse_rate_limit_block_steps(
    value: Option<&str>,
) -> Result<Vec<i32>, Box<dyn std::error::Error>> {
    let Some(value) = value else {
        return Ok(Vec::new());
    };
    let value = value.trim();
    if value.is_empty() {
        return Ok(Vec::new());
    }

    let mut steps = Vec::new();
    for part in value.split(',') {
        let part = part.trim();
        if part.is_empty() {
            continue;
        }
        let seconds: i32 = match part.parse() {
            Ok(seconds) => seconds,
            Err(_) => {
                return Err(
                    format!("--rate-limit-block-steps contains invalid duration {part:?}").into(),
                )
            }
        };
        if seconds < 0 {
            return Err("--rate-limit-block-steps cannot contain negative values".into());
        }
        steps.push(seconds);
    }
    Ok(steps)
}

async fn add_initial_default_rule(
    manager: &Arc<ProxyManager>,
    proxy_id: &str,
    default_action: i32,
    default_mock: i32,
    rate_limit: Option<RateLimitConfig>,
) {
    let rule = initial_default_rule(default_action, default_mock, rate_limit);
    if let Err(e) = manager.add_rule(proxy_id, rule).await {
        warn!("Failed to add __default rule to proxy {}: {}", proxy_id, e);
    }
}

async fn add_startup_country_rules(
    manager: &Arc<ProxyManager>,
    proxy_id: &str,
    allow_countries: &[String],
    block_countries: &[String],
) {
    for country in allow_countries {
        if let Err(e) = manager
            .add_rule(
                proxy_id,
                startup_country_rule(ActionType::Allow as i32, country),
            )
            .await
        {
            warn!(
                "Failed to add allow-country rule for {} to proxy {}: {}",
                country, proxy_id, e
            );
            continue;
        }
        info!("Rule: ALLOW country {}", country);
    }

    for country in block_countries {
        if let Err(e) = manager
            .add_rule(
                proxy_id,
                startup_country_rule(ActionType::Block as i32, country),
            )
            .await
        {
            warn!(
                "Failed to add block-country rule for {} to proxy {}: {}",
                country, proxy_id, e
            );
            continue;
        }
        info!("Rule: BLOCK country {}", country);
    }
}

async fn add_startup_ip_rules(
    manager: &Arc<ProxyManager>,
    proxy_id: &str,
    allow_ips: &[String],
    block_ips: &[String],
) {
    for ip in allow_ips {
        if let Err(e) = manager
            .add_rule(
                proxy_id,
                startup_source_ip_rule(ActionType::Allow as i32, ip),
            )
            .await
        {
            warn!(
                "Failed to add allow-ip rule for {} to proxy {}: {}",
                ip, proxy_id, e
            );
            continue;
        }
        info!("Rule: ALLOW IP {}", ip);
    }

    for ip in block_ips {
        if let Err(e) = manager
            .add_rule(
                proxy_id,
                startup_source_ip_rule(ActionType::Block as i32, ip),
            )
            .await
        {
            warn!(
                "Failed to add block-ip rule for {} to proxy {}: {}",
                ip, proxy_id, e
            );
            continue;
        }
        info!("Rule: BLOCK IP {}", ip);
    }
}

async fn add_yaml_middleware_rules(
    manager: &Arc<ProxyManager>,
    proxy_id: &str,
    middleware_mocks: Vec<(String, config::MockConfig)>,
    router_priority: i32,
) {
    for (name, mock) in middleware_mocks {
        let rule = Rule {
            id: uuid::Uuid::new_v4().to_string(),
            name: format!("__middleware:{}", name),
            priority: router_priority,
            enabled: true,
            action: ActionType::Mock as i32,
            mock_response: Some(config::mock_config_to_proto(&mock)),
            ..Default::default()
        };
        if let Err(e) = manager.add_rule(proxy_id, rule).await {
            warn!(
                "Failed to add YAML middleware rule {} to proxy {}: {}",
                name, proxy_id, e
            );
        }
    }
}

fn initial_default_rule(
    default_action: i32,
    default_mock: i32,
    rate_limit: Option<RateLimitConfig>,
) -> Rule {
    let action = normalize_default_action(default_action, default_mock);
    Rule {
        id: uuid::Uuid::new_v4().to_string(),
        name: "__default".to_string(),
        priority: -1000,
        enabled: true,
        action,
        rate_limit,
        mock_response: if action == ActionType::Mock as i32 {
            Some(MockConfig {
                preset: default_mock,
                ..Default::default()
            })
        } else {
            None
        },
        ..Default::default()
    }
}

fn startup_country_rule(action: i32, country: &str) -> Rule {
    startup_rule(
        action,
        "Country",
        country,
        ConditionType::GeoCountry as i32,
        Operator::Eq as i32,
    )
}

fn startup_source_ip_rule(action: i32, value: &str) -> Rule {
    startup_rule(
        action,
        "IP",
        value,
        ConditionType::SourceIp as i32,
        source_ip_operator(value),
    )
}

fn startup_rule(action: i32, label: &str, value: &str, condition_type: i32, op: i32) -> Rule {
    let (name_action, priority) = if action == ActionType::Block as i32 {
        ("Block", 110)
    } else {
        ("Allow", 100)
    };

    Rule {
        id: uuid::Uuid::new_v4().to_string(),
        name: format!("{} {} {}", name_action, label, value),
        priority,
        enabled: true,
        action,
        conditions: vec![Condition {
            r#type: condition_type,
            op,
            value: value.to_string(),
            ..Default::default()
        }],
        ..Default::default()
    }
}

fn source_ip_operator(value: &str) -> i32 {
    if value.contains('/') {
        Operator::Cidr as i32
    } else {
        Operator::Eq as i32
    }
}

fn action_type_from_str(action: &str) -> Option<i32> {
    match action.trim().to_ascii_lowercase().as_str() {
        "" | "allow" => Some(ActionType::Allow as i32),
        "block" => Some(ActionType::Block as i32),
        "mock" => Some(ActionType::Mock as i32),
        "approval" | "require_approval" | "require-approval" => {
            Some(ActionType::RequireApproval as i32)
        }
        _ => None,
    }
}

fn normalize_country_values(values: &[String]) -> Vec<String> {
    normalize_values(values, Some(normalize_country_value))
}

fn normalize_source_ip_values(values: &[String]) -> Vec<String> {
    let mut normalized = Vec::new();
    for value in values {
        for expanded in expand_source_ip_alias(value) {
            if expanded.is_empty() || normalized.iter().any(|existing| existing == &expanded) {
                continue;
            }
            normalized.push(expanded);
        }
    }
    normalized
}

fn expand_source_ip_alias(value: &str) -> Vec<String> {
    let trimmed = value.trim();
    match trimmed.to_ascii_lowercase().as_str() {
        "" => Vec::new(),
        "localhost" => vec!["127.0.0.0/8".to_string(), "::1/128".to_string()],
        "private" => vec![
            "10.0.0.0/8".to_string(),
            "172.16.0.0/12".to_string(),
            "192.168.0.0/16".to_string(),
            "fc00::/7".to_string(),
        ],
        "local" => vec![
            "127.0.0.0/8".to_string(),
            "::1/128".to_string(),
            "10.0.0.0/8".to_string(),
            "172.16.0.0/12".to_string(),
            "192.168.0.0/16".to_string(),
            "fc00::/7".to_string(),
            "169.254.0.0/16".to_string(),
            "fe80::/10".to_string(),
        ],
        _ => vec![trimmed.to_string()],
    }
}

fn normalize_values(values: &[String], normalize: Option<fn(&str) -> String>) -> Vec<String> {
    let mut normalized = Vec::new();
    for value in values {
        let value = match normalize {
            Some(normalize) => normalize(value),
            None => value.trim().to_string(),
        };
        if value.is_empty() || normalized.iter().any(|existing| existing == &value) {
            continue;
        }
        normalized.push(value);
    }
    normalized
}

fn normalize_country_value(value: &str) -> String {
    let trimmed = value.trim();
    if trimmed.len() == 2 {
        trimmed.to_ascii_uppercase()
    } else {
        trimmed.to_string()
    }
}

fn normalize_default_action(default_action: i32, default_mock: i32) -> i32 {
    if default_action == ActionType::Unspecified as i32 {
        if default_mock != MockPreset::Unspecified as i32 {
            ActionType::Mock as i32
        } else {
            ActionType::Allow as i32
        }
    } else {
        default_action
    }
}

struct ListenerSecurity {
    cert_pem: String,
    key_pem: String,
    ca_pem: String,
    client_auth_type: i32,
}

fn resolve_entrypoint_tls(
    ep: &config::EntryPoint,
    default_cert_pem: &str,
    default_key_pem: &str,
    default_ca_pem: &str,
    default_client_auth_type: i32,
) -> ListenerSecurity {
    let Some(tls) = &ep.tls else {
        return ListenerSecurity {
            cert_pem: default_cert_pem.to_string(),
            key_pem: default_key_pem.to_string(),
            ca_pem: default_ca_pem.to_string(),
            client_auth_type: default_client_auth_type,
        };
    };

    let cert_pem = if tls.cert_file.is_empty() {
        default_cert_pem.to_string()
    } else {
        read_optional_file(Some(&tls.cert_file), "entrypoint TLS certificate")
    };
    let key_pem = if tls.key_file.is_empty() {
        default_key_pem.to_string()
    } else {
        read_optional_file(Some(&tls.key_file), "entrypoint TLS private key")
    };
    let ca_pem = if tls.client_ca.is_empty() {
        default_ca_pem.to_string()
    } else {
        read_optional_file(Some(&tls.client_ca), "entrypoint TLS client CA")
    };

    let client_auth_type = match tls.client_auth.to_lowercase().as_str() {
        "none" => ClientAuthType::ClientAuthNone as i32,
        "optional" | "request" => ClientAuthType::ClientAuthRequest as i32,
        "require" | "required" | "mtls" => ClientAuthType::ClientAuthRequire as i32,
        "auto" => {
            if ca_pem.is_empty() {
                ClientAuthType::ClientAuthNone as i32
            } else {
                ClientAuthType::ClientAuthRequest as i32
            }
        }
        "" => {
            if !tls.client_ca.is_empty() {
                if ca_pem.is_empty() {
                    ClientAuthType::ClientAuthNone as i32
                } else {
                    ClientAuthType::ClientAuthRequest as i32
                }
            } else {
                default_client_auth_type
            }
        }
        other => {
            warn!(
                "Unknown entrypoint TLS clientAuth {:?}; using process default",
                other
            );
            default_client_auth_type
        }
    };

    ListenerSecurity {
        cert_pem,
        key_pem,
        ca_pem,
        client_auth_type,
    }
}

fn parse_go_duration(input: &str) -> Result<Duration, std::io::Error> {
    let s = input.trim();
    if s.is_empty() {
        return Err(invalid_duration(input, "duration cannot be empty"));
    }

    let bytes = s.as_bytes();
    let mut i = 0;
    let mut total_nanos = 0.0_f64;

    while i < bytes.len() {
        let start = i;
        let mut seen_digit = false;
        let mut seen_dot = false;

        while i < bytes.len() {
            let b = bytes[i];
            if b.is_ascii_digit() {
                seen_digit = true;
                i += 1;
            } else if b == b'.' && !seen_dot {
                seen_dot = true;
                i += 1;
            } else {
                break;
            }
        }

        if !seen_digit {
            return Err(invalid_duration(input, "expected duration number"));
        }

        let value = s[start..i]
            .parse::<f64>()
            .map_err(|_| invalid_duration(input, "invalid duration number"))?;
        if !value.is_finite() || value < 0.0 {
            return Err(invalid_duration(input, "invalid duration number"));
        }

        let rest = &s[i..];
        let factor = if rest.starts_with("ms") {
            i += 2;
            1_000_000.0
        } else if rest.starts_with("us") {
            i += 2;
            1_000.0
        } else if rest.starts_with("ns") {
            i += 2;
            1.0
        } else if rest.starts_with('h') {
            i += 1;
            60.0 * 60.0 * 1_000_000_000.0
        } else if rest.starts_with('m') {
            i += 1;
            60.0 * 1_000_000_000.0
        } else if rest.starts_with('s') {
            i += 1;
            1_000_000_000.0
        } else {
            return Err(invalid_duration(input, "missing or unknown duration unit"));
        };

        total_nanos += value * factor;
    }

    let max_nanos = (u64::MAX as f64) * 1_000_000_000.0;
    if !total_nanos.is_finite() || total_nanos > max_nanos {
        return Err(invalid_duration(input, "duration is too large"));
    }

    let total_nanos = total_nanos.round() as u128;
    let seconds = total_nanos / 1_000_000_000;
    let nanos = total_nanos % 1_000_000_000;
    if seconds > u64::MAX as u128 {
        return Err(invalid_duration(input, "duration is too large"));
    }

    Ok(Duration::new(seconds as u64, nanos as u32))
}

fn invalid_duration(input: &str, reason: &str) -> std::io::Error {
    std::io::Error::new(
        std::io::ErrorKind::InvalidInput,
        format!("invalid pair-timeout {:?}: {}", input, reason),
    )
}

fn read_optional_file(path: Option<&str>, label: &str) -> String {
    let Some(path) = path else {
        return String::new();
    };
    if path.is_empty() {
        return String::new();
    }
    match std_fs::read_to_string(path) {
        Ok(data) => data,
        Err(e) => {
            warn!("Failed to read {} {}: {}", label, path, e);
            String::new()
        }
    }
}

fn resolve_stats_db_path(config_path: Option<&str>, stats_db: Option<&str>) -> String {
    if let Some(path) = stats_db {
        if !path.is_empty() {
            return path.to_string();
        }
    }
    if let Some(path) = config_path {
        if !path.is_empty() {
            if let Some(parent) = Path::new(path).parent() {
                if !parent.as_os_str().is_empty() {
                    return parent.join("stats.db").to_string_lossy().to_string();
                }
            }
        }
    }
    "stats.db".to_string()
}

fn should_open_proxy_db(is_child: bool, config_path: Option<&str>, db_path: Option<&str>) -> bool {
    !is_child && config_path.unwrap_or("").is_empty() && !db_path.unwrap_or("").is_empty()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_go_duration_accepts_go_style_units() {
        assert_eq!(parse_go_duration("3m").unwrap(), Duration::from_secs(180));
        assert_eq!(parse_go_duration("90s").unwrap(), Duration::from_secs(90));
        assert_eq!(
            parse_go_duration("1h30m").unwrap(),
            Duration::from_secs(90 * 60)
        );
    }

    #[test]
    fn parse_go_duration_rejects_missing_unit() {
        assert!(parse_go_duration("90").is_err());
    }

    #[test]
    fn initial_default_rule_has_unique_id_and_mock_config() {
        let rule = initial_default_rule(
            ActionType::Mock as i32,
            MockPreset::Http403 as i32,
            Some(RateLimitConfig {
                max_connections: 3,
                ..Default::default()
            }),
        );
        assert!(!rule.id.is_empty());
        assert_eq!(rule.name, "__default");
        assert_eq!(rule.priority, -1000);
        assert_eq!(rule.action, ActionType::Mock as i32);
        assert_eq!(rule.rate_limit.as_ref().unwrap().max_connections, 3);
        assert_eq!(
            rule.mock_response.expect("mock response").preset,
            MockPreset::Http403 as i32
        );
    }

    #[test]
    fn cli_rate_limit_config_builds_fail2ban_policy() {
        let got = build_cli_rate_limit_config(CliRateLimitOptions {
            max_connections: Some(3),
            interval_seconds: Some(60),
            auto_block: Some(true),
            block_duration_seconds: Some(1800),
            count_only_failures: true,
            failure_duration_threshold: Some(20),
            ..Default::default()
        })
        .unwrap()
        .unwrap();

        assert_eq!(got.max_connections, 3);
        assert_eq!(got.interval_seconds, 60);
        assert!(got.auto_block);
        assert_eq!(got.block_duration_seconds, 1800);
        assert!(got.count_only_failures);
        assert_eq!(got.failure_duration_threshold, 20);
    }

    #[test]
    fn cli_rate_limit_config_rejects_threshold_without_failure_only_mode() {
        let err = build_cli_rate_limit_config(CliRateLimitOptions {
            max_connections: Some(3),
            failure_duration_threshold: Some(20),
            ..Default::default()
        })
        .unwrap_err();
        assert!(err.to_string().contains("count-only-failures"));
    }

    #[test]
    fn cli_rate_limit_auto_block_accepts_explicit_false() {
        let args = Args::try_parse_from([
            "nitellad-rs",
            "--backend",
            "127.0.0.1:3000",
            "--rate-limit-max-connections",
            "3",
            "--rate-limit-auto-block=false",
        ])
        .unwrap();
        assert_eq!(args.rate_limit_auto_block, Some(false));
    }

    #[test]
    fn cli_fallback_config_builds_mock_tarpit() {
        let (action, mock) = build_cli_fallback_config(Some("mock"), Some("ssh-tarpit")).unwrap();
        assert_eq!(action, FallbackAction::Mock as i32);
        assert_eq!(mock, MockPreset::SshTarpit as i32);
    }

    #[test]
    fn cli_fallback_config_rejects_mock_without_action() {
        let err = build_cli_fallback_config(None, Some("ssh-tarpit")).unwrap_err();
        assert!(err.to_string().contains("fallback-action"));
    }

    #[test]
    fn cli_country_rule_has_geo_country_condition_above_default() {
        let rule = startup_country_rule(ActionType::Allow as i32, "KR");
        assert!(!rule.id.is_empty());
        assert_eq!(rule.action, ActionType::Allow as i32);
        assert!(rule.priority > -1000);
        assert_eq!(rule.conditions.len(), 1);
        let cond = &rule.conditions[0];
        assert_eq!(cond.r#type, ConditionType::GeoCountry as i32);
        assert_eq!(cond.op, Operator::Eq as i32);
        assert_eq!(cond.value, "KR");
    }

    #[test]
    fn cli_country_values_are_trimmed_uppercased_and_deduped() {
        let values = vec![
            " kr ".to_string(),
            "JP".to_string(),
            "kr".to_string(),
            "South Korea".to_string(),
            " ".to_string(),
        ];
        assert_eq!(
            normalize_country_values(&values),
            vec![
                "KR".to_string(),
                "JP".to_string(),
                "South Korea".to_string()
            ]
        );
    }

    #[test]
    fn cli_ip_rule_uses_eq_or_cidr_operator() {
        let exact = startup_source_ip_rule(ActionType::Allow as i32, "127.0.0.1");
        let exact_cond = &exact.conditions[0];
        assert_eq!(exact_cond.r#type, ConditionType::SourceIp as i32);
        assert_eq!(exact_cond.op, Operator::Eq as i32);

        let cidr = startup_source_ip_rule(ActionType::Block as i32, "192.168.0.0/16");
        let cidr_cond = &cidr.conditions[0];
        assert_eq!(cidr.action, ActionType::Block as i32);
        assert_eq!(cidr_cond.r#type, ConditionType::SourceIp as i32);
        assert_eq!(cidr_cond.op, Operator::Cidr as i32);
    }

    #[test]
    fn cli_ip_values_are_trimmed_and_deduped() {
        let values = vec![
            " 127.0.0.1 ".to_string(),
            "192.168.0.0/16".to_string(),
            "127.0.0.1".to_string(),
            " ".to_string(),
        ];
        assert_eq!(
            normalize_values(&values, None),
            vec!["127.0.0.1".to_string(), "192.168.0.0/16".to_string()]
        );
    }

    #[test]
    fn cli_ip_values_expand_standalone_aliases() {
        let values = vec![
            "localhost".to_string(),
            "private".to_string(),
            "local".to_string(),
            "127.0.0.1".to_string(),
            "private".to_string(),
        ];
        assert_eq!(
            normalize_source_ip_values(&values),
            vec![
                "127.0.0.0/8".to_string(),
                "::1/128".to_string(),
                "10.0.0.0/8".to_string(),
                "172.16.0.0/12".to_string(),
                "192.168.0.0/16".to_string(),
                "fc00::/7".to_string(),
                "169.254.0.0/16".to_string(),
                "fe80::/10".to_string(),
                "127.0.0.1".to_string(),
            ]
        );
    }

    #[test]
    fn action_type_from_str_accepts_cli_aliases() {
        assert_eq!(
            action_type_from_str("require_approval"),
            Some(ActionType::RequireApproval as i32)
        );
        assert_eq!(
            action_type_from_str("require-approval"),
            Some(ActionType::RequireApproval as i32)
        );
        assert_eq!(action_type_from_str("bad"), None);
    }

    #[test]
    fn proxy_db_is_disabled_for_config_and_child_modes() {
        assert!(!should_open_proxy_db(false, None, None));
        assert!(!should_open_proxy_db(false, Some(""), None));
        assert!(should_open_proxy_db(false, None, Some("nitella.db")));
        assert!(should_open_proxy_db(false, Some(""), Some("nitella.db")));
        assert!(!should_open_proxy_db(
            false,
            Some("proxy.yaml"),
            Some("nitella.db")
        ));
        assert!(!should_open_proxy_db(true, None, Some("nitella.db")));
        assert!(!should_open_proxy_db(
            true,
            Some("proxy.yaml"),
            Some("nitella.db")
        ));
    }
}
