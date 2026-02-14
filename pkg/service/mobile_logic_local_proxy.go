package service

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"github.com/google/uuid"
	pb "github.com/ivere27/nitella/pkg/api/local"
	"github.com/ivere27/nitella/pkg/config"
	"google.golang.org/protobuf/types/known/timestamppb"
	"gopkg.in/yaml.v3"
)

type internalLocalProxySyncContextKey struct{}

func withInternalLocalProxySyncContext(ctx context.Context) context.Context {
	return context.WithValue(ctx, internalLocalProxySyncContextKey{}, true)
}

func canWriteLocalProxySyncMetadata(ctx context.Context) bool {
	v, _ := ctx.Value(internalLocalProxySyncContextKey{}).(bool)
	return v
}

type localProxyMeta struct {
	ID          string    `yaml:"id" json:"id"`
	Name        string    `yaml:"name" json:"name"`
	Description string    `yaml:"description,omitempty" json:"description,omitempty"`
	CreatedAt   time.Time `yaml:"created_at" json:"created_at"`
	UpdatedAt   time.Time `yaml:"updated_at" json:"updated_at"`
	SyncedAt    time.Time `yaml:"synced_at,omitempty" json:"synced_at,omitempty"`
	RevisionNum int64     `yaml:"revision_num,omitempty" json:"revision_num,omitempty"`
	ConfigHash  string    `yaml:"config_hash,omitempty" json:"config_hash,omitempty"`
}

func (s *MobileLogicService) localProxiesDir() string {
	return filepath.Join(s.dataDir, "proxies")
}

func (s *MobileLogicService) localProxyIndexPath() string {
	return filepath.Join(s.localProxiesDir(), "index.json")
}

func (s *MobileLogicService) localProxyPath(proxyID string) string {
	return filepath.Join(s.localProxiesDir(), proxyID+".yaml")
}

func (s *MobileLogicService) loadLocalProxyIndexLocked() (map[string]*localProxyMeta, error) {
	indexPath := s.localProxyIndexPath()
	data, err := os.ReadFile(indexPath)
	if err != nil {
		if os.IsNotExist(err) {
			return make(map[string]*localProxyMeta), nil
		}
		return nil, err
	}

	var index map[string]*localProxyMeta
	if err := json.Unmarshal(data, &index); err != nil {
		return nil, err
	}
	if index == nil {
		return make(map[string]*localProxyMeta), nil
	}
	return index, nil
}

