package service

import (
	"context"
	"crypto/ed25519"
	"strings"
	"testing"

	"github.com/ivere27/nitella/pkg/api/common"
	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pb "github.com/ivere27/nitella/pkg/api/local"
	"github.com/ivere27/nitella/pkg/identity"
	"google.golang.org/grpc"
	"google.golang.org/protobuf/types/known/timestamppb"
)

func TestHubTrustChallengeLifecycle(t *testing.T) {
	svc := NewMobileLogicService()
	caResp := &pb.FetchHubCAResponse{
		Success:     true,
		CaPem:       []byte("test-ca-pem"),
		Fingerprint: "aa:bb:cc",
		EmojiHash:   "🐱🐶🐼",
		Subject:     "CN=hub.local",
		Expires:     "2027-01-01T00:00:00Z",
	}

	challenge, err := svc.createHubTrustChallenge("hub.local:443", caResp, nil)
	if err != nil {
		t.Fatalf("createHubTrustChallenge() error = %v", err)
	}
	if challenge.GetChallengeId() == "" {
		t.Fatalf("expected non-empty challenge_id")
	}

	taken, err := svc.takeHubTrustChallenge("hub.local:443", challenge.GetChallengeId())
	if err != nil {
		t.Fatalf("takeHubTrustChallenge() error = %v", err)
	}
	if string(taken.GetCaPem()) != string(caResp.GetCaPem()) {
		t.Fatalf("unexpected ca_pem: got=%q want=%q", string(taken.GetCaPem()), string(caResp.GetCaPem()))
	}
	if taken.GetFingerprint() != caResp.GetFingerprint() {
		t.Fatalf("unexpected fingerprint: got=%q want=%q", taken.GetFingerprint(), caResp.GetFingerprint())
	}

	// Challenge is one-time-use and should be consumed after successful take.
	_, err = svc.takeHubTrustChallenge("hub.local:443", challenge.GetChallengeId())
	if err == nil {
		t.Fatalf("expected error for already consumed challenge")
	}
}

func TestHubTrustChallengeHubAddressBinding(t *testing.T) {
	svc := NewMobileLogicService()
	caResp := &pb.FetchHubCAResponse{
		Success:     true,
		CaPem:       []byte("test-ca-pem"),
		Fingerprint: "aa:bb:cc",
		EmojiHash:   "🐱🐶🐼",
		Subject:     "CN=hub.local",
		Expires:     "2027-01-01T00:00:00Z",
	}

	challenge, err := svc.createHubTrustChallenge("hub.local:443", caResp, nil)
	if err != nil {
		t.Fatalf("createHubTrustChallenge() error = %v", err)
	}

	_, err = svc.takeHubTrustChallenge("other-hub.local:443", challenge.GetChallengeId())
	if err == nil {
		t.Fatalf("expected error for mismatched hub address")
	}
	if !strings.Contains(err.Error(), "different hub address") {
		t.Fatalf("unexpected error for mismatched hub address: %v", err)
	}
}

func TestResolveHubTrustChallengeRejectsAndConsumesSession(t *testing.T) {
	svc := NewMobileLogicService()
	caResp := &pb.FetchHubCAResponse{
		Success:     true,
		CaPem:       []byte("test-ca-pem"),
		Fingerprint: "aa:bb:cc",
		EmojiHash:   "🐱🐶🐼",
		Subject:     "CN=hub.local",
		Expires:     "2027-01-01T00:00:00Z",
	}

	challenge, err := svc.createHubTrustChallenge("hub.local:443", caResp, &pb.OnboardHubRequest{
		InviteCode: "NITELLA",
	})
	if err != nil {
		t.Fatalf("createHubTrustChallenge() error = %v", err)
	}

	resp, err := svc.ResolveHubTrustChallenge(context.Background(), &pb.ResolveHubTrustChallengeRequest{
		ChallengeId: challenge.GetChallengeId(),
		Accepted:    false,
	})
	if err != nil {
		t.Fatalf("ResolveHubTrustChallenge() error = %v", err)
	}
	if resp.GetSuccess() {
		t.Fatalf("expected failed response for rejected trust challenge")
	}
	if !strings.Contains(resp.GetError(), "rejected") {
		t.Fatalf("unexpected reject error: %q", resp.GetError())
	}

	again, err := svc.ResolveHubTrustChallenge(context.Background(), &pb.ResolveHubTrustChallengeRequest{
		ChallengeId: challenge.GetChallengeId(),
		Accepted:    true,
	})
	if err != nil {
		t.Fatalf("ResolveHubTrustChallenge(second) error = %v", err)
	}
	if again.GetSuccess() {
		t.Fatalf("expected missing challenge after reject consumption")
	}
	if !strings.Contains(again.GetError(), "not found") {
		t.Fatalf("unexpected second error: %q", again.GetError())
	}
}

