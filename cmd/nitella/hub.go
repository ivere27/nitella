package main

import (
	"bufio"
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"io"
	"math/big"
	"os"
	"os/signal"
	"path/filepath"
	"regexp"
	"strings"
	"sync"
	"syscall"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/hub"
	"github.com/ivere27/nitella/pkg/cli"
	"github.com/ivere27/nitella/pkg/config"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/ivere27/nitella/pkg/hub/routing"
	"github.com/ivere27/nitella/pkg/hubclient"
	"github.com/ivere27/nitella/pkg/identity"
	"github.com/ivere27/nitella/pkg/p2p"
	"github.com/ivere27/nitella/pkg/pairing"
	"github.com/ivere27/nitella/pkg/shell"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// PendingAlertExpiry is how long to keep pending alerts before cleanup.
// Must match Hub's PendingAlertExpiry so CLI doesn't expire alerts before Hub does.
const PendingAlertExpiry = 5 * time.Minute

var (
	// Hub mode configuration
	hubAddress    string
	hubToken      string
	hubConfigPath string
	stunServer    string

	// Hub connection
	hubConn      *grpc.ClientConn
	mobileClient pb.MobileServiceClient
	nodeClient   pb.NodeServiceClient
	adminClient  pb.AdminServiceClient

	// Background alert streaming
	alertStreamCancel  context.CancelFunc
	alertStreamRunning bool
	pendingAlerts      = make(map[string]*common.Alert) // ID -> Alert
	pendingAlertsMu    sync.RWMutex

	// Pending alerts cleanup
	pendingAlertsCleanupOnce   sync.Once
	pendingAlertsCleanupCancel context.CancelFunc

	// P2P transport for direct connection to nodes
	p2pTransport       *p2p.Transport
	p2pTransportMu     sync.RWMutex
	p2pTransportCancel context.CancelFunc
)

// HubConfig stores Hub CLI configuration
type HubConfig struct {
	HubAddress string `json:"hub_address"`
	Token      string `json:"token"`
	DataDir    string `json:"data_dir"`
	HubCAPEM   string `json:"hub_ca_pem,omitempty"` // Stored Hub CA for TOFU
	STUNServer string `json:"stun_server,omitempty"` // STUN server URL for P2P
}

// startBackgroundAlertStream starts a background goroutine that streams alerts from Hub
func startBackgroundAlertStream() {
	if alertStreamRunning {
		return
	}

	cfg := loadHubConfig()
	if err := connectToHub(cfg); err != nil {
		// Silently fail - user can run 'alerts' manually
		return
	}

	ctx, cancel := context.WithCancel(context.Background())
	alertStreamCancel = cancel
	alertStreamRunning = true

	// Start cleanup goroutine for stale alerts
	startPendingAlertsCleanup()

	go func() {
		defer func() {
			alertStreamRunning = false
			alertStreamCancel = nil
		}()

		stream, err := mobileClient.StreamAlerts(ctx, &pb.StreamAlertsRequest{})
		if err != nil {
			return
		}

		for {
			alert, err := stream.Recv()
			if err != nil {
				if ctx.Err() != nil {
					return // Context cancelled, clean exit
				}
				// Try to reconnect after a delay
				time.Sleep(5 * time.Second)
				stream, err = mobileClient.StreamAlerts(ctx, &pb.StreamAlertsRequest{})
				if err != nil {
					return
				}
				continue
			}

			// Store pending alert for later approval
			pendingAlertsMu.Lock()
			pendingAlerts[alert.Id] = alert
			pendingAlertsMu.Unlock()

			// Display alert notification
			displayAlertNotification(alert)
		}
	}()
}

// stopBackgroundAlertStream stops the background alert streaming
func stopBackgroundAlertStream() {
	if alertStreamCancel != nil {
		alertStreamCancel()
	}
}

// stopP2PTransport stops the P2P transport and closes all connections
func stopP2PTransport() {
	p2pTransportMu.Lock()
	defer p2pTransportMu.Unlock()

	if p2pTransportCancel != nil {
		p2pTransportCancel()
		p2pTransportCancel = nil
	}
	if p2pTransport != nil {
		p2pTransport.Close()
		p2pTransport = nil
	}
}

// CleanupHubResources cleans up all Hub mode resources before exit
func CleanupHubResources() {
	stopBackgroundAlertStream()
	stopP2PTransport()

	// Stop pending alerts cleanup
	if pendingAlertsCleanupCancel != nil {
		pendingAlertsCleanupCancel()
	}

	// Close Hub connection
	if hubConn != nil {
		hubConn.Close()
	}
}

// ansiEscapeRegex matches ANSI escape sequences
var ansiEscapeRegex = regexp.MustCompile(`\x1b\[[0-9;]*[a-zA-Z]|\x1b\][^\x07]*\x07|\x1b[PX^_][^\x1b]*\x1b\\`)

// sanitizeForTerminal removes ANSI escape sequences and control characters from untrusted input.
// This prevents "termojacking" attacks where malicious data could manipulate the terminal display.
// Preserves printable ASCII, UTF-8 characters, newlines, and tabs.
func sanitizeForTerminal(s string) string {
	// Remove ANSI escape sequences
	s = ansiEscapeRegex.ReplaceAllString(s, "")

	// Remove other control characters (keep newline, tab, and printable chars)
	var result strings.Builder
	result.Grow(len(s))
	for _, r := range s {
		if r == '\n' || r == '\t' || r >= 32 {
			result.WriteRune(r)
		}
	}
	return result.String()
}

// AlertInfo contains unified alert display information.
type AlertInfo struct {
	ID         string
	NodeID     string
	Severity   string
	Timestamp  time.Time
	Source     string // "HUB" or "P2P"
	SourceIP   string
	DestAddr   string
	ProxyID    string
	GeoCountry string
	GeoCity    string
	GeoISP     string
}

// displayAlert shows an alert notification with unified formatting.
func displayAlert(info AlertInfo) {
	ts := info.Timestamp.Format("15:04:05")
	color := "\033[1;33m" // yellow for HUB
	if info.Source == "P2P" {
		color = "\033[1;35m" // magenta for P2P
	}

	var sb strings.Builder
	sb.WriteString(fmt.Sprintf("%s[%s] %s ALERT: %s\033[0m\n", color, ts, info.Source, sanitizeForTerminal(info.Severity)))
	sb.WriteString(fmt.Sprintf("  ID:     %s\n", sanitizeForTerminal(info.ID)))
	sb.WriteString(fmt.Sprintf("  Node:   %s\n", sanitizeForTerminal(info.NodeID)))
	sb.WriteString(fmt.Sprintf("  Type:   \033[1;36mCONNECTION APPROVAL REQUEST (%s)\033[0m\n", info.Source))

	if info.SourceIP != "" {
		sb.WriteString(fmt.Sprintf("  Source: %s\n", sanitizeForTerminal(info.SourceIP)))
	}
	if info.DestAddr != "" {
		sb.WriteString(fmt.Sprintf("  Dest:   %s\n", sanitizeForTerminal(info.DestAddr)))
	}
	if info.ProxyID != "" {
		sb.WriteString(fmt.Sprintf("  Proxy:  %s\n", sanitizeForTerminal(info.ProxyID)))
	}
	if info.GeoCountry != "" {
		geo := "  Geo:    " + sanitizeForTerminal(info.GeoCountry)
		if info.GeoCity != "" {
			geo += ", " + sanitizeForTerminal(info.GeoCity)
		}
		sb.WriteString(geo + "\n")
	}
	if info.GeoISP != "" {
		sb.WriteString(fmt.Sprintf("  ISP:    %s\n", sanitizeForTerminal(info.GeoISP)))
	}

	safeID := sanitizeForTerminal(info.ID)
	sb.WriteString(fmt.Sprintf("  \033[1;32m→ approve %s [duration]\033[0m  or  \033[1;31m→ deny %s\033[0m", safeID, safeID))

	shell.NotifyActive(sb.String())
}

// displayAlertNotification shows an alert in the terminal
func displayAlertNotification(alert *common.Alert) {
	info := AlertInfo{
		ID:        alert.Id,
		NodeID:    alert.NodeId,
		Severity:  alert.Severity,
		Timestamp: time.Unix(alert.TimestampUnix, 0),
		Source:    "HUB",
	}

	// Try to decrypt the encrypted payload if present
	if alert.Encrypted != nil && cliIdentity != nil && cliIdentity.RootKey != nil {
		envelope := &nitellacrypto.EncryptedPayload{
			EphemeralPubKey: alert.Encrypted.EphemeralPubkey,
			Nonce:           alert.Encrypted.Nonce,
			Ciphertext:      alert.Encrypted.Ciphertext,
		}
		if decrypted, err := nitellacrypto.Decrypt(envelope, cliIdentity.RootKey); err == nil {
			var details map[string]interface{}
			if json.Unmarshal(decrypted, &details) == nil {
				if v, ok := details["source_ip"].(string); ok {
					info.SourceIP = v
				}
				if v, ok := details["destination"].(string); ok {
					info.DestAddr = v
				}
				if v, ok := details["proxy_id"].(string); ok {
					info.ProxyID = v
				}
				if v, ok := details["geo_country"].(string); ok {
					info.GeoCountry = v
				}
				if v, ok := details["geo_city"].(string); ok {
					info.GeoCity = v
				}
				if v, ok := details["geo_isp"].(string); ok {
					info.GeoISP = v
				}
			}
		}
	}

	// Fallback to unencrypted metadata
	if alert.Metadata != nil {
		if info.SourceIP == "" {
			if v, ok := alert.Metadata["source_ip"]; ok {
				info.SourceIP = v
			}
		}
		if info.DestAddr == "" {
			if v, ok := alert.Metadata["destination"]; ok {
				info.DestAddr = v
			}
		}
		if info.GeoCountry == "" {
			if v, ok := alert.Metadata["geo_country"]; ok {
				info.GeoCountry = v
			}
		}
	}

	displayAlert(info)
}

// getPendingAlert retrieves a pending alert by ID
func getPendingAlert(id string) *common.Alert {
	pendingAlertsMu.RLock()
	defer pendingAlertsMu.RUnlock()
	return pendingAlerts[id]
}

// removePendingAlert removes a pending alert after it's been handled
func removePendingAlert(id string) {
	pendingAlertsMu.Lock()
	defer pendingAlertsMu.Unlock()
	delete(pendingAlerts, id)
}

// listPendingAlerts returns all pending alerts
func listPendingAlerts() []*common.Alert {
	pendingAlertsMu.RLock()
	defer pendingAlertsMu.RUnlock()
	alerts := make([]*common.Alert, 0, len(pendingAlerts))
	for _, a := range pendingAlerts {
		alerts = append(alerts, a)
	}
	return alerts
}

// startPendingAlertsCleanup starts a background goroutine to clean up stale alerts
// Alerts older than PendingAlertExpiry are removed (matches Hub's expiry time)
func startPendingAlertsCleanup() {
	pendingAlertsCleanupOnce.Do(func() {
		ctx, cancel := context.WithCancel(context.Background())
		pendingAlertsCleanupCancel = cancel

		go func() {
			ticker := time.NewTicker(30 * time.Second)
			defer ticker.Stop()

			for {
				select {
				case <-ctx.Done():
					return
				case <-ticker.C:
					cleanupStaleAlerts()
				}
			}
		}()
	})
}

// cleanupStaleAlerts removes alerts older than PendingAlertExpiry
func cleanupStaleAlerts() {
	pendingAlertsMu.Lock()
	defer pendingAlertsMu.Unlock()

	// Calculate threshold inside lock to avoid race condition
	staleThreshold := time.Now().Add(-PendingAlertExpiry).Unix()

	for id, alert := range pendingAlerts {
		if alert.TimestampUnix < staleThreshold {
			delete(pendingAlerts, id)
		}
	}
}

// loadHubConfig loads Hub configuration from file
func loadHubConfig() *HubConfig {
	if hubConfigPath == "" {
		hubConfigPath = filepath.Join(dataDir, "hub.json")
	}

	cfg := &HubConfig{}
	if data, err := os.ReadFile(hubConfigPath); err == nil {
		json.Unmarshal(data, cfg)
	}

	// Override with environment variables
	if addr := os.Getenv("NITELLA_HUB"); addr != "" {
		cfg.HubAddress = addr
	}
	if token := os.Getenv("NITELLA_HUB_TOKEN"); token != "" {
		cfg.Token = token
	}
	if stun := os.Getenv("NITELLA_STUN"); stun != "" {
		cfg.STUNServer = stun
	}

	// Override with flags
	if hubAddress != "" {
		cfg.HubAddress = hubAddress
	}
	if hubToken != "" {
		cfg.Token = hubToken
	}
	if stunServer != "" {
		cfg.STUNServer = stunServer
	}

	// Set default data dir
	if cfg.DataDir == "" {
		cfg.DataDir = dataDir
	}

	return cfg
}

// saveHubConfig saves Hub configuration to file
func saveHubConfig(cfg *HubConfig) error {
	dir := filepath.Dir(hubConfigPath)
	if err := os.MkdirAll(dir, 0700); err != nil {
		return err
	}
	data, err := json.MarshalIndent(cfg, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(hubConfigPath, data, 0600)
}

// connectToHub establishes mTLS connection to Hub using CLI identity
func connectToHub(cfg *HubConfig) error {
	if cfg.HubAddress == "" {
		return fmt.Errorf("hub address not configured (use 'config set hub_address <addr>')")
	}

	// Create TLS config with mTLS using CLI identity
	tlsConfig := &tls.Config{
		MinVersion: tls.VersionTLS13,
	}

	// Add client certificate from identity (mTLS)
	if cliIdentity != nil && len(cliIdentity.RootCertPEM) > 0 && cliIdentity.RootKey != nil {
		// Generate a client cert signed by our Root CA
		clientCertPEM, clientKeyPEM, err := cliIdentity.GenerateClientCert("nitella-cli", 365)
		if err != nil {
			return fmt.Errorf("failed to generate client certificate: %w", err)
		}

		// Parse the client cert and key
		cert, err := tls.X509KeyPair(clientCertPEM, clientKeyPEM)
		if err != nil {
			return fmt.Errorf("failed to load client certificate: %w", err)
		}
		tlsConfig.Certificates = []tls.Certificate{cert}
	}

	// Load Hub CA - mTLS requires proper certificate verification
	rootCAs, err := cli.LoadCertPoolFromPEM([]byte(cfg.HubCAPEM))
	if err != nil {
		return fmt.Errorf("hub CA not configured and system CA pool unavailable - configure hub_ca_pem or use 'register' to obtain Hub CA: %w", err)
	}
	tlsConfig.RootCAs = rootCAs

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	conn, err := grpc.DialContext(ctx, cfg.HubAddress,
		grpc.WithTransportCredentials(credentials.NewTLS(tlsConfig)),
	)
	if err != nil {
		return fmt.Errorf("failed to connect to hub: %w", err)
	}

	hubConn = conn
	mobileClient = pb.NewMobileServiceClient(conn)
	nodeClient = pb.NewNodeServiceClient(conn)
	adminClient = pb.NewAdminServiceClient(conn)

	// Start P2P transport if not already running
	startP2PTransport(cfg)

	return nil
}

// ensureHubConnected loads config and connects to Hub.
// Returns the config on success, or nil after printing an error.
func ensureHubConnected() *HubConfig {
	cfg := loadHubConfig()
	if err := connectToHub(cfg); err != nil {
		fmt.Printf("Error connecting to Hub: %v\n", err)
		return nil
	}
	return cfg
}

// startP2PTransport initializes the P2P transport for direct connections to nodes
func startP2PTransport(cfg *HubConfig) {
	p2pTransportMu.Lock()
	defer p2pTransportMu.Unlock()

	// Already running?
	if p2pTransport != nil {
		return
	}

	// Need identity for P2P authentication
	if cliIdentity == nil || cliIdentity.RootKey == nil {
		return
	}

	// Create P2P transport - use fingerprint as user ID
	userID := ""
	if cliIdentity != nil {
		userID = cliIdentity.Fingerprint
	}
	transport := p2p.NewTransport(userID, mobileClient)

	// Set identity for authentication
	transport.SetIdentity(cliIdentity.RootKey)
	if cfg.STUNServer != "" {
		transport.SetSTUNServer(cfg.STUNServer)
	}

	// Set handler for incoming P2P approval requests
	transport.SetApprovalRequestHandler(func(nodeID string, req *p2p.ApprovalRequest) {
		handleP2PApprovalRequest(nodeID, req)
	})

	// Start signaling in background
	ctx, cancel := context.WithCancel(context.Background())
	p2pTransportCancel = cancel
	p2pTransport = transport

	go func() {
		if err := transport.StartSignaling(ctx); err != nil {
			// Signaling failed - clear transport
			p2pTransportMu.Lock()
			if p2pTransport == transport {
				p2pTransport = nil
				p2pTransportCancel = nil
			}
			p2pTransportMu.Unlock()
		}
	}()
}

// handleP2PApprovalRequest processes an incoming approval request via P2P
func handleP2PApprovalRequest(nodeID string, req *p2p.ApprovalRequest) {
	// Store as pending alert
	alert := &common.Alert{
		Id:            req.RequestID,
		NodeId:        req.NodeID,
		Severity:      req.Severity,
		TimestampUnix: time.Now().Unix(),
		Metadata: map[string]string{
			"source_ip":   req.SourceIP,
			"destination": req.DestAddr,
			"proxy_id":    req.ProxyID,
			"rule_id":     req.RuleID,
			"geo_country": req.GeoCountry,
			"geo_city":    req.GeoCity,
			"geo_isp":     req.GeoISP,
			"via_p2p":     "true",
		},
	}

	pendingAlertsMu.Lock()
	pendingAlerts[alert.Id] = alert
	pendingAlertsMu.Unlock()

	// Display alert notification with P2P indicator
	displayP2PAlertNotification(req)
}

// displayP2PAlertNotification shows a P2P approval request in the terminal
func displayP2PAlertNotification(req *p2p.ApprovalRequest) {
	displayAlert(AlertInfo{
		ID:         req.RequestID,
		NodeID:     req.NodeID,
		Severity:   req.Severity,
		Timestamp:  time.Now(),
		Source:     "P2P",
		SourceIP:   req.SourceIP,
		DestAddr:   req.DestAddr,
		ProxyID:    req.ProxyID,
		GeoCountry: req.GeoCountry,
		GeoCity:    req.GeoCity,
		GeoISP:     req.GeoISP,
	})
}

// tryP2PApproval attempts to send approval decision via P2P
// Returns true if sent via P2P, false if should fall back to Hub
func tryP2PApproval(requestID string, allowed bool, durationSeconds int64, reason string) bool {
	p2pTransportMu.RLock()
	transport := p2pTransport
	p2pTransportMu.RUnlock()

	if transport == nil {
		return false
	}

	// Find the node for this request
	pendingAlertsMu.RLock()
	alert, ok := pendingAlerts[requestID]
	pendingAlertsMu.RUnlock()

	if !ok || alert == nil {
		return false
	}

	// Check if this was a P2P request
	if alert.Metadata == nil || alert.Metadata["via_p2p"] != "true" {
		return false
	}

	nodeID := alert.NodeId
	if !transport.IsConnected(nodeID) {
		return false
	}

	// Send decision via P2P
	action := int32(2) // block
	if allowed {
		action = 1 // allow
	}

	decision := &p2p.ApprovalDecision{
		RequestID:       requestID,
		Action:          action,
		DurationSeconds: durationSeconds,
		Reason:          reason,
	}

	if err := transport.SendApprovalDecision(nodeID, decision); err != nil {
		return false
	}

	return true
}

// sendE2EApprovalViaHub sends an E2E encrypted approval decision via Hub
// The Hub cannot see the decision - it's encrypted with the node's public key
func sendE2EApprovalViaHub(ctx context.Context, cfg *HubConfig, nodeID, requestID string, allowed bool, durationSeconds int64, reason string) error {
	// Load node's public key from stored certificate
	nodePubKey, err := identity.LoadNodePublicKey(dataDir, nodeID)
	if err != nil {
		return fmt.Errorf("failed to load node public key (node may not be paired): %w", err)
	}

	// Create the resolve approval payload
	action := common.ApprovalActionType_APPROVAL_ACTION_TYPE_ALLOW
	if !allowed {
		action = common.ApprovalActionType_APPROVAL_ACTION_TYPE_BLOCK
	}

	// Create inner command payload (this is what gets encrypted)
	// Uses duration_seconds for arbitrary duration support (not enum)
	innerPayload := &pb.EncryptedCommandPayload{
		Type: pb.CommandType_COMMAND_TYPE_RESOLVE_APPROVAL,
		Payload: mustMarshalJSON(map[string]interface{}{
			"req_id":           requestID,
			"action":           int32(action),
			"duration_seconds": durationSeconds,
			"reason":           reason,
		}),
	}

	innerBytes, err := proto.Marshal(innerPayload)
	if err != nil {
		return fmt.Errorf("failed to marshal inner payload: %w", err)
	}

	// Encrypt with node's public key (E2E - Hub cannot decrypt)
	encrypted, err := nitellacrypto.Encrypt(innerBytes, nodePubKey)
	if err != nil {
		return fmt.Errorf("failed to encrypt payload: %w", err)
	}

	// Convert to protobuf EncryptedPayload
	pbEncrypted := &common.EncryptedPayload{
		EphemeralPubkey: encrypted.EphemeralPubKey,
		Nonce:           encrypted.Nonce,
		Ciphertext:      encrypted.Ciphertext,
	}

	// Generate routing token for this node
	routingToken := routing.GenerateRoutingToken(nodeID, cliIdentity.RootKey)

	// Send via Hub (Hub just forwards the encrypted blob)
	_, err = mobileClient.SendCommand(ctx, &pb.CommandRequest{
		NodeId:       nodeID,
		RoutingToken: routingToken,
		Encrypted:    pbEncrypted,
	})
	if err != nil {
		return fmt.Errorf("failed to send command via Hub: %w", err)
	}

	return nil
}

// mustMarshalJSON marshals to JSON, panics on error (for static data)
func mustMarshalJSON(v interface{}) []byte {
	b, err := json.Marshal(v)
	if err != nil {
		panic(err)
	}
	return b
}

// handleHubCommand handles hub-specific commands
func handleHubCommand(args []string) {
	if len(args) == 0 {
		printHubHelp()
		return
	}

	switch args[0] {
	case "identity":
		cmdIdentity(args[1:])
		return
	case "config":
		cmdHubConfig(args[1:])
	case "login":
		cmdHubLogin(args[1:])
	case "register":
		cmdHubRegister(args[1:])
	case "status":
		cmdHubStatus()
	case "pair":
		cmdHubPair(args[1:])
	case "pair-offline":
		cmdHubPairOffline(args[1:])
	case "nodes":
		cmdHubNodes(args[1:])
	case "node":
		cmdHubNode(args[1:])
	case "alerts":
		cmdHubAlerts(args[1:])
	case "approvals", "pending":
		cmdHubPending(args[1:])
	case "approve":
		cmdHubApprove(args[1:])
	case "deny":
		cmdHubDeny(args[1:])
	case "proxy":
		cmdHubProxy(args[1:])
	case "send":
		cmdHubSend(args[1:])
	case "logs":
		cmdHubLogs(args[1:])
	case "help":
		printHubHelp()
	default:
		fmt.Printf("Unknown hub command: %s. Type 'help' for available commands.\n", args[0])
	}
}

func printHubHelp() {
	fmt.Print(`
Hub Mode Commands:
  config                         - Show/set Hub configuration
  config set <key> <value>       - Set configuration (hub_address, token)
  login                          - Login to Hub (interactive)
  register                       - Register this CLI with Hub using mTLS
  status                         - Show Hub connection status

  Node Pairing (PAKE - Hub learns nothing):
  pair                           - Start pairing session, generate code
  pair-offline                   - Offline QR code pairing mode

  Node Management:
  nodes                          - List registered nodes
  node <node_id>                 - Select a node for commands
  node <node_id> status          - Show node status
  node <node_id> rules           - List node rules
  node <node_id> metrics         - Stream node metrics

  alerts                         - Stream real-time alerts (approval requests)
  approve <request_id> [duration]- Approve a connection (default: 300s)
  deny <request_id> [reason]     - Deny a connection

  Proxy Management (E2E encrypted):
  proxy                          - Show proxy help
  proxy import <file.yaml>       - Import YAML file as proxy config
  proxy list [--local|--remote]  - List proxies
  proxy show <proxy-id>          - Show proxy details
  proxy edit <proxy-id>          - Edit proxy (opens $EDITOR)
  proxy push <proxy-id> -m "msg" - Push to Hub
  proxy pull <proxy-id>          - Pull from Hub
  proxy history <proxy-id>       - View revision history
  proxy apply <proxy-id> <node>  - Apply proxy to node

  send <node_id> <command>       - Send command to node (via Hub relay)

  Logs Management (Admin):
  logs stats                     - Show logs storage statistics
  logs list <routing_token>      - List logs for a routing token
  logs delete <routing_token>    - Delete logs for a routing token
  logs cleanup <days>            - Delete logs older than N days

  help                           - Show this help
`)
}

func cmdHubConfig(args []string) {
	cfg := loadHubConfig()

	if len(args) == 0 {
		// Show current configuration
		fmt.Println("\nHub Configuration:")
		fmt.Printf("  Config file:  %s\n", hubConfigPath)
		fmt.Printf("  Hub address:  %s\n", cfg.HubAddress)
		if cfg.Token != "" {
			if len(cfg.Token) > 12 {
				fmt.Printf("  Token:        %s...%s\n", cfg.Token[:8], cfg.Token[len(cfg.Token)-4:])
			} else {
				fmt.Printf("  Token:        (set)\n")
			}
		} else {
			fmt.Printf("  Token:        (not set)\n")
		}
		fmt.Printf("  Data dir:     %s\n", cfg.DataDir)
		if cfg.HubCAPEM != "" {
			fmt.Printf("  Hub CA:       (pinned)\n")
		} else {
			fmt.Printf("  Hub CA:       (not pinned - will use TOFU)\n")
		}
		fmt.Println()
		return
	}

	if args[0] == "set" && len(args) >= 3 {
		key, value := args[1], args[2]
		switch key {
		case "hub_address", "hub", "address":
			cfg.HubAddress = value
		case "token":
			cfg.Token = value
		case "data_dir":
			cfg.DataDir = value
		default:
			fmt.Printf("Unknown config key: %s\n", key)
			return
		}
		if err := saveHubConfig(cfg); err != nil {
			fmt.Printf("Error saving config: %v\n", err)
			return
		}
		fmt.Printf("Set %s = %s\n", key, value)
		return
	}

	fmt.Println("Usage: config [set <key> <value>]")
}

func cmdHubLogin(args []string) {
	cfg := loadHubConfig()

	if cfg.HubAddress == "" {
		fmt.Print("Hub address: ")
		fmt.Scanln(&cfg.HubAddress)
	}

	fmt.Print("Authentication token: ")
	fmt.Scanln(&cfg.Token)

	if cfg.Token == "" {
		fmt.Println("Token is required.")
		return
	}

	// Try to connect with mTLS
	if err := connectToHub(cfg); err != nil {
		fmt.Printf("Login failed: %v\n", err)
		return
	}

	if err := saveHubConfig(cfg); err != nil {
		fmt.Printf("Error saving config: %v\n", err)
		return
	}

	fmt.Println("Login successful. Configuration saved.")
}

func cmdHubRegister(args []string) {
	cfg := loadHubConfig()

	if cfg.HubAddress == "" {
		fmt.Println("Hub address not configured. Use 'config set hub_address <addr>'")
		return
	}

	if cliIdentity == nil {
		fmt.Println("Identity not initialized.")
		return
	}

	// Connect to Hub
	if err := connectToHub(cfg); err != nil {
		fmt.Printf("Failed to connect to Hub: %v\n", err)
		return
	}

	// Generate CSR
	fmt.Println("Generating CSR for Hub registration...")
	csr, err := generateCSR(cliIdentity.RootKey, "nitella-cli-"+cliIdentity.Fingerprint[:8])
	if err != nil {
		fmt.Printf("Failed to generate CSR: %v\n", err)
		return
	}

	// Register with Hub
	fmt.Println("\nRegistration Request:")
	fmt.Printf("  Emoji Hash: %s\n", cliIdentity.EmojiHash)
	fmt.Printf("  Fingerprint: %s...%s\n", cliIdentity.Fingerprint[:8], cliIdentity.Fingerprint[len(cliIdentity.Fingerprint)-8:])
	fmt.Println()

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	resp, err := nodeClient.Register(ctx, &pb.NodeRegisterRequest{
		CsrPem: string(csr),
	})
	if err != nil {
		fmt.Printf("Registration failed: %v\n", err)
		return
	}

	fmt.Printf("Registration submitted. Code: %s\n", resp.RegistrationCode)
	fmt.Println("Waiting for approval...")

	// Watch for approval
	watchCtx, watchCancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer watchCancel()

	stream, err := nodeClient.WatchRegistration(watchCtx, &pb.WatchRegistrationRequest{
		RegistrationCode: resp.RegistrationCode,
		WatchSecret:      resp.WatchSecret, // Only we know this secret
	})
	if err != nil {
		fmt.Printf("Failed to watch registration: %v\n", err)
		return
	}

	watchResp, err := stream.Recv()
	if err != nil {
		fmt.Printf("Registration stream error: %v\n", err)
		return
	}

	if watchResp.Status == pb.RegistrationStatus_REGISTRATION_STATUS_APPROVED {
		fmt.Println("Registration APPROVED!")

		// Save certificate
		certPath := filepath.Join(cfg.DataDir, "cli_cert.pem")
		if err := os.WriteFile(certPath, []byte(watchResp.CertPem), 0600); err != nil {
			fmt.Printf("Failed to save certificate: %v\n", err)
		} else {
			fmt.Printf("Certificate saved to: %s\n", certPath)
		}

		// Save Hub CA if provided
		if watchResp.CaPem != "" {
			cfg.HubCAPEM = watchResp.CaPem
			saveHubConfig(cfg)
			fmt.Println("Hub CA certificate saved.")
		}
	} else if watchResp.Status == pb.RegistrationStatus_REGISTRATION_STATUS_REJECTED {
		fmt.Println("Registration REJECTED.")
	} else {
		fmt.Printf("Registration ended with status: %s\n", watchResp.Status)
	}
}

// generateCSR generates a Certificate Signing Request
func generateCSR(privateKey ed25519.PrivateKey, commonName string) ([]byte, error) {
	template := x509.CertificateRequest{
		Subject: pkix.Name{
			CommonName: commonName,
		},
		SignatureAlgorithm: x509.PureEd25519,
	}

	csrDER, err := x509.CreateCertificateRequest(rand.Reader, &template, privateKey)
	if err != nil {
		return nil, err
	}

	csrPEM := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE REQUEST", Bytes: csrDER})
	return csrPEM, nil
}

func cmdHubStatus() {
	cfg := ensureHubConnected()
	if cfg == nil {
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	resp, err := mobileClient.ListNodes(ctx, &pb.ListNodesRequest{})
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	online := 0
	for _, n := range resp.Nodes {
		if n.Status == pb.NodeStatus_NODE_STATUS_ONLINE {
			online++
		}
	}

	fmt.Println("\nHub Connection Status: Connected")
	fmt.Printf("  Hub Address:  %s\n", cfg.HubAddress)
	fmt.Printf("  Total nodes:  %d\n", len(resp.Nodes))
	fmt.Printf("  Online nodes: %d\n", online)
	fmt.Println()
}

func cmdHubNodes(args []string) {
	cfg := ensureHubConnected()
	if cfg == nil {
		return
	}
	_ = cfg // cfg used for potential future P2P operations

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	resp, err := mobileClient.ListNodes(ctx, &pb.ListNodesRequest{})
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	if len(resp.Nodes) == 0 {
		fmt.Println("No nodes registered.")
		return
	}

	tbl := cli.NewTable(
		cli.Column{Header: "NODE ID", Width: 36},
		cli.Column{Header: "STATUS", Width: 12},
		cli.Column{Header: "LAST SEEN", Width: 16},
	)
	tbl.PrintHeader()
	for _, n := range resp.Nodes {
		status := n.Status.String()
		lastSeen := "never"
		if n.LastSeen != nil {
			lastSeen = n.LastSeen.AsTime().Format("2006-01-02 15:04")
		}
		tbl.PrintRow(n.Id, status, lastSeen)
	}
	tbl.PrintFooter()
}

func cmdHubNode(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: node <node_id> [status|rules|metrics|command...]")
		return
	}

	cfg := ensureHubConnected()
	if cfg == nil {
		return
	}

	nodeID := args[0]
	subCmd := "status"
	if len(args) > 1 {
		subCmd = args[1]
	}

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	switch subCmd {
	case "status":
		node, err := mobileClient.GetNode(ctx, &pb.GetNodeRequest{NodeId: nodeID})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		fmt.Printf("\nNode: %s\n", node.Id)
		fmt.Printf("  Status:       %s\n", node.Status.String())
		if node.LastSeen != nil {
			fmt.Printf("  Last seen:    %s\n", node.LastSeen.AsTime().Format(time.RFC3339))
		}
		if node.PublicIp != "" {
			fmt.Printf("  Public IP:    %s\n", node.PublicIp)
		}
		if node.Version != "" {
			fmt.Printf("  Version:      %s\n", node.Version)
		}
		fmt.Printf("  GeoIP:        %v\n", node.GeoipEnabled)
		fmt.Println()

	case "rules":
		// Send list rules command via CLIClient
		cliClient := createCLIClientWithRouting(cfg)
		if err := cliClient.Connect(ctx); err != nil {
			fmt.Printf("Error connecting: %v\n", err)
			return
		}
		defer cliClient.Close()

		// Get node for E2E (note: in new proto, node identity is encrypted)
		// For now, we'll attempt without E2E encryption
		var nodePubKey ed25519.PublicKey

		rules, err := cliClient.GetNodeRules(ctx, nodeID, nodePubKey)
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}

		if len(rules) == 0 {
			fmt.Println("No rules configured.")
			return
		}

		fmt.Printf("\n%-36s  %-20s  %-8s  %-8s\n", "ID", "Name", "Priority", "Action")
		fmt.Println(strings.Repeat("-", 80))
		for _, r := range rules {
			name := r.Name
			if len(name) > 20 {
				name = name[:17] + "..."
			}
			fmt.Printf("%-36s  %-20s  %-8d  %-8s\n",
				r.Id, name, r.Priority, r.Action.String())
		}
		fmt.Println()

	case "metrics":
		fmt.Println("Streaming metrics (Ctrl+C to stop)...")

		// Create CLI client for metrics streaming
		metricsClient := createCLIClientWithRouting(cfg)

		metricsCtx, metricsCancel := context.WithCancel(context.Background())
		defer metricsCancel()

		if err := metricsClient.Connect(metricsCtx); err != nil {
			fmt.Printf("Error connecting: %v\n", err)
			return
		}
		defer metricsClient.Close()

		// Handle Ctrl+C
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, os.Interrupt, syscall.SIGINT)
		go func() {
			<-sigCh
			fmt.Println("\nStopping metrics stream...")
			metricsCancel()
		}()
		defer signal.Stop(sigCh)

		// Set up metrics callback
		metricsClient.SetMetricsCallback(func(nid string, metrics *pb.Metrics) {
			ts := time.Now().Format("15:04:05")
			fmt.Printf("[%s] Node: %s\n", ts, nid)
			fmt.Printf("  Connections: %d active / %d total\n",
				metrics.ConnectionsActive, metrics.ConnectionsTotal)
			fmt.Printf("  Traffic:     %s in / %s out\n",
				formatBytes(metrics.BytesIn), formatBytes(metrics.BytesOut))
			fmt.Printf("  Blocked:     %d\n", metrics.BlockedCount)
			fmt.Println()
		})

		// Start metrics stream
		if err := metricsClient.StartMetricsStream(metricsCtx, nodeID); err != nil {
			fmt.Printf("Error starting metrics stream: %v\n", err)
			return
		}

		fmt.Printf("Streaming metrics from node %s...\n\n", nodeID)

		// Wait for context cancellation
		<-metricsCtx.Done()
		fmt.Println("Metrics stream stopped.")

	default:
		// Treat as a command to send
		fmt.Printf("Sending command '%s' to node %s...\n", subCmd, nodeID)

		// Create CLI client for command sending
		cmdClient := createCLIClientWithRouting(cfg)

		cmdCtx, cmdCancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cmdCancel()

		if err := cmdClient.Connect(cmdCtx); err != nil {
			fmt.Printf("Error connecting: %v\n", err)
			return
		}
		defer cmdClient.Close()

		// Build command payload
		cmdPayload := []byte(strings.Join(args[2:], " ")) // Join remaining args as payload

		// Get node public key for E2E encryption (if available)
		// Note: In zero-trust mode, certificate is not exposed via API
		// E2E encryption requires out-of-band key exchange during pairing
		var nodePubKey ed25519.PublicKey
		_, _ = cmdClient.GetNode(cmdCtx, nodeID) // Verify node exists

		result, err := cmdClient.SendCommand(cmdCtx, nodeID, pb.CommandType_COMMAND_TYPE_EXECUTE, cmdPayload, nodePubKey)
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}

		fmt.Printf("Response:\n")
		fmt.Printf("  Status: %s\n", result.Status)
		if result.ErrorMessage != "" {
			fmt.Printf("  Error:  %s\n", result.ErrorMessage)
		}
		if len(result.ResponsePayload) > 0 {
			fmt.Printf("  Data:   %s\n", string(result.ResponsePayload))
		}
	}
}

