package service

import (
	"testing"

	"github.com/ivere27/nitella/pkg/api/common"
)

func TestNormalizeQuickSourceIP(t *testing.T) {
	tests := []struct {
		name      string
		value     string
		toCIDR24  bool
		want      string
		shouldErr bool
	}{
		{
			name:     "keep value when cidr24 disabled",
			value:    "203.0.113.9",
			toCIDR24: false,
			want:     "203.0.113.9",
		},
		{
			name:     "normalize ipv4 to cidr24",
			value:    "203.0.113.9",
			toCIDR24: true,
			want:     "203.0.113.0/24",
		},
		{
			name:     "normalize ipv4 cidr to cidr24",
			value:    "203.0.113.128/25",
			toCIDR24: true,
			want:     "203.0.113.0/24",
		},
		{
			name:      "reject ipv6 with cidr24",
			value:     "2001:db8::1",
			toCIDR24:  true,
			shouldErr: true,
		},
		{
			name:      "reject invalid input",
			value:     "not-an-ip",
			toCIDR24:  true,
			shouldErr: true,
		},
	}

	for _, tc := range tests {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			got, err := normalizeQuickSourceIP(tc.value, tc.toCIDR24)
			if tc.shouldErr {
				if err == nil {
					t.Fatalf("expected error, got value %q", got)
				}
				return
			}
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if got != tc.want {
				t.Fatalf("expected %q, got %q", tc.want, got)
			}
		})
	}
}

func TestQuickSourceIPOperator(t *testing.T) {
	if got := quickSourceIPOperator("203.0.113.1"); got != common.Operator_OPERATOR_EQ {
		t.Fatalf("expected EQ for IP input, got %v", got)
	}
	if got := quickSourceIPOperator("203.0.113.0/24"); got != common.Operator_OPERATOR_CIDR {
		t.Fatalf("expected CIDR for CIDR input, got %v", got)
	}
}

