package mockproto

import (
	"math/rand/v2"
	"net"
	"time"
)

// MockSSH implements an SSH tarpit inspired by endlessh.
// In tarpit mode, it sends an endless stream of random banner lines,
// one byte at a time, keeping the connection open forever.
func MockSSH(conn net.Conn, config MockConfig) error {
	// Tarpit mode: endless random banner lines (endlessh style)
	if config.Tarpit {
		return sshTarpit(conn, config.DripIntervalMs)
	}

	// Normal mode: send banner and optionally hold
	var banner []byte
	if len(config.Payload) > 0 {
		banner = config.Payload
	} else {
		banner = []byte("SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.5\r\n")
	}

	if config.DripBanner {
		if err := DripWrite(conn, banner, config.DripIntervalMs); err != nil {
			return err
		}
	} else {
		if _, err := conn.Write(banner); err != nil {
			return err
		}
	}

	if config.NeverComplete {
		HoldOpen(conn)
		return nil
	}

	// Read client banner
	conn.SetReadDeadline(time.Now().Add(5 * time.Second))
	buf := make([]byte, 256)
	if _, err := conn.Read(buf); err != nil {
		return nil
	}
	conn.SetReadDeadline(time.Time{})

	if config.RandomDelay {
		RandomDelay(100, 500)
	}

	return nil
}

// sshTarpit sends endless random lines before the SSH banner completes.
// SSH RFC allows servers to send lines before "SSH-2.0-..." banner.
// We exploit this to keep clients waiting forever.
func sshTarpit(conn net.Conn, intervalMs int) error {
	if intervalMs == 0 {
		intervalMs = 1000 // 1 second per byte
	}

	// Keep sending random pre-banner lines forever
	// RFC 4253: "The server MAY send other lines of data before sending the version string"
	for {
		// Generate random line (looks like server info/warning)
		line := generateRandomLine()

		// Drip it byte by byte
		for _, b := range line {
			conn.SetWriteDeadline(time.Now().Add(30 * time.Second))
			if _, err := conn.Write([]byte{b}); err != nil {
				return nil // Client disconnected, we win
			}
			time.Sleep(time.Duration(intervalMs) * time.Millisecond)
		}
	}
}

// generateRandomLine creates a random line that looks like server pre-banner info
func generateRandomLine() []byte {
	// Random hex string (looks like some kind of server ID or hash)
	length := 32 + rand.IntN(32)
	line := make([]byte, length)
	for i := range line {
		line[i] = "0123456789abcdef"[rand.IntN(16)]
	}
	return append(line, '\r', '\n')
}
