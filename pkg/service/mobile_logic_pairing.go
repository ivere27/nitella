package service

import (
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/x509"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"strings"
	"time"

	pb "github.com/ivere27/nitella/pkg/api/local"
	"github.com/ivere27/nitella/pkg/core"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/ivere27/nitella/pkg/identity"
	"github.com/ivere27/nitella/pkg/pairing"
	"google.golang.org/protobuf/types/known/emptypb"
)

// ===========================================================================
// Pairing (PAKE and QR Code)
// ===========================================================================

// StartPairing starts a PAKE pairing session and returns a human-readable code.
func (s *MobileLogicService) StartPairing(ctx context.Context, req *pb.StartPairingRequest) (*pb.StartPairingResponse, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if err := s.requireIdentity(); err != nil {
		return nil, err
	}

	// Generate session ID
	sessionBytes := make([]byte, 16)
	if _, err := rand.Read(sessionBytes); err != nil {
		return nil, fmt.Errorf("failed to generate session ID: %v", err)
	}
	sessionID := hex.EncodeToString(sessionBytes)

	// Generate pairing code using the pairing package
	code, err := pairing.GeneratePairingCode()
	if err != nil {
		return nil, fmt.Errorf("failed to generate pairing code: %v", err)
	}

	// Create PAKE session (we are the CLI/initiator role)
	pakeSession, err := pairing.NewPakeSession(pairing.RoleCLI, pairing.CodeToBytes(code))
	if err != nil {
		return nil, fmt.Errorf("failed to create PAKE session: %v", err)
	}

	// Create pairing session
	session := &pairingSession{
		sessionID:   sessionID,
		pairingCode: code,
		nodeName:    req.NodeName,
		expiresAt:   time.Now().Add(5 * time.Minute).Unix(),
		pakeSession: pakeSession,
		isInitiator: true,
	}
	s.pairingSessions[sessionID] = session

	// Clean up expired sessions proactively
	s.cleanExpiredPairingSessions()

	return &pb.StartPairingResponse{
		SessionId:        sessionID,
		PairingCode:      code,
		ExpiresInSeconds: 300, // 5 minutes
	}, nil
}

// JoinPairing joins an existing pairing session using the code from a node.
func (s *MobileLogicService) JoinPairing(ctx context.Context, req *pb.JoinPairingRequest) (*pb.JoinPairingResponse, error) {
	if strings.TrimSpace(req.PairingCode) == "" {
		return &pb.JoinPairingResponse{
			Success: false,
			Error:   "pairing code is required",
		}, nil
	}

	normalizedCode, err := pairing.ParsePairingCode(req.PairingCode)
	if err != nil {
		return &pb.JoinPairingResponse{
			Success: false,
			Error:   fmt.Sprintf("invalid pairing code: %v", err),
		}, nil
	}

	s.mu.RLock()
	if err := s.requireIdentity(); err != nil {
		s.mu.RUnlock()
		return &pb.JoinPairingResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}
	pairingClient := s.pairingClient
	s.mu.RUnlock()

	if pairingClient == nil {
		return &pb.JoinPairingResponse{
			Success: false,
			Error:   "not connected to Hub",
		}, nil
	}

	// Keep PAKE stream alive across JoinPairing -> FinalizePairing UI steps.
	// The unary JoinPairing RPC context is cancelled once this call returns.
	expiresAt := time.Now().Add(5 * time.Minute)
	exchangeCtx, exchangeCancel := context.WithDeadline(context.Background(), expiresAt)

	// Run PAKE exchange now (waits for node and receives CSR).
	result, err := pairing.RunExchange(exchangeCtx, pairingClient, normalizedCode)
	if err != nil {
		exchangeCancel()
		return &pb.JoinPairingResponse{
			Success: false,
			Error:   fmt.Sprintf("pairing failed: %v", err),
		}, nil
	}

	sessionBytes := make([]byte, 16)
	if _, err := rand.Read(sessionBytes); err != nil {
		pairing.RejectExchange(result, "session init failed")
		return &pb.JoinPairingResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to generate session ID: %v", err),
		}, nil
	}
	sessionID := hex.EncodeToString(sessionBytes)

	session := &pairingSession{
		sessionID:      sessionID,
		pairingCode:    normalizedCode,
		nodeName:       result.NodeID,
		expiresAt:      expiresAt.Unix(),
		exchangeCancel: exchangeCancel,
		isInitiator:    false,
		exchange:       result,
	}

	s.mu.Lock()
	s.pairingSessions[sessionID] = session
	s.cleanExpiredPairingSessions()
	s.mu.Unlock()

	nodeName := result.NodeID
	if nodeName == "" {
		nodeName = "Paired Node"
	}

	return &pb.JoinPairingResponse{
		Success:          true,
		SessionId:        sessionID,
		EmojiFingerprint: result.Emoji,
		NodeName:         nodeName,
		Fingerprint:      result.Fingerprint,
		EmojiHash:        result.EmojiHash,
		CsrFingerprint:   result.CSRFingerprint,
		CsrHash:          result.CSRHash,
	}, nil
}

