package server

import (
	"context"
	"fmt"
	"time"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/timestamppb"

	pb "github.com/ivere27/nitella/pkg/api/hub"
)

// ============================================================================
// AdminServer - Hub administration
// ============================================================================

type AdminServer struct {
	pb.UnimplementedAdminServiceServer
	hub *HubServer
}

func NewAdminServer(hub *HubServer) *AdminServer {
	return &AdminServer{hub: hub}
}

func (s *AdminServer) GetSystemStats(ctx context.Context, req *pb.GetSystemStatsRequest) (*pb.SystemStats, error) {
	// Use count queries instead of loading all records to prevent DoS
	userCount, err := s.hub.store.CountUsers()
	if err != nil {
		userCount = 0
	}

	nodeCount, onlineCount, err := s.hub.store.CountNodes()
	if err != nil {
		nodeCount = 0
		onlineCount = 0
	}

	return &pb.SystemStats{
		TotalUsers:  int32(userCount),
		TotalNodes:  int32(nodeCount),
		OnlineNodes: int32(onlineCount),
	}, nil
}

// ============================================================================
// Logs Management (Admin)
// ============================================================================

func (s *AdminServer) GetLogsStats(ctx context.Context, req *pb.GetLogsStatsRequest) (*pb.LogsStats, error) {
	totalLogs, err := s.hub.store.CountAllLogs()
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to count logs: %v", err)
	}

	logsByToken, err := s.hub.store.GetLogsStatsByRoutingToken()
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to get logs stats: %v", err)
	}

	storageByToken, err := s.hub.store.GetLogStorageByRoutingToken()
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to get storage stats: %v", err)
	}

	var totalStorage int64
	for _, size := range storageByToken {
		totalStorage += size
	}

	oldest, newest, _ := s.hub.store.GetOldestAndNewestLog()

	resp := &pb.LogsStats{
		TotalLogs:             totalLogs,
		TotalStorageBytes:     totalStorage,
		LogsByRoutingToken:    logsByToken,
		StorageByRoutingToken: storageByToken,
	}

	if !oldest.IsZero() {
		resp.OldestLog = timestamppb.New(oldest)
	}
	if !newest.IsZero() {
		resp.NewestLog = timestamppb.New(newest)
	}

	return resp, nil
}

func (s *AdminServer) ListLogs(ctx context.Context, req *pb.ListLogsRequest) (*pb.ListLogsResponse, error) {
	if req.RoutingToken == "" {
		return nil, status.Error(codes.InvalidArgument, "routing_token is required")
	}

	pageSize := int(req.PageSize)
	if pageSize <= 0 {
		pageSize = 100
	}
	if pageSize > 1000 {
		pageSize = 1000
	}

	offset := 0
	if req.PageToken != "" {
		fmt.Sscanf(req.PageToken, "%d", &offset)
	}

	var start, end time.Time
	if req.StartTime != nil {
		start = req.StartTime.AsTime()
	}
	if req.EndTime != nil {
		end = req.EndTime.AsTime()
	}

	logs, err := s.hub.store.GetEncryptedLogsByNode(req.RoutingToken, req.NodeId, start, end, pageSize+1, offset)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to list logs: %v", err)
	}

	var nextPageToken string
	if len(logs) > pageSize {
		logs = logs[:pageSize]
		nextPageToken = fmt.Sprintf("%d", offset+pageSize)
	}

	entries := make([]*pb.AdminLogEntry, len(logs))
	for i, l := range logs {
		entries[i] = &pb.AdminLogEntry{
			Id:                 l.ID,
			NodeId:             l.NodeID,
			RoutingToken:       l.RoutingToken,
			Timestamp:          timestamppb.New(l.Timestamp),
			EncryptedSizeBytes: int32(len(l.EncryptedBlob)),
			SenderKeyId:        l.SenderKeyID,
		}
	}

	totalCount, _ := s.hub.store.CountLogs(req.RoutingToken)

	return &pb.ListLogsResponse{
		Logs:          entries,
		NextPageToken: nextPageToken,
		TotalCount:    int32(totalCount),
	}, nil
}

