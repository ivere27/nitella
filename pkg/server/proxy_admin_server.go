package server

import (
	"context"
	"sync"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/log"
	"github.com/ivere27/nitella/pkg/node"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/peer"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// Ensure common import is used
var _ = common.ActionType_ACTION_TYPE_ALLOW

// ProxyAdminServer implements ProxyControlServiceServer for admin API.
type ProxyAdminServer struct {
	pb.UnimplementedProxyControlServiceServer
	pm *node.ProxyManager
}

// NewProxyAdminServer creates a new admin server.
func NewProxyAdminServer(pm *node.ProxyManager) *ProxyAdminServer {
	return &ProxyAdminServer{pm: pm}
}

// RegisterProxyAdmin registers the ProxyControlService with a gRPC server.
func RegisterProxyAdmin(s *grpc.Server, srv *ProxyAdminServer) {
	pb.RegisterProxyControlServiceServer(s, srv)
}

// ============================================================================
// Lifecycle Management
// ============================================================================

func (s *ProxyAdminServer) CreateProxy(ctx context.Context, req *pb.CreateProxyRequest) (*pb.CreateProxyResponse, error) {
	return s.pm.CreateProxy(req)
}

func (s *ProxyAdminServer) DisableProxy(ctx context.Context, req *pb.DisableProxyRequest) (*pb.DisableProxyResponse, error) {
	return s.pm.DisableProxy(req.ProxyId)
}

func (s *ProxyAdminServer) EnableProxy(ctx context.Context, req *pb.EnableProxyRequest) (*pb.EnableProxyResponse, error) {
	return s.pm.EnableProxy(req.ProxyId)
}

func (s *ProxyAdminServer) DeleteProxy(ctx context.Context, req *pb.DeleteProxyRequest) (*pb.DeleteProxyResponse, error) {
	_, err := s.pm.DisableProxy(req.ProxyId)
	if err != nil {
		return &pb.DeleteProxyResponse{Success: false, ErrorMessage: err.Error()}, nil
	}
	return &pb.DeleteProxyResponse{Success: true}, nil
}

func (s *ProxyAdminServer) UpdateProxy(ctx context.Context, req *pb.UpdateProxyRequest) (*pb.UpdateProxyResponse, error) {
	return s.pm.UpdateProxy(req)
}

func (s *ProxyAdminServer) RestartListeners(ctx context.Context, req *emptypb.Empty) (*pb.RestartListenersResponse, error) {
	return s.pm.RestartListeners()
}

func (s *ProxyAdminServer) GetStatus(ctx context.Context, req *pb.GetStatusRequest) (*pb.ProxyStatus, error) {
	return s.pm.GetStatus(req.ProxyId)
}

func (s *ProxyAdminServer) ReloadRules(ctx context.Context, req *pb.ReloadRulesRequest) (*pb.ReloadRulesResponse, error) {
	// Reload rules for all proxies
	statuses := s.pm.GetAllStatuses()
	totalLoaded := int32(0)
	for _, st := range statuses {
		resp, err := s.pm.ReloadRules(st.ProxyId, req.Rules)
		if err == nil && resp.Success {
			totalLoaded += resp.RulesLoaded
		}
	}
	return &pb.ReloadRulesResponse{
		Success:     true,
		RulesLoaded: totalLoaded,
	}, nil
}

// ============================================================================
// Rule Management
// ============================================================================

func (s *ProxyAdminServer) AddRule(ctx context.Context, req *pb.AddRuleRequest) (*pb.Rule, error) {
	return s.pm.AddRule(req)
}

func (s *ProxyAdminServer) RemoveRule(ctx context.Context, req *pb.RemoveRuleRequest) (*emptypb.Empty, error) {
	err := s.pm.RemoveRule(req)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to remove rule: %v", err)
	}
	return &emptypb.Empty{}, nil
}

func (s *ProxyAdminServer) ListRules(ctx context.Context, req *pb.ListRulesRequest) (*pb.ListRulesResponse, error) {
	rules, err := s.pm.GetRules(req.ProxyId)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to get rules: %v", err)
	}
	return &pb.ListRulesResponse{Rules: rules}, nil
}

