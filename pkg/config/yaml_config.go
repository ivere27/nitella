package config

// YAMLConfig represents the top-level Traefik-style YAML configuration
type YAMLConfig struct {
	EntryPoints map[string]EntryPoint `yaml:"entryPoints"`
	TCP         TCPConfig             `yaml:"tcp"`
}

// EntryPoint defines a listener
type EntryPoint struct {
	Address        string     `yaml:"address"`
	DefaultAction  string     `yaml:"defaultAction"` // "allow", "block", or "mock"
	DefaultBackend string     `yaml:"defaultBackend,omitempty"`
	DefaultMock    string     `yaml:"defaultMock,omitempty"` // Mock preset for defaultAction=mock
	TLS            *TLSConfig `yaml:"tls,omitempty"`
}

// TLSConfig for mTLS settings
type TLSConfig struct {
	CertFile   string `yaml:"certFile,omitempty"`
	KeyFile    string `yaml:"keyFile,omitempty"`
	ClientCA   string `yaml:"clientCA,omitempty"`
	ClientAuth string `yaml:"clientAuth,omitempty"` // "none", "optional", "require"
}

// TCPConfig holds routers, services, and middlewares
type TCPConfig struct {
	Routers     map[string]Router     `yaml:"routers"`
	Services    map[string]Service    `yaml:"services"`
	Middlewares map[string]Middleware `yaml:"middlewares,omitempty"`
}

// Router defines a routing rule
type Router struct {
	EntryPoints []string `yaml:"entryPoints,omitempty"`
	Rule        string   `yaml:"rule"`
	Service     string   `yaml:"service,omitempty"`
	Middlewares []string `yaml:"middlewares,omitempty"`
	Priority    int      `yaml:"priority"`
}

// Service defines a backend
type Service struct {
	Address     string       `yaml:"address"`
	HealthCheck *HealthCheck `yaml:"healthCheck,omitempty"`
}

// HealthCheck defines upstream monitoring
type HealthCheck struct {
	Interval       string `yaml:"interval"`       // e.g. "10s"
	Timeout        string `yaml:"timeout"`        // e.g. "2s"
	Type           string `yaml:"type"`           // "tcp" or "http"
	Path           string `yaml:"path,omitempty"` // for http
	ExpectedStatus int    `yaml:"expectedStatus,omitempty"`
}

// Middleware defines mock/tarpit behavior
type Middleware struct {
	Mock *MockConfig `yaml:"mock,omitempty"`
}

// MockConfig for honeypot/tarpit behavior
type MockConfig struct {
	Preset  string `yaml:"preset,omitempty"` // ssh-secure, ssh-tarpit, http-403, etc.
	Tarpit  bool   `yaml:"tarpit,omitempty"`
	DelayMs int    `yaml:"delayMs,omitempty"`

	// Custom response (if not using preset)
	Protocol string `yaml:"protocol,omitempty"` // http, ssh, mysql, raw
	Banner   string `yaml:"banner,omitempty"`
	Response string `yaml:"response,omitempty"`
}
