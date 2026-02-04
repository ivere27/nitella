package config

import "time"

// Approval system defaults
const (
	// DefaultApprovalDurationSeconds is the default approval duration (5 minutes).
	// Used by: cli, node
	DefaultApprovalDurationSeconds = 300

	// DefaultApprovalTimeoutSeconds is the timeout for pending approval requests (2 minutes).
	// Used by: node
	DefaultApprovalTimeoutSeconds = 120

	// DefaultMaxPendingApprovals is the maximum concurrent pending approval requests
	// to prevent memory exhaustion from DoS attacks.
	// Used by: node
	DefaultMaxPendingApprovals = 1000

	// DefaultMaxPendingPerIP limits pending approvals from a single IP address.
	// This prevents a single attacker from exhausting all slots.
	// Used by: node
	DefaultMaxPendingPerIP = 10

	// DefaultMaxPendingPerProxy limits pending approvals per proxy.
	// This prevents an attacked proxy from blocking approvals for other proxies.
	// Used by: node
	DefaultMaxPendingPerProxy = 200

	// ApprovalCacheCleanupInterval is how often to check for expired approval entries.
	// Used by: node
	ApprovalCacheCleanupInterval = 10 * time.Second

	// MaxConnIDsPerApproval caps the ConnIDs slice size per approval entry.
	// This prevents memory exhaustion if RemoveConnID fails or attacker floods connections.
	// Used by: node
	MaxConnIDsPerApproval = 1000
)

// Cleanup system defaults
const (
	// DefaultTaskTimeout is the maximum time a cleanup task can run before logging a warning.
	// Tasks that exceed this are likely hung or doing too much work.
	// Used by: node
	DefaultTaskTimeout = 30 * time.Second
)

// IP-based rate limit defaults (anti-DDoS)
const (
	// DefaultIPRateLimit is the sustained requests per second allowed per IP.
	// Protects against DDoS while allowing corporate NAT (20+ users behind one IP).
	// Used by: hub
	DefaultIPRateLimit = 30

	// DefaultIPBurstSize is the burst allowance for initial connections and batch operations.
	// Allows short bursts (reconnection, batch queries) without triggering rate limit.
	// Used by: hub
	DefaultIPBurstSize = 60

	// DefaultIPRateLimitCleanupInterval is how often to clean up stale IP buckets.
	// Used by: hub
	DefaultIPRateLimitCleanupInterval = 1 * time.Minute

	// DefaultIPBucketExpiry is how long to keep IP buckets after last activity.
	// Used by: hub
	DefaultIPBucketExpiry = 10 * time.Minute
)
