# PHTunnel for OpenWrt 25.12.x (APK Format)

## 重要说明 - 请仔细阅读

**OpenWrt 25.12.x 已切换到 APK 包格式**（与 Alpine Linux 相同的包管理格式）。

- ✅ **OpenWrt 25.12.x 及以上版本**: 使用 **APK** 格式
- ❌ **OpenWrt 25.11.x 及以下版本**: 使用 **IPK** 格式（**不兼容**）

### ⚠️ 重要修复说明

**v1.0.0-2 版本修复了 APK 包格式问题**

之前的版本（v1.0.0-1）虽然声称支持 OpenWrt 25.12.x，但实际使用的是 OpenWrt 23.05.5 SDK 编译，导致生成的 APK 包在 OpenWrt 25.12.x 上安装时出现 "unexpected end of file" 错误。

**v1.0.0-2 版本已修复此问题**：
- ✅ 使用 OpenWrt 25.12.2 SDK 编译
- ✅ 正确配置 APK 包格式（CONFIG_USE_APK=y）
- ✅ 修复包结构兼容性问题
- ✅ 完全符合 OpenWrt 25.12.x APK 标准

## 简介

PHTunnel 是花生壳内网穿透的核心组件，可以轻松实现高性能反向代理应用，支持 TCP、HTTP、HTTPS 协议，端到端 TLS 加密通信、黑白名单防黑验证等。通过 PHTunnel，外网设备可以轻松穿透各种复杂的路由和防火墙访问内网设备。

## 包含组件

- **phtunnel**: 核心守护进程（架构特定）
- **luci-app-phtunnel**: LuCI Web 管理界面（通用）

## 兼容性

### ✅ OpenWrt 25.12.x (APK 格式)

| 版本 | 状态 | 包格式 | 说明 |
|------|------|---------|------|
| OpenWrt 25.12.x | ✅ 完全支持 | APK | 当前版本，完全支持 |
| OpenWrt 25.13.x+ | ✅ 预计支持 | APK | 未来版本 |

### ❌ OpenWrt 25.11.x 及以下 (IPK 格式，不兼容)

| 版本 | 状态 | 包格式 | 说明 |
|------|------|---------|------|
| OpenWrt 25.11.x | ❌ 不兼容 | IPK | 包格式不同 |
| OpenWrt 25.10.x | ❌ 不兼容 | IPK | 包格式不同 |
| OpenWrt 24.x | ❌ 不兼容 | IPK | 包格式不同 |
| OpenWrt 23.x | ❌ 不兼容 | IPK | 包格式不同 |
| OpenWrt 22.x | ❌ 不兼容 | IPK | 包格式不同 |
| OpenWrt 21.02 | ❌ 不兼容 | IPK | 包格式不同 |

### 支持的 CPU 架构

| 架构 | 适用设备 |
|------|---------|
| x86_64 | Intel/AMD 64-bit（PC、服务器、虚拟机） |
| aarch64_cortex-a53 | ARM 64-bit, Cortex-A53（树莓派 4、Rockchip） |
| aarch64_generic | ARM 64-bit, 通用（其他 ARM64 设备） |
| arm_cortex-a7 | ARM 32-bit, Cortex-A7（树莓派 2/3、Orange Pi） |
| arm_cortex-a9 | ARM 32-bit, Cortex-A9（老款路由器、嵌入式设备） |
| mips_24kc | MIPS 32-bit, 24KC（MT7620/MT7628 路由器） |
| mipsel_24kc | MIPSel 32-bit, 24KC（MT7620/MT7621 路由器） |

## 安装方法

### 方法 1：使用 opkg 安装（推荐）

1. **查看设备架构**：
   ```bash
   opkg print-architecture
   ```

2. **下载对应架构的 APK 包**：
   - 从 GitHub Release 下载 `phtunnel_1.0.0-2_<架构>.apk`
   - 下载 `luci-app-phtunnel_1.0.0-2_all.apk`

3. **上传到路由器**：
   ```bash
   scp phtunnel_1.0.0-2_*.apk root@<路由器IP>:/tmp/
   scp luci-app-phtunnel_1.0.0-2_all.apk root@<路由器IP>:/tmp/
   ```

4. **安装包**：
   ```bash
   ssh root@<路由器IP>
   cd /tmp
   apk add phtunnel_1.0.0-2_*.apk
   apk add luci-app-phtunnel_1.0.0-2_all.apk
   ```

### 方法 2：使用 LuCI 界面上传

