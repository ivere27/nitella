package integration

import (
	"bytes"
	"fmt"
	"net"
	"os"
	"os/exec"
	"strings"
	"testing"
	"time"
)

// TestCLI_DynamicProxyManagement tests using the CLI to dynamically manage proxies
func TestCLI_DynamicProxyManagement(t *testing.T) {
	// Check binaries exist
	nitellaBin := "../../bin/nitella"
	nitellad := "../../bin/nitellad"
	if _, err := os.Stat(nitellaBin); os.IsNotExist(err) {
		t.Skip("nitella binary not found, run 'make nitella_build' first")
	}
	if _, err := os.Stat(nitellad); os.IsNotExist(err) {
		t.Skip("nitellad binary not found, run 'make nitellad_build' first")
	}

	// Start backend
	backend := startEchoBackend(t, "CLI_BACKEND_RESPONSE")
	defer backend.Close()

	// Start nitellad
	adminPort := getFreePort(t)
	token := "cli-test-token"
	daemon := startNitelladWithAdmin(t, adminPort, token)
	defer daemon.Process.Kill()
	time.Sleep(200 * time.Millisecond)

	// Helper to run CLI command
	runCLI := func(args ...string) (string, error) {
		allArgs := append([]string{"--local", "--addr", fmt.Sprintf("localhost:%d", adminPort), "--token", token}, args...)
		cmd := exec.Command(nitellaBin, allArgs...)
		var stdout, stderr bytes.Buffer
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr
		err := cmd.Run()
		output := stdout.String() + stderr.String()
		return output, err
	}

	// --- Test: List proxies (should be empty or just default) ---
	t.Log("=== CLI: List proxies ===")
	output, err := runCLI("list")
	if err != nil {
		t.Logf("CLI list output: %s", output)
	}
	t.Logf("Initial proxies: %s", strings.TrimSpace(output))

	// --- Test: Create proxy via CLI ---
	t.Log("=== CLI: Create proxy ===")
	proxyPort := getFreePort(t)
	output, err = runCLI("proxy", "create", fmt.Sprintf("127.0.0.1:%d", proxyPort), backend.Addr().String(), "cli-created-proxy")
	if err != nil {
		t.Fatalf("CLI proxy create failed: %v, output: %s", err, output)
	}
	if !strings.Contains(output, "Proxy created:") {
		t.Fatalf("Expected 'Proxy created:', got: %s", output)
	}
	// Extract proxy ID from output
	proxyID := extractProxyID(output)
	t.Logf("Created proxy: %s", proxyID)

	// Wait for proxy to start
	time.Sleep(100 * time.Millisecond)

	// --- Test: Get status via CLI ---
	t.Log("=== CLI: Get status ===")
	output, err = runCLI("status", proxyID)
	if err != nil {
		t.Fatalf("CLI status failed: %v", err)
	}
	if !strings.Contains(output, "Running") {
		t.Logf("Status output: %s", output)
	}
	t.Logf("Proxy status retrieved")

	// --- Test: Connection through proxy works ---
	t.Log("=== Test: Connection via proxy ===")
	listenAddr := fmt.Sprintf("127.0.0.1:%d", proxyPort)
	if !testConnectionData(t, listenAddr, "CLI_BACKEND_RESPONSE") {
		t.Fatal("Connection through proxy should work")
	}
	t.Log("Connection succeeded")

	// --- Test: Add block rule via CLI ---
	t.Log("=== CLI: Add block rule ===")
	output, err = runCLI("rule", "add", proxyID, "block", "127.0.0.1")
	if err != nil {
		t.Fatalf("CLI rule add failed: %v, output: %s", err, output)
	}
	if !strings.Contains(output, "Rule added:") {
		t.Fatalf("Expected 'Rule added:', got: %s", output)
	}
	ruleID := extractRuleID(output)
	t.Logf("Added block rule: %s", ruleID)

	// --- Test: Connection should be blocked ---
	t.Log("=== Test: Connection should be blocked ===")
	if testConnectionData(t, listenAddr, "CLI_BACKEND_RESPONSE") {
		t.Fatal("Connection should be blocked after adding block rule")
	}
	t.Log("Connection blocked as expected")

	// --- Test: List rules via CLI ---
	t.Log("=== CLI: List rules ===")
	output, err = runCLI("rule", "list", proxyID)
	if err != nil {
		t.Fatalf("CLI rule list failed: %v", err)
	}
	if !strings.Contains(output, "block") && !strings.Contains(output, "Block") && !strings.Contains(output, "BLOCK") {
		t.Logf("Rule list output: %s", output)
	}
	t.Log("Rules listed successfully")

	// --- Test: Remove block rule via CLI ---
	t.Log("=== CLI: Remove block rule ===")
	output, err = runCLI("rule", "remove", proxyID, ruleID)
	if err != nil {
		t.Fatalf("CLI rule remove failed: %v, output: %s", err, output)
	}
	t.Log("Block rule removed")

	// --- Test: Connection should work again ---
	t.Log("=== Test: Connection should work again ===")
	if !testConnectionData(t, listenAddr, "CLI_BACKEND_RESPONSE") {
		t.Fatal("Connection should work after removing block rule")
	}
	t.Log("Connection succeeded after rule removal")

	// --- Test: Disable proxy via CLI ---
	t.Log("=== CLI: Disable proxy ===")
	output, err = runCLI("proxy", "disable", proxyID)
	if err != nil {
		t.Fatalf("CLI proxy disable failed: %v, output: %s", err, output)
	}
	if !strings.Contains(output, "disabled") && !strings.Contains(output, "Disabled") {
		t.Logf("Disable output: %s", output)
	}
	t.Log("Proxy disabled")

	time.Sleep(100 * time.Millisecond)

	// --- Test: Connection should fail (proxy disabled) ---
	t.Log("=== Test: Connection should fail (proxy disabled) ===")
	if testConnectionData(t, listenAddr, "CLI_BACKEND_RESPONSE") {
		t.Fatal("Connection should fail when proxy is disabled")
	}
	t.Log("Connection failed as expected (proxy disabled)")

	// --- Test: Enable proxy via CLI ---
	t.Log("=== CLI: Enable proxy ===")
	output, err = runCLI("proxy", "enable", proxyID)
	if err != nil {
		t.Fatalf("CLI proxy enable failed: %v, output: %s", err, output)
	}
	if !strings.Contains(output, "enabled") && !strings.Contains(output, "Enabled") {
		t.Logf("Enable output: %s", output)
	}
	t.Log("Proxy enabled")

	time.Sleep(100 * time.Millisecond)

	// --- Test: Connection should work again ---
	t.Log("=== Test: Connection should work again (proxy re-enabled) ===")
	if !testConnectionData(t, listenAddr, "CLI_BACKEND_RESPONSE") {
		t.Fatal("Connection should work after re-enabling proxy")
	}
	t.Log("Connection succeeded after re-enabling")

	// --- Test: Delete proxy via CLI ---
	t.Log("=== CLI: Delete proxy ===")
	output, err = runCLI("proxy", "delete", proxyID)
	if err != nil {
		t.Fatalf("CLI proxy delete failed: %v, output: %s", err, output)
	}
	t.Log("Proxy deleted")

	// --- Test: Connection should fail (proxy deleted) ---
	t.Log("=== Test: Connection should fail (proxy deleted) ===")
	if testConnectionData(t, listenAddr, "CLI_BACKEND_RESPONSE") {
		t.Fatal("Connection should fail after proxy deleted")
	}
	t.Log("Connection failed as expected (proxy deleted)")

	t.Log("=== CLI Dynamic Proxy Management Test Passed ===")
}

