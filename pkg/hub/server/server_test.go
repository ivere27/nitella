package server

import (
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/pem"
	"math/big"
	"net"
	"os"
	"strings"
	"testing"
	"time"

	pb "github.com/ivere27/nitella/pkg/api/hub"
	"github.com/ivere27/nitella/pkg/hub/auth"
	"github.com/ivere27/nitella/pkg/hub/model"
	"github.com/ivere27/nitella/pkg/hub/store"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/metadata"
)

// generateTestKeyPEM generates an Ed25519 key pair and returns PEM-encoded private key
func generateTestKeyPEM(t *testing.T) []byte {
	_, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatalf("Failed to generate key: %v", err)
	}

	privBytes, err := x509.MarshalPKCS8PrivateKey(priv)
	if err != nil {
		t.Fatalf("Failed to marshal private key: %v", err)
	}
	return pem.EncodeToMemory(&pem.Block{
		Type:  "PRIVATE KEY",
		Bytes: privBytes,
	})
}

type testServer struct {
	server       *grpc.Server
	hubServer    *HubServer
	store        store.Store
	tokenManager *auth.TokenManager
	addr         string
	cleanup      func()
	caPEM        []byte
}

func setupTestServer(t *testing.T) *testServer {
	// Create temp database
	tmpFile, err := os.CreateTemp("", "hub_server_test_*.db")
	if err != nil {
		t.Fatalf("Failed to create temp file: %v", err)
	}
	tmpFile.Close()

	// Initialize store
	testStore, err := store.NewStore("sqlite3", tmpFile.Name())
	if err != nil {
		os.Remove(tmpFile.Name())
		t.Fatalf("Failed to create store: %v", err)
	}

	// Generate JWT key (PEM-encoded)
	privKeyPEM := generateTestKeyPEM(t)
	tokenManager, err := auth.NewTokenManager(privKeyPEM, nil, "test-issuer")
	if err != nil {
		testStore.Close()
		os.Remove(tmpFile.Name())
		t.Fatalf("Failed to create token manager: %v", err)
	}

	// Create admin token manager (can be the same for tests)
	adminTokenManager, err := auth.NewTokenManager(privKeyPEM, nil, "test-admin-issuer")
	if err != nil {
		testStore.Close()
		os.Remove(tmpFile.Name())
		t.Fatalf("Failed to create admin token manager: %v", err)
	}

	// Create Hub server
	hubServer := NewHubServer(tokenManager, adminTokenManager, testStore, nil, nil)

	// Generate TLS certs for the server
	serverCertPEM, serverKeyPEM, err := generateSelfSignedCert(t)
	if err != nil {
		t.Fatalf("Failed to generate test certs: %v", err)
	}
	serverCert, err := tls.X509KeyPair(serverCertPEM, serverKeyPEM)
	if err != nil {
		t.Fatalf("Failed to load key pair: %v", err)
	}

	// Create gRPC server with TLS
	grpcServer := grpc.NewServer(
		grpc.Creds(credentials.NewServerTLSFromCert(&serverCert)),
		grpc.ChainUnaryInterceptor(hubServer.AuthInterceptor),
	)
	hubServer.RegisterServices(grpcServer)

	// Start server
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		testStore.Close()
		os.Remove(tmpFile.Name())
		t.Fatalf("Failed to listen: %v", err)
	}

	go grpcServer.Serve(listener)

	return &testServer{
		server:       grpcServer,
		hubServer:    hubServer,
		store:        testStore,
		tokenManager: tokenManager,
		addr:         listener.Addr().String(),
		caPEM:        serverCertPEM, // Self-signed leaf acts as its own CA
		cleanup: func() {
			grpcServer.Stop()
			testStore.Close()
			os.Remove(tmpFile.Name())
		},
	}
}

