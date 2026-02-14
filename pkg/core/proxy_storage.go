package core

import (
	"context"
	"crypto/ed25519"
	"fmt"

	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/ivere27/nitella/pkg/hub/routing"
	"google.golang.org/protobuf/proto"
)

// PushRevisionResult contains the response from pushing a revision.
type PushRevisionResult struct {
	RevisionNum    int64
	RevisionsKept  int32
	RevisionsLimit int32
	StorageUsedKb  int32
	StorageLimitKb int32
}

// ProxyRevision contains a decrypted proxy revision.
type ProxyRevision struct {
	RevisionNum int64
	Payload     *pbHub.ProxyRevisionPayload
	SizeBytes   int32
}

// FlushResult contains the response from flushing revisions.
type FlushResult struct {
	DeletedCount   int32
	RemainingCount int32
}

// routingToken generates a routing token from the identity fingerprint and routing secret.
func (c *Controller) routingToken() string {
	c.mu.RLock()
	id := c.identity
	routingSecret := c.cfg.RoutingSecret
	c.mu.RUnlock()

	if id == nil || len(routingSecret) == 0 {
		return ""
	}
	return routing.GenerateRoutingToken(id.Fingerprint, routingSecret)
}

// ListProxyConfigs lists all proxy configurations stored on the Hub.
func (c *Controller) ListProxyConfigs(ctx context.Context) ([]*pbHub.ProxyConfigInfo, error) {
	c.mu.RLock()
	mc := c.mobileClient
	c.mu.RUnlock()

	if mc == nil {
		return nil, fmt.Errorf("not connected to Hub")
	}

	resp, err := mc.ListProxyConfigs(ctx, &pbHub.ListProxyConfigsRequest{
		RoutingToken: c.routingToken(),
	})
	if err != nil {
		return nil, err
	}
	return resp.Proxies, nil
}

// CreateProxyConfig creates a new proxy config entry on the Hub.
func (c *Controller) CreateProxyConfig(ctx context.Context, proxyID string) error {
	c.mu.RLock()
	mc := c.mobileClient
	c.mu.RUnlock()

	if mc == nil {
		return fmt.Errorf("not connected to Hub")
	}

	resp, err := mc.CreateProxyConfig(ctx, &pbHub.CreateProxyConfigRequest{
		ProxyId:      proxyID,
		RoutingToken: c.routingToken(),
	})
	if err != nil {
		return err
	}
	if !resp.Success {
		return fmt.Errorf("%s", resp.Error)
	}
	return nil
}

// DeleteProxyConfig deletes a proxy config from the Hub.
func (c *Controller) DeleteProxyConfig(ctx context.Context, proxyID string) error {
	c.mu.RLock()
	mc := c.mobileClient
	c.mu.RUnlock()

	if mc == nil {
		return fmt.Errorf("not connected to Hub")
	}

	_, err := mc.DeleteProxyConfig(ctx, &pbHub.DeleteProxyConfigRequest{
		ProxyId:      proxyID,
		RoutingToken: c.routingToken(),
	})
	return err
}

// PushRevision encrypts and pushes a proxy revision to the Hub.
func (c *Controller) PushRevision(ctx context.Context, proxyID string, payload *pbHub.ProxyRevisionPayload) (*PushRevisionResult, error) {
	c.mu.RLock()
	mc := c.mobileClient
	id := c.identity
	c.mu.RUnlock()

	if mc == nil {
		return nil, fmt.Errorf("not connected to Hub")
	}
	if id == nil || id.RootKey == nil {
		return nil, fmt.Errorf("identity not available")
	}

	// Marshal payload
	payloadBytes, err := proto.Marshal(payload)
	if err != nil {
		return nil, fmt.Errorf("marshal payload: %w", err)
	}

	// Encrypt with user's own public key (self-encryption for storage)
	pubKey := id.RootKey.Public().(ed25519.PublicKey)
	encrypted, err := nitellacrypto.Encrypt(payloadBytes, pubKey)
	if err != nil {
		return nil, fmt.Errorf("encrypt: %w", err)
	}
	encryptedBlob := encrypted.Marshal()

	// Push to Hub
	resp, err := mc.PushRevision(ctx, &pbHub.PushRevisionRequest{
		ProxyId:       proxyID,
		RoutingToken:  c.routingToken(),
		EncryptedBlob: encryptedBlob,
		SizeBytes:     int32(len(encryptedBlob)),
	})
	if err != nil {
		return nil, err
	}
	if !resp.Success {
		return nil, fmt.Errorf("%s", resp.Error)
	}

	return &PushRevisionResult{
		RevisionNum:    resp.RevisionNum,
		RevisionsKept:  resp.RevisionsKept,
		RevisionsLimit: resp.RevisionsLimit,
		StorageUsedKb:  resp.StorageUsedKb,
		StorageLimitKb: resp.StorageLimitKb,
	}, nil
}

