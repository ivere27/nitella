package crypto

import (
	"testing"
)

func TestKDFProfiles(t *testing.T) {
	// Verify all profiles exist
	profiles := []string{"default", "server", "secure"}
	for _, name := range profiles {
		params, err := GetKDFProfile(name)
		if err != nil {
			t.Errorf("GetKDFProfile(%q) failed: %v", name, err)
		}
		if params.Time == 0 || params.Memory == 0 || params.Threads == 0 {
			t.Errorf("GetKDFProfile(%q) returned zero params: %+v", name, params)
		}
	}

	// Verify unknown profile returns error
	_, err := GetKDFProfile("unknown")
	if err == nil {
		t.Error("GetKDFProfile(unknown) should return error")
	}
}

func TestKDFParamsEncodeDecode(t *testing.T) {
	testCases := []KDFParams{
		KDFDefault,
		KDFServer,
		KDFSecure,
		{Time: 5, Memory: 256 * 1024, Threads: 8},
	}

	for _, original := range testCases {
		encoded := original.Encode()
		if len(encoded) != 9 {
			t.Errorf("Encode() should return 9 bytes, got %d", len(encoded))
		}

		decoded, err := DecodeKDFParams(encoded)
		if err != nil {
			t.Errorf("DecodeKDFParams failed: %v", err)
		}

		if decoded.Time != original.Time {
			t.Errorf("Time mismatch: got %d, want %d", decoded.Time, original.Time)
		}
		if decoded.Memory != original.Memory {
			t.Errorf("Memory mismatch: got %d, want %d", decoded.Memory, original.Memory)
		}
		if decoded.Threads != original.Threads {
			t.Errorf("Threads mismatch: got %d, want %d", decoded.Threads, original.Threads)
		}
	}
}

func TestDecodeKDFParamsTooShort(t *testing.T) {
	_, err := DecodeKDFParams([]byte{1, 2, 3})
	if err == nil {
		t.Error("DecodeKDFParams should fail on short data")
	}
}

func TestKDFParamsString(t *testing.T) {
	s := KDFDefault.String()
	if s == "" {
		t.Error("String() should not be empty")
	}
	// Should contain key info
	if !contains(s, "Argon2id") {
		t.Errorf("String() should mention Argon2id: %s", s)
	}
}

func TestKDFParamsProfileName(t *testing.T) {
	if KDFDefault.ProfileName() != "default" {
		t.Errorf("KDFDefault.ProfileName() = %s, want default", KDFDefault.ProfileName())
	}
	if KDFServer.ProfileName() != "server" {
		t.Errorf("KDFServer.ProfileName() = %s, want server", KDFServer.ProfileName())
	}
	if KDFSecure.ProfileName() != "secure" {
		t.Errorf("KDFSecure.ProfileName() = %s, want secure", KDFSecure.ProfileName())
	}

	custom := KDFParams{Time: 99, Memory: 99, Threads: 99}
	if custom.ProfileName() != "custom" {
		t.Errorf("Custom params ProfileName() = %s, want custom", custom.ProfileName())
	}
}

func TestKDFParamsSecurityComparison(t *testing.T) {
	// Server should be lower security
	serverSec := KDFServer.SecurityComparison()
	if !contains(serverSec, "lower") {
		t.Errorf("Server security comparison should mention 'lower': %s", serverSec)
	}

	// Default should be standard
	defaultSec := KDFDefault.SecurityComparison()
	if !contains(defaultSec, "standard") {
		t.Errorf("Default security comparison should mention 'standard': %s", defaultSec)
	}

	// Secure should be higher
	secureSec := KDFSecure.SecurityComparison()
	if !contains(secureSec, "higher") && !contains(secureSec, "maximum") {
		t.Errorf("Secure security comparison should mention 'higher' or 'maximum': %s", secureSec)
	}
}

func TestEncryptDecryptWithDifferentKDFParams(t *testing.T) {
	priv, _ := GenerateKey()
	passphrase := "test-passphrase-123"

	// Test with each profile
	for name, params := range KDFProfiles {
		t.Run(name, func(t *testing.T) {
			// Encrypt with specific params
			encrypted, err := EncryptPrivateKeyToPEMWithParams(priv, passphrase, params)
			if err != nil {
				t.Fatalf("EncryptPrivateKeyToPEMWithParams failed: %v", err)
			}

			// Verify we can extract params
			extractedParams, err := GetEncryptedKeyKDFParams(encrypted)
			if err != nil {
				t.Fatalf("GetEncryptedKeyKDFParams failed: %v", err)
			}

			if extractedParams.Time != params.Time {
				t.Errorf("Extracted Time = %d, want %d", extractedParams.Time, params.Time)
			}
			if extractedParams.Memory != params.Memory {
				t.Errorf("Extracted Memory = %d, want %d", extractedParams.Memory, params.Memory)
			}

			// Decrypt should work
			decrypted, err := DecryptPrivateKeyFromPEM(encrypted, passphrase)
			if err != nil {
				t.Fatalf("DecryptPrivateKeyFromPEM failed: %v", err)
			}

			// Verify key matches
			if !equal(priv, decrypted) {
				t.Error("Decrypted key doesn't match original")
			}
		})
	}
}

// helper functions
func contains(s, substr string) bool {
	return len(s) >= len(substr) && (s == substr || len(substr) == 0 ||
		(len(s) > 0 && len(substr) > 0 && findSubstring(s, substr)))
}

func findSubstring(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}

func equal(a, b []byte) bool {
	if len(a) != len(b) {
		return false
	}
	for i := range a {
		if a[i] != b[i] {
			return false
		}
	}
	return true
}