func cmdHubPending(args []string) {
	alerts := listPendingAlerts()
	if len(alerts) == 0 {
		fmt.Println("No pending approval requests.")
		if !alertStreamRunning {
			fmt.Println("Tip: Alert streaming is not running. Run 'alerts' to start streaming.")
		}
		return
	}

	fmt.Printf("\nPending Approval Requests (%d):\n", len(alerts))
	fmt.Println(strings.Repeat("-", 80))
	for _, alert := range alerts {
		ts := time.Unix(alert.TimestampUnix, 0).Format("2006-01-02 15:04:05")
		fmt.Printf("ID: %s\n", alert.Id)
		fmt.Printf("  Node:   %s\n", alert.NodeId)
		fmt.Printf("  Time:   %s\n", ts)
		if alert.Metadata != nil {
			if sourceIP, ok := alert.Metadata["source_ip"]; ok {
				fmt.Printf("  Source: %s\n", sourceIP)
			}
			if dest, ok := alert.Metadata["destination"]; ok {
				fmt.Printf("  Dest:   %s\n", dest)
			}
			if country, ok := alert.Metadata["geo_country"]; ok {
				fmt.Printf("  Geo:    %s\n", country)
			}
		}
		fmt.Println()
	}
	fmt.Println("Use 'approve <id> [duration]' or 'deny <id>' to respond.")
}

