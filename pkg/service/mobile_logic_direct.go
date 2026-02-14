package service

import (
	"context"
	"crypto/aes"
	"crypto/cipher"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/sha256"
	"crypto/tls"
	"crypto/x509"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
	"sync"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	hubpb "github.com/ivere27/nitella/pkg/api/hub"
	pb "github.com/ivere27/nitella/pkg/api/local"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/core"
	"github.com/ivere27/nitella/pkg/identity"
	"golang.org/x/crypto/hkdf"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/metadata"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// directNodeClient holds the gRPC connection and client for a direct node.
type directNodeClient struct {
	conn      *grpc.ClientConn
	client    pbProxy.ProxyControlServiceClient
	address   string
	token     string
	caPEM     string
	lastCheck time.Time
	isOnline  bool
	mu        sync.RWMutex
}

// directNodeStore manages direct node connections.
type directNodeStore struct {
	clients map[string]*directNodeClient
	mu      sync.RWMutex
}

// newDirectNodeStore creates a new direct node store.
func newDirectNodeStore() *directNodeStore {
	return &directNodeStore{
		clients: make(map[string]*directNodeClient),
	}
}

// get returns the direct node client for a node ID, or nil if not a direct node.
func (s *directNodeStore) get(nodeID string) *directNodeClient {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.clients[nodeID]
}

// add adds a new direct node client.
func (s *directNodeStore) add(nodeID string, client *directNodeClient) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.clients[nodeID] = client
}

// remove removes a direct node client and closes its connection.
func (s *directNodeStore) remove(nodeID string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if c, ok := s.clients[nodeID]; ok {
		if c.conn != nil {
			c.conn.Close()
		}
		delete(s.clients, nodeID)
	}
}

// closeAll closes all direct node connections.
func (s *directNodeStore) closeAll() {
	s.mu.Lock()
	defer s.mu.Unlock()
	for _, c := range s.clients {
		if c.conn != nil {
			c.conn.Close()
		}
	}
	s.clients = make(map[string]*directNodeClient)
}

// ===========================================================================
// Direct Node Methods
// ===========================================================================

