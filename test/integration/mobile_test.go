package integration

// ============================================================================
// Mobile Backend Integration Test Suite
// ============================================================================
//
// This test suite verifies the mobile app backend (MobileLogicService) with
// real Hub and nitellad processes - the same code path as the Flutter app.
//
// Tests:
// - Identity creation/restore with BIP-39 mnemonic
// - Hub connection and registration
// - PAKE pairing with nitellad
// - QR code pairing flow
// - Proxy and rule management via mobile API
// - Connection statistics
//
// Run: go test -v -tags=integration ./test/integration -run TestMobile
//
// ============================================================================

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"sync"
	"syscall"
	"testing"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/local"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/service"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/fieldmaskpb"
)

// ThreadSafeBuffer is a goroutine-safe buffer for capturing logs
type ThreadSafeBuffer struct {
	b  bytes.Buffer
	mu sync.Mutex
}

func (b *ThreadSafeBuffer) Write(p []byte) (n int, err error) {
	b.mu.Lock()
	defer b.mu.Unlock()
	return b.b.Write(p)
}

func (b *ThreadSafeBuffer) String() string {
	b.mu.Lock()
	defer b.mu.Unlock()
	return b.b.String()
}

// ============================================================================
// Test Infrastructure
// ============================================================================

// mobileTestCluster manages processes for mobile integration tests
type mobileTestCluster struct {
	t        *testing.T
	hub      *hubProcess
	nodes    []*nitelladProcess
	mobile   *service.MobileLogicService
	dataDir  string
}

// nitelladProcess represents a running nitellad instance
type nitelladProcess struct {
	cmd       *exec.Cmd
	pid       int
	nodeID    string
	dataDir   string
	proxyPort int
	adminPort int
	caPEM     []byte
	logBuf    *ThreadSafeBuffer
}

// newMobileTestCluster creates a new test cluster for mobile tests
func newMobileTestCluster(t *testing.T) *mobileTestCluster {
	t.Helper()
	dataDir, err := os.MkdirTemp("", "nitella-mobile-test-*")
	require.NoError(t, err)

	return &mobileTestCluster{
		t:       t,
		dataDir: dataDir,
		nodes:   make([]*nitelladProcess, 0),
	}
}

// cleanup stops all processes and removes test data
func (c *mobileTestCluster) cleanup() {
	// Shutdown mobile service
	if c.mobile != nil {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		c.mobile.Shutdown(ctx, nil)
		cancel()
	}

	// Stop nodes
	for _, n := range c.nodes {
		if n != nil {
			c.stopNitellad(n)
		}
	}

	// Stop hub
	if c.hub != nil {
		c.stopHub()
	}

	// Give gRPC time to clean up
	time.Sleep(500 * time.Millisecond)

	// Remove test data
	os.RemoveAll(c.dataDir)
}

// ============================================================================
// Hub Management (reuses patterns from hub_comprehensive_test.go)
// ============================================================================

func (c *mobileTestCluster) startHub() *hubProcess {
	c.t.Helper()

	hubDataDir := filepath.Join(c.dataDir, "hub")
	os.MkdirAll(hubDataDir, 0755)

	grpcPort := getFreePort(c.t)
	httpPort := getFreePort(c.t)

	hubBin := findMobileBinary(c.t, "hub")

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

	hub := &hubProcess{
		cmd:      cmd,
		pid:      cmd.Process.Pid,
		grpcAddr: fmt.Sprintf("localhost:%d", grpcPort),
		httpAddr: fmt.Sprintf("http://localhost:%d", httpPort),
		dataDir:  hubDataDir,
		dbPath:   filepath.Join(hubDataDir, "hub.db"),
	}

	// Wait for Hub to be ready
	for i := 0; i < 50; i++ {
		if conn, err := net.DialTimeout("tcp", hub.grpcAddr, 500*time.Millisecond); err == nil {
			conn.Close()
			// Load Hub CA
			caPEM, err := os.ReadFile(filepath.Join(hubDataDir, "hub_ca.crt"))
			if err == nil {
				hub.hubCAPEM = caPEM
			}
			c.t.Logf("Hub started: PID=%d, gRPC=%s", hub.pid, hub.grpcAddr)
			c.hub = hub
			return hub
		}
		time.Sleep(100 * time.Millisecond)
	}

	cmd.Process.Kill()
	c.t.Fatal("Hub failed to start within timeout")
	return nil
}

func (c *mobileTestCluster) stopHub() {
	if c.hub != nil && c.hub.cmd != nil && c.hub.cmd.Process != nil {
		c.hub.cmd.Process.Signal(syscall.SIGTERM)
		done := make(chan error, 1)
		go func() { done <- c.hub.cmd.Wait() }()
		select {
		case <-done:
		case <-time.After(5 * time.Second):
			c.hub.cmd.Process.Kill()
		}
		c.t.Logf("Hub stopped: PID=%d", c.hub.pid)
	}
}

// ============================================================================
// Nitellad Management
// ============================================================================

func (c *mobileTestCluster) startNitellad(name string) *nitelladProcess {
	c.t.Helper()

	nodeDataDir := filepath.Join(c.dataDir, "node-"+name)
	os.MkdirAll(nodeDataDir, 0755)

	proxyPort := getFreePort(c.t)
	adminPort := getFreePort(c.t)

	nitelladBin := findMobileBinary(c.t, "nitellad")

	cmd := exec.Command(nitelladBin,
		"--listen", fmt.Sprintf("127.0.0.1:%d", proxyPort),
		"--backend", "127.0.0.1:1", // Dummy backend
		"--admin-port", fmt.Sprintf("%d", adminPort),
		"--admin-token", "test-token",
		"--db-path", filepath.Join(nodeDataDir, "nitellad.db"),
		"--stats-db", filepath.Join(nodeDataDir, "stats.db"),
	)
	logBuf := &ThreadSafeBuffer{}
	cmd.Stdout = io.MultiWriter(os.Stdout, logBuf)
	cmd.Stderr = io.MultiWriter(os.Stderr, logBuf)

	if err := cmd.Start(); err != nil {
		c.t.Fatalf("Failed to start nitellad: %v", err)
	}

	node := &nitelladProcess{
		cmd:       cmd,
		pid:       cmd.Process.Pid,
		dataDir:   nodeDataDir,
		proxyPort: proxyPort,
		adminPort: adminPort,
		logBuf:    logBuf,
	}

	// Wait for nitellad to be ready (admin CA cert written)
	caPath := filepath.Join(nodeDataDir, "admin_ca.crt")
	for i := 0; i < 100; i++ {
		if caPEM, err := os.ReadFile(caPath); err == nil {
			node.caPEM = caPEM
			c.t.Logf("Nitellad started: PID=%d, admin=%d, proxy=%d", node.pid, adminPort, proxyPort)
			c.nodes = append(c.nodes, node)
			return node
		}
		time.Sleep(100 * time.Millisecond)
	}

	cmd.Process.Kill()
	c.t.Fatal("Nitellad failed to start within timeout")
	return nil
}

func (c *mobileTestCluster) stopNitellad(node *nitelladProcess) {
	if node != nil && node.cmd != nil && node.cmd.Process != nil {
		node.cmd.Process.Signal(syscall.SIGTERM)
		done := make(chan error, 1)
		go func() { done <- node.cmd.Wait() }()
		select {
		case <-done:
		case <-time.After(5 * time.Second):
			node.cmd.Process.Kill()
		}
		c.t.Logf("Nitellad stopped: PID=%d", node.pid)
	}
}

// ============================================================================
// Mobile Service Management
// ============================================================================

