package hubclient

import (
	"testing"

	"github.com/ivere27/nitella/pkg/hub/routing"
)

func TestCLIClientRoutingTokens(t *testing.T) {
	client := NewCLIClient("localhost:50051", "test-token", "user-123")

	t.Run("SetAndGetRoutingToken", func(t *testing.T) {
		nodeID := "node-123"
		token := "routing-token-abc"

		client.SetRoutingToken(nodeID, token)

		got := client.GetRoutingToken(nodeID)
		if got != token {
			t.Errorf("GetRoutingToken mismatch: got %s, want %s", got, token)
		}
	})

	t.Run("GetRoutingToken_NotFound", func(t *testing.T) {
		got := client.GetRoutingToken("nonexistent-node")
		if got != "" {
			t.Errorf("GetRoutingToken should return empty for nonexistent node, got %s", got)
		}
	})

	t.Run("GetAllRoutingTokens", func(t *testing.T) {
		// Reset client
		client = NewCLIClient("localhost:50051", "test-token", "user-123")

		client.SetRoutingToken("node-1", "token-1")
		client.SetRoutingToken("node-2", "token-2")
		client.SetRoutingToken("node-3", "token-3")

		tokens := client.GetAllRoutingTokens()
		if len(tokens) != 3 {
			t.Errorf("Expected 3 tokens, got %d", len(tokens))
		}

		// Verify all tokens are present (order not guaranteed)
		tokenSet := make(map[string]bool)
		for _, token := range tokens {
			tokenSet[token] = true
		}
		for _, expected := range []string{"token-1", "token-2", "token-3"} {
			if !tokenSet[expected] {
				t.Errorf("Expected token %s not found", expected)
			}
		}
	})

	t.Run("LoadRoutingTokens", func(t *testing.T) {
		client = NewCLIClient("localhost:50051", "test-token", "user-123")

		tokensMap := map[string]string{
			"node-a": "token-a",
			"node-b": "token-b",
		}

		client.LoadRoutingTokens(tokensMap)

		if client.GetRoutingToken("node-a") != "token-a" {
			t.Error("LoadRoutingTokens did not load node-a correctly")
		}
		if client.GetRoutingToken("node-b") != "token-b" {
			t.Error("LoadRoutingTokens did not load node-b correctly")
		}
	})
}

func TestCLIClientUserSecret(t *testing.T) {
	client := NewCLIClient("localhost:50051", "test-token", "user-123")

	t.Run("SetAndGetUserSecret", func(t *testing.T) {
		secret := make([]byte, 32)
		for i := range secret {
			secret[i] = byte(i)
		}

		client.SetUserSecret(secret)

		got := client.GetUserSecret()
		if len(got) != len(secret) {
			t.Errorf("GetUserSecret length mismatch: got %d, want %d", len(got), len(secret))
		}

		for i := range secret {
			if got[i] != secret[i] {
				t.Errorf("GetUserSecret byte %d mismatch: got %d, want %d", i, got[i], secret[i])
			}
		}
	})

	t.Run("GetUserSecret_NotSet", func(t *testing.T) {
		emptyClient := NewCLIClient("localhost:50051", "test-token", "user-123")
		got := emptyClient.GetUserSecret()
		if got != nil {
			t.Errorf("GetUserSecret should return nil when not set, got %v", got)
		}
	})
}

func TestCLIClientGenerateRoutingToken(t *testing.T) {
	client := NewCLIClient("localhost:50051", "test-token", "user-123")

	// Generate a user secret
	userSecret, err := routing.GenerateUserSecret()
	if err != nil {
		t.Fatalf("Failed to generate user secret: %v", err)
	}
	client.SetUserSecret(userSecret)

	t.Run("GenerateTokenFromUserSecret", func(t *testing.T) {
		nodeID := "new-node-123"

		// First call should generate and cache the token
		token1 := client.GetRoutingToken(nodeID)
		if token1 == "" {
			t.Error("GetRoutingToken should generate token when userSecret is set")
		}

		// Second call should return the cached token
		token2 := client.GetRoutingToken(nodeID)
		if token1 != token2 {
			t.Errorf("Token should be cached: got different tokens %s and %s", token1, token2)
		}

		// Verify it matches what routing.GenerateRoutingToken would produce
		expected := routing.GenerateRoutingToken(nodeID, userSecret)
		if token1 != expected {
			t.Errorf("Generated token mismatch: got %s, want %s", token1, expected)
		}
	})

	t.Run("NoGenerationWithoutUserSecret", func(t *testing.T) {
		emptyClient := NewCLIClient("localhost:50051", "test-token", "user-123")

		token := emptyClient.GetRoutingToken("some-node")
		if token != "" {
			t.Errorf("GetRoutingToken should return empty without userSecret, got %s", token)
		}
	})
}

func TestCLIClientRoutingTokenConsistency(t *testing.T) {
	// Test that routing tokens are consistent across different clients with same userSecret
	userSecret, _ := routing.GenerateUserSecret()
	nodeID := "consistent-node"

	client1 := NewCLIClient("localhost:50051", "test-token", "user-1")
	client1.SetUserSecret(userSecret)

	client2 := NewCLIClient("localhost:50051", "test-token", "user-2")
	client2.SetUserSecret(userSecret)

	token1 := client1.GetRoutingToken(nodeID)
	token2 := client2.GetRoutingToken(nodeID)

	if token1 != token2 {
		t.Errorf("Routing tokens should be consistent for same userSecret: got %s and %s", token1, token2)
	}

	// Different userSecret should produce different token
	differentSecret, _ := routing.GenerateUserSecret()
	client3 := NewCLIClient("localhost:50051", "test-token", "user-3")
	client3.SetUserSecret(differentSecret)

	token3 := client3.GetRoutingToken(nodeID)
	if token1 == token3 {
		t.Error("Different userSecret should produce different routing token")
	}
}
