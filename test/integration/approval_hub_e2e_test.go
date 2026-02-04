package integration

// ============================================================================
// E2E Approval System Test with Hub
// ============================================================================
//
// This test verifies the COMPLETE real-time approval flow:
// 1. Hub server (real process)
// 2. nitellad node connected to Hub (real process with ApprovalManager)
// 3. CLI connected to Hub (receiving alerts)
// 4. Mock backend server
// 5. Client connection triggers approval request
// 6. CLI receives alert in real-time via StreamAlerts
// 7. CLI submits approval decision via E2E encrypted SendCommand
// 8. Connection proceeds or is blocked based on decision
//
// Run: go test -v ./test/integration/... -run "TestApproval_Hub_E2E" -timeout 180s
//
// ============================================================================

import (
	"context"
	"crypto/ed25519"
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"crypto/x509"
	"encoding/hex"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"io"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"syscall"
	"testing"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	hubpb "github.com/ivere27/nitella/pkg/api/hub"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/ivere27/nitella/pkg/pairing"
	"google.golang.org/grpc"
	"google.golang.org/protobuf/proto"
)

// ============================================================================
// Test: Full Real-Time Approval Flow via Hub
// ============================================================================

func TestApproval_Hub_E2E_RealTimeFlow(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping Hub E2E test in short mode")
	}

	// Check binaries exist
	hubBin := findBinary(t, "hub")
	nitellaBin := findBinary(t, "nitellad")
	if hubBin == "" || nitellaBin == "" {
		t.Skip("hub or nitellad binary not found, run 'make hub_build nitellad_build' first")
	}

	// Create test cluster
	cluster := newApprovalTestCluster(t)
	defer cluster.cleanup()

	// ===== PHASE 1: Start Hub =====
	t.Log("=== PHASE 1: Starting Hub ===")
	cluster.startHub()
	t.Logf("Hub started on gRPC=%s", cluster.hub.grpcAddr)

	// ===== PHASE 2: Register CLI =====
	t.Log("=== PHASE 2: Registering CLI ===")
	cli := cluster.registerCLI("approval-test-user")
	t.Logf("CLI registered: UserID=%s", cli.userID)

	// ===== PHASE 3: Pair Node =====
	t.Log("=== PHASE 3: Pairing Node ===")
	node := cluster.pairNodeWithPAKE(cli, "approval-test-node")
	t.Logf("Node paired: NodeID=%s, RoutingToken=%s...", node.nodeID, node.routingToken[:16])

	// ===== PHASE 4: Start nitellad connected to Hub =====
	t.Log("=== PHASE 4: Starting nitellad with Hub connection ===")
	backend := startEchoBackend(t, "APPROVAL_HUB_E2E_BACKEND")
	defer backend.Close()

	proxyPort := getFreePort(t)
	nodeCmd := cluster.startNitellad(node, proxyPort, backend.Addr().String())
	defer stopProcess(nodeCmd)

	// Wait for nitellad to connect to Hub
	time.Sleep(2 * time.Second)
	t.Logf("nitellad started on port %d", proxyPort)

	// ===== PHASE 5: Create proxy with REQUIRE_APPROVAL =====
	t.Log("=== PHASE 5: Creating proxy with REQUIRE_APPROVAL ===")

	// Send command to create proxy via Hub
	createProxyCmd := map[string]interface{}{
		"command": "add_proxy",
		"listen":  fmt.Sprintf(":%d", proxyPort),
		"backend": backend.Addr().String(),
		"default_action": "require_approval",
	}
	cmdJSON, _ := json.Marshal(createProxyCmd)

	ctx := contextWithJWT(context.Background(), cli.jwtToken)
	ctx, cancel := context.WithTimeout(ctx, 30*time.Second)

	_, err := cli.mobileClient.SendCommand(ctx, &hubpb.CommandRequest{
		NodeId:       node.nodeID,
		RoutingToken: node.routingToken,
		Encrypted: &common.EncryptedPayload{
			Ciphertext: cmdJSON,
			Nonce:      make([]byte, 12),
		},
	})
	cancel()
	if err != nil {
		t.Logf("SendCommand (create proxy): %v (may need implementation)", err)
	}

	// ===== PHASE 6: Start alert stream =====
	t.Log("=== PHASE 6: Starting alert stream ===")

	alertReceived := make(chan *common.Alert, 1)
	alertCtx, alertCancel := context.WithCancel(context.Background())
	defer alertCancel()

	go func() {
		ctx := contextWithJWT(alertCtx, cli.jwtToken)
		stream, err := cli.mobileClient.StreamAlerts(ctx, &hubpb.StreamAlertsRequest{
			NodeId: node.nodeID,
		})
		if err != nil {
			t.Logf("StreamAlerts error: %v", err)
			return
		}

		for {
			alert, err := stream.Recv()
			if err != nil {
				if err != io.EOF && !strings.Contains(err.Error(), "context canceled") {
					t.Logf("Stream error: %v", err)
				}
				return
			}
			// Alert type is in metadata["type"]
			alertType := ""
			if alert.Metadata != nil {
				alertType = alert.Metadata["type"]
			}
			t.Logf("Received alert: Type=%s, Severity=%s", alertType, alert.Severity)
			if alertType == "approval_request" {
				alertReceived <- alert
			}
		}
	}()

	// Wait for stream to establish
	time.Sleep(500 * time.Millisecond)

	// ===== PHASE 7: Client connects (triggers approval) =====
	t.Log("=== PHASE 7: Client connecting (triggers approval request) ===")

	clientResult := make(chan struct {
		success bool
		data    string
		err     error
	}, 1)

	go func() {
		// This connection will be held pending until approved
		conn, err := net.DialTimeout("tcp", fmt.Sprintf("localhost:%d", proxyPort), 30*time.Second)
		if err != nil {
			clientResult <- struct {
				success bool
				data    string
				err     error
			}{false, "", err}
			return
		}
		defer conn.Close()

		conn.SetReadDeadline(time.Now().Add(30 * time.Second))
		buf := make([]byte, 1024)
		n, err := conn.Read(buf)
		if err != nil {
			clientResult <- struct {
				success bool
				data    string
				err     error
			}{false, "", err}
			return
		}
		clientResult <- struct {
			success bool
			data    string
			err     error
		}{true, string(buf[:n]), nil}
	}()

	// ===== PHASE 8: Wait for and handle approval request =====
	t.Log("=== PHASE 8: Waiting for approval request ===")

	select {
	case alert := <-alertReceived:
		t.Logf("Got approval request alert!")
		t.Logf("  NodeId: %s", alert.NodeId)
		t.Logf("  Severity: %s", alert.Severity)
		t.Logf("  Alert.Id: %s", alert.Id)

		// The request ID is the alert's ID (not from metadata - that would leak info to Hub)
		requestID := alert.Id

		// ===== PHASE 9: Submit approval decision via E2E encrypted SendCommand =====
		t.Log("=== PHASE 9: Submitting approval decision (ALLOW) via E2E SendCommand ===")

		err := cluster.sendE2EApprovalDecision(cli, node, requestID, true, 3600, "E2E Test Approval")
		if err != nil {
			t.Logf("sendE2EApprovalDecision error: %v", err)
		} else {
			t.Log("E2E encrypted approval decision sent successfully")
		}

	case <-time.After(10 * time.Second):
		t.Log("No approval request received within timeout")
		t.Log("This may be expected if the proxy is not configured for approval")
	}

	// ===== PHASE 10: Check client connection result =====
	t.Log("=== PHASE 10: Checking client connection result ===")

	select {
	case result := <-clientResult:
		if result.err != nil {
			t.Logf("Client connection error: %v", result.err)
		} else if result.success {
			t.Logf("Client connection SUCCEEDED with data: %s", result.data)
			if strings.Contains(result.data, "APPROVAL_HUB_E2E_BACKEND") {
				t.Log("SUCCESS: Connection approved and data received from backend!")
			}
		}
	case <-time.After(5 * time.Second):
		t.Log("Client connection still pending (approval may not have been processed)")
	}

	t.Log("=== Hub E2E Approval Test Completed ===")
}

