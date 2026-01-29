package integration

import (
	"fmt"
	"io"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
	"time"
)

const nitellaBinPath = "../../bin/nitellad"

// TestProxyStandaloneMode tests nitellad with --listen and --backend flags
func TestProxyStandaloneMode(t *testing.T) {
	wd, _ := os.Getwd()
	nitellaBin := filepath.Join(wd, nitellaBinPath)
	mockBin := filepath.Join(wd, mockBinPath)

	// Verify binaries exist
	if _, err := os.Stat(nitellaBin); os.IsNotExist(err) {
		t.Fatalf("nitellad binary not found at %s. Run 'make build' first.", nitellaBin)
	}
	if _, err := os.Stat(mockBin); os.IsNotExist(err) {
		t.Fatalf("mock binary not found at %s. Run 'make build' first.", mockBin)
	}

	// 1. Start Mock Backend (HTTP mode)
	backendPort := getFreePort(t)
	mockCmd := exec.Command(mockBin, "-port", fmt.Sprintf("%d", backendPort), "-protocol", "http")
	mockCmd.Stdout = os.Stdout
	mockCmd.Stderr = os.Stderr
	if err := mockCmd.Start(); err != nil {
		t.Fatalf("Failed to start mock server: %v", err)
	}
	defer func() {
		if mockCmd.Process != nil {
			mockCmd.Process.Kill()
		}
	}()
	time.Sleep(200 * time.Millisecond)

	// 2. Start Nitellad Proxy (with temp database to avoid conflicts)
	proxyPort := getFreePort(t)
	tempDir := t.TempDir()
	proxyCmd := exec.Command(nitellaBin,
		"--listen", fmt.Sprintf("127.0.0.1:%d", proxyPort),
		"--backend", fmt.Sprintf("127.0.0.1:%d", backendPort),
		"--db-path", filepath.Join(tempDir, "nitella.db"),
		"--stats-db", filepath.Join(tempDir, "stats.db"),
	)
	proxyCmd.Stdout = os.Stdout
	proxyCmd.Stderr = os.Stderr
	if err := proxyCmd.Start(); err != nil {
		t.Fatalf("Failed to start nitellad: %v", err)
	}
	defer func() {
		if proxyCmd.Process != nil {
			proxyCmd.Process.Kill()
		}
	}()
	time.Sleep(200 * time.Millisecond)

	// 3. Test Connection through proxy
	listenAddr := fmt.Sprintf("127.0.0.1:%d", proxyPort)
	if !testConnection(t, listenAddr, "HTTP/1.1 200 OK") {
		t.Fatal("Connection through proxy failed")
	}

	t.Log("Standalone mode proxy test passed")
}

// TestProxyToSSHMock tests proxy forwarding to SSH mock server
func TestProxyToSSHMock(t *testing.T) {
	wd, _ := os.Getwd()
	nitellaBin := filepath.Join(wd, nitellaBinPath)
	mockBin := filepath.Join(wd, mockBinPath)

	if _, err := os.Stat(nitellaBin); os.IsNotExist(err) {
		t.Skipf("nitellad binary not found")
	}
	if _, err := os.Stat(mockBin); os.IsNotExist(err) {
		t.Skipf("mock binary not found")
	}

	// 1. Start SSH Mock Backend
	backendPort := getFreePort(t)
	mockCmd := exec.Command(mockBin, "-port", fmt.Sprintf("%d", backendPort), "-protocol", "ssh")
	if err := mockCmd.Start(); err != nil {
		t.Fatalf("Failed to start mock SSH server: %v", err)
	}
	defer func() {
		if mockCmd.Process != nil {
			mockCmd.Process.Kill()
		}
	}()
	time.Sleep(200 * time.Millisecond)

	// 2. Start Nitellad Proxy (with temp database)
	proxyPort := getFreePort(t)
	tempDir := t.TempDir()
	proxyCmd := exec.Command(nitellaBin,
		"--listen", fmt.Sprintf("127.0.0.1:%d", proxyPort),
		"--backend", fmt.Sprintf("127.0.0.1:%d", backendPort),
		"--db-path", filepath.Join(tempDir, "nitella.db"),
		"--stats-db", filepath.Join(tempDir, "stats.db"),
	)
	if err := proxyCmd.Start(); err != nil {
		t.Fatalf("Failed to start nitellad: %v", err)
	}
	defer func() {
		if proxyCmd.Process != nil {
			proxyCmd.Process.Kill()
		}
	}()
	time.Sleep(200 * time.Millisecond)

	// 3. Test SSH Banner
	listenAddr := fmt.Sprintf("127.0.0.1:%d", proxyPort)
	if !testConnection(t, listenAddr, "SSH-2.0-OpenSSH") {
		t.Fatal("Did not receive SSH banner through proxy")
	}

	t.Log("SSH mock proxy test passed")
}

