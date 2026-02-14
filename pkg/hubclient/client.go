package hubclient

import (
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/sha256"
	"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/hex"
	"encoding/pem"
	"fmt"
	"log"
	"math/big"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/hub"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/ivere27/nitella/pkg/p2p"
	"github.com/mdp/qrterminal/v3"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// CommandIDCacheExpirySeconds is how long command IDs are cached for deduplication (5 minutes)
const CommandIDCacheExpirySeconds = 300

// MetricsProvider is the interface that nitellad should implement to provide metrics
type MetricsProvider interface {
	GetActiveConnections() int64
	GetTotalConnections() int64
	GetBytesIn() int64
	GetBytesOut() int64
}

// CommandHandler is the interface for handling incoming commands from Hub
type CommandHandler interface {
	HandleCommand(ctx context.Context, cmdType pb.CommandType, payload []byte) (status string, errMsg string, data []byte)
}

// Client connects nitellad to the Hub for registration, commands, and metrics
type Client struct {
	hubAddr   string
	authToken string
	userID    string

	inviteCode     string
	pairingCode    string // For Secure Pairing Mode
	qrRegistration bool   // For Air-Gapped QR Mode
	nodeID         string

	// Security: CA certificate for command signature verification
	caCertPEM      []byte
	caPubKey       ed25519.PublicKey
	verifyCommands bool   // When true, reject unsigned/invalid commands
	transportCAPEM []byte // Custom CA for TLS Transport (Hub Self-Signed)

	// Zero-Trust: Viewer public key for encrypting metrics/alerts (owner's key)
	// This is separate from CA key - Hub cannot decrypt data encrypted to viewer
	viewerPubKey ed25519.PublicKey

	alertCh chan *common.Alert
	stopCh  chan struct{}
	running bool

	privateKey ed25519.PrivateKey // For E2E decryption

	// Connection tracking
	conn   *grpc.ClientConn
	connMu sync.Mutex

	// Stats Control
	statsStreamingUntil time.Time
	statsStreamingMu    sync.RWMutex

	// P2P
	p2pManager *p2p.Manager
	useP2P     bool   // Global flag to enable/disable P2P signaling
	stunURL    string // STUN server URL for P2P

	// Replay Protection - entries expire after 5 minutes
	cmdIDCache     sync.Map
	cacheCleanupMu sync.Once

	// Pinning
	hubCertPin string // SHA-256 SPKI Fingerprint (Hex)

	storage *Storage

	// External providers
	metricsProvider MetricsProvider
	commandHandler  CommandHandler

	// Approval resolution callback (called when P2P decision received)
	onApprovalDecision func(reqID string, allowed bool, durationSeconds int64, reason string)
}

// NewClient creates a Hub client with TLS enabled (production-ready).
// All connections require TLS only.
func NewClient(hubAddr, authToken, userID, inviteCode, pairingCode string, qrMode bool, appDataDir string) *Client {
	store := NewStorage(appDataDir)
	return &Client{
		hubAddr:        hubAddr,
		authToken:      authToken,
		userID:         userID,
		inviteCode:     inviteCode,
		pairingCode:    pairingCode,
		qrRegistration: qrMode,
		storage:        store,
		verifyCommands: true, // SECURE: Verify signatures by default
		alertCh:        make(chan *common.Alert, 100),
		stopCh:         make(chan struct{}),
		useP2P:         false, // Default: Disable P2P (require explicit opt-in)
	}
}

// NewClientWithConn creates a Client with an existing gRPC connection.
// Used when the connection is established externally (e.g., after PAKE pairing).
// hubAddr is needed for reconnection if the connection drops.
func NewClientWithConn(conn *grpc.ClientConn, appDataDir string) *Client {
	store := NewStorage(appDataDir)

	// Extract hubAddr from connection target for reconnection
	hubAddr := ""
	if conn != nil {
		hubAddr = conn.Target()
	}

	c := &Client{
		hubAddr:        hubAddr,
		conn:           conn,
		storage:        store,
		verifyCommands: true,
		alertCh:        make(chan *common.Alert, 100),
		stopCh:         make(chan struct{}),
		useP2P:         false, // Default: Disable P2P (require explicit opt-in)
	}

	// Load identity if available
	if id, err := store.LoadIdentity(); err == nil {
		c.nodeID = id.NodeID
		c.privateKey = id.PrivateKey
	}

	return c
}

// SetTransportCA sets the CA certificate for TLS Transport verification
func (c *Client) SetTransportCA(certPEM []byte) {
	c.transportCAPEM = certPEM
	log.Printf("[HubClient] Custom Transport CA set (len=%d)", len(certPEM))
}

// SetHubAddr sets the Hub address for reconnection
func (c *Client) SetHubAddr(addr string) {
	c.hubAddr = addr
	log.Printf("[HubClient] Hub address set to: %s", addr)
}

// SetHubCertPin enforces strict certificate pinning for the Hub connection
func (c *Client) SetHubCertPin(pin string) {
	c.hubCertPin = strings.ReplaceAll(strings.ToLower(pin), ":", "")
	log.Printf("[HubClient] Enforcing Hub Certificate Pin: %s", c.hubCertPin)
}

// SetCACert sets the CA certificate for command signature verification
func (c *Client) SetCACert(certPEM []byte) error {
	block, _ := pem.Decode(certPEM)
	if block == nil {
		return fmt.Errorf("failed to decode CA certificate PEM")
	}
	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return fmt.Errorf("failed to parse CA certificate: %w", err)
	}
	pubKey, ok := cert.PublicKey.(ed25519.PublicKey)
	if !ok {
		return fmt.Errorf("CA certificate does not contain Ed25519 public key")
	}
	c.caCertPEM = certPEM
	c.caPubKey = pubKey
	log.Printf("[HubClient] CA certificate set for command verification. Key Len: %d", len(c.caPubKey))
	return nil
}

