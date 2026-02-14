package service

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"log"

	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pb "github.com/ivere27/nitella/pkg/api/local"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// ===========================================================================
// Templates
// ===========================================================================

// ListTemplates lists available templates.
func (s *MobileLogicService) ListTemplates(ctx context.Context, req *pb.ListTemplatesRequest) (*pb.ListTemplatesResponse, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	templates := make([]*pb.Template, 0, len(s.templates))

	for _, t := range s.templates {
		// Apply tag filter if specified
		if len(req.Tags) > 0 {
			if !hasAnyTag(t.Tags, req.Tags) {
				continue
			}
		}
		templates = append(templates, t)
	}

	// Skip public templates from Hub - not a nitella feature

	return &pb.ListTemplatesResponse{
		Templates:  templates,
		TotalCount: int32(len(templates)),
	}, nil
}

// GetTemplate returns details about a specific template.
func (s *MobileLogicService) GetTemplate(ctx context.Context, req *pb.GetTemplateRequest) (*pb.Template, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	t, exists := s.templates[req.TemplateId]
	if !exists {
		return nil, fmt.Errorf("template not found: %s", req.TemplateId)
	}

	return t, nil
}

// CreateTemplate creates a new template from a node's current configuration.
func (s *MobileLogicService) CreateTemplate(ctx context.Context, req *pb.CreateTemplateRequest) (*pb.Template, error) {
	// Check node exists and get required data under read lock
	s.mu.RLock()
	node, exists := s.nodes[req.NodeId]
	canFetch := exists && (node.Online || s.mobileClient != nil)
	fingerprint := ""
	if s.identity != nil {
		fingerprint = s.identity.Fingerprint
	}
	s.mu.RUnlock()

	if !exists {
		return nil, fmt.Errorf("node not found: %s", req.NodeId)
	}

	// Generate template ID
	idBytes := make([]byte, 8)
	rand.Read(idBytes)
	templateID := hex.EncodeToString(idBytes)

	// Fetch proxy configurations from node if online (lock NOT held — sendCommand manages its own locking)
	var proxyTemplates []*pb.ProxyTemplate
	if canFetch {
		listReq := &pbProxy.ListProxiesRequest{}
		payload, err := proto.Marshal(listReq)
		if err != nil {
			return nil, fmt.Errorf("failed to encode list proxies request: %w", err)
		}

		result, err := s.sendCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_LIST_PROXIES, payload)
		if err == nil && result.Status == "OK" {
			var listResp pbProxy.ListProxiesResponse
			if proto.Unmarshal(result.ResponsePayload, &listResp) == nil {
				for _, p := range listResp.Proxies {
					// Fetch rules for each proxy
					rulesReq := &pbProxy.ListRulesRequest{ProxyId: p.ProxyId}
					rulesPayload, err := proto.Marshal(rulesReq)
					if err != nil {
						if s.debugMode {
							log.Printf("warning: failed to encode list rules request for proxy %s: %v", p.ProxyId, err)
						}
						continue
					}
					rulesResult, err := s.sendCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_LIST_RULES, rulesPayload)

					var rules []*pbProxy.Rule
					if err == nil && rulesResult.Status == "OK" {
						var rulesResp pbProxy.ListRulesResponse
						if proto.Unmarshal(rulesResult.ResponsePayload, &rulesResp) == nil {
							rules = rulesResp.Rules
						}
					}

					proxyTemplates = append(proxyTemplates, &pb.ProxyTemplate{
						Name:           p.ProxyId, // Use proxy_id as name
						ListenAddr:     p.ListenAddr,
						DefaultAction:  p.DefaultAction,
						FallbackAction: p.FallbackAction,
						Rules:          rules,
					})
				}
			}
		}
	}

	template := &pb.Template{
		TemplateId:  templateID,
		Name:        req.Name,
		Description: req.Description,
		CreatedAt:   timestamppb.Now(),
		UpdatedAt:   timestamppb.Now(),
		Author:      fingerprint,
		IsPublic:    false,
		Tags:        req.Tags,
		Proxies:     proxyTemplates,
	}

	// Acquire write lock only for state mutation
	s.mu.Lock()
	s.templates[templateID] = template
	s.mu.Unlock()

	// Persist template to storage
	if err := s.saveTemplate(template); err != nil {
		// Non-fatal, template is in memory
		if s.debugMode {
			log.Printf("warning: failed to save template: %v\n", err)
		}
	}

	return template, nil
}

