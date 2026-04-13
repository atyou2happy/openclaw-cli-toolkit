<p align="center">
  <strong>OpenClaw CLI 工具包</strong>
</p>

<p align="center">
  为 OpenClaw AI 代理精选的 50+ CLI 工具一键安装器。<br/>
  Linux / WSL2 / macOS &bull; bash / zsh / fish
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/许可证-MIT-blue.svg" alt="License: MIT"/></a>
  <img src="https://img.shields.io/badge/工具-55+-brightgreen.svg" alt="工具: 55+"/>
  <img src="https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh%20%7C%20Fish-orange.svg" alt="Shell 支持"/>
  <a href="README.md">English</a>
</p>

---

## 为什么需要这个？

OpenClaw（AI 编程代理）在安装了现代高性能 CLI 工具的系统上表现最佳。本工具包负责研究、评估并安装最优的**免费开源** CLI 替代工具——让你的代理搜索更快、显示更好、数据处理更智能。

每个工具都经过：

- **免费开源** — 零隐藏成本
- **实战验证** — 与同类工具对比测试和基准评测
- **AI 友好** — 自动生成 `openclaw-tools.yaml` 供代理直接使用
- **一条命令管理** — 安装、配置、卸载

## 特性

- **14 个类别** — 搜索、查看、数据、系统、网络、Git、终端、开发、安全、压缩、文档、下载、AI、LaTeX
- **一键安装** — 自动检测系统（WSL2 / Linux / macOS）
- **配置驱动** — `config.yaml` 精确控制安装哪些工具
- **Shell 智能识别** — 自动检测 bash / zsh / fish 并配置对应环境
- **断点续装** — 安全重试中断的安装
- **幂等安全** — 多次运行无副作用
- **Go install** — 支持第 5 种安装方式
- **安全加固** — 修复命令注入漏洞，apt 安装使用 `--no-install-recommends`

## 快速开始

```bash
git clone https://github.com/atyou2happy/openclaw-cli-toolkit.git
cd openclaw-cli-toolkit

# 安装所有推荐工具（交互式）
./install.sh

# 预览将安装的工具
./install.sh --dry-run

# 只安装特定类别
./install.sh -c search -c data

# 强制重装
./install.sh --force
```

## 使用方法

### 安装

```bash
./install.sh                          # 安装所有启用的工具
./install.sh --dry-run                # 仅预览（不做任何更改）
./install.sh -c search -c data        # 指定类别
./install.sh --force                  # 强制重装
./install.sh --skip-config            # 跳过配置步骤
./install.sh --clean-state            # 清除状态重新开始
./install.sh --help                   # 显示所有选项
```

### 卸载

```bash
./uninstall.sh                        # 移除所有工具和配置
./uninstall.sh --keep-config          # 保留配置文件
./uninstall.sh --yes                  # 跳过确认提示
```

### 生成工具定义

```bash
python3 src/generator.py                          # 生成 openclaw-tools.yaml
python3 src/generator.py --installed-only         # 仅已安装的工具
python3 src/generator.py --output /path/to/file   # 自定义输出路径
```

### 运行测试

```bash
bash tests/test_install.sh            # 结构和语法测试
bash tests/test_tools.sh              # 工具功能测试
```

## 项目结构

```
openclaw-cli-toolkit/
├── install.sh              # 入口 — 轻量编排器
├── uninstall.sh            # 卸载器
├── config.yaml             # 用户配置（启用/禁用工具）
├── VERSION                 # 版本号唯一来源
├── src/
│   ├── common.sh           # 日志、颜色、进度条、辅助函数
│   ├── state.sh            # 纯 Bash 安装状态追踪
│   ├── detector.sh         # OS / 架构 / 包管理器检测
│   ├── installer.sh        # 工具安装逻辑（apt/brew/cargo/pip/go）
│   ├── configurator.sh     # Shell 别名、工具配置、集成
│   ├── generator.py        # 生成 openclaw-tools.yaml
│   └── parse_tools.py      # 解析工具 YAML + 配置过滤
├── tools/                  # 工具定义（13 个 YAML 文件）
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
│   └── latex.yaml
├── tests/
│   ├── test_install.sh     # 结构和语法测试
│   └── test_tools.sh       # 工具功能测试
├── docs/
│   └── research.md         # 工具评估研究报告
├── .github/workflows/
│   └── ci.yml              # CI：shellcheck + 语法 + 测试 + dry-run
├── CHANGELOG.md
├── LICENSE
└── README_CN.md            # 本文件
```