// SetViewerPublicKey sets the owner's public key for encrypting metrics/alerts
// This is the CLI/Mobile's key - Hub cannot decrypt data encrypted to this key
func (c *Client) SetViewerPublicKey(pubKey ed25519.PublicKey) {
	c.viewerPubKey = pubKey
	log.Printf("[HubClient] Viewer public key set for zero-trust encryption. Key Len: %d", len(c.viewerPubKey))
}

// GetViewerPublicKey returns the viewer public key if set
func (c *Client) GetViewerPublicKey() ed25519.PublicKey {
	return c.viewerPubKey
}

// SetMetricsProvider sets the metrics provider
func (c *Client) SetMetricsProvider(provider MetricsProvider) {
	c.metricsProvider = provider
}

// SetCommandHandler sets the command handler
func (c *Client) SetCommandHandler(handler CommandHandler) {
	c.commandHandler = handler
}

// SetUseP2P enables or disables P2P mode
func (c *Client) SetUseP2P(enabled bool) {
	c.useP2P = enabled
}

// SetSTUNServer sets the STUN server URL for P2P connections
func (c *Client) SetSTUNServer(url string) {
	c.stunURL = url
}

// SetApprovalDecisionHandler sets the callback for P2P approval decisions
func (c *Client) SetApprovalDecisionHandler(handler func(reqID string, allowed bool, durationSeconds int64, reason string)) {
	c.onApprovalDecision = handler
}

// Stop stops the client's retry loop
func (c *Client) Stop() {
	if c.running {
		close(c.stopCh)
		c.running = false

		c.connMu.Lock()
		if c.conn != nil {
			c.conn.Close()
			c.conn = nil
		}
		c.connMu.Unlock()

		log.Printf("HubClient stopped for %s", c.hubAddr)
	}
}

// SendAlert sends an alert to the Hub (or via P2P if connected)
func (c *Client) SendAlert(alert *common.Alert, info string) error {
	if alert == nil {
		return fmt.Errorf("alert is nil")
	}

	// Try P2P first if enabled and connected
	if c.useP2P && c.p2pManager != nil && c.p2pManager.HasConnectedSessions() {
		if c.trySendAlertViaP2P(alert, info) {
			log.Printf("[HubClient] Alert %s sent via P2P", alert.Id)
			return nil
		}
		// P2P failed, fall through to Hub
		log.Printf("[HubClient] P2P send failed, falling back to Hub for alert %s", alert.Id)
	}

	// Zero-Trust: Encrypt and sign alert info with viewer's public key (owner's key)
	// This ensures Hub cannot decrypt alert details - only the owner can
	// Signing allows CLI to verify which node sent the alert
	if alert.Encrypted == nil {
		if c.viewerPubKey == nil || c.privateKey == nil {
			return fmt.Errorf("viewer key and identity private key are required for encrypted alerts")
		}

		payloadData := []byte(info)
		enc, err := nitellacrypto.EncryptWithSignature(payloadData, c.viewerPubKey, c.privateKey, c.nodeID)
		if err != nil {
			return fmt.Errorf("failed to encrypt alert payload: %w", err)
		}
		alert.Encrypted = &common.EncryptedPayload{
			EphemeralPubkey:   enc.EphemeralPubKey,
			Nonce:             enc.Nonce,
			Ciphertext:        enc.Ciphertext,
			SenderFingerprint: enc.SenderFingerprint,
			Signature:         enc.Signature,
		}
	}

	select {
	case c.alertCh <- alert:
		return nil
	default:
		return fmt.Errorf("alert channel full")
	}
}

