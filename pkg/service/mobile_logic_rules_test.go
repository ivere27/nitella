package service

import (
	"context"
	"strings"
	"testing"

	pb "github.com/ivere27/nitella/pkg/api/local"
	"github.com/ivere27/nitella/pkg/identity"
)

func TestListRulesReturnsErrorWhenHubNodeOfflineWithoutRoute(t *testing.T) {
	svc := NewMobileLogicService()
	svc.identity = &identity.Identity{}
	svc.nodes["node-1"] = &pb.NodeInfo{
		NodeId: "node-1",
		Online: false,
	}

	_, err := svc.ListRules(context.Background(), &pb.ListRulesRequest{NodeId: "node-1"})
	if err == nil {
		t.Fatalf("expected ListRules() to fail for offline hub node")
	}
	if !strings.Contains(err.Error(), "offline") {
		t.Fatalf("unexpected error: %v", err)
	}
}
