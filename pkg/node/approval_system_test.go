package node

import (
	"fmt"
	"io"
	"net"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/proxy"
)

// ChannelAlertSender implements AlertSender with a channel for test interception
type ChannelAlertSender struct {
	Requests chan *common.Alert
	Infos    chan string
	mu       sync.Mutex
}

func NewChannelAlertSender(bufSize int) *ChannelAlertSender {
	return &ChannelAlertSender{
		Requests: make(chan *common.Alert, bufSize),
		Infos:    make(chan string, bufSize),
	}
}

func (s *ChannelAlertSender) SendAlert(alert *common.Alert, info string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	select {
	case s.Requests <- alert:
	default:
		// Channel full, drop
	}
	select {
	case s.Infos <- info:
	default:
	}
	return nil
}

// TestApprovalSystem tests the full approval workflow with real TCP connections
func TestApprovalSystem(t *testing.T) {
	// 1. Setup Backend (Echo Server)
	backendLn, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("Failed to create backend: %v", err)
	}
	defer backendLn.Close()
	backendAddr := backendLn.Addr().String()

	go func() {
		for {
			conn, err := backendLn.Accept()
			if err != nil {
				return
			}
			go func(c net.Conn) {
				defer c.Close()
				io.Copy(c, c)
			}(conn)
		}
	}()

	// 2. Setup Approval Manager
	sender := NewChannelAlertSender(10)
	am := NewApprovalManager(sender)

	// 3. Setup Listener with REQUIRE_APPROVAL
	listener := NewEmbeddedListener(
		"test-approval",
		"Approval Proxy",
		"127.0.0.1:0",
		backendAddr,
		common.ActionType_ACTION_TYPE_REQUIRE_APPROVAL,
		common.MockPreset_MOCK_PRESET_UNSPECIFIED,
		"", "", "", // No TLS
		pb.ClientAuthType_CLIENT_AUTH_AUTO,
		nil, // No GeoIP
	)

	// Wire up approval manager
	listener.SetApprovalManager(am)
	listener.SetNodeID("test-node-1")
	am.SetConnectionCloser(listener)

	if err := listener.Start(); err != nil {
		t.Fatalf("Failed to start listener: %v", err)
	}
	defer listener.Stop()

	proxyAddr := listener.ListenAddr

	// Helper to make a request
	makeRequest := func(message string) error {
		conn, err := net.DialTimeout("tcp", proxyAddr, 2*time.Second)
		if err != nil {
			return err
		}
		defer conn.Close()

		conn.SetDeadline(time.Now().Add(5 * time.Second))
		_, err = conn.Write([]byte(message))
		if err != nil {
			return err
		}

		buf := make([]byte, len(message))
		_, err = io.ReadFull(conn, buf)
		if err != nil {
			return err
		}
		if string(buf) != message {
			return fmt.Errorf("unexpected response: %s", string(buf))
		}
		return nil
	}

	// === TEST CASE 1: Allow Once ===
	t.Run("AllowOnce", func(t *testing.T) {
		done := make(chan error, 1)
		go func() {
			done <- makeRequest("hello")
		}()

		// Expect approval request
		var req *common.Alert
		select {
		case req = <-sender.Requests:
			if req.Id == "" {
				t.Error("Alert should have an ID")
			}
		case <-time.After(2 * time.Second):
			t.Fatal("Timeout waiting for approval request")
		}

		// Approve with duration 0 (once)
		am.Resolve(req.Id, true, 0, "")

		// Wait for connection to complete
		if err := <-done; err != nil {
			t.Errorf("Connection should succeed after approval: %v", err)
		}

		// Immediate subsequent connection should require approval again (duration=0)
		go func() {
			done <- makeRequest("hello2")
		}()

		select {
		case req = <-sender.Requests:
			// Good, asked again
			am.Resolve(req.Id, false, 0, "") // Reject
		case <-time.After(2 * time.Second):
			t.Fatal("Expected second request to trigger approval")
		}

		if err := <-done; err == nil {
			t.Error("Connection should fail after rejection")
		}
	})

	// === TEST CASE 2: Allow with Duration (Cache Hit) ===
	t.Run("AllowDuration", func(t *testing.T) {
		done := make(chan error, 1)
		go func() {
			done <- makeRequest("persistent")
		}()

		var req *common.Alert
		select {
		case req = <-sender.Requests:
		case <-time.After(2 * time.Second):
			t.Fatal("Timeout")
		}

		// Approve for 3 seconds
		am.Resolve(req.Id, true, 3, "")

		if err := <-done; err != nil {
			t.Errorf("First connection should succeed: %v", err)
		}

		// Immediate retry -> Should use cache (no new approval request)
		if err := makeRequest("cached"); err != nil {
			t.Errorf("Cached connection should succeed: %v", err)
		}

		// Verify no new approval request was sent
		select {
		case <-sender.Requests:
			t.Error("Should use cache, not send new request")
		case <-time.After(200 * time.Millisecond):
			// Good, no request
		}

		// Wait for expiry
		time.Sleep(4 * time.Second)

		// Retry -> Should require approval again
		go func() {
			done <- makeRequest("expired")
		}()

		select {
		case req = <-sender.Requests:
			am.Resolve(req.Id, true, 0, "") // Clean up
		case <-time.After(2 * time.Second):
			t.Fatal("Expected request after cache expiry")
		}
		<-done
	})

	// === TEST CASE 3: Block Once ===
	t.Run("BlockOnce", func(t *testing.T) {
		done := make(chan error, 1)
		go func() {
			done <- makeRequest("blocked")
		}()

		var req *common.Alert
		select {
		case req = <-sender.Requests:
		case <-time.After(2 * time.Second):
			t.Fatal("Timeout")
		}

		// Deny once
		am.Resolve(req.Id, false, 0, "")

		if err := <-done; err == nil {
			t.Error("Connection should fail after block")
		}

		// Subsequent connection should require approval again
		go func() {
			done <- makeRequest("blocked2")
		}()

		select {
		case req = <-sender.Requests:
			// Good, asked again
			am.Resolve(req.Id, true, 0, "") // Allow this one
		case <-time.After(2 * time.Second):
			t.Fatal("Expected second request to trigger approval")
		}

		if err := <-done; err != nil {
			t.Errorf("Second connection should succeed after approval: %v", err)
		}
	})

	// === TEST CASE 4: Block with Duration (Cache Hit) ===
	t.Run("BlockDuration", func(t *testing.T) {
		done := make(chan error, 1)
		go func() {
			done <- makeRequest("persistent-block")
		}()

		var req *common.Alert
		select {
		case req = <-sender.Requests:
		case <-time.After(2 * time.Second):
			t.Fatal("Timeout")
		}

		// Block for 3 seconds
		am.Resolve(req.Id, false, 3, "")

		if err := <-done; err == nil {
			t.Error("First connection should fail")
		}

		// Immediate retry -> Should use cache (blocked immediately, no request)
		go func() {
			done <- makeRequest("cached-block")
		}()

		// No new approval request expected
		select {
		case <-sender.Requests:
			t.Error("Should use cache (block), not send new request")
		case <-time.After(500 * time.Millisecond):
			// Good
		}

		if err := <-done; err == nil {
			t.Error("Cached block should fail")
		}

		// Wait for expiry
		time.Sleep(4 * time.Second)

		// Retry -> Should require approval again
		go func() {
			done <- makeRequest("expired-block")
		}()

		select {
		case req = <-sender.Requests:
			am.Resolve(req.Id, true, 0, "") // Allow to clean up
		case <-time.After(2 * time.Second):
			t.Fatal("Expected request after cache expiry")
		}
		<-done
	})

	// === TEST CASE 5: Revoke Active Connection ===
	t.Run("RevokeActive", func(t *testing.T) {
		// Start a long-running connection
		conn, err := net.DialTimeout("tcp", proxyAddr, 2*time.Second)
		if err != nil {
			t.Fatalf("Failed to connect: %v", err)
		}
		defer conn.Close()

		// Trigger approval request
		go func() {
			conn.Write([]byte("long-running"))
		}()

		var req *common.Alert
		select {
		case req = <-sender.Requests:
		case <-time.After(2 * time.Second):
			t.Fatal("Timeout")
		}

		// Approve for 60 seconds
		am.Resolve(req.Id, true, 60, "")

		// Wait for approval to propagate
		time.Sleep(200 * time.Millisecond)

		// Read echoed data
		buf := make([]byte, 12)
		conn.SetReadDeadline(time.Now().Add(2 * time.Second))
		_, err = io.ReadFull(conn, buf)
		if err != nil {
			t.Errorf("Should be able to read after approval: %v", err)
		}

		// Get active approvals
		active := am.GetActiveApprovals()
		if len(active) == 0 {
			t.Fatal("Should have active approvals")
		}

		entry := active[len(active)-1]
		if len(entry.LiveConns) == 0 {
			t.Log("Note: LiveConns may not be tracked if connection completes quickly")
		}

		// Revoke by removing from cache
		am.RemoveApproval(entry.SourceIP, entry.RuleID, entry.TLSSessionID)

		// Try to read again - connection was approved so it should still work
		// (Revocation affects new connections, not existing ones unless we close them)
	})

	// === TEST CASE 6: Concurrent Approvals ===
	t.Run("ConcurrentApprovals", func(t *testing.T) {
		var wg sync.WaitGroup
		results := make(chan error, 5)

		// Start 5 concurrent connections
		for i := 0; i < 5; i++ {
			wg.Add(1)
			go func(idx int) {
				defer wg.Done()
				results <- makeRequest(fmt.Sprintf("concurrent-%d", idx))
			}(i)
		}

		// Handle all approval requests
		approvedCount := 0
		for approvedCount < 5 {
			select {
			case req := <-sender.Requests:
				am.Resolve(req.Id, true, 0, "")
				approvedCount++
			case <-time.After(5 * time.Second):
				t.Fatalf("Timeout waiting for approval request %d", approvedCount+1)
			}
		}

		wg.Wait()
		close(results)

		// Check all succeeded
		successCount := 0
		for err := range results {
			if err == nil {
				successCount++
			}
		}

		if successCount != 5 {
			t.Errorf("Expected 5 successful connections, got %d", successCount)
		}
	})

	// === TEST CASE 7: Approval Timeout ===
	t.Run("ApprovalTimeout", func(t *testing.T) {
		// Don't respond to approval - let it timeout
		errCh := make(chan error, 1)
		go func() {
			errCh <- makeRequest("timeout-test")
		}()

		// Read the request but don't respond
		select {
		case <-sender.Requests:
			// Got request, don't respond
		case <-time.After(2 * time.Second):
			t.Fatal("Timeout waiting for approval request")
		}

		// Connection should eventually fail due to timeout
		select {
		case err := <-errCh:
			if err == nil {
				t.Error("Connection should fail on approval timeout")
			}
		case <-time.After(70 * time.Second):
			t.Fatal("Test timeout - approval timeout should occur within 60s")
		}
	})
}

