package integration

import (
	"io"
	"net"
	"sync"
	"testing"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/node"
)

// TestRuleEnforcement tests block, allow, mock actions using ProxyManager directly
func TestRuleEnforcement(t *testing.T) {
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
				c.Write([]byte("BACKEND_OK"))
			}(conn)
		}
	}()

	// 2. Create ProxyManager
	pm := node.NewProxyManager(true)

	// 3. Create Proxy with default ALLOW
	resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
		Name:           "test-rules",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: backendAddr,
		DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
	})
	if err != nil || !resp.Success {
		t.Fatalf("CreateProxy failed: %v", err)
	}
	proxyID := resp.ProxyId
	defer pm.DisableProxy(proxyID)

	time.Sleep(50 * time.Millisecond)

	status, _ := pm.GetStatus(proxyID)
	listenAddr := status.ListenAddr
	t.Logf("Proxy listening on %s", listenAddr)

	// --- PHASE 1: Baseline (Allow All) ---
	t.Log("Phase 1: Testing Baseline (Allow All)")
	if !testConnectionData(t, listenAddr, "BACKEND_OK") {
		t.Fatal("Baseline connection failed")
	}

	// --- PHASE 2: Add Block Rule for 127.0.0.1 ---
	t.Log("Phase 2: Adding Block Rule")
	ruleBlock := &pb.Rule{
		Id:       "block-local",
		Name:     "Block Local",
		Priority: 100,
		Enabled:  true,
		Action:   common.ActionType_ACTION_TYPE_BLOCK,
		Conditions: []*pb.Condition{
			{
				Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
				Op:    common.Operator_OPERATOR_CIDR,
				Value: "127.0.0.1/32",
			},
		},
	}

	_, err = pm.AddRule(&pb.AddRuleRequest{
		ProxyId: proxyID,
		Rule:    ruleBlock,
	})
	if err != nil {
		t.Fatalf("AddRule failed: %v", err)
	}

	// Verify Block
	if testConnectionData(t, listenAddr, "BACKEND_OK") {
		t.Fatal("Connection succeeded despite BLOCK rule")
	}
	t.Log("Connection blocked as expected")

	// --- PHASE 3: Add Mock Rule (Override Block with higher priority) ---
	t.Log("Phase 3: Adding Mock Rule (Higher Priority)")
	mockPayload := "HONEYPOT_ACTIVE"
	ruleMock := &pb.Rule{
		Id:       "mock-local",
		Name:     "Mock Local",
		Priority: 200, // Higher than block rule (100)
		Enabled:  true,
		Action:   common.ActionType_ACTION_TYPE_MOCK,
		Conditions: []*pb.Condition{
			{
				Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
				Op:    common.Operator_OPERATOR_EQ,
				Value: "127.0.0.1",
			},
		},
		MockResponse: &pb.MockConfig{
			Protocol: "raw",
			Payload:  []byte(mockPayload),
		},
	}

	_, err = pm.AddRule(&pb.AddRuleRequest{
		ProxyId: proxyID,
		Rule:    ruleMock,
	})
	if err != nil {
		t.Fatalf("AddRule (mock) failed: %v", err)
	}

	// Verify Mock Response
	if !testConnectionData(t, listenAddr, mockPayload) {
		t.Fatal("Did not receive expected Mock payload")
	}
	t.Log("Mock response received as expected")

	// --- PHASE 4: Concurrent Clients ---
	t.Log("Phase 4: Concurrent Clients against Mock Rule")
	var wg sync.WaitGroup
	clientCount := 10
	for i := 0; i < clientCount; i++ {
		wg.Add(1)
		go func(id int) {
			defer wg.Done()
			if !testConnectionData(t, listenAddr, mockPayload) {
				t.Errorf("Concurrent client %d failed", id)
			}
		}(i)
	}
	wg.Wait()
	t.Logf("All %d concurrent clients received mock response", clientCount)

	// --- PHASE 5: Remove Rules (Restore Access) ---
	t.Log("Phase 5: Removing Rules")
	pm.RemoveRule(&pb.RemoveRuleRequest{ProxyId: proxyID, RuleId: "mock-local"})
	pm.RemoveRule(&pb.RemoveRuleRequest{ProxyId: proxyID, RuleId: "block-local"})

	// Verify Baseline again
	if !testConnectionData(t, listenAddr, "BACKEND_OK") {
		t.Fatal("Connection failed after removing rules")
	}

	t.Log("Rule Enforcement Test Passed")
}

