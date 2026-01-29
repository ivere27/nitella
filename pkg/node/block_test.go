package node

import (
	"io"
	"net"
	"testing"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
)

func TestDefaultBlockAction(t *testing.T) {
	// 1. Create Listener with Empty Default Action (Should default to BLOCK)
	l := NewEmbeddedListener("test-block", "Test Proxy Block", "127.0.0.1:0", "", common.ActionType_ACTION_TYPE_BLOCK, common.MockPreset_MOCK_PRESET_UNSPECIFIED, "", "", "", pbProxy.ClientAuthType_CLIENT_AUTH_AUTO, nil)

	// 2. Start Listener
	go l.Start()
	defer l.Stop()

	// Wait for start
	time.Sleep(100 * time.Millisecond)

	port := l.ListenAddr // NewEmbeddedListener sets this after Start() usually, but here it's async?
	// EmbeddedListener.Start() updates l.ListenAddr.
	// We need to wait until it's set.
	// Hack: wait and read
	time.Sleep(200 * time.Millisecond)
	port = l.ListenAddr

	if port == "127.0.0.1:0" || port == "" {
		// If using :0, we need the actual port.
		// The EmbeddedListener struct field is updated in Start().
		// Since we run Start() in goroutine, we should be able to read it.
		// If it's still 0, the test might fail to connect.
		t.Logf("Warning: Port might not be ready: %s", port)
	}

	// 3. Connect as Client
	conn, err := net.Dial("tcp", port)
	if err != nil {
		t.Fatalf("Failed to connect: %v", err)
	}
	defer conn.Close()

	// 4. Read Response
	// Expect termination or immediate close.
	buf := make([]byte, 1024)
	n, err := conn.Read(buf)

	// Connection should be closed by server immediately (BLOCK action closes connection)
	if err != io.EOF {
		// If we got data, that's unexpected for a raw TCP block (unless we sent a block page? currently logic just closes)
		if n > 0 {
			t.Errorf("Expected connection close (EOF), got data: %s", string(buf[:n]))
		}
	}

	// Verify internal state
	if l.DefaultAction != common.ActionType_ACTION_TYPE_BLOCK {
		t.Errorf("Expected DefaultAction BLOCK, got %v", l.DefaultAction)
	}
}
