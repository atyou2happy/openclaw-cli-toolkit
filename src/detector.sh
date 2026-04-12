#!/usr/bin/env bash
set -euo pipefail

DETECTOR_VERSION="1.0.0"

DETECTED_OS=""
DETECTED_DISTRO=""
DETECTED_ARCH=""
DETECTED_WSL2=false
DETECTED_PACKAGE_MANAGERS=()
DETECTED_SHELL=""

_info()    { echo -e "\033[34m[DETECT]\033[0m $*"; }
_warn()    { echo -e "\033[33m[WARN]\033[0m $*"; }
_success() { echo -e "\033[32m[OK]\033[0m $*"; }
_error()   { echo -e "\033[31m[ERROR]\033[0m $*" >&2; }

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
            source /etc/os-release
            DETECTED_DISTRO="${ID:-unknown}"
        elif [[ -f /etc/lsb-release ]]; then
            source /etc/lsb-release
            DETECTED_DISTRO="${DISTRIB_ID,,:-unknown}"
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
        x86_64)  DETECTED_ARCH="amd64" ;;
        aarch64) DETECTED_ARCH="arm64" ;;
        armv7l)  DETECTED_ARCH="armv7" ;;
        *)       DETECTED_ARCH="$arch" ;;
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
        _info "Install at least one of: apt, brew, cargo, pip"
        return 1
    fi

    _success "System detection complete"
    echo ""
    return 0
}

get_preferred_package_manager() {
    for pm in apt brew cargo pip; do
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
    detect_wsl2 &>/dev/null
    [[ "$DETECTED_WSL2" == "true" ]]
}

is_ubuntu() {
    detect_distro &>/dev/null
    [[ "$DETECTED_DISTRO" == "ubuntu" ]]
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    detect_all
fi
