package mockproto

import (
	"net"
	"strings"
	"testing"
	"time"
)

// mockConn is a simple mock for net.Conn used in tests
type mockConn struct {
	readData  []byte
	readPos   int
	writeData []byte
	closed    bool
}

func newMockConn(readData []byte) *mockConn {
	return &mockConn{readData: readData}
}

func (m *mockConn) Read(b []byte) (n int, err error) {
	if m.readPos >= len(m.readData) {
		time.Sleep(10 * time.Millisecond)
		return 0, net.ErrClosed
	}
	n = copy(b, m.readData[m.readPos:])
	m.readPos += n
	return n, nil
}

func (m *mockConn) Write(b []byte) (n int, err error) {
	m.writeData = append(m.writeData, b...)
	return len(b), nil
}

func (m *mockConn) Close() error {
	m.closed = true
	return nil
}

func (m *mockConn) LocalAddr() net.Addr                { return &net.TCPAddr{} }
func (m *mockConn) RemoteAddr() net.Addr               { return &net.TCPAddr{} }
func (m *mockConn) SetDeadline(t time.Time) error      { return nil }
func (m *mockConn) SetReadDeadline(t time.Time) error  { return nil }
func (m *mockConn) SetWriteDeadline(t time.Time) error { return nil }

func TestHandleConnection_HTTP(t *testing.T) {
	conn := newMockConn([]byte("GET / HTTP/1.1\r\nHost: test\r\n\r\n"))

	config := MockConfig{
		Protocol:   "http",
		StatusCode: 200,
	}

	err := HandleConnection(conn, config)
	if err != nil {
		t.Fatalf("HandleConnection failed: %v", err)
	}

	response := string(conn.writeData)
	if !strings.Contains(response, "HTTP/1.1 200 OK") {
		t.Errorf("Expected HTTP 200 OK, got: %s", response)
	}
}

func TestHandleConnection_SSH(t *testing.T) {
	conn := newMockConn([]byte("SSH-2.0-OpenSSH_client\r\n"))

	config := MockConfig{
		Protocol: "ssh",
	}

	err := HandleConnection(conn, config)
	if err != nil {
		t.Fatalf("HandleConnection failed: %v", err)
	}

	response := string(conn.writeData)
	if !strings.Contains(response, "SSH-2.0-OpenSSH") {
		t.Errorf("Expected SSH banner, got: %s", response)
	}
}

func TestHandleConnection_MySQL(t *testing.T) {
	conn := newMockConn([]byte{0x00, 0x00, 0x00, 0x01}) // dummy login packet

	config := MockConfig{
		Protocol: "mysql",
	}

	err := HandleConnection(conn, config)
	if err != nil {
		t.Fatalf("HandleConnection failed: %v", err)
	}

	// MySQL handshake should be sent
	if len(conn.writeData) == 0 {
		t.Error("Expected MySQL handshake response")
	}

	// Check for protocol version byte (0x0a = MySQL 10)
	if conn.writeData[4] != 0x0a {
		t.Errorf("Expected MySQL protocol version 0x0a, got: 0x%x", conn.writeData[4])
	}
}

func TestHandleConnection_Redis(t *testing.T) {
	conn := newMockConn([]byte("*1\r\n$4\r\nPING\r\n*1\r\n$4\r\nQUIT\r\n"))

	config := MockConfig{
		Protocol: "redis",
	}

	err := HandleConnection(conn, config)
	if err != nil {
		t.Fatalf("HandleConnection failed: %v", err)
	}

	response := string(conn.writeData)
	if !strings.Contains(response, "-NOAUTH") {
		t.Errorf("Expected NOAUTH response, got: %s", response)
	}
}

func TestHandleConnection_RawWithPayload(t *testing.T) {
	conn := newMockConn([]byte{})

	config := MockConfig{
		Protocol: "raw",
		Payload:  []byte("Custom Response"),
	}

	err := HandleConnection(conn, config)
	if err != nil {
		t.Fatalf("HandleConnection failed: %v", err)
	}

	response := string(conn.writeData)
	if response != "Custom Response" {
		t.Errorf("Expected 'Custom Response', got: %s", response)
	}
}

func TestHandleConnection_RawDefault(t *testing.T) {
	conn := newMockConn([]byte{})

	config := MockConfig{
		Protocol: "unknown",
	}

	err := HandleConnection(conn, config)
	if err != nil {
		t.Fatalf("HandleConnection failed: %v", err)
	}

	response := string(conn.writeData)
	if response != "Access Denied\n" {
		t.Errorf("Expected 'Access Denied', got: %s", response)
	}
}

func TestHandleConnection_WithDelay(t *testing.T) {
	conn := newMockConn([]byte("GET / HTTP/1.1\r\n\r\n"))

	config := MockConfig{
		Protocol: "http",
		DelayMs:  100,
	}

	start := time.Now()
	err := HandleConnection(conn, config)
	elapsed := time.Since(start)

	if err != nil {
		t.Fatalf("HandleConnection failed: %v", err)
	}

	if elapsed < 100*time.Millisecond {
		t.Errorf("Expected at least 100ms delay, got: %v", elapsed)
	}
}

func TestHandleConnection_AllProtocols(t *testing.T) {
	protocols := []string{"http", "ssh", "mysql", "mssql", "rdp", "telnet", "redis", "smtp", "raw"}

	for _, proto := range protocols {
		t.Run(proto, func(t *testing.T) {
			var readData []byte
			switch proto {
			case "redis":
				readData = []byte("*1\r\n$4\r\nQUIT\r\n")
			case "smtp":
				readData = []byte("QUIT\r\n")
			default:
				readData = []byte("test data\r\n")
			}

			conn := newMockConn(readData)
			config := MockConfig{Protocol: proto}

			err := HandleConnection(conn, config)
			if err != nil {
				t.Errorf("Protocol %s failed: %v", proto, err)
			}

			if len(conn.writeData) == 0 {
				t.Errorf("Protocol %s produced no output", proto)
			}
		})
	}
}
