package crypto

import (
	"crypto/rand"
)

// Wipe overwrites the given byte slice with random data and then zeros to clear sensitive information from memory.
// This is a best-effort approach as Go's runtime/GC might have moved the data or created copies.
func Wipe(buf []byte) {
	if buf == nil {
		return
	}
	// Overwrite with random data first
	if _, err := rand.Read(buf); err != nil {
		// Fallback if rand fails (unlikely)
	}
	// Then overwrite with zeros
	for i := range buf {
		buf[i] = 0
	}
}

// SecureCompare performs a constant-time comparison of two byte slices.
// Returns true if the slices are equal.
func SecureCompare(a, b []byte) bool {
	if len(a) != len(b) {
		return false
	}
	var result byte
	for i := 0; i < len(a); i++ {
		result |= a[i] ^ b[i]
	}
	return result == 0
}

// GenerateRandomBytes generates cryptographically secure random bytes.
func GenerateRandomBytes(n int) ([]byte, error) {
	b := make([]byte, n)
	_, err := rand.Read(b)
	if err != nil {
		return nil, err
	}
	return b, nil
}
