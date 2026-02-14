package service

import (
	"context"
	"strings"
	"testing"

	pb "github.com/ivere27/nitella/pkg/api/local"
	"github.com/ivere27/nitella/pkg/identity"
)

func TestGetProxiesSnapshotIncludesNodes(t *testing.T) {
	svc := NewMobileLogicService()
	svc.identity = &identity.Identity{}
	svc.nodes["node-1"] = &pb.NodeInfo{
		NodeId: "node-1",
		Online: false,
	}
	svc.nodes["node-2"] = &pb.NodeInfo{
		NodeId: "node-2",
		Online: false,
	}

	resp, err := svc.GetProxiesSnapshot(context.Background(), &pb.GetProxiesSnapshotRequest{})
	if err != nil {
		t.Fatalf("GetProxiesSnapshot() error = %v", err)
	}
	if got := len(resp.GetNodeSnapshots()); got != 2 {
		t.Fatalf("unexpected node_snapshots length: got=%d want=2", got)
	}
	if resp.GetTotalNodes() != 2 {
		t.Fatalf("unexpected total_nodes: got=%d want=2", resp.GetTotalNodes())
	}
	if resp.GetTotalProxies() != 0 {
		t.Fatalf("unexpected total_proxies: got=%d want=0", resp.GetTotalProxies())
	}
}

func TestGetProxiesSnapshotAppliesNodeIdFilter(t *testing.T) {
	svc := NewMobileLogicService()
	svc.identity = &identity.Identity{}
	svc.nodes["node-1"] = &pb.NodeInfo{
		NodeId: "node-1",
		Online: false,
	}
	svc.nodes["node-2"] = &pb.NodeInfo{
		NodeId: "node-2",
		Online: false,
	}

	resp, err := svc.GetProxiesSnapshot(context.Background(), &pb.GetProxiesSnapshotRequest{
		NodeId: "node-2",
	})
	if err != nil {
		t.Fatalf("GetProxiesSnapshot(node_id) error = %v", err)
	}
	if got := len(resp.GetNodeSnapshots()); got != 1 {
		t.Fatalf("unexpected node_snapshots length: got=%d want=1", got)
	}
	if resp.GetNodeSnapshots()[0].GetNode().GetNodeId() != "node-2" {
		t.Fatalf("unexpected node id: got=%q want=node-2", resp.GetNodeSnapshots()[0].GetNode().GetNodeId())
	}
}

func TestListProxiesReturnsErrorWhenHubNodeOfflineWithoutRoute(t *testing.T) {
	svc := NewMobileLogicService()
	svc.identity = &identity.Identity{}
	svc.nodes["node-1"] = &pb.NodeInfo{
		NodeId: "node-1",
		Online: false,
	}

	_, err := svc.ListProxies(context.Background(), &pb.ListProxiesRequest{NodeId: "node-1"})
	if err == nil {
		t.Fatalf("expected ListProxies() to fail for offline hub node")
	}
	if !strings.Contains(err.Error(), "offline") {
		t.Fatalf("unexpected error: %v", err)
	}
}
