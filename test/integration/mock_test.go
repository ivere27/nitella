package integration

import (
	"bufio"
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

const mockBinPath = "../../bin/mock"

// =============================================================================
// Basic Protocol Tests
// =============================================================================

func TestMock_HTTP(t *testing.T) {
	port := getFreePort(t)
	cmd := startMockServer(t, port, "http")
	defer stopMockServer(cmd)

	conn := dialWithRetry(t, port, 3)
	defer conn.Close()

	_, err := conn.Write([]byte("GET / HTTP/1.1\r\nHost: test\r\n\r\n"))
	if err != nil {
		t.Fatalf("Failed to send request: %v", err)
	}

	response := readFullResponse(t, conn)

	if !strings.Contains(response, "HTTP/1.1 200 OK") {
		t.Errorf("Expected HTTP 200 OK, got: %s", truncate(response, 200))
	}
	if !strings.Contains(response, "It works!") {
		t.Errorf("Expected default body")
	}
	if !strings.Contains(response, "Server: nginx") {
		t.Errorf("Expected nginx server header")
	}
}

func TestMock_SSH(t *testing.T) {
	port := getFreePort(t)
	cmd := startMockServer(t, port, "ssh")
	defer stopMockServer(cmd)

	conn := dialWithRetry(t, port, 3)
	defer conn.Close()

	response := readResponse(t, conn)

	if !strings.HasPrefix(response, "SSH-2.0-OpenSSH") {
		t.Errorf("Expected SSH-2.0 banner, got: %s", truncate(response, 100))
	}
	if !strings.Contains(response, "Ubuntu") {
		t.Errorf("Expected Ubuntu in banner")
	}
}

func TestMock_MySQL(t *testing.T) {
	port := getFreePort(t)
	cmd := startMockServer(t, port, "mysql")
	defer stopMockServer(cmd)

	conn := dialWithRetry(t, port, 3)
	defer conn.Close()

	buf := make([]byte, 1024)
	conn.SetReadDeadline(time.Now().Add(3 * time.Second))
	n, err := conn.Read(buf)
	if err != nil {
		t.Fatalf("Failed to read MySQL handshake: %v", err)
	}

	// Check protocol version (byte 4 should be 0x0a = MySQL 10)
	if n < 5 {
		t.Fatalf("MySQL response too short: %d bytes", n)
	}
	if buf[4] != 0x0a {
		t.Errorf("Expected MySQL protocol version 0x0a, got: 0x%x", buf[4])
	}

	// Check server version string
	if !strings.Contains(string(buf[5:n]), "5.7") {
		t.Errorf("Expected MySQL 5.7 version")
	}
}

func TestMock_Redis(t *testing.T) {
	port := getFreePort(t)
	cmd := startMockServer(t, port, "redis")
	defer stopMockServer(cmd)

	conn := dialWithRetry(t, port, 3)
	defer conn.Close()

	// Redis waits for client command first
	_, err := conn.Write([]byte("PING\r\n"))
	if err != nil {
		t.Fatalf("Failed to send PING: %v", err)
	}

	response := readResponse(t, conn)

	if !strings.Contains(response, "-NOAUTH") {
		t.Errorf("Expected NOAUTH response, got: %s", truncate(response, 100))
	}
}

func TestMock_SMTP(t *testing.T) {
	port := getFreePort(t)
	cmd := startMockServer(t, port, "smtp")
	defer stopMockServer(cmd)

	conn := dialWithRetry(t, port, 3)
	defer conn.Close()

	reader := bufio.NewReader(conn)

	// Read banner
	banner, err := reader.ReadString('\n')
	if err != nil {
		t.Fatalf("Failed to read SMTP banner: %v", err)
	}
	if !strings.HasPrefix(banner, "220 ") {
		t.Errorf("Expected 220 banner, got: %s", truncate(banner, 100))
	}

	// Send EHLO
	conn.Write([]byte("EHLO test.local\r\n"))

	// Read EHLO response (multiline)
	var ehloResp strings.Builder
	for {
		line, err := reader.ReadString('\n')
		if err != nil {
			break
		}
		ehloResp.WriteString(line)
		if len(line) >= 4 && line[3] == ' ' {
			break
		}
	}
	if !strings.Contains(ehloResp.String(), "250") {
		t.Errorf("Expected 250 response")
	}
	if !strings.Contains(ehloResp.String(), "AUTH") {
		t.Errorf("Expected AUTH capability")
	}

	// Send QUIT
	conn.Write([]byte("QUIT\r\n"))
	quitResp, _ := reader.ReadString('\n')
	if !strings.HasPrefix(quitResp, "221 ") {
		t.Errorf("Expected 221 goodbye, got: %s", truncate(quitResp, 50))
	}
}

func TestMock_Telnet(t *testing.T) {
	port := getFreePort(t)
	cmd := startMockServer(t, port, "telnet")
	defer stopMockServer(cmd)

	conn := dialWithRetry(t, port, 3)
	defer conn.Close()

	response := readFullResponse(t, conn)

	// Check for IAC byte (0xff) - telnet negotiation
	if len(response) == 0 || response[0] != 0xff {
		t.Errorf("Expected telnet negotiation (IAC)")
	}

	// Check for login prompt
	if !strings.Contains(response, "Username:") {
		t.Logf("Username prompt may be delayed, got: %d bytes", len(response))
	}
}

func TestMock_RDP(t *testing.T) {
	port := getFreePort(t)
	cmd := startMockServer(t, port, "rdp")
	defer stopMockServer(cmd)

	conn := dialWithRetry(t, port, 3)
	defer conn.Close()

	buf := make([]byte, 256)
	conn.SetReadDeadline(time.Now().Add(3 * time.Second))
	n, err := conn.Read(buf)
	if err != nil && err != io.EOF {
		t.Fatalf("Failed to read RDP response: %v", err)
	}

	// TPKT header: version 3
	if n < 4 || buf[0] != 0x03 {
		t.Errorf("Expected TPKT version 3, got: 0x%x", buf[0])
	}

	// Check length matches
	length := int(buf[2])<<8 | int(buf[3])
	if n != length {
		t.Errorf("TPKT length mismatch: header=%d, actual=%d", length, n)
	}
}

func TestMock_MSSQL(t *testing.T) {
	port := getFreePort(t)
	cmd := startMockServer(t, port, "mssql")
	defer stopMockServer(cmd)

	conn := dialWithRetry(t, port, 3)
	defer conn.Close()

	buf := make([]byte, 256)
	conn.SetReadDeadline(time.Now().Add(3 * time.Second))
	n, err := conn.Read(buf)
	if err != nil && err != io.EOF {
		t.Fatalf("Failed to read MSSQL response: %v", err)
	}

	// TDS packet type 0x04 = response
	if n < 8 || buf[0] != 0x04 {
		t.Errorf("Expected TDS type 0x04, got: 0x%x", buf[0])
	}

	// Check length matches
	length := int(buf[2])<<8 | int(buf[3])
	if n != length {
		t.Errorf("TDS length mismatch: header=%d, actual=%d", length, n)
	}
}

// =============================================================================
// Feature Tests
// =============================================================================

func TestMock_CustomPayload(t *testing.T) {
	port := getFreePort(t)
	cmd := startMockServerWithArgs(t, port, "http", "-payload", "Honeypot Active")
	defer stopMockServer(cmd)

	conn := dialWithRetry(t, port, 3)
	defer conn.Close()

	conn.Write([]byte("GET / HTTP/1.1\r\n\r\n"))
	response := readFullResponse(t, conn)

	if !strings.Contains(response, "Honeypot Active") {
		t.Errorf("Expected custom payload in response")
	}
}

func TestMock_Delay(t *testing.T) {
	port := getFreePort(t)
	cmd := startMockServerWithArgs(t, port, "http", "-delay", "200")
	defer stopMockServer(cmd)

	conn := dialWithRetry(t, port, 3)
	defer conn.Close()

	start := time.Now()
	conn.Write([]byte("GET / HTTP/1.1\r\n\r\n"))
	readFullResponse(t, conn)
	elapsed := time.Since(start)

	if elapsed < 200*time.Millisecond {
		t.Errorf("Expected at least 200ms delay, got: %v", elapsed)
	}
}

func TestMock_DripMode(t *testing.T) {
	port := getFreePort(t)
	// 50ms per byte, short banner
	cmd := startMockServerWithArgs(t, port, "ssh", "-drip", "50")
	defer stopMockServer(cmd)

	conn := dialWithRetry(t, port, 3)
	defer conn.Close()

	start := time.Now()

	// Read first few bytes
	buf := make([]byte, 10)
	conn.SetReadDeadline(time.Now().Add(5 * time.Second))
	n, _ := conn.Read(buf)

	elapsed := time.Since(start)

	// 10 bytes * 50ms = 500ms minimum
	if n >= 5 && elapsed < 200*time.Millisecond {
		t.Errorf("Drip mode too fast: got %d bytes in %v", n, elapsed)
	}

	t.Logf("Drip mode: %d bytes in %v", n, elapsed)
}

func TestMock_TarpitSSH(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping tarpit test in short mode")
	}

	port := getFreePort(t)
	cmd := startMockServerWithArgs(t, port, "ssh", "-tarpit", "-drip", "100")
	defer stopMockServer(cmd)

	conn := dialWithRetry(t, port, 3)
	defer conn.Close()

	start := time.Now()

	// In tarpit mode, SSH sends endless random lines
	// Read for 2 seconds and verify we're getting data slowly
	buf := make([]byte, 100)
	totalBytes := 0

	conn.SetReadDeadline(time.Now().Add(2 * time.Second))
	for {
		n, err := conn.Read(buf)
		totalBytes += n
		if err != nil {
			break
		}
	}

	elapsed := time.Since(start)

	// Should have received some data but slowly
	if totalBytes == 0 {
		t.Error("Tarpit produced no output")
	}

	// Rough check: 100ms per byte, 2 seconds = ~20 bytes max
	if totalBytes > 50 {
		t.Errorf("Tarpit too fast: %d bytes in %v", totalBytes, elapsed)
	}

	t.Logf("SSH tarpit: %d bytes in %v (%.1f bytes/sec)", totalBytes, elapsed, float64(totalBytes)/elapsed.Seconds())
}

