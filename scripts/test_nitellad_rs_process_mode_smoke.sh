#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TMP_DIR="${NITELLA_RS_PROCESS_SMOKE_TMP:-$(mktemp -d "${TMPDIR:-/tmp}/nitella-rs-process-smoke.XXXXXX")}"
ADMIN_DIR="${TMP_DIR}/admin"
CONFIG_FILE="${TMP_DIR}/process-admin-only.yaml"
LOG_FILE="${TMP_DIR}/nitellad-rs-process.log"
TOKEN="${NITELLA_RS_PROCESS_SMOKE_TOKEN:-nitella-rs-process-mode-smoke-token}"
PORT="${NITELLA_RS_PROCESS_SMOKE_PORT:-}"
PID=""

cleanup() {
    if [[ -n "${PID}" ]] && kill -0 "${PID}" >/dev/null 2>&1; then
        kill "${PID}" >/dev/null 2>&1 || true
        wait "${PID}" >/dev/null 2>&1 || true
    fi
    if [[ -z "${NITELLA_RS_PROCESS_SMOKE_KEEP:-}" && -z "${NITELLA_RS_PROCESS_SMOKE_TMP:-}" ]]; then
        rm -rf "${TMP_DIR}"
    fi
}
trap cleanup EXIT

cd "${PROJECT_ROOT}"
mkdir -p "${ADMIN_DIR}"
printf '{}\n' >"${CONFIG_FILE}"

if [[ -z "${PORT}" ]]; then
    PORT="$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1]); s.close()')"
fi

echo "[process-smoke] building nitellad-rs"
cargo build --manifest-path nitellad-rs/Cargo.toml --quiet

echo "[process-smoke] starting nitellad-rs process mode on admin port ${PORT}"
nitellad-rs/target/debug/nitellad-rs \
    --process-mode \
    --config "${CONFIG_FILE}" \
    --admin-port "${PORT}" \
    --admin-token "${TOKEN}" \
    --admin-data-dir "${ADMIN_DIR}" \
    --db-path "${TMP_DIR}/nitella.db" \
    --stats-db "${TMP_DIR}/stats.db" \
    --geoip-cache "${TMP_DIR}/geoip_cache.db" \
    >"${LOG_FILE}" 2>&1 &
PID="$!"

for _ in $(seq 1 100); do
    if ! kill -0 "${PID}" >/dev/null 2>&1; then
        echo "[process-smoke] nitellad-rs exited early"
        sed -n '1,260p' "${LOG_FILE}" || true
        exit 1
    fi
    if [[ -f "${ADMIN_DIR}/admin_ca.crt" ]] && bash -c ":</dev/tcp/127.0.0.1/${PORT}" >/dev/null 2>&1; then
        break
    fi
    sleep 0.1
done

if [[ ! -f "${ADMIN_DIR}/admin_ca.crt" ]]; then
    echo "[process-smoke] admin CA was not generated"
    sed -n '1,260p' "${LOG_FILE}" || true
    exit 1
fi

echo "[process-smoke] running Go local proxy client against process-mode nitellad-rs"
export NITELLA_RS_ADMIN_ADDR="127.0.0.1:${PORT}"
export NITELLA_RS_ADMIN_TOKEN="${TOKEN}"
export NITELLA_RS_ADMIN_CA="${ADMIN_DIR}/admin_ca.crt"
export NITELLA_RS_ADMIN_TLS_SERVER_NAME="localhost"
go test ./pkg/core -run 'TestRustDirectProxyTrafficSmoke$' -count=1
go test ./pkg/core -run 'TestRustDirectConnectionManagementSmoke$' -count=1

echo "[process-smoke] process-mode Rust proxy forwarded traffic and managed live connections"
