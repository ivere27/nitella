package geoip

import (
	"fmt"
	"os"
	"strings"

	"gopkg.in/yaml.v3"
)

// Config represents the GeoIP service configuration.
type Config struct {
	GeoIP GeoIPConfig `yaml:"geoip"`
}

// GeoIPConfig contains all GeoIP service settings.
type GeoIPConfig struct {
	Strategy  []string `yaml:"strategy"`   // e.g., ["l1", "l2", "local", "remote"]
	TimeoutMs int      `yaml:"timeout_ms"` // Lookup timeout in milliseconds

	Local LocalConfig `yaml:"local"`
	Cache CacheConfig `yaml:"cache"`

	RemoteProviders []RemoteProviderConfig `yaml:"remote_providers"`

	Admin AdminConfig `yaml:"admin"`
}

// LocalConfig configures local MaxMind database settings.
type LocalConfig struct {
	Enabled bool   `yaml:"enabled"`
	CityDB  string `yaml:"city_db"`
	IspDB   string `yaml:"isp_db"`
}

// CacheConfig configures caching layers.
type CacheConfig struct {
	L1 L1CacheConfig `yaml:"l1"`
	L2 L2CacheConfig `yaml:"l2"`
}

// L1CacheConfig configures in-memory L1 cache.
type L1CacheConfig struct {
	Capacity int `yaml:"capacity"`
	TTLHours int `yaml:"ttl_hours"`
}

// L2CacheConfig configures SQLite L2 cache.
// TTLHours=0 means permanent (no expiration).
type L2CacheConfig struct {
	Enabled  bool   `yaml:"enabled"`
	Path     string `yaml:"path"`
	TTLHours int    `yaml:"ttl_hours"` // 0 = permanent (no expiration)
}

// RemoteProviderConfig configures an HTTP GeoIP provider.
type RemoteProviderConfig struct {
	Name         string                  `yaml:"name"`
	Enabled      bool                    `yaml:"enabled"`
	URL          string                  `yaml:"url"`
	Priority     int                     `yaml:"priority"`
	FieldMapping FieldMappingConfig      `yaml:"field_mapping"`
}

// FieldMappingConfig maps JSON response fields to GeoInfo fields.
type FieldMappingConfig struct {
	Country     []string `yaml:"country"`
	CountryCode []string `yaml:"country_code"`
	Region      []string `yaml:"region"`
	RegionName  []string `yaml:"region_name"`
	City        []string `yaml:"city"`
	Zip         []string `yaml:"zip"`
	Timezone    []string `yaml:"timezone"`
	Latitude    []string `yaml:"latitude"`
	Longitude   []string `yaml:"longitude"`
	Isp         []string `yaml:"isp"`
	Org         []string `yaml:"org"`
	As          []string `yaml:"as"`
}

// AdminConfig configures the admin service.
type AdminConfig struct {
	Enabled bool   `yaml:"enabled"`
	Port    int    `yaml:"port"`
	Token   string `yaml:"token"`
}

// DefaultConfig returns a default configuration.
func DefaultConfig() *Config {
	return &Config{
		GeoIP: GeoIPConfig{
			Strategy:  []string{"l1", "l2", "local", "remote"},
			TimeoutMs: 3000,
			Local: LocalConfig{
				Enabled: false,
				CityDB:  "",
				IspDB:   "",
			},
			Cache: CacheConfig{
				L1: L1CacheConfig{
					Capacity: 10000,
					TTLHours: 1,
				},
				L2: L2CacheConfig{
					Enabled:  true,
					Path:     "geoip_cache.db",
					TTLHours: 24, // 0 = permanent (no expiration)
				},
			},
			RemoteProviders: []RemoteProviderConfig{
				{
					Name:     "ip-whois",
					Enabled:  true,
					URL:      "https://ipwhois.app/json/%s",
					Priority: 1,
					FieldMapping: FieldMappingConfig{
						Country:     []string{"country"},
						CountryCode: []string{"country_code"},
						Region:      []string{"region_code"},
						RegionName:  []string{"region"},
						City:        []string{"city"},
						Zip:         []string{"postal"},
						Timezone:    []string{"timezone_id"},
						Latitude:    []string{"latitude"},
						Longitude:   []string{"longitude"},
						Isp:         []string{"connection.isp"},
						Org:         []string{"connection.org"},
						As:          []string{"connection.asn"},
					},
				},
				{
					Name:     "free-ip-api",
					Enabled:  true,
					URL:      "https://freeipapi.com/api/json/%s",
					Priority: 2,
					FieldMapping: FieldMappingConfig{
						Country:     []string{"countryName"},
						CountryCode: []string{"countryCode"},
						Region:      []string{"regionName"},
						RegionName:  []string{"regionName"},
						City:        []string{"cityName"},
						Zip:         []string{"zipCode"},
						Timezone:    []string{"timeZone"},
						Latitude:    []string{"latitude"},
						Longitude:   []string{"longitude"},
					},
				},
			},
			Admin: AdminConfig{
				Enabled: false,
				Port:    50053,
				Token:   "",
			},
		},
	}
}

// LoadConfig loads configuration from a YAML file.
func LoadConfig(path string) (*Config, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("failed to read config file: %w", err)
	}

	// Expand environment variables
	content := os.ExpandEnv(string(data))

	cfg := DefaultConfig()
	if err := yaml.Unmarshal([]byte(content), cfg); err != nil {
		return nil, fmt.Errorf("failed to parse config: %w", err)
	}

	// Expand home directory paths
	cfg.GeoIP.Local.CityDB = expandPath(cfg.GeoIP.Local.CityDB)
	cfg.GeoIP.Local.IspDB = expandPath(cfg.GeoIP.Local.IspDB)
	cfg.GeoIP.Cache.L2.Path = expandPath(cfg.GeoIP.Cache.L2.Path)

	return cfg, nil
}

// SaveConfig saves configuration to a YAML file.
func SaveConfig(cfg *Config, path string) error {
	data, err := yaml.Marshal(cfg)
	if err != nil {
		return fmt.Errorf("failed to marshal config: %w", err)
	}

	if err := os.WriteFile(path, data, 0600); err != nil {
		return fmt.Errorf("failed to write config file: %w", err)
	}

	return nil
}

// ToFieldMapping converts FieldMappingConfig to FieldMapping.
func (f *FieldMappingConfig) ToFieldMapping() *FieldMapping {
	return &FieldMapping{
		Country:     f.Country,
		CountryCode: f.CountryCode,
		Region:      f.Region,
		RegionName:  f.RegionName,
		City:        f.City,
		Zip:         f.Zip,
		Timezone:    f.Timezone,
		Latitude:    f.Latitude,
		Longitude:   f.Longitude,
		Isp:         f.Isp,
		Org:         f.Org,
		As:          f.As,
	}
}

// FromFieldMapping converts FieldMapping to FieldMappingConfig.
func FromFieldMapping(m *FieldMapping) FieldMappingConfig {
	if m == nil {
		return FieldMappingConfig{}
	}
	return FieldMappingConfig{
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

// expandPath expands ~ to home directory.
func expandPath(path string) string {
	if path == "" {
		return path
	}
	if strings.HasPrefix(path, "~/") {
		home, err := os.UserHomeDir()
		if err == nil {
			return strings.Replace(path, "~", home, 1)
		}
	}
	return path
}
