#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

INSTALLER_VERSION="2.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$(dirname "$SCRIPT_DIR")/tools"

INSTALL_LOG="/tmp/openclaw-toolkit-install.log"

INSTALLED_TOOLS=()
FAILED_TOOLS=()
SKIPPED_TOOLS=()

log_install() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >>"$INSTALL_LOG"
}

install_via_apt() {
	local package="$1"
	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		_info "[DRY-RUN] apt install -y $package"
		return 0
	fi
	_info "Installing $package via apt..."
	if sudo apt-get update -qq 2>/dev/null && sudo apt-get install -y --no-install-recommends -qq "$package" 2>>"$INSTALL_LOG"; then
		_success "$package installed via apt"
		log_install "SUCCESS: apt install $package"
		return 0
	fi
	_warn "Failed to install $package via apt"
	log_install "FAIL: apt install $package"
	return 1
}

install_via_brew() {
	local package="$1"
	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		_info "[DRY-RUN] brew install $package"
		return 0
	fi
	_info "Installing $package via brew..."
	if brew install "$package" 2>>"$INSTALL_LOG"; then
		_success "$package installed via brew"
		log_install "SUCCESS: brew install $package"
		return 0
	fi
	_warn "Failed to install $package via brew"
	log_install "FAIL: brew install $package"
	return 1
}

install_via_cargo() {
	local package="$1"
	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		_info "[DRY-RUN] cargo install $package"
		return 0
	fi
	_info "Installing $package via cargo..."
	if cargo install "$package" 2>>"$INSTALL_LOG"; then
		_success "$package installed via cargo"
		log_install "SUCCESS: cargo install $package"
		return 0
	fi
	_warn "Failed to install $package via cargo"
	log_install "FAIL: cargo install $package"
	return 1
}

install_via_pip() {
	local package="$1"
	local pip_cmd
	if command -v pip3 &>/dev/null; then
		pip_cmd="pip3"
	elif command -v pip &>/dev/null; then
		pip_cmd="pip"
	else
		_warn "pip not found"
		return 1
	fi

	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		_info "[DRY-RUN] $pip_cmd install --user $package"
		return 0
	fi
	_info "Installing $package via pip..."
	if $pip_cmd install --user "$package" 2>>"$INSTALL_LOG"; then
		_success "$package installed via pip"
		log_install "SUCCESS: pip install $package"
		return 0
	fi
	_warn "Failed to install $package via pip"
	log_install "FAIL: pip install $package"
	return 1
}

install_via_go() {
	local package="$1"
	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		_info "[DRY-RUN] go install $package"
		return 0
	fi
	_info "Installing $package via go..."
	if go install "$package" 2>>"$INSTALL_LOG"; then
		_success "$package installed via go"
		log_install "SUCCESS: go install $package"
		return 0
	fi
	_warn "Failed to install $package via go"
	log_install "FAIL: go install $package"
	return 1
}

try_install_method() {
	local method="$1"
	local package="$2"

	case "$method" in
	apt)
		if command -v apt-get &>/dev/null; then
			install_via_apt "$package"
		else
			_verbose "apt-get not available"
			return 1
		fi
		;;
	brew)
		if command -v brew &>/dev/null; then
			install_via_brew "$package"
		else
			_verbose "brew not available"
			return 1
		fi
		;;
	cargo)
		if command -v cargo &>/dev/null; then
			install_via_cargo "$package"
		else
			_verbose "cargo not available"
			return 1
		fi
		;;
	pip)
		if command -v pip3 &>/dev/null || command -v pip &>/dev/null; then
			install_via_pip "$package"
		else
			_verbose "pip not available"
			return 1
		fi
		;;
	go)
		if command -v go &>/dev/null; then
			install_via_go "$package"
		else
			_verbose "go not available"
			return 1
		fi
		;;
	*)
		_verbose "Unknown install method: $method"
		return 1
		;;
	esac
}

parse_all_tools() {
	local tools_dir="$1"
	local config_file="${2:-}"
	local parser="$SCRIPT_DIR/parse_tools.py"

	if python3 -c "import yaml" 2>/dev/null; then
		python3 "$parser" "$tools_dir" "$config_file"
	elif command -v uv &>/dev/null; then
		uv run --with pyyaml python3 "$parser" "$tools_dir" "$config_file"
	else
		_warn "python3 pyyaml not available, cannot parse tool definitions"
		_warn "Install with: pip install pyyaml  OR  uv pip install pyyaml"
		return 1
	fi
}

install_single_tool() {
	local name="$1"
	local binary="$2"
	local package="$3"
	local methods_str="$4"

	if [[ "${FORCE:-false}" != "true" ]] && is_installed "${binary:-$name}"; then
		_verbose "$name already installed (${binary:-$name}), skipping"
		SKIPPED_TOOLS+=("$name")
		return 0
	fi

	local methods=()
	if [[ -n "$methods_str" ]]; then
		read -ra methods <<<"$methods_str"
	fi
	if [[ ${#methods[@]} -eq 0 ]]; then
		methods=("apt" "brew" "pip")
	fi

	for method in "${methods[@]}"; do
		if [[ -z "$method" ]]; then continue; fi
		_verbose "Trying $method for $name..."
		if try_install_method "$method" "${package:-$name}"; then
			INSTALLED_TOOLS+=("$name")
			return 0
		fi
	done

	_error "Failed to install $name with any available method"
	FAILED_TOOLS+=("$name")
	return 1
}

install_report() {
	echo ""
	echo "=== Installation Report ==="
	echo ""
	echo "  Installed: ${#INSTALLED_TOOLS[@]} tools"
	local t
	for t in "${INSTALLED_TOOLS[@]:-}"; do [[ -n "$t" ]] && echo "    + $t"; done 2>/dev/null || true
	echo ""
	echo "  Skipped (already installed): ${#SKIPPED_TOOLS[@]}"
	for t in "${SKIPPED_TOOLS[@]:-}"; do [[ -n "$t" ]] && echo "    = $t"; done 2>/dev/null || true
	echo ""
	echo "  Failed: ${#FAILED_TOOLS[@]}"
	for t in "${FAILED_TOOLS[@]:-}"; do [[ -n "$t" ]] && echo "    - $t"; done 2>/dev/null || true
	echo ""
	echo "  Log file: $INSTALL_LOG"
	echo ""
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	echo "This script is meant to be sourced, not run directly."
	echo "Use install.sh as the entry point."
	exit 1
fi
