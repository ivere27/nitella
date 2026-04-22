package main

import (
	"bufio"
	"bytes"
	"context"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
	"time"

	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/ivere27/nitella/pkg/identity"
	"github.com/ivere27/nitella/pkg/pairing"
)

func TestRustOfflinePairingTerminalSmoke(t *testing.T) {
	bin := os.Getenv("NITELLA_RS_BIN")
	if bin == "" {
		t.Skip("set NITELLA_RS_BIN to run the Rust offline pairing smoke")
	}

	dataDir := t.TempDir()
	nodeName := "rust-offline-smoke"
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, bin,
		"--hub", "127.0.0.1:1",
		"--pair-offline",
		"--hub-data-dir", dataDir,
		"--hub-node-name", nodeName,
	)
	stdin, err := cmd.StdinPipe()
	if err != nil {
		t.Fatalf("stdin pipe: %v", err)
	}
	stdoutPipe, err := cmd.StdoutPipe()
	if err != nil {
		t.Fatalf("stdout pipe: %v", err)
	}
	var stderr bytes.Buffer
	cmd.Stderr = &stderr

	if err := cmd.Start(); err != nil {
		t.Fatalf("start nitellad-rs offline pairing: %v", err)
	}

	reader := bufio.NewReader(stdoutPipe)
	qrData, stdout := readRustOfflineCSRPayload(t, reader)
	response, signedCertPEM, caCertPEM := buildRustOfflinePairingResponse(t, qrData, nodeName)

	if _, err := fmt.Fprintln(stdin, response); err != nil {
		t.Fatalf("write offline pairing response: %v", err)
	}
	_ = stdin.Close()

	readRustOfflinePairingSaved(t, reader, stdout)
	cancel()

	if err := cmd.Wait(); err != nil {
		if ctx.Err() == context.DeadlineExceeded {
			t.Fatalf("offline pairing timed out: %v\nstdout:\n%s\nstderr:\n%s", ctx.Err(), stdout.String(), stderr.String())
		}
		if ctx.Err() != context.Canceled {
			t.Fatalf("offline pairing failed: %v\nstdout:\n%s\nstderr:\n%s", err, stdout.String(), stderr.String())
		}
	}
	if err := ctx.Err(); err == context.DeadlineExceeded {
		t.Fatalf("offline pairing timed out: %v\nstdout:\n%s\nstderr:\n%s", err, stdout.String(), stderr.String())
	}
	if !strings.Contains(stdout.String(), "Certificate saved!") {
		t.Fatalf("offline pairing did not report certificate save\nstdout:\n%s\nstderr:\n%s", stdout.String(), stderr.String())
	}

	assertRustOfflinePairingFiles(t, dataDir, nodeName, signedCertPEM, caCertPEM)
}

func readRustOfflinePairingSaved(t *testing.T, reader *bufio.Reader, stdout *bytes.Buffer) {
	t.Helper()

	for {
		line, err := reader.ReadString('\n')
		stdout.WriteString(line)
		if strings.Contains(line, "Certificate saved!") {
			return
		}
		if err != nil {
			t.Fatalf("read Rust offline pairing completion: %v\nstdout:\n%s", err, stdout.String())
		}
	}
}

func readRustOfflineCSRPayload(t *testing.T, reader *bufio.Reader) (string, *bytes.Buffer) {
	t.Helper()

	var stdout bytes.Buffer
	for {
		line, err := reader.ReadString('\n')
		stdout.WriteString(line)
		trimmed := strings.TrimSpace(line)
		if strings.HasPrefix(trimmed, "{") && strings.Contains(trimmed, `"t":"csr"`) {
			return trimmed, &stdout
		}
		if err != nil {
			t.Fatalf("read Rust offline CSR payload: %v\nstdout:\n%s", err, stdout.String())
		}
	}
}

