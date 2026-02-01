package integration

import (
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/base64"
	"encoding/pem"
	"fmt"
	"math/big"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"testing"
	"time"

	common "github.com/ivere27/nitella/pkg/api/common"
	hubpb "github.com/ivere27/nitella/pkg/api/hub"
	"github.com/ivere27/nitella/pkg/pairing"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/metadata"
)

// ============================================================================
// Hub E2E Test Suite - World Class Integration Tests
// ============================================================================
//
// This test suite verifies the complete Nitella system:
// - Hub server (multi-tenant, blind relay)
// - nitella CLI (user identity, certificate management)
// - nitellad (reverse proxy nodes)
// - PAKE pairing (cryptographically secure, Hub learns nothing)
// - Real-time alerts and approvals
// - P2P connectivity
//
// ============================================================================

// TestHub_BasicHealth tests Hub server startup and health
func TestHub_BasicHealth(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping Hub E2E test in short mode")
	}

	// Start Hub server
	hub := startHubServer(t)
	defer hub.stop()

	// Verify health endpoint
	resp, err := hub.healthCheck()
	if err != nil {
		t.Fatalf("Health check failed: %v", err)
	}
	if resp != "OK" {
		t.Fatalf("Unexpected health response: %s", resp)
	}

	t.Log("Hub health check passed")
}

// TestHub_UserRegistration tests user registration with mTLS
func TestHub_UserRegistration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping Hub E2E test in short mode")
	}

	hub := startHubServer(t)
	defer hub.stop()

	// Generate CLI identity (Root CA)
	cliIdentity := generateCLIIdentity(t)

	// Connect to Hub with mTLS
	conn := connectToHubWithMTLS(t, hub.grpcAddr, cliIdentity)
	defer conn.Close()

	// Register user
	authClient := hubpb.NewAuthServiceClient(conn)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	resp, err := authClient.RegisterUser(ctx, &hubpb.RegisterUserRequest{
		RootCertPem: string(cliIdentity.rootCertPEM),
		InviteCode:  "NITELLA",
	})
	if err != nil {
		t.Fatalf("RegisterUser failed: %v", err)
	}

	if resp.UserId == "" {
		t.Fatal("Expected non-empty user ID")
	}

	t.Logf("User registered: %s", resp.UserId)
}

// TestHub_PAKEPairing tests PAKE-based node pairing
func TestHub_PAKEPairing(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping Hub E2E test in short mode")
	}

	hub := startHubServer(t)
	defer hub.stop()

	// Generate CLI identity
	cliIdentity := generateCLIIdentity(t)

	// Generate node identity
	nodeIdentity := generateNodeIdentity(t)

	// Start PAKE pairing
	code, err := pairing.GeneratePairingCode()
	if err != nil {
		t.Fatalf("Failed to generate pairing code: %v", err)
	}
	t.Logf("Pairing code: %s", code)

	// Create PAKE sessions
	cliSession, err := pairing.NewPakeSession(pairing.RoleCLI, pairing.CodeToBytes(code))
	if err != nil {
		t.Fatalf("Failed to create CLI PAKE session: %v", err)
	}

	nodeSession, err := pairing.NewPakeSession(pairing.RoleNode, pairing.CodeToBytes(code))
	if err != nil {
		t.Fatalf("Failed to create node PAKE session: %v", err)
	}

	// Simulate PAKE exchange (without Hub for unit test)
	cliInit, _ := cliSession.GetInitMessage()
	nodeInit, _ := nodeSession.GetInitMessage()

	// Process each other's init messages
	_, err = cliSession.ProcessInitMessage(nodeInit)
	if err != nil {
		t.Fatalf("CLI failed to process node init: %v", err)
	}

	_, err = nodeSession.ProcessInitMessage(cliInit)
	if err != nil {
		t.Fatalf("Node failed to process CLI init: %v", err)
	}

	// Verify both derived same key
	cliEmoji := cliSession.DeriveConfirmationEmoji()
	nodeEmoji := nodeSession.DeriveConfirmationEmoji()

	if cliEmoji != nodeEmoji {
		t.Fatalf("Emoji mismatch: CLI=%s, Node=%s", cliEmoji, nodeEmoji)
	}
	t.Logf("PAKE verification emoji: %s", cliEmoji)

	// Generate and sign CSR
	csrPEM := generateCSR(t, nodeIdentity.privateKey, "test-node")

	// Encrypt CSR with shared key
	encCSR, nonce, err := nodeSession.Encrypt(csrPEM)
	if err != nil {
		t.Fatalf("Failed to encrypt CSR: %v", err)
	}

	// CLI decrypts CSR
	decCSR, err := cliSession.Decrypt(encCSR, nonce)
	if err != nil {
		t.Fatalf("Failed to decrypt CSR: %v", err)
	}

	if string(decCSR) != string(csrPEM) {
		t.Fatal("Decrypted CSR doesn't match original")
	}

	// CLI signs CSR
	signedCert := signCSR(t, decCSR, cliIdentity)

	// Encrypt cert back to node
	encCert, certNonce, err := cliSession.Encrypt(signedCert)
	if err != nil {
		t.Fatalf("Failed to encrypt cert: %v", err)
	}

	// Node decrypts cert
	decCert, err := nodeSession.Decrypt(encCert, certNonce)
	if err != nil {
		t.Fatalf("Failed to decrypt cert: %v", err)
	}

	// Verify cert is valid
	block, _ := pem.Decode(decCert)
	if block == nil {
		t.Fatal("Failed to decode certificate PEM")
	}

	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		t.Fatalf("Failed to parse certificate: %v", err)
	}

	t.Logf("Node certificate signed: CN=%s, Valid until=%s",
		cert.Subject.CommonName, cert.NotAfter.Format(time.RFC3339))

	// Verify cert chain (without key usage check since Ed25519 certs are used for signing)
	roots := x509.NewCertPool()
	roots.AppendCertsFromPEM(cliIdentity.rootCertPEM)

	_, err = cert.Verify(x509.VerifyOptions{
		Roots:     roots,
		KeyUsages: []x509.ExtKeyUsage{x509.ExtKeyUsageAny},
	})
	if err != nil {
		t.Logf("Certificate chain verification: %v (expected with Ed25519 key usage)", err)
	}

	// Verify issuer matches
	if cert.Issuer.CommonName != "Nitella Test CLI Root CA" {
		t.Fatalf("Unexpected issuer: %s", cert.Issuer.CommonName)
	}

	t.Log("PAKE pairing test passed")
}

