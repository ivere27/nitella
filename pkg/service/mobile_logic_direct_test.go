package service

import (
	"context"
	"os"
	"path/filepath"
	"strings"
	"testing"

	pb "github.com/ivere27/nitella/pkg/api/local"
)

func TestEncryptedDirectTokenReloadedAfterUnlock(t *testing.T) {
	ctx := context.Background()
	dataDir := t.TempDir()
	cacheDir := t.TempDir()

	const passphrase = "correct horse battery staple!"
	const nodeID = "node-direct-1"
	const directToken = "direct-secret-token"

	setupSvc := NewMobileLogicService()
	setupSvc.dataDir = dataDir

	createResp, err := setupSvc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
		CommonName:   "Test User",
		Passphrase:   passphrase,
		Organization: "Nitella",
	})
	if err != nil {
		t.Fatalf("CreateIdentity() error = %v", err)
	}
	if !createResp.GetSuccess() {
		t.Fatalf("CreateIdentity() failed: %s", createResp.GetError())
	}

	if err := setupSvc.saveDirectNodeMetadata(nodeID, &pb.NodeInfo{
		NodeId:        nodeID,
		Name:          "Direct Node",
		ConnType:      pb.NodeConnectionType_NODE_CONNECTION_TYPE_DIRECT,
		DirectAddress: "127.0.0.1:19001",
		DirectToken:   directToken,
		DirectCaPem:   "",
	}); err != nil {
		t.Fatalf("saveDirectNodeMetadata() error = %v", err)
	}

	metaPath := filepath.Join(dataDir, "nodes", nodeID+".json")
	metaBytes, err := os.ReadFile(metaPath)
	if err != nil {
		t.Fatalf("read metadata error = %v", err)
	}
	if strings.Contains(string(metaBytes), directToken) {
		t.Fatalf("expected direct token to be encrypted at rest")
	}

	svc := NewMobileLogicService()
	initResp, err := svc.Initialize(ctx, &pb.InitializeRequest{
		DataDir:   dataDir,
		CacheDir:  cacheDir,
		DebugMode: true,
	})
	if err != nil {
		t.Fatalf("Initialize() error = %v", err)
	}
	if !initResp.GetSuccess() {
		t.Fatalf("Initialize() failed: %s", initResp.GetError())
	}
	if !initResp.GetIdentityLocked() {
		t.Fatalf("expected identity to be locked after restart")
	}

	lockedNode, ok := svc.nodes[nodeID]
	if !ok {
		t.Fatalf("expected direct node to be loaded")
	}
	if lockedNode.GetDirectToken() != "" {
		t.Fatalf("expected direct token to stay unavailable while locked, got %q", lockedNode.GetDirectToken())
	}
	if svc.directNodes != nil && len(svc.directNodes.clients) != 0 {
		t.Fatalf("expected no direct reconnect attempts while identity is locked")
	}

	unlockResp, err := svc.UnlockIdentity(ctx, &pb.UnlockIdentityRequest{
		Passphrase: passphrase,
	})
	if err != nil {
		t.Fatalf("UnlockIdentity() error = %v", err)
	}
	if !unlockResp.GetSuccess() {
		t.Fatalf("UnlockIdentity() failed: %s", unlockResp.GetError())
	}

	unlockedNode, ok := svc.nodes[nodeID]
	if !ok {
		t.Fatalf("expected direct node to remain loaded after unlock")
	}
	if unlockedNode.GetDirectToken() != directToken {
		t.Fatalf("expected decrypted direct token after unlock, got %q", unlockedNode.GetDirectToken())
	}
}
