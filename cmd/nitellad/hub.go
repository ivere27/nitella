package main

import (
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/sha256"
	"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/json"
	"encoding/pem"
	"errors"
	"flag"
	"fmt"
	"io"
	"net"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	hubpb "github.com/ivere27/nitella/pkg/api/hub"
	pb "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/config"
	"github.com/ivere27/nitella/pkg/core"
	"github.com/ivere27/nitella/pkg/hubclient"
	"github.com/ivere27/nitella/pkg/identity"
	"github.com/ivere27/nitella/pkg/log"
	"github.com/ivere27/nitella/pkg/node"
	"github.com/ivere27/nitella/pkg/pairing"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/timestamppb"
	"gopkg.in/yaml.v3"
)

var (
	// Hub connection flags
	hubAddr     = flag.String("hub", os.Getenv("NITELLA_HUB"), "Hub server address (env: NITELLA_HUB)")
	hubDataDir  = flag.String("hub-data-dir", "", "Hub data directory for identity storage")
	hubNodeName = flag.String("hub-node-name", "", "Node name for Hub (default: hostname)")
	hubP2P      = flag.Bool("hub-p2p", false, "Enable P2P connections via Hub")
	hubSTUN     = flag.String("stun", os.Getenv("NITELLA_STUN"), "STUN server URL for P2P (env: NITELLA_STUN)")
	hubCAPEM    = flag.String("hub-ca", "", "Path to Hub CA certificate for mTLS verification")

	// Pairing flags (PAKE or QR-based)
	pairCode    = flag.String("pair", "", "PAKE pairing code (e.g., '7-tiger-castle')")
	pairOffline = flag.Bool("pair-offline", false, "Offline pairing mode (web UI or terminal)")
	pairPort    = flag.String("pair-port", "", "Port for pairing web UI (e.g., ':8888')")
	pairTimeout = flag.Duration("pair-timeout", 3*time.Minute, "Pairing timeout duration")

	// Hub client instance
	hubClient *hubclient.Client

	// Proxy manager reference
	hubProxyManager *node.ProxyManager

	// Node identity storage
	nodeDataDir string
)

// HubConfig stores Hub configuration for persistence
type HubNodeConfig struct {
	HubAddress string `json:"hub_address"`
	UserId     string `json:"user_id"`
	NodeName   string `json:"node_name"`
	P2PEnabled bool   `json:"p2p_enabled"`
}

// isHubPairingMode returns true if running in Hub pairing mode
func isHubPairingMode() bool {
	return *pairCode != "" || *pairOffline
}

// isHubOnlyMode returns true if running in Hub-only mode (no local proxy)
// This is when --hub is specified for pairing or command-only mode.
// Note: In hub.go we can only check Hub-related flags, not main.go flags.
// The actual check for no-backend/no-config is done in main.go.
func isHubOnlyMode() bool {
	// Hub mode enabled with no local proxy needed
	return *hubAddr != ""
}

// hubCommandHandler implements hubclient.CommandHandler
type hubCommandHandler struct {
	pm *node.ProxyManager
}

func (h *hubCommandHandler) HandleCommand(ctx context.Context, cmdType hubpb.CommandType, payload []byte) (status string, errMsg string, data []byte) {
	// Map CommandType to string command
	cmdStr := cmdType.String()

	result, err := handleHubCommandInternal(h.pm, cmdStr, payload)
	if err != nil {
		return "ERROR", err.Error(), nil
	}
	return "OK", "", result
}

// initHub initializes Hub connection and registration
// Returns true if pairing was performed and node should continue running
func initHub(pm *node.ProxyManager) (bool, error) {
	// Determine data directory first
	nodeDataDir = *hubDataDir
	if nodeDataDir == "" {
		home, _ := os.UserHomeDir()
		nodeDataDir = filepath.Join(home, ".nitella", "nitellad")
	}

	// Ensure data directory exists
	if err := os.MkdirAll(nodeDataDir, 0700); err != nil {
		return false, fmt.Errorf("failed to create data directory: %w", err)
	}

	// Check if pairing mode is requested
	if *pairCode != "" || *pairOffline {
		if *hubAddr == "" {
			return false, fmt.Errorf("--hub address required for pairing")
		}
		if err := doPairing(); err != nil {
			return false, err
		}
		// Pairing complete - continue to connect to Hub
	}

	if *hubAddr == "" {
		return false, nil // Hub mode disabled
	}

	hubProxyManager = pm

	// Load previously applied proxies
	loadAppliedProxies()

	// Load or set node name
	nodeName := *hubNodeName
	if nodeName == "" {
		nodeName, _ = os.Hostname()
		if nodeName == "" {
			nodeName = "nitellad-node"
		}
	}

	log.Printf("[Hub] Initializing Hub connection to %s", *hubAddr)
	log.Printf("[Hub] Data directory: %s", nodeDataDir)
	log.Printf("[Hub] Node name: %s", nodeName)

	// Check if we have a certificate (already paired)
	certPath := filepath.Join(nodeDataDir, "node.crt")
	keyPath := filepath.Join(nodeDataDir, "node.key")
	caPath := filepath.Join(nodeDataDir, "cli_ca.crt")

	if _, err := os.Stat(certPath); os.IsNotExist(err) {
		log.Printf("[Hub] No certificate found. Run with --pair <code> or --pair-offline to pair.")
		return false, fmt.Errorf("node not paired - run with --pair <code> or --pair-offline first")
	}

	nodeCertPEM, certReadErr := os.ReadFile(certPath)
	if certReadErr != nil {
		return false, fmt.Errorf("failed to read node certificate: %w", certReadErr)
	}

	// Load certificates for mTLS
	cert, err := tls.LoadX509KeyPair(certPath, keyPath)
	if err != nil {
		return false, fmt.Errorf("failed to load certificate: %w", err)
	}

	// Create TLS config with mTLS
	tlsConfig := &tls.Config{
		Certificates: []tls.Certificate{cert},
		MinVersion:   tls.VersionTLS13,
	}

	// Load CLI/Mobile CA cert for verification if available
	// (stored during pairing as cli_ca.crt)
	var cliCAPEM []byte
	if data, err := os.ReadFile(caPath); err == nil {
		cliCAPEM = data
	}
	logNodeCertificateIdentity("startup", nodeCertPEM)

	// Load Hub CA - mTLS requires proper certificate verification
	hubCACert, err := ensureHubCA(*hubAddr)
	if err != nil {
		return false, fmt.Errorf("failed to resolve Hub CA: %w", err)
	}

	roots, err := core.LoadCertPoolFromPEM(hubCACert)
	if err != nil {
		return false, fmt.Errorf("hub CA invalid and system CA pool unavailable: %w", err)
	}
	tlsConfig.RootCAs = roots

	// Create gRPC connection with mTLS
	conn, err := grpc.Dial(*hubAddr,
		grpc.WithTransportCredentials(credentials.NewTLS(tlsConfig)),
	)
	if err != nil {
		return false, fmt.Errorf("failed to connect to Hub: %w", err)
	}

	// Create Hub client for node operations
	hubClient = hubclient.NewClientWithConn(conn, nodeDataDir)
	hubClient.SetHubAddr(*hubAddr) // Set hubAddr explicitly for reconnection
	// Pass Hub CA for internal reconnections
	if len(hubCACert) > 0 {
		hubClient.SetTransportCA(hubCACert)
	}
	hubClient.SetUseP2P(*hubP2P)
	if *hubSTUN != "" {
		hubClient.SetSTUNServer(*hubSTUN)
	}

	// Set CLI/Mobile CA cert for command verification and response encryption
	if len(cliCAPEM) > 0 {
		if err := hubClient.SetCACert(cliCAPEM); err != nil {
			log.Printf("[Hub] Failed to set CLI CA cert: %v", err)
		}
		// Extract public key from cert for encrypting responses back to mobile/CLI
		block, _ := pem.Decode(cliCAPEM)
		if block != nil {
			cert, err := x509.ParseCertificate(block.Bytes)
			if err == nil {
				if pubKey, ok := cert.PublicKey.(ed25519.PublicKey); ok {
					hubClient.SetViewerPublicKey(pubKey)
				}
			}
		}
	}

	// Set command handler
	hubClient.SetCommandHandler(&hubCommandHandler{pm: pm})

	// Set metrics provider
	hubClient.SetMetricsProvider(&proxyMetricsProvider{pm: pm})

	// Create ApprovalManager with HubClient as AlertSender
	approvalManager := node.NewApprovalManager(hubClient)
	pm.SetApprovalManager(approvalManager)

	// Set P2P approval decision handler
	hubClient.SetApprovalDecisionHandler(func(reqID string, allowed bool, durationSeconds int64, reason string) {
		log.Printf("[P2P] Received approval decision for %s: allowed=%v, duration=%ds, reason=%q",
			reqID, allowed, durationSeconds, reason)
		if pm.Approval != nil {
			meta := pm.Approval.Resolve(reqID, allowed, durationSeconds, reason)
			if meta != nil {
				log.Printf("[P2P] Resolved approval for %s from %s", reqID, meta.SourceIP)
			} else {
				log.Printf("[P2P] No pending approval found for %s (may have timed out)", reqID)
			}
		}
	})

	// Start Hub connection in background
	go func() {
		log.Printf("[Hub] Starting Hub connection loop...")
		hubClient.Start()
	}()

	log.Printf("[Hub] Hub integration initialized with mTLS")
	log.Printf("[Hub] Waiting for commands... (no listening ports until configured)")
	return true, nil
}

