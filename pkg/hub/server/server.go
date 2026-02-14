package server

import (
	"bytes"
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/tls"
	"crypto/x509"
	"encoding/hex"
	"encoding/pem"
	"fmt"
	"log"
	"math/big"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/google/uuid"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/peer"
	"google.golang.org/grpc/status"
	"gopkg.in/yaml.v3"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/hub"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/ivere27/nitella/pkg/hub/auth"
	"github.com/ivere27/nitella/pkg/hub/certmanager"
	"github.com/ivere27/nitella/pkg/hub/firebase"
	"github.com/ivere27/nitella/pkg/hub/model"
	"github.com/ivere27/nitella/pkg/hub/ratelimit"
	"github.com/ivere27/nitella/pkg/hub/store"
	"github.com/ivere27/nitella/pkg/tier"
)

// Constants for rate limiting and timeouts
const (
	// GlobalPairingRateLimit is the maximum pairing requests per minute globally
	GlobalPairingRateLimit = 100

	// PendingAlertExpiry is how long pending alerts are kept before expiring
	PendingAlertExpiry = 5 * time.Minute

	// MaxGlobalPendingAlerts is the maximum pending alerts across all routing tokens.
	// This prevents memory exhaustion from distributed DoS attacks (many users/tokens).
	// With ~1KB per alert, 100K alerts = ~100MB memory budget.
	// Sized for a Hub handling ~50K nodes with 2 pending alerts each on average.
	MaxGlobalPendingAlerts = 100000
)

// Context key types to avoid collisions
type contextKey string

const (
	ctxKeyNodeID       contextKey = "node_id"
	ctxKeyUserID       contextKey = "user_id"
	ctxKeyRole         contextKey = "role"
	ctxKeyRoutingToken contextKey = "routing_token"
)

// generateCode generates a secure registration code
func generateCode() string {
	const chars = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ"
	b := make([]byte, 8)
	for i := range b {
		n, err := rand.Int(rand.Reader, big.NewInt(int64(len(chars))))
		if err != nil {
			// Intentional panic: crypto/rand failure indicates system entropy exhaustion
			// or critical OS-level issue. Server cannot operate securely in this state.
			panic("crypto/rand failed: " + err.Error())
		}
		b[i] = chars[n.Int64()]
	}
	return string(b[:4]) + "-" + string(b[4:])
}

// HubServer manages state and provides gRPC service implementations
type HubServer struct {
	store             store.Store
	firebase          *firebase.Service
	tokenManager      *auth.TokenManager
	adminTokenManager *auth.TokenManager
	tierConfig        *tier.Config
	certMgr           *certmanager.CertManager

	httpClient *http.Client

	// Pairing rate limiting per IP
	pairingRateLimit map[string]time.Time
	pairingRateMu    sync.RWMutex

	// Global pairing rate limit
	globalPairingCount int
	globalPairingReset time.Time

	// User streams (sharded for scalability)
	userStreams   map[string]map[chan *common.Alert]bool
	userStreamsMu sync.RWMutex

	// Pairing Channels
	pairingChs map[string]chan string
	pairingMu  sync.RWMutex

	// Command Responses
	commandResp   map[string]chan *pb.CommandResponse
	commandRespMu sync.RWMutex

	// Node Command Streams (for forwarding commands to nodes)
	nodeCommandChans map[string]chan *pb.Command
	nodeCommandMu    sync.RWMutex

	// Node Metrics Streams
	nodeMetricStreams map[string]chan *pb.EncryptedMetrics
	nodeMetricsMu     sync.RWMutex

	// Node Log Streams (for real-time log forwarding)
	nodeLogStreams map[string]chan *pb.EncryptedLogEntry
	nodeLogsMu     sync.RWMutex

	// Signaling Streams
	nodeSignalingStreams   map[string]chan *pb.SignalMessage
	nodeSignalingMu        sync.RWMutex
	mobileSignalingStreams map[string]chan *pb.SignalMessage
	mobileSignalingMu      sync.RWMutex

	// Pending Approval Alerts (alertID -> PendingAlert)
	// Used to route approval decisions back to the originating node
	pendingAlerts   map[string]*PendingAlert
	pendingAlertsMu sync.RWMutex

	// Registration broadcaster
	broadcaster *RegistrationBroadcaster

	// Service implementations
	Mobile  *MobileServer
	Node    *NodeServer
	Auth    *AuthServer
	Pairing *PairingServer
	Admin   *AdminServer
}

