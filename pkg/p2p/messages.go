package p2p

import (
	"crypto/ed25519"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"sync"
	"time"

	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
)

// P2P Message Types
const (
	MessageTypeApprovalRequest  = "approval_request"
	MessageTypeApprovalDecision = "approval_decision"
	MessageTypeMetrics          = "metrics"
	MessageTypeCommand          = "command"
	MessageTypeCommandResponse  = "command_response"
	MessageTypeEncrypted        = "encrypted" // Encrypted wrapper
)

// AuthMessage types for P2P authentication
type AuthMessageType string

const (
	AuthChallenge AuthMessageType = "auth_challenge"
	AuthResponse  AuthMessageType = "auth_response"
	AuthSuccess   AuthMessageType = "auth_success"
	AuthFailed    AuthMessageType = "auth_failed"
)

// AuthMessage is used for P2P peer authentication
type AuthMessage struct {
	Type      AuthMessageType `json:"type"`
	Challenge []byte          `json:"challenge,omitempty"`  // Random nonce
	UserID    string          `json:"user_id,omitempty"`    // Claimed user ID
	PublicKey []byte          `json:"public_key,omitempty"` // Ed25519 public key
	CertPEM   string          `json:"cert_pem,omitempty"`   // PEM-encoded certificate (signed by CA)
	Signature []byte          `json:"signature,omitempty"`  // Signature of challenge
}

// IsAuthMessage checks if data is an auth message
func IsAuthMessage(data []byte) bool {
	var msg AuthMessage
	if err := json.Unmarshal(data, &msg); err != nil {
		return false
	}
	return msg.Type == AuthChallenge || msg.Type == AuthResponse || msg.Type == AuthSuccess || msg.Type == AuthFailed
}

// ParseAuthMessage parses an auth message
func ParseAuthMessage(data []byte) (*AuthMessage, error) {
	var msg AuthMessage
	if err := json.Unmarshal(data, &msg); err != nil {
		return nil, err
	}
	return &msg, nil
}

// P2PMessage is the wrapper for all P2P messages
type P2PMessage struct {
	Type      string          `json:"type"`
	Timestamp int64           `json:"timestamp"`
	Nonce     string          `json:"nonce"` // Random unique ID for replay protection
	Payload   json.RawMessage `json:"payload"`
}

// ApprovalRequest is sent from Node to CLI via P2P when connection needs approval
type ApprovalRequest struct {
	RequestID  string `json:"request_id"`
	NodeID     string `json:"node_id"`
	ProxyID    string `json:"proxy_id"`
	SourceIP   string `json:"source_ip"`
	DestAddr   string `json:"dest_addr"`
	RuleID     string `json:"rule_id"`
	GeoCountry string `json:"geo_country,omitempty"`
	GeoCity    string `json:"geo_city,omitempty"`
	GeoISP     string `json:"geo_isp,omitempty"`
	Severity   string `json:"severity"`
}

// ApprovalDecision is sent from CLI to Node via P2P
type ApprovalDecision struct {
	RequestID       string `json:"request_id"`
	Action          int32  `json:"action"`           // 1=allow, 2=block, 3=block+add_rule
	DurationSeconds int64  `json:"duration_seconds"` // How long to cache
	Reason          string `json:"reason,omitempty"`
}

// generateNonce creates a random 16-byte hex-encoded nonce
func generateNonce() (string, error) {
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return hex.EncodeToString(b), nil
}

// NewP2PMessage creates a new P2P message wrapper with replay protection
func NewP2PMessage(msgType string, payload interface{}) (*P2PMessage, error) {
	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		return nil, err
	}
	nonce, err := generateNonce()
	if err != nil {
		return nil, fmt.Errorf("failed to generate nonce: %w", err)
	}
	return &P2PMessage{
		Type:      msgType,
		Timestamp: time.Now().Unix(),
		Nonce:     nonce,
		Payload:   payloadBytes,
	}, nil
}

// Marshal serializes a P2P message
func (m *P2PMessage) Marshal() ([]byte, error) {
	return json.Marshal(m)
}

// ParseP2PMessage deserializes a P2P message
func ParseP2PMessage(data []byte) (*P2PMessage, error) {
	var msg P2PMessage
	if err := json.Unmarshal(data, &msg); err != nil {
		return nil, err
	}
	return &msg, nil
}

// ParseApprovalRequest extracts ApprovalRequest from P2PMessage payload
func (m *P2PMessage) ParseApprovalRequest() (*ApprovalRequest, error) {
	var req ApprovalRequest
	if err := json.Unmarshal(m.Payload, &req); err != nil {
		return nil, err
	}
	return &req, nil
}

// ParseApprovalDecision extracts ApprovalDecision from P2PMessage payload
func (m *P2PMessage) ParseApprovalDecision() (*ApprovalDecision, error) {
	var dec ApprovalDecision
	if err := json.Unmarshal(m.Payload, &dec); err != nil {
		return nil, err
	}
	return &dec, nil
}

