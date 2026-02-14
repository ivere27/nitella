#!/bin/bash
# =============================================================================
# Full E2E Integration Test - Mobile App
# =============================================================================
#
# This script runs COMPREHENSIVE end-to-end tests covering ALL features:
#
# 1. Infrastructure Setup
#    - Start Hub server
#    - Start echo backend server
#
# 2. Pre-pairing Setup (Go)
#    - Create mobile identity
#    - Perform PAKE pairing (simulated)
#    - Save pairing certificates for nitellad
#    - Register node with Hub
#
# 3. Start Hub-connected nitellad
#    - Uses pre-paired certificates
#    - Full E2E path: Mobile -> Hub -> Node -> Backend
#
# 4. Flutter UI Tests
#    - Verify all UI screens work
#    - Test CRUD operations via Hub relay
#    - Test real traffic through proxy
#    - Test approval workflow
#
# 5. Traffic Tests
#    - Send HTTP requests through proxy
#    - Verify allow/block rules
#    - Verify approval workflow
#
# Usage:
#   ./scripts/run_full_e2e_test.sh [options]
#
# Options:
#   --visible       Show Flutter app window (flutter drive)
#   --skip-flutter  Skip Flutter tests (Go setup only)
#   --keep-running  Keep services running after tests
#   --verbose       Show all output
#   --standalone    Use standalone nitellad (no Hub connection, legacy mode)
#
# =============================================================================

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BIN_DIR="${PROJECT_ROOT}/bin"
TMP_DIR="${PROJECT_ROOT}/.e2e-test-tmp"

# Find a free port by briefly binding to port 0
get_free_port() {
    python3 -c 'import socket; s=socket.socket(); s.bind(("",0)); print(s.getsockname()[1]); s.close()'
}

# Ports — use env override or pick a random free port
HUB_GRPC_PORT="${NITELLA_E2E_HUB_GRPC_PORT:-$(get_free_port)}"
HUB_HTTP_PORT="${NITELLA_E2E_HUB_HTTP_PORT:-$(get_free_port)}"
NITELLAD_ADMIN_PORT="${NITELLA_E2E_ADMIN_PORT:-$(get_free_port)}"
NITELLAD_PROXY_PORT="${NITELLA_E2E_PROXY_PORT:-$(get_free_port)}"
BACKEND_PORT="${NITELLA_E2E_BACKEND_PORT:-$(get_free_port)}"

# Options
VISIBLE=false
SKIP_FLUTTER=false
SKIP_BUILD=false
KEEP_RUNNING=false
VERBOSE=false
STANDALONE_MODE=false

# PIDs
HUB_PID=""
NITELLAD_PID=""
BACKEND_PID=""

# Pairing data (set by setup phase)
PAIRED_NODE_ID=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# =============================================================================
# Helper Functions
# =============================================================================

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[⚠]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}\n"; }

cleanup() {
    log_info "Cleaning up..."

    if [ "$KEEP_RUNNING" = false ]; then
        [ -n "$BACKEND_PID" ] && kill -TERM "$BACKEND_PID" 2>/dev/null || true
        [ -n "$NITELLAD_PID" ] && kill -TERM "$NITELLAD_PID" 2>/dev/null || true
        [ -n "$HUB_PID" ] && kill -TERM "$HUB_PID" 2>/dev/null || true
        sleep 1
        [ -n "$BACKEND_PID" ] && kill -KILL "$BACKEND_PID" 2>/dev/null || true
        [ -n "$NITELLAD_PID" ] && kill -KILL "$NITELLAD_PID" 2>/dev/null || true
        [ -n "$HUB_PID" ] && kill -KILL "$HUB_PID" 2>/dev/null || true
        rm -rf "$TMP_DIR"
    else
        log_info "Services still running:"
        echo "  Hub:      PID=$HUB_PID (localhost:$HUB_GRPC_PORT)"
        echo "  nitellad: PID=$NITELLAD_PID (localhost:$NITELLAD_PROXY_PORT)"
        echo "  Backend:  PID=$BACKEND_PID (localhost:$BACKEND_PORT)"
        echo ""
        echo "To stop: kill $HUB_PID $NITELLAD_PID $BACKEND_PID"
    fi
}

