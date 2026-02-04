# Nitella Test Targets

## Available Make Targets

| Target | Description |
|--------|-------------|
| `make test` | Run all unit tests |
| `make geoip_test` | GeoIP unit tests |
| `make geoip_test_integration` | GeoIP integration tests |
| `make mock_test` | Mock server unit tests |
| `make mock_test_integration` | Mock integration tests |
| `make nitellad_test` | Nitellad unit tests |
| `make nitellad_test_integration` | Nitellad integration tests (proxy, rules, CLI) |
| `make hub_test` | Hub unit tests |
| `make hub_test_integration` | Hub integration tests |
| `make hub_test_quick` | Quick smoke tests |
| `make hub_test_e2e_docker` | Full Docker-based E2E tests |

## Test Results (2026-02-04)

### Unit Tests - ALL PASSED

| Target | Status |
|--------|--------|
| `make geoip_test` | PASS |
| `make mock_test` | PASS |
| `make nitellad_test` | PASS |
| `make hub_test` | PASS |

### Integration Tests

| Target | Status | Notes |
|--------|--------|-------|
| `make mock_test_integration` | PASS | All mock protocol tests passed |
| `make geoip_test_integration` | PASS | Server, CLI, lookup tests passed |
| `make nitellad_test_integration` | PARTIAL | Connection close timing issues in `TestMode_CloseConnection` |
| `make hub_test_integration` | PARTIAL | Pairing flow timing issues in some tests |

### E2E Tests (Docker)

| Target | Description |
|--------|-------------|
| `make hub_test_e2e_docker` | Full Docker-based E2E tests with Hub, nodes, and mock backends |
| `make hub_test_clean` | Clean up test artifacts and docker volumes |

#### E2E Test Functions

| Test | Description |
|------|-------------|
| `TestE2E_FullScenario` | Complete user flow: registration, pairing, proxy creation |
| `TestE2E_RestartPersistence` | Data survives Hub restart |
| `TestE2E_CrashRecovery` | Node reconnects after crash |
| `TestE2E_ApprovalSystem` | Mobile approval flow for connections |
| `TestE2E_AlertStreaming` | Real-time alert delivery |
| `TestE2E_CommandRelay` | Mobile-to-node command relay |
| `TestE2E_RuleEngine` | Rule creation and enforcement |
| `TestE2E_Statistics` | Stats collection and aggregation |
| `TestE2E_MockServices` | Mock protocol responses (HTTP, SSH, MySQL, etc.) |
| `TestE2E_EncryptedLogs` | E2E encrypted log storage |
| `TestE2E_HeartbeatStatus` | Node heartbeat and status updates |
| `TestE2E_MetricsStreaming` | Real-time metrics streaming |

### Hub Tests (Individual Batches)

Run hub tests in smaller batches to avoid timeout issues:

```bash
# Batch 1: Command relay and streaming
go test -v ./test/integration/... -run "TestHub_CommandRelay|TestHub_AlertStreaming" -timeout 180s

# Batch 2: Heartbeat and logs
go test -v ./test/integration/... -run "TestHub_HeartbeatAndStatus|TestHub_LogsE2E" -timeout 180s

# Batch 3: HubCtl operations
go test -v ./test/integration/... -run "TestHubCtl_UserManagement|TestHubCtl_SystemStats" -timeout 180s
```

### Known Issues

- **Connection close timing**: `TestMode_CloseConnection/Embedded` and `TestMode_CloseAllConnections/Embedded` may fail due to timing issues where connection cleanup hasn't completed before verification
- **Hub pairing timing**: Some hub pairing tests have timing-sensitive assertions that may fail under load
- **TLS certificate trust**: Comprehensive tests (`TestComprehensive_*`) require full mTLS setup and may fail with certificate errors when run standalone. Use `make hub_test_e2e_docker` for these tests
