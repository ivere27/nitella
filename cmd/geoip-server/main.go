package main

import (
	"crypto/rand"
	"encoding/hex"
	"flag"
	"fmt"
	"net"
	"os"
	"os/signal"
	"strings"
	"syscall"

	log "github.com/ivere27/nitella/pkg/log"

	pb "github.com/ivere27/nitella/pkg/api/geoip"
	"github.com/ivere27/nitella/pkg/geoip"
	"google.golang.org/grpc"
)

func main() {
	// Public server flags
	port := flag.Int("port", 50052, "Public gRPC server port")
	dbPath := flag.String("db", "./geoip_cache.db", "Path to L2 Cache SQLite DB")
	dbTTL := flag.Int("db-ttl", 24, "L2 cache TTL in hours (0 = permanent)")
	cityPath := flag.String("city-db", "", "Path to MaxMind City DB")
	ispPath := flag.String("isp-db", "", "Path to MaxMind ISP DB")
	remote := flag.String("remote", "", "Comma-separated remote providers (name=url_fmt)")

	// Admin server flags
	// -1 means "use config default or 50053 if no config"
	adminPort := flag.Int("admin-port", -1, "Admin gRPC server port (0 to disable, default 50053)")
	adminToken := flag.String("admin-token", os.Getenv("GEOIP_TOKEN"), "Admin authentication token (env: GEOIP_TOKEN, generated if empty)")

	// Config file flags
	configPath := flag.String("config", "", "Path to provider.yaml config file")

	flag.Parse()

	var manager *geoip.Manager

	// Initialize from config file if provided
	if *configPath != "" {
		cfg, err := geoip.LoadConfig(*configPath)
		if err != nil {
			log.Fatalf("Failed to load config: %v", err)
		}

		manager, err = geoip.NewManagerFromConfig(cfg)
		if err != nil {
			log.Fatalf("Failed to create manager from config: %v", err)
		}
		manager.SetConfigPath(*configPath)
		log.Printf("Loaded configuration from %s", *configPath)

		// Override admin settings from config if not specified on command line
		if *adminPort == -1 {
			if !cfg.GeoIP.Admin.Enabled {
				*adminPort = 0 // Disable admin service
			} else if cfg.GeoIP.Admin.Port != 0 {
				*adminPort = cfg.GeoIP.Admin.Port
			} else {
				*adminPort = 50053 // Default admin port
			}
		}
		if *adminToken == "" && cfg.GeoIP.Admin.Token != "" {
			*adminToken = cfg.GeoIP.Admin.Token
		}

		// Override local DB from command line if specified
		if *cityPath != "" || *ispPath != "" {
			if err := manager.SetLocalDB(*cityPath, *ispPath); err != nil {
				log.Printf("Warning: Failed to load local DB: %v", err)
			} else {
				log.Printf("Local DB loaded")
			}
		}

		// Override L2 cache from command line if specified
		if *dbPath != "" {
			if err := manager.InitL2(*dbPath, *dbTTL); err != nil {
				log.Printf("Warning: Failed to init L2 cache: %v", err)
			}
		}
	} else {
		// Initialize Manager from command-line flags
		manager = geoip.NewManager()

		// Setup L2 Cache
		if *dbPath != "" {
			if err := manager.InitL2(*dbPath, *dbTTL); err != nil {
				log.Printf("Warning: Failed to init L2 cache: %v", err)
			} else {
				ttlStr := fmt.Sprintf("%dh", *dbTTL)
				if *dbTTL == 0 {
					ttlStr = "permanent"
				}
				log.Printf("L2 Cache initialized at %s (TTL: %s)", *dbPath, ttlStr)
			}
		}

		// Setup Local DB
		if *cityPath != "" || *ispPath != "" {
			if err := manager.SetLocalDB(*cityPath, *ispPath); err != nil {
				log.Printf("Warning: Failed to load local DB: %v", err)
			} else {
				log.Printf("Local DB loaded")
			}
		}

		// Setup Remotes
		if *remote != "" {
			parts := strings.Split(*remote, ",")
			for _, p := range parts {
				kv := strings.SplitN(p, "=", 2)
				if len(kv) == 2 {
					manager.AddRemoteProvider(kv[0], kv[1])
					log.Printf("Added remote provider: %s", kv[0])
				}
			}
		}
	}

	// Set default admin port if not specified
	if *adminPort == -1 {
		*adminPort = 50053
	}

	defer manager.Close()

	// Log configuration summary
	logConfigSummary(manager)

	// Generate admin token if not provided
	if *adminPort > 0 && *adminToken == "" {
		*adminToken = generateToken()
		log.Printf("Generated admin token (keep secret): %s", *adminToken)
	}

	// Start Public Server
	publicLis, err := net.Listen("tcp", fmt.Sprintf(":%d", *port))
	if err != nil {
		log.Fatalf("Failed to listen on port %d: %v", *port, err)
	}

	publicServer := grpc.NewServer()
	pb.RegisterGeoIPServiceServer(publicServer, geoip.NewGrpcServer(manager))

	go func() {
		log.Printf("GeoIP Public Service listening on :%d", *port)
		if err := publicServer.Serve(publicLis); err != nil {
			log.Fatalf("Failed to serve public: %v", err)
		}
	}()

	// Start Admin Server (if enabled)
	var adminServer *grpc.Server
	if *adminPort > 0 {
		adminLis, err := net.Listen("tcp", fmt.Sprintf(":%d", *adminPort))
		if err != nil {
			log.Fatalf("Failed to listen on admin port %d: %v", *adminPort, err)
		}

		adminServer = grpc.NewServer(
			grpc.UnaryInterceptor(geoip.AdminAuthInterceptor(*adminToken)),
		)
		pb.RegisterGeoIPAdminServiceServer(adminServer, geoip.NewAdminServer(manager))

		go func() {
			log.Printf("GeoIP Admin Service listening on :%d (token required)", *adminPort)
			if err := adminServer.Serve(adminLis); err != nil {
				log.Fatalf("Failed to serve admin: %v", err)
			}
		}()
	}

	// Wait for shutdown
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGTERM)
	<-sigCh

	log.Println("Shutting down...")
	publicServer.GracefulStop()
	if adminServer != nil {
		adminServer.GracefulStop()
	}
}

