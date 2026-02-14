// Package main provides the Hub server binary for nitella.
// The Hub acts as a blind relay between mobile clients and nodes,
// handling authentication, signaling, and encrypted command relay.
package main

import (
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/tls"
	"crypto/x509"
	"encoding/pem"
	"flag"
	"fmt"
	"net"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"strings"
	"syscall"
	"time"

	"github.com/ivere27/nitella/pkg/core"
	"github.com/ivere27/nitella/pkg/hub/auth"
	"github.com/ivere27/nitella/pkg/hub/certmanager"
	"github.com/ivere27/nitella/pkg/hub/firebase"
	"github.com/ivere27/nitella/pkg/hub/ratelimit"
	"github.com/ivere27/nitella/pkg/hub/server"
	"github.com/ivere27/nitella/pkg/hub/store"
	"github.com/ivere27/nitella/pkg/log"
	nitellaPprof "github.com/ivere27/nitella/pkg/pprof"
	"github.com/ivere27/nitella/pkg/tier"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/keepalive"
	"google.golang.org/grpc/metadata"
)

var (
	// Server configuration
	port     = flag.Int("port", 50052, "gRPC server port")
	httpPort = flag.Int("http-port", 9090, "HTTP health check port")

	// TLS configuration
	tlsCert     = flag.String("tls-cert", "", "Path to TLS certificate (required for mTLS)")
	tlsKey      = flag.String("tls-key", "", "Path to TLS private key (required for mTLS)")
	tlsCA       = flag.String("tls-ca", "", "Path to CA certificate for client verification")
	autoCert    = flag.Bool("auto-cert", false, "Force auto-generate TLS certs (Hub CA + Leaf). If --tls-cert/--tls-key fail, auto-cert is used as fallback")
	certDataDir = flag.String("cert-data-dir", "", "Directory for auto-cert storage (default: same as db)")

	// Database configuration
	// NOTE: For encryption, use database-level encryption (SQLCipher) or encrypted storage.
	// Sensitive data is E2E encrypted by user's public key before reaching Hub.
	dbDriver = flag.String("db-driver", "sqlite3", "Database driver (sqlite3, mysql, postgres)")
	dbPath   = flag.String("db-path", "hub.db", "Database path/connection string")

	// JWT configuration
	jwtKeyPath = flag.String("jwt-key", "", "Path to JWT signing key (Ed25519). Generated if not exists")
	jwtDataDir = flag.String("jwt-data-dir", "", "Directory for JWT key storage (default: same as db)")

	// Firebase configuration
	firebaseCredentials = flag.String("firebase-credentials", "", "Path to Firebase service account JSON")

	// Feature flags
	requireMTLS = flag.Bool("require-mtls", false, "Require mTLS for node connections")
	enableP2P   = flag.Bool("enable-p2p", true, "Enable P2P signaling")

	// Logging
	verbose = flag.Bool("verbose", false, "Enable verbose logging")
	trace   = flag.Bool("trace", false, "Enable trace logging (very verbose)")

	// Profiling (only effective with -tags pprof)
	pprofPort = flag.Int("pprof-port", 0, "Port for pprof HTTP server (0 = disabled, requires -tags pprof build)")

	// Shutdown behavior
	gracefulShutdownTimeout = flag.Duration("graceful-timeout", 30*time.Second, "Graceful shutdown timeout before force stop")
)

