package pairing

import (
	"strings"
	"testing"
)

func TestFormatCSRInfo(t *testing.T) {
	out := FormatCSRInfo([]byte("test-csr"), "node-123")
	if out == "" {
		t.Fatalf("expected non-empty output")
	}
	if !strings.Contains(out, "NODE PAIRING REQUEST") {
		t.Fatalf("missing header in output: %q", out)
	}
	if !strings.Contains(out, "node-123") {
		t.Fatalf("missing node id in output: %q", out)
	}
}
