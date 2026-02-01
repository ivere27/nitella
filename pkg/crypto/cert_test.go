package crypto

import (
	"crypto/ed25519"
	"crypto/rand"
	"testing"
)

func TestEncryptDecryptPrivateKey(t *testing.T) {
	// Generate test key
	_, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatalf("Failed to generate key: %v", err)
	}

	tests := []struct {
		name       string
		passphrase string
	}{
		{"no passphrase", ""},
		{"simple passphrase", "test123"},
		{"complex passphrase", "This is a l0ng & c0mplex p@ssphrase!"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Encrypt
			encrypted, err := EncryptPrivateKeyToPEM(priv, tt.passphrase)
			if err != nil {
				t.Fatalf("Failed to encrypt: %v", err)
			}

			// Decrypt
			decrypted, err := DecryptPrivateKeyFromPEM(encrypted, tt.passphrase)
			if err != nil {
				t.Fatalf("Failed to decrypt: %v", err)
			}

			// Verify keys match
			if !priv.Equal(decrypted) {
				t.Error("Decrypted key does not match original")
			}
		})
	}
}

func TestDecryptWithWrongPassphrase(t *testing.T) {
	_, priv, _ := ed25519.GenerateKey(rand.Reader)

	encrypted, err := EncryptPrivateKeyToPEM(priv, "correct-passphrase")
	if err != nil {
		t.Fatalf("Failed to encrypt: %v", err)
	}

	// Try to decrypt with wrong passphrase
	_, err = DecryptPrivateKeyFromPEM(encrypted, "wrong-passphrase")
	if err == nil {
		t.Error("Expected error when decrypting with wrong passphrase")
	}
}

func TestDecryptEncryptedKeyWithoutPassphrase(t *testing.T) {
	_, priv, _ := ed25519.GenerateKey(rand.Reader)

	encrypted, err := EncryptPrivateKeyToPEM(priv, "my-passphrase")
	if err != nil {
		t.Fatalf("Failed to encrypt: %v", err)
	}

	// Try to decrypt without passphrase
	_, err = DecryptPrivateKeyFromPEM(encrypted, "")
	if err == nil {
		t.Error("Expected error when decrypting encrypted key without passphrase")
	}
	if err.Error() != "passphrase required for encrypted key" {
		t.Errorf("Unexpected error: %v", err)
	}
}
