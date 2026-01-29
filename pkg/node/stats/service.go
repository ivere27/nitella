// Package stats provides connection statistics tracking for the reverse proxy.
package stats

import (
	"math"
	"strconv"
	"sync"
	"sync/atomic"
	"time"

	pbCommon "github.com/ivere27/nitella/pkg/api/common"
	_ "github.com/mattn/go-sqlite3"
	"xorm.io/xorm"
)

// ConnectionEvent represents a single connection for statistics recording.
type ConnectionEvent struct {
	SourceIP   string
	SourcePort int32
	StartTime  time.Time
	EndTime    time.Time
	BytesIn    int64
	BytesOut   int64
	Action     int32 // 0=ALLOW, 1=BLOCK, 2=MOCK
	RuleID     string
	Geo        *pbCommon.GeoInfo
}

// StatsService manages connection statistics collection and retrieval.
// All operations are thread-safe and non-blocking.
type StatsService struct {
	db      *xorm.Engine
	enabled atomic.Bool
	eventCh chan *ConnectionEvent
	quit    chan struct{}
	wg      sync.WaitGroup

	// Configuration (protected by mu)
	mu                     sync.RWMutex
	rawRetentionHours      int
	statsRetentionDays     int
	geoRetentionDays       int
	aggregationIntervalSec int
	samplingRate           int
	sampleCounter          atomic.Int64

	// Batch processing
	batchSize     int
	flushInterval time.Duration
}

// NewStatsService creates a new statistics service.
// The service is disabled by default.
func NewStatsService(dbPath string) (*StatsService, error) {
	engine, err := xorm.NewEngine("sqlite3", dbPath+"?_journal_mode=WAL&_busy_timeout=5000")
	if err != nil {
		return nil, err
	}

	// Sync schema
	if err := engine.Sync2(new(ConnectionLog), new(IPStats), new(GeoStats), new(StatsConfig)); err != nil {
		engine.Close()
		return nil, err
	}

	s := &StatsService{
		db:                     engine,
		eventCh:                make(chan *ConnectionEvent, 10000), // Large buffer
		quit:                   make(chan struct{}),
		rawRetentionHours:      DefaultRawRetentionHours,
		statsRetentionDays:     DefaultStatsRetentionDays,
		geoRetentionDays:       DefaultGeoRetentionDays,
		aggregationIntervalSec: DefaultAggregationIntervalSec,
		samplingRate:           DefaultSamplingRate,
		batchSize:              100,
		flushInterval:          time.Second,
	}

	// Load configuration from DB
	s.loadConfig()

	return s, nil
}

// loadConfig loads configuration from the database.
func (s *StatsService) loadConfig() {
	var configs []StatsConfig
	s.db.Find(&configs)

	s.mu.Lock()
	defer s.mu.Unlock()

	for _, cfg := range configs {
		switch cfg.Key {
		case ConfigKeyEnabled:
			s.enabled.Store(cfg.Value == "true")
		case ConfigKeyRawRetentionHours:
			if v, err := strconv.Atoi(cfg.Value); err == nil && v > 0 {
				s.rawRetentionHours = v
			}
		case ConfigKeyStatsRetentionDays:
			if v, err := strconv.Atoi(cfg.Value); err == nil && v > 0 {
				s.statsRetentionDays = v
			}
		case ConfigKeyGeoRetentionDays:
			if v, err := strconv.Atoi(cfg.Value); err == nil && v > 0 {
				s.geoRetentionDays = v
			}
		case ConfigKeyAggregationIntervalSec:
			if v, err := strconv.Atoi(cfg.Value); err == nil && v > 0 {
				s.aggregationIntervalSec = v
			}
		case ConfigKeySamplingRate:
			if v, err := strconv.Atoi(cfg.Value); err == nil && v > 0 {
				s.samplingRate = v
			}
		}
	}
}

// saveConfigValue saves a single configuration value to the database.
func (s *StatsService) saveConfigValue(key, value string) error {
	cfg := &StatsConfig{Key: key, Value: value}
	has, err := s.db.Where("key = ?", key).Get(&StatsConfig{})
	if err != nil {
		return err
	}
	if has {
		_, err = s.db.Where("key = ?", key).Update(cfg)
	} else {
		_, err = s.db.Insert(cfg)
	}
	return err
}