func (s *ProxyAdminServer) ListProxies(ctx context.Context, req *pb.ListProxiesRequest) (*pb.ListProxiesResponse, error) {
	statuses := s.pm.GetAllStatuses()
	return &pb.ListProxiesResponse{Proxies: statuses}, nil
}

// ============================================================================
// Quick Actions
// ============================================================================

func (s *ProxyAdminServer) BlockIP(ctx context.Context, req *pb.BlockIPRequest) (*emptypb.Empty, error) {
	// Add block rule to all proxies
	statuses := s.pm.GetAllStatuses()
	for _, st := range statuses {
		rule := &pb.Rule{
			Name:     "Quick Block: " + req.Ip,
			Priority: 1000, // High priority
			Enabled:  true,
			Action:   common.ActionType_ACTION_TYPE_BLOCK,
			Conditions: []*pb.Condition{
				{
					Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
					Op:    common.Operator_OPERATOR_EQ,
					Value: req.Ip,
				},
			},
		}
		s.pm.AddRule(&pb.AddRuleRequest{
			ProxyId: st.ProxyId,
			Rule:    rule,
		})
	}
	return &emptypb.Empty{}, nil
}

func (s *ProxyAdminServer) AllowIP(ctx context.Context, req *pb.AllowIPRequest) (*emptypb.Empty, error) {
	// Add allow rule to all proxies
	statuses := s.pm.GetAllStatuses()
	for _, st := range statuses {
		rule := &pb.Rule{
			Name:     "Quick Allow: " + req.Ip,
			Priority: 1000,
			Enabled:  true,
			Action:   common.ActionType_ACTION_TYPE_ALLOW,
			Conditions: []*pb.Condition{
				{
					Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
					Op:    common.Operator_OPERATOR_EQ,
					Value: req.Ip,
				},
			},
		}
		s.pm.AddRule(&pb.AddRuleRequest{
			ProxyId: st.ProxyId,
			Rule:    rule,
		})
	}
	return &emptypb.Empty{}, nil
}

// ============================================================================
// Observability
// ============================================================================

func (s *ProxyAdminServer) StreamConnections(req *pb.StreamConnectionsRequest, stream pb.ProxyControlService_StreamConnectionsServer) error {
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
			if err := stream.Send(event); err != nil {
				return err
			}
		}
	}
}

func (s *ProxyAdminServer) StreamMetrics(req *pb.StreamMetricsRequest, stream pb.ProxyControlService_StreamMetricsServer) error {
	interval := req.IntervalSeconds
	if interval <= 0 {
		interval = 1 // Default 1 second
	}

	ticker := time.NewTicker(time.Duration(interval) * time.Second)
	defer ticker.Stop()

	// Track previous values for rate calculation
	var prevBytesIn, prevBytesOut int64
	var prevTimestamp int64

	for {
		select {
		case <-stream.Context().Done():
			return nil
		case <-ticker.C:
			statuses := s.pm.GetAllStatuses()

			var totalActive, totalConns, totalBytesIn, totalBytesOut int64
			for _, st := range statuses {
				totalActive += st.ActiveConnections
				totalConns += st.TotalConnections
				totalBytesIn += st.BytesIn
				totalBytesOut += st.BytesOut
			}

			now := time.Now().Unix()

			// Calculate rates
			var bytesInRate, bytesOutRate int64
			if prevTimestamp > 0 {
				elapsed := now - prevTimestamp
				if elapsed > 0 {
					bytesInRate = (totalBytesIn - prevBytesIn) / elapsed
					bytesOutRate = (totalBytesOut - prevBytesOut) / elapsed
				}
			}

			sample := &pb.MetricsSample{
				Timestamp:    now,
				ActiveConns:  totalActive,
				TotalConns:   totalConns,
				BytesInRate:  bytesInRate,
				BytesOutRate: bytesOutRate,
			}

			if err := stream.Send(sample); err != nil {
				return err
			}

			prevBytesIn = totalBytesIn
			prevBytesOut = totalBytesOut
			prevTimestamp = now
		}
	}
}

// ============================================================================
// Connection Management
// ============================================================================

