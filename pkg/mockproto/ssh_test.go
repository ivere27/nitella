package mockproto

import (
	"strings"
	"testing"
)

func TestMockSSH_DefaultBanner(t *testing.T) {
	conn := newMockConn([]byte("SSH-2.0-OpenSSH_client\r\n"))

	config := MockConfig{
		Protocol: "ssh",
	}

	err := MockSSH(conn, config)
	if err != nil {
		t.Fatalf("MockSSH failed: %v", err)
	}

	response := string(conn.writeData)

	if !strings.Contains(response, "SSH-2.0-OpenSSH_8.2p1") {
		t.Errorf("Expected default SSH banner, got: %s", response)
	}
	if !strings.Contains(response, "Ubuntu") {
		t.Errorf("Expected Ubuntu in banner, got: %s", response)
	}
}

func TestMockSSH_CustomBanner(t *testing.T) {
	conn := newMockConn([]byte("SSH-2.0-OpenSSH_client\r\n"))

	customBanner := "SSH-2.0-CustomServer_1.0\r\n"
	config := MockConfig{
		Protocol: "ssh",
		Payload:  []byte(customBanner),
	}

	err := MockSSH(conn, config)
	if err != nil {
		t.Fatalf("MockSSH failed: %v", err)
	}

	response := string(conn.writeData)

	if !strings.Contains(response, "CustomServer_1.0") {
		t.Errorf("Expected custom banner, got: %s", response)
	}
}

func TestMockSSH_DripBanner(t *testing.T) {
	conn := newMockConn([]byte("SSH-2.0-OpenSSH_client\r\n"))

	config := MockConfig{
		Protocol:       "ssh",
		Payload:        []byte("SSH-2.0-Test\r\n"),
		DripBanner:     true,
		DripIntervalMs: 1, // 1ms per byte for fast test
	}

	err := MockSSH(conn, config)
	if err != nil {
		t.Fatalf("MockSSH failed: %v", err)
	}

	response := string(conn.writeData)

	if response != "SSH-2.0-Test\r\n" {
		t.Errorf("Expected dripped banner, got: %s", response)
	}
}

func TestMockSSH_RandomDelay(t *testing.T) {
	conn := newMockConn([]byte("SSH-2.0-OpenSSH_client\r\n"))

	config := MockConfig{
		Protocol:    "ssh",
		RandomDelay: true,
	}

	err := MockSSH(conn, config)
	if err != nil {
		t.Fatalf("MockSSH failed: %v", err)
	}

	// Just verify it completes without error
	if len(conn.writeData) == 0 {
		t.Error("Expected SSH banner output")
	}
}

func TestMockSSH_RFC4253Banner(t *testing.T) {
	// RFC 4253 specifies SSH banner format
	conn := newMockConn([]byte("SSH-2.0-OpenSSH_client\r\n"))

	config := MockConfig{
		Protocol: "ssh",
	}

	err := MockSSH(conn, config)
	if err != nil {
		t.Fatalf("MockSSH failed: %v", err)
	}

	response := string(conn.writeData)

	// Must start with SSH-2.0-
	if !strings.HasPrefix(response, "SSH-2.0-") {
		t.Errorf("SSH banner must start with SSH-2.0-, got: %s", response)
	}

	// Must end with \r\n
	if !strings.HasSuffix(response, "\r\n") {
		t.Errorf("SSH banner must end with CRLF, got: %s", response)
	}
}
