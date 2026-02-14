package core

import (
	"context"
	"crypto/ed25519"
	"log"
	"sync"

	"github.com/ivere27/nitella/pkg/api/common"
	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	"github.com/ivere27/nitella/pkg/hub/routing"
	"github.com/ivere27/nitella/pkg/identity"
	"github.com/ivere27/nitella/pkg/p2p"
	"google.golang.org/grpc"
	"google.golang.org/grpc/metadata"
)

// Config holds the configuration for a Controller.
type Config struct {
	DataDir   string
	CacheDir  string
	DebugMode bool

	// P2P settings (disabled by default)
	P2PEnabled bool
	P2PMode    common.P2PMode
	STUNServer string

	// RoutingSecret is used to derive per-node routing tokens.
	// CLI: stored userSecret; Mobile: identity.RootKey bytes.
	RoutingSecret []byte
}

// Controller is the shared business logic layer used by both CLI and mobile.
// It manages identity, Hub connection, E2E encrypted commands, and node operations.
type Controller struct {
	mu sync.RWMutex

	cfg      Config
	identity *identity.Identity

	// Hub connection
	hubConn      *grpc.ClientConn
	mobileClient pbHub.MobileServiceClient
	adminClient  pbHub.AdminServiceClient
	authClient   pbHub.AuthServiceClient

	// Node state
	nodes          map[string]*NodeInfo
	nodePublicKeys map[string]ed25519.PublicKey

	// Local (direct) connections to nitellad instances
	localClients map[string]*LocalConnection

	// P2P transport (nil when P2P disabled)
	p2pTransport       *p2p.Transport
	p2pTransportCancel context.CancelFunc

	// Auth token for Hub RPCs (used by P2P signaling)
	authToken string

	// Event callbacks (optional)
	eventHandler       EventHandler
	p2pApprovalHandler func(nodeID string, req *p2p.ApprovalRequest)
}

// New creates a new Controller with the given configuration.
func New(cfg Config) *Controller {
	if cfg.P2PMode == common.P2PMode_P2P_MODE_UNSPECIFIED {
		cfg.P2PMode = common.P2PMode_P2P_MODE_HUB
	}
	return &Controller{
		cfg:            cfg,
		nodes:          make(map[string]*NodeInfo),
		nodePublicKeys: make(map[string]ed25519.PublicKey),
		localClients:   make(map[string]*LocalConnection),
	}
}

// SetIdentity sets the cryptographic identity for E2E operations.
func (c *Controller) SetIdentity(id *identity.Identity) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.identity = id
	// Use RootKey as routing secret if none provided
	if len(c.cfg.RoutingSecret) == 0 && id != nil && id.RootKey != nil {
		c.cfg.RoutingSecret = id.RootKey
	}
}

// Identity returns the current identity (may be nil).
func (c *Controller) Identity() *identity.Identity {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.identity
}

// SetEventHandler sets the handler for async events.
func (c *Controller) SetEventHandler(h EventHandler) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.eventHandler = h
}

// SetHubConnection sets an externally-managed Hub gRPC connection.
// Consumers that manage their own TLS/auth (CLI, mobile) use this
// instead of ConnectToHub. Creates all service clients from the connection.
func (c *Controller) SetHubConnection(conn *grpc.ClientConn) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.hubConn = conn
	c.mobileClient = pbHub.NewMobileServiceClient(conn)
	c.adminClient = pbHub.NewAdminServiceClient(conn)
	c.authClient = pbHub.NewAuthServiceClient(conn)
}

// HubClient returns the underlying MobileServiceClient, or nil.
func (c *Controller) HubClient() pbHub.MobileServiceClient {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.mobileClient
}

// RegisterNodeKey caches a node's public key for E2E encryption.
func (c *Controller) RegisterNodeKey(nodeID string, pubKey ed25519.PublicKey) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.nodePublicKeys[nodeID] = pubKey
}

// GetNodePublicKey returns the cached public key for a node.
// Returns nil if not found.
func (c *Controller) GetNodePublicKey(nodeID string) ed25519.PublicKey {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.nodePublicKeys[nodeID]
}

// RegisterNode adds or updates a node in the controller's node map.
func (c *Controller) RegisterNode(info *NodeInfo) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.nodes[info.NodeID] = info
	if info.PublicKey != nil {
		c.nodePublicKeys[info.NodeID] = info.PublicKey
	}
}

// RemoveNode removes a node from the controller.
func (c *Controller) RemoveNode(nodeID string) {
	c.mu.Lock()
	defer c.mu.Unlock()
	delete(c.nodes, nodeID)
	delete(c.nodePublicKeys, nodeID)
}

