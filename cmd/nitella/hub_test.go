package main

import (
	"testing"
)

func TestSanitizeForTerminal(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "plain text unchanged",
			input:    "hello world",
			expected: "hello world",
		},
		{
			name:     "preserves newlines and tabs",
			input:    "line1\nline2\ttabbed",
			expected: "line1\nline2\ttabbed",
		},
		{
			name:     "removes color codes",
			input:    "\033[1;31mred text\033[0m",
			expected: "red text",
		},
		{
			name:     "removes cursor movement",
			input:    "\033[2J\033[Hcleared",
			expected: "cleared",
		},
		{
			name:     "removes OSC sequences (title change)",
			input:    "\033]0;Evil Title\007normal",
			expected: "normal",
		},
		{
			name:     "removes control characters",
			input:    "hello\x00\x01\x02world",
			expected: "helloworld",
		},
		{
			name:     "preserves UTF-8",
			input:    "日本語 한국어 emoji 🎉",
			expected: "日本語 한국어 emoji 🎉",
		},
		{
			name:     "handles mixed malicious content",
			input:    "\033[2J\033[H\033[1;32m✓ APPROVED\033[0m\x07",
			expected: "✓ APPROVED",
		},
		{
			name:     "empty string",
			input:    "",
			expected: "",
		},
		{
			name:     "only escape codes",
			input:    "\033[1;31m\033[0m",
			expected: "",
		},
		{
			name:     "IP address unchanged",
			input:    "192.168.1.1:54321",
			expected: "192.168.1.1:54321",
		},
		{
			name:     "realistic node ID",
			input:    "node-abc123-def456",
			expected: "node-abc123-def456",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := sanitizeForTerminal(tt.input)
			if result != tt.expected {
				t.Errorf("sanitizeForTerminal(%q) = %q, want %q", tt.input, result, tt.expected)
			}
		})
	}
}
