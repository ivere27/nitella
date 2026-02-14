package core

import (
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"fmt"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"google.golang.org/grpc/metadata"
	"google.golang.org/protobuf/proto"
)

// LocalConnection holds state for a direct connection to a single nitellad.
type LocalConnection struct {
	Client     pbProxy.ProxyControlServiceClient
	Token      string // bearer token for gRPC metadata
	NodePubKey ed25519.PublicKey
}

// SetLocalConnection registers a direct node connection.
func (c *Controller) SetLocalConnection(nodeID string, lc *LocalConnection) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.localClients[nodeID] = lc
	if lc.NodePubKey != nil {
		c.nodePublicKeys[nodeID] = lc.NodePubKey
	}
}

// RemoveLocalConnection removes a direct node connection.
func (c *Controller) RemoveLocalConnection(nodeID string) {
	c.mu.Lock()
	defer c.mu.Unlock()
	delete(c.localClients, nodeID)
}

// sendCommandLocal sends an E2E encrypted command directly to a nitellad
// via ProxyControlServiceClient.SendCommand. Same pipeline as sendCommandViaHub
// but uses the local RPC with ViewerPubkey instead of routing token.
func sendCommandLocal(
	ctx context.Context,
	lc *LocalConnection,
	cmdType pbHub.CommandType,
	payload []byte,
	identityKey ed25519.PrivateKey,
	senderFingerprint string,
) (*CommandResult, error) {
	if lc.NodePubKey == nil {
		return nil, fmt.Errorf("node public key required for E2E encryption")
	}

	// Apply timeout
	ctx, cancel := context.WithTimeout(ctx, DefaultCommandTimeout)
	defer cancel()

	// Add auth token to context
	if lc.Token != "" {
		ctx = metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+lc.Token)
	}

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
	encrypted, err := nitellacrypto.EncryptWithSignature(secureBytes, lc.NodePubKey, identityKey, senderFingerprint)
	if err != nil {
		return nil, fmt.Errorf("encrypt: %w", err)
	}

	// 4. Send via local ProxyControlService
	viewerPubKey := identityKey.Public().(ed25519.PublicKey)
	resp, err := lc.Client.SendCommand(ctx, &pbProxy.SendCommandRequest{
		Encrypted: &common.EncryptedPayload{
			EphemeralPubkey:   encrypted.EphemeralPubKey,
			Nonce:             encrypted.Nonce,
			Ciphertext:        encrypted.Ciphertext,
			SenderFingerprint: encrypted.SenderFingerprint,
			Signature:         encrypted.Signature,
		},
		ViewerPubkey: viewerPubKey,
	})
	if err != nil {
		return nil, fmt.Errorf("send command: %w", err)
	}

	// Check for pre-crypto errors (e.g. auth failure before decryption)
	if resp.Status == "ERROR" && resp.Encrypted == nil {
		return nil, fmt.Errorf("%s", resp.ErrorMessage)
	}

	// 5. Decrypt response
	if resp.Encrypted == nil {
		return nil, fmt.Errorf("no encrypted response")
	}

	respPayload := &nitellacrypto.EncryptedPayload{
		EphemeralPubKey:   resp.Encrypted.EphemeralPubkey,
		Nonce:             resp.Encrypted.Nonce,
		Ciphertext:        resp.Encrypted.Ciphertext,
		SenderFingerprint: resp.Encrypted.SenderFingerprint,
		Signature:         resp.Encrypted.Signature,
	}
	decrypted, err := nitellacrypto.Decrypt(respPayload, identityKey)
	if err != nil {
		return nil, fmt.Errorf("decrypt response: %w", err)
	}

	// 6. Unmarshal CommandResult
	var result pbHub.CommandResult
	if err := proto.Unmarshal(decrypted, &result); err != nil {
		return nil, fmt.Errorf("unmarshal result: %w", err)
	}

	return &result, nil
}

// SendCommandLocal is the exported version for one-off calls (e.g. mobile's test connection)
// where the caller has a temporary LocalConnection not registered with the Controller.
func SendCommandLocal(
	ctx context.Context,
	lc *LocalConnection,
	cmdType pbHub.CommandType,
	payload []byte,
	identityKey ed25519.PrivateKey,
	senderFingerprint string,
) (*CommandResult, error) {
	return sendCommandLocal(ctx, lc, cmdType, payload, identityKey, senderFingerprint)
}

