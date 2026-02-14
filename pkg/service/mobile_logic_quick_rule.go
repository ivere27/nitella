package service

import (
	"context"
	"fmt"
	"net"
	"sort"
	"strings"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/local"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
)

func normalizeQuickSourceIP(value string, toCIDR24 bool) (string, error) {
	v := strings.TrimSpace(value)
	if v == "" {
		return "", fmt.Errorf("value is required")
	}
	if !toCIDR24 {
		return v, nil
	}

	if strings.Contains(v, "/") {
		ip, _, err := net.ParseCIDR(v)
		if err != nil {
			return "", fmt.Errorf("invalid CIDR: %s", v)
		}
		v4 := ip.To4()
		if v4 == nil {
			return "", fmt.Errorf("source_ip_to_cidr24 requires an IPv4 address")
		}
		return fmt.Sprintf("%d.%d.%d.0/24", v4[0], v4[1], v4[2]), nil
	}

	ip := net.ParseIP(v)
	if ip == nil {
		return "", fmt.Errorf("invalid IP address: %s", v)
	}
	v4 := ip.To4()
	if v4 == nil {
		return "", fmt.Errorf("source_ip_to_cidr24 requires an IPv4 address")
	}
	return fmt.Sprintf("%d.%d.%d.0/24", v4[0], v4[1], v4[2]), nil
}

func quickSourceIPOperator(value string) common.Operator {
	if strings.Contains(value, "/") {
		return common.Operator_OPERATOR_CIDR
	}
	return common.Operator_OPERATOR_EQ
}

func defaultQuickRuleName(action common.ActionType, cond common.ConditionType, value string) string {
	switch {
	case action == common.ActionType_ACTION_TYPE_BLOCK &&
		cond == common.ConditionType_CONDITION_TYPE_SOURCE_IP:
		return fmt.Sprintf("Block %s", value)
	case action == common.ActionType_ACTION_TYPE_ALLOW &&
		cond == common.ConditionType_CONDITION_TYPE_SOURCE_IP:
		return fmt.Sprintf("Allow %s", value)
	case action == common.ActionType_ACTION_TYPE_BLOCK &&
		cond == common.ConditionType_CONDITION_TYPE_GEO_COUNTRY:
		return fmt.Sprintf("Block Country: %s", value)
	case action == common.ActionType_ACTION_TYPE_BLOCK &&
		cond == common.ConditionType_CONDITION_TYPE_GEO_ISP:
		return fmt.Sprintf("Block ISP: %s", value)
	}
	return fmt.Sprintf("%s: %s", cond.String(), value)
}

func (s *MobileLogicService) resolveQuickRuleProxyTargets(ctx context.Context, nodeID, proxyID string) ([]string, error) {
	if strings.TrimSpace(proxyID) != "" {
		return []string{strings.TrimSpace(proxyID)}, nil
	}

	proxiesResp, err := s.ListProxies(ctx, &pb.ListProxiesRequest{NodeId: strings.TrimSpace(nodeID)})
	if err != nil {
		return nil, fmt.Errorf("failed to list proxies on node %s: %w", nodeID, err)
	}
	if proxiesResp == nil || len(proxiesResp.GetProxies()) == 0 {
		return nil, fmt.Errorf("no proxies found on node %s", nodeID)
	}

	seen := make(map[string]struct{}, len(proxiesResp.GetProxies()))
	ids := make([]string, 0, len(proxiesResp.GetProxies()))
	for _, p := range proxiesResp.GetProxies() {
		id := strings.TrimSpace(p.GetProxyId())
		if id == "" {
			continue
		}
		if _, ok := seen[id]; ok {
			continue
		}
		seen[id] = struct{}{}
		ids = append(ids, id)
	}
	if len(ids) == 0 {
		return nil, fmt.Errorf("no proxies found on node %s", nodeID)
	}
	sort.Strings(ids)
	return ids, nil
}