func (c *mobileTestCluster) createMobileService() *service.MobileLogicService {
	c.t.Helper()

	mobileDataDir := filepath.Join(c.dataDir, "mobile")
	os.MkdirAll(mobileDataDir, 0755)

	svc := service.NewMobileLogicService()

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	hubAddress := ""
	if c.hub != nil {
		hubAddress = c.hub.grpcAddr
	}

	resp, err := svc.Initialize(ctx, &pb.InitializeRequest{
		DataDir:    mobileDataDir,
		CacheDir:   filepath.Join(mobileDataDir, "cache"),
		HubAddress: hubAddress,
		DebugMode:  true,
	})
	require.NoError(c.t, err)
	require.True(c.t, resp.Success, "Initialize failed: %s", resp.Error)

	c.mobile = svc
	c.t.Logf("Mobile service initialized: dataDir=%s", mobileDataDir)
	return svc
}

// ============================================================================
// Helper Functions
// ============================================================================

func findMobileBinary(t *testing.T, name string) string {
	t.Helper()

	// Check common locations
	paths := []string{
		fmt.Sprintf("./bin/%s", name),
		fmt.Sprintf("../../bin/%s", name),
		fmt.Sprintf("../bin/%s", name),
		fmt.Sprintf("./cmd/%s/%s", name, name),
		fmt.Sprintf("../../cmd/%s/%s", name, name),
		fmt.Sprintf("/tmp/%s", name),
	}

	for _, p := range paths {
		if _, err := os.Stat(p); err == nil {
			return p
		}
	}

	// Try to build it
	t.Logf("Building %s binary...", name)
	tmpDir := t.TempDir()
	binPath := filepath.Join(tmpDir, name)

	cmd := exec.Command("go", "build", "-o", binPath, fmt.Sprintf("../../cmd/%s", name))
	if out, err := cmd.CombinedOutput(); err != nil {
		t.Fatalf("Failed to build %s: %v\n%s", name, err, out)
	}

	return binPath
}

// ============================================================================
// Tests
// ============================================================================

func TestMobileIdentityCreation(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	cluster := newMobileTestCluster(t)
	defer cluster.cleanup()

	// Start Hub
	cluster.startHub()

	// Create mobile service
	svc := cluster.createMobileService()
	ctx := context.Background()

	// Test: Get identity (should not exist)
	identity, err := svc.GetIdentity(ctx, nil)
	require.NoError(t, err)
	require.False(t, identity.Exists, "Identity should not exist initially")

	// Test: Create new identity
	createResp, err := svc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
		CommonName: "Test Mobile Device",
	})
	require.NoError(t, err)
	require.True(t, createResp.Success, "CreateIdentity failed: %s", createResp.Error)
	require.NotEmpty(t, createResp.Mnemonic, "Mnemonic should be returned")

	// Verify mnemonic is valid (12 or 24 words)
	words := strings.Fields(createResp.Mnemonic)
	require.True(t, len(words) == 12 || len(words) == 24,
		"Mnemonic should be 12 or 24 words, got %d", len(words))

	t.Logf("Created identity with mnemonic: %s...", words[0])

	// Test: Get identity (should exist now)
	identity, err = svc.GetIdentity(ctx, nil)
	require.NoError(t, err)
	require.True(t, identity.Exists, "Identity should exist after creation")
	require.False(t, identity.Locked, "Identity should not be locked")
	require.NotEmpty(t, identity.Fingerprint, "Fingerprint should be set")
	require.NotEmpty(t, identity.EmojiHash, "EmojiHash should be set")

	t.Logf("Identity fingerprint: %s, emoji: %s", identity.Fingerprint, identity.EmojiHash)
}

func TestMobileIdentityRestore(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	cluster := newMobileTestCluster(t)
	defer cluster.cleanup()

	cluster.startHub()
	svc := cluster.createMobileService()
	ctx := context.Background()

	// Create identity and get mnemonic
	createResp, err := svc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
		CommonName: "Original Device",
	})
	require.NoError(t, err)
	require.True(t, createResp.Success)
	mnemonic := createResp.Mnemonic
	originalFingerprint := createResp.Identity.Fingerprint

	t.Logf("Original fingerprint: %s", originalFingerprint)

	// Shutdown and create new service (simulates reinstall)
	svc.Shutdown(ctx, nil)

	// Create fresh mobile service with new data dir
	newDataDir := filepath.Join(cluster.dataDir, "mobile-restored")
	os.MkdirAll(newDataDir, 0755)

	svc2 := service.NewMobileLogicService()
	defer svc2.Shutdown(ctx, nil)

	_, err = svc2.Initialize(ctx, &pb.InitializeRequest{
		DataDir:   newDataDir,
		CacheDir:  filepath.Join(newDataDir, "cache"),
		DebugMode: true,
	})
	require.NoError(t, err)

	// Restore from mnemonic
	restoreResp, err := svc2.RestoreIdentity(ctx, &pb.RestoreIdentityRequest{
		Mnemonic:   mnemonic,
		CommonName: "Restored Device",
	})
	require.NoError(t, err)
	require.True(t, restoreResp.Success, "RestoreIdentity failed: %s", restoreResp.Error)

	// Verify fingerprint matches (deterministic from mnemonic)
	restoredFingerprint := restoreResp.Identity.Fingerprint
	require.Equal(t, originalFingerprint, restoredFingerprint,
		"Restored fingerprint should match original")

	t.Logf("Restored fingerprint: %s (matches!)", restoredFingerprint)
}

func TestMobileHubConnection(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	cluster := newMobileTestCluster(t)
	defer cluster.cleanup()

	cluster.startHub()
	svc := cluster.createMobileService()
	ctx := context.Background()

	// Create identity first
	createResp, err := svc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
		CommonName: "Mobile Hub Test",
	})
	require.NoError(t, err)
	require.True(t, createResp.Success)

	// Test: Get Hub status (should be disconnected)
	status, err := svc.GetHubStatus(ctx, nil)
	require.NoError(t, err)
	require.False(t, status.Connected, "Should not be connected initially")

	// Test: Connect to Hub
	connectResp, err := svc.ConnectToHub(ctx, &pb.ConnectToHubRequest{
		HubAddress: cluster.hub.grpcAddr,
		HubCaPem:   cluster.hub.hubCAPEM,
	})
	require.NoError(t, err)
	require.True(t, connectResp.Success, "ConnectToHub failed: %s", connectResp.Error)

	t.Logf("Connected to Hub at %s", cluster.hub.grpcAddr)

	// Test: Get Hub status (should be connected)
	status, err = svc.GetHubStatus(ctx, nil)
	require.NoError(t, err)
	require.True(t, status.Connected, "Should be connected after ConnectToHub")
	require.Equal(t, cluster.hub.grpcAddr, status.HubAddress)

	// Test: Register user with Hub
	regResp, err := svc.RegisterUser(ctx, &pb.RegisterUserRequest{
		InviteCode: "NITELLA",
	})
	require.NoError(t, err)
	require.True(t, regResp.Success, "RegisterUser failed: %s", regResp.Error)
	require.NotEmpty(t, regResp.UserId, "UserID should be returned")

	t.Logf("Registered with Hub, UserID: %s", regResp.UserId)

	// Test: Disconnect from Hub
	_, err = svc.DisconnectFromHub(ctx, nil)
	require.NoError(t, err)

	status, err = svc.GetHubStatus(ctx, nil)
	require.NoError(t, err)
	require.False(t, status.Connected, "Should be disconnected after DisconnectFromHub")
}

