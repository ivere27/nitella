package hubclient

import (
	"context"
	"crypto/ed25519"
	"crypto/sha256"
	"crypto/tls"
	"crypto/x509"
	"encoding/hex"
	"encoding/pem"
	"fmt"
	"log"
	"strings"
	"sync"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/hub"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/ivere27/nitella/pkg/hub/routing"
	"github.com/ivere27/nitella/pkg/p2p"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/metadata"
	"google.golang.org/protobuf/proto"
)

// CLIClient is used by nitella CLI to communicate with nodes via Hub
// It supports both Hub relay mode and P2P direct mode
type CLIClient struct {
	hubAddr    string
	authToken  string
	userID     string
	privateKey ed25519.PrivateKey
	publicKey  ed25519.PublicKey

	// Hub connection
	conn         *grpc.ClientConn
	mobileClient pb.MobileServiceClient
	connMu       sync.Mutex

	// P2P transport
	p2pTransport *p2p.Transport
	useP2P       bool
	p2pFallback  bool // If P2P fails, fall back to Hub relay

	// TLS options
	transportCAPEM []byte
	hubCertPin     string

	// Zero-Trust routing
	userSecret    []byte            // For generating routing tokens
	routingTokens map[string]string // nodeID -> routing token

	// Response channels for async commands
	responseChs map[string]chan *pb.CommandResponse
	responseMu  sync.Mutex

	// Metrics streams
	metricsCallback func(nodeID string, metrics *pb.Metrics)

	// P2P settings
	stunURL string
}

// NewCLIClient creates a CLI client for interacting with nodes via Hub
func NewCLIClient(hubAddr, authToken, userID string) *CLIClient {
	return &CLIClient{
		hubAddr:       hubAddr,
		authToken:     authToken,
		userID:        userID,
		useP2P:        false,
		p2pFallback:   true,
		routingTokens: make(map[string]string),
		responseChs:   make(map[string]chan *pb.CommandResponse),
	}
}

// SetIdentity sets the cryptographic identity for E2E encryption
func (c *CLIClient) SetIdentity(privKey ed25519.PrivateKey) {
	c.privateKey = privKey
	if privKey != nil && len(privKey) == ed25519.PrivateKeySize {
		c.publicKey = privKey.Public().(ed25519.PublicKey)
	}
}

// SetTransportCA sets custom CA for Hub TLS verification
func (c *CLIClient) SetTransportCA(certPEM []byte) {
	c.transportCAPEM = certPEM
}

// SetHubCertPin sets certificate pinning for Hub connection
func (c *CLIClient) SetHubCertPin(pin string) {
	c.hubCertPin = strings.ReplaceAll(strings.ToLower(pin), ":", "")
}

// SetP2PMode configures P2P behavior
func (c *CLIClient) SetP2PMode(enabled, fallback bool) {
	c.useP2P = enabled
	c.p2pFallback = fallback
}

// SetSTUNServer sets the STUN server URL for P2P connections
func (c *CLIClient) SetSTUNServer(url string) {
	c.stunURL = url
}

// SetMetricsCallback sets the callback for metrics updates
func (c *CLIClient) SetMetricsCallback(callback func(nodeID string, metrics *pb.Metrics)) {
	c.metricsCallback = callback
}

// SetUserSecret sets the user secret for routing token generation
func (c *CLIClient) SetUserSecret(secret []byte) {
	c.userSecret = secret
}

// GetUserSecret returns the user secret
func (c *CLIClient) GetUserSecret() []byte {
	return c.userSecret
}

// SetRoutingToken sets the routing token for a specific node
func (c *CLIClient) SetRoutingToken(nodeID, token string) {
	if c.routingTokens == nil {
		c.routingTokens = make(map[string]string)
	}
	c.routingTokens[nodeID] = token
}

// GetRoutingToken returns the routing token for a node.
// If not cached, generates it from userSecret if available.
func (c *CLIClient) GetRoutingToken(nodeID string) string {
	if token, ok := c.routingTokens[nodeID]; ok {
		return token
	}
	// Generate if we have userSecret
	if c.userSecret != nil {
		token := routing.GenerateRoutingToken(nodeID, c.userSecret)
		c.routingTokens[nodeID] = token
		return token
	}
	return ""
}

// GetAllRoutingTokens returns all cached routing tokens
func (c *CLIClient) GetAllRoutingTokens() []string {
	tokens := make([]string, 0, len(c.routingTokens))
	for _, token := range c.routingTokens {
		tokens = append(tokens, token)
	}
	return tokens
}

