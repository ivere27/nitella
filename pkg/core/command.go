package core

import (
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"fmt"
	"log"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/ivere27/nitella/pkg/hub/routing"
	"github.com/ivere27/nitella/pkg/p2p"
	"google.golang.org/protobuf/proto"
)

// DefaultCommandTimeout is the timeout for Hub RPC commands.
const DefaultCommandTimeout = 25 * time.Second

// SendCommand sends an E2E encrypted command to a node via Hub (or P2P if enabled).
// This is the unified command pipeline that replaces the 3 separate implementations
// in cmd/nitella/main.go, pkg/service/mobile_logic_service.go, and pkg/hubclient/cliclient.go.
//
// The pipeline:
//  1. Marshal EncryptedCommandPayload (type + payload)
//  2. Wrap in SecureCommandPayload (requestID + timestamp for anti-replay)
//  3. Encrypt with node's public key + sign with our private key
//  4. Send via Hub relay (or P2P)
//  5. Decrypt response + verify node signature
//  6. Return CommandResult
func (c *Controller) SendCommand(ctx context.Context, nodeID string, cmdType pbHub.CommandType, payload []byte) (*CommandResult, error) {
	c.mu.RLock()
	lc := c.localClients[nodeID]
	p2pTrans := c.p2pTransport
	mobileClient := c.mobileClient
	p2pMode := c.cfg.P2PMode
	id := c.identity
	nodePubKey := c.nodePublicKeys[nodeID]
	routingSecret := c.cfg.RoutingSecret
	debugMode := c.cfg.DebugMode
	c.mu.RUnlock()

	if id == nil || id.RootKey == nil {
		return nil, fmt.Errorf("identity not available")
	}

	// 0. Local connection takes priority
	if lc != nil {
		return sendCommandLocal(ctx, lc, cmdType, payload, id.RootKey, id.Fingerprint)
	}

	// Determine if we should try P2P
	tryP2P := p2pMode != common.P2PMode_P2P_MODE_HUB &&
		p2pTrans != nil &&
		p2pTrans.IsConnected(nodeID) &&
		p2pTrans.IsAuthenticated(nodeID)

	// 1. Try P2P if enabled and connected
	if tryP2P {
		result, err := sendCommandViaP2P(p2pTrans, nodeID, cmdType, payload)
		if err == nil {
			return result, nil
		}

		if p2pMode == common.P2PMode_P2P_MODE_DIRECT {
			return nil, fmt.Errorf("P2P command failed (direct mode, no fallback): %w", err)
		}

		if debugMode {
			log.Printf("[core] P2P command failed, falling back to Hub: %v\n", err)
		}
	} else if p2pMode == common.P2PMode_P2P_MODE_DIRECT {
		return nil, fmt.Errorf("P2P not connected to node %s (direct mode, no fallback)", nodeID)
	}

	// 2. Send via Hub
	if mobileClient == nil {
		return nil, fmt.Errorf("not connected to Hub and P2P unavailable")
	}
	if nodePubKey == nil {
		return nil, fmt.Errorf("node public key required for E2E encryption (node: %s)", nodeID)
	}

	routingToken := ""
	if len(routingSecret) > 0 {
		routingToken = routing.GenerateRoutingToken(nodeID, routingSecret)
	}

	return sendCommandViaHub(ctx, mobileClient, nodeID, cmdType, payload, nodePubKey, id.RootKey, id.Fingerprint, routingToken)
}

// SendCommandTyped is a generic helper that sends a command, checks status, and unmarshals the response.
func SendCommandTyped[T any, PT interface {
	*T
	proto.Message
}](c *Controller, ctx context.Context, nodeID string, cmdType pbHub.CommandType, req proto.Message) (*T, error) {
	var payload []byte
	if req != nil {
		var err error
		payload, err = proto.Marshal(req)
		if err != nil {
			return nil, fmt.Errorf("marshal request: %w", err)
		}
	}

	result, err := c.SendCommand(ctx, nodeID, cmdType, payload)
	if err != nil {
		return nil, err
	}
	if result.Status != "OK" {
		return nil, fmt.Errorf("%s", result.ErrorMessage)
	}

	msg := PT(new(T))
	if len(result.ResponsePayload) > 0 {
		if err := proto.Unmarshal(result.ResponsePayload, msg); err != nil {
			return nil, fmt.Errorf("unmarshal response: %w", err)
		}
	}
	return (*T)(msg), nil
}

