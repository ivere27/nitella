package main

import (
	"bytes"
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/sha256"
	"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/pem"
	"fmt"
	"math/big"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	hubpb "github.com/ivere27/nitella/pkg/api/hub"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/ivere27/nitella/pkg/hub/auth"
	"github.com/ivere27/nitella/pkg/hub/certmanager"
	"github.com/ivere27/nitella/pkg/hub/model"
	hubserver "github.com/ivere27/nitella/pkg/hub/server"
	hubstore "github.com/ivere27/nitella/pkg/hub/store"
	"github.com/ivere27/nitella/pkg/p2p"
	"github.com/ivere27/nitella/pkg/pairing"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/proto"
)

func TestRustHubPAKEPairingSmoke(t *testing.T) {
	rustBin := os.Getenv("NITELLA_RS_BIN")
	if rustBin == "" {
		t.Skip("set NITELLA_RS_BIN to run the Rust hub PAKE pairing smoke")
	}

	tmpDir := t.TempDir()
	hubCAPEM, hubCACert, hubCAKey := rustHubSmokeCA(t, "nitella hub smoke ca")
	hubCertPEM, hubKeyPEM := rustHubSmokeServerCert(t, hubCACert, hubCAKey)
	hubCert, err := tls.X509KeyPair(hubCertPEM, hubKeyPEM)
	if err != nil {
		t.Fatalf("load hub TLS cert: %v", err)
	}

	grpcServer := grpc.NewServer(grpc.Creds(credentials.NewTLS(&tls.Config{
		Certificates: []tls.Certificate{hubCert},
		MinVersion:   tls.VersionTLS13,
	})))
	hubpb.RegisterPairingServiceServer(grpcServer, hubserver.NewPairingServer(nil))

	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("listen: %v", err)
	}
	t.Cleanup(func() {
		grpcServer.Stop()
		_ = listener.Close()
	})
	go func() {
		_ = grpcServer.Serve(listener)
	}()

	hubCAPath := filepath.Join(tmpDir, "hub_ca.crt")
	if err := os.WriteFile(hubCAPath, hubCAPEM, 0644); err != nil {
		t.Fatalf("write hub CA: %v", err)
	}

	pairingCode, err := pairing.GeneratePairingCode()
	if err != nil {
		t.Fatalf("generate pairing code: %v", err)
	}

	nodeDataDir := filepath.Join(tmpDir, "node")
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()

	var rustLog bytes.Buffer
	cmd := exec.CommandContext(ctx, rustBin,
		"--hub", listener.Addr().String(),
		"--hub-ca", hubCAPath,
		"--hub-data-dir", nodeDataDir,
		"--hub-node-name", "rust-hub-smoke",
		"--pair", pairingCode,
		"--db-path", filepath.Join(tmpDir, "nitella.db"),
		"--stats-db", filepath.Join(tmpDir, "stats.db"),
		"--geoip-cache", filepath.Join(tmpDir, "geoip_cache.db"),
	)
	cmd.Stdout = &rustLog
	cmd.Stderr = &rustLog
	if err := cmd.Start(); err != nil {
		t.Fatalf("start nitellad-rs: %v", err)
	}

	rustDone := make(chan error, 1)
	go func() {
		rustDone <- cmd.Wait()
	}()
	t.Cleanup(func() {
		stopRustHubSmokeProcess(cmd, rustDone)
	})

	roots := x509.NewCertPool()
	if !roots.AppendCertsFromPEM(hubCAPEM) {
		t.Fatalf("append hub CA")
	}
	conn, err := grpc.NewClient(listener.Addr().String(), grpc.WithTransportCredentials(credentials.NewTLS(&tls.Config{
		RootCAs:    roots,
		ServerName: "localhost",
		MinVersion: tls.VersionTLS13,
	})))
	if err != nil {
		t.Fatalf("dial pairing hub: %v", err)
	}
	defer conn.Close()

	exchangeCh := make(chan struct {
		result *pairing.ExchangeResult
		err    error
	}, 1)
	go func() {
		result, err := pairing.RunExchange(ctx, hubpb.NewPairingServiceClient(conn), pairingCode)
		exchangeCh <- struct {
			result *pairing.ExchangeResult
			err    error
		}{result: result, err: err}
	}()

	var exchange *pairing.ExchangeResult
	select {
	case got := <-exchangeCh:
		if got.err != nil {
			t.Fatalf("Go PAKE exchange with nitellad-rs failed: %v\nnitellad-rs log:\n%s", got.err, rustLog.String())
		}
		exchange = got.result
	case err := <-rustDone:
		t.Fatalf("nitellad-rs exited before PAKE exchange completed: %v\nnitellad-rs log:\n%s", err, rustLog.String())
	case <-ctx.Done():
		t.Fatalf("timed out waiting for PAKE exchange\nnitellad-rs log:\n%s", rustLog.String())
	}

	if exchange.NodeID != "rust-hub-smoke" {
		t.Fatalf("CSR node id = %q, want rust-hub-smoke", exchange.NodeID)
	}

	cliCAPEM, cliCACert, cliCAKey := rustHubSmokeCA(t, "nitella cli smoke ca")
	completion, err := pairing.CompleteExchange(ctx, &pairing.CompletionParams{
		ExchangeResult: exchange,
		RootCertPEM:    cliCAPEM,
		RootKey:        cliCAKey,
		ValidDays:      365,
	})
	if err != nil {
		t.Fatalf("complete Go PAKE exchange: %v\nnitellad-rs log:\n%s", err, rustLog.String())
	}
	if completion.NodeID != "rust-hub-smoke" {
		t.Fatalf("completion node id = %q, want rust-hub-smoke", completion.NodeID)
	}

	nodeCertPEM := waitForRustHubSmokeFile(t, filepath.Join(nodeDataDir, "node.crt"), rustLog.String)
	nodeID := strings.TrimSpace(string(waitForRustHubSmokeFile(t, filepath.Join(nodeDataDir, "node_id"), rustLog.String)))
	if nodeID != "rust-hub-smoke" {
		t.Fatalf("saved node_id = %q, want rust-hub-smoke", nodeID)
	}
	savedCAPEM := waitForRustHubSmokeFile(t, filepath.Join(nodeDataDir, "cli_ca.crt"), rustLog.String)
	if !bytes.Equal(bytes.TrimSpace(savedCAPEM), bytes.TrimSpace(cliCAPEM)) {
		t.Fatalf("saved cli_ca.crt does not match Go signing CA")
	}
	if len(bytes.TrimSpace(waitForRustHubSmokeFile(t, filepath.Join(nodeDataDir, "node.key"), rustLog.String))) == 0 {
		t.Fatalf("saved node.key is empty")
	}

	nodeCert := parseRustHubSmokeCert(t, nodeCertPEM)
	if nodeCert.Subject.CommonName != "rust-hub-smoke" {
		t.Fatalf("saved node cert CN = %q, want rust-hub-smoke", nodeCert.Subject.CommonName)
	}
	verifyRoots := x509.NewCertPool()
	verifyRoots.AddCert(cliCACert)
	if _, err := nodeCert.Verify(x509.VerifyOptions{
		Roots:       verifyRoots,
		CurrentTime: time.Now(),
		KeyUsages:   []x509.ExtKeyUsage{x509.ExtKeyUsageClientAuth},
	}); err != nil {
		t.Fatalf("saved node cert was not signed by Go CLI CA: %v", err)
	}
}

