#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="${VERSION:-1.0.0-7}"
BUILD_DIR="${BUILD_DIR:-./phtunnel_binary}"

# Architecture to download binary for
# Options: x86_64, aarch64_cortex-a53, arm_cortex-a7, etc.
ARCH="${1:-x86_64}"

show_usage() {
    cat << USAGE
Usage: $0 [OPTIONS]

Options:
  -a, --arch ARCH   Architecture to download binary for (default: x86_64)
  -v, --version VER Set package version (default: 1.0.0-7)
  -d, --dir DIR      Output directory (default: ./phtunnel_binary)
  -b, --binary DIR   Binary directory (default: auto)
  -h, --help         Show this help

Available architectures:
  x86_64              - Generic x86_64 routers
  aarch64_cortex-a53     - ARM 64-bit, Cortex-A53 (树莓派 4)
  aarch64_generic       - ARM 64-bit, Generic
  arm_cortex-a7          - ARM 32-bit, Cortex-A7 (树莓派 2/3)
  arm_cortex-a9          - ARM 32-bit, Cortex-A9
  ramips_mt7621         - MediaTek MT7621 (斐讯 K3, 小米路由器 4A)
  ramips_mt7620         - MediaTek MT7620/MT7628 (小米路由器 4C)
  ath79_generic        - Atheros AR71xx/AR9xxx
  bcm27xx_bcm2712        - Broadcom BCM2712 (树莓派 5)
  mediatek_filogic       - MediaTek Filogic MT7986 (红米 AX6000)
  qualcommax_ipq807x     - Qualcomm IPQ807x (小米 AX3600/AX9000, 华硕 RT-AX89X 等)

Examples:
  $0
  $0 -a qualcommax_ipq807x
  $0 -v 1.1.0-0
  $0 -d ./my_binaries

USAGE
}

download_binary() {
    local arch="$1"
    
    case "$arch" in
        x86_64)
            URL="https://mirrors.oray.com/orayos/packages/phtunnel/${VERSION}/bin/phtunnel"
            ;;
        aarch64_cortex-a53)
            URL="https://mirrors.oray.com/orayos/packages/phtunnel/${VERSION}/bin/aarch64_cortex-a53/phtunnel"
            ;;
        aarch64_generic)
            URL="https://mirrors.oray.com/orayos/packages/phtunnel/${VERSION}/bin/aarch64_generic/phtunnel"
            ;;
        arm_cortex-a7)
            URL="https://mirrors.oray.com/orayos/packages/phtunnel/${VERSION}/bin/arm_cortex-a7/phtunnel"
            ;;
        arm_cortex-a9)
            URL="https://mirrors.oray.com/orayos/packages/phtunnel/${VERSION}/bin/arm_cortex-a9/phtunnel"
            ;;
        ramips_mt7621)
            URL="https://mirrors.oray.com/orayos/packages/phtunnel/${VERSION}/bin/ramips_mt7621/phtunnel"
            ;;
        ramips_mt7620)
            URL="https://mirrors.oray.com/orayos/packages/phtunnel/${VERSION}/bin/ramips_mt7620/phtunnel"
            ;;
        ath79_generic)
            URL="https://mirrors.oray.com/orayos/packages/phtunnel/${VERSION}/bin/ath79_generic/phtunnel"
            ;;
        bcm27xx_bcm2712)
            URL="https://mirrors.oray.com/orayos/packages/phtunnel/${VERSION}/bin/bcm27xx_bcm2712/phtunnel"
            ;;
        mediatek_filogic)
            URL="https://mirrors.oray.com/orayos/packages/phtunnel/${VERSION}/bin/mediatek_filogic/phtunnel"
            ;;
        qualcommax_ipq807x)
            URL="https://mirrors.oray.com/orayos/packages/phtunnel/${VERSION}/bin/qualcommax_ipq807x/phtunnel"
            ;;
        *)
            echo "Unknown architecture: $arch"
            return 1
            ;;
    esac
    
    echo "Downloading phtunnel binary for $arch from:"
    echo "$URL"
    
    mkdir -p "$(BUILD_DIR)/$arch"
    
    if curl -fL "$URL" -o "$(BUILD_DIR)/$arch/phtunnel"; then
        echo "✓ Successfully downloaded phtunnel binary"
        ls -lh "$(BUILD_DIR)/$arch/phtunnel"
    else
        echo "✗ Failed to download phtunnel binary"
        return 1
    fi
}

