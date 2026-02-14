package core

import (
	"context"
	"fmt"
	"testing"

	"github.com/ivere27/nitella/pkg/api/common"
	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"google.golang.org/grpc"
	"google.golang.org/protobuf/proto"
	emptypb "google.golang.org/protobuf/types/known/emptypb"
)

// mockMobileServiceClient implements the Hub MobileServiceClient for proxy storage tests.
type mockMobileServiceClient struct {
	pbHub.MobileServiceClient

	// Proxy config state
	proxies  []*pbHub.ProxyConfigInfo
	created  []string // proxy IDs that were created
	deleted  []string // proxy IDs that were deleted
	flushed  map[string]int32

	// Revision storage (proxyID -> revisions)
	revisions map[string][]*storedRevision

	// Error injection
	listErr   error
	createErr error
	deleteErr error
	pushErr   error
	getErr    error
	listRevErr error
	flushErr  error
}

type storedRevision struct {
	num       int64
	blob      []byte
	sizeBytes int32
}

func newMockMobileClient() *mockMobileServiceClient {
	return &mockMobileServiceClient{
		flushed:   make(map[string]int32),
		revisions: make(map[string][]*storedRevision),
	}
}

func (m *mockMobileServiceClient) ListProxyConfigs(_ context.Context, req *pbHub.ListProxyConfigsRequest, _ ...grpc.CallOption) (*pbHub.ListProxyConfigsResponse, error) {
	if m.listErr != nil {
		return nil, m.listErr
	}
	return &pbHub.ListProxyConfigsResponse{Proxies: m.proxies}, nil
}

func (m *mockMobileServiceClient) CreateProxyConfig(_ context.Context, req *pbHub.CreateProxyConfigRequest, _ ...grpc.CallOption) (*pbHub.CreateProxyConfigResponse, error) {
	if m.createErr != nil {
		return nil, m.createErr
	}
	m.created = append(m.created, req.ProxyId)
	return &pbHub.CreateProxyConfigResponse{Success: true}, nil
}

func (m *mockMobileServiceClient) DeleteProxyConfig(_ context.Context, req *pbHub.DeleteProxyConfigRequest, _ ...grpc.CallOption) (*pbHub.Empty, error) {
	if m.deleteErr != nil {
		return nil, m.deleteErr
	}
	m.deleted = append(m.deleted, req.ProxyId)
	return &pbHub.Empty{}, nil
}

func (m *mockMobileServiceClient) PushRevision(_ context.Context, req *pbHub.PushRevisionRequest, _ ...grpc.CallOption) (*pbHub.PushRevisionResponse, error) {
	if m.pushErr != nil {
		return nil, m.pushErr
	}
	revs := m.revisions[req.ProxyId]
	num := int64(len(revs) + 1)
	m.revisions[req.ProxyId] = append(revs, &storedRevision{
		num:       num,
		blob:      req.EncryptedBlob,
		sizeBytes: req.SizeBytes,
	})
	return &pbHub.PushRevisionResponse{
		Success:        true,
		RevisionNum:    num,
		RevisionsKept:  int32(len(m.revisions[req.ProxyId])),
		RevisionsLimit: 100,
		StorageUsedKb:  int32(req.SizeBytes / 1024),
		StorageLimitKb: 10240,
	}, nil
}

func (m *mockMobileServiceClient) GetRevision(_ context.Context, req *pbHub.GetRevisionRequest, _ ...grpc.CallOption) (*pbHub.GetRevisionResponse, error) {
	if m.getErr != nil {
		return nil, m.getErr
	}
	revs := m.revisions[req.ProxyId]
	if len(revs) == 0 {
		return nil, fmt.Errorf("no revisions for %s", req.ProxyId)
	}

	var rev *storedRevision
	if req.RevisionNum == 0 {
		// latest
		rev = revs[len(revs)-1]
	} else {
		for _, r := range revs {
			if r.num == req.RevisionNum {
				rev = r
				break
			}
		}
	}
	if rev == nil {
		return nil, fmt.Errorf("revision %d not found", req.RevisionNum)
	}

	return &pbHub.GetRevisionResponse{
		RevisionNum:   rev.num,
		EncryptedBlob: rev.blob,
		SizeBytes:     rev.sizeBytes,
	}, nil
}