// doPairing handles PAKE or QR-based pairing
func doPairing() error {
	// Determine data directory
	nodeDataDir = *hubDataDir
	if nodeDataDir == "" {
		home, _ := os.UserHomeDir()
		nodeDataDir = filepath.Join(home, ".nitella", "nitellad")
	}

	if err := os.MkdirAll(nodeDataDir, 0700); err != nil {
		return fmt.Errorf("failed to create data directory: %w", err)
	}

	// Generate node identity if not exists
	keyPath := filepath.Join(nodeDataDir, "node.key")
	var privateKey ed25519.PrivateKey

	if keyPEM, err := os.ReadFile(keyPath); err == nil {
		block, _ := pem.Decode(keyPEM)
		if block != nil {
			if key, err := x509.ParsePKCS8PrivateKey(block.Bytes); err == nil {
				if edKey, ok := key.(ed25519.PrivateKey); ok {
					privateKey = edKey
					log.Printf("[Pairing] Loaded existing node key")
				}
			}
		}
	}

	if privateKey == nil {
		var err error
		_, privateKey, err = ed25519.GenerateKey(rand.Reader)
		if err != nil {
			return fmt.Errorf("failed to generate key: %w", err)
		}

		// Save private key
		pkcs8, _ := x509.MarshalPKCS8PrivateKey(privateKey)
		keyPEM := pem.EncodeToMemory(&pem.Block{Type: "PRIVATE KEY", Bytes: pkcs8})
		if err := os.WriteFile(keyPath, keyPEM, 0600); err != nil {
			return fmt.Errorf("failed to save key: %w", err)
		}
		log.Printf("[Pairing] Generated new node key")
	}

	if *pairOffline {
		return doPairingOffline(privateKey)
	}
	return doPairingPAKE(privateKey)
}