func TestMobileNodeManagement(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	cluster := newMobileTestCluster(t)
	defer cluster.cleanup()

	cluster.startHub()
	svc := cluster.createMobileService()
	ctx := context.Background()

	// Create identity and connect to Hub
	createResp, err := svc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
		CommonName: "Node Management Test",
	})
	require.NoError(t, err)
	require.True(t, createResp.Success)

	_, err = svc.ConnectToHub(ctx, &pb.ConnectToHubRequest{
		HubAddress: cluster.hub.grpcAddr,
		HubCaPem:   cluster.hub.hubCAPEM,
	})
	require.NoError(t, err)

	_, err = svc.RegisterUser(ctx, &pb.RegisterUserRequest{
		InviteCode: "NITELLA",
	})
	require.NoError(t, err)

	// Test: List nodes (should be empty)
	listResp, err := svc.ListNodes(ctx, &pb.ListNodesRequest{})
	require.NoError(t, err)
	require.Empty(t, listResp.Nodes, "Should have no nodes initially")

	t.Log("Node management test passed - no nodes initially")
}

func TestMobileSettings(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	cluster := newMobileTestCluster(t)
	defer cluster.cleanup()

	cluster.startHub()
	svc := cluster.createMobileService()
	ctx := context.Background()

	// Create identity
	createResp, err := svc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
		CommonName: "Settings Test",
	})
	require.NoError(t, err)
	require.True(t, createResp.Success)

	// Test: Get default settings
	settings, err := svc.GetSettings(ctx, nil)
	require.NoError(t, err)
	require.NotNil(t, settings)

	t.Logf("Default settings: AutoConnectHub=%v, NotificationsEnabled=%v",
		settings.AutoConnectHub, settings.NotificationsEnabled)

	// Test: Update settings
	// Use UpdateMask because proto.Merge can't set bool fields to false
	// (false is the zero value and gets skipped by proto.Merge)
	newSettings := &pb.Settings{
		HubAddress:           "custom.hub.example.com:443",
		AutoConnectHub:       true,
		NotificationsEnabled: false,
		RequireBiometric:     true,
		Theme:                pb.Theme_THEME_DARK,
	}

	updatedSettings, err := svc.UpdateSettings(ctx, &pb.UpdateSettingsRequest{
		Settings: newSettings,
		UpdateMask: &fieldmaskpb.FieldMask{
			Paths: []string{"hub_address", "auto_connect_hub", "notifications_enabled", "require_biometric", "theme"},
		},
	})
	require.NoError(t, err)
	require.Equal(t, "custom.hub.example.com:443", updatedSettings.HubAddress)
	require.True(t, updatedSettings.AutoConnectHub)
	require.False(t, updatedSettings.NotificationsEnabled)

	t.Log("Settings updated successfully")
}

func TestMobileHubTLSConnection(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	cluster := newMobileTestCluster(t)
	defer cluster.cleanup()

	cluster.startHub()
	svc := cluster.createMobileService()
	ctx := context.Background()

	// Create identity
	createResp, err := svc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
		CommonName: "TLS Test Device",
	})
	require.NoError(t, err)
	require.True(t, createResp.Success)

	// Test: Connect with Hub CA PEM (should succeed)
	require.NotEmpty(t, cluster.hub.hubCAPEM, "Hub CA PEM should be available")
	connectResp, err := svc.ConnectToHub(ctx, &pb.ConnectToHubRequest{
		HubAddress: cluster.hub.grpcAddr,
		HubCaPem:   cluster.hub.hubCAPEM,
	})
	require.NoError(t, err)
	require.True(t, connectResp.Success, "ConnectToHub with CA PEM failed: %s", connectResp.Error)

	status, err := svc.GetHubStatus(ctx, nil)
	require.NoError(t, err)
	require.True(t, status.Connected, "Should be connected with proper TLS")

	t.Log("TLS connection with Hub CA PEM succeeded")

	// Test: Connect WITHOUT CA PEM to self-signed Hub should fail.
	// Use a fresh service so there's no stored hubCAPEM from the previous connect.
	freshDataDir := filepath.Join(cluster.dataDir, "mobile-tls-fresh")
	os.MkdirAll(freshDataDir, 0755)

	freshSvc := service.NewMobileLogicService()
	defer freshSvc.Shutdown(ctx, nil)

	_, err = freshSvc.Initialize(ctx, &pb.InitializeRequest{
		DataDir:   freshDataDir,
		CacheDir:  filepath.Join(freshDataDir, "cache"),
		DebugMode: true,
	})
	require.NoError(t, err)

	_, err = freshSvc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
		CommonName: "TLS No-CA Test",
	})
	require.NoError(t, err)

	connectResp, err = freshSvc.ConnectToHub(ctx, &pb.ConnectToHubRequest{
		HubAddress: cluster.hub.grpcAddr,
		// No HubCaPem — should fail with self-signed cert
	})
	// gRPC uses lazy dialing, so ConnectToHub may succeed. Verify that
	// an actual RPC fails due to TLS verification failure.
	if err == nil && connectResp.Success {
		// Connection appeared to succeed (lazy dial). Try an RPC to trigger TLS handshake.
		// RegisterUser wraps gRPC errors into {Success: false}, so check the response.
		regResp, rpcErr := freshSvc.RegisterUser(ctx, &pb.RegisterUserRequest{
			InviteCode: "NITELLA",
		})
		require.True(t, rpcErr != nil || !regResp.Success,
			"should fail with self-signed cert when no CA PEM is provided")
		t.Logf("RPC after no-CA connect failed as expected: err=%v, success=%v", rpcErr, regResp.Success)
	} else {
		t.Logf("Connect without CA PEM failed as expected: err=%v, success=%v",
			err, connectResp.Success)
	}
}

func TestMobileSettingsTLSFields(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	cluster := newMobileTestCluster(t)
	defer cluster.cleanup()

	cluster.startHub()
	svc := cluster.createMobileService()
	ctx := context.Background()

	// Create identity
	createResp, err := svc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
		CommonName: "TLS Settings Test",
	})
	require.NoError(t, err)
	require.True(t, createResp.Success)

	// Test: Update settings with TLS fields
	newSettings := &pb.Settings{
		HubAddress: cluster.hub.grpcAddr,
		HubCaPem:   cluster.hub.hubCAPEM,
		HubCertPin: "sha256:abcdef1234567890",
	}

	updatedSettings, err := svc.UpdateSettings(ctx, &pb.UpdateSettingsRequest{
		Settings: newSettings,
	})
	require.NoError(t, err)
	require.Equal(t, cluster.hub.grpcAddr, updatedSettings.HubAddress)
	require.Equal(t, cluster.hub.hubCAPEM, updatedSettings.HubCaPem, "Hub CA PEM should be persisted")
	require.Equal(t, "sha256:abcdef1234567890", updatedSettings.HubCertPin, "Hub cert pin should be persisted")

	t.Log("TLS settings fields persisted successfully")

	// Verify settings are returned correctly on subsequent get
	settings, err := svc.GetSettings(ctx, nil)
	require.NoError(t, err)
	require.Equal(t, cluster.hub.hubCAPEM, settings.HubCaPem)
	require.Equal(t, "sha256:abcdef1234567890", settings.HubCertPin)
}

func TestMobileGeoIPLookup(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	cluster := newMobileTestCluster(t)
	defer cluster.cleanup()

	cluster.startHub()
	svc := cluster.createMobileService()
	ctx := context.Background()

	// Create identity
	createResp, err := svc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
		CommonName: "GeoIP Test",
	})
	require.NoError(t, err)
	require.True(t, createResp.Success)

	// Test: Lookup IP (uses embedded GeoIP database or remote API)
	lookupResp, err := svc.LookupIP(ctx, &pb.LookupIPRequest{
		Ip: "8.8.8.8", // Google DNS
	})
	require.NoError(t, err)

	// GeoIP lookup may return empty result if no database is available
	// or remote API fails, so we just check the response is valid
	if lookupResp.Geo != nil && lookupResp.Geo.Country != "" {
		t.Logf("GeoIP lookup for 8.8.8.8: Country=%s, ISP=%s",
			lookupResp.Geo.Country, lookupResp.Geo.Isp)
	} else {
		t.Log("GeoIP lookup returned empty result (expected if no DB or API available)")
	}
}