func TestRustHubRuntimeSmoke(t *testing.T) {
	rustBin := os.Getenv("NITELLA_RS_BIN")
	if rustBin == "" {
		t.Skip("set NITELLA_RS_BIN to run the Rust hub runtime smoke")
	}

	tmpDir := t.TempDir()
	hub := startRustHubRuntimeServer(t, tmpDir)
	defer hub.cleanup()

	hubCAPath := filepath.Join(tmpDir, "hub_ca.crt")
	if err := os.WriteFile(hubCAPath, hub.caPEM, 0644); err != nil {
		t.Fatalf("write hub CA: %v", err)
	}

	pairingCode, err := pairing.GeneratePairingCode()
	if err != nil {
		t.Fatalf("generate pairing code: %v", err)
	}

	nodeDataDir := filepath.Join(tmpDir, "node")
	ctx, cancel := context.WithTimeout(context.Background(), 25*time.Second)
	defer cancel()

	var rustLog bytes.Buffer
	cmd := exec.CommandContext(ctx, rustBin,
		"--hub", hub.addr,
		"--hub-ca", hubCAPath,
		"--hub-data-dir", nodeDataDir,
		"--hub-node-name", "rust-hub-runtime",
		"--hub-p2p",
		"--stun", "stun:127.0.0.1:9",
		"--pair", pairingCode,
		"--db-path", filepath.Join(tmpDir, "nitella.db"),
		"--stats-db", filepath.Join(tmpDir, "stats.db"),
		"--geoip-cache", filepath.Join(tmpDir, "geoip_cache.db"),
	)
	cmd.Stdout = &rustLog
	cmd.Stderr = &rustLog
	if err := cmd.Start(); err != nil {
		t.Fatalf("start nitellad-rs: %v", err)
	}

	rustDone := make(chan error, 1)
	go func() {
		rustDone <- cmd.Wait()
	}()
	t.Cleanup(func() {
		stopRustHubSmokeProcess(cmd, rustDone)
	})

	conn := hub.dial(t)
	defer conn.Close()

	exchangeCh := make(chan struct {
		result *pairing.ExchangeResult
		err    error
	}, 1)
	go func() {
		result, err := pairing.RunExchange(ctx, hubpb.NewPairingServiceClient(conn), pairingCode)
		exchangeCh <- struct {
			result *pairing.ExchangeResult
			err    error
		}{result: result, err: err}
	}()

	var exchange *pairing.ExchangeResult
	select {
	case got := <-exchangeCh:
		if got.err != nil {
			t.Fatalf("Go PAKE exchange with nitellad-rs failed: %v\nnitellad-rs log:\n%s", got.err, rustLog.String())
		}
		exchange = got.result
	case err := <-rustDone:
		t.Fatalf("nitellad-rs exited before PAKE exchange completed: %v\nnitellad-rs log:\n%s", err, rustLog.String())
	case <-ctx.Done():
		t.Fatalf("timed out waiting for PAKE exchange\nnitellad-rs log:\n%s", rustLog.String())
	}

	if exchange.NodeID != "rust-hub-runtime" {
		t.Fatalf("CSR node id = %q, want rust-hub-runtime", exchange.NodeID)
	}

	cliCAPEM, _, cliCAKey := rustHubSmokeCA(t, "nitella cli runtime ca")
	mobileCtx := metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+hub.mobileToken)
	completion, err := pairing.CompleteExchange(mobileCtx, &pairing.CompletionParams{
		ExchangeResult: exchange,
		RootCertPEM:    cliCAPEM,
		RootKey:        cliCAKey,
		UserSecret:     cliCAKey,
		MobileClient:   hubpb.NewMobileServiceClient(conn),
		ValidDays:      365,
	})
	if err != nil {
		t.Fatalf("complete and register Go PAKE exchange: %v\nnitellad-rs log:\n%s", err, rustLog.String())
	}
	if completion.RoutingToken == "" {
		t.Fatalf("completion returned empty routing token")
	}

	waitForRustHubSmokeFile(t, filepath.Join(nodeDataDir, "node.crt"), rustLog.String)
	waitForRustHubSmokeFile(t, filepath.Join(nodeDataDir, "node.key"), rustLog.String)
	waitForRustHubSmokeFile(t, filepath.Join(nodeDataDir, "cli_ca.crt"), rustLog.String)

	waitForRustHubNodeOnline(t, hub.store, completion.NodeID, rustLog.String)

	result := waitForRustHubCommand(t, ctx, conn, completion.NodeID, completion.RoutingToken, completion.NodePublicKey, cliCAKey, hub.mobileToken, rustLog.String)
	if result.Status != "OK" {
		t.Fatalf("Hub command result status=%q error=%q\nnitellad-rs log:\n%s", result.Status, result.ErrorMessage, rustLog.String())
	}

	p2pResult := waitForRustHubP2PCommand(t, ctx, conn, completion.NodeID, cliCAKey, cliCAPEM, hub.mobileToken, rustLog.String)
	if p2pResult.Status != "OK" {
		t.Fatalf("P2P command result status=%q error=%q\nnitellad-rs log:\n%s", p2pResult.Status, p2pResult.ErrorMessage, rustLog.String())
	}
	var p2pGeoStatus pbProxy.GetGeoIPStatusResponse
	if err := proto.Unmarshal(p2pResult.ResponsePayload, &p2pGeoStatus); err != nil {
		t.Fatalf("unmarshal P2P GeoIP status response: %v\nnitellad-rs log:\n%s", err, rustLog.String())
	}
	if !p2pGeoStatus.Enabled || p2pGeoStatus.Mode == "" {
		t.Fatalf("P2P GeoIP status response missing fields: %#v\nnitellad-rs log:\n%s", &p2pGeoStatus, rustLog.String())
	}
}

