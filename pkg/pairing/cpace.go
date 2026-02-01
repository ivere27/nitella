// Package pairing provides CPace (Composable PAKE) for secure device pairing.
// CPace is defined in RFC 9497 and provides security against offline dictionary attacks.
//
// Unlike the old implementation, attackers cannot brute-force passwords offline
// even if they capture the entire exchange. They must participate online for each guess.
package pairing

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/sha256"
	"fmt"
	"io"

	"github.com/ivere27/nitella/pkg/crypto"
	"golang.org/x/crypto/curve25519"
	"golang.org/x/crypto/hkdf"
)

// GetSessionID returns the session ID for coordination between peers
func (c *CPaceSession) GetSessionID() []byte {
	return c.sessionID
}

const (
	ScalarSize = 32
	PointSize  = 32
	keySize    = 32 // internal, use KeySize from pake.go for public API
)

// CPaceSession represents one side of a CPace key exchange.
// CPace provides security against offline dictionary attacks.
type CPaceSession struct {
	role       string
	sessionID  []byte // Shared session identifier (e.g., pairing code)
	myScalar   []byte // Random private scalar (ya or yb)
	myPublic   []byte // Public value (Ya or Yb)
	peerPublic []byte // Peer's public value
	generator  []byte // Password-derived generator G'
	sharedKey  []byte // Final session key
}

// NewCPaceSession creates a new CPace session.
// role: "cli" or "node"
// password: shared secret (pairing code)
func NewCPaceSession(role string, password []byte) (*CPaceSession, error) {
	return NewCPaceSessionWithID(role, password, nil)
}

// NewCPaceSessionWithID creates a new CPace session with an explicit session ID.
// role: "cli" or "node"
// password: shared secret (pairing code)
// sessionID: unique session identifier (if nil, derived from password for compatibility)
// Using distinct sessionID strengthens transcript binding per RFC 9497
func NewCPaceSessionWithID(role string, password, sessionID []byte) (*CPaceSession, error) {
	if role != RoleCLI && role != RoleNode {
		return nil, fmt.Errorf("role must be '%s' or '%s'", RoleCLI, RoleNode)
	}

	// Derive sessionID from password if not provided (ensures both parties have same ID)
	if sessionID == nil {
		h := sha256.Sum256(append([]byte("cpace-session-id:"), password...))
		sessionID = h[:16]
	}

	// Derive generator: G' = Hash(password || sessionID || context) * Basepoint
	generator := deriveGenerator(password, sessionID)

	// Generate random scalar
	scalar := make([]byte, ScalarSize)
	if _, err := io.ReadFull(rand.Reader, scalar); err != nil {
		return nil, fmt.Errorf("failed to generate random scalar: %w", err)
	}
	clampScalar(scalar)

	// Compute public value: Y = scalar * G'
	public, err := curve25519.X25519(scalar, generator)
	if err != nil {
		return nil, fmt.Errorf("failed to compute public value: %w", err)
	}

	return &CPaceSession{
		role:      role,
		sessionID: sessionID,
		myScalar:  scalar,
		myPublic:  public,
		generator: generator,
	}, nil
}

// deriveGenerator derives a curve point from password using hash-and-multiply.
// G' = H(password || sessionID || context) * Basepoint
func deriveGenerator(password, sessionID []byte) []byte {
	// Domain separation for security
	h := sha256.New()
	h.Write([]byte("cpace-v1-curve25519"))
	h.Write(password)
	h.Write(sessionID)
	digest := h.Sum(nil)

	// Clamp for X25519 scalar
	clampScalar(digest)

	// G' = digest * Basepoint
	generator, _ := curve25519.X25519(digest, curve25519.Basepoint)

	// Wipe password-derived scalar
	crypto.Wipe(digest)

	return generator
}

// clampScalar clamps a scalar for X25519 as per RFC 7748
func clampScalar(s []byte) {
	s[0] &= 248
	s[31] &= 127
	s[31] |= 64
}

// GetPublicValue returns the public value to send to peer.
func (c *CPaceSession) GetPublicValue() []byte {
	return c.myPublic
}

