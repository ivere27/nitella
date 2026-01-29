package mockproto

import (
	"strings"
	"testing"
)

func TestMockHTTP_200OK(t *testing.T) {
	conn := newMockConn([]byte("GET / HTTP/1.1\r\nHost: test\r\n\r\n"))

	err := MockHTTP(conn, MockConfig{StatusCode: 200})
	if err != nil {
		t.Fatalf("MockHTTP failed: %v", err)
	}

	response := string(conn.writeData)

	if !strings.Contains(response, "HTTP/1.1 200 OK") {
		t.Errorf("Expected HTTP 200 OK status line")
	}
	if !strings.Contains(response, "Content-Type: text/html") {
		t.Errorf("Expected Content-Type header")
	}
	if !strings.Contains(response, "Server: nginx") {
		t.Errorf("Expected Server header")
	}
	if !strings.Contains(response, "It works!") {
		t.Errorf("Expected default body")
	}
}

func TestMockHTTP_401Unauthorized(t *testing.T) {
	conn := newMockConn([]byte("GET /admin HTTP/1.1\r\n\r\n"))

	err := MockHTTP(conn, MockConfig{StatusCode: 401})
	if err != nil {
		t.Fatalf("MockHTTP failed: %v", err)
	}

	response := string(conn.writeData)

	if !strings.Contains(response, "HTTP/1.1 401 Unauthorized") {
		t.Errorf("Expected HTTP 401 status line")
	}
	if !strings.Contains(response, "WWW-Authenticate: Basic") {
		t.Errorf("Expected WWW-Authenticate header for 401")
	}
	if !strings.Contains(response, "401 Unauthorized") {
		t.Errorf("Expected 401 body")
	}
}

func TestMockHTTP_403Forbidden(t *testing.T) {
	conn := newMockConn([]byte("GET /secret HTTP/1.1\r\n\r\n"))

	err := MockHTTP(conn, MockConfig{StatusCode: 403})
	if err != nil {
		t.Fatalf("MockHTTP failed: %v", err)
	}

	response := string(conn.writeData)

	if !strings.Contains(response, "HTTP/1.1 403 Forbidden") {
		t.Errorf("Expected HTTP 403 status line")
	}
	if !strings.Contains(response, "403 Forbidden") {
		t.Errorf("Expected 403 body")
	}
}

func TestMockHTTP_404NotFound(t *testing.T) {
	conn := newMockConn([]byte("GET /notfound HTTP/1.1\r\n\r\n"))

	err := MockHTTP(conn, MockConfig{StatusCode: 404})
	if err != nil {
		t.Fatalf("MockHTTP failed: %v", err)
	}

	response := string(conn.writeData)

	if !strings.Contains(response, "HTTP/1.1 404 Not Found") {
		t.Errorf("Expected HTTP 404 status line")
	}
}

func TestMockHTTP_500InternalError(t *testing.T) {
	conn := newMockConn([]byte("GET /error HTTP/1.1\r\n\r\n"))

	err := MockHTTP(conn, MockConfig{StatusCode: 500})
	if err != nil {
		t.Fatalf("MockHTTP failed: %v", err)
	}

	response := string(conn.writeData)

	if !strings.Contains(response, "HTTP/1.1 500 Internal Server Error") {
		t.Errorf("Expected HTTP 500 status line")
	}
}

func TestMockHTTP_CustomPayload(t *testing.T) {
	conn := newMockConn([]byte("GET / HTTP/1.1\r\n\r\n"))
	customPayload := []byte("<html><body>Custom Content</body></html>")

	err := MockHTTP(conn, MockConfig{StatusCode: 200, Payload: customPayload})
	if err != nil {
		t.Fatalf("MockHTTP failed: %v", err)
	}

	response := string(conn.writeData)

	if !strings.Contains(response, "Custom Content") {
		t.Errorf("Expected custom payload in response")
	}
	if strings.Contains(response, "It works!") {
		t.Errorf("Should not contain default body when custom payload provided")
	}
}

func TestMockHTTP_ContentLength(t *testing.T) {
	conn := newMockConn([]byte("GET / HTTP/1.1\r\n\r\n"))
	customPayload := []byte("12345")

	err := MockHTTP(conn, MockConfig{StatusCode: 200, Payload: customPayload})
	if err != nil {
		t.Fatalf("MockHTTP failed: %v", err)
	}

	response := string(conn.writeData)

	if !strings.Contains(response, "Content-Length: 5") {
		t.Errorf("Expected Content-Length: 5 for 5-byte payload")
	}
}

func TestMockHTTP_DateHeader(t *testing.T) {
	conn := newMockConn([]byte("GET / HTTP/1.1\r\n\r\n"))

	err := MockHTTP(conn, MockConfig{StatusCode: 200})
	if err != nil {
		t.Fatalf("MockHTTP failed: %v", err)
	}

	response := string(conn.writeData)

	if !strings.Contains(response, "Date:") {
		t.Errorf("Expected Date header in response")
	}
}

func TestMockHTTP_ConnectionClose(t *testing.T) {
	conn := newMockConn([]byte("GET / HTTP/1.1\r\n\r\n"))

	err := MockHTTP(conn, MockConfig{StatusCode: 200})
	if err != nil {
		t.Fatalf("MockHTTP failed: %v", err)
	}

	response := string(conn.writeData)

	if !strings.Contains(response, "Connection: close") {
		t.Errorf("Expected Connection: close header")
	}
}
