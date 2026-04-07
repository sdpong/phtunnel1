#!/bin/bash

# 脚本：build-apk.sh
# 功能：为 OpenWrt 25.12.x 构建 APK 格式的 phtunnel 包（正确的 Alpine Linux 格式）

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 配置
VERSION="1.0.0.7"
PKG_NAME="phtunnel"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BINARY_DIR="$PROJECT_ROOT/phtunnel-binary"
APK_DIR="$PROJECT_ROOT/phtunnel-apk"
OUTPUT_DIR="$PROJECT_ROOT/releases/apk"

echo -e "${GREEN}开始构建 APK 格式的 phtunnel 包（Alpine Linux 格式）...${NC}"

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 为每个架构构建 APK
for arch_dir in "$BINARY_DIR"/*; do
    if [ ! -d "$arch_dir" ]; then
        continue
    fi
    
    arch=$(basename "$arch_dir")
    binary_file="$arch_dir/phtunnel"
    
    if [ ! -f "$binary_file" ]; then
        echo -e "${RED}错误：找不到 $arch 的二进制文件${NC}"
        continue
    fi
    
    echo -e "\n${GREEN}正在为架构 $arch 构建 APK...${NC}"
    
    # 创建临时构建目录
    BUILD_DIR="$APK_DIR/build-$arch"
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    
    # 创建控制数据目录
    CONTROL_DIR="$BUILD_DIR/control"
    mkdir -p "$CONTROL_DIR"
    
    # 创建 .PKGINFO 文件
    cat > "$CONTROL_DIR/.PKGINFO" << EOF
pkgname=$PKG_NAME
pkgver=$VERSION
pkgdesc=PHTunnel is core component of HSK intranet penetration, high-performance reverse proxy applications
url=https://hsk.oray.com/
arch=$arch
license=Proprietary
options=!
EOF
    
    # 创建 .pre-install 脚本
    cat > "$CONTROL_DIR/.pre-install" << 'EOF'
#!/bin/sh
# PHTunnel pre-install script

# 创建必要的目录
mkdir -p /var/log/oraybox
EOF
    chmod +x "$CONTROL_DIR/.pre-install"
    
    # 创建 .post-install 脚本
    cat > "$CONTROL_DIR/.post-install" << 'EOF'
#!/bin/sh
# PHTunnel post-install script

# 确保脚本有执行权限
chmod +x /etc/init.d/phtunnel
chmod +x /etc/hotplug.d/iface/30-oray-phtunnel

# 重启网络服务以触发 hotplug 脚本
if [ -x /etc/init.d/network ]; then
    /etc/init.d/network restart
fi
EOF
    chmod +x "$CONTROL_DIR/.post-install"
    
    # 创建控制数据包
    cd "$CONTROL_DIR"
    tar -czf "$BUILD_DIR/control.tar.gz" .PKGINFO .pre-install .post-install
    cd "$BUILD_DIR"
    
    # 创建数据目录
    DATA_DIR="$BUILD_DIR/data"
    mkdir -p "$DATA_DIR"
    
    # 创建 APK 目录结构
    mkdir -p "$DATA_DIR/usr/sbin"
    mkdir -p "$DATA_DIR/etc/init.d"
    mkdir -p "$DATA_DIR/etc/config"
    mkdir -p "$DATA_DIR/etc/hotplug.d/iface"
    mkdir -p "$DATA_DIR/var/log/oraybox"
    
    # 复制二进制文件
    cp "$binary_file" "$DATA_DIR/usr/sbin/phtunnel"
    chmod +x "$DATA_DIR/usr/sbin/phtunnel"
    
    # 复制配置文件
    cp "$APK_DIR/files/etc/config/phtunnel" "$DATA_DIR/etc/config/"
    cp "$APK_DIR/files/etc/init.d/phtunnel" "$DATA_DIR/etc/init.d/"
    cp "$APK_DIR/files/etc/hotplug.d/iface/30-oray-phtunnel" "$DATA_DIR/etc/hotplug.d/iface/"
    chmod +x "$DATA_DIR/etc/init.d/phtunnel"
    chmod +x "$DATA_DIR/etc/hotplug.d/iface/30-oray-phtunnel"
    
    # 创建数据包
    cd "$DATA_DIR"
    tar -czf "$BUILD_DIR/data.tar.gz" usr etc var
    cd "$BUILD_DIR"
    
    # 创建最终 APK 包（Alpine Linux 格式：control.tar.gz + data.tar.gz）
    APKTAR="$OUTPUT_DIR/${PKG_NAME}_${VERSION}_${arch}.apk"
    cat control.tar.gz data.tar.gz > "$APKTAR"
    
    echo -e "${GREEN}✓ APK 包已创建：$APKTAR${NC}"
    echo -e "  ${YELLOW}control.tar.gz 大小：$(ls -lh "$BUILD_DIR/control.tar.gz" | awk '{print $5}')${NC}"
    echo -e "  ${YELLOW}data.tar.gz 大小：$(ls -lh "$BUILD_DIR/data.tar.gz" | awk '{print $5}')${NC}"
    echo -e "  ${YELLOW}APK 总大小：$(ls -lh "$APKTAR" | awk '{print $5}')${NC}"
    
    cd "$PROJECT_ROOT"
done

echo -e "\n${GREEN}APK 构建完成！${NC}"
echo -e "${YELLOW}输出目录：$OUTPUT_DIR${NC}"

# 列出所有 APK 包
echo -e "\n${GREEN}已创建的 APK 包：${NC}"
ls -lh "$OUTPUT_DIR"/"${PKG_NAME}_${VERSION}"_*.apk 2>/dev/null || echo "未找到 APK 包"