// LoadRoutingTokens loads routing tokens from a map (typically from storage)
func (c *CLIClient) LoadRoutingTokens(tokens map[string]string) {
	if c.routingTokens == nil {
		c.routingTokens = make(map[string]string)
	}
	for nodeID, token := range tokens {
		c.routingTokens[nodeID] = token
	}
}

// Connect establishes connection to Hub
func (c *CLIClient) Connect(ctx context.Context) error {
	tlsConfig := &tls.Config{
		MinVersion: tls.VersionTLS13,
	}

	// Custom CA
	if len(c.transportCAPEM) > 0 {
		rootCAs := x509.NewCertPool()
		if ok := rootCAs.AppendCertsFromPEM(c.transportCAPEM); ok {
			tlsConfig.RootCAs = rootCAs
		}
	}

	// Certificate pinning
	if c.hubCertPin != "" {
		tlsConfig.VerifyConnection = func(cs tls.ConnectionState) error {
			if len(cs.PeerCertificates) == 0 {
				return fmt.Errorf("no peer certificates presented")
			}
			leaf := cs.PeerCertificates[0]
			hash := sha256.Sum256(leaf.RawSubjectPublicKeyInfo)
			fingerprint := hex.EncodeToString(hash[:])
			if fingerprint != c.hubCertPin {
				return fmt.Errorf("certificate pinning mismatch")
			}
			return nil
		}
	}

	conn, err := grpc.DialContext(ctx, c.hubAddr,
		grpc.WithTransportCredentials(credentials.NewTLS(tlsConfig)),
	)
	if err != nil {
		return fmt.Errorf("failed to connect to hub: %w", err)
	}

	c.connMu.Lock()
	c.conn = conn
	c.mobileClient = pb.NewMobileServiceClient(conn)
	c.connMu.Unlock()

	// Start P2P if enabled
	if c.useP2P {
		c.p2pTransport = p2p.NewTransport(c.userID, c.mobileClient)
		if c.stunURL != "" {
			c.p2pTransport.SetSTUNServer(c.stunURL)
		}
		if c.privateKey != nil {
			c.p2pTransport.SetIdentity(c.privateKey)
		}

		// Add authorization token for signaling if not already present
		signalingCtx := ctx
		if c.authToken != "" {
			signalingCtx = metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+c.authToken)
		}

		if err := c.p2pTransport.StartSignaling(signalingCtx); err != nil {
			log.Printf("[P2P] Failed to start signaling: %v", err)
			if !c.p2pFallback {
				return fmt.Errorf("P2P signaling failed and fallback disabled: %w", err)
			}
		}
	}

	return nil
}

// Close closes all connections
func (c *CLIClient) Close() {
	c.connMu.Lock()
	defer c.connMu.Unlock()

	if c.p2pTransport != nil {
		if err := c.p2pTransport.Close(); err != nil {
			log.Printf("warning: p2p transport close error: %v", err)
		}
	}
	if c.conn != nil {
		c.conn.Close()
		c.conn = nil
	}
}

// ListNodes lists all nodes owned by the user (Zero-Trust: requires routing tokens)
func (c *CLIClient) ListNodes(ctx context.Context) ([]*pb.Node, error) {
	c.connMu.Lock()
	client := c.mobileClient
	c.connMu.Unlock()

	if client == nil {
		return nil, fmt.Errorf("not connected")
	}

	// Zero-Trust: provide routing tokens to fetch only owned nodes
	resp, err := client.ListNodes(ctx, &pb.ListNodesRequest{
		RoutingTokens: c.GetAllRoutingTokens(),
	})
	if err != nil {
		return nil, err
	}

	return resp.Nodes, nil
}

// GetNode gets a specific node by ID
func (c *CLIClient) GetNode(ctx context.Context, nodeID string) (*pb.Node, error) {
	c.connMu.Lock()
	client := c.mobileClient
	c.connMu.Unlock()

	if client == nil {
		return nil, fmt.Errorf("not connected")
	}

	node, err := client.GetNode(ctx, &pb.GetNodeRequest{NodeId: nodeID})
	if err != nil {
		return nil, err
	}

	return node, nil
}

