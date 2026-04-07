#!/bin/bash

# 脚本：prepare-binaries.sh
# 功能：将预编译的 phtunnel 二进制文件复制到项目中

set -e

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 配置
SOURCE_DIR="/Volumes/S7/Downloads/phtunnel-all"
TARGET_DIR="/Users/stevensong/workspace/phtunnel1/phtunnel-binary"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${GREEN}正在准备 phtunnel 二进制文件...${NC}"

# 创建目标目录
mkdir -p "$TARGET_DIR"

# 定义 OpenWrt 架构与 phtunnel 二进制文件的映射
declare -A ARCH_MAPPING
ARCH_MAPPING["qualcommax-ipq807x"]="aarch64-rpi3-linux-gnu"
ARCH_MAPPING["bcm27xx-bcm2712"]="aarch64-rpi3-linux-gnu"
ARCH_MAPPING["mediatek-filogic"]="aarch64-rpi3-linux-gnu"

# 32位 MIPS Little Endian (MediaTek MT7621/MT7620)
ARCH_MAPPING["ramips-mt7621"]="mipsel-unknown-linux-uclibc"
ARCH_MAPPING["ramips-mt7620"]="mipsel-unknown-linux-uclibc"

# 32位 MIPS Big Endian (Atheros AR71xx/AR9xxx)
ARCH_MAPPING["ath79-generic"]="mips-unknown-linux-uclibc"

# 64位 x86 (软路由)
ARCH_MAPPING["x86-64"]="x86_64-ubuntu12.04-linux-gnu"

# 复制二进制文件
for openwrt_arch in "${!ARCH_MAPPING[@]}"; do
    phtunnel_arch="${ARCH_MAPPING[$openwrt_arch]}"
    
    source_file="$SOURCE_DIR/$phtunnel_arch/phtunnel"
    target_dir="$TARGET_DIR/$openwrt_arch"
    target_file="$target_dir/phtunnel"
    
    if [ ! -f "$source_file" ]; then
        echo -e "${RED}错误：找不到源文件 $source_file${NC}"
        exit 1
    fi
    
    mkdir -p "$target_dir"
    cp "$source_file" "$target_file"
    chmod +x "$target_file"
    
    # 显示二进制文件信息
    file_info=$(file "$target_file")
    size=$(ls -lh "$target_file" | awk '{print $5}')
    
    echo -e "${GREEN}✓${NC} $openwrt_arch <- $phtunnel_arch ($size)"
    echo -e "  ${YELLOW}架构信息：$file_info${NC}"
done

# 创建架构映射文件
cat > "$TARGET_DIR/ARCH_MAPPING.txt" << 'EOF'
# OpenWrt 架构与 phtunnel 二进制文件的映射

qualcommax-ipq807x  -> aarch64-rpi3-linux-gnu    # WiFi 6/7 路由器（小米 AX3600/AX9000 等）
bcm27xx-bcm2712     -> aarch64-rpi3-linux-gnu    # 树莓派 5
mediatek-filogic    -> aarch64-rpi3-linux-gnu    # 红米 AX6000、TP-Link XDR6088 等

ramips-mt7621       -> mipsel-unknown-linux-uclibc  # 斐讯 K3、小米路由器 4A 等
ramips-mt7620       -> mipsel-unknown-linux-uclibc  # 小米路由器 4C

ath79-generic       -> mips-unknown-linux-uclibc    # TP-Link WR842N、NanoStation 等

x86-64              -> x86_64-ubuntu12.04-linux-gnu # 通用 x86 路由器、软路由
EOF

echo -e "${GREEN}二进制文件准备完成！${NC}"
echo -e "${YELLOW}二进制文件位置：$TARGET_DIR${NC}"
echo -e "${YELLOW}架构映射文件：$TARGET_DIR/ARCH_MAPPING.txt${NC}"

# 列出所有准备好的二进制文件
echo -e "\n${GREEN}准备好的二进制文件：${NC}"
for dir in "$TARGET_DIR"/*; do
    if [ -d "$dir" ]; then
        arch=$(basename "$dir")
        size=$(ls -lh "$dir/phtunnel" | awk '{print $5}')
        echo -e "  ${GREEN}✓${NC} $arch ($size)"
    fi
done
