package geoip

import (
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"strings"
	"time"

	log "github.com/ivere27/nitella/pkg/log"

	pbCommon "github.com/ivere27/nitella/pkg/api/common"
	"github.com/oschwald/geoip2-golang"
)

// Provider defines a strategy for looking up IP information
type Provider interface {
	Lookup(ip string) (*pbCommon.GeoInfo, error)
	Name() string
	Close()
}

// FailoverProvider tries a list of providers in order
type FailoverProvider struct {
	providers []Provider
}

func NewFailoverProvider(providers ...Provider) *FailoverProvider {
	return &FailoverProvider{
		providers: providers,
	}
}

func (p *FailoverProvider) Name() string {
	return "failover"
}

func (p *FailoverProvider) Close() {
	for _, provider := range p.providers {
		provider.Close()
	}
}

func (p *FailoverProvider) Lookup(ip string) (*pbCommon.GeoInfo, error) {
	var lastErr error
	for _, provider := range p.providers {
		info, err := provider.Lookup(ip)
		if err == nil {
			return info, nil
		}
		lastErr = err
		// Continue to next provider
	}
	return nil, fmt.Errorf("all providers failed, last error: %v", lastErr)
}

// ============================================================================
// Local DB Provider
// ============================================================================

type LocalProvider struct {
	cityReader *geoip2.Reader
	ispReader  *geoip2.Reader
}

func NewLocalProvider(cityPath, ispPath string) (*LocalProvider, error) {
	r := &LocalProvider{}
	var err error

	if cityPath != "" {
		r.cityReader, err = geoip2.Open(cityPath)
		if err != nil {
			log.Printf("GeoIP Local: Failed to open city DB %s: %v", cityPath, err)
		}
	}

	if ispPath != "" {
		r.ispReader, err = geoip2.Open(ispPath)
		if err != nil {
			log.Printf("GeoIP Local: Failed to open ISP DB %s: %v", ispPath, err)
		}
	}

	return r, nil
}

func (p *LocalProvider) Name() string {
	return "local-db"
}

func (p *LocalProvider) Lookup(ipStr string) (*pbCommon.GeoInfo, error) {
	ip := net.ParseIP(ipStr)
	if ip == nil {
		return nil, fmt.Errorf("invalid ip")
	}

	info := &pbCommon.GeoInfo{Source: p.Name()}
	found := false

	if p.cityReader != nil {
		if record, err := p.cityReader.City(ip); err == nil {
			info.Country = record.Country.IsoCode
			info.CountryCode = record.Country.IsoCode

			if len(record.Subdivisions) > 0 {
				info.Region = record.Subdivisions[0].IsoCode
				if name, ok := record.Subdivisions[0].Names["en"]; ok {
					info.RegionName = name
				}
			}

			if name, ok := record.City.Names["en"]; ok {
				info.City = name
			}

			info.Zip = record.Postal.Code
			info.Latitude = record.Location.Latitude
			info.Longitude = record.Location.Longitude
			info.Timezone = record.Location.TimeZone

			found = true
		}
	}

	if p.ispReader != nil {
		// Try ISP method first (for GeoIP2-ISP db)
		if record, err := p.ispReader.ISP(ip); err == nil && record.ISP != "" {
			info.Isp = record.ISP
			info.Org = record.Organization
			info.As = record.AutonomousSystemOrganization
			found = true
		} else {
			// Fallback to ASN method (for GeoLite2-ASN db)
			if record, err := p.ispReader.ASN(ip); err == nil {
				info.As = record.AutonomousSystemOrganization
				info.Org = record.AutonomousSystemOrganization // ASN DB usually puts Org in AS Org field
				found = true
			}
		}
	}

	if !found {
		return nil, fmt.Errorf("not found in local db")
	}
	return info, nil
}

func (p *LocalProvider) Close() {
	if p.cityReader != nil {
		p.cityReader.Close()
	}
	if p.ispReader != nil {
		p.ispReader.Close()
	}
}

// ============================================================================
// HTTP Provider
// ============================================================================

// FieldMapping defines how to extract GeoInfo fields from JSON response.
// Each field can have multiple candidate JSON paths (first match wins).
// Nested paths use dot notation (e.g., "connection.isp").
type FieldMapping struct {
	Country     []string // JSON paths for country name (e.g., ["country", "country_name"])
	CountryCode []string // JSON paths for country code (e.g., ["countryCode", "country_code"])
	Region      []string // JSON paths for region code
	RegionName  []string // JSON paths for region name
	City        []string // JSON paths for city
	Zip         []string // JSON paths for postal/zip code
	Timezone    []string // JSON paths for timezone
	Latitude    []string // JSON paths for latitude
	Longitude   []string // JSON paths for longitude
	Isp         []string // JSON paths for ISP (e.g., ["isp", "connection.isp"])
	Org         []string // JSON paths for organization
	As          []string // JSON paths for AS info
}

// DefaultFieldMapping returns the default field mapping that covers most common APIs.
func DefaultFieldMapping() *FieldMapping {
	return &FieldMapping{
		Country:     []string{"country", "country_name", "countryName"},
		CountryCode: []string{"countryCode", "country_code", "country_iso_code"},
		Region:      []string{"region", "region_code"},
		RegionName:  []string{"regionName", "region_name"},
		City:        []string{"city", "city_name", "cityName"},
		Zip:         []string{"zip", "postal", "postal_code", "zipCode"},
		Timezone:    []string{"timezone", "time_zone"},
		Latitude:    []string{"lat", "latitude"},
		Longitude:   []string{"lon", "longitude"},
		Isp:         []string{"isp", "connection.isp"},
		Org:         []string{"org", "connection.org"},
		As:          []string{"as", "as_org", "asn"},
	}
}