func main() {
	flag.Parse()
	nitellaPprof.Start(*pprofPort)

	// Configure logging
	if *trace {
		os.Setenv("NITELLA_TRACE", "1")
	}
	if *verbose {
		log.Infof("Verbose logging enabled")
	}

	log.Infof("Starting Hub server...")

	// Initialize store
	// NOTE: Sensitive data is E2E encrypted by user's public key before reaching Hub.
	// For defense-in-depth, use database-level encryption (SQLCipher, TDE) in production.
	log.Infof("Initializing database: driver=%s path=%s", *dbDriver, *dbPath)

	hubStore, err := store.NewStore(*dbDriver, *dbPath)
	if err != nil {
		log.Fatalf("Failed to initialize store: %v", err)
	}
	defer hubStore.Close()

	// Initialize JWT auth
	jwtDir := *jwtDataDir
	if jwtDir == "" {
		jwtDir = filepath.Dir(*dbPath)
	}
	jwtManager, err := initJWTManager(jwtDir, *jwtKeyPath)
	if err != nil {
		log.Fatalf("Failed to initialize JWT manager: %v", err)
	}

	// Initialize Firebase (optional)
	var firebaseService *firebase.Service
	if *firebaseCredentials != "" {
		log.Infof("Initializing Firebase with credentials: %s", *firebaseCredentials)
		firebaseService, err = firebase.NewService(*firebaseCredentials)
		if err != nil {
			log.Warnf("Failed to initialize Firebase: %v (push notifications disabled)", err)
		} else {
			log.Infof("Firebase initialized successfully")
		}
	} else {
		log.Infof("Firebase credentials not provided, push notifications disabled")
	}

	// Load tier configuration
	tierCfg := tier.DefaultConfig()
	if tiersFile := "tiers.yaml"; func() bool { _, err := os.Stat(tiersFile); return err == nil }() {
		if cfg, err := tier.LoadConfig(tiersFile); err == nil {
			tierCfg = cfg
			log.Infof("Loaded tier configuration from %s", tiersFile)
		} else {
			log.Warnf("Failed to load tiers.yaml, using defaults: %v", err)
		}
	}

	// Create IP-based rate limiter (anti-DDoS, runs first)
	ipRateLimiter := ratelimit.NewIPRateLimiter(ratelimit.DefaultIPRateLimiterConfig())

	// Create tier-based rate limiter
	tierRateLimiter := ratelimit.NewTieredRateLimiter(tierCfg, func(routingToken string) string {
		info, err := hubStore.GetRoutingTokenInfo(routingToken)
		if err != nil || info.Tier == "" {
			return "free"
		}
		return info.Tier
	})

	// Create Hub server
	// tokenManager is used for both user and admin tokens (can be separated if needed)
	hubServer := server.NewHubServer(jwtManager, jwtManager, hubStore, firebaseService, tierCfg)

	// Configure gRPC server options
	opts := []grpc.ServerOption{
		grpc.KeepaliveParams(keepalive.ServerParameters{
			MaxConnectionIdle:     5 * time.Minute,
			MaxConnectionAge:      30 * time.Minute,
			MaxConnectionAgeGrace: 5 * time.Second,
			Time:                  30 * time.Second,
			Timeout:               10 * time.Second,
		}),
		grpc.KeepaliveEnforcementPolicy(keepalive.EnforcementPolicy{
			MinTime:             10 * time.Second,
			PermitWithoutStream: true,
		}),
		grpc.MaxRecvMsgSize(16 * 1024 * 1024), // 16MB
		grpc.MaxSendMsgSize(16 * 1024 * 1024), // 16MB
	}

	// Configure TLS
	var certMgr *certmanager.CertManager
	useAutoCert := *autoCert

	// Try manual TLS first if certificates are provided
	if *tlsCert != "" && *tlsKey != "" && !*autoCert {
		tlsConfig, err := loadTLSConfig(*tlsCert, *tlsKey, *tlsCA)
		if err != nil {
			log.Warnf("Failed to load TLS configuration: %v", err)
			log.Infof("Falling back to auto-cert mode")
			useAutoCert = true
		} else {
			opts = append(opts, grpc.Creds(credentials.NewTLS(tlsConfig)))
			log.Infof("TLS enabled with certificate: %s", *tlsCert)
			if *tlsCA != "" {
				log.Infof("Client certificate verification enabled with CA: %s", *tlsCA)
			}
		}
	} else if !*autoCert && (*tlsCert == "" || *tlsKey == "") {
		// No manual certs provided, fallback to auto-cert
		log.Infof("No TLS certificates provided, using auto-cert mode")
		useAutoCert = true
	}

	// Auto-cert mode: Generate Hub CA and auto-rotating leaf certs
	if useAutoCert {
		certDir := *certDataDir
		if certDir == "" {
			certDir = filepath.Dir(*dbPath)
		}
		log.Infof("Initializing auto-cert mode with data dir: %s", certDir)

		var err error
		certMgr, err = certmanager.New(certmanager.DefaultConfig(certDir))
		if err != nil {
			log.Fatalf("Failed to initialize cert manager: %v", err)
		}
		certMgr.Start(context.Background())

		// Set certmanager for CSR signing during node registration
		hubServer.SetCertManager(certMgr)

		tlsConfig := certMgr.GetTLSConfig()
		opts = append(opts, grpc.Creds(credentials.NewTLS(tlsConfig)))
		log.Infof("Auto-cert TLS enabled (Hub CA + auto-rotating leaf)")

		// Log Hub CA fingerprint for TOFU
		if caPEM, err := certMgr.GetCACertPEM(); err == nil {
			log.Infof("Hub CA available at: %s/hub_ca.crt", certDir)
			_ = caPEM // Logged by certmanager
		}
	}

	// Add interceptors (order: IP limit -> logging -> auth -> tier limit)
	opts = append(opts, grpc.ChainUnaryInterceptor(
		ipRateLimiter.UnaryInterceptor(),
		loggingInterceptor,
		hubServer.AuthInterceptor,
		tierRateLimiter.UnaryInterceptor(),
	))
	opts = append(opts, grpc.ChainStreamInterceptor(
		ipRateLimiter.StreamInterceptor(),
		streamLoggingInterceptor(jwtManager),
		hubServer.StreamAuthInterceptor,
		tierRateLimiter.StreamInterceptor(),
	))

	// Create gRPC server
	grpcServer := grpc.NewServer(opts...)

	// Register services
	hubServer.RegisterServices(grpcServer)
	log.Infof("Registered gRPC services: NodeService, MobileService, AuthService, PairingService, AdminService")

	// Start listening
	listener, err := net.Listen("tcp", fmt.Sprintf(":%d", *port))
	if err != nil {
		log.Fatalf("Failed to listen on port %d: %v", *port, err)
	}

	// Start health check server
	go startHealthServer(*httpPort)

	// Handle graceful shutdown
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		sig := <-sigCh
		log.Infof("Received signal %v, shutting down gracefully...", sig)

		stopped := make(chan struct{})
		go func() {
			grpcServer.GracefulStop()
			close(stopped)
		}()

		timer := time.NewTimer(*gracefulShutdownTimeout)
		defer timer.Stop()

		select {
		case sig2 := <-sigCh:
			log.Warnf("Received signal %v during shutdown, forcing stop", sig2)
			grpcServer.Stop()
		case <-timer.C:
			log.Warnf("Graceful shutdown timed out after %v, forcing stop", *gracefulShutdownTimeout)
			grpcServer.Stop()
		case <-stopped:
			log.Infof("Graceful shutdown completed")
		}

		// Ensure GracefulStop goroutine exits after Stop().
		select {
		case <-stopped:
		case <-time.After(2 * time.Second):
		}

		// Stop cert manager if running
		if certMgr != nil {
			certMgr.Stop()
		}
	}()

	// Start serving
	log.Infof("Hub server listening on :%d", *port)
	if err := grpcServer.Serve(listener); err != nil {
		if err == grpc.ErrServerStopped {
			log.Infof("Hub server stopped")
			return
		}
		log.Fatalf("Failed to serve: %v", err)
	}
}

