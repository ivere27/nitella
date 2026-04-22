#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CHECKLIST="${PROJECT_ROOT}/docs/NITELLAD_RS_DROPIN_CHECKLIST.md"

cd "${PROJECT_ROOT}"

if [[ ! -f "${CHECKLIST}" ]]; then
    echo "[plan-coverage] missing ${CHECKLIST}"
    exit 1
fi

echo "[plan-coverage] checking checklist coverage IDs"
for id in B1 B2 B3 B4 B5 B6; do
    if ! grep -qE "^\| ${id} \|" "${CHECKLIST}"; then
        echo "[plan-coverage] checklist missing ${id}"
        exit 1
    fi
done

for id in G{1..25}; do
    if ! grep -qE "^\| ${id} \|" "${CHECKLIST}"; then
        echo "[plan-coverage] checklist missing ${id}"
        exit 1
    fi
done

for id in P{1..16}; do
    if ! grep -qE "^\| ${id} \|" "${CHECKLIST}"; then
        echo "[plan-coverage] checklist missing ${id}"
        exit 1
    fi
done

echo "[plan-coverage] running Rust unit and FFI coverage"
cargo test --manifest-path nitellad-rs/Cargo.toml

echo "[plan-coverage] running Go node and mobile-service coverage"
go test ./pkg/node ./pkg/service

echo "[plan-coverage] running fast Go/Rust compatibility harness"
NITELLA_COMPAT_SKIP_LIVE=1 NITELLA_COMPAT_SKIP_UNIT=1 bash scripts/compare_nitellad_compat.sh

if [[ "${NITELLA_COMPAT_SKIP_WINDOWS:-}" != "1" ]]; then
    if rustup target list --installed | grep -qx 'x86_64-pc-windows-gnu'; then
        echo "[plan-coverage] checking Windows target compile"
        cargo check --manifest-path nitellad-rs/Cargo.toml --target x86_64-pc-windows-gnu
    elif [[ "${NITELLA_COMPAT_REQUIRE_WINDOWS:-}" == "1" ]]; then
        echo "[plan-coverage] x86_64-pc-windows-gnu target is required but not installed"
        exit 1
    else
        echo "[plan-coverage] skipping Windows target compile; install x86_64-pc-windows-gnu or set NITELLA_COMPAT_REQUIRE_WINDOWS=1"
    fi
fi

if [[ "${NITELLA_COMPAT_REQUIRE_LIVE:-}" == "1" ]]; then
    echo "[plan-coverage] running full live compatibility harness"
    NITELLA_COMPAT_SKIP_UNIT=1 bash scripts/compare_nitellad_compat.sh
fi

echo "[plan-coverage] PLAN.md coverage ledger and fast gates passed"
