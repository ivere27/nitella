package p2p

import (
	"crypto/ed25519"
	"crypto/rand"
	"encoding/json"
	"testing"
)

func TestP2PMessage_MarshalParse(t *testing.T) {
	req := &ApprovalRequest{
		RequestID:  "req-123",
		NodeID:     "node-abc",
		ProxyID:    "proxy-1",
		SourceIP:   "1.2.3.4",
		DestAddr:   "10.0.0.1:5432",
		RuleID:     "rule-1",
		GeoCountry: "US",
		GeoCity:    "New York",
		GeoISP:     "Comcast",
		Severity:   "high",
	}

	msg, err := NewP2PMessage(MessageTypeApprovalRequest, req)
	if err != nil {
		t.Fatalf("NewP2PMessage failed: %v", err)
	}

	if msg.Type != MessageTypeApprovalRequest {
		t.Errorf("Expected type %s, got %s", MessageTypeApprovalRequest, msg.Type)
	}

	data, err := msg.Marshal()
	if err != nil {
		t.Fatalf("Marshal failed: %v", err)
	}

	parsed, err := ParseP2PMessage(data)
	if err != nil {
		t.Fatalf("ParseP2PMessage failed: %v", err)
	}

	if parsed.Type != msg.Type {
		t.Errorf("Type mismatch after parse")
	}

	parsedReq, err := parsed.ParseApprovalRequest()
	if err != nil {
		t.Fatalf("ParseApprovalRequest failed: %v", err)
	}

	if parsedReq.RequestID != req.RequestID {
		t.Errorf("RequestID mismatch: expected %s, got %s", req.RequestID, parsedReq.RequestID)
	}
	if parsedReq.SourceIP != req.SourceIP {
		t.Errorf("SourceIP mismatch")
	}
	if parsedReq.GeoCountry != req.GeoCountry {
		t.Errorf("GeoCountry mismatch")
	}
}

func TestP2PMessage_ApprovalDecision(t *testing.T) {
	decision := &ApprovalDecision{
		RequestID:       "req-123",
		Action:          1, // Allow
		DurationSeconds: 3600,
		Reason:          "Approved by admin",
	}

	msg, err := NewP2PMessage(MessageTypeApprovalDecision, decision)
	if err != nil {
		t.Fatalf("NewP2PMessage failed: %v", err)
	}

	data, _ := msg.Marshal()
	parsed, _ := ParseP2PMessage(data)

	parsedDecision, err := parsed.ParseApprovalDecision()
	if err != nil {
		t.Fatalf("ParseApprovalDecision failed: %v", err)
	}

	if parsedDecision.RequestID != decision.RequestID {
		t.Errorf("RequestID mismatch")
	}
	if parsedDecision.Action != decision.Action {
		t.Errorf("Action mismatch")
	}
	if parsedDecision.DurationSeconds != decision.DurationSeconds {
		t.Errorf("DurationSeconds mismatch")
	}
}

func TestEncryptP2PMessage(t *testing.T) {
	recipientPub, recipientPriv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatalf("Failed to generate key: %v", err)
	}

	req := &ApprovalRequest{
		RequestID:  "req-123",
		NodeID:     "node-abc",
		ProxyID:    "proxy-1",
		SourceIP:   "1.2.3.4",
		DestAddr:   "10.0.0.1:5432",
		GeoCountry: "US",
	}

	msg, _ := NewP2PMessage(MessageTypeApprovalRequest, req)

	// Encrypt
	encryptedData, err := EncryptP2PMessage(msg, recipientPub)
	if err != nil {
		t.Fatalf("EncryptP2PMessage failed: %v", err)
	}

	// Parse the encrypted wrapper
	wrapper, err := ParseP2PMessage(encryptedData)
	if err != nil {
		t.Fatalf("Failed to parse encrypted wrapper: %v", err)
	}

	if wrapper.Type != MessageTypeEncrypted {
		t.Errorf("Expected encrypted type, got %s", wrapper.Type)
	}

	// Decrypt
	decrypted, err := DecryptP2PMessage(encryptedData, recipientPriv)
	if err != nil {
		t.Fatalf("DecryptP2PMessage failed: %v", err)
	}

	if decrypted.Type != MessageTypeApprovalRequest {
		t.Errorf("Decrypted message type mismatch: expected %s, got %s", MessageTypeApprovalRequest, decrypted.Type)
	}

	parsedReq, err := decrypted.ParseApprovalRequest()
	if err != nil {
		t.Fatalf("ParseApprovalRequest failed: %v", err)
	}

	if parsedReq.RequestID != req.RequestID {
		t.Errorf("RequestID mismatch after decrypt")
	}
	if parsedReq.SourceIP != req.SourceIP {
		t.Errorf("SourceIP mismatch after decrypt")
	}
}

func TestDecryptP2PMessage_WrongKey(t *testing.T) {
	recipientPub, _, _ := ed25519.GenerateKey(rand.Reader)
	_, wrongPriv, _ := ed25519.GenerateKey(rand.Reader)

	req := &ApprovalRequest{RequestID: "req-123"}
	msg, _ := NewP2PMessage(MessageTypeApprovalRequest, req)

	encryptedData, _ := EncryptP2PMessage(msg, recipientPub)

	// Try to decrypt with wrong key
	_, err := DecryptP2PMessage(encryptedData, wrongPriv)
	if err == nil {
		t.Error("Decryption with wrong key should fail")
	}
}

