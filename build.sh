#!/bin/bash
# OpenWrt 25.12.x APK 编译脚本
# 支持多种主流架构的编译

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="${SCRIPT_DIR}/build_output"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# 主流架构配置
ARCHITECTURES=(
    "qualcommax:ipq807x:aarch64"
    "x86:64:x86_64"
    "mediatek:mt7622:armv7"
    "ramips:mt7620:mipsel"
    "ath79:generic:mips"
    "rockchip:generic:aarch64"
    "bcm27xx:bcm2711:armv7"
)

# 使用方法
usage() {
    cat << EOF
用法: $0 [选项] [架构]

选项:
  -h, --help     显示此帮助信息
  -a, --all      编译所有架构
  -l, --list     列出所有支持的架构
  -c, --clean    清理编译输出

架构:
  ${ARCHITECTURES[@]}

示例:
  $0 qualcommax              # 编译 qualcommax/ipq807x 架构
  $0 x86                    # 编译 x86/64 架构
  $0 --all                  # 编译所有架构
  $0 --list                 # 列出所有架构

注意:
  - 需要 Docker 环境或 Linux 主机
  - 编译时间取决于架构和系统性能
  - 输出目录: ${WORK_DIR}

EOF
    exit 1
}

# 列出所有架构
list_architectures() {
    print_info "支持的架构:"
    echo ""
    printf "%-20s %-20s %-15s\n" "目标架构" "OpenWrt 目标" "CPU 架构"
    printf "%-20s %-20s %-15s\n" "----------" "-------------" "---------"
    for arch in "${ARCHITECTURES[@]}"; do
        IFS=':' read -r target arch_name cpu <<< "$arch"
        printf "%-20s %-20s %-15s\n" "$target" "${target}/${arch_name}" "$cpu"
    done
}

# 下载 SDK
download_sdk() {
    local target="$1"
    local arch_name="$2"

    print_info "下载 OpenWrt 25.12.2 SDK for ${target}/${arch_name}..."

    # Special case for x86 to use correct SDK filename
    if [ "$target" = "x86" ]; then
        local sdk_url="https://downloads.openwrt.org/releases/25.12.2/targets/${target}/${arch_name}/openwrt-sdk-25.12.2-x86-64_gcc-14.3.0_musl.Linux-x86_64.tar.zst"
        local sdk_file="openwrt-sdk-25.12.2-x86-64_gcc-14.3.0_musl.Linux-x86_64.tar.zst"
        local sdk_dir="openwrt-sdk-25.12.2-x86-64_gcc-14.3.0_musl.Linux-x86_64"
    else
        local sdk_url="https://downloads.openwrt.org/releases/25.12.2/targets/${target}/${arch_name}/openwrt-sdk-25.12.2-${target}-${arch_name}_gcc-14.3.0_musl.Linux-x86_64.tar.zst"
        local sdk_file="openwrt-sdk-25.12.2-${target}-${arch_name}_gcc-14.3.0_musl.Linux-x86_64.tar.zst"
        local sdk_dir="openwrt-sdk-25.12.2-${target}-${arch_name}_gcc-14.3.0_musl.Linux-x86_64"
    fi

    # 创建输出目录
    mkdir -p "${WORK_DIR}/${target}"

    # 检查 SDK 是否已下载
    if [ -d "${WORK_DIR}/${target}/${sdk_dir}" ]; then
        print_success "SDK 已存在，跳过下载"
        return 0
    fi

    # 下载 SDK
    if [ -f "${WORK_DIR}/${target}/${sdk_file}" ]; then
        print_success "SDK 文件已存在"
    else
        print_info "从 ${sdk_url} 下载..."
        cd "${WORK_DIR}/${target}"
        curl -L -o "${sdk_file}" "${sdk_url}"
    fi

    # 解压 SDK
    print_info "解压 SDK..."
    cd "${WORK_DIR}/${target}"
    tar -xf "${sdk_file}"

    print_success "SDK 解压完成"
}