// SendCommand sends a command to a node and waits for response
func (c *CLIClient) SendCommand(ctx context.Context, nodeID string, cmdType pb.CommandType, payload []byte, nodePubKey ed25519.PublicKey) (*pb.CommandResult, error) {
	// Try P2P first if enabled and connected
	if c.useP2P && c.p2pTransport != nil && c.p2pTransport.IsConnected(nodeID) {
		result, err := c.sendViaP2P(ctx, nodeID, cmdType, payload, nodePubKey)
		if err == nil {
			return result, nil
		}
		if !c.p2pFallback {
			return nil, fmt.Errorf("P2P command failed: %w", err)
		}
		log.Printf("[P2P] Command failed, falling back to Hub relay: %v", err)
	}

	// Fall back to Hub relay
	return c.sendViaHub(ctx, nodeID, cmdType, payload, nodePubKey)
}

func (c *CLIClient) sendViaP2P(ctx context.Context, nodeID string, cmdType pb.CommandType, payload []byte, nodePubKey ed25519.PublicKey) (*pb.CommandResult, error) {
	encryptedPayload, err := c.buildEncryptedCommandPayload(cmdType, payload, nodePubKey)
	if err != nil {
		return nil, err
	}

	data, err := proto.Marshal(&pb.Command{Encrypted: encryptedPayload})
	if err != nil {
		return nil, fmt.Errorf("failed to marshal P2P command envelope: %w", err)
	}

	// Send via P2P
	if err := c.p2pTransport.Send(nodeID, data); err != nil {
		return nil, fmt.Errorf("failed to send via P2P: %w", err)
	}

	// Wait for response (with timeout)
	// Note: For P2P, responses come via the message handler
	// This is simplified - real implementation needs response correlation
	select {
	case <-ctx.Done():
		return nil, ctx.Err()
	case <-time.After(30 * time.Second):
		return nil, fmt.Errorf("P2P response timeout")
	}
}

func (c *CLIClient) sendViaHub(ctx context.Context, nodeID string, cmdType pb.CommandType, payload []byte, nodePubKey ed25519.PublicKey) (*pb.CommandResult, error) {
	c.connMu.Lock()
	client := c.mobileClient
	c.connMu.Unlock()

	if client == nil {
		return nil, fmt.Errorf("not connected")
	}

	encryptedPayload, err := c.buildEncryptedCommandPayload(cmdType, payload, nodePubKey)
	if err != nil {
		return nil, err
	}

	// Add auth token
	if c.authToken != "" {
		ctx = metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+c.authToken)
	}

	// Send via Hub (Type is embedded in encrypted payload)
	// Zero-Trust: include routing token to prove ownership
	resp, err := client.SendCommand(ctx, &pb.CommandRequest{
		NodeId:       nodeID,
		Encrypted:    encryptedPayload,
		RoutingToken: c.GetRoutingToken(nodeID),
	})
	if err != nil {
		return nil, fmt.Errorf("command failed: %w", err)
	}

	if resp.EncryptedData == nil {
		return nil, fmt.Errorf("hub returned unencrypted command response")
	}

	respEnvelope := &nitellacrypto.EncryptedPayload{
		EphemeralPubKey:   resp.EncryptedData.EphemeralPubkey,
		Nonce:             resp.EncryptedData.Nonce,
		Ciphertext:        resp.EncryptedData.Ciphertext,
		SenderFingerprint: resp.EncryptedData.SenderFingerprint,
		Signature:         resp.EncryptedData.Signature,
	}

	// Verify response signature with node's public key
	if len(respEnvelope.Signature) == 0 {
		return nil, fmt.Errorf("hub returned unsigned command response")
	}
	if err := nitellacrypto.VerifySignature(respEnvelope, nodePubKey); err != nil {
		return nil, fmt.Errorf("response signature verification failed: %w", err)
	}

	decrypted, err := nitellacrypto.Decrypt(respEnvelope, c.privateKey)
	if err != nil {
		return nil, fmt.Errorf("failed to decrypt response: %w", err)
	}

	var result pb.CommandResult
	if err := proto.Unmarshal(decrypted, &result); err != nil {
		return nil, fmt.Errorf("failed to unmarshal response: %w", err)
	}
	return &result, nil
}

