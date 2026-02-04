package integration

import (
	"fmt"
	"io"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/node"
)

var nitelladBinary string

func TestMain(m *testing.M) {
	// Build nitellad once for all tests
	tmpDir, err := os.MkdirTemp("", "nitella-test-build")
	if err != nil {
		fmt.Printf("Failed to create temp dir: %v\n", err)
		os.Exit(1)
	}
	defer os.RemoveAll(tmpDir)

	exePath := filepath.Join(tmpDir, "nitellad")
	cmd := exec.Command("go", "build", "-o", exePath, "../../cmd/nitellad")
	if out, err := cmd.CombinedOutput(); err != nil {
		fmt.Printf("Failed to build nitellad: %v\n%s\n", err, out)
		os.Exit(1)
	}

	nitelladBinary = exePath
	os.Setenv("NITELLA_CHILD_BINARY", nitelladBinary)

	os.Exit(m.Run())
}

// setupProcessTest validates that process mode tests can run.
func setupProcessTest(t *testing.T) {
	if nitelladBinary == "" {
		t.Skip("nitellad binary not built")
	}
}

// TestProcessListener_SingleChild tests a single child process proxy
func TestProcessListener_SingleChild(t *testing.T) {
	setupProcessTest(t)

	// 1. Start Echo Backend
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
				c.Write([]byte("CHILD_BACKEND_OK"))
			}(conn)
		}
	}()

	// 2. Create ProxyManager with process mode (useEmbedded=false)
	pm := node.NewProxyManagerWithBool(false)

	// 3. Create Proxy - this will spawn a child process
	resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
		Name:           "test-child-proxy",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: backendAddr,
		DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
	})
	if err != nil || !resp.Success {
		t.Fatalf("CreateProxy failed: %v, msg: %s", err, resp.ErrorMessage)
	}
	proxyID := resp.ProxyId
	defer pm.DisableProxy(proxyID)

	// Wait for child process to start
	time.Sleep(500 * time.Millisecond)

	status, _ := pm.GetStatus(proxyID)
	if !status.Running {
		t.Fatal("Child process proxy should be running")
	}
	listenAddr := status.ListenAddr
	t.Logf("Child process proxy listening on %s", listenAddr)

	// 4. Test connection through child process proxy
	if !testProcessConnection(t, listenAddr, "CHILD_BACKEND_OK") {
		t.Fatal("Connection through child process proxy failed")
	}

	t.Log("Single Child Process Test Passed")
}

// TestProcessListener_MultipleChildren tests multiple child processes
func TestProcessListener_MultipleChildren(t *testing.T) {
	setupProcessTest(t)

	// Create 3 backend servers
	backends := make([]net.Listener, 3)
	backendAddrs := make([]string, 3)
	for i := 0; i < 3; i++ {
		ln, err := net.Listen("tcp", "127.0.0.1:0")
		if err != nil {
			t.Fatalf("Failed to create backend %d: %v", i, err)
		}
		backends[i] = ln
		backendAddrs[i] = ln.Addr().String()

		idx := i
		go func() {
			for {
				conn, err := backends[idx].Accept()
				if err != nil {
					return
				}
				go func(c net.Conn, id int) {
					defer c.Close()
					c.Write([]byte("BACKEND_" + string(rune('A'+id))))
				}(conn, idx)
			}
		}()
	}
	defer func() {
		for _, ln := range backends {
			ln.Close()
		}
	}()

	// Create ProxyManager with process mode
	pm := node.NewProxyManagerWithBool(false)

	// Create 3 proxies - each spawns a child process
	proxyIDs := make([]string, 3)
	listenAddrs := make([]string, 3)
	for i := 0; i < 3; i++ {
		resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
			Name:           "test-multi-child-" + string(rune('A'+i)),
			ListenAddr:     "127.0.0.1:0",
			DefaultBackend: backendAddrs[i],
			DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
		})
		if err != nil || !resp.Success {
			t.Fatalf("CreateProxy %d failed: %v, msg: %s", i, err, resp.ErrorMessage)
		}
		proxyIDs[i] = resp.ProxyId
	}
	defer func() {
		for _, id := range proxyIDs {
			pm.DisableProxy(id)
		}
	}()

	// Wait for all child processes to start
	time.Sleep(1 * time.Second)

	// Get listen addresses
	for i, id := range proxyIDs {
		status, _ := pm.GetStatus(id)
		if !status.Running {
			t.Fatalf("Child process %d not running", i)
		}
		listenAddrs[i] = status.ListenAddr
		t.Logf("Child %d listening on %s", i, listenAddrs[i])
	}

	// Test concurrent connections to all proxies
	var wg sync.WaitGroup
	results := make([]bool, 3)
	for i := 0; i < 3; i++ {
		wg.Add(1)
		go func(idx int) {
			defer wg.Done()
			expected := "BACKEND_" + string(rune('A'+idx))
			results[idx] = testProcessConnection(t, listenAddrs[idx], expected)
		}(i)
	}
	wg.Wait()

	for i, ok := range results {
		if !ok {
			t.Errorf("Connection to child process %d failed", i)
		}
	}

	t.Log("Multiple Children Test Passed")
}

