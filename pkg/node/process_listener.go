package node

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	process_pb "github.com/ivere27/nitella/pkg/api/process"
	pb "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/log"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// ProcessListener manages a listener running in a separate child process.
// This provides process isolation - if a listener crashes, only that listener
// is affected, not the entire proxy manager.
type ProcessListener struct {
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
	ClientAuthType pb.ClientAuthType

	cmd     *exec.Cmd
	quit    chan struct{}
	wg      sync.WaitGroup
	mu      sync.Mutex
	running bool

	// IPC via Unix socket
	conn   *grpc.ClientConn
	client process_pb.ProcessControlClient
	socket string

	// Subscription management (sync.Map eliminates lock ordering concerns)
	subs sync.Map // map[chan *pb.ConnectionEvent]context.CancelFunc

	// Start time for uptime calculation
	startTime time.Time
}

// NewProcessListener creates a new process-isolated listener.
func NewProcessListener(id, name, listenAddr, defaultBackend string, defaultAction common.ActionType, defaultMock common.MockPreset, certPEM, keyPEM, caPEM string, clientAuth pb.ClientAuthType) *ProcessListener {
	return &ProcessListener{
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
		quit:           make(chan struct{}),
		// subs is sync.Map, zero value is ready to use
	}
}

// Start spawns the child process and establishes IPC connection.
func (p *ProcessListener) Start() error {
	p.mu.Lock()
	defer p.mu.Unlock()

	if p.running {
		return fmt.Errorf("already running")
	}

	// Get executable path (no env override - security risk)
	exe, err := os.Executable()
	if err != nil {
		return fmt.Errorf("failed to get executable path: %w", err)
	}

	// Generate unpredictable socket path (random suffix prevents symlink attacks)
	randomBytes := make([]byte, 16)
	if _, err := rand.Read(randomBytes); err != nil {
		return fmt.Errorf("failed to generate random socket name: %w", err)
	}
	p.socket = filepath.Join(os.TempDir(), fmt.Sprintf("nitella_%s.sock", hex.EncodeToString(randomBytes)))
	// Cleanup old socket (unlikely to exist with random name, but just in case)
	os.Remove(p.socket)

	// Build child arguments
	args := []string{
		"child",
		"--socket", p.socket,
		"--listen", p.ListenAddr,
		"--id", p.ID,
		"--name", p.Name,
	}
	if p.DefaultBackend != "" {
		args = append(args, "--backend", p.DefaultBackend)
	}

	cmd := exec.Command(exe, args...)

	// Redirect stdout/stderr to parent
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Start(); err != nil {
		return fmt.Errorf("failed to start child process: %w", err)
	}

	p.cmd = cmd
	p.running = true
	p.startTime = time.Now()

	// Monitor process exit
	go func() {
		err := cmd.Wait()
		log.Printf("[ProcessListener] %s exited: %v", p.ID, err)
		p.mu.Lock()
		p.running = false
		if p.conn != nil {
			p.conn.Close()
		}
		p.conn = nil
		p.client = nil
		p.mu.Unlock()
		// Cleanup socket
		os.Remove(p.socket)
	}()

	// Wait for socket to appear (max 5s)
	socketReady := false
	for i := 0; i < 50; i++ {
		if _, err := os.Stat(p.socket); err == nil {
			socketReady = true
			break
		}
		time.Sleep(100 * time.Millisecond)
	}
	if !socketReady {
		p.Stop()
		return fmt.Errorf("child process socket did not appear within timeout")
	}

	// Secure the socket (owner-only access)
	if err := os.Chmod(p.socket, 0600); err != nil {
		log.Printf("[ProcessListener] Failed to chmod socket: %v", err)
	}

	// Connect gRPC
	conn, err := grpc.NewClient("unix:"+p.socket, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		p.Stop()
		return fmt.Errorf("failed to connect to child process: %w", err)
	}

	p.conn = conn
	p.client = process_pb.NewProcessControlClient(conn)

	// Initialize the listener in the child process
	_, err = p.client.StartListener(context.Background(), &process_pb.StartListenerRequest{
		Id:             p.ID,
		Name:           p.Name,
		ListenAddr:     p.ListenAddr,
		DefaultBackend: p.DefaultBackend,
		DefaultAction:  p.DefaultAction,
		DefaultMock:    &pb.MockConfig{Preset: p.DefaultMock},
		CertPem:        p.CertPEM,
		KeyPem:         p.KeyPEM,
		CaPem:          p.CaPEM,
		ClientAuthType: p.ClientAuthType,
		FallbackAction: p.FallbackAction,
		FallbackMock:   p.FallbackMock,
	})
	if err != nil {
		p.Stop()
		return fmt.Errorf("failed to start listener in child: %w", err)
	}

	return nil
}