// doPairingPAKE handles PAKE-based pairing via Hub
func doPairingPAKE(privateKey ed25519.PrivateKey) error {
	code, err := pairing.ParsePairingCode(*pairCode)
	if err != nil {
		return fmt.Errorf("invalid pairing code: %w", err)
	}

	log.Printf("[Pairing] Starting PAKE pairing with code: %s", code)

	// Pre-flight check: If we have a cached CA, verify it matches the live Hub
	// This avoids gRPC connection timeouts/errors if the Hub identity changed.
	cachedPath := filepath.Join(nodeDataDir, "hub_ca.crt")
	if cachedData, err := os.ReadFile(cachedPath); err == nil {
		log.Printf("[Pairing] Verifying cached Hub CA against %s...", *hubAddr)
		probeInfo, err := core.ProbeHubCA(*hubAddr)
		if err == nil {
			cachedStr := strings.TrimSpace(string(cachedData))
			probeStr := strings.TrimSpace(string(probeInfo.CaPEM))
			if cachedStr != probeStr {
				log.Printf("[Pairing] CA MISMATCH: Hub identity has changed!")
				log.Printf("[Pairing] Removing outdated cached CA...")
				os.Remove(cachedPath)
			} else {
				log.Printf("[Pairing] Cached CA is valid (matches live Hub).")
			}
		} else {
			log.Printf("[Pairing] Warning: Could not probe Hub CA: %v", err)
		}
	}

	// Helper to establish connection
	connect := func() (*grpc.ClientConn, hubpb.PairingService_PakeExchangeClient, error) {
		// Connect to Hub for pairing - mTLS requires proper certificate verification
		tlsConfig := &tls.Config{
			MinVersion: tls.VersionTLS13,
		}

		hubCACert, err := ensureHubCA(*hubAddr)
		if err != nil {
			return nil, nil, fmt.Errorf("failed to resolve Hub CA: %w", err)
		}

		roots, err := core.LoadCertPoolFromPEM(hubCACert)
		if err != nil {
			return nil, nil, fmt.Errorf("hub CA invalid: %w", err)
		}
		tlsConfig.RootCAs = roots

		// Use blocking dial to ensure handshake succeeds (or fails with cert error)
		ctxDial, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		conn, err := grpc.DialContext(ctxDial, *hubAddr,
			grpc.WithTransportCredentials(credentials.NewTLS(tlsConfig)),
			grpc.WithBlock(),
		)
		if err != nil {
			return nil, nil, err
		}

		// Create PAKE session
		pairingClient := hubpb.NewPairingServiceClient(conn)
		stream, err := pairingClient.PakeExchange(context.Background())
		if err != nil {
			conn.Close()
			return nil, nil, err
		}

		return conn, stream, nil
	}

	// First attempt
	conn, stream, err := connect()
	if err != nil {
		// If cert error, try clearing cache and retrying
		if strings.Contains(err.Error(), "certificate signed by unknown authority") {
			log.Printf("[Pairing] Cached Hub CA failed verification. Clearing cache and retrying (TOFU)...")
			cachedPath := filepath.Join(nodeDataDir, "hub_ca.crt")
			os.Remove(cachedPath)

			conn, stream, err = connect()
		}
	}

	if err != nil {
		return fmt.Errorf("failed to connect to Hub: %w", err)
	}
	defer conn.Close()

	// Create PAKE session (crypto)
	pakeSession, err := pairing.NewPakeSession(pairing.RoleNode, pairing.CodeToBytes(code))
	if err != nil {
		return fmt.Errorf("failed to create PAKE session: %w", err)
	}

	// Send initial PAKE message
	initMsg, err := pakeSession.GetInitMessage()
	if err != nil {
		return fmt.Errorf("failed to generate PAKE init: %w", err)
	}

	err = stream.Send(&hubpb.PakeMessage{
		SessionCode: code,
		Role:        pairing.RoleNode,
		Type:        hubpb.PakeMessage_MESSAGE_TYPE_SPAKE2_INIT,
		Spake2Data:  initMsg,
	})
	if err != nil {
		return fmt.Errorf("failed to send PAKE init: %w", err)
	}

	log.Printf("[Pairing] Waiting for CLI...")

	// Receive CLI's init message
	cliMsg, err := stream.Recv()
	if err != nil {
		return fmt.Errorf("failed to receive from CLI: %w", err)
	}

	if cliMsg.Type == hubpb.PakeMessage_MESSAGE_TYPE_ERROR {
		return fmt.Errorf("CLI error: %s", cliMsg.ErrorMessage)
	}

	// Process CLI's init message
	_, err = pakeSession.ProcessInitMessage(cliMsg.Spake2Data)
	if err != nil {
		return fmt.Errorf("PAKE verification failed: %w", err)
	}

	// Receive CLI's reply
	cliReply, err := stream.Recv()
	if err != nil {
		return fmt.Errorf("failed to receive CLI reply: %w", err)
	}

	if err := pakeSession.ProcessReplyMessage(cliReply.Spake2Data); err != nil {
		return fmt.Errorf("failed to process CLI reply: %w", err)
	}

	// Display confirmation emoji
	emoji := pakeSession.DeriveConfirmationEmoji()
	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║                    PAKE VERIFICATION                          ║")
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Printf("║    Verification emoji: %-38s  ║\n", emoji)
	fmt.Println("║                                                                ║")
	fmt.Println("║    Verify this matches what the CLI displays!                 ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")
	fmt.Println()

	// Generate CSR
	nodeName := *hubNodeName
	if nodeName == "" {
		nodeName, _ = os.Hostname()
	}

	csrPEM, err := generateCSR(privateKey, nodeName)
	if err != nil {
		return fmt.Errorf("failed to generate CSR: %w", err)
	}

	// Encrypt and send CSR
	encryptedCSR, nonce, err := pakeSession.Encrypt(csrPEM)
	if err != nil {
		return fmt.Errorf("failed to encrypt CSR: %w", err)
	}

	// Display CSR info for user verification
	csrFingerprint := pairing.DeriveFingerprint(csrPEM)
	csrHash := sha256.Sum256(csrPEM)
	csrHashStr := fmt.Sprintf("%x", csrHash)

	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║                  NODE IDENTITY INFO                          ║")
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Printf("║  Fingerprint: %-46s ║\n", csrFingerprint)
	fmt.Printf("║  Hash:        %-46s ║\n", csrHashStr[:min(46, len(csrHashStr))])
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Println("║  Verify this matches the request on your Controller/CLI!     ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")
	fmt.Println()

	err = stream.Send(&hubpb.PakeMessage{
		SessionCode:      code,
		Role:             pairing.RoleNode,
		Type:             hubpb.PakeMessage_MESSAGE_TYPE_ENCRYPTED,
		EncryptedPayload: encryptedCSR,
		Nonce:            nonce,
	})
	if err != nil {
		return fmt.Errorf("failed to send CSR: %w", err)
	}

	log.Printf("[Pairing] CSR sent, waiting for signed certificate...")

	// Receive signed certificate
	certMsg, err := stream.Recv()
	if err != nil {
		if err == io.EOF {
			return fmt.Errorf("CLI disconnected (pairing rejected?)")
		}
		return fmt.Errorf("failed to receive certificate: %w", err)
	}

	if certMsg.Type == hubpb.PakeMessage_MESSAGE_TYPE_ERROR {
		return fmt.Errorf("CLI rejected pairing: %s", certMsg.ErrorMessage)
	}

	// Decrypt certificate
	certPEM, err := pakeSession.Decrypt(certMsg.EncryptedPayload, certMsg.Nonce)
	if err != nil {
		return fmt.Errorf("failed to decrypt certificate: %w", err)
	}

	// Receive CA certificate
	caMsg, err := stream.Recv()
	if err != nil {
		return fmt.Errorf("failed to receive CA certificate: %w", err)
	}

	caCertPEM, err := pakeSession.Decrypt(caMsg.EncryptedPayload, caMsg.Nonce)
	if err != nil {
		return fmt.Errorf("failed to decrypt CA certificate: %w", err)
	}

	// Save certificates
	certPath := filepath.Join(nodeDataDir, "node.crt")
	caPath := filepath.Join(nodeDataDir, "cli_ca.crt")

	if err := os.WriteFile(certPath, certPEM, 0600); err != nil {
		return fmt.Errorf("failed to save certificate: %w", err)
	}
	if err := os.WriteFile(caPath, caCertPEM, 0644); err != nil {
		return fmt.Errorf("failed to save CA certificate: %w", err)
	}

	// Save NodeID (CommonName) from certificate
	block, _ := pem.Decode(certPEM)
	if block != nil {
		if cert, err := x509.ParseCertificate(block.Bytes); err == nil {
			nodeID := cert.Subject.CommonName
			idPath := filepath.Join(nodeDataDir, "node_id")
			if err := os.WriteFile(idPath, []byte(nodeID), 0644); err != nil {
				log.Printf("[Pairing] Warning: failed to save node_id file: %v", err)
			} else {
				log.Printf("[Pairing] Saved Node ID: %s", nodeID)
			}
		}
	}

	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║                    PAIRING COMPLETE!                          ║")
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Println("║    Certificate saved. Node is now paired with CLI.            ║")
	fmt.Println("║                                                                ║")
	fmt.Println("║    Run nitellad without --pair to start normally.             ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")
	fmt.Println()
	logNodeCertificateIdentity("pairing", certPEM)

	return nil
}

// doPairingOffline handles QR code based offline pairing
func doPairingOffline(privateKey ed25519.PrivateKey) error {
	log.Printf("[Pairing] Starting offline pairing")

	// Generate CSR
	nodeName := *hubNodeName
	if nodeName == "" {
		nodeName, _ = os.Hostname()
	}

	csrPEM, err := generateCSR(privateKey, nodeName)
	if err != nil {
		return fmt.Errorf("failed to generate CSR: %w", err)
	}

	fingerprint := pairing.DeriveFingerprint(csrPEM)

	// If --pair-port is specified, use web UI mode
	if *pairPort != "" {
		return doPairingWeb(csrPEM, nodeName, fingerprint)
	}

	// Otherwise, use terminal mode
	return doPairingTerminal(csrPEM, nodeName, fingerprint)
}

// doPairingWeb handles web-based offline pairing (for Docker)
func doPairingWeb(csrPEM []byte, nodeName, fingerprint string) error {
	log.Printf("[Pairing] Starting web UI pairing on %s", *pairPort)

	// check for custom cert
	var cert *tls.Certificate
	if *tlsCert != "" && *tlsKey != "" {
		loadedCert, err := tls.LoadX509KeyPair(*tlsCert, *tlsKey)
		if err != nil {
			return fmt.Errorf("failed to load TLS cert: %w", err)
		}
		cert = &loadedCert
		log.Printf("[Pairing] Using provided TLS certificate: %s", *tlsCert)
	}

	// Create pairing web server
	server, err := pairing.NewPairingWebServer(pairing.PairingWebConfig{
		CSR:         csrPEM,
		NodeID:      nodeName,
		Timeout:     *pairTimeout,
		Certificate: cert,
		OnComplete: func(certPEM, caCertPEM []byte) error {
			// Save certificates
			certPath := filepath.Join(nodeDataDir, "node.crt")
			if err := os.WriteFile(certPath, certPEM, 0600); err != nil {
				return fmt.Errorf("failed to save certificate: %w", err)
			}

			if len(caCertPEM) > 0 {
				caPath := filepath.Join(nodeDataDir, "cli_ca.crt")
				if err := os.WriteFile(caPath, caCertPEM, 0644); err != nil {
					return fmt.Errorf("failed to save CA certificate: %w", err)
				}
			}

			caFingerprint := pairing.DeriveFingerprint(caCertPEM)
			log.Printf("[Pairing] Complete! CA fingerprint: %s", caFingerprint)
			logNodeCertificateIdentity("pairing", certPEM)
			return nil
		},
	})
	if err != nil {
		return fmt.Errorf("failed to create pairing server: %w", err)
	}

	// Print info to stdout (docker logs)
	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║              OFFLINE PAIRING (WEB UI)                         ║")
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Printf("║  Node Name:    %-45s  ║\n", nodeName)
	fmt.Printf("║  Fingerprint:  %-45s  ║\n", fingerprint)
	fmt.Printf("║  CPACE Words:  %-45s  ║\n", server.GetCPACEWords())
	fmt.Printf("║  Timeout:      %-45s  ║\n", pairTimeout.String())
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Printf("║  Web UI: https://localhost%s                              ║\n", *pairPort)
	fmt.Println("║                                                               ║")
	fmt.Println("║  1. Open the URL in your browser                             ║")
	fmt.Println("║  2. Enter CPACE words shown above                            ║")
	fmt.Println("║  3. Scan QR or paste signed certificate                      ║")
	fmt.Println("║  4. Verify CA fingerprint matches your CLI                   ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")
	fmt.Println()

	// Also print QR code to terminal
	fmt.Println("QR Code (also available in web UI):")
	pairing.GenerateCSRQR(csrPEM, nodeName, os.Stdout)
	fmt.Println()

	// Start web server (blocks until complete or timeout)
	if err := server.Start(*pairPort); err != nil {
		return fmt.Errorf("pairing failed: %w", err)
	}

	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║                    PAIRING COMPLETE!                          ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")
	fmt.Println()

	return nil
}