func TestEnsureHubRegisteredFastPathWhenAlreadyConnected(t *testing.T) {
	svc := NewMobileLogicService()
	svc.hubConnected = true
	svc.hubAddr = "hub.local:443"
	svc.hubUserID = "user-123"
	svc.hubTier = "free"
	svc.hubMaxNodes = 3

	resp, err := svc.EnsureHubRegistered(context.Background(), &pb.EnsureHubRegisteredRequest{})
	if err != nil {
		t.Fatalf("EnsureHubRegistered() error = %v", err)
	}
	if !resp.GetSuccess() {
		t.Fatalf("expected success response: %+v", resp)
	}
	if resp.GetStage() != pb.OnboardHubResponse_STAGE_COMPLETED {
		t.Fatalf("unexpected stage: got=%v", resp.GetStage())
	}
	if !resp.GetConnected() || !resp.GetRegistered() {
		t.Fatalf("expected connected+registered response: %+v", resp)
	}
	if resp.GetUserId() != "user-123" {
		t.Fatalf("unexpected user_id: got=%q", resp.GetUserId())
	}
}

func TestEnsureHubConnectedFastPathWhenAlreadyConnected(t *testing.T) {
	svc := NewMobileLogicService()
	svc.hubConnected = true
	svc.hubAddr = "hub.local:443"
	svc.hubUserID = "user-123"
	svc.hubTier = "free"
	svc.hubMaxNodes = 3

	resp, err := svc.EnsureHubConnected(context.Background(), &pb.EnsureHubConnectedRequest{})
	if err != nil {
		t.Fatalf("EnsureHubConnected() error = %v", err)
	}
	if !resp.GetSuccess() {
		t.Fatalf("expected success response: %+v", resp)
	}
	if resp.GetStage() != pb.OnboardHubResponse_STAGE_COMPLETED {
		t.Fatalf("unexpected stage: got=%v", resp.GetStage())
	}
	if !resp.GetConnected() || !resp.GetRegistered() {
		t.Fatalf("expected connected+registered response: %+v", resp)
	}
	if resp.GetUserId() != "user-123" {
		t.Fatalf("unexpected user_id: got=%q", resp.GetUserId())
	}
}

func TestGetHubOverviewAggregatesNodes(t *testing.T) {
	svc := NewMobileLogicService()
	svc.hubConnected = true
	svc.hubAddr = "hub.local:443"
	svc.hubUserID = "user-123"
	svc.hubTier = "free"
	svc.hubMaxNodes = 3
	svc.nodes["node-1"] = &pb.NodeInfo{
		NodeId:     "node-1",
		Online:     true,
		Pinned:     true,
		ProxyCount: 2,
		Metrics: &pb.NodeMetrics{
			ActiveConnections: 5,
		},
	}
	svc.nodes["node-2"] = &pb.NodeInfo{
		NodeId:     "node-2",
		Online:     false,
		Pinned:     false,
		ProxyCount: 1,
	}

	overview, err := svc.GetHubOverview(context.Background(), nil)
	if err != nil {
		t.Fatalf("GetHubOverview() error = %v", err)
	}
	if !overview.GetHubConnected() {
		t.Fatalf("expected hub_connected=true")
	}
	if overview.GetTotalNodes() != 2 {
		t.Fatalf("unexpected total_nodes: got=%d want=2", overview.GetTotalNodes())
	}
	if overview.GetOnlineNodes() != 1 {
		t.Fatalf("unexpected online_nodes: got=%d want=1", overview.GetOnlineNodes())
	}
	if overview.GetPinnedNodes() != 1 {
		t.Fatalf("unexpected pinned_nodes: got=%d want=1", overview.GetPinnedNodes())
	}
	if overview.GetTotalProxies() != 3 {
		t.Fatalf("unexpected total_proxies: got=%d want=3", overview.GetTotalProxies())
	}
	if overview.GetTotalActiveConnections() != 5 {
		t.Fatalf("unexpected total_active_connections: got=%d want=5", overview.GetTotalActiveConnections())
	}
}

