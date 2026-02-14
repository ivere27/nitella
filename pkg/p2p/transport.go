package p2p

import (
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/subtle"
	"crypto/x509"
	"encoding/json"
	"encoding/pem"
	"errors"
	"fmt"
	"log"
	"strings"
	"sync"
	"time"

	pb "github.com/ivere27/nitella/pkg/api/hub"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/pion/webrtc/v3"
	"google.golang.org/grpc"
	"google.golang.org/grpc/metadata"
)

// SignalingClient defines the subset of MobileService needed for P2P
type SignalingClient interface {
	StreamSignaling(ctx context.Context, opts ...grpc.CallOption) (pb.MobileService_StreamSignalingClient, error)
}

// DefaultSTUNServer is the default STUN server URL
const DefaultSTUNServer = "stun:stun.l.google.com:19302"

// AuthFailSendDelay is the time to wait for auth failure message to send before closing
const AuthFailSendDelay = 100 * time.Millisecond

// Transport manages WebRTC connections to nodes via Hub signaling
// This is used by CLI/mobile to connect to nitellad nodes
type Transport struct {
	// Identity
	myUserID  string
	myPrivKey ed25519.PrivateKey
	myPubKey  ed25519.PublicKey

	// Certificate-based authentication
	myCertPEM []byte         // Our certificate (signed by CA)
	caCert    *x509.Certificate // Trusted CA for verifying peers

	// Signaling
	signaling SignalingClient
	stream    pb.MobileService_StreamSignalingClient

	// WebRTC
	peers   map[string]*PeerConnection // Key: Remote NodeID
	peersMu sync.RWMutex
	api     *webrtc.API
	stunURL string // STUN server URL

	// Callback for received data (only called after authentication)
	onMessage func(senderID string, data []byte)

	// Callback for peer status (connected/disconnected)
	onPeerStatus func(senderID string, connected bool)

	// Callback for approval requests (P2P approval flow)
	onApprovalRequest func(nodeID string, req *ApprovalRequest)

	// Known node public keys for verification (extracted from verified certs)
	nodePublicKeys map[string]ed25519.PublicKey
	nodeKeysMu     sync.RWMutex

	// Pending request-response tracking (for SendCommandAndWait)
	pendingRequests map[string]chan *P2PMessage
	pendingMu       sync.Mutex

	// Replay protection
	nonceTracker *NonceTracker
}

// PeerConnection represents a WebRTC connection to a peer
type PeerConnection struct {
	pc            *webrtc.PeerConnection
	dataChannel   *webrtc.DataChannel
	remoteID      string
	authenticated bool
	authChallenge []byte // Challenge sent to peer
	remoteUserID  string // Verified user ID after auth
}

// NewTransport creates a new P2P Transport for CLI/mobile
func NewTransport(userID string, client SignalingClient) *Transport {
	// Setup WebRTC API with default settings
	settingEngine := webrtc.SettingEngine{}
	api := webrtc.NewAPI(webrtc.WithSettingEngine(settingEngine))

	return &Transport{
		myUserID:        userID,
		signaling:       client,
		peers:           make(map[string]*PeerConnection),
		api:             api,
		nodePublicKeys:  make(map[string]ed25519.PublicKey),
		pendingRequests: make(map[string]chan *P2PMessage),
		stunURL:         DefaultSTUNServer,
		nonceTracker:    NewNonceTracker(5 * time.Minute), // 5 min replay window
	}
}

// SetSTUNServer sets the STUN server URL for ICE negotiation
func (t *Transport) SetSTUNServer(url string) {
	if url != "" {
		t.stunURL = url
	}
}

// SetIdentity sets the local identity for authentication
func (t *Transport) SetIdentity(privKey ed25519.PrivateKey) {
	t.myPrivKey = privKey
	if privKey != nil && len(privKey) == ed25519.PrivateKeySize {
		t.myPubKey = privKey.Public().(ed25519.PublicKey)
	}
}

