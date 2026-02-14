package server

import (
	"context"
	"crypto/ed25519"
	"crypto/subtle"
	"fmt"
	"net"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	hubpb "github.com/ivere27/nitella/pkg/api/hub"
	pb "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/config"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/ivere27/nitella/pkg/log"
	"github.com/ivere27/nitella/pkg/node"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/peer"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/timestamppb"
)

const (
	// replayWindowSeconds is the timestamp tolerance for replay protection.
	replayWindowSeconds = 60
	// replayCacheExpirySeconds is how long command IDs are cached (5 minutes).
	replayCacheExpirySeconds = 300
	// maxReplayCacheSize is the maximum number of entries in the replay cache.
	maxReplayCacheSize = 10000
)

// ProxyAdminServer implements ProxyControlServiceServer for admin API.
type ProxyAdminServer struct {
	pb.UnimplementedProxyControlServiceServer
	pm          *node.ProxyManager
	nodePrivKey ed25519.PrivateKey // Node's private key for E2E encryption
	nodeID      string             // Node fingerprint for sender identification

	// Replay protection
	cmdIDCache      sync.Map
	cmdIDCacheCount int64 // atomic counter
	cacheCleanupMu  sync.Once
	stopCh          chan struct{}
}

// NewProxyAdminServer creates a new admin server.
func NewProxyAdminServer(pm *node.ProxyManager, nodePrivKey ed25519.PrivateKey, nodeID string) *ProxyAdminServer {
	return &ProxyAdminServer{
		pm:          pm,
		nodePrivKey: nodePrivKey,
		nodeID:      nodeID,
		stopCh:      make(chan struct{}),
	}
}

// Stop stops background goroutines.
func (s *ProxyAdminServer) Stop() {
	select {
	case <-s.stopCh:
	default:
		close(s.stopCh)
	}
}

// RegisterProxyAdmin registers the ProxyControlService with a gRPC server.
func RegisterProxyAdmin(gs *grpc.Server, srv *ProxyAdminServer) {
	pb.RegisterProxyControlServiceServer(gs, srv)
}

// ============================================================================
// SendCommand — unified E2E encrypted command (same envelope as Hub relay)
// ============================================================================

func (s *ProxyAdminServer) SendCommand(ctx context.Context, req *pb.SendCommandRequest) (*pb.SendCommandResponse, error) {
	// 1. Validate viewer public key
	viewerPubKey := ed25519.PublicKey(req.GetViewerPubkey())
	if len(viewerPubKey) != ed25519.PublicKeySize {
		return &pb.SendCommandResponse{
			Status:       "ERROR",
			ErrorMessage: "viewer_pubkey must be 32 bytes Ed25519",
		}, nil
	}

	enc := req.GetEncrypted()
	if enc == nil {
		return &pb.SendCommandResponse{
			Status:       "ERROR",
			ErrorMessage: "encrypted payload is required",
		}, nil
	}

	// 2. Decrypt EncryptedPayload with node's private key
	cryptoPayload := &nitellacrypto.EncryptedPayload{
		EphemeralPubKey:   enc.EphemeralPubkey,
		Nonce:             enc.Nonce,
		Ciphertext:        enc.Ciphertext,
		SenderFingerprint: enc.SenderFingerprint,
		Signature:         enc.Signature,
	}

	plaintext, err := nitellacrypto.Decrypt(cryptoPayload, s.nodePrivKey)
	if err != nil {
		return &pb.SendCommandResponse{
			Status:       "ERROR",
			ErrorMessage: "decryption failed",
		}, nil
	}

	// 3. Unmarshal SecureCommandPayload
	var securePayload common.SecureCommandPayload
	if err := proto.Unmarshal(plaintext, &securePayload); err != nil {
		return &pb.SendCommandResponse{
			Status:       "ERROR",
			ErrorMessage: "invalid secure payload",
		}, nil
	}

	// 4. Check timestamp (replay window)
	now := time.Now().Unix()
	if securePayload.Timestamp < now-replayWindowSeconds || securePayload.Timestamp > now+replayWindowSeconds {
		log.Printf("[SECURITY] Replay detected: timestamp %d out of range (now: %d)", securePayload.Timestamp, now)
		return &pb.SendCommandResponse{
			Status:       "ERROR",
			ErrorMessage: "timestamp out of range",
		}, nil
	}

	// 5. Check request ID (replay cache)
	s.cacheCleanupMu.Do(func() {
		go s.replayCacheCleanupLoop()
	})
	if _, loaded := s.cmdIDCache.LoadOrStore(securePayload.RequestId, now); loaded {
		log.Printf("[SECURITY] Replay detected: request ID %s already processed", securePayload.RequestId)
		return &pb.SendCommandResponse{
			Status:       "ERROR",
			ErrorMessage: "duplicate request",
		}, nil
	}
	if atomic.AddInt64(&s.cmdIDCacheCount, 1) > maxReplayCacheSize {
		// Evict expired entries immediately when cache is full
		s.evictExpiredCacheEntries(now)
	}

	// 6. Unmarshal EncryptedCommandPayload
	var cmdPayload hubpb.EncryptedCommandPayload
	if err := proto.Unmarshal(securePayload.Data, &cmdPayload); err != nil {
		return &pb.SendCommandResponse{
			Status:       "ERROR",
			ErrorMessage: "invalid command payload",
		}, nil
	}

	// 7. Dispatch command
	respBytes, err := s.dispatchCommand(ctx, cmdPayload.Type, cmdPayload.Payload)
	cmdStatus := "OK"
	errMsg := ""
	if err != nil {
		cmdStatus = "ERROR"
		errMsg = err.Error()
	}

	// 8. Build response: CommandResult -> encrypt with viewer's pubkey
	result := &hubpb.CommandResult{
		Status:          cmdStatus,
		ErrorMessage:    errMsg,
		ResponsePayload: respBytes,
	}
	resultBytes, err := proto.Marshal(result)
	if err != nil {
		return &pb.SendCommandResponse{
			Status:       "ERROR",
			ErrorMessage: "failed to marshal response",
		}, nil
	}

	encResp, err := nitellacrypto.EncryptWithSignature(resultBytes, viewerPubKey, s.nodePrivKey, s.nodeID)
	if err != nil {
		return &pb.SendCommandResponse{
			Status:       "ERROR",
			ErrorMessage: "failed to encrypt response",
		}, nil
	}

	return &pb.SendCommandResponse{
		Encrypted: &common.EncryptedPayload{
			EphemeralPubkey:   encResp.EphemeralPubKey,
			Nonce:             encResp.Nonce,
			Ciphertext:        encResp.Ciphertext,
			SenderFingerprint: encResp.SenderFingerprint,
			Signature:         encResp.Signature,
		},
		Status: cmdStatus,
	}, nil
}

