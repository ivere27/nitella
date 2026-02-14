// Package service provides the mobile logic service for Flutter FFI integration.
package service

import (
	"context"
	"crypto/ed25519"
	"crypto/sha256"
	"crypto/tls"
	"crypto/x509"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pb "github.com/ivere27/nitella/pkg/api/local"
	"github.com/ivere27/nitella/pkg/core"
	"github.com/ivere27/nitella/pkg/geoip"
	"github.com/ivere27/nitella/pkg/hub/routing"
	"github.com/ivere27/nitella/pkg/identity"
	"github.com/ivere27/nitella/pkg/p2p"
	"github.com/ivere27/nitella/pkg/pairing"
	"google.golang.org/grpc"
	"google.golang.org/grpc/connectivity"
	"google.golang.org/grpc/credentials"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// Default timeout for Hub RPC operations.
// This prevents FFI calls from blocking indefinitely when Hub is slow/unresponsive.
const defaultHubTimeout = 25 * time.Second

// MobileLogicService implements the FFI interface for the Flutter mobile app.
// It manages identity, nodes, proxies, rules, approvals, and Hub communication.
type MobileLogicService struct {
	pb.UnimplementedMobileLogicServiceServer

	mu sync.RWMutex

	// Configuration
	dataDir   string
	cacheDir  string
	debugMode bool
	startedAt time.Time

	// Goroutine diff tracking (for debug snapshots)
	goroutineDiffMu       sync.Mutex
	goroutineLastSnapshot map[string]int32
	goroutineLastTotal    int64
	goroutineLastAt       time.Time

	// Identity
	identity     *identity.Identity
	identityLock bool // True if identity is locked (key not in memory)

	// Hub connection
	hubAddr       string
	hubConn       *grpc.ClientConn
	mobileClient  pbHub.MobileServiceClient
	authClient    pbHub.AuthServiceClient
	pairingClient pbHub.PairingServiceClient
	hubConnected  bool
	hubTokenProv  *hubTokenProvider // JWT token for authenticated Hub RPCs
	hubUserID     string
	hubTier       string
	hubMaxNodes   int32

	// Hub TLS settings (zero-trust)
	hubCAPEM   []byte // Custom CA PEM for Hub TLS verification
	hubCertPin string // SPKI SHA256 fingerprint for certificate pinning

	// Paired nodes (node_id -> NodeInfo)
	nodes map[string]*pb.NodeInfo

	// Active pairing sessions
	pairingSessions map[string]*pairingSession

	// Active Hub trust challenges (challenge_id -> challenge session)
	hubTrustChallenges map[string]*hubTrustChallengeSession

	// Templates
	templates map[string]*pb.Template

	// Settings
	settings *pb.Settings

	// UI callbacks (for Go -> Dart calls)
	uiCallback UICallback

	// Approval streams
	approvalStreamsMu sync.RWMutex
	approvalStreams   []chan *pb.ApprovalRequest

	// Pending approvals (requestID -> ApprovalRequest)
	pendingApprovals   map[string]*pb.ApprovalRequest
	pendingDecisions   map[string]bool
	pendingApprovalsMu sync.RWMutex

	// Approval decision history (newest first)
	approvalHistory   []*pb.ApprovalHistoryEntry
	approvalHistoryMu sync.RWMutex

	// Connection streams
	connStreamsMu sync.RWMutex
	connStreams   []chan *pb.ConnectionEvent

	// P2P status streams
	p2pStatusStreamsMu sync.RWMutex
	p2pStatusStreams   []chan *pb.P2PStatus

	// Alert stream from Hub (receives approval requests from nodes)
	alertStreamCancel context.CancelFunc

	// Saved Hub JWT for reconnection (preserved across disconnect/reconnect)
	savedHubJWT string

	// FCM token
	fcmToken      string
	fcmDeviceType pb.DeviceType

	// GeoIP manager
	geoManager *geoip.Manager

	// Node public keys cache (nodeID -> ed25519.PublicKey)
	nodePublicKeys map[string]ed25519.PublicKey

	// P2P Transport (CLI/mobile side)
	p2pTransport       *p2p.Transport
	p2pTransportCancel context.CancelFunc

	// Direct node connections (for standalone nitellad without Hub)
	directNodes *directNodeStore

	// Shared business logic controller
	ctrl *core.Controller
}

// hubTokenProvider implements grpc credentials.PerRPCCredentials to inject
// JWT tokens into Hub RPC calls. The token is set after RegisterUser succeeds.
type hubTokenProvider struct {
	mu    sync.RWMutex
	token string
}

func (p *hubTokenProvider) GetRequestMetadata(ctx context.Context, uri ...string) (map[string]string, error) {
	p.mu.RLock()
	defer p.mu.RUnlock()
	if p.token == "" {
		return nil, nil
	}
	return map[string]string{"authorization": "Bearer " + p.token}, nil
}

func (p *hubTokenProvider) RequireTransportSecurity() bool {
	return true
}

func (p *hubTokenProvider) setToken(token string) {
	p.mu.Lock()
	defer p.mu.Unlock()
	p.token = token
}

// UICallback defines the interface for calling back to Flutter UI.
type UICallback interface {
	OnApprovalRequest(req *pb.ApprovalRequest) error
	OnNodeStatusChange(status *pb.NodeStatusChange) error
	OnConnectionEvent(event *pb.ConnectionEvent) error
	OnAlert(alert *pb.Alert) error
	OnToast(msg *pb.ToastMessage) error
}

// pairingSession tracks an active PAKE pairing session.
type pairingSession struct {
	sessionID      string
	pairingCode    string
	nodeName       string
	expiresAt      int64
	exchangeCancel context.CancelFunc
	pakeSession    *pairing.PakeSession // CPace-based PAKE session
	isInitiator    bool                 // True if we started the pairing
	peerPublic     []byte               // Peer's PAKE public value
	sharedSecret   []byte               // Derived shared secret
	exchange       *pairing.ExchangeResult
	offlineCSRPEM  []byte
}

type hubSession struct {
	JWTToken string `json:"jwt_token,omitempty"`
}

// NewMobileLogicService creates a new mobile logic service.
func NewMobileLogicService() *MobileLogicService {
	ctrl := core.New(core.Config{
		P2PMode: common.P2PMode_P2P_MODE_HUB,
	})

	return &MobileLogicService{
		nodes:                 make(map[string]*pb.NodeInfo),
		pairingSessions:       make(map[string]*pairingSession),
		hubTrustChallenges:    make(map[string]*hubTrustChallengeSession),
		templates:             make(map[string]*pb.Template),
		settings:              defaultSettings(),
		startedAt:             time.Now(),
		geoManager:            geoip.NewManager(),
		goroutineLastSnapshot: make(map[string]int32),
		nodePublicKeys:        make(map[string]ed25519.PublicKey),
		pendingApprovals:      make(map[string]*pb.ApprovalRequest),
		pendingDecisions:      make(map[string]bool),
		approvalHistory:       make([]*pb.ApprovalHistoryEntry, 0),
		ctrl:                  ctrl,
	}
}

func isJWTExpired(token string, now time.Time) bool {
	parts := strings.Split(token, ".")
	if len(parts) < 2 {
		return false
	}

	payload, err := base64.RawURLEncoding.DecodeString(parts[1])
	if err != nil {
		return false
	}

	var claims struct {
		Exp int64 `json:"exp"`
	}
	if err := json.Unmarshal(payload, &claims); err != nil {
		return false
	}
	if claims.Exp == 0 {
		return false
	}

	// Small skew to avoid reusing a token right at the edge.
	return now.Add(30 * time.Second).Unix() >= claims.Exp
}

func sanitizeReusableHubToken(token string) string {
	token = strings.TrimSpace(token)
	if token == "" {
		return ""
	}
	if isJWTExpired(token, time.Now()) {
		return ""
	}
	return token
}

// SetUICallback sets the callback for UI notifications.
func (s *MobileLogicService) SetUICallback(cb UICallback) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.uiCallback = cb
}

