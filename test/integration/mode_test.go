package integration

import (
	"fmt"
	"io"
	"net"
	"os"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/node"
)

// testMode represents embedded or process mode
type testMode struct {
	name        string
	useEmbedded bool
}

var testModes = []testMode{
	{"Embedded", true},
	{"Process", false},
}

// setupMode prepares the test environment for the given mode.
// Process mode tests require running as the actual nitellad binary.
func setupMode(t *testing.T, mode testMode) {
	if !mode.useEmbedded {
		exe, err := os.Executable()
		if err != nil {
			t.Skipf("Cannot determine executable path: %v", err)
		}
		if !strings.Contains(exe, "nitellad") {
			t.Skip("Process mode tests require running as nitellad binary, skipped in 'go test'.")
		}
	}
}

// createEchoBackend creates a simple echo backend server
func createEchoBackend(t *testing.T, response string) (net.Listener, string) {
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("Failed to create backend: %v", err)
	}

	go func() {
		for {
			conn, err := ln.Accept()
			if err != nil {
				return
			}
			go func(c net.Conn) {
				defer c.Close()
				c.Write([]byte(response))
			}(conn)
		}
	}()

	return ln, ln.Addr().String()
}

// createLongLivedBackend creates a backend that keeps connections alive
func createLongLivedBackend(t *testing.T) (net.Listener, string) {
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("Failed to create backend: %v", err)
	}

	go func() {
		for {
			conn, err := ln.Accept()
			if err != nil {
				return
			}
			go func(c net.Conn) {
				defer c.Close()
				buf := make([]byte, 1024)
				for {
					n, err := c.Read(buf)
					if err != nil {
						return
					}
					c.Write(buf[:n]) // Echo back
				}
			}(conn)
		}
	}()

	return ln, ln.Addr().String()
}

// modeTestConnection tests a connection and returns whether it succeeded
func modeTestConnection(t *testing.T, addr string, expected string) bool {
	for attempt := 0; attempt < 5; attempt++ {
		conn, err := net.DialTimeout("tcp", addr, 3*time.Second)
		if err != nil {
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
		if strings.Contains(result, expected) {
			return true
		}

		if len(result) == 0 {
			time.Sleep(200 * time.Millisecond)
			continue
		}

		t.Logf("Expected '%s', got '%s'", expected, result)
		return false
	}
	return false
}

// ============================================================================
// Proxy Creation Tests
// ============================================================================

func TestMode_ProxyCreate(t *testing.T) {
	for _, mode := range testModes {
		t.Run(mode.name, func(t *testing.T) {
			setupMode(t, mode)

			backend, backendAddr := createEchoBackend(t, "CREATE_TEST_OK")
			defer backend.Close()

			pm := node.NewProxyManagerWithBool(mode.useEmbedded)

			resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
				Name:           "test-create-" + mode.name,
				ListenAddr:     "127.0.0.1:0",
				DefaultBackend: backendAddr,
				DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
			})
			if err != nil || !resp.Success {
				t.Fatalf("CreateProxy failed: %v, msg: %s", err, resp.ErrorMessage)
			}
			defer pm.DisableProxy(resp.ProxyId)

			time.Sleep(500 * time.Millisecond)

			status, _ := pm.GetStatus(resp.ProxyId)
			if !status.Running {
				t.Fatal("Proxy should be running")
			}

			if !modeTestConnection(t, status.ListenAddr, "CREATE_TEST_OK") {
				t.Fatal("Connection through proxy failed")
			}
		})
	}
}

func TestMode_ProxyEnableDisable(t *testing.T) {
	for _, mode := range testModes {
		t.Run(mode.name, func(t *testing.T) {
			setupMode(t, mode)

			backend, backendAddr := createEchoBackend(t, "ENABLE_DISABLE_OK")
			defer backend.Close()

			pm := node.NewProxyManagerWithBool(mode.useEmbedded)

			resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
				Name:           "test-enable-" + mode.name,
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

			// Phase 1: Running
			status, _ := pm.GetStatus(proxyID)
			if !status.Running {
				t.Fatal("Proxy should be running initially")
			}
			listenAddr := status.ListenAddr

			// Phase 2: Disable
			pm.DisableProxy(proxyID)
			time.Sleep(300 * time.Millisecond)

			status, _ = pm.GetStatus(proxyID)
			if status.Running {
				t.Fatal("Proxy should be stopped after disable")
			}

			// Phase 3: Re-enable
			enableResp, err := pm.EnableProxy(proxyID)
			if err != nil || !enableResp.Success {
				t.Fatalf("EnableProxy failed: %v", err)
			}
			time.Sleep(500 * time.Millisecond)

			status, _ = pm.GetStatus(proxyID)
			if !status.Running {
				t.Fatal("Proxy should be running after enable")
			}

			// Connection should work (address might change)
			if !modeTestConnection(t, status.ListenAddr, "ENABLE_DISABLE_OK") {
				t.Fatalf("Connection failed after re-enable. Old addr: %s, new addr: %s", listenAddr, status.ListenAddr)
			}
		})
	}
}