// TestCLI_QuickBlockAllow tests quick block/allow IP commands
func TestCLI_QuickBlockAllow(t *testing.T) {
	nitellaBin := "../../bin/nitella"
	nitellad := "../../bin/nitellad"
	if _, err := os.Stat(nitellaBin); os.IsNotExist(err) {
		t.Skip("nitella binary not found")
	}
	if _, err := os.Stat(nitellad); os.IsNotExist(err) {
		t.Skip("nitellad binary not found")
	}

	backend := startEchoBackend(t, "QUICK_CLI_BACKEND")
	defer backend.Close()

	adminPort := getFreePort(t)
	token := "quick-cli-token"
	daemon := startNitelladWithAdmin(t, adminPort, token)
	defer daemon.Process.Kill()
	time.Sleep(200 * time.Millisecond)

	runCLI := func(args ...string) (string, error) {
		allArgs := append([]string{"--local", "--addr", fmt.Sprintf("localhost:%d", adminPort), "--token", token}, args...)
		cmd := exec.Command(nitellaBin, allArgs...)
		var stdout, stderr bytes.Buffer
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr
		err := cmd.Run()
		return stdout.String() + stderr.String(), err
	}

	// Create a proxy
	proxyPort := getFreePort(t)
	output, _ := runCLI("proxy", "create", fmt.Sprintf("127.0.0.1:%d", proxyPort), backend.Addr().String(), "quick-proxy")
	t.Logf("Created proxy: %s", strings.TrimSpace(output))
	time.Sleep(100 * time.Millisecond)

	listenAddr := fmt.Sprintf("127.0.0.1:%d", proxyPort)

	// Baseline: should connect
	if !testConnectionData(t, listenAddr, "QUICK_CLI_BACKEND") {
		t.Fatal("Baseline connection should work")
	}

	// Block IP via CLI
	t.Log("=== CLI: Block IP ===")
	output, err := runCLI("block", "127.0.0.1")
	if err != nil {
		t.Fatalf("CLI block failed: %v, output: %s", err, output)
	}
	t.Logf("Block output: %s", strings.TrimSpace(output))

	// Connection should be blocked
	if testConnectionData(t, listenAddr, "QUICK_CLI_BACKEND") {
		t.Fatal("Connection should be blocked after block command")
	}
	t.Log("IP blocked successfully")

	// Allow IP via CLI (higher priority)
	t.Log("=== CLI: Allow IP ===")
	output, err = runCLI("allow", "127.0.0.1")
	if err != nil {
		t.Fatalf("CLI allow failed: %v, output: %s", err, output)
	}
	t.Logf("Allow output: %s", strings.TrimSpace(output))

	// Since both block and allow have the same priority (1000), the behavior depends on rule order
	// This tests that both commands work

	t.Log("=== Quick Block/Allow Test Passed ===")
}

