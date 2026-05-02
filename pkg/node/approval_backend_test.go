package node

import (
	"testing"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/proxy"
)

func TestEmbeddedListenerResolveBackendOverrideValidatesRuleAllowlist(t *testing.T) {
	listener := NewEmbeddedListener(
		"proxy-1",
		"proxy",
		"127.0.0.1:0",
		"127.0.0.1:9000",
		common.ActionType_ACTION_TYPE_ALLOW,
		common.MockPreset_MOCK_PRESET_UNSPECIFIED,
		"",
		"",
		"",
		pb.ClientAuthType_CLIENT_AUTH_NONE,
		nil,
	)
	listener.SetApprovalBackends([]*common.BackendChoice{
		{Id: "a", Address: "127.0.0.1:9001", Label: "A"},
		{Id: "b", Address: "127.0.0.1:9002", Label: "B"},
	})
	listener.AddRule(&pb.Rule{
		Id:                       "rule-1",
		Priority:                 100,
		Action:                   common.ActionType_ACTION_TYPE_REQUIRE_APPROVAL,
		ApprovalBackendChoiceIds: []string{"a"},
	})
	listener.AddRule(&pb.Rule{
		Id:       "rule-empty",
		Priority: 90,
		Action:   common.ActionType_ACTION_TYPE_REQUIRE_APPROVAL,
	})

	address, ok := listener.ResolveBackendOverride("rule-1", "a")
	if !ok || address != "127.0.0.1:9001" {
		t.Fatalf("valid override resolved to address=%q ok=%v", address, ok)
	}

	if _, ok := listener.ResolveBackendOverride("rule-1", "b"); ok {
		t.Fatalf("override not present in rule allowlist should be rejected")
	}

	if _, ok := listener.ResolveBackendOverride("rule-empty", "a"); ok {
		t.Fatalf("override should be rejected when rule allowlist is empty")
	}

	address, ok = listener.ResolveBackendOverride("rule-1", "")
	if !ok || address != "" {
		t.Fatalf("empty override should be accepted without an address, got address=%q ok=%v", address, ok)
	}
}
