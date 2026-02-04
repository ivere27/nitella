package ratelimit

import (
	"context"
	"net"
	"sync"
	"time"

	"github.com/ivere27/nitella/pkg/config"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/peer"
	"google.golang.org/grpc/status"
)

// IPRateLimiter implements IP-based rate limiting for anti-DDoS protection.
// Runs before authentication to block floods early.
type IPRateLimiter struct {
	mu            sync.RWMutex
	buckets       map[string]*ipBucket
	rateLimit     int           // requests per second
	burstSize     int           // max burst
	cleanupInterval time.Duration
	bucketExpiry  time.Duration
	stopCh        chan struct{}
}

type ipBucket struct {
	tokens     int
	lastUpdate time.Time
}

// IPRateLimiterConfig holds configuration for IP rate limiter
type IPRateLimiterConfig struct {
	RateLimit       int           // requests per second per IP
	BurstSize       int           // burst allowance
	CleanupInterval time.Duration // how often to clean stale buckets
	BucketExpiry    time.Duration // when to expire unused buckets
}

// DefaultIPRateLimiterConfig returns default configuration
func DefaultIPRateLimiterConfig() IPRateLimiterConfig {
	return IPRateLimiterConfig{
		RateLimit:       config.DefaultIPRateLimit,
		BurstSize:       config.DefaultIPBurstSize,
		CleanupInterval: config.DefaultIPRateLimitCleanupInterval,
		BucketExpiry:    config.DefaultIPBucketExpiry,
	}
}

// NewIPRateLimiter creates an IP-based rate limiter
func NewIPRateLimiter(cfg IPRateLimiterConfig) *IPRateLimiter {
	rl := &IPRateLimiter{
		buckets:         make(map[string]*ipBucket),
		rateLimit:       cfg.RateLimit,
		burstSize:       cfg.BurstSize,
		cleanupInterval: cfg.CleanupInterval,
		bucketExpiry:    cfg.BucketExpiry,
		stopCh:          make(chan struct{}),
	}
	go rl.cleanup()
	return rl
}

// Stop stops the cleanup goroutine
func (rl *IPRateLimiter) Stop() {
	close(rl.stopCh)
}

// Allow checks if a request from the given IP is allowed
func (rl *IPRateLimiter) Allow(ip string) bool {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	now := time.Now()
	b, exists := rl.buckets[ip]
	if !exists {
		rl.buckets[ip] = &ipBucket{
			tokens:     rl.burstSize - 1,
			lastUpdate: now,
		}
		return true
	}

	// Refill tokens based on elapsed time
	elapsed := now.Sub(b.lastUpdate)
	refill := int(elapsed.Seconds()) * rl.rateLimit
	b.tokens = min(b.tokens+refill, rl.burstSize)
	b.lastUpdate = now

	if b.tokens > 0 {
		b.tokens--
		return true
	}
	return false
}

// cleanup removes stale buckets periodically
func (rl *IPRateLimiter) cleanup() {
	ticker := time.NewTicker(rl.cleanupInterval)
	defer ticker.Stop()

	for {
		select {
		case <-rl.stopCh:
			return
		case <-ticker.C:
			rl.cleanupStale()
		}
	}
}

func (rl *IPRateLimiter) cleanupStale() {
	staleThreshold := time.Now().Add(-rl.bucketExpiry)

	// Collect stale keys under read lock
	rl.mu.RLock()
	var staleKeys []string
	for ip, b := range rl.buckets {
		if b.lastUpdate.Before(staleThreshold) {
			staleKeys = append(staleKeys, ip)
		}
	}
	rl.mu.RUnlock()

	// Delete in batches
	if len(staleKeys) > 0 {
		const batchSize = 100
		for i := 0; i < len(staleKeys); i += batchSize {
			end := i + batchSize
			if end > len(staleKeys) {
				end = len(staleKeys)
			}
			batch := staleKeys[i:end]

			rl.mu.Lock()
			for _, ip := range batch {
				if b, exists := rl.buckets[ip]; exists && b.lastUpdate.Before(staleThreshold) {
					delete(rl.buckets, ip)
				}
			}
			rl.mu.Unlock()
		}
	}
}

// extractIP extracts client IP from gRPC context
func extractIP(ctx context.Context) string {
	p, ok := peer.FromContext(ctx)
	if !ok {
		return ""
	}

	// peer.Addr is typically "ip:port"
	host, _, err := net.SplitHostPort(p.Addr.String())
	if err != nil {
		// Might be just IP without port
		return p.Addr.String()
	}
	return host
}

// UnaryInterceptor creates a gRPC unary interceptor for IP-based rate limiting
func (rl *IPRateLimiter) UnaryInterceptor() grpc.UnaryServerInterceptor {
	return func(
		ctx context.Context,
		req interface{},
		info *grpc.UnaryServerInfo,
		handler grpc.UnaryHandler,
	) (interface{}, error) {
		ip := extractIP(ctx)
		if ip != "" && !rl.Allow(ip) {
			return nil, status.Errorf(codes.ResourceExhausted,
				"rate limit exceeded: too many requests from %s", ip)
		}
		return handler(ctx, req)
	}
}

// StreamInterceptor creates a gRPC stream interceptor for IP-based rate limiting
func (rl *IPRateLimiter) StreamInterceptor() grpc.StreamServerInterceptor {
	return func(
		srv interface{},
		ss grpc.ServerStream,
		info *grpc.StreamServerInfo,
		handler grpc.StreamHandler,
	) error {
		ip := extractIP(ss.Context())
		if ip != "" && !rl.Allow(ip) {
			return status.Errorf(codes.ResourceExhausted,
				"rate limit exceeded: too many requests from %s", ip)
		}
		return handler(srv, ss)
	}
}