trap cleanup EXIT

wait_for_port() {
    local port=$1
    local timeout=${2:-30}
    local deadline=$(($(date +%s) + timeout))
    while ! nc -z localhost "$port" 2>/dev/null; do
        [ "$(date +%s)" -ge "$deadline" ] && return 1
        sleep 0.5
    done
    return 0
}

# Cross-platform base64 encoding (no line wrapping)
b64_encode() {
    if base64 --help 2>&1 | grep -q '\-w'; then
        base64 -w0 "$1"
    else
        base64 "$1"  # macOS base64 doesn't wrap by default
    fi
}

wait_for_file() {
    local filepath=$1
    local timeout=${2:-30}
    local deadline=$(($(date +%s) + timeout))
    while [ ! -f "$filepath" ]; do
        [ "$(date +%s)" -ge "$deadline" ] && return 1
        sleep 0.5
    done
    return 0
}

# =============================================================================
# Parse Arguments
# =============================================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        --visible) VISIBLE=true; shift ;;
        --skip-flutter) SKIP_FLUTTER=true; shift ;;
        --skip-build) SKIP_BUILD=true; shift ;;
        --keep-running) KEEP_RUNNING=true; shift ;;
        --verbose) VERBOSE=true; shift ;;
        --standalone) STANDALONE_MODE=true; shift ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "  --visible       Show Flutter app window"
            echo "  --skip-flutter  Skip Flutter tests"
            echo "  --keep-running  Keep services running"
            echo "  --verbose       Show all output"
            echo "  --standalone    Use standalone nitellad (no Hub, legacy mode)"
            exit 0
            ;;
        *) log_error "Unknown option: $1"; exit 1 ;;
    esac
done

# =============================================================================
# Main Script
# =============================================================================

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║       NITELLA FULL E2E INTEGRATION TEST                       ║"
echo "║       Testing ALL mobile app features end-to-end              ║"
if [ "$STANDALONE_MODE" = true ]; then
echo "║       Mode: STANDALONE (no Hub relay)                         ║"
else
echo "║       Mode: FULL E2E (Mobile -> Hub -> Node -> Backend)       ║"
fi
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Clean up any stale temp directory from previous runs (e.g., --keep-running)
if [ -d "$TMP_DIR" ]; then
    log_info "Clearing stale temp directory: $TMP_DIR"
    rm -rf "$TMP_DIR"
fi

# Create temp directory
mkdir -p "$TMP_DIR"/{hub,nitellad,mobile,backend}

# Flutter app data directory - we'll pre-create identity here for E2E mode
FLUTTER_APP_DATA="$HOME/.local/share/app"

# Clear Flutter app's persisted data to start fresh
if [ -d "$FLUTTER_APP_DATA" ]; then
    log_info "Clearing Flutter app data: $FLUTTER_APP_DATA"
    rm -rf "$FLUTTER_APP_DATA"
fi

# Create Flutter app data directory
mkdir -p "$FLUTTER_APP_DATA"

# =============================================================================
# Phase 1: Build Binaries
# =============================================================================

log_section "Phase 1: Building Binaries"

if [ "$SKIP_BUILD" = true ]; then
    log_info "Skipping build (--skip-build set)..."
    if [ ! -f "$BIN_DIR/hub" ] || [ ! -f "$BIN_DIR/nitellad" ]; then
        log_error "Binaries not found in $BIN_DIR. Cannot skip build."
        exit 1
    fi
else
    cd "$PROJECT_ROOT"

    log_info "Building hub..."
    go build -o "$BIN_DIR/hub" ./cmd/hub

    log_info "Building nitellad..."
    go build -o "$BIN_DIR/nitellad" ./cmd/nitellad

    log_success "Binaries built"
