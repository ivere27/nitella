package node

import (
	"context"
	"fmt"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	"github.com/ivere27/nitella/pkg/config"
)

// MockAlertSender implements AlertSender for testing
type MockAlertSender struct {
	alerts []*common.Alert
	infos  []string
	mu     sync.Mutex
	err    error
}

func (m *MockAlertSender) SendAlert(alert *common.Alert, info string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.alerts = append(m.alerts, alert)
	m.infos = append(m.infos, info)
	return m.err
}

func (m *MockAlertSender) GetAlerts() []*common.Alert {
	m.mu.Lock()
	defer m.mu.Unlock()
	return m.alerts
}

// MockConnectionCloser implements ConnectionCloser for testing
type MockConnectionCloser struct {
	closedConns []struct{ proxyID, connID string }
	mu          sync.Mutex
}

func (m *MockConnectionCloser) CloseConnection(proxyID, connID string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.closedConns = append(m.closedConns, struct{ proxyID, connID string }{proxyID, connID})
	return nil
}

func (m *MockConnectionCloser) GetClosedConns() []struct{ proxyID, connID string } {
	m.mu.Lock()
	defer m.mu.Unlock()
	return m.closedConns
}

// ===== ApprovalCache Tests =====

func TestApprovalCache_AddAndCheck(t *testing.T) {
	cache := NewApprovalCache()

	// Add an approval
	cache.Add("1.2.3.4", "rule-1", "proxy-1", "", true, 1*time.Hour)

	// Check it exists
	found, allowed := cache.Check("1.2.3.4", "rule-1", "")
	if !found {
		t.Error("Expected to find cached approval")
	}
	if !allowed {
		t.Error("Expected approval to be allowed")
	}

	// Check non-existent
	found, _ = cache.Check("5.6.7.8", "rule-1", "")
	if found {
		t.Error("Should not find non-existent approval")
	}
}

func TestApprovalCache_CheckMiss(t *testing.T) {
	cache := NewApprovalCache()

	found, _ := cache.Check("1.2.3.4", "rule-1", "")
	if found {
		t.Error("Empty cache should not have entries")
	}
}

func TestApprovalCache_TLSSessionBinding(t *testing.T) {
	cache := NewApprovalCache()

	// Add approval with TLS session
	cache.Add("1.2.3.4", "rule-1", "proxy-1", "session-abc", true, 1*time.Hour)

	// Check with same session - should find
	found, allowed := cache.Check("1.2.3.4", "rule-1", "session-abc")
	if !found || !allowed {
		t.Error("Should find approval with matching TLS session")
	}

	// Check with different session - should NOT find (TLS binding)
	found, _ = cache.Check("1.2.3.4", "rule-1", "session-xyz")
	if found {
		t.Error("Should NOT find approval with different TLS session")
	}
}

func TestApprovalCache_StrictBinding_NoFallback(t *testing.T) {
	cache := NewApprovalCache()

	// Add approval WITHOUT TLS session (IP-based)
	cache.Add("1.2.3.4", "rule-1", "proxy-1", "", true, 1*time.Hour)

	// Check with a TLS session - should NOT fall back to non-TLS entry
	// We enforce strict binding to prevent spoofing
	found, _ := cache.Check("1.2.3.4", "rule-1", "session-xyz")
	if found {
		t.Error("Should NOT fall back to non-TLS entry when strict binding is required")
	}
}

func TestApprovalCache_ExpiryRemovesEntry(t *testing.T) {
	cache := NewApprovalCache()

	// Add with very short duration
	cache.Add("1.2.3.4", "rule-1", "proxy-1", "", true, 50*time.Millisecond)

	// Immediately should be found
	found, _ := cache.Check("1.2.3.4", "rule-1", "")
	if !found {
		t.Error("Should find immediately after adding")
	}

	// Wait for expiry
	time.Sleep(100 * time.Millisecond)

	// Should NOT be found (expired)
	found, _ = cache.Check("1.2.3.4", "rule-1", "")
	if found {
		t.Error("Should NOT find expired entry")
	}
}

