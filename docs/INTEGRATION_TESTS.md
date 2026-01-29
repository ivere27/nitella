# Nitella Integration Tests

This document describes the integration tests for nitella and nitellad.

## Running Tests

```bash
# Run all nitellad-related integration tests (~90 seconds)
make nitellad_test_integration

# Run specific test patterns
go test -v ./test/integration/... -run "AdminAPI" -timeout 180s
go test -v ./test/integration/... -run "Proxy" -timeout 60s
go test -v ./test/integration/... -run "Rule" -timeout 60s
```

## Test Coverage (47 Tests)

### Proxy Core Features

| Test | Description | Status |
|------|-------------|--------|
| `TestProxyStandaloneMode` | Proxy with `--listen` and `--backend` flags | PASS |
| `TestProxyToSSHMock` | Proxy forwarding to SSH mock backend | PASS |
| `TestProxyWithYAMLConfig` | Proxy with `--config` YAML file | PASS |
| `TestMultipleClients` | 20 concurrent client connections | PASS |

### Rule Engine

| Test | Description | Status |
|------|-------------|--------|
| `TestRuleEnforcement` | Full rule workflow: baseline → block → mock → concurrent → remove | PASS |
| `TestRulePriority` | Higher priority rules take precedence | PASS |
| `TestMockFallbackOnBackendFailure` | Fallback to mock when backend unreachable | PASS |
| `TestEmptyBackendFallback` | Fallback when no backend configured | PASS |

### Admin API Features

| Test | Description | Status |
|------|-------------|--------|
| `TestAdminAPI_FullLifecycle` | Create → Status → Rules → Delete proxy | PASS |
| `TestAdminAPI_ConnectionManagement` | Get/close active connections | PASS |
| `TestAdminAPI_MultipleProxies` | Create and manage 3 proxies simultaneously | PASS |
| `TestAdminAPI_QuickActions` | BlockIP/AllowIP affecting all proxies | PASS |
| `TestAdminAPI_StreamConnections` | Stream connection events via gRPC | PASS |
| `TestAdminAPI_AuthenticationRequired` | Token auth for admin API | PASS |
| `TestAdminAPI_MockPresets` | HTTP 401/403/404 mock presets | PASS |
| `TestAdminAPI_CIDRRules` | CIDR-based IP matching (127.0.0.0/8) | PASS |

### Rate Limiting & DDoS Protection

| Test | Description | Status |
|------|-------------|--------|
| `TestAdminAPI_RateLimiting` | Rate limit rule with MaxConnections | PASS |
| `TestAdminAPI_AutoBlockFail2Ban` | Fail2ban-style auto-blocking | PASS |
| `TestAdminAPI_DDoSProtection` | 50 concurrent connections stress test | PASS |

### Rule Priority & Configuration

| Test | Description | Status |
|------|-------------|--------|
| `TestAdminAPI_RulePriorityMixed` | Block → Mock → Allow priority cascade | PASS |
| `TestAdminAPI_RuleEnableDisable` | Disabled rules don't affect traffic | PASS |
| `TestAdminAPI_DefaultFallbackMock` | Fallback mock when backend unreachable | PASS |
| `TestAdminAPI_EmptyBackendMock` | Pure mock mode (no backend) | PASS |

### Statistics & GeoIP

| Test | Description | Status |
|------|-------------|--------|
| `TestAdminAPI_StatsAccumulation` | Connection stats (total, bytes) accumulate | PASS |
| `TestAdminAPI_GeoIPLookup` | GeoIP status and IP lookup | PASS |

### Mock Server

| Test | Description | Status |
|------|-------------|--------|
| `TestMock_ConnectionLimit` | Mock server connection limits | PASS |
| `TestMock_MultipleConnections` | Concurrent mock connections | PASS |

### Child Process Mode (ProcessListener)

| Test | Description | Status |
|------|-------------|--------|
| `TestProcessListener_SingleChild` | Single child process proxy | PASS |
| `TestProcessListener_MultipleChildren` | 3 concurrent child processes | PASS |
| `TestProcessListener_RuleEnforcement` | Rules via IPC to child process | PASS |
| `TestProcessListener_Isolation` | Child crash doesn't affect others | PASS |
| `TestProcessListener_MockFallback` | Mock fallback in child process | PASS |
| `TestProcessListener_ForceKillAndRecover` | Kill child with SIGKILL and recover | PASS |
| `TestGetAllActiveConnections` | Get connections from all proxies | PASS |