// RegisterServer registers the service with a gRPC server.
func (s *MobileLogicService) RegisterServer(server *grpc.Server) {
	pb.RegisterMobileLogicServiceServer(server, s)
}

// defaultSettings returns default settings.
func defaultSettings() *pb.Settings {
	return &pb.Settings{
		AutoConnectHub:          false,
		HubInviteCode:           "NITELLA",
		NotificationsEnabled:    true,
		ApprovalNotifications:   true,
		ConnectionNotifications: false,
		AlertNotifications:      true,
		P2PMode:                 common.P2PMode_P2P_MODE_HUB,
		RequireBiometric:        false,
		AutoLockMinutes:         5,
		Theme:                   pb.Theme_THEME_SYSTEM,
		Language:                "en",
		StunServers: []string{
			"stun:stun.l.google.com:19302",
			"stun:stun.nitella.net:3478",
		},
	}
}

// ===========================================================================
// Lifecycle
// ===========================================================================

// Initialize initializes the mobile backend with data directory.
func (s *MobileLogicService) Initialize(ctx context.Context, req *pb.InitializeRequest) (*pb.InitializeResponse, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.dataDir = req.DataDir
	s.cacheDir = req.CacheDir
	s.hubAddr = req.HubAddress
	s.debugMode = req.DebugMode

	// Check if identity exists
	exists := identity.KeyExists(req.DataDir)
	locked := false

	if exists {
		// Check if key is encrypted
		encrypted, err := identity.IsKeyEncrypted(req.DataDir)
		if err != nil {
			return &pb.InitializeResponse{
				Success:        false,
				Error:          fmt.Sprintf("failed to check key encryption: %v", err),
				IdentityExists: true,
			}, nil
		}
		locked = encrypted

		// Try to load identity if not encrypted
		if !encrypted {
			id, err := identity.Load(req.DataDir)
			if err != nil {
				return &pb.InitializeResponse{
					Success:        false,
					Error:          fmt.Sprintf("failed to load identity: %v", err),
					IdentityExists: true,
				}, nil
			}
			s.identity = id
			s.identityLock = false
			s.ctrl.SetIdentity(id)
		} else {
			s.identityLock = true
		}
	}

	// Load paired nodes from storage
	if err := s.loadNodes(); err != nil {
		// Non-fatal, continue
		if s.debugMode {
			log.Printf("warning: failed to load nodes: %v\n", err)
		}
	}

	// Load direct nodes and reconnect them
	if err := s.loadDirectNodes(ctx); err != nil {
		// Non-fatal, continue
		if s.debugMode {
			log.Printf("warning: failed to load direct nodes: %v\n", err)
		}
	}

	// Load settings
	if err := s.loadSettings(); err != nil {
		// Non-fatal, use defaults
		if s.debugMode {
			log.Printf("warning: failed to load settings: %v\n", err)
		}
	}

	// Load persisted Hub session (JWT token for reconnect)
	if err := s.loadHubSession(); err != nil && s.debugMode {
		log.Printf("warning: failed to load hub session: %v\n", err)
	}

	// Load templates
	if err := s.loadTemplates(); err != nil {
		// Non-fatal
		if s.debugMode {
			log.Printf("warning: failed to load templates: %v\n", err)
		}
	}

	// Load approval history
	if err := s.loadApprovalHistory(); err != nil {
		// Non-fatal
		if s.debugMode {
			log.Printf("warning: failed to load approval history: %v\n", err)
		}
	}

	return &pb.InitializeResponse{
		Success:        true,
		IdentityExists: exists,
		IdentityLocked: locked,
	}, nil
}

// Shutdown gracefully shuts down the mobile backend.
func (s *MobileLogicService) Shutdown(ctx context.Context, _ *emptypb.Empty) (*emptypb.Empty, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	// Cancel alert stream goroutines
	if s.alertStreamCancel != nil {
		s.alertStreamCancel()
		s.alertStreamCancel = nil
	}

	// Close P2P transport
	if s.p2pTransportCancel != nil {
		s.p2pTransportCancel()
		s.p2pTransportCancel = nil
	}
	if s.p2pTransport != nil {
		if err := s.p2pTransport.Close(); err != nil && s.debugMode {
			log.Printf("warning: p2p transport close error: %v", err)
		}
		s.p2pTransport = nil
		s.ctrl.SetP2PTransport(nil)
	}

	// Disconnect from Hub
	if s.hubConn != nil {
		s.hubConn.Close()
		s.hubConn = nil
		s.mobileClient = nil
		s.authClient = nil
		s.pairingClient = nil
		s.hubConnected = false
	}

	// Close all direct node connections
	if s.directNodes != nil {
		s.directNodes.closeAll()
	}

	// Clear sensitive data
	s.identity = nil
	s.identityLock = true

	return &emptypb.Empty{}, nil
}

// ===========================================================================
// Helper methods
// ===========================================================================

