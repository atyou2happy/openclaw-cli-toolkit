#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

VERSION="2.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"
TOOLS_DIR="$SCRIPT_DIR/tools"
CONFIG_FILE="$SCRIPT_DIR/config.yaml"

DRY_RUN=false
FORCE=false
VERBOSE=false
SKIP_CONFIG=false
SKIP_GENERATE=false
CLEAN_STATE=false
CATEGORIES=()
# shellcheck disable=SC2034
JOBS=4

source "$SRC_DIR/common.sh"

usage() {
	cat <<EOF
${BOLD}OpenClaw CLI Toolkit Installer v${VERSION}${NC}

${BOLD}Usage:${NC} $0 [OPTIONS]

${BOLD}Options:${NC}
  -c, --category CATEGORY    Install only specific category (repeatable)
  -d, --dry-run              Preview without installing
  -f, --force                Force reinstall (ignore state)
  -j, --jobs N               Parallel install jobs (default: 4)
  -v, --verbose              Verbose output
  --skip-config              Skip tool configuration
  --skip-generate            Skip openclaw-tools.yaml generation
  --clean-state              Remove install state and start fresh
  -h, --help                 Show help
  --version                  Show version

${BOLD}Categories:${NC} search, viewer, data, system, network, git,
            terminal, dev, security, archive, docs, download, ai

${BOLD}Examples:${NC}
  $0                          # Install all (resume from state)
  $0 --dry-run                # Preview
  $0 -c search -c data        # Specific categories
  $0 --force --jobs 8         # Force reinstall, 8 parallel
  $0 --clean-state            # Start fresh
EOF
	exit 0
}

parse_args() {
	while [[ $# -gt 0 ]]; do
		case "$1" in
		-c | --category)
			CATEGORIES+=("$2")
			shift 2
			;;
		-d | --dry-run)
			DRY_RUN=true
			shift
			;;
		-f | --force)
			FORCE=true
			shift
			;;
		-j | --jobs)
			JOBS="$2"
			shift 2
			;;
		-v | --verbose)
			VERBOSE=true
			shift
			;;
		--skip-config)
			SKIP_CONFIG=true
			shift
			;;
		--skip-generate)
			SKIP_GENERATE=true
			shift
			;;
		--clean-state)
			CLEAN_STATE=true
			shift
			;;
		-h | --help) usage ;;
		--version)
			echo "v${VERSION}"
			exit 0
			;;
		*)
			error "Unknown option: $1"
			usage
			;;
		esac
	done
}

check_prerequisites() {
	info "Checking prerequisites..."

	if ! command -v python3 &>/dev/null; then
		warn "python3 not found - some features disabled"
		SKIP_GENERATE=true
	fi

	local pm_found=false
	for pm in apt-get brew cargo pip3 go; do
		if command -v "$pm" &>/dev/null; then
			pm_found=true
			break
		fi
	done
	if ! $pm_found; then
		error "No package manager found (need apt, brew, cargo, pip, or go)"
		return 1
	fi

	ok "Prerequisites met"
}

source_modules() {
	source "$SRC_DIR/state.sh"
	source "$SRC_DIR/detector.sh"
	source "$SRC_DIR/installer.sh"
	source "$SRC_DIR/configurator.sh"
	if [[ "${CLEAN_STATE:-false}" == "true" ]]; then
		state_cleanup
	fi
}

detect_shell_type() {
	case "${SHELL:-/bin/bash}" in
	*/zsh) SHELL_TYPE="zsh" ;;
	*/fish) SHELL_TYPE="fish" ;;
	*) SHELL_TYPE="bash" ;;
	esac
	_verbose "Detected shell type: $SHELL_TYPE"
}