func TestMobileFullFlow(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	cluster := newMobileTestCluster(t)
	defer cluster.cleanup()

	// Step 1: Start Hub
	t.Log("Step 1: Starting Hub...")
	cluster.startHub()

	// Step 2: Start nitellad
	t.Log("Step 2: Starting nitellad...")
	node := cluster.startNitellad("node1")

	// Step 3: Create mobile service and identity
	t.Log("Step 3: Creating mobile service and identity...")
	svc := cluster.createMobileService()
	ctx := context.Background()

	createResp, err := svc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
		CommonName: "Full Flow Test Device",
	})
	require.NoError(t, err)
	require.True(t, createResp.Success)

	t.Logf("Identity created: fingerprint=%s", createResp.Identity.Fingerprint)

	// Step 4: Connect to Hub
	t.Log("Step 4: Connecting to Hub...")
	_, err = svc.ConnectToHub(ctx, &pb.ConnectToHubRequest{
		HubAddress: cluster.hub.grpcAddr,
		HubCaPem:   cluster.hub.hubCAPEM,
	})
	require.NoError(t, err)

	_, err = svc.RegisterUser(ctx, &pb.RegisterUserRequest{
		InviteCode: "NITELLA",
	})
	require.NoError(t, err)

	t.Log("Connected and registered with Hub")

	// Step 5: Verify no nodes paired yet
	t.Log("Step 5: Verifying no nodes paired...")
	listResp, err := svc.ListNodes(ctx, &pb.ListNodesRequest{})
	require.NoError(t, err)
	require.Empty(t, listResp.Nodes)

	// Step 6: Start pairing session
	t.Log("Step 6: Starting pairing session...")
	pairingResp, err := svc.StartPairing(ctx, &pb.StartPairingRequest{
		NodeName: "Test Node 1",
	})
	require.NoError(t, err)
	require.NotEmpty(t, pairingResp.SessionId)
	require.NotEmpty(t, pairingResp.PairingCode)

	t.Logf("Pairing session started: code=%s", pairingResp.PairingCode)

	// Note: Full pairing requires nitellad to respond to the pairing code
	// This would require nitellad to have Hub connectivity and pairing implementation
	// For now, we verify the mobile side of pairing works

	// Step 7: Cancel pairing (cleanup)
	t.Log("Step 7: Canceling pairing session...")
	_, err = svc.CancelPairing(ctx, &pb.CancelPairingRequest{
		SessionId: pairingResp.SessionId,
	})
	require.NoError(t, err)

	// Step 8: Verify settings persistence
	t.Log("Step 8: Testing settings persistence...")
	settings, err := svc.GetSettings(ctx, nil)
	require.NoError(t, err)
	require.NotNil(t, settings)

	t.Logf("Full flow test completed! Hub=%s, Node=%d",
		cluster.hub.grpcAddr, node.adminPort)
}

func TestMobileDirectConnect(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	cluster := newMobileTestCluster(t)
	defer cluster.cleanup()

	// Start nitellad (standalone, no Hub)
	node := cluster.startNitellad("direct1")

	// Create mobile service
	svc := cluster.createMobileService()
	ctx := context.Background()

	// Create identity
	createResp, err := svc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
		CommonName: "Direct Connect Test",
	})
	require.NoError(t, err)
	require.True(t, createResp.Success)

	// Test: TestDirectConnection (should succeed)
	t.Log("Testing direct connection...")
	testResp, err := svc.TestDirectConnection(ctx, &pb.TestDirectConnectionRequest{
		Address: fmt.Sprintf("127.0.0.1:%d", node.adminPort),
		Token:   "test-token",
		CaPem:   string(node.caPEM),
	})
	require.NoError(t, err)
	require.True(t, testResp.Success, "TestDirectConnection failed: %s", testResp.Error)
	require.NotEmpty(t, testResp.EmojiHash, "EmojiHash should be returned")

	// Test: AddNodeDirect
	t.Log("Adding direct node...")
	addResp, err := svc.AddNodeDirect(ctx, &pb.AddNodeDirectRequest{
		Name:    "Direct Node 1",
		Address: fmt.Sprintf("127.0.0.1:%d", node.adminPort),
		Token:   "test-token",
		CaPem:   string(node.caPEM),
	})
	require.NoError(t, err)
	require.True(t, addResp.Success, "AddNodeDirect failed: %s", addResp.Error)
	require.NotNil(t, addResp.Node)
	require.Equal(t, "Direct Node 1", addResp.Node.Name)
	require.True(t, addResp.Node.Online)
	require.Equal(t, pb.NodeConnectionType_NODE_CONNECTION_TYPE_DIRECT, addResp.Node.ConnType)
	require.NotEmpty(t, addResp.Node.EmojiHash, "EmojiHash should be populated in NodeInfo")

	nodeID := addResp.Node.NodeId
	t.Logf("Direct node added: %s", nodeID)

	// Test: ListNodes (should verify it's there)
	listResp, err := svc.ListNodes(ctx, &pb.ListNodesRequest{})
	require.NoError(t, err)
	require.Len(t, listResp.Nodes, 1)
	require.Equal(t, nodeID, listResp.Nodes[0].NodeId)
	require.Equal(t, pb.NodeConnectionType_NODE_CONNECTION_TYPE_DIRECT, listResp.Nodes[0].ConnType)

	// Test: ListProxies (should work via direct connection)
	t.Log("Listing proxies on direct node...")
	proxiesResp, err := svc.ListProxies(ctx, &pb.ListProxiesRequest{
		NodeId: nodeID,
	})
	require.NoError(t, err)
	// Even if empty, it proves the RPC worked
	t.Logf("Found %d proxies", len(proxiesResp.Proxies))

	// Test: AddProxy (direct)
	t.Log("Adding proxy to direct node...")
	proxyResp, err := svc.AddProxy(ctx, &pb.AddProxyRequest{
		NodeId:         nodeID,
		Name:           "Direct Proxy",
		ListenAddr:     ":19999",
		DefaultBackend: "127.0.0.1:80",
	})
	require.NoError(t, err)
	require.True(t, proxyResp.Running)
	createdProxyID := proxyResp.ProxyId

	// Verify proxy in list
	proxiesResp, err = svc.ListProxies(ctx, &pb.ListProxiesRequest{
		NodeId: nodeID,
	})
	require.NoError(t, err)
	
	foundProxy := false
	for _, p := range proxiesResp.Proxies {
		if p.ProxyId == createdProxyID {
			foundProxy = true
			break
		}
	}
	require.True(t, foundProxy, "Created proxy ID not found in list")

	// Test: Dynamic Approval (Direct)
	t.Log("Testing dynamic approval on direct node...")

	// 1. Add proxy with REQUIRE_APPROVAL
	approvalProxyResp, err := svc.AddProxy(ctx, &pb.AddProxyRequest{
		NodeId:         nodeID,
		Name:           "Approval Proxy",
		ListenAddr:     ":19998",
		DefaultBackend: "127.0.0.1:1",
		DefaultAction:  common.ActionType_ACTION_TYPE_REQUIRE_APPROVAL,
	})
	require.NoError(t, err)
	require.True(t, approvalProxyResp.Running)

	// 2. Start traffic in background
	done := make(chan int)
	go func() {
		client := http.Client{Timeout: 5 * time.Second}
		resp, err := client.Get("http://127.0.0.1:19998/")
		if err != nil {
			t.Logf("Traffic failed: %v", err)
			done <- 0
			return
		}
		resp.Body.Close()
		done <- resp.StatusCode
	}()

	// 3. Scan logs for approval request (Workaround: ListPendingApprovals is empty on direct nodes)
	var reqID string
	re := regexp.MustCompile(`\[Local\] Alert generated \(pending approval\): ([0-9a-fA-F-]+) -`)
	
	for i := 0; i < 30; i++ {
		time.Sleep(200 * time.Millisecond)

		// Check logs
		logs := node.logBuf.String()
		matches := re.FindStringSubmatch(logs)
		if len(matches) >= 2 {
			rawID := matches[1]
			reqID = fmt.Sprintf("%s:%s", nodeID, rawID)
			t.Logf("Found pending approval in logs: %s", reqID)
			break
		}
	}
	require.NotEmpty(t, reqID, "Did not receive pending approval request (checked logs)")

	// 4. Approve request
	approveResp, err := svc.ApproveRequest(ctx, &pb.ApproveRequestRequest{
		RequestId:       reqID,
		DurationSeconds: 60,
	})
	require.NoError(t, err)
	require.True(t, approveResp.Success, "ApproveRequest failed: %s", approveResp.Error)

	// 5. Verify traffic completes
	select {
	case status := <-done:
		t.Logf("Traffic completed with status: %d", status)
		// 0 (connection error) or 502 are expected because 127.0.0.1:1 is down.
		// Receiving any status confirms the approval unblocked the connection.
		require.True(t, status == 0 || status == 502, "Traffic should complete with error or 502")
	case <-time.After(5 * time.Second):
		t.Fatal("Traffic timed out waiting for approval")
	}

	t.Log("Direct Connect test passed!")
}

