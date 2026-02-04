package node

import (
	"net"
	"sync"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
)

// GlobalRule represents a runtime rule that applies across all proxies
type GlobalRule struct {
	ID        string
	Name      string            // Human-readable description
	SourceIP  string            // IP or CIDR
	Action    common.ActionType // ALLOW or BLOCK
	ExpiresAt time.Time         // Zero means permanent (until restart)
	CreatedAt time.Time
}

// cidrRule holds a GlobalRule with pre-parsed CIDR for efficient matching
type cidrRule struct {
	*GlobalRule
	ipNet *net.IPNet
}

// GlobalRulesStore manages runtime rules that apply across all proxies
type GlobalRulesStore struct {
	mu         sync.RWMutex
	exactRules map[string]*GlobalRule // Keyed by IP for O(1) lookup
	cidrRules  map[string]*cidrRule   // Keyed by ID, pre-parsed CIDR rules
	idToIP     map[string]string      // Maps rule ID to IP for exact rule removal
	stopCh     chan struct{}
}

// NewGlobalRulesStore creates a new global rules store
func NewGlobalRulesStore() *GlobalRulesStore {
	store := &GlobalRulesStore{
		exactRules: make(map[string]*GlobalRule),
		cidrRules:  make(map[string]*cidrRule),
		idToIP:     make(map[string]string),
		stopCh:     make(chan struct{}),
	}
	go store.cleanupLoop()
	return store
}

// Stop stops the cleanup goroutine
func (s *GlobalRulesStore) Stop() {
	close(s.stopCh)
}

// cleanupLoop removes expired rules
func (s *GlobalRulesStore) cleanupLoop() {
	ticker := time.NewTicker(10 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-s.stopCh:
			return
		case <-ticker.C:
			s.mu.Lock()
			now := time.Now()
			// Cleanup exact rules (keyed by IP)
			for ip, rule := range s.exactRules {
				if !rule.ExpiresAt.IsZero() && now.After(rule.ExpiresAt) {
					delete(s.exactRules, ip)
					delete(s.idToIP, rule.ID)
				}
			}
			// Cleanup CIDR rules (keyed by ID)
			for id, cr := range s.cidrRules {
				if !cr.ExpiresAt.IsZero() && now.After(cr.ExpiresAt) {
					delete(s.cidrRules, id)
				}
			}
			s.mu.Unlock()
		}
	}
}

// BlockIP adds a block rule for an IP or CIDR
func (s *GlobalRulesStore) BlockIP(ip string, duration time.Duration) string {
	s.mu.Lock()
	defer s.mu.Unlock()

	id := "global-block-" + ip
	var expiresAt time.Time
	if duration > 0 {
		expiresAt = time.Now().Add(duration)
	}

	rule := &GlobalRule{
		ID:        id,
		Name:      "Block: " + ip,
		SourceIP:  ip,
		Action:    common.ActionType_ACTION_TYPE_BLOCK,
		ExpiresAt: expiresAt,
		CreatedAt: time.Now(),
	}

	// Check if CIDR or exact IP
	if _, ipNet, err := net.ParseCIDR(ip); err == nil {
		s.cidrRules[id] = &cidrRule{GlobalRule: rule, ipNet: ipNet}
	} else {
		s.exactRules[ip] = rule  // Key by IP for O(1) lookup
		s.idToIP[id] = ip        // Track ID->IP for removal
	}
	return id
}

// AllowIP adds an allow rule for an IP or CIDR
func (s *GlobalRulesStore) AllowIP(ip string, duration time.Duration) string {
	s.mu.Lock()
	defer s.mu.Unlock()

	id := "global-allow-" + ip
	var expiresAt time.Time
	if duration > 0 {
		expiresAt = time.Now().Add(duration)
	}

	rule := &GlobalRule{
		ID:        id,
		Name:      "Allow: " + ip,
		SourceIP:  ip,
		Action:    common.ActionType_ACTION_TYPE_ALLOW,
		ExpiresAt: expiresAt,
		CreatedAt: time.Now(),
	}

	// Check if CIDR or exact IP
	if _, ipNet, err := net.ParseCIDR(ip); err == nil {
		s.cidrRules[id] = &cidrRule{GlobalRule: rule, ipNet: ipNet}
	} else {
		s.exactRules[ip] = rule  // Key by IP for O(1) lookup
		s.idToIP[id] = ip        // Track ID->IP for removal
	}
	return id
}

// Remove removes a global rule by ID
func (s *GlobalRulesStore) Remove(id string) bool {
	s.mu.Lock()
	defer s.mu.Unlock()

	// Check if it's an exact rule (lookup IP via idToIP)
	if ip, ok := s.idToIP[id]; ok {
		delete(s.exactRules, ip)
		delete(s.idToIP, id)
		return true
	}
	// Check if it's a CIDR rule
	if _, ok := s.cidrRules[id]; ok {
		delete(s.cidrRules, id)
		return true
	}
	return false
}

// Check evaluates global rules for an IP.
// Returns (matched, action). If matched is false, no global rule applies.
// Priority: BLOCK rules take precedence over ALLOW rules.
func (s *GlobalRulesStore) Check(sourceIP string) (bool, common.ActionType) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	now := time.Now()

	// O(1) exact match first
	if rule, ok := s.exactRules[sourceIP]; ok {
		if rule.ExpiresAt.IsZero() || now.Before(rule.ExpiresAt) {
			return true, rule.Action
		}
	}

	// Check CIDR rules (pre-parsed, no ParseCIDR per check)
	parsedIP := net.ParseIP(sourceIP)
	if parsedIP == nil {
		return false, common.ActionType_ACTION_TYPE_UNSPECIFIED
	}

	var matchedAllow bool
	for _, cr := range s.cidrRules {
		// Skip expired rules
		if !cr.ExpiresAt.IsZero() && now.After(cr.ExpiresAt) {
			continue
		}

		if cr.ipNet.Contains(parsedIP) {
			// BLOCK takes precedence - return immediately
			if cr.Action == common.ActionType_ACTION_TYPE_BLOCK {
				return true, common.ActionType_ACTION_TYPE_BLOCK
			}
			matchedAllow = true
		}
	}

	if matchedAllow {
		return true, common.ActionType_ACTION_TYPE_ALLOW
	}

	return false, common.ActionType_ACTION_TYPE_UNSPECIFIED
}

// List returns all active global rules
func (s *GlobalRulesStore) List() []*GlobalRule {
	s.mu.RLock()
	defer s.mu.RUnlock()

	now := time.Now()
	result := make([]*GlobalRule, 0, len(s.exactRules)+len(s.cidrRules))
	for _, rule := range s.exactRules {
		if rule.ExpiresAt.IsZero() || now.Before(rule.ExpiresAt) {
			result = append(result, rule)
		}
	}
	for _, cr := range s.cidrRules {
		if cr.ExpiresAt.IsZero() || now.Before(cr.ExpiresAt) {
			result = append(result, cr.GlobalRule)
		}
	}
	return result
}
