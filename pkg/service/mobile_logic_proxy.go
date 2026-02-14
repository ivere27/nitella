package service

import (
	"context"
	"fmt"
	"strings"

	"github.com/ivere27/nitella/pkg/api/common"
	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pb "github.com/ivere27/nitella/pkg/api/local"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/emptypb"
)

const maxListProxiesLimit int32 = 1000

// ===========================================================================
// Proxy Management
// ===========================================================================

// ListProxies lists all proxies on a node.
func (s *MobileLogicService) ListProxies(ctx context.Context, req *pb.ListProxiesRequest) (*pb.ListProxiesResponse, error) {
	s.mu.RLock()
	if err := s.requireIdentity(); err != nil {
		s.mu.RUnlock()
		return nil, err
	}
	node, exists := s.nodes[req.NodeId]
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if !exists {
		return nil, fmt.Errorf("node not found: %s", req.NodeId)
	}
	if _, err := requireRoutableNode(node, mobileClient, false); err != nil {
		return nil, err
	}

	result, err := s.sendRoutedCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_LIST_PROXIES, &pbProxy.ListProxiesRequest{})
	if err != nil {
		return nil, fmt.Errorf("failed to list proxies: %w", err)
	}

	if result.Status != "OK" {
		return nil, fmt.Errorf("failed to list proxies: %s", result.ErrorMessage)
	}

	var resp pbProxy.ListProxiesResponse
	if err := proto.Unmarshal(result.ResponsePayload, &resp); err != nil {
		return nil, fmt.Errorf("failed to parse list proxies response: %w", err)
	}

	// Convert to mobile API format
	proxies := make([]*pb.ProxyInfo, 0, len(resp.Proxies))
	for _, p := range resp.Proxies {
		proxies = append(proxies, &pb.ProxyInfo{
			ProxyId:           p.ProxyId,
			NodeId:            req.NodeId,
			ListenAddr:        p.ListenAddr,
			DefaultBackend:    p.DefaultBackend,
			Running:           p.Running,
			DefaultAction:     p.DefaultAction,
			FallbackAction:    p.FallbackAction,
			ActiveConnections: p.ActiveConnections,
			TotalConnections:  p.TotalConnections,
		})
	}
	totalCount := int32(len(proxies))
	proxies = paginateProxies(proxies, req.GetOffset(), req.GetLimit(), maxListProxiesLimit)

	return &pb.ListProxiesResponse{
		Proxies:    proxies,
		TotalCount: totalCount,
	}, nil
}

// GetProxiesSnapshot returns node+proxy snapshots for proxy surfaces.
func (s *MobileLogicService) GetProxiesSnapshot(ctx context.Context, req *pb.GetProxiesSnapshotRequest) (*pb.GetProxiesSnapshotResponse, error) {
	if req == nil {
		req = &pb.GetProxiesSnapshotRequest{}
	}

	listReq := &pb.ListNodesRequest{Filter: req.GetNodeFilter()}
	nodesResp, err := s.ListNodes(ctx, listReq)
	if err != nil {
		return nil, err
	}

	nodeSnapshots := make([]*pb.NodeProxiesSnapshot, 0, len(nodesResp.GetNodes()))
	totalProxies := int32(0)

	for _, node := range nodesResp.GetNodes() {
		if node == nil {
			continue
		}
		if req.GetNodeId() != "" && node.GetNodeId() != req.GetNodeId() {
			continue
		}

		proxiesResp, err := s.ListProxies(ctx, &pb.ListProxiesRequest{NodeId: node.GetNodeId()})
		if err != nil {
			proxiesResp = &pb.ListProxiesResponse{Proxies: []*pb.ProxyInfo{}}
		}

		totalProxies += int32(len(proxiesResp.GetProxies()))
		nodeSnapshots = append(nodeSnapshots, &pb.NodeProxiesSnapshot{
			Node:    node,
			Proxies: proxiesResp.GetProxies(),
		})
	}

	return &pb.GetProxiesSnapshotResponse{
		NodeSnapshots: nodeSnapshots,
		TotalNodes:    int32(len(nodeSnapshots)),
		TotalProxies:  totalProxies,
	}, nil
}

