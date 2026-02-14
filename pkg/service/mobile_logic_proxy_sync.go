package service

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"strings"
	"time"

	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pb "github.com/ivere27/nitella/pkg/api/local"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/pmezard/go-difflib/difflib"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// ===========================================================================
// Proxy Versioning (Hub sync) — delegate to core.Controller
// ===========================================================================

// PushProxyRevision encrypts and pushes a proxy revision to Hub.
func (s *MobileLogicService) PushProxyRevision(ctx context.Context, req *pb.PushProxyRevisionRequest) (*pb.PushProxyRevisionResponse, error) {
	proxyID, err := s.resolveProxyID(req.ProxyId, true)
	if err != nil {
		return &pb.PushProxyRevisionResponse{Success: false, Error: err.Error()}, nil
	}

	s.mu.RLock()
	if err := s.requireIdentity(); err != nil {
		s.mu.RUnlock()
		return &pb.PushProxyRevisionResponse{Success: false, Error: err.Error()}, nil
	}
	ctrl := s.ctrl
	s.mu.RUnlock()

	// Create proxy config on Hub if first push
	sum := sha256.Sum256([]byte(req.ConfigYaml))
	configHash := hex.EncodeToString(sum[:])
	payload := &pbHub.ProxyRevisionPayload{
		Name:            req.Name,
		Description:     req.Description,
		CommitMessage:   req.CommitMessage,
		ProtocolVersion: "v1",
		ConfigYaml:      req.ConfigYaml,
		ConfigHash:      configHash,
	}

	result, err := ctrl.PushRevision(ctx, proxyID, payload)
	if err != nil && isRemoteProxyMissingError(err) {
		if createErr := ctrl.CreateProxyConfig(ctx, proxyID); createErr == nil {
			result, err = ctrl.PushRevision(ctx, proxyID, payload)
		}
	}
	if err != nil {
		return &pb.PushProxyRevisionResponse{Success: false, Error: err.Error()}, nil
	}

	return &pb.PushProxyRevisionResponse{
		Success:        true,
		RevisionNum:    result.RevisionNum,
		RevisionsKept:  result.RevisionsKept,
		RevisionsLimit: result.RevisionsLimit,
		StorageUsedKb:  result.StorageUsedKb,
		StorageLimitKb: result.StorageLimitKb,
	}, nil
}