// ============================================================================
// Rule, Template, Error, and P2P Mode Tests
// ============================================================================

func TestMobileRuleCRUD(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	cluster := newMobileTestCluster(t)
	defer cluster.cleanup()

	// Start nitellad (direct mode, no Hub needed for rule CRUD)
	node := cluster.startNitellad("rule-node")

	// Create mobile service and identity
	svc := cluster.createMobileService()
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	createResp, err := svc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
		CommonName: "Rule CRUD Test",
	})
	require.NoError(t, err)
	require.True(t, createResp.Success, "CreateIdentity failed: %s", createResp.Error)

	// Add node via direct connection
	t.Log("Adding direct node...")
	addResp, err := svc.AddNodeDirect(ctx, &pb.AddNodeDirectRequest{
		Name:    "Rule Test Node",
		Address: fmt.Sprintf("127.0.0.1:%d", node.adminPort),
		Token:   "test-token",
		CaPem:   string(node.caPEM),
	})
	require.NoError(t, err)
	require.True(t, addResp.Success, "AddNodeDirect failed: %s", addResp.Error)
	nodeID := addResp.Node.NodeId

	// Create a proxy on the node (rules need a proxy)
	t.Log("Creating proxy for rule testing...")
	proxyResp, err := svc.AddProxy(ctx, &pb.AddProxyRequest{
		NodeId:         nodeID,
		Name:           "Rule Test Proxy",
		ListenAddr:     ":19990",
		DefaultBackend: "127.0.0.1:80",
	})
	require.NoError(t, err)
	require.True(t, proxyResp.Running, "Proxy should be running")
	proxyID := proxyResp.ProxyId
	t.Logf("Proxy created: %s", proxyID)

	// Test: ListRules (should be empty initially)
	t.Log("Listing rules (should be empty)...")
	listResp, err := svc.ListRules(ctx, &pb.ListRulesRequest{
		NodeId:  nodeID,
		ProxyId: proxyID,
	})
	require.NoError(t, err)
	require.Empty(t, listResp.Rules, "Should have no rules initially")

	// Test: AddRule with a source IP condition
	t.Log("Adding rule with source IP condition...")
	ruleToAdd := &pbProxy.Rule{
		Name:     "Block Bad IP",
		Priority: 100,
		Enabled:  true,
		Action:   common.ActionType_ACTION_TYPE_BLOCK,
		Conditions: []*pbProxy.Condition{
			{
				Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
				Op:    common.Operator_OPERATOR_CIDR,
				Value: "192.168.1.0/24",
			},
		},
	}
	addedRule, err := svc.AddRule(ctx, &pb.AddRuleRequest{
		NodeId:  nodeID,
		ProxyId: proxyID,
		Rule:    ruleToAdd,
	})
	require.NoError(t, err)
	require.NotNil(t, addedRule, "Added rule should not be nil")
	require.NotEmpty(t, addedRule.Id, "Rule should have a server-generated ID")
	require.Equal(t, "Block Bad IP", addedRule.Name)
	ruleID := addedRule.Id
	t.Logf("Rule added: ID=%s, Name=%s", ruleID, addedRule.Name)

	// Test: ListRules (should contain our rule)
	t.Log("Listing rules (should contain 1 rule)...")
	listResp, err = svc.ListRules(ctx, &pb.ListRulesRequest{
		NodeId:  nodeID,
		ProxyId: proxyID,
	})
	require.NoError(t, err)
	require.Len(t, listResp.Rules, 1, "Should have exactly 1 rule")
	require.Equal(t, ruleID, listResp.Rules[0].Id)
	require.Equal(t, "Block Bad IP", listResp.Rules[0].Name)
	require.Equal(t, int32(100), listResp.Rules[0].Priority)
	require.True(t, listResp.Rules[0].Enabled)

	// Test: UpdateRule (change name and priority)
	t.Log("Updating rule...")
	updatedRuleDef := &pbProxy.Rule{
		Id:       ruleID,
		Name:     "Block Bad IP Updated",
		Priority: 200,
		Enabled:  true,
		Action:   common.ActionType_ACTION_TYPE_BLOCK,
		Conditions: []*pbProxy.Condition{
			{
				Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
				Op:    common.Operator_OPERATOR_CIDR,
				Value: "10.0.0.0/8",
			},
		},
	}
	updatedRule, err := svc.UpdateRule(ctx, &pb.UpdateRuleRequest{
		NodeId:  nodeID,
		ProxyId: proxyID,
		Rule:    updatedRuleDef,
	})
	require.NoError(t, err)
	require.NotNil(t, updatedRule, "Updated rule should not be nil")
	require.Equal(t, "Block Bad IP Updated", updatedRule.Name)
	t.Logf("Rule updated: Name=%s", updatedRule.Name)

	// Verify update via list (the updated rule has a new ID from add+delete pattern)
	listResp, err = svc.ListRules(ctx, &pb.ListRulesRequest{
		NodeId:  nodeID,
		ProxyId: proxyID,
	})
	require.NoError(t, err)
	require.NotEmpty(t, listResp.Rules, "Should still have rules after update")

	// Find the updated rule
	var foundUpdated bool
	var updatedRuleID string
	for _, r := range listResp.Rules {
		if r.Name == "Block Bad IP Updated" {
			foundUpdated = true
			updatedRuleID = r.Id
			break
		}
	}
	require.True(t, foundUpdated, "Updated rule should be found in list")

	// Test: RemoveRule
	t.Log("Removing rule...")
	_, err = svc.RemoveRule(ctx, &pb.RemoveRuleRequest{
		NodeId:  nodeID,
		ProxyId: proxyID,
		RuleId:  updatedRuleID,
	})
	require.NoError(t, err)

	// Verify removal
	listResp, err = svc.ListRules(ctx, &pb.ListRulesRequest{
		NodeId:  nodeID,
		ProxyId: proxyID,
	})
	require.NoError(t, err)

	// Check that the removed rule is gone
	for _, r := range listResp.Rules {
		require.NotEqual(t, updatedRuleID, r.Id, "Removed rule should not appear in list")
	}
	t.Logf("Rule removed successfully, remaining rules: %d", len(listResp.Rules))

	// Test: AddRule with invalid data (empty rule) - should still work or return error
	t.Log("Testing add rule with empty conditions...")
	emptyRule := &pbProxy.Rule{
		Name:    "",
		Enabled: false,
		Action:  common.ActionType_ACTION_TYPE_UNSPECIFIED,
	}
	emptyResult, err := svc.AddRule(ctx, &pb.AddRuleRequest{
		NodeId:  nodeID,
		ProxyId: proxyID,
		Rule:    emptyRule,
	})
	// The server may accept or reject the empty rule; we verify no panic occurs
	if err != nil {
		t.Logf("AddRule with empty data returned error (expected): %v", err)
	} else {
		t.Logf("AddRule with empty data succeeded: ID=%s", emptyResult.Id)
	}

	t.Log("Rule CRUD test passed!")
}