// AddNodeDirect adds a standalone nitellad with direct connection.
func (s *MobileLogicService) AddNodeDirect(ctx context.Context, req *pb.AddNodeDirectRequest) (*pb.AddNodeDirectResponse, error) {
	// Validate input
	if req.Address == "" {
		return &pb.AddNodeDirectResponse{
			Success: false,
			Error:   "address is required",
		}, nil
	}
	if req.Token == "" {
		return &pb.AddNodeDirectResponse{
			Success: false,
			Error:   "token is required",
		}, nil
	}
	if req.CaPem == "" {
		return &pb.AddNodeDirectResponse{
			Success: false,
			Error:   "CA certificate (ca_pem) is required",
		}, nil
	}

	// Test connection first
	conn, client, err := s.createDirectConnection(ctx, req.Address, req.Token, req.CaPem)
	if err != nil {
		return &pb.AddNodeDirectResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to connect: %v", err),
		}, nil
	}

	// List proxies to verify connection and get proxy count
	result, err := s.secureDirectCall(ctx, client, req.Token, req.CaPem, hubpb.CommandType_COMMAND_TYPE_LIST_PROXIES, &pbProxy.ListProxiesRequest{})
	if err != nil {
		conn.Close()
		return &pb.AddNodeDirectResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to list proxies: %v", err),
		}, nil
	}
	var proxiesResp pbProxy.ListProxiesResponse
	if result.Status == "OK" && len(result.ResponsePayload) > 0 {
		proto.Unmarshal(result.ResponsePayload, &proxiesResp)
	}

	// Generate unique node ID from address if name not provided
	nodeName := req.Name
	if nodeName == "" {
		nodeName = req.Address
	}
	nodeID := fmt.Sprintf("direct-%s", sanitizeNodeID(req.Address))

	s.mu.Lock()
	defer s.mu.Unlock()

	// Check if already exists
	if _, exists := s.nodes[nodeID]; exists {
		conn.Close()
		return &pb.AddNodeDirectResponse{
			Success: false,
			Error:   "node already exists with this address",
		}, nil
	}

	// Initialize direct store if needed
	if s.directNodes == nil {
		s.directNodes = newDirectNodeStore()
	}

	// Store connection
	directClient := &directNodeClient{
		conn:      conn,
		client:    client,
		address:   req.Address,
		token:     req.Token,
		caPEM:     req.CaPem,
		lastCheck: time.Now(),
		isOnline:  true,
	}
	s.directNodes.add(nodeID, directClient)

	// Register with controller for unified SendCommand routing
	nodePubKey, _ := extractNodePubKey(req.CaPem)
	if s.ctrl != nil && nodePubKey != nil {
		s.ctrl.SetLocalConnection(nodeID, &core.LocalConnection{
			Client:     client,
			Token:      req.Token,
			NodePubKey: nodePubKey,
		})
	}

	// Create node info
	proxyCount := int32(len(proxiesResp.Proxies))

	node := &pb.NodeInfo{
		NodeId:        nodeID,
		Name:          nodeName,
		Online:        true,
		PairedAt:      timestamppb.Now(),
		LastSeen:      timestamppb.Now(),
		ConnType:      pb.NodeConnectionType_NODE_CONNECTION_TYPE_DIRECT,
		DirectAddress: req.Address,
		DirectToken:   req.Token,
		DirectCaPem:   req.CaPem,
		ProxyCount:    proxyCount,
		EmojiHash:     calculateEmojiHash(req.CaPem),
	}

	// Save to memory
	s.nodes[nodeID] = node

	// Persist direct node metadata
	if err := s.saveDirectNodeMetadata(nodeID, node); err != nil {
		if s.debugMode {
			log.Printf("warning: failed to save direct node metadata: %v\n", err)
		}
	}

	return &pb.AddNodeDirectResponse{
		Success: true,
		Node:    node,
	}, nil
}

// TestDirectConnection tests connectivity to a nitellad admin API.
func (s *MobileLogicService) TestDirectConnection(ctx context.Context, req *pb.TestDirectConnectionRequest) (*pb.TestDirectConnectionResponse, error) {
	// Validate input
	if req.Address == "" {
		return &pb.TestDirectConnectionResponse{
			Success: false,
			Error:   "address is required",
		}, nil
	}
	if req.Token == "" {
		return &pb.TestDirectConnectionResponse{
			Success: false,
			Error:   "token is required",
		}, nil
	}
	if req.CaPem == "" {
		return &pb.TestDirectConnectionResponse{
			Success: false,
			Error:   "CA certificate (ca_pem) is required",
		}, nil
	}

	// Create connection
	conn, client, err := s.createDirectConnection(ctx, req.Address, req.Token, req.CaPem)
	if err != nil {
		return &pb.TestDirectConnectionResponse{
			Success: false,
			Error:   fmt.Sprintf("connection failed: %v", err),
		}, nil
	}
	defer conn.Close()

	// Test with ListProxies call (encrypted)
	result, err := s.secureDirectCall(ctx, client, req.Token, req.CaPem, hubpb.CommandType_COMMAND_TYPE_LIST_PROXIES, &pbProxy.ListProxiesRequest{})
	if err != nil {
		return &pb.TestDirectConnectionResponse{
			Success: false,
			Error:   fmt.Sprintf("authentication failed: %v", err),
		}, nil
	}
	var proxiesResp pbProxy.ListProxiesResponse
	if result.Status == "OK" && len(result.ResponsePayload) > 0 {
		proto.Unmarshal(result.ResponsePayload, &proxiesResp)
	}
	proxyCount := int32(len(proxiesResp.Proxies))

	return &pb.TestDirectConnectionResponse{
		Success:    true,
		ProxyCount: proxyCount,
		EmojiHash:  calculateEmojiHash(req.CaPem),
	}, nil
}

