package integration

import (
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"encoding/json"
	"testing"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	proxypb "github.com/ivere27/nitella/pkg/api/proxy"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/ivere27/nitella/pkg/node"
	"github.com/ivere27/nitella/pkg/p2p"
)

// ===== Unit Tests for E2E Encryption =====

func TestApproval_E2EEncryption_NodeToUser(t *testing.T) {
	// Simulate node encrypting approval request for user
	userPub, userPriv, _ := ed25519.GenerateKey(rand.Reader)

	// Node creates an approval request payload
	payload := []byte(`{"request_id":"req-123","source_ip":"1.2.3.4","dest":"db:5432","geo":"US"}`)

	// Encrypt with user's public key
	encrypted, err := nitellacrypto.Encrypt(payload, userPub)
	if err != nil {
		t.Fatalf("Node encryption failed: %v", err)
	}

	// User decrypts
	decrypted, err := nitellacrypto.Decrypt(encrypted, userPriv)
	if err != nil {
		t.Fatalf("User decryption failed: %v", err)
	}

	if string(decrypted) != string(payload) {
		t.Error("Payload mismatch after E2E encryption round trip")
	}
}

func TestApproval_E2EEncryption_UserToNode(t *testing.T) {
	// Simulate user encrypting approval decision for node
	nodePub, nodePriv, _ := ed25519.GenerateKey(rand.Reader)
	userPub, userPriv, _ := ed25519.GenerateKey(rand.Reader)

	// User creates a signed decision
	decision := []byte(`{"request_id":"req-123","action":"allow","duration":3600}`)

	// User signs and encrypts
	encrypted, err := nitellacrypto.EncryptWithSignature(decision, nodePub, userPriv, "user-fingerprint-123")
	if err != nil {
		t.Fatalf("User encryption failed: %v", err)
	}

	// Node decrypts
	decrypted, err := nitellacrypto.Decrypt(encrypted, nodePriv)
	if err != nil {
		t.Fatalf("Node decryption failed: %v", err)
	}

	if string(decrypted) != string(decision) {
		t.Error("Decision mismatch after E2E encryption round trip")
	}

	// Verify signature
	sigInput := append(encrypted.EphemeralPubKey, encrypted.Nonce...)
	sigInput = append(sigInput, encrypted.Ciphertext...)
	err = nitellacrypto.Verify(sigInput, encrypted.Signature, userPub)
	if err != nil {
		t.Errorf("Signature verification failed: %v", err)
	}
}

func TestApproval_SignatureVerification_InvalidSig(t *testing.T) {
	nodePub, nodePriv, _ := ed25519.GenerateKey(rand.Reader)
	_, userPriv, _ := ed25519.GenerateKey(rand.Reader)
	attackerPub, _, _ := ed25519.GenerateKey(rand.Reader)

	decision := []byte(`{"request_id":"req-123","action":"allow"}`)

	// User signs and encrypts
	encrypted, _ := nitellacrypto.EncryptWithSignature(decision, nodePub, userPriv, "user-123")

	// Node decrypts successfully
	_, err := nitellacrypto.Decrypt(encrypted, nodePriv)
	if err != nil {
		t.Fatalf("Decryption should succeed: %v", err)
	}

	// But signature verification with attacker's key should fail
	sigInput := append(encrypted.EphemeralPubKey, encrypted.Nonce...)
	sigInput = append(sigInput, encrypted.Ciphertext...)
	err = nitellacrypto.Verify(sigInput, encrypted.Signature, attackerPub)
	if err == nil {
		t.Error("Signature verification should fail with wrong public key")
	}
}

// ===== P2P Flow Tests =====