// PendingAlert tracks an alert awaiting approval decision
type PendingAlert struct {
	NodeID       string
	RoutingToken string
	Alert        *common.Alert
	CreatedAt    time.Time
}

// RegistrationBroadcaster handles async notifications for registration approvals
type RegistrationBroadcaster struct {
	mu          sync.RWMutex
	subscribers map[string][]chan string
}

func NewRegistrationBroadcaster() *RegistrationBroadcaster {
	return &RegistrationBroadcaster{
		subscribers: make(map[string][]chan string),
	}
}

func (rb *RegistrationBroadcaster) Subscribe(code string) chan string {
	rb.mu.Lock()
	defer rb.mu.Unlock()
	ch := make(chan string, 1)
	rb.subscribers[code] = append(rb.subscribers[code], ch)
	return ch
}

func (rb *RegistrationBroadcaster) Unsubscribe(code string, ch chan string) {
	rb.mu.Lock()
	defer rb.mu.Unlock()
	subs := rb.subscribers[code]
	for i, sub := range subs {
		if sub == ch {
			rb.subscribers[code] = append(subs[:i], subs[i+1:]...)
			close(ch)
			break
		}
	}
	if len(rb.subscribers[code]) == 0 {
		delete(rb.subscribers, code)
	}
}

func (rb *RegistrationBroadcaster) Broadcast(code, certPEM string) {
	rb.mu.RLock()
	defer rb.mu.RUnlock()
	for _, ch := range rb.subscribers[code] {
		select {
		case ch <- certPEM:
		default:
		}
	}
}

// auditLog records an audit event for sensitive operations
// Zero-Trust: Payload is encrypted with user's public key - Hub cannot read
func (s *HubServer) auditLog(routingToken, eventType string, payload []byte) {
	if routingToken == "" {
		return // Cannot log without routing token
	}

	// Get routing token info (contains public key and tier)
	info, err := s.store.GetRoutingTokenInfo(routingToken)
	if err != nil {
		log.Printf("[AUDIT] Failed to get routing token info: %v", err)
		return
	}

	// Encrypt payload with user's public key (Zero-Trust compliance)
	var encryptedPayload []byte
	if len(info.AuditPubKey) == ed25519.PublicKeySize {
		encrypted, err := nitellacrypto.Encrypt(payload, ed25519.PublicKey(info.AuditPubKey))
		if err != nil {
			log.Printf("[AUDIT] Failed to encrypt audit payload: %v", err)
			return
		}
		encryptedPayload = encrypted.Marshal()
	} else {
		// No public key stored - skip audit log (can't store unencrypted)
		log.Printf("[AUDIT] No audit public key for routing token, skipping")
		return
	}

	// Determine expiry based on tier
	var expiresAt time.Time
	if info.Tier == "business" {
		expiresAt = time.Now().AddDate(1, 0, 0) // 1 year for business
	} else {
		expiresAt = time.Now().AddDate(0, 1, 0) // 1 month default
	}

	auditLog := &model.AuditLog{
		RoutingToken:     routingToken,
		Timestamp:        time.Now(),
		EncryptedPayload: encryptedPayload,
		ExpiresAt:        expiresAt,
	}

	if err := s.store.SaveAuditLog(auditLog); err != nil {
		// Log error but don't fail the operation
		log.Printf("[AUDIT] Failed to save audit log: %v", err)
	}
}

