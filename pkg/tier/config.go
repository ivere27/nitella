package tier

import (
	"os"

	"gopkg.in/yaml.v3"
)

// RPCConfig defines RPC rate limits for a tier
type RPCConfig struct {
	RequestsPerSecond int `yaml:"requests_per_second" json:"requests_per_second"`
	BurstSize         int `yaml:"burst_size" json:"burst_size"`
	MaxStreams        int `yaml:"max_streams" json:"max_streams"`
}

// StreamingConfig defines streaming rate limits for a tier
type StreamingConfig struct {
	IntervalSeconds int    `yaml:"interval_seconds" json:"interval_seconds"` // 0 = realtime
	Mode            string `yaml:"mode" json:"mode"`                         // "conflation" or "realtime"
}

// ProxyManagementConfig defines proxy configuration storage limits
type ProxyManagementConfig struct {
	Enabled             bool `yaml:"enabled" json:"enabled"`
	MaxProxies          int  `yaml:"max_proxies" json:"max_proxies"`                       // 0 = Unlimited
	MaxRevisionsPerProxy int  `yaml:"max_revisions_per_proxy" json:"max_revisions_per_proxy"` // 0 = Unlimited
	MaxStorageKB        int  `yaml:"max_storage_kb" json:"max_storage_kb"`
	TTLDays             int  `yaml:"ttl_days" json:"ttl_days"`
}

// TemplateSyncConfig is deprecated, use ProxyManagementConfig instead
// Kept for backwards compatibility
type TemplateSyncConfig = ProxyManagementConfig

// AuditConfig defines audit log limits
type AuditConfig struct {
	MaxLogs       int `yaml:"max_logs" json:"max_logs"`             // 0 = Unlimited
	RetentionDays int `yaml:"retention_days" json:"retention_days"` // Auto-delete after N days
}

// LogsConfig defines encrypted logs storage limits
type LogsConfig struct {
	MaxLogs       int `yaml:"max_logs" json:"max_logs"`             // 0 = Unlimited
	RetentionDays int `yaml:"retention_days" json:"retention_days"` // Auto-delete after N days
}

// TierConfig defines limits and features for a tier
type TierConfig struct {
	ID               string                `yaml:"id" json:"id"`
	Name             string                `yaml:"name" json:"name"`
	MaxNodes         int                   `yaml:"max_nodes" json:"max_nodes"`                   // 0 = Unlimited
	MaxProxies       int                   `yaml:"max_proxies" json:"max_proxies"`               // Max proxies per node, 0 = Unlimited
	MonthlyPushLimit int                   `yaml:"monthly_push_limit" json:"monthly_push_limit"` // 0 = Unlimited
	LicensePrefix    string                `yaml:"license_prefix" json:"license_prefix"`
	RPC              RPCConfig             `yaml:"rpc" json:"rpc"`
	Streaming        StreamingConfig       `yaml:"streaming" json:"streaming"`
	ProxyManagement  ProxyManagementConfig `yaml:"proxy_management" json:"proxy_management"`
	TemplateSync     TemplateSyncConfig    `yaml:"template_sync" json:"template_sync"` // Deprecated: use ProxyManagement
	Audit            AuditConfig           `yaml:"audit" json:"audit"`
	Logs             LogsConfig            `yaml:"logs" json:"logs"`
}

// Config holds all tier configurations
type Config struct {
	Tiers []TierConfig `yaml:"tiers" json:"tiers"`
}

// LoadConfig loads tiers from a YAML file
func LoadConfig(path string) (*Config, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var cfg Config
	if err := yaml.Unmarshal(data, &cfg); err != nil {
		return nil, err
	}
	return &cfg, nil
}

// GetTier finds a tier by ID
func (c *Config) GetTier(id string) *TierConfig {
	for i := range c.Tiers {
		if c.Tiers[i].ID == id {
			return &c.Tiers[i]
		}
	}
	return nil
}

// GetTierOrDefault returns the tier config or default "free" tier
func (c *Config) GetTierOrDefault(id string) *TierConfig {
	tier := c.GetTier(id)
	if tier != nil {
		return tier
	}
	// Return free tier as default
	return c.GetTier("free")
}

