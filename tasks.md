# Tasks: OpenClaw CLI Toolkit v2.0 — 全面升级

## Phase 1: 安全修复 (P0)
- [ ] T01: 修复命令注入漏洞 — state.sh 用纯bash替换python3 inline脚本
- [ ] T02: 修复 parse_yaml_tools 注入 — 改用环境变量传递文件路径
- [ ] T03: 修复 sudo apt-get 安全问题 — 添加 `--no-install-recommends`

## Phase 2: 架构重构 (P1)
- [ ] T04: 创建 src/common.sh — 提取共享函数（日志、颜色、工具函数）
- [ ] T05: 创建 src/state.sh — 纯bash状态管理（替代python3 JSON）
- [ ] T06: 重构 src/installer.sh — 添加 go install 方法，消除重复
- [ ] T07: 重构 install.sh — 精简为编排器，逻辑下沉到各模块
- [ ] T08: 重构 src/configurator.sh — 添加 zsh 支持
- [ ] T09: 实现批量工具解析 — 一次python3调用，TSV格式输出
- [ ] T10: 实现 config.yaml 过滤 — 真正读取并应用用户配置

## Phase 3: 代码质量 (P2)
- [ ] T11: 修复所有 shellcheck warnings
- [ ] T12: 移除未使用变量
- [ ] T13: 修复 generator.py — shutil移到模块级，添加类型注解
- [ ] T14: 替换 dog → doggo（network.yaml + config.yaml + uninstall.sh）
- [ ] T15: 统一代码风格 — shellcheck clean, shfmt格式化

## Phase 4: 功能增强 (P3)
- [ ] T16: 添加版本检查 — 安装后验证工具版本
- [ ] T17: 创建 .github/workflows/ci.yml — shellcheck + dry-run + generator
- [ ] T18: 创建 CHANGELOG.md
- [ ] T19: 增强测试 — 添加 test_unit.sh 单元测试
- [ ] T20: 更新 README.md / README_CN.md — 反映v2.0变更

## 依赖关系
```
T04 (common.sh) → T05 (state.sh) → T07 (install.sh重构)
T04 → T06 (installer.sh重构)
T04 → T08 (configurator.sh重构)
T06 → T09 (批量解析)
T09 → T10 (config过滤)
T01 → T07 (安全修复先于重构)
T11-T15 可并行（质量修复）
T16-T20 可并行（功能增强），但 T20 依赖 T01-T19 完成
```

## 执行顺序
1. T04 → T05 → T06 → T01/T02/T03 (安全+基础模块)
2. T09 → T10 → T07 → T08 (架构重构)
3. T11-T15 (并行质量修复)
4. T16-T19 (并行功能增强)
5. T20 (文档更新，最后)
