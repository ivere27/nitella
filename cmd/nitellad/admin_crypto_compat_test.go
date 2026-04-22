package main

import (
	"crypto/ed25519"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	hubpb "github.com/ivere27/nitella/pkg/api/hub"
	pb "github.com/ivere27/nitella/pkg/api/proxy"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"google.golang.org/protobuf/proto"
)

type adminCryptoCompatFixture struct {
	NodeSeed   string                   `json:"node_seed"`
	ViewerSeed string                   `json:"viewer_seed"`
	Request    adminCryptoCompatRequest `json:"request"`
}

type adminCryptoCompatRequest struct {
	ViewerPubkey string                            `json:"viewer_pubkey"`
	Encrypted    adminCryptoCompatEncryptedPayload `json:"encrypted"`
}

type adminCryptoCompatResponse struct {
	Status       string                             `json:"status"`
	ErrorMessage string                             `json:"error_message"`
	Encrypted    *adminCryptoCompatEncryptedPayload `json:"encrypted"`
}

type adminCryptoCompatEncryptedPayload struct {
	EphemeralPubkey   string `json:"ephemeral_pubkey"`
	Nonce             string `json:"nonce"`
	Ciphertext        string `json:"ciphertext"`
	SenderFingerprint string `json:"sender_fingerprint"`
	Signature         string `json:"signature"`
	Algorithm         int32  `json:"algorithm"`
}

func TestAdminCryptoCompatFixtureGo(t *testing.T) {
	outPath := os.Getenv("NITELLA_ADMIN_COMPAT_FIXTURE")
	if outPath == "" {
		t.Skip("set NITELLA_ADMIN_COMPAT_FIXTURE to write Go admin crypto fixture")
	}

	nodeSeed := bytesOf(0x31, ed25519.SeedSize)
	viewerSeed := bytesOf(0x42, ed25519.SeedSize)
	nodePriv := ed25519.NewKeyFromSeed(nodeSeed)
	viewerPriv := ed25519.NewKeyFromSeed(viewerSeed)

	cmd := &hubpb.EncryptedCommandPayload{
		Type: hubpb.CommandType_COMMAND_TYPE_STATUS,
	}
	cmdBytes, err := proto.Marshal(cmd)
	if err != nil {
		t.Fatalf("marshal command payload: %v", err)
	}

	secure := &common.SecureCommandPayload{
		RequestId: "go-rust-admin-crypto-compat",
		Timestamp: time.Now().Add(55 * time.Second).Unix(),
		Data:      cmdBytes,
	}
	secureBytes, err := proto.Marshal(secure)
	if err != nil {
		t.Fatalf("marshal secure payload: %v", err)
	}

	encrypted, err := nitellacrypto.EncryptWithSignature(
		secureBytes,
		nodePriv.Public().(ed25519.PublicKey),
		viewerPriv,
		"viewer-compat",
	)
	if err != nil {
		t.Fatalf("encrypt request: %v", err)
	}

	fixture := adminCryptoCompatFixture{
		NodeSeed:   encodeCompatB64(nodeSeed),
		ViewerSeed: encodeCompatB64(viewerSeed),
		Request: adminCryptoCompatRequest{
			ViewerPubkey: encodeCompatB64(viewerPriv.Public().(ed25519.PublicKey)),
			Encrypted: adminCryptoCompatEncryptedPayload{
				EphemeralPubkey:   encodeCompatB64(encrypted.EphemeralPubKey),
				Nonce:             encodeCompatB64(encrypted.Nonce),
				Ciphertext:        encodeCompatB64(encrypted.Ciphertext),
				SenderFingerprint: encrypted.SenderFingerprint,
				Signature:         encodeCompatB64(encrypted.Signature),
				Algorithm:         int32(common.CryptoAlgorithm_ALGO_UNKNOWN),
			},
		},
	}

	data, err := json.MarshalIndent(fixture, "", "  ")
	if err != nil {
		t.Fatalf("marshal fixture json: %v", err)
	}
	if err := os.WriteFile(outPath, append(data, '\n'), 0o600); err != nil {
		t.Fatalf("write fixture: %v", err)
	}
}

