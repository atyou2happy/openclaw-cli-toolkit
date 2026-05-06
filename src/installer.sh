#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

INSTALL_LOG="${INSTALL_LOG:-/tmp/openclaw-toolkit-install.log}"

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
	if apt-get update -qq 2>/dev/null && apt-get install -y --no-install-recommends -qq "$package" 2>>"$INSTALL_LOG"; then
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

	local proxies=("$(go env GOPROXY)" "https://goproxy.cn,direct" "https://goproxy.io,direct")
	for proxy in "${proxies[@]}"; do
		_info "Installing $package via go (proxy: ${proxy%%,*})..."
		if GOPROXY="$proxy" go install "$package" 2>>"$INSTALL_LOG"; then
			_success "$package installed via go"
			log_install "SUCCESS: go install $package (proxy: ${proxy%%,*})"
			return 0
		fi
	done
	_warn "Failed to install $package via go (tried all proxies)"
	log_install "FAIL: go install $package"
	return 1
}

# Package format: "owner/repo[#archive_binary[=install_name]]"
install_via_github_release() {
	local package="$1"
	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		_info "[DRY-RUN] github_release install $package"
		return 0
	fi
	if ! command -v curl &>/dev/null; then
		_verbose "curl not available for github_release"
		return 1
	fi

	local repo="${package%%#*}"
	local rest="${package#*#}"
	local archive_binary=""
	local install_as=""
	if [[ "$rest" != "$package" ]]; then
		archive_binary="${rest%%=*}"
		install_as="${rest#*=}"
		[[ "$install_as" == "$rest" ]] && install_as="$archive_binary"
	fi
	[[ -z "$archive_binary" ]] && archive_binary=""
	[[ -z "$install_as" ]] && install_as="$(basename "$repo")"

	local owner="${repo%%/*}"
	local proj="${repo##*/}"

	_info "Installing $repo via GitHub release..."

	local os_name arch_names
	os_name="$(uname -s | tr '[:upper:]' '[:lower:]')"
	case "$(uname -m)" in
	x86_64 | amd64) arch_names="amd64 x86_64" ;;
	aarch64 | arm64) arch_names="arm64 aarch64" ;;
	armv7l | arm) arch_names="arm armv7" ;;
	*) arch_names="$(uname -m)" ;;
	esac

	local api_url="https://api.github.com/repos/${owner}/${proj}/releases/latest"
	local release_json
	release_json="$(curl -sL --retry 3 --retry-delay 2 --retry-all-errors "$api_url" 2>>"$INSTALL_LOG")" || {
		_warn "Failed to fetch GitHub releases for $repo"
		log_install "FAIL: github_release $repo (API fetch failed)"
		return 1
	}

	local tag
	tag="$(echo "$release_json" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tag_name',''))" 2>/dev/null)" || true
	if [[ -z "$tag" ]]; then
		_warn "Could not determine latest release for $repo (API may be rate-limited or unreachable)"
		log_install "FAIL: github_release $repo (no tag found)"
		return 1
	fi

	local download_url=""
	local asset_name=""
	while IFS=$'\t' read -r name url; do
		local lower_name
		lower_name="$(echo "$name" | tr '[:upper:]' '[:lower:]')"
		local arch_matched=false
		for arch in $arch_names; do
			[[ "$lower_name" == *"$arch"* ]] && arch_matched=true && break
		done
		if [[ "$lower_name" == *"$os_name"* ]] && $arch_matched; then
			if [[ -z "$download_url" ]] || [[ "$lower_name" == *"static"* ]]; then
				download_url="$url"
				asset_name="$name"
			fi
		fi
	done < <(echo "$release_json" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for a in data.get('assets', []):
    print(f\"{a['name']}\t{a['browser_download_url']}\")
" 2>/dev/null)

	if [[ -z "$download_url" ]]; then
		_warn "No matching release asset found for $repo ($os_name/$arch_name)"
		log_install "FAIL: github_release $repo (no matching asset)"
		return 1
	fi

	_info "Downloading $asset_name ..."
	local tmp_dir
	tmp_dir="$(mktemp -d)"
	local tmp_file="${tmp_dir}/${asset_name}"

	if ! curl -sL --retry 3 --retry-delay 2 --retry-all-errors -o "$tmp_file" "$download_url" 2>>"$INSTALL_LOG"; then
		_warn "Failed to download $asset_name"
		rm -rf "$tmp_dir"
		log_install "FAIL: github_release $repo (download failed)"
		return 1
	fi

	case "$asset_name" in
	*.tar.bz2)
		tar xjf "$tmp_file" -C "$tmp_dir" 2>>"$INSTALL_LOG"
		;;
	*.tar.gz | *.tgz)
		tar xzf "$tmp_file" -C "$tmp_dir" 2>>"$INSTALL_LOG"
		;;
	*.zip)
		unzip -o -q "$tmp_file" -d "$tmp_dir" 2>>"$INSTALL_LOG"
		;;
	*.tar.xz)
		tar xJf "$tmp_file" -C "$tmp_dir" 2>>"$INSTALL_LOG"
		;;
	*)
		chmod +x "$tmp_file"
		;;
	esac

	local install_target=""
	if [[ -n "$archive_binary" ]]; then
		install_target="$(find "$tmp_dir" -maxdepth 2 -name "$archive_binary" -type f -executable 2>/dev/null | head -1)" || true
	fi
	if [[ -z "$install_target" ]]; then
		install_target="$(find "$tmp_dir" -maxdepth 2 -name "$proj" -type f -executable 2>/dev/null | head -1)" || true
	fi
	if [[ -z "$install_target" ]]; then
		install_target="$(find "$tmp_dir" -maxdepth 2 -name "${proj}*" -type f -executable 2>/dev/null | head -1)" || true
	fi

	if [[ -z "$install_target" ]]; then
		_warn "Could not find binary in $asset_name"
		rm -rf "$tmp_dir"
		log_install "FAIL: github_release $repo (binary not found in archive)"
		return 1
	fi

	local dest_dir
	if command -v brew &>/dev/null; then
		dest_dir="$(brew --prefix)/bin"
	elif [[ -d /usr/local/bin ]] && [[ -w /usr/local/bin ]]; then
		dest_dir="/usr/local/bin"
	else
		dest_dir="$HOME/.local/bin"
		mkdir -p "$dest_dir"
	fi

	cp "$install_target" "${dest_dir}/${install_as}" 2>>"$INSTALL_LOG"
	chmod +x "${dest_dir}/${install_as}"
	rm -rf "$tmp_dir"

	_success "$repo installed via GitHub release ($tag) -> ${dest_dir}/${install_as}"
	log_install "SUCCESS: github_release $repo ($tag)"
	return 0
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