type rustHubRuntimeServer struct {
	addr        string
	caPEM       []byte
	store       hubstore.Store
	mobileToken string
	cleanup     func()
}

func startRustHubRuntimeServer(t *testing.T, tmpDir string) *rustHubRuntimeServer {
	t.Helper()

	dbPath := filepath.Join(tmpDir, "hub.db")
	testStore, err := hubstore.NewStore("sqlite3", dbPath)
	if err != nil {
		t.Fatalf("create hub store: %v", err)
	}

	privKeyPEM := rustHubSmokeJWTKeyPEM(t)
	tokenManager, err := auth.NewTokenManager(privKeyPEM, nil, "rust-hub-runtime")
	if err != nil {
		testStore.Close()
		t.Fatalf("create token manager: %v", err)
	}

	if err := testStore.SaveUser(&model.User{
		ID:               "runtime-user",
		BlindIndex:       "runtime-user-blind-index",
		EncryptedProfile: []byte("runtime-user-profile"),
		Role:             "user",
		Tier:             "free",
	}); err != nil {
		testStore.Close()
		t.Fatalf("save runtime user: %v", err)
	}

	certMgr, err := certmanager.New(certmanager.DefaultConfig(filepath.Join(tmpDir, "hub-certs")))
	if err != nil {
		testStore.Close()
		t.Fatalf("create cert manager: %v", err)
	}
	certMgr.Start(context.Background())

	hubServer := hubserver.NewHubServer(tokenManager, tokenManager, testStore, nil, nil)
	hubServer.SetCertManager(certMgr)

	grpcServer := grpc.NewServer(
		grpc.Creds(credentials.NewTLS(certMgr.GetTLSConfig())),
		grpc.ChainUnaryInterceptor(hubServer.AuthInterceptor),
		grpc.ChainStreamInterceptor(hubServer.StreamAuthInterceptor),
	)
	hubServer.RegisterPublicServices(grpcServer)

	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		certMgr.Stop()
		testStore.Close()
		t.Fatalf("listen hub runtime: %v", err)
	}
	go func() {
		_ = grpcServer.Serve(listener)
	}()

	caPEM, err := certMgr.GetCACertPEM()
	if err != nil {
		grpcServer.Stop()
		certMgr.Stop()
		testStore.Close()
		t.Fatalf("read hub CA PEM: %v", err)
	}
	token, err := tokenManager.GenerateMobileToken("runtime-user", "runtime-device")
	if err != nil {
		grpcServer.Stop()
		certMgr.Stop()
		testStore.Close()
		t.Fatalf("generate mobile token: %v", err)
	}

	return &rustHubRuntimeServer{
		addr:        listener.Addr().String(),
		caPEM:       caPEM,
		store:       testStore,
		mobileToken: token,
		cleanup: func() {
			grpcServer.Stop()
			certMgr.Stop()
			testStore.Close()
			_ = listener.Close()
		},
	}
}

