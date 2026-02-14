package core

import (
	"context"

	"github.com/ivere27/nitella/pkg/api/common"
	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	"google.golang.org/protobuf/proto"
)

// ResolveApproval sends an approval decision to a node.
func (c *Controller) ResolveApproval(ctx context.Context, nodeID, reqID string, allow bool, durationSeconds int64, reason string) error {
	action := common.ApprovalActionType_APPROVAL_ACTION_TYPE_BLOCK
	if allow {
		action = common.ApprovalActionType_APPROVAL_ACTION_TYPE_ALLOW
	}

	req := &pbProxy.ResolveApprovalRequest{
		ReqId:           reqID,
		Action:          action,
		DurationSeconds: durationSeconds,
		Reason:          reason,
	}
	payload, err := proto.Marshal(req)
	if err != nil {
		return err
	}

	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_RESOLVE_APPROVAL, payload)
	if err != nil {
		return err
	}
	if result.Status != "OK" {
		return commandError(result)
	}
	return nil
}

// ListActiveApprovals fetches active approvals from a node.
func (c *Controller) ListActiveApprovals(ctx context.Context, nodeID string, proxyID, sourceIP string) ([]*pbProxy.ActiveApproval, error) {
	req := &pbProxy.ListActiveApprovalsRequest{
		ProxyId:  proxyID,
		SourceIp: sourceIP,
	}
	payload, err := proto.Marshal(req)
	if err != nil {
		return nil, err
	}

	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_LIST_ACTIVE_APPROVALS, payload)
	if err != nil {
		return nil, err
	}
	if result.Status != "OK" {
		return nil, commandError(result)
	}

	var resp pbProxy.ListActiveApprovalsResponse
	if err := proto.Unmarshal(result.ResponsePayload, &resp); err != nil {
		return nil, err
	}
	return resp.Approvals, nil
}

// CancelApproval cancels an active approval on a node.
func (c *Controller) CancelApproval(ctx context.Context, nodeID, key string, closeConnections bool) (int32, error) {
	req := &pbProxy.CancelApprovalRequest{
		Key:              key,
		CloseConnections: closeConnections,
	}
	payload, err := proto.Marshal(req)
	if err != nil {
		return 0, err
	}

	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_CANCEL_APPROVAL, payload)
	if err != nil {
		return 0, err
	}
	if result.Status != "OK" {
		return 0, commandError(result)
	}

	var resp pbProxy.CancelApprovalResponse
	if err := proto.Unmarshal(result.ResponsePayload, &resp); err != nil {
		return 0, err
	}
	return resp.ConnectionsClosed, nil
}
