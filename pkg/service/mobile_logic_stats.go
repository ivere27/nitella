package service

import (
	"context"
	"fmt"

	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pb "github.com/ivere27/nitella/pkg/api/local"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	"google.golang.org/protobuf/proto"
)

const maxListConnectionsLimit int32 = 1000

// ===========================================================================
// Connection Statistics
// ===========================================================================

// GetConnectionStats returns connection statistics summary.
func (s *MobileLogicService) GetConnectionStats(ctx context.Context, req *pb.GetConnectionStatsRequest) (*pb.ConnectionStats, error) {
	s.mu.RLock()
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	// Aggregate stats from all nodes or specific node.
	stats := &pb.ConnectionStats{
		RecommendedPollIntervalSeconds: statsPollIntervalSeconds(),
	}

	if req.NodeId != "" {
		s.mu.RLock()
		node, exists := s.nodes[req.NodeId]
		s.mu.RUnlock()

		if !exists {
			return nil, fmt.Errorf("node not found: %s", req.NodeId)
		}

		// Use cached metrics first
		if node.Metrics != nil {
			stats.ActiveConnections = node.Metrics.ActiveConnections
			stats.TotalConnections = node.Metrics.TotalConnections
			stats.BytesIn = node.Metrics.BytesIn
			stats.BytesOut = node.Metrics.BytesOut
			stats.BlockedTotal = node.Metrics.BlockedTotal
		}

		// If reachable (online via P2P or Hub connected), fetch real-time stats from node
		if node.Online || mobileClient != nil {
			statsReq := &pbProxy.GetStatsSummaryRequest{}
			payload, err := proto.Marshal(statsReq)
			if err != nil {
				return nil, fmt.Errorf("failed to encode stats request: %w", err)
			}

			result, err := s.sendCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_STATS_CONTROL, payload)
			if err == nil && result.Status == "OK" {
				var statsResp pbProxy.StatsSummaryResponse
				if proto.Unmarshal(result.ResponsePayload, &statsResp) == nil {
					stats.TotalConnections = statsResp.TotalConnections
					stats.BytesIn = statsResp.TotalBytesIn
					stats.BytesOut = statsResp.TotalBytesOut
					stats.BlockedTotal = statsResp.BlockedTotal
				}
			}
		}
	} else {
		// Aggregate from all nodes
		s.mu.RLock()
		for _, node := range s.nodes {
			if node.Metrics != nil {
				stats.ActiveConnections += node.Metrics.ActiveConnections
				stats.TotalConnections += node.Metrics.TotalConnections
				stats.BytesIn += node.Metrics.BytesIn
				stats.BytesOut += node.Metrics.BytesOut
				stats.BlockedTotal += node.Metrics.BlockedTotal
			}
		}
		s.mu.RUnlock()
	}

	return stats, nil
}