// IpApiFieldMapping returns field mapping for ip-api.com
func IpApiFieldMapping() *FieldMapping {
	return &FieldMapping{
		Country:     []string{"country"},
		CountryCode: []string{"countryCode"},
		Region:      []string{"region"},
		RegionName:  []string{"regionName"},
		City:        []string{"city"},
		Zip:         []string{"zip"},
		Timezone:    []string{"timezone"},
		Latitude:    []string{"lat"},
		Longitude:   []string{"lon"},
		Isp:         []string{"isp"},
		Org:         []string{"org"},
		As:          []string{"as"},
	}
}

// FreeIpApiFieldMapping returns field mapping for freeipapi.com
func FreeIpApiFieldMapping() *FieldMapping {
	return &FieldMapping{
		Country:     []string{"countryName"},
		CountryCode: []string{"countryCode"},
		Region:      []string{"regionName"},
		RegionName:  []string{"regionName"},
		City:        []string{"cityName"},
		Zip:         []string{"zipCode"},
		Timezone:    []string{"timeZone"},
		Latitude:    []string{"latitude"},
		Longitude:   []string{"longitude"},
		Isp:         []string{}, // Not available in free API
		Org:         []string{},
		As:          []string{},
	}
}

// IpWhoisFieldMapping returns field mapping for ipwhois.io
func IpWhoisFieldMapping() *FieldMapping {
	return &FieldMapping{
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
	}
}

type HTTPProvider struct {
	name    string
	urlFmt  string
	client  *http.Client
	mapping *FieldMapping
}

func NewHTTPProvider(name, urlFmt string, timeout time.Duration) *HTTPProvider {
	return NewHTTPProviderWithMapping(name, urlFmt, timeout, nil)
}

func NewHTTPProviderWithMapping(name, urlFmt string, timeout time.Duration, mapping *FieldMapping) *HTTPProvider {
	if timeout <= 0 {
		timeout = 3 * time.Second
	}
	if !strings.Contains(urlFmt, "%s") {
		urlFmt += "%s"
	}
	// SECURITY: Enforce HTTPS, unless localhost (for dev/testing)
	isLocal := strings.Contains(urlFmt, "localhost") || strings.Contains(urlFmt, "127.0.0.1") || strings.Contains(urlFmt, "::1")
	if strings.HasPrefix(urlFmt, "http://") && !isLocal {
		urlFmt = strings.Replace(urlFmt, "http://", "https://", 1)
	}

	if mapping == nil {
		// Auto-detect mapping based on provider name
		switch name {
		case "ip-api":
			mapping = IpApiFieldMapping()
		case "free-ip-api", "freeipapi":
			mapping = FreeIpApiFieldMapping()
		case "ip-whois", "ipwhois":
			mapping = IpWhoisFieldMapping()
		default:
			mapping = DefaultFieldMapping()
		}
	}

	return &HTTPProvider{
		name:    name,
		urlFmt:  urlFmt,
		client:  &http.Client{Timeout: timeout},
		mapping: mapping,
	}
}

func (p *HTTPProvider) Name() string {
	return "http:" + p.name
}

func (p *HTTPProvider) Lookup(ip string) (*pbCommon.GeoInfo, error) {
	url := fmt.Sprintf(p.urlFmt, ip)
	resp, err := p.client.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	info := &pbCommon.GeoInfo{Source: p.Name()}

	// Generic JSON decoding
	var data map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		return nil, err
	}

	// Failure checks
	if val, ok := data["status"].(string); ok && val == "fail" {
		return nil, fmt.Errorf("api returned fail")
	}
	if val, ok := data["success"].(bool); ok && !val {
		return nil, fmt.Errorf("api returned fail")
	}

	// Helper to get string from nested path (e.g., "connection.isp")
	getNestedStr := func(path string) string {
		parts := strings.Split(path, ".")
		var current interface{} = data

		for _, part := range parts {
			if m, ok := current.(map[string]interface{}); ok {
				current = m[part]
			} else {
				return ""
			}
		}

		if s, ok := current.(string); ok {
			return s
		}
		return ""
	}

	// Helper to get float from nested path
	getNestedFloat := func(path string) float64 {
		parts := strings.Split(path, ".")
		var current interface{} = data

		for _, part := range parts {
			if m, ok := current.(map[string]interface{}); ok {
				current = m[part]
			} else {
				return 0.0
			}
		}

		if f, ok := current.(float64); ok {
			return f
		}
		return 0.0
	}

	// Helper to get first matching string from a list of paths
	getStr := func(paths []string) string {
		for _, path := range paths {
			if v := getNestedStr(path); v != "" {
				return v
			}
		}
		return ""
	}

	// Helper to get first matching float from a list of paths
	getFloat := func(paths []string) float64 {
		for _, path := range paths {
			if v := getNestedFloat(path); v != 0.0 {
				return v
			}
		}
		return 0.0
	}

	// Use field mapping
	m := p.mapping
	info.Country = getStr(m.Country)
	info.CountryCode = getStr(m.CountryCode)
	info.Region = getStr(m.Region)
	info.RegionName = getStr(m.RegionName)
	info.City = getStr(m.City)
	info.Zip = getStr(m.Zip)
	info.Timezone = getStr(m.Timezone)
	info.Latitude = getFloat(m.Latitude)
	info.Longitude = getFloat(m.Longitude)
	info.Isp = getStr(m.Isp)
	info.Org = getStr(m.Org)
	info.As = getStr(m.As)

	if info.CountryCode == "" && info.Country == "" && info.City == "" {
		return nil, fmt.Errorf("empty geo info")
	}

	return info, nil
}

func (p *HTTPProvider) Close() {}
