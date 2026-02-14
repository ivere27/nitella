package service

import (
	"context"
	"crypto/ed25519"
	"encoding/json"
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pb "github.com/ivere27/nitella/pkg/api/local"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// ===========================================================================
// Approval Workflow
// ===========================================================================

// ListPendingApprovals lists all pending approval requests.
func (s *MobileLogicService) ListPendingApprovals(ctx context.Context, req *pb.ListPendingApprovalsRequest) (*pb.ListPendingApprovalsResponse, error) {
	// 1. Get memory approvals (Hub)
	s.pendingApprovalsMu.RLock()
	result := make([]*pb.ApprovalRequest, 0, len(s.pendingApprovals))
	for _, r := range s.pendingApprovals {
		if req.NodeId != "" && r.NodeId != req.NodeId {
			continue
		}
		result = append(result, r)
	}
	s.pendingApprovalsMu.RUnlock()

	// 2. If filtering by a Direct Node, fetch from it
	if req.NodeId != "" && s.isDirectNode(req.NodeId) {
		directApprovals, err := s.listPendingApprovalsDirect(ctx, req.NodeId)
		if err == nil {
			result = append(result, directApprovals...)
		} else if s.debugMode {
			log.Printf("listPendingApprovalsDirect failed: %v\n", err)
		}
	}

	return &pb.ListPendingApprovalsResponse{
		Requests:   result,
		TotalCount: int32(len(result)),
	}, nil
}

// GetApprovalsSnapshot returns pending approvals and optional history in one response.
func (s *MobileLogicService) GetApprovalsSnapshot(ctx context.Context, req *pb.GetApprovalsSnapshotRequest) (*pb.GetApprovalsSnapshotResponse, error) {
	if req == nil {
		req = &pb.GetApprovalsSnapshotRequest{}
	}

	pending, err := s.ListPendingApprovals(ctx, &pb.ListPendingApprovalsRequest{
		NodeId: req.GetNodeId(),
	})
	if err != nil {
		return nil, err
	}

	resp := &pb.GetApprovalsSnapshotResponse{
		PendingRequests:                pending.GetRequests(),
		PendingTotalCount:              pending.GetTotalCount(),
		ApproveDurationOptions:         approvalDurationOptions(),
		DefaultApproveDurationSeconds:  defaultApproveDurationSeconds,
		DenyBlockOptions:               denyBlockOptions(),
		RecommendedPollIntervalSeconds: approvalsPollIntervalSeconds(),
	}

	if !req.GetIncludeHistory() {
		return resp, nil
	}

	historyLimit := req.GetHistoryLimit()
	if historyLimit <= 0 {
		historyLimit = defaultApprovalHistoryLimit
	}

	history, err := s.ListApprovalHistory(ctx, &pb.ListApprovalHistoryRequest{
		NodeId: req.GetNodeId(),
		Limit:  historyLimit,
		Offset: req.GetHistoryOffset(),
	})
	if err != nil {
		return nil, err
	}

	resp.HistoryEntries = history.GetEntries()
	resp.HistoryTotalCount = history.GetTotalCount()
	return resp, nil
}

// ApproveRequest approves a connection request.
func (s *MobileLogicService) ApproveRequest(ctx context.Context, req *pb.ApproveRequestRequest) (*pb.ApproveRequestResponse, error) {
	requestID := strings.TrimSpace(req.GetRequestId())
	if requestID == "" {
		return &pb.ApproveRequestResponse{
			Success: false,
			Error:   "request_id is required",
		}, nil
	}

	retentionMode := normalizeApprovalRetentionMode(req.GetRetentionMode())
	if err := validateApprovalDecisionDuration(retentionMode, req.GetDurationSeconds()); err != nil {
		return &pb.ApproveRequestResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}
	durationSeconds := normalizeApprovalDurationSeconds(retentionMode, req.GetDurationSeconds())

	if !s.beginPendingDecision(requestID) {
		return &pb.ApproveRequestResponse{
			Success: false,
			Error:   "decision already in progress for request_id",
		}, nil
	}
	consumed := false
	defer func() {
		s.finishPendingDecision(requestID, consumed)
	}()

	nodeID, reqID, pending, resolveErr := s.resolveApprovalTarget(ctx, requestID)
	if resolveErr != nil {
		return &pb.ApproveRequestResponse{
			Success: false,
			Error:   resolveErr.Error(),
		}, nil
	}

	// Check if direct node
	if s.isDirectNode(nodeID) {
		resp, err := s.approveRequestDirect(ctx, nodeID, reqID, durationSeconds, retentionMode)
		if err != nil {
			return resp, err
		}
		if resp != nil && resp.Success {
			consumed = true
			resp.DecisionApplied = true
			historyErr := s.appendApprovalHistory(s.buildApprovalHistoryEntry(
				pending,
				nodeID,
				pb.ApprovalHistoryAction_APPROVAL_HISTORY_ACTION_APPROVED,
				durationSeconds,
				pb.DenyBlockType_DENY_BLOCK_TYPE_NONE,
				resp.RuleId,
			))
			resp.HistoryPersisted = historyErr == nil
			if historyErr != nil {
				resp.HistoryError = historyErr.Error()
				if resp.Error == "" {
					resp.Error = "decision applied but failed to persist approval history: " + historyErr.Error()
				}
			}
		}
		return resp, nil
	}

	s.mu.RLock()
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if mobileClient == nil {
		return &pb.ApproveRequestResponse{
			Success: false,
			Error:   "not connected to Hub",
		}, nil
	}

	// Send ResolveApproval command to node via Hub
	resolveReq := &pbProxy.ResolveApprovalRequest{
		ReqId:           reqID,
		Action:          common.ApprovalActionType_APPROVAL_ACTION_TYPE_ALLOW,
		RetentionMode:   retentionMode,
		DurationSeconds: durationSeconds,
	}
	payload, err := proto.Marshal(resolveReq)
	if err != nil {
		return &pb.ApproveRequestResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to encode request: %v", err),
		}, nil
	}

	result, err := s.sendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_RESOLVE_APPROVAL, payload)
	if err != nil {
		return &pb.ApproveRequestResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to approve: %v", err),
		}, nil
	}

	if result.Status != "OK" {
		return &pb.ApproveRequestResponse{
			Success: false,
			Error:   result.ErrorMessage,
		}, nil
	}

	// Remove from pending approvals
	consumed = true
	historyErr := s.appendApprovalHistory(s.buildApprovalHistoryEntry(
		pending,
		nodeID,
		pb.ApprovalHistoryAction_APPROVAL_HISTORY_ACTION_APPROVED,
		durationSeconds,
		pb.DenyBlockType_DENY_BLOCK_TYPE_NONE,
		"",
	))

	resp := &pb.ApproveRequestResponse{
		Success:          true,
		DecisionApplied:  true,
		HistoryPersisted: historyErr == nil,
	}
	if historyErr != nil {
		resp.HistoryError = historyErr.Error()
		resp.Error = "decision applied but failed to persist approval history: " + historyErr.Error()
	}
	return resp, nil
}

