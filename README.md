<p align="center">
  <strong>OpenClaw CLI Toolkit</strong>
</p>

<p align="center">
  One-click installer for 50+ curated CLI tools that supercharge your OpenClaw agent.<br/>
  Linux / WSL2 / macOS &bull; bash / zsh / fish
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"/></a>
  <img src="https://img.shields.io/badge/Tools-66+-brightgreen.svg" alt="Tools: 66+"/>
  <img src="https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh%20%7C%20Fish-orange.svg" alt="Shell Support"/>
  <a href="README_CN.md">中文文档</a>
</p>

---

## Why This Exists

OpenClaw (an AI coding agent) works best when your system has modern, fast CLI tools installed. This toolkit researches, evaluates, and installs the best **free & open-source** CLI replacements — so your agent can search faster, display better, and handle data smarter.

Every tool is:

- **Free & open-source** — zero hidden costs
- **Battle-tested** — compared against alternatives with real benchmarks
- **Agent-friendly** — auto-generates `openclaw-tools.yaml` for AI consumption
- **One-command management** — install, configure, and uninstall

## Features

- **15 categories** of tools — search, viewing, data, system, network, git, terminal, dev, security, archive, docs, download, ai, latex, formats (PDF/Excel/CSV/JSON/Markdown/HTML/XML), formats, latex
- **One-click install** — automatic system detection (WSL2 / Linux / macOS)
- **Config-driven** — `config.yaml` controls exactly which tools get installed
- **Shell-aware** — auto-detects bash / zsh / fish and configures accordingly
- **Resume support** — safely re-run to continue interrupted installs
- **Idempotent** — run multiple times without side effects
- **Go install** — `go install` supported as a 5th installation method
- **Security-hardened** — no command injection, `--no-install-recommends` for apt

## Quick Start

```bash
git clone https://github.com/atyou2happy/openclaw-cli-toolkit.git
cd openclaw-cli-toolkit

# Install everything (interactive)
./install.sh

# Preview what will be installed
./install.sh --dry-run

# Install specific categories only
./install.sh -c search -c data

# Force reinstall
./install.sh --force
```

## Usage

### Install

```bash
./install.sh                          # Install all enabled tools
./install.sh --dry-run                # Preview only (no changes)
./install.sh -c search -c data        # Specific categories
./install.sh --force                  # Force reinstall
./install.sh --skip-config            # Skip configuration step
./install.sh --clean-state            # Clear state and start fresh
./install.sh --help                   # Show all options
```

### Uninstall

```bash
./uninstall.sh                        # Remove all tools + config
./uninstall.sh --keep-config          # Keep configuration files
./uninstall.sh --yes                  # Skip confirmation prompt
```

### Generate Tool Definitions

```bash
python3 src/generator.py                          # Generate openclaw-tools.yaml
python3 src/generator.py --installed-only         # Only installed tools
python3 src/generator.py --output /path/to/file   # Custom output path
```

### Run Tests

```bash
bash tests/test_install.sh            # Structure & syntax tests
bash tests/test_tools.sh              # Tool functionality tests
```

## Project Structure

```
openclaw-cli-toolkit/
├── install.sh              # Entry point — thin orchestrator
├── uninstall.sh            # Uninstaller
├── config.yaml             # User configuration (enable/disable tools)
├── VERSION                 # Single source of truth for version
├── src/
│   ├── common.sh           # Logging, colors, progress bar, helpers
│   ├── state.sh            # Pure-bash install state tracking
│   ├── detector.sh         # OS / arch / package manager detection
│   ├── installer.sh        # Tool installation logic (apt/brew/cargo/pip/go)
│   ├── configurator.sh     # Shell aliases, tool configs, integrations
│   ├── generator.py        # Generate openclaw-tools.yaml for agents
│   └── parse_tools.py      # Parse tool YAML + config filtering
├── tools/                  # Tool definitions (13 YAML files)
│   ├── search.yaml
│   ├── viewer.yaml
│   ├── data.yaml
│   ├── system.yaml
│   ├── network.yaml
│   ├── git.yaml
│   ├── terminal.yaml
│   ├── dev.yaml
│   ├── security.yaml
│   ├── archive.yaml
│   ├── docs.yaml
│   ├── download.yaml
│   ├── ai.yaml
│   ├── latex.yaml
│   └── formats.yaml
├── tests/
│   ├── test_install.sh     # Structure & syntax tests
│   └── test_tools.sh       # Tool functionality tests
├── docs/
│   └── research.md         # Tool evaluation research report
├── .github/workflows/
│   └── ci.yml              # CI: shellcheck + syntax + test + dry-run
├── CHANGELOG.md
├── LICENSE
└── README.md               # This file
```