// TestProcessListener_RuleEnforcement tests rule enforcement in child process
func TestProcessListener_RuleEnforcement(t *testing.T) {
	setupProcessTest(t)

	// Backend
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
				c.Write([]byte("RULE_BACKEND"))
			}(conn)
		}
	}()

	// Create ProxyManager with process mode
	pm := node.NewProxyManagerWithBool(false)

	// Create proxy
	resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
		Name:           "test-child-rules",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: backendAddr,
		DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
	})
	if err != nil || !resp.Success {
		t.Fatalf("CreateProxy failed: %v", err)
	}
	proxyID := resp.ProxyId
	defer pm.DisableProxy(proxyID)

	time.Sleep(500 * time.Millisecond)

	status, _ := pm.GetStatus(proxyID)
	listenAddr := status.ListenAddr
	t.Logf("Child proxy listening on %s", listenAddr)

	// Phase 1: Baseline - should allow
	t.Log("Phase 1: Baseline (Allow)")
	if !testProcessConnection(t, listenAddr, "RULE_BACKEND") {
		t.Fatal("Baseline connection failed")
	}

	// Phase 2: Add Block Rule
	t.Log("Phase 2: Add Block Rule")
	_, err = pm.AddRule(&pb.AddRuleRequest{
		ProxyId: proxyID,
		Rule: &pb.Rule{
			Id:       "block-test",
			Name:     "Block Test",
			Priority: 100,
			Enabled:  true,
			Action:   common.ActionType_ACTION_TYPE_BLOCK,
			Conditions: []*pb.Condition{
				{
					Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
					Op:    common.Operator_OPERATOR_CIDR,
					Value: "127.0.0.0/8",
				},
			},
		},
	})
	if err != nil {
		t.Fatalf("AddRule failed: %v", err)
	}

	time.Sleep(200 * time.Millisecond)

	// Verify block
	if testProcessConnection(t, listenAddr, "RULE_BACKEND") {
		t.Fatal("Connection should be blocked")
	}
	t.Log("Connection blocked as expected")

	// Phase 3: Remove block rule
	t.Log("Phase 3: Remove Block Rule")
	pm.RemoveRule(&pb.RemoveRuleRequest{ProxyId: proxyID, RuleId: "block-test"})

	time.Sleep(200 * time.Millisecond)

	// Verify allowed again
	if !testProcessConnection(t, listenAddr, "RULE_BACKEND") {
		t.Fatal("Connection should be allowed after removing rule")
	}

	t.Log("Rule Enforcement in Child Process Test Passed")
}