func TestApproval_P2P_MessageEncryption(t *testing.T) {
	nodePub, nodePriv, _ := ed25519.GenerateKey(rand.Reader)
	cliPub, cliPriv, _ := ed25519.GenerateKey(rand.Reader)

	// Node sends approval request (encrypted with CLI's key)
	req := &p2p.ApprovalRequest{
		RequestID:  "req-p2p-001",
		NodeID:     "node-001",
		SourceIP:   "192.168.1.100",
		DestAddr:   "internal-db:5432",
		GeoCountry: "KR",
		GeoCity:    "Seoul",
		Severity:   "high",
	}

	msg, _ := p2p.NewP2PMessage(p2p.MessageTypeApprovalRequest, req)
	encrypted, err := p2p.EncryptP2PMessage(msg, cliPub)
	if err != nil {
		t.Fatalf("P2P encrypt failed: %v", err)
	}

	// CLI decrypts
	decrypted, err := p2p.DecryptP2PMessage(encrypted, cliPriv)
	if err != nil {
		t.Fatalf("P2P decrypt failed: %v", err)
	}

	parsedReq, _ := decrypted.ParseApprovalRequest()
	if parsedReq.RequestID != req.RequestID {
		t.Error("Request ID mismatch")
	}

	// CLI sends decision (encrypted with Node's key)
	decision := &p2p.ApprovalDecision{
		RequestID:       req.RequestID,
		Action:          1, // Allow
		DurationSeconds: 3600,
		Reason:          "Approved via P2P",
	}

	decisionMsg, _ := p2p.NewP2PMessage(p2p.MessageTypeApprovalDecision, decision)
	encryptedDecision, err := p2p.EncryptP2PMessage(decisionMsg, nodePub)
	if err != nil {
		t.Fatalf("P2P encrypt decision failed: %v", err)
	}

	// Node decrypts
	decryptedDecision, err := p2p.DecryptP2PMessage(encryptedDecision, nodePriv)
	if err != nil {
		t.Fatalf("P2P decrypt decision failed: %v", err)
	}

	parsedDecision, _ := decryptedDecision.ParseApprovalDecision()
	if parsedDecision.RequestID != decision.RequestID {
		t.Error("Decision request ID mismatch")
	}
	if parsedDecision.Action != decision.Action {
		t.Error("Decision action mismatch")
	}
}

func TestApproval_P2P_AuthHandshake(t *testing.T) {
	// Simulate P2P authentication handshake
	nodeID := "node-auth-test"
	nodePub, nodePriv, _ := ed25519.GenerateKey(rand.Reader)
	cliPub, cliPriv, _ := ed25519.GenerateKey(rand.Reader)

	// CLI sends challenge
	challenge := make([]byte, 32)
	rand.Read(challenge)

	// CLI would send this to node
	_ = p2p.AuthMessage{
		Type:      p2p.AuthChallenge,
		Challenge: challenge,
		UserID:    "cli-user-123",
		PublicKey: cliPub,
	}

	// Node responds with signature
	sig, err := nitellacrypto.Sign(challenge, nodePriv)
	if err != nil {
		t.Fatalf("Node signing failed: %v", err)
	}

	nodeResponse := p2p.AuthMessage{
		Type:      p2p.AuthResponse,
		UserID:    nodeID,
		PublicKey: nodePub,
		Signature: sig,
		Challenge: challenge,
	}

	// CLI verifies node's response
	err = nitellacrypto.Verify(nodeResponse.Challenge, nodeResponse.Signature, ed25519.PublicKey(nodeResponse.PublicKey))
	if err != nil {
		t.Errorf("Node signature verification failed: %v", err)
	}

	// Node also challenges CLI
	nodeChallenge := make([]byte, 32)
	rand.Read(nodeChallenge)

	cliSig, _ := nitellacrypto.Sign(nodeChallenge, cliPriv)

	// Node verifies CLI's signature
	err = nitellacrypto.Verify(nodeChallenge, cliSig, cliPub)
	if err != nil {
		t.Errorf("CLI signature verification failed: %v", err)
	}
}


// ===== Active Approval Management Tests =====