func buildRustOfflinePairingResponse(t *testing.T, qrData, nodeName string) (string, []byte, []byte) {
	t.Helper()

	payload, err := pairing.ParseQRPayload(qrData)
	if err != nil {
		t.Fatalf("parse Rust QR payload with Go parser: %v", err)
	}
	if payload.Type != "csr" {
		t.Fatalf("Rust QR payload type = %q, want csr", payload.Type)
	}
	if payload.NodeID != nodeName {
		t.Fatalf("Rust QR node id = %q, want %q", payload.NodeID, nodeName)
	}
	csrPEM, err := payload.GetCSR()
	if err != nil {
		t.Fatalf("decode Rust CSR payload: %v", err)
	}
	if got, want := payload.Fingerprint, pairing.DeriveFingerprint(csrPEM); got != want {
		t.Fatalf("Rust CSR fingerprint = %q, want %q", got, want)
	}

	ca, err := identity.Create(&identity.Config{
		CommonName: "rust-offline-smoke-ca",
		ValidYears: 1,
	})
	if err != nil {
		t.Fatalf("create Go signing identity: %v", err)
	}
	signedCertPEM, err := nitellacrypto.SignCSR(csrPEM, ca.RootCertPEM, ca.RootKey, 365)
	if err != nil {
		t.Fatalf("sign Rust CSR with Go signer: %v", err)
	}

	response := &pairing.QRPayload{
		Type:        "cert",
		Cert:        base64.StdEncoding.EncodeToString(signedCertPEM),
		CACert:      base64.StdEncoding.EncodeToString(ca.RootCertPEM),
		Fingerprint: pairing.DeriveFingerprint(signedCertPEM),
		NodeID:      payload.NodeID,
	}
	responseJSON, err := json.Marshal(response)
	if err != nil {
		t.Fatalf("marshal Go QR response: %v", err)
	}
	return string(responseJSON), signedCertPEM, ca.RootCertPEM
}

func assertRustOfflinePairingFiles(t *testing.T, dataDir, nodeName string, signedCertPEM, caCertPEM []byte) {
	t.Helper()

	keyPEM, err := os.ReadFile(filepath.Join(dataDir, "node.key"))
	if err != nil {
		t.Fatalf("read Rust offline node.key: %v", err)
	}
	if !bytes.Contains(keyPEM, []byte("BEGIN PRIVATE KEY")) {
		t.Fatalf("Rust offline node.key is not a PEM private key")
	}

	nodeCertPEM, err := os.ReadFile(filepath.Join(dataDir, "node.crt"))
	if err != nil {
		t.Fatalf("read Rust offline node.crt: %v", err)
	}
	if !bytes.Equal(nodeCertPEM, signedCertPEM) {
		t.Fatalf("Rust offline node.crt differs from Go-signed response")
	}

	savedCAPEM, err := os.ReadFile(filepath.Join(dataDir, "cli_ca.crt"))
	if err != nil {
		t.Fatalf("read Rust offline cli_ca.crt: %v", err)
	}
	if !bytes.Equal(savedCAPEM, caCertPEM) {
		t.Fatalf("Rust offline cli_ca.crt differs from Go CA response")
	}

	nodeCert := parseSmokeCertificatePEM(t, nodeCertPEM)
	caCert := parseSmokeCertificatePEM(t, savedCAPEM)
	if err := nodeCert.CheckSignatureFrom(caCert); err != nil {
		t.Fatalf("Rust offline node certificate is not signed by saved Go CA: %v", err)
	}
	if nodeCert.Subject.CommonName != nodeName {
		t.Fatalf("Rust offline node certificate CN = %q, want %q", nodeCert.Subject.CommonName, nodeName)
	}
}

func parseSmokeCertificatePEM(t *testing.T, certPEM []byte) *x509.Certificate {
	t.Helper()

	block, _ := pem.Decode(certPEM)
	if block == nil {
		t.Fatalf("decode certificate PEM")
	}
	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		t.Fatalf("parse certificate PEM: %v", err)
	}
	return cert
}
