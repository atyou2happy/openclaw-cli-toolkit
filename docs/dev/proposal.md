# Proposal: OpenClaw CLI Toolkit v4.0 — Expand Tool Ecosystem

> Project: `openclaw-cli-toolkit` | Mode: Full | License: MIT

## 1. Summary & Vision

Upgrade OpenClaw CLI Toolkit from v3.1.0 (21 categories, 107 tools) to v4.0 with **5 new categories** and **35+ new tools**, targeting 140+ tools total. Focus on tools that directly enhance AI coding agent capabilities: language-specific linters, build systems, testing frameworks, observability, and git workflow enhancers.

**Design Philosophy**: Add depth over breadth. Each new tool must provide clear value to an AI agent doing software development tasks.

## 2. Problem Statement

Current gaps limiting AI agent effectiveness:

| Gap | Impact | Solution |
|-----|--------|----------|
| No Go/Rust language tools | Can't assist effectively on Go/Rust projects | Add golangci-lint, staticcheck, rust-analyzer, cargo tools |
| No Kubernetes tools | Can't work with containerized environments | Add kubectl, helm, k9s, popeye |
| No observability/log tools | Can't debug production issues | Add stern, logcli, promtool |
| No git workflow enhancers | Git operations less efficient | Add git-lfs, ghq, git-filter-repo |
| No testing frameworks | Can't run/test code effectively | Add bats, coverage, junit2html |
| No secrets management | Can't handle sensitive data securely | Add vault, bitwarden-cli |

## 3. New Categories

### 3.1 kubernetes (NEW)

**Rationale**: Kubernetes is standard for container orchestration. AI agents need kubectl, helm, and k9s to work with containerized applications.

| Tool | Purpose | Install Methods |
|------|---------|----------------|
| kubectl | Kubernetes CLI | apt, brew |
| helm | K8s package manager | apt, brew |
| k9s | Terminal UI for K8s | brew, download |
| popeye | K8s cluster sanitizer | brew, go |
| stern | Tail K8s logs | brew, go |
| kubectx | Switch K8s contexts/namespaces | brew |

### 3.2 golang (NEW)

**Rationale**: Go is widely used (Docker, Kubernetes, etc). AI agents need Go-specific linting and formatting tools.

| Tool | Purpose | Install Methods |
|------|---------|----------------|
| golangci-lint | Go linter aggregator | brew, go, cargo |
| staticcheck | Go static analysis | go |
| goimports | Format imports | go |
| godef | Go to definition | go |
| gore | Go REPL | go |
| ginkgo | Go testing framework | go |

### 3.3 observability (NEW)

**Rationale**: AI agents debugging production need log aggregation and metrics tools.

| Tool | Purpose | Install Methods |
|------|---------|----------------|
| stern | Tail multiple pods | brew, go |
| logcli | Loki CLI | brew, go |
| promtool | Prometheus CLI | brew, go |
| ctop | Container metrics | brew, apt |
| glances | System monitor | apt, brew, pip |

### 3.4 git-helpers (NEW - extends git category)

**Rationale**: Enhanced git workflows beyond what delta/lazygit provide.

| Tool | Purpose | Install Methods |
|------|---------|----------------|
| git-lfs | Git Large File Storage | apt, brew |
| ghq | Git remote management | brew, go |
| git-filter-repo | Rewrite git history | pip, brew |
| myrepos | Multi-repo management | brew, pip |

### 3.5 testing (NEW)

**Rationale**: AI agents need testing tools for various languages and frameworks.

| Tool | Purpose | Install Methods |
|------|---------|----------------|
| bats | Bash testing framework | apt, brew, pip |
| cricket | Python coverage UI | pip |
| coverage | Python coverage CLI | pip |
| junit2html | JUnit to HTML | pip, go |

## 4. Depth Additions (Existing Categories)

### 4.1 dev.yaml — Add Language-Specific Tools

| Tool | Purpose | Install |
|------|---------|---------|
| buf | Protocol buffers linter | brew, go |
| hadolint | Already present, ensure enabled | - |
| actionlint | Already present, ensure enabled | - |

### 4.2 git.yaml — Add Workflow Tools

| Tool | Purpose | Install |
|------|---------|---------|
| git-lfs | Large file support | apt, brew |
| ghq | Clone management | brew, go |

### 4.3 terminal.yaml — Add Navigation Tools

| Tool | Purpose | Install |
|------|---------|---------|
| autojump | Directory jumping | apt, brew |
| zellij | Tmux alternative | brew, cargo |

### 4.4 security.yaml — Add Secrets Management

| Tool | Purpose | Install |
|------|---------|---------|
| bitwarden-cli | Bitwarden CLI | brew |
| vault | HashiCorp Vault | brew, apt |

### 4.5 network.yaml — Add Network Diagnostics

| Tool | Purpose | Install |
|------|---------|---------|
| mtr | Traceroute + ping | apt, brew |
| nmap | Network scanner | apt, brew |

## 5. Tool Selection Criteria

For each tool added:

- ✅ **Free & open source** — no paid-only tools
- ✅ **Active maintenance** — updated within 6 months OR long-stable project
- ✅ **Multiple install methods** — at least 2 of apt/brew/cargo/pip/go
- ✅ **Clear AI agent benefit** — enhances agent capabilities
- ✅ **No external dependencies** — doesn't require cloud auth to install

**Excluded tools**:
- ❌ AWS/GCP/Azure CLIs — require auth setup, maintenance burden
- ❌ Complex tools needing config — kubectl needs kubeconfig
- ❌ Language runtimes — Node.js, Python are base system tools

## 6. Success Metrics

| Metric | v3.1.0 (Baseline) | v4.0 (Target) |
|--------|-------------------|----------------|
| Total tools | 107 | 140+ |
| Categories | 21 | 26 |
| New categories | — | 5 (kubernetes, golang, observability, git-helpers, testing) |
| apt-available tools | ~50 | 65+ |
| brew-available tools | ~90 | 120+ |

## 7. Risk Assessment

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Too many new tools = maintenance burden | Medium | Prioritize high-value tools only |
| Some tools may not work on all platforms | Low | Multiple install methods per tool |
| Version drift in YAML | Medium | CI validates YAML syntax |
| Users overwhelmed by options | Low | Most new tools disabled by default in config.yaml |

## 8. Implementation Scope

**Phase 1** (This upgrade):
- Create 5 new category YAML files
- Add tools to 6 existing category YAML files
- Update config.yaml with new categories
- Update documentation (README, CHANGELOG)
- Regenerate openclaw-tools.yaml

**Phase 2** (Future):
- Add Rust/C++/Java language tools
- Add more observability integrations
- Add package manager helpers (pipx, nix)