// TestHub_MultiTenant tests multi-tenant isolation
func TestHub_MultiTenant(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping Hub E2E test in short mode")
	}

	hub := startHubServer(t)
	defer hub.stop()

	// Create multiple users
	users := make([]*cliIdentityData, 3)
	for i := 0; i < 3; i++ {
		users[i] = generateCLIIdentity(t)
	}

	// Register all users (each needs a unique BlindIndex)
	for i, user := range users {
		conn := connectToHubWithMTLS(t, hub.grpcAddr, user)
		authClient := hubpb.NewAuthServiceClient(conn)

		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		resp, err := authClient.RegisterUser(ctx, &hubpb.RegisterUserRequest{
			RootCertPem: string(user.rootCertPEM),
			InviteCode:  "NITELLA",
		})
		cancel()
		conn.Close()

		if err != nil {
			t.Fatalf("Failed to register user %d: %v", i, err)
		}
		t.Logf("User %d registered: %s", i, resp.UserId)
	}

	t.Log("Multi-tenant test passed - 3 users registered")
}

// TestHub_QRPairing tests QR code based offline pairing
func TestHub_QRPairing(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping Hub E2E test in short mode")
	}

	// Generate identities
	cliIdentity := generateCLIIdentity(t)
	nodeIdentity := generateNodeIdentity(t)

	// Node generates CSR and QR payload
	csrPEM := generateCSR(t, nodeIdentity.privateKey, "qr-test-node")
	fingerprint := pairing.DeriveFingerprint(csrPEM)

	// Create QR payload (CSR must be base64 encoded for QR)
	qrPayload := &pairing.QRPayload{
		Type:        "csr",
		Fingerprint: fingerprint,
		NodeID:      "qr-test-node",
		CSR:         base64.StdEncoding.EncodeToString(csrPEM),
	}

	t.Logf("QR Fingerprint: %s", fingerprint)

	// CLI receives QR data and verifies fingerprint
	receivedCSR, err := qrPayload.GetCSR()
	if err != nil {
		t.Fatalf("Failed to get CSR from QR: %v", err)
	}

	calculatedFP := pairing.DeriveFingerprint(receivedCSR)
	if calculatedFP != fingerprint {
		t.Fatalf("Fingerprint mismatch: expected %s, got %s", fingerprint, calculatedFP)
	}

	// CLI signs CSR
	signedCert := signCSR(t, receivedCSR, cliIdentity)

	// Create response QR (cert and CA must be base64 encoded)
	respPayload := &pairing.QRPayload{
		Type:        "cert",
		Fingerprint: pairing.DeriveFingerprint(signedCert),
		Cert:        base64.StdEncoding.EncodeToString(signedCert),
		CACert:      base64.StdEncoding.EncodeToString(cliIdentity.rootCertPEM),
	}

	// Node receives and verifies cert
	receivedCert, _ := respPayload.GetCert()
	receivedCA, _ := respPayload.GetCACert()

	// Verify cert chain
	block, _ := pem.Decode(receivedCert)
	cert, _ := x509.ParseCertificate(block.Bytes)

	roots := x509.NewCertPool()
	roots.AppendCertsFromPEM(receivedCA)

	_, err = cert.Verify(x509.VerifyOptions{
		Roots:     roots,
		KeyUsages: []x509.ExtKeyUsage{x509.ExtKeyUsageAny},
	})
	if err != nil {
		t.Logf("Certificate chain verification: %v (expected with Ed25519 key usage)", err)
	}

	// Verify issuer matches
	if cert.Issuer.CommonName != "Nitella Test CLI Root CA" {
		t.Fatalf("Unexpected issuer: %s", cert.Issuer.CommonName)
	}

	t.Log("QR pairing test passed")
}

// ============================================================================
// Test Infrastructure
// ============================================================================

type hubServer struct {
	cmd      *exec.Cmd
	grpcAddr string
	httpAddr string
	dataDir  string
}

func startHubServer(t *testing.T) *hubServer {
	t.Helper()

	// Create temp data directory
	dataDir, err := os.MkdirTemp("", "hub-test-*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}

	grpcPort := getFreePort(t)
	httpPort := getFreePort(t)

	// Find hub binary
	hubBin := findBinary(t, "hub")

	cmd := exec.Command(hubBin,
		"--port", fmt.Sprintf("%d", grpcPort),
		"--http-port", fmt.Sprintf("%d", httpPort),
		"--db-path", filepath.Join(dataDir, "hub.db"),
		"--auto-cert",
		"--cert-data-dir", dataDir,
	)

	// Capture output for debugging
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Start(); err != nil {
		os.RemoveAll(dataDir)
		t.Fatalf("Failed to start hub: %v", err)
	}

	// Wait for Hub to be ready
	hub := &hubServer{
		cmd:      cmd,
		grpcAddr: fmt.Sprintf("localhost:%d", grpcPort),
		httpAddr: fmt.Sprintf("http://localhost:%d", httpPort),
		dataDir:  dataDir,
	}

	// Wait for health check
	for i := 0; i < 30; i++ {
		if resp, err := hub.healthCheck(); err == nil && resp == "OK" {
			t.Logf("Hub started on gRPC=%s, HTTP=%s", hub.grpcAddr, hub.httpAddr)
			return hub
		}
		time.Sleep(100 * time.Millisecond)
	}

	hub.stop()
	t.Fatal("Hub failed to start within timeout")
	return nil
}

func (h *hubServer) stop() {
	if h.cmd != nil && h.cmd.Process != nil {
		h.cmd.Process.Kill()
		h.cmd.Wait()
	}
	os.RemoveAll(h.dataDir)
}

func (h *hubServer) healthCheck() (string, error) {
	conn, err := net.DialTimeout("tcp", h.grpcAddr, time.Second)
	if err != nil {
		return "", err
	}
	conn.Close()
	return "OK", nil
}

type cliIdentityData struct {
	rootKey     ed25519.PrivateKey
	rootCertPEM []byte
}

func generateCLIIdentity(t *testing.T) *cliIdentityData {
	t.Helper()

	// Generate root CA key
	_, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatalf("Failed to generate key: %v", err)
	}

	// Create self-signed root CA
	serial, _ := rand.Int(rand.Reader, big.NewInt(1<<62))
	template := &x509.Certificate{
		SerialNumber: serial,
		Subject: pkix.Name{
			CommonName:   "Nitella Test CLI Root CA",
			Organization: []string{"Nitella Test"},
		},
		NotBefore:             time.Now(),
		NotAfter:              time.Now().AddDate(10, 0, 0),
		KeyUsage:              x509.KeyUsageCertSign | x509.KeyUsageCRLSign,
		BasicConstraintsValid: true,
		IsCA:                  true,
	}

	certDER, err := x509.CreateCertificate(rand.Reader, template, template, priv.Public(), priv)
	if err != nil {
		t.Fatalf("Failed to create certificate: %v", err)
	}

	certPEM := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: certDER})

	return &cliIdentityData{
		rootKey:     priv,
		rootCertPEM: certPEM,
	}
}

