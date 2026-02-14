package server

import (
	"context"
	"crypto/sha256"
	"crypto/x509"
	"encoding/hex"
	"encoding/pem"
	"errors"
	"io"
	"log"
	"strings"
	"sync"
	"time"

	"github.com/ivere27/nitella/pkg/hub/auth"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/peer"
	"google.golang.org/grpc/status"

	pb "github.com/ivere27/nitella/pkg/api/hub"
	"github.com/ivere27/nitella/pkg/hub/model"
)

// ============================================================================
// PairingServer - PAKE-based pairing service (Hub learns nothing)
// ============================================================================

type PairingServer struct {
	pb.UnimplementedPairingServiceServer
	hub *HubServer

	// Active PAKE sessions: sessionCode -> channel for relaying messages
	pakeSessions   map[string]*pakeSession
	pakeSessionsMu sync.RWMutex
}

type pakeSession struct {
	code         string
	cliChan      chan *pb.PakeMessage // Messages from CLI to Node
	nodeChan     chan *pb.PakeMessage // Messages from Node to CLI
	created      time.Time
	cliJoined    bool
	nodeJoined   bool
	cliUserID    string     // Best-effort extracted from CLI JWT
	cliPeerAddr  string     // Best-effort peer address for CLI stream
	nodePeerAddr string     // Best-effort peer address for node stream
	closed       bool       // Flag to prevent send on closed channel
	closeMu      sync.Mutex // Protects closed flag and channel close operations
}

func NewPairingServer(hub *HubServer) *PairingServer {
	ps := &PairingServer{
		hub:          hub,
		pakeSessions: make(map[string]*pakeSession),
	}
	// Cleanup expired sessions periodically
	go ps.cleanupLoop()
	return ps
}

func (s *PairingServer) cleanupLoop() {
	ticker := time.NewTicker(30 * time.Second)
	for range ticker.C {
		s.pakeSessionsMu.Lock()
		now := time.Now()
		for code, sess := range s.pakeSessions {
			// Sessions expire after 5 minutes
			if now.Sub(sess.created) > 5*time.Minute {
				// Safely close channels with synchronization
				sess.closeMu.Lock()
				if !sess.closed {
					sess.closed = true
					close(sess.cliChan)
					close(sess.nodeChan)
				}
				sess.closeMu.Unlock()
				delete(s.pakeSessions, code)
			}
		}
		s.pakeSessionsMu.Unlock()
	}
}

// safeSend sends a message to a channel safely, handling closed channels
func (sess *pakeSession) safeSend(ch chan *pb.PakeMessage, msg *pb.PakeMessage) bool {
	sess.closeMu.Lock()
	defer sess.closeMu.Unlock()
	if sess.closed {
		return false
	}
	select {
	case ch <- msg:
		return true
	default:
		return false // Channel full
	}
}

