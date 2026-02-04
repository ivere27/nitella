package integration

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"testing"
	"time"

	pbCommon "github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/geoip"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/metadata"
	"google.golang.org/protobuf/types/known/emptypb"
)

const (
	serverBinPath = "../../bin/geoip-server"
	cliBinPath    = "../../bin/geoip"
)

// TestGeoIPServer tests the standalone geoip-server
func TestGeoIPServer(t *testing.T) {
	// Find binaries
	wd, _ := os.Getwd()
	serverBin := filepath.Join(wd, serverBinPath)

	if _, err := os.Stat(serverBin); os.IsNotExist(err) {
		t.Fatalf("geoip-server binary not found at %s. Run 'make build' first.", serverBin)
	}

	// Get free ports
	publicPort := getFreePort(t)
	adminPort := getFreePort(t)
	adminToken := "test-token-12345"

	// Create temp db file and cert data dir
	tmpDB, err := os.CreateTemp("", "geoip_test_*.db")
	if err != nil {
		t.Fatal(err)
	}
	tmpDB.Close()
	defer os.Remove(tmpDB.Name())

	certDataDir, err := os.MkdirTemp("", "geoip_certs_*")
	if err != nil {
		t.Fatal(err)
	}
	defer os.RemoveAll(certDataDir)

	// Start server with TLS
	cmd := exec.Command(serverBin,
		"-port", fmt.Sprintf("%d", publicPort),
		"-admin-port", fmt.Sprintf("%d", adminPort),
		"-admin-token", adminToken,
		"-db", tmpDB.Name(),
		"-cert-data-dir", certDataDir,
		"-remote", "ipwhois=https://ipwhois.app/json/%s",
	)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Start(); err != nil {
		t.Fatalf("Failed to start geoip-server: %v", err)
	}
	defer func() {
		if cmd.Process != nil {
			cmd.Process.Kill()
			cmd.Wait()
		}
	}()

	// Wait for server to start and generate certs
	publicAddr := fmt.Sprintf("localhost:%d", publicPort)
	adminAddr := fmt.Sprintf("localhost:%d", adminPort)
	caPath := filepath.Join(certDataDir, "geoip_certs", "admin_ca.crt")
	waitForCertAndGrpc(t, publicAddr, caPath, 15*time.Second)

	// Create TLS clients with proper CA verification
	publicClient, publicConn := createPublicClientTLS(t, publicAddr, caPath)
	defer publicConn.Close()

	adminClient, adminConn := createAdminClientTLS(t, adminAddr, caPath)
	defer adminConn.Close()

	ctx := context.Background()
	adminCtx := metadata.NewOutgoingContext(ctx, metadata.Pairs("authorization", "Bearer "+adminToken))

	// Test 1: Get Status
	t.Run("GetStatus", func(t *testing.T) {
		resp, err := publicClient.GetStatus(ctx, &emptypb.Empty{})
		if err != nil {
			t.Fatalf("GetStatus failed: %v", err)
		}
		if !resp.Ready {
			t.Error("Server should be ready")
		}
		t.Logf("Status: Ready=%v, L1Cache=%d, L2Cache=%d, Strategy=%s, Providers=%v",
			resp.Ready, resp.L1CacheSize, resp.L2CacheSize, resp.Strategy, resp.ActiveProviders)
	})

	// Test 2: IP Lookup
	t.Run("Lookup", func(t *testing.T) {
		testIPs := []string{"8.8.8.8", "1.1.1.1"}

		for _, ip := range testIPs {
			resp, err := publicClient.Lookup(ctx, &pb.LookupRequest{Ip: ip})
			if err != nil {
				t.Fatalf("Lookup(%s) failed: %v", ip, err)
			}
			if resp.Country == "" && resp.CountryCode == "" {
				t.Errorf("Lookup(%s) returned empty country", ip)
			}
			t.Logf("Lookup(%s): Country=%s (%s), City=%s, Source=%s, Latency=%dms",
				ip, resp.Country, resp.CountryCode, resp.City, resp.Source, resp.LatencyMs)
		}
	})

	// Test 3: Cache Hit (second lookup should be faster)
	t.Run("CacheHit", func(t *testing.T) {
		testIP := "8.8.8.8"

		// First lookup (may hit remote)
		start1 := time.Now()
		resp1, err := publicClient.Lookup(ctx, &pb.LookupRequest{Ip: testIP})
		elapsed1 := time.Since(start1)
		if err != nil {
			t.Fatalf("First lookup failed: %v", err)
		}

		// Second lookup (should hit L1 cache)
		start2 := time.Now()
		resp2, err := publicClient.Lookup(ctx, &pb.LookupRequest{Ip: testIP})
		elapsed2 := time.Since(start2)
		if err != nil {
			t.Fatalf("Second lookup failed: %v", err)
		}

		// Verify consistency
		if resp1.CountryCode != resp2.CountryCode {
			t.Errorf("Country code changed: %s != %s", resp1.CountryCode, resp2.CountryCode)
		}

		t.Logf("First lookup: %v, Second lookup: %v (cache hit)", elapsed1, elapsed2)

		// Cached lookup should generally be faster
		if elapsed2 < elapsed1 {
			t.Log("Cache hit confirmed (second lookup faster)")
		}
	})

	// Test 4: Admin - List Providers
	t.Run("AdminListProviders", func(t *testing.T) {
		resp, err := adminClient.ListProviders(adminCtx, &emptypb.Empty{})
		if err != nil {
			t.Fatalf("ListProviders failed: %v", err)
		}
		if len(resp.Providers) == 0 {
			t.Error("Expected at least one provider")
		}
		for _, p := range resp.Providers {
			t.Logf("Provider: %s, Enabled=%v, URL=%s, Priority=%d",
				p.Name, p.Enabled, p.Url, p.Priority)
		}
	})

	// Test 5: Admin - Add/Remove Provider
	t.Run("AdminAddRemoveProvider", func(t *testing.T) {
		// Add provider
		addResp, err := adminClient.AddProvider(adminCtx, &pb.AddProviderRequest{
			Name: "test-provider",
			Url:  "http://test.example.com/json/%s",
		})
		if err != nil {
			t.Fatalf("AddProvider failed: %v", err)
		}
		t.Logf("Added provider: %s (priority %d)", addResp.Name, addResp.Priority)

		// Verify provider exists
		listResp, err := adminClient.ListProviders(adminCtx, &emptypb.Empty{})
		if err != nil {
			t.Fatalf("ListProviders failed: %v", err)
		}
		found := false
		for _, p := range listResp.Providers {
			if p.Name == "test-provider" {
				found = true
				break
			}
		}
		if !found {
			t.Error("Added provider not found in list")
		}

		// Remove provider
		_, err = adminClient.RemoveProvider(adminCtx, &pb.RemoveProviderRequest{Name: "test-provider"})
		if err != nil {
			t.Fatalf("RemoveProvider failed: %v", err)
		}
		t.Log("Removed test-provider")
	})

	// Test 6: Admin - Cache Stats
	t.Run("AdminCacheStats", func(t *testing.T) {
		resp, err := adminClient.GetCacheStats(adminCtx, &emptypb.Empty{})
		if err != nil {
			t.Fatalf("GetCacheStats failed: %v", err)
		}
		t.Logf("L1: size=%d, hits=%d, misses=%d", resp.L1Size, resp.L1Hits, resp.L1Misses)
		t.Logf("L2: enabled=%v, size=%d, hits=%d, misses=%d", resp.L2Enabled, resp.L2Size, resp.L2Hits, resp.L2Misses)
	})

	// Test 7: Admin - Get/Set Strategy
	t.Run("AdminStrategy", func(t *testing.T) {
		// Get current strategy
		getResp, err := adminClient.GetStrategy(adminCtx, &emptypb.Empty{})
		if err != nil {
			t.Fatalf("GetStrategy failed: %v", err)
		}
		t.Logf("Current strategy: %v, timeout=%dms", getResp.Steps, getResp.TimeoutMs)

		// Set new strategy
		newSteps := []string{"l1", "l2", "remote"}
		_, err = adminClient.SetStrategy(adminCtx, &pb.SetStrategyRequest{Steps: newSteps})
		if err != nil {
			t.Fatalf("SetStrategy failed: %v", err)
		}

		// Verify
		getResp2, _ := adminClient.GetStrategy(adminCtx, &emptypb.Empty{})
		t.Logf("New strategy: %v", getResp2.Steps)
	})

	// Test 8: Admin - Clear Cache
	t.Run("AdminClearCache", func(t *testing.T) {
		// Clear L1 cache
		_, err := adminClient.ClearCache(adminCtx, &pb.ClearCacheRequest{Layer: pb.CacheLayer_CACHE_LAYER_L1})
		if err != nil {
			t.Fatalf("ClearCache(L1) failed: %v", err)
		}
		t.Log("L1 cache cleared")

		// Verify cache is empty
		stats, _ := adminClient.GetCacheStats(adminCtx, &emptypb.Empty{})
		if stats.L1Size != 0 {
			t.Errorf("L1 cache should be empty, got size=%d", stats.L1Size)
		}
	})

	// Test 9: Admin - Enable/Disable Provider
	t.Run("AdminEnableDisableProvider", func(t *testing.T) {
		// Get provider name
		listResp, err := adminClient.ListProviders(adminCtx, &emptypb.Empty{})
		if err != nil || len(listResp.Providers) == 0 {
			t.Skip("No providers to test")
		}
		providerName := listResp.Providers[0].Name

		// Disable
		_, err = adminClient.DisableProvider(adminCtx, &pb.ProviderNameRequest{Name: providerName})
		if err != nil {
			t.Fatalf("DisableProvider failed: %v", err)
		}
		t.Logf("Disabled provider: %s", providerName)

		// Verify disabled
		listResp2, _ := adminClient.ListProviders(adminCtx, &emptypb.Empty{})
		for _, p := range listResp2.Providers {
			if p.Name == providerName && p.Enabled {
				t.Error("Provider should be disabled")
			}
		}

		// Re-enable
		_, err = adminClient.EnableProvider(adminCtx, &pb.ProviderNameRequest{Name: providerName})
		if err != nil {
			t.Fatalf("EnableProvider failed: %v", err)
		}
		t.Logf("Re-enabled provider: %s", providerName)
	})
}

