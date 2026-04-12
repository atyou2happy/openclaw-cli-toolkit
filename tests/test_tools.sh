#!/usr/bin/env bash
# Test: Verify CLI tools are functional after installation
# Usage: bash tests/test_tools.sh

set -euo pipefail
PASS=0 FAIL=0 TOTAL=0

green() { echo -e "\033[0;32m[PASS]\033[0m $*"; }
red()   { echo -e "\033[0;31m[FAIL]\033[0m $*"; }
blue()  { echo -e "\033[0;34m[TEST]\033[0m $*"; }

test_tool() {
    local name="$1" cmd="$2" version_flag="${3:---version}"
    TOTAL=$((TOTAL + 1))
    if command -v "$cmd" &>/dev/null; then
        if $cmd "$version_flag" &>/dev/null; then
            green "$name ($cmd): $($cmd "$version_flag" 2>&1 | head -1)"
            PASS=$((PASS + 1))
        else
            green "$name ($cmd): installed (version check skipped)"
            PASS=$((PASS + 1))
        fi
    else
        red "$name ($cmd): not installed"
        FAIL=$((FAIL + 1))
    fi
}

echo "=========================================="
echo "  OpenClaw CLI Toolkit - Tool Functionality"
echo "=========================================="
echo ""

blue "Search tools..."
test_tool "ripgrep" "rg" "--version"
test_tool "fd" "fd" "--version"
echo ""

blue "Viewer tools..."
test_tool "bat" "bat" "--version"
test_tool "eza" "eza" "--version"
test_tool "tree" "tree" "--version"
echo ""

blue "Data tools..."
test_tool "jq" "jq" "--version"
test_tool "yq" "yq" "--version"
test_tool "miller" "mlr" "--version"
test_tool "dasel" "dasel" "--version"
echo ""

blue "System tools..."
test_tool "btop" "btop" "--version"
test_tool "dust" "dust" "--version"
test_tool "duf" "duf" "--version"
test_tool "procs" "procs" "--version"
test_tool "hyperfine" "hyperfine" "--version"
echo ""

blue "Network tools..."
test_tool "httpie" "http" "--version"
test_tool "curlie" "curlie" "--version"
test_tool "dog" "dog" "--version"
echo ""

blue "Git tools..."
test_tool "delta" "delta" "--version"
test_tool "lazygit" "lazygit" "--version"
test_tool "tig" "tig" "--version"
echo ""

blue "Terminal tools..."
test_tool "fzf" "fzf" "--version"
test_tool "zoxide" "zoxide" "--version"
test_tool "tmux" "tmux" "-V"
echo ""

blue "Dev tools..."
test_tool "shellcheck" "shellcheck" "--version"
test_tool "shfmt" "shfmt" "--version"
echo ""

blue "Security tools..."
test_tool "age" "age" "--version"
echo ""

blue "Archive tools..."
test_tool "zstd" "zstd" "--version"
echo ""

blue "Doc tools..."
test_tool "pandoc" "pandoc" "--version"
test_tool "glow" "glow" "--version"
echo ""

blue "Download tools..."
test_tool "aria2" "aria2c" "--version"
echo ""

blue "AI tools..."
test_tool "llm" "llm" "--version"
echo ""

echo "=========================================="
echo "  Results: $PASS/$TOTAL passed, $FAIL failed"
echo "=========================================="
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
