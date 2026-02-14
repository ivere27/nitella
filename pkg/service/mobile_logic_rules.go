package service

import (
	"context"
	"fmt"
	"strings"

	"github.com/ivere27/nitella/pkg/api/common"
	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pb "github.com/ivere27/nitella/pkg/api/local"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/emptypb"
)

// ===========================================================================
// Rule Management
// ===========================================================================

// ListRules lists all rules for a proxy.
func (s *MobileLogicService) ListRules(ctx context.Context, req *pb.ListRulesRequest) (*pb.ListRulesResponse, error) {
	s.mu.RLock()
	if err := s.requireIdentity(); err != nil {
		s.mu.RUnlock()
		return nil, err
	}
	node, exists := s.nodes[req.NodeId]
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if !exists {
		return nil, fmt.Errorf("node not found: %s", req.NodeId)
	}
	if _, err := requireRoutableNode(node, mobileClient, false); err != nil {
		return nil, err
	}

	result, err := s.sendRoutedCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_LIST_RULES, &pbProxy.ListRulesRequest{ProxyId: req.ProxyId})
	if err != nil {
		return nil, fmt.Errorf("failed to list rules: %w", err)
	}

	if result.Status != "OK" {
		return nil, fmt.Errorf("failed to list rules: %s", result.ErrorMessage)
	}

	var resp pbProxy.ListRulesResponse
	if err := proto.Unmarshal(result.ResponsePayload, &resp); err != nil {
		return nil, fmt.Errorf("failed to parse list rules response: %w", err)
	}

	return &pb.ListRulesResponse{
		Rules:          resp.Rules,
		TotalCount:     int32(len(resp.Rules)),
		ComposerPolicy: defaultRuleComposerPolicy(),
	}, nil
}

// GetRule returns details about a specific rule.
func (s *MobileLogicService) GetRule(ctx context.Context, req *pb.GetRuleRequest) (*pbProxy.Rule, error) {
	// Get all rules and find the one we want
	rulesResp, err := s.ListRules(ctx, &pb.ListRulesRequest{
		NodeId:  req.NodeId,
		ProxyId: req.ProxyId,
	})
	if err != nil {
		return nil, err
	}

	for _, rule := range rulesResp.Rules {
		if rule.Id == req.RuleId {
			return rule, nil
		}
	}

	return nil, fmt.Errorf("rule not found: %s", req.RuleId)
}

// AddRule adds a new rule to a proxy.
func (s *MobileLogicService) AddRule(ctx context.Context, req *pb.AddRuleRequest) (*pbProxy.Rule, error) {
	s.mu.RLock()
	node, exists := s.nodes[req.NodeId]
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if !exists {
		return nil, fmt.Errorf("node not found: %s", req.NodeId)
	}
	if _, err := requireRoutableNode(node, mobileClient, true); err != nil {
		return nil, err
	}

	normalized := canonicalizeRule(req.Rule)
	result, err := s.sendRoutedCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_ADD_RULE, &pbProxy.AddRuleRequest{
		ProxyId: req.ProxyId,
		Rule:    normalized,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to add rule: %w", err)
	}

	if result.Status != "OK" {
		return nil, fmt.Errorf("failed to add rule: %s", result.ErrorMessage)
	}

	// Parse the created rule from node response (contains server-generated ID)
	var createdRule pbProxy.Rule
	if err := proto.Unmarshal(result.ResponsePayload, &createdRule); err != nil {
		return req.Rule, nil // Fall back to request rule
	}
	return &createdRule, nil
}

// UpdateRule updates an existing rule.
func (s *MobileLogicService) UpdateRule(ctx context.Context, req *pb.UpdateRuleRequest) (*pbProxy.Rule, error) {
	s.mu.RLock()
	node, exists := s.nodes[req.NodeId]
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if !exists {
		return nil, fmt.Errorf("node not found: %s", req.NodeId)
	}
	if _, err := requireRoutableNode(node, mobileClient, true); err != nil {
		return nil, err
	}

	// Clone and clear the ID so the node generates a new one (avoids UNIQUE constraint on same ID)
	ruleToAdd := proto.Clone(req.Rule).(*pbProxy.Rule)
	ruleToAdd = canonicalizeRule(ruleToAdd)
	oldRuleID := ruleToAdd.Id
	ruleToAdd.Id = ""

	// Add the updated rule first (so we don't lose data if delete succeeds but add fails).
	result, err := s.sendRoutedCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_ADD_RULE, &pbProxy.AddRuleRequest{
		ProxyId: req.ProxyId,
		Rule:    ruleToAdd,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to update rule: %w", err)
	}

	if result.Status != "OK" {
		return nil, fmt.Errorf("failed to update rule: %s", result.ErrorMessage)
	}

	// Parse the created rule from node response (contains server-generated ID)
	var updatedRule pbProxy.Rule
	if err := proto.Unmarshal(result.ResponsePayload, &updatedRule); err != nil {
		// Fall back but still try to remove old rule
		proto.Merge(&updatedRule, req.Rule)
	}

	// Now remove the old rule (safe: we already have the new one with different ID).
	_, _ = s.sendRoutedCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_REMOVE_RULE, &pbProxy.RemoveRuleRequest{
		ProxyId: req.ProxyId,
		RuleId:  oldRuleID,
	})

	return &updatedRule, nil
}