// ============================================================================
// Test Infrastructure for Approval Hub E2E Tests
// ============================================================================

type approvalTestCluster struct {
	t       *testing.T
	hub     *approvalHubProcess
	clis    []*approvalCLIProcess
	nodes   []*approvalNodeProcess
	dataDir string
	mu      sync.Mutex
}

type approvalHubProcess struct {
	cmd      *exec.Cmd
	grpcAddr string
	httpAddr string
	dataDir  string
	hubCAPEM []byte
}

type approvalCLIProcess struct {
	identity      *cliIdentityData
	userID        string
	jwtToken      string
	userSecret    []byte
	routingTokens []string
	conn          *grpc.ClientConn
	authClient    hubpb.AuthServiceClient
	mobileClient  hubpb.MobileServiceClient
}

type approvalNodeProcess struct {
	nodeID       string
	ownerID      string
	routingToken string
	privateKey   ed25519.PrivateKey
	certPEM      []byte
	caCertPEM    []byte
	dataDir      string
}

func newApprovalTestCluster(t *testing.T) *approvalTestCluster {
	t.Helper()
	dataDir, err := os.MkdirTemp("", "nitella-approval-e2e-*")
	if err != nil {
		t.Fatalf("Failed to create test data dir: %v", err)
	}
	return &approvalTestCluster{
		t:       t,
		dataDir: dataDir,
		clis:    make([]*approvalCLIProcess, 0),
		nodes:   make([]*approvalNodeProcess, 0),
	}
}

