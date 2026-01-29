package stats

import (
	"os"
	"testing"
	"time"

	pbCommon "github.com/ivere27/nitella/pkg/api/common"
)

func TestStatsService_BasicOperations(t *testing.T) {
	// Create temp DB
	tmpFile, err := os.CreateTemp("", "stats_test_*.db")
	if err != nil {
		t.Fatalf("Failed to create temp file: %v", err)
	}
	tmpFile.Close()
	defer os.Remove(tmpFile.Name())

	// Create service
	svc, err := NewStatsService(tmpFile.Name())
	if err != nil {
		t.Fatalf("Failed to create stats service: %v", err)
	}

	// Start service
	if err := svc.Start(); err != nil {
		t.Fatalf("Failed to start service: %v", err)
	}
	defer svc.Stop()

	// Should be disabled by default
	if svc.IsEnabled() {
		t.Error("Expected stats to be disabled by default")
	}

	// Enable stats
	if err := svc.SetEnabled(true); err != nil {
		t.Errorf("Failed to enable stats: %v", err)
	}
	if !svc.IsEnabled() {
		t.Error("Expected stats to be enabled after SetEnabled(true)")
	}
}

func TestStatsService_RecordConnection(t *testing.T) {
	tmpFile, err := os.CreateTemp("", "stats_test_*.db")
	if err != nil {
		t.Fatalf("Failed to create temp file: %v", err)
	}
	tmpFile.Close()
	defer os.Remove(tmpFile.Name())

	svc, err := NewStatsService(tmpFile.Name())
	if err != nil {
		t.Fatalf("Failed to create stats service: %v", err)
	}

	if err := svc.Start(); err != nil {
		t.Fatalf("Failed to start service: %v", err)
	}
	defer svc.Stop()

	// Enable stats
	svc.SetEnabled(true)

	// Record some connections
	now := time.Now()
	for i := 0; i < 10; i++ {
		svc.RecordConnection(&ConnectionEvent{
			SourceIP:  "192.168.1.100",
			StartTime: now.Add(-time.Duration(i) * time.Minute),
			EndTime:   now.Add(-time.Duration(i) * time.Minute).Add(30 * time.Second),
			BytesIn:   1024,
			BytesOut:  2048,
			Action:    0, // ALLOW
			Geo: &pbCommon.GeoInfo{
				Country: "US",
				City:    "New York",
				Isp:     "Test ISP",
			},
		})
	}

	// Wait for processing
	time.Sleep(2 * time.Second)

	// Check IP stats
	results, total, err := svc.GetIPStats(&IPStatsFilter{Limit: 10})
	if err != nil {
		t.Fatalf("GetIPStats failed: %v", err)
	}

	if total != 1 {
		t.Errorf("Expected 1 unique IP, got %d", total)
	}

	if len(results) != 1 {
		t.Fatalf("Expected 1 result, got %d", len(results))
	}

	result := results[0]
	if result.SourceIP != "192.168.1.100" {
		t.Errorf("Expected IP 192.168.1.100, got %s", result.SourceIP)
	}
	if result.ConnectionCount != 10 {
		t.Errorf("Expected 10 connections, got %d", result.ConnectionCount)
	}
	if result.TotalBytesIn != 10240 {
		t.Errorf("Expected 10240 bytes in, got %d", result.TotalBytesIn)
	}
	if result.GeoCountry != "US" {
		t.Errorf("Expected country US, got %s", result.GeoCountry)
	}
}

