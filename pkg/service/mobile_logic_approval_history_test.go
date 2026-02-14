package service

import (
	"os"
	"path/filepath"
	"testing"

	pb "github.com/ivere27/nitella/pkg/api/local"
)

func TestAppendApprovalHistoryReturnsPersistenceError(t *testing.T) {
	svc := NewMobileLogicService()
	svc.dataDir = "/dev/null/nitella-history-test"

	err := svc.appendApprovalHistory(&pb.ApprovalHistoryEntry{
		RequestId: "req-1",
		NodeId:    "node-1",
	})
	if err == nil {
		t.Fatalf("expected appendApprovalHistory to return persistence error")
	}
	if got := len(svc.approvalHistory); got != 1 {
		t.Fatalf("unexpected in-memory history length: got=%d want=1", got)
	}
}

func TestAppendApprovalHistoryPersistsToDisk(t *testing.T) {
	svc := NewMobileLogicService()
	svc.dataDir = t.TempDir()

	err := svc.appendApprovalHistory(&pb.ApprovalHistoryEntry{
		RequestId: "req-2",
		NodeId:    "node-2",
	})
	if err != nil {
		t.Fatalf("appendApprovalHistory() error = %v", err)
	}

	path := filepath.Join(svc.dataDir, "approvals", "history.json")
	if _, statErr := os.Stat(path); statErr != nil {
		t.Fatalf("expected history file to exist: %v", statErr)
	}
}