// PushLocalProxyRevision pushes a locally-stored proxy config to Hub.
// This keeps CLI/Flutter thin by centralizing orchestration in backend.
func (s *MobileLogicService) PushLocalProxyRevision(ctx context.Context, req *pb.PushLocalProxyRevisionRequest) (*pb.PushLocalProxyRevisionResponse, error) {
	proxyID, err := s.resolveProxyID(req.GetProxyId(), false)
	if err != nil {
		return &pb.PushLocalProxyRevisionResponse{
			Success:              false,
			Error:                err.Error(),
			RemotePushed:         false,
			LocalMetadataUpdated: false,
		}, nil
	}

	localResp, err := s.GetLocalProxyConfig(ctx, &pb.GetLocalProxyConfigRequest{ProxyId: proxyID})
	if err != nil {
		return &pb.PushLocalProxyRevisionResponse{
			Success:              false,
			Error:                err.Error(),
			ProxyId:              proxyID,
			RemotePushed:         false,
			LocalMetadataUpdated: false,
		}, nil
	}
	if !localResp.GetSuccess() || localResp.GetProxy() == nil {
		return &pb.PushLocalProxyRevisionResponse{
			Success:              false,
			Error:                localResp.GetError(),
			ProxyId:              proxyID,
			RemotePushed:         false,
			LocalMetadataUpdated: false,
		}, nil
	}

	msg := strings.TrimSpace(req.GetCommitMessage())
	if msg == "" {
		msg = fmt.Sprintf("Updated %s", time.Now().Format("2006-01-02 15:04"))
	}

	localCanonicalHash := configHash([]byte(localResp.ConfigYaml))

	s.mu.RLock()
	if err := s.requireIdentity(); err != nil {
		s.mu.RUnlock()
		return &pb.PushLocalProxyRevisionResponse{
			Success:              false,
			Error:                err.Error(),
			ProxyId:              proxyID,
			RemotePushed:         false,
			LocalMetadataUpdated: false,
		}, nil
	}
	ctrl := s.ctrl
	s.mu.RUnlock()

	latestRemoteRev, latestErr := ctrl.GetRevision(ctx, proxyID, 0)
	if latestErr != nil {
		if !isRemoteProxyMissingError(latestErr) {
			return &pb.PushLocalProxyRevisionResponse{
				Success:              false,
				Error:                latestErr.Error(),
				ProxyId:              proxyID,
				RemotePushed:         false,
				LocalMetadataUpdated: false,
			}, nil
		}
	} else if latestRemoteRev != nil && latestRemoteRev.Payload != nil {
		remoteHash := strings.TrimSpace(latestRemoteRev.Payload.GetConfigHash())
		if remoteHash == "" {
			remoteHash = configHash([]byte(latestRemoteRev.Payload.GetConfigYaml()))
		}
		if remoteHash == localCanonicalHash {
			saveResp, saveErr := s.SaveLocalProxyConfig(withInternalLocalProxySyncContext(ctx), &pb.SaveLocalProxyConfigRequest{
				ProxyId:     proxyID,
				Name:        localResp.Proxy.Name,
				Description: localResp.Proxy.Description,
				ConfigYaml:  localResp.ConfigYaml,
				RevisionNum: latestRemoteRev.RevisionNum,
				MarkSynced:  true,
			})
			if saveErr != nil {
				return &pb.PushLocalProxyRevisionResponse{
					Success:              true,
					Error:                "no changes to push; failed to update local metadata: " + saveErr.Error(),
					ProxyId:              proxyID,
					RevisionNum:          latestRemoteRev.RevisionNum,
					RemotePushed:         false,
					LocalMetadataUpdated: false,
					LocalMetadataError:   saveErr.Error(),
				}, nil
			}
			if !saveResp.GetSuccess() {
				return &pb.PushLocalProxyRevisionResponse{
					Success:              true,
					Error:                "no changes to push; failed to update local metadata: " + saveResp.GetError(),
					ProxyId:              proxyID,
					RevisionNum:          latestRemoteRev.RevisionNum,
					RemotePushed:         false,
					LocalMetadataUpdated: false,
					LocalMetadataError:   saveResp.GetError(),
				}, nil
			}

			return &pb.PushLocalProxyRevisionResponse{
				Success:              true,
				Error:                "no changes to push",
				ProxyId:              proxyID,
				RevisionNum:          latestRemoteRev.RevisionNum,
				LocalProxy:           saveResp.GetProxy(),
				RemotePushed:         false,
				LocalMetadataUpdated: true,
			}, nil
		}
	}

	pushResp, err := s.PushProxyRevision(ctx, &pb.PushProxyRevisionRequest{
		ProxyId:       proxyID,
		Name:          localResp.Proxy.Name,
		Description:   localResp.Proxy.Description,
		CommitMessage: msg,
		ConfigYaml:    localResp.ConfigYaml,
		ConfigHash:    localResp.Proxy.ConfigHash,
	})
	if err != nil {
		return &pb.PushLocalProxyRevisionResponse{
			Success:              false,
			Error:                err.Error(),
			ProxyId:              proxyID,
			RemotePushed:         false,
			LocalMetadataUpdated: false,
		}, nil
	}
	if !pushResp.GetSuccess() {
		return &pb.PushLocalProxyRevisionResponse{
			Success:              false,
			Error:                pushResp.GetError(),
			ProxyId:              proxyID,
			RemotePushed:         false,
			LocalMetadataUpdated: false,
		}, nil
	}

	saveResp, err := s.SaveLocalProxyConfig(withInternalLocalProxySyncContext(ctx), &pb.SaveLocalProxyConfigRequest{
		ProxyId:     proxyID,
		Name:        localResp.Proxy.Name,
		Description: localResp.Proxy.Description,
		ConfigYaml:  localResp.ConfigYaml,
		RevisionNum: pushResp.RevisionNum,
		MarkSynced:  true,
	})
	if err != nil {
		return &pb.PushLocalProxyRevisionResponse{
			Success:              true,
			ProxyId:              proxyID,
			RevisionNum:          pushResp.RevisionNum,
			RevisionsKept:        pushResp.RevisionsKept,
			RevisionsLimit:       pushResp.RevisionsLimit,
			StorageUsedKb:        pushResp.StorageUsedKb,
			StorageLimitKb:       pushResp.StorageLimitKb,
			Error:                "pushed but failed to update local metadata: " + err.Error(),
			RemotePushed:         true,
			LocalMetadataUpdated: false,
			LocalMetadataError:   err.Error(),
		}, nil
	}
	if !saveResp.GetSuccess() {
		return &pb.PushLocalProxyRevisionResponse{
			Success:              true,
			ProxyId:              proxyID,
			RevisionNum:          pushResp.RevisionNum,
			RevisionsKept:        pushResp.RevisionsKept,
			RevisionsLimit:       pushResp.RevisionsLimit,
			StorageUsedKb:        pushResp.StorageUsedKb,
			StorageLimitKb:       pushResp.StorageLimitKb,
			Error:                "pushed but failed to update local metadata: " + saveResp.GetError(),
			RemotePushed:         true,
			LocalMetadataUpdated: false,
			LocalMetadataError:   saveResp.GetError(),
		}, nil
	}

	return &pb.PushLocalProxyRevisionResponse{
		Success:              true,
		ProxyId:              proxyID,
		RevisionNum:          pushResp.RevisionNum,
		RevisionsKept:        pushResp.RevisionsKept,
		RevisionsLimit:       pushResp.RevisionsLimit,
		StorageUsedKb:        pushResp.StorageUsedKb,
		StorageLimitKb:       pushResp.StorageLimitKb,
		LocalProxy:           saveResp.Proxy,
		RemotePushed:         true,
		LocalMetadataUpdated: true,
	}, nil
}

