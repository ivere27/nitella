package p2p

import (
	"encoding/json"
	"fmt"
	"log"
	"sync"
	"time"

	pb "github.com/ivere27/nitella/pkg/api/hub"
	"github.com/pion/webrtc/v3"
)

// Manager handles P2P WebRTC connections for nodes
// This is used by nitellad to accept P2P connections from CLI/mobile clients
type Manager struct {
	signalingOut chan *pb.SignalMessage
	pcs          map[string]*webrtc.PeerConnection // Key: SessionID
	dataChannels map[string]*webrtc.DataChannel    // Key: SessionID
	mu           sync.RWMutex

	// Metrics Callback - called periodically to get encrypted metrics
	GetMetrics func() *pb.EncryptedMetrics

	// Incoming Command Callback - called when data is received via P2P
	OnCommand func(sessionID string, data []byte)

	// On Response Callback - called when a response is received
	OnResponse func(sessionID string, data []byte)

	sem     chan struct{} // Semaphore for concurrent signaling handlers
	stunURL string        // STUN server URL
}

// NewManager creates a new P2P Manager for nodes
func NewManager(outCh chan *pb.SignalMessage) *Manager {
	return &Manager{
		signalingOut: outCh,
		pcs:          make(map[string]*webrtc.PeerConnection),
		dataChannels: make(map[string]*webrtc.DataChannel),
		sem:          make(chan struct{}, 10), // Limit to 10 concurrent handshakes
		stunURL:      DefaultSTUNServer,
	}
}

// SetSTUNServer sets the STUN server URL for ICE negotiation
func (m *Manager) SetSTUNServer(url string) {
	if url != "" {
		m.stunURL = url
	}
}

// IsConnected checks if a P2P connection is active for the given sessionID
func (m *Manager) IsConnected(sessionID string) bool {
	m.mu.RLock()
	defer m.mu.RUnlock()
	dc, ok := m.dataChannels[sessionID]
	if !ok {
		return false
	}
	return dc.ReadyState() == webrtc.DataChannelStateOpen
}

// SendCommand sends data via P2P DataChannel. Returns error if not connected.
func (m *Manager) SendCommand(sessionID string, data []byte) error {
	m.mu.RLock()
	dc, ok := m.dataChannels[sessionID]
	m.mu.RUnlock()

	if !ok {
		return fmt.Errorf("no data channel for session %s", sessionID)
	}
	if dc.ReadyState() != webrtc.DataChannelStateOpen {
		return fmt.Errorf("data channel not open for session %s", sessionID)
	}
	return dc.Send(data)
}

// HandleSignal processes incoming signaling messages from Hub
func (m *Manager) HandleSignal(msg *pb.SignalMessage) {
	switch msg.Type {
	case "OFFER":
		// Check if session already exists to prevent overwriting/leaking
		m.mu.RLock()
		_, exists := m.pcs[msg.SourceId]
		m.mu.RUnlock()
		if exists {
			log.Printf("[P2P] Ignoring duplicate OFFER from %s", msg.SourceId)
			return
		}

		// Use Semaphore to limit concurrent handshakes (DoS protection)
		select {
		case m.sem <- struct{}{}:
			go func() {
				defer func() { <-m.sem }()
				m.handleOffer(msg)
			}()
		default:
			log.Printf("[P2P] Dropping OFFER from %s: Server busy (semaphore full)", msg.SourceId)
		}
	case "CANDIDATE":
		// Candidates are lightweight if session exists
		go m.handleCandidate(msg)
	default:
		log.Printf("[P2P] Unknown signal type: %s", msg.Type)
	}
}