// createDirectConnection creates a gRPC connection to a direct node.
func (s *MobileLogicService) createDirectConnection(ctx context.Context, address, token, caPEM string) (*grpc.ClientConn, pbProxy.ProxyControlServiceClient, error) {
	// Parse CA certificate
	caPool := x509.NewCertPool()
	if !caPool.AppendCertsFromPEM([]byte(caPEM)) {
		return nil, nil, fmt.Errorf("failed to parse CA certificate")
	}

	// Create TLS config
	tlsConfig := &tls.Config{
		RootCAs:    caPool,
		MinVersion: tls.VersionTLS13,
	}

	// Create connection with timeout
	connCtx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()

	conn, err := grpc.DialContext(connCtx, address,
		grpc.WithTransportCredentials(credentials.NewTLS(tlsConfig)),
		grpc.WithBlock(),
	)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to connect: %w", err)
	}

	client := pbProxy.NewProxyControlServiceClient(conn)
	return conn, client, nil
}

// authContext adds authentication token to context.
func (s *MobileLogicService) authContext(ctx context.Context, token string) context.Context {
	return metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+token)
}

// getDirectClient returns the admin client for a direct node.
func (s *MobileLogicService) getDirectClient(nodeID string) (pbProxy.ProxyControlServiceClient, string, error) {
	if s.directNodes == nil {
		return nil, "", fmt.Errorf("direct node store not initialized")
	}

	client := s.directNodes.get(nodeID)
	if client == nil {
		return nil, "", fmt.Errorf("not a direct node: %s", nodeID)
	}

	client.mu.RLock()
	defer client.mu.RUnlock()

	if client.conn == nil {
		return nil, "", fmt.Errorf("direct node connection closed")
	}

	return client.client, client.token, nil
}

// isDirectNode returns true if the node is a direct connection node.
// NOTE: Caller must NOT hold s.mu — this method acquires s.mu.RLock() internally.
func (s *MobileLogicService) isDirectNode(nodeID string) bool {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.isDirectNodeLocked(nodeID)
}

// isDirectNodeLocked returns true if the node is a direct connection node.
// Caller MUST hold s.mu.RLock() or s.mu.Lock().
func (s *MobileLogicService) isDirectNodeLocked(nodeID string) bool {
	node, exists := s.nodes[nodeID]
	if !exists {
		return false
	}
	return node.ConnType == pb.NodeConnectionType_NODE_CONNECTION_TYPE_DIRECT
}

// reconnectDirectNode attempts to reconnect a direct node.
func (s *MobileLogicService) reconnectDirectNode(ctx context.Context, nodeID string) error {
	s.mu.RLock()
	node, exists := s.nodes[nodeID]
	s.mu.RUnlock()

	if !exists {
		return fmt.Errorf("node not found: %s", nodeID)
	}

	if node.ConnType != pb.NodeConnectionType_NODE_CONNECTION_TYPE_DIRECT {
		return fmt.Errorf("not a direct node: %s", nodeID)
	}

	conn, client, err := s.createDirectConnection(ctx, node.DirectAddress, node.DirectToken, node.DirectCaPem)
	if err != nil {
		return err
	}

	if s.directNodes == nil {
		s.directNodes = newDirectNodeStore()
	}

	// Replace existing client
	s.directNodes.remove(nodeID)
	s.directNodes.add(nodeID, &directNodeClient{
		conn:      conn,
		client:    client,
		address:   node.DirectAddress,
		token:     node.DirectToken,
		caPEM:     node.DirectCaPem,
		lastCheck: time.Now(),
		isOnline:  true,
	})

	// Re-register with controller
	nodePubKey, _ := extractNodePubKey(node.DirectCaPem)
	if s.ctrl != nil && nodePubKey != nil {
		s.ctrl.SetLocalConnection(nodeID, &core.LocalConnection{
			Client:     client,
			Token:      node.DirectToken,
			NodePubKey: nodePubKey,
		})
	}

	// Update node status
	s.mu.Lock()
	if n, ok := s.nodes[nodeID]; ok {
		n.Online = true
		n.LastSeen = timestamppb.Now()
	}
	s.mu.Unlock()

	return nil
}

