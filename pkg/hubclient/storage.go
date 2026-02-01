package hubclient

import (
	"crypto/ed25519"
	"crypto/rand"
	"crypto/x509"
	"encoding/pem"
	"errors"
	"fmt"
	"log"
	"os"
	"path/filepath"

	"github.com/google/uuid"
)

// Identity represents the node's cryptographic identity
type Identity struct {
	NodeID       string
	PrivateKey   ed25519.PrivateKey
	CertPEM      []byte
	ViewerPubKey ed25519.PublicKey // Owner's public key for encrypting metrics/alerts
}

// StorageConfig contains configuration for storage
type StorageConfig struct {
	// UsePassphrase enables passphrase protection for private keys
	UsePassphrase bool
	// Passphrase is the passphrase for encrypting/decrypting keys (if UsePassphrase is true)
	Passphrase string
	// PassphraseFunc is called to get passphrase if Passphrase is empty
	PassphraseFunc func(prompt string) (string, error)
}

// Storage handles persistent storage of node identity and certificates
type Storage struct {
	BaseDir string
	config  StorageConfig
}

// NewStorage creates a new storage instance (unencrypted mode for backward compatibility)
func NewStorage(baseDir string) *Storage {
	return &Storage{
		BaseDir: baseDir,
		config:  StorageConfig{UsePassphrase: false},
	}
}

// NewStorageWithConfig creates a new storage instance with configuration
func NewStorageWithConfig(baseDir string, config StorageConfig) *Storage {
	return &Storage{
		BaseDir: baseDir,
		config:  config,
	}
}

// SetPassphrase sets or updates the passphrase for key encryption
func (s *Storage) SetPassphrase(passphrase string) {
	s.config.UsePassphrase = true
	s.config.Passphrase = passphrase
}

// getPassphrase gets the passphrase from config or prompts the user
func (s *Storage) getPassphrase(prompt string) (string, error) {
	if s.config.Passphrase != "" {
		return s.config.Passphrase, nil
	}
	if s.config.PassphraseFunc != nil {
		return s.config.PassphraseFunc(prompt)
	}
	// Check environment variable as fallback
	if envPass := os.Getenv("NITELLA_PASSPHRASE"); envPass != "" {
		return envPass, nil
	}
	return "", errors.New("passphrase required but not provided")
}

// LoadIdentity loads the node identity from disk
func (s *Storage) LoadIdentity() (*Identity, error) {
	id := &Identity{}

	// 1. Load NodeID
	idPath := filepath.Join(s.BaseDir, "node_id")
	if data, err := os.ReadFile(idPath); err == nil {
		id.NodeID = string(data)
	}

	// 2. Load Private Key (supports both encrypted and plain formats)
	keyPath := filepath.Join(s.BaseDir, "node.key")
	if keyData, err := os.ReadFile(keyPath); err == nil {
		var keyBytes []byte

		// Check if file is encrypted (JSON format)
		if IsEncryptedKeyFile(keyPath) {
			enc, err := LoadEncryptedKey(keyPath)
			if err != nil {
				return nil, fmt.Errorf("failed to load encrypted key: %w", err)
			}
			passphrase, err := s.getPassphrase("Enter passphrase to unlock key: ")
			if err != nil {
				return nil, fmt.Errorf("passphrase required for encrypted key: %w", err)
			}
			keyBytes, err = DecryptKey(enc, passphrase)
			if err != nil {
				return nil, fmt.Errorf("failed to decrypt key: %w", err)
			}
		} else {
			// Plain PEM format (backward compatibility)
			block, _ := pem.Decode(keyData)
			if block != nil {
				keyBytes = block.Bytes
			}
		}

		// Parse the key bytes
		if keyBytes != nil {
			if len(keyBytes) == ed25519.PrivateKeySize {
				id.PrivateKey = ed25519.PrivateKey(keyBytes)
			} else {
				// Parse PKCS8 if needed
				if k, err := x509.ParsePKCS8PrivateKey(keyBytes); err == nil {
					if edKey, ok := k.(ed25519.PrivateKey); ok {
						id.PrivateKey = edKey
					}
				}
			}
		}
	}

	// 3. Load Certificate
	certPath := filepath.Join(s.BaseDir, "node.crt")
	if certPEM, err := os.ReadFile(certPath); err == nil {
		id.CertPEM = certPEM
	}

	// 4. Load Viewer Public Key (owner's key for encrypting metrics/alerts)
	viewerKeyPath := filepath.Join(s.BaseDir, "viewer.pub")
	if viewerPubBytes, err := os.ReadFile(viewerKeyPath); err == nil {
		if len(viewerPubBytes) == ed25519.PublicKeySize {
			id.ViewerPubKey = ed25519.PublicKey(viewerPubBytes)
		}
	}

	return id, nil
}

