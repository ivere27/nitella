package geoip

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
	"time"

	common "github.com/ivere27/nitella/pkg/api/common"
	"google.golang.org/protobuf/proto"
)

// MockProvider implements Provider interface
type MockProvider struct {
	name string
	data map[string]*common.GeoInfo
}

func (m *MockProvider) Name() string { return "mock:" + m.name }
func (m *MockProvider) Close()       {}
func (m *MockProvider) Lookup(ip string) (*common.GeoInfo, error) {
	if info, ok := m.data[ip]; ok {
		// Return a copy using proto.Clone to avoid lock copy warning
		i := proto.Clone(info).(*common.GeoInfo)
		i.Source = m.Name()
		return i, nil
	}
	return nil, fmt.Errorf("not found")
}

// createTestClient creates manager and embedded client for testing
func createTestClient(m *Manager) GeoIPClient {
	return NewEmbeddedClient(m)
}

func TestManager_FallbackAndCache(t *testing.T) {
	// Setup L2 DB
	tmpFile, err := os.CreateTemp("", "geoip_test_*.db")
	if err != nil {
		t.Fatal(err)
	}
	defer os.Remove(tmpFile.Name())
	tmpFile.Close()

	m := NewManager()
	if err := m.InitL2(tmpFile.Name(), 24); err != nil {
		t.Fatal(err)
	}
	defer m.Close()

	// Setup Mock Provider
	targetIP := "8.8.8.8"
	mockInfo := &common.GeoInfo{
		Country:     "United States",
		CountryCode: "US",
		City:        "Mountain View",
		Isp:         "Google LLC",
		Latitude:    37.4223,
		Longitude:   -122.0848,
	}

	mockRemote := &MockProvider{
		name: "remote1",
		data: map[string]*common.GeoInfo{
			targetIP: mockInfo,
		},
	}
	m.RegisterProvider(mockRemote)

	// Create embedded client
	client := createTestClient(m)
	defer client.Close()
	ctx := context.Background()

	// 1. First Lookup - Should hit Remote
	info, err := client.Lookup(ctx, targetIP)
	if err != nil {
		t.Fatalf("First lookup failed: %v", err)
	}
	if info.Source != "mock:remote1" {
		t.Errorf("Expected source mock:remote1, got %s", info.Source)
	}
	if info.City != "Mountain View" {
		t.Errorf("Expected City Mountain View, got %s", info.City)
	}

	// 2. Second Lookup - Should hit L1 Cache
	info, err = client.Lookup(ctx, targetIP)
	if err != nil {
		t.Fatalf("Second lookup failed: %v", err)
	}
	if info.Source != "cache-l1" {
		t.Errorf("Expected source cache-l1, got %s", info.Source)
	}

	// 3. Clear L1 and Lookup - Should hit L2 Cache
	m.l1Cache = NewL1Cache(100) // Hack to clear L1

	info, err = client.Lookup(ctx, targetIP)
	if err != nil {
		t.Fatalf("Third lookup failed: %v", err)
	}
	if info.Source != "cache-l2" {
		t.Errorf("Expected source cache-l2, got %s", info.Source)
	}
	if info.Latitude != 37.4223 {
		t.Errorf("Expected Lat 37.4223, got %f", info.Latitude)
	}
}

func TestManager_MultipleIPs(t *testing.T) {
	m := NewManager()
	defer m.Close()

	mockData := map[string]*common.GeoInfo{
		"1.1.1.1": {
			Country: "Australia",
			City:    "South Brisbane",
			Isp:     "Cloudflare, Inc.",
		},
		"203.0.113.1": {
			Country: "Testland",
			City:    "Mock City",
		},
	}

	mockRemote := &MockProvider{
		name: "remote_multi",
		data: mockData,
	}
	m.RegisterProvider(mockRemote)

	// Create embedded client
	client := createTestClient(m)
	defer client.Close()
	ctx := context.Background()

	tests := []struct {
		ip       string
		wantErr  bool
		wantCity string
	}{
		{"1.1.1.1", false, "South Brisbane"},
		{"203.0.113.1", false, "Mock City"},
		{"192.168.1.1", true, ""}, // Not in mock
	}

	for _, tt := range tests {
		t.Run(tt.ip, func(t *testing.T) {
			info, err := client.Lookup(ctx, tt.ip)
			if (err != nil) != tt.wantErr {
				t.Errorf("Lookup() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !tt.wantErr {
				if info.City != tt.wantCity {
					t.Errorf("Lookup() city = %v, want %v", info.City, tt.wantCity)
				}
			}
		})
	}
}

func TestRemoteProvider_Real(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping real network test in short mode")
	}

	// Test with ipwhois.app (more reliable, no strict rate limits)
	urlFmt := "https://ipwhois.app/json/%s"
	p := NewHTTPProvider("ipwhois", urlFmt, 5*time.Second)

	// Test Google DNS
	ip := "8.8.8.8"
	info, err := p.Lookup(ip)
	if err != nil {
		t.Fatalf("Real Lookup failed: %v", err)
	}

	t.Logf("Lookup(%s) Result: %+v", ip, info)

	if info.CountryCode != "US" {
		t.Errorf("Expected US, got %s", info.CountryCode)
	}

	// Test Cloudflare DNS
	ip2 := "1.1.1.1"
	info2, err := p.Lookup(ip2)
	if err != nil {
		t.Fatalf("Real Lookup failed: %v", err)
	}
	t.Logf("Lookup(%s) Result: %+v", ip2, info2)

	// Verify we got valid data
	if info2.Country == "" {
		t.Error("Expected Country to be populated")
	}
}

