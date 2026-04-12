#!/usr/bin/env bash
set -euo pipefail

INSTALLER_VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$(dirname "$SCRIPT_DIR")/tools"

DRY_RUN=false
FORCE=false
VERBOSE=false
INSTALL_LOG="/tmp/openclaw-toolkit-install.log"

INSTALLED_TOOLS=()
FAILED_TOOLS=()
SKIPPED_TOOLS=()

_info()    { echo -e "\033[34m[INSTALL]\033[0m $*"; }
_warn()    { echo -e "\033[33m[WARN]\033[0m $*"; }
_success() { echo -e "\033[32m[OK]\033[0m $*"; }
_error()   { echo -e "\033[31m[ERROR]\033[0m $*" >&2; }
_verbose() { [[ "$VERBOSE" == "true" ]] && echo -e "\033[90m[VERBOSE]\033[0m $*" || true; }

log_install() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$INSTALL_LOG"
}

is_installed() {
    local binary="$1"
    command -v "$binary" &>/dev/null
}

install_via_apt() {
    local package="$1"
    if [[ "$DRY_RUN" == "true" ]]; then
        _info "[DRY-RUN] apt install -y $package"
        return 0
    fi
    _info "Installing $package via apt..."
    if sudo apt-get update -qq 2>/dev/null && sudo apt-get install -y -qq "$package" 2>>"$INSTALL_LOG"; then
        _success "$package installed via apt"
        log_install "SUCCESS: apt install $package"
        return 0
    else
        _warn "Failed to install $package via apt"
        log_install "FAIL: apt install $package"
        return 1
    fi
}

install_via_brew() {
    local package="$1"
    if [[ "$DRY_RUN" == "true" ]]; then
        _info "[DRY-RUN] brew install $package"
        return 0
    fi
    _info "Installing $package via brew..."
    if brew install "$package" 2>>"$INSTALL_LOG"; then
        _success "$package installed via brew"
        log_install "SUCCESS: brew install $package"
        return 0
    else
        _warn "Failed to install $package via brew"
        log_install "FAIL: brew install $package"
        return 1
    fi
}

install_via_cargo() {
    local package="$1"
    if [[ "$DRY_RUN" == "true" ]]; then
        _info "[DRY-RUN] cargo install $package"
        return 0
    fi
    _info "Installing $package via cargo..."
    if cargo install "$package" 2>>"$INSTALL_LOG"; then
        _success "$package installed via cargo"
        log_install "SUCCESS: cargo install $package"
        return 0
    else
        _warn "Failed to install $package via cargo"
        log_install "FAIL: cargo install $package"
        return 1
    fi
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

    if [[ "$DRY_RUN" == "true" ]]; then
        _info "[DRY-RUN] $pip_cmd install --user $package"
        return 0
    fi
    _info "Installing $package via pip..."
    if $pip_cmd install --user "$package" 2>>"$INSTALL_LOG"; then
        _success "$package installed via pip"
        log_install "SUCCESS: pip install $package"
        return 0
    else
        _warn "Failed to install $package via pip"
        log_install "FAIL: pip install $package"
        return 1
    fi
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
        *)
            _verbose "Unknown install method: $method"
            return 1
            ;;
    esac
}

parse_yaml_tools() {
    local yaml_file="$1"
    python3 -c "
import yaml, sys, json
data = yaml.safe_load(open('$yaml_file'))
if not data or 'tools' not in data:
    sys.exit(0)
for tool in data['tools']:
    name = tool.get('name', '')
    binary = tool.get('binary', '')
    package = tool.get('package', '')
    methods = [m.get('method', '') for m in tool.get('install_methods', [])]
    print(json.dumps({
        'name': name,
        'binary': binary,
        'package': package,
        'methods': methods
    }))
" 2>/dev/null
}

install_single_tool() {
    local name="$1"
    local binary="$2"
    local package="$3"
    shift 3
    local methods=("$@")

    if [[ "$FORCE" != "true" ]] && is_installed "${binary:-$name}"; then
        _verbose "$name already installed (${binary:-$name}), skipping (use --force to reinstall)"
        SKIPPED_TOOLS+=("$name")
        return 0
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

install_from_yaml() {
    local yaml_file="$1"
    local category
    category="$(basename "$yaml_file" .yaml)"

    if [[ ! -f "$yaml_file" ]]; then
        _error "YAML file not found: $yaml_file"
        return 1
    fi

    _info "Processing category: $category"

    if ! command -v python3 &>/dev/null; then
        _warn "python3 required for YAML parsing, skipping $category"
        return 1
    fi

    local tools_json
    tools_json="$(parse_yaml_tools "$yaml_file")" || return 1

    if [[ -z "$tools_json" ]]; then
        _warn "No tools found in $category"
        return 0
    fi

    while IFS= read -r tool_line; do
        [[ -z "$tool_line" ]] && continue
        local name binary package
        name="$(echo "$tool_line" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["name"])')"
        binary="$(echo "$tool_line" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["binary"])')"
        package="$(echo "$tool_line" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["package"])')"
        local methods_str
        methods_str="$(echo "$tool_line" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(" ".join(d["methods"]))')"

        local methods=()
        if [[ -n "$methods_str" ]]; then
            read -ra methods <<< "$methods_str"
        fi

        install_single_tool "$name" "$binary" "$package" "${methods[@]}"
    done <<< "$tools_json"
}

install_category() {
    local category="$1"
    local yaml_file="$TOOLS_DIR/${category}.yaml"

    if [[ ! -f "$yaml_file" ]]; then
        _error "Category not found: $category"
        return 1
    fi

    install_from_yaml "$yaml_file"
}

install_all() {
    _info "Installing all tools..."

    for yaml_file in "$TOOLS_DIR"/*.yaml; do
        [[ -f "$yaml_file" ]] || continue
        install_from_yaml "$yaml_file"
    done
}

install_report() {
    echo ""
    echo "=== Installation Report ==="
    echo ""
    echo "  Installed: ${#INSTALLED_TOOLS[@]} tools"
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