// trySendAlertViaP2P attempts to send an approval request via P2P
// Returns true if successfully sent to at least one peer
func (c *Client) trySendAlertViaP2P(alert *common.Alert, infoBytes string) bool {
	// Parse proto-encoded AlertDetails
	var details common.AlertDetails
	if err := proto.Unmarshal([]byte(infoBytes), &details); err != nil {
		log.Printf("[HubClient] Failed to parse alert info for P2P: %v", err)
		return false
	}

	// Build P2P ApprovalRequest
	req := &p2p.ApprovalRequest{
		RequestID:  alert.Id,
		NodeID:     alert.NodeId,
		Severity:   alert.Severity,
		SourceIP:   details.SourceIp,
		DestAddr:   details.Destination,
		ProxyID:    details.ProxyId,
		RuleID:     details.RuleId,
		GeoCountry: details.GeoCountry,
		GeoCity:    details.GeoCity,
		GeoISP:     details.GeoIsp,
	}

	// Send to all connected P2P sessions
	return c.p2pManager.SendApprovalRequest(req) > 0
}

// Start begins the Hub connection loop with automatic reconnection
func (c *Client) Start() {
	c.running = true
	// Simple retry loop with stop support
	for {
		select {
		case <-c.stopCh:
			log.Printf("HubClient: received stop signal")
			return
		default:
		}

		if err := c.connect(); err != nil {
			log.Printf("Hub connection error: %v. Retrying in 5s...", err)
			select {
			case <-c.stopCh:
				return
			case <-time.After(5 * time.Second):
			}
		} else {
			log.Printf("Hub disconnected. Retrying in 5s...")
			select {
			case <-c.stopCh:
				return
			case <-time.After(5 * time.Second):
			}
		}
	}
}

// EnsureIdentity loads or generates a persistent identity
func (c *Client) EnsureIdentity() error {
	id, err := c.storage.LoadIdentity()
	if err != nil || id.PrivateKey == nil {
		log.Println("No valid identity found, generating new one...")
		id, err = c.storage.GenerateNewIdentity()
		if err != nil {
			return err
		}
	}
	c.nodeID = id.NodeID
	c.privateKey = id.PrivateKey

	// Load Cert if exists
	if len(id.CertPEM) > 0 {
		log.Printf("Loaded existing certificate for NodeID: %s", c.nodeID)
	}

	// Load CA Cert if exists (for E2E encryption/verification)
	caPath := filepath.Join(c.storage.BaseDir, "ca.crt")
	if caPEM, err := os.ReadFile(caPath); err == nil && len(caPEM) > 0 {
		if err := c.SetCACert(caPEM); err != nil {
			log.Printf("Failed to set CA cert from storage: %v", err)
		}
	}

	return nil
}