func TestRecencyWeight(t *testing.T) {
	tests := []struct {
		name          string
		lastSeen      time.Time
		halfLifeHours float64
		expectedMin   float64
		expectedMax   float64
	}{
		{
			name:          "just now",
			lastSeen:      time.Now(),
			halfLifeHours: 24.0,
			expectedMin:   0.99,
			expectedMax:   1.0,
		},
		{
			name:          "24 hours ago",
			lastSeen:      time.Now().Add(-24 * time.Hour),
			halfLifeHours: 24.0,
			expectedMin:   0.49,
			expectedMax:   0.51,
		},
		{
			name:          "48 hours ago",
			lastSeen:      time.Now().Add(-48 * time.Hour),
			halfLifeHours: 24.0,
			expectedMin:   0.24,
			expectedMax:   0.26,
		},
		{
			name:          "7 days ago",
			lastSeen:      time.Now().Add(-7 * 24 * time.Hour),
			halfLifeHours: 24.0,
			expectedMin:   0.0,
			expectedMax:   0.01,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			weight := RecencyWeight(tt.lastSeen, tt.halfLifeHours)
			if weight < tt.expectedMin || weight > tt.expectedMax {
				t.Errorf("RecencyWeight(%v, %f) = %f, expected [%f, %f]",
					tt.lastSeen, tt.halfLifeHours, weight, tt.expectedMin, tt.expectedMax)
			}
		})
	}
}

func TestStatsService_GeoStats(t *testing.T) {
	tmpFile, err := os.CreateTemp("", "stats_test_*.db")
	if err != nil {
		t.Fatalf("Failed to create temp file: %v", err)
	}
	tmpFile.Close()
	defer os.Remove(tmpFile.Name())

	svc, err := NewStatsService(tmpFile.Name())
	if err != nil {
		t.Fatalf("Failed to create stats service: %v", err)
	}

	if err := svc.Start(); err != nil {
		t.Fatalf("Failed to start service: %v", err)
	}
	defer svc.Stop()

	svc.SetEnabled(true)

	// Record connections from different countries
	now := time.Now()
	countries := []string{"US", "US", "CN", "JP", "US", "CN"}
	for i, country := range countries {
		svc.RecordConnection(&ConnectionEvent{
			SourceIP:  "192.168.1." + string(rune('0'+i)),
			StartTime: now,
			EndTime:   now.Add(time.Minute),
			BytesIn:   1000,
			BytesOut:  2000,
			Action:    0,
			Geo: &pbCommon.GeoInfo{
				Country: country,
				City:    "Test City",
				Isp:     "Test ISP",
			},
		})
	}

	// Wait for processing
	time.Sleep(2 * time.Second)

	// Check geo stats
	geoStats, err := svc.GetGeoStats(&GeoStatsFilter{Type: "country", Limit: 10})
	if err != nil {
		t.Fatalf("GetGeoStats failed: %v", err)
	}

	if len(geoStats) != 3 {
		t.Errorf("Expected 3 countries, got %d", len(geoStats))
	}

	// US should be first (most connections)
	if len(geoStats) > 0 && geoStats[0].Value != "US" {
		t.Errorf("Expected US to be first, got %s", geoStats[0].Value)
	}
}

func TestStatsService_Configuration(t *testing.T) {
	tmpFile, err := os.CreateTemp("", "stats_test_*.db")
	if err != nil {
		t.Fatalf("Failed to create temp file: %v", err)
	}
	tmpFile.Close()
	defer os.Remove(tmpFile.Name())

	svc, err := NewStatsService(tmpFile.Name())
	if err != nil {
		t.Fatalf("Failed to create stats service: %v", err)
	}

	if err := svc.Start(); err != nil {
		t.Fatalf("Failed to start service: %v", err)
	}
	defer svc.Stop()

	// Configure
	err = svc.Configure(true, 48, 60, 120, 30, 2)
	if err != nil {
		t.Fatalf("Configure failed: %v", err)
	}

	// Verify
	enabled, rawHours, statsDays, geoDays, aggInterval, samplingRate := svc.GetConfig()
	if !enabled {
		t.Error("Expected enabled to be true")
	}
	if rawHours != 48 {
		t.Errorf("Expected rawHours 48, got %d", rawHours)
	}
	if statsDays != 60 {
		t.Errorf("Expected statsDays 60, got %d", statsDays)
	}
	if geoDays != 120 {
		t.Errorf("Expected geoDays 120, got %d", geoDays)
	}
	if aggInterval != 30 {
		t.Errorf("Expected aggInterval 30, got %d", aggInterval)
	}
	if samplingRate != 2 {
		t.Errorf("Expected samplingRate 2, got %d", samplingRate)
	}
}
