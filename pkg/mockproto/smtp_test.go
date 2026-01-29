package mockproto

import (
	"strings"
	"testing"
)

func TestMockSMTP_Banner(t *testing.T) {
	conn := newMockConn([]byte("QUIT\r\n"))

	err := MockSMTP(conn, MockConfig{})
	if err != nil {
		t.Fatalf("MockSMTP failed: %v", err)
	}

	response := string(conn.writeData)

	// Should start with 220 banner
	if !strings.HasPrefix(response, "220 ") {
		t.Errorf("Expected 220 banner, got: %s", response)
	}

	if !strings.Contains(response, "ESMTP") {
		t.Errorf("Expected ESMTP in banner, got: %s", response)
	}
}

func TestMockSMTP_EHLO(t *testing.T) {
	conn := newMockConn([]byte("EHLO client.example.com\r\nQUIT\r\n"))

	err := MockSMTP(conn, MockConfig{})
	if err != nil {
		t.Fatalf("MockSMTP failed: %v", err)
	}

	response := string(conn.writeData)

	// Should respond with 250 and capabilities
	if !strings.Contains(response, "250-") {
		t.Errorf("Expected 250- continuation, got: %s", response)
	}

	// Check for common capabilities
	capabilities := []string{"PIPELINING", "SIZE", "AUTH", "8BITMIME"}
	for _, cap := range capabilities {
		if !strings.Contains(response, cap) {
			t.Errorf("Expected %s capability, got: %s", cap, response)
		}
	}
}

func TestMockSMTP_HELO(t *testing.T) {
	conn := newMockConn([]byte("HELO client.example.com\r\nQUIT\r\n"))

	err := MockSMTP(conn, MockConfig{})
	if err != nil {
		t.Fatalf("MockSMTP failed: %v", err)
	}

	response := string(conn.writeData)

	// HELO should also get 250 response
	if !strings.Contains(response, "250") {
		t.Errorf("Expected 250 response for HELO, got: %s", response)
	}
}

func TestMockSMTP_AUTH(t *testing.T) {
	conn := newMockConn([]byte("AUTH LOGIN\r\nQUIT\r\n"))

	err := MockSMTP(conn, MockConfig{})
	if err != nil {
		t.Fatalf("MockSMTP failed: %v", err)
	}

	response := string(conn.writeData)

	// AUTH should fail with 535
	if !strings.Contains(response, "535") {
		t.Errorf("Expected 535 auth failure, got: %s", response)
	}

	if !strings.Contains(response, "authentication failed") {
		t.Errorf("Expected 'authentication failed' message, got: %s", response)
	}
}

func TestMockSMTP_QUIT(t *testing.T) {
	conn := newMockConn([]byte("QUIT\r\n"))

	err := MockSMTP(conn, MockConfig{})
	if err != nil {
		t.Fatalf("MockSMTP failed: %v", err)
	}

	response := string(conn.writeData)

	// QUIT should respond with 221
	if !strings.Contains(response, "221") {
		t.Errorf("Expected 221 goodbye, got: %s", response)
	}

	if !strings.Contains(response, "Bye") {
		t.Errorf("Expected 'Bye' message, got: %s", response)
	}
}

func TestMockSMTP_UnknownCommand(t *testing.T) {
	conn := newMockConn([]byte("INVALID\r\nQUIT\r\n"))

	err := MockSMTP(conn, MockConfig{})
	if err != nil {
		t.Fatalf("MockSMTP failed: %v", err)
	}

	response := string(conn.writeData)

	// Unknown command should get 502
	if !strings.Contains(response, "502") {
		t.Errorf("Expected 502 for unknown command, got: %s", response)
	}

	if !strings.Contains(response, "command not recognized") {
		t.Errorf("Expected 'command not recognized', got: %s", response)
	}
}

func TestMockSMTP_WithDelay(t *testing.T) {
	conn := newMockConn([]byte("QUIT\r\n"))

	err := MockSMTP(conn, MockConfig{DelayMs: 10})
	if err != nil {
		t.Fatalf("MockSMTP failed: %v", err)
	}

	// Just verify it completes
	if len(conn.writeData) == 0 {
		t.Error("Expected SMTP response")
	}
}

