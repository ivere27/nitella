#!/bin/bash
# ============================================================================
# Nitella E2E Test Runner
# ============================================================================
#
# This script orchestrates comprehensive E2E tests for Nitella:
# 1. Full System Scenario (Registration, Pairing, Proxy, Multi-tenant, Security)
# 2. Advanced Features (Approval, Alerts, Commands, Rules, Stats, Logs)
# 3. Reliability (Persistence, Crash Recovery)
#
# ============================================================================

set -e

# Export E2E_TEST=1 to enable the Go tests
export E2E_TEST=1

# Dedicated local defaults for E2E to avoid collisions with common dev ports.
HUB_ADDR="${HUB_ADDR:-localhost:55052}"
HUB_HTTP_ADDR="${HUB_HTTP_ADDR:-localhost:58080}"
NODE1_ADDR="${NODE1_ADDR:-localhost:28081}"
NODE1_ADMIN="${NODE1_ADMIN:-localhost:55061}"
NODE2_ADDR="${NODE2_ADDR:-localhost:28082}"
NODE2_ADMIN="${NODE2_ADMIN:-localhost:55062}"
NODE3_ADDR="${NODE3_ADDR:-localhost:28083}"
NODE3_ADMIN="${NODE3_ADMIN:-localhost:55063}"
MOCK_HTTP="${MOCK_HTTP:-localhost:18090}"
MOCK_SSH="${MOCK_SSH:-localhost:12222}"
MOCK_MYSQL="${MOCK_MYSQL:-localhost:13306}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Results directory
RESULTS_DIR="${RESULTS_DIR:-/results}"
mkdir -p "$RESULTS_DIR"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Log file
LOG_FILE="$RESULTS_DIR/e2e_test_$(date +%Y%m%d_%H%M%S).log"

log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

log_test() {
    log "${BLUE}[TEST]${NC} $1"
}

