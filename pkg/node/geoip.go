package node

import (
	"context"
	"sync"
	"time"

	pbCommon "github.com/ivere27/nitella/pkg/api/common"
	"github.com/ivere27/nitella/pkg/geoip"
)

const defaultGeoLookupTimeout = 3 * time.Second

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
	return s.LookupWithTimeout(ip, defaultGeoLookupTimeout)
}

// LookupWithTimeout performs a GeoIP lookup with the specified timeout.
// If timeout is <= 0, defaultGeoLookupTimeout is used.
func (s *GeoIPService) LookupWithTimeout(ip string, timeout time.Duration) *pbCommon.GeoInfo {
	s.mu.RLock()
	client := s.client
	s.mu.RUnlock()

	if client == nil {
		return &pbCommon.GeoInfo{}
	}

	if timeout <= 0 {
		timeout = defaultGeoLookupTimeout
	}
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
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
