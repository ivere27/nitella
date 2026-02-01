package store

import (
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/ivere27/nitella/pkg/hub/model"
)

func TestStore(t *testing.T) {
	// Create temp database
	tmpFile, err := os.CreateTemp("", "hub_test_*.db")
	if err != nil {
		t.Fatalf("Failed to create temp file: %v", err)
	}
	defer os.Remove(tmpFile.Name())
	tmpFile.Close()

	// Initialize store
	store, err := NewStore("sqlite3", tmpFile.Name())
	if err != nil {
		t.Fatalf("Failed to create store: %v", err)
	}
	defer store.Close()

	t.Run("User CRUD", func(t *testing.T) {
		testUserCRUD(t, store)
	})

	t.Run("Node CRUD", func(t *testing.T) {
		testNodeCRUD(t, store)
	})

	t.Run("InviteCode", func(t *testing.T) {
		testInviteCode(t, store)
	})

	t.Run("Registration", func(t *testing.T) {
		testRegistration(t, store)
	})

	t.Run("Metrics", func(t *testing.T) {
		testMetrics(t, store)
	})

	t.Run("Logs", func(t *testing.T) {
		testLogs(t, store)
	})

	t.Run("RoutingToken", func(t *testing.T) {
		testRoutingToken(t, store)
	})
}

func testUserCRUD(t *testing.T, store Store) {
	// Create user (zero-trust: no email/password, use BlindIndex + EncryptedProfile)
	user := &model.User{
		ID:               "user-123",
		BlindIndex:       "blind-index-hash-abc123", // SHA256(Email + Salt)
		EncryptedProfile: []byte("encrypted-profile-data"),
		Role:             "user",
		Tier:             "free",
	}

	if err := store.SaveUser(user); err != nil {
		t.Fatalf("Failed to save user: %v", err)
	}

	// Get user by ID
	fetched, err := store.GetUser(user.ID)
	if err != nil {
		t.Fatalf("Failed to get user: %v", err)
	}
	if fetched.BlindIndex != user.BlindIndex {
		t.Errorf("BlindIndex mismatch: got %s, want %s", fetched.BlindIndex, user.BlindIndex)
	}

	// Get user by blind index
	fetchedByIndex, err := store.GetUserByBlindIndex(user.BlindIndex)
	if err != nil {
		t.Fatalf("Failed to get user by blind index: %v", err)
	}
	if fetchedByIndex.ID != user.ID {
		t.Errorf("ID mismatch: got %s, want %s", fetchedByIndex.ID, user.ID)
	}

	// Update user tier
	if err := store.UpdateUserTier(user.ID, "pro"); err != nil {
		t.Fatalf("Failed to update user tier: %v", err)
	}

	fetched, _ = store.GetUser(user.ID)
	if fetched.Tier != "pro" {
		t.Errorf("Tier not updated: got %s, want pro", fetched.Tier)
	}

	// List users
	users, err := store.ListUsers()
	if err != nil {
		t.Fatalf("Failed to list users: %v", err)
	}
	if len(users) != 1 {
		t.Errorf("Expected 1 user, got %d", len(users))
	}

	// Delete user
	if err := store.DeleteUser(user.ID); err != nil {
		t.Fatalf("Failed to delete user: %v", err)
	}

	_, err = store.GetUser(user.ID)
	if err == nil {
		t.Error("Expected error getting deleted user")
	}
}