// loadNodes loads paired nodes from persistent storage.
func (s *MobileLogicService) loadNodes() error {
	// Load node list from identity data directory
	nodeIDs, err := identity.ListPairedNodes(s.dataDir)
	if err != nil {
		return err
	}

	for _, nodeID := range nodeIDs {
		// Load node certificate
		certPEM, err := identity.LoadNodeCert(s.dataDir, nodeID)
		if err != nil {
			continue
		}

		// Extract info from cert
		pubKey, err := identity.LoadNodePublicKey(s.dataDir, nodeID)
		if err != nil {
			continue
		}

		// Load node metadata if available
		nodeName := nodeID
		var nodeTags []string
		metaPath := filepath.Join(s.dataDir, "nodes", nodeID+".json")
		if metaData, err := os.ReadFile(metaPath); err == nil {
			var meta struct {
				Name string   `json:"name"`
				Tags []string `json:"tags,omitempty"`
			}
			if json.Unmarshal(metaData, &meta) == nil {
				if meta.Name != "" {
					nodeName = meta.Name
				}
				nodeTags = meta.Tags
			}
		}

		s.nodes[nodeID] = &pb.NodeInfo{
			NodeId:      nodeID,
			Name:        nodeName,
			Tags:        nodeTags,
			Fingerprint: identity.GenerateFingerprint(pubKey),
			EmojiHash:   identity.GenerateEmojiHash(pubKey),
			Online:      false, // Will be updated when Hub connects
		}
		_ = certPEM
	}

	return nil
}

// loadSettings loads settings from persistent storage.
func (s *MobileLogicService) loadSettings() error {
	settingsPath := filepath.Join(s.dataDir, "settings.json")
	data, err := os.ReadFile(settingsPath)
	if err != nil {
		if os.IsNotExist(err) {
			return nil // No settings file, use defaults
		}
		return err
	}

	// Migrate: if Theme field is a string (old format), convert to enum int
	data = migrateThemeField(data)

	var settings pb.Settings
	if err := json.Unmarshal(data, &settings); err != nil {
		return err
	}
	if len(settings.StunServers) == 0 {
		settings.StunServers = defaultSettings().StunServers
	}
	s.settings = &settings

	// Restore Hub settings from persisted settings
	if settings.HubAddress != "" && s.hubAddr == "" {
		s.hubAddr = settings.HubAddress
	}
	if len(settings.HubCaPem) > 0 {
		s.hubCAPEM = settings.HubCaPem
	}
	if settings.HubCertPin != "" {
		s.hubCertPin = settings.HubCertPin
	}

	return nil
}

// loadHubSession loads persisted Hub session data (JWT token) from disk.
func (s *MobileLogicService) loadHubSession() error {
	sessionPath := filepath.Join(s.dataDir, "hub_session.json")
	data, err := os.ReadFile(sessionPath)
	if err != nil {
		if os.IsNotExist(err) {
			return nil
		}
		return err
	}

	var session hubSession
	if err := json.Unmarshal(data, &session); err != nil {
		return err
	}
	s.savedHubJWT = session.JWTToken
	return nil
}

