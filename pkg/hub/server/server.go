package server

import (
	"bytes"
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/subtle"
	"crypto/tls"
	"crypto/x509"
	"encoding/hex"
	"encoding/pem"
	"fmt"
	"io"
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
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
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

		// Certificate pinning
		node, err := s.store.GetNode(nodeID)
		if err != nil {
			return nil, status.Error(codes.Unauthenticated, "Node not registered")
		}

		block, _ := pem.Decode([]byte(node.CertPEM))
		if block == nil || !bytes.Equal(block.Bytes, cert.Raw) {
			return nil, status.Error(codes.Unauthenticated, "Certificate mismatch")
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
					node, err := s.store.GetNode(nodeID)
					if err != nil {
						return status.Error(codes.Unauthenticated, "Node not registered")
					}

					block, _ := pem.Decode([]byte(node.CertPEM))
					if block == nil || !bytes.Equal(block.Bytes, cert.Raw) {
						return status.Error(codes.Unauthenticated, "Certificate mismatch")
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

// ============================================================================
// NodeServer - Handles node connections
// ============================================================================

type NodeServer struct {
	pb.UnimplementedNodeServiceServer
	hub *HubServer
}

func (s *NodeServer) Register(ctx context.Context, req *pb.NodeRegisterRequest) (*pb.NodeRegisterResponse, error) {
	log.Printf("[Node] Registration request received")

	// Rate limiting for registration (prevent DoS)
	if err := checkRegistrationRateLimit(s.hub, ctx); err != nil {
		return nil, err
	}

	// Parse and validate CSR FIRST (before consuming invite code)
	block, _ := pem.Decode([]byte(req.CsrPem))
	if block == nil {
		return nil, status.Error(codes.InvalidArgument, "Invalid CSR: failed to decode PEM")
	}
	csr, err := x509.ParseCertificateRequest(block.Bytes)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "Invalid CSR: %v", err)
	}

	// Verify CSR signature
	if err := csr.CheckSignature(); err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "Invalid CSR signature: %v", err)
	}

	// Validate CommonName is present and reasonable
	commonName := csr.Subject.CommonName
	if commonName == "" {
		return nil, status.Error(codes.InvalidArgument, "Invalid CSR: CommonName is required")
	}
	// CommonName should be a valid UUID (36 chars with hyphens)
	if len(commonName) > 64 {
		return nil, status.Error(codes.InvalidArgument, "Invalid CSR: CommonName too long")
	}
	// Validate UUID format (basic check)
	if len(commonName) == 36 {
		// Check for valid UUID format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
		for i, c := range commonName {
			if i == 8 || i == 13 || i == 18 || i == 23 {
				if c != '-' {
					return nil, status.Error(codes.InvalidArgument, "Invalid CSR: CommonName must be a valid UUID")
				}
			} else if !((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')) {
				return nil, status.Error(codes.InvalidArgument, "Invalid CSR: CommonName must be a valid UUID")
			}
		}
	}

	// Verify public key is Ed25519
	if _, ok := csr.PublicKey.(ed25519.PublicKey); !ok {
		return nil, status.Error(codes.InvalidArgument, "Invalid CSR: Only Ed25519 keys are supported")
	}

	// NOW validate and consume invite code (after CSR is validated)
	if req.InviteCode != "" {
		if err := s.hub.store.ConsumeInviteCode(req.InviteCode); err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "Invalid invite code: %v", err)
		}
	}

	// Generate registration code
	code := generateCode()

	// Generate watch secret (only the registrant knows this)
	watchSecretBytes := make([]byte, 32)
	if _, err := rand.Read(watchSecretBytes); err != nil {
		return nil, status.Errorf(codes.Internal, "Failed to generate watch secret: %v", err)
	}
	watchSecret := hex.EncodeToString(watchSecretBytes)

	// Store registration request
	regReq := &model.RegistrationRequest{
		Code:        code,
		CSR:         req.CsrPem,
		NodeID:      csr.Subject.CommonName,
		Status:      "PENDING",
		LicenseKey:  req.InviteCode, // License key for tier lookup
		WatchSecret: watchSecret,
		ExpiresAt:   time.Now().Add(10 * time.Minute),
	}
	if err := s.hub.store.SaveRegistrationRequest(regReq); err != nil {
		return nil, status.Errorf(codes.Internal, "Failed to save registration: %v", err)
	}

	return &pb.NodeRegisterResponse{
		RegistrationCode: code,
		WatchSecret:      watchSecret,
	}, nil
}

func (s *NodeServer) WatchRegistration(req *pb.WatchRegistrationRequest, stream pb.NodeService_WatchRegistrationServer) error {
	code := req.GetRegistrationCode()
	watchSecret := req.GetWatchSecret()

	// Validate watch secret BEFORE doing anything else
	regReq, err := s.hub.store.GetRegistrationRequest(code)
	if err != nil {
		return status.Error(codes.NotFound, "Registration not found")
	}

	// Constant-time comparison to prevent timing attacks
	// Use bitwise OR to combine checks without early exit (constant-time)
	storedSecret := []byte(regReq.WatchSecret)
	providedSecret := []byte(watchSecret)

	// Pad to same length for constant-time comparison
	maxLen := len(storedSecret)
	if len(providedSecret) > maxLen {
		maxLen = len(providedSecret)
	}
	if maxLen == 0 {
		maxLen = 1 // Ensure we do at least one comparison
	}

	padded1 := make([]byte, maxLen)
	padded2 := make([]byte, maxLen)
	copy(padded1, storedSecret)
	copy(padded2, providedSecret)

	// Constant-time: both must be non-empty AND equal
	valid := subtle.ConstantTimeCompare(padded1, padded2) &
		subtle.ConstantTimeEq(int32(len(storedSecret)), int32(len(providedSecret))) &
		(1 - subtle.ConstantTimeEq(int32(len(storedSecret)), 0))

	if valid != 1 {
		return status.Error(codes.PermissionDenied, "Invalid watch secret")
	}

	ch := s.hub.broadcaster.Subscribe(code)
	defer s.hub.broadcaster.Unsubscribe(code, ch)

	if regReq.Status == "APPROVED" {
		return stream.Send(&pb.WatchRegistrationResponse{
			Status:  pb.RegistrationStatus_REGISTRATION_STATUS_APPROVED,
			CertPem: regReq.CertPEM,
			CaPem:   regReq.CaPEM,
		})
	}

	// Wait for approval
	select {
	case certPEM := <-ch:
		regReq, _ = s.hub.store.GetRegistrationRequest(code)
		return stream.Send(&pb.WatchRegistrationResponse{
			Status:  pb.RegistrationStatus_REGISTRATION_STATUS_APPROVED,
			CertPem: certPEM,
			CaPem:   regReq.CaPEM,
		})
	case <-stream.Context().Done():
		return stream.Context().Err()
	case <-time.After(10 * time.Minute):
		return status.Error(codes.DeadlineExceeded, "Registration timeout")
	}
}

func (s *NodeServer) CheckCertificate(ctx context.Context, req *pb.CheckCertificateRequest) (*pb.CheckCertificateResponse, error) {
	node, err := s.hub.store.GetNode(req.Fingerprint)
	if err != nil {
		return &pb.CheckCertificateResponse{Found: false}, nil
	}
	return &pb.CheckCertificateResponse{
		Found:   true,
		CertPem: node.CertPEM,
	}, nil
}

func (s *NodeServer) Heartbeat(ctx context.Context, req *pb.HeartbeatRequest) (*pb.HeartbeatResponse, error) {
	nodeID, ok := ctx.Value(ctxKeyNodeID).(string)
	if !ok {
		return nil, status.Error(codes.Unauthenticated, "node not authenticated")
	}
	s.hub.store.UpdateNodeStatus(nodeID, "online")
	return &pb.HeartbeatResponse{}, nil
}