func TestMock_TarpitHTTP(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping tarpit test in short mode")
	}

	port := getFreePort(t)
	cmd := startMockServerWithArgs(t, port, "http", "-tarpit", "-drip", "50")
	defer stopMockServer(cmd)

	conn := dialWithRetry(t, port, 3)
	defer conn.Close()

	conn.Write([]byte("GET / HTTP/1.1\r\n\r\n"))

	start := time.Now()

	// Read for 1 second
	buf := make([]byte, 200)
	totalBytes := 0

	conn.SetReadDeadline(time.Now().Add(1 * time.Second))
	for {
		n, err := conn.Read(buf)
		totalBytes += n
		if err != nil {
			break
		}
	}

	elapsed := time.Since(start)

	// Should receive HTTP headers slowly
	if totalBytes == 0 {
		t.Error("Tarpit produced no output")
	}

	t.Logf("HTTP tarpit: %d bytes in %v", totalBytes, elapsed)
}

// =============================================================================
// Stress Tests
// =============================================================================

func TestMock_ConnectionLimit(t *testing.T) {
	port := getFreePort(t)
	// Start server with very low connection limit
	cmd := startMockServerWithArgs(t, port, "http", "-max-conns", "3")
	defer stopMockServer(cmd)

	// Open connections up to the limit
	conns := make([]net.Conn, 0, 5)
	defer func() {
		for _, c := range conns {
			if c != nil {
				c.Close()
			}
		}
	}()

	// First 3 should succeed
	for i := 0; i < 3; i++ {
		conn, err := net.DialTimeout("tcp", fmt.Sprintf("127.0.0.1:%d", port), 2*time.Second)
		if err != nil {
			t.Fatalf("Connection %d should succeed: %v", i+1, err)
		}
		conns = append(conns, conn)
	}

	// Give server time to register connections
	time.Sleep(100 * time.Millisecond)

	// 4th and 5th connections should be rejected (closed immediately)
	rejectedCount := 0
	for i := 0; i < 2; i++ {
		conn, err := net.DialTimeout("tcp", fmt.Sprintf("127.0.0.1:%d", port), 1*time.Second)
		if err != nil {
			// Connection refused - this counts as rejected
			rejectedCount++
			continue
		}
		// Connection accepted but should be closed immediately
		// Try to read - should get immediate EOF or error
		conn.SetReadDeadline(time.Now().Add(500 * time.Millisecond))
		buf := make([]byte, 10)
		_, err = conn.Read(buf)
		if err != nil {
			// Connection was closed by server - this is expected
			rejectedCount++
		}
		conn.Close()
	}

	if rejectedCount == 0 {
		t.Error("Expected at least some connections to be rejected when over limit")
	}
	t.Logf("Rejected %d connections over limit (expected: 2)", rejectedCount)
}