// replayCacheCleanupLoop periodically removes old entries from the replay cache.
func (s *ProxyAdminServer) evictExpiredCacheEntries(now int64) {
	s.cmdIDCache.Range(func(key, value interface{}) bool {
		if ts, ok := value.(int64); ok {
			if now-ts > replayCacheExpirySeconds {
				s.cmdIDCache.Delete(key)
				atomic.AddInt64(&s.cmdIDCacheCount, -1)
			}
		}
		return true
	})
}

func (s *ProxyAdminServer) replayCacheCleanupLoop() {
	ticker := time.NewTicker(time.Minute)
	defer ticker.Stop()

	for {
		select {
		case <-s.stopCh:
			return
		case <-ticker.C:
			s.evictExpiredCacheEntries(time.Now().Unix())
		}
	}
}

// ============================================================================
// Command Dispatcher
// ============================================================================

func (s *ProxyAdminServer) dispatchCommand(ctx context.Context, cmdType hubpb.CommandType, payload []byte) ([]byte, error) {
	switch cmdType {
	// --- Existing Hub command types ---
	case hubpb.CommandType_COMMAND_TYPE_STATUS:
		return s.cmdStatus()
	case hubpb.CommandType_COMMAND_TYPE_LIST_PROXIES:
		return s.cmdListProxies()
	case hubpb.CommandType_COMMAND_TYPE_LIST_RULES:
		return s.cmdListRules(payload)
	case hubpb.CommandType_COMMAND_TYPE_ADD_RULE:
		return s.cmdAddRule(payload)
	case hubpb.CommandType_COMMAND_TYPE_REMOVE_RULE:
		return s.cmdRemoveRule(payload)
	case hubpb.CommandType_COMMAND_TYPE_GET_ACTIVE_CONNECTIONS:
		return s.cmdGetActiveConnections(payload)
	case hubpb.CommandType_COMMAND_TYPE_CLOSE_CONNECTION:
		return s.cmdCloseConnection(payload)
	case hubpb.CommandType_COMMAND_TYPE_CLOSE_ALL_CONNECTIONS:
		return s.cmdCloseAllConnections(payload)
	case hubpb.CommandType_COMMAND_TYPE_GET_METRICS:
		return s.cmdGetMetrics()
	case hubpb.CommandType_COMMAND_TYPE_STATS_CONTROL:
		return s.cmdGetMetrics()
	case hubpb.CommandType_COMMAND_TYPE_RESOLVE_APPROVAL:
		return s.cmdResolveApproval(payload)

	// --- Proxy lifecycle ---
	case hubpb.CommandType_COMMAND_TYPE_CREATE_PROXY:
		return s.cmdCreateProxy(payload)
	case hubpb.CommandType_COMMAND_TYPE_DELETE_PROXY:
		return s.cmdDeleteProxy(payload)
	case hubpb.CommandType_COMMAND_TYPE_ENABLE_PROXY:
		return s.cmdEnableProxy(payload)
	case hubpb.CommandType_COMMAND_TYPE_DISABLE_PROXY:
		return s.cmdDisableProxy(payload)
	case hubpb.CommandType_COMMAND_TYPE_UPDATE_PROXY:
		return s.cmdUpdateProxy(payload)
	case hubpb.CommandType_COMMAND_TYPE_RESTART_LISTENERS:
		return s.cmdRestartListeners()
	case hubpb.CommandType_COMMAND_TYPE_RELOAD_RULES:
		return s.cmdReloadRules(payload)

	// --- Quick actions ---
	case hubpb.CommandType_COMMAND_TYPE_BLOCK_IP:
		return s.cmdBlockIP(payload)
	case hubpb.CommandType_COMMAND_TYPE_ALLOW_IP:
		return s.cmdAllowIP(payload)
	case hubpb.CommandType_COMMAND_TYPE_LIST_GLOBAL_RULES:
		return s.cmdListGlobalRules()
	case hubpb.CommandType_COMMAND_TYPE_REMOVE_GLOBAL_RULE:
		return s.cmdRemoveGlobalRule(payload)

	// --- GeoIP ---
	case hubpb.CommandType_COMMAND_TYPE_CONFIGURE_GEOIP:
		return s.cmdConfigureGeoIP(payload)
	case hubpb.CommandType_COMMAND_TYPE_GET_GEOIP_STATUS:
		return s.cmdGetGeoIPStatus()
	case hubpb.CommandType_COMMAND_TYPE_LOOKUP_IP:
		return s.cmdLookupIP(payload)

	// --- Approval management ---
	case hubpb.CommandType_COMMAND_TYPE_LIST_ACTIVE_APPROVALS:
		return s.cmdListActiveApprovals(payload)
	case hubpb.CommandType_COMMAND_TYPE_CANCEL_APPROVAL:
		return s.cmdCancelApproval(payload)

	default:
		return nil, fmt.Errorf("unknown command type: %v", cmdType)
	}
}