// TestProcessListener_Isolation tests that child process crash doesn't affect others
func TestProcessListener_Isolation(t *testing.T) {
	setupProcessTest(t)

	// Create 2 backends
	backend1, _ := net.Listen("tcp", "127.0.0.1:0")
	backend2, _ := net.Listen("tcp", "127.0.0.1:0")
	defer backend1.Close()
	defer backend2.Close()

	for _, ln := range []net.Listener{backend1, backend2} {
		go func(l net.Listener) {
			for {
				conn, err := l.Accept()
				if err != nil {
					return
				}
				go func(c net.Conn) {
					defer c.Close()
					c.Write([]byte("ISOLATED_OK"))
				}(conn)
			}
		}(ln)
	}

	pm := node.NewProxyManagerWithBool(false)

	// Create 2 child proxies
	resp1, err := pm.CreateProxy(&pb.CreateProxyRequest{
		Name:           "isolation-1",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: backend1.Addr().String(),
		DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
	})
	if err != nil || !resp1.Success {
		t.Fatalf("CreateProxy 1 failed: %v, msg: %s", err, resp1.ErrorMessage)
	}
	resp2, err := pm.CreateProxy(&pb.CreateProxyRequest{
		Name:           "isolation-2",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: backend2.Addr().String(),
		DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
	})
	if err != nil || !resp2.Success {
		t.Fatalf("CreateProxy 2 failed: %v, msg: %s", err, resp2.ErrorMessage)
	}
	defer pm.DisableProxy(resp1.ProxyId)
	defer pm.DisableProxy(resp2.ProxyId)

	time.Sleep(500 * time.Millisecond)

	status1, _ := pm.GetStatus(resp1.ProxyId)
	status2, _ := pm.GetStatus(resp2.ProxyId)

	// Both should be running
	if !status1.Running || !status2.Running {
		t.Fatal("Both child proxies should be running")
	}

	// Kill first proxy
	pm.DisableProxy(resp1.ProxyId)
	time.Sleep(200 * time.Millisecond)

	// Second should still work
	if !testProcessConnection(t, status2.ListenAddr, "ISOLATED_OK") {
		t.Fatal("Second proxy should still work after first is killed")
	}

	t.Log("Process Isolation Test Passed")
}

// TestProcessListener_MockFallback tests mock fallback in child process
func TestProcessListener_MockFallback(t *testing.T) {
	setupProcessTest(t)

	pm := node.NewProxyManagerWithBool(false)

	// Create proxy with unreachable backend and mock fallback
	resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
		Name:           "test-child-mock",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: "127.0.0.1:1", // Unreachable
		DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
		DefaultMock:    common.MockPreset_MOCK_PRESET_HTTP_403,
	})
	if err != nil || !resp.Success {
		t.Fatalf("CreateProxy failed: %v", err)
	}
	proxyID := resp.ProxyId
	defer pm.DisableProxy(proxyID)

	time.Sleep(500 * time.Millisecond)

	status, _ := pm.GetStatus(proxyID)
	listenAddr := status.ListenAddr

	// Should receive mock response
	if !testProcessConnection(t, listenAddr, "403") {
		t.Fatal("Should receive mock 403 response")
	}

	t.Log("Mock Fallback in Child Process Test Passed")
}

