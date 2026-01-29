package node

import (
	"context"
	"sync"
	"time"

	pbCommon "github.com/ivere27/nitella/pkg/api/common"
	"github.com/ivere27/nitella/pkg/geoip"
)

// GeoIPService manages the GeoIP client (FFI or gRPC)
type GeoIPService struct {
	client geoip.GeoIPClient
	mu     sync.RWMutex
}

// NewGeoIPService creates a new GeoIP service with the given client.
func NewGeoIPService(client geoip.GeoIPClient) *GeoIPService {
	return &GeoIPService{
		client: client,
	}
}

// SetClient replaces the current client with a new one.
func (s *GeoIPService) SetClient(c geoip.GeoIPClient) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.client != nil {
		s.client.Close()
	}
	s.client = c
}

// Lookup performs a GeoIP lookup.
func (s *GeoIPService) Lookup(ip string) *pbCommon.GeoInfo {
	s.mu.RLock()
	client := s.client
	s.mu.RUnlock()

	if client == nil {
		return &pbCommon.GeoInfo{}
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	info, err := client.Lookup(ctx, ip)
	if err != nil {
		return &pbCommon.GeoInfo{}
	}
	return info
}

// Close closes the underlying client.
func (s *GeoIPService) Close() {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.client != nil {
		s.client.Close()
		s.client = nil
	}
}