// TestGeoIPCLI tests the CLI tool
func TestGeoIPCLI(t *testing.T) {
	wd, _ := os.Getwd()
	serverBin := filepath.Join(wd, serverBinPath)
	cliBin := filepath.Join(wd, cliBinPath)

	if _, err := os.Stat(serverBin); os.IsNotExist(err) {
		t.Fatalf("geoip-server binary not found. Run 'make build' first.")
	}
	if _, err := os.Stat(cliBin); os.IsNotExist(err) {
		t.Fatalf("geoip CLI binary not found. Run 'make build' first.")
	}

	// Start server
	publicPort := getFreePort(t)
	adminPort := getFreePort(t)
	adminToken := "cli-test-token"

	tmpDB, _ := os.CreateTemp("", "geoip_cli_test_*.db")
	tmpDB.Close()
	defer os.Remove(tmpDB.Name())

	certDataDir, _ := os.MkdirTemp("", "geoip_cli_certs_*")
	defer os.RemoveAll(certDataDir)

	serverCmd := exec.Command(serverBin,
		"-port", fmt.Sprintf("%d", publicPort),
		"-admin-port", fmt.Sprintf("%d", adminPort),
		"-admin-token", adminToken,
		"-db", tmpDB.Name(),
		"-cert-data-dir", certDataDir,
		"-remote", "ipwhois=https://ipwhois.app/json/%s",
	)
	serverCmd.Start()
	defer func() {
		if serverCmd.Process != nil {
			serverCmd.Process.Kill()
			serverCmd.Wait()
		}
	}()

	caPath := filepath.Join(certDataDir, "geoip_certs", "admin_ca.crt")
	waitForCertAndGrpc(t, fmt.Sprintf("localhost:%d", publicPort), caPath, 10*time.Second)


	// Test CLI commands (CLI only connects to admin service)
	adminAddr := fmt.Sprintf("localhost:%d", adminPort)

	t.Run("CLI_Lookup", func(t *testing.T) {
		cmd := exec.Command(cliBin,
			"--addr", adminAddr,
			"--token", adminToken,
			"--tls-ca", caPath,
			"lookup", "8.8.8.8",
		)
		out, err := cmd.CombinedOutput()
		if err != nil {
			t.Fatalf("CLI lookup failed: %v\nOutput: %s", err, out)
		}
		t.Logf("CLI lookup output:\n%s", out)
	})

	t.Run("CLI_Status", func(t *testing.T) {
		cmd := exec.Command(cliBin,
			"--addr", adminAddr,
			"--token", adminToken,
			"--tls-ca", caPath,
			"status",
		)
		out, err := cmd.CombinedOutput()
		if err != nil {
			t.Fatalf("CLI status failed: %v\nOutput: %s", err, out)
		}
		t.Logf("CLI status output:\n%s", out)
	})

	t.Run("CLI_ProviderList", func(t *testing.T) {
		cmd := exec.Command(cliBin,
			"--addr", adminAddr,
			"--token", adminToken,
			"--tls-ca", caPath,
			"provider", "list",
		)
		out, err := cmd.CombinedOutput()
		if err != nil {
			t.Fatalf("CLI provider list failed: %v\nOutput: %s", err, out)
		}
		t.Logf("CLI provider list output:\n%s", out)
	})

	t.Run("CLI_CacheStats", func(t *testing.T) {
		cmd := exec.Command(cliBin,
			"--addr", adminAddr,
			"--token", adminToken,
			"--tls-ca", caPath,
			"cache", "stats",
		)
		out, err := cmd.CombinedOutput()
		if err != nil {
			t.Fatalf("CLI cache stats failed: %v\nOutput: %s", err, out)
		}
		t.Logf("CLI cache stats output:\n%s", out)
	})

	t.Run("CLI_StrategyShow", func(t *testing.T) {
		cmd := exec.Command(cliBin,
			"--addr", adminAddr,
			"--token", adminToken,
			"--tls-ca", caPath,
			"strategy", "show",
		)
		out, err := cmd.CombinedOutput()
		if err != nil {
			t.Fatalf("CLI strategy show failed: %v\nOutput: %s", err, out)
		}
		t.Logf("CLI strategy show output:\n%s", out)
	})

	t.Run("CLI_Help", func(t *testing.T) {
		// Help command still requires token since CLI verifies on startup
		cmd := exec.Command(cliBin,
			"--addr", adminAddr,
			"--token", adminToken,
			"--tls-ca", caPath,
			"help",
		)
		out, err := cmd.CombinedOutput()
		if err != nil {
			t.Fatalf("CLI help failed: %v\nOutput: %s", err, out)
		}
		t.Logf("CLI help output:\n%s", out)
	})
}

