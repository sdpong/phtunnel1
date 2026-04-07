# PHTunnel APK 包问题分析与解决方案

## 问题描述

用户在 OpenWrt 25.12.x 上安装 APK 包时遇到以下错误：

```
ERROR: /tmp/upload.apk: unexpected end of file
```

## 问题分析

经过详细分析，发现以下问题：

### 1. APK 格式验证

**Alpine Linux APK 标准格式**：
- control.tar.gz（包含包元数据和脚本）
- data.tar.gz（包含实际文件）

**当前 APK 文件状态**：
- ✅ 包含两个正确的 gzip 流（control.tar.gz 和 data.tar.gz）
- ✅ control.tar.gz 可以正常解压
- ✅ data.tar.gz 可以正常解压
- ⚠️ APK 文件中包含额外的 gzip 流（来自 phtunnel 二进制文件中的随机数据）

### 2. 多余的 Gzip 流

APK 文件中包含多个 gzip 流（3-7 个），这是因为：
- control.tar.gz（1 个）
- data.tar.gz（1 个）
- phtunnel 二进制文件中包含看起来像 gzip 头的字节序列（多个）

这些额外的 gzip 流不应该影响 Alpine Linux 的 apk 工具，因为它只关心前两个 gzip 流。

### 3. 可能的原因

#### 原因 1: 文件上传损坏
用户使用 Web 界面上传文件到 /tmp/upload.apk，可能在上传过程中文件损坏。

#### 原因 2: OpenWrt 的 apk 工具实现
OpenWrt 25.12.x 的 apk 工具可能与标准 Alpine Linux 的 apk 工具有细微差别。

#### 原因 3: 权限问题
文件可能没有正确的权限。

## 解决方案

### 方案 1: 使用 wget 直接下载（推荐）

```bash
# 在 OpenWrt 路由器上直接下载
cd /tmp
rm -f upload.apk

# 下载核心包
wget https://github.com/sdpong/phtunnel1/releases/download/v1.0.0.7-apk/phtunnel_1.0.0.7_qualcommax-ipq807x.apk

# 下载 LuCI 界面
wget https://github.com/sdpong/phtunnel1/releases/download/v1.0.0.7-apk/luci-app-phtunnel_1.0.0.7_all.apk

# 验证文件
ls -lh phtunnel_1.0.0.7_qualcommax-ipq807x.apk
ls -lh luci-app-phtunnel_1.0.0.7_all.apk

# 安装
apk add --allow-untrusted phtunnel_1.0.0.7_qualcommax-ipq807x.apk
apk add --allow-untrusted luci-app-phtunnel_1.0.0.7_all.apk
```

### 方案 2: 检查上传的文件

```bash
# 检查文件大小
ls -lh /tmp/upload.apk

# 预期大小（qualcommax-ipq807x）: 233041 bytes (227K)
# 预期大小（luci-app-phtunnel）: 1919 bytes (1.9K)

# 如果文件大小不对，重新上传

# 检查文件完整性
md5sum /tmp/upload.apk

# 对比下载的文件的 MD5
wget -O - https://github.com/sdpong/phtunnel1/releases/download/v1.0.0.7-apk/phtunnel_1.0.0.7_qualcommax-ipq807x.apk | md5sum
```

### 方案 3: 使用不同的上传方法

```bash
# 方法 1: 使用 scp
scp phtunnel_1.0.0.7_qualcommax-ipq807x.apk root@192.168.1.1:/tmp/

# 方法 2: 使用 curl
curl -o /tmp/phtunnel_1.0.0.7_qualcommax-ipq807x.apk \
  https://github.com/sdpong/phtunnel1/releases/download/v1.0.0.7-apk/phtunnel_1.0.0.7_qualcommax-ipq807x.apk
```

### 方案 4: 验证 OpenWrt 版本

```bash
# 检查 OpenWrt 版本
cat /etc/openwrt_release

# 检查 apk 工具版本
apk --version

# 检查可用的包管理器
which apk
which opkg
```

### 方案 5: 使用 opkg（如果可用）

OpenWrt 25.12.x 可能同时支持 apk 和 opkg。

```bash
# 检查 opkg 是否可用
which opkg

# 如果有 opkg，尝试使用 opkg 安装
opkg install phtunnel_1.0.0.7_qualcommax-ipq807x.apk
```

## 临时解决方案

如果上述方法都不奏效，可以尝试手动安装：

```bash
# 解压 APK 包
mkdir -p /tmp/phtunnel
cd /tmp/phtunnel

# 提取 data.tar.gz
dd if=/tmp/phtunnel_1.0.0.7_qualcommax-ipq807x.apk bs=1 skip=740 of=data.tar.gz
gunzip -c data.tar.gz | tar -x

# 手动复制文件
cp usr/sbin/phtunnel /usr/sbin/
chmod +x /usr/sbin/phtunnel

cp etc/config/phtunnel /etc/config/
cp etc/init.d/phtunnel /etc/init.d/
chmod +x /etc/init.d/phtunnel

cp etc/hotplug.d/iface/30-oray-phtunnel /etc/hotplug.d/iface/
chmod +x /etc/hotplug.d/iface/30-oray-phtunnel

# 创建日志目录
mkdir -p /var/log/oraybox

# 启动服务
/etc/init.d/phtunnel enable
/etc/init.d/phtunnel start
```

## 相关资源

- GitHub Release: https://github.com/sdpong/phtunnel1/releases/tag/v1.0.0.7-apk
- OpenWrt 文档: https://openwrt.org/docs/
- Alpine Linux APK 文档: https://wiki.alpinelinux.org/wiki/Creating_an_apkg
- PHTunnel 官网: https://hsk.oray.com/

## 下一步

1. 尝试方案 1（使用 wget 直接下载）- 这是推荐的解决方案
2. 如果失败，尝试方案 2（检查上传的文件）
3. 如果仍然失败，尝试方案 4（验证 OpenWrt 版本）
4. 作为最后的手段，使用方案 5（手动安装）

## 联系支持

如果上述方法都无法解决问题，请联系：
- Oray 技术支持: https://hsk.oray.com/
- OpenWrt 社区: https://forum.openwrt.org/
- GitHub Issues: https://github.com/sdpong/phtunnel1/issues

---

更新时间: 2026-04-07 05:35
版本: v1.0.0.7
状态: 分析中
