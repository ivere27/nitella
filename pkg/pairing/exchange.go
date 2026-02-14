package pairing

import (
	"context"
	"crypto/ed25519"
	"crypto/sha256"
	"crypto/x509"
	"encoding/pem"
	"fmt"
	"io"

	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/ivere27/nitella/pkg/hub/routing"
	"github.com/ivere27/nitella/pkg/identity"
)

// ExchangeResult contains the results of a PAKE exchange, ready for completion.
// The caller should display the Emoji to the user for visual verification,
// then call CompleteExchange after user confirmation.
type ExchangeResult struct {
	PakeSession *PakeSession
	Stream      pbHub.PairingService_PakeExchangeClient
	Code        string
	CSRPEM      []byte
	NodeID      string
	Emoji       string // PAKE confirmation emoji

	// CSR/node identity details for user verification before signing.
	Fingerprint    string // Node public key fingerprint (SHA-256 hex)
	EmojiHash      string // Node public key emoji hash
	CSRFingerprint string // CSR fingerprint shown on node (emoji)
	CSRHash        string // CSR SHA-256 hash shown on node (hex)
}

// RunExchange performs the full PAKE key exchange over the Hub's PakeExchange stream.
// It creates a PakeSession, opens the stream, exchanges init/reply messages,
// derives the shared secret, receives and decrypts the node's CSR.
//
// The caller is responsible for:
//  1. Displaying result.Emoji to the user for visual verification
//  2. Calling CompleteExchange after user confirmation, or RejectExchange to abort
func RunExchange(ctx context.Context, pairingClient pbHub.PairingServiceClient, code string) (*ExchangeResult, error) {
	// Create PAKE session (CLI/authority role - we sign the CSR)
	pakeSession, err := NewPakeSession(RoleCLI, CodeToBytes(code))
	if err != nil {
		return nil, fmt.Errorf("failed to create PAKE session: %v", err)
	}

	// Open PakeExchange bidirectional stream
	stream, err := pairingClient.PakeExchange(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to start PAKE exchange: %v", err)
	}

	// Step 1: Send our PAKE init message
	initMsg, err := pakeSession.GetInitMessage()
	if err != nil {
		return nil, fmt.Errorf("failed to generate PAKE init: %v", err)
	}

	err = stream.Send(&pbHub.PakeMessage{
		SessionCode: code,
		Role:        RoleCLI,
		Type:        pbHub.PakeMessage_MESSAGE_TYPE_SPAKE2_INIT,
		Spake2Data:  initMsg,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to send PAKE init: %v", err)
	}

	// Step 2: Receive node's init message
	nodeMsg, err := stream.Recv()
	if err != nil {
		if err == io.EOF {
			return nil, fmt.Errorf("node disconnected")
		}
		return nil, fmt.Errorf("failed to receive from node: %v", err)
	}

	if nodeMsg.Type == pbHub.PakeMessage_MESSAGE_TYPE_ERROR {
		return nil, fmt.Errorf("node error: %s", nodeMsg.ErrorMessage)
	}

	// Step 3: Process node's init message (derives shared secret)
	_, err = pakeSession.ProcessInitMessage(nodeMsg.Spake2Data)
	if err != nil {
		return nil, fmt.Errorf("PAKE verification failed (wrong code?): %v", err)
	}

	// Step 4: Send our reply
	replyMsg, _ := pakeSession.GetInitMessage()
	err = stream.Send(&pbHub.PakeMessage{
		SessionCode: code,
		Role:        RoleCLI,
		Type:        pbHub.PakeMessage_MESSAGE_TYPE_SPAKE2_REPLY,
		Spake2Data:  replyMsg,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to send PAKE reply: %v", err)
	}

	// Step 5: Derive confirmation emoji
	emoji := pakeSession.DeriveConfirmationEmoji()

	// Step 6: Receive encrypted CSR from node
	csrMsg, err := stream.Recv()
	if err != nil {
		return nil, fmt.Errorf("failed to receive CSR: %v", err)
	}

	if csrMsg.Type != pbHub.PakeMessage_MESSAGE_TYPE_ENCRYPTED {
		return nil, fmt.Errorf("unexpected message type: %v", csrMsg.Type)
	}

	// Step 7: Decrypt CSR
	csrPEM, err := pakeSession.Decrypt(csrMsg.EncryptedPayload, csrMsg.Nonce)
	if err != nil {
		return nil, fmt.Errorf("failed to decrypt CSR: %v", err)
	}

	// Step 8: Parse CSR to extract node ID
	block, _ := pem.Decode(csrPEM)
	if block == nil {
		return nil, fmt.Errorf("invalid CSR format")
	}

	csr, err := x509.ParseCertificateRequest(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("failed to parse CSR: %v", err)
	}

	nodeID := csr.Subject.CommonName
	if nodeID == "" {
		return nil, fmt.Errorf("CSR has no CommonName")
	}
	pubKey, ok := csr.PublicKey.(ed25519.PublicKey)
	if !ok || len(pubKey) != ed25519.PublicKeySize {
		return nil, fmt.Errorf("CSR has unsupported public key type")
	}
	csrHash := sha256.Sum256(csrPEM)

	return &ExchangeResult{
		PakeSession:    pakeSession,
		Stream:         stream,
		Code:           code,
		CSRPEM:         csrPEM,
		NodeID:         nodeID,
		Emoji:          emoji,
		Fingerprint:    identity.GenerateFingerprint(pubKey),
		EmojiHash:      identity.GenerateEmojiHash(pubKey),
		CSRFingerprint: DeriveFingerprint(csrPEM),
		CSRHash:        fmt.Sprintf("%x", csrHash),
	}, nil
}

// CompletionParams contains everything needed to complete pairing after user confirmation.
type CompletionParams struct {
	ExchangeResult *ExchangeResult
	RootCertPEM    []byte
	RootKey        ed25519.PrivateKey
	UserSecret     []byte                    // HMAC secret for routing token generation
	MobileClient   pbHub.MobileServiceClient // For RegisterNodeWithCert (nil to skip)
	DataDir        string                    // For saving node cert locally (empty to skip)
	ValidDays      int                       // Certificate validity (0 defaults to 365)
}

// CompletionResult contains the results of completing the pairing.
type CompletionResult struct {
	SignedCertPEM []byte
	RoutingToken  string
	NodeID        string
	Fingerprint   string
	EmojiHash     string
	NodePublicKey ed25519.PublicKey
}

// CompleteExchange signs the CSR, delivers the signed cert/CA/routing token
// via the PAKE-encrypted stream, and optionally registers the node with Hub.
func CompleteExchange(ctx context.Context, params *CompletionParams) (*CompletionResult, error) {
	er := params.ExchangeResult
	validDays := params.ValidDays
	if validDays <= 0 {
		validDays = 365
	}

	// Step 1: Sign the CSR with our Root CA
	signedCertPEM, err := nitellacrypto.SignCSR(er.CSRPEM, params.RootCertPEM, params.RootKey, validDays)
	if err != nil {
		return nil, fmt.Errorf("failed to sign CSR: %v", err)
	}

	// Step 2: Save node cert locally
	if params.DataDir != "" {
		_ = identity.SaveNodeCert(params.DataDir, er.NodeID, signedCertPEM)
	}

	// Step 3: Send encrypted signed certificate via PAKE stream
	encryptedCert, nonce, err := er.PakeSession.Encrypt(signedCertPEM)
	if err != nil {
		return nil, fmt.Errorf("failed to encrypt certificate: %v", err)
	}

	err = er.Stream.Send(&pbHub.PakeMessage{
		SessionCode:      er.Code,
		Role:             RoleCLI,
		Type:             pbHub.PakeMessage_MESSAGE_TYPE_ENCRYPTED,
		EncryptedPayload: encryptedCert,
		Nonce:            nonce,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to send certificate: %v", err)
	}

	// Step 4: Send encrypted CA certificate
	encryptedCA, caNonce, err := er.PakeSession.Encrypt(params.RootCertPEM)
	if err != nil {
		return nil, fmt.Errorf("failed to encrypt CA cert: %v", err)
	}

	err = er.Stream.Send(&pbHub.PakeMessage{
		SessionCode:      er.Code,
		Role:             RoleCLI,
		Type:             pbHub.PakeMessage_MESSAGE_TYPE_ENCRYPTED,
		EncryptedPayload: encryptedCA,
		Nonce:            caNonce,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to send CA cert: %v", err)
	}

	// Step 5: Generate and send routing token
	var routingToken string
	if params.UserSecret != nil {
		routingToken = routing.GenerateRoutingToken(er.NodeID, params.UserSecret)
		encryptedRT, rtNonce, err := er.PakeSession.Encrypt([]byte(routingToken))
		if err == nil {
			_ = er.Stream.Send(&pbHub.PakeMessage{
				SessionCode:      er.Code,
				Role:             RoleCLI,
				Type:             pbHub.PakeMessage_MESSAGE_TYPE_ENCRYPTED,
				EncryptedPayload: encryptedRT,
				Nonce:            rtNonce,
			})
		}
	}

	// Step 6: Register node with Hub (if client provided)
	if params.MobileClient != nil {
		_, err = params.MobileClient.RegisterNodeWithCert(ctx, &pbHub.RegisterNodeWithCertRequest{
			NodeId:       er.NodeID,
			CertPem:      string(signedCertPEM),
			RoutingToken: routingToken,
			CaPem:        string(params.RootCertPEM),
		})
		if err != nil {
			// Non-fatal: Hub registration can be retried
		}
	}

	// Step 7: Extract public key info from signed cert
	result := &CompletionResult{
		SignedCertPEM: signedCertPEM,
		RoutingToken:  routingToken,
		NodeID:        er.NodeID,
	}

	if block, _ := pem.Decode(signedCertPEM); block != nil {
		if cert, err := x509.ParseCertificate(block.Bytes); err == nil {
			if pubKey, ok := cert.PublicKey.(ed25519.PublicKey); ok {
				result.Fingerprint = identity.GenerateFingerprint(pubKey)
				result.EmojiHash = identity.GenerateEmojiHash(pubKey)
				result.NodePublicKey = pubKey
			}
		}
	}

	return result, nil
}

// RejectExchange sends an error message to the node via the PAKE stream.
func RejectExchange(result *ExchangeResult, reason string) {
	if result != nil && result.Stream != nil {
		_ = result.Stream.Send(&pbHub.PakeMessage{
			SessionCode:  result.Code,
			Role:         RoleCLI,
			Type:         pbHub.PakeMessage_MESSAGE_TYPE_ERROR,
			ErrorMessage: reason,
		})
	}
}