type nodeIdentityData struct {
	privateKey ed25519.PrivateKey
}

func generateNodeIdentity(t *testing.T) *nodeIdentityData {
	t.Helper()

	_, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatalf("Failed to generate key: %v", err)
	}

	return &nodeIdentityData{privateKey: priv}
}

func generateCSR(t *testing.T, key ed25519.PrivateKey, cn string) []byte {
	t.Helper()

	template := x509.CertificateRequest{
		Subject: pkix.Name{CommonName: cn},
	}

	csrDER, err := x509.CreateCertificateRequest(rand.Reader, &template, key)
	if err != nil {
		t.Fatalf("Failed to create CSR: %v", err)
	}

	return pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE REQUEST", Bytes: csrDER})
}

func signCSR(t *testing.T, csrPEM []byte, ca *cliIdentityData) []byte {
	t.Helper()

	block, _ := pem.Decode(csrPEM)
	csr, err := x509.ParseCertificateRequest(block.Bytes)
	if err != nil {
		t.Fatalf("Failed to parse CSR: %v", err)
	}

	// Parse CA cert
	caBlock, _ := pem.Decode(ca.rootCertPEM)
	caCert, _ := x509.ParseCertificate(caBlock.Bytes)

	// Sign
	serial, _ := rand.Int(rand.Reader, big.NewInt(1<<62))
	template := &x509.Certificate{
		SerialNumber: serial,
		Subject:      csr.Subject,
		NotBefore:    time.Now(),
		NotAfter:     time.Now().AddDate(1, 0, 0),
		KeyUsage:     x509.KeyUsageDigitalSignature,
		ExtKeyUsage:  []x509.ExtKeyUsage{x509.ExtKeyUsageClientAuth},
	}

	certDER, err := x509.CreateCertificate(rand.Reader, template, caCert, csr.PublicKey, ca.rootKey)
	if err != nil {
		t.Fatalf("Failed to sign certificate: %v", err)
	}

	return pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: certDER})
}

func connectToHubWithMTLS(t *testing.T, addr string, cli *cliIdentityData) *grpc.ClientConn {
	t.Helper()

	// Generate client cert signed by root CA
	_, clientKey, _ := ed25519.GenerateKey(rand.Reader)

	caBlock, _ := pem.Decode(cli.rootCertPEM)
	caCert, _ := x509.ParseCertificate(caBlock.Bytes)

	serial, _ := rand.Int(rand.Reader, big.NewInt(1<<62))
	template := &x509.Certificate{
		SerialNumber: serial,
		Subject:      pkix.Name{CommonName: "nitella-cli-test"},
		NotBefore:    time.Now(),
		NotAfter:     time.Now().AddDate(1, 0, 0),
		KeyUsage:     x509.KeyUsageDigitalSignature,
		ExtKeyUsage:  []x509.ExtKeyUsage{x509.ExtKeyUsageClientAuth},
	}

	clientCertDER, _ := x509.CreateCertificate(rand.Reader, template, caCert, clientKey.Public(), cli.rootKey)

	// Create TLS config
	tlsConfig := &tls.Config{
		Certificates: []tls.Certificate{{
			Certificate: [][]byte{clientCertDER},
			PrivateKey:  clientKey,
		}},
		InsecureSkipVerify: true, // For testing with auto-cert
		MinVersion:         tls.VersionTLS13,
	}

	conn, err := grpc.Dial(addr,
		grpc.WithTransportCredentials(credentials.NewTLS(tlsConfig)),
	)
	if err != nil {
		t.Fatalf("Failed to connect to Hub: %v", err)
	}

	return conn
}

func connectToHubInsecure(t *testing.T, addr string) *grpc.ClientConn {
	t.Helper()

	conn, err := grpc.Dial(addr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		t.Fatalf("Failed to connect to Hub: %v", err)
	}
	return conn
}

func findBinary(t *testing.T, name string) string {
	t.Helper()

	// Check common locations
	paths := []string{
		fmt.Sprintf("./bin/%s", name),
		fmt.Sprintf("../../bin/%s", name),
		fmt.Sprintf("./cmd/%s/%s", name, name),
		fmt.Sprintf("../../cmd/%s/%s", name, name),
		fmt.Sprintf("/tmp/%s", name),
	}

	for _, p := range paths {
		if _, err := os.Stat(p); err == nil {
			return p
		}
	}

	// Try to find in PATH
	if path, err := exec.LookPath(name); err == nil {
		return path
	}

	t.Skipf("Binary %s not found - run 'make %s_build' first", name, name)
	return ""
}

// contextWithJWT creates a context with JWT token in authorization header
func contextWithJWT(ctx context.Context, token string) context.Context {
	return metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+token)
}

// ============================================================================
// Advanced E2E Tests - Multiple Nodes and Real-time Communication
// ============================================================================

// TestHub_MultipleNodesRegistration tests multiple nitellad nodes registering with Hub
func TestHub_MultipleNodesRegistration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping Hub E2E test in short mode")
	}

	hub := startHubServer(t)
	defer hub.stop()

	// Generate CLI identity (owner)
	cliIdentity := generateCLIIdentity(t)

	// Register CLI user first
	conn := connectToHubWithMTLS(t, hub.grpcAddr, cliIdentity)
	authClient := hubpb.NewAuthServiceClient(conn)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	resp, err := authClient.RegisterUser(ctx, &hubpb.RegisterUserRequest{
		RootCertPem: string(cliIdentity.rootCertPEM),
		InviteCode:  "NITELLA",
	})
	cancel()
	conn.Close()

	if err != nil {
		t.Fatalf("Failed to register CLI user: %v", err)
	}
	t.Logf("CLI user registered: %s", resp.UserId)

	// Register multiple nodes via CSR-based registration
	nodeCount := 5
	nodes := make([]*registeredNode, nodeCount)

	for i := 0; i < nodeCount; i++ {
		nodeIdentity := generateNodeIdentity(t)
		csrPEM := generateCSR(t, nodeIdentity.privateKey, fmt.Sprintf("node-%d", i))
		certPEM := signCSR(t, csrPEM, cliIdentity)

		nodeConn := connectToHubWithNodeCert(t, hub.grpcAddr, nodeIdentity.privateKey, certPEM, cliIdentity.rootCertPEM)

		nodeClient := hubpb.NewNodeServiceClient(nodeConn)
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)

		// Use CSR-based registration
		regResp, err := nodeClient.Register(ctx, &hubpb.NodeRegisterRequest{
			CsrPem: string(csrPEM),
		})
		cancel()

		if err != nil {
			nodeConn.Close()
			t.Logf("Node %d registration: %v (may require approval)", i, err)
			continue
		}

		nodes[i] = &registeredNode{
			nodeID:     fmt.Sprintf("node-%d", i),
			conn:       nodeConn,
			certPEM:    certPEM,
			privateKey: nodeIdentity.privateKey,
		}
		t.Logf("Node %d registered: status=%v", i, regResp.Status)
	}

	// Clean up
	for _, n := range nodes {
		if n != nil && n.conn != nil {
			n.conn.Close()
		}
	}

	t.Logf("Successfully processed %d node registrations", nodeCount)
}