// ============================================================================
// Command Handlers (internal — called by dispatchCommand)
// ============================================================================

func (s *ProxyAdminServer) cmdStatus() ([]byte, error) {
	statuses := s.pm.GetAllStatuses()
	var totalConns, activeConns, bytesIn, bytesOut int64
	for _, st := range statuses {
		totalConns += st.TotalConnections
		activeConns += st.ActiveConnections
		bytesIn += st.BytesIn
		bytesOut += st.BytesOut
	}
	resp := &pb.StatsSummaryResponse{
		TotalConnections:  totalConns,
		TotalBytesIn:      bytesIn,
		TotalBytesOut:     bytesOut,
		ActiveConnections: activeConns,
		ProxyCount:        int32(len(statuses)),
		Timestamp:         timestamppb.Now(),
	}
	return proto.Marshal(resp)
}

func (s *ProxyAdminServer) cmdListProxies() ([]byte, error) {
	statuses := s.pm.GetAllStatuses()
	return proto.Marshal(&pb.ListProxiesResponse{Proxies: statuses})
}

func (s *ProxyAdminServer) cmdListRules(payload []byte) ([]byte, error) {
	var req pb.ListRulesRequest
	if err := proto.Unmarshal(payload, &req); err != nil {
		return nil, err
	}
	rules, err := s.pm.GetRules(req.ProxyId)
	if err != nil {
		return nil, err
	}
	return proto.Marshal(&pb.ListRulesResponse{Rules: rules})
}

func (s *ProxyAdminServer) cmdAddRule(payload []byte) ([]byte, error) {
	var req pb.AddRuleRequest
	if err := proto.Unmarshal(payload, &req); err != nil {
		return nil, err
	}
	resp, err := s.pm.AddRule(&req)
	if err != nil {
		return nil, err
	}
	return proto.Marshal(resp)
}