// DenyRequest denies a connection request.
func (s *MobileLogicService) DenyRequest(ctx context.Context, req *pb.DenyRequestRequest) (*pb.DenyRequestResponse, error) {
	requestID := strings.TrimSpace(req.GetRequestId())
	if requestID == "" {
		return &pb.DenyRequestResponse{
			Success: false,
			Error:   "request_id is required",
		}, nil
	}

	retentionMode := normalizeApprovalRetentionMode(req.GetRetentionMode())
	if err := validateApprovalDecisionDuration(retentionMode, req.GetDurationSeconds()); err != nil {
		return &pb.DenyRequestResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}
	durationSeconds := normalizeApprovalDurationSeconds(retentionMode, req.GetDurationSeconds())
	if err := validateDenyBlockType(req.GetBlockType()); err != nil {
		return &pb.DenyRequestResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}

	if !s.beginPendingDecision(requestID) {
		return &pb.DenyRequestResponse{
			Success: false,
			Error:   "decision already in progress for request_id",
		}, nil
	}
	consumed := false
	defer func() {
		s.finishPendingDecision(requestID, consumed)
	}()

	nodeID, reqID, pending, resolveErr := s.resolveApprovalTarget(ctx, requestID)
	if resolveErr != nil {
		return &pb.DenyRequestResponse{
			Success: false,
			Error:   resolveErr.Error(),
		}, nil
	}

	// Check if direct node
	if s.isDirectNode(nodeID) {
		resp, err := s.denyRequestDirect(ctx, nodeID, reqID, durationSeconds, req.BlockType, retentionMode)
		if err != nil {
			return resp, err
		}
		if resp != nil && resp.GetDecisionApplied() {
			consumed = true
			historyErr := s.appendApprovalHistory(s.buildApprovalHistoryEntry(
				pending,
				nodeID,
				pb.ApprovalHistoryAction_APPROVAL_HISTORY_ACTION_DENIED,
				durationSeconds,
				req.BlockType,
				resp.RuleId,
			))
			resp.HistoryPersisted = historyErr == nil
			if historyErr != nil {
				resp.HistoryError = historyErr.Error()
				if resp.Error == "" {
					resp.Error = "decision applied but failed to persist approval history: " + historyErr.Error()
				}
			}
		}
		return resp, nil
	}

	s.mu.RLock()
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if mobileClient == nil {
		return &pb.DenyRequestResponse{
			Success: false,
			Error:   "not connected to Hub",
		}, nil
	}

	// First, deny the request
	resolveReq := &pbProxy.ResolveApprovalRequest{
		ReqId:           reqID,
		Action:          common.ApprovalActionType_APPROVAL_ACTION_TYPE_BLOCK,
		RetentionMode:   retentionMode,
		DurationSeconds: durationSeconds,
	}
	payload, err := proto.Marshal(resolveReq)
	if err != nil {
		return &pb.DenyRequestResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to encode request: %v", err),
		}, nil
	}

	result, err := s.sendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_RESOLVE_APPROVAL, payload)
	if err != nil {
		return &pb.DenyRequestResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to deny: %v", err),
		}, nil
	}

	if result.Status != "OK" {
		return &pb.DenyRequestResponse{
			Success: false,
			Error:   result.ErrorMessage,
		}, nil
	}

	// If block type is specified, create a block rule
	var ruleID string
	var blockRuleErr error
	switch req.BlockType {
	case pb.DenyBlockType_DENY_BLOCK_TYPE_IP:
		// Use pending approval details to get source IP
		if pending != nil && pending.SourceIp != "" {
			blockResp, err := s.BlockIP(ctx, &pb.BlockIPRequest{
				NodeId: nodeID,
				Ip:     pending.SourceIp,
			})
			if err != nil {
				blockRuleErr = err
			} else if blockResp == nil {
				blockRuleErr = fmt.Errorf("empty block IP response")
			} else if !blockResp.Success {
				blockRuleErr = fmt.Errorf("block IP failed: %s", blockResp.Error)
			} else {
				ruleID = "ip_block_created"
			}
		} else {
			blockRuleErr = fmt.Errorf("missing source IP for IP block")
		}
	case pb.DenyBlockType_DENY_BLOCK_TYPE_ISP:
		// Use pending approval details to get ISP from geo info
		if pending != nil && pending.Geo != nil && pending.Geo.Isp != "" {
			blockResp, err := s.BlockISP(ctx, &pb.BlockISPRequest{
				NodeId: nodeID,
				Isp:    pending.Geo.Isp,
			})
			if err != nil {
				blockRuleErr = err
			} else if blockResp == nil {
				blockRuleErr = fmt.Errorf("empty block ISP response")
			} else if !blockResp.Success {
				blockRuleErr = fmt.Errorf("block ISP failed: %s", blockResp.Error)
			} else {
				ruleID = blockResp.RuleId
			}
		} else {
			blockRuleErr = fmt.Errorf("missing ISP for ISP block")
		}
	}

	// Remove from pending approvals
	consumed = true
	historyErr := s.appendApprovalHistory(s.buildApprovalHistoryEntry(
		pending,
		nodeID,
		pb.ApprovalHistoryAction_APPROVAL_HISTORY_ACTION_DENIED,
		durationSeconds,
		req.BlockType,
		ruleID,
	))

	resp := &pb.DenyRequestResponse{
		Success:          blockRuleErr == nil,
		RuleId:           ruleID,
		DecisionApplied:  true,
		HistoryPersisted: historyErr == nil,
	}
	if blockRuleErr != nil {
		resp.Error = "decision applied but failed to create block rule: " + blockRuleErr.Error()
	}
	if historyErr != nil {
		resp.HistoryError = historyErr.Error()
		if resp.Error == "" {
			resp.Error = "decision applied but failed to persist approval history: " + historyErr.Error()
		}
	}
	return resp, nil
}