1. 访问 LuCI 界面：`http://<路由器IP>/cgi-bin/luci`
2. 进入 **系统 → 软件包**
3. 点击 **上传软件包**
4. 上传 APK 文件并安装

## 配置说明

### 启用服务

1. **在 LuCI 界面中**：
   ```
   服务 → PHTunnel → 设置
   勾选"启用"
   保存并应用
   ```

2. **或者使用命令行**：
   ```bash
   uci set phtunnel.base.enabled=1
   uci commit phtunnel
   /etc/init.d/phtunnel start
   /etc/init.d/phtunnel enable
   ```

### 查看状态

- **LuCI 界面**：服务 → PHTunnel → 状态
- **命令行**：
  ```bash
  /etc/init.d/phtunnel status
  cat /var/log/oraybox/phtunnel.log
  ```

### 重启服务

```bash
/etc/init.d/phtunnel restart
```

## 编译说明

### 本地编译

如果您需要自己编译 APK 包，请确保使用正确的 OpenWrt 25.12.x SDK。

#### 前提条件

1. **Linux 系统**（Ubuntu 20.04+ 推荐）
2. **OpenWrt 25.12.2 SDK**
3. **必要的依赖包**

#### 编译步骤

1. **下载 OpenWrt 25.12.2 SDK**：
   ```bash
   # 下载 SDK（示例：x86_64 架构）
   wget https://downloads.openwrt.org/releases/25.12.2/targets/x86/64/openwrt-sdk-25.12.2-x86-64_gcc-14.3.0_musl.Linux-x86_64.tar.zst
   tar -xf openwrt-sdk-25.12.2-*.tar.zst
   cd openwrt-sdk-25.12.2-*
   ```

2. **更新 feeds**：
   ```bash
   ./scripts/feeds update -a
   ./scripts/feeds install -a
   ```

3. **复制项目源码**：
   ```bash
   git clone https://github.com/sdpong/phtunnel1.git /tmp/phtunnel1
   cp -r /tmp/phtunnel1/luci-app-phtunnel package/
   cp -r /tmp/phtunnel1/phtunnel package/
   ```

4. **配置编译选项**：
   ```bash
   make defconfig

   # 重要：启用 APK 包格式
   echo "CONFIG_USE_APK=y" >> .config

   # 启用包编译
   echo "CONFIG_PACKAGE_phtunnel=y" >> .config
   echo "CONFIG_PACKAGE_luci-app-phtunnel=y" >> .config

   # 启用依赖
   echo "CONFIG_PACKAGE_luci-lib-jsonc=y" >> .config
   echo "CONFIG_PACKAGE_cgi-io=y" >> .config
   echo "CONFIG_PACKAGE_curl=y" >> .config

   make oldconfig
   ```

5. **编译包**：
   ```bash
   # 编译 phtunnel 包
   make package/phtunnel/compile V=s

   # 编译 luci-app-phtunnel 包
   make package/luci-app-phtunnel/compile V=s
   ```

6. **查找生成的 APK 包**：
   ```bash
   find bin/packages -name "*.apk"
   ```

#### 常见编译问题

**问题 1：找不到 `apk` 命令**
- **原因**：SDK 的 `apk` 工具可能未包含在旧版本中
- **解决**：确保使用 OpenWrt 25.12.2 或更高版本的 SDK

**问题 2：APK 包格式错误**
- **原因**：未启用 `CONFIG_USE_APK=y`
- **解决**：确保在 `.config` 中设置了 `CONFIG_USE_APK=y`

**问题 3：依赖包缺失**
- **原因**：feeds 未正确安装
- **解决**：运行 `./scripts/feeds update -a` 和 `./scripts/feeds install -a`

### 使用 GitHub Actions 自动编译

本项目提供了 GitHub Actions 工作流，可以自动编译所有架构的 APK 包。

1. **Fork 本项目**
2. **进入 GitHub Actions 页面**
3. **选择 "Build PHTunnel APK for OpenWrt 25.12.x" 工作流**
4. **点击 "Run workflow"**
5. **选择目标架构并运行**
6. **编译完成后，从 Artifacts 下载 APK 包**

## 技术细节

### APK vs IPK 格式

| 特性 | APK (OpenWrt 25.12.x+) | IPK (OpenWrt 25.11.x-) |
|------|---------------------------|------------------------|
| 压缩格式 | tar.gz | tar.gz |
| 元数据 | .PKGINFO 文件 | control 文件 |
| 包管理器 | apk | opkg |
| 签名 | 支持 | 支持 |
| 安装脚本 | .pre-install, .post-install | preinst, postinst |
| 配置文件 | .apk-new 后缀 | conffiles |