func (c *Client) connect() error {
	// Ensure we have an identity before connecting
	if err := c.EnsureIdentity(); err != nil {
		return fmt.Errorf("failed to ensure identity: %v", err)
	}

	var conn *grpc.ClientConn
	var err error

	// Check if we already have a valid connection
	c.connMu.Lock()
	existingConn := c.conn
	c.connMu.Unlock()

	if existingConn != nil {
		// Test if the existing connection is still usable
		state := existingConn.GetState()
		if state == 0 || state == 1 || state == 2 { // Idle, Connecting, Ready
			conn = existingConn
			log.Printf("[HubClient] Reusing existing connection (state: %v)", state)
		} else {
			// Connection is broken, close it and create a new one
			existingConn.Close()
			c.connMu.Lock()
			c.conn = nil
			c.connMu.Unlock()
		}
	}

	// SECURE: Always use TLS with certificate verification
	tlsConfig := &tls.Config{
		MinVersion: tls.VersionTLS13, // TLS 1.3 required
	}

	// Load Custom Transport CA if provided
	if len(c.transportCAPEM) > 0 {
		rootCAs := x509.NewCertPool()
		if ok := rootCAs.AppendCertsFromPEM(c.transportCAPEM); ok {
			tlsConfig.RootCAs = rootCAs
			log.Println("[HubClient] Using Custom Transport CA for TLS")
		} else {
			log.Println("[WARN] Failed to parse Custom Transport CA PEM")
		}
	}

	// Load Client Certificate for mTLS
	id, err := c.storage.LoadIdentity()
	if err == nil && len(id.CertPEM) > 0 && id.PrivateKey != nil {
		var certDER [][]byte
		rest := id.CertPEM
		for {
			var block *pem.Block
			block, rest = pem.Decode(rest)
			if block == nil {
				break
			}
			if block.Type == "CERTIFICATE" {
				certDER = append(certDER, block.Bytes)
			}
		}

		if len(certDER) > 0 {
			tlsConfig.Certificates = []tls.Certificate{{
				Certificate: certDER,
				PrivateKey:  id.PrivateKey,
			}}
			log.Printf("[Client] mTLS Certificate loaded for %s", id.NodeID)
		}
	}

	// EPHEMERAL CERT: If no cert loaded, generate one to pass TLS Handshake
	if len(tlsConfig.Certificates) == 0 {
		log.Println("[Client] Generating ephemeral mTLS certificate for registration...")
		priv, _ := nitellacrypto.GenerateKey()
		// Self-sign a temp cert
		tmpl := x509.Certificate{
			SerialNumber: big.NewInt(1),
			Subject:      pkix.Name{CommonName: "ephemeral"},
			NotBefore:    time.Now(),
			NotAfter:     time.Now().Add(1 * time.Hour),
		}
		der, _ := x509.CreateCertificate(rand.Reader, &tmpl, &tmpl, priv.Public(), priv)
		tlsConfig.Certificates = []tls.Certificate{{
			Certificate: [][]byte{der},
			PrivateKey:  priv,
		}}
	}

	// Implement PINNING if configured
	if c.hubCertPin != "" {
		tlsConfig.VerifyConnection = func(cs tls.ConnectionState) error {
			if len(cs.PeerCertificates) == 0 {
				return fmt.Errorf("no peer certificates presented")
			}
			leaf := cs.PeerCertificates[0]

			// Calculate SPKI Fingerprint
			hash := sha256.Sum256(leaf.RawSubjectPublicKeyInfo)
			fingerprint := hex.EncodeToString(hash[:])

			if fingerprint != c.hubCertPin {
				return fmt.Errorf("certificate pinning mismatch! Expected: %s, Got: %s", c.hubCertPin, fingerprint)
			}
			log.Println("Hub Certificate Pin Verified")
			return nil
		}
	}

	// Only create new connection if we don't have a reused one
	if conn == nil {
		if c.hubAddr == "" {
			return fmt.Errorf("failed to exit idle mode: failed to start resolver: passthrough: received empty target in Build()")
		}
		conn, err = grpc.Dial(c.hubAddr, grpc.WithTransportCredentials(credentials.NewTLS(tlsConfig)))
		if err != nil {
			return err
		}

		c.connMu.Lock()
		c.conn = conn
		c.connMu.Unlock()
	}

	// Close connection on exit
	defer func() {
		c.connMu.Lock()
		if c.conn != nil {
			c.conn.Close()
			c.conn = nil
		}
		c.connMu.Unlock()
	}()

	client := pb.NewNodeServiceClient(conn)

	// Check for Certificate in Storage
	existingID, _ := c.storage.LoadIdentity()
	hasCert := len(existingID.CertPEM) > 0

	// Registration Logic: If no cert, we must register first
	if !hasCert {
		log.Printf("No certificate found for NodeID %s. Starting registration...", c.nodeID)
		if err := c.doRegistration(client); err != nil {
			return err
		}
		// Re-connect with new cert
		return c.connect()
	}

	log.Printf("Using existing NodeID: %s", c.nodeID)

	// Start background loops
	ctx := context.Background()
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	go c.pushMetricsLoop(ctx, client)
	go c.pushAlertsLoop(ctx, client)

	// Receive Commands
	log.Printf("Starting ReceiveCommands stream for node %s...", c.nodeID)
	stream, err := client.ReceiveCommands(ctx, &pb.ReceiveCommandsRequest{NodeId: c.nodeID})
	if err != nil {
		return fmt.Errorf("ReceiveCommands failed: %v", err)
	}
	log.Printf("ReceiveCommands stream started successfully")

	// P2P Signaling Start (if enabled)
	if c.useP2P {
		go c.startSignalingLoop(ctx, client)
	} else {
		log.Println("[P2P] WebRTC disabled, skipping signaling loop")
	}

	// Command Loop
	for {
		cmd, err := stream.Recv()
		if err != nil {
			return fmt.Errorf("stream closed: %v", err)
		}

		log.Printf("Received Command: (encrypted)")
		go c.handleCommand(ctx, client, cmd)
	}
}

