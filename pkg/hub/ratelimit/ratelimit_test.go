package ratelimit

import (
	"testing"
	"time"

	"github.com/ivere27/nitella/pkg/tier"
)

func TestIPRateLimiter(t *testing.T) {
	t.Run("AllowWithinLimit", func(t *testing.T) {
		rl := NewIPRateLimiter(IPRateLimiterConfig{
			RateLimit:       10,
			BurstSize:       20,
			CleanupInterval: time.Minute,
			BucketExpiry:    time.Minute,
		})
		defer rl.Stop()

		// Should allow up to burst size
		for i := 0; i < 20; i++ {
			if !rl.Allow("192.168.1.1") {
				t.Fatalf("Request %d should be allowed (within burst)", i+1)
			}
		}
	})

	t.Run("BlockAfterBurst", func(t *testing.T) {
		rl := NewIPRateLimiter(IPRateLimiterConfig{
			RateLimit:       10,
			BurstSize:       5,
			CleanupInterval: time.Minute,
			BucketExpiry:    time.Minute,
		})
		defer rl.Stop()

		// Exhaust burst
		for i := 0; i < 5; i++ {
			rl.Allow("192.168.1.1")
		}

		// Next request should be blocked
		if rl.Allow("192.168.1.1") {
			t.Fatal("Request should be blocked after burst exhausted")
		}
	})

	t.Run("RefillTokens", func(t *testing.T) {
		rl := NewIPRateLimiter(IPRateLimiterConfig{
			RateLimit:       10,
			BurstSize:       5,
			CleanupInterval: time.Minute,
			BucketExpiry:    time.Minute,
		})
		defer rl.Stop()

		// Exhaust burst
		for i := 0; i < 5; i++ {
			rl.Allow("192.168.1.1")
		}

		// Wait for refill (int(seconds) * rate, so need at least 1 second)
		time.Sleep(1100 * time.Millisecond)

		// Should have 10 tokens now (1 sec * 10/s = 10, capped at burst 5)
		if !rl.Allow("192.168.1.1") {
			t.Fatal("Request should be allowed after token refill")
		}
	})

	t.Run("SeparateIPBuckets", func(t *testing.T) {
		rl := NewIPRateLimiter(IPRateLimiterConfig{
			RateLimit:       10,
			BurstSize:       2,
			CleanupInterval: time.Minute,
			BucketExpiry:    time.Minute,
		})
		defer rl.Stop()

		// Exhaust IP1
		rl.Allow("192.168.1.1")
		rl.Allow("192.168.1.1")
		if rl.Allow("192.168.1.1") {
			t.Fatal("IP1 should be blocked")
		}

		// IP2 should still work
		if !rl.Allow("192.168.1.2") {
			t.Fatal("IP2 should be allowed (separate bucket)")
		}
	})

	t.Run("CleanupStale", func(t *testing.T) {
		rl := NewIPRateLimiter(IPRateLimiterConfig{
			RateLimit:       10,
			BurstSize:       5,
			CleanupInterval: 10 * time.Millisecond,
			BucketExpiry:    20 * time.Millisecond,
		})
		defer rl.Stop()

		rl.Allow("192.168.1.1")

		// Verify bucket exists
		rl.mu.RLock()
		_, exists := rl.buckets["192.168.1.1"]
		rl.mu.RUnlock()
		if !exists {
			t.Fatal("Bucket should exist")
		}

		// Wait for cleanup
		time.Sleep(50 * time.Millisecond)

		// Bucket should be cleaned up
		rl.mu.RLock()
		_, exists = rl.buckets["192.168.1.1"]
		rl.mu.RUnlock()
		if exists {
			t.Fatal("Bucket should be cleaned up after expiry")
		}
	})
}