func (c *CLIClient) buildEncryptedCommandPayload(cmdType pb.CommandType, payload []byte, nodePubKey ed25519.PublicKey) (*common.EncryptedPayload, error) {
	if nodePubKey == nil {
		return nil, fmt.Errorf("node public key is required for E2E command encryption")
	}
	if c.privateKey == nil {
		return nil, fmt.Errorf("identity private key is required for E2E command encryption")
	}

	senderPubKey := c.publicKey
	if len(senderPubKey) == 0 {
		if pk, ok := c.privateKey.Public().(ed25519.PublicKey); ok {
			senderPubKey = pk
		}
	}
	if len(senderPubKey) == 0 {
		return nil, fmt.Errorf("identity public key is required for E2E command encryption")
	}

	innerPayload := &pb.EncryptedCommandPayload{
		Type:    cmdType,
		Payload: payload,
	}
	innerBytes, err := proto.Marshal(innerPayload)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal command: %w", err)
	}

	securePayload := &common.SecureCommandPayload{
		RequestId: fmt.Sprintf("%d", time.Now().UnixNano()),
		Timestamp: time.Now().Unix(),
		Data:      innerBytes,
	}
	secureBytes, err := proto.Marshal(securePayload)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal secure payload: %w", err)
	}

	fpHash := sha256.Sum256(senderPubKey)
	senderFP := hex.EncodeToString(fpHash[:])
	encrypted, err := nitellacrypto.EncryptWithSignature(secureBytes, nodePubKey, c.privateKey, senderFP)
	if err != nil {
		return nil, fmt.Errorf("failed to encrypt command payload: %w", err)
	}

	return &common.EncryptedPayload{
		EphemeralPubkey:   encrypted.EphemeralPubKey,
		Nonce:             encrypted.Nonce,
		Ciphertext:        encrypted.Ciphertext,
		SenderFingerprint: encrypted.SenderFingerprint,
		Signature:         encrypted.Signature,
	}, nil
}

// ConnectP2P initiates P2P connection to a node
func (c *CLIClient) ConnectP2P(nodeID string) error {
	if c.p2pTransport == nil {
		return fmt.Errorf("P2P not initialized")
	}
	return c.p2pTransport.Connect(nodeID)
}

// IsP2PConnected checks if P2P is connected to a node
func (c *CLIClient) IsP2PConnected(nodeID string) bool {
	if c.p2pTransport == nil {
		return false
	}
	return c.p2pTransport.IsConnected(nodeID)
}

// StartMetricsStream starts streaming metrics from a node
func (c *CLIClient) StartMetricsStream(ctx context.Context, nodeID string) error {
	c.connMu.Lock()
	client := c.mobileClient
	c.connMu.Unlock()

	if client == nil {
		return fmt.Errorf("not connected")
	}

	// Add auth token
	if c.authToken != "" {
		ctx = metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+c.authToken)
	}

	stream, err := client.StreamMetrics(ctx, &pb.StreamMetricsRequest{
		NodeId:       nodeID,
		RoutingToken: c.GetRoutingToken(nodeID),
	})
	if err != nil {
		return fmt.Errorf("failed to start metrics stream: %w", err)
	}

	go func() {
		for {
			sample, err := stream.Recv()
			if err != nil {
				log.Printf("[Metrics] Stream ended: %v", err)
				return
			}

			// Decrypt if needed and callback
			if c.metricsCallback != nil && c.privateKey != nil && sample.Encrypted != nil {
				decrypted, err := nitellacrypto.Decrypt(&nitellacrypto.EncryptedPayload{
					EphemeralPubKey:   sample.Encrypted.EphemeralPubkey,
					Nonce:             sample.Encrypted.Nonce,
					Ciphertext:        sample.Encrypted.Ciphertext,
					SenderFingerprint: sample.Encrypted.SenderFingerprint,
					Signature:         sample.Encrypted.Signature,
				}, c.privateKey)
				if err == nil {
					var metrics pb.Metrics
					if proto.Unmarshal(decrypted, &metrics) == nil {
						c.metricsCallback(sample.NodeId, &metrics)
					}
				}
			}
		}
	}()

	return nil
}

// ApproveNode approves a pending node registration with signed certificates
// nodeID is required for generating the routing token
func (c *CLIClient) ApproveNode(ctx context.Context, regCode, certPEM, caPEM, nodeID string) error {
	c.connMu.Lock()
	client := c.mobileClient
	c.connMu.Unlock()

	if client == nil {
		return fmt.Errorf("not connected")
	}

	// Zero-Trust: generate and store routing token for this node
	routingToken := c.GetRoutingToken(nodeID)
	if routingToken == "" && c.userSecret != nil {
		routingToken = routing.GenerateRoutingToken(nodeID, c.userSecret)
		c.SetRoutingToken(nodeID, routingToken)
	}

	_, err := client.ApproveNode(ctx, &pb.ApproveNodeRequest{
		RegistrationCode: regCode,
		CertPem:          certPEM,
		CaPem:            caPEM,
		RoutingToken:     routingToken,
	})
	return err
}