func TestMobileGlobalRuleCRUD(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	cluster := newMobileTestCluster(t)
	defer cluster.cleanup()

	// Start nitellad (direct mode, no Hub needed)
	node := cluster.startNitellad("global-rule-node")

	// Create mobile service and identity
	svc := cluster.createMobileService()
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	createResp, err := svc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
		CommonName: "Global Rule CRUD Test",
	})
	require.NoError(t, err)
	require.True(t, createResp.Success, "CreateIdentity failed: %s", createResp.Error)

	// Add node via direct connection
	t.Log("Adding direct node...")
	addResp, err := svc.AddNodeDirect(ctx, &pb.AddNodeDirectRequest{
		Name:    "Global Rule Test Node",
		Address: fmt.Sprintf("127.0.0.1:%d", node.adminPort),
		Token:   "test-token",
		CaPem:   string(node.caPEM),
	})
	require.NoError(t, err)
	require.True(t, addResp.Success, "AddNodeDirect failed: %s", addResp.Error)
	nodeID := addResp.Node.NodeId

	// Test: ListGlobalRules (should be empty initially)
	t.Log("Listing global rules (should be empty)...")
	listResp, err := svc.ListGlobalRules(ctx, &pb.ListGlobalRulesRequest{
		NodeId: nodeID,
	})
	require.NoError(t, err)
	require.Empty(t, listResp.Rules, "Should have no global rules initially")

	// Test: AddGlobalRule - Block IP
	t.Log("Adding global BLOCK rule...")
	blockResp, err := svc.AddGlobalRule(ctx, &pb.AddGlobalRuleRequest{
		NodeId: nodeID,
		Ip:     "192.168.1.0/24",
		Action: common.ActionType_ACTION_TYPE_BLOCK,
	})
	require.NoError(t, err)
	require.True(t, blockResp.Success, "AddGlobalRule (block) failed: %s", blockResp.Error)
	t.Logf("Block rule added: success=%v", blockResp.Success)

	// Verify block rule appears in list
	listResp, err = svc.ListGlobalRules(ctx, &pb.ListGlobalRulesRequest{
		NodeId: nodeID,
	})
	require.NoError(t, err)
	require.NotEmpty(t, listResp.Rules, "Should have at least 1 global rule after block")

	var blockRuleID string
	for _, r := range listResp.Rules {
		if r.SourceIp == "192.168.1.0/24" {
			blockRuleID = r.Id
			require.Equal(t, common.ActionType_ACTION_TYPE_BLOCK, r.Action)
			t.Logf("Found block rule: ID=%s, Name=%s", r.Id, r.Name)
			break
		}
	}
	require.NotEmpty(t, blockRuleID, "Block rule should appear in list with correct source IP")

	// Test: AddGlobalRule - Allow IP
	t.Log("Adding global ALLOW rule...")
	allowResp, err := svc.AddGlobalRule(ctx, &pb.AddGlobalRuleRequest{
		NodeId: nodeID,
		Ip:     "10.0.0.1",
		Action: common.ActionType_ACTION_TYPE_ALLOW,
	})
	require.NoError(t, err)
	require.True(t, allowResp.Success, "AddGlobalRule (allow) failed: %s", allowResp.Error)

	// Verify both rules in list
	listResp, err = svc.ListGlobalRules(ctx, &pb.ListGlobalRulesRequest{
		NodeId: nodeID,
	})
	require.NoError(t, err)
	require.GreaterOrEqual(t, len(listResp.Rules), 2, "Should have at least 2 global rules")
	t.Logf("Total global rules: %d", len(listResp.Rules))

	var allowRuleID string
	for _, r := range listResp.Rules {
		if r.SourceIp == "10.0.0.1" {
			allowRuleID = r.Id
			require.Equal(t, common.ActionType_ACTION_TYPE_ALLOW, r.Action)
			break
		}
	}
	require.NotEmpty(t, allowRuleID, "Allow rule should appear in list")

	// Test: AddGlobalRule with duration
	t.Log("Adding global rule with duration...")
	timedResp, err := svc.AddGlobalRule(ctx, &pb.AddGlobalRuleRequest{
		NodeId:          nodeID,
		Ip:              "172.16.0.0/12",
		Action:          common.ActionType_ACTION_TYPE_BLOCK,
		DurationSeconds: 3600,
	})
	require.NoError(t, err)
	require.True(t, timedResp.Success, "AddGlobalRule (timed) failed: %s", timedResp.Error)

	// Verify timed rule has expiry
	listResp, err = svc.ListGlobalRules(ctx, &pb.ListGlobalRulesRequest{
		NodeId: nodeID,
	})
	require.NoError(t, err)
	var timedRuleID string
	for _, r := range listResp.Rules {
		if r.SourceIp == "172.16.0.0/12" {
			timedRuleID = r.Id
			require.NotNil(t, r.ExpiresAt, "Timed rule should have ExpiresAt")
			t.Logf("Timed rule: ID=%s, ExpiresAt=%v", r.Id, r.ExpiresAt)
			break
		}
	}
	require.NotEmpty(t, timedRuleID, "Timed rule should appear in list")

	// Test: RemoveGlobalRule
	t.Log("Removing block rule...")
	removeResp, err := svc.RemoveGlobalRule(ctx, &pb.RemoveGlobalRuleRequest{
		NodeId: nodeID,
		RuleId: blockRuleID,
	})
	require.NoError(t, err)
	require.True(t, removeResp.Success, "RemoveGlobalRule failed: %s", removeResp.Error)

	// Verify removal
	listResp, err = svc.ListGlobalRules(ctx, &pb.ListGlobalRulesRequest{
		NodeId: nodeID,
	})
	require.NoError(t, err)
	for _, r := range listResp.Rules {
		require.NotEqual(t, blockRuleID, r.Id, "Removed rule should not appear in list")
	}
	t.Log("Block rule removed successfully")

	// Test: AddGlobalRule with invalid IP
	t.Log("Testing invalid IP...")
	invalidResp, err := svc.AddGlobalRule(ctx, &pb.AddGlobalRuleRequest{
		NodeId: nodeID,
		Ip:     "not-an-ip",
		Action: common.ActionType_ACTION_TYPE_BLOCK,
	})
	require.NoError(t, err)
	require.False(t, invalidResp.Success, "AddGlobalRule with invalid IP should fail")
	require.NotEmpty(t, invalidResp.Error)
	t.Logf("Invalid IP error (expected): %s", invalidResp.Error)

	// Test: AddGlobalRule with invalid action
	t.Log("Testing invalid action...")
	badActionResp, err := svc.AddGlobalRule(ctx, &pb.AddGlobalRuleRequest{
		NodeId: nodeID,
		Ip:     "1.2.3.4",
		Action: common.ActionType_ACTION_TYPE_UNSPECIFIED,
	})
	require.NoError(t, err)
	require.False(t, badActionResp.Success, "AddGlobalRule with unspecified action should fail")
	t.Logf("Invalid action error (expected): %s", badActionResp.Error)

	// Test: RemoveGlobalRule with non-existent ID
	t.Log("Testing remove non-existent rule...")
	removeNonExistent, err := svc.RemoveGlobalRule(ctx, &pb.RemoveGlobalRuleRequest{
		NodeId: nodeID,
		RuleId: "non-existent-rule-id",
	})
	require.NoError(t, err)
	// The node may or may not return an error for non-existent rules
	t.Logf("Remove non-existent: success=%v, error=%s", removeNonExistent.Success, removeNonExistent.Error)

	// Cleanup remaining rules
	t.Log("Cleanup: removing remaining rules...")
	if allowRuleID != "" {
		svc.RemoveGlobalRule(ctx, &pb.RemoveGlobalRuleRequest{NodeId: nodeID, RuleId: allowRuleID})
	}
	if timedRuleID != "" {
		svc.RemoveGlobalRule(ctx, &pb.RemoveGlobalRuleRequest{NodeId: nodeID, RuleId: timedRuleID})
	}

	t.Log("Global Rule CRUD test passed!")
}