// Stop terminates the child process.
func (p *ProcessListener) Stop() error {
	// Cancel all subscriptions
	p.subs.Range(func(key, value any) bool {
		if cancel, ok := value.(context.CancelFunc); ok {
			cancel()
		}
		p.subs.Delete(key)
		return true
	})

	p.mu.Lock()
	defer p.mu.Unlock()

	if p.conn != nil {
		p.conn.Close()
		p.conn = nil
	}

	if !p.running || p.cmd == nil {
		return nil
	}

	if err := p.cmd.Process.Kill(); err != nil {
		return err
	}

	p.running = false
	return nil
}

// AddRule adds a rule via IPC.
func (p *ProcessListener) AddRule(rule *pb.Rule) {
	p.mu.Lock()
	client := p.client
	p.mu.Unlock()

	if client == nil {
		log.Printf("[ProcessListener] Client not ready for AddRule")
		return
	}

	_, err := client.AddRule(context.Background(), &process_pb.AddRuleRequest{
		Rule: rule,
	})
	if err != nil {
		log.Printf("[ProcessListener] Failed to add rule: %v", err)
	}
}

// RemoveRule removes a rule via IPC.
func (p *ProcessListener) RemoveRule(ruleID string) error {
	p.mu.Lock()
	client := p.client
	p.mu.Unlock()

	if client == nil {
		return fmt.Errorf("client not ready")
	}

	_, err := client.RemoveRule(context.Background(), &process_pb.RemoveRuleRequest{
		RuleId: ruleID,
	})
	return err
}

// GetRules returns rules from the child process.
func (p *ProcessListener) GetRules() []*pb.Rule {
	p.mu.Lock()
	client := p.client
	p.mu.Unlock()

	if client == nil {
		return []*pb.Rule{}
	}

	resp, err := client.ListRules(context.Background(), &process_pb.ListRulesRequest{})
	if err != nil {
		log.Printf("[ProcessListener] Failed to list rules: %v", err)
		return []*pb.Rule{}
	}

	return resp.Rules
}

// GetPID returns the child process PID, or 0 if not running.
func (p *ProcessListener) GetPID() int {
	p.mu.Lock()
	defer p.mu.Unlock()
	if p.cmd != nil && p.cmd.Process != nil {
		return p.cmd.Process.Pid
	}
	return 0
}

// GetStatus returns the proxy status.
func (p *ProcessListener) GetStatus() *pb.ProxyStatus {
	p.mu.Lock()
	client := p.client
	running := p.running
	p.mu.Unlock()

	rss := int64(0)
	if p.cmd != nil && p.cmd.Process != nil {
		rss = getRSS(p.cmd.Process.Pid)
	}

	status := &pb.ProxyStatus{
		ProxyId:        p.ID,
		Running:        running,
		MemoryRss:      rss,
		ListenAddr:     p.ListenAddr,
		DefaultBackend: p.DefaultBackend,
		DefaultAction:  p.DefaultAction,
		DefaultMock:    p.DefaultMock,
		UptimeSeconds:  int64(time.Since(p.startTime).Seconds()),
	}

	if client != nil {
		resp, err := client.GetMetrics(context.Background(), &process_pb.GetMetricsRequest{})
		if err == nil && resp.Status != nil {
			status.ActiveConnections = resp.Status.ActiveConnections
			status.TotalConnections = resp.Status.TotalConnections
			status.BytesIn = resp.Status.BytesIn
			status.BytesOut = resp.Status.BytesOut
			// Use actual listen address from child process
			if resp.Status.ListenAddr != "" {
				status.ListenAddr = resp.Status.ListenAddr
			}
		}
	}

	return status
}

// Subscribe returns a channel for connection events.
func (p *ProcessListener) Subscribe() chan *pb.ConnectionEvent {
	ch := make(chan *pb.ConnectionEvent, 100)
	ctx, cancel := context.WithCancel(context.Background())

	p.subs.Store(ch, cancel)

	go func() {
		defer func() {
			p.subs.Delete(ch)
			close(ch)
		}()

		p.mu.Lock()
		client := p.client
		p.mu.Unlock()

		if client == nil {
			return
		}

		stream, err := client.StreamEvents(ctx, &process_pb.StreamEventsRequest{})
		if err != nil {
			log.Printf("[ProcessListener] Subscribe failed: %v", err)
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
				case *process_pb.Event_Connection:
					select {
					case ch <- e.Connection:
					case <-ctx.Done():
						return
					}
				case *process_pb.Event_Log:
					// Could forward to parent's logging
				}
			}
		}
	}()

	return ch
}

