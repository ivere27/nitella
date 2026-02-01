package ratelimit

import (
	"context"
	"sync"
	"time"

	"github.com/ivere27/nitella/pkg/tier"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// TieredRateLimiter implements rate limiting based on subscription tier.
// It uses routing_token (not user_id) to maintain zero-trust.
type TieredRateLimiter struct {
	mu          sync.RWMutex
	buckets     map[string]*bucket    // routing_token -> bucket
	tierConfigs *tier.Config          // Tier configurations
	getTierFunc func(token string) string // Function to fetch tier from DB
}

type bucket struct {
	tokens     int
	lastUpdate time.Time
	tier       string
}

// NewTieredRateLimiter creates a tier-aware rate limiter.
// getTierFunc: function to lookup tier by routing_token from DB
func NewTieredRateLimiter(tierConfigs *tier.Config, getTierFunc func(token string) string) *TieredRateLimiter {
	if tierConfigs == nil {
		tierConfigs = tier.DefaultConfig()
	}
	trl := &TieredRateLimiter{
		buckets:     make(map[string]*bucket),
		tierConfigs: tierConfigs,
		getTierFunc: getTierFunc,
	}
	go trl.cleanup()
	return trl
}

// getTier fetches the tier for a routing_token
func (trl *TieredRateLimiter) getTier(routingToken string) string {
	if trl.getTierFunc == nil {
		return "free"
	}
	tierID := trl.getTierFunc(routingToken)
	if tierID == "" {
		return "free"
	}
	return tierID
}

// Allow checks if a request from the given routing_token is allowed
func (trl *TieredRateLimiter) Allow(routingToken string) bool {
	tierID := trl.getTier(routingToken)

	trl.mu.Lock()
	defer trl.mu.Unlock()

	config := trl.tierConfigs.GetTierOrDefault(tierID)
	if config == nil {
		config = trl.tierConfigs.GetTier("free")
	}

	now := time.Now()
	b, exists := trl.buckets[routingToken]
	if !exists {
		trl.buckets[routingToken] = &bucket{
			tokens:     config.RPC.BurstSize - 1,
			lastUpdate: now,
			tier:       tierID,
		}
		return true
	}

	// Tier might have changed (upgrade/downgrade)
	if b.tier != tierID {
		b.tier = tierID
		b.tokens = config.RPC.BurstSize
	}

	// Refill tokens based on elapsed time
	elapsed := now.Sub(b.lastUpdate)
	refill := int(elapsed.Seconds()) * config.RPC.RequestsPerSecond
	b.tokens = min(b.tokens+refill, config.RPC.BurstSize)
	b.lastUpdate = now

	if b.tokens > 0 {
		b.tokens--
		return true
	}
	return false
}

// GetRemainingTokens returns remaining tokens for a routing_token
func (trl *TieredRateLimiter) GetRemainingTokens(routingToken string) int {
	trl.mu.RLock()
	defer trl.mu.RUnlock()
	if b, ok := trl.buckets[routingToken]; ok {
		return b.tokens
	}
	return -1
}

// GetTierLimit returns the RPS limit for a routing_token's tier
func (trl *TieredRateLimiter) GetTierLimit(routingToken string) int {
	tierID := trl.getTier(routingToken)
	config := trl.tierConfigs.GetTierOrDefault(tierID)
	if config == nil {
		return 10 // Default free
	}
	return config.RPC.RequestsPerSecond
}

// cleanup removes stale buckets every minute
// Uses batched deletion to minimize lock contention
func (trl *TieredRateLimiter) cleanup() {
	ticker := time.NewTicker(time.Minute)
	for range ticker.C {
		staleThreshold := time.Now().Add(-10 * time.Minute)

		// Collect stale keys under read lock (non-blocking for Allow())
		trl.mu.RLock()
		var staleKeys []string
		for token, b := range trl.buckets {
			if b.lastUpdate.Before(staleThreshold) {
				staleKeys = append(staleKeys, token)
			}
		}
		trl.mu.RUnlock()

		// Delete in batches to minimize lock hold time
		if len(staleKeys) > 0 {
			const batchSize = 100
			for i := 0; i < len(staleKeys); i += batchSize {
				end := i + batchSize
				if end > len(staleKeys) {
					end = len(staleKeys)
				}
				batch := staleKeys[i:end]

				trl.mu.Lock()
				for _, key := range batch {
					// Re-check staleness (bucket might have been updated since collection)
					if b, exists := trl.buckets[key]; exists && b.lastUpdate.Before(staleThreshold) {
						delete(trl.buckets, key)
					}
				}
				trl.mu.Unlock()
			}
		}
	}
}

// UnaryInterceptor creates a gRPC unary interceptor for tier-aware rate limiting
func (trl *TieredRateLimiter) UnaryInterceptor() grpc.UnaryServerInterceptor {
	return func(
		ctx context.Context,
		req interface{},
		info *grpc.UnaryServerInfo,
		handler grpc.UnaryHandler,
	) (interface{}, error) {
		// Extract routing_token from context (set by auth interceptor)
		routingToken, _ := ctx.Value(contextKeyRoutingToken).(string)

		if routingToken != "" && !trl.Allow(routingToken) {
			tierID := trl.getTier(routingToken)
			limit := trl.GetTierLimit(routingToken)
			return nil, status.Errorf(codes.ResourceExhausted,
				"rate limit exceeded: tier=%s, limit=%d req/s", tierID, limit)
		}

		return handler(ctx, req)
	}
}

// StreamInterceptor creates a gRPC stream interceptor for tier-aware rate limiting
func (trl *TieredRateLimiter) StreamInterceptor() grpc.StreamServerInterceptor {
	return func(
		srv interface{},
		ss grpc.ServerStream,
		info *grpc.StreamServerInfo,
		handler grpc.StreamHandler,
	) error {
		// Extract routing_token from context
		routingToken, _ := ss.Context().Value(contextKeyRoutingToken).(string)

		if routingToken != "" && !trl.Allow(routingToken) {
			tierID := trl.getTier(routingToken)
			limit := trl.GetTierLimit(routingToken)
			return status.Errorf(codes.ResourceExhausted,
				"rate limit exceeded: tier=%s, limit=%d req/s", tierID, limit)
		}

		return handler(srv, ss)
	}
}

// Context key for routing token
type contextKey string

const contextKeyRoutingToken contextKey = "routing_token"

// ContextWithRoutingToken adds routing_token to context
func ContextWithRoutingToken(ctx context.Context, token string) context.Context {
	return context.WithValue(ctx, contextKeyRoutingToken, token)
}

// RoutingTokenFromContext extracts routing_token from context
func RoutingTokenFromContext(ctx context.Context) string {
	token, _ := ctx.Value(contextKeyRoutingToken).(string)
	return token
}
