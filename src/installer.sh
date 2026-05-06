#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

# Source all install method modules
for _method_file in "$METHODS_DIR"/*.sh; do
	[[ -f "$_method_file" ]] && source "$_method_file"
done
unset _method_file

INSTALL_LOG="${INSTALL_LOG:-/tmp/openclaw-toolkit-install.log}"

INSTALLED_TOOLS=()
FAILED_TOOLS=()
SKIPPED_TOOLS=()

log_install() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >>"$INSTALL_LOG"
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
	github_release)
		install_via_github_release "$package"
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
	local parser="$SRC_DIR/parse_tools.py"

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
