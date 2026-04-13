#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

PASS=0 FAIL=0 TOTAL=0

green() { echo -e "\033[0;32m[PASS]\033[0m $*"; }
red() { echo -e "\033[0;31m[FAIL]\033[0m $*"; }
blue() { echo -e "\033[0;34m[TEST]\033[0m $*"; }

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

assert_source_ok() {
	TOTAL=$((TOTAL + 1))
	if bash -n "$1" 2>/dev/null; then
		green "Syntax OK: $1"
		PASS=$((PASS + 1))
	else
		red "Syntax error: $1"
		FAIL=$((FAIL + 1))
	fi
}

echo "=========================================="
echo "  OpenClaw CLI Toolkit v2.0 - Install Test"
echo "=========================================="
echo ""

blue "Testing project structure..."
assert_file "$PROJECT_DIR/install.sh"
assert_file "$PROJECT_DIR/uninstall.sh"
assert_file "$PROJECT_DIR/config.yaml"
assert_file "$PROJECT_DIR/LICENSE"
assert_file "$PROJECT_DIR/VERSION"
assert_file "$PROJECT_DIR/.gitignore"
assert_file "$PROJECT_DIR/.editorconfig"
assert_file "$PROJECT_DIR/src/common.sh"
assert_file "$PROJECT_DIR/src/state.sh"
assert_file "$PROJECT_DIR/src/detector.sh"
assert_file "$PROJECT_DIR/src/installer.sh"
assert_file "$PROJECT_DIR/src/configurator.sh"
assert_file "$PROJECT_DIR/src/generator.py"
echo ""

blue "Testing executable permissions..."
assert_executable "$PROJECT_DIR/install.sh"
assert_executable "$PROJECT_DIR/uninstall.sh"
echo ""

blue "Testing shell syntax..."
for f in "$PROJECT_DIR"/install.sh "$PROJECT_DIR"/uninstall.sh "$PROJECT_DIR"/src/*.sh; do
	assert_source_ok "$f"
done
echo ""

blue "Testing tool definitions..."
for yaml in "$PROJECT_DIR"/tools/*.yaml; do
	assert_file "$yaml"
done
echo ""

blue "Testing dry-run mode..."
TOTAL=$((TOTAL + 1))
dry_run_output="$(bash "$PROJECT_DIR/install.sh" --dry-run 2>&1 || true)"
if echo "$dry_run_output" | grep -qi "dry"; then
	green "Dry-run mode works"
	PASS=$((PASS + 1))
else
	red "Dry-run mode failed"
	FAIL=$((FAIL + 1))
fi
echo ""

blue "Testing generator..."
TOTAL=$((TOTAL + 1))
if python3 -c "import yaml" 2>/dev/null; then
	gen_cmd="python3"
elif command -v uv &>/dev/null; then
	gen_cmd="uv run --with pyyaml python3"
else
	gen_cmd=""
fi
if [[ -n "$gen_cmd" ]] && $gen_cmd "$PROJECT_DIR/src/generator.py" --tools-dir "$PROJECT_DIR/tools" --output /tmp/test-openclaw-tools.yaml 2>/dev/null; then
	green "Generator runs successfully"
	PASS=$((PASS + 1))
	assert_file "/tmp/test-openclaw-tools.yaml"
	rm -f /tmp/test-openclaw-tools.yaml
else
	red "Generator failed (pyyaml not available)"
	FAIL=$((FAIL + 1))
fi
echo ""

echo "=========================================="
echo "  Results: $PASS/$TOTAL passed, $FAIL failed"
echo "=========================================="
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