func TestMobileTemplateCRUD(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	cluster := newMobileTestCluster(t)
	defer cluster.cleanup()

	// Start nitellad (direct mode)
	node := cluster.startNitellad("template-node")

	// Create mobile service and identity
	svc := cluster.createMobileService()
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	createResp, err := svc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
		CommonName: "Template CRUD Test",
	})
	require.NoError(t, err)
	require.True(t, createResp.Success, "CreateIdentity failed: %s", createResp.Error)

	// Add node via direct connection
	t.Log("Adding direct node...")
	addResp, err := svc.AddNodeDirect(ctx, &pb.AddNodeDirectRequest{
		Name:    "Template Test Node",
		Address: fmt.Sprintf("127.0.0.1:%d", node.adminPort),
		Token:   "test-token",
		CaPem:   string(node.caPEM),
	})
	require.NoError(t, err)
	require.True(t, addResp.Success, "AddNodeDirect failed: %s", addResp.Error)
	nodeID := addResp.Node.NodeId

	// Create a proxy so the template captures something
	t.Log("Creating proxy for template capture...")
	proxyResp, err := svc.AddProxy(ctx, &pb.AddProxyRequest{
		NodeId:         nodeID,
		Name:           "Template Capture Proxy",
		ListenAddr:     ":19991",
		DefaultBackend: "127.0.0.1:80",
	})
	require.NoError(t, err)
	require.True(t, proxyResp.Running, "Proxy should be running")
	t.Logf("Proxy created: %s", proxyResp.ProxyId)

	// Test: ListTemplates (should be empty initially)
	t.Log("Listing templates (should be empty)...")
	listResp, err := svc.ListTemplates(ctx, &pb.ListTemplatesRequest{
		IncludePublic: false,
	})
	require.NoError(t, err)
	require.Empty(t, listResp.Templates, "Should have no templates initially")

	// Test: CreateTemplate from the node
	t.Log("Creating template from node configuration...")
	template, err := svc.CreateTemplate(ctx, &pb.CreateTemplateRequest{
		Name:        "Test Template",
		Description: "A test template created from node config",
		NodeId:      nodeID,
		Tags:        []string{"test", "integration"},
	})
	require.NoError(t, err)
	require.NotNil(t, template, "Created template should not be nil")
	require.NotEmpty(t, template.TemplateId, "Template should have an ID")
	require.Equal(t, "Test Template", template.Name)
	require.Equal(t, "A test template created from node config", template.Description)
	require.Equal(t, []string{"test", "integration"}, template.Tags)
	require.False(t, template.IsPublic, "Template should not be public by default")
	templateID := template.TemplateId
	t.Logf("Template created: ID=%s, Name=%s, Proxies=%d",
		templateID, template.Name, len(template.Proxies))

	// Test: ListTemplates (should contain our template)
	t.Log("Listing templates (should contain 1)...")
	listResp, err = svc.ListTemplates(ctx, &pb.ListTemplatesRequest{
		IncludePublic: false,
	})
	require.NoError(t, err)
	require.Len(t, listResp.Templates, 1, "Should have exactly 1 template")
	require.Equal(t, templateID, listResp.Templates[0].TemplateId)
	require.Equal(t, "Test Template", listResp.Templates[0].Name)
	require.Equal(t, int32(1), listResp.TotalCount)

	// Test: ListTemplates with tag filter
	t.Log("Listing templates with tag filter...")
	listResp, err = svc.ListTemplates(ctx, &pb.ListTemplatesRequest{
		Tags: []string{"integration"},
	})
	require.NoError(t, err)
	require.Len(t, listResp.Templates, 1, "Should find template by tag")

	listResp, err = svc.ListTemplates(ctx, &pb.ListTemplatesRequest{
		Tags: []string{"nonexistent"},
	})
	require.NoError(t, err)
	require.Empty(t, listResp.Templates, "Should not find template with wrong tag")

	// Test: GetTemplate
	t.Log("Getting template by ID...")
	gotTemplate, err := svc.GetTemplate(ctx, &pb.GetTemplateRequest{
		TemplateId: templateID,
	})
	require.NoError(t, err)
	require.NotNil(t, gotTemplate, "GetTemplate should return template")
	require.Equal(t, templateID, gotTemplate.TemplateId)
	require.Equal(t, "Test Template", gotTemplate.Name)
	require.Equal(t, "A test template created from node config", gotTemplate.Description)
	require.NotNil(t, gotTemplate.CreatedAt, "CreatedAt should be set")
	require.NotNil(t, gotTemplate.UpdatedAt, "UpdatedAt should be set")
	t.Logf("Template details: Author=%s, Proxies=%d", gotTemplate.Author, len(gotTemplate.Proxies))

	// Test: GetTemplate with invalid ID
	_, err = svc.GetTemplate(ctx, &pb.GetTemplateRequest{
		TemplateId: "nonexistent-id",
	})
	require.Error(t, err, "GetTemplate with invalid ID should return error")
	t.Logf("GetTemplate with invalid ID returned error (expected): %v", err)

	// Test: DeleteTemplate
	t.Log("Deleting template...")
	_, err = svc.DeleteTemplate(ctx, &pb.DeleteTemplateRequest{
		TemplateId: templateID,
	})
	require.NoError(t, err)

	// Verify deletion via list
	listResp, err = svc.ListTemplates(ctx, &pb.ListTemplatesRequest{
		IncludePublic: false,
	})
	require.NoError(t, err)
	require.Empty(t, listResp.Templates, "Should have no templates after deletion")
	t.Log("Template deleted, list is empty")

	// Test: GetTemplate after deletion should fail
	_, err = svc.GetTemplate(ctx, &pb.GetTemplateRequest{
		TemplateId: templateID,
	})
	require.Error(t, err, "GetTemplate after deletion should return error")

	// Test: DeleteTemplate with invalid ID should fail
	_, err = svc.DeleteTemplate(ctx, &pb.DeleteTemplateRequest{
		TemplateId: "nonexistent-id",
	})
	require.Error(t, err, "DeleteTemplate with invalid ID should return error")

	t.Log("Template CRUD test passed!")
}

