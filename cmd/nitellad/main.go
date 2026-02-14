package main

import (
	"crypto/ed25519"
	"crypto/rand"
	"encoding/hex"
	"flag"
	"fmt"
	"net"
	"os"
	"os/signal"
	"path/filepath"
	"strings"
	"syscall"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	geoip_pb "github.com/ivere27/nitella/pkg/api/geoip"
	pb "github.com/ivere27/nitella/pkg/api/proxy"
	cfgpkg "github.com/ivere27/nitella/pkg/config"
	"github.com/ivere27/nitella/pkg/geoip"
	"github.com/ivere27/nitella/pkg/identity"
	"github.com/ivere27/nitella/pkg/log"
	"github.com/ivere27/nitella/pkg/node"
	"github.com/ivere27/nitella/pkg/node/admincert"
	"github.com/ivere27/nitella/pkg/node/stats"
	nitellaPprof "github.com/ivere27/nitella/pkg/pprof"
	"github.com/ivere27/nitella/pkg/server"
	"github.com/ivere27/synurang/pkg/synurang"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
)

var (
	tlsCert *string
	tlsKey  *string
	tlsCA   *string
	mtls    *bool
)

func main() {
	// Check for child mode (subcommand)
	if len(os.Args) > 1 && os.Args[0] != "child" && os.Args[1] == "child" {
		runChild()
		return
	}

	// Proxy flags
	configFile := flag.String("config", "", "Path to YAML config file")
	listenAddr := flag.String("listen", ":8080", "Listen address for proxy")
	backendTarget := flag.String("backend", "", "Default backend address")
	dbPath := flag.String("db-path", "nitella.db", "Path to SQLite database")
	statsDB := flag.String("stats-db", "", "Path to statistics database (default: same dir as config)")
	processMode := flag.Bool("process-mode", false, "Run each proxy as a separate child process (for isolation)")
	adminDataDir := flag.String("admin-data-dir", "", "Data directory for admin API certificates (default: same as db-path directory)")

	// GeoIP flags
	geoipCity := flag.String("geoip-city", "", "Path to GeoIP2 City DB")
	geoipIsp := flag.String("geoip-isp", "", "Path to GeoIP2 ISP DB")
	geoipCache := flag.String("geoip-cache", "geoip_cache.db", "Path to GeoIP L2 Cache (SQLite)")
	geoipCacheTTL := flag.Int("geoip-cache-ttl", 24, "GeoIP L2 Cache TTL in hours (0 = permanent)")
	geoipStrategy := flag.String("geoip-strategy", "l1,l2,local,remote", "Lookup strategy order")
	geoipTimeout := flag.Int("geoip-timeout", 3000, "GeoIP Remote Provider timeout in milliseconds")
	geoipAddr := flag.String("geoip-addr", "", "Address of external GeoIP service")

	// TLS flags (package-level for hub.go access)
	tlsCert = flag.String("tls-cert", "", "Path to TLS Certificate")
	tlsKey = flag.String("tls-key", "", "Path to TLS Private Key")
	tlsCA = flag.String("tls-ca", "", "Path to Client CA Certificate")
	mtls = flag.Bool("mtls", false, "Require Client Certificates (mTLS)")

	// Admin API flags
	adminPort := flag.Int("admin-port", 0, "Port for Admin gRPC API (0 = disabled)")
	adminToken := flag.String("admin-token", os.Getenv("NITELLA_TOKEN"), "Authentication token for Admin API (env: NITELLA_TOKEN)")

	// Profiling flags (only effective with -tags pprof)
	pprofPort := flag.Int("pprof-port", 0, "Port for pprof HTTP server (0 = disabled, requires -tags pprof build)")

	flag.Parse()
	nitellaPprof.Start(*pprofPort)

	log.Println("Nitella Proxy Daemon starting...")

	// Load config file if specified
	var yamlConfig *cfgpkg.YAMLConfig
	if *configFile != "" {
		ext := strings.ToLower(filepath.Ext(*configFile))
		if ext == ".yaml" || ext == ".yml" {
			var err error
			yamlConfig, err = cfgpkg.LoadYAMLConfig(*configFile)
			if err != nil {
				log.Fatalf("Failed to load YAML config: %v", err)
			}
			log.Printf("Loaded YAML config from %s", *configFile)
		} else {
			log.Fatalf("Unsupported config format: %s (only .yaml/.yml supported)", ext)
		}
	}

	// Load TLS files
	loadFile := func(path string) string {
		if path == "" {
			return ""
		}
		data, err := os.ReadFile(path)
		if err != nil {
			log.Printf("[WARN] Failed to read file %s: %v", path, err)
			return ""
		}
		return string(data)
	}

	certPEM := loadFile(*tlsCert)
	keyPEM := loadFile(*tlsKey)
	caPEM := loadFile(*tlsCA)

	clientAuth := pb.ClientAuthType_CLIENT_AUTH_NONE
	if *mtls {
		clientAuth = pb.ClientAuthType_CLIENT_AUTH_REQUIRE
	} else if caPEM != "" {
		clientAuth = pb.ClientAuthType_CLIENT_AUTH_REQUEST
	}

	// Initialize GeoIP
	var geoIPClient geoip.GeoIPClient
	if *geoipAddr != "" {
		log.Printf("Connecting to external GeoIP service at %s...", *geoipAddr)
		client, err := geoip.NewRemoteClient(*geoipAddr, "") // Uses system CA pool
		if err != nil {
			log.Fatalf("Failed to connect to GeoIP service: %v", err)
		}
		geoIPClient = client
	} else {
		geoipManager := geoip.NewManager()
		if *geoipTimeout > 0 {
			geoipManager.SetTimeout(time.Duration(*geoipTimeout) * time.Millisecond)
		}
		if *geoipStrategy != "" {
			strategies := []string{}
			for _, s := range strings.Split(*geoipStrategy, ",") {
				s = strings.TrimSpace(s)
				if s != "" {
					strategies = append(strategies, s)
				}
			}
			if len(strategies) > 0 {
				geoipManager.SetStrategy(strategies)
			}
		}
		if *geoipCache != "" {
			if err := geoipManager.InitL2(*geoipCache, *geoipCacheTTL); err != nil {
				log.Printf("Warning: Failed to init GeoIP L2 cache: %v", err)
			}
		}
		if *geoipCity != "" || *geoipIsp != "" {
			if err := geoipManager.SetLocalDB(*geoipCity, *geoipIsp); err != nil {
				log.Printf("Warning: Failed to init GeoIP local DB: %v", err)
			}
		} else {
			// Use HTTPS remote providers
			geoipManager.AddRemoteProvider("ip-whois", "https://ipwhois.app/json/%s")
			geoipManager.AddRemoteProvider("free-ip-api", "https://freeipapi.com/api/json/%s")
			log.Println("[INFO] GeoIP using HTTPS remote providers (no local DB)")
		}

		// Use FFI for zero-copy GeoIP calls (Go-to-Go FFI via synurang)
		ffiServer := geoip.NewFfiServer(geoipManager)
		ffiConn := geoip_pb.NewFfiClientConn(ffiServer)
		geoIPClient = geoip.NewFfiClient(ffiConn)
		log.Println("[INFO] GeoIP using embedded FFI mode (zero-copy)")
	}

	// Create ProxyManager
	// ListenerModeFfi = in-process (default), ListenerModeProcess = child processes
	mode := node.ListenerModeFfi
	if *processMode {
		mode = node.ListenerModeProcess
	}
	pm := node.NewProxyManager(mode)
	if *processMode {
		log.Println("[INFO] Process mode enabled: each proxy runs as a separate child process")
	}
	if geoIPClient != nil {
		pm.GeoIP.SetClient(geoIPClient)
	}

	// Initialize DB persistence
	if *configFile == "" {
		log.Printf("Initializing local SQLite DB for persistence: %s", *dbPath)
		if err := pm.InitDB(*dbPath); err != nil {
			log.Printf("[WARN] Failed to initialize DB persistence: %v. Rules will be in-memory only.", err)
		} else {
			log.Printf("Persistence enabled: %s", *dbPath)
		}
	} else {
		pm.ConfigPath = *configFile
	}

	// Initialize stats service
	statsDir := "."
	if *configFile != "" {
		statsDir = filepath.Dir(*configFile)
	}
	if *statsDB != "" {
		statsDir = filepath.Dir(*statsDB)
	}
	statsPath := filepath.Join(statsDir, "stats.db")
	if *statsDB != "" {
		statsPath = *statsDB
	}

	statsService, statsErr := stats.NewStatsService(statsPath)
	if statsErr == nil {
		statsService.Start()
		statsService.SetEnabled(true)
		pm.SetStatsService(statsService)
		log.Printf("[INFO] Statistics service enabled: %s", statsPath)
	} else {
		log.Printf("[WARN] Failed to initialize stats service: %v", statsErr)
	}

	// Build listeners from config or command line
	type listenerConfig struct {
		name          string
		listenAddr    string
		defaultBackend string
		defaultAction string
		defaultMock   string
		certPEM       string
		keyPEM        string
		caPEM         string
		clientAuth    pb.ClientAuthType
	}

	var listeners []listenerConfig

	if yamlConfig != nil {
		// YAML config mode: use listeners from config
		for name, ep := range yamlConfig.EntryPoints {
			lc := listenerConfig{
				name:          name,
				listenAddr:    ep.Address,
				defaultAction: ep.DefaultAction,
				defaultMock:   ep.DefaultMock,
				certPEM:       certPEM,
				keyPEM:        keyPEM,
				caPEM:         caPEM,
				clientAuth:    clientAuth,
			}
			// Find associated service
			for _, router := range yamlConfig.TCP.Routers {
				if containsString(router.EntryPoints, name) && router.Service != "" {
					if svc, ok := yamlConfig.TCP.Services[router.Service]; ok {
						if svc.LoadBalancer != nil && len(svc.LoadBalancer.Servers) > 0 {
							// Use first server from load balancer list
							srv := svc.LoadBalancer.Servers[0]
							if srv.Address != "" {
								lc.defaultBackend = srv.Address
							} else {
								lc.defaultBackend = srv.URL
							}
							if len(svc.LoadBalancer.Servers) > 1 {
								log.Printf("[Config] Warning: Service '%s' defines multiple servers, but load balancing is not supported yet. Using first server: %s", router.Service, lc.defaultBackend)
							}
						} else {
							lc.defaultBackend = svc.Address
						}
						break
					}
				}
			}
			listeners = append(listeners, lc)
		}
		log.Printf("Configured %d listeners from YAML", len(listeners))
	} else if *backendTarget != "" {
		// CLI proxy mode: --backend specified, create listener
		listeners = append(listeners, listenerConfig{
			name:          "default",
			listenAddr:    *listenAddr,
			defaultBackend: *backendTarget,
			defaultAction: "allow",
			certPEM:       certPEM,
			keyPEM:        keyPEM,
			caPEM:         caPEM,
			clientAuth:    clientAuth,
		})
	} else if isHubPairingMode() || isHubOnlyMode() {
		// Hub-only mode: pairing or waiting for commands
		// No local listeners - proxies created via Hub commands
		log.Printf("[Hub] Hub-only mode: no local listeners (waiting for commands)")
	} else {
		// No config provided
		log.Fatal("No backend specified. Use --backend, --config, or --hub with pairing.")
	}

	// Start proxies
	var proxyIDs []string
	for _, lc := range listeners {
		// Convert string action to enum
		var actionType common.ActionType
		switch strings.ToLower(lc.defaultAction) {
		case "block":
			actionType = common.ActionType_ACTION_TYPE_BLOCK
		case "mock":
			actionType = common.ActionType_ACTION_TYPE_MOCK
		case "approval":
			actionType = common.ActionType_ACTION_TYPE_REQUIRE_APPROVAL
		default:
			actionType = common.ActionType_ACTION_TYPE_ALLOW
		}

		resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
			ListenAddr:     lc.listenAddr,
			DefaultBackend: lc.defaultBackend,
			Name:           lc.name,
			CertPem:        lc.certPEM,
			KeyPem:         lc.keyPEM,
			CaPem:          lc.caPEM,
			ClientAuthType: lc.clientAuth,
			DefaultAction:  actionType,
			DefaultMock:    node.StringToMockPreset(lc.defaultMock),
		})
		if err != nil || !resp.Success {
			log.Fatalf("Failed to start proxy %s: %v %s", lc.name, err, resp.ErrorMessage)
		}
		proxyID := resp.ProxyId
		proxyIDs = append(proxyIDs, proxyID)

		defaultAction := strings.ToLower(lc.defaultAction)
		if defaultAction == "" {
			defaultAction = "allow"
		}
		log.Printf("Proxy [%s] started on %s -> %s (ID: %s, default: %s)",
			lc.name, lc.listenAddr, lc.defaultBackend, proxyID, defaultAction)

		// Add default rule
		defaultRule := &pb.Rule{
			Name:     "__default",
			Priority: -1000,
			Enabled:  true,
		}
		if defaultAction == "block" {
			defaultRule.Action = common.ActionType_ACTION_TYPE_BLOCK
			log.Printf("  Default: BLOCK (whitelist mode)")
		} else if defaultAction == "mock" {
			defaultRule.Action = common.ActionType_ACTION_TYPE_MOCK
			defaultRule.MockResponse = &pb.MockConfig{
				Preset: node.StringToMockPreset(lc.defaultMock),
			}
			log.Printf("  Default: MOCK (preset: %s)", lc.defaultMock)
		} else if defaultAction == "approval" {
			defaultRule.Action = common.ActionType_ACTION_TYPE_REQUIRE_APPROVAL
			log.Printf("  Default: APPROVAL (manual approval mode)")
		} else {
			defaultRule.Action = common.ActionType_ACTION_TYPE_ALLOW
			log.Printf("  Default: ALLOW (blacklist mode)")
		}
		if _, err := pm.AddRule(&pb.AddRuleRequest{
			ProxyId: proxyID,
			Rule:    defaultRule,
		}); err != nil {
			log.Printf("  Warning: Failed to add default rule: %v", err)
		}
	}

	// Initialize Hub connection (if configured)
	hubActive, err := initHub(pm)
	if err != nil {
		log.Printf("[Hub] Failed to initialize Hub: %v", err)
		// Continue without Hub - standalone mode
	}
	_ = hubActive // Hub mode active - node can receive commands even without proxies

	// Ensure ApprovalManager is initialized even if Hub is inactive (standalone mode)
	if pm.Approval == nil {
		log.Println("[INFO] Initializing local ApprovalManager (standalone mode)")
		pm.SetApprovalManager(node.NewApprovalManager(&localAlertSender{}))
	}

	// Start Admin API Server with TLS
	var adminServer *grpc.Server
	if *adminPort > 0 {
		// Generate token if not provided
		if *adminToken == "" {
			*adminToken = generateToken()
			log.Printf("[Admin] Generated token (keep secret): %s", *adminToken)
		}

		// Determine admin data directory for certificates
		adminCertDir := *adminDataDir
		if adminCertDir == "" {
			adminCertDir = filepath.Dir(*dbPath)
		}

		// Initialize certificate manager (auto-generates CA and server cert)
		certMgr, err := admincert.New(adminCertDir)
		if err != nil {
			log.Fatalf("Failed to initialize admin TLS: %v", err)
		}

		adminLis, err := net.Listen("tcp", fmt.Sprintf(":%d", *adminPort))
		if err != nil {
			log.Fatalf("Failed to listen on admin port %d: %v", *adminPort, err)
		}

		// Create gRPC server with TLS credentials
		adminServer = grpc.NewServer(
			grpc.Creds(credentials.NewTLS(certMgr.GetTLSConfig())),
			grpc.UnaryInterceptor(server.ProxyAdminAuthInterceptor(*adminToken)),
			grpc.StreamInterceptor(server.ProxyAdminStreamAuthInterceptor(*adminToken)),
		)
		nodePrivKey := certMgr.GetCAPrivateKey()
		nodeFingerprint := identity.GenerateFingerprint(nodePrivKey.Public().(ed25519.PublicKey))
		server.RegisterProxyAdmin(adminServer, server.NewProxyAdminServer(pm, nodePrivKey, nodeFingerprint))

		log.Printf("[Admin] gRPC API listening on :%d (TLS enabled)", *adminPort)
		log.Printf("[Admin] Clients should use: --tls-ca %s", certMgr.GetCACertPath())

		go func() {
			if err := adminServer.Serve(adminLis); err != nil {
				log.Printf("[Admin] Server error: %v", err)
			}
		}()
	}

	// Wait for shutdown signal
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGTERM)
	<-sigCh

	log.Println("Shutting down...")
	if adminServer != nil {
		adminServer.GracefulStop()
	}
	// Close Hub connection
	closeHub()
	// Close ProxyManager (stops all listeners, health checks, GeoIP)
	pm.Close()
	if statsService != nil {
		statsService.Stop()
	}
	log.Println("Goodbye.")
}

