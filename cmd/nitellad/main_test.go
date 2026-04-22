package main

import (
	"reflect"
	"testing"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/proxy"
)

func TestActionTypeFromString(t *testing.T) {
	tests := []struct {
		name string
		want common.ActionType
		ok   bool
	}{
		{name: "", want: common.ActionType_ACTION_TYPE_ALLOW, ok: true},
		{name: "allow", want: common.ActionType_ACTION_TYPE_ALLOW, ok: true},
		{name: "block", want: common.ActionType_ACTION_TYPE_BLOCK, ok: true},
		{name: "mock", want: common.ActionType_ACTION_TYPE_MOCK, ok: true},
		{name: "approval", want: common.ActionType_ACTION_TYPE_REQUIRE_APPROVAL, ok: true},
		{name: "require_approval", want: common.ActionType_ACTION_TYPE_REQUIRE_APPROVAL, ok: true},
		{name: "bad", want: common.ActionType_ACTION_TYPE_UNSPECIFIED, ok: false},
	}

	for _, tt := range tests {
		got, ok := actionTypeFromString(tt.name)
		if got != tt.want || ok != tt.ok {
			t.Fatalf("actionTypeFromString(%q) = (%v, %v), want (%v, %v)", tt.name, got, ok, tt.want, tt.ok)
		}
	}
}

func TestBuildFallbackConfigFromFlags(t *testing.T) {
	action, mock, err := buildFallbackConfigFromFlags("mock", "ssh-tarpit", map[string]bool{
		"fallback-action": true,
		"fallback-mock":   true,
	})
	if err != nil {
		t.Fatalf("buildFallbackConfigFromFlags failed: %v", err)
	}
	if action != common.FallbackAction_FALLBACK_ACTION_MOCK {
		t.Fatalf("action = %v", action)
	}
	if mock != common.MockPreset_MOCK_PRESET_SSH_TARPIT {
		t.Fatalf("mock = %v", mock)
	}
}

func TestBuildFallbackConfigFromFlagsRejectsMockWithoutAction(t *testing.T) {
	_, _, err := buildFallbackConfigFromFlags("", "ssh-tarpit", map[string]bool{
		"fallback-mock": true,
	})
	if err == nil {
		t.Fatal("expected validation error")
	}
}

func TestParseCountryList(t *testing.T) {
	got := parseCountryList(" kr,JP, kr,South Korea, ")
	want := []string{"KR", "JP", "South Korea"}
	if !reflect.DeepEqual(got, want) {
		t.Fatalf("parseCountryList() = %#v, want %#v", got, want)
	}
}

func TestParseCommaList(t *testing.T) {
	got := parseCommaList(" 127.0.0.1,192.168.0.0/16,127.0.0.1, ", nil)
	want := []string{"127.0.0.1", "192.168.0.0/16"}
	if !reflect.DeepEqual(got, want) {
		t.Fatalf("parseCommaList() = %#v, want %#v", got, want)
	}
}

func TestParseSourceIPListExpandsStandaloneAliases(t *testing.T) {
	got := parseSourceIPList("localhost,private,local,127.0.0.1,private")
	want := []string{
		"127.0.0.0/8",
		"::1/128",
		"10.0.0.0/8",
		"172.16.0.0/12",
		"192.168.0.0/16",
		"fc00::/7",
		"169.254.0.0/16",
		"fe80::/10",
		"127.0.0.1",
	}
	if !reflect.DeepEqual(got, want) {
		t.Fatalf("parseSourceIPList() = %#v, want %#v", got, want)
	}
}

func TestStartupCountryRule(t *testing.T) {
	rule := startupCountryRule(common.ActionType_ACTION_TYPE_ALLOW, "KR")
	if rule.Action != common.ActionType_ACTION_TYPE_ALLOW {
		t.Fatalf("Action = %v", rule.Action)
	}
	if rule.Priority <= -1000 {
		t.Fatalf("Priority = %d, want above default rule", rule.Priority)
	}
	if len(rule.Conditions) != 1 {
		t.Fatalf("Conditions = %d, want 1", len(rule.Conditions))
	}
	cond := rule.Conditions[0]
	if cond.Type != common.ConditionType_CONDITION_TYPE_GEO_COUNTRY || cond.Op != common.Operator_OPERATOR_EQ || cond.Value != "KR" {
		t.Fatalf("Condition = %#v", cond)
	}
}

func TestStartupSourceIPRule(t *testing.T) {
	exact := startupSourceIPRule(common.ActionType_ACTION_TYPE_ALLOW, "127.0.0.1")
	if exact.Conditions[0].Type != common.ConditionType_CONDITION_TYPE_SOURCE_IP || exact.Conditions[0].Op != common.Operator_OPERATOR_EQ {
		t.Fatalf("exact IP condition = %#v", exact.Conditions[0])
	}

	cidr := startupSourceIPRule(common.ActionType_ACTION_TYPE_BLOCK, "192.168.0.0/16")
	if cidr.Action != common.ActionType_ACTION_TYPE_BLOCK {
		t.Fatalf("Action = %v", cidr.Action)
	}
	if cidr.Conditions[0].Type != common.ConditionType_CONDITION_TYPE_SOURCE_IP || cidr.Conditions[0].Op != common.Operator_OPERATOR_CIDR {
		t.Fatalf("CIDR condition = %#v", cidr.Conditions[0])
	}
}

func TestBuildRateLimitConfigFromFlags(t *testing.T) {
	got, err := buildRateLimitConfigFromFlags(rateLimitFlagValues{
		maxConnections:           3,
		intervalSeconds:          60,
		autoBlock:                true,
		blockDurationSeconds:     1800,
		countOnlyFailures:        true,
		failureDurationThreshold: 20,
	}, map[string]bool{
		"rate-limit-max-connections":     true,
		"rate-limit-count-only-failures": true,
		"rate-limit-failure-threshold":   true,
	})
	if err != nil {
		t.Fatalf("buildRateLimitConfigFromFlags failed: %v", err)
	}
	if got.MaxConnections != 3 ||
		got.IntervalSeconds != 60 ||
		!got.AutoBlock ||
		got.BlockDurationSeconds != 1800 ||
		!got.CountOnlyFailures ||
		got.FailureDurationThreshold != 20 {
		t.Fatalf("unexpected rate limit config: %+v", got)
	}
}

func TestBuildRateLimitConfigFromFlagsRejectsThresholdWithoutFailureOnlyMode(t *testing.T) {
	_, err := buildRateLimitConfigFromFlags(rateLimitFlagValues{
		maxConnections:           3,
		intervalSeconds:          60,
		autoBlock:                true,
		blockDurationSeconds:     600,
		failureDurationThreshold: 20,
	}, map[string]bool{
		"rate-limit-max-connections":   true,
		"rate-limit-failure-threshold": true,
	})
	if err == nil {
		t.Fatal("expected validation error")
	}
}

func TestDefaultStartupRuleCarriesRateLimit(t *testing.T) {
	rl := &pb.RateLimitConfig{MaxConnections: 3}
	rule := defaultStartupRule("require_approval", "", rl)
	if rule.Action != common.ActionType_ACTION_TYPE_REQUIRE_APPROVAL {
		t.Fatalf("Action = %v", rule.Action)
	}
	if rule.RateLimit != rl {
		t.Fatalf("RateLimit not preserved: %+v", rule.RateLimit)
	}
}