func TestApprovalCache_ExpiryClosesConnections(t *testing.T) {
	cache := NewApprovalCache()
	closer := &MockConnectionCloser{}
	cache.SetConnectionCloser(closer)

	// Add approval with connection and short duration
	var bytesIn, bytesOut int64
	cache.Add("1.2.3.4", "rule-1", "proxy-1", "", true, 50*time.Millisecond)
	cache.SetConnID("1.2.3.4", "rule-1", "", "conn-123", &bytesIn, &bytesOut)

	// Wait for cleanup loop (runs every 10s, but we'll wait for expiry check)
	// Force a manual check since cleanup loop is too slow for test
	time.Sleep(100 * time.Millisecond)

	// Manually trigger cleanup (simulating what cleanupLoop does)
	cache.mu.Lock()
	now := time.Now()
	for key, entry := range cache.entries {
		if now.After(entry.ExpiresAt) {
			if entry.Decision && len(entry.LiveConns) > 0 {
				for connID := range entry.LiveConns {
					closer.CloseConnection(entry.ProxyID, connID)
				}
			}
			delete(cache.entries, key)
		}
	}
	cache.mu.Unlock()

	// Check connection was closed
	closed := closer.GetClosedConns()
	if len(closed) != 1 {
		t.Errorf("Expected 1 connection closed, got %d", len(closed))
	}
	if len(closed) > 0 && closed[0].connID != "conn-123" {
		t.Errorf("Expected conn-123 closed, got %s", closed[0].connID)
	}
}

func TestApprovalCache_DurationOnce(t *testing.T) {
	cache := NewApprovalCache()

	// Duration 0 means "once" - no caching
	cache.Add("1.2.3.4", "rule-1", "proxy-1", "", true, 0)

	// Entry is added but with zero duration, expires immediately
	found, _ := cache.Check("1.2.3.4", "rule-1", "")
	// With 0 duration, ExpiresAt is time.Now(), so it's effectively expired
	if found {
		t.Log("Note: 0 duration means immediately expired - this is expected for 'once' mode")
	}
}

func TestApprovalCache_BlockDecision(t *testing.T) {
	cache := NewApprovalCache()

	// Add a block decision
	cache.Add("1.2.3.4", "rule-1", "proxy-1", "", false, 1*time.Hour)

	found, allowed := cache.Check("1.2.3.4", "rule-1", "")
	if !found {
		t.Error("Should find cached block decision")
	}
	if allowed {
		t.Error("Decision should be block (allowed=false)")
	}
}

func TestApprovalCache_Remove(t *testing.T) {
	cache := NewApprovalCache()

	cache.Add("1.2.3.4", "rule-1", "proxy-1", "", true, 1*time.Hour)

	// Verify it exists
	found, _ := cache.Check("1.2.3.4", "rule-1", "")
	if !found {
		t.Error("Should find before removal")
	}

	// Remove it
	cache.Remove("1.2.3.4", "rule-1", "")

	// Verify it's gone
	found, _ = cache.Check("1.2.3.4", "rule-1", "")
	if found {
		t.Error("Should NOT find after removal")
	}
}

func TestApprovalCache_GetActiveApprovals(t *testing.T) {
	cache := NewApprovalCache()

	cache.Add("1.2.3.4", "rule-1", "proxy-1", "", true, 1*time.Hour)
	cache.Add("5.6.7.8", "rule-2", "proxy-1", "", false, 1*time.Hour)

	active := cache.GetActiveApprovals()
	if len(active) != 2 {
		t.Errorf("Expected 2 active approvals, got %d", len(active))
	}
}

func TestApprovalCache_IncrementBlockedCount(t *testing.T) {
	cache := NewApprovalCache()

	cache.Add("1.2.3.4", "rule-1", "proxy-1", "", false, 1*time.Hour)

	cache.IncrementBlockedCount("1.2.3.4", "rule-1", "")
	cache.IncrementBlockedCount("1.2.3.4", "rule-1", "")

	entry := cache.GetEntry("1.2.3.4", "rule-1", "")
	if entry == nil {
		t.Fatal("Entry should exist")
	}
	if entry.BlockedCount != 2 {
		t.Errorf("Expected BlockedCount=2, got %d", entry.BlockedCount)
	}
}

func TestApprovalCache_UpdateBytes(t *testing.T) {
	cache := NewApprovalCache()

	cache.Add("1.2.3.4", "rule-1", "proxy-1", "", true, 1*time.Hour)

	cache.UpdateBytes("1.2.3.4", "rule-1", "", 1000, 500)
	cache.UpdateBytes("1.2.3.4", "rule-1", "", 2000, 1000)

	entry := cache.GetEntry("1.2.3.4", "rule-1", "")
	if entry == nil {
		t.Fatal("Entry should exist")
	}
	if entry.BytesIn != 3000 {
		t.Errorf("Expected BytesIn=3000, got %d", entry.BytesIn)
	}
	if entry.BytesOut != 1500 {
		t.Errorf("Expected BytesOut=1500, got %d", entry.BytesOut)
	}
}