func TestApproval_Management_ListActiveApprovals(t *testing.T) {
	cache := node.NewApprovalCache()

	// Add some approvals
	cache.Add("1.2.3.4", "rule-1", "proxy-1", "", true, 1*time.Hour)
	cache.AddWithGeo("5.6.7.8", "rule-2", "proxy-1", "", false, 1*time.Hour, "CN", "Beijing", "China Telecom")
	cache.Add("10.0.0.1", "default", "proxy-2", "session-123", true, 30*time.Minute)

	active := cache.GetActiveApprovals()
	if len(active) != 3 {
		t.Errorf("Expected 3 active approvals, got %d", len(active))
	}

	// Check geo info is preserved
	var foundGeo bool
	for _, entry := range active {
		if entry.SourceIP == "5.6.7.8" {
			foundGeo = true
			if entry.GeoCountry != "CN" {
				t.Error("GeoCountry should be CN")
			}
			if entry.GeoCity != "Beijing" {
				t.Error("GeoCity should be Beijing")
			}
			if entry.Decision {
				t.Error("Decision should be false (blocked)")
			}
		}
	}
	if !foundGeo {
		t.Error("Should find entry with geo info")
	}
}

func TestApproval_Management_CancelApproval(t *testing.T) {
	cache := node.NewApprovalCache()
	closer := &mockConnectionCloser{}
	cache.SetConnectionCloser(closer)

	// Add approval with connections (with dummy byte counters)
	var b1In, b1Out, b2In, b2Out int64
	cache.Add("1.2.3.4", "rule-1", "proxy-1", "", true, 1*time.Hour)
	cache.SetConnID("1.2.3.4", "rule-1", "", "conn-001", &b1In, &b1Out)
	cache.SetConnID("1.2.3.4", "rule-1", "", "conn-002", &b2In, &b2Out)

	// Verify it exists
	found, _ := cache.Check("1.2.3.4", "rule-1", "")
	if !found {
		t.Fatal("Approval should exist")
	}

	// Get entry for connection info
	entry := cache.GetEntry("1.2.3.4", "rule-1", "")
	if len(entry.LiveConns) != 2 {
		t.Errorf("Expected 2 connections, got %d", len(entry.LiveConns))
	}

	// Cancel (remove)
	cache.Remove("1.2.3.4", "rule-1", "")

	// Verify it's gone
	found, _ = cache.Check("1.2.3.4", "rule-1", "")
	if found {
		t.Error("Approval should be removed")
	}
}

func TestApproval_Management_ByteTracking(t *testing.T) {
	cache := node.NewApprovalCache()

	cache.Add("1.2.3.4", "rule-1", "proxy-1", "", true, 1*time.Hour)

	// Update bytes multiple times
	cache.UpdateBytes("1.2.3.4", "rule-1", "", 1000, 500)
	cache.UpdateBytes("1.2.3.4", "rule-1", "", 2000, 1000)
	cache.UpdateBytes("1.2.3.4", "rule-1", "", 500, 250)

	entry := cache.GetEntry("1.2.3.4", "rule-1", "")
	if entry.BytesIn != 3500 {
		t.Errorf("Expected BytesIn=3500, got %d", entry.BytesIn)
	}
	if entry.BytesOut != 1750 {
		t.Errorf("Expected BytesOut=1750, got %d", entry.BytesOut)
	}
}

func TestApproval_Management_BlockedCount(t *testing.T) {
	cache := node.NewApprovalCache()

	// Add a block decision
	cache.Add("1.2.3.4", "rule-1", "proxy-1", "", false, 1*time.Hour)

	// Increment blocked count (simulating multiple blocked attempts)
	cache.IncrementBlockedCount("1.2.3.4", "rule-1", "")
	cache.IncrementBlockedCount("1.2.3.4", "rule-1", "")
	cache.IncrementBlockedCount("1.2.3.4", "rule-1", "")

	entry := cache.GetEntry("1.2.3.4", "rule-1", "")
	if entry.BlockedCount != 3 {
		t.Errorf("Expected BlockedCount=3, got %d", entry.BlockedCount)
	}
}

// ===== Approval Manager Tests =====

