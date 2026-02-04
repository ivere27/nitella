package node

import (
	"context"
	"fmt"
	"sync"
	"sync/atomic"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	"github.com/ivere27/nitella/pkg/config"
)

// KeySeparator is used to join components in approval cache keys.
// Uses null byte to avoid collision with any valid content in IP, ruleID, or sessionID.
const KeySeparator = "\x00"

// AlertSender is an interface to decouple ApprovalManager from HubClient
type AlertSender interface {
	SendAlert(alert *common.Alert, info string) error
}

// ApprovalManager handles real-time connection approval workflow
type ApprovalManager struct {
	sender AlertSender

	mu             sync.Mutex
	requests       map[string]*PendingRequest
	pendingByIP    map[string]int // Per-IP pending count for DoS protection
	pendingByProxy map[string]int // Per-proxy pending count for cross-proxy DoS protection
	maxPending     int            // Maximum concurrent pending requests (DoS protection)
	maxPendingIP   int            // Maximum pending requests per IP
	maxPendingProxy int           // Maximum pending requests per proxy

	// Cache for time-limited approvals
	cache *ApprovalCache
}

// ApprovalCache stores time-limited approval decisions
type ApprovalCache struct {
	entries map[string]*ApprovalEntry
	mu      sync.RWMutex

	// Optional callback to close connections on expiry
	connCloser ConnectionCloser

	// Stop channel for graceful shutdown
	stopCh chan struct{}
}

// LiveConnStats holds pointers to live byte counters for an active connection.
// This allows GetActiveApprovals to read real-time byte counts without waiting
// for connections to close.
type LiveConnStats struct {
	BytesIn  *int64
	BytesOut *int64
}

// ApprovalEntry represents a cached approval decision
type ApprovalEntry struct {
	SourceIP     string
	RuleID       string
	ProxyID      string
	TLSSessionID string
	Decision     bool // true=allow, false=deny
	ExpiresAt    time.Time
	CreatedAt    time.Time

	// Active connection tracking with live byte counters
	// Key: connID, Value: pointers to the connection's byte counters
	LiveConns map[string]*LiveConnStats

	// GeoIP info for display
	GeoCountry string
	GeoCity    string
	GeoISP     string

	// Accumulated stats from closed connections
	BytesIn      int64
	BytesOut     int64
	BlockedCount int32
}

// Key returns the unique key for this approval entry
// Format: sourceIP\x00ruleID\x00tlsSessionID (uses null byte to avoid collision)
func (e *ApprovalEntry) Key() string {
	return buildKey(e.SourceIP, e.RuleID, e.TLSSessionID)
}

// ConnectionCloser is an interface for closing connections
type ConnectionCloser interface {
	CloseConnection(proxyID, connID string) error
}

// NewApprovalCache creates a new approval cache
func NewApprovalCache() *ApprovalCache {
	c := &ApprovalCache{
		entries: make(map[string]*ApprovalEntry),
		stopCh:  make(chan struct{}),
	}
	go c.cleanupLoop()
	return c
}

// Stop stops the cleanup goroutine
func (c *ApprovalCache) Stop() {
	close(c.stopCh)
}

// SetConnectionCloser sets the callback for closing connections on expiry
func (c *ApprovalCache) SetConnectionCloser(closer ConnectionCloser) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.connCloser = closer
}

// cleanupLoop periodically removes expired entries
func (c *ApprovalCache) cleanupLoop() {
	ticker := time.NewTicker(config.ApprovalCacheCleanupInterval)
	defer ticker.Stop()

	for {
		select {
		case <-c.stopCh:
			return
		case <-ticker.C:
			c.mu.Lock()
			now := time.Now()
			var toClose []struct{ proxyID, connID string }

			for key, entry := range c.entries {
				if now.After(entry.ExpiresAt) {
					if entry.Decision && len(entry.LiveConns) > 0 {
						for connID := range entry.LiveConns {
							toClose = append(toClose, struct{ proxyID, connID string }{entry.ProxyID, connID})
						}
					}
					delete(c.entries, key)
				}
			}
			closer := c.connCloser
			c.mu.Unlock()

			if closer != nil {
				for _, conn := range toClose {
					closer.CloseConnection(conn.proxyID, conn.connID)
				}
			}
		}
	}
}