// PullProxyRevision fetches and decrypts a proxy revision from Hub.
func (s *MobileLogicService) PullProxyRevision(ctx context.Context, req *pb.PullProxyRevisionRequest) (*pb.PullProxyRevisionResponse, error) {
	proxyID, err := s.resolveProxyID(req.ProxyId, true)
	if err != nil {
		return &pb.PullProxyRevisionResponse{Success: false, Error: err.Error()}, nil
	}

	s.mu.RLock()
	if err := s.requireIdentity(); err != nil {
		s.mu.RUnlock()
		return &pb.PullProxyRevisionResponse{Success: false, Error: err.Error()}, nil
	}
	ctrl := s.ctrl
	s.mu.RUnlock()

	rev, err := ctrl.GetRevision(ctx, proxyID, req.RevisionNum)
	if err != nil {
		return &pb.PullProxyRevisionResponse{Success: false, Error: err.Error()}, nil
	}

	sum := sha256.Sum256([]byte(rev.Payload.ConfigYaml))
	canonicalHash := hex.EncodeToString(sum[:])

	resp := &pb.PullProxyRevisionResponse{
		Success:       true,
		RevisionNum:   rev.RevisionNum,
		Name:          rev.Payload.Name,
		Description:   rev.Payload.Description,
		CommitMessage: rev.Payload.CommitMessage,
		ConfigYaml:    rev.Payload.ConfigYaml,
		ConfigHash:    canonicalHash,
		SizeBytes:     rev.SizeBytes,
	}

	if req.GetStoreLocal() {
		saveResp, saveErr := s.SaveLocalProxyConfig(withInternalLocalProxySyncContext(ctx), &pb.SaveLocalProxyConfigRequest{
			ProxyId:     proxyID,
			Name:        rev.Payload.Name,
			Description: rev.Payload.Description,
			ConfigYaml:  rev.Payload.ConfigYaml,
			RevisionNum: rev.RevisionNum,
			MarkSynced:  true,
		})
		if saveErr != nil {
			return &pb.PullProxyRevisionResponse{Success: false, Error: saveErr.Error()}, nil
		}
		if !saveResp.GetSuccess() {
			return &pb.PullProxyRevisionResponse{Success: false, Error: saveResp.GetError()}, nil
		}
		resp.LocalProxy = saveResp.GetProxy()
	}

	return resp, nil
}