// NewHubServer creates a new Hub server
func NewHubServer(tm *auth.TokenManager, adminTm *auth.TokenManager, s store.Store, fb *firebase.Service, tierCfg *tier.Config) *HubServer {
	if tierCfg == nil {
		tierCfg = tier.DefaultConfig()
	}

	srv := &HubServer{
		store:             s,
		firebase:          fb,
		tokenManager:      tm,
		adminTokenManager: adminTm,
		tierConfig:        tierCfg,
		httpClient: &http.Client{
			Timeout: 10 * time.Second,
			Transport: &http.Transport{
				TLSClientConfig: &tls.Config{
					MinVersion: tls.VersionTLS13,
				},
			},
		},
		pairingRateLimit:       make(map[string]time.Time),
		userStreams:            make(map[string]map[chan *common.Alert]bool),
		pairingChs:             make(map[string]chan string),
		commandResp:            make(map[string]chan *pb.CommandResponse),
		nodeCommandChans:       make(map[string]chan *pb.Command),
		nodeMetricStreams:      make(map[string]chan *pb.EncryptedMetrics),
		nodeLogStreams:         make(map[string]chan *pb.EncryptedLogEntry),
		nodeSignalingStreams:   make(map[string]chan *pb.SignalMessage),
		mobileSignalingStreams: make(map[string]chan *pb.SignalMessage),
		pendingAlerts:          make(map[string]*PendingAlert),
		broadcaster:            NewRegistrationBroadcaster(),
	}

	srv.Mobile = &MobileServer{hub: srv}
	srv.Node = &NodeServer{hub: srv}
	srv.Auth = &AuthServer{hub: srv}
	srv.Pairing = NewPairingServer(srv)
	srv.Admin = NewAdminServer(srv)

	// Seed invite codes from config
	srv.seedInviteCodes()

	// Start rate limit cleanup goroutine (fix memory leak)
	go srv.rateLimitCleanupLoop()

	// Start pending alerts cleanup goroutine (expire old alerts)
	go srv.pendingAlertsCleanupLoop()

	return srv
}

