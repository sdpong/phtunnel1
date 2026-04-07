# PHTunnel for OpenWrt 25.12.x

> 本项目针对 OpenWrt 25.12.x 进行了优化，使用 IPK 包格式，支持多路由器架构编译

[![Build Status](https://github.com/sdpong/phtunnel1/actions/workflows/build.yml/badge.svg)](https://github.com/sdpong/phtunnel1/actions/workflows/build.yml)
[![License](https://img.shields.io/badge/license-GPL--2.0-blue.svg)](LICENSE)

## 重要说明

OpenWrt 25.12.x 及以上版本使用 **IPK 包格式**（传统 OpenWrt 包格式）。

- ✅ **OpenWrt 25.12.x 及以上版本**: 使用 **IPK** 格式
- ❌ **OpenWrt 23.05.x 及以下版本**: 可能不兼容

## 主要特性

- ✅ **多架构支持**: 7 种主流路由器架构
- ✅ **IPK 包格式**: OpenWrt 25.12.x 标准包格式
- ✅ **GitHub Actions**: 自动化 CI/CD 构建
- ✅ **矩阵构建**: 并行构建所有架构
- ✅ **自动发布**: 推送 tag 自动创建 Release
- ✅ **版本管理**: 简化的版本控制工具
- ✅ **包验证**: 自动验证包完整性

## 支持的路由器架构

| 架构 | 芯片/平台 | 设备示例 | 状态 |
|------|-----------|---------|------|
| qualcommax-ipq807x | Qualcomm IPQ807x | 小米 AX3600/AX9000、红米 AX6/AX7、华硕 RT-AX89X、TP-Link Deco X80-5G | ✅ **必须支持** |
| ramips-mt7621 | MediaTek MT7621 | 斐讯 K3、小米路由器 4A、中兴、部分 TP-Link | ✅ |
| ramips-mt7620 | MediaTek MT7620/MT7628 | 小米路由器 4C、部分 TP-Link、水星 MW300R | ✅ |
| ath79-generic | Atheros AR71xx/AR9xxx | TP-Link WR842N、NanoStation、UBNT | ✅ |
| bcm27xx-bcm2712 | Broadcom BCM2712 | 树莓派 5 | ✅ |
| mediatek-filogic | MediaTek Filogic (MT7986) | 红米 AX6000、TP-Link XDR6088、小米 AX6000 | ✅ |
| x86-64 | x86_64 | 通用 x86 路由器、软路由 | ✅ |

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

3. **下载包** - 从 GitHub Release 下载对应架构的 IPK 包

### 手动触发构建

访问 GitHub Actions 页面，手动触发工作流：
- 选择架构（可单选或全部）
- 可选择是否自动创建 Release

## 安装方法

### 1. 检测架构

在 OpenWrt 路由器上运行：

```bash
opkg print-architecture
# 或
cat /etc/openwrt_release | grep DISTRIB_ARCH
```

### 2. 下载包

从 [GitHub Releases](https://github.com/sdpong/phtunnel1/releases) 下载对应架构的包：
- `phtunnel_<version>_<架构>.ipk`
- `luci-app-phtunnel_<version>_all.ipk`

### 3. 上传并安装

```bash
# 上传到路由器
scp phtunnel_*.ipk luci-app-phtunnel_*.ipk root@<路由器IP>:/tmp/

# SSH 连接到路由器
ssh root@<路由器IP>

# 更新包列表
opkg update

# 安装包
cd /tmp
opkg install phtunnel_*.ipk luci-app-phtunnel_*.ipk

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
./scripts/version.sh bump patch  # 1.0.0-4 -> 1.0.1-5
./scripts/version.sh bump minor  # 1.0.0-4 -> 1.1.0-1
./scripts/version.sh bump major  # 1.0.0-4 -> 2.0.0-1

# 创建 git tag
./scripts/version.sh tag
```

### 本地构建

```bash
# 构建所有架构
./scripts/build-all.sh

# 构建特定架构
./scripts/build-all.sh -a qualcommax-ipq807x

# 指定版本
./scripts/build-all.sh -v 1.1.0-1

# 使用现有 SDK
./scripts/build-all.sh -s ./openwrt-sdk-x86-64
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
│           └── luci-app-phtunnel.json  # RPC 权限
├── scripts/
│   ├── build-all.sh             # 本地构建脚本
│   ├── verify-packages.sh        # 包验证脚本
│   ├── generate-summary.sh      # 构建摘要生成
│   ├── version.sh               # 版本管理
│   ├── detect-arch.sh           # 架构检测
│   └── apk-packager.sh          # 打包工具
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

### Q: 如何确认路由器架构？

A: 在路由器上运行：
```bash
cat /etc/openwrt_release | grep DISTRIB_ARCH
```

### Q: 提示依赖缺失？

A: 请确保安装了所有依赖包：
```bash
opkg update
opkg install luci-lib-jsonc cgi-io curl
```

### Q: LuCI 界面显示空白？

A: 清除缓存并重启相关服务：
```bash
rm -rf /tmp/luci-*
/etc/init.d/rpcd restart
/etc/init.d/uhttpd restart
```

### Q: 服务无法启动？

A: 检查日志和配置：
```bash
cat /var/log/oraybox/phtunnel.log
/etc/init.d/phtunnel status
```

### Q: 我的路由器不在支持列表中？

A: 您可以：
1. 查看 [OpenWrt 官方支持列表](https://downloads.openwrt.org/releases/25.12.1/targets/)
2. 创建 Issue 提供您的路由器型号和架构信息
3. 手动构建：下载对应架构的 SDK 并运行 `./scripts/build-all.sh`

## 卸载

```bash
/etc/init.d/phtunnel stop
/etc/init.d/phtunnel disable
opkg remove luci-app-phtunnel phtunnel
```

## 更新日志

### v1.0.0-4 (2026-04-06)

- ✅ 修复 SDK 下载 URL（使用 OpenWrt 25.12.1）
- ✅ 更新 GCC 版本至 14.3.0
- ✅ 添加 qualcommax-ipq807x 架构支持（WiFi 6/7 路由器）
- ✅ 添加 ramips-mt7621 架构支持（斐讯 K3 等）
- ✅ 添加 ramips-mt7620 架构支持（小米路由器 4C 等）
- ✅ 添加 mediatek-filogic 架构支持（红米 AX6000 等）
- ✅ 修改包格式为 IPK（OpenWrt 标准格式）
- ✅ 优化架构列表，专注于主流路由器芯片

### v1.0.0-3 (2026-04-06)

- ⚠️ 此版本使用了错误的架构定义
- ⚠️ OpenWrt 25.12.x 使用 IPK 而非 APK

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