// DiffProxyRevisions computes unified diffs in backend for thin clients.
func (s *MobileLogicService) DiffProxyRevisions(ctx context.Context, req *pb.DiffProxyRevisionsRequest) (*pb.DiffProxyRevisionsResponse, error) {
	proxyID, err := s.resolveProxyID(req.GetProxyId(), true)
	if err != nil {
		return &pb.DiffProxyRevisionsResponse{Success: false, Error: err.Error()}, nil
	}

	if req.GetLocalVsLatest() {
		localResp, err := s.GetLocalProxyConfig(ctx, &pb.GetLocalProxyConfigRequest{ProxyId: proxyID})
		if err != nil {
			return &pb.DiffProxyRevisionsResponse{Success: false, Error: err.Error()}, nil
		}
		if !localResp.GetSuccess() {
			return &pb.DiffProxyRevisionsResponse{Success: false, Error: localResp.GetError()}, nil
		}

		remoteResp, err := s.PullProxyRevision(ctx, &pb.PullProxyRevisionRequest{
			ProxyId:     proxyID,
			RevisionNum: 0,
		})
		if err != nil {
			return &pb.DiffProxyRevisionsResponse{Success: false, Error: err.Error()}, nil
		}
		if !remoteResp.GetSuccess() {
			return &pb.DiffProxyRevisionsResponse{Success: false, Error: remoteResp.GetError()}, nil
		}

		diff, hasDiff := buildUnifiedDiff("local", fmt.Sprintf("remote (revision %d)", remoteResp.RevisionNum), localResp.ConfigYaml, remoteResp.ConfigYaml)
		return &pb.DiffProxyRevisionsResponse{
			Success:        true,
			LeftLabel:      "local",
			RightLabel:     fmt.Sprintf("remote (revision %d)", remoteResp.RevisionNum),
			UnifiedDiff:    diff,
			HasDifferences: hasDiff,
		}, nil
	}

	leftRev := req.GetRevisionNumA()
	rightRev := req.GetRevisionNumB()

	leftResp, err := s.PullProxyRevision(ctx, &pb.PullProxyRevisionRequest{
		ProxyId:     proxyID,
		RevisionNum: leftRev,
	})
	if err != nil {
		return &pb.DiffProxyRevisionsResponse{Success: false, Error: err.Error()}, nil
	}
	if !leftResp.GetSuccess() {
		return &pb.DiffProxyRevisionsResponse{Success: false, Error: leftResp.GetError()}, nil
	}

	rightResp, err := s.PullProxyRevision(ctx, &pb.PullProxyRevisionRequest{
		ProxyId:     proxyID,
		RevisionNum: rightRev,
	})
	if err != nil {
		return &pb.DiffProxyRevisionsResponse{Success: false, Error: err.Error()}, nil
	}
	if !rightResp.GetSuccess() {
		return &pb.DiffProxyRevisionsResponse{Success: false, Error: rightResp.GetError()}, nil
	}

	leftLabel := fmt.Sprintf("revision %d", leftResp.RevisionNum)
	rightLabel := fmt.Sprintf("revision %d", rightResp.RevisionNum)
	diff, hasDiff := buildUnifiedDiff(leftLabel, rightLabel, leftResp.ConfigYaml, rightResp.ConfigYaml)
	return &pb.DiffProxyRevisionsResponse{
		Success:        true,
		LeftLabel:      leftLabel,
		RightLabel:     rightLabel,
		UnifiedDiff:    diff,
		HasDifferences: hasDiff,
	}, nil
}

// ListProxyRevisions lists revision metadata for a proxy on Hub.
func (s *MobileLogicService) ListProxyRevisions(ctx context.Context, req *pb.ListProxyRevisionsRequest) (*pb.ListProxyRevisionsResponse, error) {
	proxyID, err := s.resolveProxyID(req.ProxyId, true)
	if err != nil {
		return nil, err
	}

	s.mu.RLock()
	ctrl := s.ctrl
	s.mu.RUnlock()

	revisions, err := ctrl.ListRevisions(ctx, proxyID)
	if err != nil {
		return nil, err
	}

	result := make([]*pb.ProxyRevisionMeta, len(revisions))
	for i, r := range revisions {
		result[i] = &pb.ProxyRevisionMeta{
			RevisionNum: r.RevisionNum,
			SizeBytes:   r.SizeBytes,
			CreatedAt:   r.CreatedAt,
		}
	}

	return &pb.ListProxyRevisionsResponse{Revisions: result}, nil
}

func isRemoteProxyMissingError(err error) bool {
	if err == nil {
		return false
	}
	msg := strings.ToLower(strings.TrimSpace(err.Error()))
	if msg == "" {
		return false
	}
	return strings.Contains(msg, "not found") ||
		strings.Contains(msg, "does not exist") ||
		strings.Contains(msg, "missing proxy")
}

func buildUnifiedDiff(leftLabel, rightLabel, leftContent, rightContent string) (string, bool) {
	if leftContent == rightContent {
		return "", false
	}
	ud := difflib.UnifiedDiff{
		A:        difflib.SplitLines(leftContent),
		B:        difflib.SplitLines(rightContent),
		FromFile: leftLabel,
		ToFile:   rightLabel,
		Context:  3,
	}
	text, err := difflib.GetUnifiedDiffString(ud)
	if err != nil {
		// Fallback to a minimal but deterministic representation.
		return fmt.Sprintf("--- %s\n+++ %s\n\n(diff generation failed: %v)\n", leftLabel, rightLabel, err), true
	}
	return text, true
}