// doPairingTerminal handles terminal-based offline pairing
func doPairingTerminal(csrPEM []byte, nodeName, fingerprint string) error {
	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║              OFFLINE PAIRING (TERMINAL)                       ║")
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Printf("║  Node Name:   %-46s  ║\n", nodeName)
	fmt.Printf("║  Fingerprint: %-46s  ║\n", fingerprint)
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Println("║                                                               ║")
	fmt.Println("║  Scan this QR code with 'nitella hub pair-offline'           ║")
	fmt.Println("║                                                               ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")
	fmt.Println()

	// Generate QR code
	pairing.GenerateCSRQR(csrPEM, nodeName, os.Stdout)

	// Also print JSON for manual copy
	fmt.Println()
	fmt.Println("Or copy this JSON data:")
	payload := &pairing.QRPayload{
		Type:        "csr",
		Fingerprint: fingerprint,
		NodeID:      nodeName,
	}
	payload.CSR = string(csrPEM)
	jsonData, _ := json.Marshal(payload)
	fmt.Println(string(jsonData))

	fmt.Println()
	fmt.Println("After CLI signs the certificate, paste the response JSON below:")
	fmt.Print("> ")

	// Read response
	var input string
	fmt.Scanln(&input)

	if input == "" {
		return fmt.Errorf("no response provided")
	}

	// Parse response
	respPayload, err := pairing.ParseQRPayload(input)
	if err != nil {
		return fmt.Errorf("invalid response: %w", err)
	}

	if respPayload.Type != "cert" {
		return fmt.Errorf("expected certificate response, got '%s'", respPayload.Type)
	}

	certPEM, err := respPayload.GetCert()
	if err != nil {
		return fmt.Errorf("failed to decode certificate: %w", err)
	}

	caCertPEM, _ := respPayload.GetCACert()

	// Save certificates
	certPath := filepath.Join(nodeDataDir, "node.crt")
	if err := os.WriteFile(certPath, certPEM, 0600); err != nil {
		return fmt.Errorf("failed to save certificate: %w", err)
	}

	if len(caCertPEM) > 0 {
		caPath := filepath.Join(nodeDataDir, "cli_ca.crt")
		if err := os.WriteFile(caPath, caCertPEM, 0644); err != nil {
			return fmt.Errorf("failed to save CA certificate: %w", err)
		}
	}

	caFingerprint := pairing.DeriveFingerprint(caCertPEM)
	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║                    PAIRING COMPLETE!                          ║")
	fmt.Printf("║  CA Fingerprint: %-43s  ║\n", caFingerprint)
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")
	logNodeCertificateIdentity("pairing", certPEM)

	return nil
}

// generateCSR generates a certificate signing request
func generateCSR(privateKey ed25519.PrivateKey, commonName string) ([]byte, error) {
	template := x509.CertificateRequest{
		Subject: pkix.Name{
			CommonName: commonName,
		},
		DNSNames: []string{commonName},
	}

	csrDER, err := x509.CreateCertificateRequest(rand.Reader, &template, privateKey)
	if err != nil {
		return nil, err
	}

	return pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE REQUEST", Bytes: csrDER}), nil
}

// proxyMetricsProvider implements hubclient.MetricsProvider
type proxyMetricsProvider struct {
	pm *node.ProxyManager
}

func (p *proxyMetricsProvider) GetActiveConnections() int64 {
	// Use GetAllStatuses which exists on ProxyManager
	statuses := p.pm.GetAllStatuses()
	var total int64
	for _, s := range statuses {
		total += s.ActiveConnections
	}
	return total
}

func (p *proxyMetricsProvider) GetTotalConnections() int64 {
	statuses := p.pm.GetAllStatuses()
	var total int64
	for _, s := range statuses {
		total += s.TotalConnections
	}
	return total
}

func (p *proxyMetricsProvider) GetBytesIn() int64 {
	statuses := p.pm.GetAllStatuses()
	var total int64
	for _, s := range statuses {
		total += s.BytesIn
	}
	return total
}

func (p *proxyMetricsProvider) GetBytesOut() int64 {
	statuses := p.pm.GetAllStatuses()
	var total int64
	for _, s := range statuses {
		total += s.BytesOut
	}
	return total
}

// AppliedProxy represents a proxy config applied to this node
type AppliedProxy struct {
	ProxyID     string    `json:"proxy_id"`
	RevisionNum int64     `json:"revision_num"`
	ConfigHash  string    `json:"config_hash"`
	AppliedAt   time.Time `json:"applied_at"`
	Status      string    `json:"status"` // "active", "stopped", "error"
	ErrorMsg    string    `json:"error_msg,omitempty"`
	ListenerIDs []string  `json:"listener_ids,omitempty"` // Created proxy IDs
}

var (
	appliedProxies = make(map[string]*AppliedProxy)
	appliedMu      = &sync.RWMutex{}
)