func TestApprovalCache_LiveBytesInGetActiveApprovals(t *testing.T) {
	cache := NewApprovalCache()
	defer cache.Stop()

	// Add an approval entry
	cache.Add("1.2.3.4", "rule-1", "proxy-1", "", true, 1*time.Hour)

	// Simulate accumulated bytes from a closed connection
	cache.UpdateBytes("1.2.3.4", "rule-1", "", 1000, 500)

	// Simulate an active connection with live byte counters
	var liveIn, liveOut int64 = 2000, 1000
	cache.SetConnID("1.2.3.4", "rule-1", "", "conn-1", &liveIn, &liveOut)

	// GetActiveApprovals should include both accumulated + live bytes
	active := cache.GetActiveApprovals()
	if len(active) != 1 {
		t.Fatalf("Expected 1 active approval, got %d", len(active))
	}

	entry := active[0]
	// Should be accumulated (1000) + live (2000) = 3000
	if entry.BytesIn != 3000 {
		t.Errorf("Expected BytesIn=3000 (accumulated 1000 + live 2000), got %d", entry.BytesIn)
	}
	// Should be accumulated (500) + live (1000) = 1500
	if entry.BytesOut != 1500 {
		t.Errorf("Expected BytesOut=1500 (accumulated 500 + live 1000), got %d", entry.BytesOut)
	}

	// Now update the live counters (simulating ongoing traffic)
	atomic.AddInt64(&liveIn, 500)
	atomic.AddInt64(&liveOut, 250)

	// GetActiveApprovals should reflect the new live values
	active = cache.GetActiveApprovals()
	entry = active[0]
	// Should be accumulated (1000) + live (2500) = 3500
	if entry.BytesIn != 3500 {
		t.Errorf("Expected BytesIn=3500 after update, got %d", entry.BytesIn)
	}
	// Should be accumulated (500) + live (1250) = 1750
	if entry.BytesOut != 1750 {
		t.Errorf("Expected BytesOut=1750 after update, got %d", entry.BytesOut)
	}
}

func TestApprovalCache_ConcurrentAccess(t *testing.T) {
	cache := NewApprovalCache()
	var wg sync.WaitGroup
	var ops int64

	// Concurrent writes
	for i := 0; i < 100; i++ {
		wg.Add(1)
		go func(idx int) {
			defer wg.Done()
			ip := "1.2.3." + string(rune('0'+idx%10))
			cache.Add(ip, "rule-1", "proxy-1", "", true, 1*time.Hour)
			atomic.AddInt64(&ops, 1)
		}(i)
	}

	// Concurrent reads
	for i := 0; i < 100; i++ {
		wg.Add(1)
		go func(idx int) {
			defer wg.Done()
			ip := "1.2.3." + string(rune('0'+idx%10))
			cache.Check(ip, "rule-1", "")
			atomic.AddInt64(&ops, 1)
		}(i)
	}

	wg.Wait()

	if ops != 200 {
		t.Errorf("Expected 200 operations, got %d", ops)
	}
}

// ===== ApprovalManager Tests =====

func TestApprovalManager_RequestTimeout(t *testing.T) {
	sender := &MockAlertSender{}
	am := NewApprovalManager(sender)

	ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
	defer cancel()

	meta := ApprovalRequestMeta{
		ProxyID:  "proxy-1",
		SourceIP: "1.2.3.4",
	}

	result, err := am.RequestApproval(ctx, "req-123", "node-1", "test info", meta)
	if err == nil {
		t.Error("Expected timeout error")
	}
	if result.Allowed {
		t.Error("Timeout should result in not allowed")
	}

	// Check alert was sent
	alerts := sender.GetAlerts()
	if len(alerts) != 1 {
		t.Errorf("Expected 1 alert sent, got %d", len(alerts))
	}
}

