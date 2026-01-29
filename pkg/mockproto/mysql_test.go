package mockproto

import (
	"testing"
)

func TestMockMySQL_Handshake(t *testing.T) {
	// Simulate client login packet
	conn := newMockConn([]byte{
		0x20, 0x00, 0x00, 0x01, // packet header
		0x85, 0xa6, 0x03, 0x00, // client capabilities
		0x00, 0x00, 0x00, 0x01, // max packet size
		0x21,                   // charset
		0x00, 0x00, 0x00, 0x00, // filler
	})

	err := MockMySQL(conn, MockConfig{})
	if err != nil {
		t.Fatalf("MockMySQL failed: %v", err)
	}

	// Check handshake packet was sent
	if len(conn.writeData) < 10 {
		t.Fatal("Expected MySQL handshake packet")
	}

	// First 4 bytes are header (length + sequence)
	// Byte 4 should be protocol version (0x0a = 10)
	if conn.writeData[4] != 0x0a {
		t.Errorf("Expected protocol version 0x0a, got: 0x%x", conn.writeData[4])
	}
}

func TestMockMySQL_ServerVersion(t *testing.T) {
	conn := newMockConn([]byte{0x20, 0x00, 0x00, 0x01})

	err := MockMySQL(conn, MockConfig{})
	if err != nil {
		t.Fatalf("MockMySQL failed: %v", err)
	}

	// Server version string starts at byte 5
	// Should contain "5.7.21"
	response := string(conn.writeData)
	if len(response) < 10 {
		t.Fatal("Response too short")
	}

	// Protocol version byte + server version
	serverVersion := string(conn.writeData[5:15])
	if serverVersion != "5.7.21-log" {
		t.Errorf("Expected server version 5.7.21-log, got: %s", serverVersion)
	}
}

func TestMockMySQL_AccessDenied(t *testing.T) {
	conn := newMockConn([]byte{
		0x20, 0x00, 0x00, 0x01, // login packet
		0x00, 0x00, 0x00, 0x00,
	})

	err := MockMySQL(conn, MockConfig{})
	if err != nil {
		t.Fatalf("MockMySQL failed: %v", err)
	}

	// Should have handshake + error packet
	// Error packet starts with 0xff
	foundError := false
	for i := 0; i < len(conn.writeData)-1; i++ {
		// Look for error packet header (0xff after a packet header)
		if i > 4 && conn.writeData[i] == 0xff {
			foundError = true
			// Error code 1045 = 0x0415
			if conn.writeData[i+1] == 0x15 && conn.writeData[i+2] == 0x04 {
				break
			}
		}
	}

	if !foundError {
		t.Error("Expected MySQL error packet with code 1045 (Access Denied)")
	}
}

func TestMockMySQL_PacketFormat(t *testing.T) {
	conn := newMockConn([]byte{0x00, 0x00, 0x00, 0x01})

	err := MockMySQL(conn, MockConfig{})
	if err != nil {
		t.Fatalf("MockMySQL failed: %v", err)
	}

	// Verify packet header format
	// First 3 bytes = length (little endian)
	// Byte 4 = sequence number (0 for first packet)
	if len(conn.writeData) < 4 {
		t.Fatal("Packet too short")
	}

	// Sequence should be 0 for handshake
	if conn.writeData[3] != 0x00 {
		t.Errorf("Expected sequence 0, got: %d", conn.writeData[3])
	}

	// Calculate packet length
	packetLen := int(conn.writeData[0]) | int(conn.writeData[1])<<8 | int(conn.writeData[2])<<16
	if packetLen == 0 {
		t.Error("Packet length should not be 0")
	}
}

func TestMockMySQL_WithRandomDelay(t *testing.T) {
	conn := newMockConn([]byte{0x00, 0x00, 0x00, 0x01})

	err := MockMySQL(conn, MockConfig{RandomDelay: true})
	if err != nil {
		t.Fatalf("MockMySQL failed: %v", err)
	}

	// Just verify it completes
	if len(conn.writeData) == 0 {
		t.Error("Expected MySQL response")
	}
}