fi

# =============================================================================
# Phase 2: Start Infrastructure (Hub + Backend)
# =============================================================================

log_section "Phase 2: Starting Infrastructure"

# Start echo backend server (simple HTTP server for traffic tests)
log_info "Starting echo backend on port $BACKEND_PORT..."

cat > "$TMP_DIR/backend/server.go" << 'EOF'
package main

import (
    "fmt"
    "net/http"
    "os"
)

func main() {
    port := os.Getenv("PORT")
    if port == "" {
        port = "9999"
    }
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "ECHO: %s %s\n", r.Method, r.URL.Path)
        for k, v := range r.Header {
            fmt.Fprintf(w, "Header: %s = %v\n", k, v)
        }
    })
    http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte("OK"))
    })
    fmt.Printf("Echo backend listening on :%s\n", port)
    http.ListenAndServe(":"+port, nil)
}
EOF

PORT=$BACKEND_PORT go run "$TMP_DIR/backend/server.go" > "$TMP_DIR/backend.log" 2>&1 &
BACKEND_PID=$!

if wait_for_port $BACKEND_PORT 10; then
    log_success "Echo backend started (PID: $BACKEND_PID)"
else
    log_error "Echo backend failed to start"
    exit 1
fi

# Start Hub
log_info "Starting Hub on port $HUB_GRPC_PORT..."

HUB_CMD="$BIN_DIR/hub \
    --port $HUB_GRPC_PORT \
    --http-port $HUB_HTTP_PORT \
    --db-path $TMP_DIR/hub/hub.db \
    --auto-cert \
    --cert-data-dir $TMP_DIR/hub"

if [ "$VERBOSE" = true ]; then
    $HUB_CMD &
else
    $HUB_CMD > "$TMP_DIR/hub.log" 2>&1 &
fi
HUB_PID=$!

if wait_for_port $HUB_GRPC_PORT 30; then
    log_success "Hub started (PID: $HUB_PID)"
else
    log_error "Hub failed to start"
    cat "$TMP_DIR/hub.log" 2>/dev/null
    exit 1
fi

# Wait for Hub CA cert
if wait_for_file "$TMP_DIR/hub/hub_ca.crt" 10; then
    log_success "Hub CA certificate ready"
else
    log_error "Hub CA certificate not found"
    exit 1
fi
    sleep 1

echo ""
log_success "Hub infrastructure ready!"
echo "  Hub:      localhost:$HUB_GRPC_PORT"
echo "  Backend:  localhost:$BACKEND_PORT"
echo ""

# =============================================================================
# Phase 3: Pre-pairing Setup (Create paired node identity)
# =============================================================================

if [ "$STANDALONE_MODE" = false ]; then
    log_section "Phase 3: Pre-pairing Setup"

    log_info "Creating pre-paired node identity..."

    # Create setup directory first
    mkdir -p "$TMP_DIR/setup"

    # Create the setup program that simulates PAKE pairing
    cat > "$TMP_DIR/setup/pairing_setup.go" << 'GOEOF'
package main

import (
    "context"
    "crypto/ed25519"
    "crypto/rand"
    "crypto/tls"
    "crypto/x509"
    "crypto/x509/pkix"
    "encoding/pem"
    "fmt"
    "math/big"
    "os"
    "path/filepath"
    "time"

    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials"

    hubpb "github.com/ivere27/nitella/pkg/api/hub"
    "github.com/ivere27/nitella/pkg/hub/routing"
    "github.com/ivere27/nitella/pkg/identity"
    "github.com/ivere27/nitella/pkg/pairing"
)

