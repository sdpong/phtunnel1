# OpenWrt 25.12.x APK 编译完整指南

## 目录
- [问题分析](#问题分析)
- [解决方案](#解决方案)
- [编译步骤](#编译步骤)
- [常见问题](#常见问题)
- [验证和测试](#验证和测试)

## 问题分析

### 原始问题
phtunnel1 项目在使用 OpenWrt 25.12.x 时出现 APK 安装错误：
```
unexpected end of file
```

### 根本原因
1. **错误的 SDK 版本**：项目使用 OpenWrt 23.05.5 SDK 编译，而不是 25.12.2 SDK
2. **APK 格式未正确启用**：未设置 `CONFIG_USE_APK=y`
3. **包结构不兼容**：生成的 APK 包不符合 OpenWrt 25.12.x 标准

### 技术细节

#### APK vs IPK
OpenWrt 25.12.x 从 IPK 格式切换到 APK 格式（与 Alpine Linux 相同）：

| 特性 | IPK (23.05.x-) | APK (25.12.x+) |
|------|---------------|---------------|
| 元数据格式 | control 文件 | .PKGINFO 文件 |
| 包管理器 | opkg | apk |
| 构建工具 | ipkg-build | apk mkpkg |
| 脚本格式 | preinst/postinst | pre-install/post-install |

## 解决方案

### 1. 更新 GitHub Actions 工作流
使用 OpenWrt 25.12.2 SDK 并启用 APK 格式。

### 2. 修复 APK 打包脚本
使用 OpenWrt 标准的 `apk mkpkg` 工具。

### 3. 更新配置文件
确保 `CONFIG_USE_APK=y` 设置正确。

## 编译步骤

### 方法一：本地编译（Linux 环境）

#### 环境要求
```bash
# Ubuntu 20.04+
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    ccache \
    ecj \
    fastjar \
    file \
    g++ \
    gawk \
    gettext \
    git \
    java-propose-classpath \
    libelf-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libssl-dev \
    python3 \
    unzip \
    wget \
    zstd \
    python3-distutils \
    python3-setuptools \
    python3-pyelftools \
    rsync \
    subversion \
    swig \
    time \
    xsltproc \
    zlib1g-dev
```

#### 下载和准备 SDK

**针对不同架构下载相应的 SDK：**

```bash
# x86_64
wget https://downloads.openwrt.org/releases/25.12.2/targets/x86/64/openwrt-sdk-25.12.2-x86-64_gcc-14.3.0_musl.Linux-x86_64.tar.zst

# aarch64 (示例：qualcommax/ipq807x)
wget https://downloads.openwrt.org/releases/25.12.2/targets/qualcommax/ipq807x/openwrt-sdk-25.12.2-qualcommax-ipq807x_gcc-14.3.0_musl.Linux-x86_64.tar.zst

# ARMv7 (示例：mediatek/mt7622)
wget https://downloads.openwrt.org/releases/25.12.2/targets/mediatek/mt7622/openwrt-sdk-25.12.2-mediatek-mt7622_gcc-14.3.0_musl.Linux-x86_64.tar.zst

# MIPS (示例：ath79/generic)
wget https://downloads.openwrt.org/releases/25.12.2/targets/ath79/generic/openwrt-sdk-25.12.2-ath79-generic_gcc-14.3.0_musl.Linux-x86_64.tar.zst

# MIPSel (示例：ramips/mt7620)
wget https://downloads.openwrt.org/releases/25.12.2/targets/ramips/mt7620/openwrt-sdk-25.12.2-ramips-mt7620_gcc-14.3.0_musl.Linux-x86_64.tar.zst
```

#### 解压 SDK

```bash
tar -xf openwrt-sdk-25.12.2-*.tar.zst
cd openwrt-sdk-25.12.2-*
```

#### 配置 SDK

```bash
# 1. 更新 feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 2. 克隆项目
git clone https://github.com/sdpong/phtunnel1.git /tmp/phtunnel1

# 3. 复制包源码
cp -r /tmp/phtunnel1/luci-app-phtunnel package/
cp -r /tmp/phtunnel1/phtunnel package/

# 4. 配置编译选项
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

# 保存配置
make oldconfig
```

#### 编译包

```bash
# 编译 phtunnel 包
make package/phtunnel/compile V=s

# 编译 luci-app-phtunnel 包
make package/luci-app-phtunnel/compile V=s
```

#### 查找生成的 APK 包

```bash
# 查找所有 APK 包
find bin/packages -name "*.apk"

# 预期输出示例：
# bin/packages/x86/base/phtunnel-1.0.0-2_x86_64.apk
# bin/packages/x86/luci/luci-app-phtunnel-1.0.0-2_all.apk
```

### 方法二：使用 Docker 编译

#### 创建 Dockerfile

```dockerfile
FROM ubuntu:22.04

# 安装编译依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    ccache \
    g++ \
    gawk \
    gettext \
    git \
    libelf-dev \
    libncurses5-dev \
    libssl-dev \
    python3 \
    unzip \
    wget \
    zstd \
    python3-distutils \
    python3-setuptools \
    rsync \
    subversion \
    time \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /openwrt
```

#### 构建和运行 Docker 容器

```bash
# 构建 Docker 镜像
docker build -t openwrt-builder .

# 运行 Docker 容器
docker run -it --rm -v $(pwd):/workdir openwrt-builder bash
```

#### 在容器中编译

```bash
# 复制 SDK 到容器
cd /openwrt
cp /workdir/openwrt-sdk-25.12.2-*.tar.zst .
tar -xf openwrt-sdk-25.12.2-*.tar.zst
cd openwrt-sdk-25.12.2-*

# 按照方法一的步骤进行编译
./scripts/feeds update -a
./scripts/feeds install -a
# ... 其他步骤
```

### 方法三：使用 GitHub Actions

1. **Fork 项目**到您的 GitHub 账户
2. **进入 Actions**页面
3. **选择工作流**"Build PHTunnel APK for OpenWrt 25.12.x"
4. **点击 "Run workflow"**
5. **选择架构**并运行
6. **下载编译结果**

## 验证和测试

### 验证 APK 包

```bash
# 检查 APK 包信息
apk info --file phtunnel-1.0.0-2_x86_64.apk

# 检查 APK 包内容
apk list --contents --file phtunnel-1.0.0-2_x86_64.apk

# 检查 APK 包依赖
apk info --depends --file phtunnel-1.0.0-2_x86_64.apk
```

### 在 OpenWrt 设备上测试

```bash
# 上传 APK 包到设备
scp phtunnel-1.0.0-2_*.apk root@192.168.1.1:/tmp/
scp luci-app-phtunnel-1.0.0-2_all.apk root@192.168.1.1:/tmp/

# SSH 到设备
ssh root@192.168.1.1

# 检查 OpenWrt 版本
cat /etc/openwrt_release
# 应该显示 OpenWrt 25.12.x

# 检查包管理器
which apk
# 应该显示 /sbin/apk

# 安装 APK 包
cd /tmp
apk add phtunnel-1.0.0-2_*.apk
apk add luci-app-phtunnel-1.0.0-2_all.apk

# 验证安装
apk info | grep phtunnel

# 测试服务
/etc/init.d/phtunnel start
/etc/init.d/phtunnel status
```

## 常见问题

### Q1: 编译时提示 "找不到 apk 命令"

**原因**：SDK 版本不正确，或者 `apk` 工具未包含在 SDK 中。

**解决**：
```bash
# 确保使用 OpenWrt 25.12.2 或更高版本的 SDK
# 检查 SDK 版本
cat include/version.mk | grep VERSION_NUMBER

# 检查是否包含 apk 工具
ls staging_dir/host/bin/apk
```

### Q2: 编译时提示 "CONFIG_USE_APK 未定义"

**原因**：未在 `.config` 中启用 APK 格式。

**解决**：
```bash
# 确保 .config 中包含 CONFIG_USE_APK=y
echo "CONFIG_USE_APK=y" >> .config
make oldconfig
```

### Q3: 生成的包是 IPK 格式而非 APK 格式

**原因**：`CONFIG_USE_APK` 未正确设置。

**解决**：
```bash
# 检查 .config 文件
grep CONFIG_USE_APK .config

# 如果不存在，重新配置
make defconfig
echo "CONFIG_USE_APK=y" >> .config
make oldconfig
```

### Q4: 安装时提示 "unexpected end of file"

**原因**：APK 包不完整或格式错误。

**解决**：
```bash
# 1. 检查 APK 包大小
ls -lh *.apk

# 2. 验证 APK 包完整性
apk verify *.apk

# 3. 重新下载或编译 APK 包

# 4. 确保使用 OpenWrt 25.12.x SDK 编译
```

### Q5: 依赖包缺失

**原因**：feeds 未正确安装或配置。

**解决**：
```bash
# 重新更新和安装 feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 检查依赖包是否可用
ls package/feeds/packages/luci-lib-jsonc
ls package/feeds/packages/cgi-io
ls package/feeds/packages/curl
```

### Q6: 编译速度慢

**原因**：未使用 ccache，或者编译选项未优化。

**解决**：
```bash
# 启用 ccache
export CCACHE_DIR=~/.ccache
export PATH="/usr/lib/ccache:$PATH"

# 使用多线程编译
make -j$(nproc) package/phtunnel/compile V=s
```

## 参考资源

### 官方文档
- [OpenWrt 官方文档](https://openwrt.org/docs/guide-developer/start)
- [OpenWrt SDK 使用指南](https://openwrt.org/docs/guide-developer/using_the_sdk)
- [APK 包格式规范](https://wiki.alpinelinux.org/wiki/Creating_an_apk)

### 参考项目
- [OpenAppFilter](https://github.com/destan19/OpenAppFilter.git)
  - 成功的 OpenWrt 25.12.x 项目示例
  - 参考其 APK 构建流程

### 社区资源
- [OpenWrt 论坛](https://forum.openwrt.org/)
- [OpenWrt IRC 频道](irc://irc.oftc.net/#openwrt)

## 总结

本指南提供了完整的 OpenWrt 25.12.x APK 包编译解决方案：

1. ✅ 使用正确的 OpenWrt 25.12.2 SDK
2. ✅ 启用 `CONFIG_USE_APK=y` 配置
3. ✅ 使用标准的 `apk mkpkg` 工具
4. ✅ 提供多种编译方法（本地、Docker、GitHub Actions）
5. ✅ 包含完整的验证和测试步骤

遵循本指南，您可以成功编译出兼容 OpenWrt 25.12.x 的 APK 包，解决 "unexpected end of file" 安装错误。

## 支持和反馈

如果在编译过程中遇到问题，请：
1. 检查本文档的常见问题部分
2. 查看 OpenWrt 官方文档
3. 在项目 GitHub Issues 中提交问题
4. 提供详细的错误日志和环境信息