// saveHubSessionLocked persists Hub session data (JWT token).
// Caller must hold s.mu.
func (s *MobileLogicService) saveHubSessionLocked() error {
	sessionPath := filepath.Join(s.dataDir, "hub_session.json")
	if s.savedHubJWT == "" {
		if err := os.Remove(sessionPath); err != nil && !os.IsNotExist(err) {
			return err
		}
		return nil
	}

	if err := os.MkdirAll(s.dataDir, 0700); err != nil {
		return err
	}
	data, err := json.MarshalIndent(&hubSession{
		JWTToken: s.savedHubJWT,
	}, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(sessionPath, data, 0600)
}

// loadTemplates loads templates from persistent storage.
func (s *MobileLogicService) loadTemplates() error {
	templatesDir := filepath.Join(s.dataDir, "templates")
	entries, err := os.ReadDir(templatesDir)
	if err != nil {
		if os.IsNotExist(err) {
			return nil // No templates directory
		}
		return err
	}

	for _, entry := range entries {
		if entry.IsDir() || filepath.Ext(entry.Name()) != ".json" {
			continue
		}

		data, err := os.ReadFile(filepath.Join(templatesDir, entry.Name()))
		if err != nil {
			continue
		}

		var template pb.Template
		if err := json.Unmarshal(data, &template); err != nil {
			continue
		}
		s.templates[template.TemplateId] = &template
	}
	return nil
}

// requireIdentity returns an error if identity is not available.
func (s *MobileLogicService) requireIdentity() error {
	if s.identity == nil {
		if s.identityLock {
			return fmt.Errorf("identity is locked, please unlock first")
		}
		return fmt.Errorf("no identity found, please create one first")
	}
	return nil
}

// getPrivateKey returns the Ed25519 private key from identity.
func (s *MobileLogicService) getPrivateKey() ed25519.PrivateKey {
	if s.identity == nil {
		return nil
	}
	return s.identity.RootKey
}

// getPublicKey returns the Ed25519 public key from identity.
func (s *MobileLogicService) getPublicKey() ed25519.PublicKey {
	if s.identity == nil || s.identity.RootKey == nil {
		return nil
	}
	return s.identity.RootKey.Public().(ed25519.PublicKey)
}

// notifyApprovalStreams sends an approval request to all active streams.
func (s *MobileLogicService) notifyApprovalStreams(req *pb.ApprovalRequest) {
	s.approvalStreamsMu.RLock()
	defer s.approvalStreamsMu.RUnlock()

	for _, ch := range s.approvalStreams {
		select {
		case ch <- req:
		default:
			// Channel full, skip
		}
	}

	// Also notify UI callback if set (read under main lock for thread safety)
	s.mu.RLock()
	cb := s.uiCallback
	s.mu.RUnlock()
	if cb != nil {
		go cb.OnApprovalRequest(req)
	}
}

// notifyConnectionStreams sends a connection event to all active streams.
func (s *MobileLogicService) notifyConnectionStreams(event *pb.ConnectionEvent) {
	s.connStreamsMu.RLock()
	defer s.connStreamsMu.RUnlock()

	for _, ch := range s.connStreams {
		select {
		case ch <- event:
		default:
			// Channel full, skip
		}
	}

	// Also notify UI callback if set (read under main lock for thread safety)
	s.mu.RLock()
	cb := s.uiCallback
	s.mu.RUnlock()
	if cb != nil {
		go cb.OnConnectionEvent(event)
	}
}

// startAlertStream opens StreamAlerts connections to the Hub for each known node
// and processes incoming alerts (approval requests) in background goroutines.
//
// Hub requires either a NodeId or a routing token in context to identify which
// alerts to stream. Since JWT auth doesn't set routing token in context,
// we must specify NodeId explicitly — one stream per node.
func (s *MobileLogicService) startAlertStream() {
	s.mu.RLock()
	mc := s.mobileClient
	privKey := s.getPrivateKey()
	nodeIDs := make([]string, 0, len(s.nodes))
	for id := range s.nodes {
		nodeIDs = append(nodeIDs, id)
	}
	s.mu.RUnlock()

	if mc == nil || len(nodeIDs) == 0 {
		log.Printf("[AlertStream] Skipped: mc=%v nodes=%d\n", mc != nil, len(nodeIDs))
		return
	}
	log.Printf("[AlertStream] Starting for %d nodes: %v\n", len(nodeIDs), nodeIDs)

	// Cancel existing streams if any
	s.mu.Lock()
	if s.alertStreamCancel != nil {
		s.alertStreamCancel()
	}
	ctx, cancel := context.WithCancel(context.Background())
	s.alertStreamCancel = cancel
	s.mu.Unlock()

	// Start one stream per node with exponential backoff on disconnect
	for _, nodeID := range nodeIDs {
		nodeID := nodeID // capture for goroutine
		go func() {
			backoff := time.Second
			const maxBackoff = 2 * time.Minute

			for {
				stream, err := mc.StreamAlerts(ctx, &pbHub.StreamAlertsRequest{
					NodeId: nodeID,
				})
				if err != nil {
					if ctx.Err() != nil {
						return // context cancelled, stop reconnecting
					}
					log.Printf("[AlertStream] Failed to open stream for node %s: %v (retry in %v)\n", nodeID, err, backoff)
					select {
					case <-ctx.Done():
						return
					case <-time.After(backoff):
					}
					backoff = backoff * 2
					if backoff > maxBackoff {
						backoff = maxBackoff
					}
					continue
				}

				// Connected — reset backoff
				backoff = time.Second
				log.Printf("[AlertStream] Connected for node %s, listening for alerts\n", nodeID)

				for {
					alert, err := stream.Recv()
					if err != nil {
						if ctx.Err() != nil {
							return // context cancelled, stop reconnecting
						}
						log.Printf("[AlertStream] Stream ended for node %s: %v (reconnecting in %v)\n", nodeID, err, backoff)
						break // break inner loop to reconnect
					}
					log.Printf("[AlertStream] Received alert: id=%s node=%s\n", alert.Id, alert.NodeId)
					s.processIncomingAlert(alert, privKey)
				}

				// Wait before reconnecting
				select {
				case <-ctx.Done():
					return
				case <-time.After(backoff):
				}
				backoff = backoff * 2
				if backoff > maxBackoff {
					backoff = maxBackoff
				}
			}
		}()
	}
}

// restartAlertStreamIfReadyLocked restarts Hub alert streaming when a JWT-backed
// Hub session is active and there are paired nodes to subscribe to.
// Caller must hold s.mu.
func (s *MobileLogicService) restartAlertStreamIfReadyLocked() {
	hasToken := false
	if s.hubTokenProv != nil {
		s.hubTokenProv.mu.RLock()
		hasToken = strings.TrimSpace(s.hubTokenProv.token) != ""
		s.hubTokenProv.mu.RUnlock()
	}
	ready := s.mobileClient != nil && len(s.nodes) > 0 && hasToken
	if !ready {
		if s.alertStreamCancel != nil {
			s.alertStreamCancel()
			s.alertStreamCancel = nil
		}
		return
	}

	go s.startAlertStream()
}

// sendToast sends a toast message to the UI.
func (s *MobileLogicService) sendToast(message string, toastType pb.ToastType, durationMs int32) {
	s.mu.RLock()
	cb := s.uiCallback
	s.mu.RUnlock()
	if cb != nil {
		go cb.OnToast(&pb.ToastMessage{
			Message:    message,
			Type:       toastType,
			DurationMs: durationMs,
		})
	}
}

// ===========================================================================
// Hub Status
// ===========================================================================

// GetHubStatus returns the current Hub connection status.
func (s *MobileLogicService) GetHubStatus(ctx context.Context, _ *emptypb.Empty) (*pb.HubStatus, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	return &pb.HubStatus{
		Connected:  s.hubConnected,
		HubAddress: s.hubAddr,
		UserId:     s.hubUserID,
		Tier:       s.hubTier,
		MaxNodes:   s.hubMaxNodes,
	}, nil
}

// GetHubOverview returns aggregated Hub + node summary for thin clients.
func (s *MobileLogicService) GetHubOverview(ctx context.Context, _ *emptypb.Empty) (*pb.HubOverview, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	var totalNodes, onlineNodes, pinnedNodes, totalProxies int32
	var totalActiveConnections int64

	for _, node := range s.nodes {
		if node == nil {
			continue
		}
		totalNodes++
		if node.GetOnline() {
			onlineNodes++
		}
		if node.GetPinned() {
			pinnedNodes++
		}
		totalProxies += node.GetProxyCount()
		if node.GetMetrics() != nil {
			totalActiveConnections += node.GetMetrics().GetActiveConnections()
		}
	}

	return &pb.HubOverview{
		HubConnected:           s.hubConnected,
		HubAddress:             s.hubAddr,
		UserId:                 s.hubUserID,
		Tier:                   s.hubTier,
		MaxNodes:               s.hubMaxNodes,
		TotalNodes:             totalNodes,
		OnlineNodes:            onlineNodes,
		PinnedNodes:            pinnedNodes,
		TotalProxies:           totalProxies,
		TotalActiveConnections: totalActiveConnections,
	}, nil
}

// GetHubDashboardSnapshot returns hub overview plus node lists for dashboard surfaces.
func (s *MobileLogicService) GetHubDashboardSnapshot(ctx context.Context, req *pb.GetHubDashboardSnapshotRequest) (*pb.HubDashboardSnapshot, error) {
	if req == nil {
		req = &pb.GetHubDashboardSnapshotRequest{}
	}
	s.refreshHubNodeStatuses(ctx)

	filter := strings.ToLower(strings.TrimSpace(req.GetNodeFilter()))
	if filter == "" {
		filter = "all"
	}

	s.mu.RLock()
	defer s.mu.RUnlock()

	nodes := make([]*pb.NodeInfo, 0, len(s.nodes))
	pinned := make([]*pb.NodeInfo, 0, len(s.nodes))
	var totalNodes, onlineNodes, pinnedNodes, totalProxies int32
	var totalActiveConnections int64

	for _, node := range s.nodes {
		if node == nil {
			continue
		}

		totalNodes++
		if node.GetOnline() {
			onlineNodes++
		}
		if node.GetPinned() {
			pinnedNodes++
		}
		totalProxies += node.GetProxyCount()
		if node.GetMetrics() != nil {
			totalActiveConnections += node.GetMetrics().GetActiveConnections()
		}

		if filter == "online" && !node.GetOnline() {
			continue
		}
		if filter == "offline" && node.GetOnline() {
			continue
		}

		redacted := redactNodeInfo(node)
		nodes = append(nodes, redacted)
		if redacted.GetPinned() {
			pinned = append(pinned, redacted)
		}
	}

	return &pb.HubDashboardSnapshot{
		Overview: &pb.HubOverview{
			HubConnected:           s.hubConnected,
			HubAddress:             s.hubAddr,
			UserId:                 s.hubUserID,
			Tier:                   s.hubTier,
			MaxNodes:               s.hubMaxNodes,
			TotalNodes:             totalNodes,
			OnlineNodes:            onlineNodes,
			PinnedNodes:            pinnedNodes,
			TotalProxies:           totalProxies,
			TotalActiveConnections: totalActiveConnections,
		},
		Nodes:       nodes,
		PinnedNodes: pinned,
	}, nil
}

// refreshHubNodeStatuses updates cached node online/last_seen fields from Hub.
// It does best-effort refresh and silently falls back to cached values on errors.
func (s *MobileLogicService) refreshHubNodeStatuses(ctx context.Context) {
	if ctx == nil {
		ctx = context.Background()
	}

	s.mu.RLock()
	mobileClient := s.mobileClient
	rootKey := ed25519.PrivateKey(nil)
	if s.identity != nil && len(s.identity.RootKey) > 0 {
		rootKey = append(ed25519.PrivateKey(nil), s.identity.RootKey...)
	}
	nodeIDs := make([]string, 0, len(s.nodes))
	for nodeID := range s.nodes {
		nodeIDs = append(nodeIDs, nodeID)
	}
	debugMode := s.debugMode
	s.mu.RUnlock()

	if mobileClient == nil || len(rootKey) == 0 || len(nodeIDs) == 0 {
		return
	}

	routingTokens := make([]string, 0, len(nodeIDs))
	for _, nodeID := range nodeIDs {
		routingTokens = append(routingTokens, routing.GenerateRoutingToken(nodeID, rootKey))
	}

	hubCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	resp, err := mobileClient.ListNodes(hubCtx, &pbHub.ListNodesRequest{
		RoutingTokens: routingTokens,
	})
	if err != nil {
		if debugMode {
			log.Printf("warning: failed to refresh node statuses from hub: %v\n", err)
		}
		return
	}
	if resp == nil {
		return
	}

	nodesByID := make(map[string]*pbHub.Node, len(resp.Nodes))
	for _, node := range resp.Nodes {
		if node == nil {
			continue
		}
		nodeID := strings.TrimSpace(node.GetId())
		if nodeID == "" {
			continue
		}
		nodesByID[nodeID] = node
	}

	s.mu.Lock()
	defer s.mu.Unlock()
	for nodeID, local := range s.nodes {
		if local == nil {
			continue
		}
		hubNode, ok := nodesByID[nodeID]
		if !ok {
			continue
		}
		local.Online = hubNode.GetStatus() == pbHub.NodeStatus_NODE_STATUS_ONLINE
		if hubNode.GetLastSeen() != nil {
			local.LastSeen = hubNode.GetLastSeen()
		}
	}
}

// buildHubTLSConfig creates a TLS configuration for Hub connection with proper
// certificate validation. Supports custom CA and SPKI certificate pinning.
func (s *MobileLogicService) buildHubTLSConfig(caPEM []byte, certPin string) *tls.Config {
	tlsConfig := &tls.Config{
		MinVersion: tls.VersionTLS13,
	}

	// Use custom CA if provided
	if len(caPEM) > 0 {
		rootCAs := x509.NewCertPool()
		if rootCAs.AppendCertsFromPEM(caPEM) {
			tlsConfig.RootCAs = rootCAs
		}
	}

	// Certificate pinning via SPKI SHA256 fingerprint
	if certPin != "" {
		pin := strings.ReplaceAll(strings.ToLower(certPin), ":", "")
		tlsConfig.VerifyConnection = func(cs tls.ConnectionState) error {
			if len(cs.PeerCertificates) == 0 {
				return fmt.Errorf("no peer certificates presented")
			}
			leaf := cs.PeerCertificates[0]
			hash := sha256.Sum256(leaf.RawSubjectPublicKeyInfo)
			fingerprint := hex.EncodeToString(hash[:])
			if fingerprint != pin {
				log.Printf("certificate pinning mismatch: expected %s, got %s", pin, fingerprint)
				return fmt.Errorf("certificate verification failed")
			}
			return nil
		}
	}

	return tlsConfig
}

// FetchHubCA probes a Hub server to fetch its CA certificate for TOFU verification.
// Uses the shared core.ProbeHubCA to connect with InsecureSkipVerify on an isolated
// connection, then returns the root CA for the user to verify via emoji hash / fingerprint.
func (s *MobileLogicService) FetchHubCA(ctx context.Context, req *pb.FetchHubCARequest) (*pb.FetchHubCAResponse, error) {
	hubAddr := req.HubAddress
	if hubAddr == "" {
		return &pb.FetchHubCAResponse{
			Success: false,
			Error:   "hub address not specified",
		}, nil
	}

	caInfo, err := core.ProbeHubCA(hubAddr)
	if err != nil {
		return &pb.FetchHubCAResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to probe hub: %v", err),
		}, nil
	}

	return &pb.FetchHubCAResponse{
		Success:     true,
		CaPem:       caInfo.CaPEM,
		Fingerprint: caInfo.Fingerprint,
		EmojiHash:   caInfo.EmojiHash,
		Subject:     caInfo.Subject,
		Expires:     caInfo.Expires,
	}, nil
}