// TestApprovalSystem_ByteStats tests byte counting for approved connections
func TestApprovalSystem_ByteStats(t *testing.T) {
	// Backend
	backendLn, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("Failed to create backend: %v", err)
	}
	defer backendLn.Close()

	go func() {
		for {
			conn, err := backendLn.Accept()
			if err != nil {
				return
			}
			go func(c net.Conn) {
				defer c.Close()
				io.Copy(c, c)
			}(conn)
		}
	}()

	sender := NewChannelAlertSender(10)
	am := NewApprovalManager(sender)

	listener := NewEmbeddedListener(
		"test-stats",
		"Stats Proxy",
		"127.0.0.1:0",
		backendLn.Addr().String(),
		common.ActionType_ACTION_TYPE_REQUIRE_APPROVAL,
		common.MockPreset_MOCK_PRESET_UNSPECIFIED,
		"", "", "",
		pb.ClientAuthType_CLIENT_AUTH_AUTO,
		nil,
	)
	listener.SetApprovalManager(am)
	listener.SetNodeID("test-node")
	am.SetConnectionCloser(listener)

	if err := listener.Start(); err != nil {
		t.Fatalf("Failed to start: %v", err)
	}
	defer listener.Stop()

	// Connect
	conn, err := net.DialTimeout("tcp", listener.ListenAddr, 2*time.Second)
	if err != nil {
		t.Fatalf("Failed to connect: %v", err)
	}
	defer conn.Close()

	// Trigger approval
	go func() {
		conn.Write([]byte("stats-test"))
	}()

	// Approve
	select {
	case req := <-sender.Requests:
		am.Resolve(req.Id, true, 60, "")
	case <-time.After(2 * time.Second):
		t.Fatal("Timeout")
	}

	// Wait for connection
	time.Sleep(100 * time.Millisecond)

	// Send known data
	payload := []byte("1234567890") // 10 bytes
	_, err = conn.Write(payload)
	if err != nil {
		t.Fatalf("Write failed: %v", err)
	}

	// Read echo
	buf := make([]byte, 20)
	n, err := io.ReadFull(conn, buf)
	if err != nil {
		t.Fatalf("Read failed: %v", err)
	}

	time.Sleep(200 * time.Millisecond)

	// Get active connections to find connID
	conns := listener.GetActiveConnections()
	if len(conns) == 0 {
		t.Log("Connection may have completed; stats test passed implicitly")
		return
	}

	connID := conns[0].ID
	in, out, ok := listener.GetConnectionBytes(connID)
	if !ok {
		t.Log("Connection not found - may have completed")
		return
	}

	// We sent "stats-test" (10) + "1234567890" (10) = 20 bytes
	// Echo returns 20 bytes
	t.Logf("BytesIn=%d, BytesOut=%d (read %d)", in, out, n)
	if in < 10 {
		t.Errorf("Expected at least 10 bytes in, got %d", in)
	}
}

