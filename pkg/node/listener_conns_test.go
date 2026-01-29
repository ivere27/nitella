package node

import (
	"io"
	"net"
	"testing"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/stretchr/testify/assert"
)

func TestConnectionTracking(t *testing.T) {
	// Setup Listener
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("Failed to listen: %v", err)
	}
	defer ln.Close()

	// Setup Echo Backend
	backendLn, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("Failed to listen backend: %v", err)
	}
	defer backendLn.Close()
	backendAddr := backendLn.Addr().String()

	go func() {
		for {
			conn, err := backendLn.Accept()
			if err != nil {
				return
			}
			go func(c net.Conn) {
				defer c.Close()
				io.Copy(c, c)
			}(conn)
		}
	}()

	// Setup EmbeddedListener
	listener := NewEmbeddedListener("test-conn", "Test Conn Proxy", "127.0.0.1:0", backendAddr, common.ActionType_ACTION_TYPE_ALLOW, common.MockPreset_MOCK_PRESET_UNSPECIFIED, "", "", "", pbProxy.ClientAuthType_CLIENT_AUTH_AUTO, nil)
	// We passed an address that is already bound by `ln`.
	// Start() calls net.Listen.
	// So we should NOT bind `ln` ourselves, or we should pass a free port.
	// Let's close `ln` first to free the port, assuming we just wanted a free port.
	ln.Close()

	// Wait a bit for port to free? Or just let Start() handle it.
	// Ideally we pass ":0" and let it pick.
	listener.ListenAddr = "127.0.0.1:0"
	err = listener.Start()
	assert.NoError(t, err)
	defer listener.Stop()

	realAddr := listener.ListenAddr

	// 1. Establish a connection
	conn, err := net.Dial("tcp", realAddr)
	assert.NoError(t, err)
	defer conn.Close()

	// 2. Write some data to verify stats
	_, err = conn.Write([]byte("hello"))
	assert.NoError(t, err)

	buf := make([]byte, 5)
	_, err = conn.Read(buf)
	assert.NoError(t, err)
	assert.Equal(t, "hello", string(buf))

	// Allow stats to update (atomic ops are fast but let's yield)
	time.Sleep(100 * time.Millisecond)

	// 3. Check Active Connections
	conns := listener.GetActiveConnections()
	assert.Equal(t, 1, len(conns))
	if len(conns) > 0 {
		c := conns[0]
		assert.Equal(t, "127.0.0.1", c.SourceIP) // Loopback
		assert.Equal(t, backendAddr, c.DestAddr)
		assert.GreaterOrEqual(t, *c.BytesIn, int64(5))
		assert.GreaterOrEqual(t, *c.BytesOut, int64(5))

		// 4. Close Connection via API
		err = listener.CloseConnection("", c.ID)
		assert.NoError(t, err)

		// Verify connection is closed
		_, err = conn.Write([]byte("more"))
		// Should fail eventually
		// Wait for closing to propagate
		time.Sleep(100 * time.Millisecond)

		conns = listener.GetActiveConnections()
		assert.Equal(t, 0, len(conns))
	}
}

func TestCloseAllConnections(t *testing.T) {
	// Setup Echo Backend
	backendLn, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("Failed to listen backend: %v", err)
	}
	defer backendLn.Close()
	backendAddr := backendLn.Addr().String()

	go func() {
		for {
			conn, err := backendLn.Accept()
			if err != nil {
				return
			}
			go func(c net.Conn) {
				defer c.Close()
				io.Copy(c, c)
			}(conn)
		}
	}()

	listener := NewEmbeddedListener("test-proxy-all", "Test Proxy All", "127.0.0.1:0", backendAddr, common.ActionType_ACTION_TYPE_ALLOW, common.MockPreset_MOCK_PRESET_UNSPECIFIED, "", "", "", pbProxy.ClientAuthType_CLIENT_AUTH_AUTO, nil)
	err = listener.Start()
	assert.NoError(t, err)
	defer listener.Stop()

	realAddr := listener.ListenAddr

	// Create 3 connections
	var conns []net.Conn
	for i := 0; i < 3; i++ {
		c, err := net.Dial("tcp", realAddr)
		assert.NoError(t, err)
		conns = append(conns, c)
		c.Write([]byte("ping"))
		buf := make([]byte, 4)
		c.Read(buf)
	}

	time.Sleep(100 * time.Millisecond)

	active := listener.GetActiveConnections()
	assert.Equal(t, 3, len(active))

	// Close All
	err = listener.CloseAllConnections()
	assert.NoError(t, err)

	time.Sleep(100 * time.Millisecond)

	active = listener.GetActiveConnections()
	assert.Equal(t, 0, len(active))

	// Verify clients define closed
	for _, c := range conns {
		// Write might succeed due to buffer
		c.Write([]byte("pong"))

		// Read should fail (EOF)
		buf := make([]byte, 10)
		_, err := c.Read(buf)
		assert.Error(t, err, "Expected error on Read from closed connection")

		c.Close()
	}
}