## 架构

```
┌─────────────────────────────────────────────────┐
│                  install.sh                      │
│              （轻量编排器）                        │
├─────────┬──────────┬───────────┬────────────────┤
│detector │installer │configurat │   generator    │
│  .sh    │  .sh     │  or.sh    │     .py        │
├─────────┼──────────┼───────────┼────────────────┤
│ OS/架构 │ apt      │ 别名      │ openclaw-      │
│ PM 检测 │ brew     │ rc 文件   │  tools.yaml    │
│ Shell   │ cargo    │ git pager │                │
│ WSL2    │ pip      │ fzf/zoxide│                │
│         │ go       │ starship  │                │
├─────────┴──────────┴───────────┼────────────────┤
│              common.sh + state.sh               │
│         （日志、进度、状态文件）                    │
└─────────────────────────────────────────────────┘
```

**流程**: `install.sh` → 系统检测 → 解析 `tools/*.yaml` + `config.yaml` 过滤 → 逐个安装 → 配置 Shell → 生成 `openclaw-tools.yaml`

## 工具类别

| 类别 | 工具 | 替代 |
|------|------|------|
| 🔍 搜索 | ripgrep, fd | grep, find |
| 👁️ 查看 | bat, eza, tree | cat, ls |
| 📊 数据 | jq, yq, miller, dasel | 手动解析 |
| 🖥️ 系统 | btop, dust, duf, procs, hyperfine | htop, du, df, ps |
| 🌐 网络 | httpie, doggo | curl, dig |
| 🔀 Git | delta, lazygit, tig, gh | 默认 git UI |
| 🎛️ 终端 | fzf, zoxide, tmux, starship | 手动导航 |
| 🛠️ 开发 | shellcheck, shfmt, hadolint | 人工审查 |
| 🔒 安全 | age, sops | gpg |
| 📦 压缩 | zstd, p7zip | gzip |
| 📄 文档 | pandoc, glow, poppler-utils | 手动转换 |
| ⬇️ 下载 | aria2 | wget |
| 🤖 AI | llm, sgpt, aider | — |
| 📝 LaTeX | tectonic, chktex, latexmk | pdflatex + 手动编译 |

**安装优先级**: `apt` > `brew` > `cargo` > `pip` > `go install`

## 配置

编辑 `config.yaml` 自定义安装的工具：

```yaml
categories:
  search:
    enabled: true
    tools:
      ripgrep:
        enabled: true
      the_silver_searcher:
        enabled: false  # 跳过此工具
```

## 系统要求

- **操作系统**: Linux（Ubuntu 20.04+）、WSL2、macOS
- **Shell**: Bash 4.0+ / Zsh / Fish
- **包管理器**: 至少一个 apt、brew、cargo、pip、go
- **Python**: 3.8+（用于 YAML 解析和生成）

## 贡献

欢迎贡献！请：

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/my-tool`)
3. 在 `tools/` 中添加/编辑工具定义
4. 使用 `./install.sh --dry-run` 和 `bash tests/test_install.sh` 测试
5. 确保 shellcheck 通过: `shellcheck -s bash install.sh uninstall.sh src/*.sh tests/*.sh`
6. 提交 Pull Request

## 许可证

[MIT License](LICENSE) — 可自由使用、修改和分发。

## 更新日志

详见 [CHANGELOG.md](CHANGELOG.md)。

---

<p align="center">
  <a href="README.md">English</a>
</p>