# 配置和编译
compile_package() {
    local target="$1"
    local arch_name="$2"
    local cpu_arch="$3"

    # Determine SDK directory (special case for x86)
    if [ "$target" = "x86" ]; then
        local sdk_dir="${WORK_DIR}/${target}/openwrt-sdk-25.12.2-x86-64_gcc-14.3.0_musl.Linux-x86_64"
    else
        local sdk_dir="${WORK_DIR}/${target}/openwrt-sdk-25.12.2-${target}-${arch_name}_gcc-14.3.0_musl.Linux-x86_64"
    fi

    print_info "配置和编译 ${target}/${arch_name}..."

    cd "${sdk_dir}"

    # 更新 feeds
    print_info "更新 feeds..."
    ./scripts/feeds update -a
    ./scripts/feeds install -a

    # 复制项目文件
    print_info "复制项目文件..."
    cp -r "${SCRIPT_DIR}/phtunnel" package/
    cp -r "${SCRIPT_DIR}/luci-app-phtunnel" package/

    # 配置
    print_info "配置编译选项..."
    make defconfig

    # 启用 APK 格式
    echo "CONFIG_USE_APK=y" >> .config

    # 启用包编译
    echo "CONFIG_PACKAGE_phtunnel=y" >> .config
    echo "CONFIG_PACKAGE_luci-app-phtunnel=y" >> .config

    # 启用依赖
    echo "CONFIG_PACKAGE_luci-lib-jsonc=y" >> .config
    echo "CONFIG_PACKAGE_cgi-io=y" >> .config
    echo "CONFIG_PACKAGE_curl=y" >> .config

    make oldconfig

    # 编译
    print_info "编译 phtunnel 包..."
    make package/phtunnel/compile V=s

    print_info "编译 luci-app-phtunnel 包..."
    make package/luci-app-phtunnel/compile V=s

    # 查找 APK 包
    print_info "查找 APK 包..."
    find "${sdk_dir}/bin/packages" -name "*.apk" -exec cp {} "${WORK_DIR}/${target}/" \;

    print_success "编译完成: ${target}/${arch_name}"
}

# 清理输出
clean_output() {
    print_info "清理编译输出..."
    rm -rf "${WORK_DIR}"
    print_success "清理完成"
}

# 主函数
main() {
    local all_archs=false
    local specific_arch=""

    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                ;;
            -a|--all)
                all_archs=true
                shift
                ;;
            -l|--list)
                list_architectures
                exit 0
                ;;
            -c|--clean)
                clean_output
                exit 0
                ;;
            -*)
                print_error "未知选项: $1"
                usage
                ;;
            *)
                specific_arch="$1"
                shift
                ;;
        esac
    done

    # 如果没有指定架构，显示帮助
    if [ "$all_archs" = false ] && [ -z "$specific_arch" ]; then
        usage
    fi

    # 检查依赖
    if ! command -v curl &> /dev/null; then
        print_error "curl 未安装"
        exit 1
    fi

    if ! command -v tar &> /dev/null; then
        print_error "tar 未安装"
        exit 1
    fi

    # 编译指定架构或所有架构
    if [ "$all_archs" = true ]; then
        print_info "开始编译所有架构..."
        for arch in "${ARCHITECTURES[@]}"; do
            IFS=':' read -r target arch_name cpu <<< "$arch"
            # Skip rockchip as no SDK is available
            if [ "$target" = "rockchip" ]; then
                print_warning "跳过 rockchip (无可用 SDK)"
                continue
            fi
            download_sdk "$target" "$arch_name"
            compile_package "$target" "$arch_name" "$cpu"
        done
        print_success "所有架构编译完成！"
    else
        # 查找指定的架构
        local found=false
        for arch in "${ARCHITECTURES[@]}"; do
            IFS=':' read -r target arch_name cpu <<< "$arch"
            if [ "$target" = "$specific_arch" ]; then
                found=true
                download_sdk "$target" "$arch_name"
                compile_package "$target" "$arch_name" "$cpu"
                print_success "编译完成: ${target}/${arch_name}"
                break
            fi
        done

        if [ "$found" = false ]; then
            print_error "未找到架构: $specific_arch"
            list_architectures
            exit 1
        fi
    fi

    # 显示输出目录
    print_info "编译结果位置: ${WORK_DIR}"
    find "${WORK_DIR}" -name "*.apk" -exec ls -lh {} \;
}

# 执行主函数
main "$@"