// ensureNodeRegistered checks if a node exists, and if not, attempts JIT registration
// based on the mTLS certificate chain (trusting the User CA).
func (s *HubServer) ensureNodeRegistered(nodeID string, tlsState tls.ConnectionState) (*model.Node, error) {
	peerCert := tlsState.PeerCertificates[0]
	peerCertPEM := string(pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: peerCert.Raw}))

	node, err := s.store.GetNode(nodeID)
	if err == nil {
		// Verify certificate matches stored node (Pinning)
		block, _ := pem.Decode([]byte(node.CertPEM))
		if block != nil && bytes.Equal(block.Bytes, peerCert.Raw) {
			return node, nil
		}
		var pinnedCert *x509.Certificate
		if block != nil {
			pinnedCert, _ = x509.ParseCertificate(block.Bytes)
		}

		// Cert differs from stored pin. Allow trusted re-pair/rotation only if the
		// new cert chains to a known CLI CA and maps to the same routing token.
		verifiedChains := tlsState.VerifiedChains
		if len(verifiedChains) == 0 && s.certMgr != nil {
			verifiedChains = s.certMgr.VerifyClientCertChains(peerCert.Raw)
		}
		if len(verifiedChains) > 0 {
			for _, chain := range verifiedChains {
				if len(chain) < 2 {
					continue
				}
				root := chain[len(chain)-1]
				rootPEM := string(pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: root.Raw}))
				routingToken, err := s.store.GetRoutingTokenByCA(rootPEM)
				if err == nil && routingToken != "" {
					if node.RoutingToken != "" && node.RoutingToken != routingToken {
						continue
					}
					node.RoutingToken = routingToken
				} else {
					// PAKE RegisterNodeWithCert does not persist CA->routing mapping.
					// Allow cert rotation only when the pinned cert was also signed by
					// this same verified root CA.
					if pinnedCert == nil || pinnedCert.CheckSignatureFrom(root) != nil {
						continue
					}
				}

				node.CertPEM = peerCertPEM
				if err := s.store.SaveNode(node); err != nil {
					log.Printf("[Hub] Failed to update pinned certificate for node %s: %v", nodeID, err)
					return nil, status.Error(codes.Internal, "failed to update node certificate")
				}
				log.Printf("[Hub] Updated pinned certificate for node %s via trusted cert rotation", nodeID)
				return node, nil
			}
		}

		return nil, status.Error(codes.Unauthenticated, "Certificate mismatch (pinning failed)")
	}

	// Node not found. Attempt JIT Registration.
	// We need to find the User CA that signed this cert.
	// Note: tlsState.VerifiedChains is only populated when ClientAuth >= VerifyClientCertIfGiven.
	// With RequestClientCert (needed for PairingService), it's always empty.
	// Fall back to manual verification via CertManager when VerifiedChains is empty.
	verifiedChains := tlsState.VerifiedChains
	if len(verifiedChains) == 0 && s.certMgr != nil {
		verifiedChains = s.certMgr.VerifyClientCertChains(peerCert.Raw)
	}
	if len(verifiedChains) == 0 {
		log.Printf("[Hub] JIT Failed: No verified chains for node %s", nodeID)
		return nil, status.Error(codes.Unauthenticated, "Node not registered and no trusted chain found")
	}

	log.Printf("[Hub] JIT: Checking %d verified chains for node %s", len(verifiedChains), nodeID)

	// Iterate through chains to find a known User CA
	for _, chain := range verifiedChains {
		if len(chain) < 2 {
			continue // Need at least Leaf -> Root
		}
		// Root CA is the last element
		root := chain[len(chain)-1]
		rootPEM := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: root.Raw})
		rootPEMStr := string(rootPEM)

		// Check if this CA belongs to a known User
		routingToken, err := s.store.GetRoutingTokenByCA(rootPEMStr)
		if err == nil && routingToken != "" {
			// Found owner, register node
			shortToken := routingToken
			if len(routingToken) > 8 {
				shortToken = routingToken[:8] + "..."
			}
			log.Printf("[Hub] JIT Registering Node %s (User: %s)", nodeID, shortToken)

			newNode := &model.Node{
				ID:           nodeID,
				RoutingToken: routingToken,
				CertPEM:      peerCertPEM,
				Status:       "online",
				LastSeen:     time.Now(),
				CreatedAt:    time.Now(),
				UpdatedAt:    time.Now(),
			}

			if err := s.store.SaveNode(newNode); err != nil {
				log.Printf("[Hub] Failed to save JIT node: %v", err)
				return nil, status.Error(codes.Internal, "Failed to register node")
			}

			return newNode, nil
		}
	}

	return nil, status.Error(codes.Unauthenticated, "Node not registered (and CA not recognized)")
}

// SetCertManager sets the certificate manager for CSR signing
// Also loads CLI CAs from approved registrations for mTLS verification
func (s *HubServer) SetCertManager(cm *certmanager.CertManager) {
	s.certMgr = cm

	// Load CLI CAs from existing approved registrations
	cas, err := s.store.GetApprovedCLICAs()
	if err != nil {
		log.Printf("[Hub] Warning: Failed to load CLI CAs from store: %v", err)
		return
	}
	for _, caPEM := range cas {
		if err := cm.AddClientCA([]byte(caPEM)); err != nil {
			log.Printf("[Hub] Warning: Failed to add CLI CA: %v", err)
		}
	}
	if len(cas) > 0 {
		log.Printf("[Hub] Loaded %d CLI CA(s) for mTLS verification", len(cas))
	}
}

// GetCACertPEM returns the Hub CA certificate PEM if available
func (s *HubServer) GetCACertPEM() ([]byte, error) {
	if s.certMgr == nil {
		return nil, fmt.Errorf("certificate manager not configured")
	}
	return s.certMgr.GetCACertPEM()
}

// getTierByRoutingToken retrieves tier configuration for a routing token
func (s *HubServer) getTierByRoutingToken(routingToken string) *tier.TierConfig {
	info, err := s.store.GetRoutingTokenInfo(routingToken)
	if err != nil || info.Tier == "" {
		return s.tierConfig.GetTierOrDefault("free")
	}
	return s.tierConfig.GetTierOrDefault(info.Tier)
}

