package config

// MockPreset represents a pre-defined mock behavior
type MockPreset struct {
	Name     string
	Protocol string
	Banner   string
	Behavior MockBehavior
	Response []byte
}

// MockBehavior defines how the mock responds
type MockBehavior struct {
	// Timing
	DripBanner     bool // Send banner byte-by-byte
	DripIntervalMs int  // Interval between bytes
	DelayMs        int  // Initial delay before response

	// SSH specific
	CompleteKex     bool   // Complete key exchange
	AuthAttempts    int    // Number of auth attempts to allow
	AuthDelayMs     int    // Delay per auth attempt
	FinalMessage    string // Message on final rejection
	DisconnectAfter int    // Disconnect after N attempts

	// General
	NeverComplete    bool // Never complete the handshake
	ReconnectPenalty bool // Increase delay on frequent reconnects
	PenaltyDuration  int  // Duration window to track reconnections (seconds)
}

// Presets is the registry of all mock presets
var Presets = map[string]*MockPreset{
	"ssh-secure": {
		Name:     "ssh-secure",
		Protocol: "ssh",
		Banner:   "SSH-2.0-OpenSSH_9.6p1 Debian-4\r\n",
		Behavior: MockBehavior{
			CompleteKex:     true,
			AuthAttempts:    3,
			AuthDelayMs:     2000,
			FinalMessage:    "Permission denied (publickey).",
			DisconnectAfter: 3,
		},
	},
	"ssh-tarpit": {
		Name:     "ssh-tarpit",
		Protocol: "ssh",
		Banner:   "SSH-2.0-OpenSSH_9.6p1\r\n",
		Behavior: MockBehavior{
			DripBanner:       true,
			DripIntervalMs:   100,
			DelayMs:          30000,
			NeverComplete:    true,
			ReconnectPenalty: true,
			PenaltyDuration:  60,
		},
	},
	"http-403": {
		Name:     "http-403",
		Protocol: "http",
		Response: []byte(`HTTP/1.1 403 Forbidden
Content-Type: text/html; charset=utf-8
Content-Length: 162
Connection: close
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Content-Security-Policy: default-src 'none'

<!DOCTYPE html>
<html><head><title>403 Forbidden</title></head>
<body><h1>403 Forbidden</h1><p>Access denied.</p></body></html>
`),
		Behavior: MockBehavior{
			DelayMs: 500,
		},
	},
	"mysql-secure": {
		Name:     "mysql-secure",
		Protocol: "mysql",
		Banner:   "8.4.0-MySQL Community Server - GPL",
		Behavior: MockBehavior{
			DelayMs:      1500,
			AuthAttempts: 1,
			FinalMessage: "Access denied for user",
		},
	},
	"mysql-tarpit": {
		Name:     "mysql-tarpit",
		Protocol: "mysql",
		Banner:   "8.4.0-MySQL Community Server",
		Behavior: MockBehavior{
			DripBanner:       true,
			DripIntervalMs:   200,
			NeverComplete:    true,
			ReconnectPenalty: true,
			PenaltyDuration:  60,
		},
	},
	"rdp-secure": {
		Name:     "rdp-secure",
		Protocol: "rdp",
		Banner:   "", // RDP uses binary protocol
		Behavior: MockBehavior{
			DelayMs:      2000,
			FinalMessage: "NLA authentication required",
		},
	},
	"telnet-secure": {
		Name:     "telnet-secure",
		Protocol: "telnet",
		Banner:   "Connection refused by security policy.\r\n",
		Behavior: MockBehavior{
			DelayMs: 500,
		},
	},
	"raw-tarpit": {
		Name:     "raw-tarpit",
		Protocol: "raw",
		Banner:   "",
		Behavior: MockBehavior{
			DripBanner:       true,
			DripIntervalMs:   1000,
			NeverComplete:    true,
			ReconnectPenalty: true,
			PenaltyDuration:  60,
		},
	},
	"http-404": {
		Name:     "http-404",
		Protocol: "http",
		Response: []byte(`HTTP/1.1 404 Not Found
Content-Type: text/html; charset=utf-8
Content-Length: 153
Connection: close
X-Content-Type-Options: nosniff

<!DOCTYPE html>
<html><head><title>404 Not Found</title></head>
<body><h1>404 Not Found</h1><p>The requested resource was not found.</p></body></html>
`),
		Behavior: MockBehavior{
			DelayMs: 500,
		},
	},
	"http-401": {
		Name:     "http-401",
		Protocol: "http",
		Response: []byte(`HTTP/1.1 401 Unauthorized
Content-Type: text/html; charset=utf-8
Content-Length: 158
Connection: close
WWW-Authenticate: Basic realm="Restricted"

<!DOCTYPE html>
<html><head><title>401 Unauthorized</title></head>
<body><h1>401 Unauthorized</h1><p>Authentication required.</p></body></html>
`),
		Behavior: MockBehavior{
			DelayMs: 500,
		},
	},
	"redis-secure": {
		Name:     "redis-secure",
		Protocol: "redis",
		Banner:   "-NOAUTH Authentication required.\r\n",
		Behavior: MockBehavior{
			DelayMs: 500,
		},
	},
}

// GetPreset returns a mock preset by name
func GetPreset(name string) *MockPreset {
	return Presets[name]
}
