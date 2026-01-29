package mockproto

import (
	"net"
	"time"
)

// MockConfig defines the behavior for the mock connection
type MockConfig struct {
	Protocol       string
	StatusCode     int
	DelayMs        int
	Payload        []byte
	RandomDelay    bool
	DripBanner     bool
	DripIntervalMs int
	NeverComplete  bool

	// Tarpit mode - waste attacker's time
	Tarpit bool
}

// HandleConnection routes the connection to the appropriate mock handler based on protocol.
func HandleConnection(conn net.Conn, config MockConfig) error {
	// Simulate fixed delay if randomDelay is NOT set
	if !config.RandomDelay && config.DelayMs > 0 {
		time.Sleep(time.Duration(config.DelayMs) * time.Millisecond)
	}

	// Tarpit mode enables aggressive time-wasting
	if config.Tarpit {
		config.RandomDelay = true
		config.DripBanner = true
		if config.DripIntervalMs == 0 {
			config.DripIntervalMs = 1000 // 1 second per byte default
		}
	}

	switch config.Protocol {
	case "http":
		return MockHTTP(conn, config)
	case "ssh":
		return MockSSH(conn, config)
	case "mysql":
		return MockMySQL(conn, config)
	case "mssql":
		return MockMSSQL(conn)
	case "rdp":
		return MockRDP(conn)
	case "telnet":
		return MockTelnet(conn, config)
	case "redis":
		return MockRedis(conn, config)
	case "smtp":
		return MockSMTP(conn, config)
	default:
		// "raw" or unknown
		if len(config.Payload) > 0 {
			if config.DripBanner {
				return DripWrite(conn, config.Payload, config.DripIntervalMs)
			}
			_, err := conn.Write(config.Payload)
			if err != nil {
				return err
			}
		} else {
			// Default Access Denied
			_, err := conn.Write([]byte("Access Denied\n"))
			if err != nil {
				return err
			}
		}

		if config.NeverComplete {
			HoldOpen(conn)
			return nil
		}
		return nil
	}
}
