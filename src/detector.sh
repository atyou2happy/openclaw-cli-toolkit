#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC2034
DETECTOR_VERSION="2.0.0"

DETECTED_OS=""
DETECTED_DISTRO=""
DETECTED_ARCH=""
DETECTED_WSL2=false
DETECTED_PACKAGE_MANAGERS=()
DETECTED_SHELL=""

detect_os() {
	if [[ "$(uname -s)" == "Linux" ]]; then
		DETECTED_OS="linux"
	elif [[ "$(uname -s)" == "Darwin" ]]; then
		DETECTED_OS="macos"
	else
		DETECTED_OS="unknown"
	fi
}

detect_distro() {
	if [[ "$DETECTED_OS" == "linux" ]]; then
		if [[ -f /etc/os-release ]]; then
			DETECTED_DISTRO="$(grep '^ID=' /etc/os-release 2>/dev/null | head -1 | cut -d= -f2 | tr -d '"' || echo "unknown")"
		elif [[ -f /etc/lsb-release ]]; then
			DETECTED_DISTRO="$(grep '^DISTRIB_ID=' /etc/lsb-release 2>/dev/null | head -1 | cut -d= -f2 | tr '[:upper:]' '[:lower:]' || echo "unknown")"
		else
			DETECTED_DISTRO="unknown"
		fi
	elif [[ "$DETECTED_OS" == "macos" ]]; then
		DETECTED_DISTRO="macos"
	else
		DETECTED_DISTRO="unknown"
	fi
}

detect_wsl2() {
	if [[ "$DETECTED_OS" == "linux" ]]; then
		if grep -qi microsoft /proc/version 2>/dev/null; then
			DETECTED_WSL2=true
		fi
	fi
}

detect_arch() {
	local arch
	arch="$(uname -m)"
	case "$arch" in
	x86_64) DETECTED_ARCH="amd64" ;;
	aarch64) DETECTED_ARCH="arm64" ;;
	armv7l) DETECTED_ARCH="armv7" ;;
	*) DETECTED_ARCH="$arch" ;;
	esac
}

detect_package_manager() {
	DETECTED_PACKAGE_MANAGERS=()

	if command -v apt-get &>/dev/null; then
		DETECTED_PACKAGE_MANAGERS+=("apt")
	fi
	if command -v brew &>/dev/null; then
		DETECTED_PACKAGE_MANAGERS+=("brew")
	fi
	if command -v cargo &>/dev/null; then
		DETECTED_PACKAGE_MANAGERS+=("cargo")
	fi
	if command -v pip3 &>/dev/null || command -v pip &>/dev/null; then
		DETECTED_PACKAGE_MANAGERS+=("pip")
	fi
	if command -v go &>/dev/null; then
		DETECTED_PACKAGE_MANAGERS+=("go")
	fi
	if command -v conda &>/dev/null; then
		DETECTED_PACKAGE_MANAGERS+=("conda")
	fi
}

detect_shell() {
	DETECTED_SHELL="${SHELL:-/bin/bash}"
}

detect_all() {
	echo ""
	echo "=== System Detection ==="
	echo ""

	detect_os
	detect_distro
	detect_arch
	detect_wsl2
	detect_package_manager
	detect_shell

	echo "  OS:               $DETECTED_OS"
	echo "  Distribution:     $DETECTED_DISTRO"
	echo "  Architecture:     $DETECTED_ARCH"
	echo "  WSL2:             $DETECTED_WSL2"
	echo "  Package Managers: ${DETECTED_PACKAGE_MANAGERS[*]}"
	echo "  Shell:            $DETECTED_SHELL"
	echo ""

	if [[ "$DETECTED_OS" == "unknown" ]]; then
		_error "Unsupported operating system"
		return 1
	fi

	if [[ ${#DETECTED_PACKAGE_MANAGERS[@]} -eq 0 ]]; then
		_warn "No supported package managers found"
		_info "Install at least one of: apt, brew, cargo, pip, go"
		return 1
	fi

	_success "System detection complete"
	echo ""
	return 0
}

get_preferred_package_manager() {
	for pm in apt brew cargo pip go; do
		if [[ " ${DETECTED_PACKAGE_MANAGERS[*]} " == *" $pm "* ]]; then
			echo "$pm"
			return
		fi
	done
	echo ""
}

ensure_package_manager() {
	local pm
	pm="$(get_preferred_package_manager)"
	if [[ -z "$pm" ]]; then
		_error "No package manager available"
		return 1
	fi
	echo "$pm"
}

is_wsl2() {
	[[ "$DETECTED_WSL2" == "true" ]]
}

is_ubuntu() {
	[[ "$DETECTED_DISTRO" == "ubuntu" ]]
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	detect_all
fi
