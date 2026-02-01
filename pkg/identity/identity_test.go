package identity

import (
	"encoding/hex"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestMnemonicGeneration(t *testing.T) {
	// Test config
	cfg := DefaultConfig("/tmp/nitella-test", "test-node")
	
	// Create identity
	id, err := Create(cfg)
	if err != nil {
		t.Fatalf("Failed to create identity: %v", err)
	}

	// Verify mnemonic
	words := strings.Fields(id.Mnemonic)
	if len(words) != 12 {
		t.Errorf("Expected 12 words, got %d", len(words))
	}

	if !ValidateMnemonic(id.Mnemonic) {
		t.Error("Mnemonic validation failed")
	}

	// Verify seed derivation
	seed := mnemonicToSeed(id.Mnemonic)
	if len(seed) != 64 {
		t.Errorf("Expected 64 byte seed, got %d", len(seed))
	}
}

func TestValidateMnemonic(t *testing.T) {
	// Generate a valid 24-word string (using "abandon" which is valid)
	// ValidateMnemonic does not check checksum, so this should pass validation
	valid24 := strings.Repeat("abandon ", 24)
	valid24 = strings.TrimSpace(valid24)

	tests := []struct {
		name     string
		mnemonic string
		valid    bool
	}{
		{
			name:     "Valid 12 words",
			mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
			valid:    true,
		},
		{
			name:     "Valid 24 words (length check only currently)",
			mnemonic: valid24,
			valid:    true,
		},
		{
			name:     "Invalid length (11 words)",
			mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon",
			valid:    false,
		},
		{
			name:     "Invalid length (13 words)",
			mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about about",
			valid:    false,
		},
		{
			name:     "Invalid word",
			mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon nitella",
			valid:    false,
		},
		{
			name:     "Mixed case (should be valid)",
			mnemonic: "Abandon abandon ABANDON abandon abandon abandon abandon abandon abandon abandon abandon ABOUT",
			valid:    true,
		},
		{
			name:     "Empty string",
			mnemonic: "",
			valid:    false,
		},
		{
			name:     "Whitespace only",
			mnemonic: "   ",
			valid:    false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := ValidateMnemonic(tt.mnemonic); got != tt.valid {
				t.Errorf("ValidateMnemonic() = %v, want %v", got, tt.valid)
			}
		})
	}
}

func TestVectorBIP39(t *testing.T) {
	// Test vectors from BIP-39 standard
	// Using empty passphrase ""
	
	vectors := []struct {
		entropy  string
		mnemonic string
		seed     string
	}{
		{
			entropy:  "00000000000000000000000000000000",
			mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
			seed:     "5eb00bbddcf069084889a8ab9155568165f5c453ccb85e70811aaed6f6da5fc19a5ac40b389cd370d086206dec8aa6c43daea6690f20ad3d8d48b2d2ce9e38e4",
		},
		{
			entropy:  "7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f",
			mnemonic: "legal winner thank year wave sausage worth useful legal winner thank yellow",
			seed:     "878386efb78845b3355bd15ea4d39ef97d179cb712b77d5c12b6be415fffeffe5f377ba02bf3f8544ab800b955e51fbff09828f682052a20faa6addbbddfb096",
		},
		{
			entropy:  "80808080808080808080808080808080",
			mnemonic: "letter advice cage absurd amount doctor acoustic avoid letter advice cage above",
			seed:     "77d6be9708c8218738934f84bbbb78a2e048ca007746cb764f0673e4b1812d176bbb173e1a291f31cf633f1d0bad7d3cf071c30e98cd0688b5bcce65ecaceb36",
		},
	}

	for _, v := range vectors {
		t.Run(v.mnemonic[:20]+"...", func(t *testing.T) {
			// 1. Check ValidateMnemonic
			if !ValidateMnemonic(v.mnemonic) {
				t.Error("Test vector mnemonic should be valid")
			}

			// 2. Check Seed Derivation
			seed := mnemonicToSeed(v.mnemonic)
			seedHex := hex.EncodeToString(seed)

			if seedHex != v.seed {
				t.Errorf("Seed mismatch.\nExpected: %s\nGot:      %s", v.seed, seedHex)
			}
			
			// 3. Check Entropy to Mnemonic
			// Need to decode hex entropy first
			entBytes, err := hex.DecodeString(v.entropy)
			if err != nil {
				t.Fatalf("Failed to decode entropy hex: %v", err)
			}
			
			genMnemonic := entropyToMnemonic(entBytes)
			if genMnemonic != v.mnemonic {
				t.Errorf("Mnemonic mismatch.\nExpected: %s\nGot:      %s", v.mnemonic, genMnemonic)
			}
		})
	}
}

