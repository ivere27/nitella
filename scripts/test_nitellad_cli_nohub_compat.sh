#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TMP_DIR="${NITELLA_CLI_NOHUB_TMP:-$(mktemp -d "${TMPDIR:-/tmp}/nitella-cli-nohub.XXXXXX")}"
BIN_DIR="${TMP_DIR}/bin"
BACKEND_DIR="${TMP_DIR}/backend-root"
BACKEND_LOG="${TMP_DIR}/backend.log"
TOKEN="${NITELLA_CLI_NOHUB_TOKEN:-nitella-cli-nohub-token}"
EXPECTED_BODY="${NITELLA_CLI_NOHUB_BODY:-nitella-cli-nohub-backend}"
KEEP_TMP="${NITELLA_CLI_NOHUB_KEEP:-}"

BACKEND_PID=""
DAEMON_PID=""

cleanup() {
    if [[ -n "${DAEMON_PID}" ]] && kill -0 "${DAEMON_PID}" >/dev/null 2>&1; then
        kill "${DAEMON_PID}" >/dev/null 2>&1 || true
        wait "${DAEMON_PID}" >/dev/null 2>&1 || true
    fi
    if [[ -n "${BACKEND_PID}" ]] && kill -0 "${BACKEND_PID}" >/dev/null 2>&1; then
        kill "${BACKEND_PID}" >/dev/null 2>&1 || true
        wait "${BACKEND_PID}" >/dev/null 2>&1 || true
    fi
    if [[ -z "${KEEP_TMP}" && -z "${NITELLA_CLI_NOHUB_TMP:-}" ]]; then
        rm -rf "${TMP_DIR}"
    else
        echo "[cli-nohub] kept temp dir: ${TMP_DIR}"
    fi
}
trap cleanup EXIT

free_port() {
    python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1]); s.close()'
}

wait_tcp() {
    local host="$1"
    local port="$2"
    local label="$3"
    local log_file="${4:-}"

    for _ in $(seq 1 100); do
        if bash -c ":</dev/tcp/${host}/${port}" >/dev/null 2>&1; then
            return 0
        fi
        if [[ -n "${DAEMON_PID}" ]] && ! kill -0 "${DAEMON_PID}" >/dev/null 2>&1; then
            echo "[cli-nohub] ${label} exited early"
            if [[ -n "${log_file}" ]]; then
                sed -n '1,220p' "${log_file}" || true
            fi
            exit 1
        fi
        sleep 0.1
    done

    echo "[cli-nohub] timed out waiting for ${label} on ${host}:${port}"
    if [[ -n "${log_file}" ]]; then
        sed -n '1,220p' "${log_file}" || true
    fi
    exit 1
}

wait_file() {
    local path="$1"
    local label="$2"
    local log_file="$3"

    for _ in $(seq 1 100); do
        if [[ -f "${path}" ]]; then
            return 0
        fi
        if [[ -n "${DAEMON_PID}" ]] && ! kill -0 "${DAEMON_PID}" >/dev/null 2>&1; then
            echo "[cli-nohub] ${label} exited early"
            sed -n '1,220p' "${log_file}" || true
            exit 1
        fi
        sleep 0.1
    done

    echo "[cli-nohub] timed out waiting for ${label}: ${path}"
    sed -n '1,220p' "${log_file}" || true
    exit 1
}

run_cli() {
    local label="$1"
    local admin_port="$2"
    local admin_dir="$3"
    local data_dir="$4"
    shift 4

    "${BIN_DIR}/nitella" \
        --local \
        --data-dir "${data_dir}" \
        --addr "127.0.0.1:${admin_port}" \
        --token "${TOKEN}" \
        --tls-ca "${admin_dir}/admin_ca.crt" \
        "$@" >"${TMP_DIR}/${label}.out" 2>"${TMP_DIR}/${label}.err"
}

curl_body() {
    local port="$1"
    curl -fsS --max-time 3 "http://127.0.0.1:${port}/"
}

assert_body() {
    local label="$1"
    local port="$2"
    local body

    body="$(curl_body "${port}")"
    if [[ "${body}" != "${EXPECTED_BODY}" ]]; then
        echo "[cli-nohub] ${label}: unexpected body ${body@Q}, want ${EXPECTED_BODY@Q}"
        exit 1
    fi
}

