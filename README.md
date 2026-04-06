# PHTunnel for OpenWrt 25.12.x and below

## 简介

PHTunnel 是花生壳内网穿透的核心组件，可以轻松实现高性能反向代理应用，支持 TCP、HTTP、HTTPS 协议，端到端 TLS 加密通信、黑白名单防黑验证等。

## 包含组件

- **phtunnel**: 核心守护进程（架构特定）
- **luci-app-phtunnel**: LuCI Web 管理界面（通用）

## 兼容性

### ✅ 支持的 OpenWrt 版本

| 版本 | 状态 | 说明 |
|------|------|------|
| OpenWrt 25.12.x | ✅ 推荐 | 完全支持，使用最新 API |
| OpenWrt 24.x | ✅ 支持 | 完全兼容 |
| OpenWrt 23.x | ✅ 支持 | 完全兼容 |
| OpenWrt 22.x | ✅ 支持 | 完全兼容 |
| OpenWrt 21.02 | ✅ 支持 | 完全兼容 |
| OpenWrt 19.07 | ⚠️ 部分 | 基本功能可用 |
| OpenWrt 18.06 | ⚠️ 部分 | 基本功能可用 |

### 支持的 CPU 架构

| 架构 | 适用设备 |
|------|---------|
| x86_64 | Intel/AMD 64-bit（PC、服务器、虚拟机） |
| aarch64_cortex-a53 | ARM 64-bit Cortex-A53（树莓派 4、Rockchip） |
| aarch64_generic | ARM 64-bit 通用（其他 ARM64 设备） |
| arm_cortex-a7 | ARM 32-bit Cortex-A7（树莓派 2/3、Orange Pi） |
| arm_cortex-a9 | ARM 32-bit Cortex-A9（老款路由器、嵌入式设备） |
| mips_24kc | MIPS 32-bit 24KC（MT7620/MT7628 路由器） |
| mipsel_24kc | MIPSel 32-bit 24KC（MT7620/MT7621 路由器） |

## 安装方法

### 方法 1：使用 opkg 安装（推荐）

1. 下载对应架构的 IPK 包：
   ```bash
   # 查看设备架构
   opkg print-architecture | grep arch
   ```

2. 安装包：
   ```bash
   opkg install phtunnel_1.0.0-1_<架构>.ipk
   opkg install luci-app-phtunnel_1.0.0-1_all.ipk
   ```

3. 访问 LuCI 界面：
   ```
   http://<路由器IP>/cgi-bin/luci
   服务 -> PHTunnel
   ```

### 方法 2：使用 SCP 上传

```bash
# 上传包到路由器
scp phtunnel_1.0.0-1_*.ipk root@<路由器IP>:/tmp/
scp luci-app-phtunnel_1.0.0-1_all.ipk root@<路由器IP>:/tmp/

# SSH 登录路由器
ssh root@<路由器IP>

# 安装
cd /tmp
opkg install phtunnel_1.0.0-1_*.ipk
opkg install luci-app-phtunnel_1.0.0-1_all.ipk
```

## 配置说明

### 启用服务

1. 在 LuCI 界面中：
   ```
   服务 -> PHTunnel -> 设置
   勾选"启用"
   保存并应用
   ```

2. 或者使用命令行：
   ```bash
   uci set phtunnel.base.enabled=1
   uci commit phtunnel
   /etc/init.d/phtunnel start
   /etc/init.d/phtunnel enable
   ```

### 查看状态

- **LuCI 界面**：服务 -> PHTunnel -> 状态
- **命令行**：
  ```bash
  /etc/init.d/phtunnel status
  cat /var/log/oraybox/phtunnel.log
  ```

### 重启服务

```bash
/etc/init.d/phtunnel restart
```

## 向下兼容特性

### API 兼容

| 功能 | OpenWrt 25.x | OpenWrt 21.02+ | 说明 |
|------|---------------|----------------|------|
| Controller API | `return {}` | ✅ 支持 | 现代写法 |
| JSON 库 | `luci-lib-jsonc` | `luci-lib-json` | 双重支持 |
| Auth Token | `authtoken` | `authsession` | 自动降级 |
| UCI 权限 | 完整支持 | 完整支持 | 标准 ACL |

### 服务管理

| 功能 | OpenWrt 25.x | OpenWrt 18.06+ | 说明 |
|------|---------------|----------------|------|
| Procd | ✅ 支持 | ✅ 支持 | 现代 init 系统 |
| Jail 沙箱 | ✅ 支持 | ⚠️ 可选 | 自动检测 |
| 自动重启 | ✅ 支持 | ✅ 支持 | Respawn 策略 |
| 服务重载 | ✅ 支持 | ✅ 支持 | 配置热重载 |

## 常见问题

### Q: 提示依赖缺失？

A: 请确保安装了所有依赖包：
```bash
opkg update
opkg install luci-lib-json luci-lib-jsonc cgi-io curl
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

## 技术细节

### 包格式

- **格式**: 标准 IPK (OpenWrt 包格式)
- **不是**: APK (Alpine Linux 包格式)
- **优势**: 向下兼容，可在 OpenWrt 21.02+ 上运行

### 构建环境

- **SDK**: OpenWrt 25.12.2
- **工具链**: GCC 14.2.0
- **C 库**: musl
- **Lua 版本**: 5.4 (兼容 5.1/5.3)

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

## 许可证

- **phtunnel**: Proprietary (Oray)
- **luci-app-phtunnel**: GPL-2.0-only

## 支持

- **官方网站**: https://hsk.oray.com/
- **GitHub**: https://github.com/oooopera/phtunnel1
- **问题反馈**: 请在 GitHub Issues 中提交

## 更新日志

### v1.0.0-1 (2026-04-05)

- ✅ 适配 OpenWrt 25.12.x
- ✅ 向下兼容 OpenWrt 21.02+
- ✅ 使用现代 LuCI API
- ✅ 增强 procd 服务管理
- ✅ 完整 UCI 权限配置
- ✅ 双重 JSON 库支持
- ✅ 支持 7 种 CPU 架构
- ✅ 改进日志和错误处理
- ✅ 优化热重载功能