// getTierByLicenseKey looks up tier by license key prefix
// Returns tier ID and TierConfig. If no match, returns "free" tier.
func (s *HubServer) getTierByLicenseKey(licenseKey string) (string, *tier.TierConfig) {
	if licenseKey == "" {
		return "free", s.tierConfig.GetTierOrDefault("free")
	}

	// Check each tier's license prefix
	for _, t := range s.tierConfig.Tiers {
		if t.LicensePrefix != "" && strings.HasPrefix(licenseKey, t.LicensePrefix) {
			return t.ID, &t
		}
	}

	return "free", s.tierConfig.GetTierOrDefault("free")
}

func (s *HubServer) seedInviteCodes() {
	_, err := s.store.GetInviteCode("NITELLA")
	if err == nil {
		return // Already seeded
	}

	// Try to load from YAML
	data, err := os.ReadFile("invite_codes.yaml")
	if err != nil {
		log.Printf("[Hub] invite_codes.yaml not found, using defaults")
		// Create default invite codes
		s.store.SaveInviteCode(&model.InviteCode{
			Code:      "NITELLA",
			MaxUses:   100,
			TierID:    "free",
			Active:    true,
			CreatedAt: time.Now(),
		})
		return
	}

	type InviteConfig struct {
		Codes []struct {
			Code  string `yaml:"code"`
			Limit int    `yaml:"limit"`
			Tier  string `yaml:"tier"`
		} `yaml:"codes"`
	}

	var cfg InviteConfig
	if err := yaml.Unmarshal(data, &cfg); err != nil {
		log.Printf("[Hub] Error parsing invite_codes.yaml: %v", err)
		return
	}

	for _, c := range cfg.Codes {
		tier := c.Tier
		if tier == "" {
			tier = "free"
		}
		s.store.SaveInviteCode(&model.InviteCode{
			Code:      c.Code,
			MaxUses:   c.Limit,
			TierID:    tier,
			Active:    true,
			CreatedAt: time.Now(),
		})
		log.Printf("[Hub] Seeded invite code: %s (Limit: %d, Tier: %s)", c.Code, c.Limit, tier)
	}
}

// AuthInterceptor handles JWT authentication for public endpoints
func (s *HubServer) AuthInterceptor(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
	// Skip auth for public endpoints
	if info.FullMethod == "/nitella.hub.NodeService/Register" ||
		strings.HasPrefix(info.FullMethod, "/nitella.hub.PairingService/") ||
		strings.HasPrefix(info.FullMethod, "/nitella.hub.AuthService/Register") {
		return handler(ctx, req)
	}

	// mTLS authentication for NodeService
	if strings.HasPrefix(info.FullMethod, "/nitella.hub.NodeService/") {
		p, ok := peer.FromContext(ctx)
		if !ok {
			return nil, status.Error(codes.Unauthenticated, "No peer info available")
		}
		tlsInfo, ok := p.AuthInfo.(credentials.TLSInfo)
		if !ok {
			return nil, status.Error(codes.Unauthenticated, "TLS required for node authentication")
		}
		if len(tlsInfo.State.PeerCertificates) == 0 {
			return nil, status.Error(codes.Unauthenticated, "Client certificate required")
		}

		cert := tlsInfo.State.PeerCertificates[0]

		// Check certificate validity period
		now := time.Now()
		if now.Before(cert.NotBefore) {
			return nil, status.Error(codes.Unauthenticated, "Certificate not yet valid")
		}
		if now.After(cert.NotAfter) {
			return nil, status.Error(codes.Unauthenticated, "Certificate has expired")
		}

		// Check key usage allows client authentication
		if cert.KeyUsage != 0 && cert.KeyUsage&x509.KeyUsageDigitalSignature == 0 {
			return nil, status.Error(codes.Unauthenticated, "Certificate key usage invalid")
		}

		// Check extended key usage if present
		if len(cert.ExtKeyUsage) > 0 {
			hasClientAuth := false
			for _, usage := range cert.ExtKeyUsage {
				if usage == x509.ExtKeyUsageClientAuth || usage == x509.ExtKeyUsageAny {
					hasClientAuth = true
					break
				}
			}
			if !hasClientAuth {
				return nil, status.Error(codes.Unauthenticated, "Certificate not authorized for client authentication")
			}
		}

		// Check revocation
		serial := hex.EncodeToString(cert.SerialNumber.Bytes())
		revoked, err := s.store.IsRevoked(serial)
		if err != nil {
			return nil, status.Error(codes.Internal, "Revocation check failed")
		}
		if revoked {
			return nil, status.Error(codes.Unauthenticated, "Certificate revoked")
		}

		nodeID := cert.Subject.CommonName

		// Check registration (with JIT support)
		node, err := s.ensureNodeRegistered(nodeID, tlsInfo.State)
		if err != nil {
			return nil, err
		}

		ctx = context.WithValue(ctx, ctxKeyNodeID, nodeID)
		ctx = ratelimit.ContextWithRoutingToken(ctx, node.RoutingToken)
		ctx = context.WithValue(ctx, ctxKeyRole, "node")
		return handler(ctx, req)
	}

	// JWT authentication for other services
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return nil, status.Error(codes.Unauthenticated, "no metadata provided")
	}

	tokens := md.Get("authorization")
	if len(tokens) == 0 {
		return nil, status.Error(codes.Unauthenticated, "authorization header required")
	}

	tokenStr := tokens[0]
	if strings.HasPrefix(tokenStr, "Bearer ") {
		tokenStr = strings.TrimPrefix(tokenStr, "Bearer ")
	}

	if s.tokenManager == nil {
		return nil, status.Error(codes.Internal, "JWT token manager not configured")
	}

	claims, err := s.tokenManager.ValidateToken(tokenStr)
	if err != nil {
		return nil, status.Error(codes.Unauthenticated, "invalid or expired token")
	}

	ctx = auth.NewContext(ctx, claims)
	ctx = context.WithValue(ctx, ctxKeyUserID, claims.UserID)
	ctx = context.WithValue(ctx, ctxKeyRole, claims.Role)

	return handler(ctx, req)
}

