# Proposal: OpenClaw CLI Toolkit v2.0 — 全面升级

> 项目代号: `openclaw-cli-toolkit` | 模式: Full | 开源: MIT

## 目标

将 OpenClaw CLI Toolkit 从 v1.0 升级到 v2.0，修复所有已知安全漏洞、架构缺陷、代码质量问题，并增加关键功能。

## 问题清单

### P0 — 安全漏洞（必须修复）
| ID | 问题 | 影响 | 修复方案 |
|----|------|------|---------|
| SEC-1 | `state_record`/`parse_yaml_tools` 中shell变量拼接进Python代码 | 命令注入 | 改用环境变量或文件传递数据给Python |
| SEC-2 | `sudo apt-get install -y` 无包验证 | 恶意包风险 | 添加 `--allow-downgrades` 和 apt源验证 |

### P1 — 架构缺陷（核心重构）
| ID | 问题 | 修复方案 |
|----|------|---------|
| ARCH-1 | install.sh 与 installer.sh 逻辑重复 | install.sh 只做编排，installer.sh 做具体安装 |
| ARCH-2 | config.yaml 未被读取 | 用Python解析config.yaml过滤工具列表 |
| ARCH-3 | 并行安装不工作 | 重构为Python驱动（或用xargs + 脚本文件） |
| ARCH-4 | 每工具4次python3调用解析JSON | 一次解析所有工具，用bash数组存储 |
| ARCH-5 | 只支持bash配置 | 添加zsh支持（检测shell类型） |

### P2 — 代码质量（cleanup）
| ID | 问题 | 修复方案 |
|----|------|---------|
| QUAL-1 | 15+ shellcheck warnings | 全部修复 |
| QUAL-2 | 未使用变量 | 移除或正确使用 |
| QUAL-3 | generator.py shutil函数内导入 | 移到模块级 |
| QUAL-4 | dog 包已废弃 | 替换为 doggo |
| QUAL-5 | 重复的日志/颜色函数定义 | 提取到 common.sh |

### P3 — 功能增强
| ID | 功能 | 方案 |
|----|------|------|
| FEAT-1 | go install 安装方法 | 添加 go install 支持 |
| FEAT-2 | 版本检查 | 安装后验证工具版本 |
| FEAT-3 | CI/CD | 添加 GitHub Actions |
| FEAT-4 | CHANGELOG | 添加 CHANGELOG.md |
| FEAT-5 | 更完善的测试 | 添加 bats 测试框架 |

## 升级后目录结构

```
openclaw-cli-toolkit/
├── README.md
├── README_CN.md
├── CHANGELOG.md
├── LICENSE
├── install.sh                # 主入口（精简版，只做编排）
├── uninstall.sh              # 卸载脚本
├── config.yaml               # 工具选择配置
├── openclaw-tools.yaml       # 生成的工具描述
├── src/
│   ├── common.sh             # 共享函数（日志、颜色、工具函数）
│   ├── detector.sh           # 系统检测
│   ├── installer.sh          # 安装逻辑（支持5种包管理器）
│   ├── configurator.sh       # 工具配置（bash+zsh）
│   ├── state.sh              # 状态管理（纯bash，无Python依赖）
│   └── generator.py          # 生成 openclaw-tools.yaml
├── tools/                    # 工具定义YAML（13类）
├── .github/
│   └── workflows/
│       └── ci.yml            # CI: shellcheck + dry-run + generator
├── docs/
│   └── research.md
└── tests/
    ├── test_install.sh
    ├── test_tools.sh
    └── test_unit.sh          # 单元测试
```

## 关键设计决策

1. **状态管理改为纯bash** — 不再依赖python3写JSON文件，改用bash关联数组+简单文本文件
2. **工具解析批量处理** — 一次python3调用解析所有YAML，输出为TSV格式供bash读取
3. **common.sh抽取公共函数** — 日志、颜色、工具函数统一定义
4. **config.yaml真正生效** — 用python3过滤工具列表
5. **zsh支持** — 检测当前shell，为zsh生成对应配置