func (s *NodeServer) ReceiveCommands(req *pb.ReceiveCommandsRequest, stream pb.NodeService_ReceiveCommandsServer) error {
	nodeID, ok := stream.Context().Value(ctxKeyNodeID).(string)
	if !ok {
		return status.Error(codes.Unauthenticated, "node not authenticated")
	}
	log.Printf("[Node] %s started ReceiveCommands stream", nodeID)

	// Update node status
	s.hub.store.UpdateNodeStatus(nodeID, "online")
	defer s.hub.store.UpdateNodeStatus(nodeID, "offline")

	// Create command channel for this node
	cmdCh := make(chan *pb.Command, 10)

	// Register the command channel
	s.hub.nodeCommandMu.Lock()
	// Close existing channel if any (node reconnected)
	if oldCh, exists := s.hub.nodeCommandChans[nodeID]; exists {
		close(oldCh)
	}
	s.hub.nodeCommandChans[nodeID] = cmdCh
	s.hub.nodeCommandMu.Unlock()

	// Cleanup on disconnect
	defer func() {
		s.hub.nodeCommandMu.Lock()
		if s.hub.nodeCommandChans[nodeID] == cmdCh {
			delete(s.hub.nodeCommandChans, nodeID)
		}
		s.hub.nodeCommandMu.Unlock()
		log.Printf("[Node] %s disconnected from ReceiveCommands", nodeID)
	}()

	// Forward commands to node
	for {
		select {
		case cmd, ok := <-cmdCh:
			if !ok {
				// Channel closed (node reconnected elsewhere)
				return nil
			}
			if err := stream.Send(cmd); err != nil {
				log.Printf("[Node] %s: failed to send command: %v", nodeID, err)
				return err
			}
			log.Printf("[Node] %s: forwarded command %s", nodeID, cmd.Id)
		case <-stream.Context().Done():
			return stream.Context().Err()
		}
	}
}

func (s *NodeServer) RespondToCommand(ctx context.Context, resp *pb.CommandResponse) (*pb.Empty, error) {
	s.hub.commandRespMu.Lock()
	ch, ok := s.hub.commandResp[resp.CommandId]
	if ok {
		// Remove from map first to prevent double-send
		delete(s.hub.commandResp, resp.CommandId)
	}
	s.hub.commandRespMu.Unlock()

	if ok && ch != nil {
		// Safe to send - we own the only reference now
		select {
		case ch <- resp:
		default:
			// Channel full or closed, response dropped
		}
	}
	return &pb.Empty{}, nil
}

func (s *NodeServer) PushMetrics(stream pb.NodeService_PushMetricsServer) error {
	nodeID, ok := stream.Context().Value(ctxKeyNodeID).(string)
	if !ok {
		return status.Error(codes.Unauthenticated, "node not authenticated")
	}

	// Get node to find routing token for storage
	node, err := s.hub.store.GetNode(nodeID)
	if err != nil {
		return status.Error(codes.NotFound, "Node not found")
	}
	routingToken := node.RoutingToken

	for {
		metrics, err := stream.Recv()
		if err != nil {
			return err
		}
		metrics.NodeId = nodeID

		// Store encrypted metrics in database (Zero-Trust: Hub cannot decrypt)
		if metrics.Encrypted != nil {
			ts := time.Now()
			if metrics.Timestamp != nil {
				ts = metrics.Timestamp.AsTime()
			}
			encMetric := &model.EncryptedMetric{
				NodeID:        nodeID,
				RoutingToken:  routingToken,
				Timestamp:     ts,
				EncryptedBlob: metrics.Encrypted.GetCiphertext(),
				Nonce:         metrics.Encrypted.GetNonce(),
				SenderKeyID:   metrics.Encrypted.GetSenderFingerprint(),
			}
			// Store async to not block the stream
			go func(m *model.EncryptedMetric) {
				if err := s.hub.store.SaveEncryptedMetric(m); err != nil {
					log.Printf("[Metrics] Failed to save metric for node %s: %v", m.NodeID, err)
				}
			}(encMetric)
		}

		// Forward to subscribers (real-time streaming)
		s.hub.nodeMetricsMu.RLock()
		if ch, ok := s.hub.nodeMetricStreams[nodeID]; ok {
			select {
			case ch <- metrics:
			default:
			}
		}
		s.hub.nodeMetricsMu.RUnlock()
	}
}

func (s *NodeServer) PushLogs(stream pb.NodeService_PushLogsServer) error {
	nodeID, ok := stream.Context().Value(ctxKeyNodeID).(string)
	if !ok {
		return status.Error(codes.Unauthenticated, "node not authenticated")
	}

	// Get node to find routing token for storage
	node, err := s.hub.store.GetNode(nodeID)
	if err != nil {
		return status.Error(codes.NotFound, "Node not found")
	}
	routingToken := node.RoutingToken

	// Get tier config for limits
	tierCfg := s.hub.getTierByRoutingToken(routingToken)
	maxLogs := tierCfg.Logs.MaxLogs

	for {
		logEntry, err := stream.Recv()
		if err != nil {
			return err
		}
		logEntry.NodeId = nodeID

		// Zero-Trust: Hub cannot decrypt logs - only relay/store encrypted blob
		// Logs are encrypted with User's public key, only User can decrypt

		// Store encrypted log in database
		if logEntry.Encrypted != nil {
			ts := time.Now()
			if logEntry.Timestamp != nil {
				ts = logEntry.Timestamp.AsTime()
			}
			encLog := &model.EncryptedLog{
				NodeID:        nodeID,
				RoutingToken:  routingToken,
				Timestamp:     ts,
				EncryptedBlob: logEntry.Encrypted.GetCiphertext(),
				Nonce:         logEntry.Encrypted.GetNonce(),
				SenderKeyID:   logEntry.Encrypted.GetSenderFingerprint(),
			}
			// Store async to not block the stream
			go func(l *model.EncryptedLog, maxLogs int) {
				// Check tier limit before saving
				if maxLogs > 0 {
					count, err := s.hub.store.CountLogs(l.RoutingToken)
					if err != nil {
						log.Printf("[Logs] Failed to count logs for %s: %v", l.RoutingToken, err)
					} else if count >= int64(maxLogs) {
						// Delete oldest logs to make room (keep 90% to avoid frequent cleanup)
						keepCount := int(float64(maxLogs) * 0.9)
						if err := s.hub.store.DeleteOldestLogs(l.RoutingToken, keepCount); err != nil {
							log.Printf("[Logs] Failed to cleanup old logs for %s: %v", l.RoutingToken, err)
						}
					}
				}
				if err := s.hub.store.SaveEncryptedLog(l); err != nil {
					log.Printf("[Logs] Failed to save log for node %s: %v", l.NodeID, err)
				}
			}(encLog, maxLogs)
		}

		// Forward to subscribers (real-time streaming)
		s.hub.nodeLogsMu.RLock()
		if ch, ok := s.hub.nodeLogStreams[nodeID]; ok {
			select {
			case ch <- logEntry:
			default:
				// Channel full, drop log (subscriber too slow)
			}
		}
		s.hub.nodeLogsMu.RUnlock()
	}
}

func (s *NodeServer) PushAlert(ctx context.Context, alert *common.Alert) (*pb.Empty, error) {
	nodeID, ok := ctx.Value(ctxKeyNodeID).(string)
	if !ok {
		return nil, status.Error(codes.Unauthenticated, "node not authenticated")
	}

	// Get node to find routing token
	node, err := s.hub.store.GetNode(nodeID)
	if err != nil {
		return nil, status.Error(codes.NotFound, "Node not found")
	}

	// Fill in NodeId for the alert (node may not have included it)
	alert.NodeId = nodeID

	// Store pending alert for routing approval decisions back to node
	// This is needed because approval decisions reference the alert ID
	s.hub.pendingAlertsMu.Lock()
	// Global limit check: prevent memory exhaustion from distributed DoS
	if len(s.hub.pendingAlerts) >= MaxGlobalPendingAlerts {
		s.hub.pendingAlertsMu.Unlock()
		return nil, status.Errorf(codes.ResourceExhausted,
			"hub overloaded: too many pending alerts globally (max: %d), try again later",
			MaxGlobalPendingAlerts)
	}
	s.hub.pendingAlerts[alert.Id] = &PendingAlert{
		NodeID:       nodeID,
		RoutingToken: node.RoutingToken,
		Alert:        alert,
		CreatedAt:    time.Now(),
	}
	s.hub.pendingAlertsMu.Unlock()

	// Forward the original alert (with encrypted payload) to connected clients
	s.hub.ForwardAlertToClients(node.RoutingToken, alert)

	return &pb.Empty{}, nil
}

func (s *NodeServer) StreamRevocations(req *pb.StreamRevocationsRequest, stream pb.NodeService_StreamRevocationsServer) error {
	// Keep stream open and send revocation events when they occur
	<-stream.Context().Done()
	return stream.Context().Err()
}

