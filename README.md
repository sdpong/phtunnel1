# PHTunnel for OpenWrt 25.12.x (APK Format)

## 重要说明

**OpenWrt 25.12.x 已切换到 APK 包格式**（与 Alpine Linux 相同的包管理格式）。

- ✅ **OpenWrt 25.12.x 及以上版本**: 使用 **APK** 格式
- ❌ **OpenWrt 25.11.x 及以下版本**: 使用 **IPK** 格式（**不兼容**）

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
   opkg install phtunnel_1.0.0-2_*.apk
   opkg install luci-app-phtunnel_1.0.0-2_all.apk
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

## 技术细节

### APK vs IPK 格式

| 特性 | APK (OpenWrt 25.12.x+) | IPK (OpenWrt 25.11.x-) |
|------|---------------------------|------------------------|
| 压缩格式 | tar.gz | tar.gz |
| 元数据 | .PKGINFO 文件 | control 文件 |
| 包管理器 | opkg (APK 版) | opkg (IPK 版) |
| 签名 | 支持 | 支持 |
| 安装脚本 | .pre-install, .post-install | preinst, postinst |
| 配置文件 | .apk-new 后缀 | conffiles |

### APK 包结构

```
phtunnel_1.0.0-2_x86_64.apk
├── .PKGINFO           # 包元数据
├── .pre-install       # 安装前脚本
├── .post-install      # 安装后脚本
├── usr/
│   └── sbin/
│       └── phtunnel
└── var/
    └── apk/
        └── DB_*
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
opkg update
opkg install luci-lib-jsonc cgi-io curl
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
opkg remove luci-app-phtunnel phtunnel
```

## 许可证

- **phtunnel**: Proprietary (Oray)
- **luci-app-phtunnel**: GPL-2.0-only

## 支持

- **官方网站**: https://hsk.oray.com/
- **GitHub**: https://github.com/oooopera/phtunnel1
- **问题反馈**: 请在 GitHub Issues 中提交

## 更新日志

### v1.0.0-2 (2026-04-05)

- ✅ 适配 OpenWrt 25.12.x
- ✅ 切换到 APK 包格式（放弃 IPK）
- ✅ 使用现代 LuCI controller API
- ✅ 增强 procd 服务管理
- ✅ 完整 UCI 权限配置
- ✅ 使用 luci-lib-jsonc
- ✅ 支持 7 种 CPU 架构
- ✅ 改进日志和错误处理
- ✅ 优化 APK 构建流程

### v1.0.0-1 (2026-04-05)

- ⚠️ 此版本使用 IPK 格式，不兼容 OpenWrt 25.12.x
- ⚠️ OpenWrt 25.11.x 及以下版本请使用此版本
