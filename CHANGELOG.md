# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-04-13

### Added
- `src/common.sh` — shared functions (logging, colors, progress bar, config file writer, shell rc helpers)
- `src/state.sh` — pure bash state management (no python3 JSON dependency)
- `go install` as a supported installation method
- zsh support in configurator (auto-detects shell type)
- fish shell detection in configurator
- `.github/workflows/ci.yml` — CI pipeline (shellcheck, syntax, test, dry-run)
- `CHANGELOG.md`
- `--no-install-recommends` flag for apt installs (smaller footprint)

### Changed
- **BREAKING**: `dog` replaced with `doggo` (dog is deprecated, doggo is the maintained successor)
- `install.sh` refactored to thin orchestrator — all logic moved to dedicated modules
- Tool parsing now batch-processes all YAMLs in a single python3 call (4x faster)
- `config.yaml` is now actually read and used to filter tools during installation
- State files moved from project directory to `$XDG_DATA_HOME/openclaw-toolkit/state`
- `generator.py` version bumped to 2.0.0, `shutil` import moved to module level

### Fixed
- **SECURITY**: Command injection vulnerability in `state_record`/`parse_yaml_tools` — shell variables no longer interpolated into Python code
- **SECURITY**: `sudo apt-get install` hardened with `--no-install-recommends`
- All 15+ shellcheck warnings resolved (SC2046, SC2015, SC2034, SC2155, SC2016, etc.)
- Unused variables removed (`CONFIGURATOR_VERSION`, `TOOLS_DIR` in configurator)
- Progress bar now works correctly in sequential mode
- `append_to_shell_rc` helper prevents duplicate entries in shell config

### Removed
- Inline python3 JSON state management (replaced by pure bash)
- Per-tool 4x python3 invocation for JSON parsing (replaced by batch TSV parsing)
- Duplicate install logic between `install.sh` and `installer.sh`

## [1.0.0] - 2026-04-12

### Added
- Initial release with 13 tool categories, 50+ tools
- One-click installer with system detection
- Tool configuration (aliases, rc files, git pager)
- OpenClaw tools YAML generator
- Dry-run mode
- Uninstaller
- Bilingual README (English + Chinese)
- Research report