func (m *mockMobileServiceClient) ListRevisions(_ context.Context, req *pbHub.ListRevisionsRequest, _ ...grpc.CallOption) (*pbHub.ListRevisionsResponse, error) {
	if m.listRevErr != nil {
		return nil, m.listRevErr
	}
	revs := m.revisions[req.ProxyId]
	var metas []*pbHub.RevisionMeta
	for _, r := range revs {
		metas = append(metas, &pbHub.RevisionMeta{
			RevisionNum: r.num,
			SizeBytes:   r.sizeBytes,
		})
	}
	return &pbHub.ListRevisionsResponse{Revisions: metas}, nil
}

func (m *mockMobileServiceClient) FlushRevisions(_ context.Context, req *pbHub.FlushRevisionsRequest, _ ...grpc.CallOption) (*pbHub.FlushRevisionsResponse, error) {
	if m.flushErr != nil {
		return nil, m.flushErr
	}
	m.flushed[req.ProxyId] = req.KeepCount
	revs := m.revisions[req.ProxyId]
	keep := int(req.KeepCount)
	deleted := 0
	if len(revs) > keep {
		deleted = len(revs) - keep
		m.revisions[req.ProxyId] = revs[deleted:]
	}
	return &pbHub.FlushRevisionsResponse{
		Success:        true,
		DeletedCount:   int32(deleted),
		RemainingCount: int32(len(m.revisions[req.ProxyId])),
	}, nil
}

// Unused methods — satisfy interface via embedding.
func (m *mockMobileServiceClient) StreamAlerts(context.Context, *pbHub.StreamAlertsRequest, ...grpc.CallOption) (grpc.ServerStreamingClient[common.Alert], error) {
	return nil, fmt.Errorf("not implemented")
}

// setupControllerWithMockHub creates a Controller with an identity and mock Hub client.
func setupControllerWithMockHub(t *testing.T) (*Controller, *mockMobileServiceClient) {
	t.Helper()
	id := newTestIdentity(t)

	mock := newMockMobileClient()
	ctrl := New(Config{
		RoutingSecret: []byte("test-routing-secret"),
	})
	ctrl.SetIdentity(id)

	// Inject mock client directly
	ctrl.mu.Lock()
	ctrl.mobileClient = mock
	ctrl.mu.Unlock()

	return ctrl, mock
}

func TestListProxyConfigs(t *testing.T) {
	ctrl, mock := setupControllerWithMockHub(t)

	mock.proxies = []*pbHub.ProxyConfigInfo{
		{ProxyId: "proxy-1"},
		{ProxyId: "proxy-2"},
	}

	proxies, err := ctrl.ListProxyConfigs(context.Background())
	if err != nil {
		t.Fatalf("ListProxyConfigs: %v", err)
	}
	if len(proxies) != 2 {
		t.Fatalf("len = %d, want 2", len(proxies))
	}
	if proxies[0].ProxyId != "proxy-1" {
		t.Errorf("proxies[0].ProxyId = %q, want %q", proxies[0].ProxyId, "proxy-1")
	}
}

func TestCreateProxyConfig(t *testing.T) {
	ctrl, mock := setupControllerWithMockHub(t)

	err := ctrl.CreateProxyConfig(context.Background(), "my-proxy")
	if err != nil {
		t.Fatalf("CreateProxyConfig: %v", err)
	}
	if len(mock.created) != 1 || mock.created[0] != "my-proxy" {
		t.Errorf("created = %v, want [my-proxy]", mock.created)
	}
}

func TestDeleteProxyConfig(t *testing.T) {
	ctrl, mock := setupControllerWithMockHub(t)

	err := ctrl.DeleteProxyConfig(context.Background(), "old-proxy")
	if err != nil {
		t.Fatalf("DeleteProxyConfig: %v", err)
	}
	if len(mock.deleted) != 1 || mock.deleted[0] != "old-proxy" {
		t.Errorf("deleted = %v, want [old-proxy]", mock.deleted)
	}
}

