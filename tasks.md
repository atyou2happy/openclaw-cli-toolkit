# Tasks: OpenClaw CLI Toolkit

## Phase 1: 调研 (Research)
- [ ] T01: 调研文件搜索/处理类工具 (rg, fd, bat, eza, silver-searcher)
- [ ] T02: 调研文本/数据处理类工具 (jq, yq, miller, csvkit, fx)
- [ ] T03: 调研系统信息/监控类工具 (btop, dust, duf, procs, bottom)
- [ ] T04: 调研网络工具类 (httpie, curlie, dog, nali)
- [ ] T05: 调研Git增强类 (delta, lazygit, tig, gh)
- [ ] T06: 调研终端/交互类 (fzf, zoxide, tmux, starship)
- [ ] T07: 调研开发辅助类 (shellcheck, shfmt, hadolint, actionlint)
- [ ] T08: 调研安全/加密类 (age, sops, pass, gpg)
- [ ] T09: 调研压缩归档类 (zstd, ouch, 7z)
- [ ] T10: 调研文档处理类 (pandoc, glow, poppler-utils, chafa)
- [ ] T11: 调研磁盘/文件系统类 (ncdu, dust, duf, dua)
- [ ] T12: 调研下载/传输类 (aria2, rclone)

## Phase 2: 核心开发 (Core)
- [ ] T13: 实现 detector.sh（系统检测）
- [ ] T14: 实现 installer.sh（安装逻辑，支持 apt/brew/cargo/pip）
- [ ] T15: 实现 configurator.sh（工具配置）
- [ ] T16: 实现 generator.py（生成 openclaw-tools.yaml）
- [ ] T17: 编写所有工具定义 YAML (tools/*.yaml)

## Phase 3: 集成 (Integration)
- [ ] T18: 编写 install.sh 主入口（串联所有步骤）
- [ ] T19: 编写 uninstall.sh
- [ ] T20: 编写 config.yaml（默认配置）

## Phase 4: 测试与文档 (Test & Docs)
- [ ] T21: 编写安装测试 (tests/test_install.sh)
- [ ] T22: 编写工具可用性测试 (tests/test_tools.sh)
- [ ] T23: 编写调研报告 (docs/research.md)
- [ ] T24: 编写双语 README

## 依赖关系
- T01-T12 可并行（调研互不依赖）
- T13-T17 依赖调研完成（需要确认工具列表和安装方式）
- T18 依赖 T13-T16
- T21-T22 依赖 T18
- T23 依赖 T01-T12
- T24 最后完成