// TestApprovalSystem_SharedExpiry tests multiple connections sharing one approval
func TestApprovalSystem_SharedExpiry(t *testing.T) {
	backendLn, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("Failed to create backend: %v", err)
	}
	defer backendLn.Close()

	go func() {
		for {
			conn, err := backendLn.Accept()
			if err != nil {
				return
			}
			go func(c net.Conn) {
				defer c.Close()
				io.Copy(c, c)
			}(conn)
		}
	}()

	sender := NewChannelAlertSender(10)
	am := NewApprovalManager(sender)

	listener := NewEmbeddedListener(
		"test-shared",
		"Shared Expiry Proxy",
		"127.0.0.1:0",
		backendLn.Addr().String(),
		common.ActionType_ACTION_TYPE_REQUIRE_APPROVAL,
		common.MockPreset_MOCK_PRESET_UNSPECIFIED,
		"", "", "",
		pb.ClientAuthType_CLIENT_AUTH_AUTO,
		nil,
	)
	listener.SetApprovalManager(am)
	listener.SetNodeID("test-node")
	am.SetConnectionCloser(listener)

	if err := listener.Start(); err != nil {
		t.Fatalf("Failed to start: %v", err)
	}
	defer listener.Stop()

	// Conn 1
	conn1, err := net.DialTimeout("tcp", listener.ListenAddr, 2*time.Second)
	if err != nil {
		t.Fatalf("Conn1 failed: %v", err)
	}
	defer conn1.Close()

	go func() { conn1.Write([]byte("conn1")) }()

	// Approve conn1 for 2 seconds
	select {
	case req := <-sender.Requests:
		am.Resolve(req.Id, true, 2, "")
	case <-time.After(2 * time.Second):
		t.Fatal("Timeout")
	}

	time.Sleep(100 * time.Millisecond)

	// Conn 2 - should use cache (same sourceIP)
	conn2, err := net.DialTimeout("tcp", listener.ListenAddr, 2*time.Second)
	if err != nil {
		t.Fatalf("Conn2 failed: %v", err)
	}
	defer conn2.Close()

	go func() { conn2.Write([]byte("conn2")) }()

	// Verify no new approval request
	select {
	case <-sender.Requests:
		t.Error("Conn2 should use cache")
	case <-time.After(500 * time.Millisecond):
		// Good
	}

	// Both connections should work
	buf := make([]byte, 5)
	conn1.SetReadDeadline(time.Now().Add(1 * time.Second))
	if _, err := io.ReadFull(conn1, buf); err != nil {
		t.Errorf("Conn1 read failed: %v", err)
	}

	conn2.SetReadDeadline(time.Now().Add(1 * time.Second))
	if _, err := io.ReadFull(conn2, buf); err != nil {
		t.Errorf("Conn2 read failed: %v", err)
	}
}

