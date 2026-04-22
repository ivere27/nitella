#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TMP_DIR="${NITELLA_RS_PERSIST_SMOKE_TMP:-$(mktemp -d "${TMPDIR:-/tmp}/nitella-rs-persist-smoke.XXXXXX")}"
ADMIN_DIR="${TMP_DIR}/admin"
HUB_DIR="${TMP_DIR}/hub"
DB_PATH="${TMP_DIR}/nitella.db"
STATS_DB="${TMP_DIR}/stats.db"
GEOIP_CACHE="${TMP_DIR}/geoip_cache.db"
LOG_ONE="${TMP_DIR}/nitellad-rs-first.log"
LOG_TWO="${TMP_DIR}/nitellad-rs-second.log"
BACKEND_LOG="${TMP_DIR}/backend.log"
TOKEN="${NITELLA_RS_PERSIST_SMOKE_TOKEN:-nitella-rs-persistence-smoke-token}"
ADMIN_PORT="${NITELLA_RS_PERSIST_SMOKE_ADMIN_PORT:-}"
BACKEND_PORT="${NITELLA_RS_PERSIST_SMOKE_BACKEND_PORT:-}"
FIRST_PID=""
SECOND_PID=""
BACKEND_PID=""

cleanup() {
    for pid in "${FIRST_PID}" "${SECOND_PID}" "${BACKEND_PID}"; do
        if [[ -n "${pid}" ]] && kill -0 "${pid}" >/dev/null 2>&1; then
            kill "${pid}" >/dev/null 2>&1 || true
            wait "${pid}" >/dev/null 2>&1 || true
        fi
    done
    if [[ -z "${NITELLA_RS_PERSIST_SMOKE_KEEP:-}" && -z "${NITELLA_RS_PERSIST_SMOKE_TMP:-}" ]]; then
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
    echo "[persist-smoke] timed out waiting for ${label} on 127.0.0.1:${port}"
    return 1
}

start_daemon() {
    local log_file="$1"
    nitellad-rs/target/debug/nitellad-rs \
        --hub "127.0.0.1:9" \
        --hub-data-dir "${HUB_DIR}" \
        --admin-port "${ADMIN_PORT}" \
        --admin-token "${TOKEN}" \
        --admin-data-dir "${ADMIN_DIR}" \
        --db-path "${DB_PATH}" \
        --stats-db "${STATS_DB}" \
        --geoip-cache "${GEOIP_CACHE}" \
        >"${log_file}" 2>&1 &
    echo "$!"
}

stop_daemon() {
    local pid="$1"
    if [[ -n "${pid}" ]] && kill -0 "${pid}" >/dev/null 2>&1; then
        kill "${pid}" >/dev/null 2>&1 || true
        wait "${pid}" >/dev/null 2>&1 || true
    fi
}

cd "${PROJECT_ROOT}"
mkdir -p "${ADMIN_DIR}" "${HUB_DIR}"

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
    sed -n '1,120p' "${BACKEND_LOG}" || true
    exit 1
}

echo "[persist-smoke] building nitellad-rs"
cargo build --manifest-path nitellad-rs/Cargo.toml --quiet

echo "[persist-smoke] starting first nitellad-rs instance on admin port ${ADMIN_PORT}"
FIRST_PID="$(start_daemon "${LOG_ONE}")"
for _ in $(seq 1 100); do
    if ! kill -0 "${FIRST_PID}" >/dev/null 2>&1; then
        echo "[persist-smoke] first nitellad-rs exited early"
        sed -n '1,220p' "${LOG_ONE}" || true
        exit 1
    fi
    if [[ -f "${ADMIN_DIR}/admin_ca.crt" ]] && bash -c ":</dev/tcp/127.0.0.1/${ADMIN_PORT}" >/dev/null 2>&1; then
        break
    fi
    sleep 0.1
done

wait_for_port "${ADMIN_PORT}" "first admin server" || {
    sed -n '1,220p' "${LOG_ONE}" || true
    exit 1
}

echo "[persist-smoke] creating proxy through Go admin client"
NITELLA_RS_ADMIN_ADDR="127.0.0.1:${ADMIN_PORT}" \
NITELLA_RS_ADMIN_TOKEN="${TOKEN}" \
NITELLA_RS_ADMIN_CA="${ADMIN_DIR}/admin_ca.crt" \
NITELLA_RS_ADMIN_TLS_SERVER_NAME="localhost" \
NITELLA_RS_PERSIST_BACKEND_ADDR="127.0.0.1:${BACKEND_PORT}" \
go test ./pkg/core -run TestRustDirectProxyPersistenceSeed -count=1

echo "[persist-smoke] restarting nitellad-rs with same DB and admin data"
stop_daemon "${FIRST_PID}"
FIRST_PID=""
SECOND_PID="$(start_daemon "${LOG_TWO}")"
for _ in $(seq 1 100); do
    if ! kill -0 "${SECOND_PID}" >/dev/null 2>&1; then
        echo "[persist-smoke] second nitellad-rs exited early"
        sed -n '1,220p' "${LOG_TWO}" || true
        exit 1
    fi
    if bash -c ":</dev/tcp/127.0.0.1/${ADMIN_PORT}" >/dev/null 2>&1; then
        break
    fi
    sleep 0.1
done

wait_for_port "${ADMIN_PORT}" "second admin server" || {
    sed -n '1,220p' "${LOG_TWO}" || true
    exit 1
}

echo "[persist-smoke] checking restored proxy through Go admin client and live TCP"
NITELLA_RS_ADMIN_ADDR="127.0.0.1:${ADMIN_PORT}" \
NITELLA_RS_ADMIN_TOKEN="${TOKEN}" \
NITELLA_RS_ADMIN_CA="${ADMIN_DIR}/admin_ca.crt" \
NITELLA_RS_ADMIN_TLS_SERVER_NAME="localhost" \
go test ./pkg/core -run TestRustDirectProxyRestoredTrafficSmoke -count=1

echo "[persist-smoke] restarted nitellad-rs restored persisted proxy traffic"