// buildKey creates a cache key for approval entries
// Format: sourceIP\x00ruleID\x00tlsSessionID (uses null byte to avoid collision)
func buildKey(sourceIP, ruleID, tlsSessionID string) string {
	if tlsSessionID != "" {
		return sourceIP + KeySeparator + ruleID + KeySeparator + tlsSessionID
	}
	return sourceIP + KeySeparator + ruleID
}

// Check returns (found, decision) for a cached approval
// Strict TLS session binding: no fallback to session-less entries
func (c *ApprovalCache) Check(sourceIP, ruleID, tlsSessionID string) (bool, bool) {
	c.mu.RLock()
	defer c.mu.RUnlock()

	key := buildKey(sourceIP, ruleID, tlsSessionID)
	if entry, ok := c.entries[key]; ok {
		if time.Now().Before(entry.ExpiresAt) {
			return true, entry.Decision
		}
	}

	return false, false
}

// Add adds an approval decision to the cache
func (c *ApprovalCache) Add(sourceIP, ruleID, proxyID, tlsSessionID string, decision bool, duration time.Duration) {
	c.mu.Lock()
	defer c.mu.Unlock()

	key := buildKey(sourceIP, ruleID, tlsSessionID)
	c.entries[key] = &ApprovalEntry{
		SourceIP:     sourceIP,
		RuleID:       ruleID,
		ProxyID:      proxyID,
		TLSSessionID: tlsSessionID,
		Decision:     decision,
		ExpiresAt:    time.Now().Add(duration),
		CreatedAt:    time.Now(),
	}
}

// AddWithGeo adds an entry with GeoIP information
func (c *ApprovalCache) AddWithGeo(sourceIP, ruleID, proxyID, tlsSessionID string, decision bool, duration time.Duration, geoCountry, geoCity, geoISP string) {
	c.mu.Lock()
	defer c.mu.Unlock()

	key := buildKey(sourceIP, ruleID, tlsSessionID)
	c.entries[key] = &ApprovalEntry{
		SourceIP:     sourceIP,
		RuleID:       ruleID,
		ProxyID:      proxyID,
		TLSSessionID: tlsSessionID,
		Decision:     decision,
		ExpiresAt:    time.Now().Add(duration),
		CreatedAt:    time.Now(),
		GeoCountry:   geoCountry,
		GeoCity:      geoCity,
		GeoISP:       geoISP,
	}
}

// Remove removes a cached approval
func (c *ApprovalCache) Remove(sourceIP, ruleID, tlsSessionID string) {
	c.mu.Lock()
	defer c.mu.Unlock()

	key := buildKey(sourceIP, ruleID, tlsSessionID)
	delete(c.entries, key)
}

// SetConnID adds a connection ID with live byte counter pointers to the cached approval.
// Returns false if the cap is reached (config.MaxConnIDsPerApproval).
func (c *ApprovalCache) SetConnID(sourceIP, ruleID, tlsSessionID, connID string, bytesIn, bytesOut *int64) bool {
	c.mu.Lock()
	defer c.mu.Unlock()

	key := buildKey(sourceIP, ruleID, tlsSessionID)
	if entry, ok := c.entries[key]; ok {
		// Cap check: prevent unbounded growth
		if len(entry.LiveConns) >= config.MaxConnIDsPerApproval {
			return false
		}
		if entry.LiveConns == nil {
			entry.LiveConns = make(map[string]*LiveConnStats)
		}
		entry.LiveConns[connID] = &LiveConnStats{
			BytesIn:  bytesIn,
			BytesOut: bytesOut,
		}
		return true
	}
	return false
}

// RemoveConnID removes a connection ID from the cached approval when connection closes.
// This keeps LiveConns tracking only currently active connections.
func (c *ApprovalCache) RemoveConnID(sourceIP, ruleID, tlsSessionID, connID string) {
	c.mu.Lock()
	defer c.mu.Unlock()

	key := buildKey(sourceIP, ruleID, tlsSessionID)
	if entry, ok := c.entries[key]; ok {
		delete(entry.LiveConns, connID)
	}
}