// StreamLocalConnections streams connection events from a direct node.
// The callback is invoked for each decrypted ConnectionEvent.
func (c *Controller) StreamLocalConnections(ctx context.Context, nodeID string, callback func(*pbProxy.ConnectionEvent)) error {
	c.mu.RLock()
	lc := c.localClients[nodeID]
	id := c.identity
	c.mu.RUnlock()

	if lc == nil {
		return fmt.Errorf("no local connection for node %s", nodeID)
	}
	if id == nil || id.RootKey == nil {
		return fmt.Errorf("identity not available")
	}

	// Add auth token
	streamCtx := ctx
	if lc.Token != "" {
		streamCtx = metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+lc.Token)
	}

	viewerPubKey := id.RootKey.Public().(ed25519.PublicKey)
	stream, err := lc.Client.StreamConnections(streamCtx, &pbProxy.StreamConnectionsRequest{
		ViewerPubkey: viewerPubKey,
	})
	if err != nil {
		return fmt.Errorf("start stream: %w", err)
	}

	for {
		encPayload, err := stream.Recv()
		if err != nil {
			if ctx.Err() != nil {
				return nil // context cancelled
			}
			return fmt.Errorf("stream recv: %w", err)
		}

		event, err := decryptStreamPayload[pbProxy.ConnectionEvent](encPayload, id.RootKey)
		if err != nil {
			continue // skip corrupt payloads
		}
		callback(event)
	}
}

// StreamLocalMetrics streams metrics samples from a direct node.
// The callback is invoked for each decrypted MetricsSample.
func (c *Controller) StreamLocalMetrics(ctx context.Context, nodeID string, interval int32, callback func(*pbProxy.MetricsSample)) error {
	c.mu.RLock()
	lc := c.localClients[nodeID]
	id := c.identity
	c.mu.RUnlock()

	if lc == nil {
		return fmt.Errorf("no local connection for node %s", nodeID)
	}
	if id == nil || id.RootKey == nil {
		return fmt.Errorf("identity not available")
	}

	// Add auth token
	streamCtx := ctx
	if lc.Token != "" {
		streamCtx = metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+lc.Token)
	}

	viewerPubKey := id.RootKey.Public().(ed25519.PublicKey)
	stream, err := lc.Client.StreamMetrics(streamCtx, &pbProxy.StreamMetricsRequest{
		IntervalSeconds: interval,
		ViewerPubkey:    viewerPubKey,
	})
	if err != nil {
		return fmt.Errorf("start stream: %w", err)
	}

	for {
		encPayload, err := stream.Recv()
		if err != nil {
			if ctx.Err() != nil {
				return nil // context cancelled
			}
			return fmt.Errorf("stream recv: %w", err)
		}

		sample, err := decryptStreamPayload[pbProxy.MetricsSample](encPayload, id.RootKey)
		if err != nil {
			continue // skip corrupt payloads
		}
		callback(sample)
	}
}

// decryptStreamPayload decrypts an EncryptedStreamPayload into a typed proto message.
func decryptStreamPayload[T any, PT interface {
	*T
	proto.Message
}](encPayload *pbProxy.EncryptedStreamPayload, privKey ed25519.PrivateKey) (*T, error) {
	if encPayload.GetEncrypted() == nil {
		return nil, fmt.Errorf("encrypted payload is nil")
	}

	enc := encPayload.GetEncrypted()
	cryptoPayload := &nitellacrypto.EncryptedPayload{
		EphemeralPubKey:   enc.EphemeralPubkey,
		Nonce:             enc.Nonce,
		Ciphertext:        enc.Ciphertext,
		SenderFingerprint: enc.SenderFingerprint,
		Signature:         enc.Signature,
	}

	plaintext, err := nitellacrypto.Decrypt(cryptoPayload, privKey)
	if err != nil {
		return nil, fmt.Errorf("decryption failed: %w", err)
	}

	msg := PT(new(T))
	if err := proto.Unmarshal(plaintext, msg); err != nil {
		return nil, fmt.Errorf("unmarshal failed: %w", err)
	}

	return (*T)(msg), nil
}