// AddQuickRule applies backend-owned quick rule mapping for thin clients.
func (s *MobileLogicService) AddQuickRule(ctx context.Context, req *pb.AddQuickRuleRequest) (*pb.AddQuickRuleResponse, error) {
	if req == nil {
		return &pb.AddQuickRuleResponse{Success: false, Error: "request is required"}, nil
	}

	nodeID := strings.TrimSpace(req.GetNodeId())
	proxyID := strings.TrimSpace(req.GetProxyId())
	value := strings.TrimSpace(req.GetValue())
	if value == "" {
		return &pb.AddQuickRuleResponse{Success: false, Error: "value is required"}, nil
	}
	if req.GetAction() == common.ActionType_ACTION_TYPE_UNSPECIFIED {
		return &pb.AddQuickRuleResponse{Success: false, Error: "action is required"}, nil
	}
	if req.GetConditionType() == common.ConditionType_CONDITION_TYPE_UNSPECIFIED {
		return &pb.AddQuickRuleResponse{Success: false, Error: "condition_type is required"}, nil
	}
	if nodeID == "" &&
		!(req.GetConditionType() == common.ConditionType_CONDITION_TYPE_SOURCE_IP &&
			(req.GetAction() == common.ActionType_ACTION_TYPE_BLOCK ||
				req.GetAction() == common.ActionType_ACTION_TYPE_ALLOW) &&
			req.GetApplyToAllNodes()) {
		return &pb.AddQuickRuleResponse{Success: false, Error: "node_id is required"}, nil
	}

	addGlobalOnNode := func(targetNodeID string) (*pb.AddGlobalRuleResponse, error) {
		return s.AddGlobalRule(ctx, &pb.AddGlobalRuleRequest{
			NodeId:          targetNodeID,
			Action:          req.GetAction(),
			Ip:              value,
			DurationSeconds: int64(req.GetDurationSeconds()),
		})
	}

	if req.GetConditionType() == common.ConditionType_CONDITION_TYPE_SOURCE_IP {
		normalized, err := normalizeQuickSourceIP(value, req.GetSourceIpToCidr24())
		if err != nil {
			return &pb.AddQuickRuleResponse{Success: false, Error: err.Error()}, nil
		}
		value = normalized

		if proxyID == "" && (req.GetAction() == common.ActionType_ACTION_TYPE_BLOCK ||
			req.GetAction() == common.ActionType_ACTION_TYPE_ALLOW) {
			if req.GetApplyToAllNodes() {
				s.mu.RLock()
				nodes := make([]*pb.NodeInfo, 0, len(s.nodes))
				hubConnected := s.mobileClient != nil
				for _, node := range s.nodes {
					if node.Online || hubConnected {
						nodes = append(nodes, node)
					}
				}
				s.mu.RUnlock()

				if len(nodes) == 0 {
					return &pb.AddQuickRuleResponse{Success: false, Error: "no reachable nodes for apply_to_all_nodes"}, nil
				}

				var rulesCreated int32
				lastErr := ""
				for _, node := range nodes {
					resp, err := addGlobalOnNode(strings.TrimSpace(node.GetNodeId()))
					if err != nil {
						lastErr = err.Error()
						continue
					}
					if !resp.GetSuccess() {
						if resp.GetError() != "" {
							lastErr = resp.GetError()
						}
						continue
					}
					rulesCreated++
				}
				if rulesCreated == 0 {
					if lastErr == "" {
						lastErr = "failed to add global rule on any node"
					}
					return &pb.AddQuickRuleResponse{Success: false, Error: lastErr}, nil
				}
				return &pb.AddQuickRuleResponse{
					Success:      true,
					RulesCreated: rulesCreated,
				}, nil
			}

			resp, err := addGlobalOnNode(nodeID)
			if err != nil {
				return &pb.AddQuickRuleResponse{Success: false, Error: err.Error()}, nil
			}
			if !resp.GetSuccess() {
				return &pb.AddQuickRuleResponse{Success: false, Error: resp.GetError()}, nil
			}
			return &pb.AddQuickRuleResponse{
				Success:      true,
				RulesCreated: 1,
			}, nil
		}
	}

	switch {
	case req.GetAction() == common.ActionType_ACTION_TYPE_BLOCK &&
		req.GetConditionType() == common.ConditionType_CONDITION_TYPE_SOURCE_IP:
		if proxyID == "" {
			return &pb.AddQuickRuleResponse{Success: false, Error: "proxy_id is required for per-proxy source_ip quick rules"}, nil
		}
		resp, err := s.BlockIP(ctx, &pb.BlockIPRequest{
			NodeId:          nodeID,
			ProxyId:         proxyID,
			Ip:              value,
			ApplyToAllNodes: req.GetApplyToAllNodes(),
		})
		if err != nil {
			return &pb.AddQuickRuleResponse{Success: false, Error: err.Error()}, nil
		}
		if !resp.GetSuccess() {
			return &pb.AddQuickRuleResponse{Success: false, Error: resp.GetError()}, nil
		}
		return &pb.AddQuickRuleResponse{
			Success:      true,
			RulesCreated: resp.GetRulesCreated(),
		}, nil

	case req.GetAction() == common.ActionType_ACTION_TYPE_ALLOW &&
		req.GetConditionType() == common.ConditionType_CONDITION_TYPE_SOURCE_IP:
		if proxyID == "" {
			return &pb.AddQuickRuleResponse{Success: false, Error: "proxy_id is required for per-proxy source_ip quick rules"}, nil
		}
		resp, err := s.AllowIP(ctx, &pb.AllowIPRequest{
			NodeId:          nodeID,
			ProxyId:         proxyID,
			Ip:              value,
			ApplyToAllNodes: req.GetApplyToAllNodes(),
		})
		if err != nil {
			return &pb.AddQuickRuleResponse{Success: false, Error: err.Error()}, nil
		}
		if !resp.GetSuccess() {
			return &pb.AddQuickRuleResponse{Success: false, Error: resp.GetError()}, nil
		}
		return &pb.AddQuickRuleResponse{
			Success:      true,
			RulesCreated: resp.GetRulesCreated(),
		}, nil

	case req.GetAction() == common.ActionType_ACTION_TYPE_BLOCK &&
		req.GetConditionType() == common.ConditionType_CONDITION_TYPE_GEO_COUNTRY:
		proxyTargets, err := s.resolveQuickRuleProxyTargets(ctx, nodeID, proxyID)
		if err != nil {
			return &pb.AddQuickRuleResponse{Success: false, Error: err.Error()}, nil
		}

		var rulesCreated int32
		ruleID := ""
		lastErr := ""
		for _, targetProxyID := range proxyTargets {
			resp, callErr := s.BlockCountry(ctx, &pb.BlockCountryRequest{
				NodeId:  nodeID,
				ProxyId: targetProxyID,
				Country: value,
			})
			if callErr != nil {
				lastErr = callErr.Error()
				continue
			}
			if !resp.GetSuccess() {
				if resp.GetError() != "" {
					lastErr = resp.GetError()
				}
				continue
			}
			if ruleID == "" {
				ruleID = resp.GetRuleId()
			}
			rulesCreated++
		}

		if rulesCreated == 0 {
			if lastErr == "" {
				lastErr = "failed to add country block rule"
			}
			return &pb.AddQuickRuleResponse{Success: false, Error: lastErr}, nil
		}
		return &pb.AddQuickRuleResponse{
			Success:      true,
			RuleId:       ruleID,
			RulesCreated: rulesCreated,
		}, nil

	case req.GetAction() == common.ActionType_ACTION_TYPE_BLOCK &&
		req.GetConditionType() == common.ConditionType_CONDITION_TYPE_GEO_ISP:
		proxyTargets, err := s.resolveQuickRuleProxyTargets(ctx, nodeID, proxyID)
		if err != nil {
			return &pb.AddQuickRuleResponse{Success: false, Error: err.Error()}, nil
		}

		var rulesCreated int32
		ruleID := ""
		lastErr := ""
		for _, targetProxyID := range proxyTargets {
			resp, callErr := s.BlockISP(ctx, &pb.BlockISPRequest{
				NodeId:  nodeID,
				ProxyId: targetProxyID,
				Isp:     value,
			})
			if callErr != nil {
				lastErr = callErr.Error()
				continue
			}
			if !resp.GetSuccess() {
				if resp.GetError() != "" {
					lastErr = resp.GetError()
				}
				continue
			}
			if ruleID == "" {
				ruleID = resp.GetRuleId()
			}
			rulesCreated++
		}

		if rulesCreated == 0 {
			if lastErr == "" {
				lastErr = "failed to add ISP block rule"
			}
			return &pb.AddQuickRuleResponse{Success: false, Error: lastErr}, nil
		}
		return &pb.AddQuickRuleResponse{
			Success:      true,
			RuleId:       ruleID,
			RulesCreated: rulesCreated,
		}, nil
	}

	if proxyID == "" {
		return &pb.AddQuickRuleResponse{Success: false, Error: "proxy_id is required for this quick rule"}, nil
	}

	name := strings.TrimSpace(req.GetName())
	if name == "" {
		name = defaultQuickRuleName(req.GetAction(), req.GetConditionType(), value)
	}

	op := common.Operator_OPERATOR_EQ
	if req.GetConditionType() == common.ConditionType_CONDITION_TYPE_SOURCE_IP {
		op = quickSourceIPOperator(value)
	}

	createdRule, err := s.AddRule(ctx, &pb.AddRuleRequest{
		NodeId:  nodeID,
		ProxyId: proxyID,
		Rule: &pbProxy.Rule{
			Name:    name,
			Enabled: true,
			Action:  req.GetAction(),
			Conditions: []*pbProxy.Condition{
				{
					Type:  req.GetConditionType(),
					Op:    op,
					Value: value,
				},
			},
		},
	})
	if err != nil {
		return &pb.AddQuickRuleResponse{Success: false, Error: err.Error()}, nil
	}

	return &pb.AddQuickRuleResponse{
		Success:      true,
		RuleId:       createdRule.GetId(),
		RulesCreated: 1,
	}, nil
}