func (s *NodeServer) StreamSignaling(stream pb.NodeService_StreamSignalingServer) error {
	nodeID, ok := stream.Context().Value(ctxKeyNodeID).(string)
	if !ok {
		return status.Error(codes.Unauthenticated, "node not authenticated")
	}

	// Register signaling channel
	ch := make(chan *pb.SignalMessage, 10)
	s.hub.nodeSignalingMu.Lock()
	s.hub.nodeSignalingStreams[nodeID] = ch
	s.hub.nodeSignalingMu.Unlock()

	defer func() {
		s.hub.nodeSignalingMu.Lock()
		delete(s.hub.nodeSignalingStreams, nodeID)
		s.hub.nodeSignalingMu.Unlock()
		close(ch)
	}()

	// Send loop
	go func() {
		for msg := range ch {
			if err := stream.Send(msg); err != nil {
				return
			}
		}
	}()

	// Receive loop
	for {
		msg, err := stream.Recv()
		if err != nil {
			return err
		}

		// Route to mobile
		s.hub.mobileSignalingMu.RLock()
		if mobileCh, ok := s.hub.mobileSignalingStreams[msg.TargetId]; ok {
			msg.SourceId = nodeID
			select {
			case mobileCh <- msg:
			default:
			}
		}
		s.hub.mobileSignalingMu.RUnlock()
	}
}

// ============================================================================
// MobileServer - Handles CLI/mobile connections
// ============================================================================

type MobileServer struct {
	pb.UnimplementedMobileServiceServer
	hub *HubServer
}

func (s *MobileServer) RegisterNodeViaCSR(ctx context.Context, req *pb.RegisterNodeViaCSRRequest) (*emptypb.Empty, error) {
	// Zero-Trust: No userID needed - routing token is used instead
	nodeID := req.NodeId
	if nodeID == "" {
		// Extract from cert
		block, _ := pem.Decode([]byte(req.CertPem))
		if block == nil {
			return nil, status.Error(codes.InvalidArgument, "Invalid certificate")
		}
		cert, err := x509.ParseCertificate(block.Bytes)
		if err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "Failed to parse certificate: %v", err)
		}
		nodeID = cert.Subject.CommonName
	}

	// Zero-Trust: Use routing token instead of OwnerID
	// The routing_token should be provided by CLI during registration/pairing
	routingToken := ctx.Value(ctxKeyRoutingToken)
	if routingToken == nil {
		routingToken = "" // Will be set during pairing flow
	}

	node := &model.Node{
		ID:           nodeID,
		RoutingToken: routingToken.(string),
		CertPEM:      req.CertPem,
		Status:       "offline",
	}
	if err := s.hub.store.SaveNode(node); err != nil {
		return nil, status.Errorf(codes.Internal, "Failed to save node: %v", err)
	}

	return &emptypb.Empty{}, nil
}

func (s *MobileServer) ListNodes(ctx context.Context, req *pb.ListNodesRequest) (*pb.ListNodesResponse, error) {
	// Zero-Trust: CLI provides routing tokens, Hub fetches only matching nodes
	// This ensures multi-tenant isolation - users can only see their own nodes

	var nodes []*model.Node
	routingTokens := req.GetRoutingTokens()

	if len(routingTokens) > 0 {
		// Filter by routing tokens (proper zero-trust isolation)
		for _, token := range routingTokens {
			node, err := s.hub.store.GetNodeByRoutingToken(token)
			if err == nil {
				nodes = append(nodes, node)
			}
			// Ignore errors (node may not exist for that token)
		}
	} else {
		// No routing tokens provided - return empty list for security
		// In zero-trust mode, clients MUST provide their routing tokens
		return &pb.ListNodesResponse{
			Nodes:      []*pb.Node{},
			TotalCount: 0,
		}, nil
	}

	var pbNodes []*pb.Node
	for _, n := range nodes {
		if req.Filter != "" && req.Filter != "all" {
			if req.Filter != n.Status {
				continue
			}
		}
		pbNodes = append(pbNodes, &pb.Node{
			Id:       n.ID,
			Status:   pb.NodeStatus(pb.NodeStatus_value[strings.ToUpper(n.Status)]),
			LastSeen: timestamppb.New(n.LastSeen),
		})
	}

	return &pb.ListNodesResponse{
		Nodes:      pbNodes,
		TotalCount: int32(len(pbNodes)),
	}, nil
}

func (s *MobileServer) GetNode(ctx context.Context, req *pb.GetNodeRequest) (*pb.Node, error) {
	// Require routing_token for authorization
	routingToken := req.GetRoutingToken()
	if routingToken == "" {
		return nil, status.Error(codes.InvalidArgument, "routing_token is required")
	}

	node, err := s.hub.store.GetNode(req.NodeId)
	if err != nil {
		return nil, status.Error(codes.NotFound, "Node not found")
	}

	// Verify the caller owns this node via routing token
	if node.RoutingToken != routingToken {
		return nil, status.Error(codes.PermissionDenied, "Not authorized to access this node")
	}

	return &pb.Node{
		Id:       node.ID,
		Status:   pb.NodeStatus(pb.NodeStatus_value[strings.ToUpper(node.Status)]),
		LastSeen: timestamppb.New(node.LastSeen),
	}, nil
}

func (s *MobileServer) RegisterNode(ctx context.Context, req *pb.RegisterNodeRequest) (*pb.RegisterNodeResponse, error) {
	regReq, err := s.hub.store.GetRegistrationRequest(req.RegistrationCode)
	if err != nil {
		return nil, status.Error(codes.NotFound, "Registration not found")
	}

	return &pb.RegisterNodeResponse{
		NodeId: regReq.NodeID,
		CsrPem: regReq.CSR,
	}, nil
}

func (s *MobileServer) ApproveNode(ctx context.Context, req *pb.ApproveNodeRequest) (*pb.Empty, error) {
	// CLI must sign the CSR - Hub never signs (zero-trust)
	if req.CertPem == "" {
		return nil, status.Error(codes.InvalidArgument, "cert_pem required: CLI must sign the node CSR")
	}
	if req.CaPem == "" {
		return nil, status.Error(codes.InvalidArgument, "ca_pem required: CLI must provide CA certificate for audit log encryption")
	}
	certPEM := req.CertPem
	caPEM := req.CaPem

	// Get routing token from request (CLI generates as HMAC(node_id, user_secret))
	// Zero-Trust: routing_token is REQUIRED - Hub never generates tokens
	routingToken := req.GetRoutingToken()
	if routingToken == "" {
		return nil, status.Error(codes.InvalidArgument, "routing_token is required: CLI must generate HMAC(node_id, user_secret)")
	}

	// Validate CA certificate BEFORE approval - no fallback to unencrypted audit logs
	block, _ := pem.Decode([]byte(caPEM))
	if block == nil {
		return nil, status.Error(codes.InvalidArgument, "failed to decode CA PEM")
	}
	caCert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "failed to parse CA certificate: %v", err)
	}
	auditPubKey, ok := caCert.PublicKey.(ed25519.PublicKey)
	if !ok {
		return nil, status.Error(codes.InvalidArgument, "CA certificate must contain Ed25519 public key for audit log encryption")
	}

	// Add CLI CA to CertManager for mTLS verification of node certificates
	if s.hub.certMgr != nil {
		if err := s.hub.certMgr.AddClientCA([]byte(caPEM)); err != nil {
			log.Printf("[ApproveNode] Warning: Failed to add CLI CA to CertManager: %v", err)
		}
	}

	// Look up registration first to get NodeID and LicenseKey (needed for node and tier info)
	pendingReg, err := s.hub.store.GetRegistrationRequest(req.RegistrationCode)
	if err != nil {
		return nil, status.Error(codes.NotFound, "Registration not found")
	}

	// Build node record
	node := &model.Node{
		ID:           pendingReg.NodeID,
		RoutingToken: routingToken,
		CertPEM:      certPEM,
		Status:       "offline",
	}

	// Build routing token info with tier lookup
	tierName, _ := s.hub.getTierByLicenseKey(pendingReg.LicenseKey)
	info := &model.RoutingTokenInfo{
		RoutingToken: routingToken,
		LicenseKey:   pendingReg.LicenseKey,
		Tier:         tierName,
		AuditPubKey:  auditPubKey,
	}

	// Atomic approval: registration + node + routing token info in single transaction
	// Prevents billing bypass if any step fails after approval
	regReq, err := s.hub.store.ApproveNodeAtomic(req.RegistrationCode, certPEM, caPEM, routingToken, node, info)
	if err != nil {
		if err.Error() == "registration not found" {
			return nil, status.Error(codes.NotFound, "Registration not found")
		}
		if err.Error() == "registration already approved" {
			return nil, status.Error(codes.FailedPrecondition, "Registration already approved")
		}
		return nil, status.Error(codes.FailedPrecondition, err.Error())
	}

	// Broadcast approval
	s.hub.broadcaster.Broadcast(req.RegistrationCode, certPEM)

	// Audit log: Node approved (encrypted with user's CA public key)
	s.hub.auditLog(routingToken, "node_approved", []byte(fmt.Sprintf(`{"node_id":"%s","timestamp":"%s"}`, regReq.NodeID, time.Now().Format(time.RFC3339))))

	return &pb.Empty{}, nil
}

