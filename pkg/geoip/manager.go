package geoip

import (
	"context"
	"fmt"
	"sort"
	"sync"
	"sync/atomic"
	"time"

	pbCommon "github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/geoip"
)

// ProviderStats tracks statistics for a provider.
type ProviderStats struct {
	Name         string
	LookupCount  int64
	SuccessCount int64
	ErrorCount   int64
	TotalLatency time.Duration
	LastUsed     time.Time
	LastError    string
	mu           sync.Mutex
}

// RecordSuccess records a successful lookup.
func (s *ProviderStats) RecordSuccess(latency time.Duration) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.LookupCount++
	s.SuccessCount++
	s.TotalLatency += latency
	s.LastUsed = time.Now()
}

// RecordError records a failed lookup.
func (s *ProviderStats) RecordError(err error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.LookupCount++
	s.ErrorCount++
	s.LastUsed = time.Now()
	if err != nil {
		s.LastError = err.Error()
	}
}

// AvgLatency returns the average latency in milliseconds.
func (s *ProviderStats) AvgLatency() int64 {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.SuccessCount == 0 {
		return 0
	}
	return s.TotalLatency.Milliseconds() / s.SuccessCount
}

// ToProto converts ProviderStats to protobuf.
func (s *ProviderStats) ToProto() *pb.ProviderStats {
	s.mu.Lock()
	defer s.mu.Unlock()
	avgLatency := int64(0)
	if s.SuccessCount > 0 {
		avgLatency = s.TotalLatency.Milliseconds() / s.SuccessCount
	}
	return &pb.ProviderStats{
		Name:           s.Name,
		LookupCount:    s.LookupCount,
		SuccessCount:   s.SuccessCount,
		ErrorCount:     s.ErrorCount,
		TotalLatencyMs: s.TotalLatency.Milliseconds(),
		AvgLatencyMs:   avgLatency,
		LastUsedUnix:   s.LastUsed.Unix(),
		LastError:      s.LastError,
	}
}

// RemoteProviderEntry holds a remote provider with its configuration.
type RemoteProviderEntry struct {
	Provider Provider
	Name     string
	URL      string
	Enabled  bool
	Priority int
	Mapping  *FieldMapping
	Stats    *ProviderStats
}

// Manager manages GeoIP lookups with caching and multiple providers.
type Manager struct {
	l1Cache *L1Cache
	l2Cache *L2Cache

	localProvider  Provider
	localDBEnabled bool
	localCityPath  string
	localISPPath   string

	remoteProviders []*RemoteProviderEntry

	fallbackStrategy []string // e.g. ["l1", "l2", "local", "remote"]

	timeout time.Duration

	// Cache stats
	l1Hits   int64
	l1Misses int64
	l2Hits   int64
	l2Misses int64

	// Config
	configPath string
	config     *Config

	mu sync.RWMutex
}

// NewManager creates a new GeoIP manager with defaults.
func NewManager() *Manager {
	return &Manager{
		l1Cache:          NewL1Cache(10000),
		fallbackStrategy: []string{"l1", "l2", "local", "remote"},
		timeout:          3 * time.Second,
		remoteProviders:  make([]*RemoteProviderEntry, 0),
	}
}

// NewManagerFromConfig creates a manager from configuration.
func NewManagerFromConfig(cfg *Config) (*Manager, error) {
	m := &Manager{
		l1Cache:          NewL1Cache(cfg.GeoIP.Cache.L1.Capacity),
		fallbackStrategy: cfg.GeoIP.Strategy,
		timeout:          time.Duration(cfg.GeoIP.TimeoutMs) * time.Millisecond,
		config:           cfg,
		remoteProviders:  make([]*RemoteProviderEntry, 0),
	}

	// Initialize L2 cache
	if cfg.GeoIP.Cache.L2.Enabled && cfg.GeoIP.Cache.L2.Path != "" {
		if err := m.InitL2(cfg.GeoIP.Cache.L2.Path, cfg.GeoIP.Cache.L2.TTLHours); err != nil {
			return nil, fmt.Errorf("failed to init L2 cache: %w", err)
		}
	}

	// Initialize local database
	if cfg.GeoIP.Local.Enabled {
		if err := m.SetLocalDB(cfg.GeoIP.Local.CityDB, cfg.GeoIP.Local.IspDB); err != nil {
			return nil, fmt.Errorf("failed to load local DB: %w", err)
		}
	}

	// Sort providers by priority
	providers := make([]RemoteProviderConfig, len(cfg.GeoIP.RemoteProviders))
	copy(providers, cfg.GeoIP.RemoteProviders)
	sort.Slice(providers, func(i, j int) bool {
		return providers[i].Priority < providers[j].Priority
	})

	// Initialize remote providers
	for _, p := range providers {
		if p.Enabled {
			m.AddRemoteProviderFull(p.Name, p.URL, p.Priority, p.FieldMapping.ToFieldMapping(), p.Enabled)
		}
	}

	return m, nil
}