// SetCertificates sets the CA certificate for peer verification and our own certificate
func (t *Transport) SetCertificates(caCertPEM, myCertPEM []byte) error {
	// Parse CA certificate
	block, _ := pem.Decode(caCertPEM)
	if block == nil {
		return fmt.Errorf("failed to decode CA certificate PEM")
	}
	caCert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return fmt.Errorf("failed to parse CA certificate: %w", err)
	}
	t.caCert = caCert
	t.myCertPEM = myCertPEM
	return nil
}

// RegisterNodeKey registers a node's public key for verification
func (t *Transport) RegisterNodeKey(nodeID string, pubKey ed25519.PublicKey) {
	t.nodeKeysMu.Lock()
	defer t.nodeKeysMu.Unlock()
	t.nodePublicKeys[nodeID] = pubKey
}

// GetNodeKey retrieves a registered node public key
func (t *Transport) GetNodeKey(nodeID string) (ed25519.PublicKey, bool) {
	t.nodeKeysMu.RLock()
	defer t.nodeKeysMu.RUnlock()
	key, ok := t.nodePublicKeys[nodeID]
	return key, ok
}

// StartSignaling connects to the Hub signaling stream
func (t *Transport) StartSignaling(ctx context.Context) error {
	// Add user_id to metadata for routing, preserving existing metadata
	md, _ := metadata.FromOutgoingContext(ctx)
	newMD := md.Copy()
	newMD.Set("user_id", t.myUserID)
	ctx = metadata.NewOutgoingContext(ctx, newMD)

	stream, err := t.signaling.StreamSignaling(ctx)
	if err != nil {
		return fmt.Errorf("failed to start signaling stream: %w", err)
	}
	t.stream = stream

	// Start receive loop
	go t.receiveLoop()
	return nil
}

// SetMessageHandler sets the callback for incoming P2P messages
func (t *Transport) SetMessageHandler(handler func(senderID string, data []byte)) {
	t.onMessage = handler
}

// SetPeerStatusHandler sets the callback for peer connection status
func (t *Transport) SetPeerStatusHandler(handler func(senderID string, connected bool)) {
	t.onPeerStatus = handler
}

func (t *Transport) setupPeerHandlers(peer *PeerConnection) {
	handleOpen := func() {
		log.Printf("[P2P] DataChannel OPEN for %s", peer.remoteID)
		// Authentication is mandatory - reject if no private key configured
		if t.myPrivKey == nil {
			log.Printf("[P2P] Rejecting peer %s: no private key configured (authentication required)", peer.remoteID)
			peer.pc.Close()
			return
		}
		t.initiateAuth(peer)
	}

	handleMessage := func(msg webrtc.DataChannelMessage) {
		// Authentication is mandatory - process auth messages until authenticated
		if !peer.authenticated {
			t.handleAuthMessage(peer, msg.Data)
			return
		}
		// Try P2P protocol messages first
		if t.handleP2PMessage(peer.remoteID, msg.Data) {
			return
		}
		// Fallback to generic message handler
		if t.onMessage != nil {
			t.onMessage(peer.remoteID, msg.Data)
		}
	}

	// Data Channel Events (Responder)
	peer.pc.OnDataChannel(func(d *webrtc.DataChannel) {
		peer.dataChannel = d
		d.OnOpen(handleOpen)
		d.OnMessage(handleMessage)
	})

	// ICE Candidates
	peer.pc.OnICECandidate(func(c *webrtc.ICECandidate) {
		if c == nil {
			return
		}
		payload, _ := json.Marshal(c.ToJSON())
		t.sendSignal(peer.remoteID, "candidate", payload)
	})

	// Connection State
	peer.pc.OnConnectionStateChange(func(s webrtc.PeerConnectionState) {
		log.Printf("[P2P] Peer %s state: %s", peer.remoteID, s)
		if s == webrtc.PeerConnectionStateFailed || s == webrtc.PeerConnectionStateClosed {
			if t.onPeerStatus != nil {
				t.onPeerStatus(peer.remoteID, false)
			}
		}
	})

	// Setup handling for Initiator's data channel (if we created it)
	if peer.dataChannel != nil {
		peer.dataChannel.OnOpen(handleOpen)
		peer.dataChannel.OnMessage(handleMessage)
	}
}