// initJWTManager initializes the JWT token manager with Ed25519 keys
func initJWTManager(dataDir, keyPath string) (*auth.TokenManager, error) {
	var privateKeyPEM []byte

	// Determine key file path
	if keyPath == "" {
		keyPath = filepath.Join(dataDir, "jwt.key")
	}

	// Try to load existing key
	if keyPEM, err := os.ReadFile(keyPath); err == nil {
		block, _ := pem.Decode(keyPEM)
		if block != nil {
			privateKeyPEM = keyPEM
			log.Infof("Loaded JWT signing key from: %s", keyPath)
		}
	}

	// Generate new key if not found
	if privateKeyPEM == nil {
		log.Infof("Generating new JWT signing key...")
		_, priv, err := ed25519.GenerateKey(rand.Reader)
		if err != nil {
			return nil, fmt.Errorf("failed to generate Ed25519 key: %w", err)
		}

		// Save the key
		if err := os.MkdirAll(filepath.Dir(keyPath), 0700); err != nil {
			return nil, fmt.Errorf("failed to create key directory: %w", err)
		}
		pkcs8, err := x509.MarshalPKCS8PrivateKey(priv)
		if err != nil {
			return nil, fmt.Errorf("failed to marshal private key: %w", err)
		}
		pemBlock := &pem.Block{Type: "PRIVATE KEY", Bytes: pkcs8}
		privateKeyPEM = pem.EncodeToMemory(pemBlock)
		if err := os.WriteFile(keyPath, privateKeyPEM, 0600); err != nil {
			return nil, fmt.Errorf("failed to save JWT key: %w", err)
		}
		log.Infof("Saved new JWT signing key to: %s", keyPath)
	}

	return auth.NewTokenManager(privateKeyPEM, nil, "nitella-hub")
}