// ConnectToHub connects to the Hub server.
func (s *MobileLogicService) ConnectToHub(ctx context.Context, req *pb.ConnectToHubRequest) (*pb.ConnectToHubResponse, error) {
	// Check preconditions with read lock
	s.mu.RLock()
	if err := s.requireIdentity(); err != nil {
		s.mu.RUnlock()
		return &pb.ConnectToHubResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}

	hubAddr := req.HubAddress
	if hubAddr == "" {
		hubAddr = s.hubAddr
	}

	// Use request-level TLS settings, fall back to stored settings
	caPEM := req.HubCaPem
	if len(caPEM) == 0 {
		caPEM = s.hubCAPEM
	}
	certPin := req.HubCertPin
	if certPin == "" {
		certPin = s.hubCertPin
	}
	s.mu.RUnlock()

	if hubAddr == "" {
		return &pb.ConnectToHubResponse{
			Success: false,
			Error:   "hub address not specified",
		}, nil
	}

	// Preserve existing JWT token across reconnections.
	// Priority: request token > existing provider token > saved JWT
	s.mu.RLock()
	existingToken := ""
	if req.Token != "" {
		existingToken = req.Token
	} else if s.hubTokenProv != nil {
		s.hubTokenProv.mu.RLock()
		existingToken = s.hubTokenProv.token
		s.hubTokenProv.mu.RUnlock()
	} else if s.savedHubJWT != "" {
		existingToken = s.savedHubJWT
	}
	s.mu.RUnlock()
	existingToken = sanitizeReusableHubToken(existingToken)

	// Create gRPC connection with proper TLS validation (lock NOT held during network call)
	tlsConfig := s.buildHubTLSConfig(caPEM, certPin)
	tokenProv := &hubTokenProvider{token: existingToken}
	dialCtx, cancel := context.WithTimeout(ctx, defaultHubTimeout)
	defer cancel()
	conn, err := grpc.DialContext(dialCtx, hubAddr,
		grpc.WithTransportCredentials(credentials.NewTLS(tlsConfig)),
		grpc.WithPerRPCCredentials(tokenProv),
	)
	if err != nil {
		return &pb.ConnectToHubResponse{
			Success: false,
			Error:   fmt.Sprintf("connection failed: %v", err),
		}, nil
	}

	// Force the TLS handshake by triggering a connection attempt and waiting for
	// it to reach Ready or fail. TLS failures (e.g. unknown CA) cause
	// TransientFailure within milliseconds, so this returns fast on CA errors.
	conn.Connect()
	checkCtx, checkCancel := context.WithTimeout(ctx, 10*time.Second)
	defer checkCancel()
	for {
		state := conn.GetState()
		if state == connectivity.Ready {
			break
		}
		if state == connectivity.TransientFailure {
			conn.Close()
			return &pb.ConnectToHubResponse{
				Success: false,
				Error:   "connection failed: transport: authentication handshake failed (certificate may not be trusted)",
			}, nil
		}
		if !conn.WaitForStateChange(checkCtx, state) {
			// Timeout waiting for connection
			conn.Close()
			return &pb.ConnectToHubResponse{
				Success: false,
				Error:   "connection timed out",
			}, nil
		}
	}

	// Acquire write lock only for state updates
	s.mu.Lock()
	defer s.mu.Unlock()

	// Close existing connection if any
	if s.hubConn != nil {
		s.hubConn.Close()
	}

	s.hubConn = conn
	s.mobileClient = pbHub.NewMobileServiceClient(conn)
	s.authClient = pbHub.NewAuthServiceClient(conn)
	s.pairingClient = pbHub.NewPairingServiceClient(conn)
	s.hubConnected = true
	s.hubAddr = hubAddr
	s.hubTokenProv = tokenProv

	// Wire Hub connection to shared Controller
	s.ctrl.SetHubConnection(conn)

	if tokenProv.token != "" {
		s.savedHubJWT = tokenProv.token
		if err := s.saveHubSessionLocked(); err != nil && s.debugMode {
			log.Printf("warning: failed to persist hub session: %v\n", err)
		}
	}

	// Store TLS settings for reconnect
	if len(caPEM) > 0 {
		s.hubCAPEM = caPEM
	}
	if certPin != "" {
		s.hubCertPin = certPin
	}

	// Persist Hub address and TLS settings to settings.json
	// This is the root fix: loadSettings() restores hubCAPEM/hubCertPin,
	// but previously hub_address was never persisted, so reconnect on restart failed.
	s.settings.HubAddress = hubAddr
	if len(caPEM) > 0 {
		s.settings.HubCaPem = caPEM
	}
	if certPin != "" {
		s.settings.HubCertPin = certPin
	}
	if err := s.saveSettings(); err != nil {
		if s.debugMode {
			log.Printf("warning: failed to persist hub settings: %v\n", err)
		}
	}

	// Initialize P2P transport only if we already have a JWT token (reconnect scenario).
	// On first connect, P2P will be initialized after RegisterUser sets the token.
	if s.identity != nil && !s.identityLock && tokenProv.token != "" {
		s.initP2PTransportLocked()
	}
	// Existing registered sessions reconnect with JWT and skip RegisterUser.
	// Ensure alert streaming is active in that path as well.
	s.restartAlertStreamIfReadyLocked()

	return &pb.ConnectToHubResponse{Success: true}, nil
}

