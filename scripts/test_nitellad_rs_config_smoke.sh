#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TMP_DIR="${NITELLA_RS_CONFIG_SMOKE_TMP:-$(mktemp -d "${TMPDIR:-/tmp}/nitella-rs-config-smoke.XXXXXX")}"
CONFIG_FILE="${TMP_DIR}/proxy.yaml"
LOG_FILE="${TMP_DIR}/nitellad-rs-config.log"
BACKEND_LOG="${TMP_DIR}/backend.log"
BACKEND_CAPTURE="${TMP_DIR}/backend-payloads.log"
PROXY_PORT="${NITELLA_RS_CONFIG_SMOKE_PROXY_PORT:-}"
BLOCK_PORT="${NITELLA_RS_CONFIG_SMOKE_BLOCK_PORT:-}"
BACKEND_PORT="${NITELLA_RS_CONFIG_SMOKE_BACKEND_PORT:-}"
DAEMON_PID=""
BACKEND_PID=""

cleanup() {
    if [[ -n "${DAEMON_PID}" ]] && kill -0 "${DAEMON_PID}" >/dev/null 2>&1; then
        kill "${DAEMON_PID}" >/dev/null 2>&1 || true
        wait "${DAEMON_PID}" >/dev/null 2>&1 || true
    fi
    if [[ -n "${BACKEND_PID}" ]] && kill -0 "${BACKEND_PID}" >/dev/null 2>&1; then
        kill "${BACKEND_PID}" >/dev/null 2>&1 || true
        wait "${BACKEND_PID}" >/dev/null 2>&1 || true
    fi
    if [[ -z "${NITELLA_RS_CONFIG_SMOKE_KEEP:-}" && -z "${NITELLA_RS_CONFIG_SMOKE_TMP:-}" ]]; then
        rm -rf "${TMP_DIR}"
    fi
}
trap cleanup EXIT

free_port() {
    python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1]); s.close()'
}

wait_for_port() {
    local port="$1"
    local label="$2"
    for _ in $(seq 1 100); do
        if bash -c ":</dev/tcp/127.0.0.1/${port}" >/dev/null 2>&1; then
            return 0
        fi
        sleep 0.1
    done
    echo "[config-smoke] timed out waiting for ${label} on 127.0.0.1:${port}"
    return 1
}

cd "${PROJECT_ROOT}"
mkdir -p "${TMP_DIR}"

if [[ -z "${PROXY_PORT}" ]]; then
    PROXY_PORT="$(free_port)"
fi
if [[ -z "${BLOCK_PORT}" ]]; then
    BLOCK_PORT="$(free_port)"
fi
if [[ -z "${BACKEND_PORT}" ]]; then
    BACKEND_PORT="$(free_port)"
fi
: >"${BACKEND_CAPTURE}"

cat >"${CONFIG_FILE}" <<YAML
entryPoints:
  config-smoke:
    address: "127.0.0.1:${PROXY_PORT}"
    defaultAction: allow
  config-block:
    address: "127.0.0.1:${BLOCK_PORT}"
    defaultAction: block

tcp:
  routers:
    config-smoke-router:
      entryPoints: ["config-smoke"]
      service: config-smoke-backend
    config-block-router:
      entryPoints: ["config-block"]
      service: config-smoke-backend
  services:
    config-smoke-backend:
      loadBalancer:
        servers:
          - address: "127.0.0.1:${BACKEND_PORT}"
YAML

python3 - "${BACKEND_PORT}" "${BACKEND_CAPTURE}" >"${BACKEND_LOG}" 2>&1 <<'PY' &
import socket
import sys
import threading

port = int(sys.argv[1])
capture_path = sys.argv[2]
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind(("127.0.0.1", port))
server.listen()

def handle(conn):
    with conn:
        conn.settimeout(3)
        data = conn.recv(4096)
        if data:
            with open(capture_path, "ab") as capture:
                capture.write(data + b"\n")
            conn.sendall(b"echo:" + data)

while True:
    conn, _ = server.accept()
    threading.Thread(target=handle, args=(conn,), daemon=True).start()
PY
BACKEND_PID="$!"

wait_for_port "${BACKEND_PORT}" "echo backend" || {
    sed -n '1,120p' "${BACKEND_LOG}" || true
    exit 1
}

echo "[config-smoke] building nitellad-rs"
cargo build --manifest-path nitellad-rs/Cargo.toml --quiet

echo "[config-smoke] starting nitellad-rs with ${CONFIG_FILE}"
nitellad-rs/target/debug/nitellad-rs \
    --config "${CONFIG_FILE}" \
    --db-path "${TMP_DIR}/nitella.db" \
    --stats-db "${TMP_DIR}/stats.db" \
    --geoip-cache "${TMP_DIR}/geoip_cache.db" \
    >"${LOG_FILE}" 2>&1 &
DAEMON_PID="$!"

for _ in $(seq 1 100); do
    if ! kill -0 "${DAEMON_PID}" >/dev/null 2>&1; then
        echo "[config-smoke] nitellad-rs exited early"
        sed -n '1,220p' "${LOG_FILE}" || true
        exit 1
    fi
    if bash -c ":</dev/tcp/127.0.0.1/${PROXY_PORT}" >/dev/null 2>&1; then
        break
    fi
    sleep 0.1
done

wait_for_port "${PROXY_PORT}" "configured proxy" || {
    sed -n '1,220p' "${LOG_FILE}" || true
    exit 1
}
wait_for_port "${BLOCK_PORT}" "configured block proxy" || {
    sed -n '1,220p' "${LOG_FILE}" || true
    exit 1
}

echo "[config-smoke] running traffic through config-created Rust proxies"
NITELLA_RS_CONFIG_PROXY_ADDR="127.0.0.1:${PROXY_PORT}" \
NITELLA_RS_CONFIG_BLOCK_PROXY_ADDR="127.0.0.1:${BLOCK_PORT}" \
NITELLA_RS_CONFIG_BACKEND_CAPTURE="${BACKEND_CAPTURE}" \
go test ./pkg/core -run 'TestRustConfig(ProxyTrafficSmoke|BlockProxySmoke)$' -count=1

echo "[config-smoke] config-created Rust proxies enforced allow/block defaults"
