package core

import (
	"context"
	"crypto/ed25519"
	"fmt"
	"log"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/ivere27/nitella/pkg/hub/routing"
	"google.golang.org/protobuf/proto"
)

// AlertCallback is called when an alert is received from the Hub.
// The decrypted alert payload and the node's public key are provided.
type AlertCallback func(alert *common.Alert, decryptedPayload []byte, nodePubKey ed25519.PublicKey)

// StreamAlerts opens a single multiplexed alert stream to the Hub using
// routing tokens derived from the routing secret, and calls the callback
// for each received alert. Reconnects automatically on failure.
// Runs until ctx is cancelled.
func (c *Controller) StreamAlerts(ctx context.Context, callback AlertCallback) {
	c.mu.RLock()
	mc := c.mobileClient
	id := c.identity
	routingSecret := c.cfg.RoutingSecret
	nodeIDs := make([]string, 0, len(c.nodes))
	for nid := range c.nodes {
		nodeIDs = append(nodeIDs, nid)
	}
	debugMode := c.cfg.DebugMode
	c.mu.RUnlock()

	if mc == nil || id == nil || len(nodeIDs) == 0 {
		return
	}

	// Generate routing tokens for all known nodes
	var routingTokens []string
	if len(routingSecret) > 0 {
		for _, nodeID := range nodeIDs {
			routingTokens = append(routingTokens, routing.GenerateRoutingToken(nodeID, routingSecret))
		}
	}

	if len(routingTokens) == 0 {
		return
	}

	backoff := time.Second
	const maxBackoff = 2 * time.Minute

	for {
		stream, err := mc.StreamAlerts(ctx, &pbHub.StreamAlertsRequest{
			RoutingTokens: routingTokens,
		})
		if err != nil {
			if ctx.Err() != nil {
				return
			}
			if debugMode {
				log.Printf("[core/alert] Failed to open stream: %v (retry in %v)\n", err, backoff)
			}
			select {
			case <-ctx.Done():
				return
			case <-time.After(backoff):
			}
			if backoff < maxBackoff {
				backoff *= 2
			}
			continue
		}

		backoff = time.Second

		for {
			alert, err := stream.Recv()
			if err != nil {
				if ctx.Err() != nil {
					return
				}
				if debugMode {
					log.Printf("[core/alert] Stream ended: %v (reconnecting in %v)\n", err, backoff)
				}
				break
			}

			c.processAlert(alert, id.RootKey, callback)
		}

		select {
		case <-ctx.Done():
			return
		case <-time.After(backoff):
		}
		if backoff < maxBackoff {
			backoff *= 2
		}
	}
}

// processAlert decrypts an alert and invokes the callback.
func (c *Controller) processAlert(alert *common.Alert, privKey ed25519.PrivateKey, callback AlertCallback) {
	if alert.Encrypted == nil {
		callback(alert, nil, nil)
		return
	}

	nodeID := alert.NodeId
	nodePubKey := c.GetNodePublicKey(nodeID)

	respPayload := &nitellacrypto.EncryptedPayload{
		EphemeralPubKey:   alert.Encrypted.EphemeralPubkey,
		Nonce:             alert.Encrypted.Nonce,
		Ciphertext:        alert.Encrypted.Ciphertext,
		SenderFingerprint: alert.Encrypted.SenderFingerprint,
		Signature:         alert.Encrypted.Signature,
	}

	// Verify signature if node public key is available
	if nodePubKey != nil && len(respPayload.Signature) > 0 {
		if err := nitellacrypto.VerifySignature(respPayload, nodePubKey); err != nil {
			if c.cfg.DebugMode {
				log.Printf("[core/alert] Signature verification failed for alert from node %s: %v\n", nodeID, err)
			}
			return
		}
	}

	decrypted, err := nitellacrypto.Decrypt(respPayload, privKey)
	if err != nil {
		if c.cfg.DebugMode {
			log.Printf("[core/alert] Failed to decrypt alert from node %s: %v\n", nodeID, err)
		}
		return
	}

	callback(alert, decrypted, nodePubKey)
}

// StreamMetrics opens a metrics stream for a node and calls the callback for each sample.
func (c *Controller) StreamMetrics(ctx context.Context, nodeID string, callback func(nodeID string, metrics *pbHub.Metrics)) error {
	c.mu.RLock()
	mc := c.mobileClient
	id := c.identity
	routingSecret := c.cfg.RoutingSecret
	c.mu.RUnlock()

	if mc == nil {
		return fmt.Errorf("not connected to Hub")
	}
	if id == nil {
		return fmt.Errorf("identity not available")
	}

	routingToken := ""
	if len(routingSecret) > 0 {
		routingToken = routing.GenerateRoutingToken(nodeID, routingSecret)
	}

	stream, err := mc.StreamMetrics(ctx, &pbHub.StreamMetricsRequest{
		NodeId:       nodeID,
		RoutingToken: routingToken,
	})
	if err != nil {
		return fmt.Errorf("start metrics stream: %w", err)
	}

	go func() {
		for {
			sample, err := stream.Recv()
			if err != nil {
				return
			}

			if sample.Encrypted != nil && id.RootKey != nil {
				decrypted, err := nitellacrypto.Decrypt(&nitellacrypto.EncryptedPayload{
					EphemeralPubKey:   sample.Encrypted.EphemeralPubkey,
					Nonce:             sample.Encrypted.Nonce,
					Ciphertext:        sample.Encrypted.Ciphertext,
					SenderFingerprint: sample.Encrypted.SenderFingerprint,
					Signature:         sample.Encrypted.Signature,
				}, id.RootKey)
				if err == nil {
					var metrics pbHub.Metrics
					if proto.Unmarshal(decrypted, &metrics) == nil {
						callback(sample.NodeId, &metrics)
					}
				}
			}
		}
	}()

	return nil
}