func TestManager_CacheHit(t *testing.T) {
	m := NewManager()
	defer m.Close()

	// 1. Setup a specific mock provider that counts calls
	callCount := 0
	mock := &MockProvider{
		name: "counted_remote",
		data: map[string]*common.GeoInfo{
			"10.0.0.1": {Country: "CacheLand"},
		},
	}

	// Wrap the Lookup to increment counter
	counter := &CountingProvider{
		MockProvider: mock,
		count:        &callCount,
	}

	m.RegisterProvider(counter)

	// Create embedded client
	client := createTestClient(m)
	defer client.Close()
	ctx := context.Background()

	// 2. First Lookup (Cache Miss)
	_, err := client.Lookup(ctx, "10.0.0.1")
	if err != nil {
		t.Fatalf("First lookup failed: %v", err)
	}
	if callCount != 1 {
		t.Errorf("Expected 1 provider call, got %d", callCount)
	}

	// 3. Second Lookup (Cache Hit)
	info, err := client.Lookup(ctx, "10.0.0.1")
	if err != nil {
		t.Fatalf("Second lookup failed: %v", err)
	}
	if callCount != 1 {
		t.Errorf("Expected provider call count to stay 1, got %d", callCount)
	}
	if info.Source != "cache-l1" {
		t.Errorf("Expected source cache-l1, got %s", info.Source)
	}
}

type CountingProvider struct {
	*MockProvider
	count *int
}

func (c *CountingProvider) Lookup(ip string) (*common.GeoInfo, error) {
	*c.count++
	return c.MockProvider.Lookup(ip)
}

func TestProvider_NetworkFailure_And_Fallback(t *testing.T) {
	m := NewManager()
	defer m.Close()

	// 1. Add a "Bad" Provider (Simulate Network Error)
	badProvider := NewHTTPProvider("bad_network", "http://127.0.0.1:45678/json/%s", 100*time.Millisecond)
	m.RegisterProvider(badProvider)

	// 2. Add a "Good" Provider (Mock)
	goodData := map[string]*common.GeoInfo{
		"1.2.3.4": {Country: "FallbackLand"},
	}
	goodProvider := &MockProvider{name: "good_fallback", data: goodData}
	m.RegisterProvider(goodProvider)

	// Create embedded client
	client := createTestClient(m)
	defer client.Close()
	ctx := context.Background()

	// 3. Lookup - Should fail on badProvider, then succeed on goodProvider
	info, err := client.Lookup(ctx, "1.2.3.4")
	if err != nil {
		t.Fatalf("Lookup failed completely, fallback didn't work: %v", err)
	}

	if info.Country != "FallbackLand" {
		t.Errorf("Expected Country FallbackLand, got %s", info.Country)
	}
	if info.Source != "mock:good_fallback" {
		t.Errorf("Expected source mock:good_fallback, got %s", info.Source)
	}
}

func TestManager_ConfigurableStrategy(t *testing.T) {
	m := NewManager()
	defer m.Close()

	// Strategy: Remote First -> Local (Mock)
	remoteMock := &MockProvider{
		name: "remote_primary",
		data: map[string]*common.GeoInfo{
			"1.1.1.1": {Country: "RemoteLand"},
		},
	}
	m.RegisterProvider(remoteMock)

	localMock := &MockProvider{
		name: "local_backup",
		data: map[string]*common.GeoInfo{
			"1.1.1.1": {Country: "LocalLand"},
			"2.2.2.2": {Country: "LocalLandOnly"},
		},
	}
	m.SetLocalProvider(localMock)

	// Create embedded client
	client := createTestClient(m)
	defer client.Close()
	ctx := context.Background()

	// 1. Test Remote Priority (remote, local)
	m.SetStrategy([]string{"remote", "local"})

	info, err := client.Lookup(ctx, "1.1.1.1")
	if err != nil {
		t.Fatalf("Lookup failed: %v", err)
	}
	if info.Country != "RemoteLand" {
		t.Errorf("Expected RemoteLand, got %s (Source: %s)", info.Country, info.Source)
	}

	// 2. Test Local Priority (local, remote)
	m.SetStrategy([]string{"local", "remote"})
	m.l1Cache = NewL1Cache(100) // Clear L1 cache

	info, err = client.Lookup(ctx, "1.1.1.1")
	if err != nil {
		t.Fatalf("Lookup failed: %v", err)
	}
	if info.Country != "LocalLand" {
		t.Errorf("Expected LocalLand, got %s (Source: %s)", info.Country, info.Source)
	}

	// 3. Test Fallback (Remote fails -> Local)
	m.SetStrategy([]string{"remote", "local"})
	m.l1Cache = NewL1Cache(100)

	info, err = client.Lookup(ctx, "2.2.2.2")
	if err != nil {
		t.Fatalf("Lookup failed: %v", err)
	}
	if info.Country != "LocalLandOnly" {
		t.Errorf("Expected LocalLandOnly, got %s", info.Country)
	}
}