// --- P2P Authentication Methods ---

// initiateAuth starts the authentication handshake by sending a challenge
func (t *Transport) initiateAuth(peer *PeerConnection) {
	// Generate random challenge
	challenge := make([]byte, 32)
	if _, err := rand.Read(challenge); err != nil {
		log.Printf("[P2P] Failed to generate auth challenge: %v", err)
		return
	}
	peer.authChallenge = challenge

	// Send challenge with our identity and certificate
	authMsg := AuthMessage{
		Type:      AuthChallenge,
		Challenge: challenge,
		UserID:    t.myUserID,
		PublicKey: t.myPubKey,
		CertPEM:   string(t.myCertPEM),
	}
	data, _ := json.Marshal(authMsg)

	if peer.dataChannel != nil && peer.dataChannel.ReadyState() == webrtc.DataChannelStateOpen {
		peer.dataChannel.Send(data)
		log.Printf("[P2P] Sent auth challenge to %s", peer.remoteID)
	}
}

// handleAuthMessage processes authentication protocol messages
func (t *Transport) handleAuthMessage(peer *PeerConnection, data []byte) {
	var authMsg AuthMessage
	if err := json.Unmarshal(data, &authMsg); err != nil {
		// Not an auth message, might be regular data before auth completed
		log.Printf("[P2P] Non-auth message from unauthenticated peer %s", peer.remoteID)
		return
	}

	switch authMsg.Type {
	case AuthChallenge:
		t.handleAuthChallenge(peer, &authMsg)
	case AuthResponse:
		t.handleAuthResponse(peer, &authMsg)
	case AuthSuccess:
		t.handleAuthSuccess(peer)
	case AuthFailed:
		t.handleAuthFailed(peer)
	}
}

// handleAuthChallenge responds to an auth challenge from peer
func (t *Transport) handleAuthChallenge(peer *PeerConnection, msg *AuthMessage) {
	log.Printf("[P2P] Received auth challenge from %s (UserID: %s)", peer.remoteID, msg.UserID)

	// Verify peer's certificate against our CA
	if t.caCert != nil && msg.CertPEM != "" {
		if err := t.verifyCertificate(msg.CertPEM, msg.PublicKey); err != nil {
			log.Printf("[P2P] Peer certificate verification failed for %s: %v", msg.UserID, err)
			t.sendAuthFailed(peer)
			return
		}
	} else if t.caCert != nil {
		// We have CA but peer didn't send certificate - reject
		log.Printf("[P2P] Peer %s did not provide certificate", msg.UserID)
		t.sendAuthFailed(peer)
		return
	}

	// Sign the challenge
	if t.myPrivKey == nil {
		log.Printf("[P2P] Cannot respond to auth challenge: no private key")
		t.sendAuthFailed(peer)
		return
	}

	sig, err := nitellacrypto.Sign(msg.Challenge, t.myPrivKey)
	if err != nil {
		log.Printf("[P2P] Failed to sign auth challenge: %v", err)
		t.sendAuthFailed(peer)
		return
	}

	// Send response with our certificate
	response := AuthMessage{
		Type:      AuthResponse,
		UserID:    t.myUserID,
		PublicKey: t.myPubKey,
		CertPEM:   string(t.myCertPEM),
		Signature: sig,
		Challenge: msg.Challenge, // Echo back the challenge
	}
	data, _ := json.Marshal(response)

	if peer.dataChannel != nil {
		peer.dataChannel.Send(data)
		log.Printf("[P2P] Sent auth response to %s", peer.remoteID)
	}

	// Also send our own challenge to verify the peer
	t.initiateAuth(peer)
}

