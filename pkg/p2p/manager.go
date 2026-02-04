package p2p

import (
	"crypto/ed25519"
	"encoding/json"
	"fmt"
	"log"
	"sync"
	"time"

	pb "github.com/ivere27/nitella/pkg/api/hub"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/pion/webrtc/v3"
)

// Manager handles P2P WebRTC connections for nodes
// This is used by nitellad to accept P2P connections from CLI/mobile clients
type Manager struct {
	signalingOut chan *pb.SignalMessage
	pcs          map[string]*webrtc.PeerConnection // Key: SessionID
	dataChannels map[string]*webrtc.DataChannel    // Key: SessionID
	sessionPubKeys map[string]ed25519.PublicKey    // Key: SessionID -> CLI's public key
	sessionAuth    map[string]bool                 // Key: SessionID -> authenticated
	authChallenges map[string][]byte               // Key: SessionID -> challenge sent
	mu           sync.RWMutex

	// Node's identity for authentication
	nodePrivKey ed25519.PrivateKey
	nodePubKey  ed25519.PublicKey
	nodeID      string
	nodeCertPEM []byte

	// Metrics Callback - called periodically to get encrypted metrics
	GetMetrics func() *pb.EncryptedMetrics

	// Incoming Command Callback - called when data is received via P2P
	OnCommand func(sessionID string, data []byte)

	// On Response Callback - called when a response is received
	OnResponse func(sessionID string, data []byte)

	// OnApprovalDecision - called when approval decision received via P2P
	OnApprovalDecision func(sessionID string, decision *ApprovalDecision)

	sem     chan struct{} // Semaphore for concurrent signaling handlers
	stunURL string        // STUN server URL
}

// NewManager creates a new P2P Manager for nodes
func NewManager(outCh chan *pb.SignalMessage) *Manager {
	return &Manager{
		signalingOut:   outCh,
		pcs:            make(map[string]*webrtc.PeerConnection),
		dataChannels:   make(map[string]*webrtc.DataChannel),
		sessionPubKeys: make(map[string]ed25519.PublicKey),
		sessionAuth:    make(map[string]bool),
		authChallenges: make(map[string][]byte),
		sem:            make(chan struct{}, 10), // Limit to 10 concurrent handshakes
		stunURL:        DefaultSTUNServer,
	}
}

// SetNodeIdentity sets the node's identity for P2P authentication
func (m *Manager) SetNodeIdentity(nodeID string, privKey ed25519.PrivateKey, certPEM []byte) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.nodeID = nodeID
	m.nodePrivKey = privKey
	m.nodePubKey = privKey.Public().(ed25519.PublicKey)
	m.nodeCertPEM = certPEM
}

// SetNodePrivKey sets the node's private key for decrypting incoming P2P messages
// Deprecated: use SetNodeIdentity instead
func (m *Manager) SetNodePrivKey(privKey ed25519.PrivateKey) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.nodePrivKey = privKey
	m.nodePubKey = privKey.Public().(ed25519.PublicKey)
}

// SetSessionPubKey sets the public key for a connected session (CLI's public key)
func (m *Manager) SetSessionPubKey(sessionID string, pubKey ed25519.PublicKey) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.sessionPubKeys[sessionID] = pubKey
}

// GetSessionPubKey returns the public key for a session
func (m *Manager) GetSessionPubKey(sessionID string) ed25519.PublicKey {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.sessionPubKeys[sessionID]
}