func TestTieredRateLimiter(t *testing.T) {
	tierCfg := &tier.Config{
		Tiers: []tier.TierConfig{
			{
				ID:   "free",
				Name: "Free",
				RPC:  tier.RPCConfig{RequestsPerSecond: 5, BurstSize: 10, MaxStreams: 2},
			},
			{
				ID:   "pro",
				Name: "Pro",
				RPC:  tier.RPCConfig{RequestsPerSecond: 50, BurstSize: 100, MaxStreams: 10},
			},
		},
	}

	t.Run("FreeTierLimit", func(t *testing.T) {
		trl := NewTieredRateLimiter(tierCfg, func(token string) string {
			return "free"
		})

		// Should allow up to burst size (10)
		for i := 0; i < 10; i++ {
			if !trl.Allow("token-1") {
				t.Fatalf("Request %d should be allowed (within burst)", i+1)
			}
		}

		// Next should be blocked
		if trl.Allow("token-1") {
			t.Fatal("Request should be blocked after burst exhausted")
		}
	})

	t.Run("ProTierHigherLimit", func(t *testing.T) {
		trl := NewTieredRateLimiter(tierCfg, func(token string) string {
			if token == "pro-token" {
				return "pro"
			}
			return "free"
		})

		// Pro tier has burst of 100
		for i := 0; i < 50; i++ {
			if !trl.Allow("pro-token") {
				t.Fatalf("Pro request %d should be allowed", i+1)
			}
		}

		// Free tier exhausts at 10
		for i := 0; i < 10; i++ {
			trl.Allow("free-token")
		}
		if trl.Allow("free-token") {
			t.Fatal("Free tier should be blocked after 10 requests")
		}

		// Pro tier should still have tokens
		if !trl.Allow("pro-token") {
			t.Fatal("Pro tier should still have tokens")
		}
	})

	t.Run("TierUpgrade", func(t *testing.T) {
		currentTier := "free"
		trl := NewTieredRateLimiter(tierCfg, func(token string) string {
			return currentTier
		})

		// Exhaust free tier
		for i := 0; i < 10; i++ {
			trl.Allow("token-1")
		}
		if trl.Allow("token-1") {
			t.Fatal("Should be blocked on free tier")
		}

		// Upgrade to pro
		currentTier = "pro"

		// Should now have pro burst (100)
		if !trl.Allow("token-1") {
			t.Fatal("Should be allowed after upgrade to pro")
		}
	})

	t.Run("GetTierLimit", func(t *testing.T) {
		trl := NewTieredRateLimiter(tierCfg, func(token string) string {
			if token == "pro-token" {
				return "pro"
			}
			return "free"
		})

		freeLimit := trl.GetTierLimit("free-token")
		if freeLimit != 5 {
			t.Fatalf("Free tier limit should be 5, got %d", freeLimit)
		}

		proLimit := trl.GetTierLimit("pro-token")
		if proLimit != 50 {
			t.Fatalf("Pro tier limit should be 50, got %d", proLimit)
		}
	})

	t.Run("GetRemainingTokens", func(t *testing.T) {
		trl := NewTieredRateLimiter(tierCfg, func(token string) string {
			return "free"
		})

		// Unknown token returns -1
		if trl.GetRemainingTokens("unknown") != -1 {
			t.Fatal("Unknown token should return -1")
		}

		// After first request, should have burst-1 tokens
		trl.Allow("token-1")
		remaining := trl.GetRemainingTokens("token-1")
		if remaining != 9 { // burst(10) - 1
			t.Fatalf("Should have 9 remaining tokens, got %d", remaining)
		}
	})
}

// Mock request with GetRoutingToken method
type mockRequestWithToken struct {
	routingToken string
}

func (m *mockRequestWithToken) GetRoutingToken() string {
	return m.routingToken
}

func TestRoutingTokenExtraction(t *testing.T) {
	t.Run("ExtractFromInterface", func(t *testing.T) {
		req := &mockRequestWithToken{routingToken: "test-token"}

		// Test interface assertion
		getter, ok := any(req).(RoutingTokenGetter)
		if !ok {
			t.Fatal("Should implement RoutingTokenGetter")
		}

		token := getter.GetRoutingToken()
		if token != "test-token" {
			t.Fatalf("Expected 'test-token', got '%s'", token)
		}
	})

	t.Run("NoRoutingToken", func(t *testing.T) {
		req := struct{ Name string }{Name: "test"}

		_, ok := any(req).(RoutingTokenGetter)
		if ok {
			t.Fatal("Should not implement RoutingTokenGetter")
		}
	})
}
