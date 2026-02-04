package node

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/process"
	proxy_pb "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/log"
	"github.com/ivere27/nitella/pkg/node/stats"
	"google.golang.org/grpc"
)

// FfiListener wraps ListenerCore via FFI transport, implementing the Listener interface.
// This provides in-process gRPC communication with zero-copy efficiency.
type FfiListener struct {
	// Core implementation (the actual proxy)
	core *ListenerCore

	// FFI connection (synurang.NewFfiClientConn)
	conn   grpc.ClientConnInterface
	client pb.ProcessControlClient

	// Configuration (cached for Listener interface methods)
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

	// State
	mu        sync.Mutex
	running   bool
	startTime time.Time

	// Subscription management
	subs sync.Map // map[chan *proxy_pb.ConnectionEvent]context.CancelFunc
}

// NewFfiListener creates a new FFI-based listener.
// The ffiConnFactory creates the FFI connection (e.g., synurang.NewFfiClientConn(core)).
func NewFfiListener(
	id, name, listenAddr, defaultBackend string,
	defaultAction common.ActionType,
	defaultMock common.MockPreset,
	certPEM, keyPEM, caPEM string,
	clientAuth proxy_pb.ClientAuthType,
	geoIP *GeoIPService,
) *FfiListener {
	// Create core
	core := NewListenerCore(geoIP)

	// Create FFI connection via synurang
	// Note: This requires the generated FFI binding from process.proto
	ffiConn := pb.NewFfiClientConn(core)

	return &FfiListener{
		core:           core,
		conn:           ffiConn,
		client:         pb.NewProcessControlClient(ffiConn),
		ID:             id,
		Name:           name,
		ListenAddr:     listenAddr,
		DefaultBackend: defaultBackend,
		DefaultAction:  defaultAction,
		DefaultMock:    defaultMock,
		CertPEM:        certPEM,
		KeyPEM:         keyPEM,
		CaPEM:          caPEM,
		ClientAuthType: clientAuth,
	}
}

// SetStatsService sets the statistics service.
func (f *FfiListener) SetStatsService(s *stats.StatsService) {
	f.core.SetStatsService(s)
}

// SetApprovalManager sets the approval manager.
func (f *FfiListener) SetApprovalManager(am *ApprovalManager) {
	f.core.SetApprovalManager(am)
}

// SetGlobalRules sets the global rules store.
func (f *FfiListener) SetGlobalRules(gr *GlobalRulesStore) {
	f.core.SetGlobalRules(gr)
}

// SetNodeID sets the node ID for approval requests.
func (f *FfiListener) SetNodeID(nodeID string) {
	f.core.SetNodeID(nodeID)
}

// SetFallback sets fallback action.
func (f *FfiListener) SetFallback(action common.FallbackAction, mock common.MockPreset) {
	f.FallbackAction = action
	f.FallbackMock = mock
}

// Start starts the listener via FFI.
func (f *FfiListener) Start() error {
	f.mu.Lock()
	defer f.mu.Unlock()

	if f.running {
		return fmt.Errorf("already running")
	}

	resp, err := f.client.StartListener(context.Background(), &pb.StartListenerRequest{
		Id:             f.ID,
		Name:           f.Name,
		ListenAddr:     f.ListenAddr,
		DefaultBackend: f.DefaultBackend,
		DefaultAction:  f.DefaultAction,
		DefaultMock:    &proxy_pb.MockConfig{Preset: f.DefaultMock},
		CertPem:        f.CertPEM,
		KeyPem:         f.KeyPEM,
		CaPem:          f.CaPEM,
		ClientAuthType: f.ClientAuthType,
		FallbackAction: f.FallbackAction,
		FallbackMock:   f.FallbackMock,
	})
	if err != nil {
		return fmt.Errorf("failed to start listener via FFI: %w", err)
	}
	if !resp.Success {
		return fmt.Errorf("failed to start listener: %s", resp.ErrorMessage)
	}

	f.running = true
	f.startTime = time.Now()
	f.ListenAddr = f.core.GetListenAddr() // Update with actual address

	log.Printf("[FfiListener] Started %s on %s", f.Name, f.ListenAddr)
	return nil
}

// Stop stops the listener.
func (f *FfiListener) Stop() error {
	// Cancel all subscriptions
	f.subs.Range(func(key, value any) bool {
		if cancel, ok := value.(context.CancelFunc); ok {
			cancel()
		}
		f.subs.Delete(key)
		return true
	})

	f.mu.Lock()
	defer f.mu.Unlock()

	if !f.running {
		return nil
	}

	_, err := f.client.StopListener(context.Background(), &pb.StopListenerRequest{})
	if err != nil {
		return err
	}

	f.running = false
	return nil
}