// saveDirectNodeMetadata persists direct node connection info to disk.
// The DirectToken is encrypted at rest using a key derived from the identity.
func (s *MobileLogicService) saveDirectNodeMetadata(nodeID string, node *pb.NodeInfo) error {
	nodesDir := filepath.Join(s.dataDir, "nodes")
	if err := os.MkdirAll(nodesDir, 0700); err != nil {
		return err
	}

	// Encrypt token at rest if identity is available
	tokenValue := node.DirectToken
	encrypted := false
	if s.identity != nil && tokenValue != "" {
		enc, err := s.encryptLocalSecret(tokenValue)
		if err == nil {
			tokenValue = fmt.Sprintf("%x", enc)
			encrypted = true
		}
	}

	// Direct node metadata includes connection info
	meta := struct {
		Name          string   `json:"name"`
		Tags          []string `json:"tags,omitempty"`
		ConnType      string   `json:"conn_type"`
		DirectAddress string   `json:"direct_address,omitempty"`
		DirectToken   string   `json:"direct_token,omitempty"`
		DirectCaPEM   string   `json:"direct_ca_pem,omitempty"`
		Encrypted     bool     `json:"encrypted,omitempty"`
	}{
		Name:          node.Name,
		Tags:          node.Tags,
		ConnType:      "direct",
		DirectAddress: node.DirectAddress,
		DirectToken:   tokenValue,
		DirectCaPEM:   node.DirectCaPem,
		Encrypted:     encrypted,
	}

	data, err := json.MarshalIndent(meta, "", "  ")
	if err != nil {
		return err
	}

	metaPath := filepath.Join(nodesDir, nodeID+".json")
	return os.WriteFile(metaPath, data, 0600)
}