// SetTimeout sets the lookup timeout.
func (m *Manager) SetTimeout(d time.Duration) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.timeout = d
}

// GetTimeout returns the current timeout.
func (m *Manager) GetTimeout() time.Duration {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.timeout
}

// InitL2 initializes the L2 cache. ttlHours=0 means permanent (no expiration).
func (m *Manager) InitL2(dbPath string, ttlHours int) error {
	l2, err := NewL2Cache(dbPath, ttlHours)
	if err != nil {
		return err
	}
	m.mu.Lock()
	if m.l2Cache != nil {
		m.l2Cache.Close()
	}
	m.l2Cache = l2
	m.mu.Unlock()
	return nil
}

// SetLocalDB sets the local MaxMind databases.
func (m *Manager) SetLocalDB(cityPath, ispPath string) error {
	p, err := NewLocalProvider(cityPath, ispPath)
	if err != nil {
		return err
	}
	m.mu.Lock()
	if m.localProvider != nil {
		m.localProvider.Close()
	}
	m.localProvider = p
	m.localDBEnabled = true
	m.localCityPath = cityPath
	m.localISPPath = ispPath
	m.mu.Unlock()
	return nil
}

// UnloadLocalDB unloads the local database.
func (m *Manager) UnloadLocalDB() {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.localProvider != nil {
		m.localProvider.Close()
		m.localProvider = nil
	}
	m.localDBEnabled = false
	m.localCityPath = ""
	m.localISPPath = ""
}

// GetLocalDBStatus returns the local DB status.
func (m *Manager) GetLocalDBStatus() (loaded bool, cityPath, ispPath string) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.localDBEnabled, m.localCityPath, m.localISPPath
}

// SetLocalProvider sets the local provider directly.
func (m *Manager) SetLocalProvider(p Provider) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.localProvider != nil {
		m.localProvider.Close()
	}
	m.localProvider = p
	m.localDBEnabled = p != nil
}

// AddRemoteProvider adds a remote HTTP provider.
func (m *Manager) AddRemoteProvider(name, urlFmt string) {
	m.AddRemoteProviderFull(name, urlFmt, len(m.remoteProviders)+1, nil, true)
}

// AddRemoteProviderWithMapping adds a remote HTTP provider with custom field mapping.
func (m *Manager) AddRemoteProviderWithMapping(name, urlFmt string, mapping *FieldMapping) {
	m.AddRemoteProviderFull(name, urlFmt, len(m.remoteProviders)+1, mapping, true)
}

// AddRemoteProviderFull adds a remote provider with full configuration.
func (m *Manager) AddRemoteProviderFull(name, urlFmt string, priority int, mapping *FieldMapping, enabled bool) {
	m.mu.Lock()
	defer m.mu.Unlock()

	p := NewHTTPProviderWithMapping(name, urlFmt, m.timeout, mapping)

	entry := &RemoteProviderEntry{
		Provider: p,
		Name:     name,
		URL:      urlFmt,
		Enabled:  enabled,
		Priority: priority,
		Mapping:  mapping,
		Stats:    &ProviderStats{Name: name},
	}

	m.remoteProviders = append(m.remoteProviders, entry)

	// Sort by priority
	sort.Slice(m.remoteProviders, func(i, j int) bool {
		return m.remoteProviders[i].Priority < m.remoteProviders[j].Priority
	})
}