func TestPushAndGetRevision(t *testing.T) {
	ctrl, _ := setupControllerWithMockHub(t)

	// Push a revision
	payload := &pbHub.ProxyRevisionPayload{
		Name:       "Test Proxy",
		ConfigYaml: "listeners:\n  - type: socks5\n    port: 1080\n",
		ConfigHash: "sha256:abc123",
	}

	pushResult, err := ctrl.PushRevision(context.Background(), "proxy-1", payload)
	if err != nil {
		t.Fatalf("PushRevision: %v", err)
	}
	if pushResult.RevisionNum != 1 {
		t.Errorf("RevisionNum = %d, want 1", pushResult.RevisionNum)
	}

	// Get it back (latest)
	rev, err := ctrl.GetRevision(context.Background(), "proxy-1", 0)
	if err != nil {
		t.Fatalf("GetRevision: %v", err)
	}
	if rev.RevisionNum != 1 {
		t.Errorf("RevisionNum = %d, want 1", rev.RevisionNum)
	}
	if rev.Payload.Name != "Test Proxy" {
		t.Errorf("Payload.Name = %q, want %q", rev.Payload.Name, "Test Proxy")
	}
	if rev.Payload.ConfigYaml != payload.ConfigYaml {
		t.Errorf("Payload.ConfigYaml mismatch")
	}
	if rev.Payload.ConfigHash != "sha256:abc123" {
		t.Errorf("Payload.ConfigHash = %q, want %q", rev.Payload.ConfigHash, "sha256:abc123")
	}
}

func TestPushMultipleAndGetByNumber(t *testing.T) {
	ctrl, _ := setupControllerWithMockHub(t)

	for i := 1; i <= 3; i++ {
		_, err := ctrl.PushRevision(context.Background(), "proxy-1", &pbHub.ProxyRevisionPayload{
			Name:       fmt.Sprintf("Rev %d", i),
			ConfigYaml: fmt.Sprintf("port: %d", 1080+i),
		})
		if err != nil {
			t.Fatalf("PushRevision %d: %v", i, err)
		}
	}

	// Get revision 2 specifically
	rev, err := ctrl.GetRevision(context.Background(), "proxy-1", 2)
	if err != nil {
		t.Fatalf("GetRevision(2): %v", err)
	}
	if rev.Payload.Name != "Rev 2" {
		t.Errorf("Name = %q, want %q", rev.Payload.Name, "Rev 2")
	}

	// Get latest (should be 3)
	latest, err := ctrl.GetRevision(context.Background(), "proxy-1", 0)
	if err != nil {
		t.Fatalf("GetRevision(0): %v", err)
	}
	if latest.Payload.Name != "Rev 3" {
		t.Errorf("latest Name = %q, want %q", latest.Payload.Name, "Rev 3")
	}
}

func TestListRevisions(t *testing.T) {
	ctrl, _ := setupControllerWithMockHub(t)

	for i := 0; i < 3; i++ {
		ctrl.PushRevision(context.Background(), "proxy-1", &pbHub.ProxyRevisionPayload{
			Name: fmt.Sprintf("Rev %d", i),
		})
	}

	metas, err := ctrl.ListRevisions(context.Background(), "proxy-1")
	if err != nil {
		t.Fatalf("ListRevisions: %v", err)
	}
	if len(metas) != 3 {
		t.Fatalf("len = %d, want 3", len(metas))
	}
}

func TestFlushRevisions(t *testing.T) {
	ctrl, _ := setupControllerWithMockHub(t)

	// Push 5 revisions
	for i := 0; i < 5; i++ {
		ctrl.PushRevision(context.Background(), "proxy-1", &pbHub.ProxyRevisionPayload{
			Name: fmt.Sprintf("Rev %d", i),
		})
	}

	// Keep only 2
	result, err := ctrl.FlushRevisions(context.Background(), "proxy-1", 2)
	if err != nil {
		t.Fatalf("FlushRevisions: %v", err)
	}
	if result.DeletedCount != 3 {
		t.Errorf("DeletedCount = %d, want 3", result.DeletedCount)
	}
	if result.RemainingCount != 2 {
		t.Errorf("RemainingCount = %d, want 2", result.RemainingCount)
	}
}

