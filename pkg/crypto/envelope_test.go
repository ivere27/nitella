package crypto

import (
	"bytes"
	"crypto/ed25519"
	"crypto/rand"
	"testing"
)

func TestEncryptDecrypt(t *testing.T) {
	// Generate key pair
	pubKey, privKey, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatalf("Failed to generate key pair: %v", err)
	}

	plaintext := []byte("Hello, this is a secret message for approval testing!")

	// Encrypt
	encrypted, err := Encrypt(plaintext, pubKey)
	if err != nil {
		t.Fatalf("Encrypt failed: %v", err)
	}

	// Verify encrypted payload has required fields
	if len(encrypted.EphemeralPubKey) == 0 {
		t.Error("EphemeralPubKey should not be empty")
	}
	if len(encrypted.Nonce) == 0 {
		t.Error("Nonce should not be empty")
	}
	if len(encrypted.Ciphertext) == 0 {
		t.Error("Ciphertext should not be empty")
	}

	// Decrypt
	decrypted, err := Decrypt(encrypted, privKey)
	if err != nil {
		t.Fatalf("Decrypt failed: %v", err)
	}

	if !bytes.Equal(plaintext, decrypted) {
		t.Errorf("Decrypted text doesn't match original.\nExpected: %s\nGot: %s", plaintext, decrypted)
	}
}

func TestEncryptDecrypt_LargePayload(t *testing.T) {
	pubKey, privKey, _ := ed25519.GenerateKey(rand.Reader)

	// Large payload (simulating approval request with geo info)
	plaintext := make([]byte, 10000)
	rand.Read(plaintext)

	encrypted, err := Encrypt(plaintext, pubKey)
	if err != nil {
		t.Fatalf("Encrypt large payload failed: %v", err)
	}

	decrypted, err := Decrypt(encrypted, privKey)
	if err != nil {
		t.Fatalf("Decrypt large payload failed: %v", err)
	}

	if !bytes.Equal(plaintext, decrypted) {
		t.Error("Large payload decryption mismatch")
	}
}

func TestEncryptDecrypt_WrongKey(t *testing.T) {
	pubKey1, _, _ := ed25519.GenerateKey(rand.Reader)
	_, privKey2, _ := ed25519.GenerateKey(rand.Reader)

	plaintext := []byte("Secret message")

	// Encrypt with key 1
	encrypted, _ := Encrypt(plaintext, pubKey1)

	// Try to decrypt with key 2 - should fail
	_, err := Decrypt(encrypted, privKey2)
	if err == nil {
		t.Error("Decryption with wrong key should fail")
	}
}

func TestEncrypt_InvalidPublicKey(t *testing.T) {
	plaintext := []byte("test")

	// Empty key
	_, err := Encrypt(plaintext, nil)
	if err == nil {
		t.Error("Encrypt with nil key should fail")
	}

	// Wrong size key
	_, err = Encrypt(plaintext, []byte("too short"))
	if err == nil {
		t.Error("Encrypt with wrong size key should fail")
	}
}

func TestDecrypt_InvalidPrivateKey(t *testing.T) {
	pubKey, _, _ := ed25519.GenerateKey(rand.Reader)
	plaintext := []byte("test")

	encrypted, _ := Encrypt(plaintext, pubKey)

	// Empty key
	_, err := Decrypt(encrypted, nil)
	if err == nil {
		t.Error("Decrypt with nil key should fail")
	}

	// Wrong size key
	_, err = Decrypt(encrypted, []byte("too short"))
	if err == nil {
		t.Error("Decrypt with wrong size key should fail")
	}
}

func TestDecrypt_TamperedCiphertext(t *testing.T) {
	pubKey, privKey, _ := ed25519.GenerateKey(rand.Reader)
	plaintext := []byte("Secret message")

	encrypted, _ := Encrypt(plaintext, pubKey)

	// Tamper with ciphertext
	encrypted.Ciphertext[0] ^= 0xFF

	_, err := Decrypt(encrypted, privKey)
	if err == nil {
		t.Error("Decryption of tampered ciphertext should fail")
	}
}

func TestDecrypt_TamperedNonce(t *testing.T) {
	pubKey, privKey, _ := ed25519.GenerateKey(rand.Reader)
	plaintext := []byte("Secret message")

	encrypted, _ := Encrypt(plaintext, pubKey)

	// Tamper with nonce
	encrypted.Nonce[0] ^= 0xFF

	_, err := Decrypt(encrypted, privKey)
	if err == nil {
		t.Error("Decryption with tampered nonce should fail")
	}
}