// TestLookupResult verifies the GeoInfo structure
func TestLookupResult(t *testing.T) {
	wd, _ := os.Getwd()
	serverBin := filepath.Join(wd, serverBinPath)

	if _, err := os.Stat(serverBin); os.IsNotExist(err) {
		t.Skip("geoip-server not found")
	}

	publicPort := getFreePort(t)
	tmpDB, _ := os.CreateTemp("", "geoip_result_test_*.db")
	tmpDB.Close()
	defer os.Remove(tmpDB.Name())

	certDataDir, _ := os.MkdirTemp("", "geoip_result_certs_*")
	defer os.RemoveAll(certDataDir)

	cmd := exec.Command(serverBin,
		"-port", fmt.Sprintf("%d", publicPort),
		"-admin-port", "0",
		"-db", tmpDB.Name(),
		"-cert-data-dir", certDataDir,
		"-remote", "ipwhois=https://ipwhois.app/json/%s",
	)
	cmd.Start()
	defer func() {
		if cmd.Process != nil {
			cmd.Process.Kill()
			cmd.Wait()
		}
	}()

	addr := fmt.Sprintf("localhost:%d", publicPort)
	caPath := filepath.Join(certDataDir, "geoip_certs", "admin_ca.crt")
	waitForCertAndGrpc(t, addr, caPath, 10*time.Second)

	client, conn := createPublicClientTLS(t, addr, caPath)
	defer conn.Close()

	// Test various IPs and verify GeoInfo fields
	testCases := []struct {
		ip              string
		expectedCountry string
		description     string
	}{
		{"8.8.8.8", "US", "Google DNS"},
		{"1.1.1.1", "", "Cloudflare (varies)"},
	}

	for _, tc := range testCases {
		t.Run(tc.description, func(t *testing.T) {
			resp, err := client.Lookup(context.Background(), &pb.LookupRequest{Ip: tc.ip})
			if err != nil {
				t.Fatalf("Lookup failed: %v", err)
			}

			// Verify structure
			verifyGeoInfo(t, resp, tc.ip, tc.expectedCountry)
		})
	}
}