// TestProxyWithYAMLConfig tests nitellad with config file
func TestProxyWithYAMLConfig(t *testing.T) {
	wd, _ := os.Getwd()
	nitellaBin := filepath.Join(wd, nitellaBinPath)
	mockBin := filepath.Join(wd, mockBinPath)

	if _, err := os.Stat(nitellaBin); os.IsNotExist(err) {
		t.Skipf("nitellad binary not found")
	}
	if _, err := os.Stat(mockBin); os.IsNotExist(err) {
		t.Skipf("mock binary not found")
	}

	// 1. Start Mock Backend
	backendPort := getFreePort(t)
	mockCmd := exec.Command(mockBin, "-port", fmt.Sprintf("%d", backendPort), "-protocol", "http")
	if err := mockCmd.Start(); err != nil {
		t.Fatalf("Failed to start mock server: %v", err)
	}
	defer func() {
		if mockCmd.Process != nil {
			mockCmd.Process.Kill()
		}
	}()
	time.Sleep(200 * time.Millisecond)

	// 2. Create temp config file
	proxyPort := getFreePort(t)
	configContent := fmt.Sprintf(`
entryPoints:
  web:
    address: "127.0.0.1:%d"
    defaultAction: allow

tcp:
  routers:
    web-router:
      entryPoints: ["web"]
      rule: "HostSNI(*)"
      service: backend-svc

  services:
    backend-svc:
      address: "127.0.0.1:%d"
`, proxyPort, backendPort)

	tmpFile, err := os.CreateTemp("", "nitella_test_*.yaml")
	if err != nil {
		t.Fatalf("Failed to create temp config: %v", err)
	}
	defer os.Remove(tmpFile.Name())

	if _, err := tmpFile.WriteString(configContent); err != nil {
		t.Fatalf("Failed to write config: %v", err)
	}
	tmpFile.Close()

	// 3. Start Nitellad with config (use temp database)
	tempDir := t.TempDir()
	proxyCmd := exec.Command(nitellaBin,
		"--config", tmpFile.Name(),
		"--db-path", filepath.Join(tempDir, "nitella.db"),
		"--stats-db", filepath.Join(tempDir, "stats.db"),
	)
	proxyCmd.Stdout = os.Stdout
	proxyCmd.Stderr = os.Stderr
	if err := proxyCmd.Start(); err != nil {
		t.Fatalf("Failed to start nitellad: %v", err)
	}
	defer func() {
		if proxyCmd.Process != nil {
			proxyCmd.Process.Kill()
		}
	}()
	time.Sleep(200 * time.Millisecond)

	// 4. Test connection
	listenAddr := fmt.Sprintf("127.0.0.1:%d", proxyPort)
	if !testConnection(t, listenAddr, "HTTP/1.1 200 OK") {
		t.Fatal("Connection through YAML-configured proxy failed")
	}

	t.Log("YAML config proxy test passed")
}

// TestMultipleClients tests multiple concurrent clients
func TestMultipleClients(t *testing.T) {
	wd, _ := os.Getwd()
	nitellaBin := filepath.Join(wd, nitellaBinPath)
	mockBin := filepath.Join(wd, mockBinPath)

	if _, err := os.Stat(nitellaBin); os.IsNotExist(err) {
		t.Skipf("nitellad binary not found")
	}
	if _, err := os.Stat(mockBin); os.IsNotExist(err) {
		t.Skipf("mock binary not found")
	}

	// 1. Start Mock Backend
	backendPort := getFreePort(t)
	mockCmd := exec.Command(mockBin, "-port", fmt.Sprintf("%d", backendPort), "-protocol", "http")
	if err := mockCmd.Start(); err != nil {
		t.Fatalf("Failed to start mock server: %v", err)
	}
	defer func() {
		if mockCmd.Process != nil {
			mockCmd.Process.Kill()
		}
	}()
	time.Sleep(200 * time.Millisecond)

	// 2. Start Nitellad Proxy (with temp database)
	proxyPort := getFreePort(t)
	tempDir := t.TempDir()
	proxyCmd := exec.Command(nitellaBin,
		"--listen", fmt.Sprintf("127.0.0.1:%d", proxyPort),
		"--backend", fmt.Sprintf("127.0.0.1:%d", backendPort),
		"--db-path", filepath.Join(tempDir, "nitella.db"),
		"--stats-db", filepath.Join(tempDir, "stats.db"),
	)
	if err := proxyCmd.Start(); err != nil {
		t.Fatalf("Failed to start nitellad: %v", err)
	}
	defer func() {
		if proxyCmd.Process != nil {
			proxyCmd.Process.Kill()
		}
	}()
	time.Sleep(200 * time.Millisecond)

	// 3. Multiple concurrent clients
	listenAddr := fmt.Sprintf("127.0.0.1:%d", proxyPort)
	numClients := 20
	results := make(chan bool, numClients)

	for i := 0; i < numClients; i++ {
		go func(id int) {
			success := testConnection(t, listenAddr, "HTTP/1.1 200 OK")
			if !success {
				t.Logf("Client %d failed", id)
			}
			results <- success
		}(i)
	}

	// Wait for all clients
	successCount := 0
	for i := 0; i < numClients; i++ {
		if <-results {
			successCount++
		}
	}

	if successCount != numClients {
		t.Fatalf("Only %d/%d clients succeeded", successCount, numClients)
	}

	t.Logf("Multiple clients test passed (%d clients)", numClients)
}

// testConnection connects to addr and checks if response contains expected substring.
func testConnection(t *testing.T, addr string, expected string) bool {
	conn, err := net.DialTimeout("tcp", addr, 5*time.Second)
	if err != nil {
		return false
	}
	defer conn.Close()

	conn.SetReadDeadline(time.Now().Add(5 * time.Second))

	data, _ := io.ReadAll(conn)
	return strings.Contains(string(data), expected)
}