// loadDirectNodes loads persisted direct nodes and reconnects them.
func (s *MobileLogicService) loadDirectNodes(ctx context.Context) error {
	nodesDir := filepath.Join(s.dataDir, "nodes")
	entries, err := os.ReadDir(nodesDir)
	if err != nil {
		if os.IsNotExist(err) {
			return nil
		}
		return err
	}

	for _, entry := range entries {
		if entry.IsDir() || filepath.Ext(entry.Name()) != ".json" {
			continue
		}

		nodeID := entry.Name()[:len(entry.Name())-5] // Remove .json

		data, err := os.ReadFile(filepath.Join(nodesDir, entry.Name()))
		if err != nil {
			continue
		}

		var meta struct {
			Name          string   `json:"name"`
			Tags          []string `json:"tags,omitempty"`
			ConnType      string   `json:"conn_type"`
			DirectAddress string   `json:"direct_address,omitempty"`
			DirectToken   string   `json:"direct_token,omitempty"`
			DirectCaPEM   string   `json:"direct_ca_pem,omitempty"`
			Encrypted     bool     `json:"encrypted,omitempty"`
		}
		if err := json.Unmarshal(data, &meta); err != nil {
			continue
		}

		// Only process direct nodes
		if meta.ConnType != "direct" {
			continue
		}

		// Decrypt token if encrypted
		token := meta.DirectToken
		needsMigration := false
		canReconnect := true
		skipReason := ""
		if meta.Encrypted {
			// Encrypted direct tokens require an unlocked identity.
			if token == "" {
				canReconnect = false
				skipReason = "missing encrypted token"
			} else if s.identity == nil {
				// Keep ciphertext out of runtime auth paths while locked.
				token = ""
				canReconnect = false
				skipReason = "identity is locked"
			} else {
				ciphertext, err := hexDecode(token)
				if err != nil {
					token = ""
					canReconnect = false
					skipReason = "invalid encrypted token encoding"
					if s.debugMode {
						log.Printf("warning: failed to decode encrypted token for node %s: %v", nodeID, err)
					}
				} else if decrypted, err := s.decryptLocalSecret(ciphertext); err == nil {
					token = decrypted
				} else {
					token = ""
					canReconnect = false
					skipReason = "token decryption failed"
					if s.debugMode {
						log.Printf("warning: failed to decrypt token for node %s: %v", nodeID, err)
					}
				}
			}
		} else if token != "" && s.identity != nil {
			// Auto-migrate: unencrypted file will be re-saved encrypted
			needsMigration = true
		}

		// Create node info
		node := &pb.NodeInfo{
			NodeId:        nodeID,
			Name:          meta.Name,
			Tags:          meta.Tags,
			Online:        false, // Will be updated when reconnected
			ConnType:      pb.NodeConnectionType_NODE_CONNECTION_TYPE_DIRECT,
			DirectAddress: meta.DirectAddress,
			DirectToken:   token,
			DirectCaPem:   meta.DirectCaPEM,
			EmojiHash:     calculateEmojiHash(meta.DirectCaPEM),
		}

		s.nodes[nodeID] = node

		// Auto-migrate unencrypted tokens
		if needsMigration {
			if err := s.saveDirectNodeMetadata(nodeID, node); err != nil && s.debugMode {
				log.Printf("warning: failed to migrate node %s token encryption: %v", nodeID, err)
			}
		}

		// Try to reconnect in background once a usable token is available.
		if canReconnect {
			go func(id string) {
				if err := s.reconnectDirectNode(context.Background(), id); err != nil {
					if s.debugMode {
						log.Printf("failed to reconnect direct node %s: %v", id, err)
					}
				}
			}(nodeID)
		} else if s.debugMode {
			log.Printf("info: skipping reconnect for direct node %s: %s", nodeID, skipReason)
		}
	}

	return nil
}

// hexDecode decodes a hex string to bytes.
func hexDecode(s string) ([]byte, error) {
	b := make([]byte, len(s)/2)
	for i := 0; i < len(b); i++ {
		var hi, lo byte
		hi = unhex(s[i*2])
		lo = unhex(s[i*2+1])
		if hi == 0xFF || lo == 0xFF {
			return nil, fmt.Errorf("invalid hex byte at position %d", i*2)
		}
		b[i] = hi<<4 | lo
	}
	return b, nil
}

func unhex(c byte) byte {
	switch {
	case c >= '0' && c <= '9':
		return c - '0'
	case c >= 'a' && c <= 'f':
		return c - 'a' + 10
	case c >= 'A' && c <= 'F':
		return c - 'A' + 10
	default:
		return 0xFF
	}
}

// listPendingApprovalsDirect fetches pending approvals from a direct node.
func (s *MobileLogicService) listPendingApprovalsDirect(ctx context.Context, nodeID string) ([]*pb.ApprovalRequest, error) {
	result, err := s.secureDirectCommand(ctx, nodeID, hubpb.CommandType_COMMAND_TYPE_LIST_ACTIVE_APPROVALS, &pbProxy.ListActiveApprovalsRequest{})
	if err != nil {
		return nil, err
	}
	if result.Status != "OK" {
		return nil, fmt.Errorf("%s", result.ErrorMessage)
	}
	var resp pbProxy.ListActiveApprovalsResponse
	if len(result.ResponsePayload) > 0 {
		if err := proto.Unmarshal(result.ResponsePayload, &resp); err != nil {
			return nil, err
		}
	}

	var results []*pb.ApprovalRequest
	for _, a := range resp.Approvals {
		// Only include approvals that are NOT yet allowed (pending)
		if !a.Allowed {
			results = append(results, &pb.ApprovalRequest{
				RequestId: a.Key,
				NodeId:    nodeID,
				ProxyId:   a.ProxyId,
				SourceIp:  a.SourceIp,
				DestAddr:  "",
				RuleId:    a.RuleId,
				Timestamp: a.CreatedAt,
				Geo: &common.GeoInfo{
					Country: a.GeoCountry,
					City:    a.GeoCity,
					Isp:     a.GeoIsp,
				},
			})
		}
	}
	return results, nil
}

