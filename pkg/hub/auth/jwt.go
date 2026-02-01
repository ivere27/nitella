package auth

import (
	"context"
	"crypto/ed25519"
	"crypto/x509"
	"encoding/pem"
	"errors"
	"fmt"
	"sync"
	"time"

	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/golang-jwt/jwt/v5"
)

type contextKey string

const claimsKey contextKey = "claims"

// Claims represents the JWT claims for Nitella authentication
type Claims struct {
	jwt.RegisteredClaims
	UserID   string `json:"user_id,omitempty"`
	NodeID   string `json:"node_id,omitempty"`
	DeviceID string `json:"device_id,omitempty"`
	Role     string `json:"role,omitempty"` // "mobile", "node", "admin"
	TierID   string `json:"tier_id,omitempty"`
}

// TokenManager handles JWT token generation and validation
type TokenManager struct {
	privateKey      ed25519.PrivateKey
	publicKey       ed25519.PublicKey
	legacyPublicKey ed25519.PublicKey // For graceful key rotation
	issuer          string

	// Rate limiting for token refresh
	refreshRateMu    sync.Mutex
	refreshAttempts  map[string][]time.Time // userID -> list of refresh times
	maxRefreshPerMin int
	lastCleanup      time.Time // last time we cleaned up stale entries
}

// NewTokenManager creates a new TokenManager with the given Ed25519 key pair
func NewTokenManager(privKeyPEM, pubKeyPEM []byte, issuer string) (*TokenManager, error) {
	tm := &TokenManager{
		issuer:           issuer,
		refreshAttempts:  make(map[string][]time.Time),
		maxRefreshPerMin: 10, // Max 10 refreshes per minute per user
	}

	if len(privKeyPEM) > 0 {
		privKey, err := nitellacrypto.DecodePrivateKeyFromPEM(privKeyPEM)
		if err != nil {
			return nil, fmt.Errorf("failed to decode private key: %w", err)
		}
		tm.privateKey = privKey
		// Derive public key from private
		tm.publicKey = privKey.Public().(ed25519.PublicKey)
	}

	if len(pubKeyPEM) > 0 {
		// If provided separately (e.g. public only mode), parse it
		block, _ := pem.Decode(pubKeyPEM)
		if block == nil {
			return nil, errors.New("failed to decode public key PEM")
		}
		key, err := x509.ParsePKIXPublicKey(block.Bytes)
		if err != nil {
			return nil, fmt.Errorf("failed to parse public key: %w", err)
		}
		edKey, ok := key.(ed25519.PublicKey)
		if !ok {
			return nil, errors.New("public key is not Ed25519")
		}
		tm.publicKey = edKey
	}

	if tm.privateKey == nil && tm.publicKey == nil {
		return nil, errors.New("neither private nor public key provided")
	}

	return tm, nil
}

// NewTokenManagerWithRotation creates a TokenManager with legacy key support for graceful rotation.
// The legacy key is used for validation only - new tokens are always signed with the current key.
func NewTokenManagerWithRotation(privKeyPEM, pubKeyPEM, legacyKeyPEM []byte, issuer string) (*TokenManager, error) {
	tm, err := NewTokenManager(privKeyPEM, pubKeyPEM, issuer)
	if err != nil {
		return nil, err
	}

	// Parse legacy key for validation fallback
	if len(legacyKeyPEM) > 0 {
		legacyPrivKey, err := nitellacrypto.DecodePrivateKeyFromPEM(legacyKeyPEM)
		if err != nil {
			return nil, fmt.Errorf("failed to decode legacy key: %w", err)
		}
		tm.legacyPublicKey = legacyPrivKey.Public().(ed25519.PublicKey)
	}

	return tm, nil
}

// GenerateToken generates a new JWT token for the given claims
func (tm *TokenManager) GenerateToken(userID, nodeID, role string, duration time.Duration) (string, error) {
	if tm.privateKey == nil {
		return "", errors.New("private key required for token generation")
	}

	now := time.Now()
	claims := Claims{
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    tm.issuer,
			Subject:   userID,
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(duration)),
			NotBefore: jwt.NewNumericDate(now),
		},
		UserID: userID,
		NodeID: nodeID,
		Role:   role,
	}

	token := jwt.NewWithClaims(jwt.SigningMethodEdDSA, claims)
	return token.SignedString(tm.privateKey)
}