// ResolveApprovalDecision resolves an approval request via backend-owned action routing.
func (s *MobileLogicService) ResolveApprovalDecision(ctx context.Context, req *pb.ResolveApprovalDecisionRequest) (*pb.ResolveApprovalDecisionResponse, error) {
	switch req.GetDecision() {
	case pb.ApprovalDecision_APPROVAL_DECISION_APPROVE:
		approveResp, err := s.ApproveRequest(ctx, &pb.ApproveRequestRequest{
			RequestId:       req.GetRequestId(),
			RetentionMode:   req.GetRetentionMode(),
			DurationSeconds: req.GetDurationSeconds(),
		})
		if err != nil {
			return nil, err
		}
		return &pb.ResolveApprovalDecisionResponse{
			Success:          approveResp.GetSuccess(),
			Error:            approveResp.GetError(),
			RuleId:           approveResp.GetRuleId(),
			DecisionApplied:  approveResp.GetDecisionApplied(),
			HistoryPersisted: approveResp.GetHistoryPersisted(),
			HistoryError:     approveResp.GetHistoryError(),
		}, nil

	case pb.ApprovalDecision_APPROVAL_DECISION_DENY:
		denyResp, err := s.DenyRequest(ctx, &pb.DenyRequestRequest{
			RequestId:       req.GetRequestId(),
			RetentionMode:   req.GetRetentionMode(),
			DurationSeconds: req.GetDurationSeconds(),
			BlockType:       req.GetDenyBlockType(),
		})
		if err != nil {
			return nil, err
		}
		return &pb.ResolveApprovalDecisionResponse{
			Success:          denyResp.GetSuccess(),
			Error:            denyResp.GetError(),
			RuleId:           denyResp.GetRuleId(),
			DecisionApplied:  denyResp.GetDecisionApplied(),
			HistoryPersisted: denyResp.GetHistoryPersisted(),
			HistoryError:     denyResp.GetHistoryError(),
		}, nil
	default:
		return &pb.ResolveApprovalDecisionResponse{
			Success: false,
			Error:   "decision is required",
		}, nil
	}
}

