package integration

import (
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"fmt"
	"testing"
	"time"

	pb "github.com/ivere27/nitella/pkg/api/proxy"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"google.golang.org/protobuf/proto"
)

// TestAdminAPI_StreamMetrics tests metrics streaming
func TestAdminAPI_StreamMetrics(t *testing.T) {
	backend := startEchoBackend(t, "METRICS_BACKEND")
	defer backend.Close()

	adminPort := getFreePort(t)
	token := "metrics-token"
	daemon, caPath := startNitelladWithAdmin(t, adminPort, token)
	defer daemon.Process.Kill()
	time.Sleep(100 * time.Millisecond)

	client, conn, nodePubKey := connectAdminAPI(t, adminPort, token, caPath)
	defer conn.Close()

	ctx := authContext(token)

	// Create a proxy to generate some stats
	createResp := cmdCreateProxy(t, client, ctx, nodePubKey, &pb.CreateProxyRequest{
		Name:           "metrics-proxy",
		ListenAddr:     fmt.Sprintf("127.0.0.1:%d", getFreePort(t)),
		DefaultBackend: backend.Addr().String(),
	})
	proxyID := createResp.ProxyId
	defer cmdDeleteProxy(t, client, ctx, nodePubKey, &pb.DeleteProxyRequest{ProxyId: proxyID})
    
    status := cmdGetProxyStatus(t, client, ctx, nodePubKey, proxyID)
	listenAddr := status.ListenAddr

    // Generate some traffic
    for i := 0; i < 5; i++ {
         testConnectionData(t, listenAddr, "METRICS_BACKEND")
    }

	// Start streaming metrics
	t.Log("=== Starting metrics stream ===")
	streamCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	// Generate test viewer keypair for E2E encryption
	viewerPub, viewerPriv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatalf("Failed to generate viewer key: %v", err)
	}

	stream, err := client.StreamMetrics(streamCtx, &pb.StreamMetricsRequest{
		ViewerPubkey:    viewerPub,
        IntervalSeconds: 1,
	})
	if err != nil {
		t.Fatalf("StreamMetrics failed: %v", err)
	}

	// Channel to receive decrypted metrics
	metricsCh := make(chan *pb.MetricsSample, 10)
	go func() {
		for {
			encPayload, err := stream.Recv()
			if err != nil {
				close(metricsCh)
				return
			}
			// Decrypt the payload
			enc := encPayload.GetEncrypted()
			if enc == nil {
				continue
			}
			cryptoPayload := &nitellacrypto.EncryptedPayload{
				EphemeralPubKey:   enc.EphemeralPubkey,
				Nonce:             enc.Nonce,
				Ciphertext:        enc.Ciphertext,
				SenderFingerprint: enc.SenderFingerprint,
				Signature:         enc.Signature,
			}
			// Verify signature with node's public key
			if len(cryptoPayload.Signature) > 0 && nodePubKey != nil {
				if err := nitellacrypto.VerifySignature(cryptoPayload, nodePubKey); err != nil {
					t.Errorf("Metrics signature verification failed: %v", err)
					continue
				}
			}
			plaintext, err := nitellacrypto.Decrypt(cryptoPayload, viewerPriv)
			if err != nil {
				continue
			}
			var stats pb.MetricsSample
			if err := proto.Unmarshal(plaintext, &stats); err != nil {
				continue
			}
			metricsCh <- &stats
		}
	}()

	// Wait for metrics
	timeout := time.After(4 * time.Second)
	select {
	case stats, ok := <-metricsCh:
		if !ok {
			t.Fatal("Stream closed unexpectedly")
		}
		t.Logf("Received metrics: TotalConns=%d, ActiveConns=%d", stats.TotalConns, stats.ActiveConns)
		if stats.TotalConns < 5 {
			t.Errorf("Expected TotalConns >= 5, got %d", stats.TotalConns)
		}
	case <-timeout:
		t.Fatal("Timeout waiting for metrics")
	}

	t.Log("=== Stream Metrics Test Passed ===")
}
