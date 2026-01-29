package mockproto

import (
	"bytes"
	"fmt"
	"net"
	"time"
)

// MockRedis emulates a Redis server.
// In tarpit mode, it pretends auth is almost working.
func MockRedis(conn net.Conn, config MockConfig) error {
	if config.Tarpit {
		return redisTarpit(conn)
	}

	// Normal mode
	var t *Tarpit
	buf := make([]byte, 1024)

	for {
		conn.SetReadDeadline(time.Now().Add(60 * time.Second))
		n, err := conn.Read(buf)
		if err != nil {
			return nil
		}

		if config.RandomDelay {
			if t == nil {
				t = NewTarpit(100, 200, 5000)
			}
			t.Sleep()
		}

		conn.Write([]byte("-NOAUTH Authentication required.\r\n"))

		cmd := string(bytes.ToUpper(buf[:n]))
		if bytes.Contains([]byte(cmd), []byte("QUIT")) {
			return nil
		}
	}
}

// redisTarpit keeps attackers engaged with various responses
func redisTarpit(conn net.Conn) error {
	t := NewTarpit(200, 300, 8000)
	authAttempts := 0

	buf := make([]byte, 1024)
	for {
		conn.SetReadDeadline(time.Now().Add(120 * time.Second))
		n, err := conn.Read(buf)
		if err != nil {
			return nil
		}

		t.Sleep()

		cmd := string(bytes.ToUpper(buf[:n]))

		// Parse command
		switch {
		case bytes.Contains([]byte(cmd), []byte("AUTH")):
			authAttempts++
			// Rotate through different responses to keep them guessing
			responses := []string{
				"-WRONGPASS invalid username-password pair or user is disabled.\r\n",
				"-ERR invalid password\r\n",
				"-NOAUTH Authentication required.\r\n",
				"-ERR Client sent AUTH, but no password is set\r\n",
				"-NOPERM this user has no permissions to run the 'auth' command\r\n",
			}
			conn.Write([]byte(responses[authAttempts%len(responses)]))

		case bytes.Contains([]byte(cmd), []byte("PING")):
			// Give them hope - PING works!
			conn.Write([]byte("+PONG\r\n"))

		case bytes.Contains([]byte(cmd), []byte("INFO")):
			// Return some fake info to look legit
			info := "# Server\r\nredis_version:6.2.6\r\nredis_mode:standalone\r\nos:Linux 5.4.0-generic x86_64\r\n"
			conn.Write([]byte(fmt.Sprintf("$%d\r\n%s\r\n", len(info), info)))

		case bytes.Contains([]byte(cmd), []byte("QUIT")):
			// Don't let them quit easily in tarpit mode - just ignore
			conn.Write([]byte("-ERR unknown command 'QUIT'\r\n"))

		case bytes.Contains([]byte(cmd), []byte("COMMAND")):
			// Return empty array - looks like restricted server
			conn.Write([]byte("*0\r\n"))

		default:
			conn.Write([]byte("-NOAUTH Authentication required.\r\n"))
		}
	}
}