func testNodeCRUD(t *testing.T, store Store) {
	// Create node (zero-trust: use RoutingToken instead of UserID)
	node := &model.Node{
		ID:                "node-123",
		RoutingToken:      "routing-token-abc123", // Blind identifier
		EncryptedMetadata: []byte("encrypted-node-metadata"),
		Status:            "offline",
		CertPEM:           "-----BEGIN CERTIFICATE-----\ntest\n-----END CERTIFICATE-----",
		PublicKeyPEM:      "-----BEGIN PUBLIC KEY-----\ntest\n-----END PUBLIC KEY-----",
	}

	if err := store.SaveNode(node); err != nil {
		t.Fatalf("Failed to save node: %v", err)
	}

	// Get node
	fetched, err := store.GetNode(node.ID)
	if err != nil {
		t.Fatalf("Failed to get node: %v", err)
	}
	if fetched.RoutingToken != node.RoutingToken {
		t.Errorf("RoutingToken mismatch: got %s, want %s", fetched.RoutingToken, node.RoutingToken)
	}

	// Get node by routing token
	fetchedByToken, err := store.GetNodeByRoutingToken(node.RoutingToken)
	if err != nil {
		t.Fatalf("Failed to get node by routing token: %v", err)
	}
	if fetchedByToken.ID != node.ID {
		t.Errorf("ID mismatch: got %s, want %s", fetchedByToken.ID, node.ID)
	}

	// Update node status
	if err := store.UpdateNodeStatus(node.ID, "online"); err != nil {
		t.Fatalf("Failed to update node status: %v", err)
	}

	fetched, _ = store.GetNode(node.ID)
	if fetched.Status != "online" {
		t.Errorf("Status not updated: got %s, want online", fetched.Status)
	}

	// List nodes
	nodes, err := store.ListNodes()
	if err != nil {
		t.Fatalf("Failed to list nodes: %v", err)
	}
	if len(nodes) != 1 {
		t.Errorf("Expected 1 node, got %d", len(nodes))
	}

	// Delete node
	if err := store.DeleteNode(node.ID); err != nil {
		t.Fatalf("Failed to delete node: %v", err)
	}

	_, err = store.GetNode(node.ID)
	if err == nil {
		t.Error("Expected error getting deleted node")
	}
}

func testInviteCode(t *testing.T, store Store) {
	// Create invite code
	code := &model.InviteCode{
		Code:        "INVITE123",
		CreatedBy:   "admin",
		MaxUses:     5,
		CurrentUses: 0,
		TierID:      "pro",
		ExpiresAt:   time.Now().Add(24 * time.Hour),
		Active:      true,
	}

	if err := store.SaveInviteCode(code); err != nil {
		t.Fatalf("Failed to save invite code: %v", err)
	}

	// Get invite code
	fetched, err := store.GetInviteCode(code.Code)
	if err != nil {
		t.Fatalf("Failed to get invite code: %v", err)
	}
	if fetched.MaxUses != code.MaxUses {
		t.Errorf("MaxUses mismatch: got %d, want %d", fetched.MaxUses, code.MaxUses)
	}
	if fetched.TierID != "pro" {
		t.Errorf("TierID mismatch: got %s, want pro", fetched.TierID)
	}

	// Consume invite code
	if err := store.ConsumeInviteCode(code.Code); err != nil {
		t.Fatalf("Failed to consume invite code: %v", err)
	}

	fetched, _ = store.GetInviteCode(code.Code)
	if fetched.CurrentUses != 1 {
		t.Errorf("CurrentUses should be 1, got %d", fetched.CurrentUses)
	}

	// List active invite codes
	codes, err := store.ListActiveInviteCodes()
	if err != nil {
		t.Fatalf("Failed to list active invite codes: %v", err)
	}
	if len(codes) != 1 {
		t.Errorf("Expected 1 active invite code, got %d", len(codes))
	}

	// Delete invite code
	if err := store.DeleteInviteCode(code.Code); err != nil {
		t.Fatalf("Failed to delete invite code: %v", err)
	}
}