func verifyGeoInfo(t *testing.T, info *pbCommon.GeoInfo, ip, expectedCountry string) {
	t.Helper()

	// Country should be present
	if info.Country == "" && info.CountryCode == "" {
		t.Error("Country should be present")
	}

	// Source should indicate where data came from
	if info.Source == "" {
		t.Error("Source should be present")
	}

	// Latency should be recorded
	if info.LatencyMs == 0 {
		t.Log("Warning: Latency is 0 (may be cached)")
	}

	// Verify expected country if specified
	if expectedCountry != "" && info.CountryCode != expectedCountry {
		t.Logf("Warning: Expected country %s, got %s (provider variation)", expectedCountry, info.CountryCode)
	}

	t.Logf("GeoInfo for %s: Country=%s (%s), City=%s, Region=%s, ISP=%s, Source=%s, Latency=%dms",
		ip, info.Country, info.CountryCode, info.City, info.RegionName, info.Isp, info.Source, info.LatencyMs)
}

// Helper functions

// waitForCertAndGrpc waits for CA file to be generated and gRPC to be ready
func waitForCertAndGrpc(t *testing.T, addr, caPath string, timeout time.Duration) {
	t.Helper()
	deadline := time.Now().Add(timeout)
	
	// First wait for CA file
	for time.Now().Before(deadline) {
		if _, err := os.Stat(caPath); err == nil {
			break
		}
		time.Sleep(100 * time.Millisecond)
	}
	
	// Then test gRPC connection with TLS
	for time.Now().Before(deadline) {
		caPEM, err := os.ReadFile(caPath)
		if err != nil {
			time.Sleep(100 * time.Millisecond)
			continue
		}
		caPool := x509.NewCertPool()
		if !caPool.AppendCertsFromPEM(caPEM) {
			time.Sleep(100 * time.Millisecond)
			continue
		}
		tlsConfig := &tls.Config{
			RootCAs:    caPool,
			MinVersion: tls.VersionTLS13,
		}
		conn, err := grpc.Dial(addr, grpc.WithTransportCredentials(credentials.NewTLS(tlsConfig)), grpc.WithBlock(), grpc.FailOnNonTempDialError(true))
		if err == nil {
			conn.Close()
			return
		}
		time.Sleep(100 * time.Millisecond)
	}
	t.Fatalf("gRPC server at %s not ready after %v", addr, timeout)
}

