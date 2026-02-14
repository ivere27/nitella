package core

import (
	"context"

	"github.com/ivere27/nitella/pkg/api/common"
	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	"google.golang.org/protobuf/proto"
)

// BlockIPWithRule creates a per-proxy IP block rule on a node.
// Unlike BlockIP (which uses global rules), this creates a regular proxy rule.
func (c *Controller) BlockIPWithRule(ctx context.Context, nodeID, proxyID, ip string) (*pbProxy.Rule, error) {
	if err := ValidateIPOrCIDR(ip); err != nil {
		return nil, err
	}

	req := &pbProxy.AddRuleRequest{
		ProxyId: proxyID,
		Rule: &pbProxy.Rule{
			Name:     "Block: " + ip,
			Priority: 1000,
			Enabled:  true,
			Action:   common.ActionType_ACTION_TYPE_BLOCK,
			Conditions: []*pbProxy.Condition{{
				Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
				Op:    common.Operator_OPERATOR_EQ,
				Value: ip,
			}},
		},
	}
	return c.AddRule(ctx, nodeID, req)
}

// BlockISPWithRule creates a per-proxy ISP block rule on a node.
func (c *Controller) BlockISPWithRule(ctx context.Context, nodeID, proxyID, isp string) (*pbProxy.Rule, error) {
	req := &pbProxy.AddRuleRequest{
		ProxyId: proxyID,
		Rule: &pbProxy.Rule{
			Name:     "Block ISP: " + isp,
			Priority: 1000,
			Enabled:  true,
			Action:   common.ActionType_ACTION_TYPE_BLOCK,
			Conditions: []*pbProxy.Condition{{
				Type:  common.ConditionType_CONDITION_TYPE_GEO_ISP,
				Op:    common.Operator_OPERATOR_EQ,
				Value: isp,
			}},
		},
	}

	return c.AddRule(ctx, nodeID, req)
}

// GetNodeStatus fetches the status summary from a node.
func (c *Controller) GetNodeStatus(ctx context.Context, nodeID string) (*pbProxy.StatsSummaryResponse, error) {
	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_STATUS, nil)
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
