package core

import (
	"context"
	"fmt"

	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	"github.com/ivere27/nitella/pkg/hub/routing"
)

// ListNodes lists all nodes visible via Hub using routing tokens.
func (c *Controller) ListNodes(ctx context.Context) ([]*pbHub.Node, error) {
	c.mu.RLock()
	client := c.mobileClient
	routingSecret := c.cfg.RoutingSecret
	c.mu.RUnlock()

	if client == nil {
		return nil, fmt.Errorf("not connected to Hub")
	}

	// Collect routing tokens for all known nodes
	var tokens []string
	c.mu.RLock()
	for nodeID := range c.nodes {
		if len(routingSecret) > 0 {
			tokens = append(tokens, routing.GenerateRoutingToken(nodeID, routingSecret))
		}
	}
	c.mu.RUnlock()

	resp, err := client.ListNodes(ctx, &pbHub.ListNodesRequest{
		RoutingTokens: tokens,
	})
	if err != nil {
		return nil, err
	}
	return resp.Nodes, nil
}

// GetNodeFromHub fetches a single node's info from Hub.
func (c *Controller) GetNodeFromHub(ctx context.Context, nodeID string) (*pbHub.Node, error) {
	c.mu.RLock()
	client := c.mobileClient
	routingSecret := c.cfg.RoutingSecret
	c.mu.RUnlock()

	if client == nil {
		return nil, fmt.Errorf("not connected to Hub")
	}

	routingToken := ""
	if len(routingSecret) > 0 {
		routingToken = routing.GenerateRoutingToken(nodeID, routingSecret)
	}

	return client.GetNode(ctx, &pbHub.GetNodeRequest{
		NodeId:       nodeID,
		RoutingToken: routingToken,
	})
}

// RegisterNodeWithCert registers a node with the Hub using an existing certificate (PAKE mode).
func (c *Controller) RegisterNodeWithCert(ctx context.Context, nodeID, certPEM, routingToken string) error {
	c.mu.RLock()
	client := c.mobileClient
	id := c.identity
	c.mu.RUnlock()

	if client == nil {
		return fmt.Errorf("not connected to Hub")
	}
	if id == nil || len(id.RootCertPEM) == 0 {
		return fmt.Errorf("identity root CA not available")
	}

	_, err := client.RegisterNodeWithCert(ctx, &pbHub.RegisterNodeWithCertRequest{
		NodeId:       nodeID,
		CertPem:      certPEM,
		RoutingToken: routingToken,
		CaPem:        string(id.RootCertPEM),
	})
	return err
}

// DeleteNodeFromHub removes a node from Hub.
func (c *Controller) DeleteNodeFromHub(ctx context.Context, nodeID string) error {
	c.mu.RLock()
	client := c.mobileClient
	c.mu.RUnlock()

	if client == nil {
		return fmt.Errorf("not connected to Hub")
	}

	_, err := client.DeleteNode(ctx, &pbHub.DeleteNodeRequest{NodeId: nodeID})
	return err
}

// ApproveNodeOnHub approves a pending node registration on the Hub.
func (c *Controller) ApproveNodeOnHub(ctx context.Context, regCode, certPEM, caPEM, nodeID string) error {
	c.mu.RLock()
	client := c.mobileClient
	routingSecret := c.cfg.RoutingSecret
	c.mu.RUnlock()

	if client == nil {
		return fmt.Errorf("not connected to Hub")
	}

	routingToken := ""
	if len(routingSecret) > 0 {
		routingToken = routing.GenerateRoutingToken(nodeID, routingSecret)
	}

	_, err := client.ApproveNode(ctx, &pbHub.ApproveNodeRequest{
		RegistrationCode: regCode,
		CertPem:          certPEM,
		CaPem:            caPEM,
		RoutingToken:     routingToken,
	})
	return err
}