// ListConnections lists active connections.
func (s *MobileLogicService) ListConnections(ctx context.Context, req *pb.ListConnectionsRequest) (*pb.ListConnectionsResponse, error) {
	if req == nil {
		req = &pb.ListConnectionsRequest{}
	}

	s.mu.RLock()
	node, exists := s.nodes[req.NodeId]
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if !exists {
		return nil, fmt.Errorf("node not found: %s", req.NodeId)
	}

	if !node.Online && mobileClient == nil {
		return &pb.ListConnectionsResponse{
			Connections: []*pb.ConnectionInfo{},
			TotalCount:  0,
		}, nil
	}

	// Send GetActiveConnections command to node via Hub
	connReq := &pbProxy.GetActiveConnectionsRequest{
		NodeId:  req.NodeId,
		ProxyId: req.ProxyId,
	}
	payload, err := proto.Marshal(connReq)
	if err != nil {
		return nil, fmt.Errorf("failed to encode list connections request: %w", err)
	}

	result, err := s.sendCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_GET_ACTIVE_CONNECTIONS, payload)
	if err != nil {
		return nil, fmt.Errorf("failed to list connections: %w", err)
	}

	if result.Status != "OK" {
		return nil, fmt.Errorf("failed to list connections: %s", result.ErrorMessage)
	}

	var connResp pbProxy.GetActiveConnectionsResponse
	if err := proto.Unmarshal(result.ResponsePayload, &connResp); err != nil {
		return nil, fmt.Errorf("failed to parse list connections response: %w", err)
	}

	// Convert to mobile API format
	connections := make([]*pb.ConnectionInfo, 0, len(connResp.Connections))
	for _, c := range connResp.Connections {
		conn := &pb.ConnectionInfo{
			ConnId:     c.Id,
			NodeId:     req.NodeId,
			ProxyId:    req.ProxyId,
			SourceIp:   c.SourceIp,
			SourcePort: c.SourcePort,
			DestAddr:   c.DestAddr,
			StartTime:  c.StartTime,
			BytesIn:    c.BytesIn,
			BytesOut:   c.BytesOut,
		}
		if c.Geo != nil {
			conn.Geo = c.Geo
		}
		connections = append(connections, conn)
	}

	totalCount := int32(len(connections))
	connections = paginateConnections(connections, req.GetOffset(), req.GetLimit(), maxListConnectionsLimit)

	return &pb.ListConnectionsResponse{
		Connections: connections,
		TotalCount:  totalCount,
	}, nil
}

func paginateConnections(connections []*pb.ConnectionInfo, offset, limit, maxLimit int32) []*pb.ConnectionInfo {
	total := len(connections)
	if total == 0 {
		return connections
	}

	if offset < 0 {
		offset = 0
	}
	start := int(offset)
	if start >= total {
		return []*pb.ConnectionInfo{}
	}

	switch {
	case limit <= 0:
		limit = maxLimit
	case limit > maxLimit:
		limit = maxLimit
	}
	if limit <= 0 {
		limit = int32(total - start)
	}

	end := start + int(limit)
	if end > total {
		end = total
	}
	return connections[start:end]
}

// GetIPStats returns IP-based statistics.
func (s *MobileLogicService) GetIPStats(ctx context.Context, req *pb.GetIPStatsRequest) (*pb.GetIPStatsResponse, error) {
	s.mu.RLock()
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if req.NodeId != "" {
		s.mu.RLock()
		_, exists := s.nodes[req.NodeId]
		s.mu.RUnlock()
		if !exists {
			return nil, fmt.Errorf("node not found: %s", req.NodeId)
		}
	}

	if mobileClient == nil {
		return &pb.GetIPStatsResponse{
			Stats:      []*pb.IPStats{},
			TotalCount: 0,
		}, nil
	}

	// IP stats are typically aggregated from connection history
	// For now, return empty - this requires historical data storage
	return &pb.GetIPStatsResponse{
		Stats:      []*pb.IPStats{},
		TotalCount: 0,
	}, nil
}

// GetGeoStats returns geo-based statistics.
func (s *MobileLogicService) GetGeoStats(ctx context.Context, req *pb.GetGeoStatsRequest) (*pb.GetGeoStatsResponse, error) {
	s.mu.RLock()
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if req.NodeId != "" {
		s.mu.RLock()
		_, exists := s.nodes[req.NodeId]
		s.mu.RUnlock()
		if !exists {
			return nil, fmt.Errorf("node not found: %s", req.NodeId)
		}
	}

	if mobileClient == nil {
		return &pb.GetGeoStatsResponse{
			Stats:      []*pb.GeoStats{},
			TotalCount: 0,
		}, nil
	}

	// Geo stats are typically aggregated from connection history
	// For now, return empty - this requires historical data storage
	return &pb.GetGeoStatsResponse{
		Stats:      []*pb.GeoStats{},
		TotalCount: 0,
	}, nil
}