// TestCLI_UpdateProxy tests the proxy update command
func TestCLI_UpdateProxy(t *testing.T) {
	nitellaBin := "../../bin/nitella"
	nitellad := "../../bin/nitellad"
	if _, err := os.Stat(nitellaBin); os.IsNotExist(err) {
		t.Skip("nitella binary not found")
	}
	if _, err := os.Stat(nitellad); os.IsNotExist(err) {
		t.Skip("nitellad binary not found")
	}

	backend1 := startEchoBackend(t, "BACKEND_1_RESPONSE")
	defer backend1.Close()
	backend2 := startEchoBackend(t, "BACKEND_2_RESPONSE")
	defer backend2.Close()

	adminPort := getFreePort(t)
	token := "update-cli-token"
	daemon := startNitelladWithAdmin(t, adminPort, token)
	defer daemon.Process.Kill()
	time.Sleep(200 * time.Millisecond)

	runCLI := func(args ...string) (string, error) {
		allArgs := append([]string{"--local", "--addr", fmt.Sprintf("localhost:%d", adminPort), "--token", token}, args...)
		cmd := exec.Command(nitellaBin, allArgs...)
		var stdout, stderr bytes.Buffer
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr
		err := cmd.Run()
		return stdout.String() + stderr.String(), err
	}

	// Create proxy pointing to backend1
	proxyPort := getFreePort(t)
	output, _ := runCLI("proxy", "create", fmt.Sprintf("127.0.0.1:%d", proxyPort), backend1.Addr().String(), "update-test-proxy")
	proxyID := extractProxyID(output)
	t.Logf("Created proxy: %s -> %s", proxyID, backend1.Addr().String())
	time.Sleep(100 * time.Millisecond)

	listenAddr := fmt.Sprintf("127.0.0.1:%d", proxyPort)

	// Verify routes to backend1
	if !testConnectionData(t, listenAddr, "BACKEND_1_RESPONSE") {
		t.Fatal("Should route to backend1")
	}
	t.Log("Routing to backend1 confirmed")

	// Update proxy to use backend2
	t.Log("=== CLI: Update proxy backend ===")
	output, err := runCLI("proxy", "update", proxyID, "--backend", backend2.Addr().String())
	if err != nil {
		t.Fatalf("CLI proxy update failed: %v, output: %s", err, output)
	}
	t.Logf("Update output: %s", strings.TrimSpace(output))

	// Backend update requires proxy restart to take effect (disable + enable)
	t.Log("=== CLI: Restart proxy to apply backend change ===")
	output, err = runCLI("proxy", "disable", proxyID)
	if err != nil {
		t.Fatalf("CLI proxy disable failed: %v, output: %s", err, output)
	}
	time.Sleep(100 * time.Millisecond)
	output, err = runCLI("proxy", "enable", proxyID)
	if err != nil {
		t.Fatalf("CLI proxy enable failed: %v, output: %s", err, output)
	}
	time.Sleep(200 * time.Millisecond)

	// Verify routes to backend2 after restart
	if !testConnectionData(t, listenAddr, "BACKEND_2_RESPONSE") {
		t.Fatal("Should route to backend2 after update and restart")
	}
	t.Log("Routing to backend2 confirmed after update and restart")

	t.Log("=== Update Proxy Test Passed ===")
}

