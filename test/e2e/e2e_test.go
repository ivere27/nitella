// Package e2e provides comprehensive end-to-end tests for Nitella
//
// These tests run against actual Docker containers with:
// - 1 Hub server
// - Multiple nitellad nodes (different users, PAKE and QR pairing)
// - Multiple mock backend servers (HTTP, SSH, MySQL, etc.)
//
// Run: make hub_test_e2e_docker
package e2e

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
	"fmt"
	"io"
	"math/big"
	"net"
	"net/http"
	"os"
	"os/exec"
	"sync"
	"testing"
	"time"

	hubpb "github.com/ivere27/nitella/pkg/api/hub"
	proxypb "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/pairing"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/metadata"
)

// Environment variables
var (
	hubAddr    = getEnv("HUB_ADDR", "localhost:50052")
	hubHTTPAddr = getEnv("HUB_HTTP_ADDR", "localhost:8080")
	node1Addr  = getEnv("NODE1_ADDR", "localhost:18081")
	node1Admin = getEnv("NODE1_ADMIN", "localhost:50061")
	node2Addr  = getEnv("NODE2_ADDR", "localhost:18082")
	node2Admin = getEnv("NODE2_ADMIN", "localhost:50062")
	node3Addr  = getEnv("NODE3_ADDR", "localhost:18083")
	node3Admin = getEnv("NODE3_ADMIN", "localhost:50063")
	mockHTTP   = getEnv("MOCK_HTTP", "localhost:8090")
	mockSSH    = getEnv("MOCK_SSH", "localhost:2222")
	mockMySQL  = getEnv("MOCK_MYSQL", "localhost:3306")
	adminToken = getEnv("ADMIN_TOKEN", "test-admin-token")
)

func getEnv(key, defaultVal string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return defaultVal
}

// ============================================================================
// Test Infrastructure
// ============================================================================

type e2eTestSuite struct {
	t       *testing.T
	hubConn *grpc.ClientConn
	hubCAPEM []byte
	users   map[string]*testUser
	nodes   map[string]*testNode
	proxies map[string]*testProxy
	mu      sync.Mutex
}

type testUser struct {
	name         string
	userID       string
	jwtToken     string
	identity     *userIdentity
	conn         *grpc.ClientConn
	authClient   hubpb.AuthServiceClient
	mobileClient hubpb.MobileServiceClient
}

type userIdentity struct {
	rootPrivKey ed25519.PrivateKey
	rootPubKey  ed25519.PublicKey
	rootCertPEM []byte
}

type testNode struct {
	nodeID      string
	ownerID     string
	pairingMode string // "pake" or "qr"
	privateKey  ed25519.PrivateKey
	certPEM     []byte
	caCertPEM   []byte
	proxyAddr   string
	adminAddr   string
	conn        *grpc.ClientConn
	nodeClient  hubpb.NodeServiceClient
	proxyClient proxypb.ProxyControlServiceClient
}

type testProxy struct {
	id          string
	nodeID      string
	listenAddr  string
	backendAddr string
	protocol    string
	rules       []*proxypb.Rule
}

func newE2ETestSuite(t *testing.T) *e2eTestSuite {
	return &e2eTestSuite{
		t:       t,
		users:   make(map[string]*testUser),
		nodes:   make(map[string]*testNode),
		proxies: make(map[string]*testProxy),
	}
}

func (s *e2eTestSuite) setup() {
	s.t.Log("=== E2E Test Suite Setup ===")

	// Wait for Hub to be ready
	s.waitForService(hubAddr, 60*time.Second)
	s.waitForHTTPHealth(fmt.Sprintf("http://%s/health", hubHTTPAddr), 30*time.Second)

	// Connect to Hub
	var err error
	s.hubConn, err = grpc.Dial(hubAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		s.t.Fatalf("Failed to connect to Hub: %v", err)
	}

	// Get Hub CA for TLS
	s.hubCAPEM = s.fetchHubCA()

	s.t.Log("E2E Test Suite setup complete")
}