// RemoveRule removes a rule from a proxy.
func (s *MobileLogicService) RemoveRule(ctx context.Context, req *pb.RemoveRuleRequest) (*emptypb.Empty, error) {
	s.mu.RLock()
	node, exists := s.nodes[req.NodeId]
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if !exists {
		return nil, fmt.Errorf("node not found: %s", req.NodeId)
	}
	if _, err := requireRoutableNode(node, mobileClient, true); err != nil {
		return nil, err
	}

	result, err := s.sendRoutedCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_REMOVE_RULE, &pbProxy.RemoveRuleRequest{
		ProxyId: req.ProxyId,
		RuleId:  req.RuleId,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to remove rule: %w", err)
	}

	if result.Status != "OK" {
		return nil, fmt.Errorf("failed to remove rule: %s", result.ErrorMessage)
	}

	return &emptypb.Empty{}, nil
}

func canonicalizeRule(in *pbProxy.Rule) *pbProxy.Rule {
	if in == nil {
		return &pbProxy.Rule{}
	}

	rule := proto.Clone(in).(*pbProxy.Rule)
	for _, c := range rule.Conditions {
		if c == nil {
			continue
		}
		if c.Type == common.ConditionType_CONDITION_TYPE_UNSPECIFIED {
			c.Type = common.ConditionType_CONDITION_TYPE_SOURCE_IP
		}
		if c.Op == common.Operator_OPERATOR_UNSPECIFIED {
			c.Op = defaultOperatorForCondition(c.Type, c.Value)
		}
		if c.Type == common.ConditionType_CONDITION_TYPE_SOURCE_IP &&
			c.Op == common.Operator_OPERATOR_EQ &&
			strings.Contains(strings.TrimSpace(c.Value), "/") {
			c.Op = common.Operator_OPERATOR_CIDR
		}
	}

	if strings.TrimSpace(rule.Expression) == "" && len(rule.Conditions) > 0 {
		rule.Expression = buildConditionExpression(rule.Conditions)
	}
	return rule
}

func defaultOperatorForCondition(condType common.ConditionType, value string) common.Operator {
	switch condType {
	case common.ConditionType_CONDITION_TYPE_SOURCE_IP:
		if strings.Contains(strings.TrimSpace(value), "/") {
			return common.Operator_OPERATOR_CIDR
		}
		return common.Operator_OPERATOR_EQ
	case common.ConditionType_CONDITION_TYPE_GEO_CITY,
		common.ConditionType_CONDITION_TYPE_GEO_ISP,
		common.ConditionType_CONDITION_TYPE_TLS_CN,
		common.ConditionType_CONDITION_TYPE_TLS_CA,
		common.ConditionType_CONDITION_TYPE_TLS_OU,
		common.ConditionType_CONDITION_TYPE_TLS_SAN,
		common.ConditionType_CONDITION_TYPE_TLS_SERIAL:
		return common.Operator_OPERATOR_CONTAINS
	default:
		return common.Operator_OPERATOR_EQ
	}
}

func buildConditionExpression(conditions []*pbProxy.Condition) string {
	parts := make([]string, 0, len(conditions))
	for _, c := range conditions {
		if c == nil {
			continue
		}
		fn := conditionTypeToExprFunc(c.Type)
		part := fmt.Sprintf("%s(`%s`)", fn, strings.ReplaceAll(c.Value, "`", "\\`"))
		if c.Negate {
			part = "!" + part
		}
		parts = append(parts, part)
	}
	return strings.Join(parts, " && ")
}

func conditionTypeToExprFunc(condType common.ConditionType) string {
	switch condType {
	case common.ConditionType_CONDITION_TYPE_SOURCE_IP:
		return "ClientIP"
	case common.ConditionType_CONDITION_TYPE_GEO_COUNTRY:
		return "GeoCountry"
	case common.ConditionType_CONDITION_TYPE_GEO_CITY:
		return "GeoCity"
	case common.ConditionType_CONDITION_TYPE_GEO_ISP:
		return "GeoISP"
	case common.ConditionType_CONDITION_TYPE_TLS_PRESENT:
		return "TLSPresent"
	case common.ConditionType_CONDITION_TYPE_TLS_CN:
		return "TLSCN"
	case common.ConditionType_CONDITION_TYPE_TLS_CA:
		return "TLSCA"
	case common.ConditionType_CONDITION_TYPE_TLS_OU:
		return "TLSOU"
	case common.ConditionType_CONDITION_TYPE_TLS_SAN:
		return "TLSSAN"
	case common.ConditionType_CONDITION_TYPE_TLS_FINGERPRINT:
		return "TLSFingerprint"
	case common.ConditionType_CONDITION_TYPE_TLS_SERIAL:
		return "TLSSerial"
	case common.ConditionType_CONDITION_TYPE_TIME_RANGE:
		return "TimeRange"
	default:
		return "ClientIP"
	}
}