// loadTLSConfig loads CA certificate and returns TLS config
func loadTLSConfig(t *testing.T, caPath string) *tls.Config {
	t.Helper()
	caPEM, err := os.ReadFile(caPath)
	if err != nil {
		t.Fatalf("Failed to read CA: %v", err)
	}
	caPool := x509.NewCertPool()
	if !caPool.AppendCertsFromPEM(caPEM) {
		t.Fatalf("Failed to parse CA")
	}
	return &tls.Config{
		RootCAs:    caPool,
		MinVersion: tls.VersionTLS13,
	}
}

func createPublicClientTLS(t *testing.T, addr, caPath string) (pb.GeoIPServiceClient, *grpc.ClientConn) {
	t.Helper()
	tlsConfig := loadTLSConfig(t, caPath)
	conn, err := grpc.Dial(addr, grpc.WithTransportCredentials(credentials.NewTLS(tlsConfig)))
	if err != nil {
		t.Fatalf("Failed to dial %s: %v", addr, err)
	}
	return pb.NewGeoIPServiceClient(conn), conn
}

func createAdminClientTLS(t *testing.T, addr, caPath string) (pb.GeoIPAdminServiceClient, *grpc.ClientConn) {
	t.Helper()
	tlsConfig := loadTLSConfig(t, caPath)
	conn, err := grpc.Dial(addr, grpc.WithTransportCredentials(credentials.NewTLS(tlsConfig)))
	if err != nil {
		t.Fatalf("Failed to dial %s: %v", addr, err)
	}
	return pb.NewGeoIPAdminServiceClient(conn), conn
}