func (c *Client) doRegistration(client pb.NodeServiceClient) error {
	// Generate CSR
	log.Println("Generating CSR for registration...")
	template := x509.CertificateRequest{
		Subject: pkix.Name{
			CommonName: c.nodeID,
		},
		DNSNames: []string{c.nodeID},
	}
	csrDER, err := x509.CreateCertificateRequest(rand.Reader, &template, c.privateKey)
	if err != nil {
		return fmt.Errorf("failed to create CSR: %v", err)
	}
	csrPEM := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE REQUEST", Bytes: csrDER})

	// QR (Air-Gapped) Registration
	if c.qrRegistration {
		return c.doQRRegistration(client, csrPEM)
	}

	// Standard / Pairing Mode Registration
	log.Printf("Registering with Hub (Invite: %s, Pairing: %s)", c.inviteCode, c.pairingCode)
	regReq := &pb.NodeRegisterRequest{
		CsrPem:      string(csrPEM),
		InviteCode:  c.inviteCode,
		PairingCode: c.pairingCode,
	}

	resp, err := client.Register(context.Background(), regReq)
	if err != nil {
		return fmt.Errorf("registration failed: %v", err)
	}

	log.Printf("\n"+
		"REGISTRATION PENDING\n"+
		"CODE: %s\n"+
		"Open your mobile app to approve.", resp.RegistrationCode)

	// Watch for Approval (Streaming)
	log.Println("Waiting for approval (streaming)...")
	watchStream, err := client.WatchRegistration(context.Background(), &pb.WatchRegistrationRequest{
		RegistrationCode: resp.RegistrationCode,
		WatchSecret:      resp.WatchSecret, // Only we know this secret
	})
	if err != nil {
		return fmt.Errorf("failed to start watching registration: %v", err)
	}

	watchResp, err := watchStream.Recv()
	if err != nil {
		return fmt.Errorf("stream error while waiting for approval: %v", err)
	}

	if watchResp.Status == pb.RegistrationStatus_REGISTRATION_STATUS_APPROVED {
		log.Println("Registration APPROVED!")
		if err := c.storage.SaveCertificate([]byte(watchResp.CertPem)); err != nil {
			return fmt.Errorf("failed to save certificate: %v", err)
		}
		if watchResp.CaPem != "" {
			c.SetCACert([]byte(watchResp.CaPem))
			c.storage.SaveCACertificate([]byte(watchResp.CaPem))
		}
		return nil
	} else if watchResp.Status == pb.RegistrationStatus_REGISTRATION_STATUS_REJECTED {
		return fmt.Errorf("registration rejected")
	}

	return fmt.Errorf("streaming ended with status: %s", watchResp.Status)
}

func (c *Client) doQRRegistration(client pb.NodeServiceClient, csrPEM []byte) error {
	log.Println("\n" +
		"AIR-GAPPED REGISTRATION (QR MODE)\n" +
		"1. Open Nitella App > Add Node > Scan QR\n" +
		"2. Verify Emoji Fingerprint matches\n" +
		"3. Approve on App")

	// Generate QR Code to stdout
	log.Println("Scan CSR QR Code below:")
	config := qrterminal.Config{
		Level:      qrterminal.L,
		Writer:     os.Stdout,
		HalfBlocks: true,
		QuietZone:  1,
	}
	qrterminal.GenerateWithConfig(string(csrPEM), config)

	fmt.Println("\n" + string(csrPEM)) // Fallback text

	// Generate & Print Fingerprint (Emojis)
	spkiHash, _ := nitellacrypto.GetSPKIFingerprint(c.privateKey.Public().(ed25519.PublicKey))
	emojis := nitellacrypto.HashToEmojis(spkiHash)
	log.Printf("\n\nFINGERPRINT:  %s  %s  %s  %s\n\n", emojis[0], emojis[1], emojis[2], emojis[3])

	log.Println("Waiting for certificate (polling)...")

	// Polling Loop
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-c.stopCh:
			return fmt.Errorf("stopped")
		case <-ticker.C:
			resp, err := client.CheckCertificate(context.Background(), &pb.CheckCertificateRequest{
				Fingerprint: c.nodeID,
			})
			if err == nil && resp.Found {
				log.Println("Certificate received!")
				if err := c.storage.SaveCertificate([]byte(resp.CertPem)); err != nil {
					return fmt.Errorf("failed to save certificate: %v", err)
				}
				if resp.CaPem != "" {
					c.SetCACert([]byte(resp.CaPem))
					c.storage.SaveCACertificate([]byte(resp.CaPem))
				}
				c.qrRegistration = false
				return nil
			}
		}
	}
}