// handleHubCommandInternal handles commands received from Hub
func handleHubCommandInternal(pm *node.ProxyManager, cmd string, params []byte) ([]byte, error) {
	log.Printf("[Hub] Received command: %s", cmd)

	switch cmd {
	case "COMMAND_TYPE_STATUS", "status":
		return getStatus(pm)
	case "COMMAND_TYPE_LIST_PROXIES", "list_proxies":
		return listProxies(pm)
	case "COMMAND_TYPE_LIST_RULES", "list_rules":
		return listRules(pm, params)
	case "COMMAND_TYPE_ADD_RULE", "add_rule":
		return addRule(pm, params)
	case "COMMAND_TYPE_REMOVE_RULE", "remove_rule":
		return removeRule(pm, params)
	case "COMMAND_TYPE_GET_ACTIVE_CONNECTIONS", "get_connections":
		return getConnections(pm, params)
	case "COMMAND_TYPE_CLOSE_CONNECTION", "close_connection":
		return closeConnection(pm, params)
	case "COMMAND_TYPE_CLOSE_ALL_CONNECTIONS", "close_all_connections":
		return closeAllConnections(pm, params)
	case "COMMAND_TYPE_GET_METRICS", "get_metrics":
		return getMetrics(pm)
	case "COMMAND_TYPE_APPLY_PROXY", "apply_proxy":
		var req pb.ApplyProxyRequest
		if err := proto.Unmarshal(params, &req); err == nil {
			return applyProxyTemplate(pm, &req)
		}
		return applyProxy(pm, params)
	case "COMMAND_TYPE_UNAPPLY_PROXY", "unapply_proxy":
		return unapplyProxy(pm, params)
	case "COMMAND_TYPE_GET_APPLIED", "get_applied":
		return getAppliedProxies(pm, params)
	case "COMMAND_TYPE_PROXY_UPDATE", "proxy_update":
		return handleProxyUpdate(pm, params)
	case "COMMAND_TYPE_RESOLVE_APPROVAL", "resolve_approval":
		return resolveApproval(pm, params)

	// Proxy lifecycle
	case "COMMAND_TYPE_CREATE_PROXY":
		return createProxy(pm, params)
	case "COMMAND_TYPE_DELETE_PROXY":
		return deleteProxy(pm, params)
	case "COMMAND_TYPE_ENABLE_PROXY":
		return enableProxy(pm, params)
	case "COMMAND_TYPE_DISABLE_PROXY":
		return disableProxy(pm, params)
	case "COMMAND_TYPE_UPDATE_PROXY":
		return updateProxy(pm, params)
	case "COMMAND_TYPE_RESTART_LISTENERS":
		return restartListeners(pm)
	case "COMMAND_TYPE_RELOAD_RULES":
		return reloadRules(pm, params)

	// Quick actions
	case "COMMAND_TYPE_BLOCK_IP":
		return blockIP(pm, params)
	case "COMMAND_TYPE_ALLOW_IP":
		return allowIP(pm, params)
	case "COMMAND_TYPE_LIST_GLOBAL_RULES":
		return listGlobalRules(pm)
	case "COMMAND_TYPE_REMOVE_GLOBAL_RULE":
		return removeGlobalRule(pm, params)

	// GeoIP
	case "COMMAND_TYPE_CONFIGURE_GEOIP":
		return configureGeoIP(pm, params)
	case "COMMAND_TYPE_GET_GEOIP_STATUS":
		return getGeoIPStatus(pm)
	case "COMMAND_TYPE_LOOKUP_IP":
		return lookupIP(pm, params)

	// Approval management
	case "COMMAND_TYPE_LIST_ACTIVE_APPROVALS":
		return listActiveApprovals(pm, params)
	case "COMMAND_TYPE_CANCEL_APPROVAL":
		return cancelApproval(pm, params)

	default:
		return nil, fmt.Errorf("unknown command: %s", cmd)
	}
}

func getStatus(pm *node.ProxyManager) ([]byte, error) {
	statuses := pm.GetAllStatuses()

	var totalConns, activeConns, bytesIn, bytesOut int64
	for _, s := range statuses {
		totalConns += s.TotalConnections
		activeConns += s.ActiveConnections
		bytesIn += s.BytesIn
		bytesOut += s.BytesOut
	}

	resp := &pb.StatsSummaryResponse{
		TotalConnections: totalConns,
		TotalBytesIn:     bytesIn,
		TotalBytesOut:    bytesOut,
	}
	return proto.Marshal(resp)
}

func listProxies(pm *node.ProxyManager) ([]byte, error) {
	statuses := pm.GetAllStatuses()
	resp := &pb.ListProxiesResponse{
		Proxies: statuses,
	}
	return proto.Marshal(resp)
}

func listRules(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.ListRulesRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	rules, err := pm.GetRules(req.ProxyId)
	if err != nil {
		return nil, err
	}
	resp := &pb.ListRulesResponse{
		Rules: rules,
	}
	return proto.Marshal(resp)
}

func addRule(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.AddRuleRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	resp, err := pm.AddRule(&req)
	if err != nil {
		return nil, err
	}
	// Return the created rule as the response
	return proto.Marshal(resp)
}

func removeRule(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.RemoveRuleRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	err := pm.RemoveRule(&req)
	if err != nil {
		return nil, err
	}
	// Return empty bytes on success (caller sets status to "OK")
	return nil, nil
}

func getConnections(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.GetActiveConnectionsRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, fmt.Errorf("invalid params: %w", err)
	}
	conns := pm.GetActiveConnections(req.ProxyId)

	// Convert ConnectionMetadata to proto ActiveConnection
	activeConns := make([]*pb.ActiveConnection, 0, len(conns))
	for _, c := range conns {
		activeConns = append(activeConns, &pb.ActiveConnection{
			Id:         c.ID,
			SourceIp:   c.SourceIP,
			SourcePort: int32(c.SourcePort),
			DestAddr:   c.DestAddr,
			BytesIn:    *c.BytesIn,
			BytesOut:   *c.BytesOut,
		})
	}

	resp := &pb.GetActiveConnectionsResponse{
		Connections: activeConns,
	}
	return proto.Marshal(resp)
}

func closeConnection(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.CloseConnectionRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	// Validate required fields
	if req.ConnId == "" {
		return nil, errors.New("conn_id is required")
	}
	err := pm.CloseConnection(req.ProxyId, req.ConnId)
	if err != nil {
		return nil, err
	}
	resp := &pb.CloseConnectionResponse{
		Success: true,
	}
	return proto.Marshal(resp)
}

func closeAllConnections(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.CloseAllConnectionsRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	err := pm.CloseAllConnections(req.ProxyId)
	if err != nil {
		return nil, err
	}
	resp := &pb.CloseAllConnectionsResponse{
		Success: true,
	}
	return proto.Marshal(resp)
}

func getMetrics(pm *node.ProxyManager) ([]byte, error) {
	// Aggregate metrics from all proxies using GetAllStatuses
	statuses := pm.GetAllStatuses()

	var totalConns, activeConns, bytesIn, bytesOut int64
	for _, s := range statuses {
		totalConns += s.TotalConnections
		activeConns += s.ActiveConnections
		bytesIn += s.BytesIn
		bytesOut += s.BytesOut
	}

	resp := &pb.StatsSummaryResponse{
		TotalConnections:  totalConns,
		TotalBytesIn:      bytesIn,
		TotalBytesOut:     bytesOut,
		ActiveConnections: activeConns,
		ProxyCount:        int32(len(statuses)),
		Timestamp:         timestamppb.Now(),
	}
	return proto.Marshal(resp)
}

// closeHub closes the Hub connection
func closeHub() {
	if hubClient != nil {
		hubClient.Stop()
		hubClient = nil
	}
}

// ===========================================================================
// Proxy Template Management Commands
// ===========================================================================

// applyProxy applies a proxy configuration from Hub
func applyProxy(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.CreateProxyRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, fmt.Errorf("invalid request: %w", err)
	}

	log.Printf("[Hub] Applying proxy (name=%s, listen=%s)", req.Name, req.ListenAddr)

	// Create the proxy via ProxyManager
	createResp, err := pm.CreateProxy(&req)
	if err != nil {
		return nil, fmt.Errorf("failed to create proxy: %w", err)
	}

	if !createResp.Success {
		return nil, fmt.Errorf("failed to create proxy: %s", createResp.ErrorMessage)
	}

	// Track the applied proxy
	applied := &AppliedProxy{
		ProxyID:     createResp.ProxyId,
		AppliedAt:   time.Now(),
		Status:      "active",
		ListenerIDs: []string{createResp.ProxyId},
	}

	appliedMu.Lock()
	appliedProxies[createResp.ProxyId] = applied
	appliedMu.Unlock()

	// Save applied proxies to file for persistence
	saveAppliedProxies()

	log.Printf("[Hub] Proxy %s applied successfully", createResp.ProxyId)

	// Return ProxyStatus (what the mobile client expects to unmarshal)
	status := &pb.ProxyStatus{
		ProxyId:        createResp.ProxyId,
		Running:        true,
		ListenAddr:     req.ListenAddr,
		DefaultBackend: req.DefaultBackend,
		DefaultAction:  req.DefaultAction,
		DefaultMock:    req.DefaultMock,
		FallbackAction: req.FallbackAction,
		FallbackMock:   req.FallbackMock,
	}
	return proto.Marshal(status)
}