// PakeExchange handles bidirectional PAKE message relay
// Hub only relays messages - cannot derive the shared secret
func (s *PairingServer) PakeExchange(stream grpc.BidiStreamingServer[pb.PakeMessage, pb.PakeMessage]) error {
	start := time.Now()
	ctx := stream.Context()
	peerAddr := pairingPeerAddr(ctx)
	userID := s.extractPairingUserID(ctx)

	// First message determines role and session code
	firstMsg, err := stream.Recv()
	if err != nil {
		s.logPakeExchangeEnd("", "", userID, "", peerAddr, err, time.Since(start))
		return err
	}

	sessionCode := firstMsg.SessionCode
	role := firstMsg.Role

	if sessionCode == "" {
		return status.Error(codes.InvalidArgument, "session_code required")
	}
	// Validate session code length to prevent DoS via large keys
	if len(sessionCode) > 128 {
		return status.Error(codes.InvalidArgument, "session_code too long (max 128 chars)")
	}
	if role != "cli" && role != "node" {
		return status.Error(codes.InvalidArgument, "role must be 'cli' or 'node'")
	}

	// Get or create session
	s.pakeSessionsMu.Lock()
	sess, exists := s.pakeSessions[sessionCode]
	if !exists {
		sess = &pakeSession{
			code:     sessionCode,
			cliChan:  make(chan *pb.PakeMessage, 10),
			nodeChan: make(chan *pb.PakeMessage, 10),
			created:  time.Now(),
		}
		s.pakeSessions[sessionCode] = sess
	}

	// Mark role as joined
	if role == "cli" {
		if sess.cliJoined {
			s.pakeSessionsMu.Unlock()
			return status.Error(codes.AlreadyExists, "CLI already connected to this session")
		}
		sess.cliJoined = true
		if userID != "" {
			sess.cliUserID = userID
		}
		if peerAddr != "" {
			sess.cliPeerAddr = peerAddr
		}
	} else {
		if sess.nodeJoined {
			s.pakeSessionsMu.Unlock()
			return status.Error(codes.AlreadyExists, "Node already connected to this session")
		}
		sess.nodeJoined = true
		if peerAddr != "" {
			sess.nodePeerAddr = peerAddr
		}
	}
	s.pakeSessionsMu.Unlock()

	// Determine send/receive channels based on role
	var sendChan, recvChan chan *pb.PakeMessage
	if role == "cli" {
		sendChan = sess.nodeChan // CLI sends to node
		recvChan = sess.cliChan  // CLI receives from node
	} else {
		sendChan = sess.cliChan  // Node sends to CLI
		recvChan = sess.nodeChan // Node receives from CLI
	}

	// Forward the first message to peer using safe send
	sess.safeSend(sendChan, firstMsg)

	// Relay messages in both directions
	errChan := make(chan error, 2)

	// Goroutine: receive from peer and send to this stream
	go func() {
		for {
			select {
			case <-ctx.Done():
				errChan <- ctx.Err()
				return
			case msg, ok := <-recvChan:
				if !ok {
					errChan <- nil
					return
				}
				if err := stream.Send(msg); err != nil {
					errChan <- err
					return
				}
			}
		}
	}()

	// Main loop: receive from this stream and send to peer
	go func() {
		for {
			msg, err := stream.Recv()
			if err != nil {
				errChan <- err
				return
			}
			// Use safeSend to avoid panic on closed channel
			if !sess.safeSend(sendChan, msg) {
				// Session closed or channel full
				select {
				case <-ctx.Done():
					errChan <- ctx.Err()
				default:
					errChan <- nil
				}
				return
			}
		}
	}()

	// Wait for either goroutine to finish
	err = <-errChan

	ownerUserID := ""
	// Cleanup on disconnect
	s.pakeSessionsMu.Lock()
	ownerUserID = sess.cliUserID
	if role == "cli" {
		sess.cliJoined = false
	} else {
		sess.nodeJoined = false
	}
	// Remove session if both disconnected
	if !sess.cliJoined && !sess.nodeJoined {
		// Safely close channels before deleting
		sess.closeMu.Lock()
		if !sess.closed {
			sess.closed = true
			close(sess.cliChan)
			close(sess.nodeChan)
		}
		sess.closeMu.Unlock()
		delete(s.pakeSessions, sessionCode)
	}
	s.pakeSessionsMu.Unlock()

	if err == io.EOF {
		return nil
	}
	s.logPakeExchangeEnd(role, sessionCode, userID, ownerUserID, peerAddr, err, time.Since(start))
	return err
}

func (s *PairingServer) logPakeExchangeEnd(role, sessionCode, userID, ownerUserID, peerAddr string, err error, duration time.Duration) {
	if err == nil {
		return
	}

	tag := pairingSessionTag(sessionCode)
	if isCanceledError(err) {
		switch role {
		case "cli":
			if userID != "" {
				log.Printf("[Pairing] PakeExchange canceled (role=cli user_id=%s session=%s peer=%s duration=%v)", userID, tag, peerAddr, duration)
			} else {
				log.Printf("[Pairing] PakeExchange canceled (role=cli session=%s peer=%s duration=%v)", tag, peerAddr, duration)
			}
		case "node":
			if ownerUserID != "" {
				log.Printf("[Pairing] PakeExchange canceled (role=node owner_user_id=%s session=%s peer=%s duration=%v)", ownerUserID, tag, peerAddr, duration)
			} else {
				log.Printf("[Pairing] PakeExchange canceled (role=node session=%s peer=%s duration=%v)", tag, peerAddr, duration)
			}
		default:
			if userID != "" {
				log.Printf("[Pairing] PakeExchange canceled (user_id=%s session=%s peer=%s duration=%v)", userID, tag, peerAddr, duration)
			} else {
				log.Printf("[Pairing] PakeExchange canceled (session=%s peer=%s duration=%v)", tag, peerAddr, duration)
			}
		}
		return
	}

	switch role {
	case "cli":
		log.Printf("[Pairing] PakeExchange ended with error (role=cli user_id=%s session=%s peer=%s err=%v duration=%v)", userID, tag, peerAddr, err, duration)
	case "node":
		if ownerUserID != "" {
			log.Printf("[Pairing] PakeExchange ended with error (role=node owner_user_id=%s session=%s peer=%s err=%v duration=%v)", ownerUserID, tag, peerAddr, err, duration)
		} else {
			log.Printf("[Pairing] PakeExchange ended with error (role=node session=%s peer=%s err=%v duration=%v)", tag, peerAddr, err, duration)
		}
	default:
		log.Printf("[Pairing] PakeExchange ended with error (session=%s peer=%s err=%v duration=%v)", tag, peerAddr, err, duration)
	}
}

