# Proposal: OpenClaw CLI Toolkit v5.0 — Full Refactoring

> Project: `openclaw-cli-toolkit` | Mode: Full | License: MIT (confirmed)

## 1. Summary & Vision

对 openclaw-cli-toolkit v4.0.0 进行全面重构，5大目标：

1. **installer.sh 拆分** — 394行巨型文件拆为模块化安装方法
2. **Python 代码质量** — 修复异常吞没、资源泄漏，增加类型标注
3. **测试补全** — 新增 pytest 测试，增强 Shell 测试，目标覆盖率 >60%
4. **路径/配置集中化** — 提取 paths.sh 统一管理
5. **整体架构升级** — Makefile、lint 配置、CI 增强

**设计哲学**: 内部重构，不改变外部 API。用户使用 `./install.sh` 的体验和参数完全不变。

## 2. Problem Statement

| # | 问题 | 影响 | 解决方案 |
|---|------|------|---------|
| P1 | installer.sh 394行，5种安装方法+github_release+调度+解析+报告混在一起 | 难维护、难测试 | 拆分为 src/methods/ 目录下6个独立模块 |
| P2 | parse_tools.py `except Exception: pass` 吞异常 | 静默丢失工具解析错误 | 改为精确异常+日志 |
| P3 | parse_tools.py `open()` 不用 `with` | 资源泄漏风险 | 改用 `with` 语句 |
| P4 | 测试覆盖率 ~15% | 重构无安全网 | 先补测试再重构 |
| P5 | VERSION 路径在4个文件中重复计算 | 维护负担 | 提取 paths.sh |
| P6 | SCRIPT_DIR/TOOLS_DIR 各文件独立计算 | 不一致风险 | paths.sh 集中定义 |
| P7 | 无 Makefile，无 Python lint 配置 | 开发效率低 | 新增开发工具链 |
| P8 | CI 不跑 pytest | Python 改动无验证 | CI 增加 pytest job |

## 3. Scope

### 做什么

- 拆分 installer.sh 为模块化架构
- 修复 Python 代码质量问题
- 新增 pytest 测试套件
- 增强 Shell 测试
- 提取路径集中化管理
- 新增 Makefile + ruff + CI 增强

### 不做什么

- ❌ 不改 tools/*.yaml 的 schema（26个文件不动）
- ❌ 不改 config.yaml 用户格式
- ❌ 不加新功能/新工具
- ❌ 不换语言（保持 Bash+Python 混合）
- ❌ 不引入 Python 打包（setup.py/pyproject.toml）
- ❌ 不动 uninstall.sh 核心逻辑（仅同步路径改动）

## 4. Target Architecture (Post-Refactor)

```
openclaw-cli-toolkit/
  install.sh              ← 主入口 (不变，仅 import 调整)
  uninstall.sh            ← 卸载 (仅路径同步)
  config.yaml             ← 用户配置 (不动)
  VERSION                 ← 单一版本号 (不动)
  Makefile                ← NEW: 开发命令入口
  pyproject.toml          ← NEW: ruff/pytest 配置 (不用于打包)
  src/
    common.sh             ← 颜色/日志/进度 (不变)
    paths.sh              ← NEW: 集中路径管理
    detector.sh           ← OS/Arch/Shell 检测 (路径改用 paths.sh)
    state.sh              ← 断点续装 (路径改用 paths.sh)
    configurator.sh       ← 工具配置 (路径改用 paths.sh)
    installer.sh          ← 拆为调度器 (~50行)
    methods/              ← NEW: 安装方法目录
      apt.sh              ← apt 安装 (~25行)
      brew.sh             ← brew 安装 (~25行)
      cargo.sh            ← cargo 安装 (~25行)
      pip.sh              ← pip 安装 (~30行)
      go.sh               ← go install (~40行)
      github.sh           ← GitHub release (~130行)
    generator.py          ← 增强类型+错误处理
    parse_tools.py        ← 修复异常吞没+资源泄漏
  tests/
    test_install.sh       ← 增强 (不变)
    test_tools.sh         ← 增强 (不变)
    test_structure.sh     ← NEW: 结构验证测试
    python/               ← NEW: Python 测试
      test_generator.py
      test_parse_tools.py
      test_yaml_schema.py
      conftest.py
  .github/workflows/ci.yml  ← 增强: +pytest job
```