log_pass() {
    log "${GREEN}[PASS]${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

log_fail() {
    log "${RED}[FAIL]${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

log_skip() {
    log "${YELLOW}[SKIP]${NC} $1"
    TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
}

# ============================================================================
# Wait for services
# ============================================================================

wait_for_service() {
    local host=$1
    local port=$2
    local timeout=${3:-30}
    local start=$(date +%s)

    log "Waiting for $host:$port..."
    while ! nc -z "$host" "$port" 2>/dev/null; do
        if [ $(($(date +%s) - start)) -gt $timeout ]; then
            log_fail "Timeout waiting for $host:$port"
            return 1
        fi
        sleep 1
    done
    log "Service $host:$port is ready"
    return 0
}

# ============================================================================
# Helper to run a Go test
# ============================================================================

run_go_test() {
    local test_name=$1
    local description=$2
    
    log_test "$description"
    if [ -f ./e2e_tests ]; then
        ./e2e_tests -test.run "^${test_name}$" -test.v 2>&1 | tee -a "$LOG_FILE"
        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            log_pass "$description"
        else
            log_fail "$description failed"
        fi
    else
        log_skip "$description (test binary not found)"
    fi
}

# ============================================================================
# Phase 1: Core System Tests
# ============================================================================

test_phase1_core_system() {
    log "\n${BLUE}========================================${NC}"
    log "${BLUE}PHASE 1: Core System Tests${NC}"
    log "${BLUE}========================================${NC}\n"

    # Test 1.1: Hub health check
    log_test "1.1 Hub health check"
    if curl -sf "http://${HUB_HTTP_ADDR}/health" > /dev/null 2>&1 || nc -z "${HUB_ADDR%:*}" "${HUB_ADDR#*:}"; then
        log_pass "Hub is healthy"
    else
        log_fail "Hub health check failed"
        return 1
    fi

    # Test 1.2: Full System Scenario
    # Covers: Fresh Registration (PAKE/QR), Proxy Creation, Backend Traffic, 
    # Multi-tenant Isolation, Security Verification
    run_go_test "TestE2E_FullScenario" "1.2 Full System Scenario (Reg, PAKE/QR, Proxy, Security)"
}

# ============================================================================
# Phase 2: Feature Tests
# ============================================================================

test_phase2_features() {
    log "\n${BLUE}========================================${NC}"
    log "${BLUE}PHASE 2: Feature Tests${NC}"
    log "${BLUE}========================================${NC}\n"

    run_go_test "TestE2E_MockServices" "2.1 Mock Services (HTTP, SSH, MySQL)"
    run_go_test "TestE2E_RuleEngine" "2.2 Rule Engine (IP, CIDR, GeoIP)"
    run_go_test "TestE2E_ApprovalSystem" "2.3 Approval System"
    run_go_test "TestE2E_AlertStreaming" "2.4 Alert Streaming"
    run_go_test "TestE2E_CommandRelay" "2.5 Command Relay"
    run_go_test "TestE2E_Statistics" "2.6 Statistics"
    run_go_test "TestE2E_EncryptedLogs" "2.7 Encrypted Logs"
    run_go_test "TestE2E_HeartbeatStatus" "2.8 Heartbeat & Status"
    run_go_test "TestE2E_MetricsStreaming" "2.9 Metrics Streaming"
}

# ============================================================================
# Phase 3: Reliability Tests
# ============================================================================

test_phase3_reliability() {
    log "\n${BLUE}========================================${NC}"
    log "${BLUE}PHASE 3: Reliability Tests${NC}"
    log "${BLUE}========================================${NC}\n"

    run_go_test "TestE2E_RestartPersistence" "3.1 Restart Persistence"
    run_go_test "TestE2E_CrashRecovery" "3.2 Crash Recovery"
}

# ============================================================================
# Main
# ============================================================================

main() {
    log "${BLUE}============================================${NC}"
    log "${BLUE}  Nitella E2E Test Suite${NC}"
    log "${BLUE}  Started: $(date)${NC}"
    log "${BLUE}============================================${NC}\n"

    log "Configuration:"
    log "  HUB_ADDR: $HUB_ADDR"
    log "  HUB_HTTP_ADDR: $HUB_HTTP_ADDR"
    log "  NODE1_ADDR: $NODE1_ADDR"
    log "  NODE2_ADDR: $NODE2_ADDR"
    log "  NODE3_ADDR: $NODE3_ADDR"
    log "  MOCK_HTTP: $MOCK_HTTP"
    log "  MOCK_SSH: $MOCK_SSH"
    log "  MOCK_MYSQL: $MOCK_MYSQL"
    log ""

    # Wait for Hub to be ready
    wait_for_service "${HUB_ADDR%:*}" "${HUB_ADDR#*:}" 60

    # Wait for mock backends
    wait_for_service "${MOCK_HTTP%:*}" "${MOCK_HTTP#*:}" 30
    wait_for_service "${MOCK_SSH%:*}" "${MOCK_SSH#*:}" 30

    # Run test phases
    test_phase1_core_system
    test_phase2_features
    test_phase3_reliability

    # Summary
    log "\n${BLUE}============================================${NC}"
    log "${BLUE}  Test Summary${NC}"
    log "${BLUE}============================================${NC}"
    log "  ${GREEN}Passed:${NC}  $TESTS_PASSED"
    log "  ${RED}Failed:${NC}  $TESTS_FAILED"
    log "  ${YELLOW}Skipped:${NC} $TESTS_SKIPPED"
    log "  Completed: $(date)"
    log "${BLUE}============================================${NC}\n"

    # Save summary
    cat > "$RESULTS_DIR/summary.json" << EOF
{
    "timestamp": "$(date -Iseconds)",
    "passed": $TESTS_PASSED,
    "failed": $TESTS_FAILED,
    "skipped": $TESTS_SKIPPED,
    "success": $([ $TESTS_FAILED -eq 0 ] && echo "true" || echo "false")
}
EOF

    # Exit with failure if any tests failed
    [ $TESTS_FAILED -eq 0 ]
}

main "$@"
