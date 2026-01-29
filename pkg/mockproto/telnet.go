package mockproto

import (
	"fmt"
	"net"
	"time"
)

// MockTelnet emulates a Telnet server.
// In tarpit mode, it presents an endless login loop.
func MockTelnet(conn net.Conn, config MockConfig) error {
	// Send negotiation
	negotiation := []byte{0xff, 0xfd, 0x18, 0xff, 0xfd, 0x20, 0xff, 0xfd, 0x23, 0xff, 0xfd, 0x27}

	if config.DripBanner {
		if err := DripWrite(conn, negotiation, config.DripIntervalMs); err != nil {
			return err
		}
	} else {
		if _, err := conn.Write(negotiation); err != nil {
			return err
		}
	}

	time.Sleep(100 * time.Millisecond)

	if config.Tarpit {
		return telnetTarpit(conn)
	}

	// Normal mode
	banner := "\r\nUser Access Verification\r\n\r\nUsername: "
	_, err := conn.Write([]byte(banner))
	return err
}

// telnetTarpit presents an endless login prompt that never succeeds
func telnetTarpit(conn net.Conn) error {
	t := NewTarpit(500, 500, 10000)
	buf := make([]byte, 256)
	loginAttempts := 0

	banners := []string{
		"\r\nUser Access Verification\r\n\r\n",
		"\r\nAuthorized Users Only\r\n\r\n",
		"\r\nWelcome to Ubuntu 20.04.3 LTS\r\n\r\n",
		"\r\nCisco IOS Software\r\n\r\n",
	}

	// Send initial banner
	conn.Write([]byte(banners[0]))

	for {
		// Username prompt
		conn.Write([]byte("Username: "))

		conn.SetReadDeadline(time.Now().Add(120 * time.Second))
		_, err := conn.Read(buf)
		if err != nil {
			return nil
		}

		t.Sleep()

		// Password prompt
		conn.Write([]byte("Password: "))

		conn.SetReadDeadline(time.Now().Add(120 * time.Second))
		_, err = conn.Read(buf)
		if err != nil {
			return nil
		}

		t.Sleep()

		loginAttempts++

		// Rotate through different failure messages
		failures := []string{
			"\r\n% Login invalid\r\n\r\n",
			"\r\n% Authentication failed.\r\n\r\n",
			"\r\n% Access denied\r\n\r\n",
			"\r\n% Bad passwords\r\n\r\n",
			"\r\nLogin incorrect\r\n\r\n",
			fmt.Sprintf("\r\n%% Too many failures - try again in %d seconds\r\n\r\n", loginAttempts*5),
		}

		conn.Write([]byte(failures[loginAttempts%len(failures)]))

		// Occasionally switch banner to keep them interested
		if loginAttempts%10 == 0 {
			conn.Write([]byte(banners[loginAttempts/10%len(banners)]))
		}
	}
}

// Legacy function for backward compatibility
func MockTelnetLegacy(conn net.Conn) error {
	negotiation := []byte{0xff, 0xfd, 0x18, 0xff, 0xfd, 0x20, 0xff, 0xfd, 0x23, 0xff, 0xfd, 0x27}

	_, err := conn.Write(negotiation)
	if err != nil {
		return err
	}

	time.Sleep(100 * time.Millisecond)

	banner := "\r\nUser Access Verification\r\n\r\nUsername: "
	_, err = conn.Write([]byte(banner))
	return err
}
