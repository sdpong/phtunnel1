# 更新日志

本文档记录 PHTunnel 项目的所有重要变更。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [Unreleased]

## [1.0.0-4] - 2026-04-06

### 修复
- 修复 SDK 下载 URL（使用 OpenWrt 25.12.1 正确路径）
- 修复 GCC 版本（从 13 更新至 14.3.0）
- 修复包格式声明（OpenWrt 25.12.x 使用 IPK，非 APK）

### 变更
- **重大变更**: 从通用 CPU 架构改为路由器平台架构
  - x86_64 → x86-64 (软路由)
  - aarch64_cortex-a53 → qualcommax-ipq807x
  - mipsel_24kc → ramips-mt7621
  - mips_24kc → ramips-mt7620
  - 新增: ath79-generic
  - 新增: bcm27xx-bcm2712 (树莓派 5)
  - 新增: mediatek-filogic

### 新增
- 添加 qualcommax-ipq807x 架构支持（小米 AX3600/AX9000、红米 AX6/AX7 等）
- 添加 ramips-mt7621 架构支持（斐讯 K3、小米路由器 4A、中兴等）
- 添加 ramips-mt7620 架构支持（小米路由器 4C 等）
- 添加 ath79-generic 架构支持（TP-Link WR842N、NanoStation 等）
- 添加 bcm27xx-bcm2712 架构支持（树莓派 5）
- 添加 mediatek-filogic 架构支持（红米 AX6000、TP-Link XDR6088 等）

### 文档
- 更新 README 以反映真实的路由器架构
- 添加设备示例和芯片型号
- 更新安装说明

## [1.0.0-3] - 2026-04-06

### 已知问题
- ⚠️ 使用了错误的架构定义（通用 CPU 而非路由器平台）
- ⚠️ OpenWrt 25.12.x 使用 IPK 格式，但工作流声明为 APK
- ⚠️ SDK 下载 URL 可能不正确

## 版本说明

### 版本格式
版本号格式：`MAJOR.MINOR.PATCH-RELEASE`

- **MAJOR**: 主版本号（重大变更）
- **MINOR**: 次版本号（新功能）
- **PATCH**: 修订号（Bug 修复）
- **RELEASE**: 发布号（构建次数）

### 示例
- `1.0.0-4` - 1.0.0 版本的第 4 次构建
- `1.1.0-1` - 1.1.0 版本的第 1 次构建

## 变更类型

- **新增**: 新功能
- **变更**: 现有功能的变更
- **修复**: Bug 修复
- **文档**: 文档更新

---

[Unreleased]: https://github.com/sdpong/phtunnel1/compare/v1.0.0-4...HEAD
[1.0.0-4]: https://github.com/sdpong/phtunnel1/releases/tag/v1.0.0-4
[1.0.0-3]: https://github.com/sdpong/phtunnel1/releases/tag/v1.0.0-3