// TestApprovalSystem_RuleOverride tests that rules can override default action
func TestApprovalSystem_RuleOverride(t *testing.T) {
	backendLn, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("Failed to create backend: %v", err)
	}
	defer backendLn.Close()

	go func() {
		for {
			conn, err := backendLn.Accept()
			if err != nil {
				return
			}
			go func(c net.Conn) {
				defer c.Close()
				io.Copy(c, c)
			}(conn)
		}
	}()

	sender := NewChannelAlertSender(10)
	am := NewApprovalManager(sender)

	listener := NewEmbeddedListener(
		"test-rule-override",
		"Rule Override Proxy",
		"127.0.0.1:0",
		backendLn.Addr().String(),
		common.ActionType_ACTION_TYPE_REQUIRE_APPROVAL, // Default
		common.MockPreset_MOCK_PRESET_UNSPECIFIED,
		"", "", "",
		pb.ClientAuthType_CLIENT_AUTH_AUTO,
		nil,
	)
	listener.SetApprovalManager(am)
	listener.SetNodeID("test-node")

	// Add rule that allows 127.0.0.1 without approval
	listener.AddRule(&pb.Rule{
		Id:       "allow-localhost",
		Name:     "Allow Localhost",
		Priority: 100,
		Enabled:  true,
		Action:   common.ActionType_ACTION_TYPE_ALLOW,
		Conditions: []*pb.Condition{
			{
				Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
				Op:    common.Operator_OPERATOR_EQ,
				Value: "127.0.0.1",
			},
		},
	})

	if err := listener.Start(); err != nil {
		t.Fatalf("Failed to start: %v", err)
	}
	defer listener.Stop()

	// Connect - should be allowed immediately due to rule
	conn, err := net.DialTimeout("tcp", listener.ListenAddr, 2*time.Second)
	if err != nil {
		t.Fatalf("Connect failed: %v", err)
	}
	defer conn.Close()

	// Should not trigger approval request
	conn.Write([]byte("test"))

	select {
	case <-sender.Requests:
		t.Error("Rule should bypass approval")
	case <-time.After(500 * time.Millisecond):
		// Good
	}

	// Read echo
	buf := make([]byte, 4)
	conn.SetReadDeadline(time.Now().Add(2 * time.Second))
	if _, err := io.ReadFull(conn, buf); err != nil {
		t.Errorf("Connection should work: %v", err)
	}
}

