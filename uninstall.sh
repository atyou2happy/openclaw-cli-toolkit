#!/usr/bin/env bash
# OpenClaw CLI Toolkit - Uninstaller
# Usage: ./uninstall.sh [--yes] [--category <name>] [--keep-config]

set -euo pipefail

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }

CONFIRM=false
CATEGORY=""
KEEP_CONFIG=false

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

OpenClaw CLI Toolkit - Uninstall tools and remove configurations

Options:
  -y, --yes          Skip confirmation prompt
  --category <name>  Only uninstall specific category
  --keep-config      Keep configuration files
  -h, --help         Show this help message
  --version          Show version

This will:
  1. Remove installed CLI tools via package managers
  2. Remove configuration files
  3. Remove shell integration lines from ~/.bashrc
  4. Remove generated openclaw-tools.yaml

EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes)       CONFIRM=true; shift ;;
        --category)     CATEGORY="$2"; shift 2 ;;
        --keep-config)  KEEP_CONFIG=true; shift ;;
        -h|--help)      usage ;;
        --version)      echo "v${VERSION}"; exit 0 ;;
        *)              echo "Unknown option: $1"; usage ;;
    esac
done

uninstall_via_apt() {
    local tools=(ripgrep fd-find silversearcher-ag bat eza lsd tree jq miller btop
                 bottom dust duf procs hyperfine httpie dog fzf zoxide tmux starship
                 shellcheck shfmt age sops pass zstd p7zip-full pandoc glow
                 poppler-utils chafa aria2 rclone tig gh git-delta lazygit)
    info "Removing tools via apt..."
    local count=0
    for tool in "${tools[@]}"; do
        if dpkg -l "$tool" &>/dev/null 2>&1; then
            sudo apt-get remove -y "$tool" 2>/dev/null && count=$((count+1)) || true
        fi
    done
    ok "Removed $count packages via apt"
}

uninstall_via_brew() {
    if ! command -v brew &>/dev/null; then return; fi
    local tools=(ripgrep fd bat eza lsd tree jq yq miller btop bottom dust duf procs
                 hyperfine httpie curlie dog nali fzf zoxide tmux starship shellcheck
                 shfmt hadolint actionlint age sops pass zstd ouch p7zip pandoc glow
                 poppler chafa aria2 rclone tig gh delta lazygit dasel fx)
    info "Removing tools via brew..."
    local count=0
    for tool in "${tools[@]}"; do
        if brew list "$tool" &>/dev/null 2>&1; then
            brew uninstall "$tool" 2>/dev/null && count=$((count+1)) || true
        fi
    done
    ok "Removed $count packages via brew"
}

uninstall_via_pip() {
    local pip_cmd=""
    if command -v pip3 &>/dev/null; then pip_cmd="pip3"
    elif command -v pip &>/dev/null; then pip_cmd="pip"
    else return; fi
    local tools=(httpie csvkit fx yq llm shell-gpt aider-chat hadolint)
    info "Removing tools via pip..."
    local count=0
    for tool in "${tools[@]}"; do
        if $pip_cmd show "$tool" &>/dev/null 2>&1; then
            $pip_cmd uninstall -y "$tool" 2>/dev/null && count=$((count+1)) || true
        fi
    done
    ok "Removed $count packages via pip"
}

remove_configs() {
    if [[ "$KEEP_CONFIG" == "true" ]]; then
        info "Keeping configuration files (--keep-config)"
        return
    fi
    info "Removing configuration files..."
    local configs=(
        "$HOME/.config/bat/config"
        "$HOME/.config/starship.toml"
        "$HOME/.config/lazygit/config.yml"
        "$HOME/.tmux.conf"
        "$HOME/.ripgreprc"
        "$HOME/.aria2/aria2.conf"
        "$HOME/.bashrc.d/fzf.sh"
        "$HOME/.bashrc.d/zoxide.sh"
        "$HOME/.bashrc.d/openclaw-aliases.sh"
        "$HOME/.config/openclaw-toolkit"
    )
    for cfg in "${configs[@]}"; do
        if [[ -e "$cfg" ]]; then
            rm -rf "$cfg"
        fi
    done
    rm -f "$SCRIPT_DIR/openclaw-tools.yaml" 2>/dev/null || true
    rm -f "/tmp/openclaw-toolkit-install.log" 2>/dev/null || true
    ok "Configuration files removed"
}

clean_bashrc() {
    local bashrc="$HOME/.bashrc"
    if [[ ! -f "$bashrc" ]]; then return; fi
    info "Cleaning .bashrc..."
    local tmp
    tmp="$(mktemp)"
    grep -v \
        -e "RIPGREP_CONFIG_PATH" \
        -e "fzf\.sh" \
        -e "zoxide\.sh" \
        -e "starship init" \
        -e "openclaw-aliases\.sh" \
        "$bashrc" > "$tmp" 2>/dev/null || true
    mv "$tmp" "$bashrc"
    ok "Cleaned .bashrc"
}

echo ""
warn "  ╔══════════════════════════════════════════╗"
warn "  ║   OpenClaw CLI Toolkit Uninstaller       ║"
warn "  ╚══════════════════════════════════════════╝"
echo ""

if [[ "$CONFIRM" != "true" ]]; then
    echo -e "${RED}WARNING: This will remove CLI tools and their configurations!${NC}"
    read -rp "Continue? [y/N] " response
    [[ "$response" != "y" && "$response" != "Y" ]] && echo "Cancelled." && exit 0
fi

uninstall_via_apt
uninstall_via_brew
uninstall_via_pip
remove_configs
clean_bashrc

echo ""
ok "Uninstallation complete. Run ${BLUE}source ~/.bashrc${NC} to update your shell."
