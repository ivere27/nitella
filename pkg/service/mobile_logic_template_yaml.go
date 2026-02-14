package service

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"log"
	"strconv"
	"strings"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/local"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	"google.golang.org/protobuf/types/known/timestamppb"
	"gopkg.in/yaml.v3"
)

// ExportTemplateYaml exports a template into YAML text.
func (s *MobileLogicService) ExportTemplateYaml(ctx context.Context, req *pb.ExportTemplateYamlRequest) (*pb.ExportTemplateYamlResponse, error) {
	templateID := strings.TrimSpace(req.GetTemplateId())
	if templateID == "" {
		return &pb.ExportTemplateYamlResponse{Success: false, Error: "template_id is required"}, nil
	}

	s.mu.RLock()
	tpl := s.templates[templateID]
	s.mu.RUnlock()
	if tpl == nil {
		return &pb.ExportTemplateYamlResponse{Success: false, Error: "template not found"}, nil
	}

	yamlText := templateToYAML(tpl)
	_ = ctx
	return &pb.ExportTemplateYamlResponse{
		Success:  true,
		Yaml:     yamlText,
		Template: tpl,
	}, nil
}

// ImportTemplateYaml imports template YAML using backend-owned parsing/validation.
func (s *MobileLogicService) ImportTemplateYaml(ctx context.Context, req *pb.ImportTemplateYamlRequest) (*pb.ImportTemplateYamlResponse, error) {
	raw := strings.TrimSpace(req.GetYaml())
	if raw == "" {
		return &pb.ImportTemplateYamlResponse{Success: false, Error: "yaml is required"}, nil
	}

	var doc map[string]interface{}
	if err := yaml.Unmarshal([]byte(raw), &doc); err != nil {
		return &pb.ImportTemplateYamlResponse{Success: false, Error: "invalid YAML: " + err.Error()}, nil
	}

	name := strings.TrimSpace(toString(doc["name"]))
	if name == "" {
		return &pb.ImportTemplateYamlResponse{Success: false, Error: "invalid template: missing name"}, nil
	}
	description := strings.TrimSpace(toString(doc["description"]))
	tags := parseStringList(doc["tags"])
	proxies, proxyCount := parseProxyTemplates(doc["proxies"])

	idBytes := make([]byte, 8)
	if _, err := rand.Read(idBytes); err != nil {
		return &pb.ImportTemplateYamlResponse{Success: false, Error: "failed to generate template id: " + err.Error()}, nil
	}
	templateID := hex.EncodeToString(idBytes)

	now := timestamppb.Now()
	author := ""
	s.mu.RLock()
	if s.identity != nil {
		author = s.identity.Fingerprint
	}
	s.mu.RUnlock()

	tpl := &pb.Template{
		TemplateId:  templateID,
		Name:        name,
		Description: description,
		CreatedAt:   now,
		UpdatedAt:   now,
		Author:      author,
		IsPublic:    false,
		Tags:        tags,
		Proxies:     proxies,
	}

	s.mu.Lock()
	s.templates[templateID] = tpl
	s.mu.Unlock()

	if err := s.saveTemplate(tpl); err != nil && s.debugMode {
		// Non-fatal: in-memory template still available.
		log.Printf("warning: failed to persist imported template: %v", err)
	}

	_ = ctx
	return &pb.ImportTemplateYamlResponse{
		Success:     true,
		Template:    tpl,
		Name:        name,
		Description: description,
		ProxyCount:  int32(proxyCount),
		Tags:        tags,
	}, nil
}

func templateToYAML(t *pb.Template) string {
	var b strings.Builder
	b.WriteString("name: " + yamlQuote(t.GetName()) + "\n")
	if strings.TrimSpace(t.GetDescription()) != "" {
		b.WriteString("description: " + yamlQuote(t.GetDescription()) + "\n")
	}
	if len(t.GetTags()) > 0 {
		b.WriteString("tags:\n")
		for _, tag := range t.GetTags() {
			b.WriteString("  - " + yamlQuote(tag) + "\n")
		}
	}
	if len(t.GetProxies()) > 0 {
		b.WriteString("proxies:\n")
		for _, p := range t.GetProxies() {
			b.WriteString("  - name: " + yamlQuote(p.GetName()) + "\n")
			b.WriteString("    listen_addr: " + yamlQuote(p.GetListenAddr()) + "\n")
			b.WriteString("    default_action: " + p.GetDefaultAction().String() + "\n")
			if p.GetFallbackAction() != common.FallbackAction_FALLBACK_ACTION_UNSPECIFIED {
				b.WriteString("    fallback_action: " + p.GetFallbackAction().String() + "\n")
			}
			if len(p.GetRules()) > 0 {
				b.WriteString("    rules:\n")
				for _, r := range p.GetRules() {
					b.WriteString("      - name: " + yamlQuote(r.GetName()) + "\n")
					b.WriteString("        priority: " + strconv.Itoa(int(r.GetPriority())) + "\n")
					b.WriteString("        action: " + r.GetAction().String() + "\n")
					if strings.TrimSpace(r.GetExpression()) != "" {
						b.WriteString("        expression: " + yamlQuote(r.GetExpression()) + "\n")
					}
				}
			}
		}
	}
	return b.String()
}

