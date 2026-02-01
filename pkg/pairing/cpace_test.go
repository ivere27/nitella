package pairing

import (
	"bytes"
	"testing"
)

func TestCPaceExchange(t *testing.T) {
	password := []byte("tiger-castle")

	// Create sessions for both sides
	cli, err := NewCPaceSession(RoleCLI, password)
	if err != nil {
		t.Fatalf("failed to create CLI session: %v", err)
	}

	node, err := NewCPaceSession(RoleNode, password)
	if err != nil {
		t.Fatalf("failed to create Node session: %v", err)
	}

	// Exchange public values
	cliPub := cli.GetPublicValue()
	nodePub := node.GetPublicValue()

	// Set peer public values
	if err := cli.SetPeerPublic(nodePub); err != nil {
		t.Fatalf("CLI failed to set peer public: %v", err)
	}
	if err := node.SetPeerPublic(cliPub); err != nil {
		t.Fatalf("Node failed to set peer public: %v", err)
	}

	// Verify both derived the same key
	if !bytes.Equal(cli.GetSharedKey(), node.GetSharedKey()) {
		t.Fatal("shared keys do not match")
	}

	// Verify emoji fingerprints match
	if cli.DeriveConfirmationEmoji() != node.DeriveConfirmationEmoji() {
		t.Fatal("emoji fingerprints do not match")
	}

	t.Logf("Shared key derived successfully")
	t.Logf("Emoji fingerprint: %s", cli.DeriveConfirmationEmoji())
}

func TestCPaceWrongPassword(t *testing.T) {
	// Create sessions with different passwords
	cli, _ := NewCPaceSession(RoleCLI, []byte("tiger-castle"))
	node, _ := NewCPaceSession(RoleNode, []byte("wrong-password"))

	// Exchange public values
	cli.SetPeerPublic(node.GetPublicValue())
	node.SetPeerPublic(cli.GetPublicValue())

	// Keys should NOT match
	if bytes.Equal(cli.GetSharedKey(), node.GetSharedKey()) {
		t.Fatal("shared keys should NOT match with different passwords")
	}
}

func TestCPaceEncryptDecrypt(t *testing.T) {
	password := []byte("test-password")

	cli, _ := NewCPaceSession(RoleCLI, password)
	node, _ := NewCPaceSession(RoleNode, password)

	// Complete exchange
	cli.SetPeerPublic(node.GetPublicValue())
	node.SetPeerPublic(cli.GetPublicValue())

	// CLI encrypts, Node decrypts
	plaintext := []byte("Hello from CLI!")
	ciphertext, nonce, err := cli.Encrypt(plaintext)
	if err != nil {
		t.Fatalf("encryption failed: %v", err)
	}

	decrypted, err := node.Decrypt(ciphertext, nonce)
	if err != nil {
		t.Fatalf("decryption failed: %v", err)
	}

	if !bytes.Equal(plaintext, decrypted) {
		t.Fatal("decrypted text does not match original")
	}

	// Node encrypts, CLI decrypts
	plaintext2 := []byte("Hello from Node!")
	ciphertext2, nonce2, _ := node.Encrypt(plaintext2)
	decrypted2, err := cli.Decrypt(ciphertext2, nonce2)
	if err != nil {
		t.Fatalf("decryption failed: %v", err)
	}

	if !bytes.Equal(plaintext2, decrypted2) {
		t.Fatal("decrypted text does not match original")
	}
}

func TestCPaceRejectsIdentityPoint(t *testing.T) {
	cli, _ := NewCPaceSession(RoleCLI, []byte("password"))

	// Try to set all-zeros as peer public (identity point)
	identityPoint := make([]byte, PointSize)
	err := cli.SetPeerPublic(identityPoint)
	if err == nil {
		t.Fatal("should reject identity point")
	}
}

func TestCPaceInvalidRole(t *testing.T) {
	_, err := NewCPaceSession("invalid", []byte("password"))
	if err == nil {
		t.Fatal("should reject invalid role")
	}
}

// Test PakeSession wrapper
func TestPakeSessionWrapper(t *testing.T) {
	password := CodeToBytes("tiger-castle")

	// Create sessions using old API
	cli, err := NewPakeSession(RoleCLI, password)
	if err != nil {
		t.Fatalf("failed to create CLI session: %v", err)
	}

	node, err := NewPakeSession(RoleNode, password)
	if err != nil {
		t.Fatalf("failed to create Node session: %v", err)
	}

	// CLI sends init
	cliInit, _ := cli.GetInitMessage()

	// Node processes init and replies
	nodeReply, err := node.ProcessInitMessage(cliInit)
	if err != nil {
		t.Fatalf("Node failed to process init: %v", err)
	}

	// CLI processes reply
	if err := cli.ProcessReplyMessage(nodeReply); err != nil {
		t.Fatalf("CLI failed to process reply: %v", err)
	}

	// Both should have keys
	if !cli.IsComplete() || !node.IsComplete() {
		t.Fatal("exchange not complete")
	}

	// Keys should match
	if !bytes.Equal(cli.GetSharedKey(), node.GetSharedKey()) {
		t.Fatal("shared keys do not match")
	}

	// Test encrypt/decrypt
	plaintext := []byte("test message")
	ct, nonce, _ := cli.Encrypt(plaintext)
	decrypted, err := node.Decrypt(ct, nonce)
	if err != nil {
		t.Fatalf("decrypt failed: %v", err)
	}
	if !bytes.Equal(plaintext, decrypted) {
		t.Fatal("decrypted mismatch")
	}

	t.Logf("PakeSession wrapper works correctly")
	t.Logf("Emoji: %s", cli.DeriveConfirmationEmoji())
}

// Benchmark CPace exchange
func BenchmarkCPaceExchange(b *testing.B) {
	password := []byte("benchmark-password")

	for i := 0; i < b.N; i++ {
		cli, _ := NewCPaceSession(RoleCLI, password)
		node, _ := NewCPaceSession(RoleNode, password)

		cli.SetPeerPublic(node.GetPublicValue())
		node.SetPeerPublic(cli.GetPublicValue())
	}
}