// IsSessionAuthenticated checks if a session has completed authentication
func (m *Manager) IsSessionAuthenticated(sessionID string) bool {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.sessionAuth[sessionID]
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
			m.handleIncomingMessage(sessionID, msg.Data)
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

// handleIncomingMessage routes incoming P2P messages based on type
func (m *Manager) handleIncomingMessage(sessionID string, data []byte) {
	// Check for authentication messages first (before encryption check)
	if IsAuthMessage(data) {
		m.handleAuthMessage(sessionID, data)
		return
	}

	// Check if session is authenticated
	m.mu.RLock()
	authenticated := m.sessionAuth[sessionID]
	privKey := m.nodePrivKey
	m.mu.RUnlock()

	if !authenticated {
		log.Printf("[P2P] Ignoring message from unauthenticated session %s", sessionID)
		return
	}

	// Try to decrypt if we have a private key
	var msg *P2PMessage
	var err error

	if privKey == nil {
		log.Printf("[P2P] SECURITY: Rejecting message from %s - no private key configured", sessionID)
		return
	}

	// Require encrypted messages - no unencrypted fallback for security
	msg, err = DecryptP2PMessage(data, privKey)
	if err != nil {
		log.Printf("[P2P] SECURITY: Rejecting unencrypted/invalid message from %s: %v", sessionID, err)
		return
	}

	if err != nil {
		// Fallback to legacy command handler
		if m.OnCommand != nil {
			m.OnCommand(sessionID, data)
		}
		return
	}

	switch msg.Type {
	case MessageTypeApprovalDecision:
		if m.OnApprovalDecision != nil {
			if decision, err := msg.ParseApprovalDecision(); err == nil {
				m.OnApprovalDecision(sessionID, decision)
			} else {
				log.Printf("[P2P] Failed to parse approval decision: %v", err)
			}
		}
	case MessageTypeCommand, MessageTypeCommandResponse:
		// Forward to legacy command handler
		if m.OnCommand != nil {
			m.OnCommand(sessionID, msg.Payload)
		}
	default:
		// Unknown type, try legacy handler
		if m.OnCommand != nil {
			m.OnCommand(sessionID, data)
		}
	}
}

// handleAuthMessage processes P2P authentication messages
func (m *Manager) handleAuthMessage(sessionID string, data []byte) {
	authMsg, err := ParseAuthMessage(data)
	if err != nil {
		log.Printf("[P2P] Failed to parse auth message from %s: %v", sessionID, err)
		return
	}

	switch authMsg.Type {
	case AuthChallenge:
		m.handleAuthChallenge(sessionID, authMsg)
	case AuthResponse:
		m.handleAuthResponse(sessionID, authMsg)
	case AuthSuccess:
		log.Printf("[P2P] Auth success from %s", sessionID)
	case AuthFailed:
		log.Printf("[P2P] Auth failed from %s", sessionID)
	}
}

// handleAuthChallenge responds to an auth challenge from CLI
func (m *Manager) handleAuthChallenge(sessionID string, msg *AuthMessage) {
	log.Printf("[P2P] Received auth challenge from %s (UserID: %s)", sessionID, msg.UserID)

	m.mu.RLock()
	privKey := m.nodePrivKey
	pubKey := m.nodePubKey
	certPEM := m.nodeCertPEM
	nodeID := m.nodeID
	m.mu.RUnlock()

	if privKey == nil {
		log.Printf("[P2P] Cannot respond to auth: no private key configured")
		return
	}

	// Sign the challenge
	sig, err := nitellacrypto.Sign(msg.Challenge, privKey)
	if err != nil {
		log.Printf("[P2P] Failed to sign challenge: %v", err)
		return
	}

	// Send response with our certificate and signature
	response := AuthMessage{
		Type:      AuthResponse,
		UserID:    nodeID,
		PublicKey: pubKey,
		CertPEM:   string(certPEM),
		Signature: sig,
		Challenge: msg.Challenge,
	}
	responseData, _ := json.Marshal(response)

	if err := m.SendCommand(sessionID, responseData); err != nil {
		log.Printf("[P2P] Failed to send auth response to %s: %v", sessionID, err)
		return
	}
	log.Printf("[P2P] Sent auth response to %s", sessionID)

	// Store CLI's public key for encryption
	if len(msg.PublicKey) == ed25519.PublicKeySize {
		m.mu.Lock()
		m.sessionPubKeys[sessionID] = ed25519.PublicKey(msg.PublicKey)
		m.sessionAuth[sessionID] = true // Mark as authenticated after responding
		m.mu.Unlock()
		log.Printf("[P2P] Stored public key and authenticated session %s", sessionID)
	}
}

// handleAuthResponse verifies CLI's response to our challenge (if we sent one)
func (m *Manager) handleAuthResponse(sessionID string, msg *AuthMessage) {
	log.Printf("[P2P] Received auth response from %s", sessionID)

	// Verify we sent a challenge to this session
	m.mu.RLock()
	challenge := m.authChallenges[sessionID]
	m.mu.RUnlock()

	if challenge == nil {
		// We didn't send a challenge, but CLI is responding - accept if valid
		log.Printf("[P2P] No challenge sent to %s, accepting response", sessionID)
	}

	// Get public key from response
	if len(msg.PublicKey) != ed25519.PublicKeySize {
		log.Printf("[P2P] Invalid public key size from %s", sessionID)
		return
	}
	pubKey := ed25519.PublicKey(msg.PublicKey)

	// Verify signature if we have a challenge
	if challenge != nil {
		if err := nitellacrypto.Verify(challenge, msg.Signature, pubKey); err != nil {
			log.Printf("[P2P] Auth signature verification failed for %s: %v", sessionID, err)
			return
		}
	}

	// Authentication successful - store public key
	m.mu.Lock()
	m.sessionPubKeys[sessionID] = pubKey
	m.sessionAuth[sessionID] = true
	delete(m.authChallenges, sessionID)
	m.mu.Unlock()

	log.Printf("[P2P] Session %s authenticated, public key stored", sessionID)

	// Send success message
	successMsg := AuthMessage{Type: AuthSuccess}
	successData, _ := json.Marshal(successMsg)
	m.SendCommand(sessionID, successData)
}

// SendApprovalRequest broadcasts an approval request to all connected P2P sessions
// Messages are encrypted with each session's public key
// Returns the number of sessions notified, or 0 if none connected
func (m *Manager) SendApprovalRequest(req *ApprovalRequest) int {
	msg, err := NewP2PMessage(MessageTypeApprovalRequest, req)
	if err != nil {
		log.Printf("[P2P] Failed to create approval request message: %v", err)
		return 0
	}

	sessions := m.GetConnectedSessions()
	sent := 0
	for _, sessionID := range sessions {
		// Get session's public key for encryption
		pubKey := m.GetSessionPubKey(sessionID)
		if pubKey == nil {
			log.Printf("[P2P] No public key for session %s, skipping", sessionID)
			continue
		}

		// Encrypt with session's public key
		data, err := EncryptP2PMessage(msg, pubKey)
		if err != nil {
			log.Printf("[P2P] Failed to encrypt for session %s: %v", sessionID, err)
			continue
		}

		if err := m.SendCommand(sessionID, data); err != nil {
			log.Printf("[P2P] Failed to send approval request to %s: %v", sessionID, err)
		} else {
			sent++
		}
	}

	if sent > 0 {
		log.Printf("[P2P] Sent encrypted approval request %s to %d sessions", req.RequestID, sent)
	}

	return sent
}

// HasConnectedSessions returns true if there are any active P2P connections
func (m *Manager) HasConnectedSessions() bool {
	m.mu.RLock()
	defer m.mu.RUnlock()

	for _, dc := range m.dataChannels {
		if dc.ReadyState() == webrtc.DataChannelStateOpen {
			return true
		}
	}
	return false
}