// CompletePairing completes the PAKE pairing process.
func (s *MobileLogicService) CompletePairing(ctx context.Context, req *pb.CompletePairingRequest) (*pb.CompletePairingResponse, error) {
	s.mu.Lock()
	session, exists := s.pairingSessions[req.SessionId]
	if !exists {
		s.mu.Unlock()
		return &pb.CompletePairingResponse{
			Success: false,
			Error:   "session not found",
		}, nil
	}

	// Check expiry
	if time.Now().Unix() > session.expiresAt {
		if session.exchangeCancel != nil {
			session.exchangeCancel()
			session.exchangeCancel = nil
		}
		delete(s.pairingSessions, req.SessionId)
		s.mu.Unlock()
		return &pb.CompletePairingResponse{
			Success: false,
			Error:   "session expired",
		}, nil
	}

	// Preferred unary flow used by Flutter:
	// JoinPairing already completed PAKE and buffered ExchangeResult.
	if session.exchange != nil {
		if err := s.requireIdentity(); err != nil {
			s.mu.Unlock()
			return &pb.CompletePairingResponse{Success: false, Error: err.Error()}, nil
		}

		nodeName := session.nodeName
		exchange := session.exchange
		rootCertPEM := append([]byte(nil), s.identity.RootCertPEM...)
		rootKey := append(ed25519.PrivateKey(nil), s.identity.RootKey...)
		mobileClient := s.mobileClient
		if s.hubTokenProv == nil {
			mobileClient = nil
		} else {
			s.hubTokenProv.mu.RLock()
			hasToken := strings.TrimSpace(s.hubTokenProv.token) != ""
			s.hubTokenProv.mu.RUnlock()
			if !hasToken {
				// RegisterNodeWithCert requires JWT auth; skip noisy unauthenticated call.
				mobileClient = nil
			}
		}
		ctrl := s.ctrl
		s.mu.Unlock()

		completionResult, err := pairing.CompleteExchange(ctx, &pairing.CompletionParams{
			ExchangeResult: exchange,
			RootCertPEM:    rootCertPEM,
			RootKey:        rootKey,
			UserSecret:     rootKey, // HMAC secret for routing token generation
			MobileClient:   mobileClient,
			ValidDays:      365,
		})
		if err != nil {
			return &pb.CompletePairingResponse{
				Success: false,
				Error:   fmt.Sprintf("failed to complete pairing: %v", err),
			}, nil
		}
		if nodeName == "" {
			nodeName = completionResult.NodeID
		}

		s.mu.Lock()
		defer s.mu.Unlock()

		if err := s.addNodeLocked(completionResult.NodeID, nodeName, string(completionResult.SignedCertPEM), completionResult.NodePublicKey); err != nil {
			return &pb.CompletePairingResponse{
				Success: false,
				Error:   fmt.Sprintf("paired but failed to persist node: %v", err),
			}, nil
		}
		if completionResult.NodePublicKey != nil {
			ctrl.RegisterNodeKey(completionResult.NodeID, completionResult.NodePublicKey)
			ctrl.RegisterNode(&core.NodeInfo{NodeID: completionResult.NodeID, PublicKey: completionResult.NodePublicKey})
		}
		if session.exchangeCancel != nil {
			session.exchangeCancel()
			session.exchangeCancel = nil
		}
		delete(s.pairingSessions, req.SessionId)

		return &pb.CompletePairingResponse{
			Success: true,
			Node:    s.nodes[completionResult.NodeID],
		}, nil
	}

	// Check if we have completed the PAKE exchange
	if session.pakeSession != nil && session.pakeSession.IsComplete() && len(session.sharedSecret) > 0 {
		nodeName := session.nodeName
		if nodeName == "" {
			nodeName = "Paired Node"
		}

		if session.exchangeCancel != nil {
			session.exchangeCancel()
			session.exchangeCancel = nil
		}
		delete(s.pairingSessions, req.SessionId)
		s.mu.Unlock()
		return &pb.CompletePairingResponse{
			Success: true,
			Node: &pb.NodeInfo{
				NodeId: session.sessionID[:8],
				Name:   nodeName,
			},
		}, nil
	}
	s.mu.Unlock()

	// Session not yet complete - waiting for Hub delivery
	return &pb.CompletePairingResponse{
		Success: false,
		Error:   "pairing in progress, waiting for node response",
	}, nil
}