assert_blocked() {
    local label="$1"
    local port="$2"
    local body=""

    if body="$(curl_body "${port}" 2>/dev/null)"; then
        if [[ "${body}" == "${EXPECTED_BODY}" ]]; then
            echo "[cli-nohub] ${label}: request unexpectedly reached backend"
            exit 1
        fi
    fi
}

stop_daemon() {
    if [[ -n "${DAEMON_PID}" ]] && kill -0 "${DAEMON_PID}" >/dev/null 2>&1; then
        kill "${DAEMON_PID}" >/dev/null 2>&1 || true
        wait "${DAEMON_PID}" >/dev/null 2>&1 || true
    fi
    DAEMON_PID=""
}

run_variant() {
    local variant="$1"
    local daemon_bin="$2"

    local work_dir="${TMP_DIR}/${variant}"
    local admin_dir="${work_dir}/admin"
    local cli_data_dir="${work_dir}/cli-data"
    local config_file="${work_dir}/admin-only.yaml"
    local daemon_log="${work_dir}/daemon.log"
    local summary_file="${work_dir}/summary.txt"
    local admin_port
    local proxy_port

    admin_port="$(free_port)"
    proxy_port="$(free_port)"
    mkdir -p "${admin_dir}" "${cli_data_dir}"
    printf '{}\n' >"${config_file}"

    echo "[cli-nohub] starting ${variant} nitellad admin-only on 127.0.0.1:${admin_port}"
    "${daemon_bin}" \
        --config "${config_file}" \
        --admin-port "${admin_port}" \
        --admin-token "${TOKEN}" \
        --admin-data-dir "${admin_dir}" \
        --db-path "${work_dir}/nitella.db" \
        --stats-db "${work_dir}/stats.db" \
        --geoip-cache "${work_dir}/geoip_cache.db" \
        --geoip-strategy "l1,l2,local" \
        >"${daemon_log}" 2>&1 &
    DAEMON_PID="$!"

    wait_file "${admin_dir}/admin_ca.crt" "${variant} admin CA" "${daemon_log}"
    wait_tcp "127.0.0.1" "${admin_port}" "${variant} admin" "${daemon_log}"

    run_cli "${variant}.prime" "${admin_port}" "${admin_dir}" "${cli_data_dir}" help

    run_cli "${variant}.status-empty" "${admin_port}" "${admin_dir}" "${cli_data_dir}" status
    if ! grep -q 'No proxies running.' "${TMP_DIR}/${variant}.status-empty.out"; then
        echo "[cli-nohub] ${variant}: expected empty status before proxy create"
        cat "${TMP_DIR}/${variant}.status-empty.out"
        exit 1
    fi

    echo "[cli-nohub] creating ${variant} proxy via nitella CLI on 127.0.0.1:${proxy_port}"
    run_cli "${variant}.create" "${admin_port}" "${admin_dir}" "${cli_data_dir}" \
        proxy create "127.0.0.1:${proxy_port}" "127.0.0.1:${BACKEND_PORT}" "cli-nohub"

    local proxy_id
    proxy_id="$(awk '/Proxy created:/ {print $3}' "${TMP_DIR}/${variant}.create.out")"
    if [[ -z "${proxy_id}" ]]; then
        echo "[cli-nohub] ${variant}: failed to parse proxy id"
        cat "${TMP_DIR}/${variant}.create.out"
        exit 1
    fi

    wait_tcp "127.0.0.1" "${proxy_port}" "${variant} proxy" "${daemon_log}"

    run_cli "${variant}.status-created" "${admin_port}" "${admin_dir}" "${cli_data_dir}" status "${proxy_id}"
    grep -q 'Running:           true' "${TMP_DIR}/${variant}.status-created.out"
    grep -q "Default Backend:   127.0.0.1:${BACKEND_PORT}" "${TMP_DIR}/${variant}.status-created.out"
    assert_body "${variant} allow traffic" "${proxy_port}"

    run_cli "${variant}.rule-add" "${admin_port}" "${admin_dir}" "${cli_data_dir}" \
        rule add "${proxy_id}" block 127.0.0.1
    grep -q 'Block rule created for 127.0.0.1' "${TMP_DIR}/${variant}.rule-add.out"

    run_cli "${variant}.rule-list-block" "${admin_port}" "${admin_dir}" "${cli_data_dir}" rule list "${proxy_id}"
    local block_rule_id
    block_rule_id="$(awk '$0 ~ /ACTION_TYPE_BLOCK/ {print $1; exit}' "${TMP_DIR}/${variant}.rule-list-block.out")"
    if [[ -z "${block_rule_id}" ]]; then
        echo "[cli-nohub] ${variant}: failed to find block rule"
        cat "${TMP_DIR}/${variant}.rule-list-block.out"
        exit 1
    fi
    assert_blocked "${variant} block rule" "${proxy_port}"

    run_cli "${variant}.rule-remove" "${admin_port}" "${admin_dir}" "${cli_data_dir}" \
        rule remove "${proxy_id}" "${block_rule_id}"
    grep -q 'Rule removed.' "${TMP_DIR}/${variant}.rule-remove.out"
    assert_body "${variant} after block rule removal" "${proxy_port}"

    run_cli "${variant}.disable" "${admin_port}" "${admin_dir}" "${cli_data_dir}" proxy disable "${proxy_id}"
    grep -q 'Proxy disabled.' "${TMP_DIR}/${variant}.disable.out"
    assert_blocked "${variant} disabled proxy" "${proxy_port}"

    run_cli "${variant}.enable" "${admin_port}" "${admin_dir}" "${cli_data_dir}" proxy enable "${proxy_id}"
    grep -q 'Proxy enabled.' "${TMP_DIR}/${variant}.enable.out"
    wait_tcp "127.0.0.1" "${proxy_port}" "${variant} re-enabled proxy" "${daemon_log}"
    assert_body "${variant} after enable" "${proxy_port}"

    run_cli "${variant}.delete" "${admin_port}" "${admin_dir}" "${cli_data_dir}" proxy delete "${proxy_id}"
    grep -q 'Proxy deleted.' "${TMP_DIR}/${variant}.delete.out"
    run_cli "${variant}.status-deleted" "${admin_port}" "${admin_dir}" "${cli_data_dir}" status
    grep -q "${proxy_id}" "${TMP_DIR}/${variant}.status-deleted.out"
    grep -q 'stopped' "${TMP_DIR}/${variant}.status-deleted.out"
    assert_blocked "${variant} after delete" "${proxy_port}"

    {
        echo "status_empty=No proxies running."
        echo "create=ok"
        echo "status_created=running backend=shared"
        echo "traffic_allow=${EXPECTED_BODY}"
        echo "block_rule=blocked"
        echo "traffic_after_rule_remove=${EXPECTED_BODY}"
        echo "disable=blocked"
        echo "enable=${EXPECTED_BODY}"
        echo "delete=stopped"
    } >"${summary_file}"

    stop_daemon
    echo "[cli-nohub] ${variant} summary:"
    sed 's/^/[cli-nohub]   /' "${summary_file}"
}