func TestGetHubDashboardSnapshotIncludesOverviewNodesAndPinned(t *testing.T) {
	svc := NewMobileLogicService()
	svc.hubConnected = true
	svc.hubAddr = "hub.local:443"
	svc.hubUserID = "user-123"
	svc.hubTier = "free"
	svc.hubMaxNodes = 3
	svc.nodes["node-1"] = &pb.NodeInfo{
		NodeId:     "node-1",
		Online:     true,
		Pinned:     true,
		ProxyCount: 2,
		Metrics: &pb.NodeMetrics{
			ActiveConnections: 5,
		},
	}
	svc.nodes["node-2"] = &pb.NodeInfo{
		NodeId:     "node-2",
		Online:     false,
		Pinned:     false,
		ProxyCount: 1,
	}

	snapshot, err := svc.GetHubDashboardSnapshot(context.Background(), &pb.GetHubDashboardSnapshotRequest{})
	if err != nil {
		t.Fatalf("GetHubDashboardSnapshot() error = %v", err)
	}
	if snapshot.GetOverview() == nil {
		t.Fatalf("expected overview in snapshot")
	}
	if snapshot.GetOverview().GetTotalNodes() != 2 {
		t.Fatalf("unexpected total_nodes: got=%d want=2", snapshot.GetOverview().GetTotalNodes())
	}
	if snapshot.GetOverview().GetOnlineNodes() != 1 {
		t.Fatalf("unexpected online_nodes: got=%d want=1", snapshot.GetOverview().GetOnlineNodes())
	}
	if snapshot.GetOverview().GetPinnedNodes() != 1 {
		t.Fatalf("unexpected pinned_nodes: got=%d want=1", snapshot.GetOverview().GetPinnedNodes())
	}
	if got := len(snapshot.GetNodes()); got != 2 {
		t.Fatalf("unexpected nodes length: got=%d want=2", got)
	}
	if got := len(snapshot.GetPinnedNodes()); got != 1 {
		t.Fatalf("unexpected pinned_nodes length: got=%d want=1", got)
	}
	if snapshot.GetPinnedNodes()[0].GetNodeId() != "node-1" {
		t.Fatalf("unexpected pinned node_id: %q", snapshot.GetPinnedNodes()[0].GetNodeId())
	}
}

func TestGetHubDashboardSnapshotAppliesNodeFilter(t *testing.T) {
	svc := NewMobileLogicService()
	svc.nodes["node-1"] = &pb.NodeInfo{NodeId: "node-1", Online: true, Pinned: true}
	svc.nodes["node-2"] = &pb.NodeInfo{NodeId: "node-2", Online: false, Pinned: true}

	snapshot, err := svc.GetHubDashboardSnapshot(context.Background(), &pb.GetHubDashboardSnapshotRequest{
		NodeFilter: "online",
	})
	if err != nil {
		t.Fatalf("GetHubDashboardSnapshot(filter=online) error = %v", err)
	}
	if got := len(snapshot.GetNodes()); got != 1 {
		t.Fatalf("unexpected nodes length: got=%d want=1", got)
	}
	if snapshot.GetNodes()[0].GetNodeId() != "node-1" {
		t.Fatalf("unexpected filtered node_id: %q", snapshot.GetNodes()[0].GetNodeId())
	}
	if got := len(snapshot.GetPinnedNodes()); got != 1 {
		t.Fatalf("unexpected pinned_nodes length: got=%d want=1", got)
	}
	if snapshot.GetOverview().GetTotalNodes() != 2 {
		t.Fatalf("overview totals should remain unfiltered; got=%d want=2", snapshot.GetOverview().GetTotalNodes())
	}
}

type dashboardSnapshotMobileClient struct {
	pbHub.MobileServiceClient
	listResp *pbHub.ListNodesResponse
	listReq  *pbHub.ListNodesRequest
}

func (m *dashboardSnapshotMobileClient) ListNodes(_ context.Context, req *pbHub.ListNodesRequest, _ ...grpc.CallOption) (*pbHub.ListNodesResponse, error) {
	m.listReq = req
	return m.listResp, nil
}

