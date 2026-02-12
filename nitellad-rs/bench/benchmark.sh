#!/bin/bash
set -e
set -x

# =============================================================================
# Nitella Benchmark Suite — Go vs Rust
#
# Compares Go (nitellad) and Rust (nitellad-rs) across standard and process
# modes using wrk for load generation and /proc-based resource monitoring.
#
# Prerequisites: wrk, go (for building backend), curl
# =============================================================================

# Configuration
CURRENT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT_DIR=$(dirname "$(dirname "$CURRENT_DIR")")
GO_BIN="/tmp/nitella_bench_go"
RUST_BIN="/tmp/nitella_bench_rust"
RESULTS_DIR="$CURRENT_DIR/results"
MONITOR_SCRIPT="$CURRENT_DIR/monitor.sh"
BACKEND_SRC="$CURRENT_DIR/backend.go"
BACKEND_BIN="/tmp/nitella_bench_backend"

PROXY_PORT=8081
BACKEND_PORT=9090
ADMIN_PORT=50051
PPROF_PORT=6060

# Tunable parameters
RUNS=${RUNS:-3}
WRK_THREADS=${WRK_THREADS:-4}
WARMUP_CONNS=10
WARMUP_DURATION=10
LOAD_CONNS=50
LOAD_DURATION=30
LEAK_CONNS=50
LEAK_DURATION=60
LEAK_CYCLES=3
LEAK_REST=10

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_err()   { echo -e "${RED}[ERROR]${NC} $*"; }
log_phase() { echo -e "\n${CYAN}=== $* ===${NC}"; }

# =============================================================================
# Pre-flight checks
# =============================================================================
preflight() {
    log_phase "Pre-flight Checks"

    local fail=0

    # Check build tools
    if ! command -v go &>/dev/null; then
        log_err "go not found (needed to build Go binary and backend)"
        fail=1
    else
        log_ok "go: $(go version | awk '{print $3}')"
    fi

    if ! command -v cargo &>/dev/null; then
        log_err "cargo not found (needed to build Rust binary)"
        fail=1
    else
        log_ok "cargo: $(cargo --version)"
    fi

    # Check wrk
    if ! command -v wrk &>/dev/null; then
        log_err "wrk not found. Install with: sudo apt install wrk"
        fail=1
    else
        log_ok "wrk: $(wrk --version 2>&1 | head -1)"
    fi

    # Check curl
    if ! command -v curl &>/dev/null; then
        log_err "curl not found"
        fail=1
    else
        log_ok "curl available"
    fi

    # Check source directories exist
    if [ ! -d "$ROOT_DIR/cmd/nitellad" ]; then
        log_err "Go source not found: $ROOT_DIR/cmd/nitellad"
        fail=1
    else
        log_ok "Go source: $ROOT_DIR/cmd/nitellad"
    fi

    if [ ! -d "$ROOT_DIR/nitellad-rs" ]; then
        log_err "Rust source not found: $ROOT_DIR/nitellad-rs"
        fail=1
    else
        log_ok "Rust source: $ROOT_DIR/nitellad-rs"
    fi

    if [ "$fail" -ne 0 ]; then
        log_err "Pre-flight checks failed. Aborting."
        exit 1
    fi

    log_ok "All pre-flight checks passed"
}

# =============================================================================
# Cleanup
# =============================================================================
cleanup_all() {
    log_info "Cleaning up..."
    kill "$BACKEND_PID" 2>/dev/null || true
    pkill -x "nitellad" 2>/dev/null || pkill -f "nitella_bench_go" 2>/dev/null || true
    pkill -x "nitellad-rs" 2>/dev/null || pkill -f "nitella_bench_rust" 2>/dev/null || true
    pkill -f "monitor.sh" 2>/dev/null || true
    kill "$MONITOR_PID" 2>/dev/null || true
    rm -f "$BACKEND_BIN" "$GO_BIN" "$RUST_BIN"
    # Wait for ports to free
    sleep 1
}

# =============================================================================
# Build all binaries
# =============================================================================
build_all() {
    log_phase "Building Binaries"

    log_info "Building Go nitellad (with pprof)..."
    go build -tags pprof -o "$GO_BIN" "$ROOT_DIR/cmd/nitellad"
    log_ok "Go binary: $GO_BIN (pprof enabled)"

    log_info "Building Rust nitellad-rs..."
    cargo build --release --manifest-path "$ROOT_DIR/nitellad-rs/Cargo.toml"
    cp "$ROOT_DIR/nitellad-rs/target/release/nitellad-rs" "$RUST_BIN"
    log_ok "Rust binary: $RUST_BIN"

    log_info "Building backend server..."
    go build -o "$BACKEND_BIN" "$BACKEND_SRC"
    log_ok "Backend: $BACKEND_BIN"
}

