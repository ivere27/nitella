package service

import (
	"context"

	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pb "github.com/ivere27/nitella/pkg/api/local"
)

// ===========================================================================
// Log Management (Admin) — delegate to core.Controller
// ===========================================================================

// GetLogsStats returns logs storage statistics from the Hub.
func (s *MobileLogicService) GetLogsStats(ctx context.Context, req *pb.GetLogsStatsRequest) (*pb.GetLogsStatsResponse, error) {
	s.mu.RLock()
	ctrl := s.ctrl
	s.mu.RUnlock()

	stats, err := ctrl.GetLogsStats(ctx, &pbHub.GetLogsStatsRequest{})
	if err != nil {
		return nil, err
	}

	return &pb.GetLogsStatsResponse{
		TotalLogs:             stats.TotalLogs,
		TotalStorageBytes:     stats.TotalStorageBytes,
		OldestLog:             stats.OldestLog,
		NewestLog:             stats.NewestLog,
		LogsByRoutingToken:    stats.LogsByRoutingToken,
		StorageByRoutingToken: stats.StorageByRoutingToken,
	}, nil
}

// ListLogs lists logs from the Hub.
func (s *MobileLogicService) ListLogs(ctx context.Context, req *pb.ListLogsRequest) (*pb.ListLogsResponse, error) {
	s.mu.RLock()
	ctrl := s.ctrl
	s.mu.RUnlock()

	resp, err := ctrl.ListLogs(ctx, &pbHub.ListLogsRequest{
		RoutingToken: req.RoutingToken,
		NodeId:       req.NodeId,
		PageSize:     req.PageSize,
		PageToken:    req.PageToken,
	})
	if err != nil {
		return nil, err
	}

	logs := make([]*pb.LogEntry, len(resp.Logs))
	for i, l := range resp.Logs {
		logs[i] = &pb.LogEntry{
			Id:                 l.Id,
			NodeId:             l.NodeId,
			RoutingToken:       l.RoutingToken,
			Timestamp:          l.Timestamp,
			EncryptedSizeBytes: l.EncryptedSizeBytes,
		}
	}

	return &pb.ListLogsResponse{
		Logs:          logs,
		TotalCount:    int64(resp.TotalCount),
		NextPageToken: resp.NextPageToken,
	}, nil
}

// DeleteLogs deletes logs from the Hub.
func (s *MobileLogicService) DeleteLogs(ctx context.Context, req *pb.DeleteLogsRequest) (*pb.DeleteLogsResponse, error) {
	s.mu.RLock()
	ctrl := s.ctrl
	s.mu.RUnlock()

	resp, err := ctrl.DeleteLogs(ctx, &pbHub.DeleteLogsRequest{
		RoutingToken: req.RoutingToken,
		NodeId:       req.NodeId,
		DeleteAll:    req.DeleteAll,
		Before:       req.Before,
	})
	if err != nil {
		return nil, err
	}

	return &pb.DeleteLogsResponse{
		DeletedCount: resp.DeletedCount,
		FreedBytes:   resp.FreedBytes,
	}, nil
}

// CleanupOldLogs removes logs older than the specified number of days.
func (s *MobileLogicService) CleanupOldLogs(ctx context.Context, req *pb.CleanupOldLogsRequest) (*pb.CleanupOldLogsResponse, error) {
	s.mu.RLock()
	ctrl := s.ctrl
	s.mu.RUnlock()

	resp, err := ctrl.CleanupOldLogs(ctx, &pbHub.CleanupOldLogsRequest{
		OlderThanDays: req.OlderThanDays,
		DryRun:        req.DryRun,
	})
	if err != nil {
		return nil, err
	}

	return &pb.CleanupOldLogsResponse{
		DeletedCount:           resp.DeletedCount,
		FreedBytes:             resp.FreedBytes,
		DeletedByRoutingToken:  resp.DeletedByRoutingToken,
	}, nil
}