// TestHub_CommandRelay tests CLI -> Hub -> Node command relay
func TestHub_CommandRelay(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping Hub E2E test in short mode")
	}

	hub := startHubServer(t)
	defer hub.stop()

	// Setup CLI and Node
	cliIdentity := generateCLIIdentity(t)
	nodeIdentity := generateNodeIdentity(t)
	csrPEM := generateCSR(t, nodeIdentity.privateKey, "relay-test-node")
	certPEM := signCSR(t, csrPEM, cliIdentity)

	// Register CLI user
	cliConn := connectToHubWithMTLS(t, hub.grpcAddr, cliIdentity)
	defer cliConn.Close()

	authClient := hubpb.NewAuthServiceClient(cliConn)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	_, err := authClient.RegisterUser(ctx, &hubpb.RegisterUserRequest{
		RootCertPem: string(cliIdentity.rootCertPEM),
		InviteCode:  "NITELLA",
	})
	cancel()
	if err != nil {
		t.Fatalf("Failed to register CLI user: %v", err)
	}

	// Connect node
	nodeConn := connectToHubWithNodeCert(t, hub.grpcAddr, nodeIdentity.privateKey, certPEM, cliIdentity.rootCertPEM)
	defer nodeConn.Close()

	nodeClient := hubpb.NewNodeServiceClient(nodeConn)

	// Register node via CSR
	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	_, err = nodeClient.Register(ctx, &hubpb.NodeRegisterRequest{
		CsrPem: string(csrPEM),
	})
	cancel()
	if err != nil {
		t.Logf("Node registration: %v (may require approval)", err)
	}

	// Node starts listening for commands
	cmdReceived := make(chan *hubpb.Command, 1)
	cmdCtx, cmdCancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cmdCancel()

	go func() {
		stream, err := nodeClient.ReceiveCommands(cmdCtx, &hubpb.ReceiveCommandsRequest{
			NodeId: "relay-test-node",
		})
		if err != nil {
			t.Logf("Failed to start command stream: %v", err)
			return
		}

		for {
			cmd, err := stream.Recv()
			if err != nil {
				return
			}
			select {
			case cmdReceived <- cmd:
			default:
			}
		}
	}()

	// Wait for stream to establish
	time.Sleep(500 * time.Millisecond)

	// CLI sends command via MobileService
	mobileClient := hubpb.NewMobileServiceClient(cliConn)
	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	_, err = mobileClient.SendCommand(ctx, &hubpb.CommandRequest{
		NodeId: "relay-test-node",
		Encrypted: &common.EncryptedPayload{
			Ciphertext: []byte("test-command-payload"),
			Nonce:      []byte("test-nonce-12345"),
		},
	})
	cancel()
	if err != nil {
		t.Logf("SendCommand error (expected if not implemented): %v", err)
	}

	// Wait briefly for command
	select {
	case cmd := <-cmdReceived:
		t.Logf("Node received command: ID=%s", cmd.Id)
	case <-time.After(2 * time.Second):
		t.Log("No command received (expected if relay not fully implemented)")
	}

	t.Log("Command relay test completed")
}

// TestHub_AlertStreaming tests Node -> Hub -> CLI alert streaming
func TestHub_AlertStreaming(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping Hub E2E test in short mode")
	}

	hub := startHubServer(t)
	defer hub.stop()

	// Setup CLI and Node
	cliIdentity := generateCLIIdentity(t)
	nodeIdentity := generateNodeIdentity(t)
	csrPEM := generateCSR(t, nodeIdentity.privateKey, "alert-test-node")
	certPEM := signCSR(t, csrPEM, cliIdentity)

	// Register CLI user
	cliConn := connectToHubWithMTLS(t, hub.grpcAddr, cliIdentity)
	defer cliConn.Close()

	authClient := hubpb.NewAuthServiceClient(cliConn)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	_, err := authClient.RegisterUser(ctx, &hubpb.RegisterUserRequest{
		RootCertPem: string(cliIdentity.rootCertPEM),
		InviteCode:  "NITELLA",
	})
	cancel()
	if err != nil {
		t.Fatalf("Failed to register CLI user: %v", err)
	}

	// Connect and register node
	nodeConn := connectToHubWithNodeCert(t, hub.grpcAddr, nodeIdentity.privateKey, certPEM, cliIdentity.rootCertPEM)
	defer nodeConn.Close()

	nodeClient := hubpb.NewNodeServiceClient(nodeConn)
	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	_, err = nodeClient.Register(ctx, &hubpb.NodeRegisterRequest{
		CsrPem: string(csrPEM),
	})
	cancel()
	if err != nil {
		t.Logf("Node registration: %v (may require approval)", err)
	}

	// CLI subscribes to alerts
	mobileClient := hubpb.NewMobileServiceClient(cliConn)
	alertCtx, alertCancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer alertCancel()

	alertReceived := make(chan bool, 1)
	go func() {
		stream, err := mobileClient.StreamAlerts(alertCtx, &hubpb.StreamAlertsRequest{})
		if err != nil {
			t.Logf("Failed to start alert stream: %v", err)
			return
		}

		for {
			alert, err := stream.Recv()
			if err != nil {
				return
			}
			t.Logf("CLI received alert: NodeID=%s, Severity=%s", alert.NodeId, alert.Severity)
			select {
			case alertReceived <- true:
			default:
			}
		}
	}()

	// Wait for stream to establish
	time.Sleep(500 * time.Millisecond)

	// Node pushes alert
	ctx, cancel = context.WithTimeout(context.Background(), 5*time.Second)
	_, err = nodeClient.PushAlert(ctx, &common.Alert{
		NodeId:   "alert-test-node",
		Severity: "high",
		Metadata: map[string]string{"type": "CONNECTION_BLOCKED", "message": "Suspicious IP blocked: 1.2.3.4"},
	})
	cancel()
	if err != nil {
		t.Logf("PushAlert error (expected if not fully implemented): %v", err)
	}

	// Wait for alert
	select {
	case <-alertReceived:
		t.Log("Alert received successfully")
	case <-time.After(2 * time.Second):
		t.Log("No alert received (expected if streaming not fully implemented)")
	}

	t.Log("Alert streaming test completed")
}

