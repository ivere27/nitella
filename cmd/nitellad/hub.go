package main

import (
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/json"
	"encoding/pem"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sync"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	hubpb "github.com/ivere27/nitella/pkg/api/hub"
	pb "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/cli"
	"github.com/ivere27/nitella/pkg/config"
	"github.com/ivere27/nitella/pkg/hubclient"
	"github.com/ivere27/nitella/pkg/log"
	"github.com/ivere27/nitella/pkg/node"
	"github.com/ivere27/nitella/pkg/pairing"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
)

var (
	// Hub connection flags
	hubAddr     = flag.String("hub", os.Getenv("NITELLA_HUB"), "Hub server address (env: NITELLA_HUB)")
	hubDataDir  = flag.String("hub-data-dir", "", "Hub data directory for identity storage")
	hubNodeName = flag.String("hub-node-name", "", "Node name for Hub (default: hostname)")
	hubP2P      = flag.Bool("hub-p2p", true, "Enable P2P connections via Hub")
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
	// Parse command payload as JSON
	var params json.RawMessage
	if len(payload) > 0 {
		params = payload
	}

	// Map CommandType to string command
	cmdStr := cmdType.String()

	result, err := handleHubCommandInternal(h.pm, cmdStr, params)
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
		nodeDataDir = filepath.Join(home, ".nitellad")
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

	// Load CLI's CA cert for verification if available
	if caPEM, err := os.ReadFile(caPath); err == nil {
		roots := x509.NewCertPool()
		roots.AppendCertsFromPEM(caPEM)
		// Don't set RootCAs - we verify Hub's CA separately
		_ = roots
	}

	// Load Hub CA - mTLS requires proper certificate verification
	var hubCACert []byte
	if *hubCAPEM != "" {
		caPEM, err := os.ReadFile(*hubCAPEM)
		if err != nil {
			return false, fmt.Errorf("failed to read Hub CA certificate: %w", err)
		}
		hubCACert = caPEM
	}
	roots, err := cli.LoadCertPoolFromPEM(hubCACert)
	if err != nil {
		return false, fmt.Errorf("hub CA not configured (--hub-ca) and system CA pool unavailable: %w", err)
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
		nodeDataDir = filepath.Join(home, ".nitellad")
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

	// Connect to Hub for pairing - mTLS requires proper certificate verification
	tlsConfig := &tls.Config{
		MinVersion: tls.VersionTLS13,
	}

	roots, err := cli.LoadCertPool(*hubCAPEM)
	if err != nil {
		return fmt.Errorf("hub CA required for pairing (--hub-ca): %w", err)
	}
	tlsConfig.RootCAs = roots

	conn, err := grpc.Dial(*hubAddr,
		grpc.WithTransportCredentials(credentials.NewTLS(tlsConfig)),
	)
	if err != nil {
		return fmt.Errorf("failed to connect to Hub: %w", err)
	}
	defer conn.Close()

	// Create PAKE session
	pakeSession, err := pairing.NewPakeSession(pairing.RoleNode, pairing.CodeToBytes(code))
	if err != nil {
		return fmt.Errorf("failed to create PAKE session: %w", err)
	}

	// Connect to PAKE exchange
	pairingClient := hubpb.NewPairingServiceClient(conn)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancel()

	stream, err := pairingClient.PakeExchange(ctx)
	if err != nil {
		return fmt.Errorf("failed to start PAKE exchange: %w", err)
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

	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║                    PAIRING COMPLETE!                          ║")
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Println("║    Certificate saved. Node is now paired with CLI.            ║")
	fmt.Println("║                                                                ║")
	fmt.Println("║    Run nitellad without --pair to start normally.             ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")
	fmt.Println()

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
	ProxyID       string    `json:"proxy_id"`
	RevisionNum   int64     `json:"revision_num"`
	ConfigHash    string    `json:"config_hash"`
	AppliedAt     time.Time `json:"applied_at"`
	Status        string    `json:"status"` // "active", "stopped", "error"
	ErrorMsg      string    `json:"error_msg,omitempty"`
	ListenerIDs   []string  `json:"listener_ids,omitempty"` // Created proxy IDs
}

var (
	appliedProxies = make(map[string]*AppliedProxy)
	appliedMu      = &sync.RWMutex{}
)

// handleHubCommandInternal handles commands received from Hub
func handleHubCommandInternal(pm *node.ProxyManager, cmd string, params json.RawMessage) ([]byte, error) {
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
	case "COMMAND_TYPE_GET_CONNECTIONS", "get_connections":
		return getConnections(pm, params)
	case "COMMAND_TYPE_CLOSE_CONNECTION", "close_connection":
		return closeConnection(pm, params)
	case "COMMAND_TYPE_GET_METRICS", "get_metrics":
		return getMetrics(pm)
	case "COMMAND_TYPE_APPLY_PROXY", "apply_proxy":
		return applyProxy(pm, params)
	case "COMMAND_TYPE_UNAPPLY_PROXY", "unapply_proxy":
		return unapplyProxy(pm, params)
	case "COMMAND_TYPE_GET_APPLIED", "get_applied":
		return getAppliedProxies(pm, params)
	case "COMMAND_TYPE_PROXY_UPDATE", "proxy_update":
		return handleProxyUpdate(pm, params)
	case "COMMAND_TYPE_RESOLVE_APPROVAL", "resolve_approval":
		return resolveApproval(pm, params)
	default:
		return json.Marshal(map[string]string{"error": "unknown command: " + cmd})
	}
}

func getStatus(pm *node.ProxyManager) ([]byte, error) {
	statuses := pm.GetAllStatuses()

	var totalConns, activeConns int64
	for _, s := range statuses {
		totalConns += s.TotalConnections
		activeConns += s.ActiveConnections
	}

	status := map[string]interface{}{
		"proxy_count":        len(statuses),
		"total_connections":  totalConns,
		"active_connections": activeConns,
	}
	return json.Marshal(status)
}

func listProxies(pm *node.ProxyManager) ([]byte, error) {
	statuses := pm.GetAllStatuses()
	return json.Marshal(statuses)
}

func listRules(pm *node.ProxyManager, params json.RawMessage) ([]byte, error) {
	var req struct {
		ProxyID string `json:"proxy_id"`
	}
	if err := json.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	rules, err := pm.GetRules(req.ProxyID)
	if err != nil {
		return nil, err
	}
	return json.Marshal(rules)
}

func addRule(pm *node.ProxyManager, params json.RawMessage) ([]byte, error) {
	var req pb.AddRuleRequest
	if err := json.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	resp, err := pm.AddRule(&req)
	if err != nil {
		return nil, err
	}
	return json.Marshal(map[string]string{"rule_id": resp.Id})
}

func removeRule(pm *node.ProxyManager, params json.RawMessage) ([]byte, error) {
	var req pb.RemoveRuleRequest
	if err := json.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	err := pm.RemoveRule(&req)
	if err != nil {
		return nil, err
	}
	return json.Marshal(map[string]string{"status": "ok"})
}

func getConnections(pm *node.ProxyManager, params json.RawMessage) ([]byte, error) {
	var req struct {
		ProxyID string `json:"proxy_id"`
	}
	if err := json.Unmarshal(params, &req); err != nil {
		return nil, fmt.Errorf("invalid params: %w", err)
	}
	conns := pm.GetActiveConnections(req.ProxyID)
	return json.Marshal(conns)
}

func closeConnection(pm *node.ProxyManager, params json.RawMessage) ([]byte, error) {
	var req struct {
		ProxyID string `json:"proxy_id"`
		ConnID  string `json:"conn_id"`
	}
	if err := json.Unmarshal(params, &req); err != nil {
		return nil, err
	}
	// Validate required fields
	if req.ConnID == "" {
		return nil, errors.New("conn_id is required")
	}
	err := pm.CloseConnection(req.ProxyID, req.ConnID)
	if err != nil {
		return nil, err
	}
	return json.Marshal(map[string]interface{}{"success": true})
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

	metrics := map[string]interface{}{
		"timestamp":          time.Now().Unix(),
		"proxy_count":        len(statuses),
		"total_connections":  totalConns,
		"active_connections": activeConns,
		"bytes_in":           bytesIn,
		"bytes_out":          bytesOut,
	}

	return json.Marshal(metrics)
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

// ApplyProxyRequest contains the proxy config to apply
type ApplyProxyRequest struct {
	ProxyID     string `json:"proxy_id"`
	RevisionNum int64  `json:"revision_num"`
	ConfigYAML  string `json:"config_yaml"` // Decrypted YAML from CLI
	ConfigHash  string `json:"config_hash"`
}

// applyProxy applies a proxy configuration from Hub
func applyProxy(pm *node.ProxyManager, params json.RawMessage) ([]byte, error) {
	var req ApplyProxyRequest
	if err := json.Unmarshal(params, &req); err != nil {
		return nil, fmt.Errorf("invalid request: %w", err)
	}

	if req.ProxyID == "" || req.ConfigYAML == "" {
		return nil, errors.New("proxy_id and config_yaml are required")
	}

	log.Printf("[Hub] Applying proxy %s (revision %d)", req.ProxyID, req.RevisionNum)

	// Check if already applied
	appliedMu.RLock()
	existing, exists := appliedProxies[req.ProxyID]
	appliedMu.RUnlock()

	if exists && existing.Status == "active" {
		// Already applied - check if update needed
		if existing.RevisionNum == req.RevisionNum && existing.ConfigHash == req.ConfigHash {
			return json.Marshal(map[string]interface{}{
				"status":  "already_applied",
				"message": "proxy is already applied with same revision",
			})
		}

		// Need to update - unapply first
		log.Printf("[Hub] Updating proxy %s from revision %d to %d", req.ProxyID, existing.RevisionNum, req.RevisionNum)
		if _, err := unapplyProxy(pm, params); err != nil {
			log.Printf("[Hub] Warning: failed to unapply before update: %v", err)
		}
	}

	// Parse and apply the YAML config
	// For now, we'll create a basic proxy from the YAML
	// In a full implementation, this would parse the full YAML format
	applied := &AppliedProxy{
		ProxyID:     req.ProxyID,
		RevisionNum: req.RevisionNum,
		ConfigHash:  req.ConfigHash,
		AppliedAt:   time.Now(),
		Status:      "active",
	}

	// TODO: Parse YAML and create actual listeners/rules
	// For now, just track that we've applied this config
	log.Printf("[Hub] Proxy %s applied successfully (placeholder - full YAML parsing TODO)", req.ProxyID)

	appliedMu.Lock()
	appliedProxies[req.ProxyID] = applied
	appliedMu.Unlock()

	// Save applied proxies to file for persistence
	saveAppliedProxies()

	return json.Marshal(map[string]interface{}{
		"status":       "applied",
		"proxy_id":     req.ProxyID,
		"revision_num": req.RevisionNum,
	})
}

// unapplyProxy removes a proxy configuration
func unapplyProxy(pm *node.ProxyManager, params json.RawMessage) ([]byte, error) {
	var req struct {
		ProxyID string `json:"proxy_id"`
	}
	if err := json.Unmarshal(params, &req); err != nil {
		return nil, fmt.Errorf("invalid request: %w", err)
	}

	if req.ProxyID == "" {
		return nil, errors.New("proxy_id is required")
	}

	appliedMu.Lock()
	applied, exists := appliedProxies[req.ProxyID]
	if !exists {
		appliedMu.Unlock()
		return json.Marshal(map[string]interface{}{
			"status":  "not_found",
			"message": "proxy not applied",
		})
	}

	// Stop any created listeners
	for _, listenerID := range applied.ListenerIDs {
		if _, err := pm.DisableProxy(listenerID); err != nil {
			log.Printf("[Hub] Warning: failed to disable listener %s: %v", listenerID, err)
		}
	}

	delete(appliedProxies, req.ProxyID)
	appliedMu.Unlock()

	// Save updated state
	saveAppliedProxies()

	log.Printf("[Hub] Proxy %s unapplied", req.ProxyID)

	return json.Marshal(map[string]interface{}{
		"status":   "unapplied",
		"proxy_id": req.ProxyID,
	})
}

// getAppliedProxies returns list of applied proxy configs
func getAppliedProxies(pm *node.ProxyManager, params json.RawMessage) ([]byte, error) {
	appliedMu.RLock()
	defer appliedMu.RUnlock()

	var result []*AppliedProxy
	for _, ap := range appliedProxies {
		result = append(result, ap)
	}

	return json.Marshal(map[string]interface{}{
		"proxies": result,
		"count":   len(result),
	})
}

// handleProxyUpdate handles notifications about proxy config updates from Hub
func handleProxyUpdate(pm *node.ProxyManager, params json.RawMessage) ([]byte, error) {
	var req struct {
		ProxyID     string `json:"proxy_id"`
		RevisionNum int64  `json:"revision_num"`
		Action      string `json:"action"` // "updated" or "deleted"
	}
	if err := json.Unmarshal(params, &req); err != nil {
		return nil, fmt.Errorf("invalid request: %w", err)
	}

	appliedMu.RLock()
	applied, exists := appliedProxies[req.ProxyID]
	appliedMu.RUnlock()

	if !exists {
		// Not interested in this proxy
		return json.Marshal(map[string]string{"status": "ignored", "reason": "not_applied"})
	}

	if req.Action == "deleted" {
		// Proxy was deleted - unapply it
		log.Printf("[Hub] Proxy %s was deleted on Hub, unapplying", req.ProxyID)
		return unapplyProxy(pm, params)
	}

	// Proxy was updated - needs refresh
	if req.RevisionNum > applied.RevisionNum {
		log.Printf("[Hub] Proxy %s has new revision %d (current: %d), need to fetch and apply",
			req.ProxyID, req.RevisionNum, applied.RevisionNum)

		// Mark as needing update - the CLI will need to push the new config
		appliedMu.Lock()
		applied.Status = "pending_update"
		appliedMu.Unlock()

		return json.Marshal(map[string]interface{}{
			"status":      "pending_update",
			"proxy_id":    req.ProxyID,
			"current_rev": applied.RevisionNum,
			"latest_rev":  req.RevisionNum,
		})
	}

	return json.Marshal(map[string]string{"status": "up_to_date"})
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
func resolveApproval(pm *node.ProxyManager, params json.RawMessage) ([]byte, error) {
	var req struct {
		ReqID           string `json:"req_id"`
		Action          int32  `json:"action"`
		DurationSeconds int64  `json:"duration_seconds"`
		Reason          string `json:"reason"`
	}

	if err := json.Unmarshal(params, &req); err != nil {
		return nil, fmt.Errorf("failed to parse resolve approval request: %w", err)
	}

	if pm.Approval == nil {
		return nil, fmt.Errorf("approval manager not initialized")
	}

	allowed := req.Action == int32(common.ApprovalActionType_APPROVAL_ACTION_TYPE_ALLOW)
	durationSeconds := req.DurationSeconds
	if durationSeconds <= 0 {
		durationSeconds = config.DefaultApprovalDurationSeconds
	}

	log.Printf("[Hub] Resolving approval request %s (action=%d, duration=%ds)",
		req.ReqID, req.Action, durationSeconds)

	meta := pm.Approval.Resolve(req.ReqID, allowed, durationSeconds, req.Reason)
	if meta == nil {
		return nil, fmt.Errorf("no pending approval found for request %s", req.ReqID)
	}

	log.Printf("[Hub] Approval %s resolved: allowed=%v, duration=%ds, reason=%q, source=%s",
		req.ReqID, allowed, durationSeconds, req.Reason, meta.SourceIP)

	return json.Marshal(map[string]interface{}{
		"success":    true,
		"allowed":    allowed,
		"duration_s": durationSeconds,
	})
}