// GetActiveApprovals returns all active (non-expired) approvals with live byte stats.
// The returned entries include accumulated bytes from closed connections plus
// real-time bytes from currently active connections.
func (c *ApprovalCache) GetActiveApprovals() []*ApprovalEntry {
	c.mu.RLock()
	defer c.mu.RUnlock()

	var result []*ApprovalEntry
	now := time.Now()
	for _, entry := range c.entries {
		if now.Before(entry.ExpiresAt) {
			// Create a copy with computed live stats
			copy := &ApprovalEntry{
				SourceIP:     entry.SourceIP,
				RuleID:       entry.RuleID,
				ProxyID:      entry.ProxyID,
				TLSSessionID: entry.TLSSessionID,
				Decision:     entry.Decision,
				ExpiresAt:    entry.ExpiresAt,
				CreatedAt:    entry.CreatedAt,
				GeoCountry:   entry.GeoCountry,
				GeoCity:      entry.GeoCity,
				GeoISP:       entry.GeoISP,
				BlockedCount: entry.BlockedCount,
				// Start with accumulated bytes from closed connections
				BytesIn:  entry.BytesIn,
				BytesOut: entry.BytesOut,
			}
			// Copy connection IDs for reference
			if len(entry.LiveConns) > 0 {
				copy.LiveConns = make(map[string]*LiveConnStats, len(entry.LiveConns))
				for connID, stats := range entry.LiveConns {
					copy.LiveConns[connID] = stats
					// Add live bytes from active connections
					if stats.BytesIn != nil {
						copy.BytesIn += atomic.LoadInt64(stats.BytesIn)
					}
					if stats.BytesOut != nil {
						copy.BytesOut += atomic.LoadInt64(stats.BytesOut)
					}
				}
			}
			result = append(result, copy)
		}
	}
	return result
}

// IncrementBlockedCount increments the blocked attempt counter
func (c *ApprovalCache) IncrementBlockedCount(sourceIP, ruleID, tlsSessionID string) {
	c.mu.Lock()
	defer c.mu.Unlock()

	key := buildKey(sourceIP, ruleID, tlsSessionID)
	if entry, ok := c.entries[key]; ok {
		entry.BlockedCount++
	}
}

// UpdateBytes updates the bytes in/out counters
func (c *ApprovalCache) UpdateBytes(sourceIP, ruleID, tlsSessionID string, bytesIn, bytesOut int64) {
	c.mu.Lock()
	defer c.mu.Unlock()

	key := buildKey(sourceIP, ruleID, tlsSessionID)
	if entry, ok := c.entries[key]; ok {
		entry.BytesIn += bytesIn
		entry.BytesOut += bytesOut
	}
}

// GetEntry retrieves a specific approval entry
func (c *ApprovalCache) GetEntry(sourceIP, ruleID, tlsSessionID string) *ApprovalEntry {
	c.mu.RLock()
	defer c.mu.RUnlock()

	key := buildKey(sourceIP, ruleID, tlsSessionID)
	if entry, ok := c.entries[key]; ok {
		return entry
	}

	return nil
}

// ApprovalResult contains the result of an approval request
type ApprovalResult struct {
	Allowed  bool
	Duration time.Duration
	RuleID   string // Rule that triggered the approval request
	Reason   string // Optional reason for the decision
}

// ApprovalRequestMeta holds metadata for logging
type ApprovalRequestMeta struct {
	ProxyID    string
	SourceIP   string
	DestAddr   string
	RuleID     string
	GeoCountry string
	GeoCity    string
	GeoISP     string
}

// PendingRequest represents a pending approval request
type PendingRequest struct {
	ResultCh chan ApprovalResult
	Meta     ApprovalRequestMeta
	SourceIP string    // For per-IP tracking
	CancelCh chan struct{} // For async cancellation
}

// NewApprovalManager creates a new approval manager
func NewApprovalManager(sender AlertSender) *ApprovalManager {
	return &ApprovalManager{
		sender:          sender,
		requests:        make(map[string]*PendingRequest),
		pendingByIP:     make(map[string]int),
		pendingByProxy:  make(map[string]int),
		maxPending:      config.DefaultMaxPendingApprovals,
		maxPendingIP:    config.DefaultMaxPendingPerIP,
		maxPendingProxy: config.DefaultMaxPendingPerProxy,
		cache:           NewApprovalCache(),
	}
}

