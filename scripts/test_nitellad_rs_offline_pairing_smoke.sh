#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
GO_CACHE_DIR="${NITELLA_GO_CACHE:-${TMPDIR:-/tmp}/nitella-go-build-cache}"

cd "${PROJECT_ROOT}"
mkdir -p "${GO_CACHE_DIR}"

echo "[offline-pair-smoke] building nitellad-rs"
cargo build --manifest-path nitellad-rs/Cargo.toml --quiet

echo "[offline-pair-smoke] exchanging Rust terminal CSR with Go QR signer"
GOCACHE="${GO_CACHE_DIR}" \
NITELLA_RS_BIN="${PROJECT_ROOT}/nitellad-rs/target/debug/nitellad-rs" \
go test ./cmd/nitellad -run TestRustOfflinePairingTerminalSmoke -count=1

echo "[offline-pair-smoke] Go QR response completed Rust offline pairing"