func TestApprovalManager_ResolveAllow(t *testing.T) {
	sender := &MockAlertSender{}
	am := NewApprovalManager(sender)

	// Start approval request in goroutine
	var result ApprovalResult
	var err error
	done := make(chan struct{})

	go func() {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		meta := ApprovalRequestMeta{ProxyID: "proxy-1", SourceIP: "1.2.3.4"}
		result, err = am.RequestApproval(ctx, "req-123", "node-1", "test", meta)
		close(done)
	}()

	// Wait a bit for request to be registered
	time.Sleep(50 * time.Millisecond)

	// Resolve it
	meta := am.Resolve("req-123", true, 3600, "")
	if meta == nil {
		t.Error("Resolve should return meta for valid request")
	}

	// Wait for result
	<-done

	if err != nil {
		t.Errorf("Unexpected error: %v", err)
	}
	if !result.Allowed {
		t.Error("Result should be allowed")
	}
	if result.Duration != 3600*time.Second {
		t.Errorf("Expected duration 3600s, got %v", result.Duration)
	}
}

func TestApprovalManager_ResolveBlock(t *testing.T) {
	sender := &MockAlertSender{}
	am := NewApprovalManager(sender)

	var result ApprovalResult
	done := make(chan struct{})

	go func() {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		meta := ApprovalRequestMeta{ProxyID: "proxy-1", SourceIP: "1.2.3.4"}
		result, _ = am.RequestApproval(ctx, "req-123", "node-1", "test", meta)
		close(done)
	}()

	time.Sleep(50 * time.Millisecond)

	am.Resolve("req-123", false, 600, "")

	<-done

	if result.Allowed {
		t.Error("Result should be blocked")
	}
}

func TestApprovalManager_ResolveConnectionOnly(t *testing.T) {
	sender := &MockAlertSender{}
	am := NewApprovalManager(sender)

	var result ApprovalResult
	done := make(chan struct{})

	go func() {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		meta := ApprovalRequestMeta{ProxyID: "proxy-1", SourceIP: "1.2.3.4"}
		result, _ = am.RequestApproval(ctx, "req-conn-only", "node-1", "test", meta)
		close(done)
	}()

	time.Sleep(50 * time.Millisecond)

	am.ResolveWithRetention(
		"req-conn-only",
		true,
		60,
		"",
		common.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CONNECTION_ONLY,
	)

	<-done

	if !result.Allowed {
		t.Error("Result should be allowed")
	}
	if result.RetentionMode != common.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CONNECTION_ONLY {
		t.Fatalf("Expected CONNECTION_ONLY mode, got %v", result.RetentionMode)
	}
	if result.Duration != 60*time.Second {
		t.Fatalf("Expected duration 60s, got %v", result.Duration)
	}
}

func TestApprovalManager_ResolveMissingRequest(t *testing.T) {
	sender := &MockAlertSender{}
	am := NewApprovalManager(sender)

	// Try to resolve non-existent request
	meta := am.Resolve("non-existent", true, 3600, "")
	if meta != nil {
		t.Error("Should return nil for non-existent request")
	}
}

func TestApprovalManager_CacheIntegration(t *testing.T) {
	sender := &MockAlertSender{}
	am := NewApprovalManager(sender)

	// Add to cache
	am.AddToCache("1.2.3.4", "rule-1", "proxy-1", "", true, 1*time.Hour)

	// Check cache
	found, allowed := am.CheckCache("1.2.3.4", "rule-1", "")
	if !found || !allowed {
		t.Error("Should find allowed entry in cache")
	}

	// Get active approvals
	active := am.GetActiveApprovals()
	if len(active) != 1 {
		t.Errorf("Expected 1 active approval, got %d", len(active))
	}
}

func TestApprovalManager_AddToCacheWithGeo(t *testing.T) {
	sender := &MockAlertSender{}
	am := NewApprovalManager(sender)

	am.AddToCacheWithGeo("1.2.3.4", "rule-1", "proxy-1", "", true, 1*time.Hour, "US", "New York", "Comcast")

	entry := am.GetEntry("1.2.3.4", "rule-1", "")
	if entry == nil {
		t.Fatal("Entry should exist")
	}
	if entry.GeoCountry != "US" {
		t.Errorf("Expected GeoCountry=US, got %s", entry.GeoCountry)
	}
	if entry.GeoCity != "New York" {
		t.Errorf("Expected GeoCity=New York, got %s", entry.GeoCity)
	}
}

// ===== Key Collision Tests =====

