// Package stats provides connection statistics tracking for the reverse proxy.
package stats

import (
	"fmt"
	"time"
)

// IPStatsFilter defines filters for querying IP statistics.
type IPStatsFilter struct {
	SourceIPPrefix string  // Filter by IP prefix (e.g., "192.168.")
	Country        string  // Filter by country code
	SortBy         string  // "last_seen", "connection_count", "bytes_total", "recency"
	SortDesc       bool    // Sort descending
	Limit          int     // Max results
	Offset         int     // Pagination offset
	HalfLifeHours  float64 // For recency weight calculation
}

// IPStatsResult represents a single IP stats row with computed fields.
type IPStatsResult struct {
	IPStats
	RecencyWeight float64
}

// GetIPStats retrieves aggregated IP statistics with optional filtering.
func (s *StatsService) GetIPStats(filter *IPStatsFilter) ([]*IPStatsResult, int64, error) {
	if filter == nil {
		filter = &IPStatsFilter{}
	}
	if filter.Limit <= 0 {
		filter.Limit = 100
	}
	if filter.HalfLifeHours <= 0 {
		filter.HalfLifeHours = 24.0
	}

	// Count total
	query := s.db.NewSession()
	defer query.Close()

	if filter.SourceIPPrefix != "" {
		query = query.Where("source_ip LIKE ?", filter.SourceIPPrefix+"%")
	}
	if filter.Country != "" {
		query = query.Where("geo_country = ?", filter.Country)
	}

	total, err := query.Count(new(IPStats))
	if err != nil {
		return nil, 0, err
	}

	// Build query
	query2 := s.db.NewSession()
	defer query2.Close()

	if filter.SourceIPPrefix != "" {
		query2 = query2.Where("source_ip LIKE ?", filter.SourceIPPrefix+"%")
	}
	if filter.Country != "" {
		query2 = query2.Where("geo_country = ?", filter.Country)
	}

	// Sort
	switch filter.SortBy {
	case "connection_count":
		if filter.SortDesc {
			query2 = query2.Desc("connection_count")
		} else {
			query2 = query2.Asc("connection_count")
		}
	case "bytes_total":
		if filter.SortDesc {
			query2 = query2.Desc("total_bytes_in + total_bytes_out")
		} else {
			query2 = query2.Asc("total_bytes_in + total_bytes_out")
		}
	default: // last_seen
		if filter.SortDesc {
			query2 = query2.Desc("last_seen")
		} else {
			query2 = query2.Asc("last_seen")
		}
	}

	query2 = query2.Limit(filter.Limit, filter.Offset)

	var stats []IPStats
	if err := query2.Find(&stats); err != nil {
		return nil, 0, err
	}

	// Compute recency weight
	results := make([]*IPStatsResult, len(stats))
	for i, stat := range stats {
		results[i] = &IPStatsResult{
			IPStats:       stat,
			RecencyWeight: RecencyWeight(stat.LastSeen, filter.HalfLifeHours),
		}
	}

	// If sorting by recency, sort in Go (can't do in SQL easily)
	if filter.SortBy == "recency" {
		sortByRecency(results, filter.SortDesc)
	}

	return results, total, nil
}

func sortByRecency(results []*IPStatsResult, desc bool) {
	for i := 0; i < len(results)-1; i++ {
		for j := i + 1; j < len(results); j++ {
			shouldSwap := false
			if desc {
				shouldSwap = results[j].RecencyWeight > results[i].RecencyWeight
			} else {
				shouldSwap = results[j].RecencyWeight < results[i].RecencyWeight
			}
			if shouldSwap {
				results[i], results[j] = results[j], results[i]
			}
		}
	}
}

// GeoStatsFilter defines filters for querying geo statistics.
type GeoStatsFilter struct {
	Type   string // "country", "city", "isp"
	Limit  int
	Offset int
}

// GetGeoStats retrieves aggregated geographic statistics.
func (s *StatsService) GetGeoStats(filter *GeoStatsFilter) ([]*GeoStats, error) {
	if filter == nil {
		filter = &GeoStatsFilter{}
	}
	if filter.Limit <= 0 {
		filter.Limit = 100
	}

	query := s.db.NewSession()
	defer query.Close()

	if filter.Type != "" {
		query = query.Where("type = ?", filter.Type)
	}

	query = query.Desc("connection_count").Limit(filter.Limit, filter.Offset)

	var stats []*GeoStats
	if err := query.Find(&stats); err != nil {
		return nil, err
	}

	return stats, nil
}

// RawLogFilter defines filters for querying raw connection logs.
type RawLogFilter struct {
	SourceIP  string
	StartTime time.Time
	EndTime   time.Time
	Action    int32 // -1 for all, 0=ALLOW, 1=BLOCK, 2=MOCK
	Limit     int
	Offset    int
}