// TestPassphraseEncryption tests passphrase-protected key storage
func TestPassphraseEncryption(t *testing.T) {
	// Create temp directory for test
	tmpDir, err := os.MkdirTemp("", "nitella-identity-test-*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	passphrase := "test-passphrase-123"

	// Test 1: Create identity with passphrase
	t.Run("CreateWithPassphrase", func(t *testing.T) {
		cfg := &Config{
			DataDir:    tmpDir,
			CommonName: "test-node",
			ValidYears: 1,
			Passphrase: passphrase,
		}

		id, isNew, err := LoadOrCreate(cfg)
		if err != nil {
			t.Fatalf("Failed to create identity: %v", err)
		}
		if !isNew {
			t.Error("Expected new identity")
		}
		if id.RootKey == nil {
			t.Error("Expected root key to be set")
		}

		// Verify key file is encrypted
		encrypted, err := IsKeyEncrypted(tmpDir)
		if err != nil {
			t.Fatalf("Failed to check encryption: %v", err)
		}
		if !encrypted {
			t.Error("Expected key to be encrypted")
		}
	})

	// Test 2: Load with correct passphrase
	t.Run("LoadWithCorrectPassphrase", func(t *testing.T) {
		id, err := LoadWithPassphrase(tmpDir, passphrase)
		if err != nil {
			t.Fatalf("Failed to load identity: %v", err)
		}
		if id.RootKey == nil {
			t.Error("Expected root key to be set")
		}
		if id.EmojiHash == "" {
			t.Error("Expected emoji hash to be set")
		}
	})

	// Test 3: Load with wrong passphrase
	t.Run("LoadWithWrongPassphrase", func(t *testing.T) {
		_, err := LoadWithPassphrase(tmpDir, "wrong-passphrase")
		if err == nil {
			t.Error("Expected error when loading with wrong passphrase")
		}
	})

	// Test 4: Load encrypted key without passphrase
	t.Run("LoadEncryptedWithoutPassphrase", func(t *testing.T) {
		_, err := LoadWithPassphrase(tmpDir, "")
		if err == nil {
			t.Error("Expected error when loading encrypted key without passphrase")
		}
		if err.Error() != "passphrase required for encrypted key" {
			t.Errorf("Unexpected error: %v", err)
		}
	})

	// Test 5: Load using Load() (backwards compat - should fail for encrypted)
	t.Run("LoadFunctionWithEncryptedKey", func(t *testing.T) {
		_, err := Load(tmpDir)
		if err == nil {
			t.Error("Expected error when using Load() with encrypted key")
		}
	})
}

// TestNoPassphrase tests identity without passphrase (backwards compatibility)
func TestNoPassphrase(t *testing.T) {
	tmpDir, err := os.MkdirTemp("", "nitella-identity-test-*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	// Create identity without passphrase
	cfg := &Config{
		DataDir:    tmpDir,
		CommonName: "test-node",
		ValidYears: 1,
		Passphrase: "", // No passphrase
	}

	id, isNew, err := LoadOrCreate(cfg)
	if err != nil {
		t.Fatalf("Failed to create identity: %v", err)
	}
	if !isNew {
		t.Error("Expected new identity")
	}

	// Verify key is NOT encrypted
	encrypted, err := IsKeyEncrypted(tmpDir)
	if err != nil {
		t.Fatalf("Failed to check encryption: %v", err)
	}
	if encrypted {
		t.Error("Expected key to NOT be encrypted")
	}

	// Should be able to load without passphrase
	id2, err := Load(tmpDir)
	if err != nil {
		t.Fatalf("Failed to load identity: %v", err)
	}

	// Verify same identity
	if id.Fingerprint != id2.Fingerprint {
		t.Error("Fingerprints don't match")
	}
}

// TestKeyExists tests the KeyExists helper
func TestKeyExists(t *testing.T) {
	tmpDir, err := os.MkdirTemp("", "nitella-identity-test-*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	// Initially no key
	if KeyExists(tmpDir) {
		t.Error("Expected no key to exist initially")
	}

	// Create identity
	cfg := DefaultConfig(tmpDir, "test-node")
	_, _, err = LoadOrCreate(cfg)
	if err != nil {
		t.Fatalf("Failed to create identity: %v", err)
	}

	// Now key should exist
	if !KeyExists(tmpDir) {
		t.Error("Expected key to exist after creation")
	}
}

// TestLoadOrCreateWithPassphrase tests the full flow
func TestLoadOrCreateWithPassphrase(t *testing.T) {
	tmpDir, err := os.MkdirTemp("", "nitella-identity-test-*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	passphrase := "my-secret-passphrase"

	// First call - creates new identity
	cfg := &Config{
		DataDir:    tmpDir,
		CommonName: "test-node",
		ValidYears: 1,
		Passphrase: passphrase,
	}

	id1, isNew, err := LoadOrCreate(cfg)
	if err != nil {
		t.Fatalf("Failed to create identity: %v", err)
	}
	if !isNew {
		t.Error("Expected new identity on first call")
	}

	// Second call - loads existing identity
	id2, isNew, err := LoadOrCreate(cfg)
	if err != nil {
		t.Fatalf("Failed to load identity: %v", err)
	}
	if isNew {
		t.Error("Expected existing identity on second call")
	}

	// Verify same identity
	if id1.Fingerprint != id2.Fingerprint {
		t.Error("Fingerprints should match")
	}

	// Third call with wrong passphrase - should fail
	cfg.Passphrase = "wrong-passphrase"
	_, _, err = LoadOrCreate(cfg)
	if err == nil {
		t.Error("Expected error with wrong passphrase")
	}
}

// TestIsKeyEncryptedNonExistent tests IsKeyEncrypted with non-existent key
func TestIsKeyEncryptedNonExistent(t *testing.T) {
	tmpDir, err := os.MkdirTemp("", "nitella-identity-test-*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	_, err = IsKeyEncrypted(tmpDir)
	if err == nil {
		t.Error("Expected error for non-existent key")
	}
}

// TestKeyFilePermissions verifies key files have correct permissions
func TestKeyFilePermissions(t *testing.T) {
	tmpDir, err := os.MkdirTemp("", "nitella-identity-test-*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	cfg := DefaultConfig(tmpDir, "test-node")
	cfg.Passphrase = "test-passphrase"
	_, _, err = LoadOrCreate(cfg)
	if err != nil {
		t.Fatalf("Failed to create identity: %v", err)
	}

	// Check key file permissions (should be 0600)
	keyPath := filepath.Join(tmpDir, "root_ca.key")
	info, err := os.Stat(keyPath)
	if err != nil {
		t.Fatalf("Failed to stat key file: %v", err)
	}

	perm := info.Mode().Perm()
	if perm != 0600 {
		t.Errorf("Expected key file permissions 0600, got %o", perm)
	}

	// Check cert file permissions (should be 0644)
	certPath := filepath.Join(tmpDir, "root_ca.crt")
	info, err = os.Stat(certPath)
	if err != nil {
		t.Fatalf("Failed to stat cert file: %v", err)
	}

	perm = info.Mode().Perm()
	if perm != 0644 {
		t.Errorf("Expected cert file permissions 0644, got %o", perm)
	}
}