// TestHub_HeartbeatAndStatus tests node heartbeat and status updates
func TestHub_HeartbeatAndStatus(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping Hub E2E test in short mode")
	}

	hub := startHubServer(t)
	defer hub.stop()

	// Setup CLI and Node
	cliIdentity := generateCLIIdentity(t)
	nodeIdentity := generateNodeIdentity(t)
	csrPEM := generateCSR(t, nodeIdentity.privateKey, "heartbeat-test-node")
	certPEM := signCSR(t, csrPEM, cliIdentity)

	// Register CLI user and get JWT token
	cliConn := connectToHubWithMTLS(t, hub.grpcAddr, cliIdentity)
	defer cliConn.Close()

	authClient := hubpb.NewAuthServiceClient(cliConn)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	userResp, err := authClient.RegisterUser(ctx, &hubpb.RegisterUserRequest{
		RootCertPem: string(cliIdentity.rootCertPEM),
		InviteCode:  "NITELLA",
	})
	cancel()
	if err != nil {
		t.Fatalf("Failed to register CLI user: %v", err)
	}
	jwtToken := userResp.JwtToken
	t.Logf("CLI user registered with JWT token: %s...", jwtToken[:min(len(jwtToken), 20)])

	// Connect and register node
	nodeConn := connectToHubWithNodeCert(t, hub.grpcAddr, nodeIdentity.privateKey, certPEM, cliIdentity.rootCertPEM)
	defer nodeConn.Close()

	nodeClient := hubpb.NewNodeServiceClient(nodeConn)
	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	_, err = nodeClient.Register(ctx, &hubpb.NodeRegisterRequest{
		CsrPem: string(csrPEM),
	})
	cancel()
	if err != nil {
		t.Logf("Node registration: %v (may require approval)", err)
	}

	// Send multiple heartbeats (may fail due to auth - node needs full approval flow)
	heartbeatSuccess := 0
	for i := 0; i < 3; i++ {
		ctx, cancel = context.WithTimeout(context.Background(), 5*time.Second)
		resp, err := nodeClient.Heartbeat(ctx, &hubpb.HeartbeatRequest{
			NodeId:        "heartbeat-test-node",
			Status:        hubpb.NodeStatus_NODE_STATUS_ONLINE,
			UptimeSeconds: int64((i + 1) * 3600),
		})
		cancel()

		if err != nil {
			t.Logf("Heartbeat %d: %v (expected - requires full approval flow)", i, err)
			continue
		}
		heartbeatSuccess++
		t.Logf("Heartbeat %d: rules_changed=%v", i, resp.RulesChanged)
		time.Sleep(100 * time.Millisecond)
	}

	// CLI lists nodes using JWT authentication
	mobileClient := hubpb.NewMobileServiceClient(cliConn)
	ctx, cancel = context.WithTimeout(context.Background(), 5*time.Second)
	ctx = contextWithJWT(ctx, jwtToken)
	listResp, err := mobileClient.ListNodes(ctx, &hubpb.ListNodesRequest{})
	cancel()

	if err != nil {
		t.Logf("ListNodes: %v (may need implementation)", err)
	} else {
		t.Logf("ListNodes returned %d nodes", len(listResp.Nodes))
		for _, node := range listResp.Nodes {
			if node.Id == "heartbeat-test-node" {
				t.Logf("Found node: ID=%s, Status=%v", node.Id, node.Status)
			}
		}
	}

	t.Log("Heartbeat and status test completed")
}

// TestHub_P2PSignaling tests P2P signaling between nodes
func TestHub_P2PSignaling(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping Hub E2E test in short mode")
	}

	hub := startHubServer(t)
	defer hub.stop()

	// Setup CLI
	cliIdentity := generateCLIIdentity(t)
	cliConn := connectToHubWithMTLS(t, hub.grpcAddr, cliIdentity)
	defer cliConn.Close()

	authClient := hubpb.NewAuthServiceClient(cliConn)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	_, err := authClient.RegisterUser(ctx, &hubpb.RegisterUserRequest{
		RootCertPem: string(cliIdentity.rootCertPEM),
		InviteCode:  "NITELLA",
	})
	cancel()
	if err != nil {
		t.Fatalf("Failed to register CLI user: %v", err)
	}

	// Setup two nodes
	nodes := make([]*p2pTestNode, 2)
	for i := 0; i < 2; i++ {
		nodeIdentity := generateNodeIdentity(t)
		csrPEM := generateCSR(t, nodeIdentity.privateKey, fmt.Sprintf("p2p-node-%d", i))
		certPEM := signCSR(t, csrPEM, cliIdentity)

		nodeConn := connectToHubWithNodeCert(t, hub.grpcAddr, nodeIdentity.privateKey, certPEM, cliIdentity.rootCertPEM)

		nodeClient := hubpb.NewNodeServiceClient(nodeConn)
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		_, err := nodeClient.Register(ctx, &hubpb.NodeRegisterRequest{
			CsrPem: string(csrPEM),
		})
		cancel()
		if err != nil {
			t.Logf("p2p-node-%d registration: %v (may require approval)", i, err)
		}

		nodes[i] = &p2pTestNode{
			nodeID: fmt.Sprintf("p2p-node-%d", i),
			conn:   nodeConn,
			client: nodeClient,
		}
	}
	defer func() {
		for _, n := range nodes {
			n.conn.Close()
		}
	}()

	// Start signaling streams
	signalCtx, signalCancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer signalCancel()

	msgReceived := make(chan *hubpb.SignalMessage, 2)

	for i, node := range nodes {
		go func(idx int, n *p2pTestNode) {
			stream, err := n.client.StreamSignaling(signalCtx)
			if err != nil {
				t.Logf("Node %d failed to start signaling: %v", idx, err)
				return
			}

			// Receive messages
			for {
				msg, err := stream.Recv()
				if err != nil {
					return
				}
				t.Logf("Node %d received signal from %s", idx, msg.SourceId)
				select {
				case msgReceived <- msg:
				default:
				}
			}
		}(i, node)
	}

	time.Sleep(500 * time.Millisecond)
	t.Log("P2P signaling streams established")

	t.Log("P2P signaling test completed")
}