// TestDefaultBlockAction tests default block mode (whitelist)
func TestDefaultBlockAction(t *testing.T) {
	// 1. Create backend
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
				c.Write([]byte("BACKEND_OK"))
			}(conn)
		}
	}()

	// 2. Create ProxyManager
	pm := node.NewProxyManager(true)

	// 3. Create Proxy with default BLOCK
	resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
		Name:           "test-block-default",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: backendAddr,
		DefaultAction:  common.ActionType_ACTION_TYPE_BLOCK,
	})
	if err != nil || !resp.Success {
		t.Fatalf("CreateProxy failed: %v", err)
	}
	proxyID := resp.ProxyId
	defer pm.DisableProxy(proxyID)

	time.Sleep(50 * time.Millisecond)

	status, _ := pm.GetStatus(proxyID)
	listenAddr := status.ListenAddr

	// Connection should be blocked
	if testConnectionData(t, listenAddr, "BACKEND_OK") {
		t.Fatal("Connection succeeded despite default BLOCK")
	}

	// Add Allow rule for 127.0.0.1
	pm.AddRule(&pb.AddRuleRequest{
		ProxyId: proxyID,
		Rule: &pb.Rule{
			Id:       "allow-local",
			Name:     "Allow Local",
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
		},
	})

	// Now connection should succeed
	if !testConnectionData(t, listenAddr, "BACKEND_OK") {
		t.Fatal("Connection failed despite ALLOW rule")
	}

	t.Log("Default Block Action Test Passed")
}

// TestMockFallbackOnBackendFailure tests fallback to mock when backend is unavailable
func TestMockFallbackOnBackendFailure(t *testing.T) {
	pm := node.NewProxyManager(true)

	// Create Proxy with unreachable backend and mock fallback
	resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
		Name:           "test-fallback",
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

	time.Sleep(50 * time.Millisecond)

	status, _ := pm.GetStatus(proxyID)
	listenAddr := status.ListenAddr

	// Should receive fallback mock response
	if !testConnectionData(t, listenAddr, "403 Forbidden") {
		t.Fatal("Did not receive fallback mock response")
	}

	t.Log("Mock Fallback Test Passed")
}

// TestEmptyBackendFallback tests fallback when no backend is configured
func TestEmptyBackendFallback(t *testing.T) {
	pm := node.NewProxyManager(true)

	// Create Proxy with no backend
	resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
		Name:           "test-empty-backend",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: "", // No backend
		DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
		DefaultMock:    common.MockPreset_MOCK_PRESET_HTTP_403,
	})
	if err != nil || !resp.Success {
		t.Fatalf("CreateProxy failed: %v", err)
	}
	proxyID := resp.ProxyId
	defer pm.DisableProxy(proxyID)

	time.Sleep(50 * time.Millisecond)

	status, _ := pm.GetStatus(proxyID)
	listenAddr := status.ListenAddr

	// Should receive fallback mock response
	if !testConnectionData(t, listenAddr, "403 Forbidden") {
		t.Fatal("Did not receive fallback mock response for empty backend")
	}

	t.Log("Empty Backend Fallback Test Passed")
}