// handleAuthResponse verifies the peer's signature on our challenge
func (t *Transport) handleAuthResponse(peer *PeerConnection, msg *AuthMessage) {
	log.Printf("[P2P] Received auth response from %s (UserID: %s)", peer.remoteID, msg.UserID)

	// Verify the challenge matches what we sent (constant-time comparison)
	if subtle.ConstantTimeCompare(msg.Challenge, peer.authChallenge) != 1 {
		log.Printf("[P2P] Auth challenge mismatch from %s", peer.remoteID)
		t.sendAuthFailed(peer)
		return
	}

	// Verify peer's certificate against our CA
	if t.caCert != nil {
		if msg.CertPEM == "" {
			log.Printf("[P2P] Peer %s did not provide certificate", msg.UserID)
			t.sendAuthFailed(peer)
			return
		}
		if err := t.verifyCertificate(msg.CertPEM, msg.PublicKey); err != nil {
			log.Printf("[P2P] Peer certificate verification failed for %s: %v", msg.UserID, err)
			t.sendAuthFailed(peer)
			return
		}
	}

	// Get public key for verification
	var pubKey ed25519.PublicKey
	if len(msg.PublicKey) == ed25519.PublicKeySize {
		pubKey = ed25519.PublicKey(msg.PublicKey)
	} else {
		log.Printf("[P2P] No public key provided by %s", msg.UserID)
		t.sendAuthFailed(peer)
		return
	}

	// Verify signature
	if err := nitellacrypto.Verify(peer.authChallenge, msg.Signature, pubKey); err != nil {
		log.Printf("[P2P] Auth signature verification failed for %s: %v", msg.UserID, err)
		t.sendAuthFailed(peer)
		return
	}

	// Authentication successful!
	peer.authenticated = true
	peer.remoteUserID = msg.UserID
	log.Printf("[P2P] Peer %s authenticated as %s (certificate verified)", peer.remoteID, msg.UserID)

	// Store peer's public key for E2E encryption
	t.nodeKeysMu.Lock()
	t.nodePublicKeys[peer.remoteID] = pubKey
	t.nodeKeysMu.Unlock()
	log.Printf("[P2P] Stored public key for node %s", peer.remoteID)

	// Send success message
	successMsg := AuthMessage{Type: AuthSuccess}
	data, _ := json.Marshal(successMsg)
	if peer.dataChannel != nil {
		peer.dataChannel.Send(data)
	}

	// Notify connection status
	if t.onPeerStatus != nil {
		t.onPeerStatus(peer.remoteID, true)
	}
}

// handleAuthSuccess is called when peer confirms our auth
func (t *Transport) handleAuthSuccess(peer *PeerConnection) {
	log.Printf("[P2P] Auth success confirmed by %s", peer.remoteID)
}

// handleAuthFailed closes the connection on auth failure
func (t *Transport) handleAuthFailed(peer *PeerConnection) {
	log.Printf("[P2P] Auth failed with peer %s, closing connection", peer.remoteID)
	peer.pc.Close()
}

// sendAuthFailed sends an auth failure message and closes connection
func (t *Transport) sendAuthFailed(peer *PeerConnection) {
	failMsg := AuthMessage{Type: AuthFailed}
	data, _ := json.Marshal(failMsg)
	if peer.dataChannel != nil {
		peer.dataChannel.Send(data)
		// Give time for message to send
		time.Sleep(AuthFailSendDelay)
	}
	peer.pc.Close()
}