collect_tools() {
	TOOLS_LIST=()

	local config_arg=""
	if [[ -f "$CONFIG_FILE" ]]; then
		config_arg="$CONFIG_FILE"
	fi

	if [[ ${#CATEGORIES[@]} -gt 0 ]]; then
		local filtered_dir
		filtered_dir="$(mktemp -d)"
		for cat in "${CATEGORIES[@]}"; do
			local src="$TOOLS_DIR/${cat}.yaml"
			if [[ -f "$src" ]]; then
				cp "$src" "$filtered_dir/"
			else
				error "Category not found: $cat"
			fi
		done
		while IFS=$'\t' read -r name binary pkg methods category; do
			TOOLS_LIST+=("$name|$binary|$pkg|$methods|$category")
		done < <(parse_all_tools "$filtered_dir" "$config_arg")
		rm -rf "$filtered_dir"
	else
		while IFS=$'\t' read -r name binary pkg methods category; do
			TOOLS_LIST+=("$name|$binary|$pkg|$methods|$category")
		done < <(parse_all_tools "$TOOLS_DIR" "$config_arg")
	fi

	# shellcheck disable=SC2034
	PROGRESS_TOTAL=${#TOOLS_LIST[@]}
	_verbose "Collected ${#TOOLS_LIST[@]} tools to install"
}

install_one_tool() {
	local entry="$1"
	IFS='|' read -r name binary pkg methods category <<<"$entry"

	local bin="${binary:-$name}"

	if ! $FORCE && command -v "$bin" &>/dev/null; then
		state_record "skipped" "$name"
		progress_step
		return 0
	fi

	if ! $FORCE && state_is_done "$name"; then
		progress_step
		return 0
	fi

	if $DRY_RUN; then
		echo -e "  ${DIM}[DRY-RUN] Would install: $name${NC}"
		progress_step
		return 0
	fi

	local methods_arr=()
	if [[ -n "$methods" ]]; then
		read -ra methods_arr <<<"$methods"
	fi
	if [[ ${#methods_arr[@]} -eq 0 ]]; then
		methods_arr=("apt" "brew" "pip")
	fi

	for method in "${methods_arr[@]}"; do
		[[ -z "$method" ]] && continue
		if try_install_method "$method" "${pkg:-$name}"; then
			state_record "installed" "$name"
			progress_step
			return 0
		fi
	done

	state_record "failed" "$name"
	progress_step
	return 1
}

install_tools_sequential() {
	info "Installing ${#TOOLS_LIST[@]} tools..."

	if $DRY_RUN; then
		warn "DRY RUN MODE"
	fi

	for tool in "${TOOLS_LIST[@]}"; do
		install_one_tool "$tool"
	done

	progress_done
}

configure_tools() {
	if $SKIP_CONFIG; then
		info "Skipping configuration"
		return
	fi
	info "Configuring tools..."
	configure_all
}

generate_tools_yaml() {
	if $SKIP_GENERATE; then return; fi
	if ! command -v python3 &>/dev/null; then return; fi

	if $DRY_RUN; then
		info "[DRY-RUN] Would generate openclaw-tools.yaml"
		return
	fi

	info "Generating openclaw-tools.yaml..."
	if python3 -c "import yaml" 2>/dev/null; then
		python3 "$SRC_DIR/generator.py" --output "$SCRIPT_DIR/openclaw-tools.yaml"
	elif command -v uv &>/dev/null; then
		uv run --with pyyaml python3 "$SRC_DIR/generator.py" --output "$SCRIPT_DIR/openclaw-tools.yaml"
	else
		_warn "pyyaml not available, skipping generation"
		return
	fi
	ok "Generated openclaw-tools.yaml"
}

final_report() {
	local installed skipped failed
	installed="$(state_get_count "installed")"
	skipped="$(state_get_count "skipped")"
	failed="$(state_get_count "failed")"

	echo ""
	echo -e "${GREEN}  ╔══════════════════════════════════════════╗"
	echo -e "  ║     Installation Complete!               ║"
	echo -e "  ╚══════════════════════════════════════════╝${NC}"
	echo ""
	echo -e "  ${GREEN}Installed:${NC} $installed    ${YELLOW}Skipped:${NC} $skipped    ${RED}Failed:${NC} $failed"
	echo -e "  State saved: ${DIM}$STATE_FILE${NC}"
	echo -e "  Run ${CYAN}source $(shell_rc_file)${NC} to apply changes"
	echo -e "  Re-run to ${CYAN}resume${NC} any failed installs"
	echo ""

	if $DRY_RUN; then warn "(Dry run - no changes made)"; fi
	if [[ "$failed" -gt 0 ]]; then
		warn "Failed tools:"
		state_get_list "failed" | while read -r t; do
			echo "    - $t"
		done
		echo ""
		info "Re-run with --force to retry failed tools"
	fi
}

main() {
	parse_args "$@"

	echo ""
	echo -e "${CYAN}  ╔══════════════════════════════════════════╗"
	echo -e "  ║   OpenClaw CLI Toolkit Installer v${VERSION}  ║"
	echo -e "  ╚══════════════════════════════════════════╝${NC}"
	echo ""

	check_prerequisites || exit 1
	source_modules
	detect_all || exit 1
	detect_shell_type

	state_init
	collect_tools

	echo -e "${BLUE}[1/3]${NC} Installing tools..."
	install_tools_sequential

	echo -e "${BLUE}[2/3]${NC} Configuring..."
	configure_tools

	echo -e "${BLUE}[3/3]${NC} Generating definitions..."
	generate_tools_yaml

	final_report
}

main "$@"