// RequestApproval sends an alert and waits for a decision (synchronous version)
// Deprecated: Use BeginApprovalRequest + WaitForApproval for connection-aware cancellation
func (am *ApprovalManager) RequestApproval(ctx context.Context, reqID string, nodeID string, info string, meta ApprovalRequestMeta) (ApprovalResult, error) {
	resultCh, err := am.BeginApprovalRequest(reqID, nodeID, info, meta)
	if err != nil {
		return ApprovalResult{Allowed: false}, err
	}
	defer am.CancelApprovalRequest(reqID)

	return am.WaitForApproval(ctx, reqID, resultCh, nil)
}

// BeginApprovalRequest starts an approval request without blocking.
// Returns the result channel. Caller MUST call CancelApprovalRequest when done.
func (am *ApprovalManager) BeginApprovalRequest(reqID string, nodeID string, info string, meta ApprovalRequestMeta) (chan ApprovalResult, error) {
	resultCh := make(chan ApprovalResult, 1)
	cancelCh := make(chan struct{})
	sourceIP := meta.SourceIP

	proxyID := meta.ProxyID

	am.mu.Lock()
	// DoS protection: reject if too many pending requests globally
	if len(am.requests) >= am.maxPending {
		am.mu.Unlock()
		return nil, fmt.Errorf("too many pending approval requests (max: %d)", am.maxPending)
	}
	// DoS protection: reject if too many pending requests from this IP
	if am.pendingByIP[sourceIP] >= am.maxPendingIP {
		am.mu.Unlock()
		return nil, fmt.Errorf("too many pending approval requests from IP %s (max: %d)", sourceIP, am.maxPendingIP)
	}
	// DoS protection: reject if too many pending requests for this proxy
	// This prevents an attacked proxy from blocking approvals for other proxies
	if proxyID != "" && am.pendingByProxy[proxyID] >= am.maxPendingProxy {
		am.mu.Unlock()
		return nil, fmt.Errorf("too many pending approval requests for proxy %s (max: %d)", proxyID, am.maxPendingProxy)
	}
	am.requests[reqID] = &PendingRequest{
		ResultCh: resultCh,
		Meta:     meta,
		SourceIP: sourceIP,
		CancelCh: cancelCh,
	}
	am.pendingByIP[sourceIP]++
	if proxyID != "" {
		am.pendingByProxy[proxyID]++
	}
	am.mu.Unlock()

	// Send Alert
	alert := &common.Alert{
		Id:            reqID,
		NodeId:        nodeID,
		Severity:      "high",
		TimestampUnix: time.Now().Unix(),
	}

	if err := am.sender.SendAlert(alert, info); err != nil {
		// Cleanup on send failure
		am.CancelApprovalRequest(reqID)
		return nil, fmt.Errorf("failed to send approval request: %v", err)
	}

	return resultCh, nil
}

// WaitForApproval waits for an approval decision with optional connection close detection.
// connClosedCh should be closed when the connection dies (can be nil to disable).
func (am *ApprovalManager) WaitForApproval(ctx context.Context, reqID string, resultCh chan ApprovalResult, connClosedCh <-chan struct{}) (ApprovalResult, error) {
	if connClosedCh != nil {
		select {
		case res := <-resultCh:
			return res, nil
		case <-connClosedCh:
			return ApprovalResult{Allowed: false}, fmt.Errorf("connection closed while waiting for approval")
		case <-ctx.Done():
			return ApprovalResult{Allowed: false}, fmt.Errorf("approval timeout: %w", ctx.Err())
		}
	} else {
		select {
		case res := <-resultCh:
			return res, nil
		case <-ctx.Done():
			return ApprovalResult{Allowed: false}, fmt.Errorf("approval timeout: %w", ctx.Err())
		}
	}
}

// CancelApprovalRequest cleans up a pending approval request.
// Safe to call multiple times or if request doesn't exist.
func (am *ApprovalManager) CancelApprovalRequest(reqID string) {
	am.mu.Lock()
	defer am.mu.Unlock()

	req, ok := am.requests[reqID]
	if !ok {
		return
	}

	// Decrement per-IP counter
	if req.SourceIP != "" {
		am.pendingByIP[req.SourceIP]--
		if am.pendingByIP[req.SourceIP] <= 0 {
			delete(am.pendingByIP, req.SourceIP)
		}
	}

	// Decrement per-proxy counter
	if req.Meta.ProxyID != "" {
		am.pendingByProxy[req.Meta.ProxyID]--
		if am.pendingByProxy[req.Meta.ProxyID] <= 0 {
			delete(am.pendingByProxy, req.Meta.ProxyID)
		}
	}

	// Signal cancellation
	select {
	case <-req.CancelCh:
		// Already closed
	default:
		close(req.CancelCh)
	}

	delete(am.requests, reqID)
}