func (s *ProxyAdminServer) cmdRemoveRule(payload []byte) ([]byte, error) {
	var req pb.RemoveRuleRequest
	if err := proto.Unmarshal(payload, &req); err != nil {
		return nil, err
	}
	return nil, s.pm.RemoveRule(&req)
}

func (s *ProxyAdminServer) cmdGetActiveConnections(payload []byte) ([]byte, error) {
	var req pb.GetActiveConnectionsRequest
	if err := proto.Unmarshal(payload, &req); err != nil {
		return nil, err
	}
	conns := s.pm.GetActiveConnections(req.ProxyId)
	activeConns := make([]*pb.ActiveConnection, 0, len(conns))
	for _, c := range conns {
		var bytesIn, bytesOut int64
		if c.BytesIn != nil {
			bytesIn = *c.BytesIn
		}
		if c.BytesOut != nil {
			bytesOut = *c.BytesOut
		}
		activeConns = append(activeConns, &pb.ActiveConnection{
			Id:         c.ID,
			SourceIp:   c.SourceIP,
			SourcePort: int32(c.SourcePort),
			DestAddr:   c.DestAddr,
			StartTime:  timestamppb.New(c.StartTime),
			BytesIn:    bytesIn,
			BytesOut:   bytesOut,
		})
	}
	return proto.Marshal(&pb.GetActiveConnectionsResponse{Connections: activeConns})
}

func (s *ProxyAdminServer) cmdCloseConnection(payload []byte) ([]byte, error) {
	var req pb.CloseConnectionRequest
	if err := proto.Unmarshal(payload, &req); err != nil {
		return nil, err
	}
	if req.ConnId == "" {
		return nil, fmt.Errorf("conn_id is required")
	}
	if err := s.pm.CloseConnection(req.ProxyId, req.ConnId); err != nil {
		return nil, err
	}
	return proto.Marshal(&pb.CloseConnectionResponse{Success: true})
}

func (s *ProxyAdminServer) cmdCloseAllConnections(payload []byte) ([]byte, error) {
	var req pb.CloseAllConnectionsRequest
	if err := proto.Unmarshal(payload, &req); err != nil {
		return nil, err
	}
	if err := s.pm.CloseAllConnections(req.ProxyId); err != nil {
		return nil, err
	}
	return proto.Marshal(&pb.CloseAllConnectionsResponse{Success: true})
}

func (s *ProxyAdminServer) cmdGetMetrics() ([]byte, error) {
	statuses := s.pm.GetAllStatuses()
	var totalConns, activeConns, bytesIn, bytesOut int64
	for _, st := range statuses {
		totalConns += st.TotalConnections
		activeConns += st.ActiveConnections
		bytesIn += st.BytesIn
		bytesOut += st.BytesOut
	}
	resp := &pb.StatsSummaryResponse{
		TotalConnections:  totalConns,
		TotalBytesIn:      bytesIn,
		TotalBytesOut:     bytesOut,
		ActiveConnections: activeConns,
		ProxyCount:        int32(len(statuses)),
		Timestamp:         timestamppb.Now(),
	}
	return proto.Marshal(resp)
}

func (s *ProxyAdminServer) cmdCreateProxy(payload []byte) ([]byte, error) {
	var req pb.CreateProxyRequest
	if err := proto.Unmarshal(payload, &req); err != nil {
		return nil, err
	}
	resp, err := s.pm.CreateProxy(&req)
	if err != nil {
		return nil, err
	}
	return proto.Marshal(resp)
}

func (s *ProxyAdminServer) cmdDeleteProxy(payload []byte) ([]byte, error) {
	var req pb.DeleteProxyRequest
	if err := proto.Unmarshal(payload, &req); err != nil {
		return nil, err
	}
	_, err := s.pm.DisableProxy(req.ProxyId)
	if err != nil {
		return proto.Marshal(&pb.DeleteProxyResponse{Success: false, ErrorMessage: err.Error()})
	}
	return proto.Marshal(&pb.DeleteProxyResponse{Success: true})
}

func (s *ProxyAdminServer) cmdEnableProxy(payload []byte) ([]byte, error) {
	var req pb.EnableProxyRequest
	if err := proto.Unmarshal(payload, &req); err != nil {
		return nil, err
	}
	resp, err := s.pm.EnableProxy(req.ProxyId)
	if err != nil {
		return nil, err
	}
	return proto.Marshal(resp)
}