func (c *Client) pushMetricsLoop(ctx context.Context, client pb.NodeServiceClient) {
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()

	stream, err := client.PushMetrics(ctx)
	if err != nil {
		log.Printf("Failed to start metrics push stream: %v", err)
		return
	}

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			// Optimization: Push metrics only if streaming is active
			c.statsStreamingMu.RLock()
			isActive := time.Now().Before(c.statsStreamingUntil)
			c.statsStreamingMu.RUnlock()

			if !isActive {
				continue
			}

			encMetrics := c.gatherEncryptedMetrics()
			if encMetrics == nil || encMetrics.Encrypted == nil {
				continue
			}
			encMetrics.NodeId = c.nodeID

			if err := stream.Send(encMetrics); err != nil {
				log.Printf("Failed to push metrics: %v", err)
				return
			}
		}
	}
}

func (c *Client) gatherEncryptedMetrics() *pb.EncryptedMetrics {
	var active, total, bytesIn, bytesOut int64

	if c.metricsProvider != nil {
		active = c.metricsProvider.GetActiveConnections()
		total = c.metricsProvider.GetTotalConnections()
		bytesIn = c.metricsProvider.GetBytesIn()
		bytesOut = c.metricsProvider.GetBytesOut()
	}

	plainMetrics := &pb.Metrics{
		NodeId:            c.nodeID,
		Timestamp:         timestamppb.New(time.Now()),
		ConnectionsActive: active,
		ConnectionsTotal:  total,
		BytesIn:           bytesIn,
		BytesOut:          bytesOut,
	}

	if c.viewerPubKey == nil || c.privateKey == nil {
		return nil
	}

	// Zero-Trust: Encrypt and sign with viewer's public key (owner's key)
	// This ensures Hub cannot decrypt metrics - only the owner can
	// Signing allows CLI to verify which node sent the metrics
	data, err := proto.Marshal(plainMetrics)
	if err != nil {
		log.Printf("[HubClient] Failed to marshal metrics payload: %v", err)
		return nil
	}
	enc, err := nitellacrypto.EncryptWithSignature(data, c.viewerPubKey, c.privateKey, c.nodeID)
	if err != nil {
		log.Printf("[HubClient] Failed to encrypt metrics payload: %v", err)
		return nil
	}

	return &pb.EncryptedMetrics{
		Encrypted: &common.EncryptedPayload{
			EphemeralPubkey:   enc.EphemeralPubKey,
			Nonce:             enc.Nonce,
			Ciphertext:        enc.Ciphertext,
			SenderFingerprint: enc.SenderFingerprint,
			Signature:         enc.Signature,
		},
	}
}

func (c *Client) pushAlertsLoop(ctx context.Context, client pb.NodeServiceClient) {
	for {
		select {
		case <-ctx.Done():
			return
		case alert := <-c.alertCh:
			if alert.NodeId == "" {
				alert.NodeId = c.nodeID
			}
			_, err := client.PushAlert(ctx, alert)
			if err != nil {
				log.Printf("Failed to push alert: %v", err)
			} else {
				log.Printf("[HubClient] PushAlert success for alert %s (Node: %s)", alert.Id, alert.NodeId)
			}
		}
	}
}

