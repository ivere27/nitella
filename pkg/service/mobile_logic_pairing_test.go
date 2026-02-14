package service

import (
	"bytes"
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"path/filepath"
	"strings"
	"testing"

	pb "github.com/ivere27/nitella/pkg/api/local"
	"github.com/ivere27/nitella/pkg/identity"
	"github.com/ivere27/nitella/pkg/pairing"
)

func TestDecodeCSRFromQRData_SupportsAllOfflineFormats(t *testing.T) {
	csrPEM, _ := generateTestCSR(t, "decode-node")

	// Standard QR payload format (base64 CSR).
	stdPayload := pairing.QRPayload{
		Type:        "csr",
		CSR:         base64.StdEncoding.EncodeToString(csrPEM),
		NodeID:      "decode-node",
		Fingerprint: pairing.DeriveFingerprint(csrPEM),
	}
	stdJSON, err := json.Marshal(stdPayload)
	if err != nil {
		t.Fatalf("marshal std payload: %v", err)
	}

	gotCSR, gotNodeID, err := decodeCSRFromQRData(stdJSON)
	if err != nil {
		t.Fatalf("decode std payload: %v", err)
	}
	if gotNodeID != "decode-node" {
		t.Fatalf("node id mismatch: got %q", gotNodeID)
	}
	if !bytes.Equal(gotCSR, csrPEM) {
		t.Fatalf("csr mismatch for std payload")
	}

	// nitellad terminal fallback currently prints raw PEM in the `csr` field.
	rawPayload := map[string]string{
		"t":   "csr",
		"csr": string(csrPEM),
		"nid": "decode-node-raw",
		"fp":  pairing.DeriveFingerprint(csrPEM),
	}
	rawJSON, err := json.Marshal(rawPayload)
	if err != nil {
		t.Fatalf("marshal raw payload: %v", err)
	}

	gotCSR, gotNodeID, err = decodeCSRFromQRData(rawJSON)
	if err != nil {
		t.Fatalf("decode raw payload: %v", err)
	}
	if gotNodeID != "decode-node-raw" {
		t.Fatalf("node id mismatch (raw): got %q", gotNodeID)
	}
	if !bytes.Equal(gotCSR, csrPEM) {
		t.Fatalf("csr mismatch for raw payload")
	}

	// Manual fallback: raw PEM pasted directly.
	gotCSR, gotNodeID, err = decodeCSRFromQRData(csrPEM)
	if err != nil {
		t.Fatalf("decode raw pem: %v", err)
	}
	if gotNodeID != "" {
		t.Fatalf("expected empty node hint for raw pem, got %q", gotNodeID)
	}
	if string(bytes.TrimSpace(gotCSR)) != string(bytes.TrimSpace(csrPEM)) {
		t.Fatalf("csr mismatch for raw pem")
	}
}