// sendCommandViaHub sends a command through the Hub relay with full E2E encryption.
func sendCommandViaHub(
	ctx context.Context,
	mobileClient pbHub.MobileServiceClient,
	nodeID string,
	cmdType pbHub.CommandType,
	payload []byte,
	nodePubKey ed25519.PublicKey,
	identityKey ed25519.PrivateKey,
	senderFingerprint string,
	routingToken string,
) (*CommandResult, error) {
	// Apply timeout
	ctx, cancel := context.WithTimeout(ctx, DefaultCommandTimeout)
	defer cancel()

	// 1. Build EncryptedCommandPayload
	innerPayload := &pbHub.EncryptedCommandPayload{
		Type:    cmdType,
		Payload: payload,
	}
	innerBytes, err := proto.Marshal(innerPayload)
	if err != nil {
		return nil, fmt.Errorf("marshal command: %w", err)
	}

	// 2. Wrap in SecureCommandPayload (anti-replay)
	nonce := make([]byte, 16)
	if _, err := rand.Read(nonce); err != nil {
		return nil, fmt.Errorf("generate request ID: %w", err)
	}
	securePayload := &common.SecureCommandPayload{
		RequestId: fmt.Sprintf("%x", nonce),
		Timestamp: time.Now().Unix(),
		Data:      innerBytes,
	}
	secureBytes, err := proto.Marshal(securePayload)
	if err != nil {
		return nil, fmt.Errorf("marshal secure payload: %w", err)
	}

	// 3. Encrypt + sign
	encrypted, err := nitellacrypto.EncryptWithSignature(secureBytes, nodePubKey, identityKey, senderFingerprint)
	if err != nil {
		return nil, fmt.Errorf("encrypt: %w", err)
	}
	encryptedPayload := &common.EncryptedPayload{
		EphemeralPubkey:   encrypted.EphemeralPubKey,
		Nonce:             encrypted.Nonce,
		Ciphertext:        encrypted.Ciphertext,
		SenderFingerprint: encrypted.SenderFingerprint,
		Signature:         encrypted.Signature,
	}

	// 4. Send via Hub
	resp, err := mobileClient.SendCommand(ctx, &pbHub.CommandRequest{
		NodeId:       nodeID,
		Encrypted:    encryptedPayload,
		RoutingToken: routingToken,
	})
	if err != nil {
		return nil, fmt.Errorf("send command: %w", err)
	}

	// 5. Decrypt response
	if resp.EncryptedData == nil {
		return nil, fmt.Errorf("no encrypted data in response")
	}

	respPayload := &nitellacrypto.EncryptedPayload{
		EphemeralPubKey:   resp.EncryptedData.EphemeralPubkey,
		Nonce:             resp.EncryptedData.Nonce,
		Ciphertext:        resp.EncryptedData.Ciphertext,
		SenderFingerprint: resp.EncryptedData.SenderFingerprint,
		Signature:         resp.EncryptedData.Signature,
	}

	// 6. Verify node signature (mandatory — reject unsigned responses)
	if len(respPayload.Signature) == 0 {
		return nil, fmt.Errorf("response from node %s is not signed (zero-trust violation)", nodeID)
	}
	if err := nitellacrypto.VerifySignature(respPayload, nodePubKey); err != nil {
		return nil, fmt.Errorf("response signature verification failed: %w", err)
	}

	// 7. Decrypt
	decrypted, err := nitellacrypto.Decrypt(respPayload, identityKey)
	if err != nil {
		return nil, fmt.Errorf("decrypt response: %w", err)
	}

	// 8. Unmarshal CommandResult
	var result pbHub.CommandResult
	if err := proto.Unmarshal(decrypted, &result); err != nil {
		return nil, fmt.Errorf("unmarshal result: %w", err)
	}

	return &result, nil
}

// sendCommandViaP2P sends a command over P2P with request-response correlation.
func sendCommandViaP2P(trans *p2p.Transport, nodeID string, cmdType pbHub.CommandType, payload []byte) (*CommandResult, error) {
	// Build inner command payload
	innerPayload := &pbHub.EncryptedCommandPayload{
		Type:    cmdType,
		Payload: payload,
	}
	innerBytes, err := proto.Marshal(innerPayload)
	if err != nil {
		return nil, fmt.Errorf("marshal command: %w", err)
	}

	// Generate unique request ID
	nonce := make([]byte, 16)
	if _, err := rand.Read(nonce); err != nil {
		return nil, fmt.Errorf("generate request ID: %w", err)
	}
	requestID := fmt.Sprintf("%x", nonce)

	// Wrap in SecureCommandPayload for replay protection
	securePayload := &common.SecureCommandPayload{
		RequestId: requestID,
		Timestamp: time.Now().Unix(),
		Data:      innerBytes,
	}
	secureBytes, err := proto.Marshal(securePayload)
	if err != nil {
		return nil, fmt.Errorf("marshal secure payload: %w", err)
	}

	// Build P2P command message
	cmdPayload := &p2p.P2PCommandPayload{
		CommandType: int32(cmdType),
		Data:        secureBytes,
	}
	msg, err := p2p.NewP2PMessageWithRequestID(p2p.MessageTypeCommand, requestID, cmdPayload)
	if err != nil {
		return nil, fmt.Errorf("create P2P message: %w", err)
	}

	// Send and wait for response
	respMsg, err := trans.SendCommandAndWait(nodeID, msg, DefaultCommandTimeout)
	if err != nil {
		return nil, err
	}

	// Parse response
	cmdResp, err := respMsg.ParseCommandResponse()
	if err != nil {
		return nil, fmt.Errorf("parse P2P response: %w", err)
	}

	return &pbHub.CommandResult{
		Status:          cmdResp.Status,
		ErrorMessage:    cmdResp.Error,
		ResponsePayload: cmdResp.Data,
	}, nil
}