func TestMode_ProxyList(t *testing.T) {
	for _, mode := range testModes {
		t.Run(mode.name, func(t *testing.T) {
			setupMode(t, mode)

			backend, backendAddr := createEchoBackend(t, "LIST_OK")
			defer backend.Close()

			pm := node.NewProxyManagerWithBool(mode.useEmbedded)

			// Create multiple proxies
			var proxyIDs []string
			for i := 0; i < 3; i++ {
				resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
					Name:           fmt.Sprintf("test-list-%s-%d", mode.name, i),
					ListenAddr:     "127.0.0.1:0",
					DefaultBackend: backendAddr,
					DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
				})
				if err != nil || !resp.Success {
					t.Fatalf("CreateProxy %d failed: %v", i, err)
				}
				proxyIDs = append(proxyIDs, resp.ProxyId)
			}
			defer func() {
				for _, id := range proxyIDs {
					pm.DisableProxy(id)
				}
			}()

			time.Sleep(500 * time.Millisecond)

			// List all proxies
			statuses := pm.GetAllStatuses()
			if len(statuses) < 3 {
				t.Errorf("Expected at least 3 proxies, got %d", len(statuses))
			}

			// Verify all are running
			for _, id := range proxyIDs {
				status, _ := pm.GetStatus(id)
				if !status.Running {
					t.Errorf("Proxy %s should be running", id)
				}
			}
		})
	}
}

// ============================================================================
// Rule Tests
// ============================================================================

