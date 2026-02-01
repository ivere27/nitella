package crypto

import (
	"encoding/binary"
	"fmt"
)

// KDFParams contains Argon2id parameters
type KDFParams struct {
	Time    uint32 // Number of iterations
	Memory  uint32 // Memory in KB
	Threads uint8  // Parallelism
}

// Predefined KDF profiles
var (
	// KDFDefault is suitable for CLI tools and desktop apps (OWASP recommended)
	// ~100ms on modern hardware, 64MB RAM
	KDFDefault = KDFParams{Time: 2, Memory: 64 * 1024, Threads: 4}

	// KDFServer is for high-throughput servers with many concurrent decryptions
	// ~25ms on modern hardware, 32MB RAM
	KDFServer = KDFParams{Time: 1, Memory: 32 * 1024, Threads: 2}

	// KDFSecure is for high-security applications (password managers, crypto wallets)
	// ~300ms on modern hardware, 128MB RAM
	KDFSecure = KDFParams{Time: 3, Memory: 128 * 1024, Threads: 4}
)

// KDFProfiles maps profile names to parameters
var KDFProfiles = map[string]KDFParams{
	"default": KDFDefault,
	"server":  KDFServer,
	"secure":  KDFSecure,
}

// GetKDFProfile returns KDF parameters for a named profile
func GetKDFProfile(name string) (KDFParams, error) {
	if params, ok := KDFProfiles[name]; ok {
		return params, nil
	}
	return KDFParams{}, fmt.Errorf("unknown KDF profile: %s (available: default, server, secure)", name)
}

// Encode serializes KDF params to bytes (for storage in encrypted file header)
// Format: [time:4][memory:4][threads:1] = 9 bytes
func (p KDFParams) Encode() []byte {
	buf := make([]byte, 9)
	binary.BigEndian.PutUint32(buf[0:4], p.Time)
	binary.BigEndian.PutUint32(buf[4:8], p.Memory)
	buf[8] = p.Threads
	return buf
}

// DecodeKDFParams deserializes KDF params from bytes
func DecodeKDFParams(data []byte) (KDFParams, error) {
	if len(data) < 9 {
		return KDFParams{}, fmt.Errorf("KDF params data too short: %d bytes", len(data))
	}
	return KDFParams{
		Time:    binary.BigEndian.Uint32(data[0:4]),
		Memory:  binary.BigEndian.Uint32(data[4:8]),
		Threads: data[8],
	}, nil
}

// String returns a human-readable description
func (p KDFParams) String() string {
	memMB := float64(p.Memory) / 1024
	return fmt.Sprintf("Argon2id(t=%d, m=%.0fMB, p=%d)", p.Time, memMB, p.Threads)
}

// ProfileName returns the name of the matching predefined profile, or "custom"
func (p KDFParams) ProfileName() string {
	for name, profile := range KDFProfiles {
		if p.Time == profile.Time && p.Memory == profile.Memory && p.Threads == profile.Threads {
			return name
		}
	}
	return "custom"
}

// SecurityComparison returns a description of security level
func (p KDFParams) SecurityComparison() string {
	// Calculate relative difficulty compared to default
	defaultWork := float64(KDFDefault.Time) * float64(KDFDefault.Memory)
	thisWork := float64(p.Time) * float64(p.Memory)
	ratio := thisWork / defaultWork

	switch {
	case ratio < 0.5:
		return "lower security (faster, less memory)"
	case ratio < 0.9:
		return "slightly lower security"
	case ratio < 1.1:
		return "standard security (OWASP recommended)"
	case ratio < 2.0:
		return "higher security"
	default:
		return "maximum security (slower, more memory)"
	}
}