func (c *Client) handleCommand(ctx context.Context, client pb.NodeServiceClient, cmd *pb.Command) {
	// All commands are now E2E encrypted
	encrypted := cmd.Encrypted
	if encrypted == nil {
		log.Println("[ERROR] Received command without encryption - rejected")
		return
	}

	// Verify sender fingerprint
	if encrypted.SenderFingerprint == "" {
		log.Println("[SECURITY] Encrypted command missing sender fingerprint")
		return
	}

	// E2E Decryption
	if c.privateKey == nil {
		log.Println("[ERROR] Received encrypted command but Private Key is not loaded!")
		return
	}

	payload := &nitellacrypto.EncryptedPayload{
		EphemeralPubKey:   encrypted.EphemeralPubkey,
		Nonce:             encrypted.Nonce,
		Ciphertext:        encrypted.Ciphertext,
		SenderFingerprint: encrypted.SenderFingerprint,
		Signature:         encrypted.Signature,
	}

	// VERIFY SIGNATURE
	if c.verifyCommands {
		if c.caPubKey == nil {
			log.Println("[SECURITY CRITICAL] Cannot verify command signature: CA key missing")
			return
		}

		if err := nitellacrypto.VerifySignature(payload, c.caPubKey); err != nil {
			log.Printf("[SECURITY CRITICAL] Command Signature Verification Failed: %v", err)
			return
		}
		log.Println("[SECURITY] Command signature verified by CA")
	}

	decryptedBytes, err := nitellacrypto.Decrypt(payload, c.privateKey)
	if err != nil {
		log.Printf("[ERROR] Failed to decrypt E2E command: %v", err)
		return
	}

	log.Println("[SECURITY] Successfully decrypted E2E command")

	// Unmarshal SecureCommandPayload (replay protection)
	var securePayload common.SecureCommandPayload
	if err := proto.Unmarshal(decryptedBytes, &securePayload); err != nil {
		log.Printf("[ERROR] Failed to unmarshal SecureCommandPayload: %v", err)
		return
	}

	// Check Timestamp (allow 60s skew)
	now := time.Now().Unix()
	if securePayload.Timestamp < now-60 || securePayload.Timestamp > now+60 {
		log.Printf("[SECURITY] Replay detected! Timestamp out of range: %d (now: %d)", securePayload.Timestamp, now)
		return
	}

	// Start cache cleanup goroutine (once)
	c.cacheCleanupMu.Do(func() {
		go c.replayCacheCleanupLoop()
	})

	// Check Request ID (Replay Protection)
	if _, loaded := c.cmdIDCache.LoadOrStore(securePayload.RequestId, now); loaded {
		log.Printf("[SECURITY] Replay detected! Request ID %s already processed", securePayload.RequestId)
		return
	}

	// Unmarshal Inner EncryptedCommandPayload
	var innerPayload pb.EncryptedCommandPayload
	if err := proto.Unmarshal(securePayload.Data, &innerPayload); err != nil {
		log.Printf("[ERROR] Failed to unmarshal EncryptedCommandPayload: %v", err)
		return
	}

	// Cannot execute commands if we cannot send encrypted responses.
	if c.viewerPubKey == nil {
		log.Println("[SECURITY CRITICAL] Cannot execute command: viewer public key not set (encrypted response impossible)")
		return
	}

	// Process command via external handler
	if c.commandHandler != nil {
		status, errMsg, data := c.commandHandler.HandleCommand(ctx, innerPayload.Type, innerPayload.Payload)
		client.RespondToCommand(ctx, c.encryptCommandResult(cmd.Id, status, errMsg, data))
	} else {
		log.Printf("[WARN] No command handler set, ignoring command type: %v", innerPayload.Type)
		client.RespondToCommand(ctx, c.encryptCommandResult(cmd.Id, "ERROR", "No handler", nil))
	}
}

// replayCacheCleanupLoop periodically removes old entries from the replay cache
func (c *Client) replayCacheCleanupLoop() {
	ticker := time.NewTicker(time.Minute)
	defer ticker.Stop()

	for {
		select {
		case <-c.stopCh:
			return
		case <-ticker.C:
			now := time.Now().Unix()
			// Remove entries older than 5 minutes
			c.cmdIDCache.Range(func(key, value interface{}) bool {
				if ts, ok := value.(int64); ok {
					if now-ts > CommandIDCacheExpirySeconds {
						c.cmdIDCache.Delete(key)
					}
				}
				return true
			})
		}
	}
}

func (c *Client) startSignalingLoop(ctx context.Context, client pb.NodeServiceClient) {
	for {
		if ctx.Err() != nil {
			return
		}

		stream, err := client.StreamSignaling(ctx)
		if err != nil {
			log.Printf("[Signaling] Failed to start stream: %v", err)
			select {
			case <-ctx.Done():
				return
			case <-time.After(5 * time.Second):
				continue
			}
		}

		log.Printf("[Signaling] Connected to Hub")

		// Initialize P2P Manager
		outCh := make(chan *pb.SignalMessage, 10)
		c.p2pManager = p2p.NewManager(outCh)
		if c.stunURL != "" {
			c.p2pManager.SetSTUNServer(c.stunURL)
		}

		// Set node identity for P2P authentication and encryption
		if c.privateKey != nil && c.nodeID != "" {
			id, _ := c.storage.LoadIdentity()
			var certPEM []byte
			if id != nil {
				certPEM = id.CertPEM
			}
			c.p2pManager.SetNodeIdentity(c.nodeID, c.privateKey, certPEM)
		}

		// Hook up CommandHandler for P2P command processing
		if c.commandHandler != nil {
			c.p2pManager.CommandHandler = func(ctx context.Context, cmdType int32, payload []byte) (string, string, []byte) {
				return c.commandHandler.HandleCommand(ctx, pb.CommandType(cmdType), payload)
			}
		}

		// Hook up Metrics Callback
		c.p2pManager.GetMetrics = func() *pb.EncryptedMetrics {
			return c.gatherEncryptedMetrics()
		}

		// Hook up P2P Approval Decision Handler
		c.p2pManager.OnApprovalDecision = func(sessionID string, decision *p2p.ApprovalDecision) {
			log.Printf("[P2P] Received approval decision for %s: action=%d, duration=%d",
				decision.RequestID, decision.Action, decision.DurationSeconds)
			if c.onApprovalDecision != nil {
				allowed := decision.Action == 1 // 1=allow, 2=block
				c.onApprovalDecision(decision.RequestID, allowed, decision.DurationSeconds, decision.Reason)
			}
		}

		// Send Loop
		errCh := make(chan error, 1)
		go func() {
			for {
				select {
				case <-ctx.Done():
					return
				case msg := <-outCh:
					if err := stream.Send(msg); err != nil {
						log.Printf("[Signaling] Failed to send: %v", err)
						errCh <- err
						return
					}
				}
			}
		}()

		// Recv Loop
		broken := false
		for {
			select {
			case <-errCh:
				broken = true
			default:
			}
			if broken {
				break
			}

			msg, err := stream.Recv()
			if err != nil {
				log.Printf("[Signaling] Stream broken: %v", err)
				break
			}

			c.p2pManager.HandleSignal(msg)
		}

		select {
		case <-ctx.Done():
			return
		case <-time.After(5 * time.Second):
		}
	}
}

