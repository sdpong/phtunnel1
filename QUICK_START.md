# 快速开始指南 - PHTunnel OpenWrt 25.12.x

## 🚀 快速编译（5分钟）

### 方法一：使用自动编译脚本（推荐）

```bash
# 1. 查看支持的架构
./build.sh --list

# 2. 编译 qualcommax/ipq807x（优先推荐）
./build.sh qualcommax

# 3. 查看编译结果
ls -lh build_output/qualcommax/
```

### 方法二：使用 GitHub Actions

1. Fork 本项目到您的 GitHub
2. 进入 Actions 页面
3. 选择 "Build PHTunnel APK for OpenWrt 25.12.x"
4. 选择架构并运行
5. 从 Artifacts 下载编译好的 APK 包

## 📦 支持的架构

| 优先级 | OpenWrt 目标 | CPU | 命令 |
|-------|--------------|-----|------|
| 1 | qualcommax/ipq807x | aarch64 | `./build.sh qualcommax` |
| 2 | x86/64 | x86_64 | `./build.sh x86` |
| 3 | mediatek/mt7622 | armv7 | `./build.sh mediatek` |
| 4 | ramips/mt7620 | mipsel | `./build.sh ramips` |
| 5 | ath79/generic | mips | `./build.sh ath79` |
| 6 | rockchip/generic | aarch64 | `./build.sh rockchip` |
| 7 | bcm27xx/bcm2711 | armv7 | `./build.sh bcm27xx` |

## 🔧 手动编译步骤

### 1. 下载 SDK

```bash
# qualcommax/ipq807x（推荐）
wget https://downloads.openwrt.org/releases/25.12.2/targets/qualcommax/ipq807x/openwrt-sdk-25.12.2-qualcommax-ipq807x_gcc-14.3.0_musl.Linux-x86_64.tar.zst
tar -xf openwrt-sdk-25.12.2-qualcommax-ipq807x_gcc-14.3.0_musl.Linux-x86_64.tar.zst
cd openwrt-sdk-25.12.2-qualcommax-ipq807x_*
```

### 2. 配置

```bash
# 更新 feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 复制项目
cp -r /path/to/phtunnel_fixed/* package/

# 配置编译选项（重要！）
make defconfig
echo "CONFIG_USE_APK=y" >> .config
echo "CONFIG_PACKAGE_phtunnel=y" >> .config
echo "CONFIG_PACKAGE_luci-app-phtunnel=y" >> .config
make oldconfig
```

### 3. 编译

```bash
# 编译 phtunnel
make package/phtunnel/compile V=s

# 编译 luci-app-phtunnel
make package/luci-app-phtunnel/compile V=s
```

### 4. 查找 APK 包

```bash
find bin/packages -name "*.apk"

# 预期输出：
# bin/packages/aarch64/base/phtunnel-1.0.0-2_aarch64.apk
# bin/packages/aarch64/luci/luci-app-phtunnel-1.0.0-2_all.apk
```

## 📲 安装到路由器

```bash
# 1. 上传 APK 包
scp phtunnel-1.0.0-2_*.apk root@192.168.1.1:/tmp/
scp luci-app-phtunnel-1.0.0-2_all.apk root@192.168.1.1:/tmp/

# 2. SSH 到路由器
ssh root@192.168.1.1

# 3. 安装
cd /tmp
apk add phtunnel-1.0.0-2_*.apk
apk add luci-app-phtunnel-1.0.0-2_all.apk

# 4. 验证
apk info | grep phtunnel
/etc/init.d/phtunnel status
```

## ✅ 验证步骤

### 1. 检查 APK 包

```bash
apk info --file phtunnel-1.0.0-2_*.apk
apk list --contents --file phtunnel-1.0.0-2_*.apk
```

### 2. 检查 OpenWrt 版本

```bash
cat /etc/openwrt_release
# 应该显示 OpenWrt 25.12.x
```

### 3. 测试服务

```bash
/etc/init.d/phtunnel start
/etc/init.d/phtunnel status

# 访问 LuCI 界面
# http://192.168.1.1/cgi-bin/luci
# 服务 -> PHTunnel
```

## 🎯 优先推荐

### 最优先：qualcommax/ipq807x

```bash
./build.sh qualcommax
```

**原因**：
- 最新的路由器芯片
- 性能最强
- 用户基数大

### 次优先：x86/64

```bash
./build.sh x86
```

**原因**：
- 虚拟机和测试环境
- 兼容性好
- 编译速度快

## ⚠️ 常见问题

### Q: 编译失败怎么办？

**A**: 检查：
1. 是否使用 OpenWrt 25.12.2 SDK
2. 二进制文件是否存在
3. 磁盘空间是否足够（至少 10GB）

### Q: 安装时还是提示错误？

**A**: 检查：
1. OpenWrt 版本是否为 25.12.x
2. APK 包是否完整下载
3. 架构是否匹配

### Q: 如何查看编译日志？

**A**:
```bash
# 自动脚本
./build.sh qualcommax

# 手动编译
make package/phtunnel/compile V=s
```

## 📚 更多信息

- **完整文档**: `README.md`
- **编译指南**: `COMPILE_GUIDE.md`
- **技术分析**: `SUMMARY.md`

## 🔗 相关链接

- **OpenWrt 25.12.x**: https://downloads.openwrt.org/releases/25.12.2/targets/
- **参考项目**: https://github.com/destan19/OpenAppFilter.git
- **官方网站**: https://hsk.oray.com/

---

**版本**: v1.0.0-2
**OpenWrt**: 25.12.x
**状态**: ✅ 完全修复并验证