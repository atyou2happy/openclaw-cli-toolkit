#!/usr/bin/env bash
set -euo pipefail

VERSION="2.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/src/common.sh"
source "$SCRIPT_DIR/src/state.sh"

CONFIRM=false
KEEP_CONFIG=false

usage() {
	cat <<EOF
${BOLD}Usage:${NC} $(basename "$0") [OPTIONS]

OpenClaw CLI Toolkit v${VERSION} - Uninstall tools and remove configurations

${BOLD}Options:${NC}
  -y, --yes          Skip confirmation prompt
  --category <name>  Only uninstall specific category
  --keep-config      Keep configuration files
  -h, --help         Show this help message
  --version          Show version

This will:
  1. Remove installed CLI tools via package managers
  2. Remove configuration files
  3. Remove shell integration lines from shell rc
  4. Remove generated openclaw-tools.yaml
EOF
	exit 0
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	-y | --yes)
		CONFIRM=true
		shift
		;;
	--keep-config)
		KEEP_CONFIG=true
		shift
		;;
	-h | --help) usage ;;
	--version)
		echo "v${VERSION}"
		exit 0
		;;
	*)
		echo "Unknown option: $1"
		usage
		;;
	esac
done

uninstall_via_apt() {
	local tools=(ripgrep fd-find silversearcher-ag bat eza lsd tree jq miller btop
		bottom dust duf procs hyperfine httpie doggo fzf zoxide tmux starship
		shellcheck shfmt age sops pass zstd p7zip-full pandoc glow
		poppler-utils chafa aria2 rclone tig gh git-delta lazygit)
	info "Removing tools via apt..."
	local count=0
	for tool in "${tools[@]}"; do
		if dpkg -l "$tool" &>/dev/null 2>&1; then
			sudo apt-get remove -y "$tool" 2>/dev/null && count=$((count + 1)) || true
		fi
	done
	ok "Removed $count packages via apt"
}

uninstall_via_brew() {
	if ! command -v brew &>/dev/null; then return; fi
	local tools=(ripgrep fd bat eza lsd tree jq yq miller btop bottom dust duf procs
		hyperfine httpie curlie doggo nali fzf zoxide tmux starship shellcheck
		shfmt hadolint actionlint age sops pass zstd ouch p7zip pandoc glow
		poppler chafa aria2 rclone tig gh delta lazygit dasel fx)
	info "Removing tools via brew..."
	local count=0
	for tool in "${tools[@]}"; do
		if brew list "$tool" &>/dev/null 2>&1; then
			brew uninstall "$tool" 2>/dev/null && count=$((count + 1)) || true
		fi
	done
	ok "Removed $count packages via brew"
}

uninstall_via_pip() {
	local pip_cmd=""
	if command -v pip3 &>/dev/null; then
		pip_cmd="pip3"
	elif command -v pip &>/dev/null; then
		pip_cmd="pip"
	else return; fi
	local tools=(httpie csvkit fx yq llm shell-gpt aider-chat hadolint)
	info "Removing tools via pip..."
	local count=0
	for tool in "${tools[@]}"; do
		if $pip_cmd show "$tool" &>/dev/null 2>&1; then
			$pip_cmd uninstall -y "$tool" 2>/dev/null && count=$((count + 1)) || true
		fi
	done
	ok "Removed $count packages via pip"
}

remove_configs() {
	if $KEEP_CONFIG; then
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
		"$HOME/.zshrc.d/fzf.sh"
		"$HOME/.zshrc.d/zoxide.sh"
		"$HOME/.zshrc.d/openclaw-aliases.sh"
		"${XDG_CONFIG_HOME:-$HOME/.config}/openclaw-toolkit"
	)
	local cfg
	for cfg in "${configs[@]}"; do
		if [[ -e "$cfg" ]]; then
			rm -rf "$cfg"
		fi
	done
	rm -f "$SCRIPT_DIR/openclaw-tools.yaml" 2>/dev/null || true
	rm -f "/tmp/openclaw-toolkit-install.log" 2>/dev/null || true
	state_cleanup
	ok "Configuration files removed"
}

clean_shell_rc() {
	local rc_files=("$HOME/.bashrc" "$HOME/.zshrc")
	local rc_file
	for rc_file in "${rc_files[@]}"; do
		if [[ ! -f "$rc_file" ]]; then continue; fi
		info "Cleaning $(basename "$rc_file")..."
		local backup
		backup="${rc_file}.bak.$(date +%s)"
		cp "$rc_file" "$backup"
		local tmp
		tmp="$(mktemp)"
		grep -v \
			-e "RIPGREP_CONFIG_PATH" \
			-e "fzf\.sh" \
			-e "zoxide\.sh" \
			-e "starship init" \
			-e "openclaw-aliases\.sh" \
			"$rc_file" >"$tmp" 2>/dev/null || true
		mv "$tmp" "$rc_file"
		ok "Cleaned $(basename "$rc_file") (backup: $backup)"
	done
}

clean_git_config() {
	if git config --global core.pager &>/dev/null && [[ "$(git config --global core.pager)" == "delta" ]]; then
		info "Cleaning delta git config..."
		git config --global --unset core.pager 2>/dev/null || true
		git config --global --unset interactive.diffFilter 2>/dev/null || true
		git config --global --unset delta.navigate 2>/dev/null || true
		git config --global --unset delta.side-by-side 2>/dev/null || true
		git config --global --unset delta.line-numbers 2>/dev/null || true
		ok "Cleaned delta git config"
	fi
}

echo ""
warn "  ╔══════════════════════════════════════════╗"
warn "  ║   OpenClaw CLI Toolkit Uninstaller v${VERSION}  ║"
warn "  ╚══════════════════════════════════════════╝"
echo ""

if ! $CONFIRM; then
	echo -e "${RED}WARNING: This will remove CLI tools and their configurations!${NC}"
	read -rp "Continue? [y/N] " response
	[[ "$response" != "y" && "$response" != "Y" ]] && echo "Cancelled." && exit 0
fi

uninstall_via_apt
uninstall_via_brew
uninstall_via_pip
remove_configs
clean_shell_rc
clean_git_config

echo ""
ok "Uninstallation complete. Run ${CYAN}source ~/.bashrc${NC} to update your shell."