// DisconnectFromHub disconnects from the Hub server.
func (s *MobileLogicService) DisconnectFromHub(ctx context.Context, _ *emptypb.Empty) (*emptypb.Empty, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	// Cancel alert stream goroutine
	if s.alertStreamCancel != nil {
		s.alertStreamCancel()
		s.alertStreamCancel = nil
	}

	// Stop P2P signaling and transport
	if s.p2pTransportCancel != nil {
		s.p2pTransportCancel()
		s.p2pTransportCancel = nil
	}
	if s.p2pTransport != nil {
		if err := s.p2pTransport.Close(); err != nil && s.debugMode {
			log.Printf("warning: p2p transport close error: %v", err)
		}
		s.p2pTransport = nil
		s.ctrl.SetP2PTransport(nil)
	}

	// Save JWT before clearing provider so reconnect can reuse it
	if s.hubTokenProv != nil {
		s.hubTokenProv.mu.RLock()
		if s.hubTokenProv.token != "" {
			s.savedHubJWT = s.hubTokenProv.token
		}
		s.hubTokenProv.mu.RUnlock()
	}
	if err := s.saveHubSessionLocked(); err != nil && s.debugMode {
		log.Printf("warning: failed to persist hub session: %v\n", err)
	}

	if s.hubConn != nil {
		s.hubConn.Close()
		s.hubConn = nil
		s.mobileClient = nil
		s.authClient = nil
		s.pairingClient = nil
	}
	s.hubConnected = false
	s.hubTokenProv = nil

	return &emptypb.Empty{}, nil
}

// reconnectHub reconnects to the Hub server with auto-retry.
// Safe to call without holding locks - manages its own locking.
func (s *MobileLogicService) reconnectHub(ctx context.Context) {
	// Get required data under read lock
	s.mu.RLock()
	hubAddr := s.hubAddr
	hasIdentity := s.identity != nil
	debugMode := s.debugMode
	caPEM := s.hubCAPEM
	certPin := s.hubCertPin
	existingToken := ""
	if s.hubTokenProv != nil {
		s.hubTokenProv.mu.RLock()
		existingToken = s.hubTokenProv.token
		s.hubTokenProv.mu.RUnlock()
	}
	s.mu.RUnlock()
	existingToken = sanitizeReusableHubToken(existingToken)

	if hubAddr == "" || !hasIdentity {
		return
	}

	// Create gRPC connection with proper TLS validation (lock NOT held during network call)
	tlsConfig := s.buildHubTLSConfig(caPEM, certPin)
	tokenProv := &hubTokenProvider{token: existingToken}
	dialCtx, cancel := context.WithTimeout(ctx, defaultHubTimeout)
	defer cancel()
	conn, err := grpc.DialContext(dialCtx, hubAddr,
		grpc.WithTransportCredentials(credentials.NewTLS(tlsConfig)),
		grpc.WithPerRPCCredentials(tokenProv),
	)
	if err != nil {
		if debugMode {
			log.Printf("auto-reconnect failed: %v\n", err)
		}
		return
	}

	// Acquire write lock for state updates
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.hubConn != nil {
		s.hubConn.Close()
	}

	s.hubConn = conn
	s.mobileClient = pbHub.NewMobileServiceClient(conn)
	s.authClient = pbHub.NewAuthServiceClient(conn)
	s.pairingClient = pbHub.NewPairingServiceClient(conn)
	s.hubConnected = true
	s.hubTokenProv = tokenProv

	// Re-initialize P2P transport if identity is available
	if s.identity != nil && !s.identityLock {
		s.initP2PTransportLocked()
	}

	s.restartAlertStreamIfReadyLocked()
}

