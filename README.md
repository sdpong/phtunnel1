# PHTunnel for OpenWrt 25.12.x (APK Format)

## 重要修复说明

**✅ v1.0.0-2 版本已完全修复 OpenWrt 25.12.x APK 安装问题**

### 修复内容

- ✅ 使用 OpenWrt 25.12.2 SDK 编译
- ✅ 正确启用 APK 包格式 (CONFIG_USE_APK=y)
- ✅ 修复"unexpected end of file"安装错误
- ✅ 使用本地预编译的二进制文件
- ✅ 支持多种主流架构
- ✅ 参照 OpenAppFilter 项目成功编译方法

### 支持的架构

| OpenWrt 目标 | CPU 架构 | 状态 | 优先级 |
|--------------|-----------|------|---------|
| qualcommax/ipq807x | aarch64 | ✅ | 最高 |
| x86/64 | x86_64 | ✅ | 高 |
| mediatek/mt7622 | armv7 | ✅ | 高 |
| ramips/mt7620 | mipsel | ✅ | 中 |
| ath79/generic | mips | ✅ | 中 |
| rockchip/generic | aarch64 | ✅ | 中 |
| bcm27xx/bcm2711 | armv7 | ✅ | 低 |

## 快速开始

### 方法一：使用编译脚本（推荐）

```bash
# 查看所有支持的架构
./build.sh --list

# 编译特定架构（优先推荐 qualcommax）
./build.sh qualcommax

# 编译所有架构
./build.sh --all

# 查看编译结果
ls -lh build_output/*/
```

### 方法二：手动编译

#### 1. 下载 OpenWrt 25.12.2 SDK

```bash
# qualcommax/ipq807x (优先推荐）
wget https://downloads.openwrt.org/releases/25.12.2/targets/qualcommax/ipq807x/openwrt-sdk-25.12.2-qualcommax-ipq807x_gcc-14.3.0_musl.Linux-x86_64.tar.zst
tar -xf openwrt-sdk-25.12.2-qualcommax-ipq807x_gcc-14.3.0_musl.Linux-x86_64.tar.zst
cd openwrt-sdk-25.12.2-qualcommax-ipq807x_*

# x86/64
wget https://downloads.openwrt.org/releases/25.12.2/targets/x86/64/openwrt-sdk-25.12.2-x86-64_gcc-14.3.0_musl.Linux-x86_64.tar.zst
tar -xf openwrt-sdk-25.12.2-x86-64_gcc-14.3.0_musl.Linux-x86_64.tar.zst
cd openwrt-sdk-25.12.2-x86-64_*

# mediatek/mt7622
wget https://downloads.openwrt.org/releases/25.12.2/targets/mediatek/mt7622/openwrt-sdk-25.12.2-mediatek-mt7622_gcc-14.3.0_musl.Linux-x86_64.tar.zst
tar -xf openwrt-sdk-25.12.2-mediatek-mt7622_gcc-14.3.0_musl.Linux-x86_64.tar.zst
cd openwrt-sdk-25.12.2-mediatek-mt7622_*
```

#### 2. 更新 feeds

```bash
./scripts/feeds update -a
./scripts/feeds install -a
```

#### 3. 复制项目文件

```bash
# 假设项目在 /path/to/phtunnel_fixed
cp -r /path/to/phtunnel_fixed/* package/
```

#### 4. 配置编译选项

```bash
make defconfig

# 启用 APK 包格式（重要！）
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

#### 5. 编译包

```bash
# 编译 phtunnel 包
make package/phtunnel/compile V=s

# 编译 luci-app-phtunnel 包
make package/luci-app-phtunnel/compile V=s
```

#### 6. 查找生成的 APK 包

```bash
find bin/packages -name "*.apk"

# 预期输出：
# bin/packages/<arch>/base/phtunnel-1.0.0-2_<arch>.apk
# bin/packages/<arch>/luci/luci-app-phtunnel-1.0.0-2_all.apk
```

## 二进制文件说明

本项目使用预编译的二进制文件，位于 `binaries/` 目录：

```
binaries/
├── x86_64/phtunnel        # x86_64 架构
├── aarch64/phtunnel       # ARM64 架构
├── armv7/phtunnel          # ARMv7 架构
├── mips/phtunnel           # MIPS 架构
└── mipsel/phtunnel        # MIPSel 架构
```

### 架构映射

| OpenWrt 架构 | 二进制文件目录 |
|--------------|--------------|
| x86_64 | binaries/x86_64/ |
| aarch64 | binaries/aarch64/ |
| arm_cortex-a7 | binaries/armv7/ |
| arm_cortex-a9 | binaries/armv7/ |
| mips_24kc | binaries/mips/ |
| mipsel_24kc | binaries/mipsel/ |

## 安装和使用

### 1. 检查 OpenWrt 版本

```bash
cat /etc/openwrt_release
# 应该显示 OpenWrt 25.12.x
```

### 2. 上传 APK 包到路由器

```bash
# 上传到路由器
scp phtunnel-1.0.0-2_*.apk root@192.168.1.1:/tmp/
scp luci-app-phtunnel-1.0.0-2_all.apk root@192.168.1.1:/tmp/
```

### 3. 安装 APK 包

```bash
# SSH 到路由器
ssh root@192.168.1.1

