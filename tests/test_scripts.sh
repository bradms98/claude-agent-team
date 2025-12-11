#!/bin/bash
# shellcheck shell=bash

# Test suite for activate.sh and deactivate.sh
# Run from repository root: ./tests/test_scripts.sh

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Backup original agents directory
ORIGINAL_AGENTS_DIR="$HOME/.claude/agents"
ORIGINAL_STASH_DIR="$HOME/.claude/agents.stash"
BACKUP_AGENTS_DIR="$HOME/.claude/agents.test-backup"
BACKUP_STASH_DIR="$HOME/.claude/agents.stash.test-backup"

# Test helper functions
setup() {
    echo "Setting up test environment..."
    # Backup existing directories if they exist
    if [ -d "$ORIGINAL_AGENTS_DIR" ]; then
        mv "$ORIGINAL_AGENTS_DIR" "$BACKUP_AGENTS_DIR"
    fi
    if [ -d "$ORIGINAL_STASH_DIR" ]; then
        mv "$ORIGINAL_STASH_DIR" "$BACKUP_STASH_DIR"
    fi
}

teardown() {
    echo "Cleaning up test environment..."
    # Remove test directories
    rm -rf "$ORIGINAL_AGENTS_DIR"
    rm -rf "$ORIGINAL_STASH_DIR"
    # Restore backups
    if [ -d "$BACKUP_AGENTS_DIR" ]; then
        mv "$BACKUP_AGENTS_DIR" "$ORIGINAL_AGENTS_DIR"
    fi
    if [ -d "$BACKUP_STASH_DIR" ]; then
        mv "$BACKUP_STASH_DIR" "$ORIGINAL_STASH_DIR"
    fi
}

# Trap to ensure cleanup on exit
trap teardown EXIT

pass() {
    echo -e "  ${GREEN}✓${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
    echo -e "  ${RED}✗${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

run_test() {
    TESTS_RUN=$((TESTS_RUN + 1))
    echo ""
    echo "Test $TESTS_RUN: $1"
}

# Tests

test_help_flags() {
    run_test "Help flags work"

    local output
    output=$("$REPO_DIR/activate.sh" --help 2>&1) || true
    if echo "$output" | grep -q "Usage:"; then
        pass "activate.sh --help shows usage"
    else
        fail "activate.sh --help does not show usage"
    fi

    output=$("$REPO_DIR/activate.sh" -h 2>&1) || true
    if echo "$output" | grep -q "Usage:"; then
        pass "activate.sh -h shows usage"
    else
        fail "activate.sh -h does not show usage"
    fi

    output=$("$REPO_DIR/deactivate.sh" --help 2>&1) || true
    if echo "$output" | grep -q "Usage:"; then
        pass "deactivate.sh --help shows usage"
    else
        fail "deactivate.sh --help does not show usage"
    fi

    output=$("$REPO_DIR/deactivate.sh" -h 2>&1) || true
    if echo "$output" | grep -q "Usage:"; then
        pass "deactivate.sh -h shows usage"
    else
        fail "deactivate.sh -h does not show usage"
    fi
}

test_activation() {
    run_test "Activation installs agent files"

    "$REPO_DIR/activate.sh" > /dev/null

    if [ -d "$ORIGINAL_AGENTS_DIR" ]; then
        pass "Creates ~/.claude/agents/ directory"
    else
        fail "Does not create ~/.claude/agents/ directory"
    fi

    if [ -f "$ORIGINAL_AGENTS_DIR/orchestrator.md" ]; then
        pass "Installs orchestrator.md"
    else
        fail "Does not install orchestrator.md"
    fi

    if [ -f "$ORIGINAL_AGENTS_DIR/engineer.md" ]; then
        pass "Installs engineer.md"
    else
        fail "Does not install engineer.md"
    fi

    # Count installed agents
    agent_count=$(find "$ORIGINAL_AGENTS_DIR" -name "*.md" | wc -l | tr -d ' ')
    if [ "$agent_count" -eq 10 ]; then
        pass "Installs all 10 agents"
    else
        fail "Expected 10 agents, found $agent_count"
    fi

    # Check for marker
    if grep -q "installed-from:" "$ORIGINAL_AGENTS_DIR/orchestrator.md"; then
        pass "Files contain installation marker"
    else
        fail "Files missing installation marker"
    fi
}

test_idempotent() {
    run_test "Activation is idempotent"

    # Run activation twice
    "$REPO_DIR/activate.sh" > /dev/null 2>&1 || true
    output=$("$REPO_DIR/activate.sh" 2>&1) || true

    if echo "$output" | grep -q "already active"; then
        pass "Second activation detects already active"
    else
        fail "Second activation does not detect already active"
    fi
}

test_deactivation() {
    run_test "Deactivation removes agent files"

    # Ensure activated first
    "$REPO_DIR/activate.sh" > /dev/null 2>&1 || true

    # Deactivate
    "$REPO_DIR/deactivate.sh" > /dev/null

    # Count remaining agents (should be 0)
    agent_count=$(find "$ORIGINAL_AGENTS_DIR" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$agent_count" -eq 0 ]; then
        pass "Removes all agent files"
    else
        fail "Expected 0 agents after deactivation, found $agent_count"
    fi
}

test_stash_and_restore() {
    run_test "Stash and restore existing agents"

    # Create a fake existing agent
    mkdir -p "$ORIGINAL_AGENTS_DIR"
    echo "# Fake agent" > "$ORIGINAL_AGENTS_DIR/fake-agent.md"

    # Activate (should stash fake agent)
    "$REPO_DIR/activate.sh" > /dev/null

    if [ -f "$ORIGINAL_STASH_DIR/fake-agent.md" ]; then
        pass "Stashes existing agents"
    else
        fail "Does not stash existing agents"
    fi

    if [ ! -f "$ORIGINAL_AGENTS_DIR/fake-agent.md" ]; then
        pass "Removes stashed agent from agents dir"
    else
        fail "Stashed agent still in agents dir"
    fi

    # Deactivate (should restore fake agent)
    "$REPO_DIR/deactivate.sh" > /dev/null

    if [ -f "$ORIGINAL_AGENTS_DIR/fake-agent.md" ]; then
        pass "Restores stashed agents on deactivation"
    else
        fail "Does not restore stashed agents"
    fi
}

# Run tests
echo "================================"
echo "Agent Team Script Tests"
echo "================================"

setup

test_help_flags
test_activation
test_idempotent
test_deactivation
test_stash_and_restore

# Summary
echo ""
echo "================================"
echo "Test Summary"
echo "================================"
echo "Tests run: $TESTS_RUN"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"

if [ "$TESTS_FAILED" -gt 0 ]; then
    exit 1
fi