func (s *MobileServer) DeleteNode(ctx context.Context, req *pb.DeleteNodeRequest) (*pb.Empty, error) {
	// Zero-Trust: Verify caller has routing_token for this node
	routingToken := req.GetRoutingToken()
	if routingToken == "" {
		return nil, status.Error(codes.InvalidArgument, "routing_token is required")
	}

	node, err := s.hub.store.GetNode(req.NodeId)
	if err != nil {
		return nil, status.Error(codes.NotFound, "Node not found")
	}

	// Verify routing token matches (caller must prove ownership)
	if node.RoutingToken != routingToken {
		return nil, status.Error(codes.PermissionDenied, "Not authorized to delete this node")
	}

	if err := s.hub.store.DeleteNode(req.NodeId); err != nil {
		return nil, status.Error(codes.Internal, "Failed to delete node")
	}

	// Audit log: Node deleted
	s.hub.auditLog(routingToken, "node_deleted", []byte(fmt.Sprintf(`{"node_id":"%s","timestamp":"%s"}`, req.NodeId, time.Now().Format(time.RFC3339))))

	return &pb.Empty{}, nil
}

func (s *MobileServer) SendCommand(ctx context.Context, req *pb.CommandRequest) (*pb.CommandResponse, error) {
	// Zero-Trust: Validate routing token before forwarding command
	nodeID := req.GetNodeId()
	routingToken := req.GetRoutingToken()

	if routingToken == "" {
		return nil, status.Error(codes.InvalidArgument, "routing_token is required")
	}

	// Verify the routing token matches the node's stored token
	node, err := s.hub.store.GetNodeByRoutingToken(routingToken)
	if err != nil {
		return nil, status.Error(codes.PermissionDenied, "invalid routing token")
	}

	// If node_id is provided, verify it matches
	if nodeID != "" && node.ID != nodeID {
		return nil, status.Error(codes.PermissionDenied, "routing token does not match node_id")
	}

	// Use the node ID from the validated token
	targetNodeID := node.ID

	// Get the node's command channel
	s.hub.nodeCommandMu.RLock()
	cmdCh, online := s.hub.nodeCommandChans[targetNodeID]
	s.hub.nodeCommandMu.RUnlock()

	if !online {
		return nil, status.Error(codes.Unavailable, "node is offline")
	}

	// Create response channel and register it
	cmdID := uuid.New().String()
	respCh := make(chan *pb.CommandResponse, 1)

	s.hub.commandRespMu.Lock()
	s.hub.commandResp[cmdID] = respCh
	s.hub.commandRespMu.Unlock()

	defer func() {
		s.hub.commandRespMu.Lock()
		delete(s.hub.commandResp, cmdID)
		s.hub.commandRespMu.Unlock()
	}()

	// Build command with the encrypted payload from request
	cmd := &pb.Command{
		Id:        cmdID,
		Encrypted: req.GetEncrypted(),
	}

	// Forward command to node via channel
	select {
	case cmdCh <- cmd:
		// Command sent successfully
	case <-time.After(5 * time.Second):
		return nil, status.Error(codes.Unavailable, "node command queue full")
	case <-ctx.Done():
		return nil, ctx.Err()
	}

	// Wait for response with timeout
	select {
	case resp := <-respCh:
		return resp, nil
	case <-time.After(30 * time.Second):
		return nil, status.Error(codes.DeadlineExceeded, "command timeout")
	case <-ctx.Done():
		return nil, ctx.Err()
	}
}

func (s *MobileServer) StreamMetrics(req *pb.StreamMetricsRequest, stream grpc.ServerStreamingServer[pb.EncryptedMetrics]) error {
	nodeID := req.NodeId

	// Require routing_token for authorization
	routingToken := req.GetRoutingToken()
	if routingToken == "" {
		return status.Error(codes.InvalidArgument, "routing_token is required")
	}

	// Verify the caller owns this node via routing token
	node, err := s.hub.store.GetNode(nodeID)
	if err != nil {
		return status.Error(codes.NotFound, "Node not found")
	}
	if node.RoutingToken != routingToken {
		return status.Error(codes.PermissionDenied, "Not authorized to access this node's metrics")
	}

	ch := make(chan *pb.EncryptedMetrics, 10)
	s.hub.nodeMetricsMu.Lock()
	s.hub.nodeMetricStreams[nodeID] = ch
	s.hub.nodeMetricsMu.Unlock()

	defer func() {
		s.hub.nodeMetricsMu.Lock()
		delete(s.hub.nodeMetricStreams, nodeID)
		s.hub.nodeMetricsMu.Unlock()
	}()

	for {
		select {
		case metrics := <-ch:
			if err := stream.Send(metrics); err != nil {
				return err
			}
		case <-stream.Context().Done():
			return stream.Context().Err()
		}
	}
}

func (s *MobileServer) GetMetricsHistory(ctx context.Context, req *pb.GetMetricsHistoryRequest) (*pb.GetMetricsHistoryResponse, error) {
	// Zero-Trust: Require routing_token for retrieval
	routingToken := req.GetRoutingToken()
	if routingToken == "" {
		return nil, status.Error(codes.InvalidArgument, "routing_token required")
	}

	// Parse time range
	startTime := time.Now().Add(-24 * time.Hour) // Default: last 24 hours
	endTime := time.Now()
	if req.StartTime != nil {
		startTime = req.StartTime.AsTime()
	}
	if req.EndTime != nil {
		endTime = req.EndTime.AsTime()
	}

	// Limit results
	limit := int(req.GetLimit())
	if limit <= 0 || limit > 1000 {
		limit = 100 // Default limit
	}

	// Retrieve encrypted metrics from store
	metrics, err := s.hub.store.GetEncryptedMetricsHistory(routingToken, startTime, endTime, limit)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "Failed to retrieve metrics: %v", err)
	}

	// Convert to proto
	samples := make([]*pb.EncryptedMetrics, 0, len(metrics))
	for _, m := range metrics {
		samples = append(samples, &pb.EncryptedMetrics{
			NodeId:    m.NodeID,
			Timestamp: timestamppb.New(m.Timestamp),
			Encrypted: &common.EncryptedPayload{
				Ciphertext:        m.EncryptedBlob,
				Nonce:             m.Nonce,
				SenderFingerprint: m.SenderKeyID,
			},
		})
	}

	return &pb.GetMetricsHistoryResponse{
		Samples: samples,
	}, nil
}

func (s *MobileServer) StreamAlerts(req *pb.StreamAlertsRequest, stream grpc.ServerStreamingServer[common.Alert]) error {
	// Get routing token - either from node lookup or from context
	var routingToken string

	if req.NodeId != "" {
		// Look up node to get its routing token
		node, err := s.hub.store.GetNode(req.NodeId)
		if err != nil {
			return status.Error(codes.NotFound, "Node not found")
		}
		routingToken = node.RoutingToken
	} else {
		// Try to get from context (if set by auth interceptor)
		if rt := stream.Context().Value(ctxKeyRoutingToken); rt != nil {
			routingToken = rt.(string)
		}
	}

	if routingToken == "" {
		return status.Error(codes.InvalidArgument, "routing_token or node_id required")
	}

	// Create alert channel
	alertCh := make(chan *common.Alert, 10)

	// Register in userStreams
	s.hub.userStreamsMu.Lock()
	if s.hub.userStreams[routingToken] == nil {
		s.hub.userStreams[routingToken] = make(map[chan *common.Alert]bool)
	}
	s.hub.userStreams[routingToken][alertCh] = true
	s.hub.userStreamsMu.Unlock()

	// Cleanup on disconnect
	defer func() {
		s.hub.userStreamsMu.Lock()
		delete(s.hub.userStreams[routingToken], alertCh)
		if len(s.hub.userStreams[routingToken]) == 0 {
			delete(s.hub.userStreams, routingToken)
		}
		s.hub.userStreamsMu.Unlock()
		close(alertCh)
	}()

	// Forward alerts to stream
	for {
		select {
		case alert := <-alertCh:
			if err := stream.Send(alert); err != nil {
				return err
			}
		case <-stream.Context().Done():
			return stream.Context().Err()
		}
	}
}

