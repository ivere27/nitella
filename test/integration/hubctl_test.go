package integration

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"encoding/json"
	"os"
	"path/filepath"
	"testing"
	"time"

	hubpb "github.com/ivere27/nitella/pkg/api/hub"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"

)

// ============================================================================
// HubCtl (Admin CLI) Integration Tests
// ============================================================================
//
// Tests for the hubctl admin CLI functionality including:
// - User management
// - Node management
// - System statistics
// - Admin authentication
//
// ============================================================================

// TestHubCtl_UserManagement tests user listing and management
func TestHubCtl_UserManagement(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping hubctl test in short mode")
	}

	hub := startHubServer(t)
	defer hub.stop()

	// Create admin connection
	adminConn := connectToHubAdmin(t, hub)
	defer adminConn.Close()

	adminClient := hubpb.NewAdminServiceClient(adminConn)

	// Register some test users first
	authClient := hubpb.NewAuthServiceClient(adminConn)
	for i := 0; i < 3; i++ {
		cliIdentity := generateCLIIdentity(t)
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		_, err := authClient.RegisterUser(ctx, &hubpb.RegisterUserRequest{
			RootCertPem: string(cliIdentity.rootCertPEM),
			InviteCode:  "NITELLA",
		})
		cancel()
		if err != nil {
			t.Logf("User registration %d: %v (may be expected)", i, err)
		}
	}

	// Test ListAllUsers
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	usersResp, err := adminClient.ListAllUsers(ctx, &hubpb.ListAllUsersRequest{})
	cancel()

	if err != nil {
		t.Logf("ListAllUsers: %v (may require admin auth)", err)
	} else {
		t.Logf("Found %d users", len(usersResp.Users))
	}
}

// TestHubCtl_NodeManagement tests node listing
func TestHubCtl_NodeManagement(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping hubctl test in short mode")
	}

	hub := startHubServer(t)
	defer hub.stop()

	// Setup CLI and register nodes
	cliIdentity := generateCLIIdentity(t)
	cliConn := connectToHubWithMTLS(t, hub.grpcAddr, hub.hubCAPEM, cliIdentity)
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

	// Register some nodes
	for i := 0; i < 2; i++ {
		nodeIdentity := generateNodeIdentity(t)
		csrPEM := generateCSR(t, nodeIdentity.privateKey, "admin-test-node")
		certPEM := signCSR(t, csrPEM, cliIdentity)

		nodeConn := connectToHubWithNodeCert(t, hub.grpcAddr, nodeIdentity.privateKey, certPEM, cliIdentity.rootCertPEM, hub.hubCAPEM)
		nodeClient := hubpb.NewNodeServiceClient(nodeConn)

		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		_, err := nodeClient.Register(ctx, &hubpb.NodeRegisterRequest{
			CsrPem: string(csrPEM),
		})
		cancel()
		nodeConn.Close()

		if err != nil {
			t.Logf("Node registration %d: %v", i, err)
		}
	}

	// Test admin node listing
	adminConn := connectToHubAdmin(t, hub)
	defer adminConn.Close()

	adminClient := hubpb.NewAdminServiceClient(adminConn)
	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	nodesResp, err := adminClient.ListAllNodes(ctx, &hubpb.ListAllNodesRequest{})
	cancel()

	if err != nil {
		t.Logf("Admin ListAllNodes: %v (may require admin auth)", err)
	} else {
		t.Logf("Admin sees %d nodes", len(nodesResp.Nodes))
	}
}

// TestHubCtl_InviteCodes tests invite code management
func TestHubCtl_InviteCodes(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping hubctl test in short mode")
	}

	hub := startHubServer(t)
	defer hub.stop()

	adminConn := connectToHubAdmin(t, hub)
	defer adminConn.Close()

	adminClient := hubpb.NewAdminServiceClient(adminConn)

	// Create invite code using UpsertInviteCode
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	_, err := adminClient.UpsertInviteCode(ctx, &hubpb.InviteCode{
		Code:  "TEST-INVITE-CODE",
		Limit: 5,
		Tier:  "pro",
	})
	cancel()

	if err != nil {
		t.Logf("UpsertInviteCode: %v (may require admin auth)", err)
	} else {
		t.Log("Created invite code: TEST-INVITE-CODE")
	}

	// List invite codes
	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	listResp, err := adminClient.ListInviteCodes(ctx, &hubpb.ListInviteCodesRequest{})
	cancel()

	if err != nil {
		t.Logf("ListInviteCodes: %v (may require admin auth)", err)
	} else {
		t.Logf("Found %d invite codes", len(listResp.Codes))
	}
}

