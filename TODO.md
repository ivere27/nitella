# TODO

## Must Fix

---

## Security

- [ ] **HTTP Health Server** - `cmd/hub/main.go:364-379`
  - Health check server runs on separate port without TLS or authentication
  - **Fix**: Ensure health port is firewalled from public access

- [ ] **Hub JWT Storage Hardening (Later)** - `pkg/service/mobile_logic_service.go:496-517`
  - Current behavior is acceptable for now: Hub JWT is stored in `hub_session.json` with `0600` permissions.
  - Later implementation: add optional OS keychain-backed storage with JSON fallback for headless/CLI environments.
  - Keep MobileLogicService as source of truth for token lifecycle.

- [ ] **IDOR in License Update** - `pkg/hub/server/server.go:UpdateLicense`
  - `UpdateLicense` accepts a `routing_token` and updates its tier without verifying ownership
  - An attacker can use their license key to hijack or modify the tier of any target node if they know the routing token
  - **Fix**: Verify that the authenticated user (from context JWT) owns the `routing_token` before updating

- [ ] **Missing Certificate Revocation Check** - `pkg/p2p/transport.go:428-470`
  - Only checks CA signature and validity period
  - No CRL or OCSP check for revoked certificates
  - **Fix**: Use short-lived certificates (24-72h) or implement CRL caching

---

## Stability & Performance

- [ ] **Fuzz Testing**
  - Implement fuzz testing (e.g., `go-fuzz` or OSS-Fuzz) for critical security boundaries.
  - Focus on PAKE handshake parsing and encrypted payload decryption logic to find panics or buffer overflows.

- [ ] **Deterministic Simulation (Jepsen-style)**
  - Simulate adverse network conditions: partitions, massive clock skew, and slow disk I/O during high concurrency.
  - Verify system recovery and consistency under these "split-brain" or degraded scenarios.

- [ ] **Long-Haul "Soak" Testing**
  - Setup a test cluster running continuous load for extended periods (weeks).
  - Goal: Detect memory leaks, goroutine leaks, or file descriptor exhaustion that typically only appear after long uptimes.

## Mobile App Testing

- [ ] **UI Error State Verification**
  - Add tests that intentionally simulate backend failures (e.g., Hub down, network timeout).
  - Verify UI displays user-friendly error messages/Snackbars instead of crashing or hanging.

- [ ] **Concurrency/Race Condition Tests**
  - Add tests simulating rapid user interactions (e.g., furious tapping on "Approve", rapid tab switching).
  - Verify BLoC/Provider state consistency under race conditions.

- [ ] **Golden Image Tests**
  - Implement `matchesGoldenFile` tests for key screens (Dashboard, Nodes, Rules).
  - Ensure no visual regressions (overflows, layout shifts) across updates.

---

## Logic & UX

- [ ] Enterprise plugin stubs (Phase 7) deferred
- [ ] Embedded proxy tunneling (Future Feature) deferred

---

## Design & Proto

- [ ] **`--kdf-profile` CLI Flag** - Expose KDF profile selection (`default`/`server`/`secure`) for passphrase-based key encryption
  - Add `kdf_profile_name` to `CreateIdentityRequest` and `RestoreIdentityRequest` protos
  - Add `--kdf-profile` flag + `NITELLA_KDF_PROFILE` env var to CLI
  - Update `saveIdentity()` to accept `KDFParams` (currently hardcoded to `KDFDefault`)
  - Backend infra already exists: `pkg/crypto/kdf.go`, `identity.Config.KDFParams`

---

## Refactoring

- [x] **Relax P2P Approval Logic** - `cmd/nitella/hub_alerts.go:tryP2PApproval`
  - Removed `via_p2p` metadata check; now sends via P2P if connected regardless of alert source

- [x] **Split pkg/hub/server/server.go**
  - Split into: `server.go`, `mobile_server.go`, `node_server.go`, `auth_server.go`, `pairing_server.go`, `admin_server.go`

- [x] **Split cmd/nitella/hub.go**
  - Split into: `hub.go`, `hub_pairing.go`, `hub_alerts.go`, `hub_nodes.go`, `hub_logs.go`

- [x] **Global Variables in cmd/nitella/hub.go**
  - Encapsulated in `HubCLI` struct; all split files use method receivers

- [x] **Duplicate libnitella.h** - Removed root copy

- [x] **Dart File in Go Directory** - Removed `pkg/api/local/nitella_local_ffi.pb.dart`

---

## Production Readiness

- [ ] **Structured Logging**: Migrate from `pkg/log` text logs to structured JSON logs (using `log/slog` or `zap`)
- [ ] **Metrics**: Add Prometheus/OpenTelemetry instrumentation
- [ ] **Config Management**: Implement a config file loader (e.g., `viper`) for Hub server
- [ ] **Configurable Limits**: Make `DefaultMaxPendingApprovals` and timeouts configurable

---

## Scaling Out Hub

For 100K+ users or multi-Hub deployments:

- [ ] **ClientCA Pool Optimization** - `pkg/hub/certmanager/certmanager.go`
  - Current: All CLI CAs loaded into memory (~1KB per user, ~100MB at 100K users)
  - Option A: TTL-based eviction for inactive CAs (reload from DB on demand)
  - Option B: Store CA fingerprint in node cert → lookup single CA per verification

- [ ] **Shard userStreams** - `pkg/hub/server/server.go`
  - Current: Single RWMutex for all user streams
  - At scale: Write lock (connect/disconnect) blocks all reads
  - Fix: Shard by routing token hash (16-64 shards)

- [ ] **Multi-Hub Scaling (Redis)**
  - Current: In-memory `pendingAlerts` map works for single Hub (handles ~50K nodes)
  - For multi-Hub: Use Redis for shared pending alerts state
  - Considerations: Alerts are ephemeral (5 min expiry), ~1KB each, no persistence needed
  - Implementation: Replace `map[string]*PendingAlert` with Redis hash + TTL