// Start begins the background workers for event processing and cleanup.
func (s *StatsService) Start() error {
	// Event processing worker
	s.wg.Add(1)
	go s.processEvents()

	// Cleanup worker
	s.wg.Add(1)
	go s.cleanupWorker()

	return nil
}

// Stop gracefully shuts down the service.
func (s *StatsService) Stop() {
	close(s.quit)
	s.wg.Wait()
	if s.db != nil {
		s.db.Close()
	}
}

// SetEnabled enables or disables statistics collection.
func (s *StatsService) SetEnabled(enabled bool) error {
	s.enabled.Store(enabled)
	return s.saveConfigValue(ConfigKeyEnabled, strconv.FormatBool(enabled))
}

// IsEnabled returns whether statistics collection is enabled.
func (s *StatsService) IsEnabled() bool {
	return s.enabled.Load()
}

// RecordConnection records a connection event.
// This method is non-blocking - if the buffer is full, the event is dropped.
func (s *StatsService) RecordConnection(event *ConnectionEvent) {
	if !s.enabled.Load() {
		return
	}

	// Sampling
	sampleRate := s.getSamplingRate()
	if sampleRate > 1 {
		count := s.sampleCounter.Add(1)
		if count%int64(sampleRate) != 0 {
			return
		}
	}

	// Non-blocking send
	select {
	case s.eventCh <- event:
	default:
		// Buffer full, drop event
	}
}

func (s *StatsService) getSamplingRate() int {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.samplingRate
}

// processEvents is the background worker that processes connection events.
func (s *StatsService) processEvents() {
	defer s.wg.Done()

	batch := make([]*ConnectionEvent, 0, s.batchSize)
	ticker := time.NewTicker(s.flushInterval)
	defer ticker.Stop()

	for {
		select {
		case <-s.quit:
			// Flush remaining
			if len(batch) > 0 {
				s.processBatch(batch)
			}
			return

		case event := <-s.eventCh:
			batch = append(batch, event)
			if len(batch) >= s.batchSize {
				s.processBatch(batch)
				batch = make([]*ConnectionEvent, 0, s.batchSize)
			}

		case <-ticker.C:
			if len(batch) > 0 {
				s.processBatch(batch)
				batch = make([]*ConnectionEvent, 0, s.batchSize)
			}
		}
	}
}

// processBatch processes a batch of connection events.
func (s *StatsService) processBatch(events []*ConnectionEvent) {
	if len(events) == 0 {
		return
	}

	session := s.db.NewSession()
	defer session.Close()

	if err := session.Begin(); err != nil {
		return
	}

	// Track unique IPs and geo values for aggregation
	ipUpdates := make(map[string]*ipUpdateData)
	geoUpdates := make(map[string]*geoUpdateData) // key: type:value

	for _, event := range events {
		// Insert raw log
		log := &ConnectionLog{
			SourceIP:   event.SourceIP,
			SourcePort: event.SourcePort,
			FirstSeen:  event.StartTime,
			LastSeen:   event.EndTime,
			BytesIn:    event.BytesIn,
			BytesOut:   event.BytesOut,
			DurationMs: event.EndTime.Sub(event.StartTime).Milliseconds(),
			Action:     event.Action,
			RuleID:     event.RuleID,
		}
		if event.Geo != nil {
			log.GeoCountry = event.Geo.Country
			log.GeoCity = event.Geo.City
			log.GeoISP = event.Geo.Isp
		}
		if _, err := session.Insert(log); err != nil {
			session.Rollback()
			return
		}

		// Accumulate IP stats
		data, ok := ipUpdates[event.SourceIP]
		if !ok {
			data = &ipUpdateData{
				firstSeen: event.StartTime,
				lastSeen:  event.EndTime,
			}
			if event.Geo != nil {
				data.geoCountry = event.Geo.Country
				data.geoCity = event.Geo.City
				data.geoISP = event.Geo.Isp
			}
			ipUpdates[event.SourceIP] = data
		}
		data.count++
		data.bytesIn += event.BytesIn
		data.bytesOut += event.BytesOut
		data.durationMs += event.EndTime.Sub(event.StartTime).Milliseconds()
		if event.Action == 1 { // BLOCK
			data.blocked++
		} else {
			data.allowed++
		}
		if event.EndTime.After(data.lastSeen) {
			data.lastSeen = event.EndTime
		}

		// Accumulate geo stats
		if event.Geo != nil {
			s.accumulateGeoStat(geoUpdates, "country", event.Geo.Country, event)
			s.accumulateGeoStat(geoUpdates, "city", event.Geo.City, event)
			s.accumulateGeoStat(geoUpdates, "isp", event.Geo.Isp, event)
		}
	}

	// Update IP stats
	for ip, data := range ipUpdates {
		s.updateIPStats(session, ip, data)
	}

	// Update geo stats
	for _, data := range geoUpdates {
		s.updateGeoStats(session, data)
	}

	if err := session.Commit(); err != nil {
		session.Rollback()
	}
}