cd "${PROJECT_ROOT}"
mkdir -p "${BIN_DIR}" "${BACKEND_DIR}"
printf '%s\n' "${EXPECTED_BODY}" >"${BACKEND_DIR}/index.html"

if [[ -z "${GOCACHE:-}" ]]; then
    export GOCACHE="${TMP_DIR}/go-build-cache"
fi
mkdir -p "${GOCACHE}"

echo "[cli-nohub] building nitella CLI and Go nitellad"
go build -o "${BIN_DIR}/nitella" ./cmd/nitella
go build -o "${BIN_DIR}/nitellad" ./cmd/nitellad

echo "[cli-nohub] building nitellad-rs"
cargo build --manifest-path nitellad-rs/Cargo.toml --quiet

BACKEND_PORT="$(free_port)"
echo "[cli-nohub] starting shared backend on 127.0.0.1:${BACKEND_PORT}"
python3 -m http.server "${BACKEND_PORT}" --bind 127.0.0.1 --directory "${BACKEND_DIR}" >"${BACKEND_LOG}" 2>&1 &
BACKEND_PID="$!"
wait_tcp "127.0.0.1" "${BACKEND_PORT}" "shared backend" "${BACKEND_LOG}"

run_variant go "${BIN_DIR}/nitellad"
run_variant rust "${PROJECT_ROOT}/nitellad-rs/target/debug/nitellad-rs"

echo "[cli-nohub] comparing normalized Go/Rust CLI behavior"
diff -u "${TMP_DIR}/go/summary.txt" "${TMP_DIR}/rust/summary.txt"

echo "[cli-nohub] nitella CLI no-Hub behavior matched for Go nitellad and nitellad-rs"
