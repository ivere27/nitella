#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TMP_DIR="${NITELLA_RS_RELEASE_SMOKE_TMP:-$(mktemp -d "${TMPDIR:-/tmp}/nitella-rs-release-smoke.XXXXXX")}"
ADMIN_DIR="${TMP_DIR}/admin"
LOG_FILE="${TMP_DIR}/nitellad-rs-release.log"
BACKEND_LOG="${TMP_DIR}/backend.log"
HELP_FILE="${TMP_DIR}/help.txt"
TOKEN="${NITELLA_RS_RELEASE_SMOKE_TOKEN:-nitella-rs-release-smoke-token}"
PROXY_PORT="${NITELLA_RS_RELEASE_SMOKE_PROXY_PORT:-}"
ADMIN_PORT="${NITELLA_RS_RELEASE_SMOKE_ADMIN_PORT:-}"
BACKEND_PORT="${NITELLA_RS_RELEASE_SMOKE_BACKEND_PORT:-}"
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
    if [[ -z "${NITELLA_RS_RELEASE_SMOKE_KEEP:-}" && -z "${NITELLA_RS_RELEASE_SMOKE_TMP:-}" ]]; then
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
    echo "[release-smoke] timed out waiting for ${label} on 127.0.0.1:${port}"
    return 1
}

cd "${PROJECT_ROOT}"
mkdir -p "${ADMIN_DIR}"

if [[ -z "${PROXY_PORT}" ]]; then
    PROXY_PORT="$(free_port)"
fi
if [[ -z "${ADMIN_PORT}" ]]; then
    ADMIN_PORT="$(free_port)"
fi
if [[ -z "${BACKEND_PORT}" ]]; then
    BACKEND_PORT="$(free_port)"
fi

python3 - "${BACKEND_PORT}" >"${BACKEND_LOG}" 2>&1 <<'PY' &
import socket
import sys
import threading

port = int(sys.argv[1])
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind(("127.0.0.1", port))
server.listen()

def handle(conn):
    with conn:
        conn.settimeout(3)
        data = conn.recv(4096)
        if data:
            conn.sendall(b"echo:" + data)

while True:
    conn, _ = server.accept()
    threading.Thread(target=handle, args=(conn,), daemon=True).start()
PY
BACKEND_PID="$!"

wait_for_port "${BACKEND_PORT}" "echo backend" || {
    sed -n '1,160p' "${BACKEND_LOG}" || true
    exit 1
}

echo "[release-smoke] building release nitellad-rs"
cargo build --release --manifest-path nitellad-rs/Cargo.toml --quiet
BIN="${PROJECT_ROOT}/nitellad-rs/target/release/nitellad-rs"

"${BIN}" --help >"${HELP_FILE}"
for flag in --listen --backend --default-action --allow-ip --block-ip --allow-country --block-country --config --admin-port --admin-token --process-mode --geoip-city --geoip-isp --pair-offline; do
    if ! grep -q -- "${flag}" "${HELP_FILE}"; then
        echo "[release-smoke] release binary help missing ${flag}"
        sed -n '1,220p' "${HELP_FILE}" || true
        exit 1
    fi
done

echo "[release-smoke] starting release nitellad-rs with CLI proxy and admin TLS"
"${BIN}" \
    --listen "127.0.0.1:${PROXY_PORT}" \
    --backend "127.0.0.1:${BACKEND_PORT}" \
    --admin-port "${ADMIN_PORT}" \
    --admin-token "${TOKEN}" \
    --admin-data-dir "${ADMIN_DIR}" \
    --db-path "${TMP_DIR}/nitella.db" \
    --stats-db "${TMP_DIR}/stats.db" \
    --geoip-cache "${TMP_DIR}/geoip_cache.db" \
    >"${LOG_FILE}" 2>&1 &
DAEMON_PID="$!"

for _ in $(seq 1 100); do
    if ! kill -0 "${DAEMON_PID}" >/dev/null 2>&1; then
        echo "[release-smoke] nitellad-rs exited early"
        sed -n '1,260p' "${LOG_FILE}" || true
        exit 1
    fi
    if [[ -f "${ADMIN_DIR}/admin_ca.crt" ]] \
        && bash -c ":</dev/tcp/127.0.0.1/${PROXY_PORT}" >/dev/null 2>&1 \
        && bash -c ":</dev/tcp/127.0.0.1/${ADMIN_PORT}" >/dev/null 2>&1; then
        break
    fi
    sleep 0.1
done

wait_for_port "${PROXY_PORT}" "release proxy" || {
    sed -n '1,260p' "${LOG_FILE}" || true
    exit 1
}
wait_for_port "${ADMIN_PORT}" "release admin" || {
    sed -n '1,260p' "${LOG_FILE}" || true
    exit 1
}
if [[ ! -f "${ADMIN_DIR}/admin_ca.crt" ]]; then
    echo "[release-smoke] admin CA was not generated"
    sed -n '1,260p' "${LOG_FILE}" || true
    exit 1
fi

echo "[release-smoke] checking release proxy traffic and admin status"
NITELLA_RS_CONFIG_PROXY_ADDR="127.0.0.1:${PROXY_PORT}" \
go test ./pkg/core -run 'TestRustConfigProxyTrafficSmoke$' -count=1

export NITELLA_RS_ADMIN_ADDR="127.0.0.1:${ADMIN_PORT}"
export NITELLA_RS_ADMIN_TOKEN="${TOKEN}"
export NITELLA_RS_ADMIN_CA="${ADMIN_DIR}/admin_ca.crt"
export NITELLA_RS_ADMIN_TLS_SERVER_NAME="localhost"
go test ./pkg/core -run 'TestRustDirectAdminSmoke$' -count=1

echo "[release-smoke] checking graceful SIGTERM shutdown"
kill "${DAEMON_PID}"
wait "${DAEMON_PID}"
DAEMON_PID=""

echo "[release-smoke] release binary started, served traffic, exposed admin TLS, and shut down cleanly"