func (s *rustHubRuntimeServer) dial(t *testing.T) *grpc.ClientConn {
	t.Helper()

	roots := x509.NewCertPool()
	if !roots.AppendCertsFromPEM(s.caPEM) {
		t.Fatalf("append hub CA")
	}
	conn, err := grpc.NewClient(s.addr, grpc.WithTransportCredentials(credentials.NewTLS(&tls.Config{
		RootCAs:    roots,
		ServerName: "localhost",
		MinVersion: tls.VersionTLS13,
	})))
	if err != nil {
		t.Fatalf("dial runtime hub: %v", err)
	}
	return conn
}

func waitForRustHubNodeOnline(t *testing.T, store hubstore.Store, nodeID string, logs func() string) {
	t.Helper()

	deadline := time.Now().Add(10 * time.Second)
	var lastStatus string
	var lastErr error
	for time.Now().Before(deadline) {
		node, err := store.GetNode(nodeID)
		if err == nil {
			lastStatus = node.Status
			if node.Status == "online" {
				return
			}
		} else {
			lastErr = err
		}
		time.Sleep(100 * time.Millisecond)
	}
	t.Fatalf("timed out waiting for Rust node %s to become online; last status=%q err=%v\nnitellad-rs log:\n%s", nodeID, lastStatus, lastErr, logs())
}

