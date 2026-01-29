package mockproto

import (
	"fmt"
	"math/rand/v2"
	"net"
	"strings"
	"time"
)

// MockHTTP emulates an HTTP server.
// In tarpit mode, it sends responses extremely slowly.
func MockHTTP(conn net.Conn, config MockConfig) error {
	// Drain input
	conn.SetReadDeadline(time.Now().Add(500 * time.Millisecond))
	buf := make([]byte, 4096)
	conn.Read(buf)
	conn.SetReadDeadline(time.Time{})

	if config.Tarpit {
		return httpTarpit(conn, config)
	}

	return httpNormal(conn, config.StatusCode, config.Payload)
}

// httpTarpit sends HTTP response extremely slowly (slowloris style)
func httpTarpit(conn net.Conn, config MockConfig) error {
	interval := config.DripIntervalMs
	if interval == 0 {
		interval = 500 // 500ms per byte
	}

	// Build a response that looks legit
	body := config.Payload
	if len(body) == 0 {
		// Generate a large fake page to maximize time waste
		body = generateFakePage()
	}

	httpDate := strings.Replace(time.Now().UTC().Format(time.RFC1123), "UTC", "GMT", 1)
	response := fmt.Sprintf("HTTP/1.1 200 OK\r\n"+
		"Content-Type: text/html; charset=utf-8\r\n"+
		"Content-Length: %d\r\n"+
		"Server: Apache/2.4.41 (Ubuntu)\r\n"+
		"Date: %s\r\n"+
		"Connection: keep-alive\r\n"+
		"X-Powered-By: PHP/7.4.3\r\n"+
		"\r\n", len(body), httpDate)

	// Drip headers
	if err := DripWrite(conn, []byte(response), interval); err != nil {
		return nil
	}

	// Drip body even slower
	return DripWrite(conn, body, interval*2)
}

// generateFakePage creates a large HTML page to maximize transfer time
func generateFakePage() []byte {
	var sb strings.Builder
	sb.WriteString("<!DOCTYPE html>\n<html>\n<head>\n")
	sb.WriteString("<title>Welcome</title>\n")
	sb.WriteString("<meta charset=\"utf-8\">\n")
	sb.WriteString("</head>\n<body>\n")
	sb.WriteString("<h1>Loading...</h1>\n")

	// Add lots of hidden content
	for i := 0; i < 100; i++ {
		sb.WriteString(fmt.Sprintf("<!-- cache-id: %032x -->\n", rand.Uint64()))
		sb.WriteString("<div style=\"display:none\">\n")
		for j := 0; j < 10; j++ {
			sb.WriteString(fmt.Sprintf("<p>%064x</p>\n", rand.Uint64()))
		}
		sb.WriteString("</div>\n")
	}

	sb.WriteString("<script>setTimeout(function(){location.reload()},30000);</script>\n")
	sb.WriteString("</body>\n</html>")

	return []byte(sb.String())
}

func httpNormal(conn net.Conn, statusCode int, payload []byte) error {
	statusLine := "HTTP/1.1 200 OK"
	body := payload

	switch statusCode {
	case 401:
		statusLine = "HTTP/1.1 401 Unauthorized"
		if len(body) == 0 {
			body = []byte("<html><body><h1>401 Unauthorized</h1></body></html>")
		}
	case 403:
		statusLine = "HTTP/1.1 403 Forbidden"
		if len(body) == 0 {
			body = []byte("<html><body><h1>403 Forbidden</h1></body></html>")
		}
	case 404:
		statusLine = "HTTP/1.1 404 Not Found"
		if len(body) == 0 {
			body = []byte("<html><body><h1>404 Not Found</h1></body></html>")
		}
	case 500:
		statusLine = "HTTP/1.1 500 Internal Server Error"
		if len(body) == 0 {
			body = []byte("<html><body><h1>500 Internal Server Error</h1></body></html>")
		}
	default:
		if len(body) == 0 {
			body = []byte("<html><body><h1>It works!</h1></body></html>")
		}
	}

	httpDate := strings.Replace(time.Now().UTC().Format(time.RFC1123), "UTC", "GMT", 1)
	headers := fmt.Sprintf("Content-Type: text/html\r\n"+
		"Content-Length: %d\r\n"+
		"Server: nginx\r\n"+
		"Date: %s\r\n"+
		"Connection: close\r\n", len(body), httpDate)

	if statusCode == 401 {
		headers += "WWW-Authenticate: Basic realm=\"Restricted\"\r\n"
	}

	response := fmt.Sprintf("%s\r\n%s\r\n", statusLine, headers)

	if _, err := conn.Write([]byte(response)); err != nil {
		return err
	}
	_, err := conn.Write(body)
	return err
}