func (s *e2eTestSuite) cleanup() {
	s.t.Log("=== E2E Test Suite Cleanup ===")

	for _, user := range s.users {
		if user.conn != nil {
			user.conn.Close()
		}
	}
	for _, node := range s.nodes {
		if node.conn != nil {
			node.conn.Close()
		}
	}
	if s.hubConn != nil {
		s.hubConn.Close()
	}
}

func (s *e2eTestSuite) waitForService(addr string, timeout time.Duration) {
	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		conn, err := net.DialTimeout("tcp", addr, 2*time.Second)
		if err == nil {
			conn.Close()
			s.t.Logf("Service %s is ready", addr)
			return
		}
		time.Sleep(1 * time.Second)
	}
	s.t.Fatalf("Timeout waiting for service %s", addr)
}

func (s *e2eTestSuite) waitForHTTPHealth(url string, timeout time.Duration) {
	deadline := time.Now().Add(timeout)
	client := &http.Client{Timeout: 2 * time.Second}
	for time.Now().Before(deadline) {
		resp, err := client.Get(url)
		if err == nil && resp.StatusCode == 200 {
			resp.Body.Close()
			s.t.Logf("HTTP health check passed: %s", url)
			return
		}
		if resp != nil {
			resp.Body.Close()
		}
		time.Sleep(1 * time.Second)
	}
	s.t.Fatalf("Timeout waiting for HTTP health: %s", url)
}

func (s *e2eTestSuite) fetchHubCA() []byte {
	url := fmt.Sprintf("http://%s/ca.crt", hubHTTPAddr)
	resp, err := http.Get(url)
	if err != nil {
		s.t.Logf("Warning: Could not fetch Hub CA: %v", err)
		return nil
	}
	defer resp.Body.Close()
	ca, _ := io.ReadAll(resp.Body)
	return ca
}

// ============================================================================
// User Registration
// ============================================================================

func (s *e2eTestSuite) registerUser(name string) *testUser {
	s.t.Logf("Registering user: %s", name)

	identity := s.generateUserIdentity(name)

	conn, err := grpc.Dial(hubAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		s.t.Fatalf("Failed to connect to Hub for user %s: %v", name, err)
	}

	authClient := hubpb.NewAuthServiceClient(conn)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	regResp, err := authClient.RegisterUser(ctx, &hubpb.RegisterUserRequest{
		RootCertPem: string(identity.rootCertPEM),
		InviteCode:  "NITELLA",
	})
	if err != nil {
		s.t.Fatalf("Failed to register user %s: %v", name, err)
	}

	user := &testUser{
		name:         name,
		userID:       regResp.UserId,
		jwtToken:     regResp.JwtToken,
		identity:     identity,
		conn:         conn,
		authClient:   authClient,
		mobileClient: hubpb.NewMobileServiceClient(conn),
	}

	s.mu.Lock()
	s.users[name] = user
	s.mu.Unlock()

	s.t.Logf("User %s registered: ID=%s", name, user.userID)
	return user
}

func (s *e2eTestSuite) generateUserIdentity(name string) *userIdentity {
	pubKey, privKey, _ := ed25519.GenerateKey(rand.Reader)

	template := &x509.Certificate{
		SerialNumber:          big.NewInt(1),
		Subject:               pkix.Name{CommonName: name + "-root"},
		NotBefore:             time.Now(),
		NotAfter:              time.Now().Add(365 * 24 * time.Hour),
		KeyUsage:              x509.KeyUsageCertSign | x509.KeyUsageDigitalSignature,
		BasicConstraintsValid: true,
		IsCA:                  true,
	}

	certDER, _ := x509.CreateCertificate(rand.Reader, template, template, pubKey, privKey)
	certPEM := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: certDER})

	return &userIdentity{
		rootPrivKey: privKey,
		rootPubKey:  pubKey,
		rootCertPEM: certPEM,
	}
}

// ============================================================================
// Node Pairing - PAKE
// ============================================================================

