#!/bin/bash
set -e
set -x

# =============================================================================
# Nitella Benchmark Suite — Go vs Rust
#
# Compares Go (nitellad) and Rust (nitellad-rs) across standard and process
# modes using wrk for load generation and /proc-based resource monitoring.
#
# Prerequisites: wrk, go, cargo, curl
# =============================================================================

# Configuration
CURRENT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT_DIR=$(dirname "$(dirname "$CURRENT_DIR")")
GO_BIN="/tmp/nitella_bench_go"
RUST_BIN="/tmp/nitella_bench_rust"
RESULTS_DIR="$CURRENT_DIR/results"
MONITOR_SCRIPT="$CURRENT_DIR/monitor.sh"
BACKEND_BIN_NAME="bench_backend"
BACKEND_BIN="/tmp/nitella_bench_backend"

PROXY_PORT=8081
BACKEND_PORT=9090
ADMIN_PORT=50051
PPROF_PORT=6060

# Tunable parameters
RUNS=${RUNS:-3}
WRK_THREADS=${WRK_THREADS:-4}
WARMUP_CONNS=${WARMUP_CONNS:-10}
WARMUP_DURATION=${WARMUP_DURATION:-10}
LOAD_CONNS=${LOAD_CONNS:-50}
LOAD_DURATION=${LOAD_DURATION:-30}
LEAK_CONNS=${LEAK_CONNS:-50}
LEAK_DURATION=${LEAK_DURATION:-60}
LEAK_CYCLES=${LEAK_CYCLES:-3}
LEAK_REST=${LEAK_REST:-10}
BACKEND_KIND="static_tcp"
BENCH_SCENARIOS=${BENCH_SCENARIOS:-small_req}
LARGE_BYTES=${LARGE_BYTES:-1048576}
STREAM_CHUNKS=${STREAM_CHUNKS:-128}
STREAM_CHUNK_SIZE=${STREAM_CHUNK_SIZE:-8192}
STREAM_DELAY_MS=${STREAM_DELAY_MS:-0}
BACKEND_TASKSET=${BACKEND_TASKSET:-}
DAEMON_TASKSET=${DAEMON_TASKSET:-}

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

