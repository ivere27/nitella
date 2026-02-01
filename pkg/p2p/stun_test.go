package p2p

import (
	"testing"
)

func TestDefaultSTUNServer(t *testing.T) {
	if DefaultSTUNServer == "" {
		t.Fatal("DefaultSTUNServer should not be empty")
	}
	if DefaultSTUNServer != "stun:stun.l.google.com:19302" {
		t.Errorf("Unexpected default STUN server: %s", DefaultSTUNServer)
	}
}

func TestTransport_SetSTUNServer(t *testing.T) {
	transport := NewTransport("test-user", nil)

	// Default should be set
	if transport.stunURL != DefaultSTUNServer {
		t.Errorf("Expected default STUN %s, got %s", DefaultSTUNServer, transport.stunURL)
	}

	// Test setting custom STUN
	customSTUN := "stun:stun.twilio.com:3478"
	transport.SetSTUNServer(customSTUN)
	if transport.stunURL != customSTUN {
		t.Errorf("Expected %s, got %s", customSTUN, transport.stunURL)
	}

	// Empty string should not change
	transport.SetSTUNServer("")
	if transport.stunURL != customSTUN {
		t.Errorf("Empty string should not change STUN URL, got %s", transport.stunURL)
	}
}

func TestManager_SetSTUNServer(t *testing.T) {
	outCh := make(chan interface{}, 1) // Use interface{} to avoid import
	_ = outCh

	// Create manager with nil channel for testing
	manager := &Manager{
		stunURL: DefaultSTUNServer,
	}

	// Default should be set
	if manager.stunURL != DefaultSTUNServer {
		t.Errorf("Expected default STUN %s, got %s", DefaultSTUNServer, manager.stunURL)
	}

	// Test setting custom STUN
	customSTUN := "stun:stun.twilio.com:3478"
	manager.SetSTUNServer(customSTUN)
	if manager.stunURL != customSTUN {
		t.Errorf("Expected %s, got %s", customSTUN, manager.stunURL)
	}

	// Empty string should not change
	manager.SetSTUNServer("")
	if manager.stunURL != customSTUN {
		t.Errorf("Empty string should not change STUN URL, got %s", manager.stunURL)
	}
}

// TestSTUNServerFormats tests various STUN URL formats
func TestSTUNServerFormats(t *testing.T) {
	tests := []struct {
		name     string
		stunURL  string
		expected string
	}{
		{
			name:     "Google STUN",
			stunURL:  "stun:stun.l.google.com:19302",
			expected: "stun:stun.l.google.com:19302",
		},
		{
			name:     "Twilio STUN",
			stunURL:  "stun:global.stun.twilio.com:3478",
			expected: "stun:global.stun.twilio.com:3478",
		},
		{
			name:     "Mozilla STUN",
			stunURL:  "stun:stun.services.mozilla.com:3478",
			expected: "stun:stun.services.mozilla.com:3478",
		},
		{
			name:     "Cloudflare STUN",
			stunURL:  "stun:stun.cloudflare.com:3478",
			expected: "stun:stun.cloudflare.com:3478",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			transport := NewTransport("test-user", nil)
			transport.SetSTUNServer(tt.stunURL)
			if transport.stunURL != tt.expected {
				t.Errorf("Expected %s, got %s", tt.expected, transport.stunURL)
			}
		})
	}
}