func TestMock_MultipleConnections(t *testing.T) {
	port := getFreePort(t)
	cmd := startMockServer(t, port, "http")
	defer stopMockServer(cmd)

	const numConns = 10
	results := make(chan bool, numConns)

	for i := 0; i < numConns; i++ {
		go func(id int) {
			conn, err := net.DialTimeout("tcp", fmt.Sprintf("127.0.0.1:%d", port), 2*time.Second)
			if err != nil {
				results <- false
				return
			}
			defer conn.Close()

			conn.Write([]byte("GET / HTTP/1.1\r\n\r\n"))

			buf := make([]byte, 1024)
			conn.SetReadDeadline(time.Now().Add(3 * time.Second))
			n, _ := conn.Read(buf)

			results <- strings.Contains(string(buf[:n]), "200 OK")
		}(i)
	}

	successCount := 0
	for i := 0; i < numConns; i++ {
		if <-results {
			successCount++
		}
	}

	if successCount != numConns {
		t.Errorf("Expected %d successful connections, got %d", numConns, successCount)
	}
}

func TestMock_AllProtocols(t *testing.T) {
	protocols := []struct {
		name      string
		sendFirst string // empty means server sends first
		expect    string
	}{
		{"http", "GET / HTTP/1.1\r\n\r\n", "HTTP/1.1"},
		{"ssh", "", "SSH-2.0"},
		{"mysql", "", "\x0a"}, // Protocol version byte
		{"redis", "PING\r\n", "-NOAUTH"},
		{"smtp", "", "220 "},
		{"telnet", "", "\xff"}, // IAC byte
		{"rdp", "", "\x03"},    // TPKT version
		{"mssql", "", "\x04"},  // TDS type
	}

	for _, proto := range protocols {
		t.Run(proto.name, func(t *testing.T) {
			port := getFreePort(t)
			cmd := startMockServer(t, port, proto.name)
			defer stopMockServer(cmd)

			conn := dialWithRetry(t, port, 3)
			defer conn.Close()

			if proto.sendFirst != "" {
				conn.Write([]byte(proto.sendFirst))
			}

			buf := make([]byte, 1024)
			conn.SetReadDeadline(time.Now().Add(3 * time.Second))
			n, err := conn.Read(buf)
			if err != nil && err != io.EOF {
				t.Fatalf("Read failed: %v", err)
			}

			if n == 0 {
				t.Error("No response received")
				return
			}

			response := string(buf[:n])
			if !strings.Contains(response, proto.expect) {
				t.Errorf("Expected %q in response, got: %s", proto.expect, truncate(response, 50))
			}
		})
	}
}

