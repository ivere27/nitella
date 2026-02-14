package server

import (
	"context"
	"crypto/ed25519"
	"crypto/x509"
	"encoding/pem"
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/google/uuid"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/hub"
	"github.com/ivere27/nitella/pkg/hub/auth"
	"github.com/ivere27/nitella/pkg/hub/model"
	"github.com/ivere27/nitella/pkg/tier"
)

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

func (s *MobileServer) RegisterNodeWithCert(ctx context.Context, req *pb.RegisterNodeWithCertRequest) (*emptypb.Empty, error) {
	if req.NodeId == "" || req.CertPem == "" || req.RoutingToken == "" || req.CaPem == "" {
		return nil, status.Error(codes.InvalidArgument, "node_id, cert_pem, ca_pem, and routing_token are required")
	}

	certBlock, _ := pem.Decode([]byte(req.CertPem))
	if certBlock == nil {
		return nil, status.Error(codes.InvalidArgument, "invalid cert_pem")
	}
	nodeCert, err := x509.ParseCertificate(certBlock.Bytes)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "failed to parse cert_pem: %v", err)
	}

	caBlock, _ := pem.Decode([]byte(req.CaPem))
	if caBlock == nil {
		return nil, status.Error(codes.InvalidArgument, "invalid ca_pem")
	}
	caCert, err := x509.ParseCertificate(caBlock.Bytes)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "failed to parse ca_pem: %v", err)
	}

	auditPubKey, ok := caCert.PublicKey.(ed25519.PublicKey)
	if !ok {
		return nil, status.Error(codes.InvalidArgument, "CA certificate must contain Ed25519 public key")
	}

	roots := x509.NewCertPool()
	roots.AddCert(caCert)
	if _, err := nodeCert.Verify(x509.VerifyOptions{
		Roots:     roots,
		KeyUsages: []x509.ExtKeyUsage{x509.ExtKeyUsageClientAuth},
	}); err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "cert_pem is not signed by ca_pem: %v", err)
	}

	userID, ok := ctx.Value(ctxKeyUserID).(string)
	if !ok || userID == "" {
		return nil, status.Error(codes.Unauthenticated, "user not authenticated")
	}

	user, err := s.hub.store.GetUser(userID)
	if err != nil {
		return nil, status.Error(codes.Unauthenticated, "user not found")
	}

	// Trust this CA for future mTLS verification of node certs.
	if s.hub.certMgr != nil {
		if err := s.hub.certMgr.AddClientCA([]byte(req.CaPem)); err != nil {
			log.Printf("[Mobile] Warning: failed to add node CA to cert manager for %s: %v", req.NodeId, err)
		}
	}

	// Save Node
	node := &model.Node{
		ID:                req.NodeId,
		RoutingToken:      req.RoutingToken,
		CertPEM:           req.CertPem,
		EncryptedMetadata: req.EncryptedMetadata,
		Status:            "offline",
	}
	if err := s.hub.store.SaveNode(node); err != nil {
		return nil, status.Errorf(codes.Internal, "Failed to save node: %v", err)
	}

	// Save RoutingTokenInfo (inherit User's Tier and License)
	info := &model.RoutingTokenInfo{
		RoutingToken: req.RoutingToken,
		LicenseKey:   user.InviteCode,
		Tier:         user.Tier,
		AuditPubKey:  auditPubKey,
	}

	if err := s.hub.store.SaveRoutingTokenInfo(info); err != nil {
		return nil, status.Errorf(codes.Internal, "Failed to save routing info: %v", err)
	}

	// Persist CA->routing token mapping so cert manager bootstrap and pinning/JIT
	// continue to work after Hub restarts.
	regCode := "pake-" + uuid.NewSHA1(uuid.NameSpaceOID, []byte(req.NodeId+"\x00"+req.RoutingToken)).String()
	if err := s.hub.store.SaveRegistrationRequest(&model.RegistrationRequest{
		Code:         regCode,
		NodeID:       req.NodeId,
		Status:       "APPROVED",
		CertPEM:      req.CertPem,
		CaPEM:        req.CaPem,
		RoutingToken: req.RoutingToken,
		LicenseKey:   user.InviteCode,
		ExpiresAt:    time.Now().Add(10 * 365 * 24 * time.Hour),
	}); err != nil {
		return nil, status.Errorf(codes.Internal, "Failed to persist CA mapping: %v", err)
	}

	shortToken := req.RoutingToken
	if len(shortToken) > 8 {
		shortToken = shortToken[:8] + "..."
	}
	log.Printf("[Mobile] Registered Node %s (Token: %s) for User %s", req.NodeId, shortToken, userID)

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
			Status:   nodeStatusFromStore(n.Status),
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
		Status:   nodeStatusFromStore(node.Status),
		LastSeen: timestamppb.New(node.LastSeen),
	}, nil
}