# 安装包
cd /tmp
apk add phtunnel-1.0.0-2_*.apk
apk add luci-app-phtunnel-1.0.0-2_all.apk

# 验证安装
apk info | grep phtunnel
```

### 4. 配置和使用

```bash
# 启用服务
/etc/init.d/phtunnel enable
/etc/init.d/phtunnel start

# 查看状态
/etc/init.d/phtunnel status

# 访问 LuCI 界面
# http://192.168.1.1/cgi-bin/luci
# 服务 -> PHTunnel
```

## 常见问题

### Q: 仍然出现 "unexpected end of file" 错误？

**A**: 请检查：
1. 是否使用 OpenWrt 25.12.x 版本
2. APK 包是否完整下载
3. 是否使用了本修复版本的包

### Q: 如何确认我的路由器架构？

**A**:
```bash
cat /etc/openwrt_release | grep DISTRIB_ARCH
# 或
ubus call system board
```

### Q: 编译失败怎么办？

**A**:
1. 确保使用正确的 OpenWrt 25.12.2 SDK
2. 检查二进制文件是否存在于 `binaries/` 目录
3. 查看编译日志中的错误信息

### Q: 可以在 OpenWrt 23.05.x 上使用吗？

**A**: 不可以。本版本仅支持 OpenWrt 25.12.x 及以上版本的 APK 格式。

## 技术细节

### vs 原版本对比

| 特性 | v1.0.0-1 (原版) | v1.0.0-2 (修复版) |
|------|-----------------|------------------|
| OpenWrt SDK | 23.05.5 ❌ | 25.12.2 ✅ |
| APK 格式 | 部分支持 ❌ | 完全支持 ✅ |
| CONFIG_USE_APK | 未启用 ❌ | 已启用 ✅ |
| 二进制文件 | 下载失败 ❌ | 本地预编译 ✅ |
| 安装结果 | 失败 ❌ | 成功 ✅ |

### 修复原理

1. **SDK 版本**: 从 23.05.5 升级到 25.12.2
2. **APK 格式**: 正确启用 `CONFIG_USE_APK=y`
3. **二进制文件**: 使用本地预编译文件，避免下载失败
4. **架构支持**: 支持多种主流架构的自动选择

## 参考项目

- **OpenAppFilter**: https://github.com/destan19/OpenAppFilter.git
  - 本项目参照了 OpenAppFilter 的成功编译方法
  - OpenAppFilter 在 OpenWrt 25.12.x 上编译和运行正常

## 许可证

- **phtunnel**: Proprietary (Oray)
- **luci-app-phtunnel**: GPL-2.0-only
- **编译脚本**: MIT License

## 支持

- **官方网站**: https://hsk.oray.com/
- **GitHub**: https://github.com/sdpong/phtunnel1
- **问题反馈**: 请在 GitHub Issues 中提交

## 更新日志

### v1.0.0-2 (2026-04-07)

- ✅ **修复 "unexpected end of file" 安装错误**
- ✅ **使用 OpenWrt 25.12.2 SDK 编译**
- ✅ **正确配置 APK 包格式**
- ✅ **使用本地预编译二进制文件**
- ✅ **支持 7 种主流架构**
- ✅ **参照 OpenAppFilter 成功编译方法**
- ✅ **添加自动编译脚本**
- ✅ **完整的架构映射和选择**

### v1.0.0-1 (原版本)

- ❌ **使用错误的 SDK 版本**
- ❌ **APK 格式配置错误**
- ❌ **二进制文件下载失败**
- ❌ **不兼容 OpenWrt 25.12.x**

## 致谢

- OpenAppFilter 项目提供了成功的 OpenWrt 25.12.x 编译参考
- OpenWrt 社区提供了 APK 格式的技术支持