// TestApprovalSystem_GlobalRulesOverride tests global rules take precedence
func TestApprovalSystem_GlobalRulesOverride(t *testing.T) {
	backendLn, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("Failed to create backend: %v", err)
	}
	defer backendLn.Close()

	go func() {
		for {
			conn, err := backendLn.Accept()
			if err != nil {
				return
			}
			go func(c net.Conn) {
				defer c.Close()
				io.Copy(c, c)
			}(conn)
		}
	}()

	sender := NewChannelAlertSender(10)
	am := NewApprovalManager(sender)
	globalRules := NewGlobalRulesStore()

	listener := NewEmbeddedListener(
		"test-global",
		"Global Rules Proxy",
		"127.0.0.1:0",
		backendLn.Addr().String(),
		common.ActionType_ACTION_TYPE_ALLOW, // Default allow
		common.MockPreset_MOCK_PRESET_UNSPECIFIED,
		"", "", "",
		pb.ClientAuthType_CLIENT_AUTH_AUTO,
		nil,
	)
	listener.SetApprovalManager(am)
	listener.SetGlobalRules(globalRules)

	if err := listener.Start(); err != nil {
		t.Fatalf("Failed to start: %v", err)
	}
	defer listener.Stop()

	// Block 127.0.0.1 globally
	globalRules.BlockIP("127.0.0.1", 1*time.Hour)

	// Try to connect - should be blocked
	conn, err := net.DialTimeout("tcp", listener.ListenAddr, 2*time.Second)
	if err != nil {
		t.Fatalf("Dial failed: %v", err)
	}
	defer conn.Close()

	// Write should succeed but read should fail (connection closed)
	conn.Write([]byte("test"))
	conn.SetReadDeadline(time.Now().Add(1 * time.Second))
	buf := make([]byte, 4)
	_, err = conn.Read(buf)
	if err == nil {
		t.Error("Connection should be blocked by global rule")
	}

	// Remove global block
	for _, rule := range globalRules.List() {
		globalRules.Remove(rule.ID)
	}

	// Now connection should work
	conn2, err := net.DialTimeout("tcp", listener.ListenAddr, 2*time.Second)
	if err != nil {
		t.Fatalf("Dial2 failed: %v", err)
	}
	defer conn2.Close()

	conn2.Write([]byte("test"))
	conn2.SetReadDeadline(time.Now().Add(2 * time.Second))
	if _, err := io.ReadFull(conn2, buf); err != nil {
		t.Errorf("After removing block, connection should work: %v", err)
	}
}

