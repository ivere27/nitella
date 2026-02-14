package core

import (
	"context"
	"fmt"
	"net"
	"strings"

	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	"google.golang.org/protobuf/proto"
)

// BlockIP adds a global IP block rule on a node.
func (c *Controller) BlockIP(ctx context.Context, nodeID, ip string, durationSeconds int64) error {
	if err := ValidateIPOrCIDR(ip); err != nil {
		return err
	}

	req := &pbProxy.BlockIPRequest{
		Ip:              ip,
		DurationSeconds: durationSeconds,
	}
	payload, err := proto.Marshal(req)
	if err != nil {
		return err
	}

	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_BLOCK_IP, payload)
	if err != nil {
		return err
	}
	if result.Status != "OK" {
		return commandError(result)
	}
	return nil
}

// AllowIP adds a global IP allow rule on a node.
func (c *Controller) AllowIP(ctx context.Context, nodeID, ip string, durationSeconds int64) error {
	if err := ValidateIPOrCIDR(ip); err != nil {
		return err
	}

	req := &pbProxy.AllowIPRequest{
		Ip:              ip,
		DurationSeconds: durationSeconds,
	}
	payload, err := proto.Marshal(req)
	if err != nil {
		return err
	}

	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_ALLOW_IP, payload)
	if err != nil {
		return err
	}
	if result.Status != "OK" {
		return commandError(result)
	}
	return nil
}

// ListGlobalRules fetches global rules from a node.
func (c *Controller) ListGlobalRules(ctx context.Context, nodeID string) ([]*pbProxy.GlobalRule, error) {
	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_LIST_GLOBAL_RULES, nil)
	if err != nil {
		return nil, err
	}
	if result.Status != "OK" {
		return nil, commandError(result)
	}

	var resp pbProxy.ListGlobalRulesResponse
	if err := proto.Unmarshal(result.ResponsePayload, &resp); err != nil {
		return nil, err
	}
	return resp.Rules, nil
}

// RemoveGlobalRule removes a global rule from a node.
func (c *Controller) RemoveGlobalRule(ctx context.Context, nodeID, ruleID string) error {
	req := &pbProxy.RemoveGlobalRuleRequest{RuleId: ruleID}
	payload, err := proto.Marshal(req)
	if err != nil {
		return err
	}

	result, err := c.SendCommand(ctx, nodeID, pbHub.CommandType_COMMAND_TYPE_REMOVE_GLOBAL_RULE, payload)
	if err != nil {
		return err
	}
	if result.Status != "OK" {
		return commandError(result)
	}
	return nil
}

// ValidateIPOrCIDR validates an IP address or CIDR notation string.
func ValidateIPOrCIDR(input string) error {
	if input == "" {
		return fmt.Errorf("IP/CIDR cannot be empty")
	}
	if strings.Contains(input, "/") {
		_, _, err := net.ParseCIDR(input)
		if err != nil {
			return fmt.Errorf("invalid CIDR: %v", err)
		}
		return nil
	}
	if net.ParseIP(input) == nil {
		return fmt.Errorf("invalid IP address: %s", input)
	}
	return nil
}
