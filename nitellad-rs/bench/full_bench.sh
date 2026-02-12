#!/bin/bash
set -e

# =============================================================================
# Nitella Comprehensive Benchmark Suite
#
# Scenarios:
# 1. Light Short (High churn, low concurrency)
# 2. Heavy Short (High churn, high concurrency)
# 3. Light Long (Persistent, low concurrency)
# 4. Heavy Long (Persistent, high concurrency)
# =============================================================================

CURRENT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT_DIR=$(dirname "$(dirname "$CURRENT_DIR")")
GO_BIN="/tmp/nitella_bench_go"
RUST_BIN="/tmp/nitella_bench_rust"
RESULTS_DIR="$CURRENT_DIR/results_full"
MONITOR_SCRIPT="$CURRENT_DIR/monitor_full.sh"
BACKEND_SRC="$CURRENT_DIR/backend.go"
BACKEND_BIN="/tmp/nitella_bench_backend"

PROXY_PORT=8082
BACKEND_PORT=9092
ADMIN_PORT=50052
PPROF_PORT=6062

# Config
RUNS=${RUNS:-1}
LOAD_DURATION=${LOAD_DURATION:-15} # Seconds per perf test
LEAK_CYCLES=${LEAK_CYCLES:-2}
LEAK_DURATION=${LEAK_DURATION:-15}
LEAK_REST=${LEAK_REST:-5}

# Scenarios Configuration
# Format: "NAME|WRK_ARGS"
SCENARIOS=(
    "light_short|-c10 -t2 -H 'Connection: close'"
    "heavy_short|-c100 -t10 -H 'Connection: close'"
    "light_long|-c10 -t2"
    "heavy_long|-c100 -t10"
)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_err()   { echo -e "${RED}[ERROR]${NC} $*"; }
log_phase() { echo -e "\n${CYAN}=== $* ===${NC}"; }

# =============================================================================
# Setup & Teardown
# =============================================================================
cleanup_all() {
    log_info "Cleaning up..."
    kill "$BACKEND_PID" 2>/dev/null || true
    pkill -f "nitellad" 2>/dev/null || true
    pkill -f "nitellad-rs" 2>/dev/null || true
    pkill -f "monitor_full.sh" 2>/dev/null || true
    rm -f "$BACKEND_BIN" "$GO_BIN" "$RUST_BIN"
}

build_all() {
    log_phase "Building Binaries"
    
    log_info "Building Go..."
    go build -tags pprof -o "$GO_BIN" "$ROOT_DIR/cmd/nitellad"
    
    log_info "Building Rust..."
    cargo build --release --manifest-path "$ROOT_DIR/rust/Cargo.toml"
    cp "$ROOT_DIR/rust/target/release/nitellad-rs" "$RUST_BIN"

    log_info "Building Backend..."
    go build -o "$BACKEND_BIN" "$BACKEND_SRC"
}

start_backend() {
    "$BACKEND_BIN" -port "$BACKEND_PORT" &
    BACKEND_PID=$!
    sleep 1
}

# =============================================================================
# Helpers
# =============================================================================
wait_for_proxy() {
    local port=$1
    for i in {1..20}; do
        if curl -sf "http://127.0.0.1:$port/" -o /dev/null 2>/dev/null; then
            return 0
        fi
        sleep 0.2
    done
    return 1
}

snapshot_pprof() {
    local OUT_FILE=$1
    # Only for Go
    curl -sf "http://127.0.0.1:$PPROF_PORT/debug/goroutines" > "${OUT_FILE}.tmp" 2>/dev/null || return 1
    # Construct simplistic JSON
    local GOROUTINES=$(cat "${OUT_FILE}.tmp")
    rm "${OUT_FILE}.tmp"
    
    # We also want heap info
    local MEMSTATS=$(curl -sf "http://127.0.0.1:$PPROF_PORT/debug/memstats" 2>/dev/null || echo "")
    local HEAP_INUSE=$(echo "$MEMSTATS" | grep "^HeapInuse:" | awk '{print $2}')
    
    echo "{\"goroutines\": ${GOROUTINES:-0}, \"heap_inuse\": ${HEAP_INUSE:-0}}" > "$OUT_FILE"
}

