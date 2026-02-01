// Package routing provides blind routing utilities for zero-trust Hub operation.
package routing

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"fmt"
)

// GenerateRoutingToken creates a blind routing token for a node.
// The token is an HMAC of the node ID using the user's secret key.
// Hub cannot correlate this token to a user identity.
func GenerateRoutingToken(nodeID string, userSecret []byte) string {
	h := hmac.New(sha256.New, userSecret)
	h.Write([]byte(nodeID))
	return base64.URLEncoding.EncodeToString(h.Sum(nil))
}

// GenerateFCMTopic creates a blind FCM topic for push notifications.
// Hub can send to this topic but doesn't know who subscribes.
func GenerateFCMTopic(userSecret []byte) string {
	h := sha256.Sum256(append(userSecret, []byte("fcm-topic")...))
	return "nitella-" + base64.URLEncoding.EncodeToString(h[:16])
}

// GenerateUserSecret creates a random 32-byte secret for a user.
// This secret is stored on the CLI/Mobile and never sent to Hub.
func GenerateUserSecret() ([]byte, error) {
	secret := make([]byte, 32)
	if _, err := rand.Read(secret); err != nil {
		return nil, fmt.Errorf("failed to generate user secret: %w", err)
	}
	return secret, nil
}

// VerifyRoutingToken checks if a routing token matches the expected value.
// Used by CLI to verify node responses.
func VerifyRoutingToken(nodeID string, userSecret []byte, token string) bool {
	expected := GenerateRoutingToken(nodeID, userSecret)
	return hmac.Equal([]byte(expected), []byte(token))
}