func TestApproval_Manager_ResolveApproval(t *testing.T) {
	sender := &mockAlertSender{}
	am := node.NewApprovalManager(sender)

	// Start approval request
	done := make(chan struct{})
	var result node.ApprovalResult

	go func() {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		meta := node.ApprovalRequestMeta{
			ProxyID:  "proxy-1",
			SourceIP: "1.2.3.4",
			DestAddr: "db:5432",
		}
		result, _ = am.RequestApproval(ctx, "req-resolve-test", "node-1", "test info", meta)
		close(done)
	}()

	// Wait for request to register
	time.Sleep(50 * time.Millisecond)

	// Resolve with allow
	meta := am.Resolve("req-resolve-test", true, 3600, "")
	if meta == nil {
		t.Error("Resolve should return metadata")
	}

	<-done

	if !result.Allowed {
		t.Error("Result should be allowed")
	}
	if result.Duration != 3600*time.Second {
		t.Errorf("Duration should be 3600s, got %v", result.Duration)
	}
}

// ===== Helper Types =====

type mockAlertSender struct {
	alerts []*common.Alert
}

func (m *mockAlertSender) SendAlert(alert *common.Alert, info string) error {
	m.alerts = append(m.alerts, alert)
	return nil
}

type mockConnectionCloser struct {
	closed []string
}

func (m *mockConnectionCloser) CloseConnection(proxyID, connID string) error {
	m.closed = append(m.closed, connID)
	return nil
}

// ===== Rate Limiting Tests =====

func TestApproval_RateLimiting_TierBased(t *testing.T) {
	// This would test the Hub's rate limiting based on tiers
	// The actual implementation is in pkg/hub/ratelimit/approval.go
	// Here we just verify the concept

	// Free tier: 600/min, 20 max pending (10 RPS * 60)
	// Pro tier: 6000/min, 200 max pending (100 RPS * 60)
	// Business tier: 60000/min, 2000 max pending (1000 RPS * 60)

	t.Log("Rate limiting uses RPC settings from tiers.yaml:")
	t.Log("  - requests_per_minute = rpc.requests_per_second * 60")
	t.Log("  - max_pending = rpc.burst_size")
}

// ===== Proto Message Tests =====

func TestApproval_ProtoMessages(t *testing.T) {
	// Test ResolveApprovalRequest message
	req := &proxypb.ResolveApprovalRequest{
		ReqId:           "req-proto-test",
		Action:          common.ApprovalActionType_APPROVAL_ACTION_TYPE_ALLOW,
		DurationSeconds: 3600,
		Reason:          "Test approval",
	}

	if req.ReqId != "req-proto-test" {
		t.Error("ReqId mismatch")
	}
	if req.Action != common.ApprovalActionType_APPROVAL_ACTION_TYPE_ALLOW {
		t.Error("Action should be ALLOW")
	}
	if req.DurationSeconds != 3600 {
		t.Error("DurationSeconds should be 3600")
	}
}

// ===== E2E Encrypted Approval Decision Tests (CLI -> Node via Hub) =====

func TestApproval_E2EEncryption_CLIToNode_ViaHub(t *testing.T) {
	// Simulate CLI encrypting approval decision for Node
	// Hub acts as blind relay - cannot read the decision
	nodePub, nodePriv, _ := ed25519.GenerateKey(rand.Reader)

	// CLI creates approval decision payload (same format as P2P)
	decision := map[string]interface{}{
		"req_id":   "req-hub-e2e-001",
		"action":   1, // ALLOW
		"duration": 4, // 1_HOUR
		"reason":   "Approved via Hub (E2E)",
	}

	decisionBytes, _ := json.Marshal(decision)

	// CLI encrypts with Node's public key
	encrypted, err := nitellacrypto.Encrypt(decisionBytes, nodePub)
	if err != nil {
		t.Fatalf("CLI encryption failed: %v", err)
	}

	// === Hub receives encrypted blob ===
	// Hub CANNOT decrypt - it just forwards

	// Verify Hub cannot read the content
	// (Hub doesn't have nodePriv, so decryption would fail)
	hubFakeKey := make([]byte, 32) // Random key
	_, hubDecryptErr := nitellacrypto.Decrypt(encrypted, ed25519.NewKeyFromSeed(hubFakeKey))
	if hubDecryptErr == nil {
		t.Error("Hub should NOT be able to decrypt the decision")
	}

	// === Node receives and decrypts ===
	decrypted, err := nitellacrypto.Decrypt(encrypted, nodePriv)
	if err != nil {
		t.Fatalf("Node decryption failed: %v", err)
	}

	var parsedDecision map[string]interface{}
	if err := json.Unmarshal(decrypted, &parsedDecision); err != nil {
		t.Fatalf("Failed to parse decrypted decision: %v", err)
	}

	if parsedDecision["req_id"] != "req-hub-e2e-001" {
		t.Errorf("Request ID mismatch: got %v", parsedDecision["req_id"])
	}
	if int(parsedDecision["action"].(float64)) != 1 {
		t.Errorf("Action mismatch: got %v", parsedDecision["action"])
	}
}