func TestDecryptP2PMessage_RejectsUnencrypted(t *testing.T) {
	_, privKey, _ := ed25519.GenerateKey(rand.Reader)

	// Create an unencrypted message
	req := &ApprovalRequest{RequestID: "req-123"}
	msg, _ := NewP2PMessage(MessageTypeApprovalRequest, req)
	data, _ := msg.Marshal()

	// Decrypt must reject unencrypted messages
	_, err := DecryptP2PMessage(data, privKey)
	if err == nil {
		t.Fatal("DecryptP2PMessage should reject unencrypted messages")
	}
}

func TestAuthMessage_Parse(t *testing.T) {
	pubKey, privKey, _ := ed25519.GenerateKey(rand.Reader)
	challenge := make([]byte, 32)
	rand.Read(challenge)

	authMsg := AuthMessage{
		Type:      AuthChallenge,
		Challenge: challenge,
		UserID:    "user-123",
		PublicKey: pubKey,
		CertPEM:   "-----BEGIN CERTIFICATE-----\ntest\n-----END CERTIFICATE-----",
	}

	data, _ := json.Marshal(authMsg)

	if !IsAuthMessage(data) {
		t.Error("Should recognize auth message")
	}

	parsed, err := ParseAuthMessage(data)
	if err != nil {
		t.Fatalf("ParseAuthMessage failed: %v", err)
	}

	if parsed.Type != AuthChallenge {
		t.Errorf("Type mismatch")
	}
	if parsed.UserID != authMsg.UserID {
		t.Errorf("UserID mismatch")
	}

	// Not an auth message
	regularMsg, _ := NewP2PMessage(MessageTypeApprovalRequest, &ApprovalRequest{})
	regularData, _ := regularMsg.Marshal()
	if IsAuthMessage(regularData) {
		t.Error("Should not recognize regular message as auth")
	}

	_ = privKey // silence unused warning
}

func TestAuthMessage_AllTypes(t *testing.T) {
	types := []AuthMessageType{AuthChallenge, AuthResponse, AuthSuccess, AuthFailed}

	for _, msgType := range types {
		authMsg := AuthMessage{Type: msgType}
		data, _ := json.Marshal(authMsg)

		if !IsAuthMessage(data) {
			t.Errorf("Should recognize %s as auth message", msgType)
		}

		parsed, err := ParseAuthMessage(data)
		if err != nil {
			t.Errorf("ParseAuthMessage failed for %s: %v", msgType, err)
		}
		if parsed.Type != msgType {
			t.Errorf("Type mismatch for %s", msgType)
		}
	}
}

func TestEncryptDecryptP2PMessage_RoundTrip(t *testing.T) {
	// Simulate Node -> CLI -> Node round trip
	nodePub, nodePriv, _ := ed25519.GenerateKey(rand.Reader)
	cliPub, cliPriv, _ := ed25519.GenerateKey(rand.Reader)

	// Node sends approval request to CLI (encrypted with CLI's pubkey)
	approvalReq := &ApprovalRequest{
		RequestID:  "req-456",
		SourceIP:   "192.168.1.100",
		DestAddr:   "db.internal:5432",
		GeoCountry: "JP",
		GeoCity:    "Tokyo",
	}
	reqMsg, _ := NewP2PMessage(MessageTypeApprovalRequest, approvalReq)
	encryptedReq, err := EncryptP2PMessage(reqMsg, cliPub)
	if err != nil {
		t.Fatalf("Encrypt request failed: %v", err)
	}

	// CLI decrypts request
	decryptedReq, err := DecryptP2PMessage(encryptedReq, cliPriv)
	if err != nil {
		t.Fatalf("Decrypt request failed: %v", err)
	}
	parsedReq, _ := decryptedReq.ParseApprovalRequest()
	if parsedReq.RequestID != "req-456" {
		t.Error("Request ID mismatch")
	}

	// CLI sends decision to Node (encrypted with Node's pubkey)
	decision := &ApprovalDecision{
		RequestID:       "req-456",
		Action:          1,
		DurationSeconds: 3600,
	}
	decisionMsg, _ := NewP2PMessage(MessageTypeApprovalDecision, decision)
	encryptedDecision, err := EncryptP2PMessage(decisionMsg, nodePub)
	if err != nil {
		t.Fatalf("Encrypt decision failed: %v", err)
	}

	// Node decrypts decision
	decryptedDecision, err := DecryptP2PMessage(encryptedDecision, nodePriv)
	if err != nil {
		t.Fatalf("Decrypt decision failed: %v", err)
	}
	parsedDecision, _ := decryptedDecision.ParseApprovalDecision()
	if parsedDecision.RequestID != "req-456" {
		t.Error("Decision request ID mismatch")
	}
	if parsedDecision.Action != 1 {
		t.Error("Decision action mismatch")
	}
}

// Benchmark
func BenchmarkEncryptP2PMessage(b *testing.B) {
	pubKey, _, _ := ed25519.GenerateKey(rand.Reader)
	req := &ApprovalRequest{
		RequestID:  "req-123",
		SourceIP:   "1.2.3.4",
		DestAddr:   "10.0.0.1:5432",
		GeoCountry: "US",
		GeoCity:    "New York",
		GeoISP:     "Comcast",
	}
	msg, _ := NewP2PMessage(MessageTypeApprovalRequest, req)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		EncryptP2PMessage(msg, pubKey)
	}
}

func BenchmarkDecryptP2PMessage(b *testing.B) {
	pubKey, privKey, _ := ed25519.GenerateKey(rand.Reader)
	req := &ApprovalRequest{RequestID: "req-123"}
	msg, _ := NewP2PMessage(MessageTypeApprovalRequest, req)
	encrypted, _ := EncryptP2PMessage(msg, pubKey)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		DecryptP2PMessage(encrypted, privKey)
	}
}
