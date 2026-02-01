package crypto

import (
	"fmt"
	"math"
	"strings"
)

// PassphraseStrength represents the security level of a passphrase
type PassphraseStrength int

const (
	StrengthWeak PassphraseStrength = iota
	StrengthFair
	StrengthStrong
)

func (s PassphraseStrength) String() string {
	switch s {
	case StrengthWeak:
		return "weak"
	case StrengthFair:
		return "fair"
	case StrengthStrong:
		return "strong"
	default:
		return "unknown"
	}
}

// PassphraseCheck contains the result of passphrase validation
type PassphraseCheck struct {
	Strength    PassphraseStrength
	Entropy     float64 // bits of entropy
	Message     string
	CrackTime   string // human-readable crack time estimate
	GPUScenario string // description of attack scenario
}

// Common weak passwords (top entries from breached password lists)
var commonPasswords = map[string]bool{
	"password": true, "123456": true, "12345678": true, "qwerty": true,
	"abc123": true, "monkey": true, "1234567": true, "letmein": true,
	"trustno1": true, "dragon": true, "baseball": true, "iloveyou": true,
	"master": true, "sunshine": true, "ashley": true, "bailey": true,
	"passw0rd": true, "shadow": true, "123123": true, "654321": true,
	"superman": true, "qazwsx": true, "michael": true, "football": true,
	"password1": true, "password123": true, "welcome": true, "welcome1": true,
	"admin": true, "admin123": true, "root": true, "toor": true,
	"pass": true, "test": true, "guest": true, "qwert": true,
	"changeme": true, "fuckyou": true, "hello": true, "charlie": true,
	"donald": true, "password1!": true, "qwerty123": true, "zxcvbn": true,
	"121212": true, "flower": true, "hottie": true, "loveme": true,
	"zaq1zaq1": true, "password!": true, "qwerty1": true, "qwertyuiop": true,
	"": true, // empty is also weak
}

// CheckPassphrase validates passphrase strength and returns detailed analysis
func CheckPassphrase(passphrase string) *PassphraseCheck {
	check := &PassphraseCheck{}

	// Empty passphrase
	if passphrase == "" {
		check.Strength = StrengthWeak
		check.Entropy = 0
		check.Message = "empty passphrase (no encryption)"
		check.CrackTime = "instant"
		check.GPUScenario = "no attack needed"
		return check
	}

	// Check minimum length
	if len(passphrase) < 8 {
		check.Strength = StrengthWeak
		check.Entropy = calculateEntropy(passphrase)
		check.Message = fmt.Sprintf("too short (%d chars, minimum 8)", len(passphrase))
		check.CrackTime, check.GPUScenario = estimateCrackTime(check.Entropy)
		return check
	}

	// Check against common passwords
	if commonPasswords[strings.ToLower(passphrase)] {
		check.Strength = StrengthWeak
		check.Entropy = 10 // Common passwords have ~10 bits (top 1000 list)
		check.Message = "commonly used password"
		check.CrackTime = "instant (in common password lists)"
		check.GPUScenario = "dictionary attack"
		return check
	}

	// Calculate entropy
	check.Entropy = calculateEntropy(passphrase)

	// Determine strength based on entropy
	// https://www.pleacher.com/mp/mlessons/algebra/entropy.html
	switch {
	case check.Entropy < 40:
		check.Strength = StrengthWeak
		check.Message = "low entropy"
	case check.Entropy < 60:
		check.Strength = StrengthFair
		check.Message = "acceptable"
	case check.Entropy < 80:
		check.Strength = StrengthStrong
		check.Message = "strong"
	default:
		check.Strength = StrengthStrong
		check.Message = "very strong"
	}

	check.CrackTime, check.GPUScenario = estimateCrackTime(check.Entropy)
	return check
}

// calculateEntropy estimates the bits of entropy in a passphrase
func calculateEntropy(s string) float64 {
	if len(s) == 0 {
		return 0
	}

	// Detect character set used
	var hasLower, hasUpper, hasDigit, hasSymbol, hasSpace bool
	for _, c := range s {
		switch {
		case c >= 'a' && c <= 'z':
			hasLower = true
		case c >= 'A' && c <= 'Z':
			hasUpper = true
		case c >= '0' && c <= '9':
			hasDigit = true
		case c == ' ':
			hasSpace = true
		default:
			hasSymbol = true
		}
	}

	// Calculate charset size
	charset := 0
	if hasLower {
		charset += 26
	}
	if hasUpper {
		charset += 26
	}
	if hasDigit {
		charset += 10
	}
	if hasSymbol {
		charset += 32 // Common symbols
	}
	if hasSpace {
		charset += 1
	}

	if charset == 0 {
		return 0
	}

	// Entropy = length × log2(charset)
	// This is a simplified model; real entropy depends on randomness
	entropy := float64(len(s)) * math.Log2(float64(charset))

	// Penalize repeated characters and patterns
	entropy *= detectPatternPenalty(s)

	return entropy
}

