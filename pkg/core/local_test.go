package core

import (
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"testing"

	"github.com/ivere27/nitella/pkg/api/common"
	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/ivere27/nitella/pkg/identity"
	"google.golang.org/grpc"
	"google.golang.org/protobuf/proto"
)

// mockProxyControlClient simulates a local nitellad.
// It decrypts incoming commands using the node's private key,
// and encrypts responses back to the viewer.
type mockProxyControlClient struct {
	pbProxy.ProxyControlServiceClient

	nodePrivKey ed25519.PrivateKey
	nodePubKey  ed25519.PublicKey

	// Captured request for assertions
	lastRequest *pbProxy.SendCommandRequest
	// Configurable response
	responseStatus  string
	responsePayload []byte
	responseErr     error
}

func (m *mockProxyControlClient) SendCommand(ctx context.Context, req *pbProxy.SendCommandRequest, _ ...grpc.CallOption) (*pbProxy.SendCommandResponse, error) {
	if m.responseErr != nil {
		return nil, m.responseErr
	}
	m.lastRequest = req

	// Decrypt the incoming command to validate it
	enc := req.Encrypted
	payload := &nitellacrypto.EncryptedPayload{
		EphemeralPubKey:   enc.EphemeralPubkey,
		Nonce:             enc.Nonce,
		Ciphertext:        enc.Ciphertext,
		SenderFingerprint: enc.SenderFingerprint,
		Signature:         enc.Signature,
	}
	_, err := nitellacrypto.Decrypt(payload, m.nodePrivKey)
	if err != nil {
		return &pbProxy.SendCommandResponse{
			Status:       "ERROR",
			ErrorMessage: "decrypt failed: " + err.Error(),
		}, nil
	}

	// Build CommandResult response
	result := &pbHub.CommandResult{
		Status:          m.responseStatus,
		ResponsePayload: m.responsePayload,
	}
	resultBytes, err := proto.Marshal(result)
	if err != nil {
		return nil, err
	}

	// Encrypt response back to the viewer (using ViewerPubkey from request)
	viewerPubKey := ed25519.PublicKey(req.ViewerPubkey)
	encResp, err := nitellacrypto.EncryptWithSignature(resultBytes, viewerPubKey, m.nodePrivKey, "node-fingerprint")
	if err != nil {
		return nil, err
	}

	return &pbProxy.SendCommandResponse{
		Encrypted: &common.EncryptedPayload{
			EphemeralPubkey:   encResp.EphemeralPubKey,
			Nonce:             encResp.Nonce,
			Ciphertext:        encResp.Ciphertext,
			SenderFingerprint: encResp.SenderFingerprint,
			Signature:         encResp.Signature,
		},
		Status: "OK",
	}, nil
}

// newTestKeypair generates a fresh Ed25519 keypair for testing.
func newTestKeypair(t *testing.T) (ed25519.PublicKey, ed25519.PrivateKey) {
	t.Helper()
	pub, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatalf("GenerateKey: %v", err)
	}
	return pub, priv
}

// newTestIdentity creates a minimal Identity for testing.
func newTestIdentity(t *testing.T) *identity.Identity {
	t.Helper()
	id, err := identity.Create(&identity.Config{
		CommonName: "test-cli",
		ValidYears: 1,
	})
	if err != nil {
		t.Fatalf("identity.Create: %v", err)
	}
	return id
}

func TestSetLocalConnection(t *testing.T) {
	ctrl := New(Config{})
	nodePub, _ := newTestKeypair(t)

	lc := &LocalConnection{
		Client:     &mockProxyControlClient{},
		Token:      "test-token",
		NodePubKey: nodePub,
	}

	ctrl.SetLocalConnection("node-1", lc)

	// Verify it's stored
	ctrl.mu.RLock()
	got := ctrl.localClients["node-1"]
	gotKey := ctrl.nodePublicKeys["node-1"]
	ctrl.mu.RUnlock()

	if got != lc {
		t.Fatal("SetLocalConnection did not store the connection")
	}
	if !gotKey.Equal(nodePub) {
		t.Fatal("SetLocalConnection did not register the node public key")
	}
}

func TestRemoveLocalConnection(t *testing.T) {
	ctrl := New(Config{})
	nodePub, _ := newTestKeypair(t)

	lc := &LocalConnection{
		Client:     &mockProxyControlClient{},
		NodePubKey: nodePub,
	}
	ctrl.SetLocalConnection("node-1", lc)
	ctrl.RemoveLocalConnection("node-1")

	ctrl.mu.RLock()
	got := ctrl.localClients["node-1"]
	ctrl.mu.RUnlock()

	if got != nil {
		t.Fatal("RemoveLocalConnection did not remove the connection")
	}
}

