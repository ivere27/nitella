package core

import (
	"context"

	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	"google.golang.org/protobuf/proto"
)

// GetMetrics fetches aggregate metrics from a node.
func (c *Controller) GetMetrics(ctx context.Context, nodeID string) (*pbProxy.StatsSummaryResponse, error) {
	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_GET_METRICS, nil)
	if err != nil {
		return nil, err
	}
	if result.Status != "OK" {
		return nil, commandError(result)
	}

	var resp pbProxy.StatsSummaryResponse
	if err := proto.Unmarshal(result.ResponsePayload, &resp); err != nil {
		return nil, err
	}
	return &resp, nil
}

// GetActiveConnections fetches active connections from a node for a specific proxy.
func (c *Controller) GetActiveConnections(ctx context.Context, nodeID, proxyID string) ([]*pbProxy.ActiveConnection, error) {
	req := &pbProxy.GetActiveConnectionsRequest{ProxyId: proxyID}
	payload, err := proto.Marshal(req)
	if err != nil {
		return nil, err
	}

	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_GET_ACTIVE_CONNECTIONS, payload)
	if err != nil {
		return nil, err
	}
	if result.Status != "OK" {
		return nil, commandError(result)
	}

	var resp pbProxy.GetActiveConnectionsResponse
	if err := proto.Unmarshal(result.ResponsePayload, &resp); err != nil {
		return nil, err
	}
	return resp.Connections, nil
}

// CloseConnection closes a single connection on a node.
func (c *Controller) CloseConnection(ctx context.Context, nodeID, proxyID, connID string) error {
	req := &pbProxy.CloseConnectionRequest{
		ProxyId: proxyID,
		ConnId:  connID,
	}
	payload, err := proto.Marshal(req)
	if err != nil {
		return err
	}

	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_CLOSE_CONNECTION, payload)
	if err != nil {
		return err
	}
	if result.Status != "OK" {
		return commandError(result)
	}
	return nil
}

// CloseAllConnections closes all connections on a node's proxy.
func (c *Controller) CloseAllConnections(ctx context.Context, nodeID, proxyID string) error {
	req := &pbProxy.CloseAllConnectionsRequest{ProxyId: proxyID}
	payload, err := proto.Marshal(req)
	if err != nil {
		return err
	}

	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_CLOSE_ALL_CONNECTIONS, payload)
	if err != nil {
		return err
	}
	if result.Status != "OK" {
		return commandError(result)
	}
	return nil
}