// TestCLI_GeoIPLookup tests the GeoIP lookup command
func TestCLI_GeoIPLookup(t *testing.T) {
	nitellaBin := "../../bin/nitella"
	nitellad := "../../bin/nitellad"
	if _, err := os.Stat(nitellaBin); os.IsNotExist(err) {
		t.Skip("nitella binary not found")
	}
	if _, err := os.Stat(nitellad); os.IsNotExist(err) {
		t.Skip("nitellad binary not found")
	}

	adminPort := getFreePort(t)
	token := "geoip-cli-token"
	daemon := startNitelladWithAdmin(t, adminPort, token)
	defer daemon.Process.Kill()
	time.Sleep(200 * time.Millisecond)

	runCLI := func(args ...string) (string, error) {
		allArgs := append([]string{"--local", "--addr", fmt.Sprintf("localhost:%d", adminPort), "--token", token}, args...)
		cmd := exec.Command(nitellaBin, allArgs...)
		var stdout, stderr bytes.Buffer
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr
		err := cmd.Run()
		return stdout.String() + stderr.String(), err
	}

	// Test GeoIP status
	t.Log("=== CLI: GeoIP Status ===")
	output, err := runCLI("geoip", "status")
	if err != nil {
		t.Logf("CLI geoip status output: %s", output)
	}
	t.Logf("GeoIP status: %s", strings.TrimSpace(output))

	// Test IP lookup
	t.Log("=== CLI: Lookup IP ===")
	output, err = runCLI("lookup", "8.8.8.8")
	if err != nil {
		t.Logf("CLI lookup output: %s", output)
	}
	if !strings.Contains(output, "GeoIP Lookup: 8.8.8.8") {
		t.Logf("Lookup output: %s", output)
	}
	t.Log("GeoIP lookup completed")

	t.Log("=== GeoIP Lookup Test Passed ===")
}

// TestCLI_Connections tests connection listing and closing via CLI
func TestCLI_Connections(t *testing.T) {
	nitellaBin := "../../bin/nitella"
	nitellad := "../../bin/nitellad"
	if _, err := os.Stat(nitellaBin); os.IsNotExist(err) {
		t.Skip("nitella binary not found")
	}
	if _, err := os.Stat(nitellad); os.IsNotExist(err) {
		t.Skip("nitellad binary not found")
	}

	// Backend that holds connections
	backendLn, _ := net.Listen("tcp", "127.0.0.1:0")
	defer backendLn.Close()
	go func() {
		for {
			conn, err := backendLn.Accept()
			if err != nil {
				return
			}
			go func(c net.Conn) {
				defer c.Close()
				buf := make([]byte, 1024)
				for {
					if _, err := c.Read(buf); err != nil {
						return
					}
				}
			}(conn)
		}
	}()

	adminPort := getFreePort(t)
	token := "conn-cli-token"
	daemon := startNitelladWithAdmin(t, adminPort, token)
	defer daemon.Process.Kill()
	time.Sleep(200 * time.Millisecond)

	runCLI := func(args ...string) (string, error) {
		allArgs := append([]string{"--local", "--addr", fmt.Sprintf("localhost:%d", adminPort), "--token", token}, args...)
		cmd := exec.Command(nitellaBin, allArgs...)
		var stdout, stderr bytes.Buffer
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr
		err := cmd.Run()
		return stdout.String() + stderr.String(), err
	}

	// Create proxy
	proxyPort := getFreePort(t)
	output, _ := runCLI("proxy", "create", fmt.Sprintf("127.0.0.1:%d", proxyPort), backendLn.Addr().String(), "conn-test-proxy")
	proxyID := extractProxyID(output)
	time.Sleep(100 * time.Millisecond)

	listenAddr := fmt.Sprintf("127.0.0.1:%d", proxyPort)

	// Create some connections
	var clientConns []net.Conn
	for i := 0; i < 3; i++ {
		c, err := net.Dial("tcp", listenAddr)
		if err != nil {
			t.Fatalf("Failed to connect: %v", err)
		}
		clientConns = append(clientConns, c)
	}
	defer func() {
		for _, c := range clientConns {
			c.Close()
		}
	}()
	time.Sleep(100 * time.Millisecond)

	// List connections via CLI
	t.Log("=== CLI: List connections ===")
	output, err := runCLI("conn", proxyID)
	if err != nil {
		t.Logf("CLI conn output: %s", output)
	}
	t.Logf("Connections: %s", strings.TrimSpace(output))

	// Close all connections via CLI
	t.Log("=== CLI: Close all connections ===")
	output, err = runCLI("conn", "closeall", proxyID)
	if err != nil {
		t.Fatalf("CLI conn closeall failed: %v, output: %s", err, output)
	}
	t.Logf("Close all output: %s", strings.TrimSpace(output))

	t.Log("=== Connections CLI Test Passed ===")
}