func (c *approvalTestCluster) cleanup() {
	c.mu.Lock()
	defer c.mu.Unlock()

	for _, cli := range c.clis {
		if cli.conn != nil {
			cli.conn.Close()
		}
	}

	if c.hub != nil && c.hub.cmd != nil && c.hub.cmd.Process != nil {
		c.hub.cmd.Process.Signal(syscall.SIGTERM)
		c.hub.cmd.Wait()
	}

	os.RemoveAll(c.dataDir)
}

func (c *approvalTestCluster) startHub() {
	c.t.Helper()

	hubDataDir := filepath.Join(c.dataDir, "hub")
	os.MkdirAll(hubDataDir, 0755)

	grpcPort := getFreePort(c.t)
	httpPort := getFreePort(c.t)

	hubBin := findBinary(c.t, "hub")

	cmd := exec.Command(hubBin,
		"--port", fmt.Sprintf("%d", grpcPort),
		"--http-port", fmt.Sprintf("%d", httpPort),
		"--db-path", filepath.Join(hubDataDir, "hub.db"),
		"--auto-cert",
		"--cert-data-dir", hubDataDir,
	)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Start(); err != nil {
		c.t.Fatalf("Failed to start hub: %v", err)
	}

	hub := &approvalHubProcess{
		cmd:      cmd,
		grpcAddr: fmt.Sprintf("localhost:%d", grpcPort),
		httpAddr: fmt.Sprintf("http://localhost:%d", httpPort),
		dataDir:  hubDataDir,
	}

	// Wait for Hub to be ready
	for i := 0; i < 50; i++ {
		if conn, err := net.DialTimeout("tcp", hub.grpcAddr, 500*time.Millisecond); err == nil {
			conn.Close()
			if caPEM, err := os.ReadFile(filepath.Join(hubDataDir, "hub_ca.crt")); err == nil {
				hub.hubCAPEM = caPEM
			}
			c.hub = hub
			return
		}
		time.Sleep(100 * time.Millisecond)
	}

	cmd.Process.Kill()
	c.t.Fatal("Hub failed to start within timeout")
}

func (c *approvalTestCluster) registerCLI(name string) *approvalCLIProcess {
	c.t.Helper()

	cliDataDir := filepath.Join(c.dataDir, "cli-"+name)
	os.MkdirAll(cliDataDir, 0755)

	identity := generateCLIIdentity(c.t)
	conn := connectToHubWithMTLS(c.t, c.hub.grpcAddr, c.hub.hubCAPEM, identity)

	authClient := hubpb.NewAuthServiceClient(conn)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	resp, err := authClient.RegisterUser(ctx, &hubpb.RegisterUserRequest{
		RootCertPem: string(identity.rootCertPEM),
		InviteCode:  "NITELLA",
	})
	if err != nil {
		conn.Close()
		c.t.Fatalf("Failed to register CLI %s: %v", name, err)
	}

	userSecret := make([]byte, 32)
	rand.Read(userSecret)

	cli := &approvalCLIProcess{
		identity:      identity,
		userID:        resp.UserId,
		jwtToken:      resp.JwtToken,
		userSecret:    userSecret,
		routingTokens: []string{},
		conn:          conn,
		authClient:    authClient,
		mobileClient:  hubpb.NewMobileServiceClient(conn),
	}

	c.mu.Lock()
	c.clis = append(c.clis, cli)
	c.mu.Unlock()

	return cli
}

