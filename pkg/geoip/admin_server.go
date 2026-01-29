package geoip

import (
	"context"
	"fmt"
	"net"
	"os"
	"sync"
	"time"

	log "github.com/ivere27/nitella/pkg/log"

	pbCommon "github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/geoip"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/peer"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
)

// AdminServer implements GeoIPAdminServiceServer.
type AdminServer struct {
	pb.UnimplementedGeoIPAdminServiceServer
	manager *Manager
}

// NewAdminServer creates a new admin server.
func NewAdminServer(manager *Manager) *AdminServer {
	return &AdminServer{
		manager: manager,
	}
}

// ============================================================================
// Lookup (authenticated)
// ============================================================================

// Lookup resolves an IP to geographical info.
func (s *AdminServer) Lookup(ctx context.Context, req *pb.LookupRequest) (*pbCommon.GeoInfo, error) {
	if net.ParseIP(req.Ip) == nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid IP address: %s", req.Ip)
	}
	info, err := s.manager.Lookup(ctx, req.Ip)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "lookup failed: %v", err)
	}
	return info, nil
}

// GetStatus returns the health and stats of the service.
func (s *AdminServer) GetStatus(ctx context.Context, req *emptypb.Empty) (*pb.ServiceStatus, error) {
	cacheStats := s.manager.GetCacheStats()
	providers := s.manager.ListProviders()
	localLoaded, _, _ := s.manager.GetLocalDBStatus()

	activeProviders := make([]string, 0)
	for _, p := range providers {
		if p.Enabled {
			activeProviders = append(activeProviders, p.Name)
		}
	}

	return &pb.ServiceStatus{
		Ready:           true,
		L1CacheSize:     cacheStats.L1Size,
		L2CacheSize:     cacheStats.L2Size,
		ActiveProviders: activeProviders,
		Strategy:        fmt.Sprintf("%v", s.manager.GetStrategy()),
		LocalDbLoaded:   localLoaded,
		L2TtlHours:      cacheStats.L2TtlHours,
	}, nil
}

// ============================================================================
// Local Database Management
// ============================================================================

// LoadLocalDB loads MaxMind database files.
func (s *AdminServer) LoadLocalDB(ctx context.Context, req *pb.LoadLocalDBRequest) (*emptypb.Empty, error) {
	if err := s.manager.SetLocalDB(req.CityDbPath, req.IspDbPath); err != nil {
		return nil, status.Errorf(codes.Internal, "failed to load DB: %v", err)
	}
	return &emptypb.Empty{}, nil
}

// UnloadLocalDB unloads the local database.
func (s *AdminServer) UnloadLocalDB(ctx context.Context, req *emptypb.Empty) (*emptypb.Empty, error) {
	s.manager.UnloadLocalDB()
	return &emptypb.Empty{}, nil
}

// GetLocalDBStatus returns the status of the local database.
func (s *AdminServer) GetLocalDBStatus(ctx context.Context, req *emptypb.Empty) (*pb.LocalDBStatus, error) {
	loaded, cityPath, ispPath := s.manager.GetLocalDBStatus()

	resp := &pb.LocalDBStatus{
		Loaded:     loaded,
		CityDbPath: cityPath,
		IspDbPath:  ispPath,
	}

	// Get file sizes
	if cityPath != "" {
		if info, err := os.Stat(cityPath); err == nil {
			resp.CityDbSize = info.Size()
		}
	}
	if ispPath != "" {
		if info, err := os.Stat(ispPath); err == nil {
			resp.IspDbSize = info.Size()
		}
	}

	return resp, nil
}

// ============================================================================
// Provider Management
// ============================================================================

// ListProviders returns all configured providers with stats.
func (s *AdminServer) ListProviders(ctx context.Context, req *emptypb.Empty) (*pb.ListProvidersResponse, error) {
	entries := s.manager.ListProviders()

	providers := make([]*pb.ProviderInfo, 0, len(entries))
	for _, entry := range entries {
		info := &pb.ProviderInfo{
			Name:     entry.Name,
			Url:      entry.URL,
			Enabled:  entry.Enabled,
			Priority: int32(entry.Priority),
			Stats:    entry.Stats.ToProto(),
		}
		if entry.Mapping != nil {
			info.FieldMapping = mappingToProto(entry.Mapping)
		}
		providers = append(providers, info)
	}

	return &pb.ListProvidersResponse{Providers: providers}, nil
}