func waitForRustHubCommand(t *testing.T, ctx context.Context, conn *grpc.ClientConn, nodeID, routingToken string, nodePub ed25519.PublicKey, cliPriv ed25519.PrivateKey, mobileToken string, logs func() string) *hubpb.CommandResult {
	t.Helper()

	client := hubpb.NewMobileServiceClient(conn)
	deadline := time.Now().Add(10 * time.Second)
	var lastErr error
	for time.Now().Before(deadline) {
		req := &hubpb.CommandRequest{
			NodeId:       nodeID,
			RoutingToken: routingToken,
			Encrypted:    buildRustHubSmokeEncryptedCommand(t, hubpb.CommandType_COMMAND_TYPE_STATUS, nil, nodePub, cliPriv),
		}
		resp, err := client.SendCommand(metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+mobileToken), req)
		if err == nil {
			return decryptRustHubSmokeCommandResponse(t, resp, nodePub, cliPriv)
		}
		lastErr = err
		if code := status.Code(err); code == codes.Unavailable || code == codes.DeadlineExceeded {
			time.Sleep(200 * time.Millisecond)
			continue
		}
		t.Fatalf("Hub SendCommand failed: %v\nnitellad-rs log:\n%s", err, logs())
	}
	t.Fatalf("timed out waiting for Hub command response: %v\nnitellad-rs log:\n%s", lastErr, logs())
	return nil
}

func waitForRustHubP2PCommand(t *testing.T, ctx context.Context, conn *grpc.ClientConn, nodeID string, cliPriv ed25519.PrivateKey, cliCAPEM []byte, mobileToken string, logs func() string) *hubpb.CommandResult {
	t.Helper()

	transport := p2p.NewTransport("runtime-user", hubpb.NewMobileServiceClient(conn))
	transport.SetSTUNServer("stun:127.0.0.1:9")
	transport.SetIdentity(cliPriv)
	if err := transport.SetCertificates(cliCAPEM, cliCAPEM); err != nil {
		t.Fatalf("configure P2P certificates: %v", err)
	}
	t.Cleanup(func() {
		_ = transport.Close()
	})

	streamCtx := metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+mobileToken)
	if err := transport.StartSignaling(streamCtx); err != nil {
		t.Fatalf("start P2P signaling: %v\nnitellad-rs log:\n%s", err, logs())
	}
	if err := transport.Connect(nodeID); err != nil {
		t.Fatalf("connect P2P to Rust node: %v\nnitellad-rs log:\n%s", err, logs())
	}

	deadline := time.Now().Add(15 * time.Second)
	for time.Now().Before(deadline) {
		if _, ok := transport.GetNodeKey(nodeID); ok {
			break
		}
		time.Sleep(100 * time.Millisecond)
	}
	if _, ok := transport.GetNodeKey(nodeID); !ok {
		t.Fatalf("P2P auth did not register Rust node key\nnitellad-rs log:\n%s", logs())
	}

	requestID := fmt.Sprintf("rust-hub-p2p-%d", time.Now().UnixNano())
	msg, err := p2p.NewP2PMessageWithRequestID(p2p.MessageTypeCommand, requestID, &p2p.P2PCommandPayload{
		CommandType: int32(hubpb.CommandType_COMMAND_TYPE_GET_GEOIP_STATUS),
		Data:        buildRustHubSmokeSecureCommand(t, hubpb.CommandType_COMMAND_TYPE_GET_GEOIP_STATUS, nil),
	})
	if err != nil {
		t.Fatalf("build P2P command: %v", err)
	}
	respMsg, err := transport.SendCommandAndWait(nodeID, msg, 10*time.Second)
	if err != nil {
		t.Fatalf("send P2P command to Rust node: %v\nnitellad-rs log:\n%s", err, logs())
	}
	cmdResp, err := respMsg.ParseCommandResponse()
	if err != nil {
		t.Fatalf("parse P2P command response: %v", err)
	}
	return &hubpb.CommandResult{
		Status:          cmdResp.Status,
		ErrorMessage:    cmdResp.Error,
		ResponsePayload: cmdResp.Data,
	}
}