scenario_path() {
    case "$1" in
        small_req)
            printf '/'
            ;;
        large_1m)
            printf '/bytes/%s' "$LARGE_BYTES"
            ;;
        stream_1m)
            printf '/stream/%s/%s/%s' "$STREAM_CHUNKS" "$STREAM_CHUNK_SIZE" "$STREAM_DELAY_MS"
            ;;
        /*)
            printf '%s' "$1"
            ;;
        *)
            log_err "Unknown benchmark scenario: $1"
            log_err "Known scenarios: small_req, large_1m, stream_1m, or a raw path beginning with /"
            exit 2
            ;;
    esac
}

scenario_tag() {
    local tag=$1
    tag=${tag#/}
    tag=${tag//\//_}
    tag=${tag//[^a-zA-Z0-9_]/_}
    if [ -z "$tag" ]; then
        tag="root"
    fi
    printf '%s' "$tag"
}

variant_tag() {
    local BASE=$1
    local SCENARIO=$2
    local SCENARIO_TAG=$3

    if [ "$SCENARIO_COUNT" -eq 1 ] && [ "$SCENARIO" = "small_req" ]; then
        printf '%s' "$BASE"
    else
        printf '%s_%s' "$BASE" "$SCENARIO_TAG"
    fi
}

json_escape() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

# =============================================================================
# Pre-flight checks
# =============================================================================
preflight() {
    log_phase "Pre-flight Checks"

    local fail=0

    # Check build tools
    if ! command -v go &>/dev/null; then
        log_err "go not found (needed to build Go binary)"
        fail=1
    else
        log_ok "go: $(go version | awk '{print $3}')"
    fi

    if ! command -v cargo &>/dev/null; then
        log_err "cargo not found (needed to build Rust binaries)"
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

    if { [ -n "$BACKEND_TASKSET" ] || [ -n "$DAEMON_TASKSET" ]; } && ! command -v taskset &>/dev/null; then
        log_err "taskset not found but BACKEND_TASKSET/DAEMON_TASKSET was configured"
        fail=1
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
    pkill -x "nitellad" 2>/dev/null || true
    pkill -f "nitella_bench_go" 2>/dev/null || true
    pkill -x "nitellad-rs" 2>/dev/null || true
    pkill -f "nitella_bench_rust" 2>/dev/null || true
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

    log_info "Building static TCP backend server..."
    cargo build --release --manifest-path "$ROOT_DIR/nitellad-rs/Cargo.toml" --bin "$BACKEND_BIN_NAME"
    cp "$ROOT_DIR/nitellad-rs/target/release/$BACKEND_BIN_NAME" "$BACKEND_BIN"
    log_ok "Static TCP backend: $BACKEND_BIN"
}

start_backend() {
    log_info "Starting backend on :$BACKEND_PORT..."
    if [ -n "$BACKEND_TASKSET" ]; then
        log_info "Backend CPU affinity: $BACKEND_TASKSET"
        taskset -c "$BACKEND_TASKSET" "$BACKEND_BIN" -port "$BACKEND_PORT" &
    else
        "$BACKEND_BIN" -port "$BACKEND_PORT" &
    fi
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
    local pid=$2
    local max_retries=10
    local i=0
    while [ $i -lt $max_retries ]; do
        if ! kill -0 "$pid" 2>/dev/null; then
            return 1
        fi
        if curl -sf "http://127.0.0.1:$port/" -o /dev/null 2>/dev/null; then
            return 0
        fi
        sleep 0.5
        i=$((i + 1))
    done
    return 1
}

kill_port_listeners() {
    local port=$1
    local pids
    pids=$(lsof -ti ":$port" 2>/dev/null || true)
    for pid in $pids; do
        if [ -n "${BACKEND_PID:-}" ] && [ "$pid" = "$BACKEND_PID" ]; then
            continue
        fi
        if is_benchmark_process "$pid"; then
            kill "$pid" 2>/dev/null || true
        else
            log_warn "Port $port is held by non-benchmark PID $pid; leaving it running"
        fi
    done
}

is_benchmark_process() {
    local pid=$1
    local cmdline
    cmdline=$(ps -p "$pid" -o args= 2>/dev/null || true)
    case "$cmdline" in
        *nitella_bench_go*|*nitella_bench_rust*|*nitellad-rs*|*nitellad*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

wait_for_port_free() {
    local port=$1
    local i=0
    while [ $i -lt 20 ]; do
        if ! lsof -i ":$port" -t &>/dev/null; then
            return 0
        fi
        sleep 0.2
        i=$((i + 1))
    done
    return 1
}

stop_daemon() {
    local pid=$1

    pkill -P "$pid" 2>/dev/null || true
    kill "$pid" 2>/dev/null || true
    sleep 1
    pkill -P "$pid" 2>/dev/null || true
    kill_port_listeners "$PROXY_PORT"
    kill_port_listeners "$PPROF_PORT"
    wait "$pid" 2>/dev/null || true

    wait_for_port_free "$PROXY_PORT" || log_warn "Proxy port $PROXY_PORT still in use after cleanup"
    wait_for_port_free "$PPROF_PORT" || log_warn "pprof port $PPROF_PORT still in use after cleanup"
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
    local URL_PATH=$5

    local RUN_TAG="${NAME}_run${RUN_NUM}"
    local LOAD_URL="http://127.0.0.1:$PROXY_PORT$URL_PATH"

    log_info "--- $NAME (run $RUN_NUM/$RUNS) ---"
    log_info "Traffic target: $URL_PATH"

    # Prepare DB and admin port
    local DB_PATH="$RESULTS_DIR/${RUN_TAG}.db"
    rm -f "$DB_PATH"
    local THIS_ADMIN_PORT=$((ADMIN_PORT + RANDOM % 100))

    wait_for_port_free "$PROXY_PORT" || {
        log_warn "Proxy port $PROXY_PORT was still in use before $RUN_TAG; killing stale listener"
        kill_port_listeners "$PROXY_PORT"
        wait_for_port_free "$PROXY_PORT" || return 1
    }
    wait_for_port_free "$PPROF_PORT" || {
        log_warn "pprof port $PPROF_PORT was still in use before $RUN_TAG; killing stale listener"
        kill_port_listeners "$PPROF_PORT"
        wait_for_port_free "$PPROF_PORT" || return 1
    }

    # Start daemon with explicit address binding
    # Go binaries get --pprof-port (built with -tags pprof); Rust ignores unknown flags
    local LISTEN_ADDR="0.0.0.0:$PROXY_PORT"
    local PPROF_FLAG=""
    if echo "$BIN" | grep -q "go"; then
        PPROF_FLAG="--pprof-port $PPROF_PORT"
    fi
    if [ -n "$DAEMON_TASKSET" ]; then
        taskset -c "$DAEMON_TASKSET" "$BIN" $EXTRA_ARGS \
            --listen "$LISTEN_ADDR" \
            --backend "127.0.0.1:$BACKEND_PORT" \
            --admin-port "$THIS_ADMIN_PORT" \
            --db-path "$DB_PATH" \
            $PPROF_FLAG \
            > "$RESULTS_DIR/${RUN_TAG}.log" 2>&1 &
    else
        "$BIN" $EXTRA_ARGS \
            --listen "$LISTEN_ADDR" \
            --backend "127.0.0.1:$BACKEND_PORT" \
            --admin-port "$THIS_ADMIN_PORT" \
            --db-path "$DB_PATH" \
            $PPROF_FLAG \
            > "$RESULTS_DIR/${RUN_TAG}.log" 2>&1 &
    fi
    local DAEMON_PID=$!

    log_info "Daemon PID: $DAEMON_PID"
    if [ -n "$DAEMON_TASKSET" ]; then
        log_info "Daemon CPU affinity: $DAEMON_TASKSET"
    fi

    # Wait for proxy to accept connections
    if ! wait_for_proxy "$PROXY_PORT" "$DAEMON_PID"; then
        log_err "Proxy failed to start. Logs:"
        tail -20 "$RESULTS_DIR/${RUN_TAG}.log" 2>/dev/null || true
        stop_daemon "$DAEMON_PID"
        return 1
    fi

    # Verify proxying actually works (end-to-end)
    local PROBE
    PROBE=$(curl -sf "http://127.0.0.1:$PROXY_PORT/")
    if [ "$PROBE" != "Hello from backend" ]; then
        log_err "Proxy not forwarding correctly. Got: '$PROBE'"
        stop_daemon "$DAEMON_PID"
        return 1
    fi
    log_ok "Proxy verified: forwarding to backend"

    # Start resource monitor
    bash "$MONITOR_SCRIPT" "$DAEMON_PID" "$RESULTS_DIR/${RUN_TAG}_resources.csv" &
    MONITOR_PID=$!
    local BACKEND_MONITOR_PID=""
    if [ -n "${BACKEND_PID:-}" ]; then
        bash "$MONITOR_SCRIPT" "$BACKEND_PID" "$RESULTS_DIR/${RUN_TAG}_backend_resources.csv" &
        BACKEND_MONITOR_PID=$!
    fi

    # Snapshot pprof before warmup
    snapshot_pprof "$RESULTS_DIR/${RUN_TAG}_pprof_before.json" && \
        log_info "pprof snapshot: before warmup"

    # Phase 1: Warmup
    log_info "Phase 1: Warmup (${WARMUP_DURATION}s, ${WARMUP_CONNS} connections)..."
    wrk -t"$WRK_THREADS" -c"$WARMUP_CONNS" -d"${WARMUP_DURATION}s" \
        "$LOAD_URL" > /dev/null 2>&1

    # Snapshot pprof after warmup
    snapshot_pprof "$RESULTS_DIR/${RUN_TAG}_pprof_after_warmup.json" && \
        log_info "pprof snapshot: after warmup"

    # Phase 2: High load
    log_info "Phase 2: High load (${LOAD_DURATION}s, ${LOAD_CONNS} connections)..."
    wrk -t"$WRK_THREADS" -c"$LOAD_CONNS" -d"${LOAD_DURATION}s" \
        --latency "$LOAD_URL" \
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
            "$LOAD_URL" \
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
    if [ -n "$BACKEND_MONITOR_PID" ]; then
        kill "$BACKEND_MONITOR_PID" 2>/dev/null || true
        wait "$BACKEND_MONITOR_PID" 2>/dev/null || true
    fi

    # Stop daemon and any process-mode children before the next variant starts.
    stop_daemon "$DAEMON_PID"

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
    local URL_PATH=$4

    log_phase "Benchmarking: $NAME ($RUNS runs)"
    log_info "Binary: $BIN $EXTRA_ARGS"
    log_info "Scenario URL path: $URL_PATH"

    local failures=0
    for run in $(seq 1 "$RUNS"); do
        if ! run_single_test "$NAME" "$BIN" "$EXTRA_ARGS" "$run" "$URL_PATH"; then
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
pkill -x "nitellad" 2>/dev/null || true
pkill -f "nitella_bench_go" 2>/dev/null || true
pkill -x "nitellad-rs" 2>/dev/null || true
pkill -f "nitella_bench_rust" 2>/dev/null || true
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

IFS=',' read -r -a SCENARIO_LIST <<< "$BENCH_SCENARIOS"
SCENARIO_COUNT=${#SCENARIO_LIST[@]}
VARIANTS_JSON=""
SCENARIOS_JSON=""
for SCENARIO in "${SCENARIO_LIST[@]}"; do
    SCENARIO_TAG=$(scenario_tag "$SCENARIO")
    URL_PATH=$(scenario_path "$SCENARIO")
    ESCAPED_SCENARIO=$(json_escape "$SCENARIO")
    ESCAPED_PATH=$(json_escape "$URL_PATH")
    if [ -n "$SCENARIOS_JSON" ]; then
        SCENARIOS_JSON="$SCENARIOS_JSON,"
    fi
    SCENARIOS_JSON="$SCENARIOS_JSON\"$ESCAPED_SCENARIO\":\"$ESCAPED_PATH\""

    for BASE in go_standard go_process rust_standard rust_process; do
        TAG=$(variant_tag "$BASE" "$SCENARIO" "$SCENARIO_TAG")
        ESCAPED_TAG=$(json_escape "$TAG")
        if [ -n "$VARIANTS_JSON" ]; then
            VARIANTS_JSON="$VARIANTS_JSON,"
        fi
        VARIANTS_JSON="$VARIANTS_JSON\"$ESCAPED_TAG\""
    done
done

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
    "backend": "$BACKEND_KIND",
    "bench_scenarios": "$(json_escape "$BENCH_SCENARIOS")",
    "large_bytes": $LARGE_BYTES,
    "stream_chunks": $STREAM_CHUNKS,
    "stream_chunk_size": $STREAM_CHUNK_SIZE,
    "stream_delay_ms": $STREAM_DELAY_MS,
    "env": {
        "GOMAXPROCS": "${GOMAXPROCS:-unset}",
        "BACKEND_TASKSET": "${BACKEND_TASKSET:-unset}",
        "DAEMON_TASKSET": "${DAEMON_TASKSET:-unset}"
    },
    "scenarios": {$SCENARIOS_JSON},
    "variants": [$VARIANTS_JSON]
}
EOF

# Run all variants for each selected scenario.
for SCENARIO in "${SCENARIO_LIST[@]}"; do
    SCENARIO_TAG=$(scenario_tag "$SCENARIO")
    URL_PATH=$(scenario_path "$SCENARIO")

    run_variant "$(variant_tag "go_standard" "$SCENARIO" "$SCENARIO_TAG")"   "$GO_BIN"   ""               "$URL_PATH"
    run_variant "$(variant_tag "go_process" "$SCENARIO" "$SCENARIO_TAG")"    "$GO_BIN"   "--process-mode" "$URL_PATH"
    run_variant "$(variant_tag "rust_standard" "$SCENARIO" "$SCENARIO_TAG")" "$RUST_BIN" ""               "$URL_PATH"
    run_variant "$(variant_tag "rust_process" "$SCENARIO" "$SCENARIO_TAG")"  "$RUST_BIN" "--process-mode" "$URL_PATH"
done

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