func TestSendCommandLocal_E2E(t *testing.T) {
	// Generate keys for node and user
	nodePub, nodePriv := newTestKeypair(t)
	id := newTestIdentity(t)

	mock := &mockProxyControlClient{
		nodePrivKey:     nodePriv,
		nodePubKey:      nodePub,
		responseStatus:  "OK",
		responsePayload: []byte("test-response-data"),
	}

	lc := &LocalConnection{
		Client:     mock,
		Token:      "bearer-token",
		NodePubKey: nodePub,
	}

	result, err := SendCommandLocal(
		context.Background(),
		lc,
		pbHub.CommandType_COMMAND_TYPE_LIST_RULES,
		[]byte("request-payload"),
		id.RootKey,
		id.Fingerprint,
	)
	if err != nil {
		t.Fatalf("SendCommandLocal: %v", err)
	}

	if result.Status != "OK" {
		t.Errorf("Status = %q, want %q", result.Status, "OK")
	}
	if string(result.ResponsePayload) != "test-response-data" {
		t.Errorf("ResponsePayload = %q, want %q", result.ResponsePayload, "test-response-data")
	}

	// Verify the mock received a request
	if mock.lastRequest == nil {
		t.Fatal("mock did not receive a request")
	}
	// Verify viewer public key was sent
	expectedPub := id.RootKey.Public().(ed25519.PublicKey)
	if !ed25519.PublicKey(mock.lastRequest.ViewerPubkey).Equal(expectedPub) {
		t.Error("ViewerPubkey in request does not match identity public key")
	}
}

func TestSendCommandLocal_NilNodeKey(t *testing.T) {
	id := newTestIdentity(t)

	lc := &LocalConnection{
		Client:     &mockProxyControlClient{},
		NodePubKey: nil, // no key
	}

	_, err := SendCommandLocal(
		context.Background(),
		lc,
		pbHub.CommandType_COMMAND_TYPE_LIST_RULES,
		nil,
		id.RootKey,
		id.Fingerprint,
	)
	if err == nil {
		t.Fatal("expected error for nil NodePubKey")
	}
}

func TestSendCommand_RoutesToLocal(t *testing.T) {
	// Setup Controller with identity + local connection
	nodePub, nodePriv := newTestKeypair(t)
	id := newTestIdentity(t)

	mock := &mockProxyControlClient{
		nodePrivKey:     nodePriv,
		nodePubKey:      nodePub,
		responseStatus:  "OK",
		responsePayload: []byte("local-response"),
	}

	ctrl := New(Config{})
	ctrl.SetIdentity(id)
	ctrl.SetLocalConnection("local-node", &LocalConnection{
		Client:     mock,
		Token:      "tok",
		NodePubKey: nodePub,
	})

	result, err := ctrl.SendCommand(context.Background(), "local-node", pbHub.CommandType_COMMAND_TYPE_STATUS, nil)
	if err != nil {
		t.Fatalf("SendCommand via local: %v", err)
	}
	if result.Status != "OK" {
		t.Errorf("Status = %q, want %q", result.Status, "OK")
	}
	if string(result.ResponsePayload) != "local-response" {
		t.Errorf("ResponsePayload = %q, want %q", result.ResponsePayload, "local-response")
	}

	// Verify the mock was called (not Hub)
	if mock.lastRequest == nil {
		t.Fatal("expected local mock to be called, but it was not")
	}
}

func TestSendCommand_NoLocalFallsToHub(t *testing.T) {
	// Controller with identity but no local connection and no hub → should error
	id := newTestIdentity(t)

	ctrl := New(Config{})
	ctrl.SetIdentity(id)

	_, err := ctrl.SendCommand(context.Background(), "unknown-node", pbHub.CommandType_COMMAND_TYPE_STATUS, nil)
	if err == nil {
		t.Fatal("expected error when no local, no P2P, and no Hub")
	}
}

func TestSendCommand_NoIdentity(t *testing.T) {
	ctrl := New(Config{})

	_, err := ctrl.SendCommand(context.Background(), "node", pbHub.CommandType_COMMAND_TYPE_STATUS, nil)
	if err == nil {
		t.Fatal("expected error when identity not set")
	}
}
