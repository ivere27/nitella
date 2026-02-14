package server

import (
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/subtle"
	"crypto/x509"
	"encoding/hex"
	"encoding/pem"
	"log"
	"time"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/hub"
	"github.com/ivere27/nitella/pkg/hub/model"
)

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
		shouldMarkOffline := false
		s.hub.nodeCommandMu.Lock()
		if s.hub.nodeCommandChans[nodeID] == cmdCh {
			delete(s.hub.nodeCommandChans, nodeID)
			// Mark offline only when this is still the active stream.
			// A replaced stream should not flip node status back to offline.
			shouldMarkOffline = true
		}
		s.hub.nodeCommandMu.Unlock()
		if shouldMarkOffline {
			s.hub.store.UpdateNodeStatus(nodeID, "offline")
		}
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
	if resp == nil {
		return nil, status.Error(codes.InvalidArgument, "command response is required")
	}
	if resp.GetEncryptedData() == nil {
		return nil, status.Error(codes.InvalidArgument, "encrypted payload is required")
	}

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
		if metrics.GetEncrypted() == nil {
			return status.Error(codes.InvalidArgument, "encrypted payload is required")
		}
		metrics.NodeId = nodeID

		// Store encrypted metrics in database (Zero-Trust: Hub cannot decrypt)
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
		if logEntry.GetEncrypted() == nil {
			return status.Error(codes.InvalidArgument, "encrypted payload is required")
		}
		logEntry.NodeId = nodeID

		// Zero-Trust: Hub cannot decrypt logs - only relay/store encrypted blob
		// Logs are encrypted with User's public key, only User can decrypt

		// Store encrypted log in database
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
	if alert == nil {
		return nil, status.Error(codes.InvalidArgument, "alert is required")
	}
	if alert.GetEncrypted() == nil {
		return nil, status.Error(codes.InvalidArgument, "encrypted payload is required")
	}

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