func TestSignVerify(t *testing.T) {
	pubKey, privKey, _ := ed25519.GenerateKey(rand.Reader)

	message := []byte("Challenge message for approval")

	// Sign
	signature, err := Sign(message, privKey)
	if err != nil {
		t.Fatalf("Sign failed: %v", err)
	}

	// Verify
	err = Verify(message, signature, pubKey)
	if err != nil {
		t.Errorf("Verify failed: %v", err)
	}
}

func TestSignVerify_WrongKey(t *testing.T) {
	_, privKey1, _ := ed25519.GenerateKey(rand.Reader)
	pubKey2, _, _ := ed25519.GenerateKey(rand.Reader)

	message := []byte("Challenge message")

	// Sign with key 1
	signature, _ := Sign(message, privKey1)

	// Verify with key 2 - should fail
	err := Verify(message, signature, pubKey2)
	if err == nil {
		t.Error("Verification with wrong key should fail")
	}
}

func TestSignVerify_TamperedMessage(t *testing.T) {
	pubKey, privKey, _ := ed25519.GenerateKey(rand.Reader)

	message := []byte("Original message")
	signature, _ := Sign(message, privKey)

	// Tamper with message
	tamperedMessage := []byte("Tampered message")

	err := Verify(tamperedMessage, signature, pubKey)
	if err == nil {
		t.Error("Verification of tampered message should fail")
	}
}

func TestEncryptWithSignature(t *testing.T) {
	senderPub, senderPriv, _ := ed25519.GenerateKey(rand.Reader)
	recipientPub, recipientPriv, _ := ed25519.GenerateKey(rand.Reader)

	plaintext := []byte("Signed and encrypted approval decision")
	fingerprint := "abc123"

	// Encrypt with signature
	encrypted, err := EncryptWithSignature(plaintext, recipientPub, senderPriv, fingerprint)
	if err != nil {
		t.Fatalf("EncryptWithSignature failed: %v", err)
	}

	// Verify signature is present
	if len(encrypted.Signature) == 0 {
		t.Error("Signature should not be empty")
	}
	if encrypted.SenderFingerprint != fingerprint {
		t.Errorf("SenderFingerprint mismatch: expected %s, got %s", fingerprint, encrypted.SenderFingerprint)
	}

	// Decrypt
	decrypted, err := Decrypt(encrypted, recipientPriv)
	if err != nil {
		t.Fatalf("Decrypt failed: %v", err)
	}

	if !bytes.Equal(plaintext, decrypted) {
		t.Error("Decrypted text mismatch")
	}

	// Verify signature manually
	sigInput := make([]byte, 0)
	sigInput = append(sigInput, encrypted.EphemeralPubKey...)
	sigInput = append(sigInput, encrypted.Nonce...)
	sigInput = append(sigInput, encrypted.Ciphertext...)

	err = Verify(sigInput, encrypted.Signature, senderPub)
	if err != nil {
		t.Errorf("Signature verification failed: %v", err)
	}
}

func TestEncryptDecrypt_EmptyPayload(t *testing.T) {
	pubKey, privKey, _ := ed25519.GenerateKey(rand.Reader)

	plaintext := []byte{}

	encrypted, err := Encrypt(plaintext, pubKey)
	if err != nil {
		t.Fatalf("Encrypt empty payload failed: %v", err)
	}

	decrypted, err := Decrypt(encrypted, privKey)
	if err != nil {
		t.Fatalf("Decrypt empty payload failed: %v", err)
	}

	if !bytes.Equal(plaintext, decrypted) {
		t.Error("Empty payload decryption mismatch")
	}
}

// Benchmark tests
func BenchmarkEncrypt(b *testing.B) {
	pubKey, _, _ := ed25519.GenerateKey(rand.Reader)
	plaintext := []byte("Typical approval request payload with source IP, destination, and geo info")

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		Encrypt(plaintext, pubKey)
	}
}

func BenchmarkDecrypt(b *testing.B) {
	pubKey, privKey, _ := ed25519.GenerateKey(rand.Reader)
	plaintext := []byte("Typical approval request payload with source IP, destination, and geo info")
	encrypted, _ := Encrypt(plaintext, pubKey)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		Decrypt(encrypted, privKey)
	}
}

func BenchmarkSign(b *testing.B) {
	_, privKey, _ := ed25519.GenerateKey(rand.Reader)
	message := []byte("Challenge message for P2P auth")

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		Sign(message, privKey)
	}
}

func BenchmarkVerify(b *testing.B) {
	pubKey, privKey, _ := ed25519.GenerateKey(rand.Reader)
	message := []byte("Challenge message for P2P auth")
	signature, _ := Sign(message, privKey)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		Verify(message, signature, pubKey)
	}
}
