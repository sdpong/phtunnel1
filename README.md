# PHTunnel for OpenWrt 25.12.x (APK Format)

> 本项目针对 OpenWrt 25.12.x 进行了优化，使用 APK 包格式，支持多架构编译和 GitHub Actions 自动构建

[![Build Status](https://github.com/sdpong/phtunnel1/actions/workflows/build.yml/badge.svg)](https://github.com/sdpong/phtunnel1/actions/workflows/build.yml)
[![License](https://img.shields.io/badge/license-GPL--2.0-blue.svg)](LICENSE)

## 重要说明

OpenWrt 25.12.x 及以上版本已切换到 **APK 包格式**（与 Alpine Linux 相同的包管理格式）

- ✅ **OpenWrt 25.12.x 及以上版本**: 使用 **APK** 格式
- ❌ **OpenWrt 25.11.x 及以下版本**: 使用 **IPK** 格式（不兼容）

## 主要特性

- ✅ **多架构支持**: 7 种 CPU 架构
- ✅ **APK 包格式**: 完整支持 OpenWrt 25.12.x
- ✅ **GitHub Actions**: 自动化 CI/CD 构建
- ✅ **矩阵构建**: 并行构建所有架构
- ✅ **自动发布**: 推送 tag 自动创建 Release
- ✅ **缓存优化**: SDK 缓存加速构建
- ✅ **版本管理**: 简化的版本控制工具
- ✅ **包验证**: 自动验证包完整性

## 支持的架构

| 架构 | 适用设备 | 状态 |
|------|---------|------|
| x86_64 | Intel/AMD 64-bit（PC、服务器、虚拟机） | ✅ |
| aarch64_cortex-a53 | ARM 64-bit, Cortex-A53（树莓派 4、Rockchip） | ✅ |
| aarch64_generic | ARM 64-bit, 通用（其他 ARM64 设备） | ✅ |
| arm_cortex-a7 | ARM 32-bit, Cortex-A7（树莓派 2/3、Orange Pi） | ✅ |
| arm_cortex-a9 | ARM 32-bit, Cortex-A9（老款路由器） | ✅ |
| mips_24kc | MIPS 32-bit, 24KC（MT7620/MT7628 路由器） | ✅ |
| mipsel_24kc | MIPSel 32-bit, 24KC（MT7620/MT7621 路由器） | ✅ |

## 快速开始

### 自动构建（推荐）

使用 GitHub Actions 自动构建：

1. **推送代码** - 自动触发所有架构构建
   ```bash
   git add .
   git commit -m "Update packages"
   git push origin main
   ```

2. **创建 Release** - 推送 tag 自动创建发布
   ```bash
   ./scripts/version.sh bump patch
   ./scripts/version.sh tag
   git push origin main --tags
   ```

3. **下载包** - 从 GitHub Release 下载对应架构的 APK 包

### 手动触发构建

访问 GitHub Actions 页面，手动触发工作流：
- 选择架构（可单选或全部）
- 可选择是否自动创建 Release

## 安装方法

### 1. 检测架构

```bash
# 在 OpenWrt 路由器上运行
./scripts/detect-arch.sh
```

### 2. 下载包

从 [GitHub Releases](https://github.com/sdpong/phtunnel1/releases) 下载对应架构的包：
- `phtunnel_1.0.0-3_<架构>.apk`
- `luci-app-phtunnel_1.0.0-3_all.apk`

### 3. 上传并安装

```bash
# 上传到路由器
scp phtunnel_*.apk luci-app-phtunnel_*.apk root@<路由器IP>:/tmp/

# SSH 连接到路由器
ssh root@<路由器IP>

# 安装包
cd /tmp
apk add phtunnel_*.apk
apk add luci-app-phtunnel_*.apk

# 启用并启动服务
/etc/init.d/phtunnel enable
/etc/init.d/phtunnel start
```

### 4. 配置

1. 访问 LuCI: `http://<路由器IP>/cgi-bin/luci`
2. 进入 服务 → PHTunnel
3. 启用服务
4. 配置参数

## 开发工具

### 版本管理

```bash
# 查看当前版本
./scripts/version.sh get

# 设置版本
./scripts/version.sh set 1.1.0-1

# 提升版本
./scripts/version.sh bump patch  # 1.0.0-3 -> 1.0.1-4
./scripts/version.sh bump minor  # 1.0.0-3 -> 1.1.0-1
./scripts/version.sh bump major  # 1.0.0-3 -> 2.0.0-1

# 创建 git tag
./scripts/version.sh tag
```

### 本地构建

```bash
# 构建所有架构
./scripts/build-all.sh

# 构建特定架构
./scripts/build-all.sh -a x86_64

# 指定版本
./scripts/build-all.sh -v 1.1.0-1

# 使用现有 SDK
./scripts/build-all.sh -s ./openwrt-sdk-x86_64
```

### 包验证

```bash
# 验证构建的包
./scripts/verify-packages.sh
```

### 构建摘要

```bash
# 生成构建摘要
./scripts/generate-summary.sh
```

## GitHub Actions 工作流

### 工作流特性

1. **矩阵构建**: 并行构建所有 7 种架构
2. **自动触发**:
   - Push 到 main/master 分支
   - Pull Request
   - 推送 tag（自动创建 Release）
   - 手动触发

3. **缓存优化**:
   - SDK 缓存，加速后续构建
   - 依赖缓存

4. **自动发布**:
   - Tag 触发自动创建 GitHub Release
   - 手动触发可选择是否创建 Release

5. **构建报告**:
   - 每个架构的构建摘要
   - 包验证信息
   - 失败日志

### 使用方法

**自动触发**:
```bash
# 推送代码自动构建
git push origin main

# 推送 tag 自动发布
git tag v1.1.0-1
git push origin v1.1.0-1
```

**手动触发**:
1. 访问 Actions 页面
2. 选择 "Build PHTunnel for OpenWrt 25.12.x"
3. 点击 "Run workflow"
4. 选择架构和是否创建 Release

## 项目结构

```
phtunnel1/
├── .github/
│   └── workflows/
│       └── build.yml              # GitHub Actions 工作流
├── phtunnel/                     # 核心包
│   ├── Makefile                  # Makefile
│   └── files/
│       ├── etc/
│       │   ├── config/phtunnel   # UCI 配置
│       │   ├── init.d/phtunnel   # Init 脚本
│       │   └── hotplug.d/iface/
│       │       └── 30-oray-phtunnel
├── luci-app-phtunnel/           # LuCI 界面
│   ├── Makefile
│   ├── luasrc/
│   └── root/
│       └── usr/share/rpcd/acl.d/
│           └── luci-app-phtunnel.json
├── scripts/
│   ├── build-all.sh             # 本地构建脚本
│   ├── verify-packages.sh        # 包验证脚本
│   ├── generate-summary.sh      # 构建摘要生成
│   ├── version.sh               # 版本管理
│   ├── detect-arch.sh           # 架构检测
│   └── apk-packager.sh          # APK 打包
└── README.md
```

## 配置说明

### UCI 配置

```bash
# 启用服务
uci set phtunnel.base.enabled=1
uci commit phtunnel
/etc/init.d/phtunnel restart

# 查看配置
uci show phtunnel

# 查看日志
cat /var/log/oraybox/phtunnel.log
```

### 服务管理

```bash
# 启动服务
/etc/init.d/phtunnel start

# 停止服务
/etc/init.d/phtunnel stop

# 重启服务
/etc/init.d/phtunnel restart

# 查看状态
/etc/init.d/phtunnel status

# 启用开机自启
/etc/init.d/phtunnel enable

# 禁用开机自启
/etc/init.d/phtunnel disable
```

## 常见问题

### Q: 提示"不兼容的包格式"?

A: 您的 OpenWrt 版本可能是 25.11.x 或更低，这些版本只支持 IPK 格式。请升级到 OpenWrt 25.12.x 或更高版本。

### Q: 如何检查 OpenWrt 版本?

```bash
cat /etc/openwrt_release
# 或
ubus call system board
```

### Q: 提示依赖缺失?

A: 请确保安装了所有依赖包:

```bash
apk update
apk add luci-lib-jsonc cgi-io curl
```

### Q: LuCI 界面显示空白?

A: 清除缓存并重启相关服务:

```bash
rm -rf /tmp/luci-*
/etc/init.d/rpcd restart
/etc/init.d/uhttpd restart
```

### Q: 服务无法启动?

A: 检查日志和配置:

```bash
cat /var/log/oraybox/phtunnel.log
/etc/init.d/phtunnel status
```

### Q: 构建失败?

A: 检查 GitHub Actions 日志，常见原因：
- SDK 下载失败（网络问题）
- 依赖包未安装
- Makefile 语法错误

## 卸载

```bash
/etc/init.d/phtunnel stop
/etc/init.d/phtunnel disable
apk del luci-app-phtunnel phtunnel
```

## 更新日志

### v1.0.0-3 (2026-04-06)

- ✅ 适配 OpenWrt 25.12.x
- ✅ 切换到 APK 包格式（放弃 IPK）
- ✅ 支持多架构编译（7 种架构）
- ✅ GitHub Actions 矩阵构建
- ✅ 自动发布功能
- ✅ SDK 缓存优化
- ✅ 版本管理工具
- ✅ 包验证脚本
- ✅ 构建摘要生成
- ✅ 架构检测工具
- ✅ 本地构建脚本

### v1.0.0-1 (2026-04-05)

- ⚠️ 此版本使用 IPK 格式，不兼容 OpenWrt 25.12.x
- ⚠️ OpenWrt 25.11.x 及以下版本请使用此版本

## 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 许可证

- **phtunnel**: Proprietary (Oray)
- **luci-app-phtunnel**: GPL-2.0-only

## 支持

- **官方网站**: https://hsk.oray.com/
- **GitHub**: https://github.com/sdpong/phtunnel1
- **问题反馈**: [GitHub Issues](https://github.com/sdpong/phtunnel1/issues)

## 致谢

本项目参考了以下优秀项目：

- [OpenAppFilter](https://github.com/destan19/OpenAppFilter) - OpenWrt 应用过滤器，参考了其包结构和构建方式
- [oooopera/phtunnel1](https://github.com/oooopera/phtunnel1) - 原始 PHTunnel 项目

---

**Made with ❤️ for OpenWrt Community**