// GetProxy returns details about a specific proxy.
func (s *MobileLogicService) GetProxy(ctx context.Context, req *pb.GetProxyRequest) (*pb.ProxyInfo, error) {
	s.mu.RLock()
	if err := s.requireIdentity(); err != nil {
		s.mu.RUnlock()
		return nil, err
	}
	node, exists := s.nodes[req.NodeId]
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if !exists {
		return nil, fmt.Errorf("node not found: %s", req.NodeId)
	}

	isDirect, err := requireRoutableNode(node, mobileClient, false)
	if err != nil {
		return nil, err
	}

	if isDirect {
		return s.getProxyDirect(ctx, req)
	}

	// Send GetStatus command to node via Hub
	getReq := &pbProxy.GetStatusRequest{ProxyId: req.ProxyId}
	payload, err := proto.Marshal(getReq)
	if err != nil {
		return nil, fmt.Errorf("failed to encode get proxy request: %w", err)
	}

	result, err := s.sendCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_STATS_CONTROL, payload)
	if err != nil {
		return nil, fmt.Errorf("failed to get proxy: %w", err)
	}

	if result.Status != "OK" {
		return nil, fmt.Errorf("proxy not found: %s", result.ErrorMessage)
	}

	var resp pbProxy.ProxyStatus
	if err := proto.Unmarshal(result.ResponsePayload, &resp); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	return &pb.ProxyInfo{
		ProxyId:           resp.ProxyId,
		NodeId:            req.NodeId,
		Running:           resp.Running,
		ActiveConnections: resp.ActiveConnections,
		TotalConnections:  resp.TotalConnections,
	}, nil
}

// AddProxy creates a new proxy on a node.
func (s *MobileLogicService) AddProxy(ctx context.Context, req *pb.AddProxyRequest) (*pb.ProxyInfo, error) {
	s.mu.RLock()
	if err := s.requireIdentity(); err != nil {
		s.mu.RUnlock()
		return nil, err
	}
	node, exists := s.nodes[req.NodeId]
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if !exists {
		return nil, fmt.Errorf("node not found: %s", req.NodeId)
	}
	isDirect, err := requireRoutableNode(node, mobileClient, true)
	if err != nil {
		return nil, err
	}

	addReq := &pbProxy.CreateProxyRequest{
		Name:           req.Name,
		ListenAddr:     req.ListenAddr,
		DefaultBackend: req.DefaultBackend,
		DefaultAction:  req.DefaultAction,
		FallbackAction: req.FallbackAction,
	}

	cmdType := pbHub.CommandType_COMMAND_TYPE_APPLY_PROXY
	if isDirect {
		cmdType = pbHub.CommandType_COMMAND_TYPE_CREATE_PROXY
	}
	result, err := s.sendRoutedCommand(ctx, req.NodeId, cmdType, addReq)
	if err != nil {
		return nil, fmt.Errorf("failed to create proxy: %w", err)
	}

	if result.Status != "OK" {
		return nil, fmt.Errorf("failed to create proxy: %s", result.ErrorMessage)
	}

	proxyID := ""
	running := true
	if isDirect {
		var resp pbProxy.CreateProxyResponse
		if len(result.ResponsePayload) > 0 {
			if err := proto.Unmarshal(result.ResponsePayload, &resp); err != nil {
				return nil, fmt.Errorf("failed to parse response: %w", err)
			}
		}
		if !resp.GetSuccess() {
			return nil, fmt.Errorf("failed to create proxy: %s", resp.GetErrorMessage())
		}
		proxyID = resp.GetProxyId()
	} else {
		var resp pbProxy.ProxyStatus
		if err := proto.Unmarshal(result.ResponsePayload, &resp); err != nil {
			return nil, fmt.Errorf("failed to parse response: %w", err)
		}
		proxyID = resp.GetProxyId()
		running = resp.GetRunning()
	}

	return &pb.ProxyInfo{
		ProxyId:        proxyID,
		NodeId:         req.NodeId,
		Name:           req.Name,
		ListenAddr:     req.ListenAddr,
		DefaultBackend: req.DefaultBackend,
		Running:        running,
		DefaultAction:  req.DefaultAction,
		FallbackAction: req.FallbackAction,
		Tags:           req.Tags,
	}, nil
}

