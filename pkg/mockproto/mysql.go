package mockproto

import (
	"crypto/rand"
	"net"
	"time"
)

// MockMySQL emulates a MySQL server.
// In tarpit mode, it keeps asking for authentication forever.
func MockMySQL(conn net.Conn, config MockConfig) error {
	// Send initial handshake
	if err := sendMySQLHandshake(conn); err != nil {
		return err
	}

	// Read login request
	conn.SetReadDeadline(time.Now().Add(30 * time.Second))
	buf := make([]byte, 1024)
	if _, err := conn.Read(buf); err != nil {
		return nil
	}
	conn.SetReadDeadline(time.Time{})

	// Tarpit mode: infinite auth loop
	if config.Tarpit {
		return mysqlTarpit(conn)
	}

	// Normal mode with optional delay
	if config.RandomDelay {
		RandomDelay(200, 2000)
	}

	// Send Access Denied
	return sendMySQLError(conn, 1045, "28000", "Access denied for user 'root'@'localhost'", 2)
}

// mysqlTarpit keeps the connection alive with endless auth failures
// This wastes attacker time by making them think they almost got in
func mysqlTarpit(conn net.Conn) error {
	t := NewTarpit(500, 500, 10000) // Start 500ms, +500ms each time, max 10s
	seq := uint32(2)               // Use uint32 to track, cast to byte for protocol

	messages := []string{
		"Access denied for user 'root'@'localhost' (using password: YES)",
		"Access denied for user 'root'@'localhost' (using password: NO)",
		"Your password has expired. To log in you must change it using a client that supports expired passwords.",
		"Access denied for user 'admin'@'localhost'",
		"Plugin 'mysql_native_password' is not loaded",
		"Host 'localhost' is blocked because of many connection errors",
		"Access denied; you need the SUPER privilege for this operation",
	}

	msgIdx := 0
	for {
		// Wait for next auth attempt
		conn.SetReadDeadline(time.Now().Add(60 * time.Second))
		buf := make([]byte, 1024)
		_, err := conn.Read(buf)
		if err != nil {
			return nil // Client gave up, we win
		}

		// Tarpit delay - gets slower each time
		t.Sleep()

		// Rotate through different error messages to give false hope
		// MySQL sequence number is 1 byte, wraps naturally via cast
		err = sendMySQLError(conn, 1045, "28000", messages[msgIdx%len(messages)], byte(seq&0xFF))
		if err != nil {
			return nil
		}

		msgIdx++
		seq++
	}
}

func sendMySQLHandshake(conn net.Conn) error {
	serverVersion := "5.7.21-log\x00"
	threadID := []byte{0x2d, 0x00, 0x00, 0x00}
	// Generate random salt (8 bytes + null terminator)
	saltBytes := make([]byte, 8)
	rand.Read(saltBytes)
	salt1 := string(saltBytes) + "\x00"
	capabilities := []byte{0xff, 0xf7}
	charset := byte(0x21)
	status := []byte{0x02, 0x00}

	payload := []byte{0x0a}
	payload = append(payload, []byte(serverVersion)...)
	payload = append(payload, threadID...)
	payload = append(payload, []byte(salt1)...)
	payload = append(payload, capabilities...)
	payload = append(payload, charset)
	payload = append(payload, status...)
	payload = append(payload, make([]byte, 13)...)

	packetLen := len(payload)
	header := []byte{
		byte(packetLen & 0xff),
		byte((packetLen >> 8) & 0xff),
		byte((packetLen >> 16) & 0xff),
		0x00, // Sequence 0
	}

	_, err := conn.Write(append(header, payload...))
	return err
}

func sendMySQLError(conn net.Conn, code int, state string, message string, seq byte) error {
	errPayload := []byte{
		0xff,                    // Error packet marker
		byte(code & 0xff),       // Error code low byte
		byte((code >> 8) & 0xff), // Error code high byte
		0x23,                    // '#' marker for SQL state
	}
	errPayload = append(errPayload, []byte(state)...) // SQL state (5 chars)
	errPayload = append(errPayload, []byte(message)...)

	errHeader := []byte{
		byte(len(errPayload) & 0xff),
		byte((len(errPayload) >> 8) & 0xff),
		byte((len(errPayload) >> 16) & 0xff),
		seq,
	}
	_, err := conn.Write(append(errHeader, errPayload...))
	return err
}
