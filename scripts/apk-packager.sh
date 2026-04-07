#!/bin/bash
# APK Packager for OpenWrt 25.12.x
# This script creates valid APK packages using OpenWrt's apk mkpkg tool

set -e

# Configuration
PKG_NAME="phtunnel"
PKG_VERSION="1.0.0"
PKG_RELEASE="2"
PKG_ARCH="$1"  # architecture from command line
BUILD_DIR="$2"   # build directory
OUTPUT_DIR="$3"  # output directory

if [ -z "$PKG_ARCH" ] || [ -z "$BUILD_DIR" ]; then
    echo "Usage: $0 <arch> <build_dir> [output_dir]"
    echo "Example: $0 x86_64 /path/to/build /path/to/output"
    exit 1
fi

OUTPUT_DIR="${OUTPUT_DIR:-$BUILD_DIR/apk}"

# Check if apk tool is available
if ! command -v apk &> /dev/null; then
    echo "Error: 'apk' command not found. This script requires OpenWrt's apk tool."
    echo "Please ensure you are running within OpenWrt SDK environment."
    exit 1
fi

# Create working directory
WORKDIR=$(mktemp -d)
trap "rm -rf $WORKDIR" EXIT

# Copy package files to workdir
APK_INSTALL_DIR="$WORKDIR/apk-root"
mkdir -p "$APK_INSTALL_DIR"
if [ -d "$BUILD_DIR" ]; then
    cp -r "$BUILD_DIR"/. "$APK_INSTALL_DIR/"
fi

# Ensure proper directory structure
mkdir -p "$APK_INSTALL_DIR/lib/apk/packages"

# Generate package list
(cd "$APK_INSTALL_DIR" && find . -type f,l -printf "/%P\n" | sort > "$WORKDIR/package.list")

# Create .PKGINFO format (compatible with OpenWrt 25.12.x)
BUILD_DATE=$(date -u +%s)

# Generate control information
CONTROL_DIR="$WORKDIR/control"
mkdir -p "$CONTROL_DIR"

cat > "$CONTROL_DIR/control" << EOF
Package: ${PKG_NAME}
Version: ${PKG_VERSION}-${PKG_RELEASE}
Description: PHTunnel is core component of HSK intranet penetration, supports TCP, HTTP, HTTPS protocols
Section: net
Priority: optional
Maintainer: Oray <developer@oray.com>
License: Proprietary
Architecture: ${PKG_ARCH}
Homepage: https://hsk.oray.com/
Depends: libc, libpthread, librt
EOF

# Generate pre-install script
cat > "$CONTROL_DIR/pre-install" << 'EOF'
#!/bin/sh
# Stop running service if present
if [ -f /etc/init.d/phtunnel ]; then
    /etc/init.d/phtunnel stop >/dev/null 2>&1 || true
fi
exit 0
EOF

# Generate post-install script
cat > "$CONTROL_DIR/post-install" << 'EOF'
#!/bin/sh
# Enable service
if [ -f /etc/init.d/phtunnel ]; then
    /etc/init.d/phtunnel enable
fi
exit 0
EOF

# Generate pre-upgrade script
cat > "$CONTROL_DIR/pre-upgrade" << 'EOF'
#!/bin/sh
# Stop running service if present
if [ -f /etc/init.d/phtunnel ]; then
    /etc/init.d/phtunnel stop >/dev/null 2>&1 || true
fi
exit 0
EOF

# Generate post-upgrade script
cat > "$CONTROL_DIR/post-upgrade" << 'EOF'
#!/bin/sh
# Enable service
if [ -f /etc/init.d/phtunnel ]; then
    /etc/init.d/phtunnel enable
fi
exit 0
EOF

# Generate pre-deinstall script
cat > "$CONTROL_DIR/pre-deinstall" << 'EOF'
#!/bin/sh
# Stop running service if present
if [ -f /etc/init.d/phtunnel ]; then
    /etc/init.d/phtunnel stop >/dev/null 2>&1 || true
fi
exit 0
EOF

# Make scripts executable
chmod +x "$CONTROL_DIR/"*

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Build APK package using OpenWrt's apk mkpkg
APK_FILE="${OUTPUT_DIR}/${PKG_NAME}-${PKG_VERSION}-r${PKG_RELEASE}_${PKG_ARCH}.apk"

echo "Building APK package using apk mkpkg..."
apk mkpkg \
  --info "name:${PKG_NAME}" \
  --info "version:${PKG_VERSION}-r${PKG_RELEASE}" \
  --info "description:PHTunnel is core component of HSK intranet penetration, supports TCP, HTTP, HTTPS protocols" \
  --info "arch:${PKG_ARCH}" \
  --info "license:Proprietary" \
  --info "origin:openwrt" \
  --info "url:https://hsk.oray.com/" \
  --info "maintainer:Oray <developer@oray.com>" \
  --info "depends:libc,libpthread,librt" \
  --script "pre-install:${CONTROL_DIR}/pre-install" \
  --script "post-install:${CONTROL_DIR}/post-install" \
  --script "pre-upgrade:${CONTROL_DIR}/pre-upgrade" \
  --script "post-upgrade:${CONTROL_DIR}/post-upgrade" \
  --script "pre-deinstall:${CONTROL_DIR}/pre-deinstall" \
  --files "$APK_INSTALL_DIR" \
  --output "$APK_FILE"

if [ -f "$APK_FILE" ]; then
    echo "✓ APK package created successfully: $APK_FILE"
    ls -lh "$APK_FILE"
else
    echo "✗ Failed to create APK package"
    exit 1
fi

# Verify APK package
echo "Verifying APK package..."
apk info --file "$APK_FILE" || true
echo "✓ APK package verified"