// Resolve is called when a decision is received from Hub
func (am *ApprovalManager) Resolve(reqID string, allowed bool, durationSeconds int64, reason string) *ApprovalRequestMeta {
	am.mu.Lock()
	req, ok := am.requests[reqID]
	am.mu.Unlock()

	if !ok {
		return nil
	}

	select {
	case req.ResultCh <- ApprovalResult{
		Allowed:  allowed,
		Duration: time.Duration(durationSeconds) * time.Second,
		RuleID:   req.Meta.RuleID,
		Reason:   reason,
	}:
	default:
	}

	return &req.Meta
}

// CheckCache checks if there is a valid cached approval
func (am *ApprovalManager) CheckCache(sourceIP, ruleID, tlsSessionID string) (bool, bool) {
	return am.cache.Check(sourceIP, ruleID, tlsSessionID)
}

// AddToCache adds a decision to the cache
func (am *ApprovalManager) AddToCache(sourceIP, ruleID, proxyID, tlsSessionID string, allowed bool, duration time.Duration) {
	am.cache.Add(sourceIP, ruleID, proxyID, tlsSessionID, allowed, duration)
}

// AddToCacheWithGeo adds a decision with GeoIP info
func (am *ApprovalManager) AddToCacheWithGeo(sourceIP, ruleID, proxyID, tlsSessionID string, allowed bool, duration time.Duration, geoCountry, geoCity, geoISP string) {
	am.cache.AddWithGeo(sourceIP, ruleID, proxyID, tlsSessionID, allowed, duration, geoCountry, geoCity, geoISP)
}

// GetActiveApprovals returns all active approvals
func (am *ApprovalManager) GetActiveApprovals() []*ApprovalEntry {
	return am.cache.GetActiveApprovals()
}

// RemoveApproval removes a cached approval
func (am *ApprovalManager) RemoveApproval(sourceIP, ruleID, tlsSessionID string) {
	am.cache.Remove(sourceIP, ruleID, tlsSessionID)
}

// SetConnID adds a connection ID with live byte counter pointers to the cached approval.
// Returns false if the cap is reached (config.MaxConnIDsPerApproval).
func (am *ApprovalManager) SetConnID(sourceIP, ruleID, tlsSessionID, connID string, bytesIn, bytesOut *int64) bool {
	return am.cache.SetConnID(sourceIP, ruleID, tlsSessionID, connID, bytesIn, bytesOut)
}

// RemoveConnID removes a connection ID when the connection closes.
func (am *ApprovalManager) RemoveConnID(sourceIP, ruleID, tlsSessionID, connID string) {
	am.cache.RemoveConnID(sourceIP, ruleID, tlsSessionID, connID)
}

// SetConnectionCloser sets the callback for closing connections on expiry
func (am *ApprovalManager) SetConnectionCloser(closer ConnectionCloser) {
	am.cache.SetConnectionCloser(closer)
}

// IncrementBlockedCount increments the blocked attempt counter
func (am *ApprovalManager) IncrementBlockedCount(sourceIP, ruleID, tlsSessionID string) {
	am.cache.IncrementBlockedCount(sourceIP, ruleID, tlsSessionID)
}

// UpdateBytes updates bytes in/out counters
func (am *ApprovalManager) UpdateBytes(sourceIP, ruleID, tlsSessionID string, bytesIn, bytesOut int64) {
	am.cache.UpdateBytes(sourceIP, ruleID, tlsSessionID, bytesIn, bytesOut)
}

// GetEntry retrieves a specific approval entry
func (am *ApprovalManager) GetEntry(sourceIP, ruleID, tlsSessionID string) *ApprovalEntry {
	return am.cache.GetEntry(sourceIP, ruleID, tlsSessionID)
}
