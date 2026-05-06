# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [5.0.0] - 2026-05-07

### Changed — Architecture Refactoring

- **Modular install methods**: Split `src/installer.sh` (394 lines) into 6 independent modules under `src/methods/` (apt.sh, brew.sh, cargo.sh, pip.sh, go.sh, github.sh), with installer.sh as a thin dispatcher (~120 lines)
- **Centralized paths**: New `src/paths.sh` consolidates all path/version calculations (previously duplicated across 5 files)
- **Python code quality**: Fixed exception swallowing in `parse_tools.py` (bare `except: pass` → specific error types + stderr logging), replaced bare `open()` with `with` context managers, added full type annotations

### Added

- **Python test suite**: 229 pytest tests covering generator.py, parse_tools.py, and all 26 YAML schema validations
- **Shell structure tests**: 27 tests for file existence, syntax, and project integrity
- **Makefile**: Developer convenience targets (`make lint`, `make test`, `make check`, `make generate`)
- **pyproject.toml**: Ruff + pytest configuration (dev-only, not for packaging)
- **CI enhancement**: New `python-test` job in GitHub Actions for automated pytest runs

### Fixed

- Added `npm` to valid install methods (was used in security.yaml but not recognized by schema)

## [4.0.0] - 2026-04-26

### Added — 5 New Categories

- **Kubernetes** (`tools/kubernetes.yaml`):
  - `kubectl` — Kubernetes control CLI (apt, brew)
  - `helm` — K8s package manager (apt, brew)
  - `k9s` — Terminal UI for Kubernetes (brew)
  - `popeye` — K8s cluster sanitizer (brew, go)
  - `stern` — Multi-pod log tailing (brew, go)
  - `kubectx` — K8s context switcher (brew)

- **Go Development** (`tools/golang.yaml`):
  - `golangci-lint` — Go linter aggregator (brew, go, cargo)
  - `staticcheck` — Go static analysis (go)
  - `goimports` — Format imports (go)
  - `godef` — Go to definition (go)
  - `gore` — Go REPL (go)
  - `ginkgo` — Go BDD testing (go)
  - `buf` — Protocol buffers linter (brew, go)

- **Observability** (`tools/observability.yaml`):
  - `stern` — Tail K8s logs (brew, go)
  - `logcli` — Loki CLI (brew, go)
  - `promtool` — Prometheus CLI (brew, go)
  - `ctop` — Container metrics (brew, apt)
  - `glances` — System monitor (apt, brew, pip)

- **Git Helpers** (`tools/git-helpers.yaml`):
  - `git-lfs` — Git Large File Storage (apt, brew)
  - `ghq` — Git remote management (brew, go)
  - `git-filter-repo` — Rewrite git history (pip, brew)
  - `myrepos` — Multi-repo management (brew, pip)

- **Testing** (`tools/testing.yaml`):
  - `bats` — Bash testing framework (apt, brew, pip)
  - `coverage` — Python coverage CLI (pip)
  - `junit2html` — JUnit to HTML converter (pip, go)
  - `cricket` — Python coverage GUI (pip)

### Added — Tools in Existing Categories

- **terminal**: `autojump` — Directory jumping (apt, brew), `zellij` — Modern tmux alternative (brew, cargo)
- **security**: `bitwarden-cli` — Bitwarden vault CLI (brew), `vault` — HashiCorp Vault CLI (brew, apt)
- **network**: `mtr` — Traceroute + ping combined (apt, brew), `nmap` — Network scanner (apt, brew)

### Changed

- Now **26 categories, 140+ tools** total (was 21 categories, 107 tools)
- `actionlint` now enabled by default
- `ffmpeg` now enabled by default

## [3.1.0] - 2026-04-14

### Added — 2 New Categories

- **API Testing & Load** (`tools/api-testing.yaml`):
  - `wrk` — multithreaded HTTP benchmarking tool with Lua scripting (apt, brew)
  - `hey` — Go-based HTTP load generator (brew, go)
  - `oha` — Rust-based HTTP load generator with real-time TUI (brew, cargo)
  - `hurl` — HTTP request runner with plain-text definition language (apt, brew)
  - `httpyac` — multi-file HTTP request runner with variables and auth [disabled] (pip, brew)
  - `step` — crypto and certificate management CLI (TLS/SSH/JWT/x509) [disabled] (brew, github_release)
  - `grpcurl` — command-line gRPC client like curl (brew, go)
- **Text Processing** (`tools/text-processing.yaml`):
  - `sd` — intuitive find & replace, sed alternative (brew, cargo)
  - `gum` — glamorous TUI widgets for shell scripts (brew, go)
  - `jnv` — interactive JSON navigator with live jq preview [disabled] (brew, cargo)
  - `choose` — human-friendly column extraction, cut alternative (brew, cargo)
  - `huniq` — fast order-preserving duplicate line removal [disabled] (brew, cargo)
  - `grep-ast` — AST-aware source code search with context (pip)
  - `repgrep` — interactive ripgrep with file preview [disabled] (brew, cargo)
  - `tabulate` — pretty-print tabular data in Markdown/RST/HTML (pip, apt, brew)
  - `ugrep` — ultra-fast Unicode-aware text search [disabled] (apt, brew)