// SaveIdentity saves the node identity to disk
func (s *Storage) SaveIdentity(id *Identity) error {
	if err := os.MkdirAll(s.BaseDir, 0700); err != nil {
		return err
	}

	// Save NodeID
	if id.NodeID != "" {
		if err := os.WriteFile(filepath.Join(s.BaseDir, "node_id"), []byte(id.NodeID), 0600); err != nil {
			return err
		}
	}

	// Save Private Key
	if id.PrivateKey != nil {
		keyPath := filepath.Join(s.BaseDir, "node.key")

		// Marshal to PKCS8 format
		pkcs8, err := x509.MarshalPKCS8PrivateKey(id.PrivateKey)
		if err != nil {
			return fmt.Errorf("failed to marshal private key: %w", err)
		}

		if s.config.UsePassphrase {
			// Encrypt the key with passphrase
			passphrase, err := s.getPassphrase("Enter passphrase to protect key: ")
			if err != nil {
				return fmt.Errorf("passphrase required for encryption: %w", err)
			}
			enc, err := EncryptKey(pkcs8, passphrase)
			if err != nil {
				return fmt.Errorf("failed to encrypt key: %w", err)
			}
			if err := SaveEncryptedKey(keyPath, enc); err != nil {
				return fmt.Errorf("failed to save encrypted key: %w", err)
			}
		} else {
			// Save as plain PEM (backward compatibility)
			pemBlock := &pem.Block{Type: "PRIVATE KEY", Bytes: pkcs8}
			data := pem.EncodeToMemory(pemBlock)
			if err := os.WriteFile(keyPath, data, 0600); err != nil {
				return err
			}
		}
	}

	// Save Cert
	if len(id.CertPEM) > 0 {
		if err := os.WriteFile(filepath.Join(s.BaseDir, "node.crt"), id.CertPEM, 0600); err != nil {
			return err
		}
	} else {
		// If empty, remove the file
		os.Remove(filepath.Join(s.BaseDir, "node.crt"))
	}

	// Save Viewer Public Key (owner's key for encrypting metrics/alerts)
	if len(id.ViewerPubKey) > 0 {
		if err := os.WriteFile(filepath.Join(s.BaseDir, "viewer.pub"), id.ViewerPubKey, 0600); err != nil {
			return err
		}
	}

	return nil
}

// GenerateNewIdentity creates a fresh ID and Key
func (s *Storage) GenerateNewIdentity() (*Identity, error) {
	pub, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		return nil, err
	}
	_ = pub // Unused here, implicit in priv

	id := &Identity{
		NodeID:     uuid.New().String(),
		PrivateKey: priv,
	}

	if err := s.SaveIdentity(id); err != nil {
		return nil, err
	}

	// Ensure old certs are gone
	os.Remove(filepath.Join(s.BaseDir, "node.crt"))

	return id, nil
}

// ClearCertificate removes the stored certificate
func (s *Storage) ClearCertificate() error {
	return os.Remove(filepath.Join(s.BaseDir, "node.crt"))
}

// SaveCertificate saves the certificate PEM to disk
func (s *Storage) SaveCertificate(certPEM []byte) error {
	if err := os.MkdirAll(s.BaseDir, 0700); err != nil {
		return err
	}
	return os.WriteFile(filepath.Join(s.BaseDir, "node.crt"), certPEM, 0600)
}

// SaveCACertificate saves the CA certificate PEM to disk
func (s *Storage) SaveCACertificate(caPEM []byte) error {
	if err := os.MkdirAll(s.BaseDir, 0700); err != nil {
		return err
	}
	return os.WriteFile(filepath.Join(s.BaseDir, "ca.crt"), caPEM, 0600)
}

// LoadCACertificate loads the CA certificate from disk
func (s *Storage) LoadCACertificate() ([]byte, error) {
	return os.ReadFile(filepath.Join(s.BaseDir, "ca.crt"))
}

// HasIdentity returns true if identity files exist
func (s *Storage) HasIdentity() bool {
	idPath := filepath.Join(s.BaseDir, "node_id")
	keyPath := filepath.Join(s.BaseDir, "node.key")
	_, err1 := os.Stat(idPath)
	_, err2 := os.Stat(keyPath)
	return err1 == nil && err2 == nil
}

// HasCertificate returns true if certificate file exists
func (s *Storage) HasCertificate() bool {
	certPath := filepath.Join(s.BaseDir, "node.crt")
	_, err := os.Stat(certPath)
	return err == nil
}

// GetDataDir returns the base directory path
func (s *Storage) GetDataDir() string {
	return s.BaseDir
}