// ValidateToken validates a JWT token and returns the claims.
// If a legacy key is configured, it will try the current key first,
// then fall back to the legacy key for graceful rotation.
func (tm *TokenManager) ValidateToken(tokenString string) (*Claims, error) {
	if tm.publicKey == nil {
		return nil, errors.New("public key required for token validation")
	}

	// Try current key first
	claims, err := tm.validateWithKey(tokenString, tm.publicKey)
	if err == nil {
		return claims, nil
	}

	// If legacy key is configured, try it as fallback
	if tm.legacyPublicKey != nil {
		legacyClaims, legacyErr := tm.validateWithKey(tokenString, tm.legacyPublicKey)
		if legacyErr == nil {
			return legacyClaims, nil
		}
	}

	// Return original error
	return nil, err
}

// validateWithKey validates a JWT token with a specific public key
func (tm *TokenManager) validateWithKey(tokenString string, pubKey ed25519.PublicKey) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodEd25519); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return pubKey, nil
	})

	if err != nil {
		return nil, fmt.Errorf("token parsing failed: %w", err)
	}

	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, errors.New("invalid token")
	}

	return claims, nil
}

// GenerateMobileToken creates a token for mobile/CLI app authentication
func (tm *TokenManager) GenerateMobileToken(userID, deviceID string) (string, error) {
	if tm.privateKey == nil {
		return "", errors.New("private key required for token generation")
	}

	now := time.Now()
	claims := Claims{
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    tm.issuer,
			Subject:   userID,
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(24 * time.Hour)), // 24 hour expiry
			NotBefore: jwt.NewNumericDate(now),
		},
		UserID:   userID,
		DeviceID: deviceID,
		Role:     "mobile",
	}

	token := jwt.NewWithClaims(jwt.SigningMethodEdDSA, claims)
	return token.SignedString(tm.privateKey)
}

// GenerateNodeToken creates a token for proxy node authentication
func (tm *TokenManager) GenerateNodeToken(nodeID, userID string) (string, error) {
	if tm.privateKey == nil {
		return "", errors.New("private key required for token generation")
	}

	now := time.Now()
	claims := Claims{
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    tm.issuer,
			Subject:   nodeID,
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(7 * 24 * time.Hour)), // 7 day expiry for nodes
			NotBefore: jwt.NewNumericDate(now),
		},
		NodeID: nodeID,
		UserID: userID, // Owner
		Role:   "node",
	}

	token := jwt.NewWithClaims(jwt.SigningMethodEdDSA, claims)
	return token.SignedString(tm.privateKey)
}

// GenerateAdminToken creates a token for hub admin authentication
func (tm *TokenManager) GenerateAdminToken(adminID string) (string, error) {
	if tm.privateKey == nil {
		return "", errors.New("private key required for token generation")
	}

	now := time.Now()
	claims := Claims{
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    tm.issuer,
			Subject:   adminID,
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(1 * time.Hour)), // 1 hour expiry for admin
			NotBefore: jwt.NewNumericDate(now),
		},
		UserID: adminID,
		Role:   "admin",
	}

	token := jwt.NewWithClaims(jwt.SigningMethodEdDSA, claims)
	return token.SignedString(tm.privateKey)
}

