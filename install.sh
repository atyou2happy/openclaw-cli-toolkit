#!/usr/bin/env bash
# OpenClaw CLI Toolkit - One-Click Installer
# Supports: WSL2, Ubuntu, Debian, macOS
# Usage: ./install.sh [--dry-run] [--category <name>] [--force] [--skip-config]

set -euo pipefail

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"
TOOLS_DIR="$SCRIPT_DIR/tools"

DRY_RUN=false
FORCE=false
VERBOSE=false
SKIP_CONFIG=false
SKIP_GENERATE=false
CATEGORIES=()

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

usage() {
    cat <<EOF
OpenClaw CLI Toolkit Installer v${VERSION}

Usage: $0 [OPTIONS]

Options:
  -c, --category CATEGORY    Install only tools from specified category
                             (search, viewer, data, system, network, git,
                              terminal, dev, security, archive, docs,
                              download, ai)
  -d, --dry-run              Show what would be installed without installing
  -f, --force                Force reinstall even if tool is already installed
  -v, --verbose              Verbose output
  --skip-config              Skip tool configuration step
  --skip-generate            Skip openclaw-tools.yaml generation
  -h, --help                 Show this help message
  --version                  Show version

Examples:
  $0                          # Install all tools
  $0 --dry-run                # Preview installation
  $0 --category search        # Only install search tools (rg, fd, etc.)
  $0 -c search -c data        # Install search and data tools
  $0 --force --category git   # Force reinstall git tools

Available categories:
  search     - File search (ripgrep, fd, ag, ack)
  viewer     - File viewing (bat, eza, lsd, tree)
  data       - Data processing (jq, yq, miller, csvkit, fx, dasel)
  system     - System monitoring (btop, bottom, dust, duf, procs, hyperfine)
  network    - Network tools (httpie, curlie, dog, nali, wget2)
  git        - Git enhancement (delta, lazygit, tig, gh)
  terminal   - Terminal tools (fzf, zoxide, tmux, starship)
  dev        - Development (shellcheck, shfmt, hadolint, actionlint)
  security   - Security (age, sops, pass)
  archive    - Compression (zstd, ouch, 7zip)
  docs       - Documents (pandoc, glow, poppler-utils, chafa)
  download   - Download (aria2, rclone)
  ai         - AI assistance (aider, llm, sgpt)

EOF
    exit 0
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--category)  CATEGORIES+=("$2"); shift 2 ;;
            -d|--dry-run)   DRY_RUN=true; shift ;;
            -f|--force)     FORCE=true; shift ;;
            -v|--verbose)   VERBOSE=true; shift ;;
            --skip-config)  SKIP_CONFIG=true; shift ;;
            --skip-generate) SKIP_GENERATE=true; shift ;;
            -h|--help)      usage ;;
            --version)      echo "v${VERSION}"; exit 0 ;;
            *)              error "Unknown option: $1"; usage ;;
        esac
    done
}

check_prerequisites() {
    info "Checking prerequisites..."

    if ! command -v bash &>/dev/null; then
        error "bash is required"
        return 1
    fi

    if ! command -v python3 &>/dev/null; then
        warn "python3 not found - generation step will be skipped"
        SKIP_GENERATE=true
    fi

    local pm_count=0
    for pm in apt-get brew cargo pip3 pip; do
        if command -v "$pm" &>/dev/null; then
            pm_count=$((pm_count + 1))
        fi
    done

    if [[ $pm_count -eq 0 ]]; then
        error "No supported package manager found. Install at least one of: apt, brew, cargo, pip"
        return 1
    fi

    ok "Prerequisites met"
}

source_modules() {
    local saved_dry_run="$DRY_RUN"
    local saved_force="$FORCE"
    local saved_verbose="$VERBOSE"
    source "$SRC_DIR/detector.sh"
    source "$SRC_DIR/installer.sh"
    source "$SRC_DIR/configurator.sh"
    DRY_RUN="$saved_dry_run"
    FORCE="$saved_force"
    VERBOSE="$saved_verbose"
}

install_tools() {
    if [[ ${#CATEGORIES[@]} -gt 0 ]]; then
        for cat in "${CATEGORIES[@]}"; do
            info "Category: $cat"
            install_category "$cat"
        done
    else
        install_all
    fi
}

configure_tools() {
    if [[ "$SKIP_CONFIG" == "true" ]]; then
        info "Skipping configuration (--skip-config)"
        return
    fi
    configure_all
}

generate_tools_yaml() {
    if [[ "$SKIP_GENERATE" == "true" ]]; then
        info "Skipping generation (--skip-generate)"
        return
    fi

    if ! command -v python3 &>/dev/null; then
        warn "python3 not available, skipping generation"
        return
    fi

    if ! python3 -c "import yaml" 2>/dev/null; then
        info "Installing PyYAML..."
        pip3 install --user -q pyyaml 2>/dev/null || pip install --user -q pyyaml 2>/dev/null || true
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY-RUN] Would generate openclaw-tools.yaml"
        return
    fi

    info "Generating openclaw-tools.yaml..."
    python3 "$SRC_DIR/generator.py" --output "$SCRIPT_DIR/openclaw-tools.yaml"
    ok "Generated openclaw-tools.yaml"
}

main() {
    parse_args "$@"

    echo ""
    echo -e "${CYAN}  ╔══════════════════════════════════════════╗"
    echo -e "  ║     OpenClaw CLI Toolkit Installer       ║"
    echo -e "  ║            Version ${VERSION}               ║"
    echo -e "  ╚══════════════════════════════════════════╝${NC}"
    echo ""

    if [[ "$DRY_RUN" == "true" ]]; then
        warn "DRY RUN MODE - no changes will be made"
        echo ""
    fi

    check_prerequisites || exit 1
    source_modules
    detect_all || exit 1

    echo -e "${BLUE}[STEP 1/3]${NC} Installing tools..."
    install_tools
    install_report

    echo -e "${BLUE}[STEP 2/3]${NC} Configuring tools..."
    configure_tools

    echo -e "${BLUE}[STEP 3/3]${NC} Generating tool definitions..."
    generate_tools_yaml

    echo ""
    echo -e "${GREEN}  ╔══════════════════════════════════════════╗"
    echo -e "  ║     Installation Complete!               ║"
    echo -e "  ╚══════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  Run ${CYAN}source ~/.bashrc${NC} to apply shell changes"
    echo -e "  View installed tools: ${CYAN}cat openclaw-tools.yaml${NC}"
    echo ""

    if [[ "$DRY_RUN" == "true" ]]; then
        warn "(This was a dry run - no changes were made)"
    fi
}

main "$@"
