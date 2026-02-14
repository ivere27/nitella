package service

import (
	"context"
	"strings"
	"testing"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/local"
)

func TestResolveApprovalDecisionRequiresDecision(t *testing.T) {
	svc := NewMobileLogicService()
	resp, err := svc.ResolveApprovalDecision(context.Background(), &pb.ResolveApprovalDecisionRequest{
		RequestId: "req-1",
		Decision:  pb.ApprovalDecision_APPROVAL_DECISION_UNSPECIFIED,
	})
	if err != nil {
		t.Fatalf("ResolveApprovalDecision() error = %v", err)
	}
	if resp.GetSuccess() {
		t.Fatalf("expected failure for unspecified decision")
	}
	if !strings.Contains(resp.GetError(), "decision is required") {
		t.Fatalf("unexpected error: %q", resp.GetError())
	}
}

func TestResolveApprovalDecisionApprovePropagatesValidation(t *testing.T) {
	svc := NewMobileLogicService()
	resp, err := svc.ResolveApprovalDecision(context.Background(), &pb.ResolveApprovalDecisionRequest{
		RequestId: "invalid-format",
		Decision:  pb.ApprovalDecision_APPROVAL_DECISION_APPROVE,
	})
	if err != nil {
		t.Fatalf("ResolveApprovalDecision(approve) error = %v", err)
	}
	if resp.GetSuccess() {
		t.Fatalf("expected failure for invalid request_id")
	}
	if !strings.Contains(resp.GetError(), "approval request not found") {
		t.Fatalf("unexpected error: %q", resp.GetError())
	}
}

func TestResolveApprovalDecisionDenyPropagatesValidation(t *testing.T) {
	svc := NewMobileLogicService()
	resp, err := svc.ResolveApprovalDecision(context.Background(), &pb.ResolveApprovalDecisionRequest{
		RequestId: "invalid-format",
		Decision:  pb.ApprovalDecision_APPROVAL_DECISION_DENY,
	})
	if err != nil {
		t.Fatalf("ResolveApprovalDecision(deny) error = %v", err)
	}
	if resp.GetSuccess() {
		t.Fatalf("expected failure for invalid request_id")
	}
	if !strings.Contains(resp.GetError(), "approval request not found") {
		t.Fatalf("unexpected error: %q", resp.GetError())
	}
}

func TestGetApprovalsSnapshotIncludesHistoryAndNodeFilter(t *testing.T) {
	svc := NewMobileLogicService()
	svc.pendingApprovals["req-1"] = &pb.ApprovalRequest{
		RequestId: "req-1",
		NodeId:    "node-1",
		SourceIp:  "1.2.3.4",
	}
	svc.pendingApprovals["req-2"] = &pb.ApprovalRequest{
		RequestId: "req-2",
		NodeId:    "node-2",
		SourceIp:  "5.6.7.8",
	}
	svc.approvalHistory = []*pb.ApprovalHistoryEntry{
		{RequestId: "req-old-1", NodeId: "node-1"},
		{RequestId: "req-old-2", NodeId: "node-2"},
	}

	resp, err := svc.GetApprovalsSnapshot(context.Background(), &pb.GetApprovalsSnapshotRequest{
		NodeId:         "node-1",
		IncludeHistory: true,
		HistoryLimit:   10,
	})
	if err != nil {
		t.Fatalf("GetApprovalsSnapshot() error = %v", err)
	}
	if got := len(resp.GetPendingRequests()); got != 1 {
		t.Fatalf("unexpected pending request count: got=%d want=1", got)
	}
	if resp.GetPendingTotalCount() != 1 {
		t.Fatalf("unexpected pending_total_count: got=%d want=1", resp.GetPendingTotalCount())
	}
	if resp.GetPendingRequests()[0].GetNodeId() != "node-1" {
		t.Fatalf("unexpected pending node_id: %q", resp.GetPendingRequests()[0].GetNodeId())
	}
	if got := len(resp.GetHistoryEntries()); got != 1 {
		t.Fatalf("unexpected history entry count: got=%d want=1", got)
	}
	if resp.GetHistoryTotalCount() != 1 {
		t.Fatalf("unexpected history_total_count: got=%d want=1", resp.GetHistoryTotalCount())
	}
	if resp.GetHistoryEntries()[0].GetNodeId() != "node-1" {
		t.Fatalf("unexpected history node_id: %q", resp.GetHistoryEntries()[0].GetNodeId())
	}
}

func TestGetApprovalsSnapshotSkipsHistoryWhenExcluded(t *testing.T) {
	svc := NewMobileLogicService()
	svc.pendingApprovals["req-1"] = &pb.ApprovalRequest{
		RequestId: "req-1",
		NodeId:    "node-1",
	}
	svc.approvalHistory = []*pb.ApprovalHistoryEntry{
		{RequestId: "req-old-1", NodeId: "node-1"},
	}

	resp, err := svc.GetApprovalsSnapshot(context.Background(), &pb.GetApprovalsSnapshotRequest{
		IncludeHistory: false,
	})
	if err != nil {
		t.Fatalf("GetApprovalsSnapshot() error = %v", err)
	}
	if got := len(resp.GetPendingRequests()); got != 1 {
		t.Fatalf("unexpected pending request count: got=%d want=1", got)
	}
	if resp.GetPendingTotalCount() != 1 {
		t.Fatalf("unexpected pending_total_count: got=%d want=1", resp.GetPendingTotalCount())
	}
	if len(resp.GetHistoryEntries()) != 0 {
		t.Fatalf("expected history entries to be empty when include_history=false")
	}
	if resp.GetHistoryTotalCount() != 0 {
		t.Fatalf("expected history_total_count=0 when include_history=false, got=%d", resp.GetHistoryTotalCount())
	}
}

func TestProcessIncomingAlertSetsTimestampFromAlert(t *testing.T) {
	svc := NewMobileLogicService()
	ts := time.Now().Add(-90 * time.Second).Unix()

	svc.processIncomingAlert(&common.Alert{
		Id:            "req-1",
		NodeId:        "node-1",
		TimestampUnix: ts,
	}, nil)

	req := svc.getPendingApproval("req-1")
	if req == nil {
		t.Fatalf("expected pending approval to be stored")
	}
	if req.GetTimestamp() == nil {
		t.Fatalf("expected timestamp to be set")
	}
	if got := req.GetTimestamp().AsTime().Unix(); got != ts {
		t.Fatalf("unexpected timestamp: got=%d want=%d", got, ts)
	}
}

func TestProcessIncomingAlertSetsTimestampWhenMissingInAlert(t *testing.T) {
	svc := NewMobileLogicService()
	before := time.Now().Add(-2 * time.Second)

	svc.processIncomingAlert(&common.Alert{
		Id:     "req-2",
		NodeId: "node-1",
	}, nil)

	req := svc.getPendingApproval("req-2")
	if req == nil {
		t.Fatalf("expected pending approval to be stored")
	}
	if req.GetTimestamp() == nil {
		t.Fatalf("expected timestamp to be set")
	}
	after := time.Now().Add(2 * time.Second)
	got := req.GetTimestamp().AsTime()
	if got.Before(before) || got.After(after) {
		t.Fatalf("unexpected timestamp range: got=%s before=%s after=%s", got, before, after)
	}
}
