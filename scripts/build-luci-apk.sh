#!/bin/bash

# 脚本：build-luci-apk.sh
# 功能：为 OpenWrt 25.12.x 构建 APK 格式的 luci-app-phtunnel 包（Alpine Linux 格式）

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 配置
VERSION="1.0.0.7"
PKG_NAME="luci-app-phtunnel"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LUCI_DIR="$PROJECT_ROOT/luci-app-phtunnel-apk"
OUTPUT_DIR="$PROJECT_ROOT/releases/apk"

echo -e "${GREEN}开始构建 APK 格式的 luci-app-phtunnel 包...${NC}"

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 构建 all 架构的包（LuCI 应用是架构无关的）
arch="all"

echo -e "\n${GREEN}正在为架构 $arch 构建 APK...${NC}"

# 创建临时构建目录
BUILD_DIR="$LUCI_DIR/build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# 创建 APK 目录结构
mkdir -p "$BUILD_DIR/usr/share/rpcd/acl.d"
mkdir -p "$BUILD_DIR/usr/lib/lua/luci"
mkdir -p "$BUILD_DIR/etc/config"

# 复制 LuCI 控制器
mkdir -p "$BUILD_DIR/usr/lib/lua/luci/controller"
cp "$LUCI_DIR/luasrc/controller/phtunnel.lua" "$BUILD_DIR/usr/lib/lua/luci/controller/"

# 复制 LuCI CBI 模型
mkdir -p "$BUILD_DIR/usr/lib/lua/luci/model/cbi"
cp "$LUCI_DIR/luasrc/model/cbi/phtunnel.lua" "$BUILD_DIR/usr/lib/lua/luci/model/cbi/"

# 复制 LuCI 视图
mkdir -p "$BUILD_DIR/usr/lib/lua/luci/view/phtunnel"
cp "$LUCI_DIR/luasrc/view/phtunnel/phtunnel_status.htm" "$BUILD_DIR/usr/lib/lua/luci/view/phtunnel/"

# 创建 .PKGINFO 文件（APK 包元数据）
cat > "$BUILD_DIR/.PKGINFO" << EOF
pkgname=$PKG_NAME
pkgver=$VERSION
pkgdesc=LuCI support for PHTunnel
url=https://hsk.oray.com/
arch=$arch
license=Apache-2.0
depends=luci-core phtunnel
options=!
EOF

# 创建 .post-install 脚本（安装后执行）
cat > "$BUILD_DIR/.post-install" << 'EOF'
#!/bin/sh
# luci-app-phtunnel post-install script

# 重启 rpcd 服务以加载新的 ACL
if [ -x /etc/init.d/rpcd ]; then
    /etc/init.d/rpcd restart
fi

# 重启 uhttpd 服务以重新加载 LuCI
if [ -x /etc/init.d/uhttpd ]; then
    /etc/init.d/uhttpd restart
fi
EOF
chmod +x "$BUILD_DIR/.post-install"

# 创建 APK 包
cd "$BUILD_DIR"

# 使用 tar 创建 APK 包（APK 是 tar.gz 格式）
APKTAR="$OUTPUT_DIR/${PKG_NAME}_${VERSION}_${arch}.apk"

# 创建 APK 包（直接打包所有内容）
tar -czf "$APKTAR" .PKGINFO .post-install usr etc

echo -e "${GREEN}✓ APK 包已创建：$APKTAR${NC}"
echo -e "  ${YELLOW}大小：$(ls -lh "$APKTAR" | awk '{print $5}')${NC}"

cd "$PROJECT_ROOT"

echo -e "\n${GREEN}APK 构建完成！${NC}"
echo -e "${YELLOW}输出目录：$OUTPUT_DIR${NC}"

# 列出所有 APK 包
echo -e "\n${GREEN}已创建的 APK 包：${NC}"
ls -lh "$OUTPUT_DIR"/"${PKG_NAME}_${VERSION}"_*.apk 2>/dev/null || echo "未找到 APK 包"
