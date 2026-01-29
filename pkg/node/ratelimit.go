package node

import (
	"sync"
	"time"

	pb "github.com/ivere27/nitella/pkg/api/proxy"
)

// RateLimiter manages rate limiting and auto-blocking state
type RateLimiter struct {
	config *pb.RateLimitConfig
	mu     sync.Mutex

	// IP -> state
	counters map[string]*ipState
	blocks   map[string]time.Time // IP -> Block expiration time

	// Cleanup control
	quit chan struct{}
}

type ipState struct {
	count       int
	firstSeen   time.Time
	lastSeen    time.Time
	failedCount int
	banLevel    int
}

func NewRateLimiter(config *pb.RateLimitConfig) *RateLimiter {
	if config == nil {
		return nil
	}
	rl := &RateLimiter{
		config:   config,
		counters: make(map[string]*ipState),
		blocks:   make(map[string]time.Time),
		quit:     make(chan struct{}),
	}
	go rl.cleanupLoop()
	return rl
}

// Stop stops the cleanup goroutine
func (rl *RateLimiter) Stop() {
	close(rl.quit)
}

// cleanupLoop periodically removes stale entries to prevent memory leak
func (rl *RateLimiter) cleanupLoop() {
	ticker := time.NewTicker(1 * time.Minute)
	defer ticker.Stop()

	for {
		select {
		case <-rl.quit:
			return
		case <-ticker.C:
			rl.cleanup()
		}
	}
}

// cleanup removes expired blocks and stale counter entries
func (rl *RateLimiter) cleanup() {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	now := time.Now()
	interval := time.Duration(rl.config.IntervalSeconds) * time.Second
	if interval == 0 {
		interval = 60 * time.Second // Default 1 minute
	}
	// Keep entries for 2x interval for safety margin
	staleThreshold := interval * 2

	// Clean expired blocks
	for ip, expiry := range rl.blocks {
		if now.After(expiry) {
			delete(rl.blocks, ip)
		}
	}

	// Clean stale counters
	for ip, state := range rl.counters {
		if now.Sub(state.lastSeen) > staleThreshold {
			delete(rl.counters, ip)
		}
	}
}

// Check returns true if the IP is allowed, false if blocked/rate-limited
func (rl *RateLimiter) Check(ip string) bool {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	// 1. Check if globally blocked by this limiter
	if expiry, blocked := rl.blocks[ip]; blocked {
		if time.Now().Before(expiry) {
			return false
		}
		// Block expired
		delete(rl.blocks, ip)

		// If we were blocked and are now unblocked, set state so next failure triggers immediate block
		// (fail2ban style "probation")
		if state, exists := rl.counters[ip]; exists && rl.config.CountOnlyFailures {
			// Set to Max - 1, so 1 more failure triggers block
			state.failedCount = int(rl.config.MaxConnections) - 1
			if state.failedCount < 0 {
				state.failedCount = 0
			}
			// Reset window to now, so we have a fresh interval for this probation
			state.firstSeen = time.Now()
		}
	}

	// 2. Check rate limit window
	state, exists := rl.counters[ip]
	now := time.Now()

	if !exists {
		rl.counters[ip] = &ipState{
			count:     0, // Will be incremented in Track
			firstSeen: now,
			lastSeen:  now,
		}
		return true
	}

	// Reset window if interval passed
	if now.Sub(state.firstSeen) > time.Duration(rl.config.IntervalSeconds)*time.Second {
		state.count = 0
		// Only reset failedCount if we haven't just come out of a block (checked above)
		// Actually, if interval passed, we should reset.
		// But if we just unblocked (above), we reset firstSeen to now, so this won't trigger immediately.
		state.failedCount = 0
		state.firstSeen = now
	}

	// If we are NOT counting failures only, check strict connection count
	if !rl.config.CountOnlyFailures {
		if state.count >= int(rl.config.MaxConnections) {
			// Trigger block if auto-block is enabled
			if rl.config.AutoBlock {
				rl.blocks[ip] = now.Add(time.Duration(rl.config.BlockDurationSeconds) * time.Second)
			}
			return false
		}
	}

	return true
}

// TrackConnection records a new connection attempt
func (rl *RateLimiter) TrackConnection(ip string) {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	state, exists := rl.counters[ip]
	if !exists {
		// Should have been created in Check, but just in case
		rl.counters[ip] = &ipState{
			count:     1,
			firstSeen: time.Now(),
		}
		return
	}
	state.count++
	state.lastSeen = time.Now()
}

// ReportResult reports the outcome of a connection (duration, success/fail)
// Used for "fail2ban" logic where we only care about failed attempts
func (rl *RateLimiter) ReportResult(ip string, duration time.Duration) {
	if !rl.config.CountOnlyFailures {
		return
	}

	rl.mu.Lock()
	defer rl.mu.Unlock()

	state, exists := rl.counters[ip]
	if !exists {
		return
	}

	// Define "Failure": Connection duration < Threshold
	threshold := time.Duration(rl.config.FailureDurationThreshold) * time.Second
	if threshold == 0 {
		threshold = 1 * time.Second // Default default
	}

	if duration < threshold {
		state.failedCount++

		// Check limit based on failures
		if state.failedCount >= int(rl.config.MaxConnections) {
			if rl.config.AutoBlock {
				var blockDuration time.Duration

				// Escalation logic
				steps := rl.config.BlockStepsSeconds
				if len(steps) > 0 {
					level := state.banLevel
					if level >= len(steps) {
						level = len(steps) - 1
					}
					blockDuration = time.Duration(steps[level]) * time.Second
					state.banLevel++
				} else {
					// Legacy/Simple mode
					seconds := rl.config.BlockDurationSeconds
					if seconds == 0 {
						seconds = 600 // Default 10 min
					}
					blockDuration = time.Duration(seconds) * time.Second
				}

				rl.blocks[ip] = time.Now().Add(blockDuration)
			}
		}
	}
}