// AddProvider adds a new HTTP provider.
func (s *AdminServer) AddProvider(ctx context.Context, req *pb.AddProviderRequest) (*pb.ProviderInfo, error) {
	var mapping *FieldMapping
	if req.FieldMapping != nil {
		mapping = mappingFromProto(req.FieldMapping)
	}

	priority := int(req.Priority)
	if priority == 0 {
		priority = len(s.manager.ListProviders()) + 1
	}

	s.manager.AddRemoteProviderFull(req.Name, req.Url, priority, mapping, true)

	// Return the new provider info
	stats := s.manager.GetProviderStats(req.Name)
	return &pb.ProviderInfo{
		Name:         req.Name,
		Url:          req.Url,
		Enabled:      true,
		Priority:     int32(priority),
		FieldMapping: req.FieldMapping,
		Stats:        stats.ToProto(),
	}, nil
}

// RemoveProvider removes a provider by name.
func (s *AdminServer) RemoveProvider(ctx context.Context, req *pb.RemoveProviderRequest) (*emptypb.Empty, error) {
	if !s.manager.RemoveRemoteProvider(req.Name) {
		return nil, status.Errorf(codes.NotFound, "provider not found: %s", req.Name)
	}
	return &emptypb.Empty{}, nil
}

// UpdateProvider updates an existing provider.
func (s *AdminServer) UpdateProvider(ctx context.Context, req *pb.UpdateProviderRequest) (*pb.ProviderInfo, error) {
	entries := s.manager.ListProviders()

	var found *RemoteProviderEntry
	for _, entry := range entries {
		if entry.Name == req.Name {
			found = entry
			break
		}
	}

	if found == nil {
		return nil, status.Errorf(codes.NotFound, "provider not found: %s", req.Name)
	}

	// Update fields
	s.manager.mu.Lock()
	if req.Url != "" {
		found.URL = req.Url
		found.Provider = NewHTTPProviderWithMapping(req.Name, req.Url, s.manager.timeout, found.Mapping)
	}
	if req.Priority > 0 {
		found.Priority = int(req.Priority)
	}
	if req.FieldMapping != nil {
		found.Mapping = mappingFromProto(req.FieldMapping)
		found.Provider = NewHTTPProviderWithMapping(req.Name, found.URL, s.manager.timeout, found.Mapping)
	}
	found.Enabled = req.Enabled
	s.manager.mu.Unlock()

	return &pb.ProviderInfo{
		Name:         found.Name,
		Url:          found.URL,
		Enabled:      found.Enabled,
		Priority:     int32(found.Priority),
		FieldMapping: mappingToProto(found.Mapping),
		Stats:        found.Stats.ToProto(),
	}, nil
}

// ReorderProviders changes the provider priority order.
func (s *AdminServer) ReorderProviders(ctx context.Context, req *pb.ReorderProvidersRequest) (*pb.ListProvidersResponse, error) {
	if err := s.manager.ReorderProviders(req.ProviderNames); err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "failed to reorder: %v", err)
	}
	return s.ListProviders(ctx, &emptypb.Empty{})
}

// EnableProvider enables a disabled provider.
func (s *AdminServer) EnableProvider(ctx context.Context, req *pb.ProviderNameRequest) (*emptypb.Empty, error) {
	if !s.manager.EnableProvider(req.Name) {
		return nil, status.Errorf(codes.NotFound, "provider not found: %s", req.Name)
	}
	return &emptypb.Empty{}, nil
}

// DisableProvider disables a provider without removing it.
func (s *AdminServer) DisableProvider(ctx context.Context, req *pb.ProviderNameRequest) (*emptypb.Empty, error) {
	if !s.manager.DisableProvider(req.Name) {
		return nil, status.Errorf(codes.NotFound, "provider not found: %s", req.Name)
	}
	return &emptypb.Empty{}, nil
}

