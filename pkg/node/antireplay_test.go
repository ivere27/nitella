package node

import (
	"testing"
	"time"
)

func TestAntiReplayCache_ValidateCommand(t *testing.T) {
	cache := NewAntiReplayCache(1*time.Minute, "trusted-fingerprint-123")

	now := time.Now().Unix()

	// Test 1: Valid command should pass
	err := cache.ValidateCommand("req-001", now, "trusted-fingerprint-123")
	if err != nil {
		t.Errorf("Valid command rejected: %v", err)
	}

	// Test 2: Replay should fail
	err = cache.ValidateCommand("req-001", now, "trusted-fingerprint-123")
	if err == nil {
		t.Error("Replay attack not detected")
	}

	// Test 3: Expired command (> 1 minute old) should fail
	oldTime := now - 120 // 2 minutes ago
	err = cache.ValidateCommand("req-002", oldTime, "trusted-fingerprint-123")
	if err == nil {
		t.Error("Expired command not rejected")
	}

	// Test 4: Untrusted sender should fail
	err = cache.ValidateCommand("req-003", now, "untrusted-fingerprint")
	if err == nil {
		t.Error("Untrusted sender not rejected")
	}

	// Test 5: Future timestamp (> 30s) should fail
	futureTime := now + 60 // 1 minute in future
	err = cache.ValidateCommand("req-004", futureTime, "trusted-fingerprint-123")
	if err == nil {
		t.Error("Far future timestamp not rejected")
	}

	// Test 6: Slight future timestamp (< 30s) should pass (clock skew tolerance)
	slightFuture := now + 15
	err = cache.ValidateCommand("req-005", slightFuture, "trusted-fingerprint-123")
	if err != nil {
		t.Errorf("Slight clock skew rejected: %v", err)
	}
}

func TestAntiReplayCache_EmptyTrustedFingerprint(t *testing.T) {
	// When trustedFingerprint is empty, all senders are allowed
	cache := NewAntiReplayCache(1*time.Minute, "")

	err := cache.ValidateCommand("req-100", time.Now().Unix(), "any-fingerprint")
	if err != nil {
		t.Errorf("Expected pass when trustedFingerprint is empty: %v", err)
	}
}

func TestAntiReplayCache_Stats(t *testing.T) {
	cache := NewAntiReplayCache(1*time.Minute, "")

	if cache.Stats() != 0 {
		t.Error("Expected 0 entries initially")
	}

	cache.ValidateCommand("req-1", time.Now().Unix(), "")
	cache.ValidateCommand("req-2", time.Now().Unix(), "")
	cache.ValidateCommand("req-3", time.Now().Unix(), "")

	if cache.Stats() != 3 {
		t.Errorf("Expected 3 entries, got %d", cache.Stats())
	}
}