// StreamAuthInterceptor handles authentication for streaming RPCs
func (s *HubServer) StreamAuthInterceptor(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
	// Skip auth for public endpoints
	if strings.HasPrefix(info.FullMethod, "/nitella.hub.PairingService/") {
		return handler(srv, ss)
	}

	// mTLS for NodeService streams
	if strings.HasPrefix(info.FullMethod, "/nitella.hub.NodeService/") {
		if p, ok := peer.FromContext(ss.Context()); ok {
			if tlsInfo, ok := p.AuthInfo.(credentials.TLSInfo); ok {
				if len(tlsInfo.State.PeerCertificates) > 0 {
					cert := tlsInfo.State.PeerCertificates[0]

					serial := hex.EncodeToString(cert.SerialNumber.Bytes())
					revoked, err := s.store.IsRevoked(serial)
					if err != nil {
						return status.Error(codes.Internal, "Revocation check failed")
					}
					if revoked {
						return status.Error(codes.Unauthenticated, "Certificate revoked")
					}

					nodeID := cert.Subject.CommonName
					node, err := s.ensureNodeRegistered(nodeID, tlsInfo.State)
					if err != nil {
						return err
					}

					newCtx := context.WithValue(ss.Context(), ctxKeyNodeID, nodeID)
					newCtx = ratelimit.ContextWithRoutingToken(newCtx, node.RoutingToken)
					newCtx = context.WithValue(newCtx, ctxKeyRole, "node")
					wrapped := &wrappedStream{ServerStream: ss, ctx: newCtx}
					return handler(srv, wrapped)
				}
			}
		}
		return status.Error(codes.Unauthenticated, "Node streaming requires valid mTLS certificate")
	}

	// JWT for other streams
	md, ok := metadata.FromIncomingContext(ss.Context())
	if !ok {
		return status.Error(codes.Unauthenticated, "no metadata provided")
	}

	tokens := md.Get("authorization")
	if len(tokens) == 0 {
		return status.Error(codes.Unauthenticated, "authorization header required")
	}

	tokenStr := strings.TrimPrefix(tokens[0], "Bearer ")

	claims, err := s.tokenManager.ValidateToken(tokenStr)
	if err != nil {
		return status.Error(codes.Unauthenticated, "invalid or expired token")
	}

	newCtx := auth.NewContext(ss.Context(), claims)
	newCtx = context.WithValue(newCtx, ctxKeyUserID, claims.UserID)
	wrapped := &wrappedStream{ServerStream: ss, ctx: newCtx}
	return handler(srv, wrapped)
}