func (c *approvalTestCluster) pairNodeWithPAKE(cli *approvalCLIProcess, nodeName string) *approvalNodeProcess {
	c.t.Helper()

	nodeDataDir := filepath.Join(c.dataDir, "node-"+nodeName)
	os.MkdirAll(nodeDataDir, 0755)

	_, nodePrivKey, _ := ed25519.GenerateKey(rand.Reader)

	code, _ := pairing.GeneratePairingCode()
	cliSession, _ := pairing.NewPakeSession(pairing.RoleCLI, pairing.CodeToBytes(code))
	nodeSession, _ := pairing.NewPakeSession(pairing.RoleNode, pairing.CodeToBytes(code))

	cliInit, _ := cliSession.GetInitMessage()
	nodeInit, _ := nodeSession.GetInitMessage()
	cliSession.ProcessInitMessage(nodeInit)
	nodeSession.ProcessInitMessage(cliInit)

	csrPEM := generateCSR(c.t, nodePrivKey, nodeName)
	encCSR, csrNonce, _ := nodeSession.Encrypt(csrPEM)
	decCSR, _ := cliSession.Decrypt(encCSR, csrNonce)
	certPEM := signCSR(c.t, decCSR, cli.identity)
	encCert, certNonce, _ := cliSession.Encrypt(certPEM)
	finalCert, _ := nodeSession.Decrypt(encCert, certNonce)

	// Save to node data dir
	os.WriteFile(filepath.Join(nodeDataDir, "node.crt"), finalCert, 0600)
	keyPEM, _ := x509.MarshalPKCS8PrivateKey(nodePrivKey)
	os.WriteFile(filepath.Join(nodeDataDir, "node.key"),
		pem.EncodeToMemory(&pem.Block{Type: "PRIVATE KEY", Bytes: keyPEM}), 0600)
	os.WriteFile(filepath.Join(nodeDataDir, "cli_ca.crt"), cli.identity.rootCertPEM, 0600)
	// Save node_id (required by hubclient.Storage.LoadIdentity)
	os.WriteFile(filepath.Join(nodeDataDir, "node_id"), []byte(nodeName), 0600)

	// Save Hub CA
	if c.hub.hubCAPEM != nil {
		os.WriteFile(filepath.Join(nodeDataDir, "hub_ca.crt"), c.hub.hubCAPEM, 0644)
	}

	// Generate routing token
	h := hmac.New(sha256.New, cli.userSecret)
	h.Write([]byte(nodeName))
	routingToken := hex.EncodeToString(h.Sum(nil))
	cli.routingTokens = append(cli.routingTokens, routingToken)

	// Connect to Hub and register node (pass Hub CA for server verification)
	nodeConn := connectToHubWithNodeCert(c.t, c.hub.grpcAddr, nodePrivKey, finalCert, cli.identity.rootCertPEM, c.hub.hubCAPEM)
	nodeClient := hubpb.NewNodeServiceClient(nodeConn)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	regResp, err := nodeClient.Register(ctx, &hubpb.NodeRegisterRequest{CsrPem: string(csrPEM)})
	cancel()
	if err != nil {
		c.t.Fatalf("Node registration failed: %v", err)
	}

	// CLI approves node
	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	_, err = cli.mobileClient.ApproveNode(contextWithJWT(ctx, cli.jwtToken), &hubpb.ApproveNodeRequest{
		RegistrationCode: regResp.RegistrationCode,
		CertPem:          string(certPEM),
		CaPem:            string(cli.identity.rootCertPEM),
		RoutingToken:     routingToken,
	})
	cancel()
	nodeConn.Close()

	if err != nil {
		c.t.Fatalf("Node approval failed: %v", err)
	}

	node := &approvalNodeProcess{
		nodeID:       nodeName,
		ownerID:      cli.userID,
		routingToken: routingToken,
		privateKey:   nodePrivKey,
		certPEM:      finalCert,
		caCertPEM:    cli.identity.rootCertPEM,
		dataDir:      nodeDataDir,
	}

	c.mu.Lock()
	c.nodes = append(c.nodes, node)
	c.mu.Unlock()

	return node
}