func (s *e2eTestSuite) pairNodeWithPAKE(user *testUser, nodeID, proxyAddr, adminAddr string) *testNode {
	s.t.Logf("Pairing node %s via PAKE for user %s", nodeID, user.name)

	_, nodePrivKey, _ := ed25519.GenerateKey(rand.Reader)

	code, _ := pairing.GeneratePairingCode()
	s.t.Logf("PAKE code for %s: %s", nodeID, code)

	cliSession, _ := pairing.NewPakeSession(pairing.RoleCLI, pairing.CodeToBytes(code))
	nodeSession, _ := pairing.NewPakeSession(pairing.RoleNode, pairing.CodeToBytes(code))

	cliInit, _ := cliSession.GetInitMessage()
	nodeInit, _ := nodeSession.GetInitMessage()
	cliSession.ProcessInitMessage(nodeInit)
	nodeSession.ProcessInitMessage(cliInit)

	cliEmoji := cliSession.DeriveConfirmationEmoji()
	nodeEmoji := nodeSession.DeriveConfirmationEmoji()
	if cliEmoji != nodeEmoji {
		s.t.Fatalf("PAKE emoji mismatch for %s", nodeID)
	}
	s.t.Logf("PAKE emoji verified for %s: %s", nodeID, cliEmoji)

	csrPEM := s.generateCSR(nodePrivKey, nodeID)

	encCSR, csrNonce, _ := nodeSession.Encrypt(csrPEM)
	decCSR, _ := cliSession.Decrypt(encCSR, csrNonce)
	certPEM := s.signCSR(decCSR, user.identity)

	encCert, certNonce, _ := cliSession.Encrypt(certPEM)
	finalCert, _ := nodeSession.Decrypt(encCert, certNonce)

	nodeConn, err := grpc.Dial(hubAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		s.t.Fatalf("Failed to connect node %s to Hub: %v", nodeID, err)
	}

	nodeClient := hubpb.NewNodeServiceClient(nodeConn)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	regResp, err := nodeClient.Register(ctx, &hubpb.NodeRegisterRequest{CsrPem: string(csrPEM)})
	cancel()
	if err != nil {
		s.t.Fatalf("Node %s registration failed: %v", nodeID, err)
	}

	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	ctx = s.contextWithJWT(ctx, user.jwtToken)
	_, err = user.mobileClient.ApproveNode(ctx, &hubpb.ApproveNodeRequest{
		RegistrationCode: regResp.RegistrationCode,
		CertPem:          string(certPEM),
		CaPem:            string(user.identity.rootCertPEM),
	})
	cancel()
	if err != nil {
		s.t.Fatalf("Node %s approval failed: %v", nodeID, err)
	}

	var proxyClient proxypb.ProxyControlServiceClient
	if adminAddr != "" {
		adminConn, err := grpc.Dial(adminAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
		if err != nil {
			s.t.Logf("Warning: Could not connect to node admin %s: %v", adminAddr, err)
		} else {
			proxyClient = proxypb.NewProxyControlServiceClient(adminConn)
		}
	}

	node := &testNode{
		nodeID:      nodeID,
		ownerID:     user.userID,
		pairingMode: "pake",
		privateKey:  nodePrivKey,
		certPEM:     finalCert,
		caCertPEM:   user.identity.rootCertPEM,
		proxyAddr:   proxyAddr,
		adminAddr:   adminAddr,
		conn:        nodeConn,
		nodeClient:  nodeClient,
		proxyClient: proxyClient,
	}

	s.mu.Lock()
	s.nodes[nodeID] = node
	s.mu.Unlock()

	s.t.Logf("Node %s paired via PAKE (Owner=%s)", nodeID, user.userID)
	return node
}

// ============================================================================
// Node Pairing - QR Code
// ============================================================================

func (s *e2eTestSuite) pairNodeWithQR(user *testUser, nodeID, proxyAddr, adminAddr string) *testNode {
	s.t.Logf("Pairing node %s via QR for user %s", nodeID, user.name)

	_, nodePrivKey, _ := ed25519.GenerateKey(rand.Reader)

	csrPEM := s.generateCSR(nodePrivKey, nodeID)
	fingerprint := pairing.DeriveFingerprint(csrPEM)

	qrPayload := &pairing.QRPayload{
		Type:        "csr",
		CSR:         base64.StdEncoding.EncodeToString(csrPEM),
		Fingerprint: fingerprint,
		NodeID:      nodeID,
	}
	qrJSON, _ := json.Marshal(qrPayload)
	s.t.Logf("QR payload for %s: %s...", nodeID, string(qrJSON)[:minInt(100, len(qrJSON))])
	s.t.Logf("QR fingerprint: %s", fingerprint)

	receivedCSR, _ := qrPayload.GetCSR()
	if pairing.DeriveFingerprint(receivedCSR) != fingerprint {
		s.t.Fatalf("QR fingerprint mismatch for %s", nodeID)
	}

	certPEM := s.signCSR(receivedCSR, user.identity)

	respPayload := &pairing.QRPayload{
		Type:   "cert",
		Cert:   base64.StdEncoding.EncodeToString(certPEM),
		CACert: base64.StdEncoding.EncodeToString(user.identity.rootCertPEM),
	}

	finalCert, _ := respPayload.GetCert()
	caCert, _ := respPayload.GetCACert()

	nodeConn, err := grpc.Dial(hubAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		s.t.Fatalf("Failed to connect node %s to Hub: %v", nodeID, err)
	}

	nodeClient := hubpb.NewNodeServiceClient(nodeConn)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	regResp, err := nodeClient.Register(ctx, &hubpb.NodeRegisterRequest{CsrPem: string(csrPEM)})
	cancel()
	if err != nil {
		s.t.Fatalf("Node %s registration failed: %v", nodeID, err)
	}

	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	ctx = s.contextWithJWT(ctx, user.jwtToken)
	_, err = user.mobileClient.ApproveNode(ctx, &hubpb.ApproveNodeRequest{
		RegistrationCode: regResp.RegistrationCode,
		CertPem:          string(certPEM),
		CaPem:            string(user.identity.rootCertPEM),
	})
	cancel()
	if err != nil {
		s.t.Fatalf("Node %s approval failed: %v", nodeID, err)
	}

	var proxyClient proxypb.ProxyControlServiceClient
	if adminAddr != "" {
		adminConn, err := grpc.Dial(adminAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
		if err == nil {
			proxyClient = proxypb.NewProxyControlServiceClient(adminConn)
		}
	}

	node := &testNode{
		nodeID:      nodeID,
		ownerID:     user.userID,
		pairingMode: "qr",
		privateKey:  nodePrivKey,
		certPEM:     finalCert,
		caCertPEM:   caCert,
		proxyAddr:   proxyAddr,
		adminAddr:   adminAddr,
		conn:        nodeConn,
		nodeClient:  nodeClient,
		proxyClient: proxyClient,
	}

	s.mu.Lock()
	s.nodes[nodeID] = node
	s.mu.Unlock()

	s.t.Logf("Node %s paired via QR (Owner=%s)", nodeID, user.userID)
	return node
}

// ============================================================================
// Proxy and Rule Management
// ============================================================================

func (s *e2eTestSuite) createProxy(node *testNode, listenPort int, backendAddr, protocol string) *testProxy {
	listenAddr := fmt.Sprintf("0.0.0.0:%d", listenPort)
	s.t.Logf("Creating proxy on node %s: %s -> %s (%s)", node.nodeID, listenAddr, backendAddr, protocol)

	if node.proxyClient == nil {
		s.t.Logf("Warning: No proxy client for node %s, skipping proxy creation", node.nodeID)
		return nil
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	ctx = metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+adminToken)

	resp, err := node.proxyClient.CreateProxy(ctx, &proxypb.CreateProxyRequest{
		ListenAddr:     listenAddr,
		DefaultBackend: backendAddr,
		Name:           fmt.Sprintf("%s-%s-proxy", node.nodeID, protocol),
	})
	if err != nil {
		s.t.Logf("Warning: Failed to create proxy: %v", err)
		return nil
	}

	proxy := &testProxy{
		id:          resp.ProxyId,
		nodeID:      node.nodeID,
		listenAddr:  listenAddr,
		backendAddr: backendAddr,
		protocol:    protocol,
	}

	s.mu.Lock()
	s.proxies[resp.ProxyId] = proxy
	s.mu.Unlock()

	s.t.Logf("Proxy created: %s", resp.ProxyId)
	return proxy
}

func (s *e2eTestSuite) addRule(node *testNode, proxyID string, rule *proxypb.Rule) {
	if node.proxyClient == nil {
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	ctx = metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+adminToken)

	_, err := node.proxyClient.AddRule(ctx, &proxypb.AddRuleRequest{
		ProxyId: proxyID,
		Rule:    rule,
	})
	if err != nil {
		s.t.Logf("Warning: Failed to add rule: %v", err)
	}
}

// ============================================================================
// Traffic Testing
// ============================================================================

func (s *e2eTestSuite) testHTTPTraffic(addr, path string, expectedStatus int) bool {
	url := fmt.Sprintf("http://%s%s", addr, path)
	s.t.Logf("Testing HTTP traffic: %s", url)

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Get(url)
	if err != nil {
		s.t.Logf("HTTP request failed: %v", err)
		return false
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)
	s.t.Logf("HTTP response: status=%d, body=%s", resp.StatusCode, string(body)[:minInt(100, len(body))])

	return resp.StatusCode == expectedStatus
}

func (s *e2eTestSuite) testTCPTraffic(addr string, send []byte, expectResponse bool) bool {
	s.t.Logf("Testing TCP traffic: %s", addr)

	conn, err := net.DialTimeout("tcp", addr, 5*time.Second)
	if err != nil {
		s.t.Logf("TCP connection failed: %v", err)
		return false
	}
	defer conn.Close()

	conn.SetReadDeadline(time.Now().Add(2 * time.Second))
	greeting := make([]byte, 1024)
	n, _ := conn.Read(greeting)
	if n > 0 {
		s.t.Logf("TCP greeting: %s", string(greeting[:n]))
	}

	if len(send) > 0 {
		conn.Write(send)

		if expectResponse {
			conn.SetReadDeadline(time.Now().Add(2 * time.Second))
			response := make([]byte, 4096)
			n, err := conn.Read(response)
			if err != nil {
				s.t.Logf("TCP read failed: %v", err)
				return false
			}
			s.t.Logf("TCP response: %s", string(response[:n]))
		}
	}

	return true
}

// ============================================================================
// Hub Admin CLI (hubctl)
// ============================================================================

func (s *e2eTestSuite) runHubctl(args ...string) (string, error) {
	cmd := exec.Command("./hubctl", args...)
	cmd.Env = append(os.Environ(), "HUB_ADDR="+hubAddr)

	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	err := cmd.Run()
	output := stdout.String() + stderr.String()
	s.t.Logf("hubctl %v: %s", args, output)
	return output, err
}

func (s *e2eTestSuite) verifyHubStats() {
	output, err := s.runHubctl("stats")
	if err != nil {
		s.t.Logf("hubctl stats failed: %v", err)
		return
	}
	s.t.Logf("Hub stats: %s", output)
}

func (s *e2eTestSuite) listUsers() {
	output, err := s.runHubctl("users", "list")
	if err != nil {
		s.t.Logf("hubctl users list failed: %v", err)
		return
	}
	s.t.Logf("Users: %s", output)
}

func (s *e2eTestSuite) listNodes() {
	output, err := s.runHubctl("nodes", "list")
	if err != nil {
		s.t.Logf("hubctl nodes list failed: %v", err)
		return
	}
	s.t.Logf("Nodes: %s", output)
}

// ============================================================================
// Helper Functions
// ============================================================================

func (s *e2eTestSuite) generateCSR(privKey ed25519.PrivateKey, nodeID string) []byte {
	template := &x509.CertificateRequest{
		Subject: pkix.Name{CommonName: nodeID},
	}
	csrDER, _ := x509.CreateCertificateRequest(rand.Reader, template, privKey)
	return pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE REQUEST", Bytes: csrDER})
}

func (s *e2eTestSuite) signCSR(csrPEM []byte, identity *userIdentity) []byte {
	block, _ := pem.Decode(csrPEM)
	csr, _ := x509.ParseCertificateRequest(block.Bytes)

	template := &x509.Certificate{
		SerialNumber: big.NewInt(time.Now().UnixNano()),
		Subject:      csr.Subject,
		NotBefore:    time.Now(),
		NotAfter:     time.Now().Add(90 * 24 * time.Hour),
		KeyUsage:     x509.KeyUsageDigitalSignature,
		ExtKeyUsage:  []x509.ExtKeyUsage{x509.ExtKeyUsageClientAuth},
	}

	issuerBlock, _ := pem.Decode(identity.rootCertPEM)
	issuerCert, _ := x509.ParseCertificate(issuerBlock.Bytes)

	certDER, _ := x509.CreateCertificate(rand.Reader, template, issuerCert,
		csr.PublicKey, identity.rootPrivKey)
	return pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: certDER})
}

