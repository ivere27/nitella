package node

import (
	"crypto/rand"
	"encoding/binary"
	"fmt"
	"net"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/config"
	"github.com/ivere27/nitella/pkg/mockproto"
)

// secureRandomInt returns a cryptographically random int in [0, max)
func secureRandomInt(max int) int {
	if max <= 0 {
		return 0
	}
	var buf [8]byte
	rand.Read(buf[:])
	return int(binary.LittleEndian.Uint64(buf[:]) % uint64(max))
}

// HandleMockConnection handles the connection for ACTION_MOCK
func (p *EmbeddedListener) HandleMockConnection(conn net.Conn, rule *pb.Rule) {
	mockResp := rule.MockResponse
	if mockResp == nil {
		mockResp = &pb.MockConfig{
			Protocol: "raw",
			Payload:  []byte("Access Denied\n"),
		}
	}

	// Apply Preset if defined
	protocol := mockResp.Protocol
	payload := mockResp.Payload
	delayMs := int(mockResp.DelayMs)
	randomDelay := false // DDoS Tarpit Mode
	statusCode := 200

	var preset *config.MockPreset

	// Load from config.Presets if available
	if mockResp.Preset != common.MockPreset_MOCK_PRESET_UNSPECIFIED {
		// Map Enum to String Key for Presets lookup
		presetKey := ""
		switch mockResp.Preset {
		case common.MockPreset_MOCK_PRESET_SSH_SECURE:
			presetKey = "ssh-secure"
		case common.MockPreset_MOCK_PRESET_SSH_TARPIT:
			presetKey = "ssh-tarpit"
		case common.MockPreset_MOCK_PRESET_HTTP_403:
			presetKey = "http-403"
		case common.MockPreset_MOCK_PRESET_HTTP_404:
			presetKey = "http-404"
		case common.MockPreset_MOCK_PRESET_HTTP_401:
			presetKey = "http-401"
		case common.MockPreset_MOCK_PRESET_REDIS_SECURE:
			presetKey = "redis-secure"
		case common.MockPreset_MOCK_PRESET_MYSQL_SECURE:
			presetKey = "mysql-secure"
		case common.MockPreset_MOCK_PRESET_MYSQL_TARPIT:
			presetKey = "mysql-tarpit"
		case common.MockPreset_MOCK_PRESET_RDP_SECURE:
			presetKey = "rdp-secure"
		case common.MockPreset_MOCK_PRESET_TELNET_SECURE:
			presetKey = "telnet-secure"
		case common.MockPreset_MOCK_PRESET_RAW_TARPIT:
			presetKey = "raw-tarpit"
		}

		if p, ok := config.Presets[presetKey]; ok {
			preset = p
			protocol = preset.Protocol
			if len(preset.Response) > 0 {
				payload = preset.Response
			} else {
				payload = []byte(preset.Banner)
			}

			// Apply behavior
			delayMs = preset.Behavior.DelayMs
			randomDelay = false
			// DripBanner and NeverComplete are passed to mockproto via MockConfig

			// Protocol specific overrides based on preset name
			switch mockResp.Preset {
			case common.MockPreset_MOCK_PRESET_HTTP_401:
				statusCode = 401
			case common.MockPreset_MOCK_PRESET_HTTP_403:
				statusCode = 403
			case common.MockPreset_MOCK_PRESET_HTTP_404:
				statusCode = 404
			case common.MockPreset_MOCK_PRESET_SSH_TARPIT, common.MockPreset_MOCK_PRESET_MYSQL_TARPIT, common.MockPreset_MOCK_PRESET_RAW_TARPIT:
				randomDelay = true
				if preset.Behavior.DelayMs == 0 {
					delayMs = 0
				}
			}
		}
	}

	// Use shared mock implementation
	mockConfig := mockproto.MockConfig{
		Protocol:       protocol,
		StatusCode:     statusCode,
		DelayMs:        delayMs,
		Payload:        payload,
		RandomDelay:    randomDelay,
		DripBanner:     preset != nil && preset.Behavior.DripBanner,
		DripIntervalMs: 0,
		NeverComplete:  preset != nil && preset.Behavior.NeverComplete,
	}

	if preset != nil {
		mockConfig.DripIntervalMs = preset.Behavior.DripIntervalMs

		// Apply Reconnect Penalty if configured
		if preset.Behavior.ReconnectPenalty {
			sourceAddr := conn.RemoteAddr().String()
			sourceIP, _, _ := net.SplitHostPort(sourceAddr)

			attempts := p.trackConnection(sourceIP, preset.Behavior.PenaltyDuration)
			if attempts > 1 {
				// Linear backoff: delay * attempts
				// e.g. 2nd retry -> 2x delay
				// 5th retry -> 5x delay

				// Add Jitter to avoid predictable static delay (fingerprinting protection)
				// Range: [attempts*delay, attempts*delay + 50% delay]
				baseDelay := mockConfig.DelayMs * attempts
				jitter := secureRandomInt(mockConfig.DelayMs/2 + 1)

				mockConfig.DelayMs = baseDelay + jitter
				fmt.Printf("[Tarpit] Penalty applied for %s: %d attempts -> %dms delay (jitter: %d)\n", sourceIP, attempts, mockConfig.DelayMs, jitter)
			}
		}
	}

	mockproto.HandleConnection(conn, mockConfig)
}

// trackConnection records a connection attempt and returns the count of recent attempts
func (p *EmbeddedListener) trackConnection(ip string, windowSeconds int) int {
	if windowSeconds <= 0 {
		windowSeconds = 60 // Default 1 min
	}
	window := time.Duration(windowSeconds) * time.Second
	now := time.Now()

	p.tarpitMux.Lock()
	defer p.tarpitMux.Unlock()

	// Get history
	history, ok := p.tarpitHistory[ip]
	if !ok {
		history = []time.Time{}
	}

	// Prune old entries
	validHistory := make([]time.Time, 0, len(history)+1)
	for _, t := range history {
		if now.Sub(t) < window {
			validHistory = append(validHistory, t)
		}
	}

	// Add current
	validHistory = append(validHistory, now)

	// Update or delete entry to prevent memory leak
	if len(validHistory) > 0 {
		p.tarpitHistory[ip] = validHistory
	} else {
		delete(p.tarpitHistory, ip)
	}

	return len(validHistory)
}
