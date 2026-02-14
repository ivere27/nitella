package core

import (
	"context"

	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	"google.golang.org/protobuf/proto"
)

// ListProxies fetches all proxy statuses from a node.
func (c *Controller) ListProxies(ctx context.Context, nodeID string) ([]*pbProxy.ProxyStatus, error) {
	req := &pbProxy.ListProxiesRequest{}
	payload, err := proto.Marshal(req)
	if err != nil {
		return nil, err
	}

	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_LIST_PROXIES, payload)
	if err != nil {
		return nil, err
	}
	if result.Status != "OK" {
		return nil, commandError(result)
	}

	var resp pbProxy.ListProxiesResponse
	if err := proto.Unmarshal(result.ResponsePayload, &resp); err != nil {
		return nil, err
	}
	return resp.Proxies, nil
}

// ApplyProxy sends a proxy configuration (YAML or CreateProxyRequest) to a node.
func (c *Controller) ApplyProxy(ctx context.Context, nodeID string, req *pbProxy.ApplyProxyRequest) error {
	payload, err := proto.Marshal(req)
	if err != nil {
		return err
	}

	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_APPLY_PROXY, payload)
	if err != nil {
		return err
	}
	if result.Status != "OK" {
		return commandError(result)
	}
	return nil
}

// CreateProxy creates a new proxy on a node.
func (c *Controller) CreateProxy(ctx context.Context, nodeID string, req *pbProxy.CreateProxyRequest) (*pbProxy.CreateProxyResponse, error) {
	resp, err := SendCommandTyped[pbProxy.CreateProxyResponse](c, ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_CREATE_PROXY, req)
	return resp, err
}

// DeleteProxy deletes a proxy on a node.
func (c *Controller) DeleteProxy(ctx context.Context, nodeID, proxyID string) error {
	req := &pbProxy.DeleteProxyRequest{ProxyId: proxyID}
	payload, err := proto.Marshal(req)
	if err != nil {
		return err
	}

	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_UNAPPLY_PROXY, payload)
	if err != nil {
		return err
	}
	if result.Status != "OK" {
		return commandError(result)
	}
	return nil
}

// UpdateProxy updates a proxy configuration on a node.
func (c *Controller) UpdateProxy(ctx context.Context, nodeID string, req *pbProxy.UpdateProxyRequest) error {
	payload, err := proto.Marshal(req)
	if err != nil {
		return err
	}

	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_PROXY_UPDATE, payload)
	if err != nil {
		return err
	}
	if result.Status != "OK" {
		return commandError(result)
	}
	return nil
}

// EnableProxy enables a proxy on a node.
func (c *Controller) EnableProxy(ctx context.Context, nodeID, proxyID string) error {
	req := &pbProxy.EnableProxyRequest{ProxyId: proxyID}
	payload, err := proto.Marshal(req)
	if err != nil {
		return err
	}

	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_ENABLE_PROXY, payload)
	if err != nil {
		return err
	}
	if result.Status != "OK" {
		return commandError(result)
	}
	return nil
}

// DisableProxy disables a proxy on a node.
func (c *Controller) DisableProxy(ctx context.Context, nodeID, proxyID string) error {
	req := &pbProxy.DisableProxyRequest{ProxyId: proxyID}
	payload, err := proto.Marshal(req)
	if err != nil {
		return err
	}

	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_DISABLE_PROXY, payload)
	if err != nil {
		return err
	}
	if result.Status != "OK" {
		return commandError(result)
	}
	return nil
}