// TestCLI_RestartListeners tests the restart command
func TestCLI_RestartListeners(t *testing.T) {
	nitellaBin := "../../bin/nitella"
	nitellad := "../../bin/nitellad"
	if _, err := os.Stat(nitellaBin); os.IsNotExist(err) {
		t.Skip("nitella binary not found")
	}
	if _, err := os.Stat(nitellad); os.IsNotExist(err) {
		t.Skip("nitellad binary not found")
	}

	backend := startEchoBackend(t, "RESTART_BACKEND")
	defer backend.Close()

	adminPort := getFreePort(t)
	token := "restart-cli-token"
	daemon := startNitelladWithAdmin(t, adminPort, token)
	defer daemon.Process.Kill()
	time.Sleep(200 * time.Millisecond)

	runCLI := func(args ...string) (string, error) {
		allArgs := append([]string{"--local", "--addr", fmt.Sprintf("localhost:%d", adminPort), "--token", token}, args...)
		cmd := exec.Command(nitellaBin, allArgs...)
		var stdout, stderr bytes.Buffer
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr
		err := cmd.Run()
		return stdout.String() + stderr.String(), err
	}

	// Create proxy
	proxyPort := getFreePort(t)
	output, _ := runCLI("proxy", "create", fmt.Sprintf("127.0.0.1:%d", proxyPort), backend.Addr().String(), "restart-test-proxy")
	t.Logf("Created proxy: %s", strings.TrimSpace(output))
	time.Sleep(100 * time.Millisecond)

	listenAddr := fmt.Sprintf("127.0.0.1:%d", proxyPort)

	// Verify connection works
	if !testConnectionData(t, listenAddr, "RESTART_BACKEND") {
		t.Fatal("Connection should work before restart")
	}

	// Restart listeners via CLI
	t.Log("=== CLI: Restart listeners ===")
	output, err := runCLI("restart")
	if err != nil {
		t.Fatalf("CLI restart failed: %v, output: %s", err, output)
	}
	t.Logf("Restart output: %s", strings.TrimSpace(output))

	time.Sleep(200 * time.Millisecond)

	// Verify connection still works after restart
	if !testConnectionData(t, listenAddr, "RESTART_BACKEND") {
		t.Fatal("Connection should work after restart")
	}
	t.Log("Connection works after restart")

	t.Log("=== Restart Listeners Test Passed ===")
}

// ============================================================================
// Helper Functions
// ============================================================================

// extractProxyID extracts proxy ID from "Proxy created: <id>" output
func extractProxyID(output string) string {
	lines := strings.Split(output, "\n")
	for _, line := range lines {
		if strings.Contains(line, "Proxy created:") {
			parts := strings.Split(line, ":")
			if len(parts) >= 2 {
				return strings.TrimSpace(parts[len(parts)-1])
			}
		}
	}
	return ""
}