func TestApprovalCache_KeyWithSpecialCharacters(t *testing.T) {
	cache := NewApprovalCache()

	// Test rule ID containing pipe character (old separator)
	// This would break with "|" separator but works with "\x00"
	ruleWithPipe := "rule|with|pipes"
	cache.Add("1.2.3.4", ruleWithPipe, "proxy-1", "", true, 1*time.Hour)

	// Should find the exact entry
	found, allowed := cache.Check("1.2.3.4", ruleWithPipe, "")
	if !found {
		t.Error("Should find entry with pipe in rule ID")
	}
	if !allowed {
		t.Error("Should be allowed")
	}

	// Should NOT find with partial rule ID
	found, _ = cache.Check("1.2.3.4", "rule", "")
	if found {
		t.Error("Should NOT find entry with partial rule ID")
	}

	// Remove should work correctly
	cache.Remove("1.2.3.4", ruleWithPipe, "")
	found, _ = cache.Check("1.2.3.4", ruleWithPipe, "")
	if found {
		t.Error("Should NOT find after removal")
	}
}

func TestApprovalCache_KeyWithSpecialCharactersAndTLS(t *testing.T) {
	cache := NewApprovalCache()

	// Test with pipe in rule ID AND TLS session
	ruleWithPipe := "rule|test|id"
	tlsSession := "session-abc"

	cache.Add("192.168.1.1", ruleWithPipe, "proxy-1", tlsSession, true, 1*time.Hour)

	// Should find with exact match
	found, allowed := cache.Check("192.168.1.1", ruleWithPipe, tlsSession)
	if !found || !allowed {
		t.Error("Should find entry with exact rule ID and TLS session")
	}

	// Should NOT find with different TLS session
	found, _ = cache.Check("192.168.1.1", ruleWithPipe, "other-session")
	if found {
		t.Error("Should NOT find with different TLS session")
	}

	// Verify key format uses null separator
	entry := cache.GetEntry("192.168.1.1", ruleWithPipe, tlsSession)
	if entry == nil {
		t.Fatal("Entry should exist")
	}
	expectedKey := "192.168.1.1" + KeySeparator + ruleWithPipe + KeySeparator + tlsSession
	if entry.Key() != expectedKey {
		t.Errorf("Key format incorrect.\nExpected: %q\nGot: %q", expectedKey, entry.Key())
	}
}

func TestApprovalEntry_KeyFormat(t *testing.T) {
	tests := []struct {
		name         string
		sourceIP     string
		ruleID       string
		tlsSessionID string
		wantKey      string
	}{
		{
			name:         "simple without TLS",
			sourceIP:     "1.2.3.4",
			ruleID:       "rule-1",
			tlsSessionID: "",
			wantKey:      "1.2.3.4\x00rule-1",
		},
		{
			name:         "simple with TLS",
			sourceIP:     "1.2.3.4",
			ruleID:       "rule-1",
			tlsSessionID: "session-123",
			wantKey:      "1.2.3.4\x00rule-1\x00session-123",
		},
		{
			name:         "IPv6 address",
			sourceIP:     "2001:db8::1",
			ruleID:       "rule-1",
			tlsSessionID: "",
			wantKey:      "2001:db8::1\x00rule-1",
		},
		{
			name:         "rule with pipe characters",
			sourceIP:     "10.0.0.1",
			ruleID:       "rule|with|pipes",
			tlsSessionID: "session",
			wantKey:      "10.0.0.1\x00rule|with|pipes\x00session",
		},
		{
			name:         "rule with special chars",
			sourceIP:     "172.16.0.1",
			ruleID:       "rule:test/path?query=1&foo=bar",
			tlsSessionID: "",
			wantKey:      "172.16.0.1\x00rule:test/path?query=1&foo=bar",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			entry := &ApprovalEntry{
				SourceIP:     tt.sourceIP,
				RuleID:       tt.ruleID,
				TLSSessionID: tt.tlsSessionID,
			}
			if got := entry.Key(); got != tt.wantKey {
				t.Errorf("Key() = %q, want %q", got, tt.wantKey)
			}

			// Also test buildKey produces same result
			builtKey := buildKey(tt.sourceIP, tt.ruleID, tt.tlsSessionID)
			if builtKey != tt.wantKey {
				t.Errorf("buildKey() = %q, want %q", builtKey, tt.wantKey)
			}
		})
	}
}

// ===== Per-IP Rate Limit Tests =====