func buildRustHubSmokeSecureCommand(t *testing.T, cmdType hubpb.CommandType, payload []byte) []byte {
	t.Helper()

	inner := &hubpb.EncryptedCommandPayload{
		Type:    cmdType,
		Payload: payload,
	}
	innerBytes, err := proto.Marshal(inner)
	if err != nil {
		t.Fatalf("marshal P2P command payload: %v", err)
	}
	secure := &common.SecureCommandPayload{
		RequestId: fmt.Sprintf("rust-hub-p2p-secure-%d", time.Now().UnixNano()),
		Timestamp: time.Now().Unix(),
		Data:      innerBytes,
	}
	secureBytes, err := proto.Marshal(secure)
	if err != nil {
		t.Fatalf("marshal P2P secure payload: %v", err)
	}
	return secureBytes
}

func buildRustHubSmokeEncryptedCommand(t *testing.T, cmdType hubpb.CommandType, payload []byte, nodePub ed25519.PublicKey, cliPriv ed25519.PrivateKey) *common.EncryptedPayload {
	t.Helper()

	inner := &hubpb.EncryptedCommandPayload{
		Type:    cmdType,
		Payload: payload,
	}
	innerBytes, err := proto.Marshal(inner)
	if err != nil {
		t.Fatalf("marshal command payload: %v", err)
	}
	secure := &common.SecureCommandPayload{
		RequestId: fmt.Sprintf("rust-hub-runtime-%d", time.Now().UnixNano()),
		Timestamp: time.Now().Unix(),
		Data:      innerBytes,
	}
	secureBytes, err := proto.Marshal(secure)
	if err != nil {
		t.Fatalf("marshal secure command payload: %v", err)
	}
	pub := cliPriv.Public().(ed25519.PublicKey)
	fp := sha256.Sum256(pub)
	encrypted, err := nitellacrypto.EncryptWithSignature(secureBytes, nodePub, cliPriv, fmt.Sprintf("%x", fp[:]))
	if err != nil {
		t.Fatalf("encrypt command payload: %v", err)
	}
	return &common.EncryptedPayload{
		EphemeralPubkey:   encrypted.EphemeralPubKey,
		Nonce:             encrypted.Nonce,
		Ciphertext:        encrypted.Ciphertext,
		SenderFingerprint: encrypted.SenderFingerprint,
		Signature:         encrypted.Signature,
	}
}

func decryptRustHubSmokeCommandResponse(t *testing.T, resp *hubpb.CommandResponse, nodePub ed25519.PublicKey, cliPriv ed25519.PrivateKey) *hubpb.CommandResult {
	t.Helper()

	if resp == nil || resp.GetEncryptedData() == nil {
		t.Fatalf("Hub returned empty command response")
	}
	encrypted := &nitellacrypto.EncryptedPayload{
		EphemeralPubKey:   resp.EncryptedData.EphemeralPubkey,
		Nonce:             resp.EncryptedData.Nonce,
		Ciphertext:        resp.EncryptedData.Ciphertext,
		SenderFingerprint: resp.EncryptedData.SenderFingerprint,
		Signature:         resp.EncryptedData.Signature,
	}
	if err := nitellacrypto.VerifySignature(encrypted, nodePub); err != nil {
		t.Fatalf("verify Rust command response signature: %v", err)
	}
	plain, err := nitellacrypto.Decrypt(encrypted, cliPriv)
	if err != nil {
		t.Fatalf("decrypt Rust command response: %v", err)
	}
	var result hubpb.CommandResult
	if err := proto.Unmarshal(plain, &result); err != nil {
		t.Fatalf("unmarshal Rust command response: %v", err)
	}
	return &result
}

func rustHubSmokeJWTKeyPEM(t *testing.T) []byte {
	t.Helper()

	_, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatalf("generate JWT key: %v", err)
	}
	keyDER, err := x509.MarshalPKCS8PrivateKey(priv)
	if err != nil {
		t.Fatalf("marshal JWT key: %v", err)
	}
	return pem.EncodeToMemory(&pem.Block{Type: "PRIVATE KEY", Bytes: keyDER})
}