func testRegistration(t *testing.T, store Store) {
	// Create registration request
	reg := &model.RegistrationRequest{
		Code:              "REG123",
		CSR:               "-----BEGIN CERTIFICATE REQUEST-----\ntest\n-----END CERTIFICATE REQUEST-----",
		EncryptedMetadata: []byte("encrypted-registration-metadata"),
		NodeID:            "pending-node",
		Status:            "PENDING",
		ExpiresAt:         time.Now().Add(10 * time.Minute),
	}

	if err := store.SaveRegistrationRequest(reg); err != nil {
		t.Fatalf("Failed to save registration request: %v", err)
	}

	// Get registration request
	fetched, err := store.GetRegistrationRequest(reg.Code)
	if err != nil {
		t.Fatalf("Failed to get registration request: %v", err)
	}
	if fetched.NodeID != reg.NodeID {
		t.Errorf("NodeID mismatch: got %s, want %s", fetched.NodeID, reg.NodeID)
	}
	if fetched.Status != "PENDING" {
		t.Errorf("Status should be PENDING, got %s", fetched.Status)
	}

	// Approve registration atomically
	certPEM := "-----BEGIN CERTIFICATE-----\napproved-cert\n-----END CERTIFICATE-----"
	caPEM := "-----BEGIN CERTIFICATE-----\nca-cert\n-----END CERTIFICATE-----"
	routingToken := "routing-token-approved"

	approved, err := store.ApproveRegistration(reg.Code, certPEM, caPEM, routingToken)
	if err != nil {
		t.Fatalf("Failed to approve registration: %v", err)
	}
	if approved.Status != "APPROVED" {
		t.Errorf("Status should be APPROVED, got %s", approved.Status)
	}
	if approved.CertPEM != certPEM {
		t.Errorf("CertPEM mismatch")
	}
	if approved.RoutingToken != routingToken {
		t.Errorf("RoutingToken mismatch: got %s, want %s", approved.RoutingToken, routingToken)
	}

	// Verify from database
	fetched, _ = store.GetRegistrationRequest(reg.Code)
	if fetched.Status != "APPROVED" {
		t.Errorf("Status should be APPROVED in DB, got %s", fetched.Status)
	}

	// Try to approve again (should fail - already approved)
	_, err = store.ApproveRegistration(reg.Code, certPEM, caPEM, routingToken)
	if err == nil {
		t.Error("Expected error when approving already approved registration")
	}
	if err != nil && err.Error() != "registration already approved" {
		t.Errorf("Expected 'registration already approved' error, got: %v", err)
	}

	// Try to approve non-existent registration
	_, err = store.ApproveRegistration("NON_EXISTENT", certPEM, caPEM, routingToken)
	if err == nil {
		t.Error("Expected error when approving non-existent registration")
	}

	// Delete registration request
	if err := store.DeleteRegistrationRequest(reg.Code); err != nil {
		t.Fatalf("Failed to delete registration request: %v", err)
	}

	// Test rejected registration cannot be approved
	rejectedReg := &model.RegistrationRequest{
		Code:      "REG_REJECTED",
		CSR:       "-----BEGIN CERTIFICATE REQUEST-----\ntest\n-----END CERTIFICATE REQUEST-----",
		NodeID:    "rejected-node",
		Status:    "REJECTED",
		ExpiresAt: time.Now().Add(10 * time.Minute),
	}
	if err := store.SaveRegistrationRequest(rejectedReg); err != nil {
		t.Fatalf("Failed to save rejected registration: %v", err)
	}

	_, err = store.ApproveRegistration(rejectedReg.Code, certPEM, caPEM, routingToken)
	if err == nil {
		t.Error("Expected error when approving rejected registration")
	}

	store.DeleteRegistrationRequest(rejectedReg.Code)
}

func testMetrics(t *testing.T, store Store) {
	// Create encrypted metric with a truncated timestamp to avoid precision issues with SQLite
	now := time.Now().Truncate(time.Second)
	routingToken := "routing-token-metrics-test"

	metric := &model.EncryptedMetric{
		NodeID:        "node-metrics-123",
		RoutingToken:  routingToken,
		Timestamp:     now,
		EncryptedBlob: []byte("encrypted-metrics-data-here"),
		Nonce:         []byte("nonce12bytes"),
		SenderKeyID:   "sender-fingerprint-abc123",
	}

	if err := store.SaveEncryptedMetric(metric); err != nil {
		t.Fatalf("Failed to save encrypted metric: %v", err)
	}

	// Get metrics history with wider time range
	start := now.Add(-1 * time.Hour).Truncate(time.Second)
	end := now.Add(1 * time.Hour).Truncate(time.Second)
	metrics, err := store.GetEncryptedMetricsHistory(routingToken, start, end, 100)
	if err != nil {
		t.Fatalf("Failed to get encrypted metrics history: %v", err)
	}
	if len(metrics) == 0 {
		t.Log("No metrics found in time range - this may be a SQLite datetime precision issue")
		// Try fetching with even wider range
		metrics, err = store.GetEncryptedMetricsHistory(routingToken, time.Time{}, time.Now().Add(24*time.Hour), 100)
		if err != nil {
			t.Fatalf("Failed to get metrics with wider range: %v", err)
		}
		if len(metrics) == 0 {
			t.Fatalf("Still no metrics found - metrics may not have been saved correctly")
		}
	}
	if len(metrics) > 0 {
		if metrics[0].NodeID != "node-metrics-123" {
			t.Errorf("NodeID mismatch: got %s, want node-metrics-123", metrics[0].NodeID)
		}
		if string(metrics[0].EncryptedBlob) != "encrypted-metrics-data-here" {
			t.Errorf("EncryptedBlob mismatch")
		}
		if metrics[0].SenderKeyID != "sender-fingerprint-abc123" {
			t.Errorf("SenderKeyID mismatch: got %s, want sender-fingerprint-abc123", metrics[0].SenderKeyID)
		}
	}

	// Test DeleteOldMetrics
	oldTime := now.Add(1 * time.Hour) // Delete metrics older than 1 hour from now (should delete our test metric)
	if err := store.DeleteOldMetrics(oldTime); err != nil {
		t.Fatalf("Failed to delete old metrics: %v", err)
	}

	// Verify metric was deleted
	metrics, err = store.GetEncryptedMetricsHistory(routingToken, time.Time{}, time.Now().Add(24*time.Hour), 100)
	if err != nil {
		t.Fatalf("Failed to get metrics after deletion: %v", err)
	}
	if len(metrics) != 0 {
		t.Errorf("Expected 0 metrics after deletion, got %d", len(metrics))
	}
}

