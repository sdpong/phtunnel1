# PHTunnel for OpenWrt 25.12.x (APK Format)

[![Build APK](https://github.com/sdpong/phtunnel1/actions/workflows/build-apk.yml/badge.svg)](https://github.com/sdpong/phtunnel1/actions/workflows/build-apk.yml)

PHTunnel 是 Oray（花生壳）的内网穿透核心组件，用于实现高性能反向代理应用。此项目为 OpenWrt 25.12.x 提供了 APK 格式的预编译包。

## 特性

- ✅ 支持 TCP、HTTP、HTTPS 协议
- ✅ 端到端 TLS 加密通信
- ✅ 黑白名单防黑验证
- ✅ 自动网络重连
- ✅ 支持 7 种路由器架构
- ✅ 包含 LuCI Web 管理界面

## 支持的架构

| 架构 | 芯片/平台 | 设备示例 |
|------|-----------|---------|
| qualcommax-ipq807x | Qualcomm IPQ807x | 小米 AX3600/AX9000、红米 AX6/AX7、华硕 RT-AX89X 等 |
| bcm27xx-bcm2712 | Broadcom BCM2712 | 树莓派 5 |
| mediatek-filogic | MediaTek Filogic MT7986 | 红米 AX6000、TP-Link XDR6088、小米 AX6000 |
| ramips-mt7621 | MediaTek MT7621 | 斐讯 K3、小米路由器 4A、中兴、TP-Link 等 |
| ramips-mt7620 | MediaTek MT7620/MT7628 | 小米路由器 4C、部分 TP-Link、水星 MW300R |
| ath79-generic | Atheros AR71xx/AR9xxx | TP-Link WR842N、NanoStation、UBNT |
| x86-64 | 通用 x86 路由器、软路由 | 各品牌软路由 |

## 安装

### 方法 1: 从 GitHub Releases 安装

```bash
# 下载适合您架构的包
wget https://github.com/sdpong/phtunnel1/releases/latest/download/phtunnel_1.0.0.7_<your-arch>.apk
wget https://github.com/sdpong/phtunnel1/releases/latest/download/luci-app-phtunnel_1.0.0.7_all.apk

# 安装核心包
apk add phtunnel_1.0.0.7_<your-arch>.apk

# 安装 Web 管理界面
apk add luci-app-phtunnel_1.0.0.7_all.apk
```

### 方法 2: 本地构建

```bash
# 克隆仓库
git clone https://github.com/sdpong/phtunnel1.git
cd phtunnel1

# 准备二进制文件（将预编译的二进制文件放到 phtunnel-binary 目录）
# 二进制文件来源：https://github.com/oray/phtunnel/releases

# 构建 APK 包
./scripts/build-apk.sh

# 构建 LuCI 应用
./scripts/build-luci-apk.sh

# APK 包将生成在 releases/apk 目录
ls -lh releases/apk/
```

## 配置

### 通过 LuCI Web 界面配置

1. 打开浏览器访问路由器管理界面（通常是 `http://192.168.1.1`）
2. 导航到 **服务** -> **PHTunnel**
3. 配置基本信息：
   - **SN**: 设备序列号（在 Oray 官网注册设备后获得）
   - **User**: 设备用户名
4. 配置代理设置（可选）：
   - **Port**: 要转发的本地端口
   - **Protocol**: 协议类型（http/https/tcp）
   - **Host**: 目标主机地址
5. 点击 **保存并应用**
6. 启用服务

### 通过命令行配置

```bash
# 编辑配置文件
vi /etc/config/phtunnel

# 配置示例
config phtunnel 'core'
    option enabled '1'
    option sn 'your-sn-here'
    option user 'your-user-here'

config proxy
    option port '80'
    option protocol 'http'
    option host '192.168.1.100'

# 启用并启动服务
/etc/init.d/phtunnel enable
/etc/init.d/phtunnel start

# 查看服务状态
/etc/init.d/phtunnel status

# 查看日志
tail -f /var/log/oraybox/phtunnel.log
```

## 管理命令

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

## 卸载

```bash
# 停止服务
/etc/init.d/phtunnel stop

# 卸载 LuCI 界面
apk del luci-app-phtunnel

# 卸载核心包
apk del phtunnel
```

## 故障排除

### 服务无法启动

1. 检查配置文件：
   ```bash
   cat /etc/config/phtunnel
   ```

2. 查看日志：
   ```bash
   tail -f /var/log/oraybox/phtunnel.log
   ```

3. 检查网络连接：
   ```bash
   ping hsk.oray.com
   ```

### 无法访问内网服务

1. 确认服务已启动：
   ```bash
   /etc/init.d/phtunnel status
   ```

2. 检查 Oray 官网设备状态：
   - 登录 https://hsk.oray.com/
   - 查看设备是否在线
   - 检查端口映射是否正确

### 依赖问题

如果遇到依赖问题，请确保您的 OpenWrt 系统是 25.12.x 或更高版本，并且使用 APK 包管理系统。

## 文件结构

### phtunnel 包

```
usr/
└── sbin/
    └── phtunnel          # PHTunnel 二进制文件

etc/
├── config/
│   └── phtunnel         # UCI 配置文件
├── init.d/
│   └── phtunnel         # 初始化脚本
└── hotplug.d/iface/
    └── 30-oray-phtunnel # 网络热插拔脚本

var/
└── log/
    └── oraybox/
        └── phtunnel.log # 日志文件
```

### luci-app-phtunnel 包

```
usr/
└── lib/
    └── lua/
        └── luci/
            ├── controller/
            │   └── phtunnel.lua         # 控制器
            ├── model/
            │   └── cbi/
            │       └── phtunnel.lua     # CBI 模型
            └── view/
                └── phtunnel/
                    └── phtunnel_status.htm  # 状态页面
```

## 脚本说明

### `scripts/prepare-binaries.sh`

准备预编译的二进制文件，将不同架构的 phtunnel 二进制文件复制到项目中。

### `scripts/build-apk.sh`

构建核心包（phtunnel）的 APK 包。

### `scripts/build-luci-apk.sh`

构建 LuCI Web 管理界面（luci-app-phtunnel）的 APK 包。

## 注意事项

1. 此包使用 Oray 官方提供的预编译二进制文件
2. PHTunnel 是专有软件，许可证为 Proprietary
3. 如有问题，请联系 Oray 技术支持：https://hsk.oray.com/
4. 需要在 Oray 官网注册设备并获得 SN 和用户信息

## 许可证

PHTunnel 是专有软件，版权归 Oray 所有。

## 相关链接

- Oray 官网: https://www.oray.com/
- HSK 内网穿透: https://hsk.oray.com/
- OpenWrt 官网: https://openwrt.org/

## 贡献

欢迎提交 Issue 和 Pull Request！

## 更新日志

### 1.0.0.7 (2026-04-07)

- ✅ 初始 APK 格式版本
- ✅ 支持 OpenWrt 25.12.x
- ✅ 支持 7 种路由器架构
- ✅ 包含 LuCI Web 管理界面
- ✅ 自动网络重连
- ✅ 支持热插拔网络接口
