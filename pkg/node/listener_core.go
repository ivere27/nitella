package node

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/process"
	proxy_pb "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/log"
	"github.com/ivere27/nitella/pkg/node/stats"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// ListenerCore is the core proxy implementation that implements ProcessControlServer.
// It can be accessed via FFI (in-process) or IPC (child process) using synurang.
type ListenerCore struct {
	pb.UnimplementedProcessControlServer

	// Configuration
	ID             string
	Name           string
	ListenAddr     string
	DefaultBackend string
	DefaultAction  common.ActionType
	DefaultMock    common.MockPreset
	FallbackAction common.FallbackAction
	FallbackMock   common.MockPreset
	CertPEM        string
	KeyPEM         string
	CaPEM          string
	ClientAuthType proxy_pb.ClientAuthType

	// Internal listener (actual proxy)
	listener *EmbeddedListener
	mu       sync.Mutex
	running  bool

	// Services
	geoIP       *GeoIPService
	stats       *stats.StatsService
	approval    *ApprovalManager
	globalRules *GlobalRulesStore
	nodeID      string
}

// NewListenerCore creates a new ListenerCore.
func NewListenerCore(geoIP *GeoIPService) *ListenerCore {
	return &ListenerCore{
		geoIP: geoIP,
	}
}

// SetStatsService sets the statistics service.
func (c *ListenerCore) SetStatsService(s *stats.StatsService) {
	c.stats = s
}

// SetApprovalManager sets the approval manager.
func (c *ListenerCore) SetApprovalManager(am *ApprovalManager) {
	c.approval = am
}

// SetGlobalRules sets the global rules store.
func (c *ListenerCore) SetGlobalRules(gr *GlobalRulesStore) {
	c.globalRules = gr
}

// SetNodeID sets the node ID for approval requests.
func (c *ListenerCore) SetNodeID(nodeID string) {
	c.nodeID = nodeID
}

// StartListener initializes and starts the listener.
func (c *ListenerCore) StartListener(ctx context.Context, req *pb.StartListenerRequest) (*pb.StartListenerResponse, error) {
	c.mu.Lock()
	defer c.mu.Unlock()

	if c.running {
		return &pb.StartListenerResponse{Success: false, ErrorMessage: "already running"}, nil
	}

	// Store config
	c.ID = req.Id
	if c.ID == "" {
		c.ID = uuid.New().String()
	}
	c.Name = req.Name
	c.ListenAddr = req.ListenAddr
	c.DefaultBackend = req.DefaultBackend
	c.DefaultAction = req.DefaultAction
	if c.DefaultAction == common.ActionType_ACTION_TYPE_UNSPECIFIED {
		c.DefaultAction = common.ActionType_ACTION_TYPE_ALLOW
	}
	if req.DefaultMock != nil {
		c.DefaultMock = req.DefaultMock.Preset
	}
	c.CertPEM = req.CertPem
	c.KeyPEM = req.KeyPem
	c.CaPEM = req.CaPem
	c.ClientAuthType = req.ClientAuthType
	c.FallbackAction = req.FallbackAction
	c.FallbackMock = req.FallbackMock

	// Create embedded listener
	c.listener = NewEmbeddedListener(
		c.ID,
		c.Name,
		c.ListenAddr,
		c.DefaultBackend,
		c.DefaultAction,
		c.DefaultMock,
		c.CertPEM,
		c.KeyPEM,
		c.CaPEM,
		c.ClientAuthType,
		c.geoIP,
	)

	// Wire services
	if c.stats != nil {
		c.listener.SetStatsService(c.stats)
	}
	if c.globalRules != nil {
		c.listener.SetGlobalRules(c.globalRules)
	}
	if c.approval != nil {
		c.listener.SetApprovalManager(c.approval)
	}
	if c.nodeID != "" {
		c.listener.SetNodeID(c.nodeID)
	}
	c.listener.SetFallback(c.FallbackAction, c.FallbackMock)

	// Start
	if err := c.listener.Start(); err != nil {
		return &pb.StartListenerResponse{Success: false, ErrorMessage: err.Error()}, nil
	}

	c.running = true
	c.ListenAddr = c.listener.ListenAddr // Update with actual address (if :0)

	log.Printf("[ListenerCore] Started %s on %s", c.Name, c.ListenAddr)
	return &pb.StartListenerResponse{Success: true}, nil
}

// StopListener stops the listener.
func (c *ListenerCore) StopListener(ctx context.Context, req *pb.StopListenerRequest) (*pb.StopListenerResponse, error) {
	c.mu.Lock()
	defer c.mu.Unlock()

	if c.listener != nil {
		c.listener.Stop()
		c.listener = nil
	}
	c.running = false

	return &pb.StopListenerResponse{Success: true}, nil
}

// HealthCheck returns health status.
func (c *ListenerCore) HealthCheck(ctx context.Context, req *pb.HealthCheckRequest) (*pb.HealthCheckResponse, error) {
	c.mu.Lock()
	listener := c.listener
	c.mu.Unlock()

	if listener == nil {
		return &pb.HealthCheckResponse{Status: "idle", ActiveConnections: 0}, nil
	}

	status := listener.GetStatus()
	return &pb.HealthCheckResponse{
		Status:            "ok",
		ActiveConnections: int32(status.ActiveConnections),
	}, nil
}

// GetMetrics returns proxy metrics.
func (c *ListenerCore) GetMetrics(ctx context.Context, req *pb.GetMetricsRequest) (*pb.GetMetricsResponse, error) {
	c.mu.Lock()
	listener := c.listener
	c.mu.Unlock()

	if listener == nil {
		return &pb.GetMetricsResponse{}, nil
	}

	return &pb.GetMetricsResponse{
		Status: listener.GetStatus(),
	}, nil
}

