#!/bin/bash
set -euo pipefail

# Short syscall-shape profile for the Rust Linux raw-TCP data path.
#
# This intentionally uses strace, so throughput/timing numbers from this script
# are not benchmark results. Use bench/benchmark.sh for performance numbers and
# use this script mainly for syscall counts.

CURRENT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT_DIR=$(dirname "$(dirname "$CURRENT_DIR")")
RESULTS_DIR="$CURRENT_DIR/results"
BACKEND_BIN_NAME="bench_backend"
BACKEND_BIN="$ROOT_DIR/nitellad-rs/target/release/$BACKEND_BIN_NAME"
RUST_BIN="$ROOT_DIR/nitellad-rs/target/release/nitellad-rs"

PROXY_PORT=${PROXY_PORT:-8081}
BACKEND_PORT=${BACKEND_PORT:-9090}
ADMIN_PORT=${ADMIN_PORT:-50051}

PROFILE_SCENARIO=${PROFILE_SCENARIO:-small_req}
PROFILE_THREADS=${PROFILE_THREADS:-4}
PROFILE_CONNS=${PROFILE_CONNS:-50}
PROFILE_WARMUP=${PROFILE_WARMUP:-2}
PROFILE_DURATION=${PROFILE_DURATION:-8}

LARGE_BYTES=${LARGE_BYTES:-1048576}
STREAM_CHUNKS=${STREAM_CHUNKS:-128}
STREAM_CHUNK_SIZE=${STREAM_CHUNK_SIZE:-8192}
STREAM_DELAY_MS=${STREAM_DELAY_MS:-0}

TRACE_SYSCALLS=${TRACE_SYSCALLS:-epoll_wait,epoll_ctl,splice,eventfd2,eventfd,read,write,recvfrom,sendto,accept4,connect,shutdown,close,futex}

log() {
    printf '[profile] %s\n' "$*"
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
            printf 'unknown profile scenario: %s\n' "$1" >&2
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
    pkill -f "target/release/$BACKEND_BIN_NAME -port $BACKEND_PORT" 2>/dev/null || true
}

wait_for_http() {
    local url=$1
    local i=0
    while [ "$i" -lt 20 ]; do
        if curl -sf "$url" -o /dev/null 2>/dev/null; then
            return 0
        fi
        sleep 0.25
        i=$((i + 1))
    done
    return 1
}

main() {
    if ! command -v strace >/dev/null; then
        printf 'strace not found\n' >&2
        exit 1
    fi
    if ! command -v wrk >/dev/null; then
        printf 'wrk not found\n' >&2
        exit 1
    fi

    mkdir -p "$RESULTS_DIR"
    trap cleanup EXIT

    log "building Rust daemon and backend"
    cargo build --release --manifest-path "$ROOT_DIR/nitellad-rs/Cargo.toml" --bin nitellad-rs --bin "$BACKEND_BIN_NAME"

    log "starting backend on :$BACKEND_PORT"
    "$BACKEND_BIN" -port "$BACKEND_PORT" &
    BACKEND_PID=$!
    wait_for_http "http://127.0.0.1:$BACKEND_PORT/" || {
        printf 'backend did not become ready\n' >&2
        exit 1
    }

    local path
    path=$(scenario_path "$PROFILE_SCENARIO")
    local tag
    tag="syscalls_$(scenario_tag "$PROFILE_SCENARIO")"
    local trace_out="$RESULTS_DIR/${tag}.txt"
    local wrk_out="$RESULTS_DIR/${tag}_wrk.txt"
    local log_out="$RESULTS_DIR/${tag}.log"
    local db_path="$RESULTS_DIR/${tag}.db"

    rm -f "$trace_out" "$wrk_out" "$log_out" "$db_path"

    log "starting Rust daemon under strace for scenario $PROFILE_SCENARIO ($path)"
    strace -f -c -e "trace=$TRACE_SYSCALLS" -o "$trace_out" \
        "$RUST_BIN" \
        --listen "0.0.0.0:$PROXY_PORT" \
        --backend "127.0.0.1:$BACKEND_PORT" \
        --admin-port "$ADMIN_PORT" \
        --db-path "$db_path" \
        >"$log_out" 2>&1 &
    DAEMON_PID=$!

    wait_for_http "http://127.0.0.1:$PROXY_PORT/" || {
        printf 'Rust daemon did not become ready\n' >&2
        exit 1
    }

    log "warmup ${PROFILE_WARMUP}s"
    wrk -t"$PROFILE_THREADS" -c"$PROFILE_CONNS" -d"${PROFILE_WARMUP}s" \
        "http://127.0.0.1:$PROXY_PORT$path" >/dev/null 2>&1

    log "load ${PROFILE_DURATION}s"
    wrk -t"$PROFILE_THREADS" -c"$PROFILE_CONNS" -d"${PROFILE_DURATION}s" --latency \
        "http://127.0.0.1:$PROXY_PORT$path" >"$wrk_out" 2>&1

    log "stopping daemon"
    pkill -P "$DAEMON_PID" 2>/dev/null || true
    kill "$DAEMON_PID" 2>/dev/null || true
    wait "$DAEMON_PID" 2>/dev/null || true
    unset DAEMON_PID

    log "wrote $trace_out"
    log "wrote $wrk_out"
}

main "$@"