// AdminAuthInterceptor handles authentication for admin endpoints
func (s *HubServer) AdminAuthInterceptor(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return nil, status.Error(codes.Unauthenticated, "no metadata provided")
	}

	tokens := md.Get("authorization")
	if len(tokens) == 0 {
		return nil, status.Error(codes.Unauthenticated, "authorization header required")
	}

	tokenStr := strings.TrimPrefix(tokens[0], "Bearer ")

	if s.adminTokenManager == nil {
		return nil, status.Error(codes.Internal, "Admin JWT token manager not configured")
	}

	claims, err := s.adminTokenManager.ValidateToken(tokenStr)
	if err != nil {
		return nil, status.Error(codes.Unauthenticated, "invalid or expired admin token")
	}

	ctx = auth.NewContext(ctx, claims)
	return handler(ctx, req)
}

// NotifyByRoutingToken sends notification via stream or push using blind routing
// Zero-Trust: Hub routes by token, doesn't know user identity
func (s *HubServer) NotifyByRoutingToken(routingToken string, title string, body string, data map[string]string) {
	// Try stream first (keyed by routing_token now)
	s.userStreamsMu.RLock()
	streams, hasStream := s.userStreams[routingToken]
	s.userStreamsMu.RUnlock()

	if hasStream && len(streams) > 0 {
		alert := &common.Alert{
			Id:            uuid.New().String(),
			TimestampUnix: time.Now().Unix(),
			Severity:      "INFO",
			Metadata:      data,
		}

		s.userStreamsMu.RLock()
		for ch := range streams {
			select {
			case ch <- alert:
			default:
			}
		}
		s.userStreamsMu.RUnlock()
		return
	}

	// Fallback to Firebase via FCM topic
	if s.firebase != nil && s.firebase.IsEnabled() {
		// Get FCM topic from routing token info
		info, err := s.store.GetRoutingTokenInfo(routingToken)
		if err != nil || info.FCMTopic == "" {
			return
		}
		// Get device tokens subscribed to this topic
		tokens, err := s.store.GetFCMTokensByTopic(info.FCMTopic)
		if err != nil {
			return
		}
		for _, t := range tokens {
			go s.firebase.SendPush(t.Token, title, body, data)
		}
	}
}

// ForwardAlertToClients forwards an alert (with encrypted payload intact) to connected CLI/Mobile clients
// Zero-Trust: The encrypted payload can only be decrypted by the user's private key
func (s *HubServer) ForwardAlertToClients(routingToken string, alert *common.Alert) {
	s.userStreamsMu.RLock()
	streams := s.userStreams[routingToken]
	if len(streams) == 0 {
		s.userStreamsMu.RUnlock()
		log.Printf("[Hub] No connected clients for routing token, alert %s not delivered", alert.Id)
		return
	}
	for ch := range streams {
		select {
		case ch <- alert:
		default:
			// Channel full, drop alert
		}
	}
	s.userStreamsMu.RUnlock()
}

// Helper for rate limiting pairing
func (s *HubServer) checkPairingRateLimit(ctx context.Context) error {
	peerInfo, ok := peer.FromContext(ctx)
	if !ok {
		return nil
	}

	ip := peerInfo.Addr.String()
	if colonIdx := strings.LastIndex(ip, ":"); colonIdx != -1 {
		ip = ip[:colonIdx]
	}

	s.pairingRateMu.Lock()
	defer s.pairingRateMu.Unlock()

	now := time.Now()
	if now.After(s.globalPairingReset) {
		s.globalPairingCount = 0
		s.globalPairingReset = now.Add(1 * time.Minute)
	}
	s.globalPairingCount++
	if s.globalPairingCount > GlobalPairingRateLimit {
		return status.Error(codes.ResourceExhausted, "Service busy. Please try again later.")
	}

	lastAttempt, exists := s.pairingRateLimit[ip]
	if exists && time.Since(lastAttempt) < 3*time.Second {
		return status.Error(codes.ResourceExhausted, "Too many pairing attempts. Please wait.")
	}
	s.pairingRateLimit[ip] = now
	return nil
}