func containsString(slice []string, s string) bool {
	for _, item := range slice {
		if item == s {
			return true
		}
	}
	return false
}

// generateToken generates a random 32-character token.
func generateToken() string {
	bytes := make([]byte, 16)
	if _, err := rand.Read(bytes); err != nil {
		panic("crypto/rand failed: " + err.Error())
	}
	return hex.EncodeToString(bytes)
}

func init() {
	// Set up usage message
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, `nitellad - Nitella Proxy Daemon

Usage: nitellad [options]

Proxy Options:
  -listen string       Listen address for proxy (default ":8080")
  -backend string      Default backend address (required unless -config)
  -config string       Path to YAML config file
  -db-path string      Path to SQLite database (default "nitella.db")
  -stats-db string     Path to statistics database
  -process-mode        Run each proxy as separate child process (for isolation)

Admin API Options:
  -admin-port int      Port for Admin gRPC API (0 = disabled)
  -admin-token string  Authentication token (env: NITELLA_TOKEN)

Hub Mode Options:
  -hub string          Hub server address (env: NITELLA_HUB)
  -hub-user-id string  User ID for Hub registration (env: NITELLA_HUB_USER_ID)
  -hub-node-name str   Node name for Hub (default: hostname)
  -hub-data-dir string Hub data directory for identity storage
  -hub-p2p             Enable P2P connections via Hub (default: true)
  -hub-qr-mode         Use QR code pairing mode (air-gapped)
  -hub-ca string       Path to Hub CA certificate for verification

TLS Options:
  -tls-cert string     Path to TLS Certificate
  -tls-key string      Path to TLS Private Key
  -tls-ca string       Path to Client CA Certificate
  -mtls                Require Client Certificates (mTLS)

GeoIP Options:
  -geoip-city string   Path to GeoIP2 City DB (MaxMind)
  -geoip-isp string    Path to GeoIP2 ISP/ASN DB (MaxMind)
  -geoip-cache string  Path to GeoIP L2 Cache SQLite (default "geoip_cache.db")
  -geoip-cache-ttl int GeoIP L2 Cache TTL in hours (default 24)
  -geoip-strategy str  Lookup order: l1,l2,local,remote (default "l1,l2,local,remote")
  -geoip-timeout int   Remote provider timeout in ms (default 3000)
  -geoip-addr string   External GeoIP service address (optional)

Examples:
  # Basic proxy (standalone mode)
  nitellad --listen :8080 --backend localhost:3000

  # With admin API (generates token if not provided)
  nitellad --listen :8080 --backend localhost:3000 --admin-port 50051

  # Hub mode (register with Hub server)
  nitellad --listen :8080 --backend localhost:3000 --hub hub.example.com:50052 --hub-user-id user123

  # Hub mode with QR pairing (for air-gapped registration)
  nitellad --listen :8080 --backend localhost:3000 --hub hub.example.com:50052 --hub-qr-mode

  # Using YAML config
  nitellad --config proxy.yaml

  # With local GeoIP database
  nitellad --listen :8080 --backend localhost:3000 --geoip-city /path/to/GeoLite2-City.mmdb

  # With TLS
  nitellad --listen :8443 --backend localhost:3000 --tls-cert cert.pem --tls-key key.pem

  # Process mode (each proxy as separate child process for isolation)
  nitellad --listen :8080 --backend localhost:3000 --process-mode --admin-port 50051
`)
	}
}