func (s *PairingServer) extractPairingUserID(ctx context.Context) string {
	if userID, ok := auth.GetUserID(ctx); ok {
		userID = strings.TrimSpace(userID)
		if userID != "" {
			return userID
		}
	}

	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return ""
	}

	if ids := md.Get("user_id"); len(ids) > 0 {
		userID := strings.TrimSpace(ids[0])
		if userID != "" {
			return userID
		}
	}

	if s == nil || s.hub == nil || s.hub.tokenManager == nil {
		return ""
	}

	authz := md.Get("authorization")
	if len(authz) == 0 {
		return ""
	}
	tokenStr := strings.TrimSpace(authz[0])
	if strings.HasPrefix(strings.ToLower(tokenStr), "bearer ") {
		tokenStr = strings.TrimSpace(tokenStr[len("bearer "):])
	}
	if tokenStr == "" {
		return ""
	}
	claims, err := s.hub.tokenManager.ValidateToken(tokenStr)
	if err != nil || claims == nil {
		return ""
	}
	return strings.TrimSpace(claims.UserID)
}

func pairingPeerAddr(ctx context.Context) string {
	p, ok := peer.FromContext(ctx)
	if !ok || p.Addr == nil {
		return ""
	}
	return p.Addr.String()
}

func pairingSessionTag(code string) string {
	if strings.TrimSpace(code) == "" {
		return "-"
	}
	sum := sha256.Sum256([]byte(code))
	return hex.EncodeToString(sum[:4])
}

func isCanceledError(err error) bool {
	if err == nil {
		return false
	}
	if errors.Is(err, context.Canceled) {
		return true
	}
	if status.Code(err) == codes.Canceled {
		return true
	}
	msg := strings.ToLower(err.Error())
	return strings.Contains(msg, "context canceled")
}

// SubmitSignedCert handles QR-based offline pairing
// Node submits the certificate signed by CLI's Root CA
func (s *PairingServer) SubmitSignedCert(ctx context.Context, req *pb.SubmitSignedCertRequest) (*pb.Empty, error) {
	if req.CertPem == "" {
		return nil, status.Error(codes.InvalidArgument, "cert_pem required")
	}

	// Parse the certificate to extract node ID and verify
	block, _ := pem.Decode([]byte(req.CertPem))
	if block == nil {
		return nil, status.Error(codes.InvalidArgument, "invalid certificate PEM")
	}

	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "failed to parse certificate: %v", err)
	}

	nodeID := req.NodeId
	if nodeID == "" {
		nodeID = cert.Subject.CommonName
	}

	// Verify the CA certificate if provided
	if req.CaPem != "" {
		caBlock, _ := pem.Decode([]byte(req.CaPem))
		if caBlock == nil {
			return nil, status.Error(codes.InvalidArgument, "invalid CA certificate PEM")
		}
		caCert, err := x509.ParseCertificate(caBlock.Bytes)
		if err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "failed to parse CA certificate: %v", err)
		}
		// Verify cert is signed by this CA
		roots := x509.NewCertPool()
		roots.AddCert(caCert)
		if _, err := cert.Verify(x509.VerifyOptions{
			Roots:     roots,
			KeyUsages: []x509.ExtKeyUsage{x509.ExtKeyUsageClientAuth},
		}); err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "certificate not signed by provided CA: %v", err)
		}
	}

	// Zero-Trust: Use routing token from request (preferred) or context (legacy)
	routingToken := req.GetRoutingToken()
	if routingToken == "" {
		if rt := ctx.Value(ctxKeyRoutingToken); rt != nil {
			routingToken = rt.(string)
		}
	}

	// Store the node with routing token
	node := &model.Node{
		ID:           nodeID,
		RoutingToken: routingToken,
		CertPEM:      req.CertPem,
		Status:       "offline",
	}
	if err := s.hub.store.SaveNode(node); err != nil {
		return nil, status.Errorf(codes.Internal, "failed to save node: %v", err)
	}

	log.Printf("[Pairing] Node %s registered via QR pairing (fingerprint: %s)", nodeID, req.Fingerprint)

	return &pb.Empty{}, nil
}