// TestRulePriority tests that higher priority rules take precedence
func TestRulePriority(t *testing.T) {
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
				c.Write([]byte("BACKEND_OK"))
			}(conn)
		}
	}()

	pm := node.NewProxyManager(true)

	resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
		Name:           "test-priority",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: backendAddr,
		DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
	})
	if err != nil || !resp.Success {
		t.Fatalf("CreateProxy failed: %v", err)
	}
	proxyID := resp.ProxyId
	defer pm.DisableProxy(proxyID)

	time.Sleep(50 * time.Millisecond)

	status, _ := pm.GetStatus(proxyID)
	listenAddr := status.ListenAddr

	// Add low priority BLOCK rule
	pm.AddRule(&pb.AddRuleRequest{
		ProxyId: proxyID,
		Rule: &pb.Rule{
			Id:       "block-low",
			Name:     "Block Low Priority",
			Priority: 10,
			Enabled:  true,
			Action:   common.ActionType_ACTION_TYPE_BLOCK,
			Conditions: []*pb.Condition{
				{
					Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
					Op:    common.Operator_OPERATOR_EQ,
					Value: "127.0.0.1",
				},
			},
		},
	})

	// Verify blocked
	if testConnectionData(t, listenAddr, "BACKEND_OK") {
		t.Fatal("Low priority block rule not working")
	}

	// Add high priority ALLOW rule
	pm.AddRule(&pb.AddRuleRequest{
		ProxyId: proxyID,
		Rule: &pb.Rule{
			Id:       "allow-high",
			Name:     "Allow High Priority",
			Priority: 100, // Higher priority
			Enabled:  true,
			Action:   common.ActionType_ACTION_TYPE_ALLOW,
			Conditions: []*pb.Condition{
				{
					Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
					Op:    common.Operator_OPERATOR_EQ,
					Value: "127.0.0.1",
				},
			},
		},
	})

	// Verify allowed (high priority ALLOW overrides low priority BLOCK)
	if !testConnectionData(t, listenAddr, "BACKEND_OK") {
		t.Fatal("High priority allow rule not taking precedence")
	}

	t.Log("Rule Priority Test Passed")
}

// TestCIDRCondition tests CIDR-based matching
func TestCIDRCondition(t *testing.T) {
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
				c.Write([]byte("BACKEND_OK"))
			}(conn)
		}
	}()

	pm := node.NewProxyManager(true)

	resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
		Name:           "test-cidr",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: backendAddr,
		DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
	})
	if err != nil || !resp.Success {
		t.Fatalf("CreateProxy failed: %v", err)
	}
	proxyID := resp.ProxyId
	defer pm.DisableProxy(proxyID)

	time.Sleep(50 * time.Millisecond)

	status, _ := pm.GetStatus(proxyID)
	listenAddr := status.ListenAddr

	// Add CIDR block rule (127.0.0.0/8 covers all loopback)
	pm.AddRule(&pb.AddRuleRequest{
		ProxyId: proxyID,
		Rule: &pb.Rule{
			Id:       "block-loopback",
			Name:     "Block Loopback CIDR",
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

	// Connection from 127.0.0.1 should be blocked
	if testConnectionData(t, listenAddr, "BACKEND_OK") {
		t.Fatal("CIDR block rule not working")
	}

	t.Log("CIDR Condition Test Passed")
}

// Helper function for rule tests - with retry for stability
func testConnectionData(t *testing.T, addr string, expected string) bool {
	// Retry up to 3 times for flaky connections
	for attempt := 0; attempt < 3; attempt++ {
		conn, err := net.DialTimeout("tcp", addr, 3*time.Second)
		if err != nil {
			time.Sleep(50 * time.Millisecond)
			continue
		}

		conn.SetReadDeadline(time.Now().Add(3 * time.Second))

		data, err := io.ReadAll(conn)
		conn.Close()
		if err != nil && err != io.EOF {
			time.Sleep(50 * time.Millisecond)
			continue
		}

		result := string(data)
		contains := len(result) > 0 && (expected == "" || containsString(result, expected))
		if contains {
			return true
		}

		// Only retry if we got empty data (timing issue)
		if len(result) == 0 {
			time.Sleep(50 * time.Millisecond)
			continue
		}

		// Got data but didn't match - don't retry
		t.Logf("Expected '%s', got '%s'", expected, result)
		return false
	}

	t.Logf("Expected '%s', got empty after retries", expected)
	return false
}

func containsString(s, substr string) bool {
	return len(substr) == 0 || (len(s) >= len(substr) && findSubstring(s, substr))
}

func findSubstring(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}