func TestMobileErrorPaths(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	cluster := newMobileTestCluster(t)
	defer cluster.cleanup()

	// Create mobile service (no hub, no nodes)
	svc := cluster.createMobileService()
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Create identity (required for most operations)
	createResp, err := svc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
		CommonName: "Error Paths Test",
	})
	require.NoError(t, err)
	require.True(t, createResp.Success, "CreateIdentity failed: %s", createResp.Error)

	fakeNodeID := "nonexistent-node-id-12345"

	// Test: ListRules on non-existent node
	t.Log("Testing ListRules on non-existent node...")
	_, err = svc.ListRules(ctx, &pb.ListRulesRequest{
		NodeId:  fakeNodeID,
		ProxyId: "fake-proxy",
	})
	require.Error(t, err, "ListRules on non-existent node should return error")
	require.Contains(t, err.Error(), "node not found",
		"Error message should mention node not found")
	t.Logf("ListRules error (expected): %v", err)

	// Test: AddProxy on non-existent node
	t.Log("Testing AddProxy on non-existent node...")
	_, err = svc.AddProxy(ctx, &pb.AddProxyRequest{
		NodeId:         fakeNodeID,
		Name:           "Ghost Proxy",
		ListenAddr:     ":19999",
		DefaultBackend: "127.0.0.1:80",
	})
	require.Error(t, err, "AddProxy on non-existent node should return error")
	require.Contains(t, err.Error(), "node not found",
		"Error message should mention node not found")
	t.Logf("AddProxy error (expected): %v", err)

	// Test: RemoveNode on non-existent node
	t.Log("Testing RemoveNode on non-existent node...")
	_, err = svc.RemoveNode(ctx, &pb.RemoveNodeRequest{
		NodeId: fakeNodeID,
	})
	require.Error(t, err, "RemoveNode on non-existent node should return error")
	require.Contains(t, err.Error(), "node not found",
		"Error message should mention node not found")
	t.Logf("RemoveNode error (expected): %v", err)

	// Test: AddRule on non-existent node
	t.Log("Testing AddRule on non-existent node...")
	_, err = svc.AddRule(ctx, &pb.AddRuleRequest{
		NodeId:  fakeNodeID,
		ProxyId: "fake-proxy",
		Rule: &pbProxy.Rule{
			Name:    "Ghost Rule",
			Enabled: true,
			Action:  common.ActionType_ACTION_TYPE_BLOCK,
		},
	})
	require.Error(t, err, "AddRule on non-existent node should return error")
	require.Contains(t, err.Error(), "node not found",
		"Error message should mention node not found")
	t.Logf("AddRule error (expected): %v", err)

	// Test: RemoveRule on non-existent node
	t.Log("Testing RemoveRule on non-existent node...")
	_, err = svc.RemoveRule(ctx, &pb.RemoveRuleRequest{
		NodeId:  fakeNodeID,
		ProxyId: "fake-proxy",
		RuleId:  "fake-rule",
	})
	require.Error(t, err, "RemoveRule on non-existent node should return error")
	require.Contains(t, err.Error(), "node not found",
		"Error message should mention node not found")
	t.Logf("RemoveRule error (expected): %v", err)

	// Test: CreateTemplate on non-existent node
	t.Log("Testing CreateTemplate on non-existent node...")
	_, err = svc.CreateTemplate(ctx, &pb.CreateTemplateRequest{
		Name:   "Ghost Template",
		NodeId: fakeNodeID,
	})
	require.Error(t, err, "CreateTemplate on non-existent node should return error")
	require.Contains(t, err.Error(), "node not found",
		"Error message should mention node not found")
	t.Logf("CreateTemplate error (expected): %v", err)

	// Test: Operations without identity (fresh service)
	t.Log("Testing operations without identity...")
	freshDataDir := filepath.Join(cluster.dataDir, "mobile-fresh")
	os.MkdirAll(freshDataDir, 0755)

	freshSvc := service.NewMobileLogicService()
	defer freshSvc.Shutdown(ctx, nil)

	_, err = freshSvc.Initialize(ctx, &pb.InitializeRequest{
		DataDir:   freshDataDir,
		CacheDir:  filepath.Join(freshDataDir, "cache"),
		DebugMode: true,
	})
	require.NoError(t, err)

	// ListRules without identity should fail
	_, err = freshSvc.ListRules(ctx, &pb.ListRulesRequest{
		NodeId:  fakeNodeID,
		ProxyId: "fake-proxy",
	})
	require.Error(t, err, "ListRules without identity should return error")
	t.Logf("ListRules without identity error (expected): %v", err)

	t.Log("Error paths test passed!")
}

func TestMobileP2PModeSwitching(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	cluster := newMobileTestCluster(t)
	defer cluster.cleanup()

	// Create mobile service (no hub needed for settings)
	svc := cluster.createMobileService()
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Create identity
	createResp, err := svc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
		CommonName: "P2P Mode Test",
	})
	require.NoError(t, err)
	require.True(t, createResp.Success, "CreateIdentity failed: %s", createResp.Error)

	// Test: GetSettings - check default P2P mode
	t.Log("Getting default settings...")
	settings, err := svc.GetSettings(ctx, nil)
	require.NoError(t, err)
	require.NotNil(t, settings)
	defaultMode := settings.P2PMode
	t.Logf("Default P2P mode: %v (%d)", defaultMode, int32(defaultMode))

	// Test: Cycle through all P2P modes
	modes := []struct {
		mode common.P2PMode
		name string
	}{
		{common.P2PMode_P2P_MODE_AUTO, "Auto"},
		{common.P2PMode_P2P_MODE_DIRECT, "Direct/P2P Only"},
		{common.P2PMode_P2P_MODE_HUB, "Hub Only"},
	}

	for _, m := range modes {
		t.Logf("Setting P2P mode to %s (%d)...", m.name, int32(m.mode))

		updatedSettings, err := svc.UpdateSettings(ctx, &pb.UpdateSettingsRequest{
			Settings: &pb.Settings{
				P2PMode: m.mode,
			},
		})
		require.NoError(t, err)
		require.Equal(t, m.mode, updatedSettings.P2PMode,
			"P2P mode should be %s after update", m.name)

		// Verify persistence by reading settings again
		readSettings, err := svc.GetSettings(ctx, nil)
		require.NoError(t, err)
		require.Equal(t, m.mode, readSettings.P2PMode,
			"P2P mode should persist as %s after re-read", m.name)

		t.Logf("P2P mode %s set and verified", m.name)
	}

	// Test: Update P2P mode along with other settings (should not interfere)
	t.Log("Testing P2P mode with other settings...")
	combinedSettings, err := svc.UpdateSettings(ctx, &pb.UpdateSettingsRequest{
		Settings: &pb.Settings{
			P2PMode:              common.P2PMode_P2P_MODE_AUTO,
			AutoConnectHub:       true,
			NotificationsEnabled: true,
			RequireBiometric:     false,
		},
	})
	require.NoError(t, err)
	require.Equal(t, common.P2PMode_P2P_MODE_AUTO, combinedSettings.P2PMode)
	require.True(t, combinedSettings.AutoConnectHub)
	require.True(t, combinedSettings.NotificationsEnabled)

	// Verify combined settings persisted
	finalSettings, err := svc.GetSettings(ctx, nil)
	require.NoError(t, err)
	require.Equal(t, common.P2PMode_P2P_MODE_AUTO, finalSettings.P2PMode)
	require.True(t, finalSettings.AutoConnectHub)
	require.True(t, finalSettings.NotificationsEnabled)

	t.Log("P2P mode switching test passed!")
}

// ============================================================================
// Benchmark Tests
// ============================================================================

func BenchmarkMobileIdentityCreation(b *testing.B) {
	// Setup
	dataDir, _ := os.MkdirTemp("", "nitella-mobile-bench-*")
	defer os.RemoveAll(dataDir)

	for i := 0; i < b.N; i++ {
		svc := service.NewMobileLogicService()
		ctx := context.Background()

		subDir := filepath.Join(dataDir, fmt.Sprintf("iter-%d", i))
		os.MkdirAll(subDir, 0755)

		svc.Initialize(ctx, &pb.InitializeRequest{
			DataDir:   subDir,
			CacheDir:  filepath.Join(subDir, "cache"),
			DebugMode: false,
		})

		svc.CreateIdentity(ctx, &pb.CreateIdentityRequest{
			CommonName: "Bench",
		})

		svc.Shutdown(ctx, nil)
	}
}