// EncryptedP2PPayload wraps an encrypted P2P message
type EncryptedP2PPayload struct {
	EphemeralPubKey []byte `json:"ephemeral_pubkey"`
	Nonce           []byte `json:"nonce"`
	Ciphertext      []byte `json:"ciphertext"`
	InnerType       string `json:"inner_type"` // Type of encrypted message
}

// EncryptP2PMessage encrypts a P2P message with recipient's public key
func EncryptP2PMessage(msg *P2PMessage, recipientPubKey ed25519.PublicKey) ([]byte, error) {
	// Marshal the inner message
	innerData, err := msg.Marshal()
	if err != nil {
		return nil, err
	}

	// Encrypt with recipient's public key
	encrypted, err := nitellacrypto.Encrypt(innerData, recipientPubKey)
	if err != nil {
		return nil, err
	}

	// Create encrypted wrapper
	encPayload := &EncryptedP2PPayload{
		EphemeralPubKey: encrypted.EphemeralPubKey,
		Nonce:           encrypted.Nonce,
		Ciphertext:      encrypted.Ciphertext,
		InnerType:       msg.Type,
	}

	// Wrap in P2PMessage with type "encrypted"
	wrapper := &P2PMessage{
		Type:      MessageTypeEncrypted,
		Timestamp: time.Now().Unix(),
	}
	wrapper.Payload, _ = json.Marshal(encPayload)

	return wrapper.Marshal()
}

// DecryptP2PMessage decrypts an encrypted P2P message
func DecryptP2PMessage(data []byte, recipientPrivKey ed25519.PrivateKey) (*P2PMessage, error) {
	// Parse the wrapper
	wrapper, err := ParseP2PMessage(data)
	if err != nil {
		return nil, err
	}

	// If not encrypted, return as-is
	if wrapper.Type != MessageTypeEncrypted {
		return wrapper, nil
	}

	// Parse encrypted payload
	var encPayload EncryptedP2PPayload
	if err := json.Unmarshal(wrapper.Payload, &encPayload); err != nil {
		return nil, err
	}

	// Decrypt
	cryptoPayload := &nitellacrypto.EncryptedPayload{
		EphemeralPubKey: encPayload.EphemeralPubKey,
		Nonce:           encPayload.Nonce,
		Ciphertext:      encPayload.Ciphertext,
	}

	plaintext, err := nitellacrypto.Decrypt(cryptoPayload, recipientPrivKey)
	if err != nil {
		return nil, err
	}

	// Parse decrypted message
	return ParseP2PMessage(plaintext)
}

// NonceTracker tracks seen nonces to prevent replay attacks
type NonceTracker struct {
	seen   map[string]time.Time
	mu     sync.RWMutex
	maxAge time.Duration // How long to remember nonces
	stopCh chan struct{}
}

const MaxNonceItems = 10000 // Limit memory usage

// NewNonceTracker creates a new nonce tracker
// maxAge determines how long nonces are remembered (should match message validity window)
func NewNonceTracker(maxAge time.Duration) *NonceTracker {
	nt := &NonceTracker{
		seen:   make(map[string]time.Time),
		maxAge: maxAge,
		stopCh: make(chan struct{}),
	}
	go nt.cleanupLoop()
	return nt
}

// Stop stops the cleanup goroutine. Must be called when NonceTracker is no longer needed.
func (nt *NonceTracker) Stop() {
	close(nt.stopCh)
}

// Check returns true if nonce is new (not seen before), false if replay detected
// Also validates timestamp is within acceptable window
func (nt *NonceTracker) Check(nonce string, timestamp int64) bool {
	if nonce == "" {
		return false // Empty nonce is invalid
	}

	// Check timestamp is within acceptable window
	msgTime := time.Unix(timestamp, 0)
	now := time.Now()
	if now.Sub(msgTime) > nt.maxAge || msgTime.After(now.Add(time.Minute)) {
		return false // Message too old or from the future
	}

	nt.mu.Lock()
	defer nt.mu.Unlock()

	// DoS protection: if map gets too big, reject to protect memory
	// (or we could aggressively cleanup, but rejection is safer for stability)
	if len(nt.seen) >= MaxNonceItems {
		// Try to cleanup inline if full
		cutoff := time.Now().Add(-nt.maxAge)
		for n, seenAt := range nt.seen {
			if seenAt.Before(cutoff) {
				delete(nt.seen, n)
			}
		}
		// If still full, reject
		if len(nt.seen) >= MaxNonceItems {
			return false
		}
	}

	if _, exists := nt.seen[nonce]; exists {
		return false // Replay detected
	}

	nt.seen[nonce] = now
	return true
}

// cleanupLoop periodically removes old nonces
func (nt *NonceTracker) cleanupLoop() {
	ticker := time.NewTicker(time.Minute)
	defer ticker.Stop()
	for {
		select {
		case <-nt.stopCh:
			return
		case <-ticker.C:
			nt.mu.Lock()
			cutoff := time.Now().Add(-nt.maxAge)
			for nonce, seenAt := range nt.seen {
				if seenAt.Before(cutoff) {
					delete(nt.seen, nonce)
				}
			}
			nt.mu.Unlock()
		}
	}
}
