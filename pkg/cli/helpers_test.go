package cli

import (
	"strings"
	"testing"
)

func TestParseDuration(t *testing.T) {
	t.Parallel()

	const defaultVal int64 = 300
	tests := []struct {
		name        string
		input       string
		want        int64
		wantErr     bool
		errContains string
	}{
		{name: "empty uses default", input: "", want: defaultVal},
		{name: "plain seconds", input: "10", want: 10},
		{name: "permanent", input: "-1", want: -1},
		{name: "seconds suffix", input: "10s", want: 10},
		{name: "minutes suffix", input: "10m", want: 600},
		{name: "hours suffix", input: "10h", want: 36000},
		{name: "days suffix", input: "10d", want: 864000},
		{name: "weeks suffix", input: "2w", want: 1209600},
		{name: "years suffix", input: "1y", want: 31536000},
		{name: "upper-case suffix", input: "5H", want: 18000},
		{name: "invalid text", input: "abc", want: defaultVal, wantErr: true, errContains: "invalid duration"},
		{name: "invalid suffix", input: "10mo", want: defaultVal, wantErr: true, errContains: "invalid duration"},
		{name: "decimal unsupported", input: "1.5h", want: defaultVal, wantErr: true, errContains: "invalid duration"},
	}

	for _, tc := range tests {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			got, err := ParseDuration(tc.input, defaultVal)
			if got != tc.want {
				t.Fatalf("ParseDuration(%q) = %d, want %d", tc.input, got, tc.want)
			}
			if tc.wantErr && err == nil {
				t.Fatalf("ParseDuration(%q) error = nil, want error", tc.input)
			}
			if !tc.wantErr && err != nil {
				t.Fatalf("ParseDuration(%q) error = %v, want nil", tc.input, err)
			}
			if tc.wantErr && tc.errContains != "" && err != nil && !strings.Contains(err.Error(), tc.errContains) {
				t.Fatalf("ParseDuration(%q) error = %q, want substring %q", tc.input, err.Error(), tc.errContains)
			}
		})
	}
}