func (s *ProxyAdminServer) GetActiveConnections(ctx context.Context, req *pb.GetActiveConnectionsRequest) (*pb.GetActiveConnectionsResponse, error) {
	conns := s.pm.GetActiveConnections(req.ProxyId)
	if conns == nil {
		return &pb.GetActiveConnectionsResponse{}, nil
	}

	var result []*pb.ActiveConnection
	for _, c := range conns {
		var bytesIn, bytesOut int64
		if c.BytesIn != nil {
			bytesIn = *c.BytesIn
		}
		if c.BytesOut != nil {
			bytesOut = *c.BytesOut
		}
		result = append(result, &pb.ActiveConnection{
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

func (s *ProxyAdminServer) CloseConnection(ctx context.Context, req *pb.CloseConnectionRequest) (*pb.CloseConnectionResponse, error) {
	err := s.pm.CloseConnection(req.ProxyId, req.ConnId)
	if err != nil {
		return &pb.CloseConnectionResponse{Success: false, ErrorMessage: err.Error()}, nil
	}
	return &pb.CloseConnectionResponse{Success: true}, nil
}

func (s *ProxyAdminServer) CloseAllConnections(ctx context.Context, req *pb.CloseAllConnectionsRequest) (*pb.CloseAllConnectionsResponse, error) {
	err := s.pm.CloseAllConnections(req.ProxyId)
	if err != nil {
		return &pb.CloseAllConnectionsResponse{Success: false, ErrorMessage: err.Error()}, nil
	}
	return &pb.CloseAllConnectionsResponse{Success: true}, nil
}

// ============================================================================
// Configuration
// ============================================================================

func (s *ProxyAdminServer) ConfigureGeoIP(ctx context.Context, req *pb.ConfigureGeoIPRequest) (*pb.ConfigureGeoIPResponse, error) {
	return s.pm.ConfigureGeoIP(req)
}

func (s *ProxyAdminServer) LookupIP(ctx context.Context, req *pb.LookupIPRequest) (*pb.LookupIPResponse, error) {
	return s.pm.LookupIP(req)
}

func (s *ProxyAdminServer) GetGeoIPStatus(ctx context.Context, req *pb.GetGeoIPStatusRequest) (*pb.GetGeoIPStatusResponse, error) {
	return s.pm.GetGeoIPStatus(req)
}

// ============================================================================
// Authentication Interceptor
// ============================================================================

// ProxyAdminAuthInterceptor creates a token authentication interceptor.
func ProxyAdminAuthInterceptor(token string) grpc.UnaryServerInterceptor {
	var loggedOnce sync.Once

	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		// Get client address
		clientAddr := "unknown"
		if p, ok := peer.FromContext(ctx); ok && p.Addr != nil {
			clientAddr = p.Addr.String()
		}

		md, ok := metadata.FromIncomingContext(ctx)
		if !ok {
			log.Printf("[Admin] Auth failed from %s: no metadata", clientAddr)
			return nil, status.Error(codes.Unauthenticated, "no metadata")
		}

		tokens := md.Get("authorization")
		if len(tokens) == 0 {
			log.Printf("[Admin] Auth failed from %s: missing authorization", clientAddr)
			return nil, status.Error(codes.Unauthenticated, "missing authorization")
		}

		// Support both "Bearer <token>" and plain token
		authToken := tokens[0]
		if len(authToken) > 7 && authToken[:7] == "Bearer " {
			authToken = authToken[7:]
		}

		if authToken != token {
			log.Printf("[Admin] Auth failed from %s: invalid token", clientAddr)
			return nil, status.Error(codes.Unauthenticated, "invalid token")
		}

		// Log first successful auth only
		loggedOnce.Do(func() {
			log.Printf("[Admin] First client authenticated from %s", clientAddr)
		})

		return handler(ctx, req)
	}
}

// ProxyAdminStreamAuthInterceptor creates a stream authentication interceptor.
func ProxyAdminStreamAuthInterceptor(token string) grpc.StreamServerInterceptor {
	return func(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		md, ok := metadata.FromIncomingContext(ss.Context())
		if !ok {
			return status.Error(codes.Unauthenticated, "no metadata")
		}

		tokens := md.Get("authorization")
		if len(tokens) == 0 {
			return status.Error(codes.Unauthenticated, "missing authorization")
		}

		authToken := tokens[0]
		if len(authToken) > 7 && authToken[:7] == "Bearer " {
			authToken = authToken[7:]
		}

		if authToken != token {
			return status.Error(codes.Unauthenticated, "invalid token")
		}

		return handler(srv, ss)
	}
}
