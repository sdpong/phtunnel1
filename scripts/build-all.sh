#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="${VERSION:-1.0.0-3}"
RELEASE="${RELEASE:-3}"
SDK_DIR="${SDK_DIR:-./openwrt-sdk}"

ARCHS=(
    "x86_64|x86|x86-64|x86_64"
    "aarch64_cortex-a53|aarch64|cortex-a53|aarch64_cortex-a53"
    "aarch64_generic|aarch64|generic|aarch64_generic"
    "arm_cortex-a7|armvirt|cortex-a7|arm_cortex-a7_neon-vfpv4"
    "arm_cortex-a9|armvirt|cortex-a9|arm_cortex-a9"
    "mips_24kc|mips|24kc|mips_24kc"
    "mipsel_24kc|mipsel|24kc|mipsel_24kc"
)

show_usage() {
    cat << USAGE
Usage: $0 [OPTIONS]

Options:
  -a, --arch ARCH    Build specific architecture only
  -v, --version VER  Set version (default: 1.0.0-3)
  -s, --sdk DIR      OpenWrt SDK directory
  -h, --help         Show this help message

Architectures:
  x86_64, aarch64_cortex-a53, aarch64_generic,
  arm_cortex-a7, arm_cortex-a9, mips_24kc, mipsel_24kc

Examples:
  $0                          # Build all architectures
  $0 -a x86_64               # Build only x86_64
  $0 -v 1.1.0-1              # Build version 1.1.0-1
  $0 -s ./openwrt-sdk-x86_64 # Use specific SDK

USAGE
}

download_sdk() {
    local arch="$1"
    local subarch="$2"
    local sdk_subarch="$3"
    
    local sdk_name="openwrt-sdk-${arch}-${sdk_subarch}_gcc-13_musl.Linux-x86_64"
    local sdk_url="https://downloads.openwrt.org/releases/25.12.1/targets/${arch}/${subarch}/${sdk_name}.tar.xz"
    
    if [ -d "$SDK_DIR" ]; then
        echo "Using existing SDK: $SDK_DIR"
        return 0
    fi
    
    echo "Downloading SDK: $sdk_url"
    
    if curl -fL "$sdk_url" -o "${sdk_name}.tar.xz"; then
        tar -xf "${sdk_name}.tar.xz"
        mv "$sdk_name" "$SDK_DIR"
        echo "SDK downloaded and extracted"
    else
        echo "Failed to download SDK for $arch"
        return 1
    fi
}

build_package() {
    local arch_spec="$1"
    IFS='|' read -r name arch subarch sdk_subarch <<< "$arch_spec"
    
    echo "=========================================="
    echo "Building for: $name"
    echo "=========================================="
    
    local work_dir="build_${name}"
    mkdir -p "$work_dir"
    
    if ! download_sdk "$arch" "$subarch" "$sdk_subarch"; then
        echo "Skipping $name (SDK download failed)"
        return 1
    fi
    
    cd "$work_dir"
    
    cp -r "$SDK_DIR" sdk
    
    echo "Copying packages..."
    cp -r "$SCRIPT_DIR/../phtunnel" sdk/package/
    cp -r "$SCRIPT_DIR/../luci-app-phtunnel" sdk/package/
    
    echo "Configuring build..."
    cd sdk
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    
    make defconfig
    echo "CONFIG_PACKAGE_phtunnel=y" >> .config
    echo "CONFIG_PACKAGE_luci-app-phtunnel=y" >> .config
    make oldconfig
    
    echo "Building packages..."
    make package/phtunnel/compile V=s || true
    make package/luci-app-phtunnel/compile V=s || true
    
    echo "Collecting packages..."
    mkdir -p "../release"
    find bin/packages -name "*.ipk" -o -name "*.apk" | while read pkg; do
        cp "$pkg" "../release/"
    done
    
    cd "$SCRIPT_DIR"
    
    echo "✓ Build completed for $name"
    echo ""
}

main() {
    local build_archs=()
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a|--arch)
                build_archs=("$2")
                shift 2
                ;;
            -v|--version)
                VERSION="$2"
                shift 2
                ;;
            -s|--sdk)
                SDK_DIR="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    if [ ${#build_archs[@]} -eq 0 ]; then
        for arch_spec in "${ARCHS[@]}"; do
            build_package "$arch_spec" || true
        done
    else
        for arch in "${build_archs[@]}"; do
            local found=0
            for arch_spec in "${ARCHS[@]}"; do
                IFS='|' read -r name _ _ _ <<< "$arch_spec"
                if [ "$name" = "$arch" ]; then
                    build_package "$arch_spec"
                    found=1
                    break
                fi
            done
            if [ $found -eq 0 ]; then
                echo "Error: Unknown architecture: $arch"
                exit 1
            fi
        done
    fi
    
    echo "=========================================="
    echo "Build Summary"
    echo "=========================================="
    echo ""
    echo "Release directory: $SCRIPT_DIR/release"
    ls -lh "$SCRIPT_DIR/release/" || echo "No packages found"
    echo ""
    echo "To verify packages:"
    echo "  $SCRIPT_DIR/scripts/verify-packages.sh"
    echo ""
    echo "To generate build summary:"
    echo "  $SCRIPT_DIR/scripts/generate-summary.sh"
}

main "$@"