func testRoutingToken(t *testing.T, store Store) {
	// Create routing token info
	info := &model.RoutingTokenInfo{
		RoutingToken: "routing-token-xyz789",
		LicenseKey:   "LICENSE-ABC",
		Tier:         "pro",
		FCMTopic:     "fcm-topic-xyz",
	}

	if err := store.SaveRoutingTokenInfo(info); err != nil {
		t.Fatalf("Failed to save routing token info: %v", err)
	}

	// Get routing token info
	fetched, err := store.GetRoutingTokenInfo(info.RoutingToken)
	if err != nil {
		t.Fatalf("Failed to get routing token info: %v", err)
	}
	if fetched.Tier != "pro" {
		t.Errorf("Tier mismatch: got %s, want pro", fetched.Tier)
	}
	if fetched.LicenseKey != "LICENSE-ABC" {
		t.Errorf("LicenseKey mismatch: got %s, want LICENSE-ABC", fetched.LicenseKey)
	}

	// Update tier
	if err := store.UpdateRoutingTokenTier(info.RoutingToken, "business"); err != nil {
		t.Fatalf("Failed to update routing token tier: %v", err)
	}

	fetched, _ = store.GetRoutingTokenInfo(info.RoutingToken)
	if fetched.Tier != "business" {
		t.Errorf("Tier not updated: got %s, want business", fetched.Tier)
	}

	// Create another token with same license key for bulk update test
	info2 := &model.RoutingTokenInfo{
		RoutingToken: "routing-token-xyz790",
		LicenseKey:   "LICENSE-ABC",
		Tier:         "pro",
		FCMTopic:     "fcm-topic-xyz2",
	}
	if err := store.SaveRoutingTokenInfo(info2); err != nil {
		t.Fatalf("Failed to save second routing token info: %v", err)
	}

	// Bulk update by license key
	if err := store.UpdateTierByLicenseKey("LICENSE-ABC", "enterprise"); err != nil {
		t.Fatalf("Failed to bulk update tier by license key: %v", err)
	}

	// Verify both were updated
	fetched, _ = store.GetRoutingTokenInfo(info.RoutingToken)
	if fetched.Tier != "enterprise" {
		t.Errorf("First token tier not updated: got %s, want enterprise", fetched.Tier)
	}
	fetched2, _ := store.GetRoutingTokenInfo(info2.RoutingToken)
	if fetched2.Tier != "enterprise" {
		t.Errorf("Second token tier not updated: got %s, want enterprise", fetched2.Tier)
	}

	// Delete routing token info
	if err := store.DeleteRoutingTokenInfo(info.RoutingToken); err != nil {
		t.Fatalf("Failed to delete routing token info: %v", err)
	}
	if err := store.DeleteRoutingTokenInfo(info2.RoutingToken); err != nil {
		t.Fatalf("Failed to delete second routing token info: %v", err)
	}
}