// detectPatternPenalty reduces entropy for common patterns
func detectPatternPenalty(s string) float64 {
	penalty := 1.0
	lower := strings.ToLower(s)

	// Check for keyboard patterns
	patterns := []string{
		"qwerty", "asdf", "zxcv", "1234", "4321",
		"qazwsx", "1qaz", "2wsx", "abcd", "dcba",
	}
	for _, p := range patterns {
		if strings.Contains(lower, p) {
			penalty *= 0.7
		}
	}

	// Check for repeated characters (e.g., "aaa", "111")
	repeatCount := 0
	for i := 1; i < len(s); i++ {
		if s[i] == s[i-1] {
			repeatCount++
		}
	}
	if repeatCount > len(s)/3 {
		penalty *= 0.6
	}

	return penalty
}

// estimateCrackTime estimates time to crack with massive GPU clusters
func estimateCrackTime(entropyBits float64) (crackTime, scenario string) {
	if entropyBits <= 0 {
		return "instant", "no attack needed"
	}

	// Attack scenarios (hashes per second with Argon2id 64MB/t=2)
	// Note: Argon2id is memory-hard, so GPU parallelism is limited by VRAM
	// RTX 4090 (24GB VRAM) can run ~375 parallel 64MB hashes = ~400 h/s
	scenarios := []struct {
		name       string
		gpuCount   float64
		hashPerSec float64
	}{
		{"single RTX 4090", 1, 400},
		{"gaming rig (4 GPUs)", 4, 1600},
		{"small cluster (100 GPUs)", 100, 40000},
		{"corporate cluster (1K GPUs)", 1000, 400000},
		{"nation-state (100K GPUs)", 100000, 40000000},
		{"all hyperscalers combined (1M H100s)", 1000000, 500000000},
	}

	// Total combinations = 2^entropy
	combinations := math.Pow(2, entropyBits)

	// Find the most relevant scenario
	for i := len(scenarios) - 1; i >= 0; i-- {
		s := scenarios[i]
		// Average time = combinations / (2 * hashPerSec) -- on average, find at 50%
		seconds := combinations / (2 * s.hashPerSec)
		timeStr := formatDuration(seconds)

		if i == len(scenarios)-1 || seconds > 365*24*3600 { // More than 1 year
			return timeStr, fmt.Sprintf("%s @ %.0f hashes/sec", s.name, s.hashPerSec)
		}
	}

	return "instant", scenarios[0].name
}

// formatDuration converts seconds to human-readable duration
func formatDuration(seconds float64) string {
	if seconds < 1 {
		return "instant"
	}
	if seconds < 60 {
		return fmt.Sprintf("%.0f seconds", seconds)
	}
	if seconds < 3600 {
		return fmt.Sprintf("%.0f minutes", seconds/60)
	}
	if seconds < 86400 {
		return fmt.Sprintf("%.1f hours", seconds/3600)
	}
	if seconds < 86400*365 {
		return fmt.Sprintf("%.1f days", seconds/86400)
	}
	if seconds < 86400*365*1000 {
		return fmt.Sprintf("%.0f years", seconds/(86400*365))
	}
	if seconds < 86400*365*1000000 {
		return fmt.Sprintf("%.0f thousand years", seconds/(86400*365*1000))
	}
	if seconds < 86400*365*1e9 {
		return fmt.Sprintf("%.0f million years", seconds/(86400*365*1e6))
	}
	if seconds < 86400*365*1e12 {
		return fmt.Sprintf("%.0f billion years", seconds/(86400*365*1e9))
	}

	// Universe age is ~13.8 billion years
	universeAges := seconds / (86400 * 365 * 13.8e9)
	if universeAges < 1000 {
		return fmt.Sprintf("%.0fx age of universe", universeAges)
	}
	return "heat death of universe"
}

// FormatStrengthReport returns a formatted string for CLI display
func (c *PassphraseCheck) FormatStrengthReport() string {
	if c.Entropy == 0 {
		return "  ⚠️  No passphrase - key will NOT be encrypted"
	}

	var icon string
	switch c.Strength {
	case StrengthWeak:
		icon = "⚠️  WEAK"
	case StrengthFair:
		icon = "⚡ FAIR"
	case StrengthStrong:
		icon = "✓  STRONG"
	}

	return fmt.Sprintf(`  %s: %s
     Entropy:    %.1f bits
     Crack time: %s
     Scenario:   %s`,
		icon, c.Message, c.Entropy, c.CrackTime, c.GPUScenario)
}