func cmdHubAlerts(args []string) {
	if ensureHubConnected() == nil {
		return
	}

	fmt.Println("Streaming alerts from Hub (Ctrl+C to stop)...")
	fmt.Println("When an approval request appears, use 'approve <id>' or 'deny <id>' in another terminal.")
	fmt.Println()

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Handle Ctrl+C
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGINT)
	go func() {
		<-sigCh
		fmt.Println("\nStopping alert stream...")
		cancel()
	}()
	defer signal.Stop(sigCh)

	stream, err := mobileClient.StreamAlerts(ctx, &pb.StreamAlertsRequest{})
	if err != nil {
		fmt.Printf("Error starting alert stream: %v\n", err)
		return
	}

	for {
		alert, err := stream.Recv()
		if err != nil {
			if ctx.Err() != nil {
				fmt.Println("Alert stream stopped.")
				return
			}
			fmt.Printf("Alert stream error: %v\n", err)
			return
		}

		// Display alert
		ts := time.Unix(alert.TimestampUnix, 0).Format("15:04:05")
		severity := alert.Severity

		fmt.Printf("\n[%s] %s ALERT\n", ts, severity)
		fmt.Printf("  ID:       %s\n", alert.Id)
		fmt.Printf("  Node:     %s\n", alert.NodeId)

		// Check if this is an approval request (has encrypted payload)
		if alert.Encrypted != nil {
			fmt.Printf("  Type:     CONNECTION APPROVAL REQUEST\n")
			fmt.Printf("  Action:   Run 'approve %s' or 'deny %s'\n", alert.Id, alert.Id)
		}

		// Show metadata if available
		if alert.Metadata != nil {
			if sourceIP, ok := alert.Metadata["source_ip"]; ok {
				fmt.Printf("  Source:   %s\n", sourceIP)
			}
			if dest, ok := alert.Metadata["destination"]; ok {
				fmt.Printf("  Dest:     %s\n", dest)
			}
			if country, ok := alert.Metadata["geo_country"]; ok {
				fmt.Printf("  Country:  %s\n", country)
			}
		}
		fmt.Println()
	}
}