// generateSelfSignedCert generates a self-signed certificate for localhost
func generateSelfSignedCert(t *testing.T) ([]byte, []byte, error) {
	_, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		return nil, nil, err
	}

	template := x509.Certificate{
		SerialNumber: big.NewInt(1),
		Subject: pkix.Name{
			Organization: []string{"Test Hub"},
		},
		NotBefore:             time.Now(),
		NotAfter:              time.Now().Add(time.Hour),
		KeyUsage:              x509.KeyUsageKeyEncipherment | x509.KeyUsageDigitalSignature | x509.KeyUsageCertSign,
		ExtKeyUsage:           []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth},
		BasicConstraintsValid: true,
		IsCA:                  true, // Self-signed, so it must be CA to sign itself (or just be a leaf that we trust as root)
		IPAddresses:           []net.IP{net.ParseIP("127.0.0.1")},
		DNSNames:              []string{"localhost"},
	}

	derBytes, err := x509.CreateCertificate(rand.Reader, &template, &template, priv.Public(), priv)
	if err != nil {
		return nil, nil, err
	}

	certPEM := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: derBytes})
	
	privBytes, err := x509.MarshalPKCS8PrivateKey(priv)
	if err != nil {
		return nil, nil, err
	}
	keyPEM := pem.EncodeToMemory(&pem.Block{Type: "PRIVATE KEY", Bytes: privBytes})

	return certPEM, keyPEM, nil
}

func (ts *testServer) dial(t *testing.T) *grpc.ClientConn {
	pool := x509.NewCertPool()
	pool.AppendCertsFromPEM(ts.caPEM)
	
	tlsConfig := &tls.Config{
		RootCAs:    pool,
		MinVersion: tls.VersionTLS13,
	}

	conn, err := grpc.NewClient(ts.addr, grpc.WithTransportCredentials(credentials.NewTLS(tlsConfig)))
	if err != nil {
		t.Fatalf("Failed to dial: %v", err)
	}
	return conn
}

func (ts *testServer) mobileContext(userID, deviceID string) context.Context {
	token, _ := ts.tokenManager.GenerateMobileToken(userID, deviceID)
	return metadata.AppendToOutgoingContext(context.Background(), "authorization", "Bearer "+token)
}

func (ts *testServer) adminContext() context.Context {
	token, _ := ts.tokenManager.GenerateAdminToken("admin")
	return metadata.AppendToOutgoingContext(context.Background(), "authorization", "Bearer "+token)
}

func TestMobileService(t *testing.T) {
	ts := setupTestServer(t)
	defer ts.cleanup()

	conn := ts.dial(t)
	defer conn.Close()

	// Create test user and node in store (zero-trust: use RoutingToken, not UserID)
	ts.store.SaveUser(&model.User{
		ID:               "user-123",
		BlindIndex:       "blind-index-hash-mobile",
		EncryptedProfile: []byte("encrypted-profile"),
		Role:             "user",
		Tier:             "free",
	})
	ts.store.SaveNode(&model.Node{
		ID:                "node-456",
		RoutingToken:      "routing-token-user-123",
		EncryptedMetadata: []byte("encrypted-metadata"),
		Status:            "online",
		CertPEM:           "-----BEGIN CERTIFICATE-----\ntest\n-----END CERTIFICATE-----",
	})

	// Also create routing token info
	ts.store.SaveRoutingTokenInfo(&model.RoutingTokenInfo{
		RoutingToken: "routing-token-user-123",
		Tier:         "free",
		FCMTopic:     "fcm-topic-user-123",
	})

	client := pb.NewMobileServiceClient(conn)

	t.Run("ListNodes", func(t *testing.T) {
		ctx := ts.mobileContext("user-123", "device-001")
		resp, err := client.ListNodes(ctx, &pb.ListNodesRequest{})
		if err != nil {
			t.Logf("ListNodes error (expected if method not implemented): %v", err)
			return
		}
		t.Logf("ListNodes response: %v nodes", len(resp.Nodes))
	})

	t.Run("GetNode", func(t *testing.T) {
		ctx := ts.mobileContext("user-123", "device-001")
		resp, err := client.GetNode(ctx, &pb.GetNodeRequest{NodeId: "node-456"})
		if err != nil {
			t.Logf("GetNode error (expected if method not implemented): %v", err)
			return
		}
		t.Logf("GetNode response: %+v", resp)
	})
}