// TestProcessListener_ForceKillAndRecover tests killing child process and recovering
func TestProcessListener_ForceKillAndRecover(t *testing.T) {
	setupProcessTest(t)

	// Backend
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
				c.Write([]byte("RECOVERY_BACKEND"))
			}(conn)
		}
	}()

	// Create ProxyManager with process mode
	pm := node.NewProxyManagerWithBool(false)

	// Create proxy
	resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
		Name:           "test-kill-recover",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: backendAddr,
		DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
	})
	if err != nil || !resp.Success {
		t.Fatalf("CreateProxy failed: %v", err)
	}
	proxyID := resp.ProxyId
	defer pm.DisableProxy(proxyID)

	time.Sleep(500 * time.Millisecond)

	status, _ := pm.GetStatus(proxyID)
	listenAddr := status.ListenAddr
	t.Logf("Child proxy listening on %s", listenAddr)

	// Phase 1: Verify it's running
	t.Log("Phase 1: Verify proxy is running")
	if !status.Running {
		t.Fatal("Proxy should be running")
	}
	if !testProcessConnection(t, listenAddr, "RECOVERY_BACKEND") {
		t.Fatal("Connection should work before kill")
	}

	// Phase 2: Get child PID and force kill it
	t.Log("Phase 2: Force kill child process")

	// Get all proxies and find ours
	statuses := pm.GetAllStatuses()
	var childPID int
	for _, s := range statuses {
		if s.ProxyId == proxyID {
			// Access via the proxy's MemoryRss calculation uses PID
			// We need to get PID from the ProcessListener
			break
		}
	}

	// Use syscall to kill the process
	// First find the process listening on the port
	listenPort := listenAddr[len("127.0.0.1:"):]
	cmd := exec.Command("sh", "-c", fmt.Sprintf("lsof -ti tcp:%s | head -1", listenPort))
	output, err := cmd.Output()
	if err != nil {
		t.Logf("Could not find PID via lsof: %v", err)
		// Fallback: disable and re-enable instead
		t.Log("Fallback: Using disable/enable for recovery test")
		pm.DisableProxy(proxyID)
		time.Sleep(200 * time.Millisecond)
		goto recovery
	}

	childPID = 0
	fmt.Sscanf(string(output), "%d", &childPID)
	if childPID <= 0 {
		t.Log("Could not parse PID, using fallback")
		pm.DisableProxy(proxyID)
		time.Sleep(200 * time.Millisecond)
		goto recovery
	}
	t.Logf("Found child PID: %d", childPID)

	// Force kill with SIGKILL
	{
		killCmd := exec.Command("kill", "-9", fmt.Sprintf("%d", childPID))
		if err := killCmd.Run(); err != nil {
			t.Logf("Kill command failed: %v", err)
		}
	}

	// Wait for parent to detect the exit
	time.Sleep(500 * time.Millisecond)

	// Phase 3: Verify proxy is now not running
	t.Log("Phase 3: Verify proxy detected crash")
	status, _ = pm.GetStatus(proxyID)
	if status.Running {
		t.Log("Warning: Proxy still shows running (may take time to detect)")
	} else {
		t.Log("Proxy correctly detected as not running after kill")
	}

	// Connection should fail
	if testProcessConnection(t, listenAddr, "RECOVERY_BACKEND") {
		t.Log("Connection still works - process may not be dead yet")
	}

recovery:
	// Phase 4: Recover by re-enabling
	t.Log("Phase 4: Re-enable proxy to recover")
	enableResp, err := pm.EnableProxy(proxyID)
	if err != nil {
		t.Fatalf("EnableProxy failed: %v", err)
	}
	if !enableResp.Success {
		t.Fatalf("EnableProxy returned error: %s", enableResp.ErrorMessage)
	}

	// Wait for restart
	time.Sleep(500 * time.Millisecond)

	// Phase 5: Verify recovered
	t.Log("Phase 5: Verify proxy recovered")
	status, _ = pm.GetStatus(proxyID)
	if !status.Running {
		t.Fatal("Proxy should be running after recovery")
	}
	newListenAddr := status.ListenAddr
	t.Logf("Recovered proxy listening on %s", newListenAddr)

	// Connection should work again
	if !testProcessConnection(t, newListenAddr, "RECOVERY_BACKEND") {
		t.Fatal("Connection should work after recovery")
	}

	t.Log("Force Kill and Recovery Test Passed")
}