// SetP2PTransport sets the P2P transport (managed externally by consumers).
func (c *Controller) SetP2PTransport(t *p2p.Transport) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.p2pTransport = t
}

// Shutdown releases resources held by the controller.
func (c *Controller) Shutdown() {
	c.mu.Lock()
	defer c.mu.Unlock()

	c.stopP2PTransportLocked()
	// Note: hubConn is not closed here — consumers own the connection lifecycle.
}

// Config returns a copy of the current configuration.
func (c *Controller) Config() Config {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.cfg
}

// SetP2PMode updates the P2P routing mode at runtime.
func (c *Controller) SetP2PMode(mode common.P2PMode) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.cfg.P2PMode = mode
}

// P2PEnabled returns whether P2P is currently enabled.
func (c *Controller) P2PEnabled() bool {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.cfg.P2PEnabled
}

// SetAuthToken sets the auth token used for Hub RPCs (P2P signaling, etc).
func (c *Controller) SetAuthToken(token string) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.authToken = token
}

// GenerateRoutingToken derives a routing token for a node from the routing secret.
func (c *Controller) GenerateRoutingToken(nodeID string) string {
	c.mu.RLock()
	secret := c.cfg.RoutingSecret
	c.mu.RUnlock()

	if len(secret) == 0 {
		return ""
	}
	return routing.GenerateRoutingToken(nodeID, secret)
}

// SetP2PEnabled enables or disables P2P at runtime.
// When enabling, starts the P2P transport if identity and Hub connection are available.
// When disabling, stops the running transport.
func (c *Controller) SetP2PEnabled(enabled bool) {
	c.mu.Lock()
	defer c.mu.Unlock()

	if c.cfg.P2PEnabled == enabled {
		return
	}
	c.cfg.P2PEnabled = enabled

	if enabled {
		c.startP2PTransportLocked()
	} else {
		c.stopP2PTransportLocked()
	}
}

// StartP2PTransport starts the P2P transport if P2P is enabled and prerequisites are met.
// Safe to call multiple times; no-op if already running or P2P is disabled.
func (c *Controller) StartP2PTransport() {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.startP2PTransportLocked()
}

// StopP2PTransport stops the P2P transport if running.
func (c *Controller) StopP2PTransport() {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.stopP2PTransportLocked()
}

// P2PTransport returns the current P2P transport, or nil if not running.
func (c *Controller) P2PTransport() *p2p.Transport {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.p2pTransport
}

func (c *Controller) startP2PTransportLocked() {
	if !c.cfg.P2PEnabled {
		return
	}
	if c.p2pTransport != nil {
		return
	}
	if c.identity == nil || c.identity.RootKey == nil {
		return
	}
	if c.mobileClient == nil {
		return
	}

	transport := p2p.NewTransport(c.identity.Fingerprint, c.mobileClient)
	transport.SetIdentity(c.identity.RootKey)
	if c.cfg.STUNServer != "" {
		transport.SetSTUNServer(c.cfg.STUNServer)
	}

	// Register known node keys
	for nodeID, pk := range c.nodePublicKeys {
		transport.RegisterNodeKey(nodeID, pk)
	}

	// Set handlers
	if c.eventHandler != nil {
		transport.SetPeerStatusHandler(func(nodeID string, connected bool) {
			c.eventHandler.OnNodeStatusChange(nodeID, connected)
		})
	}
	if c.p2pApprovalHandler != nil {
		transport.SetApprovalRequestHandler(c.p2pApprovalHandler)
	}

	ctx, cancel := context.WithCancel(context.Background())
	if c.authToken != "" {
		ctx = metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+c.authToken)
	}

	c.p2pTransportCancel = cancel
	c.p2pTransport = transport

	go func() {
		if err := transport.StartSignaling(ctx); err != nil {
			if c.cfg.DebugMode {
				log.Printf("[P2P] Signaling ended: %v", err)
			}
			c.mu.Lock()
			if c.p2pTransport == transport {
				c.p2pTransport = nil
				c.p2pTransportCancel = nil
			}
			c.mu.Unlock()
		}
	}()
}

func (c *Controller) stopP2PTransportLocked() {
	if c.p2pTransportCancel != nil {
		c.p2pTransportCancel()
		c.p2pTransportCancel = nil
	}
	if c.p2pTransport != nil {
		c.p2pTransport.Close()
		c.p2pTransport = nil
	}
}

// SetP2PApprovalHandler sets a handler for incoming P2P approval requests.
// Must be called before enabling P2P. The handler is set on the transport
// when it starts.
func (c *Controller) SetP2PApprovalHandler(handler func(nodeID string, req *p2p.ApprovalRequest)) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.p2pApprovalHandler = handler
}
