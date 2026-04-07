#!/bin/bash
set -e

echo "=========================================="
echo "OpenWrt Architecture Detection Script"
echo "=========================================="
echo ""

if [ -f /etc/openwrt_release ]; then
    echo "Detecting architecture from OpenWrt..."
    
    if grep -q "DISTRIB_ARCH=" /etc/openwrt_release; then
        DISTRIB_ARCH=$(grep "DISTRIB_ARCH=" /etc/openwrt_release | cut -d"'" -f2)
        echo "Detected architecture: $DISTRIB_ARCH"
        
        case "$DISTRIB_ARCH" in
            x86_64)
                echo "Package architecture: x86_64"
                echo "Download: phtunnel_1.0.0-3_x86_64.apk"
                ;;
            aarch64_cortex-a53)
                echo "Package architecture: aarch64_cortex-a53"
                echo "Download: phtunnel_1.0.0-3_aarch64_cortex-a53.apk"
                ;;
            aarch64_generic)
                echo "Package architecture: aarch64_generic"
                echo "Download: phtunnel_1.0.0-3_aarch64_generic.apk"
                ;;
            arm_cortex-a7*)
                echo "Package architecture: arm_cortex-a7"
                echo "Download: phtunnel_1.0.0-3_arm_cortex-a7.apk"
                ;;
            arm_cortex-a9*)
                echo "Package architecture: arm_cortex-a9"
                echo "Download: phtunnel_1.0.0-3_arm_cortex-a9.apk"
                ;;
            mips_24kc*)
                echo "Package architecture: mips_24kc"
                echo "Download: phtunnel_1.0.0-3_mips_24kc.apk"
                ;;
            mipsel_24kc*)
                echo "Package architecture: mipsel_24kc"
                echo "Download: phtunnel_1.0.0-3_mipsel_24kc.apk"
                ;;
            *)
                echo "Unknown architecture: $DISTRIB_ARCH"
                echo "Please contact support for assistance."
                exit 1
                ;;
        esac
    else
        echo "Could not detect architecture from /etc/openwrt_release"
        exit 1
    fi
else
    echo "Error: /etc/openwrt_release not found"
    echo "This script must be run on an OpenWrt device"
    exit 1
fi

echo ""
echo "=========================================="
echo "Installation Commands"
echo "=========================================="
echo ""
echo "1. Download the appropriate APK package from:"
echo "   https://github.com/sdpong/phtunnel1/releases"
echo ""
echo "2. Upload to your router:"
echo "   scp phtunnel_*.apk luci-app-phtunnel_*.apk root@<router-ip>:/tmp/"
echo ""
echo "3. SSH into your router and install:"
echo "   ssh root@<router-ip>"
echo "   cd /tmp"
echo "   apk add phtunnel_*.apk luci-app-phtunnel_*.apk"
echo ""