// executeApprovalDecision handles both approve and deny actions.
func executeApprovalDecision(requestID string, allowed bool, duration int64, reason string) {
	cfg := ensureHubConnected()
	if cfg == nil {
		return
	}

	// Get node ID from pending alert
	alert := getPendingAlert(requestID)
	if alert == nil {
		fmt.Printf("Error: No pending alert found for request %s\n", requestID)
		return
	}
	nodeID := alert.NodeId

	// Try P2P first for faster response
	p2pAttempted := p2pTransport != nil
	if tryP2PApproval(requestID, allowed, duration, reason) {
		if allowed {
			fmt.Printf("Approved request via P2P: %s (duration: %ds)\n", requestID, duration)
		} else {
			fmt.Printf("Denied request via P2P: %s\n", requestID)
		}
		removePendingAlert(requestID)
		return
	}

	// Fall back to Hub with E2E encrypted command
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	err := sendE2EApprovalViaHub(ctx, cfg, nodeID, requestID, allowed, duration, reason)
	if err != nil {
		if p2pAttempted {
			fmt.Printf("Error: P2P failed, Hub also failed: %v\n", err)
		} else {
			fmt.Printf("Error: %v\n", err)
		}
		return
	}

	printApprovalResult(allowed, p2pAttempted, requestID, duration, reason)
	removePendingAlert(requestID)
}