func (s *ProxyAdminServer) cmdDisableProxy(payload []byte) ([]byte, error) {
	var req pb.DisableProxyRequest
	if err := proto.Unmarshal(payload, &req); err != nil {
		return nil, err
	}
	resp, err := s.pm.DisableProxy(req.ProxyId)
	if err != nil {
		return nil, err
	}
	return proto.Marshal(resp)
}

func (s *ProxyAdminServer) cmdUpdateProxy(payload []byte) ([]byte, error) {
	var req pb.UpdateProxyRequest
	if err := proto.Unmarshal(payload, &req); err != nil {
		return nil, err
	}
	resp, err := s.pm.UpdateProxy(&req)
	if err != nil {
		return nil, err
	}
	return proto.Marshal(resp)
}

func (s *ProxyAdminServer) cmdRestartListeners() ([]byte, error) {
	resp, err := s.pm.RestartListeners()
	if err != nil {
		return nil, err
	}
	return proto.Marshal(resp)
}

func (s *ProxyAdminServer) cmdReloadRules(payload []byte) ([]byte, error) {
	var req pb.ReloadRulesRequest
	if err := proto.Unmarshal(payload, &req); err != nil {
		return nil, err
	}
	statuses := s.pm.GetAllStatuses()
	totalLoaded := int32(0)
	for _, st := range statuses {
		resp, err := s.pm.ReloadRules(st.ProxyId, req.Rules)
		if err == nil && resp.Success {
			totalLoaded += resp.RulesLoaded
		}
	}
	return proto.Marshal(&pb.ReloadRulesResponse{Success: true, RulesLoaded: totalLoaded})
}

func (s *ProxyAdminServer) cmdBlockIP(payload []byte) ([]byte, error) {
	var req pb.BlockIPRequest
	if err := proto.Unmarshal(payload, &req); err != nil {
		return nil, err
	}
	if err := validateIPOrCIDR(req.Ip); err != nil {
		return nil, err
	}
	globalRules := s.pm.GetGlobalRules()
	if globalRules != nil {
		duration := time.Duration(req.DurationSeconds) * time.Second
		globalRules.BlockIP(req.Ip, duration)
		log.Printf("[Admin] Global block added: %s (duration: %v)", req.Ip, duration)
	} else {
		statuses := s.pm.GetAllStatuses()
		for _, st := range statuses {
			s.pm.AddRule(&pb.AddRuleRequest{
				ProxyId: st.ProxyId,
				Rule: &pb.Rule{
					Name: "Quick Block: " + req.Ip, Priority: 1000, Enabled: true,
					Action: common.ActionType_ACTION_TYPE_BLOCK,
					Conditions: []*pb.Condition{{
						Type: common.ConditionType_CONDITION_TYPE_SOURCE_IP, Op: common.Operator_OPERATOR_EQ, Value: req.Ip,
					}},
				},
			})
		}
	}
	return nil, nil
}

func (s *ProxyAdminServer) cmdAllowIP(payload []byte) ([]byte, error) {
	var req pb.AllowIPRequest
	if err := proto.Unmarshal(payload, &req); err != nil {
		return nil, err
	}
	if err := validateIPOrCIDR(req.Ip); err != nil {
		return nil, err
	}
	globalRules := s.pm.GetGlobalRules()
	if globalRules != nil {
		duration := time.Duration(req.DurationSeconds) * time.Second
		globalRules.AllowIP(req.Ip, duration)
		log.Printf("[Admin] Global allow added: %s (duration: %v)", req.Ip, duration)
	} else {
		statuses := s.pm.GetAllStatuses()
		for _, st := range statuses {
			s.pm.AddRule(&pb.AddRuleRequest{
				ProxyId: st.ProxyId,
				Rule: &pb.Rule{
					Name: "Quick Allow: " + req.Ip, Priority: 1000, Enabled: true,
					Action: common.ActionType_ACTION_TYPE_ALLOW,
					Conditions: []*pb.Condition{{
						Type: common.ConditionType_CONDITION_TYPE_SOURCE_IP, Op: common.Operator_OPERATOR_EQ, Value: req.Ip,
					}},
				},
			})
		}
	}
	return nil, nil
}

func (s *ProxyAdminServer) cmdListGlobalRules() ([]byte, error) {
	globalRules := s.pm.GetGlobalRules()
	if globalRules == nil {
		return proto.Marshal(&pb.ListGlobalRulesResponse{})
	}
	rules := globalRules.List()
	pbRules := make([]*pb.GlobalRule, 0, len(rules))
	for _, r := range rules {
		pbRule := &pb.GlobalRule{
			Id: r.ID, Name: r.Name, SourceIp: r.SourceIP, Action: r.Action,
			CreatedAt: timestamppb.New(r.CreatedAt),
		}
		if !r.ExpiresAt.IsZero() {
			pbRule.ExpiresAt = timestamppb.New(r.ExpiresAt)
		}
		pbRules = append(pbRules, pbRule)
	}
	return proto.Marshal(&pb.ListGlobalRulesResponse{Rules: pbRules})
}

