// Package stats provides connection statistics tracking for the reverse proxy.
// It records raw connection events and maintains aggregated statistics
// for IPs and geographic data. All operations are asynchronous to avoid
// impacting proxy performance.
package stats

import (
	"time"
)

// ConnectionLog stores raw connection events - high volume, short retention.
// This table is automatically pruned based on retention policy.
type ConnectionLog struct {
	ID         int64     `xorm:"pk autoincr"`
	SourceIP   string    `xorm:"index notnull"`
	SourcePort int32     `xorm:"notnull"`
	FirstSeen  time.Time `xorm:"index created notnull"`
	LastSeen   time.Time `xorm:"updated notnull"`
	BytesIn    int64     `xorm:"notnull default 0"`
	BytesOut   int64     `xorm:"notnull default 0"`
	DurationMs int64     `xorm:"notnull default 0"` // Connection duration in milliseconds
	Action     int32     `xorm:"notnull default 0"` // 0=ALLOW, 1=BLOCK, 2=MOCK
	RuleID     string    `xorm:"varchar(64)"`       // Rule that matched (if any)
	GeoCountry string    `xorm:"varchar(8) index"`
	GeoCity    string    `xorm:"varchar(128)"`
	GeoISP     string    `xorm:"varchar(256)"`
}

// TableName returns the table name for XORM
func (ConnectionLog) TableName() string {
	return "connection_log"
}

// IPStats stores aggregated statistics per source IP.
// This table has medium volume and longer retention.
type IPStats struct {
	ID              int64     `xorm:"pk autoincr"`
	SourceIP        string    `xorm:"unique index notnull"`
	FirstSeen       time.Time `xorm:"notnull"`
	LastSeen        time.Time `xorm:"index notnull"`
	ConnectionCount int64     `xorm:"notnull default 0"`
	TotalBytesIn    int64     `xorm:"notnull default 0"`
	TotalBytesOut   int64     `xorm:"notnull default 0"`
	TotalDurationMs int64     `xorm:"notnull default 0"` // Sum of all durations
	BlockedCount    int64     `xorm:"notnull default 0"`
	AllowedCount    int64     `xorm:"notnull default 0"`
	// Cached GeoIP data (from most recent lookup)
	GeoCountry string `xorm:"varchar(8)"`
	GeoCity    string `xorm:"varchar(128)"`
	GeoISP     string `xorm:"varchar(256)"`
}

// TableName returns the table name for XORM
func (IPStats) TableName() string {
	return "ip_stats"
}

// AvgDurationMs returns the average connection duration in milliseconds.
func (s *IPStats) AvgDurationMs() float64 {
	if s.ConnectionCount == 0 {
		return 0
	}
	return float64(s.TotalDurationMs) / float64(s.ConnectionCount)
}

// GeoStats stores aggregated statistics by geographic dimension.
// Type can be "country", "city", or "isp".
type GeoStats struct {
	ID              int64     `xorm:"pk autoincr"`
	Type            string    `xorm:"varchar(16) index notnull"`                   // "country", "city", "isp"
	Value           string    `xorm:"varchar(256) notnull unique(type_value_idx)"` // The actual value
	ConnectionCount int64     `xorm:"notnull default 0"`
	UniqueIPs       int64     `xorm:"notnull default 0"`
	TotalBytesIn    int64     `xorm:"notnull default 0"`
	TotalBytesOut   int64     `xorm:"notnull default 0"`
	BlockedCount    int64     `xorm:"notnull default 0"`
	LastUpdated     time.Time `xorm:"updated notnull"`
}

// TableName returns the table name for XORM
func (GeoStats) TableName() string {
	return "geo_stats"
}

// StatsConfig stores configuration key-value pairs.
type StatsConfig struct {
	ID    int64  `xorm:"pk autoincr"`
	Key   string `xorm:"varchar(64) unique notnull"`
	Value string `xorm:"text notnull"`
}

// TableName returns the table name for XORM
func (StatsConfig) TableName() string {
	return "stats_config"
}

// Configuration keys
const (
	ConfigKeyEnabled                = "enabled"
	ConfigKeyRawRetentionHours      = "raw_retention_hours"
	ConfigKeyStatsRetentionDays     = "stats_retention_days"
	ConfigKeyGeoRetentionDays       = "geo_retention_days"
	ConfigKeyAggregationIntervalSec = "aggregation_interval_sec"
	ConfigKeySamplingRate           = "sampling_rate"
)

// Default configuration values
const (
	DefaultRawRetentionHours      = 24
	DefaultStatsRetentionDays     = 30
	DefaultGeoRetentionDays       = 90
	DefaultAggregationIntervalSec = 60
	DefaultSamplingRate           = 1 // Log every connection
)
