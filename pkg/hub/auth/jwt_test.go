package auth

import (
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/x509"
	"encoding/pem"
	"testing"
	"time"
)

// generateTestKeyPEM generates an Ed25519 key pair and returns PEM-encoded keys
func generateTestKeyPEM(t *testing.T) (privPEM, pubPEM []byte) {
	pub, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatalf("Failed to generate key: %v", err)
	}

	// Encode private key to PKCS8
	privBytes, err := x509.MarshalPKCS8PrivateKey(priv)
	if err != nil {
		t.Fatalf("Failed to marshal private key: %v", err)
	}
	privPEM = pem.EncodeToMemory(&pem.Block{
		Type:  "PRIVATE KEY",
		Bytes: privBytes,
	})

	// Encode public key
	pubBytes, err := x509.MarshalPKIXPublicKey(pub)
	if err != nil {
		t.Fatalf("Failed to marshal public key: %v", err)
	}
	pubPEM = pem.EncodeToMemory(&pem.Block{
		Type:  "PUBLIC KEY",
		Bytes: pubBytes,
	})

	return privPEM, pubPEM
}

func TestTokenManager(t *testing.T) {
	privPEM, _ := generateTestKeyPEM(t)

	manager, err := NewTokenManager(privPEM, nil, "test-issuer")
	if err != nil {
		t.Fatalf("Failed to create token manager: %v", err)
	}

	t.Run("GenerateMobileToken", func(t *testing.T) {
		token, err := manager.GenerateMobileToken("user-123", "device-456")
		if err != nil {
			t.Fatalf("Failed to generate token: %v", err)
		}
		if token == "" {
			t.Error("Token should not be empty")
		}

		// Validate token
		claims, err := manager.ValidateToken(token)
		if err != nil {
			t.Fatalf("Failed to validate token: %v", err)
		}
		if claims.Subject != "user-123" {
			t.Errorf("Subject mismatch: got %s, want user-123", claims.Subject)
		}
		if claims.Role != "mobile" {
			t.Errorf("Role mismatch: got %s, want mobile", claims.Role)
		}
		if claims.UserID != "user-123" {
			t.Errorf("UserID mismatch: got %s, want user-123", claims.UserID)
		}
		if claims.DeviceID != "device-456" {
			t.Errorf("DeviceID mismatch: got %s, want device-456", claims.DeviceID)
		}
	})

	t.Run("GenerateNodeToken", func(t *testing.T) {
		token, err := manager.GenerateNodeToken("node-123", "user-456")
		if err != nil {
			t.Fatalf("Failed to generate token: %v", err)
		}

		claims, err := manager.ValidateToken(token)
		if err != nil {
			t.Fatalf("Failed to validate token: %v", err)
		}
		if claims.Subject != "node-123" {
			t.Errorf("Subject mismatch: got %s, want node-123", claims.Subject)
		}
		if claims.Role != "node" {
			t.Errorf("Role mismatch: got %s, want node", claims.Role)
		}
		if claims.UserID != "user-456" {
			t.Errorf("UserID mismatch: got %s, want user-456", claims.UserID)
		}
		if claims.NodeID != "node-123" {
			t.Errorf("NodeID mismatch: got %s, want node-123", claims.NodeID)
		}
	})

	t.Run("GenerateAdminToken", func(t *testing.T) {
		token, err := manager.GenerateAdminToken("admin-123")
		if err != nil {
			t.Fatalf("Failed to generate token: %v", err)
		}

		claims, err := manager.ValidateToken(token)
		if err != nil {
			t.Fatalf("Failed to validate token: %v", err)
		}
		if claims.Role != "admin" {
			t.Errorf("Role mismatch: got %s, want admin", claims.Role)
		}
		if claims.UserID != "admin-123" {
			t.Errorf("UserID mismatch: got %s, want admin-123", claims.UserID)
		}
	})

	t.Run("GenerateToken", func(t *testing.T) {
		token, err := manager.GenerateToken("user-789", "node-789", "custom-role", time.Hour)
		if err != nil {
			t.Fatalf("Failed to generate token: %v", err)
		}

		claims, err := manager.ValidateToken(token)
		if err != nil {
			t.Fatalf("Failed to validate token: %v", err)
		}
		if claims.UserID != "user-789" {
			t.Errorf("UserID mismatch: got %s, want user-789", claims.UserID)
		}
		if claims.NodeID != "node-789" {
			t.Errorf("NodeID mismatch: got %s, want node-789", claims.NodeID)
		}
		if claims.Role != "custom-role" {
			t.Errorf("Role mismatch: got %s, want custom-role", claims.Role)
		}
	})

	t.Run("InvalidToken", func(t *testing.T) {
		_, err := manager.ValidateToken("invalid-token")
		if err == nil {
			t.Error("Expected error for invalid token")
		}
	})

	t.Run("TamperedToken", func(t *testing.T) {
		token, _ := manager.GenerateMobileToken("user-123", "device-456")
		// Tamper with the token
		tamperedToken := token[:len(token)-5] + "XXXXX"
		_, err := manager.ValidateToken(tamperedToken)
		if err == nil {
			t.Error("Expected error for tampered token")
		}
	})
}