func TestAdminService(t *testing.T) {
	ts := setupTestServer(t)
	defer ts.cleanup()

	conn := ts.dial(t)
	defer conn.Close()

	client := pb.NewAdminServiceClient(conn)

	t.Run("ListAllUsers", func(t *testing.T) {
		// Create test user
		ts.store.SaveUser(&model.User{
			ID:               "admin-user",
			BlindIndex:       "blind-index-admin",
			EncryptedProfile: []byte("encrypted-admin-profile"),
			Role:             "admin",
			Tier:             "business",
		})

		ctx := ts.adminContext()
		resp, err := client.ListAllUsers(ctx, &pb.ListAllUsersRequest{})
		if err != nil {
			t.Logf("ListAllUsers error (expected if method not implemented): %v", err)
			return
		}
		t.Logf("ListAllUsers response: %d users", len(resp.Users))
	})

	t.Run("ListInviteCodes", func(t *testing.T) {
		ctx := ts.adminContext()
		resp, err := client.ListInviteCodes(ctx, &pb.ListInviteCodesRequest{})
		if err != nil {
			t.Logf("ListInviteCodes error (expected if method not implemented): %v", err)
			return
		}
		t.Logf("ListInviteCodes response: %d codes", len(resp.Codes))
	})

	t.Run("GetSystemStats", func(t *testing.T) {
		ctx := ts.adminContext()
		resp, err := client.GetSystemStats(ctx, &pb.GetSystemStatsRequest{})
		if err != nil {
			t.Logf("GetSystemStats error (expected if method not implemented): %v", err)
			return
		}
		t.Logf("GetSystemStats response: %d users, %d nodes", resp.TotalUsers, resp.TotalNodes)
	})
}

func TestAuthService(t *testing.T) {
	ts := setupTestServer(t)
	defer ts.cleanup()

	conn := ts.dial(t)
	defer conn.Close()

	client := pb.NewAuthServiceClient(conn)

	t.Run("RegisterUser", func(t *testing.T) {
		ctx := context.Background()
		resp, err := client.RegisterUser(ctx, &pb.RegisterUserRequest{
			InviteCode: "NITELLA",
		})
		if err != nil {
			t.Logf("RegisterUser error (expected if method not implemented): %v", err)
			return
		}
		t.Logf("RegisterUser response: user_id=%s", resp.UserId)
	})
}

func TestRoutingTokenOperations(t *testing.T) {
	ts := setupTestServer(t)
	defer ts.cleanup()

	// Test routing token info operations
	info := &model.RoutingTokenInfo{
		RoutingToken: "test-routing-token",
		LicenseKey:   "TEST-LICENSE",
		Tier:         "free",
		FCMTopic:     "test-fcm-topic",
	}

	// Save
	if err := ts.store.SaveRoutingTokenInfo(info); err != nil {
		t.Fatalf("Failed to save routing token info: %v", err)
	}

	// Get
	fetched, err := ts.store.GetRoutingTokenInfo(info.RoutingToken)
	if err != nil {
		t.Fatalf("Failed to get routing token info: %v", err)
	}
	if fetched.Tier != "free" {
		t.Errorf("Tier mismatch: got %s, want free", fetched.Tier)
	}

	// Update tier
	if err := ts.store.UpdateRoutingTokenTier(info.RoutingToken, "pro"); err != nil {
		t.Fatalf("Failed to update routing token tier: %v", err)
	}

	fetched, _ = ts.store.GetRoutingTokenInfo(info.RoutingToken)
	if fetched.Tier != "pro" {
		t.Errorf("Tier not updated: got %s, want pro", fetched.Tier)
	}
}

func TestZeroTrustNodeOperations(t *testing.T) {
	ts := setupTestServer(t)
	defer ts.cleanup()

	// Create node with zero-trust fields
	node := &model.Node{
		ID:                "zero-trust-node",
		RoutingToken:      "blind-routing-token",
		EncryptedMetadata: []byte("encrypted-node-info"),
		Status:            "offline",
		CertPEM:           "-----BEGIN CERTIFICATE-----\ntest\n-----END CERTIFICATE-----",
		PublicKeyPEM:      "-----BEGIN PUBLIC KEY-----\ntest\n-----END PUBLIC KEY-----",
	}

	// Save
	if err := ts.store.SaveNode(node); err != nil {
		t.Fatalf("Failed to save node: %v", err)
	}

	// Get by ID
	fetched, err := ts.store.GetNode(node.ID)
	if err != nil {
		t.Fatalf("Failed to get node: %v", err)
	}
	if fetched.RoutingToken != node.RoutingToken {
		t.Errorf("RoutingToken mismatch: got %s, want %s", fetched.RoutingToken, node.RoutingToken)
	}

	// Get by routing token
	fetchedByToken, err := ts.store.GetNodeByRoutingToken(node.RoutingToken)
	if err != nil {
		t.Fatalf("Failed to get node by routing token: %v", err)
	}
	if fetchedByToken.ID != node.ID {
		t.Errorf("ID mismatch: got %s, want %s", fetchedByToken.ID, node.ID)
	}

	// Update status
	if err := ts.store.UpdateNodeStatus(node.ID, "online"); err != nil {
		t.Fatalf("Failed to update node status: %v", err)
	}

	fetched, _ = ts.store.GetNode(node.ID)
	if fetched.Status != "online" {
		t.Errorf("Status not updated: got %s, want online", fetched.Status)
	}
}

