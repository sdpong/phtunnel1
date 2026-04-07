# 更新日志

本文档记录 PHTunnel 项目的所有重要变更。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [Unreleased]

### 计划中
- 支持更多架构
- 添加自动更新功能
- 改进日志系统

## [1.0.0-3] - 2026-04-06

### 新增
- 适配 OpenWrt 25.12.x
- 切换到 APK 包格式（放弃 IPK）
- 支持多架构编译（7 种架构）：
  - x86_64
  - aarch64_cortex-a53
  - aarch64_generic
  - arm_cortex-a7
  - arm_cortex-a9
  - mips_24kc
  - mipsel_24kc
- GitHub Actions 矩阵构建
- 自动发布功能
- SDK 缓存优化
- 版本管理工具 (`scripts/version.sh`)
- 包验证脚本 (`scripts/verify-packages.sh`)
- 构建摘要生成 (`scripts/generate-summary.sh`)
- 架构检测工具 (`scripts/detect-arch.sh`)
- 本地构建脚本 (`scripts/build-all.sh`)
- 完整的 RPCD ACL 权限配置
- 完善的文档和贡献指南

### 改进
- 使用现代 LuCI controller API
- 增强 procd 服务管理
- 改进错误处理和日志
- 优化 APK 构建流程
- 添加构建缓存
- 改进 CI/CD 工作流

### 变更
- Makefile 遵循 OpenWrt 标准
- 包结构参照 OpenAppFilter 项目
- 架构名称映射更新

### 文档
- 完整的 README
- 贡献指南（CONTRIBUTING.md）
- 更新日志（CHANGELOG.md）
- 使用说明和故障排除

### 修复
- 修复 APK 打包脚本中的路径问题
- 修复架构检测逻辑

## [1.0.0-1] - 2026-04-05

### 新增
- 初始版本
- 支持 OpenWrt 23.05.x 和 24.10.x
- IPK 包格式
- 基础 LuCI 界面
- GitHub Actions 构建

### 已知问题
- 不兼容 OpenWrt 25.12.x（使用 APK 格式）
- 仅支持 5 种架构

## 版本说明

### 版本格式
版本号格式：`MAJOR.MINOR.PATCH-RELEASE`

- **MAJOR**: 主版本号（重大变更）
- **MINOR**: 次版本号（新功能）
- **PATCH**: 修订号（Bug 修复）
- **RELEASE**: 发布号（构建次数）

### 示例
- `1.0.0-3` - 1.0.0 版本的第 3 次构建
- `1.1.0-1` - 1.1.0 版本的第 1 次构建

## 变更类型

- **新增**: 新功能
- **变更**: 现有功能的变更
- **弃用**: 即将移除的功能
- **移除**: 已移除的功能
- **修复**: Bug 修复
- **安全**: 安全问题修复

---

[Unreleased]: https://github.com/sdpong/phtunnel1/compare/v1.0.0-3...HEAD
[1.0.0-3]: https://github.com/sdpong/phtunnel1/releases/tag/v1.0.0-3
[1.0.0-1]: https://github.com/sdpong/phtunnel1/releases/tag/v1.0.0-1