func rustHubSmokeCA(t *testing.T, commonName string) ([]byte, *x509.Certificate, ed25519.PrivateKey) {
	t.Helper()

	pub, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatalf("generate CA key: %v", err)
	}
	serial, err := rand.Int(rand.Reader, new(big.Int).Lsh(big.NewInt(1), 128))
	if err != nil {
		t.Fatalf("generate CA serial: %v", err)
	}
	tmpl := &x509.Certificate{
		SerialNumber: serial,
		Subject: pkix.Name{
			CommonName: commonName,
		},
		NotBefore:             time.Now().Add(-time.Minute),
		NotAfter:              time.Now().Add(24 * time.Hour),
		KeyUsage:              x509.KeyUsageCertSign | x509.KeyUsageDigitalSignature,
		BasicConstraintsValid: true,
		IsCA:                  true,
	}
	der, err := x509.CreateCertificate(rand.Reader, tmpl, tmpl, pub, priv)
	if err != nil {
		t.Fatalf("create CA cert: %v", err)
	}
	cert, err := x509.ParseCertificate(der)
	if err != nil {
		t.Fatalf("parse CA cert: %v", err)
	}
	return pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: der}), cert, priv
}

func rustHubSmokeServerCert(t *testing.T, caCert *x509.Certificate, caKey ed25519.PrivateKey) ([]byte, []byte) {
	t.Helper()

	pub, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatalf("generate server key: %v", err)
	}
	serial, err := rand.Int(rand.Reader, new(big.Int).Lsh(big.NewInt(1), 128))
	if err != nil {
		t.Fatalf("generate server serial: %v", err)
	}
	tmpl := &x509.Certificate{
		SerialNumber: serial,
		Subject: pkix.Name{
			CommonName: "localhost",
		},
		NotBefore:             time.Now().Add(-time.Minute),
		NotAfter:              time.Now().Add(time.Hour),
		KeyUsage:              x509.KeyUsageDigitalSignature,
		ExtKeyUsage:           []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth},
		BasicConstraintsValid: true,
		DNSNames:              []string{"localhost"},
		IPAddresses:           []net.IP{net.ParseIP("127.0.0.1")},
	}
	der, err := x509.CreateCertificate(rand.Reader, tmpl, caCert, pub, caKey)
	if err != nil {
		t.Fatalf("create server cert: %v", err)
	}
	keyDER, err := x509.MarshalPKCS8PrivateKey(priv)
	if err != nil {
		t.Fatalf("marshal server key: %v", err)
	}
	return pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: der}),
		pem.EncodeToMemory(&pem.Block{Type: "PRIVATE KEY", Bytes: keyDER})
}

func waitForRustHubSmokeFile(t *testing.T, path string, logs func() string) []byte {
	t.Helper()

	deadline := time.Now().Add(5 * time.Second)
	var lastErr error
	for time.Now().Before(deadline) {
		data, err := os.ReadFile(path)
		if err == nil && len(bytes.TrimSpace(data)) > 0 {
			return data
		}
		lastErr = err
		time.Sleep(50 * time.Millisecond)
	}
	t.Fatalf("timed out waiting for %s: %v\nnitellad-rs log:\n%s", path, lastErr, logs())
	return nil
}

func parseRustHubSmokeCert(t *testing.T, certPEM []byte) *x509.Certificate {
	t.Helper()

	block, _ := pem.Decode(certPEM)
	if block == nil {
		t.Fatalf("failed to decode cert PEM")
	}
	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		t.Fatalf("parse cert: %v", err)
	}
	return cert
}

func stopRustHubSmokeProcess(cmd *exec.Cmd, done <-chan error) {
	if cmd.Process == nil {
		return
	}
	if cmd.ProcessState != nil {
		return
	}
	select {
	case <-done:
		return
	default:
	}
	_ = cmd.Process.Signal(os.Interrupt)
	select {
	case <-done:
		return
	case <-time.After(time.Second):
		_ = cmd.Process.Kill()
	}
	select {
	case <-done:
	case <-time.After(time.Second):
		fmt.Fprintln(os.Stderr, "timed out waiting for nitellad-rs process to stop")
	}
}