func TestOfflineQRPairing_SignsCSRAndReturnsCertPayload(t *testing.T) {
	ctx := context.Background()
	dataDir := t.TempDir()

	svc := NewMobileLogicService()
	initResp, err := svc.Initialize(ctx, &pb.InitializeRequest{
		DataDir:  dataDir,
		CacheDir: filepath.Join(dataDir, "cache"),
	})
	if err != nil {
		t.Fatalf("initialize: %v", err)
	}
	if initResp == nil || !initResp.Success {
		t.Fatalf("initialize unsuccessful: %+v", initResp)
	}

	createResp, err := svc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
		CommonName: "test-mobile-logic",
	})
	if err != nil {
		t.Fatalf("create identity: %v", err)
	}
	if createResp == nil || !createResp.Success {
		t.Fatalf("create identity unsuccessful: %+v", createResp)
	}

	const nodeID = "offline-node-1"
	csrPEM, nodePub := generateTestCSR(t, nodeID)
	qrPayload := pairing.QRPayload{
		Type:        "csr",
		CSR:         base64.StdEncoding.EncodeToString(csrPEM),
		NodeID:      nodeID,
		Fingerprint: pairing.DeriveFingerprint(csrPEM),
	}
	qrJSON, err := json.Marshal(qrPayload)
	if err != nil {
		t.Fatalf("marshal qr payload: %v", err)
	}

	scanResp, err := svc.ScanQRCode(ctx, &pb.ScanQRCodeRequest{
		QrData: qrJSON,
	})
	if err != nil {
		t.Fatalf("scan qr: %v", err)
	}
	if scanResp == nil || !scanResp.Success {
		t.Fatalf("scan qr unsuccessful: %+v", scanResp)
	}
	if scanResp.NodeId != nodeID {
		t.Fatalf("scan node id mismatch: got %q want %q", scanResp.NodeId, nodeID)
	}
	if scanResp.SessionId == "" {
		t.Fatalf("scan response missing session id: %+v", scanResp)
	}
	if scanResp.CsrPem == "" || scanResp.Fingerprint == "" || scanResp.EmojiHash == "" {
		t.Fatalf("scan response missing fields: %+v", scanResp)
	}

	replyResp, err := svc.FinalizePairing(ctx, &pb.FinalizePairingRequest{
		SessionId: scanResp.SessionId,
		Accepted:  true,
	})
	if err != nil {
		t.Fatalf("finalize pairing: %v", err)
	}
	if replyResp == nil || !replyResp.Success || len(replyResp.QrData) == 0 {
		t.Fatalf("empty qr reply response")
	}
	if replyResp.Node == nil || replyResp.Node.NodeId != nodeID {
		t.Fatalf("node registration missing/mismatch: %+v", replyResp.Node)
	}
	wantFingerprint := identity.GenerateFingerprint(nodePub)
	if replyResp.Node.Fingerprint != wantFingerprint {
		t.Fatalf("node fingerprint mismatch: got %q want %q", replyResp.Node.Fingerprint, wantFingerprint)
	}

	parsedReply, err := pairing.ParseQRPayload(string(replyResp.QrData))
	if err != nil {
		t.Fatalf("parse reply payload: %v", err)
	}
	if parsedReply.Type != "cert" {
		t.Fatalf("unexpected reply type: %q", parsedReply.Type)
	}

	signedCertPEM, err := parsedReply.GetCert()
	if err != nil {
		t.Fatalf("decode signed cert: %v", err)
	}
	caPEM, err := parsedReply.GetCACert()
	if err != nil {
		t.Fatalf("decode ca cert: %v", err)
	}
	if len(caPEM) == 0 {
		t.Fatalf("missing CA cert in reply payload")
	}

	cert := parseCertificate(t, signedCertPEM)
	caCert := parseCertificate(t, caPEM)

	// Signed certificate must bind to the node's CSR public key.
	certPub, ok := cert.PublicKey.(ed25519.PublicKey)
	if !ok {
		t.Fatalf("signed cert public key is not ed25519")
	}
	if !bytes.Equal(certPub, nodePub) {
		t.Fatalf("signed cert public key does not match CSR key")
	}

	roots := x509.NewCertPool()
	roots.AddCert(caCert)
	if _, err := cert.Verify(x509.VerifyOptions{Roots: roots}); err != nil {
		t.Fatalf("certificate chain verification failed: %v", err)
	}
}