// Unsubscribe stops receiving events on the channel.
func (p *ProcessListener) Unsubscribe(ch chan *pb.ConnectionEvent) {
	if value, ok := p.subs.LoadAndDelete(ch); ok {
		if cancel, ok := value.(context.CancelFunc); ok {
			cancel()
		}
	}
}

// GetConnectionBytes returns byte counts for a connection.
func (p *ProcessListener) GetConnectionBytes(connID string) (in, out int64, ok bool) {
	// ProcessListener doesn't track individual connections
	return 0, 0, false
}

// GetActiveConnections returns active connections from child.
func (p *ProcessListener) GetActiveConnections() []*ConnectionMetadata {
	p.mu.Lock()
	client := p.client
	p.mu.Unlock()

	if client == nil {
		return nil
	}

	resp, err := client.GetActiveConnections(context.Background(), &process_pb.GetActiveConnectionsRequest{})
	if err != nil {
		return nil
	}

	var result []*ConnectionMetadata
	for _, conn := range resp.Connections {
		bytesIn := conn.BytesIn
		bytesOut := conn.BytesOut
		result = append(result, &ConnectionMetadata{
			ID:        conn.Id,
			SourceIP:  conn.SourceIp,
			DestAddr:  conn.DestAddr,
			StartTime: conn.StartTime.AsTime(),
			BytesIn:   &bytesIn,
			BytesOut:  &bytesOut,
		})
	}
	return result
}

// CloseConnection closes a specific connection.
func (p *ProcessListener) CloseConnection(proxyID, connID string) error {
	p.mu.Lock()
	client := p.client
	p.mu.Unlock()

	if client == nil {
		return fmt.Errorf("client not ready")
	}

	resp, err := client.CloseConnection(context.Background(), &process_pb.CloseConnectionRequest{
		ConnId: connID,
	})
	if err != nil {
		return err
	}
	if !resp.Success {
		return fmt.Errorf("%s", resp.ErrorMessage)
	}
	return nil
}

// CloseAllConnections closes all connections in the child.
func (p *ProcessListener) CloseAllConnections() error {
	p.mu.Lock()
	client := p.client
	p.mu.Unlock()

	if client == nil {
		return fmt.Errorf("client not ready")
	}

	resp, err := client.CloseAllConnections(context.Background(), &process_pb.CloseAllConnectionsRequest{})
	if err != nil {
		return err
	}
	if !resp.Success {
		return fmt.Errorf("%s", resp.ErrorMessage)
	}
	return nil
}

// SetFallback sets fallback action.
func (p *ProcessListener) SetFallback(action common.FallbackAction, mock common.MockPreset) {
	p.FallbackAction = action
	p.FallbackMock = mock
}

// getRSS reads RSS (Resident Set Size) from /proc for a PID.
func getRSS(pid int) int64 {
	data, err := os.ReadFile(fmt.Sprintf("/proc/%d/stat", pid))
	if err != nil {
		return 0
	}
	fields := strings.Fields(string(data))
	if len(fields) < 24 {
		return 0
	}
	// Field 24 is RSS in pages
	pages, err := strconv.ParseInt(fields[23], 10, 64)
	if err != nil {
		return 0
	}
	return pages * int64(os.Getpagesize())
}

// ConnectionMetadataFromActive converts ActiveConnection to ConnectionMetadata.
func ConnectionMetadataFromActive(conn *pb.ActiveConnection) *ConnectionMetadata {
	bytesIn := conn.BytesIn
	bytesOut := conn.BytesOut
	return &ConnectionMetadata{
		ID:        conn.Id,
		SourceIP:  conn.SourceIp,
		DestAddr:  conn.DestAddr,
		StartTime: conn.StartTime.AsTime(),
		BytesIn:   &bytesIn,
		BytesOut:  &bytesOut,
	}
}

// Ensure ProcessListener implements Listener interface
var _ Listener = (*ProcessListener)(nil)

// ToActiveConnection converts ConnectionMetadata to ActiveConnection proto.
func (m *ConnectionMetadata) ToActiveConnection() *pb.ActiveConnection {
	var bytesIn, bytesOut int64
	if m.BytesIn != nil {
		bytesIn = *m.BytesIn
	}
	if m.BytesOut != nil {
		bytesOut = *m.BytesOut
	}
	return &pb.ActiveConnection{
		Id:         m.ID,
		SourceIp:   m.SourceIP,
		SourcePort: int32(m.SourcePort),
		DestAddr:   m.DestAddr,
		StartTime:  timestamppb.New(m.StartTime),
		BytesIn:    bytesIn,
		BytesOut:   bytesOut,
	}
}