### APK 包结构

```
phtunnel_1.0.0-2_x86_64.apk
├── .PKGINFO           # 包元数据
├── .pre-install       # 安装前脚本
├── .post-install      # 安装后脚本
├── .pre-upgrade       # 升级前脚本
├── .post-upgrade      # 升级后脚本
├── .pre-deinstall     # 卸载前脚本
├── usr/
│   └── sbin/
│       └── phtunnel
└── lib/
    └── apk/
        └── packages/
            ├── phtunnel.list           # 文件列表
            └── phtunnel.conffiles       # 配置文件列表
```

### 文件结构

```
/usr/sbin/phtunnel                    # 核心程序
/usr/lib/lua/luci/controller/oray/   # LuCI 控制器
/usr/lib/lua/luci/model/cbi/oray/    # LuCI 模型
/usr/lib/lua/luci/view/oray/         # LuCI 视图
/usr/share/rpcd/acl.d/               # RPC 权限配置
/etc/init.d/phtunnel                 # Init 脚本
/etc/config/phtunnel                 # UCI 配置
/etc/hotplug.d/iface/30-oray-phtunnel # 热插拔脚本
```

## 常见问题

### Q: 提示"不兼容的包格式"？

A: 您的 OpenWrt 版本可能是 25.11.x 或更低，这些版本只支持 IPK 格式。请升级到 OpenWrt 25.12.x 或更高版本。

### Q: 如何检查 OpenWrt 版本？

A:
```bash
cat /etc/openwrt_release
# 或
ubus call system board
```

### Q: 提示依赖缺失？

A: 请确保安装了所有依赖包：
```bash
apk update
apk add luci-lib-jsonc cgi-io curl
```

### Q: LuCI 界面显示空白？

A: 清除浏览器缓存并重启相关服务：
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

### Q: 如何卸载？

A:
```bash
/etc/init.d/phtunnel stop
/etc/init.d/phtunnel disable
apk del luci-app-phtunnel phtunnel
```

### Q: 之前的 v1.0.0-1 版本安装失败？

A: v1.0.0-1 版本使用了错误的 SDK 编译，导致 "unexpected end of file" 错误。请使用 v1.0.0-2 版本，该版本已修复此问题。

## 许可证

- **phtunnel**: Proprietary (Oray)
- **luci-app-phtunnel**: GPL-2.0-only

## 支持

- **官方网站**: https://hsk.oray.com/
- **GitHub**: https://github.com/sdpong/phtunnel1
- **问题反馈**: 请在 GitHub Issues 中提交

## 更新日志

### v1.0.0-2 (2026-04-07)

- ✅ **修复 "unexpected end of file" 安装错误**
- ✅ **使用 OpenWrt 25.12.2 SDK 编译**
- ✅ **正确配置 APK 包格式 (CONFIG_USE_APK=y)**
- ✅ **修复 APK 包结构兼容性**
- ✅ **完全符合 OpenWrt 25.12.x APK 标准**
- ✅ **优化 APK 构建脚本**
- ✅ **更新 GitHub Actions 工作流**
- ✅ **提供详细的编译说明**

### v1.0.0-1 (2026-04-05)

- ⚠️ **此版本使用错误的 SDK 编译，不兼容 OpenWrt 25.12.x**
- ⚠️ **OpenWrt 25.11.x 及以下版本请使用其他版本**
- ❌ **存在 "unexpected end of file" 安装错误**
- ❌ **不推荐使用此版本**

## 参考项目

- **OpenAppFilter**: https://github.com/destan19/OpenAppFilter.git
  - 本项目参考了 OpenAppFilter 的编译流程和 APK 包构建方法
  - OpenAppFilter 项目在 OpenWrt 25.12.x 上编译和运行正常

## 开发说明

本项目使用标准的 OpenWrt 包构建系统，遵循 OpenWrt 25.12.x 的 APK 包格式规范。

### 包结构

```
phtunnel1/
├── phtunnel/                      # 核心二进制包
│   ├── Makefile                  # 包构建配置
│   └── files/                    # 文件和脚本
├── luci-app-phtunnel/            # LuCI Web 界面
│   ├── Makefile                  # 包构建配置
│   └── luasrc/                   # Lua 源码
└── scripts/                      # 构建脚本
    └── apk-packager.sh           # APK 打包脚本
```