// UpdateProxy updates proxy configuration.
func (s *MobileLogicService) UpdateProxy(ctx context.Context, req *pb.UpdateProxyRequest) (*pb.ProxyInfo, error) {
	s.mu.RLock()
	if err := s.requireIdentity(); err != nil {
		s.mu.RUnlock()
		return nil, err
	}
	node, exists := s.nodes[req.NodeId]
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if !exists {
		return nil, fmt.Errorf("node not found: %s", req.NodeId)
	}
	isDirect, err := requireRoutableNode(node, mobileClient, true)
	if err != nil {
		return nil, err
	}

	updateMaskPaths := req.GetUpdateMask().GetPaths()
	configUpdates := hasProxyConfigUpdates(req, updateMaskPaths)
	runningRequested := hasPath(updateMaskPaths, "running")

	// Backward-compat: when no update_mask and no config fields are set, treat
	// this as a running toggle request.
	if !runningRequested && len(updateMaskPaths) == 0 && !configUpdates {
		runningRequested = true
	}

	if runningRequested {
		if err := s.setProxyRunning(ctx, req.NodeId, req.ProxyId, req.Running); err != nil {
			return nil, err
		}
	}

	if !configUpdates {
		return s.GetProxy(ctx, &pb.GetProxyRequest{
			NodeId:  req.NodeId,
			ProxyId: req.ProxyId,
		})
	}

	updateReq := &pbProxy.UpdateProxyRequest{
		ProxyId:        req.ProxyId,
		Name:           req.Name,
		ListenAddr:     req.ListenAddr,
		DefaultBackend: req.DefaultBackend,
		DefaultAction:  req.DefaultAction,
		DefaultMock:    req.DefaultMock,
		FallbackAction: req.FallbackAction,
		FallbackMock:   req.FallbackMock,
		Tags:           req.Tags,
	}

	cmdType := pbHub.CommandType_COMMAND_TYPE_PROXY_UPDATE
	if isDirect {
		cmdType = pbHub.CommandType_COMMAND_TYPE_UPDATE_PROXY
	}
	result, err := s.sendRoutedCommand(ctx, req.NodeId, cmdType, updateReq)
	if err != nil {
		return nil, fmt.Errorf("failed to update proxy: %w", err)
	}

	if result.Status != "OK" {
		return nil, fmt.Errorf("failed to update proxy: %s", result.ErrorMessage)
	}

	return &pb.ProxyInfo{
		ProxyId:        req.ProxyId,
		NodeId:         req.NodeId,
		Name:           req.Name,
		ListenAddr:     req.ListenAddr,
		DefaultBackend: req.DefaultBackend,
		Running:        req.Running,
		DefaultAction:  req.DefaultAction,
		FallbackAction: req.FallbackAction,
		Tags:           req.Tags,
	}, nil
}

// SetNodeProxiesRunning enables/disables all proxies on a node in one call.
func (s *MobileLogicService) SetNodeProxiesRunning(ctx context.Context, req *pb.SetNodeProxiesRunningRequest) (*pb.SetNodeProxiesRunningResponse, error) {
	if req == nil || strings.TrimSpace(req.GetNodeId()) == "" {
		return &pb.SetNodeProxiesRunningResponse{
			Success: false,
			Error:   "node_id is required",
		}, nil
	}

	proxiesResp, err := s.ListProxies(ctx, &pb.ListProxiesRequest{
		NodeId: req.GetNodeId(),
	})
	if err != nil {
		return &pb.SetNodeProxiesRunningResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}

	updatedCount := int32(0)
	skippedCount := int32(0)
	failedProxyIDs := make([]string, 0)
	for _, proxyInfo := range proxiesResp.GetProxies() {
		if proxyInfo == nil || strings.TrimSpace(proxyInfo.GetProxyId()) == "" {
			continue
		}
		if proxyInfo.GetRunning() == req.GetRunning() {
			skippedCount++
			continue
		}
		if err := s.setProxyRunning(ctx, req.GetNodeId(), proxyInfo.GetProxyId(), req.GetRunning()); err != nil {
			failedProxyIDs = append(failedProxyIDs, proxyInfo.GetProxyId())
			continue
		}
		updatedCount++
	}

	if len(failedProxyIDs) > 0 {
		return &pb.SetNodeProxiesRunningResponse{
			Success:        false,
			Error:          fmt.Sprintf("failed to update %d proxy(s)", len(failedProxyIDs)),
			UpdatedCount:   updatedCount,
			SkippedCount:   skippedCount,
			FailedProxyIds: failedProxyIDs,
		}, nil
	}

	return &pb.SetNodeProxiesRunningResponse{
		Success:      true,
		UpdatedCount: updatedCount,
		SkippedCount: skippedCount,
	}, nil
}

// RemoveProxy removes a proxy from a node.
func (s *MobileLogicService) RemoveProxy(ctx context.Context, req *pb.RemoveProxyRequest) (*emptypb.Empty, error) {
	s.mu.RLock()
	if err := s.requireIdentity(); err != nil {
		s.mu.RUnlock()
		return nil, err
	}
	node, exists := s.nodes[req.NodeId]
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if !exists {
		return nil, fmt.Errorf("node not found: %s", req.NodeId)
	}
	isDirect, err := requireRoutableNode(node, mobileClient, true)
	if err != nil {
		return nil, err
	}

	cmdType := pbHub.CommandType_COMMAND_TYPE_UNAPPLY_PROXY
	if isDirect {
		cmdType = pbHub.CommandType_COMMAND_TYPE_DELETE_PROXY
	}
	result, err := s.sendRoutedCommand(ctx, req.NodeId, cmdType, &pbProxy.DeleteProxyRequest{ProxyId: req.ProxyId})
	if err != nil {
		return nil, fmt.Errorf("failed to remove proxy: %w", err)
	}

	if result.Status != "OK" {
		return nil, fmt.Errorf("failed to remove proxy: %s", result.ErrorMessage)
	}

	return &emptypb.Empty{}, nil
}