// checkRegistrationRateLimit rate limits registration requests (prevents DoS)
func checkRegistrationRateLimit(s *HubServer, ctx context.Context) error {
	peerInfo, ok := peer.FromContext(ctx)
	if !ok {
		return nil
	}

	ip := peerInfo.Addr.String()
	if colonIdx := strings.LastIndex(ip, ":"); colonIdx != -1 {
		ip = ip[:colonIdx]
	}

	s.pairingRateMu.Lock()
	defer s.pairingRateMu.Unlock()

	now := time.Now()

	// Global rate limit: max 50 registrations per minute
	if now.After(s.globalPairingReset) {
		s.globalPairingCount = 0
		s.globalPairingReset = now.Add(1 * time.Minute)
	}
	s.globalPairingCount++
	if s.globalPairingCount > 50 {
		return status.Error(codes.ResourceExhausted, "Registration service busy. Please try again later.")
	}

	// Per-IP rate limit: 1 registration per 5 seconds (can be disabled for e2e tests)
	if os.Getenv("NITELLA_DISABLE_PAIRING_RATE_LIMIT") != "true" {
		lastAttempt, exists := s.pairingRateLimit[ip]
		if exists && time.Since(lastAttempt) < 5*time.Second {
			return status.Error(codes.ResourceExhausted, "Too many registration attempts. Please wait 5 seconds.")
		}
	}
	s.pairingRateLimit[ip] = now
	return nil
}

// rateLimitCleanupLoop periodically removes stale rate limit entries (fix memory leak)
func (s *HubServer) rateLimitCleanupLoop() {
	ticker := time.NewTicker(PendingAlertExpiry)
	defer ticker.Stop()
	for range ticker.C {
		s.pairingRateMu.Lock()
		now := time.Now()
		for ip, lastAttempt := range s.pairingRateLimit {
			// Remove entries older than 1 minute
			if now.Sub(lastAttempt) > time.Minute {
				delete(s.pairingRateLimit, ip)
			}
		}
		s.pairingRateMu.Unlock()
	}
}

// pendingAlertsCleanupLoop periodically removes expired pending alerts
func (s *HubServer) pendingAlertsCleanupLoop() {
	ticker := time.NewTicker(1 * time.Minute)
	defer ticker.Stop()
	for range ticker.C {
		s.pendingAlertsMu.Lock()
		now := time.Now()
		var expiredTokens []string
		for id, pending := range s.pendingAlerts {
			// Remove alerts older than PendingAlertExpiry (approval timeout)
			if now.Sub(pending.CreatedAt) > PendingAlertExpiry {
				log.Printf("[Hub] Expiring pending alert %s (no response)", id)
				expiredTokens = append(expiredTokens, pending.RoutingToken)
				delete(s.pendingAlerts, id)
			}
		}
		s.pendingAlertsMu.Unlock()
	}
}

// wrappedStream wraps ServerStream with custom context
type wrappedStream struct {
	grpc.ServerStream
	ctx context.Context
}

func (w *wrappedStream) Context() context.Context {
	return w.ctx
}

// RegisterServices registers all Hub gRPC services on the given server
func (s *HubServer) RegisterServices(grpcServer *grpc.Server) {
	pb.RegisterNodeServiceServer(grpcServer, s.Node)
	pb.RegisterMobileServiceServer(grpcServer, s.Mobile)
	pb.RegisterAuthServiceServer(grpcServer, s.Auth)
	pb.RegisterPairingServiceServer(grpcServer, s.Pairing)
	pb.RegisterAdminServiceServer(grpcServer, s.Admin)
}