## Architecture

```
┌─────────────────────────────────────────────────┐
│                  install.sh                      │
│              (thin orchestrator)                 │
├─────────┬──────────┬───────────┬────────────────┤
│detector │installer │configurat │   generator    │
│  .sh    │  .sh     │  or.sh    │     .py        │
├─────────┼──────────┼───────────┼────────────────┤
│ OS/Arch │ apt      │ aliases   │ openclaw-      │
│ PM det  │ brew     │ rc files  │  tools.yaml    │
│ Shell   │ cargo    │ git pager │                │
│ WSL2    │ pip      │ fzf/zoxide│                │
│         │ go       │ starship  │                │
├─────────┴──────────┴───────────┴────────────────┤
│              common.sh + state.sh                │
│         (logging, progress, state file)          │
└─────────────────────────────────────────────────┘
```

**Flow**: `install.sh` → detect system → parse `tools/*.yaml` + filter by `config.yaml` → install each tool → configure shell → generate `openclaw-tools.yaml`

## Tool Categories

| Category | Tools | Replaces |
|----------|-------|----------|
| 🔍 Search | ripgrep, fd | grep, find |
| 👁️ Viewer | bat, eza, tree | cat, ls |
| 📊 Data | jq, yq, miller, dasel | manual parsing |
| 🖥️ System | btop, dust, duf, procs, hyperfine | htop, du, df, ps |
| 🌐 Network | httpie, doggo | curl, dig |
| 🔀 Git | delta, lazygit, tig, gh | default git UI |
| 🎛️ Terminal | fzf, zoxide, tmux, starship | manual navigation |
| 🛠️ Dev | shellcheck, shfmt, hadolint | manual review |
| 🔒 Security | age, sops | gpg |
| 📦 Archive | zstd, p7zip | gzip |
| 📄 Docs | pandoc, glow, poppler-utils | manual conversion |
| ⬇️ Download | aria2 | wget |
| 🤖 AI | llm, sgpt, aider | — |
| 📝 LaTeX | tectonic, chktex, latexmk | pdflatex + manual builds |
| 📄 Formats | qpdf, visidata, xsv, gron, htmlq, tidy, xmllint, xmlstarlet, lychee | manual format processing |

**Installation priority**: `apt` > `brew` > `cargo` > `pip` > `go install`

## Configuration

Edit `config.yaml` to customize which tools and categories are installed:

```yaml
categories:
  search:
    enabled: true
    tools:
      ripgrep:
        enabled: true
      the_silver_searcher:
        enabled: false  # skip this tool
```

## Requirements

- **OS**: Linux (Ubuntu 20.04+), WSL2, or macOS
- **Shell**: Bash 4.0+ / Zsh / Fish
- **Package manager**: at least one of apt, brew, cargo, pip, or go
- **Python**: 3.8+ (for YAML parsing and generation)

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-tool`)
3. Add/edit tool definitions in `tools/`
4. Test with `./install.sh --dry-run` and `bash tests/test_install.sh`
5. Ensure shellcheck passes: `shellcheck -s bash install.sh uninstall.sh src/*.sh tests/*.sh`
6. Submit a pull request

## License

[MIT License](LICENSE) — free to use, modify, and distribute.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release history.

---

<p align="center">
  <a href="README_CN.md">中文文档</a>
</p>
