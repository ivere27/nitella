package mockproto

import (
	"bytes"
	"testing"
)

func TestMockMSSQL_TDSResponse(t *testing.T) {
	conn := newMockConn([]byte{})

	err := MockMSSQL(conn)
	if err != nil {
		t.Fatalf("MockMSSQL failed: %v", err)
	}

	// Should send TDS pre-login response
	if len(conn.writeData) == 0 {
		t.Fatal("Expected TDS response")
	}

	// TDS packet type 0x04 = response
	if conn.writeData[0] != 0x04 {
		t.Errorf("Expected TDS packet type 0x04, got: 0x%x", conn.writeData[0])
	}

	// Status byte 0x01 = end of message
	if conn.writeData[1] != 0x01 {
		t.Errorf("Expected TDS status 0x01, got: 0x%x", conn.writeData[1])
	}
}

func TestMockMSSQL_PacketLength(t *testing.T) {
	conn := newMockConn([]byte{})

	err := MockMSSQL(conn)
	if err != nil {
		t.Fatalf("MockMSSQL failed: %v", err)
	}

	// TDS header: type(1) + status(1) + length(2) + channel(2) + packet#(1) + window(1)
	if len(conn.writeData) < 8 {
		t.Errorf("Expected at least 8 bytes for TDS header, got: %d", len(conn.writeData))
	}

	// Length is bytes 2-3 (big endian)
	length := int(conn.writeData[2])<<8 | int(conn.writeData[3])

	// Actual response length should match header length
	if len(conn.writeData) != length {
		t.Errorf("Response length %d doesn't match TDS header length %d", len(conn.writeData), length)
	}
}

func TestMockRDP_X224Response(t *testing.T) {
	conn := newMockConn([]byte{})

	err := MockRDP(conn)
	if err != nil {
		t.Fatalf("MockRDP failed: %v", err)
	}

	// Should send TPKT + X.224 Connection Confirm
	if len(conn.writeData) == 0 {
		t.Fatal("Expected RDP response")
	}

	// TPKT version 3
	if conn.writeData[0] != 0x03 {
		t.Errorf("Expected TPKT version 3, got: 0x%x", conn.writeData[0])
	}

	// Reserved byte 0
	if conn.writeData[1] != 0x00 {
		t.Errorf("Expected TPKT reserved 0, got: 0x%x", conn.writeData[1])
	}
}

func TestMockRDP_TPKTLength(t *testing.T) {
	conn := newMockConn([]byte{})

	err := MockRDP(conn)
	if err != nil {
		t.Fatalf("MockRDP failed: %v", err)
	}

	// TPKT length is bytes 2-3 (big endian)
	length := int(conn.writeData[2])<<8 | int(conn.writeData[3])
	if length != 0x13 { // 19 bytes
		t.Errorf("Expected TPKT length 19, got: %d", length)
	}

	// Actual response should match TPKT length
	if len(conn.writeData) != length {
		t.Errorf("Response length %d doesn't match TPKT length %d", len(conn.writeData), length)
	}
}

func TestMockRDP_X224ConnectionConfirm(t *testing.T) {
	conn := newMockConn([]byte{})

	err := MockRDP(conn)
	if err != nil {
		t.Fatalf("MockRDP failed: %v", err)
	}

	// X.224 CC (Connection Confirm) code is 0xd0
	// It's at offset 5 in our response
	if len(conn.writeData) > 5 && conn.writeData[5] != 0xd0 {
		t.Errorf("Expected X.224 CC code 0xd0, got: 0x%x", conn.writeData[5])
	}
}

func TestMockTelnet_Negotiation(t *testing.T) {
	conn := newMockConn([]byte{})

	err := MockTelnet(conn, MockConfig{})
	if err != nil {
		t.Fatalf("MockTelnet failed: %v", err)
	}

	// Should send telnet negotiation
	if len(conn.writeData) == 0 {
		t.Fatal("Expected Telnet response")
	}

	// Telnet commands start with IAC (0xff)
	if conn.writeData[0] != 0xff {
		t.Errorf("Expected Telnet IAC (0xff), got: 0x%x", conn.writeData[0])
	}
}

func TestMockTelnet_DOCommands(t *testing.T) {
	conn := newMockConn([]byte{})

	err := MockTelnet(conn, MockConfig{})
	if err != nil {
		t.Fatalf("MockTelnet failed: %v", err)
	}

	// Should contain DO commands (0xfd)
	foundDO := false
	for i := 0; i < len(conn.writeData)-1; i++ {
		if conn.writeData[i] == 0xff && conn.writeData[i+1] == 0xfd {
			foundDO = true
			break
		}
	}

	if !foundDO {
		t.Error("Expected Telnet DO command (0xfd)")
	}
}

func TestMockTelnet_LoginBanner(t *testing.T) {
	conn := newMockConn([]byte{})

	err := MockTelnet(conn, MockConfig{})
	if err != nil {
		t.Fatalf("MockTelnet failed: %v", err)
	}

	response := string(conn.writeData)

	// Should contain login prompt
	if len(response) == 0 {
		t.Fatal("Expected response")
	}

	// Check for "Username:" prompt
	if !bytes.Contains(conn.writeData, []byte("Username:")) {
		t.Error("Expected 'Username:' prompt in Telnet banner")
	}
}

func TestMockTelnet_UserAccessVerification(t *testing.T) {
	conn := newMockConn([]byte{})

	err := MockTelnet(conn, MockConfig{})
	if err != nil {
		t.Fatalf("MockTelnet failed: %v", err)
	}

	// Check for Cisco-style banner
	if !bytes.Contains(conn.writeData, []byte("User Access Verification")) {
		t.Error("Expected 'User Access Verification' banner")
	}
}