// approveRequestDirect approves a request on a direct node.
func (s *MobileLogicService) approveRequestDirect(ctx context.Context, nodeID, reqID string, duration int64, retentionMode common.ApprovalRetentionMode) (*pb.ApproveRequestResponse, error) {
	result, err := s.secureDirectCommand(ctx, nodeID, hubpb.CommandType_COMMAND_TYPE_RESOLVE_APPROVAL, &pbProxy.ResolveApprovalRequest{
		ReqId:           reqID,
		Action:          common.ApprovalActionType_APPROVAL_ACTION_TYPE_ALLOW,
		RetentionMode:   retentionMode,
		DurationSeconds: duration,
	})
	if err != nil {
		return &pb.ApproveRequestResponse{Success: false, Error: err.Error()}, nil
	}
	if result.Status != "OK" {
		return &pb.ApproveRequestResponse{Success: false, Error: result.ErrorMessage}, nil
	}
	var resp pbProxy.ResolveApprovalResponse
	if len(result.ResponsePayload) > 0 {
		proto.Unmarshal(result.ResponsePayload, &resp)
	}
	if !resp.Success {
		return &pb.ApproveRequestResponse{Success: false, Error: resp.ErrorMessage}, nil
	}

	return &pb.ApproveRequestResponse{Success: true}, nil
}