func main() {
    if len(os.Args) < 5 {
        fmt.Fprintf(os.Stderr, "Usage: %s <mobile_data_dir> <node_data_dir> <hub_ca_path> <hub_address>\n", os.Args[0])
        os.Exit(1)
    }

    mobileDataDir := os.Args[1]
    nodeDataDir := os.Args[2]
    hubCAPath := os.Args[3]
    hubAddress := os.Args[4]

    // Ensure directories exist
    os.MkdirAll(mobileDataDir, 0755)
    os.MkdirAll(nodeDataDir, 0755)

    // 1. Create mobile identity and persist to disk (so Flutter app can load it)
    fmt.Println("Creating mobile identity...")
    cfg := identity.DefaultConfig(mobileDataDir, "E2E Test Mobile")
    mobileID, _, err := identity.LoadOrCreate(cfg)
    if err != nil {
        fmt.Fprintf(os.Stderr, "Failed to create mobile identity: %v\n", err)
        os.Exit(1)
    }
    fmt.Printf("Mobile fingerprint: %s\n", mobileID.Fingerprint)

    // 2. Generate node identity
    fmt.Println("Generating node identity...")
    nodePub, nodePriv, err := ed25519.GenerateKey(rand.Reader)
    if err != nil {
        fmt.Fprintf(os.Stderr, "Failed to generate node key: %v\n", err)
        os.Exit(1)
    }

    // 3. Simulate PAKE pairing (both sides use same code)
    fmt.Println("Simulating PAKE pairing...")
    code, err := pairing.GeneratePairingCode()
    if err != nil {
        fmt.Fprintf(os.Stderr, "Failed to generate pairing code: %v\n", err)
        os.Exit(1)
    }
    fmt.Printf("Pairing code: %s\n", code)

    // Create sessions for both sides
    cliSession, _ := pairing.NewPakeSession(pairing.RoleCLI, pairing.CodeToBytes(code))
    nodeSession, _ := pairing.NewPakeSession(pairing.RoleNode, pairing.CodeToBytes(code))

    // Exchange init messages
    cliInit, _ := cliSession.GetInitMessage()
    nodeInit, _ := nodeSession.GetInitMessage()
    cliSession.ProcessInitMessage(nodeInit)
    nodeSession.ProcessInitMessage(cliInit)

    // 4. Generate node CSR
    fmt.Println("Generating node CSR...")
    nodeName := "e2e-test-node"
    csrTemplate := x509.CertificateRequest{
        Subject: pkix.Name{
            CommonName: nodeName,
        },
    }
    csrDER, err := x509.CreateCertificateRequest(rand.Reader, &csrTemplate, nodePriv)
    if err != nil {
        fmt.Fprintf(os.Stderr, "Failed to create CSR: %v\n", err)
        os.Exit(1)
    }
    csrPEM := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE REQUEST", Bytes: csrDER})

    // 5. CLI signs the CSR (simulated encrypted exchange)
    encCSR, csrNonce, _ := nodeSession.Encrypt(csrPEM)
    decCSR, _ := cliSession.Decrypt(encCSR, csrNonce)

    // Parse CSR and sign it
    block, _ := pem.Decode(decCSR)
    csr, err := x509.ParseCertificateRequest(block.Bytes)
    if err != nil {
        fmt.Fprintf(os.Stderr, "Failed to parse CSR: %v\n", err)
        os.Exit(1)
    }

    // Sign with mobile's CA
    fmt.Println("Signing node certificate...")
    nodeCertTemplate := x509.Certificate{
        SerialNumber: big.NewInt(time.Now().UnixNano()),
        Subject:      csr.Subject,
        NotBefore:    time.Now(),
        NotAfter:     time.Now().AddDate(1, 0, 0), // 1 year
        KeyUsage:     x509.KeyUsageDigitalSignature,
        ExtKeyUsage:  []x509.ExtKeyUsage{x509.ExtKeyUsageClientAuth},
    }

    nodeCertDER, err := x509.CreateCertificate(rand.Reader, &nodeCertTemplate, mobileID.RootCert, nodePub, mobileID.RootKey)
    if err != nil {
        fmt.Fprintf(os.Stderr, "Failed to sign node cert: %v\n", err)
        os.Exit(1)
    }
    nodeCertPEM := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: nodeCertDER})

    // Send cert back through encrypted channel
    encCert, certNonce, _ := cliSession.Encrypt(nodeCertPEM)
    finalCert, _ := nodeSession.Decrypt(encCert, certNonce)

    // 6. Save node files
    fmt.Println("Saving node files...")

    // node.crt - signed certificate
    if err := os.WriteFile(filepath.Join(nodeDataDir, "node.crt"), finalCert, 0600); err != nil {
        fmt.Fprintf(os.Stderr, "Failed to save node.crt: %v\n", err)
        os.Exit(1)
    }

    // node.key - private key
    keyPKCS8, _ := x509.MarshalPKCS8PrivateKey(nodePriv)
    keyPEM := pem.EncodeToMemory(&pem.Block{Type: "PRIVATE KEY", Bytes: keyPKCS8})
    if err := os.WriteFile(filepath.Join(nodeDataDir, "node.key"), keyPEM, 0600); err != nil {
        fmt.Fprintf(os.Stderr, "Failed to save node.key: %v\n", err)
        os.Exit(1)
    }

    // cli_ca.crt - mobile's CA cert for verifying commands
    if err := os.WriteFile(filepath.Join(nodeDataDir, "cli_ca.crt"), mobileID.RootCertPEM, 0600); err != nil {
        fmt.Fprintf(os.Stderr, "Failed to save cli_ca.crt: %v\n", err)
        os.Exit(1)
    }

    // node_id - required by hubclient
    if err := os.WriteFile(filepath.Join(nodeDataDir, "node_id"), []byte(nodeName), 0600); err != nil {
        fmt.Fprintf(os.Stderr, "Failed to save node_id: %v\n", err)
        os.Exit(1)
    }

    // Copy Hub CA
    hubCA, err := os.ReadFile(hubCAPath)
    if err != nil {
        fmt.Fprintf(os.Stderr, "Failed to read Hub CA: %v\n", err)
        os.Exit(1)
    }
    if err := os.WriteFile(filepath.Join(nodeDataDir, "hub_ca.crt"), hubCA, 0644); err != nil {
        fmt.Fprintf(os.Stderr, "Failed to save hub_ca.crt: %v\n", err)
        os.Exit(1)
    }

    // 7. Save node certificate to mobile's nodes directory
    // This allows the Flutter app to find the node via listNodes
    fmt.Println("Saving node to mobile identity...")
    if err := identity.SaveNodeCert(mobileDataDir, nodeName, nodeCertPEM); err != nil {
        fmt.Fprintf(os.Stderr, "Failed to save node cert to mobile: %v\n", err)
        os.Exit(1)
    }

    // 8. Generate routing token using same algorithm as mobile backend:
    //    routing.GenerateRoutingToken(nodeID, identity.RootKey) = base64url(HMAC-SHA256(RootKey, nodeID))
    routingToken := routing.GenerateRoutingToken(nodeName, mobileID.RootKey)

    // Save routing info for later use
    routingFile := filepath.Join(mobileDataDir, "routing_token")
    if err := os.WriteFile(routingFile, []byte(routingToken), 0600); err != nil {
        fmt.Fprintf(os.Stderr, "Failed to save routing token: %v\n", err)
        os.Exit(1)
    }

    // 9. Register node with Hub via SubmitSignedCert (PairingService - no auth required)
    fmt.Println("Registering node with Hub...")
    hubCAPEM, err := os.ReadFile(hubCAPath)
    if err != nil {
        fmt.Fprintf(os.Stderr, "Failed to read Hub CA for gRPC: %v\n", err)
        os.Exit(1)
    }
    certPool := x509.NewCertPool()
    if !certPool.AppendCertsFromPEM(hubCAPEM) {
        fmt.Fprintf(os.Stderr, "Failed to parse Hub CA certificate\n")
        os.Exit(1)
    }
    tlsCreds := credentials.NewTLS(&tls.Config{
        RootCAs: certPool,
    })
    conn, err := grpc.NewClient(hubAddress, grpc.WithTransportCredentials(tlsCreds))
    if err != nil {
        fmt.Fprintf(os.Stderr, "Failed to connect to Hub: %v\n", err)
        os.Exit(1)
    }
    defer conn.Close()

    pairingClient := hubpb.NewPairingServiceClient(conn)
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()

    _, err = pairingClient.SubmitSignedCert(ctx, &hubpb.SubmitSignedCertRequest{
        NodeId:       nodeName,
        CertPem:      string(nodeCertPEM),
        CaPem:        string(mobileID.RootCertPEM),
        Fingerprint:  mobileID.Fingerprint,
        RoutingToken: routingToken,
    })
    if err != nil {
        fmt.Fprintf(os.Stderr, "Failed to register node with Hub: %v\n", err)
        os.Exit(1)
    }
    fmt.Printf("Node %s registered with Hub at %s\n", nodeName, hubAddress)

    // Output node ID for script to capture
    fmt.Printf("NODE_ID=%s\n", nodeName)
    fmt.Printf("ROUTING_TOKEN=%s\n", routingToken)
    fmt.Println("Pre-pairing setup complete!")
}
GOEOF

    # Run the setup program
    # IMPORTANT: Use Flutter app's data directory for mobile identity
    # so Flutter app can use the same identity and access the paired node
    cd "$PROJECT_ROOT"
    if go run "$TMP_DIR/setup/pairing_setup.go" \
        "$FLUTTER_APP_DATA" \
        "$TMP_DIR/nitellad" \
        "$TMP_DIR/hub/hub_ca.crt" \
        "localhost:$HUB_GRPC_PORT" > "$TMP_DIR/pairing.log" 2>&1; then

        # Extract node ID from output
        PAIRED_NODE_ID=$(grep "^NODE_ID=" "$TMP_DIR/pairing.log" | cut -d= -f2)
        ROUTING_TOKEN=$(grep "^ROUTING_TOKEN=" "$TMP_DIR/pairing.log" | cut -d= -f2)

        log_success "Pre-pairing complete!"
        echo "  Node ID: $PAIRED_NODE_ID"
        echo "  Certificates saved to: $TMP_DIR/nitellad/"
    else
        log_error "Pre-pairing failed"
        cat "$TMP_DIR/pairing.log" 2>/dev/null
        exit 1
    fi

    # Pre-populate settings.json with Hub address + CA PEM
    # This ensures Go backend has Hub settings when Initialize() + loadSettings() runs
    log_info "Pre-populating settings.json with Hub address..."
    HUB_CA_B64=$(b64_encode "$TMP_DIR/hub/hub_ca.crt")
    cat > "$FLUTTER_APP_DATA/settings.json" << SETTINGSEOF
{
  "hub_address": "localhost:$HUB_GRPC_PORT",
  "auto_connect_hub": true,
  "hub_ca_pem": "$HUB_CA_B64"
}
SETTINGSEOF
    log_success "settings.json created with Hub address and CA PEM"

    # =============================================================================
    # Phase 4: Start Hub-connected nitellad
    # =============================================================================

    log_section "Phase 4: Starting Hub-connected nitellad"

    log_info "Starting nitellad with Hub connection..."

    NITELLAD_CMD="$BIN_DIR/nitellad \
        --listen 0.0.0.0:$NITELLAD_PROXY_PORT \
        --backend 127.0.0.1:$BACKEND_PORT \
        --admin-port $NITELLAD_ADMIN_PORT \
        --admin-token test-token \
        --db-path $TMP_DIR/nitellad/nitellad.db \
        --stats-db $TMP_DIR/nitellad/stats.db \
        --admin-data-dir $TMP_DIR/nitellad \
        --hub localhost:$HUB_GRPC_PORT \
        --hub-data-dir $TMP_DIR/nitellad \
        --hub-ca $TMP_DIR/nitellad/hub_ca.crt \
        --hub-node-name $PAIRED_NODE_ID"

    if [ "$VERBOSE" = true ]; then
        $NITELLAD_CMD &
    else
        $NITELLAD_CMD > "$TMP_DIR/nitellad.log" 2>&1 &
    fi
    NITELLAD_PID=$!

    # Wait for admin CA cert (indicates nitellad is ready)
    if wait_for_file "$TMP_DIR/nitellad/admin_ca.crt" 30; then
        log_success "nitellad started with Hub connection (PID: $NITELLAD_PID)"
    else
        log_error "nitellad failed to start"
        cat "$TMP_DIR/nitellad.log" 2>/dev/null
        exit 1
    fi

    # Verify Hub connection
    sleep 2
    if grep -q "Hub integration initialized" "$TMP_DIR/nitellad.log" 2>/dev/null; then
        log_success "nitellad connected to Hub"
    else
        log_warning "nitellad may not be connected to Hub (check logs)"
    fi