// FinalizePairing applies user approval/rejection for a pending pairing session.
// It is the unified client path for both PAKE and offline QR pairing.
func (s *MobileLogicService) FinalizePairing(ctx context.Context, req *pb.FinalizePairingRequest) (*pb.FinalizePairingResponse, error) {
	sessionID := strings.TrimSpace(req.GetSessionId())
	if sessionID == "" {
		return &pb.FinalizePairingResponse{
			Success: false,
			Error:   "session_id is required",
		}, nil
	}

	s.mu.RLock()
	session, exists := s.pairingSessions[sessionID]
	s.mu.RUnlock()
	if !exists || session == nil {
		return &pb.FinalizePairingResponse{
			Success: false,
			Error:   "session not found",
		}, nil
	}

	if !req.GetAccepted() {
		if _, err := s.CancelPairing(ctx, &pb.CancelPairingRequest{SessionId: sessionID}); err != nil {
			return nil, err
		}
		return &pb.FinalizePairingResponse{
			Success:   true,
			Cancelled: true,
			Completed: false,
			Node:      nil,
			QrData:    nil,
			Error:     "",
		}, nil
	}

	if len(session.offlineCSRPEM) > 0 {
		qrResp, err := s.GenerateQRResponse(ctx, &pb.GenerateQRReplyRequest{
			ScanSessionId: sessionID,
			NodeName:      req.GetNodeName(),
		})
		if err != nil {
			return &pb.FinalizePairingResponse{
				Success: false,
				Error:   err.Error(),
			}, nil
		}
		return &pb.FinalizePairingResponse{
			Success:   true,
			Completed: true,
			Node:      qrResp.GetNode(),
			QrData:    append([]byte(nil), qrResp.GetQrData()...),
		}, nil
	}

	completeResp, err := s.CompletePairing(ctx, &pb.CompletePairingRequest{SessionId: sessionID})
	if err != nil {
		return nil, err
	}
	if completeResp == nil {
		return &pb.FinalizePairingResponse{
			Success: false,
			Error:   "pairing failed: empty completion response",
		}, nil
	}

	return &pb.FinalizePairingResponse{
		Success:   completeResp.GetSuccess(),
		Error:     completeResp.GetError(),
		Completed: completeResp.GetSuccess(),
		Node:      completeResp.GetNode(),
	}, nil
}