func (s *MobileServer) StreamSignaling(stream grpc.BidiStreamingServer[pb.SignalMessage, pb.SignalMessage]) error {
	userID, _ := auth.GetUserID(stream.Context())
	sessionID := uuid.New().String()

	ch := make(chan *pb.SignalMessage, 10)
	s.hub.mobileSignalingMu.Lock()
	s.hub.mobileSignalingStreams[sessionID] = ch
	s.hub.mobileSignalingMu.Unlock()

	defer func() {
		s.hub.mobileSignalingMu.Lock()
		delete(s.hub.mobileSignalingStreams, sessionID)
		s.hub.mobileSignalingMu.Unlock()
		close(ch)
	}()

	// Send loop
	go func() {
		for msg := range ch {
			if err := stream.Send(msg); err != nil {
				return
			}
		}
	}()

	// Receive loop
	for {
		msg, err := stream.Recv()
		if err != nil {
			return err
		}

		// Route to node
		s.hub.nodeSignalingMu.RLock()
		if nodeCh, ok := s.hub.nodeSignalingStreams[msg.TargetId]; ok {
			msg.SourceId = sessionID
			msg.SourceUserId = userID
			select {
			case nodeCh <- msg:
			default:
			}
		}
		s.hub.nodeSignalingMu.RUnlock()
	}
}

// ============================================================================
// Proxy Management (Zero-Trust: encrypted content, Hub only sees IDs)
// ============================================================================

func (s *MobileServer) CreateProxyConfig(ctx context.Context, req *pb.CreateProxyConfigRequest) (*pb.CreateProxyConfigResponse, error) {
	routingToken := req.GetRoutingToken()
	if routingToken == "" {
		return nil, status.Error(codes.InvalidArgument, "routing_token is required")
	}

	proxyID := req.GetProxyId()
	if proxyID == "" {
		return nil, status.Error(codes.InvalidArgument, "proxy_id is required")
	}

	// Get tier limits
	tierCfg := s.getTierConfigByRoutingToken(routingToken)
	limits := tierCfg.ProxyManagement

	if !limits.Enabled {
		return &pb.CreateProxyConfigResponse{
			Success: false,
			Error:   "proxy management not available for your tier",
		}, nil
	}

	// Check proxy count limit (0 = unlimited)
	if limits.MaxProxies > 0 {
		count, err := s.hub.store.CountProxyConfigsByRoutingToken(routingToken)
		if err != nil {
			return nil, status.Errorf(codes.Internal, "failed to count proxies: %v", err)
		}
		if int(count) >= limits.MaxProxies {
			return &pb.CreateProxyConfigResponse{
				Success: false,
				Error:   fmt.Sprintf("proxy limit reached: %d/%d", count, limits.MaxProxies),
			}, nil
		}
	}

	// Create proxy config
	cfg := &model.ProxyConfig{
		ProxyID:      proxyID,
		RoutingToken: routingToken,
	}

	if err := s.hub.store.CreateProxyConfig(cfg); err != nil {
		// Check for duplicate
		if strings.Contains(err.Error(), "UNIQUE") || strings.Contains(err.Error(), "duplicate") {
			return &pb.CreateProxyConfigResponse{
				Success: false,
				Error:   "proxy_id already exists",
			}, nil
		}
		return nil, status.Errorf(codes.Internal, "failed to create proxy config: %v", err)
	}

	return &pb.CreateProxyConfigResponse{Success: true}, nil
}

func (s *MobileServer) ListProxyConfigs(ctx context.Context, req *pb.ListProxyConfigsRequest) (*pb.ListProxyConfigsResponse, error) {
	routingToken := req.GetRoutingToken()
	if routingToken == "" {
		return nil, status.Error(codes.InvalidArgument, "routing_token is required")
	}

	proxies, err := s.hub.store.ListProxyConfigsByRoutingToken(routingToken)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to list proxies: %v", err)
	}

	var pbProxies []*pb.ProxyConfigInfo
	for _, p := range proxies {
		if p.Deleted {
			continue
		}

		// Get revision count and latest revision
		revCount, _ := s.hub.store.CountProxyRevisions(p.ProxyID)
		latestRev, _ := s.hub.store.GetLatestProxyRevision(p.ProxyID)

		var latestRevNum int64
		var totalSize int32
		if latestRev != nil {
			latestRevNum = latestRev.RevisionNum
		}

		// Get total size of all revisions for this proxy
		revisions, _ := s.hub.store.ListProxyRevisions(p.ProxyID)
		for _, r := range revisions {
			totalSize += r.SizeBytes
		}

		pbProxies = append(pbProxies, &pb.ProxyConfigInfo{
			ProxyId:        p.ProxyID,
			RevisionCount:  revCount,
			LatestRevision: latestRevNum,
			CreatedAt:      timestamppb.New(p.CreatedAt),
			UpdatedAt:      timestamppb.New(p.UpdatedAt),
			TotalSizeBytes: totalSize,
		})
	}

	return &pb.ListProxyConfigsResponse{Proxies: pbProxies}, nil
}

func (s *MobileServer) DeleteProxyConfig(ctx context.Context, req *pb.DeleteProxyConfigRequest) (*pb.Empty, error) {
	routingToken := req.GetRoutingToken()
	if routingToken == "" {
		return nil, status.Error(codes.InvalidArgument, "routing_token is required")
	}

	proxyID := req.GetProxyId()
	if proxyID == "" {
		return nil, status.Error(codes.InvalidArgument, "proxy_id is required")
	}

	// Verify ownership
	cfg, err := s.hub.store.GetProxyConfig(proxyID)
	if err != nil {
		return nil, status.Error(codes.NotFound, "proxy config not found")
	}

	if cfg.RoutingToken != routingToken {
		return nil, status.Error(codes.PermissionDenied, "not authorized to delete this proxy")
	}

	// Soft delete
	if err := s.hub.store.DeleteProxyConfig(proxyID); err != nil {
		return nil, status.Errorf(codes.Internal, "failed to delete proxy: %v", err)
	}

	return &pb.Empty{}, nil
}

func (s *MobileServer) PushRevision(ctx context.Context, req *pb.PushRevisionRequest) (*pb.PushRevisionResponse, error) {
	routingToken := req.GetRoutingToken()
	if routingToken == "" {
		return nil, status.Error(codes.InvalidArgument, "routing_token is required")
	}

	proxyID := req.GetProxyId()
	if proxyID == "" {
		return nil, status.Error(codes.InvalidArgument, "proxy_id is required")
	}

	// Verify ownership
	cfg, err := s.hub.store.GetProxyConfig(proxyID)
	if err != nil {
		return nil, status.Error(codes.NotFound, "proxy config not found")
	}

	if cfg.RoutingToken != routingToken {
		return nil, status.Error(codes.PermissionDenied, "not authorized to push to this proxy")
	}

	// Get tier limits
	tierCfg := s.getTierConfigByRoutingToken(routingToken)
	limits := tierCfg.ProxyManagement

	// Check storage limit (0 = unlimited)
	if limits.MaxStorageKB > 0 {
		currentStorage, _ := s.hub.store.GetTotalProxyStorageByRoutingToken(routingToken)
		newTotal := currentStorage + int64(req.SizeBytes)
		limitBytes := int64(limits.MaxStorageKB) * 1024

		if newTotal > limitBytes {
			return &pb.PushRevisionResponse{
				Success:        false,
				Error:          "storage limit exceeded",
				StorageUsedKb:  int32(currentStorage / 1024),
				StorageLimitKb: int32(limits.MaxStorageKB),
			}, nil
		}
	}

	// Get current revision count to determine next revision number
	latestRev, _ := s.hub.store.GetLatestProxyRevision(proxyID)
	nextRevNum := int64(1)
	if latestRev != nil {
		nextRevNum = latestRev.RevisionNum + 1
	}

	// Create revision
	rev := &model.ProxyRevision{
		ProxyID:       proxyID,
		RevisionNum:   nextRevNum,
		EncryptedBlob: req.EncryptedBlob,
		SizeBytes:     req.SizeBytes,
	}

	if err := s.hub.store.CreateProxyRevision(rev); err != nil {
		return nil, status.Errorf(codes.Internal, "failed to create revision: %v", err)
	}

	// Prune old revisions based on tier limit (0 = unlimited)
	revisionsLimit := limits.MaxRevisionsPerProxy
	var revisionsKept int32
	if revisionsLimit > 0 {
		deleted, _ := s.hub.store.DeleteOldestProxyRevisions(proxyID, revisionsLimit)
		revisionsKept = int32(revisionsLimit)
		_ = deleted
	} else {
		count, _ := s.hub.store.CountProxyRevisions(proxyID)
		revisionsKept = int32(count)
	}

	// Calculate updated storage
	currentStorage, _ := s.hub.store.GetTotalProxyStorageByRoutingToken(routingToken)

	return &pb.PushRevisionResponse{
		Success:         true,
		RevisionNum:     nextRevNum,
		RevisionsKept:   revisionsKept,
		RevisionsLimit:  int32(revisionsLimit),
		StorageUsedKb:   int32(currentStorage / 1024),
		StorageLimitKb:  int32(limits.MaxStorageKB),
	}, nil
}

