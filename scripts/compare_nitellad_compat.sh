#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TMP_DIR="${NITELLA_COMPAT_TMP:-$(mktemp -d "${TMPDIR:-/tmp}/nitella-compat.XXXXXX")}"
GO_JSON="${TMP_DIR}/go.json"
RUST_JSON="${TMP_DIR}/rust.json"
ADMIN_FIXTURE_JSON="${TMP_DIR}/admin_crypto_fixture.json"
ADMIN_RESPONSE_JSON="${TMP_DIR}/admin_crypto_rust_response.json"

cleanup() {
    if [[ -z "${NITELLA_COMPAT_KEEP:-}" && -z "${NITELLA_COMPAT_TMP:-}" ]]; then
        rm -rf "${TMP_DIR}"
    fi
}
trap cleanup EXIT

cd "${PROJECT_ROOT}"
if [[ -z "${GOCACHE:-}" ]]; then
    export GOCACHE="${TMP_DIR}/go-build-cache"
    mkdir -p "${GOCACHE}"
fi

if [[ "${NITELLA_COMPAT_SKIP_UNIT:-}" != "1" ]]; then
    echo "[compat] checking Rust unit coverage"
    cargo test --manifest-path nitellad-rs/Cargo.toml

    echo "[compat] checking Go node and mobile-service unit coverage"
    go test ./pkg/node ./pkg/service
fi

if [[ "${NITELLA_COMPAT_SKIP_WINDOWS:-}" != "1" ]]; then
    if rustup target list --installed | grep -qx 'x86_64-pc-windows-gnu'; then
        echo "[compat] checking nitellad-rs Windows target compile"
        cargo check --manifest-path nitellad-rs/Cargo.toml --target x86_64-pc-windows-gnu
    elif [[ "${NITELLA_COMPAT_REQUIRE_WINDOWS:-}" == "1" ]]; then
        echo "[compat] x86_64-pc-windows-gnu target is required but not installed"
        exit 1
    else
        echo "[compat] skipping Windows target compile; install x86_64-pc-windows-gnu or set NITELLA_COMPAT_REQUIRE_WINDOWS=1"
    fi
fi

echo "[compat] dumping Go nitellad command behavior"
NITELLA_COMPAT_DUMP="${GO_JSON}" go test ./cmd/nitellad -run TestCompatHarnessDumpGo -count=1

echo "[compat] dumping Rust nitellad-rs command behavior"
NITELLA_COMPAT_DUMP="${RUST_JSON}" cargo test --manifest-path nitellad-rs/Cargo.toml compat_harness_dump_rust -- --nocapture

python3 - "$GO_JSON" "$RUST_JSON" <<'PY'
import difflib
import json
import sys
from pathlib import Path

go_path = Path(sys.argv[1])
rust_path = Path(sys.argv[2])

go = json.loads(go_path.read_text())
rust = json.loads(rust_path.read_text())

if go != rust:
    go_text = json.dumps(go, indent=2, sort_keys=True).splitlines(keepends=True)
    rust_text = json.dumps(rust, indent=2, sort_keys=True).splitlines(keepends=True)
    sys.stdout.writelines(difflib.unified_diff(
        go_text,
        rust_text,
        fromfile=str(go_path),
        tofile=str(rust_path),
    ))
    sys.exit(1)

print(f"[compat] matched {len(go)} normalized command cases")
PY

echo "[compat] checking Go -> Rust -> Go admin crypto envelope"
NITELLA_ADMIN_COMPAT_FIXTURE="${ADMIN_FIXTURE_JSON}" go test ./cmd/nitellad -run TestAdminCryptoCompatFixtureGo -count=1
NITELLA_ADMIN_COMPAT_FIXTURE="${ADMIN_FIXTURE_JSON}" NITELLA_ADMIN_COMPAT_RESPONSE="${ADMIN_RESPONSE_JSON}" cargo test --manifest-path nitellad-rs/Cargo.toml admin_crypto_compat_fixture_go_request_rust_response -- --nocapture
NITELLA_ADMIN_COMPAT_FIXTURE="${ADMIN_FIXTURE_JSON}" NITELLA_ADMIN_COMPAT_RESPONSE="${ADMIN_RESPONSE_JSON}" go test ./cmd/nitellad -run TestAdminCryptoCompatVerifyRustResponseGo -count=1
echo "[compat] admin crypto envelope matched"

if [[ "${NITELLA_COMPAT_SKIP_LIVE:-}" != "1" ]]; then
    echo "[compat] checking live nitellad-rs admin server with Go local client"
    NITELLA_RS_ADMIN_SMOKE_TMP="${NITELLA_RS_ADMIN_SMOKE_TMP:-${TMP_DIR}/live-admin-smoke}" \
        bash scripts/test_nitellad_rs_direct_admin_smoke.sh

    echo "[compat] checking nitellad-rs process-mode proxy traffic"
    NITELLA_RS_PROCESS_SMOKE_TMP="${NITELLA_RS_PROCESS_SMOKE_TMP:-${TMP_DIR}/process-smoke}" \
        bash scripts/test_nitellad_rs_process_mode_smoke.sh

    echo "[compat] checking nitellad-rs config-file startup traffic"
    NITELLA_RS_CONFIG_SMOKE_TMP="${NITELLA_RS_CONFIG_SMOKE_TMP:-${TMP_DIR}/config-smoke}" \
        bash scripts/test_nitellad_rs_config_smoke.sh

    echo "[compat] checking nitellad-rs DB persistence restart traffic"
    NITELLA_RS_PERSIST_SMOKE_TMP="${NITELLA_RS_PERSIST_SMOKE_TMP:-${TMP_DIR}/persist-smoke}" \
        bash scripts/test_nitellad_rs_persistence_smoke.sh

    echo "[compat] checking nitellad-rs Hub PAKE pairing with Go peer"
    bash scripts/test_nitellad_rs_hub_pairing_smoke.sh

    echo "[compat] checking nitellad-rs offline QR pairing with Go signer"
    bash scripts/test_nitellad_rs_offline_pairing_smoke.sh

    echo "[compat] checking nitellad-rs release binary deployment smoke"
    NITELLA_RS_RELEASE_SMOKE_TMP="${NITELLA_RS_RELEASE_SMOKE_TMP:-${TMP_DIR}/release-smoke}" \
        bash scripts/test_nitellad_rs_release_smoke.sh
fi