// GetIdentity returns the current identity
func (c *Client) GetIdentity() (*Identity, error) {
	return c.storage.LoadIdentity()
}

// RegenerateIdentity creates a new identity
func (c *Client) RegenerateIdentity() (*Identity, error) {
	id, err := c.storage.GenerateNewIdentity()
	if err != nil {
		return nil, err
	}

	c.nodeID = id.NodeID
	c.privateKey = id.PrivateKey

	return id, nil
}

// SetCertificate updates the stored certificate
func (c *Client) SetCertificate(certPEM []byte) error {
	id, err := c.storage.LoadIdentity()
	if err != nil {
		return err
	}
	id.CertPEM = certPEM
	if err := c.storage.SaveIdentity(id); err != nil {
		return err
	}
	log.Printf("Certificate updated for NodeID: %s", c.nodeID)
	return nil
}

// GetCSR generates and returns a CSR
func (c *Client) GetCSR() ([]byte, error) {
	if c.privateKey == nil {
		return nil, fmt.Errorf("private key not loaded")
	}

	template := x509.CertificateRequest{
		Subject: pkix.Name{
			CommonName: c.nodeID,
		},
		SignatureAlgorithm: x509.PureEd25519,
	}

	csrBytes, err := x509.CreateCertificateRequest(rand.Reader, &template, c.privateKey)
	if err != nil {
		return nil, err
	}

	return pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE REQUEST", Bytes: csrBytes}), nil
}

// GetNodeID returns the current node ID
func (c *Client) GetNodeID() string {
	return c.nodeID
}

// IsConnected returns true if connected to Hub
func (c *Client) IsConnected() bool {
	c.connMu.Lock()
	defer c.connMu.Unlock()
	return c.conn != nil
}

// EnableStatsStreaming enables stats streaming for the given duration
func (c *Client) EnableStatsStreaming(duration time.Duration) {
	c.statsStreamingMu.Lock()
	c.statsStreamingUntil = time.Now().Add(duration)
	c.statsStreamingMu.Unlock()
}

// encryptCommandResult encrypts the command result for response
func (c *Client) encryptCommandResult(cmdID, status, errMsg string, payload []byte) *pb.CommandResponse {
	result := &pb.CommandResult{
		Status:          status,
		ErrorMessage:    errMsg,
		ResponsePayload: payload,
	}

	resultBytes, err := proto.Marshal(result)
	if err != nil {
		log.Printf("Failed to marshal CommandResult: %v", err)
		return &pb.CommandResponse{
			CommandId: cmdID,
		}
	}

	// Zero-Trust: Encrypt and sign with viewer's public key (owner's key)
	// This ensures Hub cannot decrypt command responses - only the owner can
	if c.viewerPubKey != nil && c.privateKey != nil {
		if enc, err := nitellacrypto.EncryptWithSignature(resultBytes, c.viewerPubKey, c.privateKey, c.nodeID); err == nil {
			encryptedData := &common.EncryptedPayload{
				EphemeralPubkey:   enc.EphemeralPubKey,
				Nonce:             enc.Nonce,
				Ciphertext:        enc.Ciphertext,
				SenderFingerprint: enc.SenderFingerprint,
				Signature:         enc.Signature,
			}
			return &pb.CommandResponse{
				CommandId:     cmdID,
				EncryptedData: encryptedData,
			}
		} else {
			log.Printf("[HubClient] Failed to encrypt CommandResult: %v", err)
		}
	} else {
		log.Printf("[HubClient] WARNING: Viewer public key not set, sending empty CommandResponse")
	}

	return &pb.CommandResponse{
		CommandId: cmdID,
	}
}
