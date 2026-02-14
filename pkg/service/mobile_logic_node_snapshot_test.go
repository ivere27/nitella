package service

import (
	"context"
	"testing"

	pb "github.com/ivere27/nitella/pkg/api/local"
	"github.com/ivere27/nitella/pkg/identity"
	"google.golang.org/protobuf/types/known/timestamppb"
)

func TestGetNodeDetailSnapshotDefaultIncludesComposedFields(t *testing.T) {
	svc := NewMobileLogicService()
	svc.identity = &identity.Identity{}
	svc.nodes["node-1"] = &pb.NodeInfo{
		NodeId:   "node-1",
		Name:     "Node 1",
		Online:   true,
		LastSeen: timestamppb.Now(),
		Version:  "v1.2.3",
		Metrics: &pb.NodeMetrics{
			ActiveConnections: 7,
			TotalConnections:  99,
			BytesIn:           1000,
			BytesOut:          2000,
			BlockedTotal:      3,
		},
	}

	resp, err := svc.GetNodeDetailSnapshot(context.Background(), &pb.GetNodeDetailSnapshotRequest{
		NodeId: "node-1",
	})
	if err != nil {
		t.Fatalf("GetNodeDetailSnapshot() error = %v", err)
	}
	if resp.GetNode() == nil || resp.GetNode().GetNodeId() != "node-1" {
		t.Fatalf("unexpected node in snapshot: %+v", resp.GetNode())
	}
	if resp.GetRuntimeStatus() == nil {
		t.Fatalf("expected runtime_status in default snapshot")
	}
	if resp.GetRuntimeStatus().GetStatus() != "ONLINE" {
		t.Fatalf("unexpected runtime status: got=%q want=ONLINE", resp.GetRuntimeStatus().GetStatus())
	}
	if resp.GetConnectionStats() == nil {
		t.Fatalf("expected connection_stats in default snapshot")
	}
	if resp.GetConnectionStats().GetActiveConnections() != 7 {
		t.Fatalf("unexpected active_connections: got=%d want=7", resp.GetConnectionStats().GetActiveConnections())
	}
}

func TestGetNodeDetailSnapshotHonorsIncludeFlags(t *testing.T) {
	svc := NewMobileLogicService()
	svc.identity = &identity.Identity{}
	svc.nodes["node-1"] = &pb.NodeInfo{
		NodeId: "node-1",
		Metrics: &pb.NodeMetrics{
			ActiveConnections: 2,
		},
	}

	resp, err := svc.GetNodeDetailSnapshot(context.Background(), &pb.GetNodeDetailSnapshotRequest{
		NodeId:                 "node-1",
		IncludeConnectionStats: true,
	})
	if err != nil {
		t.Fatalf("GetNodeDetailSnapshot(include_connection_stats) error = %v", err)
	}
	if resp.GetNode() == nil {
		t.Fatalf("expected node in snapshot")
	}
	if resp.GetRuntimeStatus() != nil {
		t.Fatalf("runtime_status should be omitted when include_runtime_status=false")
	}
	if got := len(resp.GetProxies()); got != 0 {
		t.Fatalf("expected no proxies; got=%d", got)
	}
	if got := len(resp.GetRules()); got != 0 {
		t.Fatalf("expected no rules; got=%d", got)
	}
	if resp.GetConnectionStats() == nil {
		t.Fatalf("expected connection_stats when include_connection_stats=true")
	}
}

func TestGetNodeDetailSnapshotRequiresNodeID(t *testing.T) {
	svc := NewMobileLogicService()
	svc.identity = &identity.Identity{}

	if _, err := svc.GetNodeDetailSnapshot(context.Background(), &pb.GetNodeDetailSnapshotRequest{}); err == nil {
		t.Fatalf("expected error for missing node_id")
	}
}

func TestGetNodeDetailSnapshotNodeNotFound(t *testing.T) {
	svc := NewMobileLogicService()
	svc.identity = &identity.Identity{}

	if _, err := svc.GetNodeDetailSnapshot(context.Background(), &pb.GetNodeDetailSnapshotRequest{NodeId: "missing-node"}); err == nil {
		t.Fatalf("expected error for missing node")
	}
}