// StreamConnections streams connection events in real-time.
func (s *MobileLogicService) StreamConnections(req *pb.StreamConnectionsRequest, stream pb.MobileLogicService_StreamConnectionsServer) error {
	// For direct nodes, use local streaming via Controller
	if req.NodeId != "" && s.isDirectNode(req.NodeId) {
		s.mu.RLock()
		ctrl := s.ctrl
		s.mu.RUnlock()
		return ctrl.StreamLocalConnections(stream.Context(), req.NodeId, func(event *pbProxy.ConnectionEvent) {
			_ = stream.Send(&pb.ConnectionEvent{
				ConnId:      event.ConnId,
				NodeId:      req.NodeId,
				SourceIp:    event.SourceIp,
				SourcePort:  event.SourcePort,
				DestAddr:    event.TargetAddr,
				EventType:   pb.ConnectionEvent_EventType(event.EventType),
				RuleMatched: event.RuleMatched,
				ActionTaken: event.ActionTaken,
				BytesIn:     event.BytesIn,
				BytesOut:    event.BytesOut,
				Geo:         event.Geo,
			})
		})
	}

	// Create a channel for this stream
	ch := make(chan *pb.ConnectionEvent, 100)

	// Register the channel
	s.connStreamsMu.Lock()
	s.connStreams = append(s.connStreams, ch)
	s.connStreamsMu.Unlock()

	// Clean up when done
	defer func() {
		s.connStreamsMu.Lock()
		for i, c := range s.connStreams {
			if c == ch {
				s.connStreams = append(s.connStreams[:i], s.connStreams[i+1:]...)
				break
			}
		}
		s.connStreamsMu.Unlock()
		close(ch)
	}()

	// Stream events
	for {
		select {
		case <-stream.Context().Done():
			return nil
		case event, ok := <-ch:
			if !ok {
				return nil
			}
			// Apply filter if specified
			if req.NodeId != "" && event.NodeId != req.NodeId {
				continue
			}
			if req.ProxyId != "" && event.ProxyId != req.ProxyId {
				continue
			}
			if err := stream.Send(event); err != nil {
				return fmt.Errorf("failed to send event: %w", err)
			}
		}
	}
}

// handleConnectionEvent processes an incoming connection event from a node.
func (s *MobileLogicService) handleConnectionEvent(event *pb.ConnectionEvent) {
	// Notify all streams
	s.notifyConnectionStreams(event)
}

// StreamConnectionsInternal is used by FFI for polling-based streaming.
// It returns the next available connection event or nil if none available.
func (s *MobileLogicService) StreamConnectionsInternal(ctx context.Context, req *pb.StreamConnectionsRequest) (*pb.ConnectionEvent, error) {
	// This is a stub for FFI - in practice, the FFI layer uses RegisterDartCallback
	// to push events to the UI, not polling.
	return nil, nil
}

// CloseConnection closes a specific connection on a node.
func (s *MobileLogicService) CloseConnection(ctx context.Context, req *pb.CloseConnectionRequest) (*pb.CloseConnectionResponse, error) {
	// Validate that at least one identifier is set (oneof)
	if req.GetConnId() == "" && req.GetSourceIp() == "" {
		return &pb.CloseConnectionResponse{
			Success: false,
			Error:   "either conn_id or source_ip must be specified",
		}, nil
	}

	s.mu.RLock()
	node, exists := s.nodes[req.NodeId]
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if !exists {
		return &pb.CloseConnectionResponse{
			Success: false,
			Error:   fmt.Sprintf("node not found: %s", req.NodeId),
		}, nil
	}

	if !node.Online && mobileClient == nil {
		return &pb.CloseConnectionResponse{
			Success: false,
			Error:   "node is offline or Hub not connected",
		}, nil
	}

	// Send CloseConnection command to node via Hub
	closeReq := &pbProxy.CloseConnectionRequest{
		ProxyId: req.ProxyId,
		ConnId:  req.GetConnId(),
	}
	payload, err := proto.Marshal(closeReq)
	if err != nil {
		return &pb.CloseConnectionResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to encode close connection request: %v", err),
		}, nil
	}

	result, err := s.sendCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_CLOSE_CONNECTION, payload)
	if err != nil {
		return &pb.CloseConnectionResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to send command: %v", err),
		}, nil
	}

	if result.Status != "OK" {
		return &pb.CloseConnectionResponse{
			Success: false,
			Error:   result.ErrorMessage,
		}, nil
	}

	return &pb.CloseConnectionResponse{
		Success: true,
	}, nil
}