// SaveViewerPublicKey saves the owner's public key for encrypting metrics/alerts
func (s *Storage) SaveViewerPublicKey(pubKey ed25519.PublicKey) error {
	if err := os.MkdirAll(s.BaseDir, 0700); err != nil {
		return err
	}
	return os.WriteFile(filepath.Join(s.BaseDir, "viewer.pub"), pubKey, 0600)
}

// LoadViewerPublicKey loads the owner's public key
func (s *Storage) LoadViewerPublicKey() (ed25519.PublicKey, error) {
	data, err := os.ReadFile(filepath.Join(s.BaseDir, "viewer.pub"))
	if err != nil {
		return nil, err
	}
	if len(data) != ed25519.PublicKeySize {
		return nil, errors.New("invalid viewer public key size")
	}
	return ed25519.PublicKey(data), nil
}

// HasViewerPublicKey returns true if viewer public key exists
func (s *Storage) HasViewerPublicKey() bool {
	_, err := os.Stat(filepath.Join(s.BaseDir, "viewer.pub"))
	return err == nil
}

// IsKeyEncrypted checks if the stored key is encrypted
func (s *Storage) IsKeyEncrypted() bool {
	keyPath := filepath.Join(s.BaseDir, "node.key")
	return IsEncryptedKeyFile(keyPath)
}

// EncryptExistingKey encrypts an existing plain key with a passphrase
// This is used to migrate from unencrypted to encrypted storage
func (s *Storage) EncryptExistingKey(passphrase string) error {
	keyPath := filepath.Join(s.BaseDir, "node.key")

	// Check if already encrypted
	if IsEncryptedKeyFile(keyPath) {
		return errors.New("key is already encrypted")
	}

	// Read plain PEM
	keyPEM, err := os.ReadFile(keyPath)
	if err != nil {
		return fmt.Errorf("failed to read key: %w", err)
	}

	block, _ := pem.Decode(keyPEM)
	if block == nil {
		return errors.New("failed to decode PEM")
	}

	// Encrypt the key bytes
	enc, err := EncryptKey(block.Bytes, passphrase)
	if err != nil {
		return fmt.Errorf("failed to encrypt key: %w", err)
	}

	// Save encrypted key
	if err := SaveEncryptedKey(keyPath, enc); err != nil {
		return fmt.Errorf("failed to save encrypted key: %w", err)
	}

	// Update config
	s.config.UsePassphrase = true
	s.config.Passphrase = passphrase

	return nil
}

// DecryptExistingKey decrypts an encrypted key to plain PEM format
// This is used to disable passphrase protection
func (s *Storage) DecryptExistingKey(passphrase string) error {
	keyPath := filepath.Join(s.BaseDir, "node.key")

	// Check if encrypted
	if !IsEncryptedKeyFile(keyPath) {
		return errors.New("key is not encrypted")
	}

	// Load and decrypt
	enc, err := LoadEncryptedKey(keyPath)
	if err != nil {
		return fmt.Errorf("failed to load encrypted key: %w", err)
	}

	keyBytes, err := DecryptKey(enc, passphrase)
	if err != nil {
		return fmt.Errorf("failed to decrypt key: %w", err)
	}

	// Save as plain PEM
	pemBlock := &pem.Block{Type: "PRIVATE KEY", Bytes: keyBytes}
	data := pem.EncodeToMemory(pemBlock)
	if err := os.WriteFile(keyPath, data, 0600); err != nil {
		return fmt.Errorf("failed to save decrypted key: %w", err)
	}

	// Update config
	s.config.UsePassphrase = false
	s.config.Passphrase = ""

	return nil
}

// ChangePassphrase changes the passphrase for an encrypted key
func (s *Storage) ChangePassphrase(oldPassphrase, newPassphrase string) error {
	keyPath := filepath.Join(s.BaseDir, "node.key")

	// Check if encrypted
	if !IsEncryptedKeyFile(keyPath) {
		return errors.New("key is not encrypted")
	}

	// Load and decrypt with old passphrase
	enc, err := LoadEncryptedKey(keyPath)
	if err != nil {
		return fmt.Errorf("failed to load encrypted key: %w", err)
	}

	keyBytes, err := DecryptKey(enc, oldPassphrase)
	if err != nil {
		return fmt.Errorf("failed to decrypt key: %w", err)
	}

	// Re-encrypt with new passphrase
	newEnc, err := EncryptKey(keyBytes, newPassphrase)
	if err != nil {
		return fmt.Errorf("failed to encrypt key: %w", err)
	}

	// Save
	if err := SaveEncryptedKey(keyPath, newEnc); err != nil {
		return fmt.Errorf("failed to save encrypted key: %w", err)
	}

	// Update config
	s.config.Passphrase = newPassphrase

	return nil
}