func TestMockSMTP_WithRandomDelay(t *testing.T) {
	conn := newMockConn([]byte("EHLO test\r\nQUIT\r\n"))

	err := MockSMTP(conn, MockConfig{RandomDelay: true})
	if err != nil {
		t.Fatalf("MockSMTP failed: %v", err)
	}

	// Just verify it completes
	if len(conn.writeData) == 0 {
		t.Error("Expected SMTP response")
	}
}

func TestMockSMTP_CaseInsensitive(t *testing.T) {
	// Commands should be case-insensitive
	conn := newMockConn([]byte("ehlo test\r\nquit\r\n"))

	err := MockSMTP(conn, MockConfig{})
	if err != nil {
		t.Fatalf("MockSMTP failed: %v", err)
	}

	response := string(conn.writeData)

	// Should handle lowercase commands
	if !strings.Contains(response, "250") {
		t.Errorf("Expected 250 for lowercase ehlo, got: %s", response)
	}
}

func TestSanitizeSMTPResponse(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "normal command",
			input:    "BADCMD",
			expected: "BADCMD",
		},
		{
			name:     "with CRLF injection",
			input:    "BADCMD\r\n250 OK",
			expected: "BADCMD250 OK",
		},
		{
			name:     "with LF only",
			input:    "BADCMD\n250 OK",
			expected: "BADCMD250 OK",
		},
		{
			name:     "with null byte",
			input:    "BAD\x00CMD",
			expected: "BADCMD",
		},
		{
			name:     "with control characters",
			input:    "BAD\x01\x02\x03CMD",
			expected: "BADCMD",
		},
		{
			name:     "very long input truncated",
			input:    "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
			expected: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", // 32 chars max
		},
		{
			name:     "empty string",
			input:    "",
			expected: "",
		},
		{
			name:     "only control chars",
			input:    "\r\n\x00\x01",
			expected: "",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := sanitizeSMTPResponse(tt.input)
			if result != tt.expected {
				t.Errorf("sanitizeSMTPResponse(%q) = %q, want %q", tt.input, result, tt.expected)
			}
		})
	}
}

func TestSMTPResponseInjectionPrevented(t *testing.T) {
	// This test verifies that SMTP response injection attacks are prevented
	// in tarpit mode, which echoes commands back in error messages.
	// The vulnerability was: user input echoed without sanitizing CRLF

	// Attempt injection: send a command with embedded CRLF
	// In tarpit mode, the server echoes the command in a 500 error
	injectionPayload := "BADCMD\r\n250 2.1.0 Ok\r\nQUIT\r\n"
	conn := newMockConn([]byte(injectionPayload))

	// Use tarpit mode - this is where command echoing happens
	err := MockSMTP(conn, MockConfig{Tarpit: true})
	if err != nil {
		t.Fatalf("MockSMTP failed: %v", err)
	}

	response := string(conn.writeData)

	// The response should NOT contain our injected "250 2.1.0 Ok" as a separate SMTP response line
	// It should be sanitized - CRLF removed from the command before echoing
	lines := strings.Split(response, "\r\n")
	for _, line := range lines {
		// Check that no line is exactly our injected response
		// (it could appear inside the error message, but not as a standalone SMTP response)
		if line == "250 2.1.0 Ok" {
			t.Errorf("SMTP response injection succeeded! Found injected line as standalone response")
		}
	}

	// The sanitized command should appear in a 500 error (with CRLF stripped)
	if !strings.Contains(response, "500") {
		t.Errorf("Expected 500 error for unknown command in tarpit mode, got: %s", response)
	}

	// Verify the response doesn't have suspiciously many 250 lines
	count250 := strings.Count(response, "\n250 ")
	if count250 > 10 { // Normal EHLO gives several 250- lines, but not dozens
		t.Errorf("Suspicious number of 250 responses (%d), possible injection", count250)
	}
}