// RegisterUser registers the user with Hub.
func (s *MobileLogicService) RegisterUser(ctx context.Context, req *pb.RegisterUserRequest) (*pb.RegisterUserResponse, error) {
	// Acquire lock briefly to get required data, then release before network call
	s.mu.RLock()
	if err := s.requireIdentity(); err != nil {
		s.mu.RUnlock()
		return &pb.RegisterUserResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}

	authClient := s.authClient
	if authClient == nil {
		s.mu.RUnlock()
		return &pb.RegisterUserResponse{
			Success: false,
			Error:   "not connected to Hub",
		}, nil
	}

	// Copy data needed for the call
	rootCertPEM := string(s.identity.RootCertPEM)
	s.mu.RUnlock()

	// Register user via AuthService with timeout (lock NOT held during network call)
	regCtx, cancel := context.WithTimeout(ctx, defaultHubTimeout)
	defer cancel()

	// Default invite code if missing
	inviteCode := req.InviteCode
	if inviteCode == "" {
		inviteCode = "NITELLA"
	}
	biometricPublicKey := append([]byte(nil), req.GetBiometricPublicKey()...)

	resp, err := authClient.RegisterUser(regCtx, &pbHub.RegisterUserRequest{
		RootCertPem:        rootCertPEM,
		InviteCode:         inviteCode,
		BiometricPublicKey: biometricPublicKey,
	})
	if err != nil {
		return &pb.RegisterUserResponse{
			Success: false,
			Error:   fmt.Sprintf("registration failed: %v", err),
		}, nil
	}

	// Store JWT token for authenticated Hub RPCs (MobileService requires JWT)
	if resp.JwtToken != "" {
		s.mu.RLock()
		tp := s.hubTokenProv
		s.mu.RUnlock()
		if tp != nil {
			tp.setToken(resp.JwtToken)
		}
		s.mu.Lock()
		s.savedHubJWT = resp.JwtToken
		if err := s.saveHubSessionLocked(); err != nil && s.debugMode {
			log.Printf("warning: failed to persist hub session: %v\n", err)
		}
		s.mu.Unlock()
		// Start alert stream now that we have JWT auth
		go s.startAlertStream()
		// Initialize P2P transport now that we have JWT auth for StreamSignaling
		s.mu.Lock()
		if s.identity != nil && !s.identityLock {
			s.initP2PTransportLocked()
		}
		s.mu.Unlock()
	}

	s.mu.Lock()
	s.hubUserID = resp.UserId
	s.hubTier = resp.Tier
	s.hubMaxNodes = resp.MaxNodes
	s.mu.Unlock()

	return &pb.RegisterUserResponse{
		Success:  true,
		UserId:   resp.UserId,
		Tier:     resp.Tier,
		MaxNodes: resp.MaxNodes,
		JwtToken: resp.JwtToken,
	}, nil
}

// sendCommand sends an encrypted command to a node via the shared core.Controller.
// This delegates to ctrl.SendCommand() which handles P2P/Hub routing and E2E encryption.
func (s *MobileLogicService) sendCommand(ctx context.Context, nodeID string, cmdType pbHub.CommandType, payload []byte) (*pbHub.CommandResult, error) {
	// Ensure node public key is cached in the controller
	if s.ctrl.GetNodePublicKey(nodeID) == nil {
		if pk := s.getNodePublicKey(nodeID); pk != nil {
			s.ctrl.RegisterNodeKey(nodeID, pk)
		}
	}

	// Update P2P mode from settings
	s.mu.RLock()
	p2pMode := s.settings.GetP2PMode()
	s.mu.RUnlock()
	s.ctrl.SetP2PMode(p2pMode)

	return s.ctrl.SendCommand(ctx, nodeID, cmdType, payload)
}

// getRoutingToken generates a routing token for zero-trust node identification.
// Thread-safe: acquires s.mu internally.
func (s *MobileLogicService) getRoutingToken(nodeID string) string {
	s.mu.RLock()
	id := s.identity
	s.mu.RUnlock()
	if id == nil || id.RootKey == nil {
		return ""
	}
	return routing.GenerateRoutingToken(nodeID, id.RootKey)
}

// LookupIP looks up geolocation for an IP address.
func (s *MobileLogicService) LookupIP(ctx context.Context, req *pb.LookupIPRequest) (*pb.LookupIPResponse, error) {
	if s.geoManager == nil {
		return &pb.LookupIPResponse{Cached: false}, nil
	}

	info, err := s.geoManager.Lookup(ctx, req.Ip)
	if err != nil {
		return &pb.LookupIPResponse{Cached: false}, nil
	}

	return &pb.LookupIPResponse{
		Geo:    info,
		Cached: info.Source == "cache-l1" || info.Source == "cache-l2",
	}, nil
}

// GetIdentity returns the current identity info without re-reading locks.
func (s *MobileLogicService) buildIdentityInfo() *pb.IdentityInfo {
	if s.identity == nil {
		return &pb.IdentityInfo{
			Exists: identity.KeyExists(s.dataDir),
			Locked: s.identityLock,
		}
	}

	var createdAt *timestamppb.Timestamp
	if s.identity.RootCert != nil && !s.identity.RootCert.NotBefore.IsZero() {
		createdAt = timestamppb.New(s.identity.RootCert.NotBefore)
	}

	return &pb.IdentityInfo{
		Exists:      true,
		Locked:      false,
		Fingerprint: s.identity.Fingerprint,
		EmojiHash:   s.identity.EmojiHash,
		RootCertPem: string(s.identity.RootCertPEM),
		CreatedAt:   createdAt,
		PairedNodes: int32(len(s.nodes)),
	}
}

// getNodePublicKeyLocked returns the cached public key for a node, or loads it from storage.
// Caller MUST hold write lock.
func (s *MobileLogicService) getNodePublicKeyLocked(nodeID string) ed25519.PublicKey {
	pk, ok := s.nodePublicKeys[nodeID]
	if ok {
		return pk
	}

	// Try to load from cert
	pk, err := identity.LoadNodePublicKey(s.dataDir, nodeID)
	if err != nil {
		return nil
	}

	// Cache it
	s.nodePublicKeys[nodeID] = pk
	return pk
}

