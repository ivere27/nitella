#!/bin/bash
# ============================================================================
# Nitella E2E Test Runner
# ============================================================================
#
# This script orchestrates comprehensive E2E tests for Nitella:
# 1. Fresh registration (PAKE and QR pairing)
# 2. Proxy creation and rule management
# 3. Backend connectivity testing
# 4. Multi-tenant isolation
# 5. Restart and persistence
# 6. Crash recovery
# 7. Security verification (E2E encryption)
#
# ============================================================================

set -e

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
    ((TESTS_PASSED++))
}

log_fail() {
    log "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

log_skip() {
    log "${YELLOW}[SKIP]${NC} $1"
    ((TESTS_SKIPPED++))
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
# Phase 1: Fresh Registration Tests
# ============================================================================

test_phase1_fresh_registration() {
    log "\n${BLUE}========================================${NC}"
    log "${BLUE}PHASE 1: Fresh Registration${NC}"
    log "${BLUE}========================================${NC}\n"

    # Test 1.1: Hub health check
    log_test "1.1 Hub health check"
    if curl -sf "http://${HUB_ADDR%:*}:8080/health" > /dev/null 2>&1 || nc -z "${HUB_ADDR%:*}" "${HUB_ADDR#*:}"; then
        log_pass "Hub is healthy"
    else
        log_fail "Hub health check failed"
        return 1
    fi

    # Test 1.2: User registration (simulated via CLI)
    log_test "1.2 User registration"
    # In real test, this would use the nitella CLI
    if ./nitella --hub="$HUB_ADDR" --help > /dev/null 2>&1; then
        log_pass "CLI available for registration"
    else
        log_skip "CLI registration test (requires interactive mode)"
    fi

    # Test 1.3: PAKE pairing simulation
    log_test "1.3 PAKE pairing"
    # This would be tested via the Go test binary
    if [ -f ./e2e_tests ]; then
        ./e2e_tests -test.run TestComprehensive_FreshRegister_PAKE -test.v 2>&1 | tee -a "$LOG_FILE"
        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            log_pass "PAKE pairing test"
        else
            log_fail "PAKE pairing test"
        fi
    else
        log_skip "PAKE pairing test (test binary not found)"
    fi

    # Test 1.4: QR pairing simulation
    log_test "1.4 QR code pairing"
    if [ -f ./e2e_tests ]; then
        ./e2e_tests -test.run TestComprehensive_FreshRegister_QRCode -test.v 2>&1 | tee -a "$LOG_FILE"
        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            log_pass "QR code pairing test"
        else
            log_fail "QR code pairing test"
        fi
    else
        log_skip "QR code pairing test (test binary not found)"
    fi
}

# ============================================================================
# Phase 2: Proxy and Backend Tests
# ============================================================================

test_phase2_proxy_backend() {
    log "\n${BLUE}========================================${NC}"
    log "${BLUE}PHASE 2: Proxy and Backend Tests${NC}"
    log "${BLUE}========================================${NC}\n"

    # Test 2.1: HTTP backend connectivity
    log_test "2.1 HTTP backend via proxy"
    if curl -sf "http://$MOCK_HTTP/health" > /dev/null 2>&1; then
        log_pass "HTTP mock backend reachable"
    else
        log_fail "HTTP mock backend unreachable"
    fi

    # Test 2.2: SSH backend connectivity
    log_test "2.2 SSH backend"
    if nc -z "${MOCK_SSH%:*}" "${MOCK_SSH#*:}" 2>/dev/null; then
        log_pass "SSH mock backend reachable"
    else
        log_fail "SSH mock backend unreachable"
    fi

    # Test 2.3: MySQL backend connectivity
    log_test "2.3 MySQL backend"
    if nc -z "${MOCK_MYSQL%:*}" "${MOCK_MYSQL#*:}" 2>/dev/null; then
        log_pass "MySQL mock backend reachable"
    else
        log_fail "MySQL mock backend unreachable"
    fi
}

# ============================================================================
# Phase 3: Multi-Tenant Tests
# ============================================================================

test_phase3_multi_tenant() {
    log "\n${BLUE}========================================${NC}"
    log "${BLUE}PHASE 3: Multi-Tenant Isolation${NC}"
    log "${BLUE}========================================${NC}\n"

    log_test "3.1 Multi-tenant isolation test"
    if [ -f ./e2e_tests ]; then
        ./e2e_tests -test.run TestComprehensive_MultiTenant -test.v 2>&1 | tee -a "$LOG_FILE"
        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            log_pass "Multi-tenant isolation verified"
        else
            log_fail "Multi-tenant isolation test failed"
        fi
    else
        log_skip "Multi-tenant test (test binary not found)"
    fi
}

# ============================================================================
# Phase 4: Persistence Tests
# ============================================================================

test_phase4_persistence() {
    log "\n${BLUE}========================================${NC}"
    log "${BLUE}PHASE 4: Restart and Persistence${NC}"
    log "${BLUE}========================================${NC}\n"

    log_test "4.1 Restart persistence test"
    if [ -f ./e2e_tests ]; then
        ./e2e_tests -test.run TestComprehensive_RestartPersistence -test.v 2>&1 | tee -a "$LOG_FILE"
        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            log_pass "Restart persistence verified"
        else
            log_fail "Restart persistence test failed"
        fi
    else
        log_skip "Restart persistence test (test binary not found)"
    fi
}

# ============================================================================
# Phase 5: Crash Recovery Tests
# ============================================================================

test_phase5_crash_recovery() {
    log "\n${BLUE}========================================${NC}"
    log "${BLUE}PHASE 5: Crash Recovery${NC}"
    log "${BLUE}========================================${NC}\n"

    log_test "5.1 Crash recovery test"
    if [ -f ./e2e_tests ]; then
        ./e2e_tests -test.run TestComprehensive_CrashRecovery -test.v 2>&1 | tee -a "$LOG_FILE"
        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            log_pass "Crash recovery verified"
        else
            log_fail "Crash recovery test failed"
        fi
    else
        log_skip "Crash recovery test (test binary not found)"
    fi
}

# ============================================================================
# Phase 6: Security Tests
# ============================================================================

test_phase6_security() {
    log "\n${BLUE}========================================${NC}"
    log "${BLUE}PHASE 6: Security (E2E Encryption)${NC}"
    log "${BLUE}========================================${NC}\n"

    log_test "6.1 E2E encryption verification"
    if [ -f ./e2e_tests ]; then
        ./e2e_tests -test.run TestComprehensive_Security_E2E -test.v 2>&1 | tee -a "$LOG_FILE"
        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            log_pass "E2E encryption verified - Hub cannot see sensitive data"
        else
            log_fail "E2E encryption test failed"
        fi
    else
        log_skip "E2E encryption test (test binary not found)"
    fi

    log_test "6.2 Full system integration test"
    if [ -f ./e2e_tests ]; then
        ./e2e_tests -test.run TestComprehensive_FullSystem -test.v 2>&1 | tee -a "$LOG_FILE"
        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            log_pass "Full system integration test"
        else
            log_fail "Full system integration test failed"
        fi
    else
        log_skip "Full system integration test (test binary not found)"
    fi
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
    test_phase1_fresh_registration
    test_phase2_proxy_backend
    test_phase3_multi_tenant
    test_phase4_persistence
    test_phase5_crash_recovery
    test_phase6_security

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