func (s *ProxyAdminServer) cmdRemoveGlobalRule(payload []byte) ([]byte, error) {
	var req pb.RemoveGlobalRuleRequest
	if err := proto.Unmarshal(payload, &req); err != nil {
		return nil, err
	}
	globalRules := s.pm.GetGlobalRules()
	if globalRules == nil {
		return proto.Marshal(&pb.RemoveGlobalRuleResponse{Success: false, ErrorMessage: "Global rules not configured"})
	}
	if !globalRules.Remove(req.RuleId) {
		return proto.Marshal(&pb.RemoveGlobalRuleResponse{Success: false, ErrorMessage: "Rule not found"})
	}
	log.Printf("[Admin] Global rule removed: %s", req.RuleId)
	return proto.Marshal(&pb.RemoveGlobalRuleResponse{Success: true})
}

func (s *ProxyAdminServer) cmdConfigureGeoIP(payload []byte) ([]byte, error) {
	var req pb.ConfigureGeoIPRequest
	if err := proto.Unmarshal(payload, &req); err != nil {
		return nil, err
	}
	resp, err := s.pm.ConfigureGeoIP(&req)
	if err != nil {
		return nil, err
	}
	return proto.Marshal(resp)
}

func (s *ProxyAdminServer) cmdGetGeoIPStatus() ([]byte, error) {
	resp, err := s.pm.GetGeoIPStatus(&pb.GetGeoIPStatusRequest{})
	if err != nil {
		return nil, err
	}
	return proto.Marshal(resp)
}

func (s *ProxyAdminServer) cmdLookupIP(payload []byte) ([]byte, error) {
	var req pb.LookupIPRequest
	if err := proto.Unmarshal(payload, &req); err != nil {
		return nil, err
	}
	resp, err := s.pm.LookupIP(&req)
	if err != nil {
		return nil, err
	}
	return proto.Marshal(resp)
}

func (s *ProxyAdminServer) cmdListActiveApprovals(payload []byte) ([]byte, error) {
	if s.pm.Approval == nil {
		return proto.Marshal(&pb.ListActiveApprovalsResponse{})
	}
	var req pb.ListActiveApprovalsRequest
	if len(payload) > 0 {
		if err := proto.Unmarshal(payload, &req); err != nil {
			return nil, err
		}
	}
	entries := s.pm.Approval.GetActiveApprovals()
	approvals := make([]*pb.ActiveApproval, 0, len(entries))
	for _, e := range entries {
		if req.ProxyId != "" && e.ProxyID != req.ProxyId {
			continue
		}
		if req.SourceIp != "" && e.SourceIP != req.SourceIp {
			continue
		}
		connIDs := make([]string, 0, len(e.LiveConns))
		for connID := range e.LiveConns {
			connIDs = append(connIDs, connID)
		}
		approvals = append(approvals, &pb.ActiveApproval{
			Key: e.Key(), SourceIp: e.SourceIP, RuleId: e.RuleID,
			ProxyId: e.ProxyID, TlsSessionId: e.TLSSessionID, Allowed: e.Decision,
			CreatedAt: timestamppb.New(e.CreatedAt), ExpiresAt: timestamppb.New(e.ExpiresAt),
			BytesIn: e.BytesIn, BytesOut: e.BytesOut, BlockedCount: int64(e.BlockedCount),
			ConnIds: connIDs, GeoCountry: e.GeoCountry, GeoCity: e.GeoCity, GeoIsp: e.GeoISP,
		})
	}
	return proto.Marshal(&pb.ListActiveApprovalsResponse{Approvals: approvals})
}