type ipUpdateData struct {
	count      int64
	bytesIn    int64
	bytesOut   int64
	durationMs int64
	blocked    int64
	allowed    int64
	firstSeen  time.Time
	lastSeen   time.Time
	geoCountry string
	geoCity    string
	geoISP     string
}

type geoUpdateData struct {
	geoType   string
	value     string
	count     int64
	bytesIn   int64
	bytesOut  int64
	blocked   int64
	uniqueIPs map[string]struct{}
}

func (s *StatsService) accumulateGeoStat(updates map[string]*geoUpdateData, geoType, value string, event *ConnectionEvent) {
	if value == "" {
		return
	}
	key := geoType + ":" + value
	data, ok := updates[key]
	if !ok {
		data = &geoUpdateData{
			geoType:   geoType,
			value:     value,
			uniqueIPs: make(map[string]struct{}),
		}
		updates[key] = data
	}
	data.count++
	data.bytesIn += event.BytesIn
	data.bytesOut += event.BytesOut
	if event.Action == 1 {
		data.blocked++
	}
	data.uniqueIPs[event.SourceIP] = struct{}{}
}

func (s *StatsService) updateIPStats(session *xorm.Session, ip string, data *ipUpdateData) {
	var existing IPStats
	has, _ := session.Where("source_ip = ?", ip).Get(&existing)

	if has {
		existing.ConnectionCount += data.count
		existing.TotalBytesIn += data.bytesIn
		existing.TotalBytesOut += data.bytesOut
		existing.TotalDurationMs += data.durationMs
		existing.BlockedCount += data.blocked
		existing.AllowedCount += data.allowed
		existing.LastSeen = data.lastSeen
		// Update geo if provided
		if data.geoCountry != "" {
			existing.GeoCountry = data.geoCountry
			existing.GeoCity = data.geoCity
			existing.GeoISP = data.geoISP
		}
		session.Where("id = ?", existing.ID).Update(&existing)
	} else {
		newStats := &IPStats{
			SourceIP:        ip,
			FirstSeen:       data.firstSeen,
			LastSeen:        data.lastSeen,
			ConnectionCount: data.count,
			TotalBytesIn:    data.bytesIn,
			TotalBytesOut:   data.bytesOut,
			TotalDurationMs: data.durationMs,
			BlockedCount:    data.blocked,
			AllowedCount:    data.allowed,
			GeoCountry:      data.geoCountry,
			GeoCity:         data.geoCity,
			GeoISP:          data.geoISP,
		}
		session.Insert(newStats)
	}
}

func (s *StatsService) updateGeoStats(session *xorm.Session, data *geoUpdateData) {
	var existing GeoStats
	has, _ := session.Where("type = ? AND value = ?", data.geoType, data.value).Get(&existing)

	if has {
		existing.ConnectionCount += data.count
		existing.TotalBytesIn += data.bytesIn
		existing.TotalBytesOut += data.bytesOut
		existing.BlockedCount += data.blocked
		// UniqueIPs needs special handling - for now just add, not exact
		existing.UniqueIPs += int64(len(data.uniqueIPs))
		session.Where("id = ?", existing.ID).Update(&existing)
	} else {
		newStats := &GeoStats{
			Type:            data.geoType,
			Value:           data.value,
			ConnectionCount: data.count,
			UniqueIPs:       int64(len(data.uniqueIPs)),
			TotalBytesIn:    data.bytesIn,
			TotalBytesOut:   data.bytesOut,
			BlockedCount:    data.blocked,
		}
		session.Insert(newStats)
	}
}