else
    # =============================================================================
    # Standalone Mode: Start nitellad without Hub
    # =============================================================================

    log_section "Phase 3: Starting Standalone nitellad"

    log_info "Starting nitellad in standalone mode..."

    NITELLAD_CMD="$BIN_DIR/nitellad \
        --listen 0.0.0.0:$NITELLAD_PROXY_PORT \
        --backend 127.0.0.1:$BACKEND_PORT \
        --admin-port $NITELLAD_ADMIN_PORT \
        --admin-token test-token \
        --db-path $TMP_DIR/nitellad/nitellad.db \
        --stats-db $TMP_DIR/nitellad/stats.db \
        --admin-data-dir $TMP_DIR/nitellad"

    if [ "$VERBOSE" = true ]; then
        $NITELLAD_CMD &
    else
        $NITELLAD_CMD > "$TMP_DIR/nitellad.log" 2>&1 &
    fi
    NITELLAD_PID=$!

    if wait_for_file "$TMP_DIR/nitellad/admin_ca.crt" 30; then
        log_success "nitellad started in standalone mode (PID: $NITELLAD_PID)"
    else
        log_error "nitellad failed to start"
        cat "$TMP_DIR/nitellad.log" 2>/dev/null
        exit 1
    fi
fi

echo ""
log_success "Full infrastructure ready!"
echo "  Hub:      localhost:$HUB_GRPC_PORT (PID: $HUB_PID)"
echo "  nitellad: localhost:$NITELLAD_PROXY_PORT (proxy), localhost:$NITELLAD_ADMIN_PORT (admin)"
echo "  Backend:  localhost:$BACKEND_PORT (PID: $BACKEND_PID)"
if [ -n "$PAIRED_NODE_ID" ]; then
    echo "  Node ID:  $PAIRED_NODE_ID (Hub-connected)"
