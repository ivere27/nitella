package node

import (
	"io"
	"net"
	"strings"
	"testing"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
)

func TestMockFallback(t *testing.T) {
	// Scenario 1: Empty Backend
	t.Run("EmptyBackend", func(t *testing.T) {
		l := NewEmbeddedListener("test-fallback", "Fallback Proxy", "127.0.0.1:0", "", common.ActionType_ACTION_TYPE_ALLOW, common.MockPreset_MOCK_PRESET_HTTP_403, "", "", "", pbProxy.ClientAuthType_CLIENT_AUTH_AUTO, nil)
		go l.Start()
		defer l.Stop()
		time.Sleep(100 * time.Millisecond) // Wait for start

		port := strings.Split(l.ListenAddr, ":")[1]
		conn, err := net.Dial("tcp", "127.0.0.1:"+port)
		if err != nil {
			t.Fatalf("Failed to connect: %v", err)
		}
		defer conn.Close()

		buf := make([]byte, 1024)
		n, err := conn.Read(buf)
		if err != nil && err != io.EOF {
			t.Fatalf("Read error: %v", err)
		}
		resp := string(buf[:n])

		if !strings.Contains(resp, "403 Forbidden") {
			t.Errorf("Expected 403 Forbidden fallback, got: %s", resp)
		}
	})

	// Scenario 2: Unreachable Backend
	t.Run("UnreachableBackend", func(t *testing.T) {
		// Use a port that is likely closed/unreachable (e.g. 127.0.0.1:1 - usually rejected immediately or times out)
		// 127.0.0.1:1 on interface lo usually gets RST immediately (Connection Refused).
		l := NewEmbeddedListener("test-fallback-2", "Fallback Proxy 2", "127.0.0.1:0", "127.0.0.1:1", common.ActionType_ACTION_TYPE_ALLOW, common.MockPreset_MOCK_PRESET_HTTP_403, "", "", "", pbProxy.ClientAuthType_CLIENT_AUTH_AUTO, nil)
		go l.Start()
		defer l.Stop()
		time.Sleep(100 * time.Millisecond)

		port := strings.Split(l.ListenAddr, ":")[1]
		conn, err := net.Dial("tcp", "127.0.0.1:"+port)
		if err != nil {
			t.Fatalf("Failed to connect: %v", err)
		}
		defer conn.Close()

		buf := make([]byte, 1024)
		n, err := conn.Read(buf)
		if err != nil && err != io.EOF {
			// If dial failed immediately, Read might fail immediately if conn was closed by proxy (if no logic)?
			// But we expect fallback to write mock data.
			t.Fatalf("Read error: %v", err)
		}
		resp := string(buf[:n])

		if !strings.Contains(resp, "403 Forbidden") {
			t.Errorf("Expected 403 Forbidden fallback (on dial fail), got: %s", resp)
		}
	})
}
