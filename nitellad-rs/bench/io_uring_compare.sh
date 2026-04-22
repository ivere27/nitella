#!/bin/bash
set -euo pipefail

# Compare the production Rust epoll+splice path with the isolated io_uring
# splice prototype. The prototype uses io_uring_setup, so this script must run
# outside sandbox policies that block io_uring.

CURRENT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT_DIR=$(dirname "$(dirname "$CURRENT_DIR")")
RESULTS_DIR="$CURRENT_DIR/results"

BACKEND_BIN="$ROOT_DIR/nitellad-rs/target/release/bench_backend"
RUST_BIN="$ROOT_DIR/nitellad-rs/target/release/nitellad-rs"
IOURING_BIN="$ROOT_DIR/nitellad-rs/target/release/io_uring_splice_proxy"

PROXY_PORT=${PROXY_PORT:-8081}
BACKEND_PORT=${BACKEND_PORT:-9090}
ADMIN_PORT=${ADMIN_PORT:-50051}

IOURING_BENCH_SCENARIOS=${IOURING_BENCH_SCENARIOS:-small_req,large_1m,stream_1m}
IOURING_BENCH_THREADS=${IOURING_BENCH_THREADS:-4}
IOURING_BENCH_CONNS=${IOURING_BENCH_CONNS:-50}
IOURING_BENCH_WARMUP=${IOURING_BENCH_WARMUP:-5}
IOURING_BENCH_DURATION=${IOURING_BENCH_DURATION:-15}

LARGE_BYTES=${LARGE_BYTES:-1048576}
STREAM_CHUNKS=${STREAM_CHUNKS:-128}
STREAM_CHUNK_SIZE=${STREAM_CHUNK_SIZE:-8192}
STREAM_DELAY_MS=${STREAM_DELAY_MS:-0}

log() {
    printf '[io_uring-compare] %s\n' "$*"
}

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
            printf 'unknown scenario: %s\n' "$1" >&2
            exit 2
            ;;
    esac
}

scenario_tag() {
    printf '%s' "$1" | tr '/:' '__'
}

cleanup() {
    if [ -n "${DAEMON_PID:-}" ]; then
        pkill -P "$DAEMON_PID" 2>/dev/null || true
        kill "$DAEMON_PID" 2>/dev/null || true
        wait "$DAEMON_PID" 2>/dev/null || true
    fi
    if [ -n "${BACKEND_PID:-}" ]; then
        kill "$BACKEND_PID" 2>/dev/null || true
        wait "$BACKEND_PID" 2>/dev/null || true
    fi
    pkill -f "target/release/nitellad-rs --listen 0.0.0.0:$PROXY_PORT" 2>/dev/null || true
    pkill -f "target/release/io_uring_splice_proxy --listen 0.0.0.0:$PROXY_PORT" 2>/dev/null || true
    pkill -f "target/release/bench_backend -port $BACKEND_PORT" 2>/dev/null || true
}

wait_for_http() {
    local url=$1
    local i=0
    while [ "$i" -lt 40 ]; do
        if curl -sf "$url" -o /dev/null 2>/dev/null; then
            return 0
        fi
        sleep 0.25
        i=$((i + 1))
    done
    return 1
}

start_variant() {
    local variant=$1
    local scenario=$2
    local tag
    tag="$(scenario_tag "$scenario")"

    case "$variant" in
        rust_epoll)
            "$RUST_BIN" \
                --listen "0.0.0.0:$PROXY_PORT" \
                --backend "127.0.0.1:$BACKEND_PORT" \
                --admin-port "$ADMIN_PORT" \
                --db-path "$RESULTS_DIR/io_uring_compare_${variant}_${tag}.db" \
                >"$RESULTS_DIR/io_uring_compare_${variant}_${tag}.log" 2>&1 &
            ;;
        io_uring_proto)
            "$IOURING_BIN" \
                --listen "0.0.0.0:$PROXY_PORT" \
                --backend "127.0.0.1:$BACKEND_PORT" \
                >"$RESULTS_DIR/io_uring_compare_${variant}_${tag}.log" 2>&1 &
            ;;
        *)
            printf 'unknown variant: %s\n' "$variant" >&2
            exit 2
            ;;
    esac
    DAEMON_PID=$!
    wait_for_http "http://127.0.0.1:$PROXY_PORT/" || {
        printf '%s did not become ready\n' "$variant" >&2
        exit 1
    }
}

stop_variant() {
    if [ -n "${DAEMON_PID:-}" ]; then
        pkill -P "$DAEMON_PID" 2>/dev/null || true
        kill "$DAEMON_PID" 2>/dev/null || true
        wait "$DAEMON_PID" 2>/dev/null || true
        unset DAEMON_PID
    fi
}

run_one() {
    local variant=$1
    local scenario=$2
    local path
    local tag
    path=$(scenario_path "$scenario")
    tag="$(scenario_tag "$scenario")"

    log "running $variant / $scenario ($path)"
    start_variant "$variant" "$scenario"

    wrk -t"$IOURING_BENCH_THREADS" -c"$IOURING_BENCH_CONNS" \
        -d"${IOURING_BENCH_WARMUP}s" \
        "http://127.0.0.1:$PROXY_PORT$path" >/dev/null 2>&1

    local out="$RESULTS_DIR/io_uring_compare_${variant}_${tag}_wrk.txt"
    wrk -t"$IOURING_BENCH_THREADS" -c"$IOURING_BENCH_CONNS" \
        -d"${IOURING_BENCH_DURATION}s" --latency \
        "http://127.0.0.1:$PROXY_PORT$path" >"$out" 2>&1

    stop_variant

    local req transfer p50 p99
    req=$(awk '/Requests\/sec:/ {print $2}' "$out")
    transfer=$(awk '/Transfer\/sec:/ {print $2}' "$out")
    p50=$(awk '/ 50%/ {print $2}' "$out")
    p99=$(awk '/ 99%/ {print $2}' "$out")
    printf '%s,%s,%s,%s,%s,%s\n' "$scenario" "$variant" "$req" "$transfer" "$p50" "$p99" \
        >>"$RESULTS_DIR/io_uring_compare_summary.csv"
}

main() {
    if ! command -v wrk >/dev/null; then
        printf 'wrk not found\n' >&2
        exit 1
    fi
    if ! command -v curl >/dev/null; then
        printf 'curl not found\n' >&2
        exit 1
    fi

    mkdir -p "$RESULTS_DIR"
    trap cleanup EXIT
    cleanup

    log "building Rust daemon, backend, and io_uring prototype"
    cargo build --release --manifest-path "$ROOT_DIR/nitellad-rs/Cargo.toml" \
        --bin nitellad-rs --bin bench_backend --bin io_uring_splice_proxy

    log "starting backend on :$BACKEND_PORT"
    "$BACKEND_BIN" -port "$BACKEND_PORT" &
    BACKEND_PID=$!
    wait_for_http "http://127.0.0.1:$BACKEND_PORT/" || {
        printf 'backend did not become ready\n' >&2
        exit 1
    }

    printf 'scenario,variant,requests_per_sec,transfer_per_sec,p50,p99\n' \
        >"$RESULTS_DIR/io_uring_compare_summary.csv"

    IFS=',' read -r -a scenarios <<<"$IOURING_BENCH_SCENARIOS"
    for scenario in "${scenarios[@]}"; do
        run_one rust_epoll "$scenario"
        run_one io_uring_proto "$scenario"
    done

    log "summary:"
    cat "$RESULTS_DIR/io_uring_compare_summary.csv"
}

main "$@"