// DefaultConfig returns the fallback hardcoded config
func DefaultConfig() *Config {
	return &Config{
		Tiers: []TierConfig{
			{
				ID:               "free",
				Name:             "Starter",
				MaxNodes:         3,
				MaxProxies:       5,
				MonthlyPushLimit: 10,
				LicensePrefix:    "",
				RPC:              RPCConfig{RequestsPerSecond: 10, BurstSize: 20, MaxStreams: 2},
				Streaming:        StreamingConfig{IntervalSeconds: 5, Mode: "conflation"},
				ProxyManagement:  ProxyManagementConfig{Enabled: true, MaxProxies: 3, MaxRevisionsPerProxy: 1, MaxStorageKB: 100, TTLDays: 7},
				Audit:            AuditConfig{MaxLogs: 1000, RetentionDays: 7},
				Logs:             LogsConfig{MaxLogs: 10000, RetentionDays: 7},
			},
			{
				ID:               "pro",
				Name:             "Pro",
				MaxNodes:         20,
				MaxProxies:       20,
				MonthlyPushLimit: 500,
				LicensePrefix:    "PRO",
				RPC:              RPCConfig{RequestsPerSecond: 100, BurstSize: 200, MaxStreams: 10},
				Streaming:        StreamingConfig{IntervalSeconds: 1, Mode: "conflation"},
				ProxyManagement:  ProxyManagementConfig{Enabled: true, MaxProxies: 20, MaxRevisionsPerProxy: 5, MaxStorageKB: 1024, TTLDays: 30},
				Audit:            AuditConfig{MaxLogs: 100000, RetentionDays: 90},
				Logs:             LogsConfig{MaxLogs: 1000000, RetentionDays: 30},
			},
			{
				ID:               "business",
				Name:             "Business",
				MaxNodes:         0, // Unlimited
				MaxProxies:       0, // Unlimited
				MonthlyPushLimit: 0, // Unlimited
				LicensePrefix:    "BIZ",
				RPC:              RPCConfig{RequestsPerSecond: 1000, BurstSize: 2000, MaxStreams: 100},
				Streaming:        StreamingConfig{IntervalSeconds: 0, Mode: "realtime"},
				ProxyManagement:  ProxyManagementConfig{Enabled: true, MaxProxies: 0, MaxRevisionsPerProxy: 0, MaxStorageKB: 0, TTLDays: 365},
				Audit:            AuditConfig{MaxLogs: 0, RetentionDays: 365},
				Logs:             LogsConfig{MaxLogs: 0, RetentionDays: 365},
			},
		},
	}
}

// TierLimits returns the limits for a specific tier
type TierLimits struct {
	MaxNodes         int
	MaxProxies       int
	MonthlyPushLimit int
	// RPC
	RPSLimit   int
	BurstSize  int
	MaxStreams int
	// Proxy Management
	MaxProxyConfigs      int
	MaxRevisionsPerProxy int
	MaxStorageKB         int
	ProxyTTLDays         int
	// Audit
	MaxAuditLogs       int
	AuditRetentionDays int
	// Logs
	MaxLogs           int
	LogsRetentionDays int
}

// GetLimits returns TierLimits for easier access
func (t *TierConfig) GetLimits() TierLimits {
	return TierLimits{
		MaxNodes:             t.MaxNodes,
		MaxProxies:           t.MaxProxies,
		MonthlyPushLimit:     t.MonthlyPushLimit,
		RPSLimit:             t.RPC.RequestsPerSecond,
		BurstSize:            t.RPC.BurstSize,
		MaxStreams:           t.RPC.MaxStreams,
		MaxProxyConfigs:      t.ProxyManagement.MaxProxies,
		MaxRevisionsPerProxy: t.ProxyManagement.MaxRevisionsPerProxy,
		MaxStorageKB:         t.ProxyManagement.MaxStorageKB,
		ProxyTTLDays:         t.ProxyManagement.TTLDays,
		MaxAuditLogs:         t.Audit.MaxLogs,
		AuditRetentionDays:   t.Audit.RetentionDays,
		MaxLogs:              t.Logs.MaxLogs,
		LogsRetentionDays:    t.Logs.RetentionDays,
	}
}

// IsUnlimited checks if a limit value means unlimited (0 or negative)
func IsUnlimited(limit int) bool {
	return limit <= 0
}

// CheckNodeLimit checks if adding a node would exceed the tier limit
func (t *TierConfig) CheckNodeLimit(currentCount int) bool {
	if IsUnlimited(t.MaxNodes) {
		return true
	}
	return currentCount < t.MaxNodes
}

// CheckProxyLimit checks if adding a proxy would exceed the tier limit
func (t *TierConfig) CheckProxyLimit(currentCount int) bool {
	if IsUnlimited(t.MaxProxies) {
		return true
	}
	return currentCount < t.MaxProxies
}

// CheckPushLimit checks if sending a push would exceed the monthly limit
func (t *TierConfig) CheckPushLimit(currentCount int) bool {
	if IsUnlimited(t.MonthlyPushLimit) {
		return true
	}
	return currentCount < t.MonthlyPushLimit
}

// CheckProxyConfigLimit checks if adding a proxy config would exceed the tier limit
func (t *TierConfig) CheckProxyConfigLimit(currentCount int) bool {
	if IsUnlimited(t.ProxyManagement.MaxProxies) {
		return true
	}
	return currentCount < t.ProxyManagement.MaxProxies
}

// CheckRevisionLimit checks if adding a revision would exceed the tier limit
func (t *TierConfig) CheckRevisionLimit(currentCount int) bool {
	if IsUnlimited(t.ProxyManagement.MaxRevisionsPerProxy) {
		return true
	}
	return currentCount < t.ProxyManagement.MaxRevisionsPerProxy
}

// CheckAuditLogLimit checks if adding an audit log would exceed the tier limit
func (t *TierConfig) CheckAuditLogLimit(currentCount int) bool {
	if IsUnlimited(t.Audit.MaxLogs) {
		return true
	}
	return currentCount < t.Audit.MaxLogs
}

// CheckLogLimit checks if adding a log would exceed the tier limit
func (t *TierConfig) CheckLogLimit(currentCount int) bool {
	if IsUnlimited(t.Logs.MaxLogs) {
		return true
	}
	return currentCount < t.Logs.MaxLogs
}
