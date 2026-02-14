package service

import (
	"context"
	"fmt"
	"net"
	"strings"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/local"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
)

// ===========================================================================
// IP/ISP Blocking Operations
// ===========================================================================

// validateIP validates an IP address or CIDR notation using net.ParseIP / net.ParseCIDR.
func validateIP(ip string) error {
	if strings.Contains(ip, "/") {
		_, _, err := net.ParseCIDR(ip)
		if err != nil {
			return fmt.Errorf("invalid CIDR: %s", ip)
		}
		return nil
	}
	if net.ParseIP(ip) == nil {
		return fmt.Errorf("invalid IP address: %s", ip)
	}
	return nil
}

// BlockIP blocks an IP address by creating a block rule on the specified node(s).
func (s *MobileLogicService) BlockIP(ctx context.Context, req *pb.BlockIPRequest) (*pb.BlockIPResponse, error) {
	if req == nil {
		return &pb.BlockIPResponse{
			Success: false,
			Error:   "request is required",
		}, nil
	}

	// Validate IP
	if err := validateIP(req.Ip); err != nil {
		return &pb.BlockIPResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}

	op := common.Operator_OPERATOR_EQ
	if strings.Contains(req.Ip, "/") {
		op = common.Operator_OPERATOR_CIDR
	}

	newBlockRule := func() *pbProxy.Rule {
		return &pbProxy.Rule{
			Name:    fmt.Sprintf("Block %s", req.Ip),
			Enabled: true,
			Action:  common.ActionType_ACTION_TYPE_BLOCK,
			Conditions: []*pbProxy.Condition{
				{
					Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
					Op:    op,
					Value: req.Ip,
				},
			},
		}
	}

	var rulesCreated int32

	if req.ApplyToAllNodes {
		// Apply to all reachable nodes (online via P2P or reachable via Hub)
		s.mu.RLock()
		nodes := make([]*pb.NodeInfo, 0)
		hubConnected := s.mobileClient != nil
		for _, node := range s.nodes {
			if node.Online || hubConnected {
				nodes = append(nodes, node)
			}
		}
		s.mu.RUnlock()

		for _, node := range nodes {
			_, err := s.AddRule(ctx, &pb.AddRuleRequest{
				NodeId:  node.NodeId,
				ProxyId: req.ProxyId,
				Rule:    newBlockRule(),
			})
			if err == nil {
				rulesCreated++
			}
		}
	} else if req.NodeId != "" {
		_, err := s.AddRule(ctx, &pb.AddRuleRequest{
			NodeId:  req.NodeId,
			ProxyId: req.ProxyId,
			Rule:    newBlockRule(),
		})
		if err != nil {
			return &pb.BlockIPResponse{
				Success: false,
				Error:   fmt.Sprintf("failed to add block rule: %v", err),
			}, nil
		}
		rulesCreated = 1
	} else {
		return &pb.BlockIPResponse{
			Success: false,
			Error:   "node_id required when apply_to_all_nodes is false",
		}, nil
	}

	return &pb.BlockIPResponse{
		Success:      true,
		RulesCreated: rulesCreated,
	}, nil
}