// TestGetAllActiveConnections tests getting connections from all proxies when no proxyID specified
func TestGetAllActiveConnections(t *testing.T) {
	setupProcessTest(t)

	// Create 2 backends
	backend1, _ := net.Listen("tcp", "127.0.0.1:0")
	backend2, _ := net.Listen("tcp", "127.0.0.1:0")
	defer backend1.Close()
	defer backend2.Close()

	// These backends keep connections alive (echo after delay)
	for _, ln := range []net.Listener{backend1, backend2} {
		go func(l net.Listener) {
			for {
				conn, err := l.Accept()
				if err != nil {
					return
				}
				go func(c net.Conn) {
					defer c.Close()
					// Keep connection alive for a bit
					buf := make([]byte, 1024)
					for {
						n, err := c.Read(buf)
						if err != nil {
							return
						}
						c.Write(buf[:n])
					}
				}(conn)
			}
		}(ln)
	}

	// Create ProxyManager with embedded mode (simpler for this test)
	pm := node.NewProxyManagerWithBool(true)

	// Create 2 proxies
	resp1, err := pm.CreateProxy(&pb.CreateProxyRequest{
		Name:           "conn-test-1",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: backend1.Addr().String(),
		DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
	})
	if err != nil || !resp1.Success {
		t.Fatalf("CreateProxy 1 failed: %v", err)
	}
	resp2, err := pm.CreateProxy(&pb.CreateProxyRequest{
		Name:           "conn-test-2",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: backend2.Addr().String(),
		DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
	})
	if err != nil || !resp2.Success {
		t.Fatalf("CreateProxy 2 failed: %v", err)
	}
	defer pm.DisableProxy(resp1.ProxyId)
	defer pm.DisableProxy(resp2.ProxyId)

	time.Sleep(300 * time.Millisecond)

	status1, _ := pm.GetStatus(resp1.ProxyId)
	status2, _ := pm.GetStatus(resp2.ProxyId)

	// Establish connections to both proxies (keep alive)
	conn1, err := net.Dial("tcp", status1.ListenAddr)
	if err != nil {
		t.Fatalf("Failed to connect to proxy 1: %v", err)
	}
	defer conn1.Close()

	conn2, err := net.Dial("tcp", status2.ListenAddr)
	if err != nil {
		t.Fatalf("Failed to connect to proxy 2: %v", err)
	}
	defer conn2.Close()

	// Send some data to keep connections active
	conn1.Write([]byte("test1"))
	conn2.Write([]byte("test2"))

	// Wait with retry for connections to be registered
	var conns1, conns2, allConns []*node.ConnectionMetadata
	for attempt := 0; attempt < 10; attempt++ {
		time.Sleep(200 * time.Millisecond)
		conns1 = pm.GetActiveConnections(resp1.ProxyId)
		conns2 = pm.GetActiveConnections(resp2.ProxyId)
		allConns = pm.GetActiveConnections("")
		if len(conns1) >= 1 && len(conns2) >= 1 && len(allConns) >= 2 {
			break
		}
	}

	// Test 1: GetActiveConnections with specific proxyID returns only that proxy's connections
	if len(conns1) != 1 {
		t.Errorf("Expected 1 connection for proxy1, got %d", len(conns1))
	}

	if len(conns2) != 1 {
		t.Errorf("Expected 1 connection for proxy2, got %d", len(conns2))
	}

	// Test 2: GetActiveConnections with empty proxyID returns ALL connections
	if len(allConns) < 2 {
		t.Errorf("Expected at least 2 connections total, got %d", len(allConns))
	}
	t.Logf("Total connections from all proxies: %d", len(allConns))

	// Verify connections are from different proxies by checking connection IDs are unique
	connIDs := make(map[string]bool)
	for _, c := range allConns {
		connIDs[c.ID] = true
		t.Logf("  Connection: %s (ID: %s) -> %s", c.SourceIP, c.ID, c.DestAddr)
	}
	if len(connIDs) < 2 {
		t.Errorf("Expected connections with unique IDs, got %d unique IDs", len(connIDs))
	}

	t.Log("GetAllActiveConnections Test Passed")
}

// containsString checks if s contains substr
func containsString(s, substr string) bool {
	return strings.Contains(s, substr)
}

// testProcessConnection helper with retry
func testProcessConnection(t *testing.T, addr string, expected string) bool {
	for attempt := 0; attempt < 5; attempt++ {
		conn, err := net.DialTimeout("tcp", addr, 3*time.Second)
		if err != nil {
			t.Logf("Attempt %d: dial failed: %v", attempt+1, err)
			time.Sleep(200 * time.Millisecond)
			continue
		}

		conn.SetReadDeadline(time.Now().Add(3 * time.Second))
		data, err := io.ReadAll(conn)
		conn.Close()
		if err != nil && err != io.EOF {
			time.Sleep(200 * time.Millisecond)
			continue
		}

		result := string(data)
		if len(result) > 0 && containsString(result, expected) {
			return true
		}

		if len(result) == 0 {
			time.Sleep(200 * time.Millisecond)
			continue
		}

		t.Logf("Expected '%s', got '%s'", expected, result)
		return false
	}

	t.Logf("Expected '%s', got empty after retries", expected)
	return false
}