// DeleteNode deletes a node
func (c *CLIClient) DeleteNode(ctx context.Context, nodeID string) error {
	c.connMu.Lock()
	client := c.mobileClient
	c.connMu.Unlock()

	if client == nil {
		return fmt.Errorf("not connected")
	}

	_, err := client.DeleteNode(ctx, &pb.DeleteNodeRequest{NodeId: nodeID})
	return err
}

// GetNodeRules fetches rules from a node
func (c *CLIClient) GetNodeRules(ctx context.Context, nodeID string, nodePubKey ed25519.PublicKey) ([]*pbProxy.Rule, error) {
	// Send ListRulesRequest via command
	req := &pbProxy.ListRulesRequest{ProxyId: nodeID}
	payload, _ := proto.Marshal(req)
	result, err := c.SendCommand(ctx, nodeID, pb.CommandType_COMMAND_TYPE_LIST_RULES, payload, nodePubKey)
	if err != nil {
		return nil, err
	}

	if result.Status != "OK" {
		return nil, fmt.Errorf("command failed: %s", result.ErrorMessage)
	}

	var resp pbProxy.ListRulesResponse
	if err := proto.Unmarshal(result.ResponsePayload, &resp); err != nil {
		return nil, fmt.Errorf("failed to unmarshal rules: %w", err)
	}

	return resp.Rules, nil
}

// AddNodeRule adds a rule to a node
func (c *CLIClient) AddNodeRule(ctx context.Context, nodeID string, rule *pbProxy.Rule, nodePubKey ed25519.PublicKey) error {
	req := &pbProxy.AddRuleRequest{
		ProxyId: nodeID,
		Rule:    rule,
	}
	payload, _ := proto.Marshal(req)
	result, err := c.SendCommand(ctx, nodeID, pb.CommandType_COMMAND_TYPE_ADD_RULE, payload, nodePubKey)
	if err != nil {
		return err
	}

	if result.Status != "OK" {
		return fmt.Errorf("add rule failed: %s", result.ErrorMessage)
	}

	return nil
}

// RemoveNodeRule removes a rule from a node
func (c *CLIClient) RemoveNodeRule(ctx context.Context, nodeID string, ruleID string, nodePubKey ed25519.PublicKey) error {
	req := &pbProxy.RemoveRuleRequest{
		ProxyId: nodeID,
		RuleId:  ruleID,
	}
	payload, _ := proto.Marshal(req)
	result, err := c.SendCommand(ctx, nodeID, pb.CommandType_COMMAND_TYPE_REMOVE_RULE, payload, nodePubKey)
	if err != nil {
		return err
	}

	if result.Status != "OK" {
		return fmt.Errorf("remove rule failed: %s", result.ErrorMessage)
	}

	return nil
}

// ResolveApproval resolves a pending connection approval
func (c *CLIClient) ResolveApproval(ctx context.Context, nodeID, reqID string, allow bool, durationSeconds int64, nodePubKey ed25519.PublicKey) error {
	action := common.ApprovalActionType_APPROVAL_ACTION_TYPE_BLOCK
	if allow {
		action = common.ApprovalActionType_APPROVAL_ACTION_TYPE_ALLOW
	}

	req := &pbProxy.ResolveApprovalRequest{
		ReqId:           reqID,
		Action:          action,
		DurationSeconds: durationSeconds,
	}
	payload, _ := proto.Marshal(req)
	result, err := c.SendCommand(ctx, nodeID, pb.CommandType_COMMAND_TYPE_RESOLVE_APPROVAL, payload, nodePubKey)
	if err != nil {
		return err
	}

	if result.Status != "OK" {
		return fmt.Errorf("resolve approval failed: %s", result.ErrorMessage)
	}

	return nil
}

// GetNodePublicKey extracts public key from node's certificate
func GetNodePublicKey(certPEM string) (ed25519.PublicKey, error) {
	block, _ := pem.Decode([]byte(certPEM))
	if block == nil {
		return nil, fmt.Errorf("failed to decode certificate PEM")
	}

	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("failed to parse certificate: %w", err)
	}

	pubKey, ok := cert.PublicKey.(ed25519.PublicKey)
	if !ok {
		return nil, fmt.Errorf("certificate does not contain Ed25519 public key")
	}

	return pubKey, nil
}