start_backend() {
    log_info "Starting backend on :$BACKEND_PORT..."
    "$BACKEND_BIN" -port "$BACKEND_PORT" &
    BACKEND_PID=$!
    sleep 1

    # Verify backend responds
    if curl -sf "http://127.0.0.1:$BACKEND_PORT/" -o /dev/null; then
        log_ok "Backend is responding"
    else
        log_err "Backend failed to respond on port $BACKEND_PORT"
        exit 1
    fi
}

# =============================================================================
# Query pprof endpoints (Go only — silently skipped for Rust)
# =============================================================================
snapshot_pprof() {
    local OUT_FILE=$1
    local GOROUTINES MEMSTATS

    GOROUTINES=$(curl -sf "http://127.0.0.1:$PPROF_PORT/debug/goroutines" 2>/dev/null || echo "")
    MEMSTATS=$(curl -sf "http://127.0.0.1:$PPROF_PORT/debug/memstats" 2>/dev/null || echo "")

    if [ -z "$GOROUTINES" ]; then
        # pprof not available (Rust binary or pprof disabled)
        return 1
    fi

    # Parse key fields from memstats text
    local HEAP_ALLOC HEAP_INUSE HEAP_OBJECTS SYS NUM_GC
    HEAP_ALLOC=$(echo "$MEMSTATS" | grep "^HeapAlloc:" | awk '{print $2}')
    HEAP_INUSE=$(echo "$MEMSTATS" | grep "^HeapInuse:" | awk '{print $2}')
    HEAP_OBJECTS=$(echo "$MEMSTATS" | grep "^HeapObjects:" | awk '{print $2}')
    SYS=$(echo "$MEMSTATS" | grep "^Sys:" | awk '{print $2}')
    NUM_GC=$(echo "$MEMSTATS" | grep "^NumGC:" | awk '{print $2}')

    cat > "$OUT_FILE" <<PPEOF
{
    "goroutines": $GOROUTINES,
    "heap_alloc": ${HEAP_ALLOC:-0},
    "heap_inuse": ${HEAP_INUSE:-0},
    "heap_objects": ${HEAP_OBJECTS:-0},
    "sys": ${SYS:-0},
    "num_gc": ${NUM_GC:-0}
}
PPEOF
    return 0
}

# =============================================================================
# Wait for proxy to be ready (health check with retries)
# =============================================================================
wait_for_proxy() {
    local port=$1
    local max_retries=10
    local i=0
    while [ $i -lt $max_retries ]; do
        if curl -sf "http://127.0.0.1:$port/" -o /dev/null 2>/dev/null; then
            return 0
        fi
        sleep 0.5
        i=$((i + 1))
    done
    return 1
}

# =============================================================================
# Parse wrk output to extract key metrics
# =============================================================================
# wrk outputs something like:
#   Running 30s test @ http://127.0.0.1:8081/
#     4 threads and 50 connections
#     Thread Stats   Avg      Stdev     Max   +/- Stdev
#       Latency     1.23ms  456.78us  12.34ms   78.90%
#       Req/Sec     2.50k   123.45     3.00k    67.89%
#     Latency Distribution
#       50%    1.10ms
#       75%    1.50ms
#       90%    2.00ms
#       99%    5.00ms
#   300000 requests in 30.00s, 35.00MB read
#   Non-2xx responses: 1234      (only appears if there are errors)
# Requests/sec:  10000.00
# Transfer/sec:      1.17MB

