package mockproto

import (
	"net"
)

func MockMSSQL(conn net.Conn) error {
	// TDS Pre-Login Response
	// Header: type(1) + status(1) + length(2, big-endian) + channel(2) + packet#(1) + window(1)
	// Followed by pre-login option tokens
	response := []byte{
		0x04,       // Type: Response
		0x01,       // Status: EOM
		0x00, 0x1a, // Length: 26 bytes (big-endian)
		0x00, 0x00, // Channel
		0x01,       // Packet number
		0x00,       // Window
		// Pre-login tokens (VERSION, ENCRYPTION, TERMINATOR)
		0x00, 0x00, 0x10, 0x00, 0x06, // VERSION at offset 16, length 6
		0x01, 0x00, 0x16, 0x00, 0x01, // ENCRYPTION at offset 22, length 1
		0xff,                               // TERMINATOR
		0x0e, 0x00, 0x00, 0x00, 0x00, 0x00, // VERSION data: 14.0.0.0
		0x02, // ENCRYPTION data: NOT_SUP
	}
	_, err := conn.Write(response)
	return err
}

func MockRDP(conn net.Conn) error {
	// TPKT Header + X.224 Connection Confirm
	response := []byte{
		0x03, 0x00, 0x00, 0x13, // TPKT Header (Len 19)
		0x0e, 0xd0, 0x00, 0x00, 0x12, 0x34, 0x00, // X.224 CC
		0x02, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,
	}
	_, err := conn.Write(response)
	return err
}