// GetRawLogs retrieves raw connection log entries.
func (s *StatsService) GetRawLogs(filter *RawLogFilter) ([]*ConnectionLog, int64, error) {
	if filter == nil {
		filter = &RawLogFilter{}
	}
	if filter.Limit <= 0 {
		filter.Limit = 100
	}

	// Count total
	countQuery := s.db.NewSession()
	defer countQuery.Close()

	if filter.SourceIP != "" {
		countQuery = countQuery.Where("source_ip = ?", filter.SourceIP)
	}
	if !filter.StartTime.IsZero() {
		countQuery = countQuery.Where("first_seen >= ?", filter.StartTime)
	}
	if !filter.EndTime.IsZero() {
		countQuery = countQuery.Where("first_seen <= ?", filter.EndTime)
	}
	if filter.Action >= 0 {
		countQuery = countQuery.Where("action = ?", filter.Action)
	}

	total, err := countQuery.Count(new(ConnectionLog))
	if err != nil {
		return nil, 0, err
	}

	// Query
	query := s.db.NewSession()
	defer query.Close()

	if filter.SourceIP != "" {
		query = query.Where("source_ip = ?", filter.SourceIP)
	}
	if !filter.StartTime.IsZero() {
		query = query.Where("first_seen >= ?", filter.StartTime)
	}
	if !filter.EndTime.IsZero() {
		query = query.Where("first_seen <= ?", filter.EndTime)
	}
	if filter.Action >= 0 {
		query = query.Where("action = ?", filter.Action)
	}

	query = query.Desc("first_seen").Limit(filter.Limit, filter.Offset)

	var logs []*ConnectionLog
	if err := query.Find(&logs); err != nil {
		return nil, 0, err
	}

	return logs, total, nil
}

// GetTopBlockedIPs returns the most frequently blocked IPs.
func (s *StatsService) GetTopBlockedIPs(limit int) ([]*IPStatsResult, error) {
	if limit <= 0 {
		limit = 10
	}

	var stats []IPStats
	err := s.db.Where("blocked_count > 0").Desc("blocked_count").Limit(limit).Find(&stats)
	if err != nil {
		return nil, err
	}

	results := make([]*IPStatsResult, len(stats))
	for i, stat := range stats {
		results[i] = &IPStatsResult{
			IPStats:       stat,
			RecencyWeight: RecencyWeight(stat.LastSeen, 24.0),
		}
	}

	return results, nil
}

// GetRecentIPs returns IPs that have connected recently (high recency weight).
func (s *StatsService) GetRecentIPs(limit int, minWeight float64) ([]*IPStatsResult, error) {
	if limit <= 0 {
		limit = 10
	}
	if minWeight <= 0 {
		minWeight = 0.5 // Last 24 hours with 24h half-life
	}

	// Get all IPs from last 7 days and filter by recency
	cutoff := time.Now().Add(-7 * 24 * time.Hour)

	var stats []IPStats
	err := s.db.Where("last_seen > ?", cutoff).Desc("last_seen").Find(&stats)
	if err != nil {
		return nil, err
	}

	var results []*IPStatsResult
	for _, stat := range stats {
		weight := RecencyWeight(stat.LastSeen, 24.0)
		if weight >= minWeight {
			results = append(results, &IPStatsResult{
				IPStats:       stat,
				RecencyWeight: weight,
			})
		}
		if len(results) >= limit {
			break
		}
	}

	return results, nil
}

// StatsSummary returns a summary of all statistics.
type StatsSummary struct {
	TotalConnections int64
	TotalBytesIn     int64
	TotalBytesOut    int64
	UniqueIPs        int64
	UniqueCountries  int64
	BlockedTotal     int64
	AllowedTotal     int64
}

// GetSummary returns a summary of all statistics.
func (s *StatsService) GetSummary() (*StatsSummary, error) {
	summary := &StatsSummary{}

	// Get totals from IP stats
	var stats []struct {
		SumConns    int64 `xorm:"sum(connection_count)"`
		SumBytesIn  int64 `xorm:"sum(total_bytes_in)"`
		SumBytesOut int64 `xorm:"sum(total_bytes_out)"`
		SumBlocked  int64 `xorm:"sum(blocked_count)"`
		SumAllowed  int64 `xorm:"sum(allowed_count)"`
	}
	s.db.Table("ip_stats").Select("sum(connection_count) as sum_conns, sum(total_bytes_in) as sum_bytes_in, sum(total_bytes_out) as sum_bytes_out, sum(blocked_count) as sum_blocked, sum(allowed_count) as sum_allowed").Find(&stats)
	if len(stats) > 0 {
		summary.TotalConnections = stats[0].SumConns
		summary.TotalBytesIn = stats[0].SumBytesIn
		summary.TotalBytesOut = stats[0].SumBytesOut
		summary.BlockedTotal = stats[0].SumBlocked
		summary.AllowedTotal = stats[0].SumAllowed
	}

	// Count unique IPs
	summary.UniqueIPs, _ = s.db.Count(new(IPStats))

	// Count unique countries
	var countryCount int64
	s.db.Table("geo_stats").Where("type = 'country'").Count(&countryCount)
	summary.UniqueCountries = countryCount

	return summary, nil
}

// GetIPByIP returns statistics for a specific IP address.
func (s *StatsService) GetIPByIP(ip string) (*IPStatsResult, error) {
	var stat IPStats
	has, err := s.db.Where("source_ip = ?", ip).Get(&stat)
	if err != nil {
		return nil, err
	}
	if !has {
		return nil, fmt.Errorf("IP not found: %s", ip)
	}

	return &IPStatsResult{
		IPStats:       stat,
		RecencyWeight: RecencyWeight(stat.LastSeen, 24.0),
	}, nil
}