func (s *MobileServer) GetRevision(ctx context.Context, req *pb.GetRevisionRequest) (*pb.GetRevisionResponse, error) {
	routingToken := req.GetRoutingToken()
	if routingToken == "" {
		return nil, status.Error(codes.InvalidArgument, "routing_token is required")
	}

	proxyID := req.GetProxyId()
	if proxyID == "" {
		return nil, status.Error(codes.InvalidArgument, "proxy_id is required")
	}

	// Verify ownership
	cfg, err := s.hub.store.GetProxyConfig(proxyID)
	if err != nil {
		return nil, status.Error(codes.NotFound, "proxy config not found")
	}

	if cfg.RoutingToken != routingToken {
		return nil, status.Error(codes.PermissionDenied, "not authorized to access this proxy")
	}

	// Get revision (0 = latest)
	var rev *model.ProxyRevision
	revNum := req.GetRevisionNum()
	if revNum == 0 {
		rev, err = s.hub.store.GetLatestProxyRevision(proxyID)
	} else {
		rev, err = s.hub.store.GetProxyRevision(proxyID, revNum)
	}

	if err != nil {
		return nil, status.Error(codes.NotFound, "revision not found")
	}

	return &pb.GetRevisionResponse{
		EncryptedBlob: rev.EncryptedBlob,
		RevisionNum:   rev.RevisionNum,
		CreatedAt:     timestamppb.New(rev.CreatedAt),
		SizeBytes:     rev.SizeBytes,
	}, nil
}

func (s *MobileServer) ListRevisions(ctx context.Context, req *pb.ListRevisionsRequest) (*pb.ListRevisionsResponse, error) {
	routingToken := req.GetRoutingToken()
	if routingToken == "" {
		return nil, status.Error(codes.InvalidArgument, "routing_token is required")
	}

	proxyID := req.GetProxyId()
	if proxyID == "" {
		return nil, status.Error(codes.InvalidArgument, "proxy_id is required")
	}

	// Verify ownership
	cfg, err := s.hub.store.GetProxyConfig(proxyID)
	if err != nil {
		return nil, status.Error(codes.NotFound, "proxy config not found")
	}

	if cfg.RoutingToken != routingToken {
		return nil, status.Error(codes.PermissionDenied, "not authorized to access this proxy")
	}

	revisions, err := s.hub.store.ListProxyRevisions(proxyID)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to list revisions: %v", err)
	}

	var pbRevisions []*pb.RevisionMeta
	for _, r := range revisions {
		pbRevisions = append(pbRevisions, &pb.RevisionMeta{
			RevisionNum: r.RevisionNum,
			SizeBytes:   r.SizeBytes,
			CreatedAt:   timestamppb.New(r.CreatedAt),
		})
	}

	return &pb.ListRevisionsResponse{Revisions: pbRevisions}, nil
}

func (s *MobileServer) FlushRevisions(ctx context.Context, req *pb.FlushRevisionsRequest) (*pb.FlushRevisionsResponse, error) {
	routingToken := req.GetRoutingToken()
	if routingToken == "" {
		return nil, status.Error(codes.InvalidArgument, "routing_token is required")
	}

	proxyID := req.GetProxyId()
	if proxyID == "" {
		return nil, status.Error(codes.InvalidArgument, "proxy_id is required")
	}

	// Verify ownership
	cfg, err := s.hub.store.GetProxyConfig(proxyID)
	if err != nil {
		return nil, status.Error(codes.NotFound, "proxy config not found")
	}

	if cfg.RoutingToken != routingToken {
		return nil, status.Error(codes.PermissionDenied, "not authorized to flush this proxy's revisions")
	}

	keepCount := int(req.GetKeepCount())
	if keepCount < 1 {
		keepCount = 1 // Always keep at least the latest
	}

	deleted, err := s.hub.store.DeleteOldestProxyRevisions(proxyID, keepCount)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to flush revisions: %v", err)
	}

	remaining, _ := s.hub.store.CountProxyRevisions(proxyID)

	return &pb.FlushRevisionsResponse{
		Success:        true,
		DeletedCount:   int32(deleted),
		RemainingCount: int32(remaining),
	}, nil
}

// getTierConfigByRoutingToken retrieves tier configuration for a routing token
func (s *MobileServer) getTierConfigByRoutingToken(routingToken string) *tier.TierConfig {
	info, err := s.hub.store.GetRoutingTokenInfo(routingToken)
	if err != nil || info.Tier == "" {
		return s.hub.tierConfig.GetTierOrDefault("free")
	}
	return s.hub.tierConfig.GetTierOrDefault(info.Tier)
}

// ============================================================================
// AuthServer - Authentication service
// ============================================================================

type AuthServer struct {
	pb.UnimplementedAuthServiceServer
	hub *HubServer
}

func (s *AuthServer) RegisterUser(ctx context.Context, req *pb.RegisterUserRequest) (*pb.RegisterUserResponse, error) {
	// Validate invite code
	if req.InviteCode != "" {
		invite, err := s.hub.store.GetInviteCode(req.InviteCode)
		if err != nil {
			return nil, status.Error(codes.InvalidArgument, "Invalid invite code")
		}
		if err := s.hub.store.ConsumeInviteCode(req.InviteCode); err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "Invite code error: %v", err)
		}

		// Create user with tier from invite
		// BlindIndex is required to be unique - if not provided, generate from UUID
		blindIndex := req.BlindIndex
		if blindIndex == "" {
			blindIndex = uuid.New().String()
		}
		user := &model.User{
			ID:         uuid.New().String(),
			BlindIndex: blindIndex,
			Tier:       invite.TierID,
			InviteCode: req.InviteCode,
			CreatedAt:  time.Now(),
		}
		if err := s.hub.store.SaveUser(user); err != nil {
			return nil, status.Errorf(codes.Internal, "Failed to create user: %v", err)
		}

		// Generate tokens
		token, err := s.hub.tokenManager.GenerateMobileToken(user.ID, "")
		if err != nil {
			return nil, status.Errorf(codes.Internal, "Failed to generate token: %v", err)
		}

		tierCfg := s.hub.tierConfig.GetTierOrDefault(invite.TierID)

		return &pb.RegisterUserResponse{
			UserId:       user.ID,
			Tier:         invite.TierID,
			MaxNodes:     int32(tierCfg.MaxNodes),
			JwtToken:     token,
			RefreshToken: token, // Using same token for now
		}, nil
	}

	return nil, status.Error(codes.InvalidArgument, "Invite code required")
}

func (s *AuthServer) RegisterDevice(ctx context.Context, req *pb.RegisterDeviceRequest) (*pb.Empty, error) {
	// Zero-Trust: Use FCM topic (blind) instead of UserID
	// The FCMTopic should be derived from user's secret on the client side
	fcmTopic := req.UserId // TODO: Rename field in proto to fcm_topic
	token := &model.FCMToken{
		Token:      req.FcmToken,
		FCMTopic:   fcmTopic,
		DeviceType: req.DeviceType,
		UpdatedAt:  time.Now(),
	}
	s.hub.store.SaveFCMToken(token)
	return &pb.Empty{}, nil
}