// verifyCertificate verifies that a peer's certificate is signed by our trusted CA
func (t *Transport) verifyCertificate(certPEM string, claimedPubKey []byte) error {
	if t.caCert == nil {
		return fmt.Errorf("no CA certificate configured")
	}

	// Parse peer's certificate
	block, _ := pem.Decode([]byte(certPEM))
	if block == nil {
		return fmt.Errorf("failed to decode certificate PEM")
	}
	peerCert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return fmt.Errorf("failed to parse certificate: %w", err)
	}

	// Verify certificate is signed by our CA
	if err := peerCert.CheckSignatureFrom(t.caCert); err != nil {
		return fmt.Errorf("certificate not signed by trusted CA: %w", err)
	}

	// Check certificate validity period
	now := time.Now()
	if now.Before(peerCert.NotBefore) {
		return fmt.Errorf("certificate not yet valid")
	}
	if now.After(peerCert.NotAfter) {
		return fmt.Errorf("certificate has expired")
	}

	// Verify the public key in the certificate matches the claimed public key (constant-time comparison)
	if len(claimedPubKey) == ed25519.PublicKeySize {
		certPubKey, ok := peerCert.PublicKey.(ed25519.PublicKey)
		if !ok {
			return fmt.Errorf("certificate does not contain Ed25519 public key")
		}
		if subtle.ConstantTimeCompare(certPubKey, claimedPubKey) != 1 {
			return fmt.Errorf("public key mismatch: claimed key does not match certificate")
		}
	}

	return nil
}

// IsAuthenticated checks if a peer is authenticated
func (t *Transport) IsAuthenticated(peerID string) bool {
	t.peersMu.RLock()
	defer t.peersMu.RUnlock()
	peer, ok := t.peers[peerID]
	if !ok {
		return false
	}
	return peer.authenticated
}

// GetPeerUserID returns the authenticated user ID for a peer
func (t *Transport) GetPeerUserID(peerID string) string {
	t.peersMu.RLock()
	defer t.peersMu.RUnlock()
	peer, ok := t.peers[peerID]
	if !ok || !peer.authenticated {
		return ""
	}
	return peer.remoteUserID
}

// Connect initiates a P2P connection to a target node
func (t *Transport) Connect(targetNodeID string) error {
	t.peersMu.Lock()
	if _, exists := t.peers[targetNodeID]; exists {
		t.peersMu.Unlock()
		return fmt.Errorf("already connected to %s", targetNodeID)
	}
	t.peersMu.Unlock()

	// Create PeerConnection
	config := webrtc.Configuration{
		ICEServers: []webrtc.ICEServer{
			{URLs: []string{t.stunURL}},
		},
	}

	pc, err := t.api.NewPeerConnection(config)
	if err != nil {
		return fmt.Errorf("failed to create PC: %w", err)
	}

	// Create Data Channel (Initiator creates it)
	dc, err := pc.CreateDataChannel("nitella", nil)
	if err != nil {
		pc.Close()
		return fmt.Errorf("failed to create data channel: %w", err)
	}

	peer := &PeerConnection{
		pc:          pc,
		dataChannel: dc,
		remoteID:    targetNodeID,
	}

	t.setupPeerHandlers(peer)

	// Store peer
	t.peersMu.Lock()
	t.peers[targetNodeID] = peer
	t.peersMu.Unlock()

	// Create Offer
	offer, err := pc.CreateOffer(nil)
	if err != nil {
		return err
	}

	if err = pc.SetLocalDescription(offer); err != nil {
		return err
	}

	// Send Offer via Signaling
	payload, _ := json.Marshal(offer)
	return t.sendSignal(targetNodeID, "offer", payload)
}

// Send sends data to a connected peer
func (t *Transport) Send(peerID string, data []byte) error {
	t.peersMu.RLock()
	peer, ok := t.peers[peerID]
	t.peersMu.RUnlock()

	if !ok {
		return fmt.Errorf("peer %s not found", peerID)
	}

	if peer.dataChannel == nil {
		return fmt.Errorf("no data channel for peer %s", peerID)
	}

	if peer.dataChannel.ReadyState() != webrtc.DataChannelStateOpen {
		return fmt.Errorf("data channel not open for peer %s", peerID)
	}

	return peer.dataChannel.Send(data)
}