// getNodePublicKey returns the cached public key for a node, or loads it from storage.
// Thread-safe: acquires s.mu internally.
func (s *MobileLogicService) getNodePublicKey(nodeID string) ed25519.PublicKey {
	s.mu.RLock()
	pk, ok := s.nodePublicKeys[nodeID]
	dataDir := s.dataDir
	s.mu.RUnlock()
	if ok {
		return pk
	}

	// Try to load from cert (outside lock — disk I/O)
	pk, err := identity.LoadNodePublicKey(dataDir, nodeID)
	if err != nil {
		return nil
	}

	// Cache it under write lock
	s.mu.Lock()
	s.nodePublicKeys[nodeID] = pk
	s.mu.Unlock()
	return pk
}

// migrateThemeField converts old string-based Theme field to enum int in raw JSON.
// Old format: "theme":"dark" -> New format: "theme":2
func migrateThemeField(data []byte) []byte {
	var raw map[string]interface{}
	if json.Unmarshal(data, &raw) != nil {
		return data
	}
	if theme, ok := raw["theme"]; ok {
		if themeStr, ok := theme.(string); ok {
			themeMap := map[string]int{
				"light":  1,
				"dark":   2,
				"system": 3,
			}
			if enumVal, found := themeMap[strings.ToLower(themeStr)]; found {
				raw["theme"] = enumVal
				if migrated, err := json.Marshal(raw); err == nil {
					return migrated
				}
			}
		}
	}
	return data
}

// saveSettings persists settings to disk.
func (s *MobileLogicService) saveSettings() error {
	if s.settings == nil {
		return nil
	}

	data, err := json.MarshalIndent(s.settings, "", "  ")
	if err != nil {
		return err
	}

	settingsPath := filepath.Join(s.dataDir, "settings.json")
	return os.WriteFile(settingsPath, data, 0600)
}

// saveTemplate persists a template to disk.
func (s *MobileLogicService) saveTemplate(template *pb.Template) error {
	templatesDir := filepath.Join(s.dataDir, "templates")
	if err := os.MkdirAll(templatesDir, 0700); err != nil {
		return err
	}

	data, err := json.MarshalIndent(template, "", "  ")
	if err != nil {
		return err
	}

	templatePath := filepath.Join(templatesDir, template.TemplateId+".json")
	return os.WriteFile(templatePath, data, 0600)
}

// deleteTemplateFile removes a template file from disk.
func (s *MobileLogicService) deleteTemplateFile(templateID string) error {
	templatePath := filepath.Join(s.dataDir, "templates", templateID+".json")
	return os.Remove(templatePath)
}

// initP2PTransportLocked initializes the P2P transport.
// Caller MUST hold write lock.
func (s *MobileLogicService) initP2PTransportLocked() {
	if s.identity == nil || s.mobileClient == nil {
		return
	}

	// Close existing transport if any
	if s.p2pTransportCancel != nil {
		s.p2pTransportCancel()
		s.p2pTransportCancel = nil
	}
	if s.p2pTransport != nil {
		if err := s.p2pTransport.Close(); err != nil && s.debugMode {
			log.Printf("warning: p2p transport close error: %v", err)
		}
		s.ctrl.SetP2PTransport(nil)
	}

	// Create new transport
	t := p2p.NewTransport(s.identity.Fingerprint, s.mobileClient)
	if len(s.settings.GetStunServers()) > 0 {
		t.SetSTUNServer(s.settings.GetStunServers()[0])
	}
	t.SetIdentity(s.identity.RootKey)
	if err := t.SetCertificates(s.identity.RootCertPEM, s.identity.RootCertPEM); err != nil {
		if s.debugMode {
			log.Printf("failed to set P2P certificates: %v\n", err)
		}
		return
	}

	// Set handlers
	t.SetPeerStatusHandler(s.handleP2PPeerStatus)
	t.SetApprovalRequestHandler(s.handleP2PApprovalRequest)

	// Register known node keys
	for nodeID := range s.nodes {
		if pk := s.getNodePublicKeyLocked(nodeID); pk != nil {
			t.RegisterNodeKey(nodeID, pk)
		}
	}

	// Start signaling
	signalCtx, signalCancel := context.WithCancel(context.Background())
	if err := t.StartSignaling(signalCtx); err != nil {
		signalCancel()
		if s.debugMode {
			log.Printf("failed to start P2P signaling: %v\n", err)
		}
		return
	}

	s.p2pTransport = t
	s.p2pTransportCancel = signalCancel
	s.ctrl.SetP2PTransport(t)

	// Attempt to connect to pinned/active nodes
	for nodeID, node := range s.nodes {
		if node.Pinned {
			go t.Connect(nodeID)
		}
	}
}

// handleP2PPeerStatus handles P2P connection status changes.
func (s *MobileLogicService) handleP2PPeerStatus(nodeID string, connected bool) {
	s.mu.Lock()
	node, exists := s.nodes[nodeID]
	if exists {
		node.Online = connected
		if connected {
			node.LastSeen = timestamppb.Now()
		}
	}
	callback := s.uiCallback
	// Notify P2P status streams while holding the lock (needed for buildP2PStatusLocked)
	s.notifyP2PStatusStreamsLocked()
	s.mu.Unlock()

	// Notify UI (outside lock to avoid blocking)
	if callback != nil && exists {
		callback.OnNodeStatusChange(&pb.NodeStatusChange{
			NodeId:    nodeID,
			Name:      node.Name,
			Online:    connected,
			Timestamp: timestamppb.Now(),
		})
	}
}

// handleP2PApprovalRequest converts a P2P approval request to a local
// ApprovalRequest and pushes it through the same approval pipeline as Hub alerts.
func (s *MobileLogicService) handleP2PApprovalRequest(nodeID string, req *p2p.ApprovalRequest) {
	compositeID := nodeID + ":" + req.RequestID

	approvalReq := &pb.ApprovalRequest{
		RequestId: compositeID,
		NodeId:    nodeID,
		SourceIp:  req.SourceIP,
		DestAddr:  req.DestAddr,
		ProxyId:   req.ProxyID,
		Timestamp: timestamppb.Now(),
	}

	// Add geo info if available
	if req.GeoCountry != "" || req.GeoCity != "" || req.GeoISP != "" {
		approvalReq.Geo = &common.GeoInfo{
			Country: req.GeoCountry,
			City:    req.GeoCity,
			Isp:     req.GeoISP,
		}
	}

	s.handleApprovalRequest(approvalReq)
}