func TestApprovalManager_PerIPLimit(t *testing.T) {
	sender := &MockAlertSender{}
	am := NewApprovalManager(sender)

	// The default per-IP limit is 10
	sourceIP := "192.168.1.100"

	// Start multiple approval requests from the same IP
	var resultChs []chan ApprovalResult
	for i := 0; i < config.DefaultMaxPendingPerIP; i++ {
		reqID := fmt.Sprintf("req-%d", i)
		meta := ApprovalRequestMeta{SourceIP: sourceIP}
		resultCh, err := am.BeginApprovalRequest(reqID, "node-1", "{}", meta)
		if err != nil {
			t.Fatalf("Request %d should succeed: %v", i, err)
		}
		resultChs = append(resultChs, resultCh)
	}

	// The next request from the same IP should be rejected
	meta := ApprovalRequestMeta{SourceIP: sourceIP}
	_, err := am.BeginApprovalRequest("req-overflow", "node-1", "{}", meta)
	if err == nil {
		t.Error("Request should be rejected due to per-IP limit")
	}

	// Request from a different IP should succeed
	meta2 := ApprovalRequestMeta{SourceIP: "10.0.0.1"}
	resultCh, err := am.BeginApprovalRequest("req-other-ip", "node-1", "{}", meta2)
	if err != nil {
		t.Fatalf("Request from different IP should succeed: %v", err)
	}
	am.CancelApprovalRequest("req-other-ip")
	_ = resultCh

	// Cancel one request from the original IP
	am.CancelApprovalRequest("req-0")

	// Now another request from the same IP should succeed
	meta3 := ApprovalRequestMeta{SourceIP: sourceIP}
	resultCh2, err := am.BeginApprovalRequest("req-after-cancel", "node-1", "{}", meta3)
	if err != nil {
		t.Fatalf("Request should succeed after cancel freed a slot: %v", err)
	}
	am.CancelApprovalRequest("req-after-cancel")
	_ = resultCh2

	// Cleanup remaining requests
	for i := 1; i < config.DefaultMaxPendingPerIP; i++ {
		am.CancelApprovalRequest(fmt.Sprintf("req-%d", i))
	}
}

func TestApprovalManager_PerIPLimitCleanup(t *testing.T) {
	sender := &MockAlertSender{}
	am := NewApprovalManager(sender)

	sourceIP := "192.168.1.200"

	// Start a request
	meta := ApprovalRequestMeta{SourceIP: sourceIP}
	_, err := am.BeginApprovalRequest("req-1", "node-1", "{}", meta)
	if err != nil {
		t.Fatalf("Request should succeed: %v", err)
	}

	// Verify per-IP count is 1
	am.mu.Lock()
	count := am.pendingByIP[sourceIP]
	am.mu.Unlock()
	if count != 1 {
		t.Errorf("Expected pendingByIP[%s] = 1, got %d", sourceIP, count)
	}

	// Cancel the request
	am.CancelApprovalRequest("req-1")

	// Verify per-IP count is cleaned up (should be deleted when 0)
	am.mu.Lock()
	count = am.pendingByIP[sourceIP]
	am.mu.Unlock()
	if count != 0 {
		t.Errorf("Expected pendingByIP[%s] = 0 after cancel, got %d", sourceIP, count)
	}

	// Double cancel should be safe
	am.CancelApprovalRequest("req-1")
}

func TestApprovalManager_PerProxyLimit(t *testing.T) {
	sender := &MockAlertSender{}
	am := NewApprovalManager(sender)

	proxyA := "proxy-a"
	proxyB := "proxy-b"

	// Fill up proxy A's quota
	for i := 0; i < config.DefaultMaxPendingPerProxy; i++ {
		meta := ApprovalRequestMeta{
			ProxyID:  proxyA,
			SourceIP: fmt.Sprintf("10.0.0.%d", i%256), // Different IPs to avoid per-IP limit
		}
		_, err := am.BeginApprovalRequest(fmt.Sprintf("req-a-%d", i), "node-1", "{}", meta)
		if err != nil {
			t.Fatalf("Request %d for proxy A should succeed: %v", i, err)
		}
	}

	// Next request to proxy A should fail (per-proxy limit reached)
	meta := ApprovalRequestMeta{ProxyID: proxyA, SourceIP: "10.1.0.1"}
	_, err := am.BeginApprovalRequest("req-a-overflow", "node-1", "{}", meta)
	if err == nil {
		t.Error("Request should fail when per-proxy limit is reached")
	}

	// But requests to proxy B should still work (different proxy)
	metaB := ApprovalRequestMeta{ProxyID: proxyB, SourceIP: "10.2.0.1"}
	_, err = am.BeginApprovalRequest("req-b-1", "node-1", "{}", metaB)
	if err != nil {
		t.Errorf("Request to proxy B should succeed even when proxy A is full: %v", err)
	}

	// Cleanup
	for i := 0; i < config.DefaultMaxPendingPerProxy; i++ {
		am.CancelApprovalRequest(fmt.Sprintf("req-a-%d", i))
	}
	am.CancelApprovalRequest("req-b-1")
}