// Broadcast sends data to all connected peers
func (t *Transport) Broadcast(data []byte) {
	t.peersMu.RLock()
	defer t.peersMu.RUnlock()

	for id, peer := range t.peers {
		if peer.dataChannel != nil && peer.dataChannel.ReadyState() == webrtc.DataChannelStateOpen {
			if err := peer.dataChannel.Send(data); err != nil {
				log.Printf("[P2P] Failed to send to %s: %v", id, err)
			}
		}
	}
}

// IsConnected checks if connected to a peer
func (t *Transport) IsConnected(peerID string) bool {
	t.peersMu.RLock()
	defer t.peersMu.RUnlock()

	peer, ok := t.peers[peerID]
	if !ok {
		return false
	}

	if peer.dataChannel == nil {
		return false
	}

	return peer.dataChannel.ReadyState() == webrtc.DataChannelStateOpen
}

// Close closes all connections and returns any errors encountered.
func (t *Transport) Close() error {
	// Stop nonce tracker goroutine
	if t.nonceTracker != nil {
		t.nonceTracker.Stop()
	}

	// Cancel all pending requests
	t.pendingMu.Lock()
	for id, ch := range t.pendingRequests {
		close(ch)
		delete(t.pendingRequests, id)
	}
	t.pendingMu.Unlock()

	t.peersMu.Lock()
	defer t.peersMu.Unlock()

	var errs []error
	for _, peer := range t.peers {
		if err := peer.pc.Close(); err != nil {
			errs = append(errs, err)
		}
	}
	t.peers = make(map[string]*PeerConnection)
	return errors.Join(errs...)
}

// --- Internal ---

func (t *Transport) receiveLoop() {
	for {
		msg, err := t.stream.Recv()
		if err != nil {
			// Suppress logs for expected shutdown errors
			errStr := err.Error()
			if !strings.Contains(errStr, "Canceled") && !strings.Contains(errStr, "client connection is closing") {
				log.Printf("[P2P] Signaling stream ended: %v", err)
			}
			return
		}

		// Determine Sender Identity
		senderID := msg.SourceId
		if msg.SourceUserId != "" {
			senderID = msg.SourceUserId
		}

		// Handle signals based on type
		switch msg.Type {
		case "offer":
			t.handleOffer(senderID, []byte(msg.Payload))

		case "answer":
			t.handleAnswer(senderID, []byte(msg.Payload))

		case "candidate":
			t.handleCandidate(senderID, []byte(msg.Payload))
		}
	}
}

func (t *Transport) sendSignal(targetID, typeStr string, payload []byte) error {
	msg := &pb.SignalMessage{
		TargetId: targetID,
		Type:     typeStr,
		Payload:  string(payload),
	}
	return t.stream.Send(msg)
}

func (t *Transport) handleOffer(senderID string, payload []byte) {
	// Parse Offer
	var offer webrtc.SessionDescription
	if err := json.Unmarshal(payload, &offer); err != nil {
		log.Printf("[P2P] Invalid offer from %s: %v", senderID, err)
		return
	}

	// Create PC (Responder)
	config := webrtc.Configuration{
		ICEServers: []webrtc.ICEServer{
			{URLs: []string{t.stunURL}},
		},
	}
	pc, err := t.api.NewPeerConnection(config)
	if err != nil {
		log.Printf("[P2P] Failed to create PeerConnection for %s: %v", senderID, err)
		return
	}

	peer := &PeerConnection{
		pc:       pc,
		remoteID: senderID,
	}
	t.setupPeerHandlers(peer)

	t.peersMu.Lock()
	t.peers[senderID] = peer
	t.peersMu.Unlock()

	// Set Remote
	if err := pc.SetRemoteDescription(offer); err != nil {
		log.Printf("[P2P] Failed to set remote desc: %v", err)
		pc.Close()
		return
	}

	// Create Answer
	answer, err := pc.CreateAnswer(nil)
	if err != nil {
		log.Printf("[P2P] Failed to create answer: %v", err)
		pc.Close()
		return
	}

	if err = pc.SetLocalDescription(answer); err != nil {
		log.Printf("[P2P] Failed to set local desc: %v", err)
		pc.Close()
		return
	}

	// Send Answer
	answerPayload, _ := json.Marshal(answer)
	if err := t.sendSignal(senderID, "answer", answerPayload); err != nil {
		log.Printf("[P2P] Failed to send answer: %v", err)
	}
}