// FlushProxyRevisions deletes old revisions from Hub.
func (s *MobileLogicService) FlushProxyRevisions(ctx context.Context, req *pb.FlushProxyRevisionsRequest) (*pb.FlushProxyRevisionsResponse, error) {
	proxyID, err := s.resolveProxyID(req.ProxyId, true)
	if err != nil {
		return &pb.FlushProxyRevisionsResponse{Success: false, Error: err.Error()}, nil
	}

	s.mu.RLock()
	ctrl := s.ctrl
	s.mu.RUnlock()

	result, err := ctrl.FlushRevisions(ctx, proxyID, req.KeepCount)
	if err != nil {
		return &pb.FlushProxyRevisionsResponse{Success: false, Error: err.Error()}, nil
	}

	return &pb.FlushProxyRevisionsResponse{
		Success:        true,
		DeletedCount:   result.DeletedCount,
		RemainingCount: result.RemainingCount,
	}, nil
}

// ListProxyConfigs lists proxy configs stored on Hub.
func (s *MobileLogicService) ListProxyConfigs(ctx context.Context, req *pb.ListProxyConfigsRequest) (*pb.ListProxyConfigsResponse, error) {
	s.mu.RLock()
	ctrl := s.ctrl
	s.mu.RUnlock()

	proxies, err := ctrl.ListProxyConfigs(ctx)
	if err != nil {
		return nil, err
	}

	result := make([]*pb.ProxyConfigInfo, len(proxies))
	for i, p := range proxies {
		var updatedAt *timestamppb.Timestamp
		if p.UpdatedAt != nil {
			updatedAt = p.UpdatedAt
		}
		result[i] = &pb.ProxyConfigInfo{
			ProxyId:        p.ProxyId,
			LatestRevision: p.LatestRevision,
			TotalSizeBytes: p.TotalSizeBytes,
			UpdatedAt:      updatedAt,
		}
	}

	return &pb.ListProxyConfigsResponse{Proxies: result}, nil
}

// CreateProxyConfig creates a proxy config entry on Hub.
func (s *MobileLogicService) CreateProxyConfig(ctx context.Context, req *pb.CreateProxyConfigRequest) (*pb.CreateProxyConfigResponse, error) {
	s.mu.RLock()
	ctrl := s.ctrl
	s.mu.RUnlock()

	if err := ctrl.CreateProxyConfig(ctx, req.ProxyId); err != nil {
		return &pb.CreateProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}

	return &pb.CreateProxyConfigResponse{Success: true}, nil
}

// DeleteProxyConfig deletes a proxy config from Hub.
func (s *MobileLogicService) DeleteProxyConfig(ctx context.Context, req *pb.DeleteProxyConfigRequest) (*pb.DeleteProxyConfigResponse, error) {
	proxyID, err := s.resolveProxyID(req.ProxyId, true)
	if err != nil {
		return &pb.DeleteProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}

	s.mu.RLock()
	ctrl := s.ctrl
	s.mu.RUnlock()

	if err := ctrl.DeleteProxyConfig(ctx, proxyID); err != nil {
		return &pb.DeleteProxyConfigResponse{Success: false, Error: err.Error()}, nil
	}

	return &pb.DeleteProxyConfigResponse{Success: true}, nil
}

// ===========================================================================
// Proxy Deployment (to nodes via E2E commands)
// ===========================================================================