func TestApproval_E2EEncryption_CLIToNode_DenyViaHub(t *testing.T) {
	// Test DENY decision encryption
	nodePub, nodePriv, _ := ed25519.GenerateKey(rand.Reader)

	decision := map[string]interface{}{
		"req_id":   "req-hub-deny-001",
		"action":   2, // BLOCK
		"duration": 0, // N/A for deny
		"reason":   "Denied: suspicious source IP",
	}

	decisionBytes, _ := json.Marshal(decision)

	// CLI encrypts
	encrypted, err := nitellacrypto.Encrypt(decisionBytes, nodePub)
	if err != nil {
		t.Fatalf("CLI encryption failed: %v", err)
	}

	// Node decrypts
	decrypted, err := nitellacrypto.Decrypt(encrypted, nodePriv)
	if err != nil {
		t.Fatalf("Node decryption failed: %v", err)
	}

	var parsedDecision map[string]interface{}
	json.Unmarshal(decrypted, &parsedDecision)

	if int(parsedDecision["action"].(float64)) != 2 {
		t.Errorf("Action should be BLOCK (2), got %v", parsedDecision["action"])
	}
	if parsedDecision["reason"] != "Denied: suspicious source IP" {
		t.Errorf("Reason mismatch")
	}
}

func TestApproval_E2EEncryption_SamePayloadFormat_P2P_And_Hub(t *testing.T) {
	// Verify P2P and Hub use the same encrypted payload format
	// This ensures CLI can use the same encryption logic for both paths
	nodePub, nodePriv, _ := ed25519.GenerateKey(rand.Reader)

	// Create decision (same structure used by both P2P and Hub)
	decision := &p2p.ApprovalDecision{
		RequestID:       "req-unified-001",
		Action:          1, // ALLOW
		DurationSeconds: 3600,
		Reason:          "Approved",
	}

	// Encrypt as P2P message
	p2pMsg, _ := p2p.NewP2PMessage(p2p.MessageTypeApprovalDecision, decision)
	p2pEncrypted, err := p2p.EncryptP2PMessage(p2pMsg, nodePub)
	if err != nil {
		t.Fatalf("P2P encryption failed: %v", err)
	}

	// Node decrypts P2P message
	p2pDecrypted, err := p2p.DecryptP2PMessage(p2pEncrypted, nodePriv)
	if err != nil {
		t.Fatalf("P2P decryption failed: %v", err)
	}

	parsedP2P, _ := p2pDecrypted.ParseApprovalDecision()
	if parsedP2P.RequestID != "req-unified-001" {
		t.Errorf("P2P request ID mismatch")
	}

	// Now encrypt using raw crypto (Hub path)
	decisionBytes, _ := json.Marshal(map[string]interface{}{
		"req_id":   decision.RequestID,
		"action":   decision.Action,
		"duration": decision.DurationSeconds,
		"reason":   decision.Reason,
	})

	hubEncrypted, _ := nitellacrypto.Encrypt(decisionBytes, nodePub)
	hubDecrypted, err := nitellacrypto.Decrypt(hubEncrypted, nodePriv)
	if err != nil {
		t.Fatalf("Hub path decryption failed: %v", err)
	}

	var parsedHub map[string]interface{}
	json.Unmarshal(hubDecrypted, &parsedHub)

	// Both paths should decrypt successfully
	if parsedHub["req_id"] != parsedP2P.RequestID {
		t.Error("P2P and Hub paths should produce same request ID")
	}
}