func TestMode_RuleAddRemove(t *testing.T) {
	for _, mode := range testModes {
		t.Run(mode.name, func(t *testing.T) {
			setupMode(t, mode)

			backend, backendAddr := createEchoBackend(t, "RULE_TEST_OK")
			defer backend.Close()

			pm := node.NewProxyManagerWithBool(mode.useEmbedded)

			resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
				Name:           "test-rule-" + mode.name,
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

			// Phase 1: Baseline - should allow
			if !modeTestConnection(t, listenAddr, "RULE_TEST_OK") {
				t.Fatal("Baseline connection failed")
			}

			// Phase 2: Add block rule
			_, err = pm.AddRule(&pb.AddRuleRequest{
				ProxyId: proxyID,
				Rule: &pb.Rule{
					Id:       "block-localhost",
					Name:     "Block Localhost",
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

			// Verify rule was added
			rules, _ := pm.GetRules(proxyID)
			found := false
			for _, r := range rules {
				if r.Id == "block-localhost" {
					found = true
					break
				}
			}
			if !found {
				t.Fatal("Rule not found after add")
			}

			// Connection should be blocked
			if modeTestConnection(t, listenAddr, "RULE_TEST_OK") {
				t.Fatal("Connection should be blocked")
			}

			// Phase 3: Remove rule
			pm.RemoveRule(&pb.RemoveRuleRequest{ProxyId: proxyID, RuleId: "block-localhost"})
			time.Sleep(200 * time.Millisecond)

			// Connection should work again
			if !modeTestConnection(t, listenAddr, "RULE_TEST_OK") {
				t.Fatal("Connection should work after removing rule")
			}
		})
	}
}

func TestMode_RuleList(t *testing.T) {
	for _, mode := range testModes {
		t.Run(mode.name, func(t *testing.T) {
			setupMode(t, mode)

			backend, backendAddr := createEchoBackend(t, "RULE_LIST_OK")
			defer backend.Close()

			pm := node.NewProxyManagerWithBool(mode.useEmbedded)

			resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
				Name:           "test-rulelist-" + mode.name,
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

			// Add multiple rules
			for i := 0; i < 3; i++ {
				pm.AddRule(&pb.AddRuleRequest{
					ProxyId: proxyID,
					Rule: &pb.Rule{
						Id:       fmt.Sprintf("rule-%d", i),
						Name:     fmt.Sprintf("Rule %d", i),
						Priority: int32(100 + i),
						Enabled:  true,
						Action:   common.ActionType_ACTION_TYPE_ALLOW,
						Conditions: []*pb.Condition{
							{
								Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
								Op:    common.Operator_OPERATOR_EQ,
								Value: fmt.Sprintf("10.0.0.%d", i),
							},
						},
					},
				})
			}

			time.Sleep(200 * time.Millisecond)

			// List rules
			rules, _ := pm.GetRules(proxyID)
			if len(rules) < 3 {
				t.Errorf("Expected at least 3 rules, got %d", len(rules))
			}

			// Verify all rules exist
			for i := 0; i < 3; i++ {
				found := false
				for _, r := range rules {
					if r.Id == fmt.Sprintf("rule-%d", i) {
						found = true
						break
					}
				}
				if !found {
					t.Errorf("Rule rule-%d not found", i)
				}
			}
		})
	}
}

func TestMode_RulePriority(t *testing.T) {
	for _, mode := range testModes {
		t.Run(mode.name, func(t *testing.T) {
			setupMode(t, mode)

			backend, backendAddr := createEchoBackend(t, "PRIORITY_OK")
			defer backend.Close()

			pm := node.NewProxyManagerWithBool(mode.useEmbedded)

			resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
				Name:           "test-priority-" + mode.name,
				ListenAddr:     "127.0.0.1:0",
				DefaultBackend: backendAddr,
				DefaultAction:  common.ActionType_ACTION_TYPE_BLOCK, // Default block
			})
			if err != nil || !resp.Success {
				t.Fatalf("CreateProxy failed: %v", err)
			}
			proxyID := resp.ProxyId
			defer pm.DisableProxy(proxyID)

			time.Sleep(500 * time.Millisecond)

			status, _ := pm.GetStatus(proxyID)
			listenAddr := status.ListenAddr

			// Default should block
			if modeTestConnection(t, listenAddr, "PRIORITY_OK") {
				t.Fatal("Default action should block")
			}

			// Add high priority allow rule
			pm.AddRule(&pb.AddRuleRequest{
				ProxyId: proxyID,
				Rule: &pb.Rule{
					Id:       "allow-high",
					Name:     "Allow High Priority",
					Priority: 1000, // High priority
					Enabled:  true,
					Action:   common.ActionType_ACTION_TYPE_ALLOW,
					Conditions: []*pb.Condition{
						{
							Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
							Op:    common.Operator_OPERATOR_CIDR,
							Value: "127.0.0.0/8",
						},
					},
				},
			})

			time.Sleep(200 * time.Millisecond)

			// Should allow now
			if !modeTestConnection(t, listenAddr, "PRIORITY_OK") {
				t.Fatal("High priority allow rule should take effect")
			}
		})
	}
}

// ============================================================================
// Connection Management Tests
// ============================================================================

func TestMode_GetActiveConnections(t *testing.T) {
	for _, mode := range testModes {
		t.Run(mode.name, func(t *testing.T) {
			setupMode(t, mode)

			backend, backendAddr := createLongLivedBackend(t)
			defer backend.Close()

			pm := node.NewProxyManagerWithBool(mode.useEmbedded)

			resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
				Name:           "test-conns-" + mode.name,
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

			// Create multiple connections
			var conns []net.Conn
			for i := 0; i < 3; i++ {
				conn, err := net.Dial("tcp", listenAddr)
				if err != nil {
					t.Fatalf("Failed to connect: %v", err)
				}
				conn.Write([]byte("test"))
				conns = append(conns, conn)
			}
			defer func() {
				for _, c := range conns {
					c.Close()
				}
			}()

			time.Sleep(300 * time.Millisecond)

			// Get active connections for specific proxy
			activeConns := pm.GetActiveConnections(proxyID)
			if len(activeConns) < 3 {
				t.Errorf("Expected at least 3 connections, got %d", len(activeConns))
			}

			// Verify each connection has metadata
			for _, c := range activeConns {
				if c.ID == "" {
					t.Error("Connection ID should not be empty")
				}
				if c.SourceIP == "" {
					t.Error("Connection SourceIP should not be empty")
				}
			}
		})
	}
}

func TestMode_GetAllActiveConnections(t *testing.T) {
	for _, mode := range testModes {
		t.Run(mode.name, func(t *testing.T) {
			setupMode(t, mode)

			backend1, backendAddr1 := createLongLivedBackend(t)
			backend2, backendAddr2 := createLongLivedBackend(t)
			defer backend1.Close()
			defer backend2.Close()

			pm := node.NewProxyManagerWithBool(mode.useEmbedded)

			// Create 2 proxies
			resp1, _ := pm.CreateProxy(&pb.CreateProxyRequest{
				Name:           "test-allconns-1-" + mode.name,
				ListenAddr:     "127.0.0.1:0",
				DefaultBackend: backendAddr1,
				DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
			})
			resp2, _ := pm.CreateProxy(&pb.CreateProxyRequest{
				Name:           "test-allconns-2-" + mode.name,
				ListenAddr:     "127.0.0.1:0",
				DefaultBackend: backendAddr2,
				DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
			})
			defer pm.DisableProxy(resp1.ProxyId)
			defer pm.DisableProxy(resp2.ProxyId)

			time.Sleep(500 * time.Millisecond)

			status1, _ := pm.GetStatus(resp1.ProxyId)
			status2, _ := pm.GetStatus(resp2.ProxyId)

			// Create connections to both proxies
			conn1, _ := net.Dial("tcp", status1.ListenAddr)
			conn2, _ := net.Dial("tcp", status2.ListenAddr)
			defer conn1.Close()
			defer conn2.Close()

			conn1.Write([]byte("test1"))
			conn2.Write([]byte("test2"))

			time.Sleep(300 * time.Millisecond)

			// Get all connections (empty proxyID)
			allConns := pm.GetActiveConnections("")
			if len(allConns) < 2 {
				t.Errorf("Expected at least 2 connections total, got %d", len(allConns))
			}
			t.Logf("Total connections from all proxies: %d", len(allConns))
		})
	}
}

func TestMode_CloseConnection(t *testing.T) {
	for _, mode := range testModes {
		t.Run(mode.name, func(t *testing.T) {
			setupMode(t, mode)

			backend, backendAddr := createLongLivedBackend(t)
			defer backend.Close()

			pm := node.NewProxyManagerWithBool(mode.useEmbedded)

			resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
				Name:           "test-closeconn-" + mode.name,
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

			// Create connection
			conn, err := net.Dial("tcp", listenAddr)
			if err != nil {
				t.Fatalf("Failed to connect: %v", err)
			}
			defer conn.Close()
			conn.Write([]byte("test"))

			time.Sleep(300 * time.Millisecond)

			// Get connection ID
			activeConns := pm.GetActiveConnections(proxyID)
			if len(activeConns) == 0 {
				t.Fatal("Expected at least 1 connection")
			}
			connID := activeConns[0].ID

			// Close specific connection
			err = pm.CloseConnection(proxyID, connID)
			if err != nil {
				t.Fatalf("CloseConnection failed: %v", err)
			}

			// Wait and retry to verify connection is gone (may take time to propagate)
			var connFound bool
			for attempt := 0; attempt < 10; attempt++ {
				time.Sleep(200 * time.Millisecond)
				activeConns = pm.GetActiveConnections(proxyID)
				connFound = false
				for _, c := range activeConns {
					if c.ID == connID {
						connFound = true
						break
					}
				}
				if !connFound {
					break
				}
			}
			if connFound {
				t.Error("Connection should have been closed")
			}
		})
	}
}

func TestMode_CloseAllConnections(t *testing.T) {
	for _, mode := range testModes {
		t.Run(mode.name, func(t *testing.T) {
			setupMode(t, mode)

			backend, backendAddr := createLongLivedBackend(t)
			defer backend.Close()

			pm := node.NewProxyManagerWithBool(mode.useEmbedded)

			resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
				Name:           "test-closeall-" + mode.name,
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

			// Create multiple connections
			var conns []net.Conn
			for i := 0; i < 3; i++ {
				conn, err := net.Dial("tcp", listenAddr)
				if err != nil {
					t.Fatalf("Failed to connect: %v", err)
				}
				conn.Write([]byte("test"))
				conns = append(conns, conn)
			}
			defer func() {
				for _, c := range conns {
					c.Close()
				}
			}()

			time.Sleep(300 * time.Millisecond)

			// Verify connections exist
			activeConns := pm.GetActiveConnections(proxyID)
			if len(activeConns) < 3 {
				t.Fatalf("Expected at least 3 connections, got %d", len(activeConns))
			}

			// Close all connections
			err = pm.CloseAllConnections(proxyID)
			if err != nil {
				t.Fatalf("CloseAllConnections failed: %v", err)
			}

			// Wait and retry to verify all connections are gone (may take time to propagate)
			var connCount int
			for attempt := 0; attempt < 10; attempt++ {
				time.Sleep(200 * time.Millisecond)
				activeConns = pm.GetActiveConnections(proxyID)
				connCount = len(activeConns)
				if connCount == 0 {
					break
				}
			}
			if connCount != 0 {
				t.Errorf("Expected 0 connections after closeall, got %d", connCount)
			}
		})
	}
}

// ============================================================================
// Metrics and Status Tests
// ============================================================================

func TestMode_GetStatus(t *testing.T) {
	for _, mode := range testModes {
		t.Run(mode.name, func(t *testing.T) {
			setupMode(t, mode)

			backend, backendAddr := createEchoBackend(t, "STATUS_OK")
			defer backend.Close()

			pm := node.NewProxyManagerWithBool(mode.useEmbedded)

			resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
				Name:           "test-status-" + mode.name,
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

			// Verify status fields
			if status.ProxyId != proxyID {
				t.Errorf("ProxyId mismatch: expected %s, got %s", proxyID, status.ProxyId)
			}
			if !status.Running {
				t.Error("Proxy should be running")
			}
			if status.ListenAddr == "" {
				t.Error("ListenAddr should not be empty")
			}
			if status.DefaultAction != common.ActionType_ACTION_TYPE_ALLOW {
				t.Errorf("DefaultAction should be ALLOW")
			}

			// Make some connections to update metrics
			for i := 0; i < 5; i++ {
				modeTestConnection(t, status.ListenAddr, "STATUS_OK")
			}

			time.Sleep(200 * time.Millisecond)

			// Check updated status
			status, _ = pm.GetStatus(proxyID)
			if status.TotalConnections < 5 {
				t.Errorf("Expected at least 5 total connections, got %d", status.TotalConnections)
			}
		})
	}
}

// ============================================================================
// Mock/Fallback Tests
// ============================================================================

func TestMode_MockFallback(t *testing.T) {
	for _, mode := range testModes {
		t.Run(mode.name, func(t *testing.T) {
			setupMode(t, mode)

			pm := node.NewProxyManagerWithBool(mode.useEmbedded)

			// Create proxy with unreachable backend and mock fallback
			resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
				Name:           "test-mock-" + mode.name,
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

			// Should receive mock response
			if !modeTestConnection(t, status.ListenAddr, "403") {
				t.Fatal("Should receive mock 403 response")
			}
		})
	}
}

// ============================================================================
// Concurrent Access Tests
// ============================================================================

func TestMode_ConcurrentConnections(t *testing.T) {
	for _, mode := range testModes {
		t.Run(mode.name, func(t *testing.T) {
			setupMode(t, mode)

			backend, backendAddr := createEchoBackend(t, "CONCURRENT_OK")
			defer backend.Close()

			pm := node.NewProxyManagerWithBool(mode.useEmbedded)

			resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
				Name:           "test-concurrent-" + mode.name,
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

			// Make concurrent connections
			var wg sync.WaitGroup
			results := make([]bool, 10)
			for i := 0; i < 10; i++ {
				wg.Add(1)
				go func(idx int) {
					defer wg.Done()
					results[idx] = modeTestConnection(t, listenAddr, "CONCURRENT_OK")
				}(i)
			}
			wg.Wait()

			// Verify all succeeded
			for i, ok := range results {
				if !ok {
					t.Errorf("Concurrent connection %d failed", i)
				}
			}
		})
	}
}

func TestMode_ConcurrentRuleModification(t *testing.T) {
	for _, mode := range testModes {
		t.Run(mode.name, func(t *testing.T) {
			setupMode(t, mode)

			backend, backendAddr := createEchoBackend(t, "CONC_RULE_OK")
			defer backend.Close()

			pm := node.NewProxyManagerWithBool(mode.useEmbedded)

			resp, err := pm.CreateProxy(&pb.CreateProxyRequest{
				Name:           "test-concrule-" + mode.name,
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

			// Concurrent rule add/remove
			var wg sync.WaitGroup
			for i := 0; i < 5; i++ {
				wg.Add(1)
				go func(idx int) {
					defer wg.Done()
					ruleID := fmt.Sprintf("conc-rule-%d", idx)
					pm.AddRule(&pb.AddRuleRequest{
						ProxyId: proxyID,
						Rule: &pb.Rule{
							Id:       ruleID,
							Name:     fmt.Sprintf("Concurrent Rule %d", idx),
							Priority: int32(100 + idx),
							Enabled:  true,
							Action:   common.ActionType_ACTION_TYPE_ALLOW,
							Conditions: []*pb.Condition{
								{
									Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
									Op:    common.Operator_OPERATOR_EQ,
									Value: fmt.Sprintf("10.0.0.%d", idx),
								},
							},
						},
					})
					time.Sleep(50 * time.Millisecond)
					pm.RemoveRule(&pb.RemoveRuleRequest{ProxyId: proxyID, RuleId: ruleID})
				}(i)
			}
			wg.Wait()

			// Should not crash, rules should be consistent
			rules, _ := pm.GetRules(proxyID)
			t.Logf("Final rule count: %d", len(rules))
		})
	}
}