// generateToken generates a random 32-character token.
func generateToken() string {
	bytes := make([]byte, 16)
	if _, err := rand.Read(bytes); err != nil {
		panic("crypto/rand failed: " + err.Error())
	}
	return hex.EncodeToString(bytes)
}

// logConfigSummary logs the current configuration.
func logConfigSummary(m *geoip.Manager) {
	stats := m.GetCacheStats()
	providers := m.ListProviders()
	localLoaded, cityPath, ispPath := m.GetLocalDBStatus()
	strategy := m.GetStrategy()

	// L1 Cache
	log.Printf("  L1 Cache: capacity=%d", stats.L1Capacity)

	// L2 Cache
	if stats.L2Enabled {
		ttl := "permanent"
		if stats.L2TtlHours > 0 {
			ttl = fmt.Sprintf("%dh", stats.L2TtlHours)
		}
		log.Printf("  L2 Cache: %s (TTL: %s)", stats.L2Path, ttl)
	} else {
		log.Printf("  L2 Cache: disabled")
	}

	// Local DB
	if localLoaded {
		log.Printf("  Local DB: city=%s, isp=%s", cityPath, ispPath)
	} else {
		log.Printf("  Local DB: not loaded")
	}

	// Remote Providers
	if len(providers) > 0 {
		names := make([]string, 0, len(providers))
		for _, p := range providers {
			status := p.Name
			if !p.Enabled {
				status += "(disabled)"
			}
			names = append(names, status)
		}
		log.Printf("  Providers: %s", strings.Join(names, ", "))
	} else {
		log.Printf("  Providers: none")
	}

	// Strategy
	log.Printf("  Strategy: %v", strategy)
}