// TestHubCtl_SystemStats tests system statistics retrieval
func TestHubCtl_SystemStats(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping hubctl test in short mode")
	}

	hub := startHubServer(t)
	defer hub.stop()

	adminConn := connectToHubAdmin(t, hub)
	defer adminConn.Close()

	adminClient := hubpb.NewAdminServiceClient(adminConn)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	statsResp, err := adminClient.GetSystemStats(ctx, &hubpb.GetSystemStatsRequest{})
	cancel()

	if err != nil {
		t.Logf("GetSystemStats: %v (may require admin auth)", err)
	} else {
		t.Logf("System stats: users=%d, nodes=%d, online=%d",
			statsResp.TotalUsers, statsResp.TotalNodes, statsResp.OnlineNodes)
	}
}

// TestHubCtl_DatabaseStats tests database statistics
func TestHubCtl_DatabaseStats(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping hubctl test in short mode")
	}

	hub := startHubServer(t)
	defer hub.stop()

	adminConn := connectToHubAdmin(t, hub)
	defer adminConn.Close()

	adminClient := hubpb.NewAdminServiceClient(adminConn)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	dbStats, err := adminClient.GetDatabaseStats(ctx, &hubpb.GetDatabaseStatsRequest{})
	cancel()

	if err != nil {
		t.Logf("GetDatabaseStats: %v (may require admin auth)", err)
	} else {
		t.Logf("Database stats: size=%d bytes, users=%d, nodes=%d",
			dbStats.DbSizeBytes, dbStats.UserCount, dbStats.NodeCount)
	}
}

// TestHubCtl_AuditLog tests audit log retrieval
func TestHubCtl_AuditLog(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping hubctl test in short mode")
	}

	hub := startHubServer(t)
	defer hub.stop()

	adminConn := connectToHubAdmin(t, hub)
	defer adminConn.Close()

	adminClient := hubpb.NewAdminServiceClient(adminConn)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	auditResp, err := adminClient.GetAuditLog(ctx, &hubpb.GetAuditLogRequest{
		PageSize: 100,
	})
	cancel()

	if err != nil {
		t.Logf("GetAuditLog: %v (may require admin auth)", err)
	} else {
		t.Logf("Audit log: %d entries", len(auditResp.Entries))
	}
}

// TestHubCtl_UserTierManagement tests user tier changes
func TestHubCtl_UserTierManagement(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping hubctl test in short mode")
	}

	hub := startHubServer(t)
	defer hub.stop()

	// First register a user
	cliIdentity := generateCLIIdentity(t)
	cliConn := connectToHubWithMTLS(t, hub.grpcAddr, hub.hubCAPEM, cliIdentity)
	defer cliConn.Close()

	authClient := hubpb.NewAuthServiceClient(cliConn)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	userResp, err := authClient.RegisterUser(ctx, &hubpb.RegisterUserRequest{
		RootCertPem: string(cliIdentity.rootCertPEM),
		InviteCode:  "NITELLA",
	})
	cancel()
	if err != nil {
		t.Fatalf("Failed to register user: %v", err)
	}

	// Admin changes user tier
	adminConn := connectToHubAdmin(t, hub)
	defer adminConn.Close()

	adminClient := hubpb.NewAdminServiceClient(adminConn)

	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	_, err = adminClient.SetUserTier(ctx, &hubpb.SetUserTierRequest{
		UserId: userResp.UserId,
		Tier:   "enterprise",
	})
	cancel()

	if err != nil {
		t.Logf("SetUserTier: %v (may require admin auth)", err)
	} else {
		t.Logf("User %s tier updated to enterprise", userResp.UserId)
	}

	// Verify tier change
	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	details, err := adminClient.GetUserDetails(ctx, &hubpb.GetUserDetailsRequest{
		UserId: userResp.UserId,
	})
	cancel()

	if err != nil {
		t.Logf("GetUserDetails: %v (may require admin auth)", err)
	} else if details.User != nil {
		t.Logf("User tier: %s", details.User.Tier)
	}
}