func nodeStatusFromStore(status string) pb.NodeStatus {
	switch strings.ToLower(strings.TrimSpace(status)) {
	case "online":
		return pb.NodeStatus_NODE_STATUS_ONLINE
	case "offline":
		return pb.NodeStatus_NODE_STATUS_OFFLINE
	case "blocked":
		return pb.NodeStatus_NODE_STATUS_BLOCKED
	case "connecting":
		return pb.NodeStatus_NODE_STATUS_CONNECTING
	default:
		return pb.NodeStatus_NODE_STATUS_UNSPECIFIED
	}
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

	if req.GetEncrypted() == nil {
		return nil, status.Error(codes.InvalidArgument, "encrypted payload is required")
	}

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
	// Collect all routing tokens to subscribe to
	tokens := make(map[string]bool)

	// 1. From explicit list
	for _, t := range req.RoutingTokens {
		if t != "" {
			tokens[t] = true
		}
	}

	// 2. From node_id lookup
	if req.NodeId != "" {
		node, err := s.hub.store.GetNode(req.NodeId)
		if err == nil {
			tokens[node.RoutingToken] = true
		} else {
			// If specific node requested but not found, return error
			return status.Error(codes.NotFound, "Node not found")
		}
	}

	// 3. From context (node authentication)
	if rt := stream.Context().Value(ctxKeyRoutingToken); rt != nil {
		if t, ok := rt.(string); ok && t != "" {
			tokens[t] = true
		}
	}

	if len(tokens) == 0 {
		return status.Error(codes.InvalidArgument, "routing_token or node_id required")
	}

	// Create shared alert channel
	alertCh := make(chan *common.Alert, 10)

	// Register in userStreams for ALL tokens
	s.hub.userStreamsMu.Lock()
	for token := range tokens {
		if s.hub.userStreams[token] == nil {
			s.hub.userStreams[token] = make(map[chan *common.Alert]bool)
		}
		s.hub.userStreams[token][alertCh] = true
	}
	s.hub.userStreamsMu.Unlock()

	// Cleanup on disconnect
	defer func() {
		s.hub.userStreamsMu.Lock()
		for token := range tokens {
			if listeners, ok := s.hub.userStreams[token]; ok {
				delete(listeners, alertCh)
				if len(listeners) == 0 {
					delete(s.hub.userStreams, token)
				}
			}
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
		// Check for duplicate proxy_id (primary key)
		if strings.Contains(err.Error(), "UNIQUE") || strings.Contains(err.Error(), "duplicate") {
			return &pb.CreateProxyConfigResponse{
				Success: false,
				Error:   "proxy already exists",
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
		Success:        true,
		RevisionNum:    nextRevNum,
		RevisionsKept:  revisionsKept,
		RevisionsLimit: int32(revisionsLimit),
		StorageUsedKb:  int32(currentStorage / 1024),
		StorageLimitKb: int32(limits.MaxStorageKB),
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
