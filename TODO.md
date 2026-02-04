# TODO

## Security Audit

## Stability & Performance

---

## Logic & UX

---

## Refactoring

- [ ] **Relax P2P Approval Logic** - `cmd/nitella/hub.go:tryP2PApproval`
  - Currently requires alert to have arrived `via_p2p` to send decision via P2P.
  - Should send via P2P if connected, regardless of how the alert arrived (e.g., race condition where Hub alert arrived first).
  - **Fix**: Remove `via_p2p` metadata check.

- [ ] **Split pkg/hub/server/server.go** - 2k+ lines
  - Single file with 5 embedded service implementations
  - Split into: `mobile_server.go`, `node_server.go`, `auth_server.go`, `pairing_server.go`, `admin_server.go`

- [ ] **Split cmd/nitella/hub.go** - 2184 lines
  - Contains all Hub CLI commands in one file
  - Split into: `hub_pairing.go`, `hub_alerts.go`, `hub_nodes.go`, `hub_logs.go`, `hub_proxy.go`

- [ ] **Global Variables in cmd/nitella/hub.go** - Lines 37-64
  - Uses package-level globals for state (hubConn, p2pTransport, pendingAlerts, etc.)
  - Makes testing difficult, creates singleton anti-pattern
  - **Fix**: Encapsulate in HubCLI struct

---

## Production Readiness

- [ ] **HTTP Health Server** - `cmd/hub/main.go:364-379`
  - Health check server runs on separate port without TLS or authentication
  - **Fix**: Ensure health port is firewalled from public access

- [ ] **IDOR in License Update** - `pkg/hub/server/server.go:UpdateLicense`
  - `UpdateLicense` accepts a `routing_token` and updates its tier without verifying ownership.
  - An attacker can use their license key to hijack or modify the tier of any target node if they know the routing token.
  - **Fix**: Verify that the authenticated user (from context JWT) owns the `routing_token` before updating.

- [ ] **Missing Certificate Revocation Check** - `pkg/p2p/transport.go:428-470`
  - Only checks CA signature and validity period
  - No CRL or OCSP check for revoked certificates
  - **Fix**: Use short-lived certificates (24-72h) or implement CRL caching

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