// ApplyTemplate applies a template to a node.
func (s *MobileLogicService) ApplyTemplate(ctx context.Context, req *pb.ApplyTemplateRequest) (*pb.ApplyTemplateResponse, error) {
	s.mu.RLock()
	template, templateExists := s.templates[req.TemplateId]
	node, nodeExists := s.nodes[req.NodeId]
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if !templateExists {
		return &pb.ApplyTemplateResponse{
			Success: false,
			Error:   "template not found",
		}, nil
	}

	if !nodeExists {
		return &pb.ApplyTemplateResponse{
			Success: false,
			Error:   "node not found",
		}, nil
	}

	if !node.Online && mobileClient == nil {
		return &pb.ApplyTemplateResponse{
			Success: false,
			Error:   "node is offline",
		}, nil
	}

	if mobileClient == nil {
		return &pb.ApplyTemplateResponse{
			Success: false,
			Error:   "not connected to Hub",
		}, nil
	}

	// Send template configuration to node
	// For each proxy in template, create proxy on node
	// For each rule in proxy, add rule
	proxiesCreated := int32(0)
	rulesCreated := int32(0)

	for _, pt := range template.Proxies {
		// Create proxy
		createReq := &pbProxy.CreateProxyRequest{
			Name:           pt.Name,
			ListenAddr:     pt.ListenAddr,
			DefaultAction:  pt.DefaultAction,
			FallbackAction: pt.FallbackAction,
		}
		payload, err := proto.Marshal(createReq)
		if err != nil {
			if s.debugMode {
				log.Printf("warning: failed to encode create proxy request for template proxy %s: %v", pt.GetName(), err)
			}
			continue
		}

		result, err := s.sendCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_APPLY_PROXY, payload)
		if err != nil || result.Status != "OK" {
			continue
		}

		// Parse response to get proxy ID
		var createResp pbProxy.ProxyStatus
		if proto.Unmarshal(result.ResponsePayload, &createResp) != nil {
			continue
		}

		proxiesCreated++

		// Add rules for this proxy
		for _, rule := range pt.Rules {
			addRuleReq := &pbProxy.AddRuleRequest{
				ProxyId: createResp.ProxyId,
				Rule:    rule,
			}
			rulePayload, err := proto.Marshal(addRuleReq)
			if err != nil {
				if s.debugMode {
					log.Printf("warning: failed to encode add rule request for template proxy %s: %v", pt.GetName(), err)
				}
				continue
			}
			ruleResult, err := s.sendCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_ADD_RULE, rulePayload)
			if err == nil && ruleResult.Status == "OK" {
				rulesCreated++
			}
		}
	}

	return &pb.ApplyTemplateResponse{
		Success:        true,
		ProxiesCreated: proxiesCreated,
		RulesCreated:   rulesCreated,
	}, nil
}

// DeleteTemplate deletes a template.
func (s *MobileLogicService) DeleteTemplate(ctx context.Context, req *pb.DeleteTemplateRequest) (*emptypb.Empty, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if _, exists := s.templates[req.TemplateId]; !exists {
		return nil, fmt.Errorf("template not found: %s", req.TemplateId)
	}

	delete(s.templates, req.TemplateId)

	// Remove from persistent storage
	if err := s.deleteTemplateFile(req.TemplateId); err != nil {
		// Non-fatal, template is removed from memory
		if s.debugMode {
			log.Printf("warning: failed to delete template file: %v\n", err)
		}
	}

	return &emptypb.Empty{}, nil
}

// SyncTemplates syncs templates with Hub.
func (s *MobileLogicService) SyncTemplates(ctx context.Context, _ *emptypb.Empty) (*pb.SyncTemplatesResponse, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	if s.mobileClient == nil {
		return &pb.SyncTemplatesResponse{
			Uploaded:   0,
			Downloaded: 0,
			Conflicts:  0,
		}, nil
	}

	// Skip template sync with Hub - not a nitella feature
	return &pb.SyncTemplatesResponse{
		Uploaded:   0,
		Downloaded: 0,
		Conflicts:  0,
	}, nil
}

// hasAnyTag checks if the source has any of the target tags.
func hasAnyTag(source, target []string) bool {
	for _, s := range source {
		for _, t := range target {
			if s == t {
				return true
			}
		}
	}
	return false
}