### Mode Comparison Tests (Embedded vs Process)

Tests that run in **both** embedded and process modes to verify feature parity:

| Test | Description | Status |
|------|-------------|--------|
| `TestMode_ProxyCreate` | Create proxy in both modes | PASS |
| `TestMode_ProxyEnableDisable` | Enable/disable lifecycle | PASS |
| `TestMode_ProxyList` | List multiple proxies | PASS |
| `TestMode_RuleAddRemove` | Add/remove rules with block verification | PASS |
| `TestMode_RuleList` | List multiple rules | PASS |
| `TestMode_RulePriority` | Rule priority ordering | PASS |
| `TestMode_GetActiveConnections` | Get connections for specific proxy | PASS |
| `TestMode_GetAllActiveConnections` | Get connections from all proxies (empty proxyID) | PASS |
| `TestMode_CloseConnection` | Close single connection | PASS |
| `TestMode_CloseAllConnections` | Close all connections on proxy | PASS |
| `TestMode_GetStatus` | Status and metrics | PASS |
| `TestMode_MockFallback` | Mock response on backend failure | PASS |
| `TestMode_ConcurrentConnections` | Concurrent connection handling | PASS |
| `TestMode_ConcurrentRuleModification` | Concurrent rule add/remove | PASS |

## Features Covered

### nitellad (Proxy Daemon)

- [x] Standalone mode with `--listen` and `--backend`
- [x] YAML configuration file loading
- [x] Admin gRPC API with token authentication
- [x] Auto-generated token when not provided
- [x] Multiple proxy management
- [x] Rule engine with priority-based matching
- [x] CIDR condition matching
- [x] Block/Allow/Mock actions
- [x] Rate limiting (MaxConnections, IntervalSeconds)
- [x] Fail2ban-style auto-blocking (CountOnlyFailures, BlockSteps)
- [x] Mock fallback on backend failure
- [x] Connection tracking and management
- [x] Statistics collection
- [x] GeoIP integration (embedded FFI mode)
- [x] TLS/mTLS support (via flags)
- [x] Child process mode (ProcessListener) for process isolation
- [x] Multiple child processes for parallel proxy handling
- [x] IPC via Unix socket for parent-child communication
- [x] Process mode crash recovery (EnableProxy restarts crashed listeners)
- [x] CloseAllConnections across all proxies

### nitella (CLI)

- [x] Token-based authentication
- [x] Token validation on startup
- [x] Proxy management (create, delete, list, status)
- [x] Rule management (add, remove, list)
- [x] Connection management (list, close, closeall)
- [x] Get connections from all proxies (empty proxyID)
- [x] Close all connections on all proxies
- [x] Quick actions (block, allow)
- [x] Connection event streaming (Ctrl+C to stop)
- [x] Metrics streaming (Ctrl+C to stop)
- [x] GeoIP status and lookup
- [x] Tab auto-completion
- [x] Command history (Up/Down arrows)
- [x] Readline-style editing (Ctrl+A/E/W/K/U/L)
- [x] Word navigation (Ctrl+Left/Right, Alt+Left/Right)
- [x] Word deletion (Alt+Backspace)

## Test Architecture

The integration tests use:

1. **Process-level testing**: `proxy_test.go` spawns nitellad and mock server as separate OS processes using `exec.Command`

2. **In-process testing**: `rule_test.go` uses `ProxyManager` directly for faster rule testing

3. **gRPC client testing**: `admin_api_test.go` connects to nitellad's admin API via gRPC

4. **Child process testing**: `process_test.go` tests `ProcessListener` which spawns child processes for process isolation. Uses `NITELLA_BIN` env var to specify the nitellad binary path.

### Test Isolation

Each test uses:
- Unique temp directories for database files (`t.TempDir()`)
- Random free ports to avoid conflicts
- Retry logic for connection stability

## Adding New Tests

1. Place test files in `test/integration/`
2. Use `helpers_test.go` for common utilities (`getFreePort`, etc.)
3. For process-level tests, use `exec.Command` to spawn binaries
4. For unit-level tests, use `ProxyManager` directly
5. Clean up resources with `defer` statements
6. Use temp directories for database files to ensure test isolation:
   ```go
   tempDir := t.TempDir()
   cmd := exec.Command(nitellaBin,
       "--db-path", filepath.Join(tempDir, "nitella.db"),
       "--stats-db", filepath.Join(tempDir, "stats.db"),
   )
   ```