// RemoveRemoteProvider removes a provider by name.
func (m *Manager) RemoveRemoteProvider(name string) bool {
	m.mu.Lock()
	defer m.mu.Unlock()

	for i, entry := range m.remoteProviders {
		if entry.Name == name {
			entry.Provider.Close()
			m.remoteProviders = append(m.remoteProviders[:i], m.remoteProviders[i+1:]...)
			return true
		}
	}
	return false
}

// EnableProvider enables a provider by name.
func (m *Manager) EnableProvider(name string) bool {
	m.mu.Lock()
	defer m.mu.Unlock()

	for _, entry := range m.remoteProviders {
		if entry.Name == name {
			entry.Enabled = true
			return true
		}
	}
	return false
}

// DisableProvider disables a provider by name.
func (m *Manager) DisableProvider(name string) bool {
	m.mu.Lock()
	defer m.mu.Unlock()

	for _, entry := range m.remoteProviders {
		if entry.Name == name {
			entry.Enabled = false
			return true
		}
	}
	return false
}

// GetProviderStats returns stats for a provider.
func (m *Manager) GetProviderStats(name string) *ProviderStats {
	m.mu.RLock()
	defer m.mu.RUnlock()

	for _, entry := range m.remoteProviders {
		if entry.Name == name {
			return entry.Stats
		}
	}
	return nil
}

// ListProviders returns all remote provider entries.
func (m *Manager) ListProviders() []*RemoteProviderEntry {
	m.mu.RLock()
	defer m.mu.RUnlock()

	result := make([]*RemoteProviderEntry, len(m.remoteProviders))
	copy(result, m.remoteProviders)
	return result
}

// ReorderProviders reorders providers by name list.
func (m *Manager) ReorderProviders(names []string) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	// Build map for quick lookup
	byName := make(map[string]*RemoteProviderEntry)
	for _, entry := range m.remoteProviders {
		byName[entry.Name] = entry
	}

	// Rebuild list in new order
	newList := make([]*RemoteProviderEntry, 0, len(names))
	for i, name := range names {
		entry, ok := byName[name]
		if !ok {
			return fmt.Errorf("provider not found: %s", name)
		}
		entry.Priority = i + 1
		newList = append(newList, entry)
		delete(byName, name)
	}

	// Append any remaining providers
	for _, entry := range byName {
		entry.Priority = len(newList) + 1
		newList = append(newList, entry)
	}

	m.remoteProviders = newList
	return nil
}

// RegisterProvider adds a custom provider.
func (m *Manager) RegisterProvider(p Provider) {
	m.mu.Lock()
	defer m.mu.Unlock()

	entry := &RemoteProviderEntry{
		Provider: p,
		Name:     p.Name(),
		Enabled:  true,
		Priority: len(m.remoteProviders) + 1,
		Stats:    &ProviderStats{Name: p.Name()},
	}
	m.remoteProviders = append(m.remoteProviders, entry)
}

// SetStrategy sets the lookup strategy.
func (m *Manager) SetStrategy(strategy []string) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.fallbackStrategy = strategy
}

// GetStrategy returns the current strategy.
func (m *Manager) GetStrategy() []string {
	m.mu.RLock()
	defer m.mu.RUnlock()
	result := make([]string, len(m.fallbackStrategy))
	copy(result, m.fallbackStrategy)
	return result
}

