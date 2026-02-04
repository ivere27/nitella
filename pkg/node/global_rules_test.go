package node

import (
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
)

func TestGlobalRules_BlockIP(t *testing.T) {
	store := NewGlobalRulesStore()

	id := store.BlockIP("1.2.3.4", 0)
	if id == "" {
		t.Error("Expected rule ID")
	}

	matched, action := store.Check("1.2.3.4")
	if !matched {
		t.Error("Should match blocked IP")
	}
	if action != common.ActionType_ACTION_TYPE_BLOCK {
		t.Errorf("Expected BLOCK action, got %v", action)
	}

	// Non-blocked IP
	matched, _ = store.Check("5.6.7.8")
	if matched {
		t.Error("Should NOT match non-blocked IP")
	}
}

func TestGlobalRules_AllowIP(t *testing.T) {
	store := NewGlobalRulesStore()

	store.AllowIP("10.0.0.1", 0)

	matched, action := store.Check("10.0.0.1")
	if !matched {
		t.Error("Should match allowed IP")
	}
	if action != common.ActionType_ACTION_TYPE_ALLOW {
		t.Errorf("Expected ALLOW action, got %v", action)
	}
}

func TestGlobalRules_CIDR(t *testing.T) {
	store := NewGlobalRulesStore()

	// Block entire subnet
	store.BlockIP("192.168.1.0/24", 0)

	// IPs in subnet should be blocked
	matched, action := store.Check("192.168.1.50")
	if !matched {
		t.Error("Should match IP in blocked CIDR")
	}
	if action != common.ActionType_ACTION_TYPE_BLOCK {
		t.Errorf("Expected BLOCK action, got %v", action)
	}

	matched, _ = store.Check("192.168.1.255")
	if !matched {
		t.Error("Should match IP in blocked CIDR (255)")
	}

	// IP outside subnet should NOT be blocked
	matched, _ = store.Check("192.168.2.1")
	if matched {
		t.Error("Should NOT match IP outside CIDR")
	}
}

func TestGlobalRules_Expiry(t *testing.T) {
	store := NewGlobalRulesStore()

	// Block with short duration
	store.BlockIP("1.2.3.4", 50*time.Millisecond)

	// Immediately should be blocked
	matched, _ := store.Check("1.2.3.4")
	if !matched {
		t.Error("Should match immediately after adding")
	}

	// Wait for expiry
	time.Sleep(100 * time.Millisecond)

	// Should NOT be blocked (expired)
	matched, _ = store.Check("1.2.3.4")
	if matched {
		t.Error("Should NOT match after expiry")
	}
}

func TestGlobalRules_PermanentRule(t *testing.T) {
	store := NewGlobalRulesStore()

	// Block with 0 duration (permanent)
	store.BlockIP("1.2.3.4", 0)

	// Should be blocked
	matched, _ := store.Check("1.2.3.4")
	if !matched {
		t.Error("Permanent rule should match")
	}

	// Wait a bit - should still be blocked
	time.Sleep(100 * time.Millisecond)

	matched, _ = store.Check("1.2.3.4")
	if !matched {
		t.Error("Permanent rule should still match")
	}
}

func TestGlobalRules_Remove(t *testing.T) {
	store := NewGlobalRulesStore()

	id := store.BlockIP("1.2.3.4", 0)

	// Verify it exists
	matched, _ := store.Check("1.2.3.4")
	if !matched {
		t.Error("Should match before removal")
	}

	// Remove it
	removed := store.Remove(id)
	if !removed {
		t.Error("Remove should return true for existing rule")
	}

	// Verify it's gone
	matched, _ = store.Check("1.2.3.4")
	if matched {
		t.Error("Should NOT match after removal")
	}

	// Try removing non-existent
	removed = store.Remove("non-existent")
	if removed {
		t.Error("Remove should return false for non-existent rule")
	}
}

func TestGlobalRules_List(t *testing.T) {
	store := NewGlobalRulesStore()

	store.BlockIP("1.2.3.4", 1*time.Hour)
	store.AllowIP("5.6.7.8", 1*time.Hour)
	store.BlockIP("10.0.0.0/8", 1*time.Hour)

	rules := store.List()
	if len(rules) != 3 {
		t.Errorf("Expected 3 rules, got %d", len(rules))
	}
}

func TestGlobalRules_MultipleMatchesFirstWins(t *testing.T) {
	store := NewGlobalRulesStore()

	// Add both block and allow for same IP
	// In practice, implementation returns first match (order not guaranteed with map)
	store.BlockIP("1.2.3.4", 0)
	store.AllowIP("1.2.3.4", 0)

	// One of them should match
	matched, _ := store.Check("1.2.3.4")
	if !matched {
		t.Error("At least one rule should match")
	}
}

func TestGlobalRules_ConcurrentAccess(t *testing.T) {
	store := NewGlobalRulesStore()
	var wg sync.WaitGroup
	var ops int64

	// Concurrent writes
	for i := 0; i < 50; i++ {
		wg.Add(1)
		go func(idx int) {
			defer wg.Done()
			ip := "1.2.3." + string(rune('0'+idx%10))
			store.BlockIP(ip, 1*time.Hour)
			atomic.AddInt64(&ops, 1)
		}(i)
	}

	// Concurrent reads
	for i := 0; i < 50; i++ {
		wg.Add(1)
		go func(idx int) {
			defer wg.Done()
			ip := "1.2.3." + string(rune('0'+idx%10))
			store.Check(ip)
			atomic.AddInt64(&ops, 1)
		}(i)
	}

	// Concurrent list
	for i := 0; i < 10; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			store.List()
			atomic.AddInt64(&ops, 1)
		}()
	}

	wg.Wait()

	if ops != 110 {
		t.Errorf("Expected 110 operations, got %d", ops)
	}
}

func TestGlobalRules_IPv6(t *testing.T) {
	store := NewGlobalRulesStore()

	// Block IPv6 address
	store.BlockIP("2001:db8::1", 0)

	matched, action := store.Check("2001:db8::1")
	if !matched {
		t.Error("Should match IPv6 address")
	}
	if action != common.ActionType_ACTION_TYPE_BLOCK {
		t.Error("Expected BLOCK action")
	}

	// Non-matching IPv6
	matched, _ = store.Check("2001:db8::2")
	if matched {
		t.Error("Should NOT match different IPv6")
	}
}

func TestGlobalRules_IPv6CIDR(t *testing.T) {
	store := NewGlobalRulesStore()

	// Block IPv6 CIDR
	store.BlockIP("2001:db8::/32", 0)

	matched, _ := store.Check("2001:db8::1")
	if !matched {
		t.Error("Should match IP in IPv6 CIDR")
	}

	matched, _ = store.Check("2001:db8:1234::5678")
	if !matched {
		t.Error("Should match IP in IPv6 CIDR")
	}

	matched, _ = store.Check("2001:db9::1")
	if matched {
		t.Error("Should NOT match IP outside IPv6 CIDR")
	}
}

func TestGlobalRules_InvalidCIDR(t *testing.T) {
	store := NewGlobalRulesStore()

	// Add invalid CIDR (treated as exact match)
	store.BlockIP("invalid-cidr", 0)

	// Should match exact string (unlikely scenario)
	matched, _ := store.Check("invalid-cidr")
	if !matched {
		t.Error("Should match exact string for invalid CIDR")
	}

	// Should not match valid IP
	matched, _ = store.Check("1.2.3.4")
	if matched {
		t.Error("Invalid CIDR should not match valid IP")
	}
}
