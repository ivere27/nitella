package node

import (
	"crypto/sha256"
	"crypto/tls"
	"encoding/hex"
	"fmt"
	"net"
	"regexp"
	"strings"
	"sync"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pbCommon "github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/proxy"
)

// regexCache stores compiled regex patterns to prevent ReDoS attacks
// and improve performance by avoiding recompilation on every match
var (
	regexCache   = make(map[string]*regexp.Regexp)
	regexCacheMu sync.RWMutex
	// MaxRegexLength limits the size of regex patterns to prevent DoS
	MaxRegexLength = 256
	// MaxRegexCacheSize limits the cache size to prevent memory leak
	MaxRegexCacheSize = 1000
)

// getCompiledRegex returns a cached compiled regex, or compiles and caches it
// Returns nil if the regex is invalid or too long
func getCompiledRegex(pattern string) *regexp.Regexp {
	if len(pattern) > MaxRegexLength {
		return nil // Pattern too long, reject
	}

	regexCacheMu.RLock()
	re, ok := regexCache[pattern]
	regexCacheMu.RUnlock()
	if ok {
		return re
	}

	// Compile with timeout protection - use POSIX for linear time guarantee
	regexCacheMu.Lock()
	defer regexCacheMu.Unlock()

	// Double-check after acquiring write lock
	if re, ok = regexCache[pattern]; ok {
		return re
	}

	// Evict old entries if cache is too large (simple LRU-like behavior)
	if len(regexCache) >= MaxRegexCacheSize {
		// Clear half the cache to avoid frequent evictions
		count := 0
		for k := range regexCache {
			delete(regexCache, k)
			count++
			if count >= MaxRegexCacheSize/2 {
				break
			}
		}
	}

	// Use CompilePOSIX for linear time complexity (prevents catastrophic backtracking)
	compiled, err := regexp.CompilePOSIX(pattern)
	if err != nil {
		// Try standard compile as fallback (some patterns need it)
		compiled, err = regexp.Compile(pattern)
		if err != nil {
			regexCache[pattern] = nil // Cache the failure
			return nil
		}
	}
	regexCache[pattern] = compiled
	return compiled
}

// MatchRule checks if a connection matches the rule's conditions.
// It returns true if ALL conditions match (AND logic).
func MatchRule(rule *pb.Rule, conn net.Conn, geo *pbCommon.GeoInfo) bool {
	if !rule.Enabled {
		return false
	}

	// If no conditions, it matches everything (use carefully)
	if len(rule.Conditions) == 0 {
		return true
	}

	for _, cond := range rule.Conditions {
		if !matchCondition(cond, conn, geo) {
			return false
		}
	}

	return true
}

func matchCondition(cond *pb.Condition, conn net.Conn, geo *pbCommon.GeoInfo) bool {
	matched := false

	switch cond.Type {
	case common.ConditionType_CONDITION_TYPE_SOURCE_IP:
		host, _, err := net.SplitHostPort(conn.RemoteAddr().String())
		if err != nil {
			host = conn.RemoteAddr().String() // Fallback
		}
		matched = matchString(cond.Op, cond.Value, host)

	case common.ConditionType_CONDITION_TYPE_GEO_COUNTRY:
		if geo == nil {
			return false
		}
		matched = matchString(cond.Op, cond.Value, geo.Country)

	case common.ConditionType_CONDITION_TYPE_GEO_CITY:
		if geo == nil {
			return false
		}
		matched = matchString(cond.Op, cond.Value, geo.City)

	case common.ConditionType_CONDITION_TYPE_GEO_ISP:
		if geo == nil {
			return false
		}
		matched = matchString(cond.Op, cond.Value, geo.Isp)

	case common.ConditionType_CONDITION_TYPE_TIME_RANGE:
		// Format: "HH:MM-HH:MM" (24h)
		matched = matchTimeRange(cond.Value)

	case common.ConditionType_CONDITION_TYPE_TLS_FINGERPRINT:
		cs := getTLSState(conn)
		if cs == nil || len(cs.PeerCertificates) == 0 {
			return false
		}
		// SHA256 Fingerprint of Leaf Cert
		hash := sha256.Sum256(cs.PeerCertificates[0].Raw)
		fp := hex.EncodeToString(hash[:])
		matched = matchString(cond.Op, cond.Value, fp)

	case common.ConditionType_CONDITION_TYPE_TLS_CN:
		cs := getTLSState(conn)
		if cs == nil || len(cs.PeerCertificates) == 0 {
			return false
		}
		matched = matchString(cond.Op, cond.Value, cs.PeerCertificates[0].Subject.CommonName)

	case common.ConditionType_CONDITION_TYPE_TLS_SERIAL:
		cs := getTLSState(conn)
		if cs == nil || len(cs.PeerCertificates) == 0 {
			return false
		}
		serial := cs.PeerCertificates[0].SerialNumber.String()
		matched = matchString(cond.Op, cond.Value, serial)

	case common.ConditionType_CONDITION_TYPE_TLS_PRESENT:
		cs := getTLSState(conn)
		hasCert := cs != nil && len(cs.PeerCertificates) > 0
		if cond.Value == "false" {
			matched = !hasCert
		} else {
			matched = hasCert
		}

	case common.ConditionType_CONDITION_TYPE_TLS_CA:
		cs := getTLSState(conn)
		if cs == nil || len(cs.PeerCertificates) == 0 {
			return false
		}
		// Match against issuer CommonName
		issuerCN := cs.PeerCertificates[0].Issuer.CommonName
		matched = matchString(cond.Op, cond.Value, issuerCN)

	case common.ConditionType_CONDITION_TYPE_TLS_SAN:
		cs := getTLSState(conn)
		if cs == nil || len(cs.PeerCertificates) == 0 {
			return false
		}
		cert := cs.PeerCertificates[0]
		// Match against any SAN (DNS, Email, IP)
		for _, dns := range cert.DNSNames {
			if matchString(cond.Op, cond.Value, dns) {
				matched = true
				break
			}
		}
		if !matched {
			for _, email := range cert.EmailAddresses {
				if matchString(cond.Op, cond.Value, email) {
					matched = true
					break
				}
			}
		}
		if !matched {
			for _, ip := range cert.IPAddresses {
				if matchString(cond.Op, cond.Value, ip.String()) {
					matched = true
					break
				}
			}
		}

	case common.ConditionType_CONDITION_TYPE_TLS_OU:
		cs := getTLSState(conn)
		if cs == nil || len(cs.PeerCertificates) == 0 {
			return false
		}
		// Match against any Organizational Unit
		for _, ou := range cs.PeerCertificates[0].Subject.OrganizationalUnit {
			if matchString(cond.Op, cond.Value, ou) {
				matched = true
				break
			}
		}

	default:
		// Unsupported condition type
		return false
	}

	if cond.Negate {
		return !matched
	}
	return matched
}