// runChild runs in child process mode.
// Child processes handle a single listener and communicate with parent via IPC (socketpair or TCP).
func runChild() {
	// Parse child-specific flags
	childFlags := flag.NewFlagSet("child", flag.ExitOnError)
	listenAddr := childFlags.String("listen", "", "Listen address")
	proxyID := childFlags.String("id", "", "Proxy ID")
	_ = childFlags.String("name", "", "Proxy name") 
	backendAddr := childFlags.String("backend", "", "Default backend address")
	
	// Legacy flags ignored (ipc-fd, ipc-addr handled by synurang via env vars)
	_ = childFlags.String("ipc-fd", "", "ignored")
	_ = childFlags.String("ipc-addr", "", "ignored")

	if err := childFlags.Parse(os.Args[2:]); err != nil {
		log.Fatalf("[child] Failed to parse flags: %v", err)
	}

	// Establish IPC listener using Synurang
	listener, err := synurang.NewIPCListener()
	if err != nil {
		log.Fatalf("[child] Failed to create IPC listener: %v", err)
	}
	defer listener.Close()

	log.Printf("[child] Starting child process (id=%s)", *proxyID)

	// Create ProxyManager for this child (FFI listeners)
	pm := node.NewProxyManager(node.ListenerModeFfi)

	// Create gRPC server with NO TLS (IPC is local/anonymous)
	grpcServer := grpc.NewServer()
	processServer := server.NewProcessServer(pm)

	// Register process control service
	server.RegisterProcessControl(grpcServer, processServer)

	log.Printf("[child] IPC ready. Waiting for parent to initialize listener (listen=%s, backend=%s)", *listenAddr, *backendAddr)

	// Handle shutdown signals
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGTERM)

	go func() {
		<-sigCh
		log.Println("[child] Shutting down...")
		grpcServer.GracefulStop()
	}()

	// Serve gRPC over the IPC connection
	if err := grpcServer.Serve(listener); err != nil {
		log.Printf("[child] gRPC server error: %v", err)
	}

	log.Println("[child] Goodbye.")
}

// localAlertSender handles alerts when Hub is not connected
type localAlertSender struct{}

func (s *localAlertSender) SendAlert(alert *common.Alert, info string) error {
	log.Printf("[Local] Alert generated (pending approval): %s - %s", alert.Id, info)
	return nil
}
