package node

import (
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
)

// ProxyModel represents a saved proxy listener
type ProxyModel struct {
	ID              string `xorm:"'id' pk"`
	Name            string `xorm:"index"`
	ListenAddr      string
	DefaultBackend  string
	DefaultAction   int `xorm:"default 0"` // 0=Allow, 1=Block, 2=Mock
	DefaultMock     string
	FallbackAction  int `xorm:"default 0"` // 0=Close, 1=Mock
	FallbackMock    string
	Enabled         bool      `xorm:"default true"`
	CertPEM         string    `xorm:"text"`
	KeyPEM          string    `xorm:"text"`
	CaPEM           string    `xorm:"text"`
	ClientAuthType  int       `xorm:"default 0"` // 0=Auto, 1=None, 2=Request, 3=Require
	HealthCheckJSON string    `xorm:"text"`      // JSON of HealthCheckConfig
	CreatedAt       time.Time `xorm:"created"`
	UpdatedAt       time.Time `xorm:"updated"`
}

// RuleModel represents a rule associated with a proxy
type RuleModel struct {
	ID            string `xorm:"'id' pk"`
	ProxyID       string `xorm:"'proxy_id' index"`
	Name          string
	Priority      int  `xorm:"default 0"`
	Enabled       bool `xorm:"default true"`
	Action        int
	TargetBackend string

	// Serialized Data
	ConditionsJSON string `xorm:"text"` // JSON array of conditions
	MockConfigJSON string `xorm:"text"` // JSON of MockConfig
	RateLimitJSON  string `xorm:"text"` // JSON of RateLimitConfig
	Expression     string // Traefik-style expression string

	CreatedAt time.Time `xorm:"created"`
	UpdatedAt time.Time `xorm:"updated"`
}

// MockPresetToString converts protobuf MockPreset enum to legacy string key (for DB/Config)
func MockPresetToString(p common.MockPreset) string {
	switch p {
	case common.MockPreset_MOCK_PRESET_SSH_SECURE:
		return "ssh-secure"
	case common.MockPreset_MOCK_PRESET_SSH_TARPIT:
		return "ssh-tarpit"
	case common.MockPreset_MOCK_PRESET_HTTP_403:
		return "http-403"
	case common.MockPreset_MOCK_PRESET_HTTP_404:
		return "http-404"
	case common.MockPreset_MOCK_PRESET_HTTP_401:
		return "http-401"
	case common.MockPreset_MOCK_PRESET_REDIS_SECURE:
		return "redis-secure"
	case common.MockPreset_MOCK_PRESET_MYSQL_SECURE:
		return "mysql-secure"
	case common.MockPreset_MOCK_PRESET_MYSQL_TARPIT:
		return "mysql-tarpit"
	case common.MockPreset_MOCK_PRESET_RDP_SECURE:
		return "rdp-secure"
	case common.MockPreset_MOCK_PRESET_TELNET_SECURE:
		return "telnet-secure"
	case common.MockPreset_MOCK_PRESET_RAW_TARPIT:
		return "raw-tarpit"
	default:
		return ""
	}
}

// StringToMockPreset converts legacy string key to protobuf MockPreset enum
func StringToMockPreset(s string) common.MockPreset {
	switch s {
	case "ssh-secure":
		return common.MockPreset_MOCK_PRESET_SSH_SECURE
	case "ssh-tarpit":
		return common.MockPreset_MOCK_PRESET_SSH_TARPIT
	case "http-403":
		return common.MockPreset_MOCK_PRESET_HTTP_403
	case "http-404":
		return common.MockPreset_MOCK_PRESET_HTTP_404
	case "http-401":
		return common.MockPreset_MOCK_PRESET_HTTP_401
	case "redis-secure":
		return common.MockPreset_MOCK_PRESET_REDIS_SECURE
	case "mysql-secure":
		return common.MockPreset_MOCK_PRESET_MYSQL_SECURE
	case "mysql-tarpit":
		return common.MockPreset_MOCK_PRESET_MYSQL_TARPIT
	case "rdp-secure":
		return common.MockPreset_MOCK_PRESET_RDP_SECURE
	case "telnet-secure":
		return common.MockPreset_MOCK_PRESET_TELNET_SECURE
	case "raw-tarpit":
		return common.MockPreset_MOCK_PRESET_RAW_TARPIT
	default:
		return common.MockPreset_MOCK_PRESET_UNSPECIFIED
	}
}