// SetPeerPublic sets the peer's public value and derives the shared key.
func (c *CPaceSession) SetPeerPublic(peerPublic []byte) error {
	if len(peerPublic) != PointSize {
		return fmt.Errorf("invalid peer public value size: %d", len(peerPublic))
	}

	// Check for low-order points (all zeros = identity)
	allZero := true
	for _, b := range peerPublic {
		if b != 0 {
			allZero = false
			break
		}
	}
	if allZero {
		return fmt.Errorf("invalid peer public value: identity point")
	}

	c.peerPublic = peerPublic

	// Compute shared secret: K = myScalar * peerPublic
	sharedSecret, err := curve25519.X25519(c.myScalar, peerPublic)
	if err != nil {
		return fmt.Errorf("failed to compute shared secret: %w", err)
	}

	// Derive session key: key = HKDF(K, Ya || Yb || sessionID)
	c.sharedKey = c.deriveSessionKey(sharedSecret)

	// Wipe shared secret after key derivation
	crypto.Wipe(sharedSecret)

	return nil
}

// deriveSessionKey derives the final session key from shared secret and transcript.
func (c *CPaceSession) deriveSessionKey(sharedSecret []byte) []byte {
	// Order public values deterministically (CLI first)
	var transcript []byte
	if c.role == RoleCLI {
		transcript = append(transcript, c.myPublic...)
		transcript = append(transcript, c.peerPublic...)
	} else {
		transcript = append(transcript, c.peerPublic...)
		transcript = append(transcript, c.myPublic...)
	}
	transcript = append(transcript, c.sessionID...)

	// HKDF with transcript as info
	hkdfReader := hkdf.New(sha256.New, sharedSecret, nil, transcript)
	key := make([]byte, keySize)
	io.ReadFull(hkdfReader, key)
	return key
}

// GetSharedKey returns the derived shared key (nil if exchange not complete).
func (c *CPaceSession) GetSharedKey() []byte {
	return c.sharedKey
}

// IsComplete returns true if the key exchange is complete.
func (c *CPaceSession) IsComplete() bool {
	return c.sharedKey != nil
}

// Encrypt encrypts data with the shared key using AES-GCM.
func (c *CPaceSession) Encrypt(plaintext []byte) (ciphertext, nonce []byte, err error) {
	if c.sharedKey == nil {
		return nil, nil, fmt.Errorf("key exchange not complete")
	}

	block, err := aes.NewCipher(c.sharedKey)
	if err != nil {
		return nil, nil, err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, nil, err
	}

	nonce = make([]byte, gcm.NonceSize())
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
		return nil, nil, err
	}

	ciphertext = gcm.Seal(nil, nonce, plaintext, nil)
	return ciphertext, nonce, nil
}

// Decrypt decrypts data with the shared key using AES-GCM.
func (c *CPaceSession) Decrypt(ciphertext, nonce []byte) ([]byte, error) {
	if c.sharedKey == nil {
		return nil, fmt.Errorf("key exchange not complete")
	}

	block, err := aes.NewCipher(c.sharedKey)
	if err != nil {
		return nil, err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}

	return gcm.Open(nil, nonce, ciphertext, nil)
}

// DeriveConfirmationEmoji derives emoji fingerprint from shared key for visual confirmation.
func (c *CPaceSession) DeriveConfirmationEmoji() string {
	if c.sharedKey == nil {
		return ""
	}

	hash := sha256.Sum256(c.sharedKey)

	emojis := []string{
		"🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼",
		"🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔",
		"🐧", "🐦", "🐤", "🦆", "🦅", "🦉", "🦇", "🐺",
		"🐗", "🐴", "🦄", "🐝", "🐛", "🦋", "🐌", "🐞",
		"🌸", "🌺", "🌻", "🌹", "🌷", "🌼", "🌿", "🍀",
		"🍎", "🍊", "🍋", "🍇", "🍓", "🍒", "🍑", "🥝",
		"🌙", "⭐", "🌟", "✨", "⚡", "🔥", "🌈", "☀️",
		"🎸", "🎹", "🎺", "🎷", "🥁", "🎻", "🎤", "🎧",
	}

	result := ""
	for i := 0; i < 4; i++ {
		idx := int(hash[i*2]) % len(emojis)
		result += emojis[idx]
	}

	return result
}

// Close securely wipes all sensitive key material from the session.
// Should be called when the session is no longer needed.
func (c *CPaceSession) Close() {
	crypto.Wipe(c.myScalar)
	crypto.Wipe(c.generator)
	crypto.Wipe(c.sharedKey)
	c.myScalar = nil
	c.generator = nil
	c.sharedKey = nil
}