// AddRule adds a rule via FFI.
func (f *FfiListener) AddRule(rule *proxy_pb.Rule) {
	_, err := f.client.AddRule(context.Background(), &pb.AddRuleRequest{Rule: rule})
	if err != nil {
		log.Printf("[FfiListener] Failed to add rule: %v", err)
	}
}

// RemoveRule removes a rule via FFI.
func (f *FfiListener) RemoveRule(ruleID string) error {
	resp, err := f.client.RemoveRule(context.Background(), &pb.RemoveRuleRequest{RuleId: ruleID})
	if err != nil {
		return err
	}
	if !resp.Success {
		return fmt.Errorf("rule not found")
	}
	return nil
}

// GetRules returns rules via FFI.
func (f *FfiListener) GetRules() []*proxy_pb.Rule {
	resp, err := f.client.ListRules(context.Background(), &pb.ListRulesRequest{})
	if err != nil {
		log.Printf("[FfiListener] Failed to list rules: %v", err)
		return nil
	}
	return resp.Rules
}

// GetStatus returns the proxy status.
func (f *FfiListener) GetStatus() *proxy_pb.ProxyStatus {
	f.mu.Lock()
	running := f.running
	startTime := f.startTime
	f.mu.Unlock()

	resp, err := f.client.GetMetrics(context.Background(), &pb.GetMetricsRequest{})
	if err != nil || resp.Status == nil {
		return &proxy_pb.ProxyStatus{
			ProxyId:        f.ID,
			Running:        running,
			ListenAddr:     f.ListenAddr,
			DefaultBackend: f.DefaultBackend,
			DefaultAction:  f.DefaultAction,
			DefaultMock:    f.DefaultMock,
			UptimeSeconds:  int64(time.Since(startTime).Seconds()),
		}
	}

	status := resp.Status
	status.UptimeSeconds = int64(time.Since(startTime).Seconds())
	return status
}

// Subscribe returns a channel for connection events.
func (f *FfiListener) Subscribe() chan *proxy_pb.ConnectionEvent {
	ch := make(chan *proxy_pb.ConnectionEvent, 100)
	ctx, cancel := context.WithCancel(context.Background())

	f.subs.Store(ch, cancel)

	go func() {
		defer func() {
			f.subs.Delete(ch)
			close(ch)
		}()

		stream, err := f.client.StreamEvents(ctx, &pb.StreamEventsRequest{})
		if err != nil {
			log.Printf("[FfiListener] Subscribe failed: %v", err)
			return
		}

		for {
			select {
			case <-ctx.Done():
				return
			default:
				event, err := stream.Recv()
				if err != nil {
					return
				}

				switch e := event.Type.(type) {
				case *pb.Event_Connection:
					select {
					case ch <- e.Connection:
					case <-ctx.Done():
						return
					}
				}
			}
		}
	}()

	return ch
}

// Unsubscribe stops receiving events on the channel.
func (f *FfiListener) Unsubscribe(ch chan *proxy_pb.ConnectionEvent) {
	if value, ok := f.subs.LoadAndDelete(ch); ok {
		if cancel, ok := value.(context.CancelFunc); ok {
			cancel()
		}
	}
}

// GetConnectionBytes returns byte counts for a connection.
func (f *FfiListener) GetConnectionBytes(connID string) (in, out int64, ok bool) {
	// Not tracked at this level
	return 0, 0, false
}

// GetActiveConnections returns active connections.
func (f *FfiListener) GetActiveConnections() []*ConnectionMetadata {
	resp, err := f.client.GetActiveConnections(context.Background(), &pb.GetActiveConnectionsRequest{})
	if err != nil {
		return nil
	}

	var result []*ConnectionMetadata
	for _, conn := range resp.Connections {
		result = append(result, ConnectionMetadataFromActive(conn))
	}
	return result
}

// CloseConnection closes a specific connection.
func (f *FfiListener) CloseConnection(proxyID, connID string) error {
	resp, err := f.client.CloseConnection(context.Background(), &pb.CloseConnectionRequest{ConnId: connID})
	if err != nil {
		return err
	}
	if !resp.Success {
		return fmt.Errorf("%s", resp.ErrorMessage)
	}
	return nil
}

// CloseAllConnections closes all connections.
func (f *FfiListener) CloseAllConnections() error {
	resp, err := f.client.CloseAllConnections(context.Background(), &pb.CloseAllConnectionsRequest{})
	if err != nil {
		return err
	}
	if !resp.Success {
		return fmt.Errorf("%s", resp.ErrorMessage)
	}
	return nil
}

// Ensure FfiListener implements Listener interface
var _ Listener = (*FfiListener)(nil)