// AddRule adds a rule to the listener.
func (c *ListenerCore) AddRule(ctx context.Context, req *pb.AddRuleRequest) (*pb.AddRuleResponse, error) {
	c.mu.Lock()
	listener := c.listener
	c.mu.Unlock()

	if listener == nil {
		return &pb.AddRuleResponse{Success: false, ErrorMessage: "listener not running"}, nil
	}

	listener.AddRule(req.Rule)
	return &pb.AddRuleResponse{Success: true}, nil
}

// RemoveRule removes a rule from the listener.
func (c *ListenerCore) RemoveRule(ctx context.Context, req *pb.RemoveRuleRequest) (*pb.RemoveRuleResponse, error) {
	c.mu.Lock()
	listener := c.listener
	c.mu.Unlock()

	if listener == nil {
		return &pb.RemoveRuleResponse{Success: false}, nil
	}

	err := listener.RemoveRule(req.RuleId)
	return &pb.RemoveRuleResponse{Success: err == nil}, nil
}

// ListRules returns all rules for the listener.
func (c *ListenerCore) ListRules(ctx context.Context, req *pb.ListRulesRequest) (*pb.ListRulesResponse, error) {
	c.mu.Lock()
	listener := c.listener
	c.mu.Unlock()

	if listener == nil {
		return &pb.ListRulesResponse{}, nil
	}

	return &pb.ListRulesResponse{Rules: listener.GetRules()}, nil
}

// GetActiveConnections returns active connections.
func (c *ListenerCore) GetActiveConnections(ctx context.Context, req *pb.GetActiveConnectionsRequest) (*pb.GetActiveConnectionsResponse, error) {
	c.mu.Lock()
	listener := c.listener
	c.mu.Unlock()

	if listener == nil {
		return &pb.GetActiveConnectionsResponse{}, nil
	}

	conns := listener.GetActiveConnections()
	var result []*proxy_pb.ActiveConnection
	for _, conn := range conns {
		result = append(result, conn.ToActiveConnection())
	}

	return &pb.GetActiveConnectionsResponse{Connections: result}, nil
}

// CloseConnection closes a specific connection.
func (c *ListenerCore) CloseConnection(ctx context.Context, req *pb.CloseConnectionRequest) (*pb.CloseConnectionResponse, error) {
	c.mu.Lock()
	listener := c.listener
	c.mu.Unlock()

	if listener == nil {
		return &pb.CloseConnectionResponse{Success: false, ErrorMessage: "listener not running"}, nil
	}

	err := listener.CloseConnection(c.ID, req.ConnId)
	if err != nil {
		return &pb.CloseConnectionResponse{Success: false, ErrorMessage: err.Error()}, nil
	}

	return &pb.CloseConnectionResponse{Success: true}, nil
}

// CloseAllConnections closes all connections.
func (c *ListenerCore) CloseAllConnections(ctx context.Context, req *pb.CloseAllConnectionsRequest) (*pb.CloseAllConnectionsResponse, error) {
	c.mu.Lock()
	listener := c.listener
	c.mu.Unlock()

	if listener == nil {
		return &pb.CloseAllConnectionsResponse{Success: false, ErrorMessage: "listener not running"}, nil
	}

	err := listener.CloseAllConnections()
	if err != nil {
		return &pb.CloseAllConnectionsResponse{Success: false, ErrorMessage: err.Error()}, nil
	}

	return &pb.CloseAllConnectionsResponse{Success: true}, nil
}

// StreamEvents streams connection events.
func (c *ListenerCore) StreamEvents(req *pb.StreamEventsRequest, stream pb.ProcessControl_StreamEventsServer) error {
	c.mu.Lock()
	listener := c.listener
	c.mu.Unlock()

	if listener == nil {
		return fmt.Errorf("listener not running")
	}

	eventCh := listener.Subscribe()
	defer listener.Unsubscribe(eventCh)

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

// StreamEventsInternal is used by FFI mode to get a single event (polling style).
// This is required by the generated FfiServer interface.
func (c *ListenerCore) StreamEventsInternal(ctx context.Context, req *pb.StreamEventsRequest) (*pb.Event, error) {
	c.mu.Lock()
	listener := c.listener
	c.mu.Unlock()

	if listener == nil {
		return nil, fmt.Errorf("listener not running")
	}

	eventCh := listener.Subscribe()
	defer listener.Unsubscribe(eventCh)

	select {
	case <-ctx.Done():
		return nil, ctx.Err()
	case event, ok := <-eventCh:
		if !ok {
			return nil, fmt.Errorf("event channel closed")
		}
		return &pb.Event{
			Type: &pb.Event_Connection{
				Connection: event,
			},
		}, nil
	}
}

// GetListenAddr returns the actual listen address (useful when :0 was used).
func (c *ListenerCore) GetListenAddr() string {
	c.mu.Lock()
	defer c.mu.Unlock()
	return c.ListenAddr
}

// IsRunning returns whether the listener is running.
func (c *ListenerCore) IsRunning() bool {
	c.mu.Lock()
	defer c.mu.Unlock()
	return c.running
}

// GetStartTime returns the start time (for uptime calculation).
func (c *ListenerCore) GetStartTime() time.Time {
	c.mu.Lock()
	listener := c.listener
	c.mu.Unlock()

	if listener != nil {
		return listener.startTime
	}
	return time.Time{}
}

// Ensure ListenerCore implements ProcessControlServer
var _ pb.ProcessControlServer = (*ListenerCore)(nil)

// Helper to suppress unused import warning
var _ = timestamppb.Now