// ===========================================================================
// CLI-Side Storage (User Secret & Routing Tokens)
// ===========================================================================

// SaveUserSecret saves the CLI user secret for routing token generation.
// If passphrase protection is enabled, the secret is encrypted.
func (s *Storage) SaveUserSecret(secret []byte) error {
	if err := os.MkdirAll(s.BaseDir, 0700); err != nil {
		return err
	}

	secretPath := filepath.Join(s.BaseDir, "user_secret")

	if s.config.UsePassphrase {
		// Encrypt the secret with passphrase
		passphrase, err := s.getPassphrase("Enter passphrase to protect user secret: ")
		if err != nil {
			return fmt.Errorf("passphrase required for encryption: %w", err)
		}
		enc, err := EncryptKey(secret, passphrase)
		if err != nil {
			return fmt.Errorf("failed to encrypt user secret: %w", err)
		}
		return SaveEncryptedKey(secretPath, enc)
	}

	// Save as plain file (backward compatibility)
	log.Printf("[SECURITY] Warning: Saving user secret without encryption. Consider enabling passphrase protection.")
	return os.WriteFile(secretPath, secret, 0600)
}

// LoadUserSecret loads the CLI user secret.
// If the secret is encrypted, it will be decrypted with passphrase.
func (s *Storage) LoadUserSecret() ([]byte, error) {
	secretPath := filepath.Join(s.BaseDir, "user_secret")

	// Check if file is encrypted
	if IsEncryptedKeyFile(secretPath) {
		enc, err := LoadEncryptedKey(secretPath)
		if err != nil {
			return nil, fmt.Errorf("failed to load encrypted user secret: %w", err)
		}
		passphrase, err := s.getPassphrase("Enter passphrase to unlock user secret: ")
		if err != nil {
			return nil, fmt.Errorf("passphrase required for encrypted user secret: %w", err)
		}
		return DecryptKey(enc, passphrase)
	}

	// Plain file (backward compatibility)
	return os.ReadFile(secretPath)
}

// HasUserSecret returns true if user secret exists
func (s *Storage) HasUserSecret() bool {
	_, err := os.Stat(filepath.Join(s.BaseDir, "user_secret"))
	return err == nil
}

// EncryptExistingUserSecret encrypts an existing plain user secret with a passphrase
func (s *Storage) EncryptExistingUserSecret(passphrase string) error {
	secretPath := filepath.Join(s.BaseDir, "user_secret")

	// Check if already encrypted
	if IsEncryptedKeyFile(secretPath) {
		return errors.New("user secret is already encrypted")
	}

	// Read plain secret
	secret, err := os.ReadFile(secretPath)
	if err != nil {
		return fmt.Errorf("failed to read user secret: %w", err)
	}

	// Encrypt
	enc, err := EncryptKey(secret, passphrase)
	if err != nil {
		return fmt.Errorf("failed to encrypt user secret: %w", err)
	}

	// Save encrypted
	if err := SaveEncryptedKey(secretPath, enc); err != nil {
		return fmt.Errorf("failed to save encrypted user secret: %w", err)
	}

	return nil
}

// SaveRoutingToken saves a routing token for a specific node
func (s *Storage) SaveRoutingToken(nodeID, routingToken string) error {
	tokensDir := filepath.Join(s.BaseDir, "routing_tokens")
	if err := os.MkdirAll(tokensDir, 0700); err != nil {
		return err
	}
	return os.WriteFile(filepath.Join(tokensDir, nodeID), []byte(routingToken), 0600)
}

// LoadRoutingToken loads a routing token for a specific node
func (s *Storage) LoadRoutingToken(nodeID string) (string, error) {
	data, err := os.ReadFile(filepath.Join(s.BaseDir, "routing_tokens", nodeID))
	if err != nil {
		return "", err
	}
	return string(data), nil
}

// LoadAllRoutingTokens loads all stored routing tokens
func (s *Storage) LoadAllRoutingTokens() (map[string]string, error) {
	tokens := make(map[string]string)
	tokensDir := filepath.Join(s.BaseDir, "routing_tokens")

	entries, err := os.ReadDir(tokensDir)
	if err != nil {
		if os.IsNotExist(err) {
			return tokens, nil
		}
		return nil, err
	}

	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}
		nodeID := entry.Name()
		data, err := os.ReadFile(filepath.Join(tokensDir, nodeID))
		if err != nil {
			continue
		}
		tokens[nodeID] = string(data)
	}

	return tokens, nil
}

// DeleteRoutingToken removes a routing token for a node
func (s *Storage) DeleteRoutingToken(nodeID string) error {
	return os.Remove(filepath.Join(s.BaseDir, "routing_tokens", nodeID))
}