// printApprovalResult outputs the result of an approval decision.
func printApprovalResult(allowed, p2pAttempted bool, requestID string, duration int64, reason string) {
	action := "Approved"
	extra := fmt.Sprintf("(duration: %ds)", duration)
	if !allowed {
		action = "Denied"
		extra = fmt.Sprintf("(reason: %s)", reason)
	}

	if p2pAttempted {
		fmt.Printf("%s request via Hub (P2P unavailable): %s %s [E2E encrypted]\n", action, requestID, extra)
	} else {
		fmt.Printf("%s request via Hub: %s %s [E2E encrypted]\n", action, requestID, extra)
	}
}

func cmdHubApprove(args []string) {
	if !cli.RequireArgs(args, 1, "Usage: approve <request_id> [duration_seconds]") {
		return
	}
	duration := int64(config.DefaultApprovalDurationSeconds)
	if len(args) > 1 {
		d, err := cli.ParseDuration(args[1], duration)
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		duration = d
	}
	executeApprovalDecision(args[0], true, duration, "")
}

func cmdHubDeny(args []string) {
	if !cli.RequireArgs(args, 1, "Usage: deny <request_id> [reason]") {
		return
	}
	reason := "Denied via CLI"
	if len(args) > 1 {
		reason = strings.Join(args[1:], " ")
	}
	executeApprovalDecision(args[0], false, 0, reason)
}

// saveNodeCertWithLog saves a node certificate and logs the result.
func saveNodeCertWithLog(nodeID string, certPEM []byte) {
	if err := identity.SaveNodeCert(dataDir, nodeID, certPEM); err != nil {
		fmt.Printf("Warning: Failed to save node certificate locally: %v\n", err)
	} else {
		fmt.Printf("Saved node certificate: %s/nodes/%s.crt\n", dataDir, nodeID)
	}
}