// GetRevision fetches and decrypts a proxy revision from the Hub.
// Pass revisionNum=0 to get the latest revision.
func (c *Controller) GetRevision(ctx context.Context, proxyID string, revisionNum int64) (*ProxyRevision, error) {
	c.mu.RLock()
	mc := c.mobileClient
	id := c.identity
	c.mu.RUnlock()

	if mc == nil {
		return nil, fmt.Errorf("not connected to Hub")
	}
	if id == nil || id.RootKey == nil {
		return nil, fmt.Errorf("identity not available")
	}

	resp, err := mc.GetRevision(ctx, &pbHub.GetRevisionRequest{
		ProxyId:      proxyID,
		RoutingToken: c.routingToken(),
		RevisionNum:  revisionNum,
	})
	if err != nil {
		return nil, err
	}

	// Decrypt
	envelope, err := nitellacrypto.UnmarshalEncryptedPayload(resp.EncryptedBlob)
	if err != nil {
		return nil, fmt.Errorf("parse encrypted blob: %w", err)
	}
	decrypted, err := nitellacrypto.Decrypt(envelope, id.RootKey)
	if err != nil {
		return nil, fmt.Errorf("decrypt: %w", err)
	}

	var payload pbHub.ProxyRevisionPayload
	if err := proto.Unmarshal(decrypted, &payload); err != nil {
		return nil, fmt.Errorf("unmarshal payload: %w", err)
	}

	return &ProxyRevision{
		RevisionNum: resp.RevisionNum,
		Payload:     &payload,
		SizeBytes:   resp.SizeBytes,
	}, nil
}

// ListRevisions lists revision metadata for a proxy config on the Hub.
func (c *Controller) ListRevisions(ctx context.Context, proxyID string) ([]*pbHub.RevisionMeta, error) {
	c.mu.RLock()
	mc := c.mobileClient
	c.mu.RUnlock()

	if mc == nil {
		return nil, fmt.Errorf("not connected to Hub")
	}

	resp, err := mc.ListRevisions(ctx, &pbHub.ListRevisionsRequest{
		ProxyId:      proxyID,
		RoutingToken: c.routingToken(),
	})
	if err != nil {
		return nil, err
	}
	return resp.Revisions, nil
}

// FlushRevisions deletes old revisions from the Hub, keeping the most recent keepCount.
func (c *Controller) FlushRevisions(ctx context.Context, proxyID string, keepCount int32) (*FlushResult, error) {
	c.mu.RLock()
	mc := c.mobileClient
	c.mu.RUnlock()

	if mc == nil {
		return nil, fmt.Errorf("not connected to Hub")
	}

	resp, err := mc.FlushRevisions(ctx, &pbHub.FlushRevisionsRequest{
		ProxyId:      proxyID,
		RoutingToken: c.routingToken(),
		KeepCount:    keepCount,
	})
	if err != nil {
		return nil, err
	}
	if !resp.Success {
		return nil, fmt.Errorf("%s", resp.Error)
	}

	return &FlushResult{
		DeletedCount:   resp.DeletedCount,
		RemainingCount: resp.RemainingCount,
	}, nil
}