// StreamMetrics streams node metrics via Hub or direct connection.
func (s *MobileLogicService) StreamMetrics(req *pb.StreamMetricsRequest, stream pb.MobileLogicService_StreamMetricsServer) error {
	s.mu.RLock()
	ctrl := s.ctrl
	s.mu.RUnlock()

	// For direct nodes, use local streaming via Controller
	if req.NodeId != "" && s.isDirectNode(req.NodeId) {
		interval := req.IntervalSeconds
		if interval <= 0 {
			interval = 1
		}
		return ctrl.StreamLocalMetrics(stream.Context(), req.NodeId, interval, func(sample *pbProxy.MetricsSample) {
			_ = stream.Send(&pb.NodeMetrics{
				ActiveConnections: sample.ActiveConns,
				TotalConnections:  sample.TotalConns,
				BytesIn:           sample.BytesInRate,
				BytesOut:          sample.BytesOutRate,
				BlockedTotal:      sample.BlockedTotal,
			})
		})
	}

	errCh := make(chan error, 1)
	err := ctrl.StreamMetrics(stream.Context(), req.NodeId, func(nodeID string, metrics *pbHub.Metrics) {
		nodeMetrics := &pb.NodeMetrics{
			ActiveConnections: int64(metrics.ConnectionsActive),
			TotalConnections:  int64(metrics.ConnectionsTotal),
			BytesIn:           int64(metrics.BytesIn),
			BytesOut:          int64(metrics.BytesOut),
			BlockedTotal:      int64(metrics.BlockedCount),
		}
		if err := stream.Send(nodeMetrics); err != nil {
			select {
			case errCh <- err:
			default:
			}
		}
	})
	if err != nil {
		return err
	}

	// Wait for context cancellation or send error
	select {
	case <-stream.Context().Done():
		return nil
	case err := <-errCh:
		return err
	}
}

// StreamMetricsInternal is used by FFI for polling-based metrics streaming.
func (s *MobileLogicService) StreamMetricsInternal(ctx context.Context, req *pb.StreamMetricsRequest) (*pb.NodeMetrics, error) {
	// Stub for FFI polling - in practice, metrics are pushed via callbacks
	return nil, nil
}