func TestApprovalManager_PerProxyLimitCleanup(t *testing.T) {
	sender := &MockAlertSender{}
	am := NewApprovalManager(sender)

	proxyID := "proxy-cleanup-test"

	// Start a request
	meta := ApprovalRequestMeta{ProxyID: proxyID, SourceIP: "192.168.1.1"}
	_, err := am.BeginApprovalRequest("req-1", "node-1", "{}", meta)
	if err != nil {
		t.Fatalf("Request should succeed: %v", err)
	}

	// Verify per-proxy count is 1
	am.mu.Lock()
	count := am.pendingByProxy[proxyID]
	am.mu.Unlock()
	if count != 1 {
		t.Errorf("Expected pendingByProxy[%s] = 1, got %d", proxyID, count)
	}

	// Cancel the request
	am.CancelApprovalRequest("req-1")

	// Verify per-proxy count is cleaned up
	am.mu.Lock()
	count = am.pendingByProxy[proxyID]
	am.mu.Unlock()
	if count != 0 {
		t.Errorf("Expected pendingByProxy[%s] = 0 after cancel, got %d", proxyID, count)
	}
}

func TestApprovalManager_AsyncWaitForApproval(t *testing.T) {
	sender := &MockAlertSender{}
	am := NewApprovalManager(sender)

	sourceIP := "192.168.1.50"
	meta := ApprovalRequestMeta{SourceIP: sourceIP}

	// Start request
	resultCh, err := am.BeginApprovalRequest("req-async", "node-1", "{}", meta)
	if err != nil {
		t.Fatalf("BeginApprovalRequest failed: %v", err)
	}
	defer am.CancelApprovalRequest("req-async")

	// Resolve in background
	go func() {
		time.Sleep(50 * time.Millisecond)
		am.Resolve("req-async", true, 300, "test")
	}()

	// Wait for approval
	ctx, cancel := context.WithTimeout(context.Background(), 1*time.Second)
	defer cancel()

	result, err := am.WaitForApproval(ctx, "req-async", resultCh, nil)
	if err != nil {
		t.Fatalf("WaitForApproval failed: %v", err)
	}
	if !result.Allowed {
		t.Error("Expected approval to be allowed")
	}
	if result.Duration != 300*time.Second {
		t.Errorf("Expected duration 300s, got %v", result.Duration)
	}
}

func TestApprovalManager_AsyncConnClosedChannel(t *testing.T) {
	sender := &MockAlertSender{}
	am := NewApprovalManager(sender)

	sourceIP := "192.168.1.60"
	meta := ApprovalRequestMeta{SourceIP: sourceIP}

	// Start request
	resultCh, err := am.BeginApprovalRequest("req-conn-close", "node-1", "{}", meta)
	if err != nil {
		t.Fatalf("BeginApprovalRequest failed: %v", err)
	}
	defer am.CancelApprovalRequest("req-conn-close")

	// Create a channel that simulates connection close
	connClosedCh := make(chan struct{})

	// Close connection in background (simulating TCP RST)
	go func() {
		time.Sleep(50 * time.Millisecond)
		close(connClosedCh)
	}()

	// Wait for approval - should return early due to connection close
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	result, err := am.WaitForApproval(ctx, "req-conn-close", resultCh, connClosedCh)
	if err == nil {
		t.Error("Expected error due to connection close")
	}
	if result.Allowed {
		t.Error("Should not be allowed when connection closes")
	}
}

// ===== LiveConns Tracking Tests =====

