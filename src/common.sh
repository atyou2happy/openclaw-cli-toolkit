#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC2034
COMMON_VERSION="$(cat "$(dirname "${BASH_SOURCE[0]}")/../VERSION" | tr -d '[:space:]')"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
# shellcheck disable=SC2034
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
_success() { echo -e "${GREEN}[OK]${NC} $*"; }
_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
_verbose() { [[ "${VERBOSE:-false}" == "true" ]] && echo -e "${DIM}[VERBOSE]${NC} $*" || true; }

ok() { _success "$@"; }
info() { _info "$@"; }
warn() { _warn "$@"; }
error() { _error "$@"; }

is_installed() {
	command -v "$1" &>/dev/null
}

ensure_dir() {
	local dir="$1"
	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		_info "[DRY-RUN] mkdir -p $dir"
		return
	fi
	mkdir -p "$dir"
}

PROGRESS_TOTAL=0
PROGRESS_CURRENT=0

progress_bar() {
	local current="$1" total="$2" width=40
	if [[ "$total" -eq 0 ]]; then
		printf "\r  ${CYAN}[%s]${NC} done (no tools)" "$(printf '%*s' "$width" '' | tr ' ' '░')"
		return
	fi
	local pct=$((current * 100 / total))
	local filled=$((current * width / total))
	local empty=$((width - filled))
	local bar=""
	for ((i = 0; i < filled; i++)); do bar+="█"; done
	for ((i = 0; i < empty; i++)); do bar+="░"; done
	printf "\r  ${CYAN}[%s]${NC} %3d%% (%d/%d)" "$bar" "$pct" "$current" "$total"
}

progress_step() {
	PROGRESS_CURRENT=$((PROGRESS_CURRENT + 1))
	progress_bar "$PROGRESS_CURRENT" "$PROGRESS_TOTAL"
}

progress_done() {
	progress_bar "$PROGRESS_TOTAL" "$PROGRESS_TOTAL"
	echo ""
}

write_config_file() {
	local filepath="$1"
	local content="$2"

	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		_info "[DRY-RUN] write $filepath"
		return
	fi

	local dir
	dir="$(dirname "$filepath")"
	mkdir -p "$dir"

	if [[ -f "$filepath" ]]; then
		local backup
		backup="${filepath}.bak.$(date +%s)"
		cp "$filepath" "$backup"
		_warn "Backed up existing $filepath to $backup"
	fi

	printf '%s\n' "$content" >"$filepath"
	_success "Written: $filepath"
}

shell_rc_file() {
	case "${SHELL_TYPE:-bash}" in
	zsh) echo "$HOME/.zshrc" ;;
	fish) echo "$HOME/.config/fish/config.fish" ;;
	*) echo "$HOME/.bashrc" ;;
	esac
}

shell_rc_d_dir() {
	case "${SHELL_TYPE:-bash}" in
	zsh) echo "$HOME/.zshrc.d" ;;
	*) echo "$HOME/.bashrc.d" ;;
	esac
}

append_to_shell_rc() {
	local marker="$1"
	local content="$2"
	local rc_file
	rc_file="$(shell_rc_file)"

	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		_info "[DRY-RUN] append to $rc_file: $marker"
		return
	fi

	if ! grep -qF "$marker" "$rc_file" 2>/dev/null; then
		printf '\n%s\n' "$content" >>"$rc_file"
		_success "Added $marker to $(basename "$rc_file")"
	fi
}