func normalizeApprovalRetentionMode(mode common.ApprovalRetentionMode) common.ApprovalRetentionMode {
	switch mode {
	case common.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CONNECTION_ONLY:
		return common.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CONNECTION_ONLY
	case common.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CACHE,
		common.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_UNSPECIFIED:
		fallthrough
	default:
		return common.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CACHE
	}
}

func normalizeApprovalDurationSeconds(mode common.ApprovalRetentionMode, seconds int64) int64 {
	if mode == common.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CACHE && seconds <= 0 {
		return defaultApproveDurationSeconds
	}
	return seconds
}

func validateApprovalDecisionDuration(mode common.ApprovalRetentionMode, seconds int64) error {
	switch mode {
	case common.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CONNECTION_ONLY:
		if seconds < 0 {
			return fmt.Errorf("duration_seconds must be >= 0 for CONNECTION_ONLY mode")
		}
		return nil
	default:
		if seconds < -1 {
			return fmt.Errorf("duration_seconds must be -1 (permanent) or >= 0")
		}
		return nil
	}
}

func validateDenyBlockType(blockType pb.DenyBlockType) error {
	switch blockType {
	case pb.DenyBlockType_DENY_BLOCK_TYPE_NONE,
		pb.DenyBlockType_DENY_BLOCK_TYPE_IP,
		pb.DenyBlockType_DENY_BLOCK_TYPE_ISP:
		return nil
	default:
		return fmt.Errorf("unsupported deny_block_type: %s", blockType.String())
	}
}

// StreamApprovals streams approval requests in real-time.
func (s *MobileLogicService) StreamApprovals(req *pb.StreamApprovalsRequest, stream pb.MobileLogicService_StreamApprovalsServer) error {
	// Create a channel for this stream
	ch := make(chan *pb.ApprovalRequest, 100)

	// Register the channel
	s.approvalStreamsMu.Lock()
	s.approvalStreams = append(s.approvalStreams, ch)
	s.approvalStreamsMu.Unlock()

	// Clean up when done
	defer func() {
		s.approvalStreamsMu.Lock()
		for i, c := range s.approvalStreams {
			if c == ch {
				s.approvalStreams = append(s.approvalStreams[:i], s.approvalStreams[i+1:]...)
				break
			}
		}
		s.approvalStreamsMu.Unlock()
		close(ch)
	}()

	// Stream events
	for {
		select {
		case <-stream.Context().Done():
			return nil
		case approval, ok := <-ch:
			if !ok {
				return nil
			}
			// Apply filter if specified
			if req.NodeId != "" && approval.NodeId != req.NodeId {
				continue
			}
			if err := stream.Send(approval); err != nil {
				return fmt.Errorf("failed to send approval: %w", err)
			}
		}
	}
}

