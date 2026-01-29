package config

import (
	"fmt"
	"net"
	"os"
	"regexp"
	"strings"

	"gopkg.in/yaml.v3"
)

// LoadYAMLConfig loads a YAML configuration file
func LoadYAMLConfig(path string) (*YAMLConfig, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("failed to read config file: %w", err)
	}

	var config YAMLConfig
	if err := yaml.Unmarshal(data, &config); err != nil {
		return nil, fmt.Errorf("failed to parse YAML config: %w", err)
	}

	return &config, nil
}

// RuleExpression represents a parsed rule expression
type RuleExpression struct {
	Raw      string
	Matchers []Matcher
	Operator string // "&&", "||", or "" for single matcher
}

// Matcher represents a single condition like GeoCountry(`KR`)
type Matcher struct {
	Type    string   // GeoCountry, ClientIP, TLSCA, etc.
	Values  []string // The values inside backticks
	Negated bool     // If prefixed with !
}

// MatcherType constants
const (
	MatcherGeoCountry     = "GeoCountry"
	MatcherGeoCity        = "GeoCity"
	MatcherGeoISP         = "GeoISP"
	MatcherClientIP       = "ClientIP"
	MatcherHostSNI        = "HostSNI"
	MatcherTLSCA          = "TLSCA"
	MatcherTLSCN          = "TLSCN"
	MatcherTLSSAN         = "TLSSAN"
	MatcherTLSOU          = "TLSOU"
	MatcherTLSFingerprint = "TLSFingerprint"
	MatcherTLSSerial      = "TLSSerial"
	MatcherTLSValid       = "TLSValid"
)

// matcherRegex matches patterns like GeoCountry(`KR`) or !ClientIP(`10.0.0.0/8`)
var matcherRegex = regexp.MustCompile(`(!?)(\w+)\(([^)]*)\)`)

// ParseRuleExpression parses a Traefik-style rule expression
func ParseRuleExpression(rule string) (*RuleExpression, error) {
	expr := &RuleExpression{Raw: rule}

	// Determine operator
	if strings.Contains(rule, "||") {
		expr.Operator = "||"
	} else if strings.Contains(rule, "&&") {
		expr.Operator = "&&"
	}

	// Find all matchers
	matches := matcherRegex.FindAllStringSubmatch(rule, -1)
	if len(matches) == 0 {
		return nil, fmt.Errorf("no valid matchers found in rule: %s", rule)
	}

	for _, match := range matches {
		if len(match) < 4 {
			continue
		}

		negated := match[1] == "!"
		matcherType := match[2]
		valuesStr := match[3]

		// Parse values (can be comma-separated for multi-value matchers)
		var values []string
		if valuesStr != "" {
			// Remove backticks and split by comma
			valuesStr = strings.ReplaceAll(valuesStr, "`", "")
			for _, v := range strings.Split(valuesStr, ",") {
				v = strings.TrimSpace(v)
				if v != "" {
					values = append(values, v)
				}
			}
		}

		expr.Matchers = append(expr.Matchers, Matcher{
			Type:    matcherType,
			Values:  values,
			Negated: negated,
		})
	}

	return expr, nil
}

// Evaluate evaluates the rule expression against connection context
func (e *RuleExpression) Evaluate(ctx *ConnectionContext) bool {
	if len(e.Matchers) == 0 {
		return false
	}

	results := make([]bool, len(e.Matchers))
	for i, m := range e.Matchers {
		result := m.Evaluate(ctx)
		if m.Negated {
			result = !result
		}
		results[i] = result
	}

	// Combine results based on operator
	switch e.Operator {
	case "||":
		for _, r := range results {
			if r {
				return true
			}
		}
		return false
	case "&&":
		for _, r := range results {
			if !r {
				return false
			}
		}
		return true
	default:
		// Single matcher
		return results[0]
	}
}

// Evaluate evaluates a single matcher against connection context
func (m *Matcher) Evaluate(ctx *ConnectionContext) bool {
	switch m.Type {
	case MatcherGeoCountry:
		return containsIgnoreCase(m.Values, ctx.GeoCountry)
	case MatcherGeoCity:
		return containsIgnoreCase(m.Values, ctx.GeoCity)
	case MatcherGeoISP:
		return containsAnyIgnoreCase(m.Values, ctx.GeoISP)
	case MatcherClientIP:
		return matchCIDR(m.Values, ctx.SourceIP)
	case MatcherHostSNI:
		return containsIgnoreCase(m.Values, ctx.SNI)
	case MatcherTLSCA:
		return containsIgnoreCase(m.Values, ctx.TLSIssuer)
	case MatcherTLSCN:
		return containsIgnoreCase(m.Values, ctx.TLSCN)
	case MatcherTLSSAN:
		return containsAny(m.Values, ctx.TLSSAN)
	case MatcherTLSOU:
		return containsIgnoreCase(m.Values, ctx.TLSOU)
	case MatcherTLSFingerprint:
		return containsIgnoreCase(m.Values, ctx.TLSFingerprint)
	case MatcherTLSSerial:
		return containsIgnoreCase(m.Values, ctx.TLSSerial)
	case MatcherTLSValid:
		return ctx.TLSValid
	default:
		return false
	}
}

// ConnectionContext holds all connection attributes for rule evaluation
type ConnectionContext struct {
	// Network
	SourceIP string
	SNI      string

	// GeoIP
	GeoCountry string
	GeoCity    string
	GeoISP     string

	// TLS Certificate
	TLSValid       bool
	TLSIssuer      string
	TLSCN          string
	TLSSAN         []string
	TLSOU          string
	TLSFingerprint string
	TLSSerial      string
}

// Helper functions
func containsIgnoreCase(slice []string, val string) bool {
	valLower := strings.ToLower(val)
	for _, s := range slice {
		if strings.ToLower(s) == valLower {
			return true
		}
	}
	return false
}

func containsAnyIgnoreCase(patterns []string, val string) bool {
	valLower := strings.ToLower(val)
	for _, p := range patterns {
		if strings.Contains(valLower, strings.ToLower(p)) {
			return true
		}
	}
	return false
}

func containsAny(slice []string, vals []string) bool {
	for _, s := range slice {
		for _, v := range vals {
			if strings.EqualFold(s, v) {
				return true
			}
		}
	}
	return false
}

func matchCIDR(cidrs []string, ip string) bool {
	parsedIP := net.ParseIP(ip)
	if parsedIP == nil {
		return false
	}

	for _, cidr := range cidrs {
		if strings.Contains(cidr, "/") {
			// CIDR notation
			_, network, err := net.ParseCIDR(cidr)
			if err != nil {
				continue
			}
			if network.Contains(parsedIP) {
				return true
			}
		} else {
			// Exact IP match
			cidrIP := net.ParseIP(cidr)
			if cidrIP != nil && cidrIP.Equal(parsedIP) {
				return true
			}
		}
	}
	return false
}