func TestGetHubDashboardSnapshotRefreshesNodeStatusFromHub(t *testing.T) {
	svc := NewMobileLogicService()
	seed := make([]byte, ed25519.SeedSize)
	for i := range seed {
		seed[i] = byte(i + 1)
	}
	svc.identity = &identity.Identity{
		RootKey: ed25519.NewKeyFromSeed(seed),
	}
	svc.nodes["thinkpad"] = &pb.NodeInfo{
		NodeId: "thinkpad",
		Online: false,
	}

	mockClient := &dashboardSnapshotMobileClient{
		listResp: &pbHub.ListNodesResponse{
			Nodes: []*pbHub.Node{
				{
					Id:       "thinkpad",
					Status:   pbHub.NodeStatus_NODE_STATUS_ONLINE,
					LastSeen: timestamppb.Now(),
				},
			},
		},
	}
	svc.mobileClient = mockClient

	snapshot, err := svc.GetHubDashboardSnapshot(context.Background(), &pb.GetHubDashboardSnapshotRequest{})
	if err != nil {
		t.Fatalf("GetHubDashboardSnapshot() error = %v", err)
	}
	if got := len(snapshot.GetNodes()); got != 1 {
		t.Fatalf("unexpected nodes length: got=%d want=1", got)
	}
	node := snapshot.GetNodes()[0]
	if !node.GetOnline() {
		t.Fatalf("expected refreshed node to be online")
	}
	if node.GetLastSeen() == nil {
		t.Fatalf("expected refreshed node last_seen to be set")
	}
	if snapshot.GetOverview().GetOnlineNodes() != 1 {
		t.Fatalf("unexpected online_nodes after refresh: got=%d want=1", snapshot.GetOverview().GetOnlineNodes())
	}
	if mockClient.listReq == nil {
		t.Fatalf("expected ListNodes request to be sent to hub")
	}
	if got := len(mockClient.listReq.GetRoutingTokens()); got != 1 {
		t.Fatalf("unexpected routing token count: got=%d want=1", got)
	}
	if strings.TrimSpace(mockClient.listReq.GetRoutingTokens()[0]) == "" {
		t.Fatalf("expected non-empty routing token")
	}
}

func TestGetHubSettingsSnapshotResolvesFromStatusAndSettings(t *testing.T) {
	svc := NewMobileLogicService()
	svc.hubConnected = true
	svc.hubAddr = "hub-live.local:443"
	svc.hubUserID = "user-123"
	svc.hubTier = "free"
	svc.hubMaxNodes = 3
	svc.settings.HubAddress = "hub-settings.local:443"
	svc.settings.HubInviteCode = "INVITE-123"
	svc.settings.RequireBiometric = true

	snapshot, err := svc.GetHubSettingsSnapshot(context.Background(), nil)
	if err != nil {
		t.Fatalf("GetHubSettingsSnapshot() error = %v", err)
	}
	if snapshot.GetStatus() == nil {
		t.Fatalf("expected status in snapshot")
	}
	if snapshot.GetSettings() == nil {
		t.Fatalf("expected settings in snapshot")
	}
	if snapshot.GetResolvedHubAddress() != "hub-live.local:443" {
		t.Fatalf("unexpected resolved_hub_address: got=%q", snapshot.GetResolvedHubAddress())
	}
	if snapshot.GetResolvedInviteCode() != "INVITE-123" {
		t.Fatalf("unexpected resolved_invite_code: got=%q", snapshot.GetResolvedInviteCode())
	}
	if !snapshot.GetSettings().GetRequireBiometric() {
		t.Fatalf("expected require_biometric=true in settings")
	}
}

func TestGetHubSettingsSnapshotFallsBackToDefaults(t *testing.T) {
	svc := NewMobileLogicService()
	svc.hubConnected = false
	svc.hubAddr = ""
	svc.settings.HubAddress = "hub-from-settings.local:443"
	svc.settings.HubInviteCode = ""

	snapshot, err := svc.GetHubSettingsSnapshot(context.Background(), nil)
	if err != nil {
		t.Fatalf("GetHubSettingsSnapshot() error = %v", err)
	}
	if snapshot.GetResolvedHubAddress() != "hub-from-settings.local:443" {
		t.Fatalf("unexpected resolved_hub_address: got=%q", snapshot.GetResolvedHubAddress())
	}
	if snapshot.GetResolvedInviteCode() != "NITELLA" {
		t.Fatalf("unexpected resolved_invite_code default: got=%q", snapshot.GetResolvedInviteCode())
	}
}

