package crypto

import (
	"crypto/ed25519"
	"crypto/sha256"
	"crypto/x509"
	"fmt"
	"strings"
)

// Emojis for Visual Fingerprint (64 items to map 6 bits)
var emojis = []string{
	"🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼",
	"🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔",
	"🐧", "🐦", "🐤", "🦆", "🦅", "🦉", "🦇", "🐺",
	"🐗", "🐴", "🦄", "🐝", "🐛", "🦋", "🐌", "🐞",
	"🐜", "🦟", "🦗", "🕷", "🦂", "🐢", "🐍", "🦎",
	"🦖", "🦕", "🐙", "🦑", "🦐", "🦞", "🦀", "🐡",
	"🐠", "🐟", "🐬", "🐳", "🐋", "🦈", "🐊", "🐅",
	"🐆", "🦓", "🦍", "🦧", "🐘", "🦛", "🦏", "🐪",
}

// ComputeVisualFingerprint returns a visual representation of the data's SHA-256 hash.
// It returns a standard Hex fingerprint and a Visual Emoji String.
func ComputeVisualFingerprint(data []byte) (string, string) {
	hash := sha256.Sum256(data)
	hex := fmt.Sprintf("%x", hash)

	// Use first 4 bytes for 4 emojis
	var visualParts []string
	for i := 0; i < 4; i++ {
		idx := int(hash[i]) % len(emojis)
		visualParts = append(visualParts, emojis[idx])
	}

	visual := strings.Join(visualParts, " - ")
	return hex, visual
}

// GetSPKIFingerprint computes the SHA-256 hash of the SubjectPublicKeyInfo
func GetSPKIFingerprint(pubKey ed25519.PublicKey) ([]byte, error) {
	// Marshal to PKIX (SPKI)
	spkiBytes, err := x509.MarshalPKIXPublicKey(pubKey)
	if err != nil {
		return nil, err
	}
	hash := sha256.Sum256(spkiBytes)
	return hash[:], nil
}

// HashToEmojis converts a hash to a slice of 4 emojis
func HashToEmojis(hash []byte) []string {
	var visualParts []string
	// Use first 4 bytes
	if len(hash) < 4 {
		return []string{"❓", "❓", "❓", "❓"}
	}
	for i := 0; i < 4; i++ {
		idx := int(hash[i]) % len(emojis)
		visualParts = append(visualParts, emojis[idx])
	}
	return visualParts
}

// ComputeSHA256 computes SHA-256 hash of data
func ComputeSHA256(data []byte) []byte {
	hash := sha256.Sum256(data)
	return hash[:]
}

// ComputeHexFingerprint returns the hex string of SHA-256 hash
func ComputeHexFingerprint(data []byte) string {
	hash := sha256.Sum256(data)
	return fmt.Sprintf("%x", hash)
}