create_ipk_package() {
    local arch="$1"
    local arch_name
    
    case "$arch" in
        x86_64)
            ARCH_NAME="x86-64"
            ;;
        aarch64_cortex-a53)
            ARCH_NAME="aarch64_cortex-a53"
            ;;
        aarch64_generic)
            ARCH_NAME="aarch64_generic"
            ;;
        arm_cortex-a7)
            ARCH_NAME="arm_cortex-a7"
            ;;
        arm_cortex-a9)
            ARCH_NAME="arm_cortex-a9"
            ;;
        ramips_mt7621)
            ARCH_NAME="ramips_mt7621"
            ;;
        ramips_mt7620)
            ARCH_NAME="ramips_mt7620"
            ;;
        ath79_generic)
            ARCH_NAME="ath79_generic"
            ;;
        bcm27xx_bcm2712)
            ARCH_NAME="bcm27xx_bcm2712"
            ;;
        mediatek_filogic)
            ARCH_NAME="mediatek_filogic"
            ;;
        qualcommax_ipq807x)
            ARCH_NAME="qualcommax_ipq807x"
            ;;
        *)
            echo "Unknown architecture: $arch"
            return 1
            ;;
    esac
    
    echo "Creating IPK package for $ARCH_NAME"
    
    PKG_DIR="$(BUILD_DIR)/${ARCH_NAME}-ipk"
    mkdir -p "$PKG_DIR"
    
    echo "Creating control file..."
    cat > "$PKG_DIR/CONTROL" << EOFCTRL
Package: phtunnel
Version: $VERSION
Architecture: $ARCH_NAME
Installed-Size: 12345678
Maintainer: Oray <developer@oray.com>
License: Proprietary

Section: net
Category: Network
Tags: web servers, proxy, intranet penetration, vpn
Priority: optional

Depends: libc, libpthread, librt
Description: PHTunnel is core component of HSK intranet penetration, which can easily implement high-performance
 reverse proxy applications, supports TCP, HTTP, HTTPS protocols, end-to-end TLS encrypted
endef
    
    mkdir -p "$PKG_DIR/CONTROL"
    cp "$PKG_DIR/CONTROL" "$PKG_DIR/CONTROL"
    
    mkdir -p "$PKG_DIR/etc/init.d"
    cat > "$PKG_DIR/etc/init.d/phtunnel" << 'EOFINIT'
#!/bin/sh
START=99
STOP=15

USE_PROCD=1

START=95

boot()
{
    procd_open_instance $NAME
}

shutdown() {
    procd_close_instance
}

reload_service() {
    echo "Reloading phtunnel..."
    procd_send_signal "$NAME" "$@"
    procd_start
}

start_service() {
    start_service
}

stop_service() {
    stop_service
}

restart() {
    stop_service
    sleep 3
    start_service
}
EOFINIT
chmod +x "$PKG_DIR/etc/init.d/phtunnel"
    
    mkdir -p "$PKG_DIR/etc/config"
    cat > "$PKG_DIR/etc/config/phtunnel" << 'EOFCONFIG'
config phtunnel
    option enabled '0'

config base
    option log_level 'info'
    option log_file '/var/log/oraybox/phtunnel.log'
    option log_level 'info'

config network
    option server '192.168.1.1'
    option port '80'
option protocol 'tcp'

config advanced
    option keepalive '0'
    
EOF
    
    mkdir -p "$PKG_DIR/var/log/oraybox"
    touch "$PKG_DIR/var/log/oraybox/phtunnel.log"
    
    mkdir -p "$PKG_DIR/usr/sbin"
    cp "$(BUILD_DIR)/$arch/phtunnel" "$PKG_DIR/usr/sbin/phtunnel"
    chmod +x "$PKG_DIR/usr/sbin/phtunnel"
    
    mkdir -p "$PKG_DIR/etc/hotplug.d/iface"
    cat > "$PKG_DIR/etc/hotplug.d/iface/30-oray-phtunnel" << 'HOTPLUG'
#!/bin/sh

. /usr/sbin/phtunnel &

[ "$ACTION" == "ifup" ] && \
    /etc/init.d/phtunnel start
fi
[ "$ACTION" == "ifdown" ] && \
    /etc/init.d/phtunnel stop
fi
EOFHOTPLUG
chmod +x "$PKG_DIR/etc/hotplug.d/iface/30-oray-phtunnel"
    
    mkdir -p "$PKG_DIR/lib"
    echo "PHTunnel binary from Oray" > "$PKG_DIR/lib/README"
    
    echo "Creating IPK package..."
    cd "$PKG_DIR"
    
    tar -czf "../phtunnel_${VERSION}_${ARCH_NAME}.ipk" ./
    
    cd ..
    rm -rf "$PKG_DIR"
    
    echo "Created IPK package: phtunnel_${VERSION}_${ARCH_NAME}.ipk"
    ls -lh phtunnel_${VERSION}_${ARCH_NAME}.ipk"
}

