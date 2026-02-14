package service

import (
	"context"
	"crypto/ed25519"
	"crypto/x509"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"

	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pb "github.com/ivere27/nitella/pkg/api/local"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/core"
	"github.com/ivere27/nitella/pkg/identity"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// ===========================================================================
// Node Management
// ===========================================================================

// redactNodeInfo returns a copy of NodeInfo with sensitive fields cleared.
func redactNodeInfo(node *pb.NodeInfo) *pb.NodeInfo {
	clone := proto.Clone(node).(*pb.NodeInfo)
	clone.DirectToken = ""
	clone.DirectCaPem = ""
	return clone
}

// ListNodes returns all paired nodes.
func (s *MobileLogicService) ListNodes(ctx context.Context, req *pb.ListNodesRequest) (*pb.ListNodesResponse, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	if err := s.requireIdentity(); err != nil {
		return nil, err
	}

	nodes := make([]*pb.NodeInfo, 0, len(s.nodes))
	onlineCount := int32(0)

	for _, node := range s.nodes {
		// Apply filter
		if req.Filter != "" && req.Filter != "all" {
			if req.Filter == "online" && !node.Online {
				continue
			}
			if req.Filter == "offline" && node.Online {
				continue
			}
		}

		nodes = append(nodes, redactNodeInfo(node))
		if node.Online {
			onlineCount++
		}
	}

	return &pb.ListNodesResponse{
		Nodes:       nodes,
		TotalCount:  int32(len(s.nodes)),
		OnlineCount: onlineCount,
	}, nil
}

// GetNode returns detailed information about a specific node.
func (s *MobileLogicService) GetNode(ctx context.Context, req *pb.GetNodeRequest) (*pb.NodeInfo, error) {
	s.mu.RLock()
	if err := s.requireIdentity(); err != nil {
		s.mu.RUnlock()
		return nil, err
	}
	node, exists := s.nodes[req.NodeId]
	mobileClient := s.mobileClient
	routingToken := s.getRoutingToken(req.NodeId)
	s.mu.RUnlock()

	if !exists {
		return nil, fmt.Errorf("node not found: %s", req.NodeId)
	}

	// Fetch fresh status from Hub if connected
	if mobileClient != nil {
		// Apply standard Hub timeout for node metadata refresh.
		hubCtx, cancel := context.WithTimeout(ctx, defaultHubTimeout)
		hubNode, err := mobileClient.GetNode(hubCtx, &pbHub.GetNodeRequest{
			NodeId:       req.NodeId,
			RoutingToken: routingToken,
		})
		cancel()
		if err == nil && hubNode != nil {
			// Update cached status
			s.mu.Lock()
			if n, ok := s.nodes[req.NodeId]; ok {
				n.Online = hubNode.Status == pbHub.NodeStatus_NODE_STATUS_ONLINE
				n.LastSeen = hubNode.LastSeen
				node = n
			}
			s.mu.Unlock()
		}
	}

	return redactNodeInfo(node), nil
}

// GetNodeDetailSnapshot returns a node-centric snapshot for thin clients.
func (s *MobileLogicService) GetNodeDetailSnapshot(ctx context.Context, req *pb.GetNodeDetailSnapshotRequest) (*pb.NodeDetailSnapshot, error) {
	if req == nil {
		req = &pb.GetNodeDetailSnapshotRequest{}
	}
	nodeID := strings.TrimSpace(req.GetNodeId())
	if nodeID == "" {
		return nil, fmt.Errorf("node_id is required")
	}

	includeRuntimeStatus := req.GetIncludeRuntimeStatus()
	includeProxies := req.GetIncludeProxies()
	includeRules := req.GetIncludeRules()
	includeConnectionStats := req.GetIncludeConnectionStats()

	// Default to a full detail snapshot when no include flag is set.
	if !includeRuntimeStatus && !includeProxies && !includeRules && !includeConnectionStats {
		includeRuntimeStatus = true
		includeProxies = true
		includeRules = true
		includeConnectionStats = true
	}

	node, err := s.GetNode(ctx, &pb.GetNodeRequest{NodeId: nodeID})
	if err != nil {
		return nil, err
	}

	resp := &pb.NodeDetailSnapshot{
		Node: node,
	}

	if includeRuntimeStatus {
		runtime := &pb.NodeRuntimeStatus{
			Status:   "OFFLINE",
			LastSeen: node.GetLastSeen(),
			Version:  node.GetVersion(),
		}
		if node.GetOnline() {
			runtime.Status = "ONLINE"
		}
		if hubNode, err := s.GetNodeFromHub(ctx, &pb.GetNodeFromHubRequest{NodeId: nodeID}); err == nil && hubNode != nil {
			if hubNode.GetStatus() != "" {
				runtime.Status = hubNode.GetStatus()
			}
			if hubNode.GetLastSeen() != nil {
				runtime.LastSeen = hubNode.GetLastSeen()
			}
			runtime.PublicIp = hubNode.GetPublicIp()
			if hubNode.GetVersion() != "" {
				runtime.Version = hubNode.GetVersion()
			}
			runtime.GeoipEnabled = hubNode.GetGeoipEnabled()
		}
		resp.RuntimeStatus = runtime
	}

	needProxies := includeProxies || includeRules
	proxies := make([]*pb.ProxyInfo, 0)
	if needProxies {
		if proxiesResp, err := s.ListProxies(ctx, &pb.ListProxiesRequest{NodeId: nodeID}); err == nil && proxiesResp != nil {
			proxies = proxiesResp.GetProxies()
		}
		if includeProxies {
			resp.Proxies = proxies
		}
	}

	if includeRules {
		rules := make([]*pbProxy.Rule, 0)
		if rulesResp, err := s.ListRules(ctx, &pb.ListRulesRequest{NodeId: nodeID}); err == nil && rulesResp != nil {
			rules = append(rules, rulesResp.GetRules()...)
		}

		// If aggregate list returns empty, retry per proxy for compatibility.
		if len(rules) == 0 && len(proxies) > 0 {
			seen := make(map[string]struct{})
			for _, p := range proxies {
				if p == nil || strings.TrimSpace(p.GetProxyId()) == "" {
					continue
				}
				perProxyResp, err := s.ListRules(ctx, &pb.ListRulesRequest{
					NodeId:  nodeID,
					ProxyId: p.GetProxyId(),
				})
				if err != nil || perProxyResp == nil {
					continue
				}
				for _, rule := range perProxyResp.GetRules() {
					if rule == nil {
						continue
					}
					ruleID := strings.TrimSpace(rule.GetId())
					if ruleID != "" {
						if _, exists := seen[ruleID]; exists {
							continue
						}
						seen[ruleID] = struct{}{}
					}
					rules = append(rules, rule)
				}
			}
		}
		resp.Rules = rules
	}

	if includeConnectionStats {
		if stats, err := s.GetConnectionStats(ctx, &pb.GetConnectionStatsRequest{NodeId: nodeID}); err == nil && stats != nil {
			resp.ConnectionStats = stats
		}
	}

	return resp, nil
}

// UpdateNode updates node metadata (name, tags).
func (s *MobileLogicService) UpdateNode(ctx context.Context, req *pb.UpdateNodeRequest) (*pb.NodeInfo, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if err := s.requireIdentity(); err != nil {
		return nil, err
	}

	node, exists := s.nodes[req.NodeId]
	if !exists {
		return nil, fmt.Errorf("node not found: %s", req.NodeId)
	}

	// Update metadata
	if req.Name != "" {
		node.Name = req.Name
	}
	if len(req.Tags) > 0 {
		node.Tags = req.Tags
	}

	// Persist changes to node metadata file
	if err := s.saveNodeMetadata(req.NodeId, node); err != nil {
		// Non-fatal, changes are in memory
		if s.debugMode {
			log.Printf("warning: failed to save node metadata: %v\n", err)
		}
	}

	return node, nil
}

// RemoveNode removes/unpairs a node.
func (s *MobileLogicService) RemoveNode(ctx context.Context, req *pb.RemoveNodeRequest) (*emptypb.Empty, error) {
	// First, check if node exists and get necessary data
	s.mu.RLock()
	if err := s.requireIdentity(); err != nil {
		s.mu.RUnlock()
		return nil, err
	}
	node, exists := s.nodes[req.NodeId]
	if !exists {
		s.mu.RUnlock()
		return nil, fmt.Errorf("node not found: %s", req.NodeId)
	}
	connType := node.ConnType
	dataDir := s.dataDir
	debugMode := s.debugMode
	mobileClient := s.mobileClient
	routingToken := s.getRoutingToken(req.NodeId)
	directNodes := s.directNodes
	s.mu.RUnlock()

	// Handle direct nodes (lock not needed for directNodes.remove - it has its own lock)
	if connType == pb.NodeConnectionType_NODE_CONNECTION_TYPE_DIRECT {
		if directNodes != nil {
			directNodes.remove(req.NodeId)
		}
	} else {
		// Delete node certificate (only for Hub-paired nodes)
		if err := identity.DeleteNodeCert(dataDir, req.NodeId); err != nil {
			// Non-fatal for deletion
			if debugMode {
				log.Printf("warning: failed to delete node certificate: %v\n", err)
			}
		}

		// Notify Hub to delete node association (lock NOT held during network call)
		if mobileClient != nil {
			delCtx, cancel := context.WithTimeout(ctx, defaultHubTimeout)
			_, err := mobileClient.DeleteNode(delCtx, &pbHub.DeleteNodeRequest{
				NodeId:       req.NodeId,
				RoutingToken: routingToken,
			})
			cancel()
			if err != nil {
				// Non-fatal, local removal succeeded
				if debugMode {
					log.Printf("warning: failed to notify Hub of node deletion: %v\n", err)
				}
			}
		}
	}

	// Acquire write lock for state updates
	s.mu.Lock()
	defer s.mu.Unlock()

	// Remove from memory (re-check existence in case of concurrent removal)
	delete(s.nodes, req.NodeId)
	delete(s.nodePublicKeys, req.NodeId)
	s.restartAlertStreamIfReadyLocked()

	// Delete node metadata file
	_ = s.deleteNodeMetadata(req.NodeId)

	return &emptypb.Empty{}, nil
}

// GetNodeFromHub fetches a node's info directly from Hub.
func (s *MobileLogicService) GetNodeFromHub(ctx context.Context, req *pb.GetNodeFromHubRequest) (*pb.GetNodeFromHubResponse, error) {
	s.mu.RLock()
	ctrl := s.ctrl
	s.mu.RUnlock()

	node, err := ctrl.GetNodeFromHub(ctx, req.NodeId)
	if err != nil {
		return nil, err
	}

	return &pb.GetNodeFromHubResponse{
		NodeId:       node.Id,
		Status:       node.Status.String(),
		LastSeen:     node.LastSeen,
		PublicIp:     node.PublicIp,
		Version:      node.Version,
		GeoipEnabled: node.GeoipEnabled,
	}, nil
}

// RegisterNodeWithHub registers a node with the Hub using a certificate and routing token.
// If no routing token is provided, one is generated automatically.
// After Hub registration, the node is also registered locally (cert saved, in-memory state updated).
func (s *MobileLogicService) RegisterNodeWithHub(ctx context.Context, req *pb.RegisterNodeWithHubRequest) (*pb.RegisterNodeWithHubResponse, error) {
	s.mu.RLock()
	ctrl := s.ctrl
	s.mu.RUnlock()

	// Generate routing token if not provided
	routingToken := req.RoutingToken
	if routingToken == "" {
		routingToken = ctrl.GenerateRoutingToken(req.NodeId)
	}

	if err := ctrl.RegisterNodeWithCert(ctx, req.NodeId, req.CertPem, routingToken); err != nil {
		return &pb.RegisterNodeWithHubResponse{Success: false, Error: err.Error()}, nil
	}

	// Register node locally: save cert, update in-memory state
	s.mu.Lock()
	// Extract public key from the cert for E2E encryption
	pk := extractEd25519PubKeyFromCertPEM([]byte(req.CertPem))
	if err := s.addNodeLocked(req.NodeId, req.NodeId, req.CertPem, pk); err != nil {
		s.mu.Unlock()
		// Node registered on Hub but local save failed — not fatal
		return &pb.RegisterNodeWithHubResponse{
			Success:      true,
			RoutingToken: routingToken,
			Error:        fmt.Sprintf("warning: local registration failed: %v", err),
		}, nil
	}
	// Also register key in controller for immediate E2E use
	if pk != nil {
		ctrl.RegisterNodeKey(req.NodeId, pk)
		ctrl.RegisterNode(&core.NodeInfo{NodeID: req.NodeId, PublicKey: pk})
	}
	s.mu.Unlock()

	return &pb.RegisterNodeWithHubResponse{
		Success:      true,
		RoutingToken: routingToken,
	}, nil
}

// addNodeLocked adds a newly paired node to the service.
// IMPORTANT: Caller must hold s.mu.Lock() before calling this function.
func (s *MobileLogicService) addNodeLocked(nodeID, name, certPEM string, pubKey ed25519.PublicKey) error {
	// NOTE: Lock is held by caller - do NOT lock here to avoid deadlock

	// Save certificate
	if err := identity.SaveNodeCert(s.dataDir, nodeID, []byte(certPEM)); err != nil {
		return fmt.Errorf("failed to save node certificate: %w", err)
	}

	// Add to memory
	var fingerprint, emojiHash string
	if len(pubKey) == ed25519.PublicKeySize {
		fingerprint = identity.GenerateFingerprint(pubKey)
		emojiHash = identity.GenerateEmojiHash(pubKey)
	}

	s.nodes[nodeID] = &pb.NodeInfo{
		NodeId:      nodeID,
		Name:        name,
		Fingerprint: fingerprint,
		EmojiHash:   emojiHash,
		Online:      false, // Will be updated by Hub
		PairedAt:    timestamppb.Now(),
	}

	// Register with P2P transport if available
	if s.p2pTransport != nil {
		if len(pubKey) == ed25519.PublicKeySize {
			s.p2pTransport.RegisterNodeKey(nodeID, pubKey)
		} else if pk := s.getNodePublicKeyLocked(nodeID); pk != nil {
			s.p2pTransport.RegisterNodeKey(nodeID, pk)
		}
	}
	s.restartAlertStreamIfReadyLocked()

	return nil
}

// nodeMetadata is the persisted metadata for a node.
type nodeMetadata struct {
	Name string   `json:"name"`
	Tags []string `json:"tags,omitempty"`
}

// saveNodeMetadata persists node metadata to disk.
func (s *MobileLogicService) saveNodeMetadata(nodeID string, node *pb.NodeInfo) error {
	nodesDir := filepath.Join(s.dataDir, "nodes")
	if err := os.MkdirAll(nodesDir, 0700); err != nil {
		return err
	}

	meta := nodeMetadata{
		Name: node.Name,
		Tags: node.Tags,
	}

	data, err := json.MarshalIndent(meta, "", "  ")
	if err != nil {
		return err
	}

	metaPath := filepath.Join(nodesDir, nodeID+".json")
	return os.WriteFile(metaPath, data, 0600)
}

// deleteNodeMetadata removes node metadata file from disk.
func (s *MobileLogicService) deleteNodeMetadata(nodeID string) error {
	metaPath := filepath.Join(s.dataDir, "nodes", nodeID+".json")
	return os.Remove(metaPath)
}

// extractEd25519PubKeyFromCertPEM extracts the Ed25519 public key from a PEM-encoded certificate.
// Returns nil if the cert can't be parsed or uses a different key type.
func extractEd25519PubKeyFromCertPEM(certPEM []byte) ed25519.PublicKey {
	block, _ := pem.Decode(certPEM)
	if block == nil {
		return nil
	}
	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return nil
	}
	if pk, ok := cert.PublicKey.(ed25519.PublicKey); ok {
		return pk
	}
	return nil
}