// ApplyProxyToNode applies a proxy config to a node via E2E encrypted command.
func (s *MobileLogicService) ApplyProxyToNode(ctx context.Context, req *pb.ApplyProxyToNodeRequest) (*pb.ApplyProxyToNodeResponse, error) {
	proxyID, err := s.resolveProxyID(req.ProxyId, true)
	if err != nil {
		return &pb.ApplyProxyToNodeResponse{Success: false, Error: err.Error()}, nil
	}

	configYAML := req.ConfigYaml
	revisionNum := req.RevisionNum

	// Thin clients can omit config YAML and let backend resolve the requested revision.
	if strings.TrimSpace(configYAML) == "" {
		s.mu.RLock()
		if err := s.requireIdentity(); err != nil {
			s.mu.RUnlock()
			return &pb.ApplyProxyToNodeResponse{Success: false, Error: err.Error()}, nil
		}
		ctrl := s.ctrl
		s.mu.RUnlock()

		rev, err := ctrl.GetRevision(ctx, proxyID, req.RevisionNum)
		if err != nil {
			return &pb.ApplyProxyToNodeResponse{Success: false, Error: fmt.Sprintf("resolve revision: %v", err)}, nil
		}

		configYAML = rev.Payload.ConfigYaml
		revisionNum = rev.RevisionNum
	}

	if strings.TrimSpace(configYAML) == "" {
		return &pb.ApplyProxyToNodeResponse{Success: false, Error: "config_yaml is required"}, nil
	}

	sum := sha256.Sum256([]byte(configYAML))
	configHash := hex.EncodeToString(sum[:])

	applyReq := &pbProxy.ApplyProxyRequest{
		ProxyId:     proxyID,
		RevisionNum: revisionNum,
		ConfigYaml:  configYAML,
		ConfigHash:  configHash,
	}

	payload, err := proto.Marshal(applyReq)
	if err != nil {
		return &pb.ApplyProxyToNodeResponse{Success: false, Error: fmt.Sprintf("marshal: %v", err)}, nil
	}

	result, err := s.sendCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_APPLY_PROXY, payload)
	if err != nil {
		return &pb.ApplyProxyToNodeResponse{Success: false, Error: err.Error()}, nil
	}
	if result.Status != "OK" {
		return &pb.ApplyProxyToNodeResponse{Success: false, Error: result.ErrorMessage}, nil
	}

	var resp pbProxy.ApplyProxyResponse
	if err := proto.Unmarshal(result.ResponsePayload, &resp); err != nil {
		return &pb.ApplyProxyToNodeResponse{Success: false, Error: fmt.Sprintf("unmarshal: %v", err)}, nil
	}

	return &pb.ApplyProxyToNodeResponse{
		Success: resp.Success,
		Error:   resp.ErrorMessage,
	}, nil
}

// UnapplyProxyFromNode removes a proxy from a node via E2E encrypted command.
func (s *MobileLogicService) UnapplyProxyFromNode(ctx context.Context, req *pb.UnapplyProxyFromNodeRequest) (*pb.UnapplyProxyFromNodeResponse, error) {
	proxyID, err := s.resolveProxyID(req.ProxyId, true)
	if err != nil {
		return &pb.UnapplyProxyFromNodeResponse{Success: false, Error: err.Error()}, nil
	}

	unapplyReq := &pbProxy.DeleteProxyRequest{
		ProxyId: proxyID,
	}

	payload, err := proto.Marshal(unapplyReq)
	if err != nil {
		return &pb.UnapplyProxyFromNodeResponse{Success: false, Error: fmt.Sprintf("marshal: %v", err)}, nil
	}

	result, err := s.sendCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_UNAPPLY_PROXY, payload)
	if err != nil {
		return &pb.UnapplyProxyFromNodeResponse{Success: false, Error: err.Error()}, nil
	}
	if result.Status != "OK" {
		return &pb.UnapplyProxyFromNodeResponse{Success: false, Error: result.ErrorMessage}, nil
	}

	return &pb.UnapplyProxyFromNodeResponse{Success: true}, nil
}

// GetAppliedProxies gets proxies applied on a node via E2E encrypted command.
func (s *MobileLogicService) GetAppliedProxies(ctx context.Context, req *pb.GetAppliedProxiesRequest) (*pb.GetAppliedProxiesResponse, error) {
	result, err := s.sendCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_GET_APPLIED, []byte{})
	if err != nil {
		return nil, err
	}
	if result.Status != "OK" {
		return nil, fmt.Errorf("%s", result.ErrorMessage)
	}

	var resp pbProxy.GetAppliedProxiesResponse
	if err := proto.Unmarshal(result.ResponsePayload, &resp); err != nil {
		return nil, fmt.Errorf("unmarshal: %v", err)
	}

	proxies := make([]*pb.AppliedProxy, len(resp.Proxies))
	for i, p := range resp.Proxies {
		proxies[i] = &pb.AppliedProxy{
			ProxyId:     p.ProxyId,
			RevisionNum: p.RevisionNum,
			AppliedAt:   p.AppliedAt,
			Status:      p.Status,
		}
	}

	return &pb.GetAppliedProxiesResponse{Proxies: proxies}, nil
}