// denyRequestDirect denies a request on a direct node.
func (s *MobileLogicService) denyRequestDirect(ctx context.Context, nodeID, reqID string, duration int64, blockType pb.DenyBlockType, retentionMode common.ApprovalRetentionMode) (*pb.DenyRequestResponse, error) {
	// If block rule requested, look up approval details BEFORE resolving
	// (resolving removes the approval from the active list)
	var sourceIP, geoISP, proxyID string
	if blockType != pb.DenyBlockType_DENY_BLOCK_TYPE_NONE {
		listResult, err := s.secureDirectCommand(ctx, nodeID, hubpb.CommandType_COMMAND_TYPE_LIST_ACTIVE_APPROVALS, &pbProxy.ListActiveApprovalsRequest{})
		if err == nil && listResult.Status == "OK" {
			var listResp pbProxy.ListActiveApprovalsResponse
			if proto.Unmarshal(listResult.ResponsePayload, &listResp) == nil {
				for _, a := range listResp.Approvals {
					if a.Key == reqID {
						sourceIP = a.SourceIp
						geoISP = a.GeoIsp
						proxyID = a.ProxyId
						break
					}
				}
			}
		}
	}

	// Resolve the approval as BLOCK
	result, err := s.secureDirectCommand(ctx, nodeID, hubpb.CommandType_COMMAND_TYPE_RESOLVE_APPROVAL, &pbProxy.ResolveApprovalRequest{
		ReqId:           reqID,
		Action:          common.ApprovalActionType_APPROVAL_ACTION_TYPE_BLOCK,
		RetentionMode:   retentionMode,
		DurationSeconds: duration,
	})
	if err != nil {
		return &pb.DenyRequestResponse{Success: false, Error: err.Error()}, nil
	}
	if result.Status != "OK" {
		return &pb.DenyRequestResponse{Success: false, Error: result.ErrorMessage}, nil
	}

	// Create block rule if requested
	var ruleID string
	var blockRuleErr error
	switch blockType {
	case pb.DenyBlockType_DENY_BLOCK_TYPE_IP:
		if sourceIP == "" {
			blockRuleErr = fmt.Errorf("missing source IP for IP block")
			break
		}
		ruleResult, err := s.secureDirectCommand(ctx, nodeID, hubpb.CommandType_COMMAND_TYPE_ADD_RULE, &pbProxy.AddRuleRequest{
			ProxyId: proxyID,
			Rule: &pbProxy.Rule{
				Name:    fmt.Sprintf("Block %s", sourceIP),
				Enabled: true,
				Action:  common.ActionType_ACTION_TYPE_BLOCK,
				Conditions: []*pbProxy.Condition{
					{
						Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
						Op:    common.Operator_OPERATOR_EQ,
						Value: sourceIP,
					},
				},
			},
		})
		if err != nil {
			blockRuleErr = err
			break
		}
		if ruleResult.Status != "OK" {
			blockRuleErr = fmt.Errorf("block IP failed: %s", ruleResult.ErrorMessage)
			break
		}
		if len(ruleResult.ResponsePayload) == 0 {
			ruleID = "ip_block_created"
			break
		}
		var rule pbProxy.Rule
		if err := proto.Unmarshal(ruleResult.ResponsePayload, &rule); err != nil {
			blockRuleErr = fmt.Errorf("parse block IP response: %w", err)
			break
		}
		ruleID = rule.Id
	case pb.DenyBlockType_DENY_BLOCK_TYPE_ISP:
		if geoISP == "" {
			blockRuleErr = fmt.Errorf("missing ISP for ISP block")
			break
		}
		ruleResult, err := s.secureDirectCommand(ctx, nodeID, hubpb.CommandType_COMMAND_TYPE_ADD_RULE, &pbProxy.AddRuleRequest{
			ProxyId: proxyID,
			Rule: &pbProxy.Rule{
				Name:    fmt.Sprintf("Block ISP: %s", geoISP),
				Enabled: true,
				Action:  common.ActionType_ACTION_TYPE_BLOCK,
				Conditions: []*pbProxy.Condition{
					{
						Type:  common.ConditionType_CONDITION_TYPE_GEO_ISP,
						Op:    common.Operator_OPERATOR_EQ,
						Value: geoISP,
					},
				},
			},
		})
		if err != nil {
			blockRuleErr = err
			break
		}
		if ruleResult.Status != "OK" {
			blockRuleErr = fmt.Errorf("block ISP failed: %s", ruleResult.ErrorMessage)
			break
		}
		if len(ruleResult.ResponsePayload) == 0 {
			ruleID = "isp_block_created"
			break
		}
		var rule pbProxy.Rule
		if err := proto.Unmarshal(ruleResult.ResponsePayload, &rule); err != nil {
			blockRuleErr = fmt.Errorf("parse block ISP response: %w", err)
			break
		}
		ruleID = rule.Id
	case pb.DenyBlockType_DENY_BLOCK_TYPE_NONE:
	default:
		blockRuleErr = fmt.Errorf("unsupported block type: %s", blockType.String())
	}

	resp := &pb.DenyRequestResponse{
		Success:         blockRuleErr == nil,
		RuleId:          ruleID,
		DecisionApplied: true,
	}
	if blockRuleErr != nil {
		resp.Error = "decision applied but failed to create block rule: " + blockRuleErr.Error()
	}
	return resp, nil
}

// sanitizeNodeID creates a safe node ID from an address.
func sanitizeNodeID(address string) string {
	result := make([]byte, 0, len(address))
	for _, c := range address {
		if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '-' {
			result = append(result, byte(c))
		} else if c == ':' || c == '.' {
			result = append(result, '-')
		}
	}
	return string(result)
}

// deriveLocalKey derives a 32-byte AES key from the identity's root key seed
// using HKDF-SHA256 with a fixed info string for local secret encryption.
func (s *MobileLogicService) deriveLocalKey() ([]byte, error) {
	if s.identity == nil || s.identity.RootKey == nil {
		return nil, fmt.Errorf("identity not available for key derivation")
	}
	seed := s.identity.RootKey.Seed()
	hkdfReader := hkdf.New(sha256.New, seed, nil, []byte("nitella-local-secret-v1"))
	key := make([]byte, 32)
	if _, err := io.ReadFull(hkdfReader, key); err != nil {
		return nil, fmt.Errorf("HKDF key derivation failed: %w", err)
	}
	return key, nil
}