// CancelPairing cancels an ongoing pairing session.
func (s *MobileLogicService) CancelPairing(ctx context.Context, req *pb.CancelPairingRequest) (*emptypb.Empty, error) {
	s.mu.Lock()
	session := s.pairingSessions[req.SessionId]
	delete(s.pairingSessions, req.SessionId)
	s.mu.Unlock()

	if session != nil {
		if session.exchange != nil {
			pairing.RejectExchange(session.exchange, "pairing cancelled by user")
		}
		if session.exchangeCancel != nil {
			session.exchangeCancel()
		}
	}

	return &emptypb.Empty{}, nil
}

// GenerateQRCode generates QR code data for offline pairing.
func (s *MobileLogicService) GenerateQRCode(ctx context.Context, req *pb.GenerateQRCodeRequest) (*pb.GenerateQRCodeResponse, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	if err := s.requireIdentity(); err != nil {
		return nil, err
	}

	// QR code contains: Root CA certificate (public)
	qrData := s.identity.RootCertPEM

	return &pb.GenerateQRCodeResponse{
		QrData:      qrData,
		Fingerprint: s.identity.Fingerprint,
	}, nil
}

// ScanQRCode processes a scanned QR code from a node.
func (s *MobileLogicService) ScanQRCode(ctx context.Context, req *pb.ScanQRCodeRequest) (*pb.ScanQRCodeResponse, error) {
	// Parse QR input (JSON payload or raw CSR PEM)
	csrPEM, nodeIDHint, err := decodeCSRFromQRData(req.QrData)
	if err != nil {
		return &pb.ScanQRCodeResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}

	block, _ := pem.Decode(csrPEM)
	if block == nil {
		return &pb.ScanQRCodeResponse{
			Success: false,
			Error:   "invalid PEM data",
		}, nil
	}

	csr, err := x509.ParseCertificateRequest(block.Bytes)
	if err != nil {
		return &pb.ScanQRCodeResponse{
			Success: false,
			Error:   fmt.Sprintf("invalid CSR: %v", err),
		}, nil
	}
	if err := csr.CheckSignature(); err != nil {
		return &pb.ScanQRCodeResponse{
			Success: false,
			Error:   fmt.Sprintf("invalid CSR signature: %v", err),
		}, nil
	}

	// Extract node info from CSR.
	nodeID := csr.Subject.CommonName
	if nodeID == "" {
		nodeID = nodeIDHint
	}
	if nodeID == "" {
		return &pb.ScanQRCodeResponse{
			Success: false,
			Error:   "CSR missing CommonName/node_id",
		}, nil
	}

	pubKey, ok := csr.PublicKey.(ed25519.PublicKey)
	if !ok || len(pubKey) == 0 {
		return &pb.ScanQRCodeResponse{
			Success: false,
			Error:   "CSR public key must be Ed25519",
		}, nil
	}

	sessionBytes := make([]byte, 16)
	if _, err := rand.Read(sessionBytes); err != nil {
		return &pb.ScanQRCodeResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to generate scan session: %v", err),
		}, nil
	}
	sessionID := hex.EncodeToString(sessionBytes)

	s.mu.Lock()
	defer s.mu.Unlock()

	if err := s.requireIdentity(); err != nil {
		return &pb.ScanQRCodeResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}

	s.pairingSessions[sessionID] = &pairingSession{
		sessionID:     sessionID,
		nodeName:      nodeID,
		expiresAt:     time.Now().Add(5 * time.Minute).Unix(),
		offlineCSRPEM: append([]byte(nil), csrPEM...),
	}
	s.cleanExpiredPairingSessions()

	return &pb.ScanQRCodeResponse{
		Success:     true,
		SessionId:   sessionID,
		NodeId:      nodeID,
		CsrPem:      string(csrPEM),
		Fingerprint: identity.GenerateFingerprint(pubKey),
		EmojiHash:   identity.GenerateEmojiHash(pubKey),
	}, nil
}