// unapplyProxy removes a proxy configuration
func unapplyProxy(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.DeleteProxyRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, fmt.Errorf("invalid request: %w", err)
	}

	if req.ProxyId == "" {
		return nil, errors.New("proxy_id is required")
	}

	appliedMu.Lock()
	applied, exists := appliedProxies[req.ProxyId]
	if !exists {
		appliedMu.Unlock()
		resp := &pb.DeleteProxyResponse{
			Success:      false,
			ErrorMessage: "proxy not applied",
		}
		return proto.Marshal(resp)
	}

	// Remove created listeners completely (stop + delete from manager)
	for _, listenerID := range applied.ListenerIDs {
		if err := pm.RemoveProxy(listenerID); err != nil {
			log.Printf("[Hub] Warning: failed to remove listener %s: %v", listenerID, err)
		}
	}

	delete(appliedProxies, req.ProxyId)
	appliedMu.Unlock()

	// Save updated state
	saveAppliedProxies()

	log.Printf("[Hub] Proxy %s unapplied", req.ProxyId)

	resp := &pb.DeleteProxyResponse{
		Success: true,
	}
	return proto.Marshal(resp)
}

// getAppliedProxies returns list of applied proxy configs
func getAppliedProxies(pm *node.ProxyManager, params []byte) ([]byte, error) {
	appliedMu.RLock()
	defer appliedMu.RUnlock()

	var pbProxies []*pb.AppliedProxyStatus
	for _, ap := range appliedProxies {
		pbProxies = append(pbProxies, &pb.AppliedProxyStatus{
			ProxyId:     ap.ProxyID,
			RevisionNum: ap.RevisionNum,
			AppliedAt:   ap.AppliedAt.Format(time.RFC3339),
			Status:      ap.Status,
		})
	}

	resp := &pb.GetAppliedProxiesResponse{Proxies: pbProxies}
	return proto.Marshal(resp)
}

// handleProxyUpdate handles proxy update commands from the mobile client
func handleProxyUpdate(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.UpdateProxyRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, fmt.Errorf("invalid request: %w", err)
	}

	if req.ProxyId == "" {
		return nil, errors.New("proxy_id is required")
	}

	log.Printf("[Hub] Updating proxy %s", req.ProxyId)

	// Delegate to ProxyManager
	// Note: ProxyManager doesn't have UpdateProxy yet, so we use the existing
	// approach: check if applied, then update
	appliedMu.RLock()
	_, exists := appliedProxies[req.ProxyId]
	appliedMu.RUnlock()

	if !exists {
		resp := &pb.UpdateProxyResponse{
			Success:      false,
			ErrorMessage: "proxy not applied on this node",
		}
		return proto.Marshal(resp)
	}

	resp := &pb.UpdateProxyResponse{
		Success: true,
	}
	return proto.Marshal(resp)
}

// saveAppliedProxies persists the applied proxies to disk
func saveAppliedProxies() {
	appliedMu.RLock()
	defer appliedMu.RUnlock()

	data, err := json.MarshalIndent(appliedProxies, "", "  ")
	if err != nil {
		log.Printf("[Hub] Failed to serialize applied proxies: %v", err)
		return
	}

	path := filepath.Join(nodeDataDir, "applied_proxies.json")
	if err := os.WriteFile(path, data, 0600); err != nil {
		log.Printf("[Hub] Failed to save applied proxies: %v", err)
	}
}

// loadAppliedProxies loads applied proxies from disk
func loadAppliedProxies() {
	path := filepath.Join(nodeDataDir, "applied_proxies.json")
	data, err := os.ReadFile(path)
	if err != nil {
		return // No file yet
	}

	appliedMu.Lock()
	defer appliedMu.Unlock()

	if err := json.Unmarshal(data, &appliedProxies); err != nil {
		log.Printf("[Hub] Failed to load applied proxies: %v", err)
	}
}

// resolveApproval handles approval decisions from the Hub
func resolveApproval(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.ResolveApprovalRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, fmt.Errorf("failed to parse resolve approval request: %w", err)
	}

	log.Printf("[Hub] Parsed RESOLVE_APPROVAL: req_id=%q, action=%v, duration=%ds, reason=%q",
		req.ReqId, req.Action, req.DurationSeconds, req.Reason)

	if pm.Approval == nil {
		return nil, fmt.Errorf("approval manager not initialized")
	}

	allowed := req.Action == common.ApprovalActionType_APPROVAL_ACTION_TYPE_ALLOW
	retentionMode := req.GetRetentionMode()
	if retentionMode == common.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_UNSPECIFIED {
		retentionMode = common.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CACHE
	}
	durationSeconds := req.DurationSeconds
	if retentionMode == common.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CACHE && durationSeconds <= 0 {
		durationSeconds = config.DefaultApprovalDurationSeconds
	}
	if retentionMode == common.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CONNECTION_ONLY && durationSeconds < 0 {
		durationSeconds = 0
	}

	log.Printf("[Hub] Resolving approval request %s (action=%v, mode=%v, duration=%ds)",
		req.ReqId, req.Action, retentionMode, durationSeconds)

	meta := pm.Approval.ResolveWithRetention(req.ReqId, allowed, durationSeconds, req.Reason, retentionMode)
	if meta == nil {
		return nil, fmt.Errorf("no pending approval found for request %s", req.ReqId)
	}

	log.Printf("[Hub] Approval %s resolved: allowed=%v, mode=%v, duration=%ds, reason=%q, source=%s",
		req.ReqId, allowed, retentionMode, durationSeconds, req.Reason, meta.SourceIP)

	resp := &pb.ResolveApprovalResponse{
		Success: true,
	}
	return proto.Marshal(resp)
}

// ===========================================================================
// Proxy Lifecycle Commands
// ===========================================================================

func createProxy(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.CreateProxyRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	resp, err := pm.CreateProxy(&req)
	if err != nil {
		return nil, err
	}
	return proto.Marshal(resp)
}

func deleteProxy(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.DeleteProxyRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	_, err := pm.DisableProxy(req.ProxyId)
	if err != nil {
		return proto.Marshal(&pb.DeleteProxyResponse{Success: false, ErrorMessage: err.Error()})
	}
	return proto.Marshal(&pb.DeleteProxyResponse{Success: true})
}

func enableProxy(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.EnableProxyRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	resp, err := pm.EnableProxy(req.ProxyId)
	if err != nil {
		return nil, err
	}
	return proto.Marshal(resp)
}

func disableProxy(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.DisableProxyRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	resp, err := pm.DisableProxy(req.ProxyId)
	if err != nil {
		return nil, err
	}
	return proto.Marshal(resp)
}

func updateProxy(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.UpdateProxyRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	resp, err := pm.UpdateProxy(&req)
	if err != nil {
		return nil, err
	}
	return proto.Marshal(resp)
}

func restartListeners(pm *node.ProxyManager) ([]byte, error) {
	resp, err := pm.RestartListeners()
	if err != nil {
		return nil, err
	}
	return proto.Marshal(resp)
}

func reloadRules(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.ReloadRulesRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	statuses := pm.GetAllStatuses()
	totalLoaded := int32(0)
	for _, st := range statuses {
		resp, err := pm.ReloadRules(st.ProxyId, req.Rules)
		if err == nil && resp.Success {
			totalLoaded += resp.RulesLoaded
		}
	}
	return proto.Marshal(&pb.ReloadRulesResponse{Success: true, RulesLoaded: totalLoaded})
}

// ===========================================================================
// Quick Action Commands
// ===========================================================================