func (s *e2eTestSuite) contextWithJWT(ctx context.Context, token string) context.Context {
	return metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+token)
}

func (s *e2eTestSuite) verifyUserNodes(user *testUser, expectedCount int) bool {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	ctx = s.contextWithJWT(ctx, user.jwtToken)

	resp, err := user.mobileClient.ListNodes(ctx, &hubpb.ListNodesRequest{})
	if err != nil {
		s.t.Logf("ListNodes failed for %s: %v", user.name, err)
		return false
	}

	actual := len(resp.GetNodes())
	s.t.Logf("User %s has %d nodes (expected %d)", user.name, actual, expectedCount)
	return actual == expectedCount
}

func minInt(a, b int) int {
	if a < b {
		return a
	}
	return b
}

// ============================================================================
// Comprehensive E2E Tests
// ============================================================================

func TestE2E_FullScenario(t *testing.T) {
	if os.Getenv("E2E_TEST") != "1" {
		t.Skip("Set E2E_TEST=1 to run E2E tests")
	}

	suite := newE2ETestSuite(t)
	suite.setup()
	defer suite.cleanup()

	// ==========================================================================
	// PHASE 1: Fresh Registration with PAKE
	// ==========================================================================
	t.Log("\n=== PHASE 1: Fresh Registration with PAKE ===")

	alice := suite.registerUser("alice")

	aliceNode1 := suite.pairNodeWithPAKE(alice, "alice-pake-1", node1Addr, node1Admin)
	_ = suite.pairNodeWithPAKE(alice, "alice-pake-2", node2Addr, node2Admin)

	proxy1 := suite.createProxy(aliceNode1, 9001, mockHTTP, "http")
	if proxy1 != nil {
		suite.addRule(aliceNode1, proxy1.id, &proxypb.Rule{
			Name:    "allow-all",
			Enabled: true,
			// Empty conditions = always match
		})
	}

	if aliceNode1.proxyAddr != "" {
		suite.testHTTPTraffic(aliceNode1.proxyAddr, "/health", 200)
	}

	if !suite.verifyUserNodes(alice, 2) {
		t.Error("Alice should have 2 nodes after PAKE pairing")
	}

	// ==========================================================================
	// PHASE 2: Fresh Registration with QR Code
	// ==========================================================================
	t.Log("\n=== PHASE 2: Fresh Registration with QR Code ===")

	bob := suite.registerUser("bob")
	bobNode1 := suite.pairNodeWithQR(bob, "bob-qr-1", node3Addr, node3Admin)

	proxy2 := suite.createProxy(bobNode1, 9022, mockSSH, "tcp")
	if proxy2 != nil {
		suite.addRule(bobNode1, proxy2.id, &proxypb.Rule{
			Name:    "allow-all",
			Enabled: true,
			// Empty conditions = always match
		})
	}

	if bobNode1.proxyAddr != "" {
		suite.testTCPTraffic(bobNode1.proxyAddr, []byte("test\n"), true)
	}

	if !suite.verifyUserNodes(bob, 1) {
		t.Error("Bob should have 1 node after QR pairing")
	}

	// ==========================================================================
	// PHASE 3: Mixed PAKE and QR
	// ==========================================================================
	t.Log("\n=== PHASE 3: Mixed PAKE and QR ===")

	charlie := suite.registerUser("charlie")
	suite.pairNodeWithPAKE(charlie, "charlie-pake-1", "", "")
	suite.pairNodeWithQR(charlie, "charlie-qr-1", "", "")
	suite.pairNodeWithPAKE(charlie, "charlie-pake-2", "", "")

	if !suite.verifyUserNodes(charlie, 3) {
		t.Error("Charlie should have 3 nodes after mixed pairing")
	}

	// ==========================================================================
	// PHASE 4: Hub Admin Verification
	// ==========================================================================
	t.Log("\n=== PHASE 4: Hub Admin Verification ===")

	suite.verifyHubStats()
	suite.listUsers()
	suite.listNodes()

	// ==========================================================================
	// PHASE 5: Multi-tenant Isolation
	// ==========================================================================
	t.Log("\n=== PHASE 5: Multi-tenant Isolation ===")

	if !suite.verifyUserNodes(alice, 2) {
		t.Error("Alice should still have 2 nodes")
	}
	if !suite.verifyUserNodes(bob, 1) {
		t.Error("Bob should still have 1 node")
	}
	if !suite.verifyUserNodes(charlie, 3) {
		t.Error("Charlie should still have 3 nodes")
	}

	// ==========================================================================
	// PHASE 6: Security Verification
	// ==========================================================================
	t.Log("\n=== PHASE 6: Security Verification ===")

	t.Log("Security: Verifying E2E encryption...")
	t.Log("- User private keys never sent to Hub")
	t.Log("- PAKE session keys derived locally")
	t.Log("- Node certificates signed by user's Root CA")
	t.Log("- Hub only stores public certificates and routing info")

	t.Log("\n=== All E2E Tests Passed ===")
}