func TestTokenManagerWithKeyRotation(t *testing.T) {
	// Generate old and new keys
	oldPrivPEM, _ := generateTestKeyPEM(t)
	newPrivPEM, _ := generateTestKeyPEM(t)

	// Create manager with old key as legacy
	manager, err := NewTokenManagerWithRotation(newPrivPEM, nil, oldPrivPEM, "test-issuer")
	if err != nil {
		t.Fatalf("Failed to create token manager with rotation: %v", err)
	}

	// Generate token with old manager (simulating old token)
	oldManager, err := NewTokenManager(oldPrivPEM, nil, "test-issuer")
	if err != nil {
		t.Fatalf("Failed to create old token manager: %v", err)
	}
	oldToken, err := oldManager.GenerateMobileToken("user-old", "device-old")
	if err != nil {
		t.Fatalf("Failed to generate old token: %v", err)
	}

	// New manager should accept old tokens
	claims, err := manager.ValidateToken(oldToken)
	if err != nil {
		t.Fatalf("Failed to validate old token with new manager: %v", err)
	}
	if claims.Subject != "user-old" {
		t.Errorf("Subject mismatch: got %s, want user-old", claims.Subject)
	}

	// New manager generates tokens with new key
	newToken, err := manager.GenerateMobileToken("user-new", "device-new")
	if err != nil {
		t.Fatalf("Failed to generate new token: %v", err)
	}
	claims, err = manager.ValidateToken(newToken)
	if err != nil {
		t.Fatalf("Failed to validate new token: %v", err)
	}
	if claims.Subject != "user-new" {
		t.Errorf("Subject mismatch: got %s, want user-new", claims.Subject)
	}
}

func TestContextHelpers(t *testing.T) {
	claims := &Claims{
		UserID: "user-123",
		NodeID: "node-456",
		Role:   "mobile",
		TierID: "pro",
	}

	ctx := NewContext(context.Background(), claims)

	// Test GetClaims
	retrieved, ok := GetClaims(ctx)
	if !ok {
		t.Fatal("GetClaims returned false")
	}
	if retrieved == nil {
		t.Fatal("GetClaims returned nil")
	}
	if retrieved.UserID != claims.UserID {
		t.Errorf("UserID mismatch: got %s, want %s", retrieved.UserID, claims.UserID)
	}

	// Test GetUserID
	userID, ok := GetUserID(ctx)
	if !ok {
		t.Fatal("GetUserID returned false")
	}
	if userID != "user-123" {
		t.Errorf("UserID mismatch: got %s, want user-123", userID)
	}

	// Test GetNodeID
	nodeID, ok := GetNodeID(ctx)
	if !ok {
		t.Fatal("GetNodeID returned false")
	}
	if nodeID != "node-456" {
		t.Errorf("NodeID mismatch: got %s, want node-456", nodeID)
	}

	// Test GetRole
	role, ok := GetRole(ctx)
	if !ok {
		t.Fatal("GetRole returned false")
	}
	if role != "mobile" {
		t.Errorf("Role mismatch: got %s, want mobile", role)
	}

	// Test with empty context
	emptyCtx := context.Background()
	_, ok = GetClaims(emptyCtx)
	if ok {
		t.Error("GetClaims should return false for empty context")
	}
	_, ok = GetUserID(emptyCtx)
	if ok {
		t.Error("GetUserID should return false for empty context")
	}
}

func TestRefreshToken(t *testing.T) {
	privPEM, _ := generateTestKeyPEM(t)
	manager, err := NewTokenManager(privPEM, nil, "test-issuer")
	if err != nil {
		t.Fatalf("Failed to create token manager: %v", err)
	}

	// Generate initial token
	token, err := manager.GenerateMobileToken("user-123", "device-456")
	if err != nil {
		t.Fatalf("Failed to generate token: %v", err)
	}

	// Since the token has more than 1 hour validity, RefreshToken should return the same token
	refreshedToken, err := manager.RefreshToken(token)
	if err != nil {
		t.Fatalf("Failed to refresh token: %v", err)
	}

	// Token should be the same (not refreshed yet)
	if refreshedToken != token {
		t.Error("Token should not be refreshed when it has more than 1 hour validity")
	}

	// Validate the token still works
	claims, err := manager.ValidateToken(refreshedToken)
	if err != nil {
		t.Fatalf("Failed to validate token: %v", err)
	}
	if claims.Subject != "user-123" {
		t.Errorf("Subject mismatch: got %s, want user-123", claims.Subject)
	}
}

func TestPublicKeyOnlyMode(t *testing.T) {
	privPEM, pubPEM := generateTestKeyPEM(t)

	// Create full manager with private key to generate token
	fullManager, err := NewTokenManager(privPEM, nil, "test-issuer")
	if err != nil {
		t.Fatalf("Failed to create full manager: %v", err)
	}

	token, err := fullManager.GenerateMobileToken("user-123", "device-456")
	if err != nil {
		t.Fatalf("Failed to generate token: %v", err)
	}

	// Create public-key-only manager
	pubOnlyManager, err := NewTokenManager(nil, pubPEM, "test-issuer")
	if err != nil {
		t.Fatalf("Failed to create public-key-only manager: %v", err)
	}

	// Should be able to validate
	claims, err := pubOnlyManager.ValidateToken(token)
	if err != nil {
		t.Fatalf("Failed to validate with public key: %v", err)
	}
	if claims.UserID != "user-123" {
		t.Errorf("UserID mismatch: got %s, want user-123", claims.UserID)
	}

	// Should not be able to generate
	_, err = pubOnlyManager.GenerateMobileToken("user-456", "device-789")
	if err == nil {
		t.Error("Expected error when generating with public-key-only manager")
	}
}