func blockIP(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.BlockIPRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	if err := validateIPOrCIDRHub(req.Ip); err != nil {
		return nil, err
	}
	globalRules := pm.GetGlobalRules()
	if globalRules != nil {
		duration := time.Duration(req.DurationSeconds) * time.Second
		globalRules.BlockIP(req.Ip, duration)
		log.Printf("[Hub] Global block added: %s (duration: %v)", req.Ip, duration)
	} else {
		statuses := pm.GetAllStatuses()
		for _, st := range statuses {
			pm.AddRule(&pb.AddRuleRequest{
				ProxyId: st.ProxyId,
				Rule: &pb.Rule{
					Name: "Quick Block: " + req.Ip, Priority: 1000, Enabled: true,
					Action: common.ActionType_ACTION_TYPE_BLOCK,
					Conditions: []*pb.Condition{{
						Type: common.ConditionType_CONDITION_TYPE_SOURCE_IP, Op: common.Operator_OPERATOR_EQ, Value: req.Ip,
					}},
				},
			})
		}
	}
	return nil, nil
}

func allowIP(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.AllowIPRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	if err := validateIPOrCIDRHub(req.Ip); err != nil {
		return nil, err
	}
	globalRules := pm.GetGlobalRules()
	if globalRules != nil {
		duration := time.Duration(req.DurationSeconds) * time.Second
		globalRules.AllowIP(req.Ip, duration)
		log.Printf("[Hub] Global allow added: %s (duration: %v)", req.Ip, duration)
	} else {
		statuses := pm.GetAllStatuses()
		for _, st := range statuses {
			pm.AddRule(&pb.AddRuleRequest{
				ProxyId: st.ProxyId,
				Rule: &pb.Rule{
					Name: "Quick Allow: " + req.Ip, Priority: 1000, Enabled: true,
					Action: common.ActionType_ACTION_TYPE_ALLOW,
					Conditions: []*pb.Condition{{
						Type: common.ConditionType_CONDITION_TYPE_SOURCE_IP, Op: common.Operator_OPERATOR_EQ, Value: req.Ip,
					}},
				},
			})
		}
	}
	return nil, nil
}

func listGlobalRules(pm *node.ProxyManager) ([]byte, error) {
	globalRules := pm.GetGlobalRules()
	if globalRules == nil {
		return proto.Marshal(&pb.ListGlobalRulesResponse{})
	}
	rules := globalRules.List()
	pbRules := make([]*pb.GlobalRule, 0, len(rules))
	for _, r := range rules {
		pbRule := &pb.GlobalRule{
			Id: r.ID, Name: r.Name, SourceIp: r.SourceIP, Action: r.Action,
			CreatedAt: timestamppb.New(r.CreatedAt),
		}
		if !r.ExpiresAt.IsZero() {
			pbRule.ExpiresAt = timestamppb.New(r.ExpiresAt)
		}
		pbRules = append(pbRules, pbRule)
	}
	return proto.Marshal(&pb.ListGlobalRulesResponse{Rules: pbRules})
}

func removeGlobalRule(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.RemoveGlobalRuleRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	globalRules := pm.GetGlobalRules()
	if globalRules == nil {
		return proto.Marshal(&pb.RemoveGlobalRuleResponse{Success: false, ErrorMessage: "Global rules not configured"})
	}
	if !globalRules.Remove(req.RuleId) {
		return proto.Marshal(&pb.RemoveGlobalRuleResponse{Success: false, ErrorMessage: "Rule not found"})
	}
	log.Printf("[Hub] Global rule removed: %s", req.RuleId)
	return proto.Marshal(&pb.RemoveGlobalRuleResponse{Success: true})
}

// ===========================================================================
// GeoIP Commands
// ===========================================================================

func configureGeoIP(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.ConfigureGeoIPRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	resp, err := pm.ConfigureGeoIP(&req)
	if err != nil {
		return nil, err
	}
	return proto.Marshal(resp)
}

func getGeoIPStatus(pm *node.ProxyManager) ([]byte, error) {
	resp, err := pm.GetGeoIPStatus(&pb.GetGeoIPStatusRequest{})
	if err != nil {
		return nil, err
	}
	return proto.Marshal(resp)
}

func lookupIP(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.LookupIPRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	resp, err := pm.LookupIP(&req)
	if err != nil {
		return nil, err
	}
	return proto.Marshal(resp)
}

// ===========================================================================
// Approval Management Commands
// ===========================================================================

func listActiveApprovals(pm *node.ProxyManager, params []byte) ([]byte, error) {
	if pm.Approval == nil {
		return proto.Marshal(&pb.ListActiveApprovalsResponse{})
	}
	var req pb.ListActiveApprovalsRequest
	if len(params) > 0 {
		if err := proto.Unmarshal(params, &req); err != nil {
			return nil, err
		}
	}
	entries := pm.Approval.GetActiveApprovals()
	approvals := make([]*pb.ActiveApproval, 0, len(entries))
	for _, e := range entries {
		if req.ProxyId != "" && e.ProxyID != req.ProxyId {
			continue
		}
		if req.SourceIp != "" && e.SourceIP != req.SourceIp {
			continue
		}
		connIDs := make([]string, 0, len(e.LiveConns))
		for connID := range e.LiveConns {
			connIDs = append(connIDs, connID)
		}
		approvals = append(approvals, &pb.ActiveApproval{
			Key: e.Key(), SourceIp: e.SourceIP, RuleId: e.RuleID,
			ProxyId: e.ProxyID, TlsSessionId: e.TLSSessionID, Allowed: e.Decision,
			CreatedAt: timestamppb.New(e.CreatedAt), ExpiresAt: timestamppb.New(e.ExpiresAt),
			BytesIn: e.BytesIn, BytesOut: e.BytesOut, BlockedCount: int64(e.BlockedCount),
			ConnIds: connIDs, GeoCountry: e.GeoCountry, GeoCity: e.GeoCity, GeoIsp: e.GeoISP,
		})
	}
	return proto.Marshal(&pb.ListActiveApprovalsResponse{Approvals: approvals})
}

func cancelApproval(pm *node.ProxyManager, params []byte) ([]byte, error) {
	var req pb.CancelApprovalRequest
	if err := proto.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	if pm.Approval == nil {
		return proto.Marshal(&pb.CancelApprovalResponse{Success: false, ErrorMessage: "Approval system not configured"})
	}
	parts := strings.Split(req.Key, node.KeySeparator)
	if len(parts) < 2 {
		return proto.Marshal(&pb.CancelApprovalResponse{Success: false, ErrorMessage: "Invalid approval key format"})
	}
	sourceIP, ruleID := parts[0], parts[1]
	tlsSessionID := ""
	if len(parts) > 2 {
		tlsSessionID = parts[2]
	}
	entry := pm.Approval.GetEntry(sourceIP, ruleID, tlsSessionID)
	if entry == nil {
		return proto.Marshal(&pb.CancelApprovalResponse{Success: false, ErrorMessage: "Approval not found"})
	}
	connectionsClosed := int32(0)
	if req.CloseConnections && len(entry.LiveConns) > 0 {
		for connID := range entry.LiveConns {
			if err := pm.CloseConnection(entry.ProxyID, connID); err == nil {
				connectionsClosed++
			}
		}
	}
	pm.Approval.RemoveApproval(sourceIP, ruleID, tlsSessionID)
	log.Printf("[Hub] Approval cancelled: %s (connections closed: %d)", req.Key, connectionsClosed)
	return proto.Marshal(&pb.CancelApprovalResponse{Success: true, ConnectionsClosed: connectionsClosed})
}