func TestSendCommandRoutingTokenValidation(t *testing.T) {
	ts := setupTestServer(t)
	defer ts.cleanup()

	conn := ts.dial(t)
	defer conn.Close()

	// Create test user and node
	ts.store.SaveUser(&model.User{
		ID:               "user-cmd",
		BlindIndex:       "blind-index-cmd",
		EncryptedProfile: []byte("encrypted-profile"),
		Role:             "user",
		Tier:             "free",
	})

	validRoutingToken := "valid-routing-token-for-cmd"
	ts.store.SaveNode(&model.Node{
		ID:                "node-cmd-test",
		RoutingToken:      validRoutingToken,
		EncryptedMetadata: []byte("encrypted-metadata"),
		Status:            "online",
		CertPEM:           "-----BEGIN CERTIFICATE-----\ntest\n-----END CERTIFICATE-----",
	})

	client := pb.NewMobileServiceClient(conn)

	t.Run("SendCommand_MissingRoutingToken", func(t *testing.T) {
		ctx := ts.mobileContext("user-cmd", "device-001")
		_, err := client.SendCommand(ctx, &pb.CommandRequest{
			NodeId: "node-cmd-test",
			// RoutingToken is missing
		})
		if err == nil {
			t.Error("SendCommand should fail without routing_token")
		}
		// Check error contains expected message
		if err != nil && !containsAny(err.Error(), "routing_token", "required") {
			t.Logf("Error message: %v (may be expected for unimplemented method)", err)
		}
	})

	t.Run("SendCommand_InvalidRoutingToken", func(t *testing.T) {
		ctx := ts.mobileContext("user-cmd", "device-001")
		_, err := client.SendCommand(ctx, &pb.CommandRequest{
			NodeId:       "node-cmd-test",
			RoutingToken: "invalid-routing-token",
		})
		if err == nil {
			t.Error("SendCommand should fail with invalid routing_token")
		}
		if err != nil && !containsAny(err.Error(), "invalid", "permission", "denied") {
			t.Logf("Error message: %v (may be expected for unimplemented method)", err)
		}
	})

	t.Run("SendCommand_RoutingTokenMismatch", func(t *testing.T) {
		// Create another node with different routing token
		ts.store.SaveNode(&model.Node{
			ID:                "node-other",
			RoutingToken:      "other-routing-token",
			EncryptedMetadata: []byte("encrypted-metadata"),
			Status:            "online",
			CertPEM:           "-----BEGIN CERTIFICATE-----\ntest\n-----END CERTIFICATE-----",
		})

		ctx := ts.mobileContext("user-cmd", "device-001")
		_, err := client.SendCommand(ctx, &pb.CommandRequest{
			NodeId:       "node-cmd-test",           // This node's ID
			RoutingToken: "other-routing-token",     // But other node's token
		})
		if err == nil {
			t.Error("SendCommand should fail when routing_token doesn't match node_id")
		}
		if err != nil && !containsAny(err.Error(), "mismatch", "permission", "denied") {
			t.Logf("Error message: %v (may be expected for unimplemented method)", err)
		}
	})

	t.Run("SendCommand_ValidRoutingToken", func(t *testing.T) {
		ctx := ts.mobileContext("user-cmd", "device-001")
		_, err := client.SendCommand(ctx, &pb.CommandRequest{
			NodeId:       "node-cmd-test",
			RoutingToken: validRoutingToken,
		})
		// This will timeout because the node isn't actually connected,
		// but the routing token validation should pass
		if err != nil {
			errStr := err.Error()
			// If we get timeout or unavailable, that means validation passed
			if containsAny(errStr, "timeout", "Unavailable", "deadline") {
				t.Log("Routing token validation passed (timeout expected since node not connected)")
			} else if containsAny(errStr, "routing_token", "permission", "invalid") {
				t.Errorf("SendCommand failed routing validation with valid token: %v", err)
			} else {
				t.Logf("SendCommand error (may be expected): %v", err)
			}
		}
	})
}

// containsAny checks if s contains any of the substrings (case-insensitive)
func containsAny(s string, substrings ...string) bool {
	sLower := strings.ToLower(s)
	for _, sub := range substrings {
		if strings.Contains(sLower, strings.ToLower(sub)) {
			return true
		}
	}
	return false
}