// cleanupWorker periodically removes old data based on retention policies.
func (s *StatsService) cleanupWorker() {
	defer s.wg.Done()

	// Run cleanup every hour
	ticker := time.NewTicker(time.Hour)
	defer ticker.Stop()

	// Run once at startup
	s.runCleanup()

	for {
		select {
		case <-s.quit:
			return
		case <-ticker.C:
			s.runCleanup()
		}
	}
}

func (s *StatsService) runCleanup() {
	s.mu.RLock()
	rawHours := s.rawRetentionHours
	statsDays := s.statsRetentionDays
	geoDays := s.geoRetentionDays
	s.mu.RUnlock()

	// Clean raw logs
	rawCutoff := time.Now().Add(-time.Duration(rawHours) * time.Hour)
	s.db.Where("first_seen < ?", rawCutoff).Delete(new(ConnectionLog))

	// Clean IP stats
	statsCutoff := time.Now().Add(-time.Duration(statsDays) * 24 * time.Hour)
	s.db.Where("last_seen < ?", statsCutoff).Delete(new(IPStats))

	// Clean geo stats
	geoCutoff := time.Now().Add(-time.Duration(geoDays) * 24 * time.Hour)
	s.db.Where("last_updated < ?", geoCutoff).Delete(new(GeoStats))
}

// Configure updates the statistics configuration.
func (s *StatsService) Configure(enabled bool, rawRetentionHours, statsRetentionDays, geoRetentionDays, aggregationIntervalSec, samplingRate int) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.enabled.Store(enabled)

	if rawRetentionHours > 0 {
		s.rawRetentionHours = rawRetentionHours
	}
	if statsRetentionDays > 0 {
		s.statsRetentionDays = statsRetentionDays
	}
	if geoRetentionDays > 0 {
		s.geoRetentionDays = geoRetentionDays
	}
	if aggregationIntervalSec > 0 {
		s.aggregationIntervalSec = aggregationIntervalSec
	}
	if samplingRate > 0 {
		s.samplingRate = samplingRate
	}

	// Save to DB
	s.saveConfigValue(ConfigKeyEnabled, strconv.FormatBool(enabled))
	s.saveConfigValue(ConfigKeyRawRetentionHours, strconv.Itoa(s.rawRetentionHours))
	s.saveConfigValue(ConfigKeyStatsRetentionDays, strconv.Itoa(s.statsRetentionDays))
	s.saveConfigValue(ConfigKeyGeoRetentionDays, strconv.Itoa(s.geoRetentionDays))
	s.saveConfigValue(ConfigKeyAggregationIntervalSec, strconv.Itoa(s.aggregationIntervalSec))
	s.saveConfigValue(ConfigKeySamplingRate, strconv.Itoa(s.samplingRate))

	return nil
}

// GetConfig returns the current configuration.
func (s *StatsService) GetConfig() (enabled bool, rawRetentionHours, statsRetentionDays, geoRetentionDays, aggregationIntervalSec, samplingRate int) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.enabled.Load(), s.rawRetentionHours, s.statsRetentionDays, s.geoRetentionDays, s.aggregationIntervalSec, s.samplingRate
}

// RecencyWeight calculates a 0.0-1.0 weight based on time since last activity.
// Uses exponential decay with configurable half-life.
func RecencyWeight(lastSeen time.Time, halfLifeHours float64) float64 {
	if halfLifeHours <= 0 {
		halfLifeHours = 24.0 // Default 24h half-life
	}
	lambda := math.Log(2) / halfLifeHours
	ageHours := time.Since(lastSeen).Hours()
	weight := math.Exp(-lambda * ageHours)
	return math.Max(0.0, math.Min(1.0, weight))
}

// ResetTable clears a specific table.
func (s *StatsService) ResetTable(tableName string) error {
	switch tableName {
	case "raw", "connection_log":
		_, err := s.db.Exec("DELETE FROM connection_log")
		return err
	case "ip", "ip_stats":
		_, err := s.db.Exec("DELETE FROM ip_stats")
		return err
	case "geo", "geo_stats":
		_, err := s.db.Exec("DELETE FROM geo_stats")
		return err
	case "all":
		return s.ResetAll()
	default:
		return nil
	}
}

// ResetAll clears all statistics tables.
func (s *StatsService) ResetAll() error {
	s.db.Exec("DELETE FROM connection_log")
	s.db.Exec("DELETE FROM ip_stats")
	s.db.Exec("DELETE FROM geo_stats")
	return nil
}
