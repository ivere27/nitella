package service

import (
	"context"
	"strings"
	"testing"

	pb "github.com/ivere27/nitella/pkg/api/local"
)

func TestSaveLocalProxyConfigRejectsAdapterManagedSyncMetadata(t *testing.T) {
	svc := NewMobileLogicService()
	svc.dataDir = t.TempDir()

	resp, err := svc.SaveLocalProxyConfig(context.Background(), &pb.SaveLocalProxyConfigRequest{
		ProxyId:     "proxy-1",
		Name:        "Proxy 1",
		ConfigYaml:  "entryPoints: {}\ntcp: {}\n",
		RevisionNum: 7,
		MarkSynced:  true,
	})
	if err != nil {
		t.Fatalf("SaveLocalProxyConfig() error = %v", err)
	}
	if resp.GetSuccess() {
		t.Fatalf("expected save rejection for adapter-managed sync metadata")
	}
	if !strings.Contains(resp.GetError(), "backend-managed") {
		t.Fatalf("unexpected error: %q", resp.GetError())
	}
}

func TestSaveLocalProxyConfigAllowsInternalSyncMetadata(t *testing.T) {
	svc := NewMobileLogicService()
	svc.dataDir = t.TempDir()

	resp, err := svc.SaveLocalProxyConfig(withInternalLocalProxySyncContext(context.Background()), &pb.SaveLocalProxyConfigRequest{
		ProxyId:     "proxy-1",
		Name:        "Proxy 1",
		ConfigYaml:  "entryPoints: {}\ntcp: {}\n",
		RevisionNum: 11,
		MarkSynced:  true,
	})
	if err != nil {
		t.Fatalf("SaveLocalProxyConfig(internal) error = %v", err)
	}
	if !resp.GetSuccess() {
		t.Fatalf("expected internal sync metadata save success: %s", resp.GetError())
	}
	if resp.GetProxy() == nil {
		t.Fatalf("expected proxy metadata in response")
	}
	if resp.GetProxy().GetRevisionNum() != 11 {
		t.Fatalf("unexpected revision_num: got=%d want=11", resp.GetProxy().GetRevisionNum())
	}
	if resp.GetProxy().GetSyncedAt() == nil {
		t.Fatalf("expected synced_at to be set for internal sync metadata save")
	}
}