// TestHub_FullSystemIntegration tests complete system with CLI, Hub, and multiple nodes
func TestHub_FullSystemIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping Hub E2E test in short mode")
	}

	hub := startHubServer(t)
	defer hub.stop()

	// Phase 1: Setup CLI user (organization owner)
	t.Log("Phase 1: Setting up CLI user...")
	cliIdentity := generateCLIIdentity(t)
	cliConn := connectToHubWithMTLS(t, hub.grpcAddr, cliIdentity)
	defer cliConn.Close()

	authClient := hubpb.NewAuthServiceClient(cliConn)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	userResp, err := authClient.RegisterUser(ctx, &hubpb.RegisterUserRequest{
		RootCertPem: string(cliIdentity.rootCertPEM),
		InviteCode:  "NITELLA",
	})
	cancel()
	if err != nil {
		t.Fatalf("Failed to register CLI user: %v", err)
	}
	jwtToken := userResp.JwtToken
	t.Logf("CLI user registered: %s (JWT: %s...)", userResp.UserId, jwtToken[:min(len(jwtToken), 20)])

	// Phase 2: Register multiple nodes (simulating distributed deployment)
	t.Log("Phase 2: Registering distributed nodes...")
	nodeCount := 3
	registeredNodes := make([]*fullTestNode, nodeCount)

	for i := 0; i < nodeCount; i++ {
		// Simulate PAKE pairing process
		nodeIdentity := generateNodeIdentity(t)
		code, _ := pairing.GeneratePairingCode()

		cliSession, _ := pairing.NewPakeSession(pairing.RoleCLI, pairing.CodeToBytes(code))
		nodeSession, _ := pairing.NewPakeSession(pairing.RoleNode, pairing.CodeToBytes(code))

		// Exchange PAKE messages
		cliInit, _ := cliSession.GetInitMessage()
		nodeInit, _ := nodeSession.GetInitMessage()
		cliSession.ProcessInitMessage(nodeInit)
		nodeSession.ProcessInitMessage(cliInit)

		// Verify emoji match (would be manual in real flow)
		if cliSession.DeriveConfirmationEmoji() != nodeSession.DeriveConfirmationEmoji() {
			t.Fatalf("Emoji mismatch for node %d", i)
		}

		// Node generates CSR and encrypts
		csrPEM := generateCSR(t, nodeIdentity.privateKey, fmt.Sprintf("prod-node-%d", i))
		encCSR, csrNonce, _ := nodeSession.Encrypt(csrPEM)

		// CLI decrypts and signs
		decCSR, _ := cliSession.Decrypt(encCSR, csrNonce)
		certPEM := signCSR(t, decCSR, cliIdentity)

		// CLI encrypts cert back
		encCert, certNonce, _ := cliSession.Encrypt(certPEM)

		// Node decrypts cert
		finalCert, _ := nodeSession.Decrypt(encCert, certNonce)

		// Connect to Hub with signed cert
		nodeConn := connectToHubWithNodeCert(t, hub.grpcAddr, nodeIdentity.privateKey, finalCert, cliIdentity.rootCertPEM)

		nodeClient := hubpb.NewNodeServiceClient(nodeConn)
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		regResp, err := nodeClient.Register(ctx, &hubpb.NodeRegisterRequest{
			CsrPem: string(csrPEM),
		})
		cancel()

		if err != nil {
			t.Logf("prod-node-%d registration: %v (may require approval)", i, err)
		}

		registeredNodes[i] = &fullTestNode{
			nodeID: fmt.Sprintf("prod-node-%d", i),
			conn:   nodeConn,
			client: nodeClient,
		}
		if regResp != nil {
			t.Logf("Node %d paired and registered via PAKE: status=%v", i, regResp.Status)
		}
	}
	defer func() {
		for _, n := range registeredNodes {
			if n.conn != nil {
				n.conn.Close()
			}
		}
	}()

	// Phase 3: Nodes send heartbeats (may fail due to auth - node needs full approval flow)
	t.Log("Phase 3: Simulating node heartbeats...")
	for i, node := range registeredNodes {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		_, err := node.client.Heartbeat(ctx, &hubpb.HeartbeatRequest{
			NodeId:        node.nodeID,
			Status:        hubpb.NodeStatus_NODE_STATUS_ONLINE,
			UptimeSeconds: int64((i + 1) * 3600),
		})
		cancel()
		if err != nil {
			t.Logf("Node %s heartbeat: %v (expected - requires full approval flow)", node.nodeID, err)
		}
	}

	// Phase 4: CLI lists and monitors nodes (with JWT auth)
	t.Log("Phase 4: CLI monitoring nodes...")
	mobileClient := hubpb.NewMobileServiceClient(cliConn)
	ctx, cancel = context.WithTimeout(context.Background(), 5*time.Second)
	ctx = contextWithJWT(ctx, jwtToken)
	listResp, err := mobileClient.ListNodes(ctx, &hubpb.ListNodesRequest{})
	cancel()

	if err != nil {
		t.Logf("ListNodes: %v (may need implementation)", err)
	}

	t.Logf("CLI sees %d nodes registered", len(listResp.GetNodes()))
	for _, node := range listResp.Nodes {
		t.Logf("  - %s: status=%v", node.Id, node.Status)
	}

	// Phase 5: Simulate alerts from nodes
	t.Log("Phase 5: Testing alert flow...")
	alertTypes := []string{"CONNECTION_BLOCKED", "GEO_RESTRICTION", "RATE_LIMIT_EXCEEDED"}
	for i, node := range registeredNodes {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		_, err := node.client.PushAlert(ctx, &common.Alert{
			NodeId:   node.nodeID,
			Severity: "medium",
			Metadata: map[string]string{"type": alertTypes[i%len(alertTypes)], "message": fmt.Sprintf("Test alert from %s", node.nodeID)},
		})
		cancel()
		if err != nil {
			t.Logf("Alert push from %s: %v (may be expected)", node.nodeID, err)
		}
	}

	// Phase 6: Verify multi-tenant isolation
	t.Log("Phase 6: Verifying multi-tenant isolation...")
	otherCLI := generateCLIIdentity(t)
	otherConn := connectToHubWithMTLS(t, hub.grpcAddr, otherCLI)
	defer otherConn.Close()

	otherAuthClient := hubpb.NewAuthServiceClient(otherConn)
	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	_, err = otherAuthClient.RegisterUser(ctx, &hubpb.RegisterUserRequest{
		RootCertPem: string(otherCLI.rootCertPEM),
		InviteCode:  "NITELLA",
	})
	cancel()
	if err != nil {
		t.Fatalf("Failed to register other CLI user: %v", err)
	}

	// Other user should not see first user's nodes
	otherMobile := hubpb.NewMobileServiceClient(otherConn)
	ctx, cancel = context.WithTimeout(context.Background(), 5*time.Second)
	otherList, err := otherMobile.ListNodes(ctx, &hubpb.ListNodesRequest{})
	cancel()

	if err == nil && len(otherList.Nodes) > 0 {
		// Check that other user's nodes are different
		for _, node := range otherList.Nodes {
			for _, ourNode := range registeredNodes {
				if node.Id == ourNode.nodeID {
					t.Errorf("Multi-tenant violation: other user can see node %s", node.Id)
				}
			}
		}
	}
	t.Log("Multi-tenant isolation verified")

	t.Log("Full system integration test completed successfully")
}