# =============================================================================
# Run a single benchmark test
# =============================================================================
run_single_test() {
    local NAME=$1
    local BIN=$2
    local EXTRA_ARGS=$3
    local RUN_NUM=$4

    local RUN_TAG="${NAME}_run${RUN_NUM}"

    log_info "--- $NAME (run $RUN_NUM/$RUNS) ---"

    # Prepare DB and admin port
    local DB_PATH="$RESULTS_DIR/${RUN_TAG}.db"
    rm -f "$DB_PATH"
    local THIS_ADMIN_PORT=$((ADMIN_PORT + RANDOM % 100))

    # Start daemon with explicit address binding
    # Go binaries get --pprof-port (built with -tags pprof); Rust ignores unknown flags
    local LISTEN_ADDR="0.0.0.0:$PROXY_PORT"
    local PPROF_FLAG=""
    if echo "$BIN" | grep -q "go"; then
        PPROF_FLAG="--pprof-port $PPROF_PORT"
    fi
    $BIN $EXTRA_ARGS \
        --listen "$LISTEN_ADDR" \
        --backend "127.0.0.1:$BACKEND_PORT" \
        --admin-port "$THIS_ADMIN_PORT" \
        --db-path "$DB_PATH" \
        $PPROF_FLAG \
        > "$RESULTS_DIR/${RUN_TAG}.log" 2>&1 &
    local DAEMON_PID=$!

    log_info "Daemon PID: $DAEMON_PID"

    # Wait for proxy to accept connections
    if ! wait_for_proxy "$PROXY_PORT"; then
        log_err "Proxy failed to start. Logs:"
        tail -20 "$RESULTS_DIR/${RUN_TAG}.log" 2>/dev/null || true
        kill "$DAEMON_PID" 2>/dev/null || true
        return 1
    fi

    # Verify proxying actually works (end-to-end)
    local PROBE
    PROBE=$(curl -sf "http://127.0.0.1:$PROXY_PORT/")
    if [ "$PROBE" != "Hello from backend" ]; then
        log_err "Proxy not forwarding correctly. Got: '$PROBE'"
        kill "$DAEMON_PID" 2>/dev/null || true
        return 1
    fi
    log_ok "Proxy verified: forwarding to backend"

    # Start resource monitor
    bash "$MONITOR_SCRIPT" "$DAEMON_PID" "$RESULTS_DIR/${RUN_TAG}_resources.csv" &
    MONITOR_PID=$!

    # Snapshot pprof before warmup
    snapshot_pprof "$RESULTS_DIR/${RUN_TAG}_pprof_before.json" && \
        log_info "pprof snapshot: before warmup"

    # Phase 1: Warmup
    log_info "Phase 1: Warmup (${WARMUP_DURATION}s, ${WARMUP_CONNS} connections)..."
    wrk -t"$WRK_THREADS" -c"$WARMUP_CONNS" -d"${WARMUP_DURATION}s" \
        "http://127.0.0.1:$PROXY_PORT/" > /dev/null 2>&1

    # Snapshot pprof after warmup
    snapshot_pprof "$RESULTS_DIR/${RUN_TAG}_pprof_after_warmup.json" && \
        log_info "pprof snapshot: after warmup"

    # Phase 2: High load
    log_info "Phase 2: High load (${LOAD_DURATION}s, ${LOAD_CONNS} connections)..."
    wrk -t"$WRK_THREADS" -c"$LOAD_CONNS" -d"${LOAD_DURATION}s" \
        --latency "http://127.0.0.1:$PROXY_PORT/" \
        > "$RESULTS_DIR/${RUN_TAG}_wrk_load.txt" 2>&1

    # Snapshot pprof after load
    snapshot_pprof "$RESULTS_DIR/${RUN_TAG}_pprof_after_load.json" && \
        log_info "pprof snapshot: after load"

    # Phase 3: Leak detection — multiple cycles with rest periods
    log_info "Phase 3: Leak detection ($LEAK_CYCLES cycles × ${LEAK_DURATION}s + ${LEAK_REST}s rest)..."
    for cycle in $(seq 1 "$LEAK_CYCLES"); do
        # Record RSS before cycle
        local RSS_BEFORE
        RSS_BEFORE=$(awk -F, 'END{print $2}' "$RESULTS_DIR/${RUN_TAG}_resources.csv" 2>/dev/null || echo "0")
        echo "$RSS_BEFORE" > "$RESULTS_DIR/${RUN_TAG}_rss_before_cycle${cycle}.txt"

        # Snapshot pprof before leak cycle
        snapshot_pprof "$RESULTS_DIR/${RUN_TAG}_pprof_leak_cycle${cycle}_before.json"

        wrk -t"$WRK_THREADS" -c"$LEAK_CONNS" -d"${LEAK_DURATION}s" \
            "http://127.0.0.1:$PROXY_PORT/" \
            > "$RESULTS_DIR/${RUN_TAG}_wrk_leak_cycle${cycle}.txt" 2>&1

        sleep "$LEAK_REST"

        # Record RSS after rest
        local RSS_AFTER
        RSS_AFTER=$(awk -F, 'END{print $2}' "$RESULTS_DIR/${RUN_TAG}_resources.csv" 2>/dev/null || echo "0")
        echo "$RSS_AFTER" > "$RESULTS_DIR/${RUN_TAG}_rss_after_cycle${cycle}.txt"

        # Snapshot pprof after leak cycle rest
        snapshot_pprof "$RESULTS_DIR/${RUN_TAG}_pprof_leak_cycle${cycle}_after.json"

        log_info "  Cycle $cycle: RSS before=${RSS_BEFORE}KB after=${RSS_AFTER}KB"
    done

    # Stop monitor
    kill "$MONITOR_PID" 2>/dev/null || true
    wait "$MONITOR_PID" 2>/dev/null || true

    # Stop daemon gracefully
    kill "$DAEMON_PID" 2>/dev/null || true
    sleep 1
    # Force kill children (process mode)
    pkill -P "$DAEMON_PID" 2>/dev/null || true
    wait "$DAEMON_PID" 2>/dev/null || true

    log_ok "Completed $NAME run $RUN_NUM"
    return 0
}