// AllowIP allows an IP address by creating an allow rule on the specified node(s).
func (s *MobileLogicService) AllowIP(ctx context.Context, req *pb.AllowIPRequest) (*pb.AllowIPResponse, error) {
	if req == nil {
		return &pb.AllowIPResponse{
			Success: false,
			Error:   "request is required",
		}, nil
	}

	// Validate IP
	if err := validateIP(req.Ip); err != nil {
		return &pb.AllowIPResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}

	op := common.Operator_OPERATOR_EQ
	if strings.Contains(req.Ip, "/") {
		op = common.Operator_OPERATOR_CIDR
	}

	newAllowRule := func() *pbProxy.Rule {
		return &pbProxy.Rule{
			Name:    fmt.Sprintf("Allow %s", req.Ip),
			Enabled: true,
			Action:  common.ActionType_ACTION_TYPE_ALLOW,
			Conditions: []*pbProxy.Condition{
				{
					Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
					Op:    op,
					Value: req.Ip,
				},
			},
		}
	}

	var rulesCreated int32

	if req.ApplyToAllNodes {
		s.mu.RLock()
		nodes := make([]*pb.NodeInfo, 0)
		hubConnected := s.mobileClient != nil
		for _, node := range s.nodes {
			if node.Online || hubConnected {
				nodes = append(nodes, node)
			}
		}
		s.mu.RUnlock()

		for _, node := range nodes {
			_, err := s.AddRule(ctx, &pb.AddRuleRequest{
				NodeId:  node.NodeId,
				ProxyId: req.ProxyId,
				Rule:    newAllowRule(),
			})
			if err == nil {
				rulesCreated++
			}
		}
	} else if req.NodeId != "" {
		_, err := s.AddRule(ctx, &pb.AddRuleRequest{
			NodeId:  req.NodeId,
			ProxyId: req.ProxyId,
			Rule:    newAllowRule(),
		})
		if err != nil {
			return &pb.AllowIPResponse{
				Success: false,
				Error:   fmt.Sprintf("failed to add allow rule: %v", err),
			}, nil
		}
		rulesCreated = 1
	} else {
		return &pb.AllowIPResponse{
			Success: false,
			Error:   "node_id required when apply_to_all_nodes is false",
		}, nil
	}

	return &pb.AllowIPResponse{
		Success:      true,
		RulesCreated: rulesCreated,
	}, nil
}

// BlockISP blocks an ISP by creating a block rule on the specified node.
func (s *MobileLogicService) BlockISP(ctx context.Context, req *pb.BlockISPRequest) (*pb.BlockISPResponse, error) {
	if req == nil {
		return &pb.BlockISPResponse{
			Success: false,
			Error:   "request is required",
		}, nil
	}

	if req.Isp == "" {
		return &pb.BlockISPResponse{
			Success: false,
			Error:   "ISP name is required",
		}, nil
	}

	createdRule, err := s.AddRule(ctx, &pb.AddRuleRequest{
		NodeId:  req.NodeId,
		ProxyId: req.ProxyId,
		Rule: &pbProxy.Rule{
			Name:    fmt.Sprintf("Block ISP: %s", req.Isp),
			Enabled: true,
			Action:  common.ActionType_ACTION_TYPE_BLOCK,
			Conditions: []*pbProxy.Condition{
				{
					Type:  common.ConditionType_CONDITION_TYPE_GEO_ISP,
					Op:    common.Operator_OPERATOR_EQ,
					Value: req.Isp,
				},
			},
		},
	})
	if err != nil {
		return &pb.BlockISPResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to add ISP block rule: %v", err),
		}, nil
	}

	return &pb.BlockISPResponse{
		Success: true,
		RuleId:  createdRule.Id,
	}, nil
}

// BlockCountry blocks a country by creating a block rule on the specified node.
func (s *MobileLogicService) BlockCountry(ctx context.Context, req *pb.BlockCountryRequest) (*pb.BlockCountryResponse, error) {
	if req == nil {
		return &pb.BlockCountryResponse{
			Success: false,
			Error:   "request is required",
		}, nil
	}

	if strings.TrimSpace(req.Country) == "" {
		return &pb.BlockCountryResponse{
			Success: false,
			Error:   "country is required",
		}, nil
	}

	createdRule, err := s.AddRule(ctx, &pb.AddRuleRequest{
		NodeId:  req.NodeId,
		ProxyId: req.ProxyId,
		Rule: &pbProxy.Rule{
			Name:    fmt.Sprintf("Block Country: %s", req.Country),
			Enabled: true,
			Action:  common.ActionType_ACTION_TYPE_BLOCK,
			Conditions: []*pbProxy.Condition{
				{
					Type:  common.ConditionType_CONDITION_TYPE_GEO_COUNTRY,
					Op:    common.Operator_OPERATOR_EQ,
					Value: req.Country,
				},
			},
		},
	})
	if err != nil {
		return &pb.BlockCountryResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to add country block rule: %v", err),
		}, nil
	}

	return &pb.BlockCountryResponse{
		Success: true,
		RuleId:  createdRule.Id,
	}, nil
}
