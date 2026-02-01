// Package pairing provides PAKE (Password-Authenticated Key Exchange) for secure device pairing.
// This implementation uses CPace (RFC 9497) which provides security against offline dictionary attacks.
package pairing


const (
	RoleCLI  = "cli"
	RoleNode = "node"
)

// PakeSession wraps CPaceSession for convenience.
// Internally uses CPace (RFC 9497) for security against offline attacks.
type PakeSession struct {
	cpace *CPaceSession
}

// NewPakeSession creates a new PAKE session using CPace internally.
func NewPakeSession(role string, password []byte) (*PakeSession, error) {
	cpace, err := NewCPaceSession(role, password)
	if err != nil {
		return nil, err
	}
	return &PakeSession{cpace: cpace}, nil
}

// GetInitMessage returns the initial PAKE message (CPace public value).
func (p *PakeSession) GetInitMessage() ([]byte, error) {
	return p.cpace.GetPublicValue(), nil
}

// ProcessInitMessage processes peer's message and returns our response.
// After this call, the shared key is derived.
func (p *PakeSession) ProcessInitMessage(peerMsg []byte) ([]byte, error) {
	if err := p.cpace.SetPeerPublic(peerMsg); err != nil {
		return nil, err
	}
	// Return our public value as the reply
	return p.cpace.GetPublicValue(), nil
}

// ProcessReplyMessage processes the peer's reply (for the initiator).
// After this call, the shared key is derived.
func (p *PakeSession) ProcessReplyMessage(peerMsg []byte) error {
	return p.cpace.SetPeerPublic(peerMsg)
}

// GetSharedKey returns the derived shared key.
func (p *PakeSession) GetSharedKey() []byte {
	return p.cpace.GetSharedKey()
}

// IsComplete returns true if key exchange is complete.
func (p *PakeSession) IsComplete() bool {
	return p.cpace.IsComplete()
}

// Encrypt encrypts data with the shared key.
func (p *PakeSession) Encrypt(plaintext []byte) (ciphertext, nonce []byte, err error) {
	return p.cpace.Encrypt(plaintext)
}

// Decrypt decrypts data with the shared key.
func (p *PakeSession) Decrypt(ciphertext, nonce []byte) ([]byte, error) {
	return p.cpace.Decrypt(ciphertext, nonce)
}

// DeriveConfirmationEmoji returns emoji fingerprint for visual verification.
func (p *PakeSession) DeriveConfirmationEmoji() string {
	return p.cpace.DeriveConfirmationEmoji()
}

// CodeToBytes and GeneratePairingCode are defined in wordlist.go