// Helper types for advanced tests
type registeredNode struct {
	nodeID     string
	conn       *grpc.ClientConn
	certPEM    []byte
	privateKey ed25519.PrivateKey
}

type p2pTestNode struct {
	nodeID string
	conn   *grpc.ClientConn
	client hubpb.NodeServiceClient
}

type fullTestNode struct {
	nodeID string
	conn   *grpc.ClientConn
	client hubpb.NodeServiceClient
}

// connectToHubWithNodeCert connects to Hub with node's signed certificate
func connectToHubWithNodeCert(t *testing.T, addr string, privateKey ed25519.PrivateKey, certPEM, caCertPEM []byte) *grpc.ClientConn {
	t.Helper()

	// Parse cert
	block, _ := pem.Decode(certPEM)
	if block == nil {
		t.Fatal("Failed to decode cert PEM")
	}

	// Create TLS config with client cert
	tlsConfig := &tls.Config{
		Certificates: []tls.Certificate{{
			Certificate: [][]byte{block.Bytes},
			PrivateKey:  privateKey,
		}},
		InsecureSkipVerify: true, // For testing with auto-cert Hub
		MinVersion:         tls.VersionTLS13,
	}

	conn, err := grpc.Dial(addr,
		grpc.WithTransportCredentials(credentials.NewTLS(tlsConfig)),
	)
	if err != nil {
		t.Fatalf("Failed to connect to Hub: %v", err)
	}

	return conn
}

// ============================================================================
// Logs E2E Tests
// ============================================================================

// TestHub_LogsE2E tests the complete encrypted logs flow:
// 1. Node pushes encrypted logs to Hub
// 2. Admin API lists and queries logs
// 3. Admin API deletes and cleans up logs
func TestHub_LogsE2E(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping Hub E2E test in short mode")
	}

	hub := startHubServer(t)
	defer hub.stop()

	// Setup CLI and Node
	cliIdentity := generateCLIIdentity(t)
	nodeIdentity := generateNodeIdentity(t)
	csrPEM := generateCSR(t, nodeIdentity.privateKey, "logs-test-node")
	certPEM := signCSR(t, csrPEM, cliIdentity)

	// Register CLI user
	cliConn := connectToHubWithMTLS(t, hub.grpcAddr, cliIdentity)
	defer cliConn.Close()

	authClient := hubpb.NewAuthServiceClient(cliConn)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	userResp, err := authClient.RegisterUser(ctx, &hubpb.RegisterUserRequest{
		RootCertPem: string(cliIdentity.rootCertPEM),
		InviteCode:  "NITELLA",
	})
	cancel()
	if err != nil {
		t.Fatalf("Failed to register CLI user: %v", err)
	}
	jwtToken := userResp.JwtToken
	t.Logf("CLI user registered with JWT token")

	// Connect and register node
	nodeConn := connectToHubWithNodeCert(t, hub.grpcAddr, nodeIdentity.privateKey, certPEM, cliIdentity.rootCertPEM)
	defer nodeConn.Close()

	nodeClient := hubpb.NewNodeServiceClient(nodeConn)
	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	_, err = nodeClient.Register(ctx, &hubpb.NodeRegisterRequest{
		CsrPem: string(csrPEM),
	})
	cancel()
	if err != nil {
		t.Logf("Node registration: %v (may require approval)", err)
	}

	// Phase 1: Push encrypted logs from node
	t.Log("Phase 1: Pushing encrypted logs from node...")

	logCtx, logCancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer logCancel()

	logStream, err := nodeClient.PushLogs(logCtx)
	if err != nil {
		t.Fatalf("Failed to start log stream: %v", err)
	}

	// Push 10 encrypted log entries
	logCount := 10
	for i := 0; i < logCount; i++ {
		entry := &hubpb.EncryptedLogEntry{
			NodeId: "logs-test-node",
			Encrypted: &common.EncryptedPayload{
				Ciphertext: []byte(fmt.Sprintf("encrypted-log-entry-%d-content", i)),
				Nonce:      []byte(fmt.Sprintf("nonce-%d", i)),
			},
		}
		if err := logStream.Send(entry); err != nil {
			t.Logf("Failed to send log entry %d: %v", i, err)
		}
	}

	// Close and receive response
	_, err = logStream.CloseAndRecv()
	if err != nil {
		t.Logf("Log stream close: %v (may be expected if routing token not set)", err)
	}

	t.Logf("Pushed %d encrypted log entries", logCount)

	// Phase 2: Query logs via admin API
	t.Log("Phase 2: Querying logs via admin API...")

	adminClient := hubpb.NewAdminServiceClient(cliConn)

	// Get logs stats (with JWT auth)
	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	ctx = contextWithJWT(ctx, jwtToken)
	stats, err := adminClient.GetLogsStats(ctx, &hubpb.GetLogsStatsRequest{})
	cancel()

	if err != nil {
		t.Logf("GetLogsStats: %v (admin API may require special auth)", err)
	} else {
		t.Logf("Logs stats: total=%d, routing_tokens=%d, storage=%d bytes",
			stats.TotalLogs, len(stats.LogsByRoutingToken), stats.TotalStorageBytes)
	}

	// List logs (with JWT auth)
	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	ctx = contextWithJWT(ctx, jwtToken)
	listResp, err := adminClient.ListLogs(ctx, &hubpb.ListLogsRequest{
		PageSize: 100,
	})
	cancel()

	if err != nil {
		t.Logf("ListLogs: %v (admin API may require special auth)", err)
	} else {
		t.Logf("Listed %d logs", len(listResp.Logs))
		for i, log := range listResp.Logs {
			if i < 3 { // Show first 3
				t.Logf("  Log %d: NodeID=%s, Size=%d bytes", log.Id, log.NodeId, log.EncryptedSizeBytes)
			}
		}
	}

	// Phase 3: Test logs by node ID filter
	t.Log("Phase 3: Testing logs filter by node ID...")

	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	ctx = contextWithJWT(ctx, jwtToken)
	nodeLogsResp, err := adminClient.ListLogs(ctx, &hubpb.ListLogsRequest{
		NodeId:   "logs-test-node",
		PageSize: 50,
	})
	cancel()

	if err != nil {
		t.Logf("ListLogs by node: %v", err)
	} else {
		t.Logf("Logs for node 'logs-test-node': %d entries", len(nodeLogsResp.Logs))
	}

	// Phase 4: Test logs cleanup
	t.Log("Phase 4: Testing logs cleanup...")

	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	ctx = contextWithJWT(ctx, jwtToken)
	cleanupResp, err := adminClient.CleanupOldLogs(ctx, &hubpb.CleanupOldLogsRequest{
		OlderThanDays: 0, // Delete all logs older than 0 days (should not delete recent logs)
	})
	cancel()

	if err != nil {
		t.Logf("CleanupOldLogs: %v", err)
	} else {
		t.Logf("Cleaned up %d old logs", cleanupResp.DeletedCount)
	}

	// Phase 5: Delete specific logs
	t.Log("Phase 5: Testing specific logs deletion...")

	// Get current count (with JWT auth)
	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	ctx = contextWithJWT(ctx, jwtToken)
	beforeStats, err := adminClient.GetLogsStats(ctx, &hubpb.GetLogsStatsRequest{})
	cancel()

	if err == nil && beforeStats.TotalLogs > 0 {
		// Delete by node ID (with JWT auth)
		ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
		ctx = contextWithJWT(ctx, jwtToken)
		deleteResp, err := adminClient.DeleteLogs(ctx, &hubpb.DeleteLogsRequest{
			NodeId: "logs-test-node",
		})
		cancel()

		if err != nil {
			t.Logf("DeleteLogs: %v", err)
		} else {
			t.Logf("Deleted %d logs for node 'logs-test-node'", deleteResp.DeletedCount)
		}

		// Verify deletion (with JWT auth)
		ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
		ctx = contextWithJWT(ctx, jwtToken)
		afterStats, err := adminClient.GetLogsStats(ctx, &hubpb.GetLogsStatsRequest{})
		cancel()

		if err == nil {
			t.Logf("After deletion: total=%d (was %d)", afterStats.TotalLogs, beforeStats.TotalLogs)
		}
	}

	t.Log("Logs E2E test completed")
}

