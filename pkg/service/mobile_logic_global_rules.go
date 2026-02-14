package service

import (
	"context"
	"fmt"

	"github.com/ivere27/nitella/pkg/api/common"
	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pb "github.com/ivere27/nitella/pkg/api/local"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	"google.golang.org/protobuf/proto"
)

// ===========================================================================
// Global Rules (node-level, cross-proxy runtime rules)
// ===========================================================================

// AddGlobalRule adds a global block or allow rule on a node.
func (s *MobileLogicService) AddGlobalRule(ctx context.Context, req *pb.AddGlobalRuleRequest) (*pb.AddGlobalRuleResponse, error) {
	if err := validateIP(req.Ip); err != nil {
		return &pb.AddGlobalRuleResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}

	s.mu.RLock()
	node, exists := s.nodes[req.NodeId]
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if !exists {
		return &pb.AddGlobalRuleResponse{
			Success: false,
			Error:   fmt.Sprintf("node not found: %s", req.NodeId),
		}, nil
	}
	_, routeErr := requireRoutableNode(node, mobileClient, true)
	if routeErr != nil {
		return &pb.AddGlobalRuleResponse{
			Success: false,
			Error:   routeErr.Error(),
		}, nil
	}

	var cmdType pbHub.CommandType
	var reqMsg proto.Message

	switch req.Action {
	case common.ActionType_ACTION_TYPE_BLOCK:
		cmdType = pbHub.CommandType_COMMAND_TYPE_BLOCK_IP
		reqMsg = &pbProxy.BlockIPRequest{
			Ip:              req.Ip,
			DurationSeconds: req.DurationSeconds,
		}
	case common.ActionType_ACTION_TYPE_ALLOW:
		cmdType = pbHub.CommandType_COMMAND_TYPE_ALLOW_IP
		reqMsg = &pbProxy.AllowIPRequest{
			Ip:              req.Ip,
			DurationSeconds: req.DurationSeconds,
		}
	default:
		return &pb.AddGlobalRuleResponse{
			Success: false,
			Error:   "action must be BLOCK or ALLOW",
		}, nil
	}

	result, err := s.sendRoutedCommand(ctx, req.NodeId, cmdType, reqMsg)
	if err != nil {
		return &pb.AddGlobalRuleResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to send command: %v", err),
		}, nil
	}

	if result.Status != "OK" {
		return &pb.AddGlobalRuleResponse{
			Success: false,
			Error:   result.ErrorMessage,
		}, nil
	}

	return &pb.AddGlobalRuleResponse{Success: true}, nil
}

// ListGlobalRules lists all global rules on a node.
func (s *MobileLogicService) ListGlobalRules(ctx context.Context, req *pb.ListGlobalRulesRequest) (*pb.ListGlobalRulesResponse, error) {
	s.mu.RLock()
	node, exists := s.nodes[req.NodeId]
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if !exists {
		return nil, fmt.Errorf("node not found: %s", req.NodeId)
	}
	if _, err := requireRoutableNode(node, mobileClient, false); err != nil {
		return nil, err
	}

	result, err := s.sendRoutedCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_LIST_GLOBAL_RULES, &pbProxy.ListGlobalRulesRequest{})
	if err != nil {
		return nil, fmt.Errorf("failed to list global rules: %w", err)
	}

	if result.Status != "OK" {
		return nil, fmt.Errorf("failed to list global rules: %s", result.ErrorMessage)
	}

	var resp pbProxy.ListGlobalRulesResponse
	if err := proto.Unmarshal(result.ResponsePayload, &resp); err != nil {
		return nil, fmt.Errorf("failed to parse list global rules response: %w", err)
	}

	return &pb.ListGlobalRulesResponse{Rules: resp.Rules}, nil
}

// RemoveGlobalRule removes a global rule from a node.
func (s *MobileLogicService) RemoveGlobalRule(ctx context.Context, req *pb.RemoveGlobalRuleRequest) (*pb.RemoveGlobalRuleResponse, error) {
	s.mu.RLock()
	node, exists := s.nodes[req.NodeId]
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if !exists {
		return &pb.RemoveGlobalRuleResponse{
			Success: false,
			Error:   fmt.Sprintf("node not found: %s", req.NodeId),
		}, nil
	}
	if _, err := requireRoutableNode(node, mobileClient, true); err != nil {
		return &pb.RemoveGlobalRuleResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}

	result, err := s.sendRoutedCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_REMOVE_GLOBAL_RULE, &pbProxy.RemoveGlobalRuleRequest{RuleId: req.RuleId})
	if err != nil {
		return &pb.RemoveGlobalRuleResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to send command: %v", err),
		}, nil
	}

	if result.Status != "OK" {
		return &pb.RemoveGlobalRuleResponse{
			Success: false,
			Error:   result.ErrorMessage,
		}, nil
	}

	return &pb.RemoveGlobalRuleResponse{Success: true}, nil
}