func cmdHubSend(args []string) {
	if len(args) < 2 {
		fmt.Println("Usage: send <node_id> <command> [params...]")
		fmt.Println()
		fmt.Println("Commands:")
		fmt.Println("  reload        - Reload configuration")
		fmt.Println("  status        - Get node status")
		fmt.Println("  list-rules    - List all rules")
		fmt.Println("  add-rule      - Add a rule (JSON payload)")
		fmt.Println("  remove-rule   - Remove a rule by ID")
		return
	}

	cfg := ensureHubConnected()
	if cfg == nil {
		return
	}

	nodeID := args[0]
	command := args[1]

	// Create CLI client
	sendClient := createCLIClientWithRouting(cfg)

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := sendClient.Connect(ctx); err != nil {
		fmt.Printf("Error connecting: %v\n", err)
		return
	}
	defer sendClient.Close()

	// Get node public key for E2E encryption
	// Note: In zero-trust mode, certificate is not exposed via API
	// E2E encryption requires out-of-band key exchange during pairing
	var nodePubKey ed25519.PublicKey
	_, _ = sendClient.GetNode(ctx, nodeID) // Verify node exists

	// Map command to CommandType
	var cmdType pb.CommandType
	var payload []byte

	switch command {
	case "reload", "status", "list-rules":
		cmdType = pb.CommandType_COMMAND_TYPE_EXECUTE
		payload = []byte(command)
	case "add-rule":
		cmdType = pb.CommandType_COMMAND_TYPE_ADD_RULE
		if len(args) > 2 {
			payload = []byte(strings.Join(args[2:], " "))
		}
	case "remove-rule":
		cmdType = pb.CommandType_COMMAND_TYPE_REMOVE_RULE
		if len(args) > 2 {
			payload = []byte(args[2])
		}
	case "get-connections":
		cmdType = pb.CommandType_COMMAND_TYPE_GET_ACTIVE_CONNECTIONS
	case "close-connection":
		cmdType = pb.CommandType_COMMAND_TYPE_CLOSE_CONNECTION
		if len(args) > 2 {
			payload = []byte(args[2])
		}
	case "close-all":
		cmdType = pb.CommandType_COMMAND_TYPE_CLOSE_ALL_CONNECTIONS
	case "stats":
		cmdType = pb.CommandType_COMMAND_TYPE_STATS_CONTROL
		if len(args) > 2 {
			payload = []byte(args[2]) // "start" or "stop"
		}
	default:
		cmdType = pb.CommandType_COMMAND_TYPE_EXECUTE
		payload = []byte(command)
		if len(args) > 2 {
			payload = []byte(command + " " + strings.Join(args[2:], " "))
		}
	}

	fmt.Printf("Sending command '%s' to node %s...\n", command, nodeID)

	result, err := sendClient.SendCommand(ctx, nodeID, cmdType, payload, nodePubKey)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	fmt.Printf("\nResponse:\n")
	fmt.Printf("  Status: %s\n", result.Status)
	if result.ErrorMessage != "" {
		fmt.Printf("  Error:  %s\n", result.ErrorMessage)
	}
	if len(result.ResponsePayload) > 0 {
		// Try to pretty-print JSON, otherwise print raw
		var prettyJSON map[string]interface{}
		if json.Unmarshal(result.ResponsePayload, &prettyJSON) == nil {
			formatted, _ := json.MarshalIndent(prettyJSON, "  ", "  ")
			fmt.Printf("  Data:\n  %s\n", string(formatted))
		} else {
			fmt.Printf("  Data:   %s\n", string(result.ResponsePayload))
		}
	}
}

// ============================================================================
// Logs Management Commands (Admin)
// ============================================================================