func TestProvider_Parsing_Variations(t *testing.T) {
	tests := []struct {
		name     string
		response string
		want     *common.GeoInfo
	}{
		{
			name: "FreeIPAPI",
			response: `{
				"ipVersion": 4,
				"ipAddress": "8.8.8.8",
				"latitude": 37.405992,
				"longitude": -122.078515,
				"countryName": "United States of America",
				"countryCode": "US",
				"timeZone": "-07:00",
				"zipCode": "94043",
				"cityName": "Mountain View",
				"regionName": "California"
			}`,
			want: &common.GeoInfo{
				Country:     "United States of America",
				CountryCode: "US",
				City:        "Mountain View",
				Zip:         "94043",
				RegionName:  "California",
			},
		},
		{
			name: "IPWhois",
			response: `{
				"success": true,
				"ip": "8.8.8.8",
				"type": "IPv4",
				"continent": "North America",
				"continent_code": "NA",
				"country": "United States",
				"country_code": "US",
				"region": "California",
				"city": "Mountain View",
				"latitude": 37.3860517,
				"longitude": -122.0838511,
				"isp": "Google LLC",
				"org": "Google LLC"
			}`,
			want: &common.GeoInfo{
				Country:     "United States",
				CountryCode: "US",
				City:        "Mountain View",
				Region:      "California",
				Isp:         "Google LLC",
				Org:         "Google LLC",
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				w.Header().Set("Content-Type", "application/json")
				fmt.Fprintln(w, tt.response)
			}))
			defer ts.Close()

			p := NewHTTPProvider("test-"+tt.name, ts.URL+"/%s", 1*time.Second)
			info, err := p.Lookup("1.1.1.1")
			if err != nil {
				t.Fatalf("Lookup failed: %v", err)
			}

			if info.Country != tt.want.Country {
				t.Errorf("Country: want %s, got %s", tt.want.Country, info.Country)
			}
			if info.CountryCode != tt.want.CountryCode {
				t.Errorf("CountryCode: want %s, got %s", tt.want.CountryCode, info.CountryCode)
			}
			if info.City != tt.want.City {
				t.Errorf("City: want %s, got %s", tt.want.City, info.City)
			}
			if tt.want.Zip != "" && info.Zip != tt.want.Zip {
				t.Errorf("Zip: want %s, got %s", tt.want.Zip, info.Zip)
			}
			if tt.want.Isp != "" && info.Isp != tt.want.Isp {
				t.Errorf("Isp: want %s, got %s", tt.want.Isp, info.Isp)
			}
		})
	}
}

func TestProvider_Consistency(t *testing.T) {
	targetIP := "8.8.8.8"

	scenarios := []struct {
		name     string
		response string
	}{
		{
			name: "ip-api",
			response: `{
				"status": "success",
				"country": "United States",
				"countryCode": "US",
				"region": "CA",
				"regionName": "California",
				"city": "Mountain View",
				"zip": "94043",
				"lat": 37.4223,
				"lon": -122.0848,
				"timezone": "America/Los_Angeles",
				"isp": "Google LLC",
				"org": "Google LLC",
				"as": "AS15169 Google LLC",
				"query": "8.8.8.8"
			}`,
		},
		{
			name: "free-ip-api",
			response: `{
				"ipVersion": 4,
				"ipAddress": "8.8.8.8",
				"latitude": 37.4223,
				"longitude": -122.0848,
				"countryName": "United States of America",
				"countryCode": "US",
				"timeZone": "-07:00",
				"zipCode": "94043",
				"cityName": "Mountain View",
				"regionName": "California"
			}`,
		},
		{
			name: "ip-whois",
			response: `{
				"success": true,
				"ip": "8.8.8.8",
				"type": "IPv4",
				"continent": "North America",
				"continent_code": "NA",
				"country": "United States",
				"country_code": "US",
				"region": "California",
				"city": "Mountain View",
				"latitude": 37.4223,
				"longitude": -122.0848,
				"isp": "Google LLC",
				"org": "Google LLC"
			}`,
		},
	}

	for _, s := range scenarios {
		t.Run(s.name, func(t *testing.T) {
			ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				w.Header().Set("Content-Type", "application/json")
				fmt.Fprintln(w, s.response)
			}))
			defer ts.Close()

			p := NewHTTPProvider(s.name, ts.URL+"/%s", 1*time.Second)
			info, err := p.Lookup(targetIP)
			if err != nil {
				t.Fatalf("Lookup failed: %v", err)
			}

			if info.CountryCode != "US" {
				t.Errorf("CountryCode: want US, got %s", info.CountryCode)
			}
			if info.City != "Mountain View" {
				t.Errorf("City: want Mountain View, got %s", info.City)
			}
			if info.RegionName != "" && info.RegionName != "California" {
				t.Errorf("RegionName: want California, got %s", info.RegionName)
			}
		})
	}
}