// matchTimeRange checks if current time falls within "HH:MM-HH:MM" range
func matchTimeRange(value string) bool {
	parts := strings.Split(value, "-")
	if len(parts) != 2 {
		return false
	}

	start, err1 := parseTime(parts[0])
	end, err2 := parseTime(parts[1])
	if err1 != nil || err2 != nil {
		return false
	}

	now := time.Now()
	current := now.Hour()*60 + now.Minute()

	if start <= end {
		// Normal range: e.g., 09:00-17:00
		return current >= start && current <= end
	}
	// Overnight range: e.g., 22:00-06:00
	return current >= start || current <= end
}

// parseTime parses "HH:MM" to minutes since midnight
func parseTime(s string) (int, error) {
	s = strings.TrimSpace(s)
	parts := strings.Split(s, ":")
	if len(parts) != 2 {
		return 0, fmt.Errorf("invalid time format: %s", s)
	}
	h := parseIntSafe(parts[0])
	m := parseIntSafe(parts[1])
	if h < 0 || h > 23 || m < 0 || m > 59 {
		return 0, fmt.Errorf("time out of range: %s", s)
	}
	return h*60 + m, nil
}

func parseIntSafe(s string) int {
	val := 0
	for _, c := range s {
		if c >= '0' && c <= '9' {
			val = val*10 + int(c-'0')
		}
	}
	return val
}

func matchString(op common.Operator, targetValue, actualValue string) bool {
	switch op {
	case common.Operator_OPERATOR_EQ:
		return targetValue == actualValue

	case common.Operator_OPERATOR_CONTAINS:
		return strings.Contains(actualValue, targetValue)

	case common.Operator_OPERATOR_REGEX:
		// Use cached compiled regex with timeout protection
		re := getCompiledRegex(targetValue)
		if re == nil {
			return false // Invalid or too long regex
		}

		// Add timeout protection for matching
		done := make(chan bool, 1)
		go func() {
			done <- re.MatchString(actualValue)
		}()

		select {
		case result := <-done:
			return result
		case <-time.After(100 * time.Millisecond):
			// Regex match took too long - potential ReDoS
			return false
		}

	case common.Operator_OPERATOR_CIDR:
		_, ipNet, err := net.ParseCIDR(targetValue)
		if err != nil {
			return false
		}
		ip := net.ParseIP(actualValue)
		return ipNet.Contains(ip)

	default:
		return false
	}
}

// getTLSState retrieves the TLS state from a connection, ensuring handshake is complete
func getTLSState(conn net.Conn) *tls.ConnectionState {
	if tc, ok := conn.(*tls.Conn); ok {
		// SECURITY FIX: Ensure TLS handshake is complete before accessing state
		tc.SetDeadline(time.Now().Add(5 * time.Second))
		if err := tc.Handshake(); err != nil {
			return nil // Handshake failed, treat as no TLS
		}
		tc.SetDeadline(time.Time{}) // Clear deadline

		state := tc.ConnectionState()
		return &state
	}
	return nil
}
