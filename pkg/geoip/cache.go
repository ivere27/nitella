package geoip

import (
	"database/sql"
	"sync"
	"time"

	log "github.com/ivere27/nitella/pkg/log"

	pbCommon "github.com/ivere27/nitella/pkg/api/common"
	_ "github.com/mattn/go-sqlite3"
)

type Cache interface {
	Get(ip string) *pbCommon.GeoInfo
	Put(ip string, info *pbCommon.GeoInfo)
	Close()
	Size() int64
}

// ============================================================================
// L1 Cache (Memory)
// ============================================================================

type L1Cache struct {
	data  map[string]*l1Entry
	limit int
	mu    sync.RWMutex
}

type l1Entry struct {
	info      *pbCommon.GeoInfo
	expiresAt time.Time
}

func NewL1Cache(limit int) *L1Cache {
	return &L1Cache{
		data:  make(map[string]*l1Entry),
		limit: limit,
	}
}

func (c *L1Cache) Get(ip string) *pbCommon.GeoInfo {
	c.mu.RLock()
	defer c.mu.RUnlock()

	if entry, ok := c.data[ip]; ok {
		if time.Now().Before(entry.expiresAt) {
			return entry.info
		}
	}
	return nil
}

func (c *L1Cache) Put(ip string, info *pbCommon.GeoInfo) {
	c.mu.Lock()
	defer c.mu.Unlock()

	// Evict if full (simple random/map iteration eviction)
	if len(c.data) >= c.limit {
		for k := range c.data {
			delete(c.data, k)
			break
		}
	}

	c.data[ip] = &l1Entry{
		info:      info,
		expiresAt: time.Now().Add(1 * time.Hour), // TTL 1h
	}
}

func (c *L1Cache) Close() {
	c.mu.Lock()
	c.data = nil
	c.mu.Unlock()
}

func (c *L1Cache) Size() int64 {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return int64(len(c.data))
}

// ============================================================================
// L2 Cache (SQLite)
// ============================================================================

type L2Cache struct {
	db       *sql.DB
	path     string
	ttlHours int // 0 = permanent (no expiration)
}

// NewL2Cache creates a new L2 cache. ttlHours=0 means permanent (no expiration).
func NewL2Cache(dbPath string, ttlHours int) (*L2Cache, error) {
	db, err := sql.Open("sqlite3", dbPath)
	if err != nil {
		return nil, err
	}

	// Enable WAL mode for better concurrent performance
	db.Exec("PRAGMA journal_mode=WAL")

	query := `
	CREATE TABLE IF NOT EXISTS geoip_cache (
		ip TEXT PRIMARY KEY,
		country TEXT,
		country_code TEXT,
		region TEXT,
		region_name TEXT,
		city TEXT,
		zip TEXT,
		latitude REAL,
		longitude REAL,
		timezone TEXT,
		isp TEXT,
		org TEXT,
		as_info TEXT,
		source TEXT,
		created_at INTEGER
	);
	CREATE INDEX IF NOT EXISTS idx_cache_created ON geoip_cache(created_at);
	`
	if _, err := db.Exec(query); err != nil {
		return nil, err
	}

	return &L2Cache{db: db, path: dbPath, ttlHours: ttlHours}, nil
}

func (c *L2Cache) Get(ip string) *pbCommon.GeoInfo {
	row := c.db.QueryRow(`
		SELECT country, country_code, region, region_name, city, zip, latitude, longitude, timezone, isp, org, as_info, source, created_at
		FROM geoip_cache WHERE ip = ?`, ip)

	var country, countryCode, region, regionName, city, zip, timezone, isp, org, asInfo, source string
	var lat, lon float64
	var createdAt int64

	if err := row.Scan(&country, &countryCode, &region, &regionName, &city, &zip, &lat, &lon, &timezone, &isp, &org, &asInfo, &source, &createdAt); err != nil {
		return nil
	}

	// TTL Check (ttlHours=0 means permanent, no expiration)
	if c.ttlHours > 0 {
		ttl := time.Duration(c.ttlHours) * time.Hour
		if time.Since(time.Unix(createdAt, 0)) > ttl {
			return nil
		}
	}

	return &pbCommon.GeoInfo{
		Country:     country,
		CountryCode: countryCode,
		Region:      region,
		RegionName:  regionName,
		City:        city,
		Zip:         zip,
		Latitude:    lat,
		Longitude:   lon,
		Timezone:    timezone,
		Isp:         isp,
		Org:         org,
		As:          asInfo,
		Source:      source,
	}
}

// Path returns the database file path.
func (c *L2Cache) Path() string {
	return c.path
}

// TTLHours returns the TTL in hours (0 = permanent).
func (c *L2Cache) TTLHours() int {
	return c.ttlHours
}

// SetTTL updates the TTL setting.
func (c *L2Cache) SetTTL(hours int) {
	c.ttlHours = hours
}

// Clear removes all entries from the cache.
func (c *L2Cache) Clear() error {
	_, err := c.db.Exec("DELETE FROM geoip_cache")
	return err
}

// Vacuum optimizes the database.
func (c *L2Cache) Vacuum() error {
	_, err := c.db.Exec("VACUUM")
	return err
}

func (c *L2Cache) Put(ip string, info *pbCommon.GeoInfo) {
	_, err := c.db.Exec(`
		INSERT OR REPLACE INTO geoip_cache (
			ip, country, country_code, region, region_name, city, zip, latitude, longitude, timezone, isp, org, as_info, source, created_at
		) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
	`, ip, info.Country, info.CountryCode, info.Region, info.RegionName, info.City, info.Zip, info.Latitude, info.Longitude, info.Timezone, info.Isp, info.Org, info.As, info.Source, time.Now().Unix())

	if err != nil {
		log.Printf("L2 Cache Put Error: %v", err)
	}
}

func (c *L2Cache) Close() {
	c.db.Close()
}

func (c *L2Cache) Size() int64 {
	var count int64
	c.db.QueryRow("SELECT COUNT(*) FROM geoip_cache").Scan(&count)
	return count
}
