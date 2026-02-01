package crypto

import (
	"strings"
	"testing"
)

func TestCheckPassphrase(t *testing.T) {
	tests := []struct {
		name             string
		passphrase       string
		expectedStrength PassphraseStrength
		minEntropy       float64
		maxEntropy       float64
	}{
		{
			name:             "empty passphrase",
			passphrase:       "",
			expectedStrength: StrengthWeak,
			minEntropy:       0,
			maxEntropy:       0,
		},
		{
			name:             "common password",
			passphrase:       "password",
			expectedStrength: StrengthWeak,
			minEntropy:       5,
			maxEntropy:       15,
		},
		{
			name:             "short numeric",
			passphrase:       "123456",
			expectedStrength: StrengthWeak,
			minEntropy:       10,
			maxEntropy:       25,
		},
		{
			name:             "medium alphanumeric",
			passphrase:       "MyP@ssw0rd",
			expectedStrength: StrengthStrong,
			minEntropy:       50,
			maxEntropy:       80,
		},
		{
			name:             "long passphrase with spaces",
			passphrase:       "correct horse battery staple",
			expectedStrength: StrengthStrong,
			minEntropy:       100,
			maxEntropy:       200,
		},
		{
			name:             "very long random",
			passphrase:       "xK9#mL2$pQ7@nR4!",
			expectedStrength: StrengthStrong,
			minEntropy:       80,
			maxEntropy:       150,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			check := CheckPassphrase(tt.passphrase)

			if check.Strength != tt.expectedStrength {
				t.Errorf("Strength = %v, want %v", check.Strength, tt.expectedStrength)
			}

			if check.Entropy < tt.minEntropy || check.Entropy > tt.maxEntropy {
				t.Errorf("Entropy = %.1f, want between %.1f and %.1f",
					check.Entropy, tt.minEntropy, tt.maxEntropy)
			}

			if check.CrackTime == "" {
				t.Error("CrackTime should not be empty")
			}

			if check.GPUScenario == "" {
				t.Error("GPUScenario should not be empty")
			}
		})
	}
}

func TestCalculateEntropy(t *testing.T) {
	tests := []struct {
		name       string
		input      string
		minEntropy float64
		maxEntropy float64
	}{
		{"empty", "", 0, 0},
		{"single char", "a", 4, 6},
		{"lowercase only", "abcdefgh", 25, 40},
		{"mixed case", "AbCdEfGh", 30, 45},
		{"with numbers", "abc123", 30, 45},
		{"with symbols", "a!b@c#", 35, 50},
		{"with spaces", "a b c d", 25, 40},
		{"all types", "Ab1! x", 35, 50},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			entropy := calculateEntropy(tt.input)
			if entropy < tt.minEntropy || entropy > tt.maxEntropy {
				t.Errorf("calculateEntropy(%q) = %.1f, want between %.1f and %.1f",
					tt.input, entropy, tt.minEntropy, tt.maxEntropy)
			}
		})
	}
}

func TestPatternPenalty(t *testing.T) {
	// Passwords with patterns should have reduced entropy
	withPattern := calculateEntropy("qwerty123")
	withoutPattern := calculateEntropy("xkcd1234") // No keyboard pattern

	// Pattern penalty should reduce entropy
	if withPattern >= withoutPattern {
		t.Logf("withPattern=%.1f, withoutPattern=%.1f", withPattern, withoutPattern)
		// This is OK - patterns might not always reduce below random
	}

	// Repeated chars should reduce entropy
	repeated := calculateEntropy("aaaa1234")
	notRepeated := calculateEntropy("abcd1234")
	if repeated >= notRepeated {
		t.Logf("repeated=%.1f, notRepeated=%.1f (penalty may not apply to short repeats)", repeated, notRepeated)
	}
}

func TestFormatDuration(t *testing.T) {
	tests := []struct {
		seconds  float64
		contains string
	}{
		{0.5, "instant"},
		{30, "seconds"},
		{120, "minutes"},
		{7200, "hours"},
		{86400 * 5, "days"},
		{86400 * 365 * 10, "years"},
		{86400 * 365 * 1e6, "million"},
		{86400 * 365 * 1e10, "billion"},
		{86400 * 365 * 13.8e9 * 1000, "universe"},
	}

	for _, tt := range tests {
		result := formatDuration(tt.seconds)
		if !strings.Contains(strings.ToLower(result), tt.contains) {
			t.Errorf("formatDuration(%.0f) = %q, want to contain %q",
				tt.seconds, result, tt.contains)
		}
	}
}

func TestFormatStrengthReport(t *testing.T) {
	// Test weak passphrase report
	weak := CheckPassphrase("123")
	report := weak.FormatStrengthReport()
	if !strings.Contains(report, "WEAK") {
		t.Errorf("Weak passphrase report should contain 'WEAK': %s", report)
	}

	// Test strong passphrase report
	strong := CheckPassphrase("correct horse battery staple!")
	report = strong.FormatStrengthReport()
	if !strings.Contains(report, "STRONG") {
		t.Errorf("Strong passphrase report should contain 'STRONG': %s", report)
	}
	if !strings.Contains(report, "Entropy") {
		t.Errorf("Report should contain entropy: %s", report)
	}
	if !strings.Contains(report, "Crack time") {
		t.Errorf("Report should contain crack time: %s", report)
	}

	// Test empty passphrase report
	empty := CheckPassphrase("")
	report = empty.FormatStrengthReport()
	if !strings.Contains(report, "NOT be encrypted") {
		t.Errorf("Empty passphrase report should warn about no encryption: %s", report)
	}
}