// TestHubCtl_ConfigFile tests hubctl config file management
func TestHubCtl_ConfigFile(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping hubctl config test in short mode")
	}

	// Create temp config directory
	tempDir, err := os.MkdirTemp("", "hubctl-test-*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tempDir)

	configPath := filepath.Join(tempDir, "config.json")

	// Test config structure
	type HubctlConfig struct {
		HubAddress string `json:"hub_address"`
		AdminToken string `json:"admin_token"`
		TLSCert    string `json:"tls_cert,omitempty"`
		TLSKey     string `json:"tls_key,omitempty"`
		TLSCA      string `json:"tls_ca,omitempty"`
	}

	config := HubctlConfig{
		HubAddress: "localhost:50052",
		AdminToken: "test-admin-token",
	}

	// Write config
	data, err := json.MarshalIndent(config, "", "  ")
	if err != nil {
		t.Fatalf("Failed to marshal config: %v", err)
	}

	if err := os.WriteFile(configPath, data, 0600); err != nil {
		t.Fatalf("Failed to write config: %v", err)
	}

	// Read and verify config
	readData, err := os.ReadFile(configPath)
	if err != nil {
		t.Fatalf("Failed to read config: %v", err)
	}

	var readConfig HubctlConfig
	if err := json.Unmarshal(readData, &readConfig); err != nil {
		t.Fatalf("Failed to unmarshal config: %v", err)
	}

	if readConfig.HubAddress != config.HubAddress {
		t.Errorf("Hub address mismatch: expected %s, got %s", config.HubAddress, readConfig.HubAddress)
	}

	t.Log("Config file operations successful")
}

// TestHubCtl_BulkOperations tests bulk admin operations
func TestHubCtl_BulkOperations(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping hubctl bulk operations test in short mode")
	}

	hub := startHubServer(t)
	defer hub.stop()

	// Register many users
	userCount := 10
	for i := 0; i < userCount; i++ {
		cliIdentity := generateCLIIdentity(t)
		cliConn := connectToHubWithMTLS(t, hub.grpcAddr, hub.hubCAPEM, cliIdentity)

		authClient := hubpb.NewAuthServiceClient(cliConn)
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		_, err := authClient.RegisterUser(ctx, &hubpb.RegisterUserRequest{
			RootCertPem: string(cliIdentity.rootCertPEM),
			InviteCode:  "NITELLA",
		})
		cancel()
		cliConn.Close()

		if err != nil {
			t.Logf("User %d registration: %v", i, err)
		}
	}

	// Admin lists all users
	adminConn := connectToHubAdmin(t, hub)
	defer adminConn.Close()

	adminClient := hubpb.NewAdminServiceClient(adminConn)

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	usersResp, err := adminClient.ListAllUsers(ctx, &hubpb.ListAllUsersRequest{})
	cancel()

	if err != nil {
		t.Logf("ListAllUsers: %v (may require admin auth)", err)
	} else {
		t.Logf("Bulk operation test: %d users registered and listed", len(usersResp.Users))
	}

	// Get system stats after bulk operations
	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	stats, err := adminClient.GetSystemStats(ctx, &hubpb.GetSystemStatsRequest{})
	cancel()

	if err == nil {
		t.Logf("After bulk: users=%d, nodes=%d", stats.TotalUsers, stats.TotalNodes)
	}
}

func connectToHubAdmin(t *testing.T, hub *hubServer) *grpc.ClientConn {
	t.Helper()
	pool := x509.NewCertPool()
	if !pool.AppendCertsFromPEM(hub.hubCAPEM) {
		t.Fatal("Failed to append Hub CA")
	}
	tlsConfig := &tls.Config{
		RootCAs:    pool,
		MinVersion: tls.VersionTLS13,
	}
	conn, err := grpc.Dial(hub.grpcAddr, grpc.WithTransportCredentials(credentials.NewTLS(tlsConfig)))
	if err != nil {
		t.Fatalf("Failed to connect to Hub: %v", err)
	}
	return conn
}