func TestAdminCryptoCompatVerifyRustResponseGo(t *testing.T) {
	fixturePath := os.Getenv("NITELLA_ADMIN_COMPAT_FIXTURE")
	responsePath := os.Getenv("NITELLA_ADMIN_COMPAT_RESPONSE")
	if fixturePath == "" || responsePath == "" {
		t.Skip("set NITELLA_ADMIN_COMPAT_FIXTURE and NITELLA_ADMIN_COMPAT_RESPONSE")
	}

	var fixture adminCryptoCompatFixture
	readJSONCompat(t, fixturePath, &fixture)
	var response adminCryptoCompatResponse
	readJSONCompat(t, responsePath, &response)

	if response.Status != "OK" {
		t.Fatalf("Rust response status = %q, error = %q", response.Status, response.ErrorMessage)
	}
	if response.Encrypted == nil {
		t.Fatalf("Rust response did not include encrypted payload")
	}

	nodeSeed := decodeSeedCompat(t, fixture.NodeSeed)
	viewerSeed := decodeSeedCompat(t, fixture.ViewerSeed)
	nodePub := ed25519.NewKeyFromSeed(nodeSeed).Public().(ed25519.PublicKey)
	viewerPriv := ed25519.NewKeyFromSeed(viewerSeed)

	encrypted, err := response.Encrypted.toCryptoPayload()
	if err != nil {
		t.Fatalf("decode encrypted response: %v", err)
	}
	if err := nitellacrypto.VerifySignature(encrypted, nodePub); err != nil {
		t.Fatalf("verify Rust response signature with Go crypto: %v", err)
	}

	plaintext, err := nitellacrypto.Decrypt(encrypted, viewerPriv)
	if err != nil {
		t.Fatalf("decrypt Rust response with Go crypto: %v", err)
	}

	var result hubpb.CommandResult
	if err := proto.Unmarshal(plaintext, &result); err != nil {
		t.Fatalf("unmarshal command result: %v", err)
	}
	if result.Status != "OK" || result.ErrorMessage != "" {
		t.Fatalf("command result status = %q, error = %q", result.Status, result.ErrorMessage)
	}

	var stats pb.StatsSummaryResponse
	if err := proto.Unmarshal(result.ResponsePayload, &stats); err != nil {
		t.Fatalf("unmarshal stats payload: %v", err)
	}
	if stats.ProxyCount != 0 || stats.ActiveConnections != 0 {
		t.Fatalf("unexpected empty-node stats: proxy_count=%d active_connections=%d", stats.ProxyCount, stats.ActiveConnections)
	}
}

func (p adminCryptoCompatEncryptedPayload) toCryptoPayload() (*nitellacrypto.EncryptedPayload, error) {
	ephemeral, err := decodeCompatB64(p.EphemeralPubkey)
	if err != nil {
		return nil, fmt.Errorf("ephemeral_pubkey: %w", err)
	}
	nonce, err := decodeCompatB64(p.Nonce)
	if err != nil {
		return nil, fmt.Errorf("nonce: %w", err)
	}
	ciphertext, err := decodeCompatB64(p.Ciphertext)
	if err != nil {
		return nil, fmt.Errorf("ciphertext: %w", err)
	}
	signature, err := decodeCompatB64(p.Signature)
	if err != nil {
		return nil, fmt.Errorf("signature: %w", err)
	}
	return &nitellacrypto.EncryptedPayload{
		EphemeralPubKey:   ephemeral,
		Nonce:             nonce,
		Ciphertext:        ciphertext,
		SenderFingerprint: p.SenderFingerprint,
		Signature:         signature,
	}, nil
}

func readJSONCompat(t *testing.T, path string, out interface{}) {
	t.Helper()
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("read %s: %v", path, err)
	}
	if err := json.Unmarshal(data, out); err != nil {
		t.Fatalf("parse %s: %v", path, err)
	}
}

func decodeSeedCompat(t *testing.T, encoded string) []byte {
	t.Helper()
	seed, err := decodeCompatB64(encoded)
	if err != nil {
		t.Fatalf("decode seed: %v", err)
	}
	if len(seed) != ed25519.SeedSize {
		t.Fatalf("seed length = %d, want %d", len(seed), ed25519.SeedSize)
	}
	return seed
}

func decodeCompatB64(encoded string) ([]byte, error) {
	return base64.StdEncoding.DecodeString(encoded)
}

func encodeCompatB64(data []byte) string {
	return base64.StdEncoding.EncodeToString(data)
}

func bytesOf(value byte, length int) []byte {
	out := make([]byte, length)
	for i := range out {
		out[i] = value
	}
	return out
}