// Lookup performs a GeoIP lookup.
func (m *Manager) Lookup(ctx context.Context, ip string) (*pbCommon.GeoInfo, error) {
	start := time.Now()

	for _, step := range m.fallbackStrategy {
		switch step {
		case "l1":
			if info := m.l1Cache.Get(ip); info != nil {
				atomic.AddInt64(&m.l1Hits, 1)
				info.Source = "cache-l1"
				info.LatencyMs = time.Since(start).Milliseconds()
				return info, nil
			}
			atomic.AddInt64(&m.l1Misses, 1)

		case "l2":
			if m.l2Cache != nil {
				if info := m.l2Cache.Get(ip); info != nil {
					atomic.AddInt64(&m.l2Hits, 1)
					// Populate L1
					m.l1Cache.Put(ip, info)
					info.Source = "cache-l2"
					info.LatencyMs = time.Since(start).Milliseconds()
					return info, nil
				}
				atomic.AddInt64(&m.l2Misses, 1)
			}

		case "local":
			m.mu.RLock()
			local := m.localProvider
			enabled := m.localDBEnabled
			m.mu.RUnlock()

			if enabled && local != nil {
				if info, err := local.Lookup(ip); err == nil {
					// Cache it
					m.l1Cache.Put(ip, info)
					if m.l2Cache != nil {
						m.l2Cache.Put(ip, info)
					}
					info.LatencyMs = time.Since(start).Milliseconds()
					return info, nil
				}
			}

		case "remote":
			m.mu.RLock()
			remotes := make([]*RemoteProviderEntry, len(m.remoteProviders))
			copy(remotes, m.remoteProviders)
			m.mu.RUnlock()

			for _, entry := range remotes {
				if !entry.Enabled {
					continue
				}

				lookupStart := time.Now()
				info, err := entry.Provider.Lookup(ip)
				latency := time.Since(lookupStart)

				if err == nil {
					entry.Stats.RecordSuccess(latency)

					// Cache it
					m.l1Cache.Put(ip, info)
					if m.l2Cache != nil {
						m.l2Cache.Put(ip, info)
					}
					info.LatencyMs = time.Since(start).Milliseconds()
					return info, nil
				}
				entry.Stats.RecordError(err)
			}
		}
	}

	return nil, fmt.Errorf("lookup failed on all strategies")
}

// GetStatus returns the service status.
func (m *Manager) GetStatus() *pb.ServiceStatus {
	m.mu.RLock()
	defer m.mu.RUnlock()

	providers := []string{}
	if m.localProvider != nil && m.localDBEnabled {
		providers = append(providers, m.localProvider.Name())
	}
	for _, entry := range m.remoteProviders {
		if entry.Enabled {
			providers = append(providers, entry.Name)
		}
	}

	l2Size := int64(0)
	l2TtlHours := int32(0)
	if m.l2Cache != nil {
		l2Size = m.l2Cache.Size()
		l2TtlHours = int32(m.l2Cache.TTLHours())
	}

	return &pb.ServiceStatus{
		Ready:           true,
		L1CacheSize:     m.l1Cache.Size(),
		L2CacheSize:     l2Size,
		LocalDbLoaded:   m.localDBEnabled,
		ActiveProviders: providers,
		Strategy:        fmt.Sprintf("%v", m.fallbackStrategy),
		L2TtlHours:      l2TtlHours,
	}
}

// GetCacheStats returns cache statistics.
func (m *Manager) GetCacheStats() *pb.CacheStats {
	m.mu.RLock()
	defer m.mu.RUnlock()

	stats := &pb.CacheStats{
		L1Size:     m.l1Cache.Size(),
		L1Capacity: int64(m.l1Cache.limit),
		L1Hits:     atomic.LoadInt64(&m.l1Hits),
		L1Misses:   atomic.LoadInt64(&m.l1Misses),
	}

	if m.l2Cache != nil {
		stats.L2Enabled = true
		stats.L2Path = m.l2Cache.Path()
		stats.L2Size = m.l2Cache.Size()
		stats.L2Hits = atomic.LoadInt64(&m.l2Hits)
		stats.L2Misses = atomic.LoadInt64(&m.l2Misses)
		stats.L2TtlHours = int32(m.l2Cache.TTLHours())
	}

	return stats
}

// ClearL1Cache clears the L1 cache and resets stats.
func (m *Manager) ClearL1Cache() {
	m.l1Cache.mu.Lock()
	m.l1Cache.data = make(map[string]*l1Entry)
	m.l1Cache.mu.Unlock()
	atomic.StoreInt64(&m.l1Hits, 0)
	atomic.StoreInt64(&m.l1Misses, 0)
}

// ClearL2Cache clears the L2 cache and resets stats.
func (m *Manager) ClearL2Cache() {
	if m.l2Cache != nil {
		m.l2Cache.Clear()
	}
	atomic.StoreInt64(&m.l2Hits, 0)
	atomic.StoreInt64(&m.l2Misses, 0)
}