func TestFinalizePairing_RejectOfflineSessionCancels(t *testing.T) {
	ctx := context.Background()
	dataDir := t.TempDir()

	svc := NewMobileLogicService()
	initResp, err := svc.Initialize(ctx, &pb.InitializeRequest{
		DataDir:  dataDir,
		CacheDir: filepath.Join(dataDir, "cache"),
	})
	if err != nil {
		t.Fatalf("initialize: %v", err)
	}
	if initResp == nil || !initResp.Success {
		t.Fatalf("initialize unsuccessful: %+v", initResp)
	}

	createResp, err := svc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
		CommonName: "test-mobile-logic",
	})
	if err != nil {
		t.Fatalf("create identity: %v", err)
	}
	if createResp == nil || !createResp.Success {
		t.Fatalf("create identity unsuccessful: %+v", createResp)
	}

	const nodeID = "offline-node-reject"
	csrPEM, _ := generateTestCSR(t, nodeID)
	qrPayload := pairing.QRPayload{
		Type:        "csr",
		CSR:         base64.StdEncoding.EncodeToString(csrPEM),
		NodeID:      nodeID,
		Fingerprint: pairing.DeriveFingerprint(csrPEM),
	}
	qrJSON, err := json.Marshal(qrPayload)
	if err != nil {
		t.Fatalf("marshal qr payload: %v", err)
	}

	scanResp, err := svc.ScanQRCode(ctx, &pb.ScanQRCodeRequest{QrData: qrJSON})
	if err != nil {
		t.Fatalf("scan qr: %v", err)
	}
	if scanResp == nil || !scanResp.Success || scanResp.SessionId == "" {
		t.Fatalf("scan qr unsuccessful: %+v", scanResp)
	}

	rejectResp, err := svc.FinalizePairing(ctx, &pb.FinalizePairingRequest{
		SessionId: scanResp.SessionId,
		Accepted:  false,
	})
	if err != nil {
		t.Fatalf("finalize reject: %v", err)
	}
	if !rejectResp.Success || !rejectResp.Cancelled {
		t.Fatalf("expected cancelled finalize response: %+v", rejectResp)
	}

	// Session should be consumed after rejection.
	approveResp, err := svc.FinalizePairing(ctx, &pb.FinalizePairingRequest{
		SessionId: scanResp.SessionId,
		Accepted:  true,
	})
	if err != nil {
		t.Fatalf("finalize approve after reject: %v", err)
	}
	if approveResp.Success {
		t.Fatalf("expected failure after rejected session consumption: %+v", approveResp)
	}
	if !strings.Contains(approveResp.Error, "session not found") {
		t.Fatalf("unexpected error after reject: %q", approveResp.Error)
	}
}

func TestGenerateQRResponse_RequiresScanSessionID(t *testing.T) {
	ctx := context.Background()
	dataDir := t.TempDir()

	svc := NewMobileLogicService()
	initResp, err := svc.Initialize(ctx, &pb.InitializeRequest{
		DataDir:  dataDir,
		CacheDir: filepath.Join(dataDir, "cache"),
	})
	if err != nil {
		t.Fatalf("initialize: %v", err)
	}
	if initResp == nil || !initResp.Success {
		t.Fatalf("initialize unsuccessful: %+v", initResp)
	}

	createResp, err := svc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
		CommonName: "test-mobile-logic",
	})
	if err != nil {
		t.Fatalf("create identity: %v", err)
	}
	if createResp == nil || !createResp.Success {
		t.Fatalf("create identity unsuccessful: %+v", createResp)
	}

	csrPEM, _ := generateTestCSR(t, "offline-node-require-session")

	_, err = svc.GenerateQRResponse(ctx, &pb.GenerateQRReplyRequest{
		NodeId: "offline-node-require-session",
		CsrPem: string(csrPEM),
	})
	if err == nil {
		t.Fatalf("expected error when scan_session_id is missing")
	}
	if !strings.Contains(err.Error(), "scan_session_id is required") {
		t.Fatalf("unexpected error: %v", err)
	}
}

func generateTestCSR(t *testing.T, nodeID string) ([]byte, ed25519.PublicKey) {
	t.Helper()

	pub, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatalf("generate key: %v", err)
	}

	template := &x509.CertificateRequest{
		Subject: pkix.Name{CommonName: nodeID},
		DNSNames: []string{
			nodeID,
		},
	}
	csrDER, err := x509.CreateCertificateRequest(rand.Reader, template, priv)
	if err != nil {
		t.Fatalf("create csr: %v", err)
	}
	return pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE REQUEST", Bytes: csrDER}), pub
}

func parseCertificate(t *testing.T, certPEM []byte) *x509.Certificate {
	t.Helper()
	block, _ := pem.Decode(certPEM)
	if block == nil {
		t.Fatalf("failed to decode certificate PEM")
	}
	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		t.Fatalf("parse certificate: %v", err)
	}
	return cert
}
