package server

import (
	"context"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/process"
	proxy_pb "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/node"
	"google.golang.org/grpc"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// RegisterProcessControl registers the ProcessControl service with a gRPC server.
func RegisterProcessControl(s *grpc.Server, srv *ProcessServer) {
	pb.RegisterProcessControlServer(s, srv)
}

// ProcessServer handles IPC from parent process to child process.
// Each child process runs a single listener and receives commands via Unix socket.
type ProcessServer struct {
	pb.UnimplementedProcessControlServer
	pm             *node.ProxyManager
	currentProxyID string
}

// NewProcessServer creates a new ProcessServer.
func NewProcessServer(pm *node.ProxyManager) *ProcessServer {
	return &ProcessServer{pm: pm}
}

// StartListener initializes the listener in this child process.
func (s *ProcessServer) StartListener(ctx context.Context, req *pb.StartListenerRequest) (*pb.StartListenerResponse, error) {
	action := common.ActionType_ACTION_TYPE_ALLOW
	if req.DefaultAction != common.ActionType_ACTION_TYPE_UNSPECIFIED {
		action = req.DefaultAction
	}

	mockPreset := common.MockPreset_MOCK_PRESET_UNSPECIFIED
	if req.DefaultMock != nil {
		mockPreset = req.DefaultMock.Preset
	}

	proxyReq := &proxy_pb.CreateProxyRequest{
		Name:           req.Name,
		ListenAddr:     req.ListenAddr,
		DefaultBackend: req.DefaultBackend,
		DefaultAction:  action,
		DefaultMock:    mockPreset,
		CertPem:        req.CertPem,
		KeyPem:         req.KeyPem,
		CaPem:          req.CaPem,
		ClientAuthType: req.ClientAuthType,
		FallbackAction: req.FallbackAction,
		FallbackMock:   req.FallbackMock,
	}

	resp, err := s.pm.CreateProxyWithID(req.Id, proxyReq)
	if err != nil {
		return &pb.StartListenerResponse{Success: false, ErrorMessage: err.Error()}, nil
	}
	if !resp.Success {
		return &pb.StartListenerResponse{Success: false, ErrorMessage: resp.ErrorMessage}, nil
	}

	s.currentProxyID = resp.ProxyId
	return &pb.StartListenerResponse{Success: true}, nil
}

// StopListener stops the listener in this child process.
func (s *ProcessServer) StopListener(ctx context.Context, req *pb.StopListenerRequest) (*pb.StopListenerResponse, error) {
	if s.currentProxyID != "" {
		s.pm.DisableProxy(s.currentProxyID)
		s.currentProxyID = ""
	}
	return &pb.StopListenerResponse{Success: true}, nil
}

// HealthCheck returns health status.
func (s *ProcessServer) HealthCheck(ctx context.Context, req *pb.HealthCheckRequest) (*pb.HealthCheckResponse, error) {
	connCount := int32(0)
	status := "ok"

	proxies := s.pm.GetAllStatuses()
	if len(proxies) == 0 {
		status = "idle"
	}

	for _, p := range proxies {
		connCount += int32(p.ActiveConnections)
	}

	return &pb.HealthCheckResponse{
		Status:            status,
		ActiveConnections: connCount,
	}, nil
}

// GetMetrics returns proxy metrics.
func (s *ProcessServer) GetMetrics(ctx context.Context, req *pb.GetMetricsRequest) (*pb.GetMetricsResponse, error) {
	proxies := s.pm.GetAllStatuses()
	if len(proxies) == 0 {
		return &pb.GetMetricsResponse{}, nil
	}
	// Return the first (single listener per child)
	return &pb.GetMetricsResponse{
		Status: proxies[0],
	}, nil
}

// AddRule adds a rule to the listener.
func (s *ProcessServer) AddRule(ctx context.Context, req *pb.AddRuleRequest) (*pb.AddRuleResponse, error) {
	if s.currentProxyID == "" {
		return &pb.AddRuleResponse{Success: false, ErrorMessage: "Proxy not started"}, nil
	}

	_, err := s.pm.AddRule(&proxy_pb.AddRuleRequest{
		ProxyId: s.currentProxyID,
		Rule:    req.Rule,
	})
	if err != nil {
		return &pb.AddRuleResponse{Success: false, ErrorMessage: err.Error()}, nil
	}

	return &pb.AddRuleResponse{Success: true}, nil
}

// RemoveRule removes a rule from the listener.
func (s *ProcessServer) RemoveRule(ctx context.Context, req *pb.RemoveRuleRequest) (*pb.RemoveRuleResponse, error) {
	if s.currentProxyID == "" {
		return &pb.RemoveRuleResponse{Success: false}, nil
	}

	err := s.pm.RemoveRule(&proxy_pb.RemoveRuleRequest{
		ProxyId: s.currentProxyID,
		RuleId:  req.RuleId,
	})
	if err != nil {
		return &pb.RemoveRuleResponse{Success: false}, nil
	}

	return &pb.RemoveRuleResponse{Success: true}, nil
}

// ListRules returns all rules for the listener.
func (s *ProcessServer) ListRules(ctx context.Context, req *pb.ListRulesRequest) (*pb.ListRulesResponse, error) {
	if s.currentProxyID == "" {
		return &pb.ListRulesResponse{}, nil
	}

	rules, err := s.pm.GetRules(s.currentProxyID)
	if err != nil {
		return &pb.ListRulesResponse{}, nil
	}

	return &pb.ListRulesResponse{Rules: rules}, nil
}

// GetActiveConnections returns active connections.
func (s *ProcessServer) GetActiveConnections(ctx context.Context, req *pb.GetActiveConnectionsRequest) (*pb.GetActiveConnectionsResponse, error) {
	if s.currentProxyID == "" {
		return &pb.GetActiveConnectionsResponse{}, nil
	}

	conns := s.pm.GetActiveConnections(s.currentProxyID)
	if conns == nil {
		return &pb.GetActiveConnectionsResponse{}, nil
	}

	var result []*proxy_pb.ActiveConnection
	for _, c := range conns {
		var bytesIn, bytesOut int64
		if c.BytesIn != nil {
			bytesIn = *c.BytesIn
		}
		if c.BytesOut != nil {
			bytesOut = *c.BytesOut
		}
		result = append(result, &proxy_pb.ActiveConnection{
			Id:         c.ID,
			SourceIp:   c.SourceIP,
			SourcePort: int32(c.SourcePort),
			DestAddr:   c.DestAddr,
			StartTime:  timestamppb.New(c.StartTime),
			BytesIn:    bytesIn,
			BytesOut:   bytesOut,
		})
	}

	return &pb.GetActiveConnectionsResponse{Connections: result}, nil
}

// CloseConnection closes a specific connection.
func (s *ProcessServer) CloseConnection(ctx context.Context, req *pb.CloseConnectionRequest) (*pb.CloseConnectionResponse, error) {
	if s.currentProxyID == "" {
		return &pb.CloseConnectionResponse{Success: false, ErrorMessage: "Proxy not started"}, nil
	}

	err := s.pm.CloseConnection(s.currentProxyID, req.ConnId)
	if err != nil {
		return &pb.CloseConnectionResponse{Success: false, ErrorMessage: err.Error()}, nil
	}

	return &pb.CloseConnectionResponse{Success: true}, nil
}

// CloseAllConnections closes all connections in the child process.
func (s *ProcessServer) CloseAllConnections(ctx context.Context, req *pb.CloseAllConnectionsRequest) (*pb.CloseAllConnectionsResponse, error) {
	if s.currentProxyID == "" {
		return &pb.CloseAllConnectionsResponse{Success: false, ErrorMessage: "Proxy not started"}, nil
	}

	err := s.pm.CloseAllConnections(s.currentProxyID)
	if err != nil {
		return &pb.CloseAllConnectionsResponse{Success: false, ErrorMessage: err.Error()}, nil
	}

	return &pb.CloseAllConnectionsResponse{Success: true}, nil
}

// StreamEvents streams connection events to the parent process.
func (s *ProcessServer) StreamEvents(req *pb.StreamEventsRequest, stream pb.ProcessControl_StreamEventsServer) error {
	eventCh := s.pm.SubscribeGlobal()
	defer s.pm.UnsubscribeGlobal(eventCh)

	for {
		select {
		case <-stream.Context().Done():
			return nil
		case event, ok := <-eventCh:
			if !ok {
				return nil
			}
			err := stream.Send(&pb.Event{
				Type: &pb.Event_Connection{
					Connection: event,
				},
			})
			if err != nil {
				return err
			}
		}
	}
}

// GetProxyID returns the current proxy ID (for testing).
func (s *ProcessServer) GetProxyID() string {
	return s.currentProxyID
}
