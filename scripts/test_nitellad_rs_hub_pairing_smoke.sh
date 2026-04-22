#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_ROOT}"

echo "[hub-pair-smoke] building nitellad-rs"
cargo build --manifest-path nitellad-rs/Cargo.toml --quiet

echo "[hub-pair-smoke] pairing live nitellad-rs with Go PAKE hub peer"
NITELLA_RS_BIN="${PROJECT_ROOT}/nitellad-rs/target/debug/nitellad-rs" \
    go test ./cmd/nitellad -run TestRustHubPAKEPairingSmoke -count=1

echo "[hub-pair-smoke] checking post-pairing Hub runtime command relay"
NITELLA_RS_BIN="${PROJECT_ROOT}/nitellad-rs/target/debug/nitellad-rs" \
    go test ./cmd/nitellad -run TestRustHubRuntimeSmoke -count=1

echo "[hub-pair-smoke] Go PAKE hub peer paired live nitellad-rs and relayed a command"