func yamlQuote(v string) string {
	if strings.ContainsAny(v, ":#'\"\n") || strings.HasPrefix(v, " ") || strings.HasSuffix(v, " ") {
		return `"` + strings.ReplaceAll(v, `"`, `\"`) + `"`
	}
	return v
}

func toString(v interface{}) string {
	switch x := v.(type) {
	case string:
		return x
	case fmt.Stringer:
		return x.String()
	default:
		if x == nil {
			return ""
		}
		return fmt.Sprintf("%v", x)
	}
}

func parseStringList(v interface{}) []string {
	raw, ok := v.([]interface{})
	if !ok {
		return nil
	}
	out := make([]string, 0, len(raw))
	for _, it := range raw {
		s := strings.TrimSpace(toString(it))
		if s != "" {
			out = append(out, s)
		}
	}
	return out
}

func parseProxyTemplates(v interface{}) ([]*pb.ProxyTemplate, int) {
	raw, ok := v.([]interface{})
	if !ok {
		return nil, 0
	}
	out := make([]*pb.ProxyTemplate, 0, len(raw))
	for _, it := range raw {
		item, ok := it.(map[string]interface{})
		if !ok {
			continue
		}
		name := strings.TrimSpace(toString(item["name"]))
		listenAddr := strings.TrimSpace(toString(item["listen_addr"]))
		defAction := parseActionType(item["default_action"], common.ActionType_ACTION_TYPE_ALLOW)
		fallback := parseFallbackAction(item["fallback_action"], common.FallbackAction_FALLBACK_ACTION_CLOSE)
		rules := parseRules(item["rules"])
		out = append(out, &pb.ProxyTemplate{
			Name:           name,
			ListenAddr:     listenAddr,
			DefaultAction:  defAction,
			FallbackAction: fallback,
			Rules:          rules,
		})
	}
	return out, len(out)
}

func parseRules(v interface{}) []*pbProxy.Rule {
	raw, ok := v.([]interface{})
	if !ok {
		return nil
	}
	out := make([]*pbProxy.Rule, 0, len(raw))
	for _, it := range raw {
		item, ok := it.(map[string]interface{})
		if !ok {
			continue
		}
		r := &pbProxy.Rule{
			Name:       strings.TrimSpace(toString(item["name"])),
			Priority:   int32(parseInt(item["priority"], 100)),
			Action:     parseActionType(item["action"], common.ActionType_ACTION_TYPE_BLOCK),
			Expression: strings.TrimSpace(toString(item["expression"])),
			Enabled:    true,
		}
		out = append(out, r)
	}
	return out
}

func parseActionType(v interface{}, def common.ActionType) common.ActionType {
	s := strings.TrimSpace(strings.ToUpper(toString(v)))
	if s == "" {
		return def
	}
	if val, ok := common.ActionType_value[s]; ok {
		return common.ActionType(val)
	}
	switch s {
	case "ALLOW":
		return common.ActionType_ACTION_TYPE_ALLOW
	case "BLOCK":
		return common.ActionType_ACTION_TYPE_BLOCK
	case "MOCK":
		return common.ActionType_ACTION_TYPE_MOCK
	case "REQUIRE_APPROVAL", "APPROVAL", "2FA":
		return common.ActionType_ACTION_TYPE_REQUIRE_APPROVAL
	default:
		return def
	}
}

func parseFallbackAction(v interface{}, def common.FallbackAction) common.FallbackAction {
	s := strings.TrimSpace(strings.ToUpper(toString(v)))
	if s == "" {
		return def
	}
	if val, ok := common.FallbackAction_value[s]; ok {
		return common.FallbackAction(val)
	}
	switch s {
	case "CLOSE":
		return common.FallbackAction_FALLBACK_ACTION_CLOSE
	case "MOCK":
		return common.FallbackAction_FALLBACK_ACTION_MOCK
	default:
		return def
	}
}

func parseInt(v interface{}, def int) int {
	switch x := v.(type) {
	case int:
		return x
	case int32:
		return int(x)
	case int64:
		return int(x)
	case uint32:
		return int(x)
	case uint64:
		return int(x)
	case float64:
		return int(x)
	case string:
		if n, err := strconv.Atoi(strings.TrimSpace(x)); err == nil {
			return n
		}
	}
	return def
}