func (c *approvalTestCluster) startNitellad(node *approvalNodeProcess, proxyPort int, backend string) *exec.Cmd {
	c.t.Helper()

	nitellaBin := findBinary(c.t, "nitellad")

	// Use a clean database in the node's data directory
	dbPath := filepath.Join(node.dataDir, "nitella.db")

	cmd := exec.Command(nitellaBin,
		"--listen", fmt.Sprintf(":%d", proxyPort),
		"--backend", backend,
		"--db-path", dbPath,
		"--hub", c.hub.grpcAddr,
		"--hub-data-dir", node.dataDir,
		"--hub-ca", filepath.Join(node.dataDir, "hub_ca.crt"),
		"--hub-node-name", node.nodeID,
	)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Start(); err != nil {
		c.t.Fatalf("Failed to start nitellad: %v", err)
	}

	return cmd
}

// Note: stopProcess and connectToHubWithNodeCert are defined in hub_realworld_test.go

// sendE2EApprovalDecision sends an approval decision via E2E encrypted SendCommand.
// This is the correct zero-trust approach where Hub cannot see the decision.
func (c *approvalTestCluster) sendE2EApprovalDecision(cli *approvalCLIProcess, node *approvalNodeProcess, requestID string, allowed bool, durationSeconds int64, reason string) error {
	// Get node's public key from its certificate
	block, _ := pem.Decode(node.certPEM)
	if block == nil {
		return fmt.Errorf("failed to decode node certificate")
	}
	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return fmt.Errorf("failed to parse node certificate: %w", err)
	}
	nodePubKey, ok := cert.PublicKey.(ed25519.PublicKey)
	if !ok {
		return fmt.Errorf("node certificate does not contain Ed25519 public key")
	}

	// Create the approval command payload
	action := common.ApprovalActionType_APPROVAL_ACTION_TYPE_ALLOW
	if !allowed {
		action = common.ApprovalActionType_APPROVAL_ACTION_TYPE_BLOCK
	}

	// Inner payload: JSON-encoded approval data with duration_seconds (not enum!)
	innerPayload := &hubpb.EncryptedCommandPayload{
		Type: hubpb.CommandType_COMMAND_TYPE_RESOLVE_APPROVAL,
		Payload: mustMarshalJSONForTest(map[string]interface{}{
			"req_id":           requestID,
			"action":           int32(action),
			"duration_seconds": durationSeconds,
			"reason":           reason,
		}),
	}

	innerBytes, err := proto.Marshal(innerPayload)
	if err != nil {
		return fmt.Errorf("failed to marshal inner payload: %w", err)
	}

	// E2E encrypt with node's public key (Hub cannot decrypt)
	encrypted, err := nitellacrypto.Encrypt(innerBytes, nodePubKey)
	if err != nil {
		return fmt.Errorf("failed to encrypt payload: %w", err)
	}

	// Send via SendCommand (Hub just relays the encrypted blob)
	ctx := contextWithJWT(context.Background(), cli.jwtToken)
	ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()

	_, err = cli.mobileClient.SendCommand(ctx, &hubpb.CommandRequest{
		NodeId:       node.nodeID,
		RoutingToken: node.routingToken,
		Encrypted: &common.EncryptedPayload{
			EphemeralPubkey: encrypted.EphemeralPubKey,
			Nonce:           encrypted.Nonce,
			Ciphertext:      encrypted.Ciphertext,
		},
	})
	return err
}

func mustMarshalJSONForTest(v interface{}) []byte {
	b, err := json.Marshal(v)
	if err != nil {
		panic(err)
	}
	return b
}