// loadTLSConfig loads TLS configuration with optional client verification
func loadTLSConfig(certFile, keyFile, caFile string) (*tls.Config, error) {
	cert, err := tls.LoadX509KeyPair(certFile, keyFile)
	if err != nil {
		return nil, fmt.Errorf("failed to load server certificate: %w", err)
	}

	config := &tls.Config{
		Certificates: []tls.Certificate{cert},
		MinVersion:   tls.VersionTLS13,
	}

	// Load CA for client verification if provided
	if caFile != "" {
		caPool, err := core.LoadCertPool(caFile)
		if err != nil {
			return nil, err
		}
		config.ClientCAs = caPool
		if *requireMTLS {
			config.ClientAuth = tls.RequireAndVerifyClientCert
		} else {
			config.ClientAuth = tls.VerifyClientCertIfGiven
		}
	}

	return config, nil
}

// loggingInterceptor logs unary RPC calls
func loggingInterceptor(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
	start := time.Now()
	resp, err := handler(ctx, req)
	duration := time.Since(start)

	if err != nil {
		log.Warnf("RPC %s failed: %v (duration: %v)", info.FullMethod, err, duration)
	} else if *verbose {
		log.Infof("RPC %s completed (duration: %v)", info.FullMethod, duration)
	}

	return resp, err
}

// streamLoggingInterceptor logs streaming RPC calls and includes user_id when available.
func streamLoggingInterceptor(tokenManager *auth.TokenManager) grpc.StreamServerInterceptor {
	return func(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		start := time.Now()
		err := handler(srv, ss)
		duration := time.Since(start)

		if err != nil {
			// PairingService/PakeExchange has dedicated structured logs in PairingServer.
			// Skip generic stream warning here to avoid duplicate ambiguous lines.
			if info.FullMethod == "/nitella.hub.PairingService/PakeExchange" {
				return err
			}
			userID := extractStreamUserID(ss.Context(), tokenManager)
			if userID != "" {
				log.Warnf("Stream %s ended with error: %v (user_id: %s, duration: %v)", info.FullMethod, err, userID, duration)
			} else {
				log.Warnf("Stream %s ended with error: %v (duration: %v)", info.FullMethod, err, duration)
			}
		} else if *verbose {
			log.Infof("Stream %s ended (duration: %v)", info.FullMethod, duration)
		}

		return err
	}
}

func extractStreamUserID(ctx context.Context, tokenManager *auth.TokenManager) string {
	if userID, ok := auth.GetUserID(ctx); ok {
		userID = strings.TrimSpace(userID)
		if userID != "" {
			return userID
		}
	}

	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return ""
	}

	if ids := md.Get("user_id"); len(ids) > 0 {
		userID := strings.TrimSpace(ids[0])
		if userID != "" {
			return userID
		}
	}

	if tokenManager == nil {
		return ""
	}

	authz := md.Get("authorization")
	if len(authz) == 0 {
		return ""
	}

	tokenStr := strings.TrimSpace(authz[0])
	if strings.HasPrefix(strings.ToLower(tokenStr), "bearer ") {
		tokenStr = strings.TrimSpace(tokenStr[len("bearer "):])
	}
	if tokenStr == "" {
		return ""
	}

	claims, err := tokenManager.ValidateToken(tokenStr)
	if err != nil || claims == nil {
		return ""
	}
	return strings.TrimSpace(claims.UserID)
}

// startHealthServer starts a simple HTTP health check server
func startHealthServer(port int) {
	mux := http.NewServeMux()
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	})
	mux.HandleFunc("/ready", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("Ready"))
	})

	log.Infof("Health check server listening on :%d", port)
	if err := http.ListenAndServe(fmt.Sprintf(":%d", port), mux); err != nil {
		log.Warnf("Health check server failed: %v", err)
	}
}