// RefreshToken creates a new token with extended expiry if the current token is still valid
// Preserves all claim data including DeviceID and TierID
func (tm *TokenManager) RefreshToken(tokenString string) (string, error) {
	claims, err := tm.ValidateToken(tokenString)
	if err != nil {
		return "", fmt.Errorf("cannot refresh invalid token: %w", err)
	}

	// Check if token is within refresh window (expires in less than 1 hour)
	if time.Until(claims.ExpiresAt.Time) > time.Hour {
		return tokenString, nil // Token still has plenty of time
	}

	// Rate limit refresh attempts
	userKey := claims.UserID
	if userKey == "" {
		userKey = claims.NodeID // Use nodeID for node tokens
	}
	if userKey != "" {
		if err := tm.checkRefreshRateLimit(userKey); err != nil {
			return "", err
		}
	}

	// Generate new token with same claims but new expiry
	var duration time.Duration
	switch claims.Role {
	case "mobile":
		duration = 24 * time.Hour
	case "node":
		duration = 7 * 24 * time.Hour
	case "admin":
		duration = 1 * time.Hour
	default:
		duration = 1 * time.Hour
	}

	return tm.GenerateTokenWithAllClaims(claims.UserID, claims.NodeID, claims.DeviceID, claims.Role, claims.TierID, duration)
}

// checkRefreshRateLimit checks if a user has exceeded the refresh rate limit
func (tm *TokenManager) checkRefreshRateLimit(userID string) error {
	tm.refreshRateMu.Lock()
	defer tm.refreshRateMu.Unlock()

	now := time.Now()
	cutoff := now.Add(-time.Minute)

	// Periodic cleanup: remove stale entries to prevent memory leak
	// Run cleanup every 5 minutes
	if now.Sub(tm.lastCleanup) > 5*time.Minute {
		for uid, attempts := range tm.refreshAttempts {
			hasRecent := false
			for _, t := range attempts {
				if t.After(cutoff) {
					hasRecent = true
					break
				}
			}
			if !hasRecent {
				delete(tm.refreshAttempts, uid)
			}
		}
		tm.lastCleanup = now
	}

	// Filter old attempts for this user
	attempts := tm.refreshAttempts[userID]
	var recentAttempts []time.Time
	for _, t := range attempts {
		if t.After(cutoff) {
			recentAttempts = append(recentAttempts, t)
		}
	}

	// Check rate limit
	if len(recentAttempts) >= tm.maxRefreshPerMin {
		tm.refreshAttempts[userID] = recentAttempts
		return errors.New("token refresh rate limit exceeded")
	}

	// Record this attempt
	recentAttempts = append(recentAttempts, now)
	tm.refreshAttempts[userID] = recentAttempts
	return nil
}

// GenerateTokenWithAllClaims generates a JWT with all claim fields preserved
// Use this for token refresh to preserve DeviceID and TierID
func (tm *TokenManager) GenerateTokenWithAllClaims(userID, nodeID, deviceID, role, tierID string, duration time.Duration) (string, error) {
	if tm.privateKey == nil {
		return "", errors.New("private key required for token generation")
	}

	now := time.Now()
	claims := Claims{
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    tm.issuer,
			Subject:   userID,
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(duration)),
			NotBefore: jwt.NewNumericDate(now),
		},
		UserID:   userID,
		NodeID:   nodeID,
		DeviceID: deviceID,
		Role:     role,
		TierID:   tierID,
	}

	token := jwt.NewWithClaims(jwt.SigningMethodEdDSA, claims)
	return token.SignedString(tm.privateKey)
}

// NewContext creates a new context with claims attached
func NewContext(ctx context.Context, claims *Claims) context.Context {
	return context.WithValue(ctx, claimsKey, claims)
}

// GetClaims retrieves claims from context
func GetClaims(ctx context.Context) (*Claims, bool) {
	claims, ok := ctx.Value(claimsKey).(*Claims)
	return claims, ok
}

// GetUserID retrieves user ID from context claims
func GetUserID(ctx context.Context) (string, bool) {
	claims, ok := GetClaims(ctx)
	if !ok {
		return "", false
	}
	return claims.UserID, true
}

// GetNodeID retrieves node ID from context claims
func GetNodeID(ctx context.Context) (string, bool) {
	claims, ok := GetClaims(ctx)
	if !ok {
		return "", false
	}
	return claims.NodeID, true
}

// GetRole retrieves role from context claims
func GetRole(ctx context.Context) (string, bool) {
	claims, ok := GetClaims(ctx)
	if !ok {
		return "", false
	}
	return claims.Role, true
}