// GenerateQRResponse generates a QR response with the signed certificate.
func (s *MobileLogicService) GenerateQRResponse(ctx context.Context, req *pb.GenerateQRReplyRequest) (*pb.GenerateQRReplyResponse, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if err := s.requireIdentity(); err != nil {
		return nil, err
	}

	scanSessionID := strings.TrimSpace(req.GetScanSessionId())
	if scanSessionID == "" {
		return nil, fmt.Errorf("scan_session_id is required")
	}

	session, exists := s.pairingSessions[scanSessionID]
	if !exists {
		return nil, fmt.Errorf("scan session not found")
	}
	if time.Now().Unix() > session.expiresAt {
		delete(s.pairingSessions, scanSessionID)
		return nil, fmt.Errorf("scan session expired")
	}
	if len(session.offlineCSRPEM) == 0 {
		return nil, fmt.Errorf("scan session does not contain CSR data")
	}

	nodeID := strings.TrimSpace(session.nodeName)
	requestNodeID := strings.TrimSpace(req.GetNodeId())
	if requestNodeID != "" && nodeID != "" && requestNodeID != nodeID {
		return nil, fmt.Errorf("node_id mismatch with scan session")
	}

	csrPEM := strings.TrimSpace(string(session.offlineCSRPEM))
	if csrPEM == "" {
		return nil, fmt.Errorf("scan session has empty CSR data")
	}

	block, _ := pem.Decode([]byte(csrPEM))
	if block == nil {
		return nil, fmt.Errorf("invalid CSR PEM")
	}
	csr, err := x509.ParseCertificateRequest(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("invalid CSR: %v", err)
	}
	if err := csr.CheckSignature(); err != nil {
		return nil, fmt.Errorf("invalid CSR signature: %v", err)
	}

	nodePub, ok := csr.PublicKey.(ed25519.PublicKey)
	if !ok || len(nodePub) == 0 {
		return nil, fmt.Errorf("CSR public key must be Ed25519")
	}

	csrNodeID := strings.TrimSpace(csr.Subject.CommonName)
	if nodeID == "" {
		nodeID = csrNodeID
	}
	if nodeID == "" {
		return nil, fmt.Errorf("node_id is required (and CSR CommonName is empty)")
	}
	if csrNodeID != "" && nodeID != csrNodeID {
		return nil, fmt.Errorf("node_id mismatch: request=%q csr=%q", nodeID, csrNodeID)
	}

	// Sign the node CSR with our identity CA.
	signedCertPEM, err := nitellacrypto.SignCSR([]byte(csrPEM), s.identity.RootCertPEM, s.identity.RootKey, 365)
	if err != nil {
		return nil, fmt.Errorf("failed to sign CSR: %v", err)
	}

	// Register node locally.
	nodeName := strings.TrimSpace(req.GetNodeName())
	if nodeName == "" {
		nodeName = nodeID
	}
	if err := s.addNodeLocked(nodeID, nodeName, string(signedCertPEM), nodePub); err != nil {
		return nil, err
	}
	delete(s.pairingSessions, scanSessionID)

	// Return QR payload that nitellad expects (`type=cert`, base64 cert + CA).
	respPayload := &pairing.QRPayload{
		Type:        "cert",
		Cert:        base64.StdEncoding.EncodeToString(signedCertPEM),
		CACert:      base64.StdEncoding.EncodeToString(s.identity.RootCertPEM),
		Fingerprint: pairing.DeriveFingerprint(signedCertPEM),
		NodeID:      nodeID,
	}
	qrData, err := json.Marshal(respPayload)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal response payload: %v", err)
	}

	return &pb.GenerateQRReplyResponse{
		QrData: qrData,
		Node:   s.nodes[nodeID],
	}, nil
}