func (s *AdminServer) DeleteLogs(ctx context.Context, req *pb.DeleteLogsRequest) (*pb.DeleteLogsResponse, error) {
	if req.RoutingToken == "" {
		return nil, status.Error(codes.InvalidArgument, "routing_token is required")
	}

	// Get storage size before delete for reporting
	storageBefore, _ := s.hub.store.GetLogStorageByRoutingToken()
	sizeBefore := storageBefore[req.RoutingToken]

	var deleted int64
	var err error

	if req.DeleteAll {
		deleted, err = s.hub.store.DeleteLogsByRoutingToken(req.RoutingToken)
	} else if req.NodeId != "" {
		deleted, err = s.hub.store.DeleteLogsByNodeID(req.RoutingToken, req.NodeId)
	} else if req.Before != nil {
		deleted, err = s.hub.store.DeleteLogsBefore(req.RoutingToken, req.Before.AsTime())
	} else {
		return nil, status.Error(codes.InvalidArgument, "specify delete_all, node_id, or before")
	}

	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to delete logs: %v", err)
	}

	// Calculate freed space
	storageAfter, _ := s.hub.store.GetLogStorageByRoutingToken()
	sizeAfter := storageAfter[req.RoutingToken]
	freedBytes := sizeBefore - sizeAfter

	return &pb.DeleteLogsResponse{
		DeletedCount: deleted,
		FreedBytes:   freedBytes,
	}, nil
}

func (s *AdminServer) CleanupOldLogs(ctx context.Context, req *pb.CleanupOldLogsRequest) (*pb.CleanupOldLogsResponse, error) {
	if req.OlderThanDays <= 0 {
		return nil, status.Error(codes.InvalidArgument, "older_than_days must be positive")
	}

	before := time.Now().AddDate(0, 0, -int(req.OlderThanDays))

	// Get stats before cleanup
	statsBefore, _ := s.hub.store.GetLogsStatsByRoutingToken()
	storageBefore, _ := s.hub.store.GetLogStorageByRoutingToken()

	var totalBefore int64
	for _, size := range storageBefore {
		totalBefore += size
	}

	if req.DryRun {
		// Just report what would be deleted
		var wouldDelete int64
		deletedByToken := make(map[string]int64)

		for token := range statsBefore {
			logs, _ := s.hub.store.GetEncryptedLogsByNode(token, "", time.Time{}, before, 0, 0)
			count := int64(len(logs))
			if count > 0 {
				deletedByToken[token] = count
				wouldDelete += count
			}
		}

		return &pb.CleanupOldLogsResponse{
			DeletedCount:          wouldDelete,
			FreedBytes:            0, // Can't estimate without actually counting blob sizes
			DeletedByRoutingToken: deletedByToken,
		}, nil
	}

	// Actually delete
	err := s.hub.store.DeleteOldLogs(before)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to cleanup logs: %v", err)
	}

	// Get stats after cleanup
	statsAfter, _ := s.hub.store.GetLogsStatsByRoutingToken()
	storageAfter, _ := s.hub.store.GetLogStorageByRoutingToken()

	var totalAfter int64
	for _, size := range storageAfter {
		totalAfter += size
	}

	deletedByToken := make(map[string]int64)
	for token, countBefore := range statsBefore {
		countAfter := statsAfter[token]
		if countBefore > countAfter {
			deletedByToken[token] = countBefore - countAfter
		}
	}

	var totalDeleted int64
	for _, count := range deletedByToken {
		totalDeleted += count
	}

	return &pb.CleanupOldLogsResponse{
		DeletedCount:          totalDeleted,
		FreedBytes:            totalBefore - totalAfter,
		DeletedByRoutingToken: deletedByToken,
	}, nil
}