func (m *Manager) handleOffer(msg *pb.SignalMessage) {
	log.Printf("[P2P] Handling OFFER from %s", msg.SourceId)

	// Create PeerConnection
	config := webrtc.Configuration{
		ICEServers: []webrtc.ICEServer{
			{
				URLs: []string{m.stunURL},
			},
		},
	}

	pc, err := webrtc.NewPeerConnection(config)
	if err != nil {
		log.Printf("[P2P] Failed to create PC: %v", err)
		return
	}

	sessionID := msg.SourceId
	m.mu.Lock()
	m.pcs[sessionID] = pc
	m.mu.Unlock()

	// Clean up on close
	pc.OnConnectionStateChange(func(s webrtc.PeerConnectionState) {
		log.Printf("[P2P] PC %s state: %s", sessionID, s.String())
		if s == webrtc.PeerConnectionStateFailed || s == webrtc.PeerConnectionStateClosed {
			m.mu.Lock()
			delete(m.pcs, sessionID)
			delete(m.dataChannels, sessionID)
			m.mu.Unlock()
		}
	})

	// Set ICE Candidate Handler
	pc.OnICECandidate(func(c *webrtc.ICECandidate) {
		if c == nil {
			return
		}
		cJSON := c.ToJSON()
		payload, _ := json.Marshal(cJSON)

		m.signalingOut <- &pb.SignalMessage{
			TargetId: sessionID,
			Type:     "CANDIDATE",
			Payload:  string(payload),
		}
	})

	// Set Data Channel Handler
	pc.OnDataChannel(func(d *webrtc.DataChannel) {
		log.Printf("[P2P] New DataChannel %s %d", d.Label(), d.ID())

		// Store DataChannel reference
		m.mu.Lock()
		m.dataChannels[sessionID] = d
		m.mu.Unlock()

		d.OnOpen(func() {
			log.Printf("[P2P] DataChannel %s open, starting metrics stream", d.Label())
			// Start streaming metrics
			go m.streamMetrics(d, sessionID)
		})

		// Handle incoming messages (commands from mobile/CLI)
		d.OnMessage(func(msg webrtc.DataChannelMessage) {
			if m.OnCommand != nil {
				m.OnCommand(sessionID, msg.Data)
			}
		})
	})

	// Set Remote Description
	offer := webrtc.SessionDescription{}
	if err := json.Unmarshal([]byte(msg.Payload), &offer); err != nil {
		log.Printf("[P2P] Failed to unmarshal offer: %v", err)
		return
	}

	if err := pc.SetRemoteDescription(offer); err != nil {
		log.Printf("[P2P] Failed to set remote description: %v", err)
		return
	}

	// Create Answer
	answer, err := pc.CreateAnswer(nil)
	if err != nil {
		log.Printf("[P2P] Failed to create answer: %v", err)
		return
	}

	if err := pc.SetLocalDescription(answer); err != nil {
		log.Printf("[P2P] Failed to set local description: %v", err)
		return
	}

	// Send Answer
	answerJSON, _ := json.Marshal(answer)
	m.signalingOut <- &pb.SignalMessage{
		TargetId: sessionID,
		Type:     "ANSWER",
		Payload:  string(answerJSON),
	}
}

func (m *Manager) handleCandidate(msg *pb.SignalMessage) {
	m.mu.RLock()
	pc, exists := m.pcs[msg.SourceId]
	m.mu.RUnlock()

	if !exists {
		log.Printf("[P2P] Candidate for unknown session %s", msg.SourceId)
		return
	}

	candidate := webrtc.ICECandidateInit{}
	if err := json.Unmarshal([]byte(msg.Payload), &candidate); err != nil {
		log.Printf("[P2P] Failed to unmarshal candidate: %v", err)
		return
	}

	if err := pc.AddICECandidate(candidate); err != nil {
		log.Printf("[P2P] Failed to add candidate: %v", err)
	}
}

func (m *Manager) streamMetrics(d *webrtc.DataChannel, sessionID string) {
	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			// Check if channel open
			if d.ReadyState() != webrtc.DataChannelStateOpen {
				return
			}

			if m.GetMetrics != nil {
				metrics := m.GetMetrics()
				data, err := json.Marshal(metrics)
				if err == nil {
					d.Send(data)
				}
			}
		}
	}
}

// Close closes all P2P connections
func (m *Manager) Close() {
	m.mu.Lock()
	defer m.mu.Unlock()

	for _, pc := range m.pcs {
		pc.Close()
	}
	m.pcs = make(map[string]*webrtc.PeerConnection)
	m.dataChannels = make(map[string]*webrtc.DataChannel)
}

// GetConnectedSessions returns list of connected session IDs
func (m *Manager) GetConnectedSessions() []string {
	m.mu.RLock()
	defer m.mu.RUnlock()

	var sessions []string
	for id, dc := range m.dataChannels {
		if dc.ReadyState() == webrtc.DataChannelStateOpen {
			sessions = append(sessions, id)
		}
	}
	return sessions
}