// getProxyDirect returns proxy details from a direct node.
func (s *MobileLogicService) getProxyDirect(ctx context.Context, req *pb.GetProxyRequest) (*pb.ProxyInfo, error) {
	// Use ListProxies and filter since GetStatus RPC was removed
	result, err := s.secureDirectCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_LIST_PROXIES, &pbProxy.ListProxiesRequest{})
	if err != nil {
		return nil, fmt.Errorf("failed to get proxy: %w", err)
	}
	if result.Status != "OK" {
		return nil, fmt.Errorf("failed to get proxy: %s", result.ErrorMessage)
	}

	var listResp pbProxy.ListProxiesResponse
	if len(result.ResponsePayload) > 0 {
		if err := proto.Unmarshal(result.ResponsePayload, &listResp); err != nil {
			return nil, fmt.Errorf("failed to parse response: %w", err)
		}
	}

	for _, p := range listResp.Proxies {
		if p.ProxyId == req.ProxyId {
			return &pb.ProxyInfo{
				ProxyId:           p.ProxyId,
				NodeId:            req.NodeId,
				Running:           p.Running,
				ActiveConnections: p.ActiveConnections,
				TotalConnections:  p.TotalConnections,
			}, nil
		}
	}

	return nil, fmt.Errorf("proxy not found: %s", req.ProxyId)
}

func hasPath(paths []string, target string) bool {
	for _, path := range paths {
		if path == target {
			return true
		}
	}
	return false
}

func paginateProxies(proxies []*pb.ProxyInfo, offset, limit, maxLimit int32) []*pb.ProxyInfo {
	if offset < 0 {
		offset = 0
	}
	if limit <= 0 {
		limit = maxLimit
	} else if limit > maxLimit {
		limit = maxLimit
	}

	start := int(offset)
	if start >= len(proxies) {
		return []*pb.ProxyInfo{}
	}

	end := start + int(limit)
	if end > len(proxies) {
		end = len(proxies)
	}
	return proxies[start:end]
}

func hasProxyConfigUpdates(req *pb.UpdateProxyRequest, updateMaskPaths []string) bool {
	if req == nil {
		return false
	}

	if req.GetName() != "" ||
		req.GetListenAddr() != "" ||
		req.GetDefaultBackend() != "" ||
		req.GetDefaultAction() != common.ActionType_ACTION_TYPE_UNSPECIFIED ||
		req.GetDefaultMock() != common.MockPreset_MOCK_PRESET_UNSPECIFIED ||
		req.GetFallbackAction() != common.FallbackAction_FALLBACK_ACTION_UNSPECIFIED ||
		req.GetFallbackMock() != common.MockPreset_MOCK_PRESET_UNSPECIFIED ||
		len(req.GetTags()) > 0 {
		return true
	}

	for _, path := range updateMaskPaths {
		if path != "running" {
			return true
		}
	}
	return false
}

func (s *MobileLogicService) setProxyRunning(ctx context.Context, nodeID, proxyID string, running bool) error {
	proxyID = strings.TrimSpace(proxyID)
	if proxyID == "" {
		return fmt.Errorf("proxy_id is required")
	}

	var cmdType pbHub.CommandType
	var req proto.Message
	if running {
		cmdType = pbHub.CommandType_COMMAND_TYPE_ENABLE_PROXY
		req = &pbProxy.EnableProxyRequest{ProxyId: proxyID}
	} else {
		cmdType = pbHub.CommandType_COMMAND_TYPE_DISABLE_PROXY
		req = &pbProxy.DisableProxyRequest{ProxyId: proxyID}
	}

	result, err := s.sendRoutedCommand(ctx, nodeID, cmdType, req)
	if err != nil {
		return fmt.Errorf("failed to set proxy running state: %w", err)
	}
	if result.GetStatus() != "OK" {
		return fmt.Errorf("failed to set proxy running state: %s", result.GetErrorMessage())
	}
	return nil
}

// Helper to convert ActionType enum to string for display
func actionTypeToString(at common.ActionType) string {
	switch at {
	case common.ActionType_ACTION_TYPE_ALLOW:
		return "allow"
	case common.ActionType_ACTION_TYPE_BLOCK:
		return "block"
	case common.ActionType_ACTION_TYPE_MOCK:
		return "mock"
	case common.ActionType_ACTION_TYPE_REQUIRE_APPROVAL:
		return "ask"
	default:
		return "unknown"
	}
}