# =============================================================================
# Run all tests for a given variant
# =============================================================================
run_variant() {
    local NAME=$1
    local BIN=$2
    local EXTRA_ARGS=$3

    log_phase "Benchmarking: $NAME ($RUNS runs)"
    log_info "Binary: $BIN $EXTRA_ARGS"

    local failures=0
    for run in $(seq 1 "$RUNS"); do
        if ! run_single_test "$NAME" "$BIN" "$EXTRA_ARGS" "$run"; then
            log_warn "Run $run failed for $NAME, continuing..."
            failures=$((failures + 1))
        fi
        # Small gap between runs to let OS settle
        sleep 2
    done
    if [ "$failures" -gt 0 ]; then
        log_warn "$NAME: $failures/$RUNS runs failed"
    fi
}

# =============================================================================
# Main
# =============================================================================

preflight

# Ensure clean slate
log_phase "Cleanup"
pkill -x "nitellad" 2>/dev/null || pkill -f "nitella_bench_go" 2>/dev/null || true
pkill -x "nitellad-rs" 2>/dev/null || pkill -f "nitella_bench_rust" 2>/dev/null || true
pkill -f "monitor.sh" 2>/dev/null || true
sleep 2

# Check ports
for port in $PROXY_PORT $BACKEND_PORT; do
    if lsof -i ":$port" -t &>/dev/null; then
        log_err "Port $port is already in use"
        lsof -i ":$port"
        exit 1
    fi
done

mkdir -p "$RESULTS_DIR"

# Build all binaries and start backend
build_all
start_backend
trap cleanup_all EXIT

# Save benchmark config for analyze.py
cat > "$RESULTS_DIR/config.json" <<EOF
{
    "runs": $RUNS,
    "wrk_threads": $WRK_THREADS,
    "warmup_conns": $WARMUP_CONNS,
    "warmup_duration": $WARMUP_DURATION,
    "load_conns": $LOAD_CONNS,
    "load_duration": $LOAD_DURATION,
    "leak_conns": $LEAK_CONNS,
    "leak_duration": $LEAK_DURATION,
    "leak_cycles": $LEAK_CYCLES,
    "leak_rest": $LEAK_REST,
    "variants": ["go_standard", "go_process", "rust_standard", "rust_process"]
}
EOF

# Run all variants
run_variant "go_standard"   "$GO_BIN"   ""
run_variant "go_process"    "$GO_BIN"   "--process-mode"
run_variant "rust_standard" "$RUST_BIN" ""
run_variant "rust_process"  "$RUST_BIN" "--process-mode"

# Generate analysis
log_phase "Analysis"
if command -v python3 &>/dev/null; then
    python3 "$CURRENT_DIR/analyze.py" "$RESULTS_DIR"
    log_ok "Results written to $RESULTS_DIR/summary.json and $RESULTS_DIR/summary.md"
else
    log_warn "python3 not found, skipping analysis. Run manually: python3 analyze.py $RESULTS_DIR"
fi

log_phase "Complete"
log_ok "All benchmarks finished. Results in $RESULTS_DIR/"