# =============================================================================
# Test Execution
# =============================================================================
run_single_test() {
    local VARIANT_NAME=$1
    local BIN=$2
    local EXTRA_ARGS=$3
    local SCENARIO_ARGS=$4
    local RUN_NUM=$5

    local RUN_TAG="${VARIANT_NAME}_run${RUN_NUM}"
    log_info "--- $VARIANT_NAME (run $RUN_NUM) ---"

    # Start Daemon
    local DB_PATH="$RESULTS_DIR/${RUN_TAG}.db"
    rm -f "$DB_PATH"
    local THIS_ADMIN_PORT=$((ADMIN_PORT + RANDOM % 100))
    
    local CMD="$BIN"
    if [ -n "$EXTRA_ARGS" ]; then
        CMD="$CMD $EXTRA_ARGS"
    fi

    local PPROF_FLAG=""
    if echo "$BIN" | grep -q "go"; then
        PPROF_FLAG="--pprof-port $PPROF_PORT"
    fi
    if [ -n "$PPROF_FLAG" ]; then
        CMD="$CMD $PPROF_FLAG"
    fi
    
    # Debug print
    echo "Running: $CMD --listen 0.0.0.0:$PROXY_PORT --backend 127.0.0.1:$BACKEND_PORT --admin-port $THIS_ADMIN_PORT --db-path $DB_PATH"

    $CMD \
        --listen "0.0.0.0:$PROXY_PORT" \
        --backend "127.0.0.1:$BACKEND_PORT" \
        --admin-port "$THIS_ADMIN_PORT" \
        --db-path "$DB_PATH" \
        > "$RESULTS_DIR/${RUN_TAG}.log" 2>&1 &
    local DAEMON_PID=$!

    if ! wait_for_proxy "$PROXY_PORT"; then
        log_err "Proxy failed to start. Logs:"
        tail -n 10 "$RESULTS_DIR/${RUN_TAG}.log"
        kill "$DAEMON_PID" 2>/dev/null
        return 1
    fi

    # Start Monitor
    bash "$MONITOR_SCRIPT" "$DAEMON_PID" "$RESULTS_DIR/${RUN_TAG}_resources.csv" &
    local MONITOR_PID=$!

    # Snapshot PPROF (Before)
    snapshot_pprof "$RESULTS_DIR/${RUN_TAG}_pprof_before.json" || true

    # 1. Warmup
    wrk -t2 -c10 -d5s "http://127.0.0.1:$PROXY_PORT/" > /dev/null 2>&1

    # 2. Performance Load
    log_info "Load Test: wrk $SCENARIO_ARGS -d${LOAD_DURATION}s"
    eval "wrk $SCENARIO_ARGS -d${LOAD_DURATION}s --latency http://127.0.0.1:$PROXY_PORT/" \
        > "$RESULTS_DIR/${RUN_TAG}_wrk_load.txt" 2>&1

    snapshot_pprof "$RESULTS_DIR/${RUN_TAG}_pprof_after_load.json" || true

    # 3. Leak Detection (Cycles)
    log_info "Leak Detection ($LEAK_CYCLES cycles)"
    for cycle in $(seq 1 "$LEAK_CYCLES"); do
        eval "wrk $SCENARIO_ARGS -d${LEAK_DURATION}s http://127.0.0.1:$PROXY_PORT/" > /dev/null 2>&1
        sleep "$LEAK_REST"
        
        # Record RSS
        local RSS
        RSS=$(awk -F, 'END{print $2}' "$RESULTS_DIR/${RUN_TAG}_resources.csv" 2>/dev/null || echo "0")
        echo "$RSS" > "$RESULTS_DIR/${RUN_TAG}_rss_after_cycle${cycle}.txt"
        
        snapshot_pprof "$RESULTS_DIR/${RUN_TAG}_pprof_leak_cycle${cycle}_after.json" || true
    done

    # Stop everything
    kill "$MONITOR_PID" 2>/dev/null
    wait "$MONITOR_PID" 2>/dev/null || true
    
    kill "$DAEMON_PID" 2>/dev/null
    pkill -P "$DAEMON_PID" 2>/dev/null || true # Kill children
    wait "$DAEMON_PID" 2>/dev/null || true
    
    return 0
}

# =============================================================================
# Main Loop
# =============================================================================
mkdir -p "$RESULTS_DIR"
pkill -f "nitellad" 2>/dev/null || true

build_all
start_backend
trap cleanup_all EXIT

VARIANTS_LIST=()
SCENARIOS_JSON=""

# Build Scenario JSON fragment for config
for scen in "${SCENARIOS[@]}"; do
    NAME=${scen%%|*}
    ARGS=${scen#*|}
    if [ -n "$SCENARIOS_JSON" ]; then SCENARIOS_JSON+=", "; fi
    SCENARIOS_JSON+="\"$NAME\": \"$ARGS\""
done

# Run Matrix
for scen in "${SCENARIOS[@]}"; do
    SCEN_NAME=${scen%%|*}
    SCEN_ARGS=${scen#*|}
    
    if [ -n "$ONLY_SCENARIO" ] && [ "$SCEN_NAME" != "$ONLY_SCENARIO" ]; then
        continue
    fi
    
    log_phase "Scenario: $SCEN_NAME"
    
    # Define combinations: Impl + Mode
    # 1. Go Standard
    VNAME="go_standard_${SCEN_NAME}"
    VARIANTS_LIST+=("\"$VNAME\"")
    for r in $(seq 1 "$RUNS"); do
        run_single_test "$VNAME" "$GO_BIN" "" "$SCEN_ARGS" "$r"
    done
    
    # 2. Go Process
    VNAME="go_process_${SCEN_NAME}"
    VARIANTS_LIST+=("\"$VNAME\"")
    for r in $(seq 1 "$RUNS"); do
        run_single_test "$VNAME" "$GO_BIN" "--process-mode" "$SCEN_ARGS" "$r"
    done
    
    # 3. Rust Standard
    VNAME="rust_standard_${SCEN_NAME}"
    VARIANTS_LIST+=("\"$VNAME\"")
    for r in $(seq 1 "$RUNS"); do
        run_single_test "$VNAME" "$RUST_BIN" "" "$SCEN_ARGS" "$r"
    done
    
    # 4. Rust Process
    VNAME="rust_process_${SCEN_NAME}"
    VARIANTS_LIST+=("\"$VNAME\"")
    for r in $(seq 1 "$RUNS"); do
        run_single_test "$VNAME" "$RUST_BIN" "--process-mode" "$SCEN_ARGS" "$r"
    done
done

# Write Config
cat > "$RESULTS_DIR/config.json" <<EOF
{
    "runs": $RUNS,
    "leak_cycles": $LEAK_CYCLES,
    "scenarios": { $SCENARIOS_JSON },
    "variants": [ $(IFS=,; echo "${VARIANTS_LIST[*]}") ]
}
EOF

log_phase "Analysis"
python3 "$CURRENT_DIR/analyze.py" "$RESULTS_DIR"