// =============================================================================
// Helper Functions
// =============================================================================

func startMockServer(t *testing.T, port int, protocol string) *exec.Cmd {
	return startMockServerWithArgs(t, port, protocol)
}

func startMockServerWithArgs(t *testing.T, port int, protocol string, extraArgs ...string) *exec.Cmd {
	wd, _ := os.Getwd()
	mockBin := filepath.Join(wd, mockBinPath)

	if _, err := os.Stat(mockBin); os.IsNotExist(err) {
		t.Fatalf("Mock binary not found at %s. Run 'make mock_build' first.", mockBin)
	}

	args := []string{"-port", fmt.Sprintf("%d", port), "-protocol", protocol}
	args = append(args, extraArgs...)

	cmd := exec.Command(mockBin, args...)
	// Uncomment for debugging:
	// cmd.Stdout = os.Stdout
	// cmd.Stderr = os.Stderr

	if err := cmd.Start(); err != nil {
		t.Fatalf("Failed to start mock server: %v", err)
	}

	time.Sleep(200 * time.Millisecond)
	return cmd
}

func stopMockServer(cmd *exec.Cmd) {
	if cmd != nil && cmd.Process != nil {
		cmd.Process.Kill()
		cmd.Wait()
	}
}

func dialWithRetry(t *testing.T, port int, retries int) net.Conn {
	var conn net.Conn
	var err error

	for i := 0; i < retries; i++ {
		conn, err = net.DialTimeout("tcp", fmt.Sprintf("127.0.0.1:%d", port), 2*time.Second)
		if err == nil {
			return conn
		}
		time.Sleep(100 * time.Millisecond)
	}

	t.Fatalf("Failed to connect after %d retries: %v", retries, err)
	return nil
}

func readResponse(t *testing.T, conn net.Conn) string {
	buf := make([]byte, 4096)
	conn.SetReadDeadline(time.Now().Add(3 * time.Second))
	n, err := conn.Read(buf)
	if err != nil && err != io.EOF {
		t.Fatalf("Failed to read response: %v", err)
	}
	return string(buf[:n])
}

func readFullResponse(t *testing.T, conn net.Conn) string {
	var result []byte
	buf := make([]byte, 4096)
	conn.SetReadDeadline(time.Now().Add(3 * time.Second))

	for {
		n, err := conn.Read(buf)
		if n > 0 {
			result = append(result, buf[:n]...)
		}
		if err != nil {
			break
		}
		conn.SetReadDeadline(time.Now().Add(500 * time.Millisecond))
	}
	return string(result)
}

func truncate(s string, maxLen int) string {
	if len(s) <= maxLen {
		return s
	}
	return s[:maxLen] + "..."
}