func (t *Transport) handleAnswer(senderID string, payload []byte) {
	t.peersMu.RLock()
	peer, exists := t.peers[senderID]
	t.peersMu.RUnlock()

	if !exists {
		log.Printf("[P2P] Received answer from unknown peer %s", senderID)
		return
	}

	var answer webrtc.SessionDescription
	if err := json.Unmarshal(payload, &answer); err != nil {
		log.Printf("[P2P] Invalid answer from %s: %v", senderID, err)
		return
	}

	if err := peer.pc.SetRemoteDescription(answer); err != nil {
		log.Printf("[P2P] Failed to set remote desc (answer) from %s: %v", senderID, err)
	}
}

func (t *Transport) handleCandidate(senderID string, payload []byte) {
	t.peersMu.RLock()
	peer, exists := t.peers[senderID]
	t.peersMu.RUnlock()

	if !exists {
		return
	}

	var candidate webrtc.ICECandidateInit
	if err := json.Unmarshal(payload, &candidate); err != nil {
		log.Printf("[P2P] Invalid candidate from %s: %v", senderID, err)
		return
	}

	if err := peer.pc.AddICECandidate(candidate); err != nil {
		log.Printf("[P2P] Failed to add candidate from %s: %v", senderID, err)
	}
}

// SetApprovalRequestHandler sets the callback for incoming P2P approval requests
func (t *Transport) SetApprovalRequestHandler(handler func(nodeID string, req *ApprovalRequest)) {
	t.onApprovalRequest = handler
}

// SendApprovalDecision sends an approval decision to a specific node via P2P
// The message is encrypted with the node's public key
func (t *Transport) SendApprovalDecision(nodeID string, decision *ApprovalDecision) error {
	msg, err := NewP2PMessage(MessageTypeApprovalDecision, decision)
	if err != nil {
		return fmt.Errorf("failed to create decision message: %w", err)
	}

	// Get node's public key for encryption
	t.nodeKeysMu.RLock()
	nodePubKey := t.nodePublicKeys[nodeID]
	t.nodeKeysMu.RUnlock()

	if nodePubKey == nil {
		return fmt.Errorf("no public key for node %s", nodeID)
	}

	// Encrypt with node's public key
	data, err := EncryptP2PMessage(msg, nodePubKey)
	if err != nil {
		return fmt.Errorf("failed to encrypt decision: %w", err)
	}

	return t.Send(nodeID, data)
}

// SendCommandAndWait sends a command message to a node and waits for the correlated response.
// The msg must have a RequestID set for correlation. Returns the response message or error on timeout.
func (t *Transport) SendCommandAndWait(nodeID string, msg *P2PMessage, timeout time.Duration) (*P2PMessage, error) {
	if msg.RequestID == "" {
		return nil, fmt.Errorf("message must have RequestID for request-response correlation")
	}

	// Register pending request channel
	ch := make(chan *P2PMessage, 1)
	t.pendingMu.Lock()
	t.pendingRequests[msg.RequestID] = ch
	t.pendingMu.Unlock()

	// Clean up on exit
	defer func() {
		t.pendingMu.Lock()
		delete(t.pendingRequests, msg.RequestID)
		t.pendingMu.Unlock()
	}()

	// Get node's public key for encryption
	t.nodeKeysMu.RLock()
	nodePubKey := t.nodePublicKeys[nodeID]
	t.nodeKeysMu.RUnlock()

	if nodePubKey == nil {
		return nil, fmt.Errorf("no public key for node %s", nodeID)
	}

	// Encrypt and send
	encData, err := EncryptP2PMessage(msg, nodePubKey)
	if err != nil {
		return nil, fmt.Errorf("failed to encrypt command: %w", err)
	}

	if err := t.Send(nodeID, encData); err != nil {
		return nil, fmt.Errorf("failed to send command: %w", err)
	}

	// Wait for response with timeout
	timer := time.NewTimer(timeout)
	defer timer.Stop()

	select {
	case resp := <-ch:
		return resp, nil
	case <-timer.C:
		return nil, fmt.Errorf("command timed out after %v", timeout)
	}
}

