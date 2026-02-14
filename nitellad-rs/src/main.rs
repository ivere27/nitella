use clap::Parser;
use ed25519_dalek::{
    pkcs8::{DecodePrivateKey, EncodePrivateKey},
    SigningKey, VerifyingKey,
};
use rand::RngCore;
use std::fs as std_fs;
use std::sync::Arc;
use tokio::sync::{broadcast, RwLock};
use tonic::transport::{Identity, Server, ServerTlsConfig};
use tonic::{Request, Status};
use tracing::{error, info, warn, Level};
use tracing_subscriber::FmtSubscriber;

// Use library crate's proto and modules
use nitella::proto;
use nitella::{
    admin, admin_security, config, db, geoip, health, hub, manager, pairing_offline, rules, server,
    stats, synurang,
};

use admin::AdminServer;
use db::Database;
use geoip::GeoIPService;
use health::HealthChecker;
use hub::HubClient;
use manager::ProxyManager;
use nitella::approval::ApprovalManager;
use pairing_offline::OfflinePairing;
use proto::common::{ActionType, FallbackAction, MockPreset};
use proto::process::process_control_server::ProcessControlServer;
use proto::proxy::proxy_control_service_server::ProxyControlServiceServer;
use proto::proxy::CreateProxyRequest;
use rules::RuleEngine;
use server::NitellaProcessServer;
use stats::StatsService;