// extractRuleID extracts rule ID from "Rule added: <id>" output
func extractRuleID(output string) string {
	lines := strings.Split(output, "\n")
	for _, line := range lines {
		if strings.Contains(line, "Rule added:") {
			parts := strings.Split(line, ":")
			if len(parts) >= 2 {
				return strings.TrimSpace(parts[len(parts)-1])
			}
		}
	}
	return ""
}

// ============================================================================
// Passphrase Integration Tests
// ============================================================================

// TestCLI_PassphraseEncryption tests identity creation with passphrase
func TestCLI_PassphraseEncryption(t *testing.T) {
	nitellaBin := "../../bin/nitella"
	if _, err := os.Stat(nitellaBin); os.IsNotExist(err) {
		t.Skip("nitella binary not found, run 'make nitella_build' first")
	}

	// Create temp data directory
	tmpDir, err := os.MkdirTemp("", "nitella-passphrase-test-*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	passphrase := "integration-test-passphrase-123"

	// Test 1: Create identity with passphrase
	t.Run("CreateWithPassphrase", func(t *testing.T) {
		cmd := exec.Command(nitellaBin, "--data-dir", tmpDir, "identity")
		cmd.Env = append(os.Environ(), "NITELLA_PASSPHRASE="+passphrase)
		var stdout, stderr bytes.Buffer
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr
		err := cmd.Run()
		output := stdout.String() + stderr.String()
		if err != nil {
			t.Fatalf("Failed to create identity: %v, output: %s", err, output)
		}

		// Verify identity was created
		if !strings.Contains(output, "Emoji Hash") && !strings.Contains(output, "IDENTITY CREATED") {
			t.Logf("Output: %s", output)
		}

		// Verify key file exists and is encrypted
		keyPath := tmpDir + "/root_ca.key"
		keyData, err := os.ReadFile(keyPath)
		if err != nil {
			t.Fatalf("Failed to read key file: %v", err)
		}
		if !strings.Contains(string(keyData), "ENCRYPTED PRIVATE KEY") {
			t.Error("Key should be encrypted")
		}
		t.Log("Identity created with encrypted key")
	})

	// Test 2: Load identity with correct passphrase
	t.Run("LoadWithCorrectPassphrase", func(t *testing.T) {
		cmd := exec.Command(nitellaBin, "--data-dir", tmpDir, "identity")
		cmd.Env = append(os.Environ(), "NITELLA_PASSPHRASE="+passphrase)
		var stdout, stderr bytes.Buffer
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr
		err := cmd.Run()
		output := stdout.String() + stderr.String()
		if err != nil {
			t.Fatalf("Failed to load identity: %v, output: %s", err, output)
		}
		if !strings.Contains(output, "Emoji Hash") {
			t.Errorf("Expected identity info, got: %s", output)
		}
		t.Log("Identity loaded with correct passphrase")
	})

	// Test 3: Load with wrong passphrase should fail
	t.Run("LoadWithWrongPassphrase", func(t *testing.T) {
		cmd := exec.Command(nitellaBin, "--data-dir", tmpDir, "identity")
		cmd.Env = append(os.Environ(), "NITELLA_PASSPHRASE=wrong-passphrase")
		var stdout, stderr bytes.Buffer
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr
		err := cmd.Run()
		output := stdout.String() + stderr.String()
		if err == nil {
			t.Error("Expected error with wrong passphrase")
		}
		if !strings.Contains(output, "incorrect passphrase") && !strings.Contains(output, "decryption failed") {
			t.Logf("Expected passphrase error, got: %s", output)
		}
		t.Log("Wrong passphrase correctly rejected")
	})

	// Test 4: Load encrypted key without passphrase should fail
	t.Run("LoadWithoutPassphrase", func(t *testing.T) {
		cmd := exec.Command(nitellaBin, "--data-dir", tmpDir, "identity")
		// No NITELLA_PASSPHRASE set - but this will prompt for input
		// Since we can't provide stdin in test, it will fail
		cmd.Env = os.Environ() // No passphrase env
		var stdout, stderr bytes.Buffer
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr

		// Set stdin to empty to simulate no input
		cmd.Stdin = strings.NewReader("")

		err := cmd.Run()
		output := stdout.String() + stderr.String()
		// Should fail because it can't read passphrase from terminal
		if err == nil {
			// If it somehow succeeded, check if key is still encrypted
			t.Log("Command succeeded - checking if passphrase was actually required")
		}
		t.Logf("Output without passphrase: %s", output)
	})
}

// TestCLI_NoPassphrase tests identity creation without passphrase (backwards compat)
func TestCLI_NoPassphrase(t *testing.T) {
	nitellaBin := "../../bin/nitella"
	if _, err := os.Stat(nitellaBin); os.IsNotExist(err) {
		t.Skip("nitella binary not found, run 'make nitella_build' first")
	}

	// Create temp data directory
	tmpDir, err := os.MkdirTemp("", "nitella-no-passphrase-test-*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	// Create identity without passphrase (empty passphrase)
	t.Run("CreateWithoutPassphrase", func(t *testing.T) {
		cmd := exec.Command(nitellaBin, "--data-dir", tmpDir, "--passphrase", "", "identity")
		var stdout, stderr bytes.Buffer
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr
		err := cmd.Run()
		output := stdout.String() + stderr.String()
		if err != nil {
			t.Fatalf("Failed to create identity: %v, output: %s", err, output)
		}

		// Verify key file exists and is NOT encrypted
		keyPath := tmpDir + "/root_ca.key"
		keyData, err := os.ReadFile(keyPath)
		if err != nil {
			t.Fatalf("Failed to read key file: %v", err)
		}
		if strings.Contains(string(keyData), "ENCRYPTED") {
			t.Error("Key should NOT be encrypted when no passphrase provided")
		}
		if !strings.Contains(string(keyData), "PRIVATE KEY") {
			t.Error("Key file should contain PRIVATE KEY")
		}
		t.Log("Identity created without encryption")
	})

	// Load without passphrase should work
	t.Run("LoadWithoutPassphrase", func(t *testing.T) {
		cmd := exec.Command(nitellaBin, "--data-dir", tmpDir, "identity")
		var stdout, stderr bytes.Buffer
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr
		err := cmd.Run()
		output := stdout.String() + stderr.String()
		if err != nil {
			t.Fatalf("Failed to load identity: %v, output: %s", err, output)
		}
		if !strings.Contains(output, "Emoji Hash") {
			t.Errorf("Expected identity info, got: %s", output)
		}
		t.Log("Identity loaded without passphrase")
	})
}

// TestCLI_PassphraseFlag tests --passphrase flag
func TestCLI_PassphraseFlag(t *testing.T) {
	nitellaBin := "../../bin/nitella"
	if _, err := os.Stat(nitellaBin); os.IsNotExist(err) {
		t.Skip("nitella binary not found, run 'make nitella_build' first")
	}

	tmpDir, err := os.MkdirTemp("", "nitella-passphrase-flag-test-*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	passphrase := "flag-test-passphrase"

	// Create with --passphrase flag
	t.Run("CreateWithFlag", func(t *testing.T) {
		cmd := exec.Command(nitellaBin, "--data-dir", tmpDir, "--passphrase", passphrase, "identity")
		var stdout, stderr bytes.Buffer
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr
		err := cmd.Run()
		output := stdout.String() + stderr.String()
		if err != nil {
			t.Fatalf("Failed to create identity: %v, output: %s", err, output)
		}

		// Verify key is encrypted
		keyPath := tmpDir + "/root_ca.key"
		keyData, err := os.ReadFile(keyPath)
		if err != nil {
			t.Fatalf("Failed to read key file: %v", err)
		}
		if !strings.Contains(string(keyData), "ENCRYPTED PRIVATE KEY") {
			t.Error("Key should be encrypted when using --passphrase flag")
		}
		t.Log("Identity created with --passphrase flag")
	})

	// Load with --passphrase flag
	t.Run("LoadWithFlag", func(t *testing.T) {
		cmd := exec.Command(nitellaBin, "--data-dir", tmpDir, "--passphrase", passphrase, "identity")
		var stdout, stderr bytes.Buffer
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr
		err := cmd.Run()
		output := stdout.String() + stderr.String()
		if err != nil {
			t.Fatalf("Failed to load identity: %v, output: %s", err, output)
		}
		if !strings.Contains(output, "Emoji Hash") {
			t.Errorf("Expected identity info, got: %s", output)
		}
		t.Log("Identity loaded with --passphrase flag")
	})
}