// CloseAllConnections closes all connections on a proxy.
func (s *MobileLogicService) CloseAllConnections(ctx context.Context, req *pb.CloseAllConnectionsRequest) (*pb.CloseAllConnectionsResponse, error) {
	if req == nil || req.GetNodeId() == "" || req.GetProxyId() == "" {
		return &pb.CloseAllConnectionsResponse{
			Success: false,
			Error:   "node_id and proxy_id are required",
		}, nil
	}

	s.mu.RLock()
	node, exists := s.nodes[req.NodeId]
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if !exists {
		return &pb.CloseAllConnectionsResponse{
			Success: false,
			Error:   fmt.Sprintf("node not found: %s", req.NodeId),
		}, nil
	}

	closeReq := &pbProxy.CloseAllConnectionsRequest{
		ProxyId: req.ProxyId,
	}

	if s.isDirectNode(req.NodeId) {
		result, err := s.secureDirectCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_CLOSE_ALL_CONNECTIONS, closeReq)
		if err != nil {
			return &pb.CloseAllConnectionsResponse{
				Success: false,
				Error:   fmt.Sprintf("failed to send command: %v", err),
			}, nil
		}
		if result.Status != "OK" {
			return &pb.CloseAllConnectionsResponse{
				Success: false,
				Error:   result.ErrorMessage,
			}, nil
		}
		var closeResp pbProxy.CloseAllConnectionsResponse
		if len(result.ResponsePayload) > 0 {
			_ = proto.Unmarshal(result.ResponsePayload, &closeResp)
		}
		if !closeResp.GetSuccess() && closeResp.GetErrorMessage() != "" {
			return &pb.CloseAllConnectionsResponse{
				Success: false,
				Error:   closeResp.GetErrorMessage(),
			}, nil
		}
		return &pb.CloseAllConnectionsResponse{Success: true}, nil
	}

	if !node.Online && mobileClient == nil {
		return &pb.CloseAllConnectionsResponse{
			Success: false,
			Error:   "node is offline or Hub not connected",
		}, nil
	}

	// Send CloseAllConnections command to node via Hub.
	payload, err := proto.Marshal(closeReq)
	if err != nil {
		return &pb.CloseAllConnectionsResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to encode close-all-connections request: %v", err),
		}, nil
	}

	result, err := s.sendCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_CLOSE_ALL_CONNECTIONS, payload)
	if err != nil {
		return &pb.CloseAllConnectionsResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to send command: %v", err),
		}, nil
	}

	if result.Status != "OK" {
		return &pb.CloseAllConnectionsResponse{
			Success: false,
			Error:   result.ErrorMessage,
		}, nil
	}

	var closeResp pbProxy.CloseAllConnectionsResponse
	if len(result.ResponsePayload) > 0 {
		_ = proto.Unmarshal(result.ResponsePayload, &closeResp)
	}
	if !closeResp.GetSuccess() && closeResp.GetErrorMessage() != "" {
		return &pb.CloseAllConnectionsResponse{
			Success: false,
			Error:   closeResp.GetErrorMessage(),
		}, nil
	}

	return &pb.CloseAllConnectionsResponse{
		Success: true,
	}, nil
}

// CloseAllNodeConnections closes all active connections across all proxies on a node.
func (s *MobileLogicService) CloseAllNodeConnections(ctx context.Context, req *pb.CloseAllNodeConnectionsRequest) (*pb.CloseAllNodeConnectionsResponse, error) {
	if req == nil || req.GetNodeId() == "" {
		return &pb.CloseAllNodeConnectionsResponse{
			Success: false,
			Error:   "node_id is required",
		}, nil
	}

	proxiesResp, err := s.ListProxies(ctx, &pb.ListProxiesRequest{
		NodeId: req.GetNodeId(),
	})
	if err != nil {
		return &pb.CloseAllNodeConnectionsResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}

	processed := int32(0)
	totalClosed := int32(0)
	failedProxyIDs := make([]string, 0)
	for _, proxyInfo := range proxiesResp.GetProxies() {
		if proxyInfo == nil || proxyInfo.GetProxyId() == "" {
			continue
		}
		processed++
		closeResp, closeErr := s.CloseAllConnections(ctx, &pb.CloseAllConnectionsRequest{
			NodeId:  req.GetNodeId(),
			ProxyId: proxyInfo.GetProxyId(),
		})
		if closeErr != nil || closeResp == nil || !closeResp.GetSuccess() {
			failedProxyIDs = append(failedProxyIDs, proxyInfo.GetProxyId())
			continue
		}
		totalClosed += closeResp.GetClosedCount()
	}

	if len(failedProxyIDs) > 0 {
		return &pb.CloseAllNodeConnectionsResponse{
			Success:             false,
			Error:               fmt.Sprintf("failed to close connections on %d proxy(s)", len(failedProxyIDs)),
			ProcessedProxyCount: processed,
			ClosedCount:         totalClosed,
			FailedProxyIds:      failedProxyIDs,
		}, nil
	}

	return &pb.CloseAllNodeConnectionsResponse{
		Success:             true,
		ProcessedProxyCount: processed,
		ClosedCount:         totalClosed,
	}, nil
}