// deliverResponse delivers a response message to a pending request channel.
// Returns true if a pending request was found and delivered to.
func (t *Transport) deliverResponse(requestID string, msg *P2PMessage) bool {
	t.pendingMu.Lock()
	ch, ok := t.pendingRequests[requestID]
	t.pendingMu.Unlock()

	if !ok {
		return false
	}

	select {
	case ch <- msg:
		return true
	default:
		return false
	}
}

// handleP2PMessage parses and routes incoming P2P protocol messages
// SECURITY: Only called for authenticated peers, all messages must be encrypted
func (t *Transport) handleP2PMessage(senderID string, data []byte) bool {
	if t.myPrivKey == nil {
		// Should never happen - authentication requires private key (see line 177)
		log.Printf("[P2P] SECURITY: Rejecting message from %s - no private key", senderID)
		return true // Consumed but rejected
	}

	msg, err := DecryptP2PMessage(data, t.myPrivKey)
	if err != nil {
		// Decryption failed - reject (no plaintext fallback)
		log.Printf("[P2P] Rejecting unencrypted/malformed message from %s: %v", senderID, err)
		return true // Consumed but rejected
	}

	// Check for replay attacks (skip for encrypted wrapper - inner msg has nonce)
	if msg.Type != MessageTypeEncrypted && t.nonceTracker != nil {
		if !t.nonceTracker.Check(msg.Nonce, msg.Timestamp) {
			log.Printf("[P2P] Replay attack detected from %s (nonce: %s)", senderID, msg.Nonce)
			return true // Consumed but rejected
		}
	}

	switch msg.Type {
	case MessageTypeApprovalRequest:
		if t.onApprovalRequest != nil {
			if req, err := msg.ParseApprovalRequest(); err == nil {
				t.onApprovalRequest(senderID, req)
			} else {
				log.Printf("[P2P] Failed to parse approval request: %v", err)
			}
		}
		return true
	case MessageTypeCommandResponse:
		// Route to pending request if we have a matching RequestID
		if resp, err := msg.ParseCommandResponse(); err == nil && resp.RequestID != "" {
			if t.deliverResponse(resp.RequestID, msg) {
				return true
			}
		}
		// No pending request found, forward to generic handler
		if t.onMessage != nil {
			t.onMessage(senderID, msg.Payload)
		}
		return true
	case MessageTypeMetrics, MessageTypeCommand:
		// Forward to generic handler
		if t.onMessage != nil {
			t.onMessage(senderID, msg.Payload)
		}
		return true
	default:
		return false
	}
}

// GetConnectedNodes returns list of connected node IDs
func (t *Transport) GetConnectedNodes() []string {
	t.peersMu.RLock()
	defer t.peersMu.RUnlock()

	var nodes []string
	for id, peer := range t.peers {
		if peer.dataChannel != nil && peer.dataChannel.ReadyState() == webrtc.DataChannelStateOpen {
			nodes = append(nodes, id)
		}
	}
	return nodes
}

// HasConnectedNodes returns true if there are any active P2P connections
func (t *Transport) HasConnectedNodes() bool {
	t.peersMu.RLock()
	defer t.peersMu.RUnlock()

	for _, peer := range t.peers {
		if peer.dataChannel != nil && peer.dataChannel.ReadyState() == webrtc.DataChannelStateOpen {
			return true
		}
	}
	return false
}