// ClearAllCaches clears all cache layers.
func (m *Manager) ClearAllCaches() {
	m.ClearL1Cache()
	m.ClearL2Cache()
}

// GetL2Cache returns the L2 cache instance.
func (m *Manager) GetL2Cache() *L2Cache {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.l2Cache
}

// SetL2TTL sets the L2 cache TTL (0 = permanent).
func (m *Manager) SetL2TTL(hours int) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.l2Cache != nil {
		m.l2Cache.SetTTL(hours)
	}
}

// GetL2TTL returns the L2 cache TTL in hours.
func (m *Manager) GetL2TTL() int {
	m.mu.RLock()
	defer m.mu.RUnlock()
	if m.l2Cache != nil {
		return m.l2Cache.TTLHours()
	}
	return 0
}

// VacuumL2 optimizes the L2 cache database.
func (m *Manager) VacuumL2() error {
	m.mu.RLock()
	defer m.mu.RUnlock()
	if m.l2Cache != nil {
		return m.l2Cache.Vacuum()
	}
	return nil
}

// SetConfigPath sets the config file path.
func (m *Manager) SetConfigPath(path string) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.configPath = path
}

// GetConfigPath returns the config file path.
func (m *Manager) GetConfigPath() string {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.configPath
}

// GetConfig returns the current config.
func (m *Manager) GetConfig() *Config {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.config
}

// ReloadConfig reloads configuration from file.
func (m *Manager) ReloadConfig() error {
	m.mu.RLock()
	path := m.configPath
	m.mu.RUnlock()

	if path == "" {
		return fmt.Errorf("no config path set")
	}

	cfg, err := LoadConfig(path)
	if err != nil {
		return err
	}

	// Apply new configuration
	m.mu.Lock()
	m.config = cfg
	m.fallbackStrategy = cfg.GeoIP.Strategy
	m.timeout = time.Duration(cfg.GeoIP.TimeoutMs) * time.Millisecond
	m.mu.Unlock()

	return nil
}

// SaveConfigToFile saves current configuration to file.
func (m *Manager) SaveConfigToFile() error {
	m.mu.RLock()
	path := m.configPath
	cfg := m.buildConfig()
	m.mu.RUnlock()

	if path == "" {
		return fmt.Errorf("no config path set")
	}

	return SaveConfig(cfg, path)
}

// buildConfig builds a Config from current state.
func (m *Manager) buildConfig() *Config {
	cfg := DefaultConfig()

	cfg.GeoIP.Strategy = m.fallbackStrategy
	cfg.GeoIP.TimeoutMs = int(m.timeout.Milliseconds())

	cfg.GeoIP.Local.Enabled = m.localDBEnabled
	cfg.GeoIP.Local.CityDB = m.localCityPath
	cfg.GeoIP.Local.IspDB = m.localISPPath

	if m.l2Cache != nil {
		cfg.GeoIP.Cache.L2.Enabled = true
		cfg.GeoIP.Cache.L2.Path = m.l2Cache.Path()
		cfg.GeoIP.Cache.L2.TTLHours = m.l2Cache.TTLHours()
	}

	cfg.GeoIP.RemoteProviders = make([]RemoteProviderConfig, 0, len(m.remoteProviders))
	for _, entry := range m.remoteProviders {
		cfg.GeoIP.RemoteProviders = append(cfg.GeoIP.RemoteProviders, RemoteProviderConfig{
			Name:         entry.Name,
			Enabled:      entry.Enabled,
			URL:          entry.URL,
			Priority:     entry.Priority,
			FieldMapping: FromFieldMapping(entry.Mapping),
		})
	}

	return cfg
}

// Close closes all resources.
func (m *Manager) Close() {
	m.mu.Lock()
	defer m.mu.Unlock()

	m.l1Cache.Close()
	if m.l2Cache != nil {
		m.l2Cache.Close()
	}
	if m.localProvider != nil {
		m.localProvider.Close()
	}
	for _, entry := range m.remoteProviders {
		entry.Provider.Close()
	}
}
