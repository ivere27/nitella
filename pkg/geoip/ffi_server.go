package geoip

import (
	"context"
	"strings"

	pbCommon "github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/geoip"
	empty "google.golang.org/protobuf/types/known/emptypb"
)

// FfiServerImpl implements geoip.FfiServer for zero-copy FFI calls.
type FfiServerImpl struct {
	pb.UnimplementedGeoIPServiceServer
	manager *Manager
}

// NewFfiServer creates a new FFI server wrapping the manager.
func NewFfiServer(manager *Manager) *FfiServerImpl {
	return &FfiServerImpl{manager: manager}
}

// Lookup resolves an IP to geographical info.
func (s *FfiServerImpl) Lookup(ctx context.Context, req *pb.LookupRequest) (*pbCommon.GeoInfo, error) {
	return s.manager.Lookup(ctx, req.Ip)
}

// GetStatus returns the health and stats of the service.
func (s *FfiServerImpl) GetStatus(ctx context.Context, req *empty.Empty) (*pb.ServiceStatus, error) {
	cacheStats := s.manager.GetCacheStats()

	// Get active providers
	var activeProviders []string
	for _, p := range s.manager.ListProviders() {
		if p.Enabled {
			activeProviders = append(activeProviders, p.Name)
		}
	}

	// Get strategy
	strategy := s.manager.GetStrategy()

	// Check if local DB is loaded
	localLoaded, _, _ := s.manager.GetLocalDBStatus()

	return &pb.ServiceStatus{
		Ready:           true,
		L1CacheSize:     cacheStats.L1Size,
		L2CacheSize:     cacheStats.L2Size,
		ActiveProviders: activeProviders,
		Strategy:        strings.Join(strategy, ","),
		LocalDbLoaded:   localLoaded,
		L2TtlHours:      cacheStats.L2TtlHours,
	}, nil
}

// Ensure FfiServerImpl implements geoip.FfiServer interface.
var _ pb.FfiServer = (*FfiServerImpl)(nil)
