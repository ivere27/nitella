package service

import (
	"context"
	"log"
	"os"
	"path/filepath"

	pb "github.com/ivere27/nitella/pkg/api/local"
	"google.golang.org/protobuf/encoding/protojson"
	"google.golang.org/protobuf/proto"
)

const maxApprovalHistoryEntries = 1000
const defaultApprovalHistoryLimit = 100

func cloneApprovalHistoryEntry(entry *pb.ApprovalHistoryEntry) *pb.ApprovalHistoryEntry {
	if entry == nil {
		return nil
	}
	return proto.Clone(entry).(*pb.ApprovalHistoryEntry)
}

func (s *MobileLogicService) approvalHistoryPath() string {
	return filepath.Join(s.dataDir, "approvals", "history.json")
}

func (s *MobileLogicService) loadApprovalHistory() error {
	if s.dataDir == "" {
		return nil
	}

	path := s.approvalHistoryPath()
	data, err := os.ReadFile(path)
	if err != nil {
		if os.IsNotExist(err) {
			return nil
		}
		return err
	}

	var stored pb.ListApprovalHistoryResponse
	if err := protojson.Unmarshal(data, &stored); err != nil {
		return err
	}

	s.approvalHistoryMu.Lock()
	defer s.approvalHistoryMu.Unlock()

	s.approvalHistory = stored.Entries
	if len(s.approvalHistory) > maxApprovalHistoryEntries {
		s.approvalHistory = s.approvalHistory[:maxApprovalHistoryEntries]
	}
	return nil
}

func (s *MobileLogicService) saveApprovalHistoryLocked() error {
	if s.dataDir == "" {
		return nil
	}

	if err := os.MkdirAll(filepath.Dir(s.approvalHistoryPath()), 0700); err != nil {
		return err
	}

	data, err := protojson.MarshalOptions{
		UseProtoNames: true,
		Indent:        "  ",
	}.Marshal(&pb.ListApprovalHistoryResponse{
		Entries: s.approvalHistory,
	})
	if err != nil {
		return err
	}

	return os.WriteFile(s.approvalHistoryPath(), data, 0600)
}

func (s *MobileLogicService) appendApprovalHistory(entry *pb.ApprovalHistoryEntry) error {
	if entry == nil {
		return nil
	}

	s.approvalHistoryMu.Lock()
	defer s.approvalHistoryMu.Unlock()

	s.approvalHistory = append([]*pb.ApprovalHistoryEntry{cloneApprovalHistoryEntry(entry)}, s.approvalHistory...)
	if len(s.approvalHistory) > maxApprovalHistoryEntries {
		s.approvalHistory = s.approvalHistory[:maxApprovalHistoryEntries]
	}

	if err := s.saveApprovalHistoryLocked(); err != nil {
		log.Printf("warning: failed to save approval history: %v\n", err)
		return err
	}
	return nil
}

// ListApprovalHistory returns backend-owned approval decision history.
func (s *MobileLogicService) ListApprovalHistory(ctx context.Context, req *pb.ListApprovalHistoryRequest) (*pb.ListApprovalHistoryResponse, error) {
	_ = ctx
	if req == nil {
		req = &pb.ListApprovalHistoryRequest{}
	}

	s.approvalHistoryMu.RLock()
	filtered := make([]*pb.ApprovalHistoryEntry, 0, len(s.approvalHistory))
	for _, e := range s.approvalHistory {
		if req.NodeId != "" && e.NodeId != req.NodeId {
			continue
		}
		filtered = append(filtered, cloneApprovalHistoryEntry(e))
	}
	s.approvalHistoryMu.RUnlock()

	total := len(filtered)
	offset := int(req.Offset)
	if offset < 0 {
		offset = 0
	}
	if offset > total {
		offset = total
	}

	limit := int(req.Limit)
	if limit <= 0 {
		limit = defaultApprovalHistoryLimit
	}
	end := offset + limit
	if end > total {
		end = total
	}

	entries := filtered[offset:end]
	return &pb.ListApprovalHistoryResponse{
		Entries:    entries,
		TotalCount: int32(total),
	}, nil
}

// ClearApprovalHistory clears backend-owned approval decision history.
func (s *MobileLogicService) ClearApprovalHistory(ctx context.Context, req *pb.ClearApprovalHistoryRequest) (*pb.ClearApprovalHistoryResponse, error) {
	_ = ctx
	_ = req

	s.approvalHistoryMu.Lock()
	deleted := len(s.approvalHistory)
	s.approvalHistory = make([]*pb.ApprovalHistoryEntry, 0)
	err := s.saveApprovalHistoryLocked()
	s.approvalHistoryMu.Unlock()
	if err != nil {
		return &pb.ClearApprovalHistoryResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}

	return &pb.ClearApprovalHistoryResponse{
		Success:      true,
		DeletedCount: int32(deleted),
	}, nil
}