// ensureHubCA resolves the Hub CA certificate, using TOFU if necessary
func ensureHubCA(hubAddr string) ([]byte, error) {
	// 1. If explicit flag provided, use it
	if *hubCAPEM != "" {
		return os.ReadFile(*hubCAPEM)
	}

	// 2. Check local cache
	cachedPath := filepath.Join(nodeDataDir, "hub_ca.crt")
	if data, err := os.ReadFile(cachedPath); err == nil {
		log.Printf("[Hub] Using cached Hub CA: %s", cachedPath)

		// Parse and display info
		block, _ := pem.Decode(data)
		if block != nil {
			cert, err := x509.ParseCertificate(block.Bytes)
			if err == nil {
				fingerprint, emojiHash := core.CertFingerprintAndEmoji(cert)
				log.Printf("[Hub] CA Fingerprint: %s", fingerprint)
				log.Printf("[Hub] CA Emoji Hash:  %s", emojiHash)
			}
		}
		return data, nil
	}

	// 3. TOFU Probe
	log.Printf("[Hub] No Hub CA provided or found. Probing %s for TOFU...", hubAddr)
	info, err := core.ProbeHubCA(hubAddr)
	if err != nil {
		return nil, fmt.Errorf("failed to probe Hub CA: %w", err)
	}

	// 4. Display Warning
	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║                   SECURITY WARNING (TOFU)                    ║")
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Println("║  Trusting Hub CA for the first time. Verify this matches!    ║")
	fmt.Printf("║  Fingerprint: %-46s ║\n", info.Fingerprint[:min(46, len(info.Fingerprint))])
	if len(info.Fingerprint) > 46 {
		fmt.Printf("║               %-46s ║\n", info.Fingerprint[46:])
	}
	fmt.Printf("║  Emoji Hash:  %-46s ║\n", info.EmojiHash)
	fmt.Println("║                                                              ║")
	fmt.Println("║  The certificate will be saved to:                           ║")
	fmt.Printf("║  %-58s  ║\n", cachedPath)
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")
	fmt.Println()

	// 5. Save and Return
	if err := os.WriteFile(cachedPath, info.CaPEM, 0644); err != nil {
		return nil, fmt.Errorf("failed to save probed Hub CA: %w", err)
	}

	return info.CaPEM, nil
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func certIdentity(certPEM []byte) (string, string, error) {
	block, _ := pem.Decode(certPEM)
	if block == nil {
		return "", "", fmt.Errorf("invalid certificate PEM")
	}
	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return "", "", err
	}
	pubKey, ok := cert.PublicKey.(ed25519.PublicKey)
	if !ok || len(pubKey) != ed25519.PublicKeySize {
		return "", "", fmt.Errorf("certificate public key is not ed25519")
	}
	return identity.GenerateFingerprint(pubKey), identity.GenerateEmojiHash(pubKey), nil
}

func logNodeCertificateIdentity(contextName string, nodeCertPEM []byte) {
	nodeFP, nodeEmoji, err := certIdentity(nodeCertPEM)
	if err != nil {
		log.Printf("[Identity:%s] Unable to derive node certificate identity: %v", contextName, err)
		return
	}
	log.Printf("[Identity:%s] Node cert fingerprint: %s", contextName, nodeFP)
	log.Printf("[Identity:%s] Node cert emoji hash: %s", contextName, nodeEmoji)
}

// applyProxyTemplate applies a full YAML configuration from Proto request
func applyProxyTemplate(pm *node.ProxyManager, req *pb.ApplyProxyRequest) ([]byte, error) {
	var yamlConfig config.YAMLConfig
	if err := yaml.Unmarshal([]byte(req.ConfigYaml), &yamlConfig); err != nil {
		return nil, fmt.Errorf("failed to parse YAML: %w", err)
	}

	proxyID := req.ProxyId
	revNum := req.RevisionNum

	log.Printf("[Hub] Applying proxy config %s (rev %d)", proxyID, revNum)

	// Stop/Remove existing listeners for this proxyID
	appliedMu.Lock()
	if existing, ok := appliedProxies[proxyID]; ok {
		for _, lid := range existing.ListenerIDs {
			if err := pm.RemoveProxy(lid); err != nil {
				log.Printf("[Hub] Warning: failed to remove old listener %s: %v", lid, err)
			}
		}
	}
	appliedMu.Unlock()

	var newListenerIDs []string
	var lastError error

	// Create new listeners
	for name, ep := range yamlConfig.EntryPoints {
		// Determine backend
		defaultBackend := ep.DefaultBackend
		// Find associated service (Basic logic matching main.go)
		for _, router := range yamlConfig.TCP.Routers {
			if containsString(router.EntryPoints, name) && router.Service != "" {
				if svc, ok := yamlConfig.TCP.Services[router.Service]; ok {
					if svc.LoadBalancer != nil && len(svc.LoadBalancer.Servers) > 0 {
						srv := svc.LoadBalancer.Servers[0]
						if srv.Address != "" {
							defaultBackend = srv.Address
						} else {
							defaultBackend = srv.URL
						}
					} else {
						defaultBackend = svc.Address
					}
					break
				}
			}
		}

		// Convert string action to enum
		var actionType common.ActionType
		switch strings.ToLower(ep.DefaultAction) {
		case "block":
			actionType = common.ActionType_ACTION_TYPE_BLOCK
		case "mock":
			actionType = common.ActionType_ACTION_TYPE_MOCK
		case "approval":
			actionType = common.ActionType_ACTION_TYPE_REQUIRE_APPROVAL
		default:
			actionType = common.ActionType_ACTION_TYPE_ALLOW
		}

		log.Printf("[Hub] CreateProxy %s: Addr=%s, Action=%v (from YAML: %s)", name, ep.Address, actionType, ep.DefaultAction)

		// Convert fallback action string to enum
		var fallbackAction common.FallbackAction
		switch strings.ToLower(ep.FallbackAction) {
		case "mock":
			fallbackAction = common.FallbackAction_FALLBACK_ACTION_MOCK
		case "close":
			fallbackAction = common.FallbackAction_FALLBACK_ACTION_CLOSE
		default:
			fallbackAction = common.FallbackAction_FALLBACK_ACTION_UNSPECIFIED
		}

		// Create Proxy
		resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
			ListenAddr:     ep.Address,
			DefaultBackend: defaultBackend,
			Name:           fmt.Sprintf("%s-%s", proxyID[:8], name),
			DefaultAction:  actionType,
			DefaultMock:    node.StringToMockPreset(ep.DefaultMock),
			FallbackAction: fallbackAction,
			FallbackMock:   node.StringToMockPreset(ep.FallbackMock),
		})

		if err != nil {
			lastError = err
			log.Printf("[Hub] Failed to create listener %s: %v", name, err)
			continue
		}
		if !resp.Success {
			lastError = errors.New(resp.ErrorMessage)
			log.Printf("[Hub] Failed to create listener %s: %s", name, resp.ErrorMessage)
			continue
		}

		newListenerIDs = append(newListenerIDs, resp.ProxyId)
		log.Printf("[Hub] Started listener %s on %s -> %s", name, ep.Address, defaultBackend)
	}

	if len(newListenerIDs) == 0 && lastError != nil {
		return nil, fmt.Errorf("failed to apply any listeners: %v", lastError)
	}

	// Update applied state
	applied := &AppliedProxy{
		ProxyID:     proxyID,
		RevisionNum: revNum,
		AppliedAt:   time.Now(),
		Status:      "active",
		ListenerIDs: newListenerIDs,
	}

	appliedMu.Lock()
	appliedProxies[proxyID] = applied
	appliedMu.Unlock()

	saveAppliedProxies()

	return proto.Marshal(&pb.ApplyProxyResponse{Success: true})
}

// validateIPOrCIDRHub validates an IP address or CIDR notation string.
func validateIPOrCIDRHub(input string) error {
	if input == "" {
		return fmt.Errorf("IP/CIDR cannot be empty")
	}
	if strings.Contains(input, "/") {
		_, _, err := net.ParseCIDR(input)
		if err != nil {
			return fmt.Errorf("invalid CIDR: %v", err)
		}
		return nil
	}
	if net.ParseIP(input) == nil {
		return fmt.Errorf("invalid IP address: %s", input)
	}
	return nil
}
