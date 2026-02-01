package hubclient

import (
	"crypto/ed25519"
	"os"
	"path/filepath"
	"testing"
)

func TestStorage(t *testing.T) {
	// Create temp directory
	tmpDir, err := os.MkdirTemp("", "hubclient_test_*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	storage := NewStorage(tmpDir)

	t.Run("HasIdentity_Empty", func(t *testing.T) {
		if storage.HasIdentity() {
			t.Error("Should not have identity on empty storage")
		}
	})

	t.Run("GenerateNewIdentity", func(t *testing.T) {
		id, err := storage.GenerateNewIdentity()
		if err != nil {
			t.Fatalf("Failed to generate identity: %v", err)
		}
		if id.NodeID == "" {
			t.Error("NodeID should not be empty")
		}
		if id.PrivateKey == nil {
			t.Error("PrivateKey should not be nil")
		}
		if len(id.PrivateKey) != ed25519.PrivateKeySize {
			t.Errorf("PrivateKey size mismatch: got %d, want %d", len(id.PrivateKey), ed25519.PrivateKeySize)
		}
	})

	t.Run("HasIdentity_AfterGenerate", func(t *testing.T) {
		if !storage.HasIdentity() {
			t.Error("Should have identity after generation")
		}
	})

	t.Run("LoadIdentity", func(t *testing.T) {
		id, err := storage.LoadIdentity()
		if err != nil {
			t.Fatalf("Failed to load identity: %v", err)
		}
		if id.NodeID == "" {
			t.Error("NodeID should not be empty")
		}
		if id.PrivateKey == nil {
			t.Error("PrivateKey should not be nil")
		}
	})

	t.Run("SaveAndLoadCertificate", func(t *testing.T) {
		certPEM := []byte("-----BEGIN CERTIFICATE-----\ntest\n-----END CERTIFICATE-----")
		if err := storage.SaveCertificate(certPEM); err != nil {
			t.Fatalf("Failed to save certificate: %v", err)
		}

		if !storage.HasCertificate() {
			t.Error("Should have certificate after saving")
		}

		// Load identity and check cert
		id, _ := storage.LoadIdentity()
		if string(id.CertPEM) != string(certPEM) {
			t.Errorf("CertPEM mismatch: got %s, want %s", id.CertPEM, certPEM)
		}
	})

	t.Run("ClearCertificate", func(t *testing.T) {
		if err := storage.ClearCertificate(); err != nil {
			t.Fatalf("Failed to clear certificate: %v", err)
		}
		if storage.HasCertificate() {
			t.Error("Should not have certificate after clearing")
		}
	})

	t.Run("SaveAndLoadCACertificate", func(t *testing.T) {
		caPEM := []byte("-----BEGIN CERTIFICATE-----\nca-test\n-----END CERTIFICATE-----")
		if err := storage.SaveCACertificate(caPEM); err != nil {
			t.Fatalf("Failed to save CA certificate: %v", err)
		}

		loaded, err := storage.LoadCACertificate()
		if err != nil {
			t.Fatalf("Failed to load CA certificate: %v", err)
		}
		if string(loaded) != string(caPEM) {
			t.Errorf("CA PEM mismatch: got %s, want %s", loaded, caPEM)
		}
	})

	t.Run("GetDataDir", func(t *testing.T) {
		if storage.GetDataDir() != tmpDir {
			t.Errorf("DataDir mismatch: got %s, want %s", storage.GetDataDir(), tmpDir)
		}
	})
}

func TestStoragePersistence(t *testing.T) {
	// Create temp directory
	tmpDir, err := os.MkdirTemp("", "hubclient_persist_test_*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	// Generate identity with first storage instance
	storage1 := NewStorage(tmpDir)
	id1, err := storage1.GenerateNewIdentity()
	if err != nil {
		t.Fatalf("Failed to generate identity: %v", err)
	}
	nodeID := id1.NodeID
	privateKey := id1.PrivateKey

	// Save a certificate
	certPEM := []byte("-----BEGIN CERTIFICATE-----\npersist-test\n-----END CERTIFICATE-----")
	storage1.SaveCertificate(certPEM)

	// Create new storage instance and verify persistence
	storage2 := NewStorage(tmpDir)
	id2, err := storage2.LoadIdentity()
	if err != nil {
		t.Fatalf("Failed to load identity: %v", err)
	}

	if id2.NodeID != nodeID {
		t.Errorf("NodeID not persisted: got %s, want %s", id2.NodeID, nodeID)
	}

	if len(id2.PrivateKey) != len(privateKey) {
		t.Errorf("PrivateKey length mismatch: got %d, want %d", len(id2.PrivateKey), len(privateKey))
	}

	// Compare keys
	for i := range privateKey {
		if id2.PrivateKey[i] != privateKey[i] {
			t.Error("PrivateKey not persisted correctly")
			break
		}
	}

	if string(id2.CertPEM) != string(certPEM) {
		t.Errorf("CertPEM not persisted: got %s, want %s", id2.CertPEM, certPEM)
	}
}

func TestStorageFiles(t *testing.T) {
	// Create temp directory
	tmpDir, err := os.MkdirTemp("", "hubclient_files_test_*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	storage := NewStorage(tmpDir)
	storage.GenerateNewIdentity()

	// Check files were created
	expectedFiles := []string{"node_id", "node.key"}
	for _, f := range expectedFiles {
		path := filepath.Join(tmpDir, f)
		if _, err := os.Stat(path); os.IsNotExist(err) {
			t.Errorf("Expected file %s to exist", f)
		}
	}

	// Save cert and check file
	storage.SaveCertificate([]byte("test-cert"))
	certPath := filepath.Join(tmpDir, "node.crt")
	if _, err := os.Stat(certPath); os.IsNotExist(err) {
		t.Error("Expected node.crt to exist")
	}

	// Clear cert and check file removed
	storage.ClearCertificate()
	if _, err := os.Stat(certPath); !os.IsNotExist(err) {
		t.Error("Expected node.crt to be removed")
	}
}

func TestIdentityStruct(t *testing.T) {
	id := &Identity{
		NodeID:     "test-node",
		PrivateKey: make(ed25519.PrivateKey, ed25519.PrivateKeySize),
		CertPEM:    []byte("cert"),
	}

	if id.NodeID != "test-node" {
		t.Error("NodeID not set correctly")
	}
}

func TestStorageWithPassphrase(t *testing.T) {
	// Create temp directory
	tmpDir, err := os.MkdirTemp("", "hubclient_passphrase_test_*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	passphrase := "test-passphrase-123"

	t.Run("GenerateWithPassphrase", func(t *testing.T) {
		config := StorageConfig{
			UsePassphrase: true,
			Passphrase:    passphrase,
		}
		storage := NewStorageWithConfig(tmpDir, config)

		id, err := storage.GenerateNewIdentity()
		if err != nil {
			t.Fatalf("Failed to generate identity: %v", err)
		}
		if id.NodeID == "" {
			t.Error("NodeID should not be empty")
		}
		if id.PrivateKey == nil {
			t.Error("PrivateKey should not be nil")
		}

		// Verify key is encrypted
		if !storage.IsKeyEncrypted() {
			t.Error("Key should be encrypted")
		}
	})

	t.Run("LoadWithPassphrase", func(t *testing.T) {
		config := StorageConfig{
			UsePassphrase: true,
			Passphrase:    passphrase,
		}
		storage := NewStorageWithConfig(tmpDir, config)

		id, err := storage.LoadIdentity()
		if err != nil {
			t.Fatalf("Failed to load identity: %v", err)
		}
		if id.NodeID == "" {
			t.Error("NodeID should not be empty")
		}
		if id.PrivateKey == nil {
			t.Error("PrivateKey should not be nil")
		}
		if len(id.PrivateKey) != ed25519.PrivateKeySize {
			t.Errorf("PrivateKey size mismatch: got %d, want %d", len(id.PrivateKey), ed25519.PrivateKeySize)
		}
	})

	t.Run("LoadWithWrongPassphrase", func(t *testing.T) {
		config := StorageConfig{
			UsePassphrase: true,
			Passphrase:    "wrong-passphrase",
		}
		storage := NewStorageWithConfig(tmpDir, config)

		_, err := storage.LoadIdentity()
		if err == nil {
			t.Error("Should fail with wrong passphrase")
		}
	})

	t.Run("ChangePassphrase", func(t *testing.T) {
		config := StorageConfig{
			UsePassphrase: true,
			Passphrase:    passphrase,
		}
		storage := NewStorageWithConfig(tmpDir, config)

		newPassphrase := "new-passphrase-456"
		if err := storage.ChangePassphrase(passphrase, newPassphrase); err != nil {
			t.Fatalf("Failed to change passphrase: %v", err)
		}

		// Load with new passphrase
		storage.SetPassphrase(newPassphrase)
		id, err := storage.LoadIdentity()
		if err != nil {
			t.Fatalf("Failed to load identity with new passphrase: %v", err)
		}
		if id.PrivateKey == nil {
			t.Error("PrivateKey should not be nil")
		}

		// Old passphrase should fail
		storage.SetPassphrase(passphrase)
		_, err = storage.LoadIdentity()
		if err == nil {
			t.Error("Old passphrase should fail")
		}

		// Restore for next tests
		storage.SetPassphrase(newPassphrase)
		storage.ChangePassphrase(newPassphrase, passphrase)
	})
}

func TestEncryptExistingKey(t *testing.T) {
	// Create temp directory
	tmpDir, err := os.MkdirTemp("", "hubclient_encrypt_test_*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	passphrase := "encrypt-existing-123"

	// Generate identity without passphrase
	storage := NewStorage(tmpDir)
	originalID, err := storage.GenerateNewIdentity()
	if err != nil {
		t.Fatalf("Failed to generate identity: %v", err)
	}

	// Verify key is not encrypted
	if storage.IsKeyEncrypted() {
		t.Error("Key should not be encrypted initially")
	}

	// Encrypt existing key
	if err := storage.EncryptExistingKey(passphrase); err != nil {
		t.Fatalf("Failed to encrypt existing key: %v", err)
	}

	// Verify key is now encrypted
	if !storage.IsKeyEncrypted() {
		t.Error("Key should be encrypted after EncryptExistingKey")
	}

	// Load with passphrase
	id, err := storage.LoadIdentity()
	if err != nil {
		t.Fatalf("Failed to load identity after encryption: %v", err)
	}

	// Verify key matches original
	if id.NodeID != originalID.NodeID {
		t.Error("NodeID should match after encryption")
	}
	for i := range originalID.PrivateKey {
		if id.PrivateKey[i] != originalID.PrivateKey[i] {
			t.Error("PrivateKey should match after encryption")
			break
		}
	}
}

func TestDecryptExistingKey(t *testing.T) {
	// Create temp directory
	tmpDir, err := os.MkdirTemp("", "hubclient_decrypt_test_*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	passphrase := "decrypt-existing-123"

	// Generate identity with passphrase
	config := StorageConfig{
		UsePassphrase: true,
		Passphrase:    passphrase,
	}
	storage := NewStorageWithConfig(tmpDir, config)
	originalID, err := storage.GenerateNewIdentity()
	if err != nil {
		t.Fatalf("Failed to generate identity: %v", err)
	}

	// Verify key is encrypted
	if !storage.IsKeyEncrypted() {
		t.Error("Key should be encrypted initially")
	}

	// Decrypt existing key
	if err := storage.DecryptExistingKey(passphrase); err != nil {
		t.Fatalf("Failed to decrypt existing key: %v", err)
	}

	// Verify key is now plain
	if storage.IsKeyEncrypted() {
		t.Error("Key should not be encrypted after DecryptExistingKey")
	}

	// Load without passphrase
	plainStorage := NewStorage(tmpDir)
	id, err := plainStorage.LoadIdentity()
	if err != nil {
		t.Fatalf("Failed to load identity after decryption: %v", err)
	}

	// Verify key matches original
	if id.NodeID != originalID.NodeID {
		t.Error("NodeID should match after decryption")
	}
	for i := range originalID.PrivateKey {
		if id.PrivateKey[i] != originalID.PrivateKey[i] {
			t.Error("PrivateKey should match after decryption")
			break
		}
	}
}

// ===========================================================================
// CLI Routing Token Storage Tests
// ===========================================================================

func TestUserSecretStorage(t *testing.T) {
	// Create temp directory
	tmpDir, err := os.MkdirTemp("", "hubclient_usersecret_test_*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	storage := NewStorage(tmpDir)

	t.Run("HasUserSecret_Empty", func(t *testing.T) {
		if storage.HasUserSecret() {
			t.Error("Should not have user secret on empty storage")
		}
	})

	t.Run("SaveAndLoadUserSecret", func(t *testing.T) {
		secret := make([]byte, 32)
		for i := range secret {
			secret[i] = byte(i)
		}

		if err := storage.SaveUserSecret(secret); err != nil {
			t.Fatalf("Failed to save user secret: %v", err)
		}

		if !storage.HasUserSecret() {
			t.Error("Should have user secret after saving")
		}

		loaded, err := storage.LoadUserSecret()
		if err != nil {
			t.Fatalf("Failed to load user secret: %v", err)
		}

		if len(loaded) != len(secret) {
			t.Errorf("Secret length mismatch: got %d, want %d", len(loaded), len(secret))
		}

		for i := range secret {
			if loaded[i] != secret[i] {
				t.Errorf("Secret byte %d mismatch: got %d, want %d", i, loaded[i], secret[i])
			}
		}
	})

	t.Run("LoadUserSecret_NotFound", func(t *testing.T) {
		emptyDir, _ := os.MkdirTemp("", "hubclient_empty_*")
		defer os.RemoveAll(emptyDir)

		emptyStorage := NewStorage(emptyDir)
		_, err := emptyStorage.LoadUserSecret()
		if err == nil {
			t.Error("Should fail to load non-existent user secret")
		}
	})
}

func TestRoutingTokenStorage(t *testing.T) {
	// Create temp directory
	tmpDir, err := os.MkdirTemp("", "hubclient_routingtoken_test_*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	storage := NewStorage(tmpDir)

	t.Run("SaveAndLoadRoutingToken", func(t *testing.T) {
		nodeID := "node-123"
		token := "routing-token-abc"

		if err := storage.SaveRoutingToken(nodeID, token); err != nil {
			t.Fatalf("Failed to save routing token: %v", err)
		}

		loaded, err := storage.LoadRoutingToken(nodeID)
		if err != nil {
			t.Fatalf("Failed to load routing token: %v", err)
		}

		if loaded != token {
			t.Errorf("Token mismatch: got %s, want %s", loaded, token)
		}
	})

	t.Run("LoadRoutingToken_NotFound", func(t *testing.T) {
		_, err := storage.LoadRoutingToken("nonexistent-node")
		if err == nil {
			t.Error("Should fail to load non-existent routing token")
		}
	})

	t.Run("LoadAllRoutingTokens", func(t *testing.T) {
		// Save multiple tokens
		tokens := map[string]string{
			"node-1": "token-1",
			"node-2": "token-2",
			"node-3": "token-3",
		}

		for nodeID, token := range tokens {
			if err := storage.SaveRoutingToken(nodeID, token); err != nil {
				t.Fatalf("Failed to save routing token for %s: %v", nodeID, err)
			}
		}

		loaded, err := storage.LoadAllRoutingTokens()
		if err != nil {
			t.Fatalf("Failed to load all routing tokens: %v", err)
		}

		// Check all tokens are loaded (including the one from previous test)
		if len(loaded) < len(tokens) {
			t.Errorf("Expected at least %d tokens, got %d", len(tokens), len(loaded))
		}

		for nodeID, expectedToken := range tokens {
			if loaded[nodeID] != expectedToken {
				t.Errorf("Token mismatch for %s: got %s, want %s", nodeID, loaded[nodeID], expectedToken)
			}
		}
	})

	t.Run("DeleteRoutingToken", func(t *testing.T) {
		nodeID := "node-to-delete"
		token := "token-to-delete"

		// Save
		if err := storage.SaveRoutingToken(nodeID, token); err != nil {
			t.Fatalf("Failed to save routing token: %v", err)
		}

		// Verify it exists
		_, err := storage.LoadRoutingToken(nodeID)
		if err != nil {
			t.Fatalf("Token should exist before deletion: %v", err)
		}

		// Delete
		if err := storage.DeleteRoutingToken(nodeID); err != nil {
			t.Fatalf("Failed to delete routing token: %v", err)
		}

		// Verify it's gone
		_, err = storage.LoadRoutingToken(nodeID)
		if err == nil {
			t.Error("Token should not exist after deletion")
		}
	})

	t.Run("LoadAllRoutingTokens_EmptyDir", func(t *testing.T) {
		emptyDir, _ := os.MkdirTemp("", "hubclient_empty_tokens_*")
		defer os.RemoveAll(emptyDir)

		emptyStorage := NewStorage(emptyDir)
		tokens, err := emptyStorage.LoadAllRoutingTokens()
		if err != nil {
			t.Fatalf("Should not fail on empty dir: %v", err)
		}
		if len(tokens) != 0 {
			t.Errorf("Expected 0 tokens, got %d", len(tokens))
		}
	})
}