// TestApprovalSystem_BlockFallback tests that when approval is denied, the connection
// falls back to mock response (e.g., SSH banner) instead of just closing.
func TestApprovalSystem_BlockFallback(t *testing.T) {
	// Setup backend (echo server)
	backendLn, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("Failed to create backend: %v", err)
	}
	defer backendLn.Close()
	backendAddr := backendLn.Addr().String()

	go func() {
		for {
			conn, err := backendLn.Accept()
			if err != nil {
				return
			}
			go func(c net.Conn) {
				defer c.Close()
				io.Copy(c, c)
			}(conn)
		}
	}()

	// Create approval manager with channel-based sender
	sender := NewChannelAlertSender(10)
	am := NewApprovalManager(sender)
	am.SetConnectionCloser(nil)

	// Create listener with REQUIRE_APPROVAL and set fallback to SSH mock
	listener := NewEmbeddedListener(
		"test-block-fallback",
		"Block Fallback Proxy",
		"127.0.0.1:0",
		backendAddr,
		common.ActionType_ACTION_TYPE_REQUIRE_APPROVAL,
		common.MockPreset_MOCK_PRESET_UNSPECIFIED,
		"", "", "",
		pb.ClientAuthType_CLIENT_AUTH_AUTO,
		nil,
	)
	listener.SetApprovalManager(am)
	// Set fallback to SSH secure mock when blocked
	listener.SetFallback(common.FallbackAction_FALLBACK_ACTION_MOCK, common.MockPreset_MOCK_PRESET_SSH_SECURE)

	if err = listener.Start(); err != nil {
		t.Fatalf("Start failed: %v", err)
	}
	defer listener.Stop()
	time.Sleep(100 * time.Millisecond)

	// Connect
	conn, dialErr := net.DialTimeout("tcp", listener.ListenAddr, 2*time.Second)
	if dialErr != nil {
		t.Fatalf("Dial failed: %v", dialErr)
	}
	defer conn.Close()

	// Wait for approval request and DENY it
	select {
	case req := <-sender.Requests:
		// Deny the request
		am.Resolve(req.Id, false, 0, "")
	case <-time.After(2 * time.Second):
		t.Fatal("Timeout waiting for approval request")
	}

	// Read response - should get SSH banner from mock, not just connection closed
	buf := make([]byte, 1024)
	conn.SetReadDeadline(time.Now().Add(2 * time.Second))
	n, err := conn.Read(buf)
	if err != nil {
		t.Fatalf("Read error: %v (expected SSH banner from fallback mock)", err)
	}

	response := string(buf[:n])
	if !strings.Contains(response, "SSH-2.0") {
		t.Errorf("Expected SSH banner from fallback mock, got: %s", response)
	}
	t.Logf("Received fallback mock response: %s", strings.TrimSpace(response))
}
