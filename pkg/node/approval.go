package node

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
)

// AlertSender is an interface to decouple ApprovalManager from HubClient
type AlertSender interface {
	SendAlert(alert *common.Alert, info string) error
}

// ApprovalManager handles real-time connection approval workflow
type ApprovalManager struct {
	sender AlertSender

	mu       sync.Mutex
	requests map[string]*PendingRequest

	// Cache for time-limited approvals
	cache *ApprovalCache
}

// ApprovalCache stores time-limited approval decisions
type ApprovalCache struct {
	entries map[string]*ApprovalEntry
	mu      sync.RWMutex

	// Optional callback to close connections on expiry
	connCloser ConnectionCloser
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

	// Active connection tracking
	ConnIDs []string

	// GeoIP info for display
	GeoCountry string
	GeoCity    string
	GeoISP     string

	// Live stats
	BytesIn      int64
	BytesOut     int64
	BlockedCount int32
}

// ConnectionCloser is an interface for closing connections
type ConnectionCloser interface {
	CloseConnection(proxyID, connID string) error
}

// NewApprovalCache creates a new approval cache
func NewApprovalCache() *ApprovalCache {
	c := &ApprovalCache{
		entries: make(map[string]*ApprovalEntry),
	}
	go c.cleanupLoop()
	return c
}

// SetConnectionCloser sets the callback for closing connections on expiry
func (c *ApprovalCache) SetConnectionCloser(closer ConnectionCloser) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.connCloser = closer
}

// cleanupLoop periodically removes expired entries
func (c *ApprovalCache) cleanupLoop() {
	ticker := time.NewTicker(10 * time.Second)
	for range ticker.C {
		c.mu.Lock()
		now := time.Now()
		var toClose []struct{ proxyID, connID string }

		for key, entry := range c.entries {
			if now.After(entry.ExpiresAt) {
				if entry.Decision && len(entry.ConnIDs) > 0 {
					for _, connID := range entry.ConnIDs {
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

func buildKey(sourceIP, ruleID, tlsSessionID string) string {
	if tlsSessionID != "" {
		return sourceIP + ":" + ruleID + ":" + tlsSessionID
	}
	return sourceIP + ":" + ruleID
}

// Check returns (found, decision) for a cached approval
func (c *ApprovalCache) Check(sourceIP, ruleID, tlsSessionID string) (bool, bool) {
	c.mu.RLock()
	defer c.mu.RUnlock()

	key := buildKey(sourceIP, ruleID, tlsSessionID)
	if entry, ok := c.entries[key]; ok {
		if time.Now().Before(entry.ExpiresAt) {
			return true, entry.Decision
		}
	}

	// Fallback: check without TLS session ID
	if tlsSessionID != "" {
		key = buildKey(sourceIP, ruleID, "")
		if entry, ok := c.entries[key]; ok {
			if time.Now().Before(entry.ExpiresAt) {
				return true, entry.Decision
			}
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

	if tlsSessionID != "" {
		key = buildKey(sourceIP, ruleID, "")
		delete(c.entries, key)
	}
}

// SetConnID updates the connection ID for a cached approval
func (c *ApprovalCache) SetConnID(sourceIP, ruleID, tlsSessionID, connID string) {
	c.mu.Lock()
	defer c.mu.Unlock()

	key := buildKey(sourceIP, ruleID, tlsSessionID)
	if entry, ok := c.entries[key]; ok {
		entry.ConnIDs = append(entry.ConnIDs, connID)
		return
	}

	if tlsSessionID != "" {
		key = buildKey(sourceIP, ruleID, "")
		if entry, ok := c.entries[key]; ok {
			entry.ConnIDs = append(entry.ConnIDs, connID)
		}
	}
}

// GetActiveApprovals returns all active (non-expired) approvals
func (c *ApprovalCache) GetActiveApprovals() []*ApprovalEntry {
	c.mu.RLock()
	defer c.mu.RUnlock()

	var result []*ApprovalEntry
	now := time.Now()
	for _, entry := range c.entries {
		if now.Before(entry.ExpiresAt) {
			result = append(result, entry)
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
		return
	}

	if tlsSessionID != "" {
		key = buildKey(sourceIP, ruleID, "")
		if entry, ok := c.entries[key]; ok {
			entry.BlockedCount++
		}
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
		return
	}

	if tlsSessionID != "" {
		key = buildKey(sourceIP, ruleID, "")
		if entry, ok := c.entries[key]; ok {
			entry.BytesIn += bytesIn
			entry.BytesOut += bytesOut
		}
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

	if tlsSessionID != "" {
		key = buildKey(sourceIP, ruleID, "")
		if entry, ok := c.entries[key]; ok {
			return entry
		}
	}

	return nil
}

// ApprovalResult contains the result of an approval request
type ApprovalResult struct {
	Allowed  bool
	Duration time.Duration
	RuleID   string
	Payload  string
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
}

// NewApprovalManager creates a new approval manager
func NewApprovalManager(sender AlertSender) *ApprovalManager {
	return &ApprovalManager{
		sender:   sender,
		requests: make(map[string]*PendingRequest),
		cache:    NewApprovalCache(),
	}
}

// RequestApproval sends an alert and waits for a decision
func (am *ApprovalManager) RequestApproval(ctx context.Context, reqID string, nodeID string, info string, meta ApprovalRequestMeta) (ApprovalResult, error) {
	resultCh := make(chan ApprovalResult, 1)

	am.mu.Lock()
	am.requests[reqID] = &PendingRequest{
		ResultCh: resultCh,
		Meta:     meta,
	}
	am.mu.Unlock()

	defer func() {
		am.mu.Lock()
		delete(am.requests, reqID)
		am.mu.Unlock()
	}()

	// Send Alert
	alert := &common.Alert{
		Id:            reqID,
		NodeId:        nodeID,
		Severity:      "high",
		TimestampUnix: time.Now().Unix(),
		// Metadata can be added for source IP, dest, etc.
	}

	if err := am.sender.SendAlert(alert, info); err != nil {
		return ApprovalResult{}, fmt.Errorf("failed to send approval request: %v", err)
	}

	// Wait for response or timeout
	select {
	case res := <-resultCh:
		return res, nil
	case <-ctx.Done():
		return ApprovalResult{Allowed: false}, fmt.Errorf("approval timeout: %w", ctx.Err())
	}
}

// Resolve is called when a decision is received from Hub
func (am *ApprovalManager) Resolve(reqID string, allowed bool, durationSeconds int64) *ApprovalRequestMeta {
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

// SetConnID updates the connection ID for a cached approval
func (am *ApprovalManager) SetConnID(sourceIP, ruleID, tlsSessionID, connID string) {
	am.cache.SetConnID(sourceIP, ruleID, tlsSessionID, connID)
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