func TestGetP2PSettingsSnapshotIncludesSettingsAndStatus(t *testing.T) {
	svc := NewMobileLogicService()
	svc.settings.P2PMode = common.P2PMode_P2P_MODE_AUTO
	svc.settings.StunServers = []string{"stun:stun.test:3478"}
	svc.settings.TurnServer = "turn:turn.test:3478"

	snapshot, err := svc.GetP2PSettingsSnapshot(context.Background(), nil)
	if err != nil {
		t.Fatalf("GetP2PSettingsSnapshot() error = %v", err)
	}
	if snapshot.GetStatus() == nil {
		t.Fatalf("expected status in snapshot")
	}
	if snapshot.GetSettings() == nil {
		t.Fatalf("expected settings in snapshot")
	}
	if snapshot.GetStatus().GetEnabled() {
		t.Fatalf("expected enabled=false when identity is missing")
	}
	if snapshot.GetSettings().GetP2PMode() != common.P2PMode_P2P_MODE_AUTO {
		t.Fatalf("unexpected p2p mode in settings: got=%v", snapshot.GetSettings().GetP2PMode())
	}
	if got := snapshot.GetSettings().GetStunServers(); len(got) != 1 || got[0] != "stun:stun.test:3478" {
		t.Fatalf("unexpected stun servers in settings: %v", got)
	}
	if snapshot.GetSettings().GetTurnServer() != "turn:turn.test:3478" {
		t.Fatalf("unexpected turn_server in settings: %q", snapshot.GetSettings().GetTurnServer())
	}
}

func TestGetSettingsOverviewSnapshotIncludesIdentityHubAndP2P(t *testing.T) {
	svc := NewMobileLogicService()
	svc.identity = &identity.Identity{
		Fingerprint: "fp-123",
		EmojiHash:   "🔐🧠",
	}
	svc.hubConnected = true
	svc.hubAddr = "hub-live.local:443"
	svc.hubUserID = "user-123"
	svc.hubTier = "pro"
	svc.hubMaxNodes = 10
	svc.settings.HubAddress = "hub-settings.local:443"
	svc.settings.HubInviteCode = ""
	svc.settings.P2PMode = common.P2PMode_P2P_MODE_AUTO
	svc.settings.StunServers = []string{"stun:stun.test:3478"}

	snapshot, err := svc.GetSettingsOverviewSnapshot(context.Background(), nil)
	if err != nil {
		t.Fatalf("GetSettingsOverviewSnapshot() error = %v", err)
	}
	if snapshot.GetIdentity() == nil {
		t.Fatalf("expected identity in settings overview snapshot")
	}
	if !snapshot.GetIdentity().GetExists() {
		t.Fatalf("expected identity.exists=true")
	}
	if snapshot.GetIdentity().GetFingerprint() != "fp-123" {
		t.Fatalf("unexpected identity fingerprint: got=%q", snapshot.GetIdentity().GetFingerprint())
	}
	if snapshot.GetHub() == nil {
		t.Fatalf("expected hub snapshot in settings overview snapshot")
	}
	if snapshot.GetHub().GetResolvedHubAddress() != "hub-live.local:443" {
		t.Fatalf("unexpected resolved_hub_address: got=%q", snapshot.GetHub().GetResolvedHubAddress())
	}
	if snapshot.GetHub().GetResolvedInviteCode() != "NITELLA" {
		t.Fatalf("unexpected resolved_invite_code default: got=%q", snapshot.GetHub().GetResolvedInviteCode())
	}
	if snapshot.GetP2P() == nil {
		t.Fatalf("expected p2p snapshot in settings overview snapshot")
	}
	if snapshot.GetP2P().GetSettings() == nil {
		t.Fatalf("expected p2p settings in settings overview snapshot")
	}
	if snapshot.GetP2P().GetSettings().GetP2PMode() != common.P2PMode_P2P_MODE_AUTO {
		t.Fatalf("unexpected p2p mode in overview: got=%v", snapshot.GetP2P().GetSettings().GetP2PMode())
	}
}
