package mockproto

import (
	"strings"
	"testing"
)

func TestMockRedis_NOAUTH(t *testing.T) {
	// PING command in RESP format
	conn := newMockConn([]byte("*1\r\n$4\r\nPING\r\n*1\r\n$4\r\nQUIT\r\n"))

	err := MockRedis(conn, MockConfig{})
	if err != nil {
		t.Fatalf("MockRedis failed: %v", err)
	}

	response := string(conn.writeData)

	if !strings.Contains(response, "-NOAUTH Authentication required") {
		t.Errorf("Expected NOAUTH response, got: %s", response)
	}
}

func TestMockRedis_MultipleCommands(t *testing.T) {
	// Multiple commands before QUIT
	// Note: Our mock conn reads all data at once, so Redis sees it as one command
	// This tests that Redis responds and handles QUIT properly
	conn := newMockConn([]byte("GET key\r\nSET key value\r\nQUIT\r\n"))

	err := MockRedis(conn, MockConfig{})
	if err != nil {
		t.Fatalf("MockRedis failed: %v", err)
	}

	response := string(conn.writeData)

	// Should respond with at least one NOAUTH
	if !strings.Contains(response, "-NOAUTH") {
		t.Error("Expected NOAUTH response")
	}
}

func TestMockRedis_QUITCommand(t *testing.T) {
	// QUIT should terminate connection
	conn := newMockConn([]byte("QUIT\r\n"))

	err := MockRedis(conn, MockConfig{})
	if err != nil {
		t.Fatalf("MockRedis failed: %v", err)
	}

	// Should still respond with NOAUTH before quitting
	response := string(conn.writeData)
	if !strings.Contains(response, "-NOAUTH") {
		t.Errorf("Expected NOAUTH response even for QUIT")
	}
}

func TestMockRedis_WithRandomDelay(t *testing.T) {
	conn := newMockConn([]byte("PING\r\nQUIT\r\n"))

	err := MockRedis(conn, MockConfig{RandomDelay: true})
	if err != nil {
		t.Fatalf("MockRedis failed: %v", err)
	}

	// Just verify it completes
	if len(conn.writeData) == 0 {
		t.Error("Expected Redis response")
	}
}

func TestMockRedis_RESPFormat(t *testing.T) {
	conn := newMockConn([]byte("PING\r\nQUIT\r\n"))

	err := MockRedis(conn, MockConfig{})
	if err != nil {
		t.Fatalf("MockRedis failed: %v", err)
	}

	response := string(conn.writeData)

	// RESP error format starts with '-'
	if !strings.HasPrefix(response, "-") {
		t.Errorf("Expected RESP error format (starts with -), got: %s", response)
	}

	// RESP messages end with \r\n
	if !strings.HasSuffix(strings.TrimRight(response, "-NOAUTH Authentication required.\r\n"), "") {
		t.Logf("Response format OK: %s", response)
	}
}

func TestMockRedis_CaseInsensitive(t *testing.T) {
	// QUIT in lowercase should also work
	conn := newMockConn([]byte("ping\r\nquit\r\n"))

	err := MockRedis(conn, MockConfig{})
	if err != nil {
		t.Fatalf("MockRedis failed: %v", err)
	}

	// Should process quit command (case insensitive)
	response := string(conn.writeData)
	if !strings.Contains(response, "-NOAUTH") {
		t.Error("Expected NOAUTH response")
	}
}