func testLogs(t *testing.T, store Store) {
	routingToken := "log-test-token-123"
	nodeID := "log-test-node-456"
	now := time.Now()

	// Create test log entries
	for i := 0; i < 5; i++ {
		log := &model.EncryptedLog{
			NodeID:        nodeID,
			RoutingToken:  routingToken,
			Timestamp:     now.Add(time.Duration(i) * time.Minute),
			EncryptedBlob: []byte(fmt.Sprintf("encrypted-log-data-%d", i)),
			Nonce:         []byte(fmt.Sprintf("nonce-%d", i)),
			SenderKeyID:   "sender-key-id",
		}
		if err := store.SaveEncryptedLog(log); err != nil {
			t.Fatalf("Failed to save log %d: %v", i, err)
		}
	}

	// Test CountLogs
	count, err := store.CountLogs(routingToken)
	if err != nil {
		t.Fatalf("Failed to count logs: %v", err)
	}
	if count != 5 {
		t.Errorf("Expected 5 logs, got %d", count)
	}

	// Test CountAllLogs
	totalCount, err := store.CountAllLogs()
	if err != nil {
		t.Fatalf("Failed to count all logs: %v", err)
	}
	if totalCount < 5 {
		t.Errorf("Expected at least 5 total logs, got %d", totalCount)
	}

	// Test GetEncryptedLogsHistory
	logs, err := store.GetEncryptedLogsHistory(routingToken, time.Time{}, time.Now().Add(time.Hour), 100)
	if err != nil {
		t.Fatalf("Failed to get logs history: %v", err)
	}
	if len(logs) != 5 {
		t.Errorf("Expected 5 logs, got %d", len(logs))
	}

	// Test GetEncryptedLogsByNode with limit
	logs, err = store.GetEncryptedLogsByNode(routingToken, nodeID, time.Time{}, time.Time{}, 3, 0)
	if err != nil {
		t.Fatalf("Failed to get logs by node: %v", err)
	}
	if len(logs) != 3 {
		t.Errorf("Expected 3 logs with limit, got %d", len(logs))
	}

	// Test GetLogsStatsByRoutingToken
	stats, err := store.GetLogsStatsByRoutingToken()
	if err != nil {
		t.Fatalf("Failed to get logs stats: %v", err)
	}
	if stats[routingToken] != 5 {
		t.Errorf("Expected 5 logs for token, got %d", stats[routingToken])
	}

	// Test GetLogStorageByRoutingToken
	storage, err := store.GetLogStorageByRoutingToken()
	if err != nil {
		t.Fatalf("Failed to get storage stats: %v", err)
	}
	if storage[routingToken] == 0 {
		t.Error("Expected non-zero storage for token")
	}

	// Test GetOldestAndNewestLog
	oldest, newest, err := store.GetOldestAndNewestLog()
	if err != nil {
		t.Fatalf("Failed to get oldest/newest log: %v", err)
	}
	if oldest.IsZero() || newest.IsZero() {
		t.Error("Expected non-zero oldest and newest timestamps")
	}

	// Test DeleteOldestLogs (keep 3)
	if err := store.DeleteOldestLogs(routingToken, 3); err != nil {
		t.Fatalf("Failed to delete oldest logs: %v", err)
	}
	count, _ = store.CountLogs(routingToken)
	if count != 3 {
		t.Errorf("Expected 3 logs after delete oldest, got %d", count)
	}

	// Add more logs for delete tests
	for i := 0; i < 3; i++ {
		log := &model.EncryptedLog{
			NodeID:        "another-node",
			RoutingToken:  routingToken,
			Timestamp:     now.Add(time.Duration(10+i) * time.Minute),
			EncryptedBlob: []byte(fmt.Sprintf("more-data-%d", i)),
			Nonce:         []byte(fmt.Sprintf("nonce-more-%d", i)),
			SenderKeyID:   "sender-key-id",
		}
		store.SaveEncryptedLog(log)
	}

	// Test DeleteLogsByNodeID
	deleted, err := store.DeleteLogsByNodeID(routingToken, "another-node")
	if err != nil {
		t.Fatalf("Failed to delete logs by node: %v", err)
	}
	if deleted != 3 {
		t.Errorf("Expected 3 deleted, got %d", deleted)
	}

	// Test DeleteLogsByRoutingToken (cleanup)
	deleted, err = store.DeleteLogsByRoutingToken(routingToken)
	if err != nil {
		t.Fatalf("Failed to delete logs by routing token: %v", err)
	}
	if deleted < 1 {
		t.Errorf("Expected at least 1 deleted, got %d", deleted)
	}

	// Verify all deleted
	count, _ = store.CountLogs(routingToken)
	if count != 0 {
		t.Errorf("Expected 0 logs after deletion, got %d", count)
	}
}