func (s *AuthServer) UpdateLicense(ctx context.Context, req *pb.UpdateLicenseRequest) (*pb.UpdateLicenseResponse, error) {
	routingToken := req.GetRoutingToken()
	if routingToken == "" {
		return nil, status.Error(codes.InvalidArgument, "routing_token is required")
	}

	// Look up tier from license key prefix
	tierID, tierCfg := s.hub.getTierByLicenseKey(req.GetLicenseKey())

	// Update routing token's tier
	info, err := s.hub.store.GetRoutingTokenInfo(routingToken)
	if err != nil {
		return nil, status.Error(codes.NotFound, "routing token not found")
	}

	info.LicenseKey = req.GetLicenseKey()
	info.Tier = tierID
	if err := s.hub.store.SaveRoutingTokenInfo(info); err != nil {
		return nil, status.Errorf(codes.Internal, "failed to update license: %v", err)
	}

	maxNodes := tierCfg.MaxNodes
	if maxNodes == 0 {
		maxNodes = -1 // -1 indicates unlimited
	}

	return &pb.UpdateLicenseResponse{
		Tier:     tierID,
		MaxNodes: int32(maxNodes),
		Valid:    true,
	}, nil
}

// ============================================================================
// PairingServer - PAKE-based pairing service (Hub learns nothing)
// ============================================================================

type PairingServer struct {
	pb.UnimplementedPairingServiceServer
	hub *HubServer

	// Active PAKE sessions: sessionCode -> channel for relaying messages
	pakeSessions   map[string]*pakeSession
	pakeSessionsMu sync.RWMutex
}

type pakeSession struct {
	code       string
	cliChan    chan *pb.PakeMessage // Messages from CLI to Node
	nodeChan   chan *pb.PakeMessage // Messages from Node to CLI
	created    time.Time
	cliJoined  bool
	nodeJoined bool
	closed     bool      // Flag to prevent send on closed channel
	closeMu    sync.Mutex // Protects closed flag and channel close operations
}

func NewPairingServer(hub *HubServer) *PairingServer {
	ps := &PairingServer{
		hub:          hub,
		pakeSessions: make(map[string]*pakeSession),
	}
	// Cleanup expired sessions periodically
	go ps.cleanupLoop()
	return ps
}

func (s *PairingServer) cleanupLoop() {
	ticker := time.NewTicker(30 * time.Second)
	for range ticker.C {
		s.pakeSessionsMu.Lock()
		now := time.Now()
		for code, sess := range s.pakeSessions {
			// Sessions expire after 5 minutes
			if now.Sub(sess.created) > 5*time.Minute {
				// Safely close channels with synchronization
				sess.closeMu.Lock()
				if !sess.closed {
					sess.closed = true
					close(sess.cliChan)
					close(sess.nodeChan)
				}
				sess.closeMu.Unlock()
				delete(s.pakeSessions, code)
			}
		}
		s.pakeSessionsMu.Unlock()
	}
}

// safeSend sends a message to a channel safely, handling closed channels
func (sess *pakeSession) safeSend(ch chan *pb.PakeMessage, msg *pb.PakeMessage) bool {
	sess.closeMu.Lock()
	defer sess.closeMu.Unlock()
	if sess.closed {
		return false
	}
	select {
	case ch <- msg:
		return true
	default:
		return false // Channel full
	}
}

// PakeExchange handles bidirectional PAKE message relay
// Hub only relays messages - cannot derive the shared secret
func (s *PairingServer) PakeExchange(stream grpc.BidiStreamingServer[pb.PakeMessage, pb.PakeMessage]) error {
	// First message determines role and session code
	firstMsg, err := stream.Recv()
	if err != nil {
		return err
	}

	sessionCode := firstMsg.SessionCode
	role := firstMsg.Role

	if sessionCode == "" {
		return status.Error(codes.InvalidArgument, "session_code required")
	}
	// Validate session code length to prevent DoS via large keys
	if len(sessionCode) > 128 {
		return status.Error(codes.InvalidArgument, "session_code too long (max 128 chars)")
	}
	if role != "cli" && role != "node" {
		return status.Error(codes.InvalidArgument, "role must be 'cli' or 'node'")
	}

	// Get or create session
	s.pakeSessionsMu.Lock()
	sess, exists := s.pakeSessions[sessionCode]
	if !exists {
		sess = &pakeSession{
			code:     sessionCode,
			cliChan:  make(chan *pb.PakeMessage, 10),
			nodeChan: make(chan *pb.PakeMessage, 10),
			created:  time.Now(),
		}
		s.pakeSessions[sessionCode] = sess
	}

	// Mark role as joined
	if role == "cli" {
		if sess.cliJoined {
			s.pakeSessionsMu.Unlock()
			return status.Error(codes.AlreadyExists, "CLI already connected to this session")
		}
		sess.cliJoined = true
	} else {
		if sess.nodeJoined {
			s.pakeSessionsMu.Unlock()
			return status.Error(codes.AlreadyExists, "Node already connected to this session")
		}
		sess.nodeJoined = true
	}
	s.pakeSessionsMu.Unlock()

	// Determine send/receive channels based on role
	var sendChan, recvChan chan *pb.PakeMessage
	if role == "cli" {
		sendChan = sess.nodeChan // CLI sends to node
		recvChan = sess.cliChan  // CLI receives from node
	} else {
		sendChan = sess.cliChan  // Node sends to CLI
		recvChan = sess.nodeChan // Node receives from CLI
	}

	// Forward the first message to peer using safe send
	sess.safeSend(sendChan, firstMsg)

	// Create context for cleanup
	ctx := stream.Context()

	// Relay messages in both directions
	errChan := make(chan error, 2)

	// Goroutine: receive from peer and send to this stream
	go func() {
		for {
			select {
			case <-ctx.Done():
				errChan <- ctx.Err()
				return
			case msg, ok := <-recvChan:
				if !ok {
					errChan <- nil
					return
				}
				if err := stream.Send(msg); err != nil {
					errChan <- err
					return
				}
			}
		}
	}()

	// Main loop: receive from this stream and send to peer
	go func() {
		for {
			msg, err := stream.Recv()
			if err != nil {
				errChan <- err
				return
			}
			// Use safeSend to avoid panic on closed channel
			if !sess.safeSend(sendChan, msg) {
				// Session closed or channel full
				select {
				case <-ctx.Done():
					errChan <- ctx.Err()
				default:
					errChan <- nil
				}
				return
			}
		}
	}()

	// Wait for either goroutine to finish
	err = <-errChan

	// Cleanup on disconnect
	s.pakeSessionsMu.Lock()
	if role == "cli" {
		sess.cliJoined = false
	} else {
		sess.nodeJoined = false
	}
	// Remove session if both disconnected
	if !sess.cliJoined && !sess.nodeJoined {
		// Safely close channels before deleting
		sess.closeMu.Lock()
		if !sess.closed {
			sess.closed = true
			close(sess.cliChan)
			close(sess.nodeChan)
		}
		sess.closeMu.Unlock()
		delete(s.pakeSessions, sessionCode)
	}
	s.pakeSessionsMu.Unlock()

	if err == io.EOF {
		return nil
	}
	return err
}

// SubmitSignedCert handles QR-based offline pairing
// Node submits the certificate signed by CLI's Root CA
func (s *PairingServer) SubmitSignedCert(ctx context.Context, req *pb.SubmitSignedCertRequest) (*pb.Empty, error) {
	if req.CertPem == "" {
		return nil, status.Error(codes.InvalidArgument, "cert_pem required")
	}

	// Parse the certificate to extract node ID and verify
	block, _ := pem.Decode([]byte(req.CertPem))
	if block == nil {
		return nil, status.Error(codes.InvalidArgument, "invalid certificate PEM")
	}

	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "failed to parse certificate: %v", err)
	}

	nodeID := req.NodeId
	if nodeID == "" {
		nodeID = cert.Subject.CommonName
	}

	// Verify the CA certificate if provided
	if req.CaPem != "" {
		caBlock, _ := pem.Decode([]byte(req.CaPem))
		if caBlock == nil {
			return nil, status.Error(codes.InvalidArgument, "invalid CA certificate PEM")
		}
		caCert, err := x509.ParseCertificate(caBlock.Bytes)
		if err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "failed to parse CA certificate: %v", err)
		}
		// Verify cert is signed by this CA
		roots := x509.NewCertPool()
		roots.AddCert(caCert)
		if _, err := cert.Verify(x509.VerifyOptions{Roots: roots}); err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "certificate not signed by provided CA: %v", err)
		}
	}

	// Zero-Trust: Extract routing token from context (set during pairing)
	routingToken := ""
	if rt := ctx.Value(ctxKeyRoutingToken); rt != nil {
		routingToken = rt.(string)
	}

	// Store the node with routing token
	node := &model.Node{
		ID:           nodeID,
		RoutingToken: routingToken,
		CertPEM:      req.CertPem,
		Status:       "offline",
	}
	if err := s.hub.store.SaveNode(node); err != nil {
		return nil, status.Errorf(codes.Internal, "failed to save node: %v", err)
	}

	log.Printf("[Pairing] Node %s registered via QR pairing (fingerprint: %s)", nodeID, req.Fingerprint)

	return &pb.Empty{}, nil
}