// processIncomingAlert processes an alert received from the Hub's StreamAlerts.
// It decrypts the alert payload and converts it into an ApprovalRequest.
func (s *MobileLogicService) processIncomingAlert(alert *common.Alert, privKey ed25519.PrivateKey) {
	requestID := strings.TrimSpace(alert.GetId())
	if requestID == "" {
		return
	}

	approvalReq := &pb.ApprovalRequest{
		RequestId: requestID,
		NodeId:    alert.NodeId,
	}
	if tsUnix := alert.GetTimestampUnix(); tsUnix > 0 {
		approvalReq.Timestamp = timestamppb.New(time.Unix(tsUnix, 0))
	} else {
		approvalReq.Timestamp = timestamppb.Now()
	}

	// Try to decrypt encrypted payload for details
	if alert.Encrypted != nil && privKey != nil {
		cryptoPayload := &nitellacrypto.EncryptedPayload{
			EphemeralPubKey:   alert.Encrypted.EphemeralPubkey,
			Nonce:             alert.Encrypted.Nonce,
			Ciphertext:        alert.Encrypted.Ciphertext,
			SenderFingerprint: alert.Encrypted.SenderFingerprint,
			Signature:         alert.Encrypted.Signature,
		}

		// Verify signature if present (zero-trust: reject forged alerts)
		if len(cryptoPayload.Signature) > 0 {
			// Look up node public key for signature verification
			if nodePubKey := s.getNodePublicKey(alert.NodeId); nodePubKey != nil {
				if err := nitellacrypto.VerifySignature(cryptoPayload, nodePubKey); err != nil {
					// Signature verification failed — alert may be forged
					return
				}
			}
		}

		if plaintext, err := nitellacrypto.Decrypt(cryptoPayload, privKey); err == nil {
			var info map[string]interface{}
			if json.Unmarshal(plaintext, &info) == nil {
				if v, ok := info["source_ip"].(string); ok {
					approvalReq.SourceIp = v
				}
				if v, ok := info["destination"].(string); ok {
					approvalReq.DestAddr = v
				}
				if v, ok := info["proxy_id"].(string); ok {
					approvalReq.ProxyId = v
				}
			}
		}
	}

	s.handleApprovalRequest(approvalReq)
}

// handleApprovalRequest processes an incoming approval request from a node.
// This is called by the Hub connection handler when an approval alert arrives.
func (s *MobileLogicService) handleApprovalRequest(req *pb.ApprovalRequest) {
	// Store pending approval for later lookup
	s.addPendingApproval(req)

	// Notify all streams
	s.notifyApprovalStreams(req)
}

// addPendingApproval stores a pending approval for later lookup.
func (s *MobileLogicService) addPendingApproval(req *pb.ApprovalRequest) {
	s.pendingApprovalsMu.Lock()
	defer s.pendingApprovalsMu.Unlock()
	s.pendingApprovals[req.RequestId] = req
}

// getPendingApproval retrieves a pending approval by request ID.
func (s *MobileLogicService) getPendingApproval(requestID string) *pb.ApprovalRequest {
	s.pendingApprovalsMu.RLock()
	defer s.pendingApprovalsMu.RUnlock()
	return s.pendingApprovals[requestID]
}

// removePendingApproval removes a pending approval after it's resolved.
func (s *MobileLogicService) removePendingApproval(requestID string) {
	s.pendingApprovalsMu.Lock()
	defer s.pendingApprovalsMu.Unlock()
	delete(s.pendingDecisions, requestID)
	delete(s.pendingApprovals, requestID)
}

func (s *MobileLogicService) beginPendingDecision(requestID string) bool {
	s.pendingApprovalsMu.Lock()
	defer s.pendingApprovalsMu.Unlock()
	if s.pendingDecisions[requestID] {
		return false
	}
	s.pendingDecisions[requestID] = true
	return true
}