func (s *ProxyAdminServer) cmdCancelApproval(payload []byte) ([]byte, error) {
	var req pb.CancelApprovalRequest
	if err := proto.Unmarshal(payload, &req); err != nil {
		return nil, err
	}
	if s.pm.Approval == nil {
		return proto.Marshal(&pb.CancelApprovalResponse{Success: false, ErrorMessage: "Approval system not configured"})
	}
	parts := strings.Split(req.Key, node.KeySeparator)
	if len(parts) < 2 {
		return proto.Marshal(&pb.CancelApprovalResponse{Success: false, ErrorMessage: "Invalid approval key format"})
	}
	sourceIP, ruleID := parts[0], parts[1]
	tlsSessionID := ""
	if len(parts) > 2 {
		tlsSessionID = parts[2]
	}
	entry := s.pm.Approval.GetEntry(sourceIP, ruleID, tlsSessionID)
	if entry == nil {
		return proto.Marshal(&pb.CancelApprovalResponse{Success: false, ErrorMessage: "Approval not found"})
	}
	connectionsClosed := int32(0)
	if req.CloseConnections && len(entry.LiveConns) > 0 {
		for connID := range entry.LiveConns {
			if err := s.pm.CloseConnection(entry.ProxyID, connID); err == nil {
				connectionsClosed++
			}
		}
	}
	s.pm.Approval.RemoveApproval(sourceIP, ruleID, tlsSessionID)
	log.Printf("[Admin] Approval cancelled: %s (connections closed: %d)", req.Key, connectionsClosed)
	return proto.Marshal(&pb.CancelApprovalResponse{Success: true, ConnectionsClosed: connectionsClosed})
}

func (s *ProxyAdminServer) cmdResolveApproval(payload []byte) ([]byte, error) {
	var req pb.ResolveApprovalRequest
	if err := proto.Unmarshal(payload, &req); err != nil {
		return nil, err
	}
	if s.pm.Approval == nil {
		return proto.Marshal(&pb.ResolveApprovalResponse{Success: false, ErrorMessage: "Approval system not configured"})
	}
	retentionMode := req.GetRetentionMode()
	if retentionMode == common.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_UNSPECIFIED {
		retentionMode = common.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CACHE
	}
	durationSeconds := req.DurationSeconds
	if retentionMode == common.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CACHE && durationSeconds <= 0 {
		durationSeconds = config.DefaultApprovalDurationSeconds
	}
	if retentionMode == common.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CONNECTION_ONLY && durationSeconds < 0 {
		durationSeconds = 0
	}
	allowed := req.Action == common.ApprovalActionType_APPROVAL_ACTION_TYPE_ALLOW
	meta := s.pm.Approval.ResolveWithRetention(req.ReqId, allowed, durationSeconds, req.Reason, retentionMode)
	if meta == nil {
		return proto.Marshal(&pb.ResolveApprovalResponse{Success: false, ErrorMessage: "Approval request not found or already resolved"})
	}
	log.Printf("[Admin] Approval resolved: %s -> %v (mode=%v, duration: %ds)", req.ReqId, allowed, retentionMode, durationSeconds)
	return proto.Marshal(&pb.ResolveApprovalResponse{Success: true})
}

// ============================================================================
// Observability (E2E encrypted streams — kept as-is)
// ============================================================================

func (s *ProxyAdminServer) StreamConnections(req *pb.StreamConnectionsRequest, stream pb.ProxyControlService_StreamConnectionsServer) error {
	viewerPubKey := ed25519.PublicKey(req.GetViewerPubkey())
	if len(viewerPubKey) != ed25519.PublicKeySize {
		return status.Error(codes.InvalidArgument, "viewer_pubkey is required and must be a valid Ed25519 public key")
	}

	eventCh := s.pm.SubscribeGlobal()
	defer s.pm.UnsubscribeGlobal(eventCh)

	for {
		select {
		case <-stream.Context().Done():
			return nil
		case event, ok := <-eventCh:
			if !ok {
				return nil
			}
			encPayload, err := s.encryptStreamPayload(event, "ConnectionEvent", viewerPubKey)
			if err != nil {
				log.Printf("[Admin] Failed to encrypt connection event: %v", err)
				continue
			}
			if err := stream.Send(encPayload); err != nil {
				return err
			}
		}
	}
}