func TestProxyStorage_NoHubConnection(t *testing.T) {
	ctrl := New(Config{})
	id := newTestIdentity(t)
	ctrl.SetIdentity(id)
	// No Hub connection set

	_, err := ctrl.ListProxyConfigs(context.Background())
	if err == nil {
		t.Fatal("expected error when not connected to Hub")
	}

	err = ctrl.CreateProxyConfig(context.Background(), "x")
	if err == nil {
		t.Fatal("expected error when not connected to Hub")
	}

	err = ctrl.DeleteProxyConfig(context.Background(), "x")
	if err == nil {
		t.Fatal("expected error when not connected to Hub")
	}

	_, err = ctrl.PushRevision(context.Background(), "x", &pbHub.ProxyRevisionPayload{})
	if err == nil {
		t.Fatal("expected error when not connected to Hub")
	}

	_, err = ctrl.GetRevision(context.Background(), "x", 0)
	if err == nil {
		t.Fatal("expected error when not connected to Hub")
	}

	_, err = ctrl.ListRevisions(context.Background(), "x")
	if err == nil {
		t.Fatal("expected error when not connected to Hub")
	}

	_, err = ctrl.FlushRevisions(context.Background(), "x", 1)
	if err == nil {
		t.Fatal("expected error when not connected to Hub")
	}
}

func TestPushRevision_EncryptsPayload(t *testing.T) {
	ctrl, mock := setupControllerWithMockHub(t)

	payload := &pbHub.ProxyRevisionPayload{
		Name:       "Encrypted Test",
		ConfigYaml: "port: 9090",
	}

	_, err := ctrl.PushRevision(context.Background(), "proxy-1", payload)
	if err != nil {
		t.Fatalf("PushRevision: %v", err)
	}

	// Verify the stored blob is actually encrypted (not raw proto)
	revs := mock.revisions["proxy-1"]
	if len(revs) != 1 {
		t.Fatalf("expected 1 revision stored, got %d", len(revs))
	}

	blob := revs[0].blob

	// Try to unmarshal as raw proto — should fail or produce garbage
	var rawPayload pbHub.ProxyRevisionPayload
	err = proto.Unmarshal(blob, &rawPayload)
	if err == nil && rawPayload.Name == "Encrypted Test" {
		t.Fatal("stored blob is not encrypted — raw proto unmarshal succeeded")
	}

	// Verify we can decrypt it with the identity key
	envelope, err := nitellacrypto.UnmarshalEncryptedPayload(blob)
	if err != nil {
		t.Fatalf("UnmarshalEncryptedPayload: %v", err)
	}
	id := ctrl.Identity()
	decrypted, err := nitellacrypto.Decrypt(envelope, id.RootKey)
	if err != nil {
		t.Fatalf("Decrypt: %v", err)
	}
	var decPayload pbHub.ProxyRevisionPayload
	if err := proto.Unmarshal(decrypted, &decPayload); err != nil {
		t.Fatalf("Unmarshal decrypted: %v", err)
	}
	if decPayload.Name != "Encrypted Test" {
		t.Errorf("decrypted Name = %q, want %q", decPayload.Name, "Encrypted Test")
	}
}

func TestRoutingToken_Generated(t *testing.T) {
	ctrl, _ := setupControllerWithMockHub(t)

	token := ctrl.routingToken()
	if token == "" {
		t.Fatal("routingToken() returned empty string")
	}
}

func TestRoutingToken_EmptyWithoutSecret(t *testing.T) {
	ctrl := New(Config{})

	token := ctrl.routingToken()
	if token != "" {
		t.Errorf("routingToken() = %q, want empty when no identity/secret", token)
	}
}

// Verify that the unused emptypb import doesn't cause issues (satisfies linter).
var _ = (*emptypb.Empty)(nil)
