#!/usr/bin/env bash
# Test: Verify project structure and file integrity
# Usage: bash tests/test_structure.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

PASS=0 FAIL=0 TOTAL=0

green() { echo -e "\033[0;32m[PASS]\033[0m $*"; }
red()   { echo -e "\033[0;31m[FAIL]\033[0m $*"; }
blue()  { echo -e "\033[0;34m[TEST]\033[0m $*"; }

assert_file() {
	TOTAL=$((TOTAL + 1))
	if [[ -f "$1" ]]; then
		green "File exists: $1"; PASS=$((PASS + 1))
	else
		red "File missing: $1"; FAIL=$((FAIL + 1))
	fi
}

assert_executable() {
	TOTAL=$((TOTAL + 1))
	if [[ -x "$1" ]]; then
		green "Executable: $1"; PASS=$((PASS + 1))
	else
		red "Not executable: $1"; FAIL=$((FAIL + 1))
	fi
}

assert_syntax_ok() {
	TOTAL=$((TOTAL + 1))
	if bash -n "$1" 2>/dev/null; then
		green "Syntax OK: $1"; PASS=$((PASS + 1))
	else
		red "Syntax error: $1"; FAIL=$((FAIL + 1))
	fi
}

assert_dir() {
	TOTAL=$((TOTAL + 1))
	if [[ -d "$1" ]]; then
		green "Dir exists: $1"; PASS=$((PASS + 1))
	else
		red "Dir missing: $1"; FAIL=$((FAIL + 1))
	fi
}

echo "=========================================="
echo "  OpenClaw CLI Toolkit - Structure Test"
echo "=========================================="
echo ""

blue "Testing root files..."
assert_file "$PROJECT_DIR/install.sh"
assert_file "$PROJECT_DIR/uninstall.sh"
assert_file "$PROJECT_DIR/config.yaml"
assert_file "$PROJECT_DIR/VERSION"
assert_file "$PROJECT_DIR/LICENSE"
assert_file "$PROJECT_DIR/.gitignore"
assert_file "$PROJECT_DIR/.editorconfig"
assert_executable "$PROJECT_DIR/install.sh"
assert_executable "$PROJECT_DIR/uninstall.sh"
echo ""

blue "Testing src/ modules..."
assert_file "$PROJECT_DIR/src/common.sh"
assert_file "$PROJECT_DIR/src/detector.sh"
assert_file "$PROJECT_DIR/src/installer.sh"
assert_file "$PROJECT_DIR/src/configurator.sh"
assert_file "$PROJECT_DIR/src/state.sh"
assert_file "$PROJECT_DIR/src/generator.py"
assert_file "$PROJECT_DIR/src/parse_tools.py"
echo ""

blue "Testing shell syntax..."
assert_syntax_ok "$PROJECT_DIR/src/common.sh"
assert_syntax_ok "$PROJECT_DIR/src/detector.sh"
assert_syntax_ok "$PROJECT_DIR/src/installer.sh"
assert_syntax_ok "$PROJECT_DIR/src/configurator.sh"
assert_syntax_ok "$PROJECT_DIR/src/state.sh"
assert_syntax_ok "$PROJECT_DIR/install.sh"
assert_syntax_ok "$PROJECT_DIR/uninstall.sh"
echo ""

blue "Testing tools/ YAML..."
assert_dir "$PROJECT_DIR/tools"
YAML_COUNT=$(find "$PROJECT_DIR/tools" -name "*.yaml" | wc -l)
TOTAL=$((TOTAL + 1))
if [[ "$YAML_COUNT" -ge 20 ]]; then
	green "Tool YAML files: $YAML_COUNT (>= 20)"; PASS=$((PASS + 1))
else
	red "Too few tool YAML files: $YAML_COUNT"; FAIL=$((FAIL + 1))
fi
echo ""

blue "Testing Python compilation..."
TOTAL=$((TOTAL + 1))
if python3 -m py_compile "$PROJECT_DIR/src/generator.py" 2>/dev/null && \
   python3 -m py_compile "$PROJECT_DIR/src/parse_tools.py" 2>/dev/null; then
	green "Python files compile OK"; PASS=$((PASS + 1))
else
	red "Python compilation failed"; FAIL=$((FAIL + 1))
fi
echo ""

blue "Testing VERSION format..."
TOTAL=$((TOTAL + 1))
VERSION=$(cat "$PROJECT_DIR/VERSION" | tr -d '[:space:]')
if [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	green "VERSION valid: $VERSION"; PASS=$((PASS + 1))
else
	red "VERSION invalid: $VERSION"; FAIL=$((FAIL + 1))
fi
echo ""

echo "=========================================="
echo "  Results: $PASS passed, $FAIL failed (total: $TOTAL)"
echo "=========================================="
[[ "$FAIL" -gt 0 ]] && exit 1
exit 0