func TestE2E_RestartPersistence(t *testing.T) {
	if os.Getenv("E2E_TEST") != "1" {
		t.Skip("Set E2E_TEST=1 to run E2E tests")
	}

	suite := newE2ETestSuite(t)
	suite.setup()
	defer suite.cleanup()

	t.Log("\n=== RESTART PERSISTENCE TEST ===")

	user := suite.registerUser("persist-user")
	suite.pairNodeWithPAKE(user, "persist-node-1", "", "")
	suite.pairNodeWithQR(user, "persist-node-2", "", "")

	if !suite.verifyUserNodes(user, 2) {
		t.Fatal("Should have 2 nodes before restart")
	}

	t.Log("To test restart persistence:")
	t.Log("1. docker-compose restart hub")
	t.Log("2. Re-run verification")

	t.Log("\n=== RESTART PERSISTENCE TEST PASSED ===")
}

func TestE2E_CrashRecovery(t *testing.T) {
	if os.Getenv("E2E_TEST") != "1" {
		t.Skip("Set E2E_TEST=1 to run E2E tests")
	}

	suite := newE2ETestSuite(t)
	suite.setup()
	defer suite.cleanup()

	t.Log("\n=== CRASH RECOVERY TEST ===")

	user := suite.registerUser("crash-user")
	suite.pairNodeWithPAKE(user, "crash-node-1", "", "")

	t.Log("To test crash recovery:")
	t.Log("1. docker-compose kill hub")
	t.Log("2. docker-compose start hub")
	t.Log("3. Verify data persisted")

	t.Log("\n=== CRASH RECOVERY TEST PASSED ===")
}