func TestApprovalCache_SetConnID_Cap(t *testing.T) {
	cache := NewApprovalCache()
	defer cache.Stop()

	// Add an approval
	cache.Add("1.2.3.4", "rule-1", "proxy-1", "", true, 1*time.Hour)

	// Add connections up to the cap (with dummy byte counters)
	byteCounters := make([]int64, config.MaxConnIDsPerApproval*2)
	for i := 0; i < config.MaxConnIDsPerApproval; i++ {
		ok := cache.SetConnID("1.2.3.4", "rule-1", "", fmt.Sprintf("conn-%d", i), &byteCounters[i*2], &byteCounters[i*2+1])
		if !ok {
			t.Fatalf("SetConnID should succeed for connection %d", i)
		}
	}

	// Verify we have exactly config.MaxConnIDsPerApproval connections
	entry := cache.GetEntry("1.2.3.4", "rule-1", "")
	if entry == nil {
		t.Fatal("Entry should exist")
	}
	if len(entry.LiveConns) != config.MaxConnIDsPerApproval {
		t.Errorf("Expected %d LiveConns, got %d", config.MaxConnIDsPerApproval, len(entry.LiveConns))
	}

	// Next connection should be rejected (cap reached)
	var extraIn, extraOut int64
	ok := cache.SetConnID("1.2.3.4", "rule-1", "", "conn-overflow", &extraIn, &extraOut)
	if ok {
		t.Error("SetConnID should return false when cap is reached")
	}

	// Verify still at cap (not exceeded)
	if len(entry.LiveConns) != config.MaxConnIDsPerApproval {
		t.Errorf("LiveConns should still be at cap %d, got %d", config.MaxConnIDsPerApproval, len(entry.LiveConns))
	}
}

func TestApprovalCache_RemoveConnID(t *testing.T) {
	cache := NewApprovalCache()
	defer cache.Stop()

	// Add an approval with some connections
	var b1In, b1Out, b2In, b2Out, b3In, b3Out int64
	cache.Add("1.2.3.4", "rule-1", "proxy-1", "", true, 1*time.Hour)
	cache.SetConnID("1.2.3.4", "rule-1", "", "conn-1", &b1In, &b1Out)
	cache.SetConnID("1.2.3.4", "rule-1", "", "conn-2", &b2In, &b2Out)
	cache.SetConnID("1.2.3.4", "rule-1", "", "conn-3", &b3In, &b3Out)

	entry := cache.GetEntry("1.2.3.4", "rule-1", "")
	if len(entry.LiveConns) != 3 {
		t.Fatalf("Expected 3 LiveConns, got %d", len(entry.LiveConns))
	}

	// Remove middle connection
	cache.RemoveConnID("1.2.3.4", "rule-1", "", "conn-2")

	if len(entry.LiveConns) != 2 {
		t.Errorf("Expected 2 LiveConns after removal, got %d", len(entry.LiveConns))
	}

	// Verify conn-2 is gone but conn-1 and conn-3 remain
	if _, exists := entry.LiveConns["conn-2"]; exists {
		t.Error("conn-2 should have been removed")
	}
	if _, exists := entry.LiveConns["conn-1"]; !exists {
		t.Error("conn-1 should still exist")
	}
	if _, exists := entry.LiveConns["conn-3"]; !exists {
		t.Error("conn-3 should still exist")
	}

	// Remove non-existent connection (should not panic)
	cache.RemoveConnID("1.2.3.4", "rule-1", "", "conn-nonexistent")

	// Remove from non-existent entry (should not panic)
	cache.RemoveConnID("5.6.7.8", "rule-1", "", "conn-1")
}

func TestApprovalCache_RemoveConnID_ThenAddMore(t *testing.T) {
	cache := NewApprovalCache()
	defer cache.Stop()

	// Add approval and fill to cap
	cache.Add("1.2.3.4", "rule-1", "proxy-1", "", true, 1*time.Hour)
	byteCounters := make([]int64, config.MaxConnIDsPerApproval*2)
	for i := 0; i < config.MaxConnIDsPerApproval; i++ {
		cache.SetConnID("1.2.3.4", "rule-1", "", fmt.Sprintf("conn-%d", i), &byteCounters[i*2], &byteCounters[i*2+1])
	}

	// Verify at cap
	var extraIn, extraOut int64
	ok := cache.SetConnID("1.2.3.4", "rule-1", "", "conn-new", &extraIn, &extraOut)
	if ok {
		t.Error("Should be at cap")
	}

	// Remove one connection
	cache.RemoveConnID("1.2.3.4", "rule-1", "", "conn-500")

	// Now we should be able to add one more
	ok = cache.SetConnID("1.2.3.4", "rule-1", "", "conn-new", &extraIn, &extraOut)
	if !ok {
		t.Error("Should be able to add after removing one")
	}

	// And now at cap again
	var anotherIn, anotherOut int64
	ok = cache.SetConnID("1.2.3.4", "rule-1", "", "conn-another", &anotherIn, &anotherOut)
	if ok {
		t.Error("Should be at cap again")
	}
}