// ============================================================================
// AdminServer - Hub administration
// ============================================================================

type AdminServer struct {
	pb.UnimplementedAdminServiceServer
	hub *HubServer
}

func NewAdminServer(hub *HubServer) *AdminServer {
	return &AdminServer{hub: hub}
}

func (s *AdminServer) GetSystemStats(ctx context.Context, req *pb.GetSystemStatsRequest) (*pb.SystemStats, error) {
	// Use count queries instead of loading all records to prevent DoS
	userCount, err := s.hub.store.CountUsers()
	if err != nil {
		userCount = 0
	}

	nodeCount, onlineCount, err := s.hub.store.CountNodes()
	if err != nil {
		nodeCount = 0
		onlineCount = 0
	}

	return &pb.SystemStats{
		TotalUsers:  int32(userCount),
		TotalNodes:  int32(nodeCount),
		OnlineNodes: int32(onlineCount),
	}, nil
}

// ============================================================================
// Logs Management (Admin)
// ============================================================================

func (s *AdminServer) GetLogsStats(ctx context.Context, req *pb.GetLogsStatsRequest) (*pb.LogsStats, error) {
	totalLogs, err := s.hub.store.CountAllLogs()
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to count logs: %v", err)
	}

	logsByToken, err := s.hub.store.GetLogsStatsByRoutingToken()
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to get logs stats: %v", err)
	}

	storageByToken, err := s.hub.store.GetLogStorageByRoutingToken()
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to get storage stats: %v", err)
	}

	var totalStorage int64
	for _, size := range storageByToken {
		totalStorage += size
	}

	oldest, newest, _ := s.hub.store.GetOldestAndNewestLog()

	resp := &pb.LogsStats{
		TotalLogs:             totalLogs,
		TotalStorageBytes:     totalStorage,
		LogsByRoutingToken:    logsByToken,
		StorageByRoutingToken: storageByToken,
	}

	if !oldest.IsZero() {
		resp.OldestLog = timestamppb.New(oldest)
	}
	if !newest.IsZero() {
		resp.NewestLog = timestamppb.New(newest)
	}

	return resp, nil
}

func (s *AdminServer) ListLogs(ctx context.Context, req *pb.ListLogsRequest) (*pb.ListLogsResponse, error) {
	if req.RoutingToken == "" {
		return nil, status.Error(codes.InvalidArgument, "routing_token is required")
	}

	pageSize := int(req.PageSize)
	if pageSize <= 0 {
		pageSize = 100
	}
	if pageSize > 1000 {
		pageSize = 1000
	}

	offset := 0
	if req.PageToken != "" {
		fmt.Sscanf(req.PageToken, "%d", &offset)
	}

	var start, end time.Time
	if req.StartTime != nil {
		start = req.StartTime.AsTime()
	}
	if req.EndTime != nil {
		end = req.EndTime.AsTime()
	}

	logs, err := s.hub.store.GetEncryptedLogsByNode(req.RoutingToken, req.NodeId, start, end, pageSize+1, offset)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to list logs: %v", err)
	}

	var nextPageToken string
	if len(logs) > pageSize {
		logs = logs[:pageSize]
		nextPageToken = fmt.Sprintf("%d", offset+pageSize)
	}

	entries := make([]*pb.AdminLogEntry, len(logs))
	for i, l := range logs {
		entries[i] = &pb.AdminLogEntry{
			Id:                 l.ID,
			NodeId:             l.NodeID,
			RoutingToken:       l.RoutingToken,
			Timestamp:          timestamppb.New(l.Timestamp),
			EncryptedSizeBytes: int32(len(l.EncryptedBlob)),
			SenderKeyId:        l.SenderKeyID,
		}
	}

	totalCount, _ := s.hub.store.CountLogs(req.RoutingToken)

	return &pb.ListLogsResponse{
		Logs:          entries,
		NextPageToken: nextPageToken,
		TotalCount:    int32(totalCount),
	}, nil
}

func (s *AdminServer) DeleteLogs(ctx context.Context, req *pb.DeleteLogsRequest) (*pb.DeleteLogsResponse, error) {
	if req.RoutingToken == "" {
		return nil, status.Error(codes.InvalidArgument, "routing_token is required")
	}

	// Get storage size before delete for reporting
	storageBefore, _ := s.hub.store.GetLogStorageByRoutingToken()
	sizeBefore := storageBefore[req.RoutingToken]

	var deleted int64
	var err error

	if req.DeleteAll {
		deleted, err = s.hub.store.DeleteLogsByRoutingToken(req.RoutingToken)
	} else if req.NodeId != "" {
		deleted, err = s.hub.store.DeleteLogsByNodeID(req.RoutingToken, req.NodeId)
	} else if req.Before != nil {
		deleted, err = s.hub.store.DeleteLogsBefore(req.RoutingToken, req.Before.AsTime())
	} else {
		return nil, status.Error(codes.InvalidArgument, "specify delete_all, node_id, or before")
	}

	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to delete logs: %v", err)
	}

	// Calculate freed space
	storageAfter, _ := s.hub.store.GetLogStorageByRoutingToken()
	sizeAfter := storageAfter[req.RoutingToken]
	freedBytes := sizeBefore - sizeAfter

	return &pb.DeleteLogsResponse{
		DeletedCount: deleted,
		FreedBytes:   freedBytes,
	}, nil
}

func (s *AdminServer) CleanupOldLogs(ctx context.Context, req *pb.CleanupOldLogsRequest) (*pb.CleanupOldLogsResponse, error) {
	if req.OlderThanDays <= 0 {
		return nil, status.Error(codes.InvalidArgument, "older_than_days must be positive")
	}

	before := time.Now().AddDate(0, 0, -int(req.OlderThanDays))

	// Get stats before cleanup
	statsBefore, _ := s.hub.store.GetLogsStatsByRoutingToken()
	storageBefore, _ := s.hub.store.GetLogStorageByRoutingToken()

	var totalBefore int64
	for _, size := range storageBefore {
		totalBefore += size
	}

	if req.DryRun {
		// Just report what would be deleted
		var wouldDelete int64
		deletedByToken := make(map[string]int64)

		for token := range statsBefore {
			logs, _ := s.hub.store.GetEncryptedLogsByNode(token, "", time.Time{}, before, 0, 0)
			count := int64(len(logs))
			if count > 0 {
				deletedByToken[token] = count
				wouldDelete += count
			}
		}

		return &pb.CleanupOldLogsResponse{
			DeletedCount:          wouldDelete,
			FreedBytes:            0, // Can't estimate without actually counting blob sizes
			DeletedByRoutingToken: deletedByToken,
		}, nil
	}

	// Actually delete
	err := s.hub.store.DeleteOldLogs(before)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to cleanup logs: %v", err)
	}

	// Get stats after cleanup
	statsAfter, _ := s.hub.store.GetLogsStatsByRoutingToken()
	storageAfter, _ := s.hub.store.GetLogStorageByRoutingToken()

	var totalAfter int64
	for _, size := range storageAfter {
		totalAfter += size
	}

	deletedByToken := make(map[string]int64)
	for token, countBefore := range statsBefore {
		countAfter := statsAfter[token]
		if countBefore > countAfter {
			deletedByToken[token] = countBefore - countAfter
		}
	}

	var totalDeleted int64
	for _, count := range deletedByToken {
		totalDeleted += count
	}

	return &pb.CleanupOldLogsResponse{
		DeletedCount:          totalDeleted,
		FreedBytes:            totalBefore - totalAfter,
		DeletedByRoutingToken: deletedByToken,
	}, nil
}

// ============================================================================
// Service Registration
// ============================================================================

// RegisterServices registers all Hub gRPC services on the given server
func (s *HubServer) RegisterServices(grpcServer *grpc.Server) {
	pb.RegisterNodeServiceServer(grpcServer, s.Node)
	pb.RegisterMobileServiceServer(grpcServer, s.Mobile)
	pb.RegisterAuthServiceServer(grpcServer, s.Auth)
	pb.RegisterPairingServiceServer(grpcServer, s.Pairing)
	pb.RegisterAdminServiceServer(grpcServer, s.Admin)
}