// encryptLocalSecret encrypts plaintext using AES-256-GCM with a key derived from identity.
func (s *MobileLogicService) encryptLocalSecret(plaintext string) ([]byte, error) {
	key, err := s.deriveLocalKey()
	if err != nil {
		return nil, err
	}
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}
	nonce := make([]byte, gcm.NonceSize())
	if _, err := rand.Read(nonce); err != nil {
		return nil, err
	}
	return gcm.Seal(nonce, nonce, []byte(plaintext), nil), nil
}

// decryptLocalSecret decrypts ciphertext using AES-256-GCM with a key derived from identity.
func (s *MobileLogicService) decryptLocalSecret(ciphertext []byte) (string, error) {
	key, err := s.deriveLocalKey()
	if err != nil {
		return "", err
	}
	block, err := aes.NewCipher(key)
	if err != nil {
		return "", err
	}
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return "", err
	}
	nonceSize := gcm.NonceSize()
	if len(ciphertext) < nonceSize {
		return "", fmt.Errorf("ciphertext too short")
	}
	plaintext, err := gcm.Open(nil, ciphertext[:nonceSize], ciphertext[nonceSize:], nil)
	if err != nil {
		return "", err
	}
	return string(plaintext), nil
}

func calculateEmojiHash(caPEM string) string {
	pubKey, err := extractNodePubKey(caPEM)
	if err != nil {
		return ""
	}
	return identity.GenerateEmojiHash(pubKey)
}

// extractNodePubKey extracts the Ed25519 public key from a CA certificate PEM.
func extractNodePubKey(caPEM string) (ed25519.PublicKey, error) {
	block, _ := pem.Decode([]byte(caPEM))
	if block == nil {
		return nil, fmt.Errorf("failed to decode PEM")
	}
	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("parse cert: %w", err)
	}
	pubKey, ok := cert.PublicKey.(ed25519.PublicKey)
	if !ok {
		return nil, fmt.Errorf("not an Ed25519 certificate")
	}
	return pubKey, nil
}

// secureDirectCall sends an E2E encrypted command to a direct node using a temporary LocalConnection.
// Used for one-off calls (e.g. TestDirectConnection) where the client isn't registered with the Controller.
func (s *MobileLogicService) secureDirectCall(ctx context.Context, client pbProxy.ProxyControlServiceClient, token, caPEM string, cmdType hubpb.CommandType, req proto.Message) (*hubpb.CommandResult, error) {
	nodePubKey, err := extractNodePubKey(caPEM)
	if err != nil {
		return nil, fmt.Errorf("extract node pubkey: %w", err)
	}

	if s.identity == nil || s.identity.RootKey == nil {
		return nil, fmt.Errorf("identity not available")
	}

	var payload []byte
	if req != nil {
		payload, err = proto.Marshal(req)
		if err != nil {
			return nil, fmt.Errorf("marshal request: %w", err)
		}
	}

	lc := &core.LocalConnection{
		Client:     client,
		Token:      token,
		NodePubKey: nodePubKey,
	}
	return core.SendCommandLocal(ctx, lc, cmdType, payload, s.identity.RootKey, s.identity.Fingerprint)
}

// secureDirectCommand sends an encrypted command to a stored direct node via the Controller.
func (s *MobileLogicService) secureDirectCommand(ctx context.Context, nodeID string, cmdType hubpb.CommandType, req proto.Message) (*hubpb.CommandResult, error) {
	var payload []byte
	if req != nil {
		var err error
		payload, err = proto.Marshal(req)
		if err != nil {
			return nil, fmt.Errorf("marshal request: %w", err)
		}
	}
	return s.ctrl.SendCommand(ctx, nodeID, cmdType, payload)
}