func cmdHubLogs(args []string) {
	if len(args) == 0 {
		printLogsHelp()
		return
	}

	if ensureHubConnected() == nil {
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	switch args[0] {
	case "stats":
		cmdLogsStats(ctx)
	case "list":
		if len(args) < 2 {
			fmt.Println("Usage: logs list <routing_token> [--node <node_id>] [--limit <n>]")
			return
		}
		cmdLogsList(ctx, args[1:])
	case "delete":
		if len(args) < 2 {
			fmt.Println("Usage: logs delete <routing_token> [--node <node_id>] [--before <date>] [--all]")
			return
		}
		cmdLogsDelete(ctx, args[1:])
	case "cleanup":
		if len(args) < 2 {
			fmt.Println("Usage: logs cleanup <days> [--dry-run]")
			return
		}
		cmdLogsCleanup(ctx, args[1:])
	default:
		fmt.Printf("Unknown logs command: %s\n", args[0])
		printLogsHelp()
	}
}

func printLogsHelp() {
	fmt.Print(`
Logs Management Commands (Admin):
  logs stats                          - Show logs storage statistics
  logs list <routing_token>           - List logs for a routing token
    --node <node_id>                  - Filter by node
    --limit <n>                       - Limit results (default: 100)
  logs delete <routing_token>         - Delete logs
    --node <node_id>                  - Delete only for specific node
    --before <date>                   - Delete logs before date (YYYY-MM-DD)
    --all                             - Delete all logs for routing token
  logs cleanup <days>                 - Delete logs older than N days
    --dry-run                         - Show what would be deleted
`)
}

func cmdLogsStats(ctx context.Context) {
	resp, err := adminClient.GetLogsStats(ctx, &pb.GetLogsStatsRequest{})
	if err != nil {
		fmt.Printf("Error getting logs stats: %v\n", err)
		return
	}

	fmt.Println("\nLogs Statistics:")
	fmt.Printf("  Total logs:     %d\n", resp.TotalLogs)
	fmt.Printf("  Total storage:  %s\n", formatBytes(resp.TotalStorageBytes))

	if resp.OldestLog != nil {
		fmt.Printf("  Oldest log:     %s\n", resp.OldestLog.AsTime().Format(time.RFC3339))
	}
	if resp.NewestLog != nil {
		fmt.Printf("  Newest log:     %s\n", resp.NewestLog.AsTime().Format(time.RFC3339))
	}

	if len(resp.LogsByRoutingToken) > 0 {
		fmt.Println("\n  By Routing Token:")
		for token, count := range resp.LogsByRoutingToken {
			storage := resp.StorageByRoutingToken[token]
			displayToken := token
			if len(token) > 20 {
				displayToken = token[:8] + "..." + token[len(token)-8:]
			}
			fmt.Printf("    %s: %d logs (%s)\n", displayToken, count, formatBytes(storage))
		}
	}
}

func cmdLogsList(ctx context.Context, args []string) {
	routingToken := args[0]
	nodeID := ""
	limit := int32(100)

	for i := 1; i < len(args); i++ {
		switch args[i] {
		case "--node":
			if i+1 < len(args) {
				nodeID = args[i+1]
				i++
			}
		case "--limit":
			if i+1 < len(args) {
				fmt.Sscanf(args[i+1], "%d", &limit)
				i++
			}
		}
	}

	resp, err := adminClient.ListLogs(ctx, &pb.ListLogsRequest{
		RoutingToken: routingToken,
		NodeId:       nodeID,
		PageSize:     limit,
	})
	if err != nil {
		fmt.Printf("Error listing logs: %v\n", err)
		return
	}

	fmt.Printf("\nLogs for %s (total: %d):\n", routingToken, resp.TotalCount)
	fmt.Println("  ID       | Node ID           | Timestamp           | Size")
	fmt.Println("  ---------+-------------------+---------------------+--------")

	for _, log := range resp.Logs {
		nodeDisplay := log.NodeId
		if len(nodeDisplay) > 17 {
			nodeDisplay = nodeDisplay[:14] + "..."
		}
		fmt.Printf("  %-8d | %-17s | %s | %s\n",
			log.Id,
			nodeDisplay,
			log.Timestamp.AsTime().Format("2006-01-02 15:04:05"),
			formatBytes(int64(log.EncryptedSizeBytes)),
		)
	}

	if resp.NextPageToken != "" {
		fmt.Printf("\n  (more results available, use --limit to increase)\n")
	}
}

func cmdLogsDelete(ctx context.Context, args []string) {
	routingToken := args[0]
	nodeID := ""
	deleteAll := false
	var beforeTime time.Time

	for i := 1; i < len(args); i++ {
		switch args[i] {
		case "--node":
			if i+1 < len(args) {
				nodeID = args[i+1]
				i++
			}
		case "--before":
			if i+1 < len(args) {
				t, err := time.Parse("2006-01-02", args[i+1])
				if err != nil {
					fmt.Printf("Invalid date format: %s (use YYYY-MM-DD)\n", args[i+1])
					return
				}
				beforeTime = t
				i++
			}
		case "--all":
			deleteAll = true
		}
	}

	if !deleteAll && nodeID == "" && beforeTime.IsZero() {
		fmt.Println("Error: specify --all, --node, or --before")
		return
	}

	req := &pb.DeleteLogsRequest{
		RoutingToken: routingToken,
		NodeId:       nodeID,
		DeleteAll:    deleteAll,
	}
	if !beforeTime.IsZero() {
		req.Before = timestamppb.New(beforeTime)
	}

	resp, err := adminClient.DeleteLogs(ctx, req)
	if err != nil {
		fmt.Printf("Error deleting logs: %v\n", err)
		return
	}

	fmt.Printf("Deleted %d logs, freed %s\n", resp.DeletedCount, formatBytes(resp.FreedBytes))
}

func cmdLogsCleanup(ctx context.Context, args []string) {
	var days int32
	dryRun := false

	fmt.Sscanf(args[0], "%d", &days)
	if days <= 0 {
		fmt.Println("Error: days must be a positive number")
		return
	}

	for i := 1; i < len(args); i++ {
		if args[i] == "--dry-run" {
			dryRun = true
		}
	}

	resp, err := adminClient.CleanupOldLogs(ctx, &pb.CleanupOldLogsRequest{
		OlderThanDays: days,
		DryRun:        dryRun,
	})
	if err != nil {
		fmt.Printf("Error cleaning up logs: %v\n", err)
		return
	}

	if dryRun {
		fmt.Printf("Would delete %d logs\n", resp.DeletedCount)
	} else {
		fmt.Printf("Deleted %d logs, freed %s\n", resp.DeletedCount, formatBytes(resp.FreedBytes))
	}

	if len(resp.DeletedByRoutingToken) > 0 {
		fmt.Println("\n  By Routing Token:")
		for token, count := range resp.DeletedByRoutingToken {
			displayToken := token
			if len(token) > 20 {
				displayToken = token[:8] + "..." + token[len(token)-8:]
			}
			fmt.Printf("    %s: %d logs\n", displayToken, count)
		}
	}
}

// ============================================================================
// PAKE Pairing Commands
// ============================================================================

func cmdHubPair(args []string) {
	if cliIdentity == nil {
		fmt.Println("Error: CLI identity not initialized. Run without --local first.")
		return
	}

	cfg := ensureHubConnected()
	if cfg == nil {
		return
	}

	// Generate pairing code
	code, err := pairing.GeneratePairingCode()
	if err != nil {
		fmt.Printf("Error generating pairing code: %v\n", err)
		return
	}

	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║                    NODE PAIRING (PAKE)                        ║")
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Printf("║                                                                ║\n")
	fmt.Printf("║    Pairing Code:  %-42s  ║\n", code)
	fmt.Printf("║                                                                ║\n")
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Println("║  On your node, run:                                           ║")
	fmt.Printf("║    nitellad --hub %s --pair %s  ║\n", truncateStr(cfg.HubAddress, 15), code)
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")
	fmt.Println()
	fmt.Println("Waiting for node to connect... (Ctrl+C to cancel)")

	// Create PAKE session
	pakeSession, err := pairing.NewPakeSession(pairing.RoleCLI, pairing.CodeToBytes(code))
	if err != nil {
		fmt.Printf("Error creating PAKE session: %v\n", err)
		return
	}

	// Connect to PakeExchange stream
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancel()

	// Handle Ctrl+C
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGINT)
	go func() {
		<-sigCh
		fmt.Println("\nPairing cancelled.")
		cancel()
	}()
	defer signal.Stop(sigCh)

	// Get pairing client
	pairingClient := pb.NewPairingServiceClient(hubConn)

	stream, err := pairingClient.PakeExchange(ctx)
	if err != nil {
		fmt.Printf("Error starting PAKE exchange: %v\n", err)
		return
	}

	// Send initial PAKE message
	initMsg, err := pakeSession.GetInitMessage()
	if err != nil {
		fmt.Printf("Error generating PAKE init message: %v\n", err)
		return
	}

	err = stream.Send(&pb.PakeMessage{
		SessionCode: code,
		Role:        pairing.RoleCLI,
		Type:        pb.PakeMessage_MESSAGE_TYPE_SPAKE2_INIT,
		Spake2Data:  initMsg,
	})
	if err != nil {
		fmt.Printf("Error sending PAKE init: %v\n", err)
		return
	}

	fmt.Println("PAKE session started, waiting for node...")

	// Receive node's init message
	nodeMsg, err := stream.Recv()
	if err != nil {
		if err == io.EOF {
			fmt.Println("Node disconnected.")
		} else {
			fmt.Printf("Error receiving from node: %v\n", err)
		}
		return
	}

	if nodeMsg.Type == pb.PakeMessage_MESSAGE_TYPE_ERROR {
		fmt.Printf("Node error: %s\n", nodeMsg.ErrorMessage)
		return
	}

	fmt.Println("Node connected! Processing PAKE exchange...")

	// Process node's init message
	_, err = pakeSession.ProcessInitMessage(nodeMsg.Spake2Data)
	if err != nil {
		fmt.Printf("PAKE verification failed (wrong code?): %v\n", err)
		return
	}

	// Send our reply
	replyMsg, _ := pakeSession.GetInitMessage()
	err = stream.Send(&pb.PakeMessage{
		SessionCode: code,
		Role:        pairing.RoleCLI,
		Type:        pb.PakeMessage_MESSAGE_TYPE_SPAKE2_REPLY,
		Spake2Data:  replyMsg,
	})
	if err != nil {
		fmt.Printf("Error sending PAKE reply: %v\n", err)
		return
	}

	// Display confirmation emoji
	emoji := pakeSession.DeriveConfirmationEmoji()
	fmt.Println()
	fmt.Printf("Verification emoji: %s\n", emoji)
	fmt.Println("Verify this matches what the node displays!")
	fmt.Println()

	// Wait for encrypted CSR from node
	fmt.Println("Waiting for node's certificate signing request...")
	csrMsg, err := stream.Recv()
	if err != nil {
		fmt.Printf("Error receiving CSR: %v\n", err)
		return
	}

	if csrMsg.Type != pb.PakeMessage_MESSAGE_TYPE_ENCRYPTED {
		fmt.Printf("Unexpected message type: %v\n", csrMsg.Type)
		return
	}

	// Decrypt CSR
	csrPEM, err := pakeSession.Decrypt(csrMsg.EncryptedPayload, csrMsg.Nonce)
	if err != nil {
		fmt.Printf("Error decrypting CSR: %v\n", err)
		return
	}

	// Parse and display CSR info
	block, _ := pem.Decode(csrPEM)
	if block == nil {
		fmt.Println("Error: Invalid CSR format")
		return
	}

	csr, err := x509.ParseCertificateRequest(block.Bytes)
	if err != nil {
		fmt.Printf("Error parsing CSR: %v\n", err)
		return
	}

	csrFingerprint := pairing.DeriveFingerprint(csrPEM)
	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║              CERTIFICATE SIGNING REQUEST                      ║")
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Printf("║  Node ID:     %-46s  ║\n", truncateStr(csr.Subject.CommonName, 46))
	fmt.Printf("║  Fingerprint: %-46s  ║\n", csrFingerprint)
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Println("║  Do you want to sign this certificate? (yes/no)              ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")

	// Get user confirmation
	reader := bufio.NewReader(os.Stdin)
	fmt.Print("> ")
	response, _ := reader.ReadString('\n')
	response = strings.TrimSpace(strings.ToLower(response))

	if response != "yes" && response != "y" {
		fmt.Println("Pairing cancelled by user.")
		stream.Send(&pb.PakeMessage{
			SessionCode:  code,
			Role:         pairing.RoleCLI,
			Type:         pb.PakeMessage_MESSAGE_TYPE_ERROR,
			ErrorMessage: "User rejected pairing",
		})
		return
	}

	// Sign the CSR with our Root CA
	fmt.Println("Signing certificate...")
	signedCertPEM, err := signCSRWithRootCA(csrPEM)
	if err != nil {
		fmt.Printf("Error signing CSR: %v\n", err)
		return
	}

	// Save node certificate locally for E2E encrypted communication
	nodeID := csr.Subject.CommonName
	saveNodeCertWithLog(nodeID, signedCertPEM)

	// Encrypt and send signed certificate
	encryptedCert, nonce, err := pakeSession.Encrypt(signedCertPEM)
	if err != nil {
		fmt.Printf("Error encrypting certificate: %v\n", err)
		return
	}

	err = stream.Send(&pb.PakeMessage{
		SessionCode:      code,
		Role:             pairing.RoleCLI,
		Type:             pb.PakeMessage_MESSAGE_TYPE_ENCRYPTED,
		EncryptedPayload: encryptedCert,
		Nonce:            nonce,
	})
	if err != nil {
		fmt.Printf("Error sending certificate: %v\n", err)
		return
	}

	// Also send our CA certificate
	caCertPEM := cliIdentity.RootCertPEM
	encryptedCA, caNonce, err := pakeSession.Encrypt(caCertPEM)
	if err != nil {
		fmt.Printf("Error encrypting CA cert: %v\n", err)
		return
	}

	err = stream.Send(&pb.PakeMessage{
		SessionCode:      code,
		Role:             pairing.RoleCLI,
		Type:             pb.PakeMessage_MESSAGE_TYPE_ENCRYPTED,
		EncryptedPayload: encryptedCA,
		Nonce:            caNonce,
	})
	if err != nil {
		fmt.Printf("Error sending CA cert: %v\n", err)
		return
	}

	// Zero-Trust: Generate and save routing token for this node
	// nodeID already set above when saving certificate
	userSecret, err := getOrCreateUserSecret(cfg)
	if err != nil {
		fmt.Printf("Warning: Failed to get user secret for routing token: %v\n", err)
	} else {
		routingToken := routing.GenerateRoutingToken(nodeID, userSecret)
		if err := saveRoutingToken(cfg, nodeID, routingToken); err != nil {
			fmt.Printf("Warning: Failed to save routing token: %v\n", err)
		}
	}

	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║                    PAIRING COMPLETE!                          ║")
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Printf("║  Node:        %-46s  ║\n", truncateStr(csr.Subject.CommonName, 46))
	fmt.Printf("║  Fingerprint: %-46s  ║\n", csrFingerprint)
	fmt.Println("║                                                                ║")
	fmt.Println("║  The node is now trusted and can connect via Hub.             ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")
	fmt.Println()
}

