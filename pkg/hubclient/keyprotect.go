// Package hubclient provides key protection utilities for encrypting private keys at rest.
package hubclient

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"

	"golang.org/x/crypto/argon2"
)

// Argon2id parameters (OWASP recommended)
const (
	argonTime    = 3
	argonMemory  = 64 * 1024 // 64 MB
	argonThreads = 4
	argonKeyLen  = 32 // AES-256
	saltLen      = 16
	nonceLen     = 12 // GCM nonce
)

// EncryptedKey represents an encrypted private key stored on disk
type EncryptedKey struct {
	Salt       string `json:"salt"`       // Base64 encoded salt for Argon2id
	Nonce      string `json:"nonce"`      // Base64 encoded GCM nonce
	Ciphertext string `json:"ciphertext"` // Base64 encoded encrypted key
	Version    int    `json:"version"`    // Format version for future upgrades
}

// EncryptKey encrypts a private key using Argon2id + AES-256-GCM
func EncryptKey(plainKey []byte, passphrase string) (*EncryptedKey, error) {
	if passphrase == "" {
		return nil, errors.New("passphrase cannot be empty")
	}

	// Generate random salt
	salt := make([]byte, saltLen)
	if _, err := io.ReadFull(rand.Reader, salt); err != nil {
		return nil, fmt.Errorf("failed to generate salt: %w", err)
	}

	// Derive key using Argon2id
	derivedKey := argon2.IDKey([]byte(passphrase), salt, argonTime, argonMemory, argonThreads, argonKeyLen)

	// Create AES-GCM cipher
	block, err := aes.NewCipher(derivedKey)
	if err != nil {
		return nil, fmt.Errorf("failed to create cipher: %w", err)
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, fmt.Errorf("failed to create GCM: %w", err)
	}

	// Generate random nonce
	nonce := make([]byte, nonceLen)
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
		return nil, fmt.Errorf("failed to generate nonce: %w", err)
	}

	// Encrypt
	ciphertext := gcm.Seal(nil, nonce, plainKey, nil)

	return &EncryptedKey{
		Salt:       base64.StdEncoding.EncodeToString(salt),
		Nonce:      base64.StdEncoding.EncodeToString(nonce),
		Ciphertext: base64.StdEncoding.EncodeToString(ciphertext),
		Version:    1,
	}, nil
}

// DecryptKey decrypts an encrypted private key
func DecryptKey(enc *EncryptedKey, passphrase string) ([]byte, error) {
	if passphrase == "" {
		return nil, errors.New("passphrase cannot be empty")
	}

	// Decode base64 values
	salt, err := base64.StdEncoding.DecodeString(enc.Salt)
	if err != nil {
		return nil, fmt.Errorf("failed to decode salt: %w", err)
	}

	nonce, err := base64.StdEncoding.DecodeString(enc.Nonce)
	if err != nil {
		return nil, fmt.Errorf("failed to decode nonce: %w", err)
	}

	ciphertext, err := base64.StdEncoding.DecodeString(enc.Ciphertext)
	if err != nil {
		return nil, fmt.Errorf("failed to decode ciphertext: %w", err)
	}

	// Derive key using Argon2id
	derivedKey := argon2.IDKey([]byte(passphrase), salt, argonTime, argonMemory, argonThreads, argonKeyLen)

	// Create AES-GCM cipher
	block, err := aes.NewCipher(derivedKey)
	if err != nil {
		return nil, fmt.Errorf("failed to create cipher: %w", err)
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, fmt.Errorf("failed to create GCM: %w", err)
	}

	// Decrypt
	plaintext, err := gcm.Open(nil, nonce, ciphertext, nil)
	if err != nil {
		return nil, errors.New("decryption failed: wrong passphrase or corrupted data")
	}

	return plaintext, nil
}

// SaveEncryptedKey saves an encrypted key to a file
func SaveEncryptedKey(path string, enc *EncryptedKey) error {
	data, err := json.MarshalIndent(enc, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(path, data, 0600)
}

// LoadEncryptedKey loads an encrypted key from a file
func LoadEncryptedKey(path string) (*EncryptedKey, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var enc EncryptedKey
	if err := json.Unmarshal(data, &enc); err != nil {
		return nil, err
	}
	return &enc, nil
}

// IsEncryptedKeyFile checks if a file contains an encrypted key (vs plain PEM)
func IsEncryptedKeyFile(path string) bool {
	data, err := os.ReadFile(path)
	if err != nil {
		return false
	}
	var enc EncryptedKey
	return json.Unmarshal(data, &enc) == nil && enc.Version > 0
}