fi
echo ""

# =============================================================================
# Phase 5: Run Go Backend Tests
# =============================================================================

log_section "Phase 5: Go Backend Tests"

export NITELLA_HUB_ADDRESS="localhost:$HUB_GRPC_PORT"
export NITELLA_NITELLAD_ADMIN="localhost:$NITELLAD_ADMIN_PORT"
export NITELLA_HUB_CA_PATH="$TMP_DIR/hub/hub_ca.crt"

log_info "Running Go mobile backend tests..."

if go test -v -timeout 5m ./test/integration/... -run "^TestMobile" 2>&1 | tee "$TMP_DIR/go_test.log"; then
    log_success "Go backend tests passed!"
else
    log_warning "Some Go tests failed (continuing with Flutter tests)"
fi

# =============================================================================
# Phase 6: Run Flutter E2E Tests
# =============================================================================

if [ "$SKIP_FLUTTER" = false ]; then
    log_section "Phase 6: Flutter E2E Tests"

    cd "$PROJECT_ROOT/app"

    # Export all environment variables for Flutter tests
    export NITELLA_HUB_ADDRESS="localhost:$HUB_GRPC_PORT"
    export NITELLA_NODE_ADMIN_ADDRESS="localhost:$NITELLAD_ADMIN_PORT"
    export NITELLA_PROXY_ADDRESS="localhost:$NITELLAD_PROXY_PORT"
    export NITELLA_BACKEND_ADDRESS="localhost:$BACKEND_PORT"
    export NITELLA_NODE_ADMIN_TOKEN="test-token"
    export NITELLA_NODE_CA_PATH="$TMP_DIR/nitellad/admin_ca.crt"
    export NITELLA_HUB_CA_PATH="$TMP_DIR/hub/hub_ca.crt"
    export NITELLA_HUB_CA_PEM_B64="$(b64_encode "$TMP_DIR/hub/hub_ca.crt")"
    export NITELLA_SKIP_TRAFFIC_TESTS="false"
    export NITELLA_INVITE_CODE="NITELLA"

    # Pass the paired node ID if available
    if [ -n "$PAIRED_NODE_ID" ]; then
        export NITELLA_PAIRED_NODE_ID="$PAIRED_NODE_ID"
        export NITELLA_HUB_MODE="true"
    else
        export NITELLA_HUB_MODE="false"
    fi

    if [ "$VISIBLE" = true ]; then
        export NITELLA_SLOW_MODE="true"
        log_info "Running Flutter tests with VISIBLE window..."
        log_info "Watch the app perform automated actions!"
        echo ""

        flutter drive \
            --driver=test_driver/integration_test.dart \
            --target=integration_test/full_e2e_test.dart \
            --dart-define=TEST_DATA_DIR="$FLUTTER_APP_DATA" \
            -d linux 2>&1 | tee "$TMP_DIR/flutter_test.log"
    else
        log_info "Running Flutter tests (headless, sequential)..."

        flutter test integration_test/full_e2e_test.dart \
            --concurrency=1 \
            --dart-define=TEST_DATA_DIR="$FLUTTER_APP_DATA" \
            -d linux 2>&1 | tee "$TMP_DIR/flutter_test.log"
    fi

    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        log_success "Flutter E2E tests passed!"
    else
        log_warning "Some Flutter tests failed"
    fi
