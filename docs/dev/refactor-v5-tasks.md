# Tasks: OpenClaw CLI Toolkit v5.0 — Full Refactoring

## Overview

5大目标，12个任务，分5个 Phase 执行。

**原则**: 先测试后重构，每步可验证。

---

## Phase 1: 测试安全网 (先补测试再动代码)

### T01: 新增 Python 测试基础设施
- [ ] 创建 `tests/python/conftest.py` — fixtures (sample YAML, temp dirs, mock tools)
- [ ] 创建 `tests/python/test_generator.py` — 测试 get_version, load_tool_definitions, generate_openclaw_entry, generate_output
- [ ] 创建 `tests/python/test_parse_tools.py` — 测试 parse_tools 函数，config 过滤逻辑
- [ ] 创建 `tests/python/test_yaml_schema.py` — 验证 26 个 tools/*.yaml 的 schema 合法性
- [ ] **验证**: `python3 -m pytest tests/python/ -v` 全部通过

**预估**: ~250 行测试代码

### T02: 增强 Shell 测试 + 新增结构测试
- [ ] 创建 `tests/test_structure.sh` — 验证目录结构、文件权限、语法检查
- [ ] 更新 `tests/test_install.sh` — 增加对 methods/ 目录的检查 (重构后)
- [ ] **验证**: `bash tests/test_install.sh && bash tests/test_structure.sh`

**预估**: ~80 行测试代码

---

## Phase 2: 路径集中化

### T03: 创建 paths.sh
- [ ] 创建 `src/paths.sh` — PROJECT_DIR, VERSION, SRC_DIR, TOOLS_DIR, CONFIG_FILE, INSTALL_LOG
- [ ] 更新 `install.sh` — 移除本地路径计算，source paths.sh
- [ ] 更新 `common.sh` — 移除 COMMON_VERSION 计算
- [ ] 更新 `detector.sh` — 移除 DETECTOR_VERSION 计算
- [ ] 更新 `state.sh` — 移除 STATE_VERSION 计算
- [ ] 更新 `installer.sh` — 移除 INSTALLER_VERSION 和路径计算
- [ ] 更新 `uninstall.sh` — source paths.sh
- [ ] **验证**: `bash tests/test_install.sh` 通过

**预估**: 修改6个文件，净减 ~20 行重复代码

---

## Phase 3: installer.sh 拆分

### T04: 创建 methods/ 目录和基础模块
- [ ] 创建 `src/methods/apt.sh` — extract install_via_apt()
- [ ] 创建 `src/methods/brew.sh` — extract install_via_brew()
- [ ] 创建 `src/methods/cargo.sh` — extract install_via_cargo()
- [ ] 创建 `src/methods/pip.sh` — extract install_via_pip()
- [ ] 创建 `src/methods/go.sh` — extract install_via_go()
- [ ] **验证**: 每个 `source src/methods/apt.sh` 等不报错

### T05: 创建 methods/github.sh
- [ ] 创建 `src/methods/github.sh` — extract install_via_github_release() (~130行)
- [ ] **验证**: `bash -n src/methods/github.sh` 语法正确

### T06: 重写 installer.sh 为调度器
- [ ] 重写 `src/installer.sh` — source methods/*.sh + 保留调度函数
- [ ] 保留函数签名: try_install_method, install_single_tool, install_report, parse_all_tools, log_install
- [ ] 保留全局变量: INSTALLED_TOOLS, FAILED_TOOLS, SKIPPED_TOOLS
- [ ] **验证**: `bash install.sh --dry-run` 功能正常

**预估**: installer.sh 394行 → ~120行调度器 + 6个 methods 文件

---

## Phase 4: Python 代码质量

### T07: 修复 parse_tools.py
- [ ] 替换 `except Exception: pass` → 精确异常处理 + stderr 日志
- [ ] 替换裸 `open()` → `with open(...) as fh`
- [ ] 增加类型标注
- [ ] 增加 main() 的 argparse (可选，或保持 sys.argv)
- [ ] **验证**: `python3 -m pytest tests/python/test_parse_tools.py -v`

### T08: 增强 generator.py
- [ ] 增加 None 安全检查 (tool.get() 返回 None 的场景)
- [ ] 增加完整类型标注
- [ ] 确认 `with` 语句使用 (已OK)
- [ ] **验证**: `python3 -m pytest tests/python/test_generator.py -v`

---

## Phase 5: 开发工具链 + CI

### T09: 新增 Makefile
- [ ] 创建 `Makefile` — lint, test, test-python, test-shell, check, generate, clean
- [ ] **验证**: `make check` 执行成功

### T10: 新增 pyproject.toml (dev-only)
- [ ] 创建 `pyproject.toml` — ruff 配置 + pytest 配置
- [ ] **验证**: `ruff check src/` 通过

### T11: 增强 CI
- [ ] 更新 `.github/workflows/ci.yml` — 增加 python-test job
- [ ] 更新 shellcheck 范围 — 增加 src/methods/*.sh
- [ ] **验证**: YAML 语法正确

### T12: 文档更新 + 版本号
- [ ] 更新 `VERSION` — 4.0.0 → 5.0.0
- [ ] 更新 `README.md` — 项目结构树、开发指南
- [ ] 更新 `README_CN.md` — 同步
- [ ] 更新 `CHANGELOG.md` — v5.0.0 变更记录
- [ ] **验证**: README 结构树与实际目录一致

---

## Dependency Graph

```
T01 ─┐
T02 ─┤
     ├── T03 ── T04 ── T05 ── T06
     │                          │
T07 ─┤                          ├── T09 ── T11
T08 ─┘                          │
                                │
                          T10 ──┘
                          
T12 (final, depends on all)
```

## Execution Order

```
T01 → T02 → T03 → T04+T05(parallel) → T06 → T07+T08(parallel) → T09+T10(parallel) → T11 → T12
```
