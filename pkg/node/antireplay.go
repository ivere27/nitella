package node

import (
	"errors"
	"sync"
	"time"
)

// AntiReplayCache tracks seen request IDs to prevent replay attacks.
// Commands older than MaxAge are rejected, and duplicate request IDs are blocked.
type AntiReplayCache struct {
	seen   map[string]time.Time
	mu     sync.RWMutex
	maxAge time.Duration

	// trustedFingerprint is the SHA256 fingerprint of the trusted CA
	trustedFingerprint string

	// Cleanup control
	quit chan struct{}
}

// NewAntiReplayCache creates a new cache with the specified max age and trusted fingerprint.
func NewAntiReplayCache(maxAge time.Duration, trustedFingerprint string) *AntiReplayCache {
	c := &AntiReplayCache{
		seen:               make(map[string]time.Time),
		maxAge:             maxAge,
		trustedFingerprint: trustedFingerprint,
		quit:               make(chan struct{}),
	}
	// Start cleanup goroutine
	go c.cleanupLoop()
	return c
}

// Stop stops the cleanup goroutine and releases resources.
func (c *AntiReplayCache) Stop() {
	close(c.quit)
}

// cleanupLoop periodically removes expired entries to prevent memory leak
func (c *AntiReplayCache) cleanupLoop() {
	ticker := time.NewTicker(1 * time.Minute)
	defer ticker.Stop()

	for {
		select {
		case <-c.quit:
			return
		case <-ticker.C:
			c.mu.Lock()
			now := time.Now()
			for id, ts := range c.seen {
				if now.Sub(ts) > c.maxAge*2 { // Keep for 2x maxAge for safety margin
					delete(c.seen, id)
				}
			}
			c.mu.Unlock()
		}
	}
}

// ValidateCommand checks if a command is valid:
// 1. Timestamp is within maxAge (default: 1 minute)
// 2. Request ID hasn't been seen before (replay protection)
// 3. Sender fingerprint matches trusted CA
func (c *AntiReplayCache) ValidateCommand(
	requestID string,
	timestamp int64,
	senderFingerprint string,
) error {
	now := time.Now()
	cmdTime := time.Unix(timestamp, 0)

	// Check 1: Command age
	age := now.Sub(cmdTime)
	if age < 0 {
		// Future timestamp - might be clock skew, allow small window
		if -age > 30*time.Second {
			return errors.New("command timestamp is in the future")
		}
	} else if age > c.maxAge {
		return errors.New("command expired: older than " + c.maxAge.String())
	}

	// Check 2: Sender fingerprint
	if c.trustedFingerprint != "" && senderFingerprint != c.trustedFingerprint {
		return errors.New("untrusted sender: fingerprint mismatch")
	}

	// Check 3: Replay protection
	c.mu.Lock()
	defer c.mu.Unlock()

	if _, exists := c.seen[requestID]; exists {
		return errors.New("replay detected: duplicate request ID")
	}

	// Mark as seen
	c.seen[requestID] = now

	return nil
}

// SetTrustedFingerprint updates the trusted fingerprint.
func (c *AntiReplayCache) SetTrustedFingerprint(fingerprint string) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.trustedFingerprint = fingerprint
}

// Stats returns the number of tracked request IDs (for monitoring)
func (c *AntiReplayCache) Stats() int {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return len(c.seen)
}