### Changed

- Now **21 categories, 107 tools** total (was 19 categories, 87+ tools)
- `install.sh` usage text updated with new categories
- `config.yaml` updated with api-testing and text-processing entries

## [3.0.0] - 2026-04-13

### Added — 4 New Categories

- **Container** (`tools/container.yaml`):
  - `docker` — build, run, manage containers (apt, brew)
  - `docker-compose` — multi-container orchestration (apt, brew)
- **Database** (`tools/database.yaml`):
  - `sqlite3` — CLI for SQLite databases (apt, brew)
  - `usql` — universal SQL CLI for all database backends (brew, go)
- **Media** (`tools/media.yaml`):
  - `imagemagick` — image processing Swiss army knife (apt, brew)
  - `exiftool` — read/write EXIF metadata in images/PDFs (apt, brew)
  - `ffmpeg` — audio/video record, convert, stream (apt, brew) [disabled]
- **Diagram** (`tools/diagram.yaml`):
  - `d2` — text-to-diagram language (brew, go)
  - `graphviz` — graph visualization with DOT language (apt, brew)

### Added — 12 Tools in Existing Categories

- **search**: `ast-grep` — AST-aware structural code search (brew, cargo)
- **git**: `difftastic` — structural diff that understands code syntax (apt, brew, cargo)
- **dev**: `ruff` — fast Python linter+formatter (apt, brew, pip, cargo)
- **dev**: `just` — modern Make alternative command runner (apt, brew, cargo)
- **dev**: `uv` — ultra-fast Python package manager (brew, pip, cargo)
- **formats**: `yamllint` — YAML linter (apt, brew, pip)
- **formats**: `taplo` — TOML toolkit (brew, cargo)
- **data**: `jo` — generate JSON from shell (apt, brew)
- **system**: `watchexec` — execute commands on file change (brew, cargo)
- **system**: `tokei` — count lines of code by language (apt, brew, cargo)
- **system**: `parallel` — GNU parallel batch processing (apt, brew)
- **terminal**: `direnv` — auto-set env vars per directory (apt, brew)
- **network**: `gping` — ping with real-time graph (apt, brew, cargo)
- **download**: `rsync` — fast incremental file sync (apt, brew)

### Changed

- **BREAKING**: version bumped to 3.0.0 due to scope expansion (19 categories, 87 tools)
- Now **19 categories, 87 tools** total

## [2.5.0] - 2026-04-13

### Added
- `weasyprint` — HTML/CSS to PDF rendering engine with full CSS Paged Media support (pip, brew)
- Now **15 categories, 67 tools** total

## [2.4.0] - 2026-04-13

### Added
- **HTML/XML tools** added to formats category (4 tools):
  - `htmlq` — HTML parser with CSS selectors, extract elements and attributes (cargo, brew)
  - `tidy` — HTML/XHTML/XML formatter, validator, and cleaner (apt, brew)
  - `xmllint` (libxml2-utils) — XML validator, XPath query, and pretty-printer (apt, brew)
  - `xmlstarlet` — XML transformation toolkit: edit, select, validate, XSLT (apt, brew)
- Now **15 categories, 66 tools** total

## [2.3.0] - 2026-04-13

### Added
- **Formats category** with 7 tools covering PDF, Excel, CSV, JSON, and Markdown:
  - `qpdf` — PDF merge, split, rotate, encrypt, decrypt (apt, brew)
  - `img2pdf` — lossless image-to-PDF conversion (pip, apt)
  - `visidata` — interactive terminal data viewer for xlsx/csv/json/sqlite and 40+ formats (pip, apt, brew)
  - `xsv` — fast CSV/TSV toolkit: index, slice, join, stats (cargo, brew)
  - `gron` — flatten JSON for grep-friendly searching (apt, brew, cargo)
  - `markdownlint-cli` — Markdown linting and style checking (brew, pip)
  - `lychee` — fast async link checker for Markdown/HTML (cargo, brew)
- Now **15 categories, 62 tools** total

## [2.2.0] - 2026-04-13

### Added
- **LaTeX category** with 3 tools:
  - `tectonic` — modern self-contained LaTeX engine (no TeX Live needed)
  - `chktex` — LaTeX syntax and style checker
  - `latexmk` — automate multi-pass LaTeX compilation
- `tools/latex.yaml` tool definitions
- `latex` category in `config.yaml` (enabled by default)

## [2.1.0] - 2026-04-13

### Added
- `VERSION` file — single source of truth for version number
- `.gitignore` — exclude generated files, caches, OS files
- `.editorconfig` — unify coding style (tabs for shell, spaces for Python/YAML)

### Changed
- All scripts now read version from `VERSION` file (no more hardcoded version in 6 files)
- README.md and README_CN.md rewritten with standard open-source layout (badges, architecture, project structure, contributing)
- Development process files (proposal.md, design.md, tasks.md) moved to `docs/dev/`

### Removed
- `src/openclaw-tools.yaml` — duplicate generated file removed (root-level one is the canonical copy)

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