// decodeCSRFromQRData supports both QR payload JSON and raw CSR PEM.
func decodeCSRFromQRData(qrData []byte) ([]byte, string, error) {
	raw := strings.TrimSpace(string(qrData))
	if raw == "" {
		return nil, "", fmt.Errorf("empty QR data")
	}

	// Preferred format: QR payload JSON.
	if payload, err := pairing.ParseQRPayload(raw); err == nil && payload != nil && payload.Type == "csr" {
		// Standard QR format (base64 CSR field).
		if csr, err := payload.GetCSR(); err == nil && len(csr) > 0 {
			return csr, payload.NodeID, nil
		}
		// Terminal fallback format currently printed by nitellad (raw PEM in `csr`).
		if strings.Contains(payload.CSR, "BEGIN CERTIFICATE REQUEST") {
			return []byte(payload.CSR), payload.NodeID, nil
		}
		return nil, "", fmt.Errorf("invalid CSR payload")
	}

	// Backward/manual fallback: accept raw CSR PEM pasted directly.
	if strings.Contains(raw, "BEGIN CERTIFICATE REQUEST") {
		return []byte(raw), "", nil
	}

	return nil, "", fmt.Errorf("invalid QR payload")
}

// emojiList for generating visual fingerprints
var emojiList = []string{
	"🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼",
	"🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔",
	"🌸", "🌺", "🌻", "🌷", "🌹", "🌴", "🌲", "🌳",
	"🍕", "🍔", "🍟", "🍿", "🍩", "🍪", "🎂", "🍰",
	"⭐", "🌙", "☀️", "🌈", "⚡", "❄️", "🔥", "💧",
	"🎸", "🎹", "🎺", "🥁", "🎻", "🎷", "🪕", "🎤",
	"🚀", "✈️", "🚁", "🛸", "🚂", "🚗", "🚌", "🏎️",
	"🏠", "🏰", "⛺", "🗼", "🗽", "⛩️", "🕌", "🕍",
}

// generateEmojiFingerprint generates a 4-emoji visual fingerprint from data.
func generateEmojiFingerprint(data []byte) string {
	var hash uint32
	for _, b := range data {
		hash = hash*31 + uint32(b)
	}

	var emojis string
	for i := 0; i < 4; i++ {
		idx := (hash >> (i * 8)) % uint32(len(emojiList))
		emojis += emojiList[idx]
	}
	return emojis
}

// cleanExpiredPairingSessions removes expired pairing sessions.
// Caller MUST hold s.mu.Lock().
func (s *MobileLogicService) cleanExpiredPairingSessions() {
	now := time.Now().Unix()
	for id, session := range s.pairingSessions {
		if now > session.expiresAt {
			if session.exchangeCancel != nil {
				session.exchangeCancel()
				session.exchangeCancel = nil
			}
			delete(s.pairingSessions, id)
		}
	}
}

// Helper to add node using identity package
func (s *MobileLogicService) addNodeWithCert(nodeID, name string, certPEM []byte) error {
	// Save certificate
	if err := identity.SaveNodeCert(s.dataDir, nodeID, certPEM); err != nil {
		return err
	}

	// Load public key from cert
	block, _ := pem.Decode(certPEM)
	if block == nil {
		return fmt.Errorf("invalid certificate PEM")
	}

	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return err
	}

	var fingerprint, emojiHash string
	if pubKey, ok := cert.PublicKey.(ed25519.PublicKey); ok {
		fingerprint = identity.GenerateFingerprint(pubKey)
		emojiHash = identity.GenerateEmojiHash(pubKey)
	}

	s.nodes[nodeID] = &pb.NodeInfo{
		NodeId:      nodeID,
		Name:        name,
		Fingerprint: fingerprint,
		EmojiHash:   emojiHash,
		Online:      false,
	}

	return nil
}