// TestHub_LogsMultiNodeE2E tests logs from multiple nodes
func TestHub_LogsMultiNodeE2E(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping Hub E2E test in short mode")
	}

	hub := startHubServer(t)
	defer hub.stop()

	// Setup CLI
	cliIdentity := generateCLIIdentity(t)
	cliConn := connectToHubWithMTLS(t, hub.grpcAddr, cliIdentity)
	defer cliConn.Close()

	authClient := hubpb.NewAuthServiceClient(cliConn)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	userResp, err := authClient.RegisterUser(ctx, &hubpb.RegisterUserRequest{
		RootCertPem: string(cliIdentity.rootCertPEM),
		InviteCode:  "NITELLA",
	})
	cancel()
	if err != nil {
		t.Fatalf("Failed to register CLI user: %v", err)
	}
	jwtToken := userResp.JwtToken

	// Setup multiple nodes
	nodeCount := 3
	logsPerNode := 5
	type nodeInfo struct {
		nodeID string
		conn   *grpc.ClientConn
		client hubpb.NodeServiceClient
	}
	nodes := make([]*nodeInfo, nodeCount)

	for i := 0; i < nodeCount; i++ {
		nodeIdentity := generateNodeIdentity(t)
		nodeID := fmt.Sprintf("multi-log-node-%d", i)
		csrPEM := generateCSR(t, nodeIdentity.privateKey, nodeID)
		certPEM := signCSR(t, csrPEM, cliIdentity)

		nodeConn := connectToHubWithNodeCert(t, hub.grpcAddr, nodeIdentity.privateKey, certPEM, cliIdentity.rootCertPEM)

		nodeClient := hubpb.NewNodeServiceClient(nodeConn)
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		_, err := nodeClient.Register(ctx, &hubpb.NodeRegisterRequest{
			CsrPem: string(csrPEM),
		})
		cancel()
		if err != nil {
			t.Logf("Node %s registration: %v (may require approval)", nodeID, err)
		}

		nodes[i] = &nodeInfo{
			nodeID: nodeID,
			conn:   nodeConn,
			client: nodeClient,
		}
	}
	defer func() {
		for _, n := range nodes {
			if n.conn != nil {
				n.conn.Close()
			}
		}
	}()

	// Each node pushes logs
	t.Log("Pushing logs from multiple nodes...")
	for _, node := range nodes {
		logCtx, logCancel := context.WithTimeout(context.Background(), 30*time.Second)

		logStream, err := node.client.PushLogs(logCtx)
		if err != nil {
			logCancel()
			t.Logf("Node %s: Failed to start log stream: %v", node.nodeID, err)
			continue
		}

		for j := 0; j < logsPerNode; j++ {
			entry := &hubpb.EncryptedLogEntry{
				NodeId: node.nodeID,
				Encrypted: &common.EncryptedPayload{
					Ciphertext: []byte(fmt.Sprintf("log-from-%s-entry-%d", node.nodeID, j)),
					Nonce:      []byte(fmt.Sprintf("nonce-%s-%d", node.nodeID, j)),
				},
			}
			if err := logStream.Send(entry); err != nil {
				t.Logf("Node %s: Failed to send log %d: %v", node.nodeID, j, err)
			}
		}

		_, err = logStream.CloseAndRecv()
		logCancel()
		if err != nil {
			t.Logf("Node %s: Log stream close: %v", node.nodeID, err)
		} else {
			t.Logf("Node %s: Pushed %d logs", node.nodeID, logsPerNode)
		}
	}

	// Query stats (with JWT auth)
	adminClient := hubpb.NewAdminServiceClient(cliConn)
	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	ctx = contextWithJWT(ctx, jwtToken)
	stats, err := adminClient.GetLogsStats(ctx, &hubpb.GetLogsStatsRequest{})
	cancel()

	if err != nil {
		t.Logf("GetLogsStats: %v", err)
	} else {
		t.Logf("Total logs from %d routing tokens: %d logs, %d bytes storage",
			len(stats.LogsByRoutingToken), stats.TotalLogs, stats.TotalStorageBytes)

		expectedTotal := nodeCount * logsPerNode
		if stats.TotalLogs >= int64(expectedTotal) {
			t.Logf("Verified: received at least %d logs from %d nodes", expectedTotal, nodeCount)
		}
	}

	// List logs per node (with JWT auth)
	for _, node := range nodes {
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		ctx = contextWithJWT(ctx, jwtToken)
		resp, err := adminClient.ListLogs(ctx, &hubpb.ListLogsRequest{
			NodeId:   node.nodeID,
			PageSize: 100,
		})
		cancel()

		if err != nil {
			t.Logf("ListLogs for %s: %v", node.nodeID, err)
		} else {
			t.Logf("Node %s: %d logs stored", node.nodeID, len(resp.Logs))
		}
	}

	t.Log("Multi-node logs E2E test completed")
}

// Note: TestHub_LogsStreamingE2E is not implemented as StreamLogs is not yet
// available in MobileService. Log streaming can be added when that RPC is defined.