/// Nitella Proxy Daemon (Rust Implementation)
#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    // --- Proxy Options ---
    /// Listen address for proxy
    #[arg(long, default_value = "0.0.0.0:8080")]
    listen: String,

    /// Default backend address
    #[arg(long)]
    backend: Option<String>,

    /// Path to YAML config file
    #[arg(long)]
    config: Option<String>,

    /// Path to SQLite database (default "nitella.db")
    #[arg(long, default_value = "nitella.db")]
    db_path: String,

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
    #[arg(long, default_value_t = true)]
    hub_p2p: bool,

    /// Use QR code pairing mode
    #[arg(long)]
    hub_qr_mode: bool,

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
    #[arg(long)]
    geoip_cache: Option<String>,

    /// GeoIP L2 Cache TTL in hours
    #[arg(long)]
    geoip_cache_ttl: Option<i32>,

    /// Lookup strategy order
    #[arg(long)]
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

    info!("Nitella Proxy Daemon (Rust) starting...");

    // 0. Handle Offline Pairing
    if args.pair_offline {
        let node_name = args.hub_node_name.clone().unwrap_or_else(|| {
            gethostname::gethostname()
                .into_string()
                .unwrap_or_else(|_| "nitellad-node".to_string())
        });
        let pairing = OfflinePairing::new(args.hub_data_dir.clone().unwrap(), node_name);

        let port = if let Some(p_str) = args.pair_port.as_deref() {
            Some(p_str.parse::<u16>()?)
        } else {
            None
        };

        match pairing.run(port).await {
            Ok(_) => info!("Offline pairing completed successfully."),
            Err(e) => error!("Offline pairing failed: {}", e),
        }
        return Ok(());
    }

    // 1. Initialize DB
    let db = match Database::new(&args.db_path).await {
        Ok(d) => Some(d),
        Err(e) => {
            warn!(
                "Failed to init DB persistence: {}. Running in-memory only.",
                e
            );
            None
        }
    };

    // 2. Initialize Shared Services
    let geoip = Arc::new(
        GeoIPService::new(
            args.geoip_city.clone(),
            args.geoip_isp.clone(),
            args.geoip_addr
                .clone()
                .or_else(|| Some("https://ip-api.com/json".to_string())),
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
    let stats = Arc::new(StatsService::new(event_tx.clone()));

    // 7. Run Logic
    if is_child {
        // --- CHILD MODE ---
        info!("Mode: Child Process (IPC)");

        // In child mode, we use a dedicated local rule engine for the single proxy
        let rule_engine = Arc::new(RwLock::new(RuleEngine::new(vec![])));

        let process_server = NitellaProcessServer::new(
            rule_engine.clone(),
            geoip.clone(),
            stats.clone(),
            event_tx.clone(),
        );

        #[cfg(unix)]
        {
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

        // Restore state from DB
        if let Err(e) = manager.load_state().await {
            error!("Failed to restore state: {}", e);
        }

        // 5. Load YAML Config
        if let Some(cfg_path) = &args.config {
            match config::load_config(cfg_path).await {
                Ok(yaml) => {
                    info!("Loaded YAML config from {}", cfg_path);
                    if let Some(eps) = yaml.entry_points {
                        for (name, ep) in eps {
                            let mut default_backend = ep.default_backend.clone();

                            // Try to resolve backend from TCP routers if not specified
                            if default_backend.is_empty() {
                                if let Some(tcp) = &yaml.tcp {
                                    if let Some(routers) = &tcp.routers {
                                        for (_, router) in routers {
                                            if router.entry_points.contains(&name)
                                                && !router.service.is_empty()
                                            {
                                                if let Some(services) = &tcp.services {
                                                    if let Some(svc) = services.get(&router.service)
                                                    {
                                                        if let Some(lb) = &svc.load_balancer {
                                                            if let Some(server) = lb.servers.first()
                                                            {
                                                                if !server.address.is_empty() {
                                                                    default_backend =
                                                                        server.address.clone();
                                                                } else {
                                                                    default_backend =
                                                                        server.url.clone();
                                                                }
                                                                if lb.servers.len() > 1 {
                                                                    warn!("[Config] Service '{}' defines multiple servers, but load balancing is not supported yet. Using first server: {}", router.service, default_backend);
                                                                }
                                                            }
                                                        } else if let Some(addr) = &svc.address {
                                                            default_backend = addr.clone();
                                                        }
                                                    }
                                                }
                                                break;
                                            }
                                        }
                                    }
                                }
                            }

                            // Map default_action string to ActionType enum
                            let action_type = match ep.default_action.to_lowercase().as_str() {
                                "block" => ActionType::Block as i32,
                                "mock" => ActionType::Mock as i32,
                                "approval" => ActionType::RequireApproval as i32,
                                _ => ActionType::Allow as i32,
                            };

                            // Map default_mock string to MockPreset enum
                            let mock_preset = string_to_mock_preset(&ep.default_mock);

                            // Map fallback_action string to FallbackAction enum
                            let fallback_action = match ep.fallback_action.to_lowercase().as_str() {
                                "mock" => FallbackAction::Mock as i32,
                                "close" => FallbackAction::Close as i32,
                                _ => FallbackAction::Unspecified as i32,
                            };

                            let fallback_mock = string_to_mock_preset(&ep.fallback_mock);

                            info!(
                                "[Config] CreateProxy {}: Addr={}, Action={} (from YAML: {})",
                                name, ep.address, action_type, ep.default_action
                            );

                            let req = CreateProxyRequest {
                                name: name.clone(),
                                listen_addr: ep.address,
                                default_backend,
                                default_action: action_type,
                                default_mock: mock_preset,
                                fallback_action,
                                fallback_mock,
                                ..Default::default()
                            };
                            if let Err(e) = manager.create_proxy(req).await {
                                error!("Failed to start config proxy: {}", e);
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
            } else {
                let p = std::path::Path::new(&args.db_path);
                match p.parent() {
                    Some(parent) if parent.as_os_str().is_empty() => ".".to_string(),
                    Some(parent) => parent.to_string_lossy().to_string(),
                    None => ".".to_string(),
                }
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

        // C. Start Initial Proxy from Flags
        if let Some(backend) = args.backend {
            let req = CreateProxyRequest {
                name: args.name.unwrap_or("cli-default".to_string()),
                listen_addr: args.listen.clone(),
                default_backend: backend,
                cert_pem: args.tls_cert.unwrap_or_default(),
                key_pem: args.tls_key.unwrap_or_default(),
                ca_pem: args.tls_ca.unwrap_or_default(),
                ..Default::default()
            };

            if let Err(e) = manager.create_proxy(req).await {
                error!("Failed to start initial proxy: {}", e);
                std::process::exit(1);
            }
        } else if args.hub.is_none() && args.config.is_none() && args.admin_port == 0 {
            eprintln!("Error: No backend, config, conn-hub or admin-port specified.");
            std::process::exit(1);
        }

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
    }

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