func cmdHubPairOffline(args []string) {
	if cliIdentity == nil {
		fmt.Println("Error: CLI identity not initialized.")
		return
	}

	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║              OFFLINE PAIRING (QR CODE)                        ║")
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Println("║                                                                ║")
	fmt.Println("║  1. On the node, run: nitellad --pair-offline                 ║")
	fmt.Println("║  2. The node will display a QR code with its CSR              ║")
	fmt.Println("║  3. Paste the QR data below (or scan with camera)             ║")
	fmt.Println("║                                                                ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")
	fmt.Println()
	fmt.Println("Paste the node's QR data (JSON) and press Enter:")
	fmt.Print("> ")

	reader := bufio.NewReader(os.Stdin)
	qrData, _ := reader.ReadString('\n')
	qrData = strings.TrimSpace(qrData)

	if qrData == "" {
		fmt.Println("No data provided. Cancelled.")
		return
	}

	// Parse QR payload
	payload, err := pairing.ParseQRPayload(qrData)
	if err != nil {
		fmt.Printf("Error parsing QR data: %v\n", err)
		return
	}

	if payload.Type != "csr" {
		fmt.Printf("Error: Expected CSR payload, got '%s'\n", payload.Type)
		return
	}

	// Decode CSR
	csrPEM, err := payload.GetCSR()
	if err != nil {
		fmt.Printf("Error decoding CSR: %v\n", err)
		return
	}

	// Parse CSR
	block, _ := pem.Decode(csrPEM)
	if block == nil {
		fmt.Println("Error: Invalid CSR format")
		return
	}

	csr, err := x509.ParseCertificateRequest(block.Bytes)
	if err != nil {
		fmt.Printf("Error parsing CSR: %v\n", err)
		return
	}

	// Verify fingerprint matches
	calculatedFP := pairing.DeriveFingerprint(csrPEM)

	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║              CERTIFICATE SIGNING REQUEST                      ║")
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Printf("║  Node ID:          %-40s  ║\n", truncateStr(csr.Subject.CommonName, 40))
	fmt.Printf("║  Fingerprint:      %-40s  ║\n", calculatedFP)

	if payload.Fingerprint != calculatedFP {
		fmt.Println("╠══════════════════════════════════════════════════════════════╣")
		fmt.Println("║  ERROR: Fingerprint mismatch - possible tampering!           ║")
		fmt.Println("║                                                              ║")
		fmt.Printf("║  Expected: %-49s ║\n", payload.Fingerprint)
		fmt.Printf("║  Got:      %-49s ║\n", calculatedFP)
		fmt.Println("║                                                              ║")
		fmt.Println("║  Refusing to sign. The QR code may have been modified.       ║")
		fmt.Println("╚══════════════════════════════════════════════════════════════╝")
		return
	}

	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Println("║  Sign this certificate? (yes/no)                              ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")

	fmt.Print("> ")
	response, _ := reader.ReadString('\n')
	response = strings.TrimSpace(strings.ToLower(response))

	if response != "yes" && response != "y" {
		fmt.Println("Signing cancelled.")
		return
	}

	// Sign CSR
	signedCertPEM, err := signCSRWithRootCA(csrPEM)
	if err != nil {
		fmt.Printf("Error signing CSR: %v\n", err)
		return
	}

	// Save node certificate locally for E2E encrypted communication
	nodeID := csr.Subject.CommonName
	saveNodeCertWithLog(nodeID, signedCertPEM)

	// Generate QR code with signed cert
	fmt.Println()
	fmt.Println("Certificate signed! Show this QR code to the node:")
	fmt.Println()

	pairing.GenerateCertQR(signedCertPEM, cliIdentity.RootCertPEM, os.Stdout)

	// Also print the data for manual copy
	fmt.Println()
	fmt.Println("Or copy this data manually:")
	certPayload := &pairing.QRPayload{
		Type:        "cert",
		Fingerprint: pairing.DeriveFingerprint(signedCertPEM),
	}
	certPayload.Cert = string(signedCertPEM)
	certPayload.CACert = string(cliIdentity.RootCertPEM)

	jsonData, _ := json.Marshal(certPayload)
	fmt.Println(string(jsonData))

	fmt.Println()
	fmt.Println("Pairing complete! The node can now scan this QR code.")
}

// signCSRWithRootCA signs a CSR using the CLI's Root CA
func signCSRWithRootCA(csrPEM []byte) ([]byte, error) {
	if cliIdentity == nil || cliIdentity.RootKey == nil {
		return nil, fmt.Errorf("CLI identity not initialized")
	}

	// Parse CSR
	block, _ := pem.Decode(csrPEM)
	if block == nil {
		return nil, fmt.Errorf("invalid CSR PEM")
	}

	csr, err := x509.ParseCertificateRequest(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("failed to parse CSR: %w", err)
	}

	// Verify CSR signature
	if err := csr.CheckSignature(); err != nil {
		return nil, fmt.Errorf("CSR signature invalid: %w", err)
	}

	// Validate public key type - only Ed25519 allowed
	if _, ok := csr.PublicKey.(ed25519.PublicKey); !ok {
		return nil, fmt.Errorf("CSR public key must be Ed25519, got %T", csr.PublicKey)
	}

	// Validate CommonName is present and reasonable
	if csr.Subject.CommonName == "" {
		return nil, fmt.Errorf("CSR CommonName is required")
	}
	if len(csr.Subject.CommonName) > 64 {
		return nil, fmt.Errorf("CSR CommonName too long (max 64 chars)")
	}

	// Reject CSRs with dangerous extension requests
	for _, ext := range csr.Extensions {
		// Basic Constraints OID: 2.5.29.19 - reject if requesting CA:TRUE
		if ext.Id.String() == "2.5.29.19" {
			return nil, fmt.Errorf("CSR requests BasicConstraints extension - not allowed")
		}
	}

	// Parse our Root CA cert
	caBlock, _ := pem.Decode(cliIdentity.RootCertPEM)
	if caBlock == nil {
		return nil, fmt.Errorf("invalid CA cert PEM")
	}

	caCert, err := x509.ParseCertificate(caBlock.Bytes)
	if err != nil {
		return nil, fmt.Errorf("failed to parse CA cert: %w", err)
	}

	// Generate serial number
	serialNumber, err := rand.Int(rand.Reader, new(big.Int).Lsh(big.NewInt(1), 128))
	if err != nil {
		return nil, fmt.Errorf("failed to generate serial: %w", err)
	}

	// Create certificate template
	template := &x509.Certificate{
		SerialNumber: serialNumber,
		Subject:      csr.Subject,
		NotBefore:    time.Now(),
		NotAfter:     time.Now().AddDate(1, 0, 0), // 1 year validity
		KeyUsage:     x509.KeyUsageDigitalSignature | x509.KeyUsageKeyEncipherment,
		ExtKeyUsage:  []x509.ExtKeyUsage{x509.ExtKeyUsageClientAuth},
		DNSNames:     csr.DNSNames,
	}

	// Sign the certificate
	certDER, err := x509.CreateCertificate(rand.Reader, template, caCert, csr.PublicKey, cliIdentity.RootKey)
	if err != nil {
		return nil, fmt.Errorf("failed to create certificate: %w", err)
	}

	// Encode to PEM
	certPEM := pem.EncodeToMemory(&pem.Block{
		Type:  "CERTIFICATE",
		Bytes: certDER,
	})

	return certPEM, nil
}

func truncateStr(s string, maxLen int) string {
	if len(s) <= maxLen {
		return s
	}
	return s[:maxLen-3] + "..."
}

// createCLIClientWithRouting creates a CLIClient with user secret and routing tokens loaded
func createCLIClientWithRouting(cfg *HubConfig) *hubclient.CLIClient {
	client := hubclient.NewCLIClient(cfg.HubAddress, cfg.Token, "cli")

	if cliIdentity != nil {
		client.SetIdentity(cliIdentity.RootKey)
	}
	if cfg.HubCAPEM != "" {
		client.SetTransportCA([]byte(cfg.HubCAPEM))
	}
	if cfg.STUNServer != "" {
		client.SetSTUNServer(cfg.STUNServer)
	}

	// Load user secret for routing token generation
	storage := hubclient.NewStorage(cfg.DataDir)
	if userSecret, err := storage.LoadUserSecret(); err == nil {
		client.SetUserSecret(userSecret)
	}

	// Load routing tokens for known nodes
	if tokens, err := storage.LoadAllRoutingTokens(); err == nil {
		client.LoadRoutingTokens(tokens)
	}

	return client
}

// getOrCreateUserSecret ensures we have a user secret for routing tokens
func getOrCreateUserSecret(cfg *HubConfig) ([]byte, error) {
	storage := hubclient.NewStorage(cfg.DataDir)

	// Try to load existing secret
	if secret, err := storage.LoadUserSecret(); err == nil {
		return secret, nil
	}

	// Generate new secret
	secret, err := routing.GenerateUserSecret()
	if err != nil {
		return nil, err
	}

	// Save it
	if err := storage.SaveUserSecret(secret); err != nil {
		return nil, err
	}

	return secret, nil
}

// saveRoutingToken stores a routing token for a node
func saveRoutingToken(cfg *HubConfig, nodeID, token string) error {
	storage := hubclient.NewStorage(cfg.DataDir)
	return storage.SaveRoutingToken(nodeID, token)
}