// GetProviderStats returns detailed statistics for a provider.
func (s *AdminServer) GetProviderStats(ctx context.Context, req *pb.ProviderNameRequest) (*pb.ProviderStats, error) {
	stats := s.manager.GetProviderStats(req.Name)
	if stats == nil {
		return nil, status.Errorf(codes.NotFound, "provider not found: %s", req.Name)
	}
	return stats.ToProto(), nil
}

// ============================================================================
// Cache Management
// ============================================================================

// GetCacheStats returns cache statistics.
func (s *AdminServer) GetCacheStats(ctx context.Context, req *emptypb.Empty) (*pb.CacheStats, error) {
	return s.manager.GetCacheStats(), nil
}

// ClearCache clears specified cache layers.
func (s *AdminServer) ClearCache(ctx context.Context, req *pb.ClearCacheRequest) (*emptypb.Empty, error) {
	switch req.Layer {
	case pb.CacheLayer_CACHE_LAYER_L1:
		s.manager.ClearL1Cache()
	case pb.CacheLayer_CACHE_LAYER_L2:
		s.manager.ClearL2Cache()
	case pb.CacheLayer_CACHE_LAYER_ALL:
		s.manager.ClearAllCaches()
	}
	return &emptypb.Empty{}, nil
}

// GetCacheSettings returns current cache settings.
func (s *AdminServer) GetCacheSettings(ctx context.Context, req *emptypb.Empty) (*pb.CacheSettings, error) {
	s.manager.mu.RLock()
	defer s.manager.mu.RUnlock()

	settings := &pb.CacheSettings{
		L1Capacity: int32(s.manager.l1Cache.limit),
		L1TtlHours: 1, // Default
	}

	if s.manager.l2Cache != nil {
		settings.L2Enabled = true
		settings.L2Path = s.manager.l2Cache.Path()
		settings.L2TtlHours = int32(s.manager.l2Cache.TTLHours())
	}

	return settings, nil
}

// UpdateCacheSettings updates cache configuration.
func (s *AdminServer) UpdateCacheSettings(ctx context.Context, req *pb.UpdateCacheSettingsRequest) (*pb.CacheSettings, error) {
	// L1 capacity update requires recreating the cache
	if req.L1Capacity > 0 {
		s.manager.mu.Lock()
		oldData := s.manager.l1Cache.data
		s.manager.l1Cache = NewL1Cache(int(req.L1Capacity))
		// Copy old data (up to new limit)
		count := 0
		for ip, entry := range oldData {
			if count >= int(req.L1Capacity) {
				break
			}
			s.manager.l1Cache.data[ip] = entry
			count++
		}
		s.manager.mu.Unlock()
	}

	// L2 enable/disable
	if req.L2Enabled && s.manager.l2Cache == nil && req.L2Path != "" {
		ttlHours := int(req.L2TtlHours)
		if err := s.manager.InitL2(req.L2Path, ttlHours); err != nil {
			return nil, status.Errorf(codes.Internal, "failed to init L2: %v", err)
		}
	}

	// Update L2 TTL if already enabled
	if s.manager.l2Cache != nil && req.L2TtlHours >= 0 {
		s.manager.SetL2TTL(int(req.L2TtlHours))
	}

	return s.GetCacheSettings(ctx, &emptypb.Empty{})
}

// ============================================================================
// Strategy Management
// ============================================================================

// GetStrategy returns the current lookup strategy.
func (s *AdminServer) GetStrategy(ctx context.Context, req *emptypb.Empty) (*pb.StrategyResponse, error) {
	return &pb.StrategyResponse{
		Steps:     s.manager.GetStrategy(),
		TimeoutMs: int32(s.manager.GetTimeout().Milliseconds()),
	}, nil
}

// SetStrategy sets the lookup strategy order.
func (s *AdminServer) SetStrategy(ctx context.Context, req *pb.SetStrategyRequest) (*pb.StrategyResponse, error) {
	// Validate steps
	validSteps := map[string]bool{"l1": true, "l2": true, "local": true, "remote": true}
	for _, step := range req.Steps {
		if !validSteps[step] {
			return nil, status.Errorf(codes.InvalidArgument, "invalid strategy step: %s", step)
		}
	}

	s.manager.SetStrategy(req.Steps)
	if req.TimeoutMs > 0 {
		s.manager.SetTimeout(time.Duration(req.TimeoutMs) * time.Millisecond)
	}

	return s.GetStrategy(ctx, &emptypb.Empty{})
}