func (s *MobileLogicService) saveLocalProxyIndexLocked(index map[string]*localProxyMeta) error {
	if err := os.MkdirAll(s.localProxiesDir(), 0700); err != nil {
		return err
	}
	data, err := json.MarshalIndent(index, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(s.localProxyIndexPath(), data, 0600)
}

func resolveProxyIDFromIndex(index map[string]*localProxyMeta, idOrPrefix string, fallbackToInput bool) (string, error) {
	proxyID := strings.TrimSpace(idOrPrefix)
	if proxyID == "" {
		return "", fmt.Errorf("proxy_id is required")
	}
	if _, ok := index[proxyID]; ok {
		return proxyID, nil
	}

	matches := make([]string, 0, 1)
	for id := range index {
		if strings.HasPrefix(id, proxyID) {
			matches = append(matches, id)
		}
	}
	sort.Strings(matches)

	switch len(matches) {
	case 0:
		if fallbackToInput {
			return proxyID, nil
		}
		return "", fmt.Errorf("local proxy not found")
	case 1:
		return matches[0], nil
	default:
		return "", fmt.Errorf("ambiguous proxy id prefix: %s", proxyID)
	}
}

func (s *MobileLogicService) resolveProxyID(idOrPrefix string, fallbackToInput bool) (string, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	index, err := s.loadLocalProxyIndexLocked()
	if err != nil {
		return "", err
	}
	return resolveProxyIDFromIndex(index, idOrPrefix, fallbackToInput)
}

func configHash(content []byte) string {
	sum := sha256.Sum256(content)
	return hex.EncodeToString(sum[:])
}

func timePtr(t time.Time) *timestamppb.Timestamp {
	if t.IsZero() {
		return nil
	}
	return timestamppb.New(t)
}

func toPBLocalProxy(meta *localProxyMeta) *pb.LocalProxyConfig {
	if meta == nil {
		return nil
	}
	return &pb.LocalProxyConfig{
		ProxyId:     meta.ID,
		Name:        meta.Name,
		Description: meta.Description,
		CreatedAt:   timePtr(meta.CreatedAt),
		UpdatedAt:   timePtr(meta.UpdatedAt),
		SyncedAt:    timePtr(meta.SyncedAt),
		RevisionNum: meta.RevisionNum,
		ConfigHash:  meta.ConfigHash,
	}
}

func normalizeProxyContent(raw []byte) ([]byte, map[string]interface{}, error) {
	trimmed := strings.TrimSpace(string(raw))
	if trimmed == "" {
		return nil, nil, fmt.Errorf("empty proxy content")
	}

	// Accept either full content with nitella header or raw YAML body.
	body, _, err := config.ExtractContent(raw)
	if err != nil {
		body = raw
	}

	var yamlData map[string]interface{}
	if err := yaml.Unmarshal(body, &yamlData); err != nil {
		return nil, nil, fmt.Errorf("invalid YAML: %v", err)
	}
	if yamlData == nil {
		yamlData = map[string]interface{}{}
	}
	return body, yamlData, nil
}

func extractMetaStrings(yamlData map[string]interface{}) (id string, name string, desc string) {
	meta, ok := yamlData["meta"].(map[string]interface{})
	if !ok || meta == nil {
		return "", "", ""
	}
	if v, ok := meta["id"].(string); ok {
		id = strings.TrimSpace(v)
	}
	if v, ok := meta["name"].(string); ok {
		name = strings.TrimSpace(v)
	}
	if v, ok := meta["description"].(string); ok {
		desc = strings.TrimSpace(v)
	}
	return id, name, desc
}

func ensureYAMLMeta(yamlData map[string]interface{}) map[string]interface{} {
	meta, ok := yamlData["meta"].(map[string]interface{})
	if !ok || meta == nil {
		meta = map[string]interface{}{}
		yamlData["meta"] = meta
	}
	return meta
}

func (s *MobileLogicService) ListLocalProxyConfigs(ctx context.Context, req *pb.ListLocalProxyConfigsRequest) (*pb.ListLocalProxyConfigsResponse, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	index, err := s.loadLocalProxyIndexLocked()
	if err != nil {
		return nil, err
	}

	metas := make([]*localProxyMeta, 0, len(index))
	for _, meta := range index {
		metas = append(metas, meta)
	}
	sort.Slice(metas, func(i, j int) bool {
		return strings.ToLower(metas[i].Name) < strings.ToLower(metas[j].Name)
	})

	resp := &pb.ListLocalProxyConfigsResponse{}
	for _, meta := range metas {
		resp.Proxies = append(resp.Proxies, toPBLocalProxy(meta))
	}
	_ = ctx
	_ = req
	return resp, nil
}

func (s *MobileLogicService) GetLocalProxyConfig(ctx context.Context, req *pb.GetLocalProxyConfigRequest) (*pb.GetLocalProxyConfigResponse, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	index, err := s.loadLocalProxyIndexLocked()
	if err != nil {
		return &pb.GetLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}
	proxyID, err := resolveProxyIDFromIndex(index, req.GetProxyId(), false)
	if err != nil {
		return &pb.GetLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}
	meta := index[proxyID]
	if meta == nil {
		return &pb.GetLocalProxyConfigResponse{Success: false, Error: "local proxy not found"}, nil
	}

	content, err := os.ReadFile(s.localProxyPath(proxyID))
	if err != nil {
		return &pb.GetLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}

	_ = ctx
	return &pb.GetLocalProxyConfigResponse{
		Success:    true,
		Proxy:      toPBLocalProxy(meta),
		ConfigYaml: string(content),
	}, nil
}

func (s *MobileLogicService) ImportLocalProxyConfig(ctx context.Context, req *pb.ImportLocalProxyConfigRequest) (*pb.ImportLocalProxyConfigResponse, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	raw := req.GetConfigData()
	if len(raw) == 0 {
		return &pb.ImportLocalProxyConfigResponse{Success: false, Error: "config_data is required"}, nil
	}

	_, yamlData, err := normalizeProxyContent(raw)
	if err != nil {
		return &pb.ImportLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}

	existingID, metaName, metaDesc := extractMetaStrings(yamlData)
	proxyID := existingID
	if proxyID == "" {
		proxyID = uuid.New().String()
	}

	name := strings.TrimSpace(req.GetName())
	if name == "" {
		name = metaName
	}
	if name == "" {
		sourceName := strings.TrimSpace(req.GetSourceName())
		if sourceName != "" {
			base := filepath.Base(sourceName)
			name = strings.TrimSuffix(base, filepath.Ext(base))
		}
	}
	if name == "" {
		name = "proxy-" + proxyID[:8]
	}

	index, err := s.loadLocalProxyIndexLocked()
	if err != nil {
		return &pb.ImportLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}
	prev := index[proxyID]

	now := time.Now()
	createdAt := now
	if prev != nil && !prev.CreatedAt.IsZero() {
		createdAt = prev.CreatedAt
	}

	meta := ensureYAMLMeta(yamlData)
	meta["id"] = proxyID
	meta["name"] = name
	meta["created_at"] = createdAt.Format(time.RFC3339)
	meta["updated_at"] = now.Format(time.RFC3339)
	if metaDesc != "" {
		meta["description"] = metaDesc
	}

	body, err := yaml.Marshal(yamlData)
	if err != nil {
		return &pb.ImportLocalProxyConfigResponse{Success: false, Error: fmt.Sprintf("serialize yaml: %v", err)}, nil
	}
	fullContent := config.WriteWithHeader(config.TypeProxy, config.VersionProxy, body, false)

	if err := os.MkdirAll(s.localProxiesDir(), 0700); err != nil {
		return &pb.ImportLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}
	if err := os.WriteFile(s.localProxyPath(proxyID), fullContent, 0600); err != nil {
		return &pb.ImportLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}

	newMeta := &localProxyMeta{
		ID:          proxyID,
		Name:        name,
		Description: metaDesc,
		CreatedAt:   createdAt,
		UpdatedAt:   now,
		ConfigHash:  configHash(fullContent),
	}
	if prev != nil {
		newMeta.SyncedAt = prev.SyncedAt
		newMeta.RevisionNum = prev.RevisionNum
		if prev.Description != "" && newMeta.Description == "" {
			newMeta.Description = prev.Description
		}
	}
	index[proxyID] = newMeta
	if err := s.saveLocalProxyIndexLocked(index); err != nil {
		return &pb.ImportLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}

	_ = ctx
	return &pb.ImportLocalProxyConfigResponse{
		Success:    true,
		Proxy:      toPBLocalProxy(newMeta),
		ConfigYaml: string(fullContent),
	}, nil
}

func (s *MobileLogicService) SaveLocalProxyConfig(ctx context.Context, req *pb.SaveLocalProxyConfigRequest) (*pb.SaveLocalProxyConfigResponse, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	proxyID := strings.TrimSpace(req.GetProxyId())
	if proxyID == "" {
		return &pb.SaveLocalProxyConfigResponse{Success: false, Error: "proxy_id is required"}, nil
	}
	if strings.TrimSpace(req.GetConfigYaml()) == "" {
		return &pb.SaveLocalProxyConfigResponse{Success: false, Error: "config_yaml is required"}, nil
	}
	if !canWriteLocalProxySyncMetadata(ctx) {
		if req.GetMarkSynced() || req.GetRevisionNum() != 0 || strings.TrimSpace(req.GetConfigHash()) != "" {
			return &pb.SaveLocalProxyConfigResponse{
				Success: false,
				Error:   "mark_synced, revision_num, and config_hash are backend-managed",
			}, nil
		}
	}

	index, err := s.loadLocalProxyIndexLocked()
	if err != nil {
		return &pb.SaveLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}
	proxyID, err = resolveProxyIDFromIndex(index, proxyID, true)
	if err != nil {
		return &pb.SaveLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}
	prev := index[proxyID]

	_, yamlData, err := normalizeProxyContent([]byte(req.GetConfigYaml()))
	if err != nil {
		return &pb.SaveLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}

	existingID, metaName, metaDesc := extractMetaStrings(yamlData)
	if existingID != "" && existingID != proxyID {
		return &pb.SaveLocalProxyConfigResponse{
			Success: false,
			Error:   fmt.Sprintf("proxy_id mismatch: request=%q yaml=%q", proxyID, existingID),
		}, nil
	}

	name := strings.TrimSpace(req.GetName())
	if name == "" {
		name = metaName
	}
	if name == "" && prev != nil {
		name = prev.Name
	}
	if name == "" {
		name = "proxy-" + proxyID[:8]
	}

	description := strings.TrimSpace(req.GetDescription())
	if description == "" {
		description = metaDesc
	}
	if description == "" && prev != nil {
		description = prev.Description
	}

	now := time.Now()
	createdAt := now
	if prev != nil && !prev.CreatedAt.IsZero() {
		createdAt = prev.CreatedAt
	}

	meta := ensureYAMLMeta(yamlData)
	meta["id"] = proxyID
	meta["name"] = name
	meta["created_at"] = createdAt.Format(time.RFC3339)
	meta["updated_at"] = now.Format(time.RFC3339)
	if description != "" {
		meta["description"] = description
	}

	body, err := yaml.Marshal(yamlData)
	if err != nil {
		return &pb.SaveLocalProxyConfigResponse{Success: false, Error: fmt.Sprintf("serialize yaml: %v", err)}, nil
	}
	fullContent := config.WriteWithHeader(config.TypeProxy, config.VersionProxy, body, false)

	if err := os.MkdirAll(s.localProxiesDir(), 0700); err != nil {
		return &pb.SaveLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}
	if err := os.WriteFile(s.localProxyPath(proxyID), fullContent, 0600); err != nil {
		return &pb.SaveLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}

	revisionNum := int64(0)
	if prev != nil {
		revisionNum = prev.RevisionNum
	}
	if req.GetMarkSynced() && req.GetRevisionNum() > 0 && canWriteLocalProxySyncMetadata(ctx) {
		revisionNum = req.GetRevisionNum()
	}

	syncedAt := time.Time{}
	if req.GetMarkSynced() {
		syncedAt = now
	}

	hash := configHash(fullContent)

	newMeta := &localProxyMeta{
		ID:          proxyID,
		Name:        name,
		Description: description,
		CreatedAt:   createdAt,
		UpdatedAt:   now,
		SyncedAt:    syncedAt,
		RevisionNum: revisionNum,
		ConfigHash:  hash,
	}
	index[proxyID] = newMeta

	if err := s.saveLocalProxyIndexLocked(index); err != nil {
		return &pb.SaveLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}

	_ = ctx
	return &pb.SaveLocalProxyConfigResponse{
		Success: true,
		Proxy:   toPBLocalProxy(newMeta),
	}, nil
}

func (s *MobileLogicService) DeleteLocalProxyConfig(ctx context.Context, req *pb.DeleteLocalProxyConfigRequest) (*pb.DeleteLocalProxyConfigResponse, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	index, err := s.loadLocalProxyIndexLocked()
	if err != nil {
		return &pb.DeleteLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}
	proxyID, err := resolveProxyIDFromIndex(index, req.GetProxyId(), false)
	if err != nil {
		return &pb.DeleteLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}

	if err := os.Remove(s.localProxyPath(proxyID)); err != nil && !os.IsNotExist(err) {
		return &pb.DeleteLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}

	delete(index, proxyID)
	if err := s.saveLocalProxyIndexLocked(index); err != nil {
		return &pb.DeleteLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}

	_ = ctx
	return &pb.DeleteLocalProxyConfigResponse{Success: true}, nil
}

func (s *MobileLogicService) ValidateLocalProxyConfig(ctx context.Context, req *pb.ValidateLocalProxyConfigRequest) (*pb.ValidateLocalProxyConfigResponse, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	index, err := s.loadLocalProxyIndexLocked()
	if err != nil {
		return &pb.ValidateLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}
	proxyID, err := resolveProxyIDFromIndex(index, req.GetProxyId(), false)
	if err != nil {
		return &pb.ValidateLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}

	content, err := os.ReadFile(s.localProxyPath(proxyID))
	if err != nil {
		return &pb.ValidateLocalProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}

	resp := &pb.ValidateLocalProxyConfigResponse{Success: true}

	if err := config.VerifyChecksum(content); err != nil {
		resp.ChecksumOk = false
		resp.ChecksumError = err.Error()
	} else {
		resp.ChecksumOk = true
	}

	body, header, err := config.ExtractContent(content)
	if err != nil {
		resp.HeaderOk = false
		resp.HeaderError = err.Error()
		_ = ctx
		return resp, nil
	}
	resp.HeaderOk = true
	resp.HeaderType = string(header.Type)
	resp.HeaderVersion = int32(header.Version)

	var yamlData map[string]interface{}
	if err := yaml.Unmarshal(body, &yamlData); err != nil {
		resp.YamlOk = false
		resp.YamlError = err.Error()
		_ = ctx
		return resp, nil
	}
	resp.YamlOk = true

	_, resp.HasEntryPoints = yamlData["entryPoints"]
	_, resp.HasTcp = yamlData["tcp"]

	_ = ctx
	return resp, nil
}
