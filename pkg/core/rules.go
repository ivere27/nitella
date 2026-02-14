package core

import (
	"context"

	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	"google.golang.org/protobuf/proto"
)

// ListRules fetches rules from a node for a given proxy.
func (c *Controller) ListRules(ctx context.Context, nodeID, proxyID string) ([]*pbProxy.Rule, error) {
	req := &pbProxy.ListRulesRequest{ProxyId: proxyID}
	payload, err := proto.Marshal(req)
	if err != nil {
		return nil, err
	}

	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_LIST_RULES, payload)
	if err != nil {
		return nil, err
	}
	if result.Status != "OK" {
		return nil, commandError(result)
	}

	var resp pbProxy.ListRulesResponse
	if err := proto.Unmarshal(result.ResponsePayload, &resp); err != nil {
		return nil, err
	}
	return resp.Rules, nil
}

// AddRule adds a rule to a node's proxy.
func (c *Controller) AddRule(ctx context.Context, nodeID string, req *pbProxy.AddRuleRequest) (*pbProxy.Rule, error) {
	payload, err := proto.Marshal(req)
	if err != nil {
		return nil, err
	}

	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_ADD_RULE, payload)
	if err != nil {
		return nil, err
	}
	if result.Status != "OK" {
		return nil, commandError(result)
	}

	var rule pbProxy.Rule
	if len(result.ResponsePayload) > 0 {
		if err := proto.Unmarshal(result.ResponsePayload, &rule); err != nil {
			return nil, err
		}
	}
	return &rule, nil
}

// RemoveRule removes a rule from a node's proxy.
func (c *Controller) RemoveRule(ctx context.Context, nodeID string, proxyID, ruleID string) error {
	req := &pbProxy.RemoveRuleRequest{
		ProxyId: proxyID,
		RuleId:  ruleID,
	}
	payload, err := proto.Marshal(req)
	if err != nil {
		return err
	}

	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_REMOVE_RULE, payload)
	if err != nil {
		return err
	}
	if result.Status != "OK" {
		return commandError(result)
	}
	return nil
}
