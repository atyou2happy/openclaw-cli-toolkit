#!/usr/bin/env bash
# Test: OpenClaw CLI Toolkit Installation
# Usage: bash tests/test_install.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

PASS=0
FAIL=0
TOTAL=0

green() { echo -e "\033[0;32m[PASS]\033[0m $*"; }
red()   { echo -e "\033[0;31m[FAIL]\033[0m $*"; }
blue()  { echo -e "\033[0;34m[TEST]\033[0m $*"; }

assert_file() {
    TOTAL=$((TOTAL + 1))
    if [[ -f "$1" ]]; then
        green "File exists: $1"
        PASS=$((PASS + 1))
    else
        red "File missing: $1"
        FAIL=$((FAIL + 1))
    fi
}

assert_executable() {
    TOTAL=$((TOTAL + 1))
    if [[ -x "$1" ]]; then
        green "Executable: $1"
        PASS=$((PASS + 1))
    else
        red "Not executable: $1"
        FAIL=$((FAIL + 1))
    fi
}

assert_command() {
    TOTAL=$((TOTAL + 1))
    if command -v "$1" &>/dev/null; then
        green "Command available: $1"
        PASS=$((PASS + 1))
    else
        red "Command not found: $1"
        FAIL=$((FAIL + 1))
    fi
}

echo "=========================================="
echo "  OpenClaw CLI Toolkit - Installation Test"
echo "=========================================="
echo ""

# Test 1: Project structure
blue "Testing project structure..."
assert_file "$PROJECT_DIR/install.sh"
assert_file "$PROJECT_DIR/uninstall.sh"
assert_file "$PROJECT_DIR/config.yaml"
assert_file "$PROJECT_DIR/LICENSE"
assert_file "$PROJECT_DIR/src/detector.sh"
assert_file "$PROJECT_DIR/src/installer.sh"
assert_file "$PROJECT_DIR/src/configurator.sh"
assert_file "$PROJECT_DIR/src/generator.py"
echo ""

# Test 2: Executable permissions
blue "Testing executable permissions..."
assert_executable "$PROJECT_DIR/install.sh"
assert_executable "$PROJECT_DIR/uninstall.sh"
echo ""

# Test 3: Tool YAML files
blue "Testing tool definitions..."
for yaml in "$PROJECT_DIR"/tools/*.yaml; do
    assert_file "$yaml"
done
echo ""

# Test 4: Dry run
blue "Testing dry-run mode..."
TOTAL=$((TOTAL + 1))
if bash "$PROJECT_DIR/install.sh" --dry-run 2>&1 | grep -q "DRY RUN"; then
    green "Dry-run mode works"
    PASS=$((PASS + 1))
else
    red "Dry-run mode failed"
    FAIL=$((FAIL + 1))
fi
echo ""

# Test 5: Generator
blue "Testing generator..."
TOTAL=$((TOTAL + 1))
if python3 "$PROJECT_DIR/src/generator.py" --tools-dir "$PROJECT_DIR/tools" --output /tmp/test-openclaw-tools.yaml 2>/dev/null; then
    green "Generator runs successfully"
    PASS=$((PASS + 1))
    assert_file "/tmp/test-openclaw-tools.yaml"
    rm -f /tmp/test-openclaw-tools.yaml
else
    red "Generator failed"
    FAIL=$((FAIL + 1))
fi
echo ""

# Summary
echo "=========================================="
echo "  Results: $PASS/$TOTAL passed, $FAIL failed"
echo "=========================================="
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