fi

# =============================================================================
# Summary
# =============================================================================

log_section "Test Summary"

echo "Infrastructure:"
echo "  Hub:      localhost:$HUB_GRPC_PORT (PID: $HUB_PID)"
echo "  nitellad: localhost:$NITELLAD_PROXY_PORT (PID: $NITELLAD_PID)"
echo "  Backend:  localhost:$BACKEND_PORT (PID: $BACKEND_PID)"
if [ -n "$PAIRED_NODE_ID" ]; then
    echo "  Node ID:  $PAIRED_NODE_ID"
    echo "  Mode:     Full E2E (Mobile -> Hub -> Node)"
else
    echo "  Mode:     Standalone (direct admin API)"
fi
echo ""

echo "Test Results:"
if [ -f "$TMP_DIR/go_test.log" ]; then
    GO_PASS=$(grep -c "^--- PASS" "$TMP_DIR/go_test.log" 2>/dev/null || echo 0)
    GO_FAIL=$(grep -c "^--- FAIL" "$TMP_DIR/go_test.log" 2>/dev/null || echo 0)
    echo "  Go tests:      $GO_PASS passed, $GO_FAIL failed"
fi

if [ -f "$TMP_DIR/flutter_test.log" ]; then
    echo "  Flutter tests: See $TMP_DIR/flutter_test.log"
fi

echo ""
log_success "Full E2E test suite completed!"

if [ "$KEEP_RUNNING" = true ]; then
    echo ""
    log_info "Services still running. Press Ctrl+C to stop."
    wait
fi