func (s *ProxyAdminServer) StreamMetrics(req *pb.StreamMetricsRequest, stream pb.ProxyControlService_StreamMetricsServer) error {
	viewerPubKey := ed25519.PublicKey(req.GetViewerPubkey())
	if len(viewerPubKey) != ed25519.PublicKeySize {
		return status.Error(codes.InvalidArgument, "viewer_pubkey is required and must be a valid Ed25519 public key")
	}

	interval := req.IntervalSeconds
	if interval <= 0 {
		interval = 1
	}

	ticker := time.NewTicker(time.Duration(interval) * time.Second)
	defer ticker.Stop()

	var prevBytesIn, prevBytesOut int64
	var prevTimestamp int64

	for {
		select {
		case <-stream.Context().Done():
			return nil
		case <-ticker.C:
			statuses := s.pm.GetAllStatuses()
			var totalActive, totalConns, totalBytesIn, totalBytesOut int64
			for _, st := range statuses {
				totalActive += st.ActiveConnections
				totalConns += st.TotalConnections
				totalBytesIn += st.BytesIn
				totalBytesOut += st.BytesOut
			}
			now := time.Now().Unix()
			var bytesInRate, bytesOutRate int64
			if prevTimestamp > 0 {
				elapsed := now - prevTimestamp
				if elapsed > 0 {
					bytesInRate = (totalBytesIn - prevBytesIn) / elapsed
					bytesOutRate = (totalBytesOut - prevBytesOut) / elapsed
				}
			}
			sample := &pb.MetricsSample{
				Timestamp: now, ActiveConns: totalActive, TotalConns: totalConns,
				BytesInRate: bytesInRate, BytesOutRate: bytesOutRate,
			}
			encPayload, err := s.encryptStreamPayload(sample, "MetricsSample", viewerPubKey)
			if err != nil {
				log.Printf("[Admin] Failed to encrypt metrics sample: %v", err)
				continue
			}
			if err := stream.Send(encPayload); err != nil {
				return err
			}
			prevBytesIn = totalBytesIn
			prevBytesOut = totalBytesOut
			prevTimestamp = now
		}
	}
}

func (s *ProxyAdminServer) encryptStreamPayload(msg proto.Message, payloadType string, viewerPubKey ed25519.PublicKey) (*pb.EncryptedStreamPayload, error) {
	data, err := proto.Marshal(msg)
	if err != nil {
		return nil, err
	}
	enc, err := nitellacrypto.EncryptWithSignature(data, viewerPubKey, s.nodePrivKey, s.nodeID)
	if err != nil {
		return nil, err
	}
	return &pb.EncryptedStreamPayload{
		Encrypted: &common.EncryptedPayload{
			EphemeralPubkey: enc.EphemeralPubKey, Nonce: enc.Nonce,
			Ciphertext: enc.Ciphertext, SenderFingerprint: enc.SenderFingerprint,
			Signature: enc.Signature,
		},
		PayloadType: payloadType,
	}, nil
}

// ============================================================================
// Helpers
// ============================================================================

func validateIPOrCIDR(input string) error {
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

// ============================================================================
// Authentication Interceptors
// ============================================================================

// ProxyAdminAuthInterceptor creates a token authentication interceptor.
func ProxyAdminAuthInterceptor(token string) grpc.UnaryServerInterceptor {
	var loggedOnce sync.Once

	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		clientAddr := "unknown"
		if p, ok := peer.FromContext(ctx); ok && p.Addr != nil {
			clientAddr = p.Addr.String()
		}

		md, ok := metadata.FromIncomingContext(ctx)
		if !ok {
			log.Printf("[Admin] Auth failed from %s: no metadata", clientAddr)
			return nil, status.Error(codes.Unauthenticated, "no metadata")
		}

		tokens := md.Get("authorization")
		if len(tokens) == 0 {
			log.Printf("[Admin] Auth failed from %s: missing authorization", clientAddr)
			return nil, status.Error(codes.Unauthenticated, "missing authorization")
		}

		authToken := tokens[0]
		if len(authToken) > 7 && authToken[:7] == "Bearer " {
			authToken = authToken[7:]
		}

		if subtle.ConstantTimeCompare([]byte(authToken), []byte(token)) != 1 {
			log.Printf("[Admin] Auth failed from %s: invalid token", clientAddr)
			return nil, status.Error(codes.Unauthenticated, "invalid token")
		}

		loggedOnce.Do(func() {
			log.Printf("[Admin] First client authenticated from %s", clientAddr)
		})

		return handler(ctx, req)
	}
}

// ProxyAdminStreamAuthInterceptor creates a stream authentication interceptor.
func ProxyAdminStreamAuthInterceptor(token string) grpc.StreamServerInterceptor {
	return func(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		md, ok := metadata.FromIncomingContext(ss.Context())
		if !ok {
			return status.Error(codes.Unauthenticated, "no metadata")
		}

		tokens := md.Get("authorization")
		if len(tokens) == 0 {
			return status.Error(codes.Unauthenticated, "missing authorization")
		}

		authToken := tokens[0]
		if len(authToken) > 7 && authToken[:7] == "Bearer " {
			authToken = authToken[7:]
		}

		if subtle.ConstantTimeCompare([]byte(authToken), []byte(token)) != 1 {
			return status.Error(codes.Unauthenticated, "invalid token")
		}

		return handler(srv, ss)
	}
}