func (s *MobileLogicService) finishPendingDecision(requestID string, consume bool) {
	s.pendingApprovalsMu.Lock()
	defer s.pendingApprovalsMu.Unlock()
	delete(s.pendingDecisions, requestID)
	if consume {
		delete(s.pendingApprovals, requestID)
	}
}

func (s *MobileLogicService) resolveApprovalTarget(ctx context.Context, requestID string) (string, string, *pb.ApprovalRequest, error) {
	if pending := s.getPendingApproval(requestID); pending != nil {
		cloned := cloneApprovalRequest(pending)
		if cloned == nil || strings.TrimSpace(cloned.GetNodeId()) == "" {
			return "", "", nil, fmt.Errorf("approval request missing node context")
		}
		return cloned.GetNodeId(), requestID, cloned, nil
	}

	// Best-effort fallback for direct nodes when the request is not in memory.
	s.mu.RLock()
	directNodeIDs := make([]string, 0, len(s.nodes))
	for nodeID := range s.nodes {
		if s.isDirectNodeLocked(nodeID) {
			directNodeIDs = append(directNodeIDs, nodeID)
		}
	}
	s.mu.RUnlock()
	for _, nodeID := range directNodeIDs {
		approvals, err := s.listPendingApprovalsDirect(ctx, nodeID)
		if err != nil {
			continue
		}
		for _, a := range approvals {
			if a != nil && a.GetRequestId() == requestID {
				return nodeID, requestID, cloneApprovalRequest(a), nil
			}
		}
	}

	return "", "", nil, fmt.Errorf("approval request not found: %s", requestID)
}

func cloneApprovalRequest(src *pb.ApprovalRequest) *pb.ApprovalRequest {
	if src == nil {
		return nil
	}

	dst := *src
	if src.Geo != nil {
		geo := *src.Geo
		dst.Geo = &geo
	}
	if src.Timestamp != nil {
		dst.Timestamp = timestamppb.New(src.Timestamp.AsTime())
	}
	return &dst
}

func (s *MobileLogicService) lookupApprovalForDecision(ctx context.Context, nodeID, requestID string) *pb.ApprovalRequest {
	if pending := s.getPendingApproval(requestID); pending != nil {
		return cloneApprovalRequest(pending)
	}

	if s.isDirectNode(nodeID) {
		if approvals, err := s.listPendingApprovalsDirect(ctx, nodeID); err == nil {
			for _, a := range approvals {
				if a != nil && a.RequestId == requestID {
					return cloneApprovalRequest(a)
				}
			}
		}
	}

	return &pb.ApprovalRequest{
		RequestId: requestID,
		NodeId:    nodeID,
	}
}

func (s *MobileLogicService) buildApprovalHistoryEntry(
	pending *pb.ApprovalRequest,
	nodeID string,
	action pb.ApprovalHistoryAction,
	durationSeconds int64,
	blockType pb.DenyBlockType,
	ruleID string,
) *pb.ApprovalHistoryEntry {
	if pending == nil {
		pending = &pb.ApprovalRequest{}
	}

	entry := &pb.ApprovalHistoryEntry{
		RequestId:       pending.RequestId,
		NodeId:          pending.NodeId,
		NodeName:        pending.NodeName,
		ProxyId:         pending.ProxyId,
		ProxyName:       pending.ProxyName,
		SourceIp:        pending.SourceIp,
		DestAddr:        pending.DestAddr,
		Action:          action,
		DurationSeconds: durationSeconds,
		BlockType:       blockType,
		RuleId:          ruleID,
		DecidedAt:       timestamppb.Now(),
	}
	if entry.NodeId == "" {
		entry.NodeId = nodeID
	}
	if pending.Geo != nil {
		entry.Geo = proto.Clone(pending.Geo).(*common.GeoInfo)
	}
	return entry
}

// StreamApprovalsInternal is used by FFI for polling-based streaming.
// It returns the next available approval request or nil if none available.
func (s *MobileLogicService) StreamApprovalsInternal(ctx context.Context, req *pb.StreamApprovalsRequest) (*pb.ApprovalRequest, error) {
	// This is a stub for FFI - in practice, the FFI layer uses RegisterDartCallback
	// to push events to the UI, not polling.
	return nil, nil
}