// VacuumL2 optimizes the L2 cache database.
func (s *AdminServer) VacuumL2(ctx context.Context, req *emptypb.Empty) (*emptypb.Empty, error) {
	if err := s.manager.VacuumL2(); err != nil {
		return nil, status.Errorf(codes.Internal, "vacuum failed: %v", err)
	}
	return &emptypb.Empty{}, nil
}

// ============================================================================
// Config File Management
// ============================================================================

// ReloadConfig reloads configuration from file.
func (s *AdminServer) ReloadConfig(ctx context.Context, req *emptypb.Empty) (*emptypb.Empty, error) {
	if err := s.manager.ReloadConfig(); err != nil {
		return nil, status.Errorf(codes.Internal, "reload failed: %v", err)
	}
	return &emptypb.Empty{}, nil
}

// SaveConfig saves current configuration to file.
func (s *AdminServer) SaveConfig(ctx context.Context, req *emptypb.Empty) (*emptypb.Empty, error) {
	if err := s.manager.SaveConfigToFile(); err != nil {
		return nil, status.Errorf(codes.Internal, "save failed: %v", err)
	}
	return &emptypb.Empty{}, nil
}

// ============================================================================
// Helper Functions
// ============================================================================

// mappingToProto converts FieldMapping to proto.
func mappingToProto(m *FieldMapping) *pb.FieldMapping {
	if m == nil {
		return nil
	}
	return &pb.FieldMapping{
		Country:     m.Country,
		CountryCode: m.CountryCode,
		Region:      m.Region,
		RegionName:  m.RegionName,
		City:        m.City,
		Zip:         m.Zip,
		Timezone:    m.Timezone,
		Latitude:    m.Latitude,
		Longitude:   m.Longitude,
		Isp:         m.Isp,
		Org:         m.Org,
		As:          m.As,
	}
}

// mappingFromProto converts proto to FieldMapping.
func mappingFromProto(m *pb.FieldMapping) *FieldMapping {
	if m == nil {
		return nil
	}
	return &FieldMapping{
		Country:     m.Country,
		CountryCode: m.CountryCode,
		Region:      m.Region,
		RegionName:  m.RegionName,
		City:        m.City,
		Zip:         m.Zip,
		Timezone:    m.Timezone,
		Latitude:    m.Latitude,
		Longitude:   m.Longitude,
		Isp:         m.Isp,
		Org:         m.Org,
		As:          m.As,
	}
}

// ============================================================================
// Authentication Interceptor
// ============================================================================

// AdminAuthInterceptor creates a token authentication interceptor with logging.
func AdminAuthInterceptor(token string) grpc.UnaryServerInterceptor {
	var loggedOnce sync.Once

	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		// Get client address
		clientAddr := "unknown"
		if p, ok := peer.FromContext(ctx); ok && p.Addr != nil {
			clientAddr = p.Addr.String()
		}

		md, ok := metadata.FromIncomingContext(ctx)
		if !ok {
			log.Printf("[Admin] Auth failed from %s: no metadata", clientAddr)
			return nil, status.Error(codes.Unauthenticated, "no metadata")
		}

		tokens := md.Get("authorization")
		if len(tokens) == 0 {
			log.Printf("[Admin] Auth failed from %s: missing authorization", clientAddr)
			return nil, status.Error(codes.Unauthenticated, "missing authorization")
		}

		// Support both "Bearer <token>" and plain token
		authToken := tokens[0]
		if len(authToken) > 7 && authToken[:7] == "Bearer " {
			authToken = authToken[7:]
		}

		if authToken != token {
			log.Printf("[Admin] Auth failed from %s: invalid token", clientAddr)
			return nil, status.Error(codes.Unauthenticated, "invalid token")
		}

		// Log first successful auth only
		loggedOnce.Do(func() {
			log.Printf("[Admin] First client authenticated")
		})

		return handler(ctx, req)
	}
}