func TestManager_Redundancy(t *testing.T) {
	m := NewManager()
	defer m.Close()

	// 1. Mock IP-API (Fails)
	mockMsg1 := "api returned fail"
	ts1 := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintf(w, `{"status": "fail", "message": "%s"}`, mockMsg1)
	}))
	defer ts1.Close()
	m.AddRemoteProvider("mock-ip-api", ts1.URL+"/%s")

	// 2. Mock FreeIPAPI (Succeeds)
	ts2 := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintln(w, `{
			"ipVersion": 4,
			"ipAddress": "8.8.8.8",
			"latitude": 0,
			"longitude": 0,
			"countryName": "RedundancyLand",
			"countryCode": "RL",
			"cityName": "BackupCity"
		}`)
	}))
	defer ts2.Close()
	m.AddRemoteProvider("mock-free-ip-api", ts2.URL+"/%s")

	// 3. Mock IPWhois (Not reached)
	ts3 := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))
	defer ts3.Close()
	m.AddRemoteProvider("mock-ip-whois", ts3.URL+"/%s")

	// Set Strategy to ONLY remote
	m.SetStrategy([]string{"remote"})

	// Create embedded client
	client := createTestClient(m)
	defer client.Close()
	ctx := context.Background()

	// Verify Lookup
	info, err := client.Lookup(ctx, "8.8.8.8")
	if err != nil {
		t.Fatalf("Lookup failed with redundancy: %v", err)
	}

	if info.Country != "RedundancyLand" {
		t.Errorf("Expected country RedundancyLand, got %s", info.Country)
	}
	if info.Source != "http:mock-free-ip-api" {
		t.Errorf("Expected source http:mock-free-ip-api, got %s", info.Source)
	}
}

func TestProvider_VariedIPs(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")

		switch {
		case strings.Contains(r.URL.Path, "1.1.1.1"):
			fmt.Fprintln(w, `{
				"ipVersion": 4,
				"ipAddress": "1.1.1.1",
				"countryName": "Australia",
				"countryCode": "AU",
				"cityName": "South Brisbane"
			}`)
		case strings.Contains(r.URL.Path, "103.102.166.224"):
			fmt.Fprintln(w, `{
				"ipVersion": 4,
				"ipAddress": "103.102.166.224",
				"countryName": "Japan",
				"countryCode": "JP",
				"cityName": "Tokyo"
			}`)
		case strings.Contains(r.URL.Path, "8.8.8.8"):
			fmt.Fprintln(w, `{
				"ipVersion": 4,
				"ipAddress": "8.8.8.8",
				"countryName": "United States of America",
				"countryCode": "US",
				"cityName": "Mountain View"
			}`)
		default:
			http.Error(w, "Not Found", http.StatusNotFound)
		}
	}))
	defer ts.Close()

	p := NewHTTPProvider("test-varied", ts.URL+"/%s", 1*time.Second)

	tests := []struct {
		ip          string
		wantCountry string
		wantCity    string
	}{
		{"1.1.1.1", "Australia", "South Brisbane"},
		{"103.102.166.224", "Japan", "Tokyo"},
		{"8.8.8.8", "United States of America", "Mountain View"},
	}

	for _, tt := range tests {
		t.Run(tt.ip, func(t *testing.T) {
			info, err := p.Lookup(tt.ip)
			if err != nil {
				t.Fatalf("Lookup(%s) failed: %v", tt.ip, err)
			}
			if info.Country != tt.wantCountry {
				t.Errorf("Lookup(%s) Country: want %s, got %s", tt.ip, tt.wantCountry, info.Country)
			}
			if info.City != tt.wantCity {
				t.Errorf("Lookup(%s) City: want %s, got %s", tt.ip, tt.wantCity, info.City)
			}
		})
	}
}