create_luci_app_ipk() {
    local arch="$1"
    local arch_name
    
    case "$arch" in
        x86_64)
            ARCH_NAME="x86-64"
            ;;
        aarch64_cortex-a53)
            ARCH_NAME="aarch64_cortex-a53"
            ;;
        aarch64_generic)
            ARCH_NAME="aarch64_generic"
            ;;
        arm_cortex-a7)
            ARCH_NAME="arm_cortex-a7"
            ;;
        arm_cortex-a9)
            ARCH_NAME="arm_cortex-a9"
            ;;
        ramips_mt7621)
            ARCH_NAME="ramips_mt7621"
            ;;
        ramips_mt7620)
            ARCH_NAME="ramips_mt7620"
            ;;
        ath79_generic)
            ARCH_NAME="ath79_generic"
            ;;
        bcm27xx_bcm2712)
            ARCH_NAME="bcm27xx_bcm2712"
            ;;
        mediatek_filogic)
            ARCH_NAME="mediatek_filogic"
            ;;
        qualcommax_ipq807x)
            ARCH_NAME="qualcommax_ipq807x"
            ;;
        *)
            echo "Unknown architecture: $arch"
            return 1
            ;;
    esac
    
    echo "Creating LuCI app IPK package for $ARCH_NAME"
    
    PKG_DIR="$(BUILD_DIR)/luci-app-phtunnel-${ARCH_NAME}-ipk"
    mkdir -p "$PKG_DIR"
    
    echo "Creating control file..."
    cat > "$PKG_DIR/CONTROL" << EOFCTRL
Package: luci-app-phtunnel
Version: $VERSION
Architecture: $ARCH_NAME
Installed-Size: 789012
Maintainer: Oray <developer@oray.com>
License: GPL-2.0-only

Section: luci
Category: LuCI
Tags: web servers, proxy, intranet penetration, vpn
Priority: optional

Depends: luci-app-phtunnel, luci-lib-jsonc, cgi-io
Description: LuCI interface for PHTunnel (HSK intranet penetration).
This package provides a web interface for managing PHTunnel configuration and status.
endef
    
    mkdir -p "$PKG_DIR/CONTROL"
    chmod 644 "$PKG_DIR/CONTROL"
    
    mkdir -p "$PKG_DIR/usr/lib/lua/luci/controller/oray"
    cat > "$PKG_DIR/usr/lib/lua/luci/controller/oray/phtunnel.lua" << 'EOFCTRL'
module("luci.controller.phtunnel", package.seeall)

function index()
    if not nixio.access() then
        return false
    end
    
    luci.template.render("phtunnel/index.htm")
end

function status()
    local http = luci.http
    local uci = require "luci.model.phtunnel"
    
    -- PHTunnel Status
    local enabled = uci:get_first('base.enabled')
    local status = "unknown"
    
    if enabled == '1' then
        status = "running"
    else
        status = "stopped"
    end
    
    http.prepare("application/json")
    
    http.json.write({
        enabled = (enabled == '1'),
        status = status,
        version = "$VERSION",
        platform = _VERSION.os or "unknown"
    })
end

function download_binary()
    local http = luci.http
    local download_url = "https://mirrors.oray.com/orayos/packages/"..VERSION..phtunnel"
    
    http.prepare("application/tgz")
    http.header('Content-Type', 'application/tar.gz')
    
    local file = io.open("/tmp/phtunnel.tgz")
    http:redirect(download_url)
    file:close()
end
EOFCTRL
    
    mkdir -p "$PKG_DIR/usr/lib/lua/luci/view/phtunnel"
    mkdir -p "$PKG_DIR/usr/share/lua/luci/view/phtunnel"
    
    cat > "$PKG_DIR/usr/share/lua/luci/view/phtunnel/status.htm" << 'EOF'
<% if luci.http.requesthandler("phtunnel/status") %>
-- HTTP request handler for phtunnel/status
local http = luci.http

function PHTunnel Status
    local uci = require "luci.model.phtunnel"
    
    local enabled = uci:get_first('base.enabled')
    local log_file = uci:get_first('base.log_file') or '/var/log/oraybox/phtunnel.log'
    
    local status
    if enabled == '1' then
        status = 'running'
    else
        status = 'stopped'
    end
    
    http.prepare("application/json")
    http.json.write({
        enabled = (enabled == '1'),
        status = status,
        log_file = log_file
    })
end
EOFCTRL
    
    cat > "$PKG_DIR/usr/share/lua/luci/view/phtunnel/log.htm" << 'EOFCTRL'
<% if luci.http.requesthandler("phtunnel/log") %>
-- HTTP request handler for phtunnel/log

local http = luci.http

function PHTunnel Log
    local uci = require("luci.model.phtunnel")

local log_file = uci:get_first('base.log_file') or '/var/log/oraybox/phtunnel.log'

if nixio.access(luci.http.getenv('log_file')) then
    local file = luci.http.getenv('log_file')
    if nixio.stat(file) then
        local f = io.open(file)
        local log_content = f:read("*a")
        luci.http.prepare("text/plain")
        http.header("Content-Type", "application/octet-stream")
        http.write(log_content)
    else
        luci.http.write("404 Not Found")
    end
end
EOFCTRL
    
    mkdir -p "$PKG_DIR/usr/share/rpcd/acl.d"
    cat > "$PKG_DIR/usr/share/rpcd/acl.d/luci-app-phtunnel.json" << 'EOFCTRL'
{
    "description": "PHTunnel ACL",
    "owner": "root",
    "access": [
        {
            "name": "luci-app-phtunnel",
            "description": "PHTunnel management",
            "access": "all"
        }
    ]
}
EOFCTRL
    
    cat > "$PKG_DIR/usr/share/rpcd/acl.d/.gitkeep" << 'EOF'
This directory keeps git from creating empty .keep files
EOF
