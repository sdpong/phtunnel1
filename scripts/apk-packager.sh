#!/bin/bash
# APK Packager for OpenWrt 25.12.x
# This script creates valid APK packages from OpenWrt build output

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

# Create working directory
WORKDIR=$(mktemp -d)
trap "rm -rf $WORKDIR" EXIT

# Copy package files to workdir
APK_INSTALL_DIR="$WORKDIR/apk-root"
mkdir -p "$APK_INSTALL_DIR"
cp -r "$BUILD_DIR"/. "$APK_INSTALL_DIR/"

# Calculate package size
PKG_SIZE=$(du -sb "$APK_INSTALL_DIR" | cut -f1)
BUILD_DATE=$(date -u +%Y%m%d%H%M%S)

# Generate .PKGINFO
cat > "$WORKDIR/.PKGINFO" << EOF
pkgname = $PKG_NAME
pkgver = ${PKG_VERSION}-r${PKG_RELEASE}
pkgdesc = PHTunnel is core component of HSK intranet penetration, supports TCP, HTTP, HTTPS protocols
url = https://hsk.oray.com/
builddate = $BUILD_DATE
packager = OpenWrt Build System
size = $PKG_SIZE
arch = $PKG_ARCH
license = Proprietary
maintainer = Oray <developer@oray.com>
origin = openwrt
EOF

# Generate .pre-install script
cat > "$WORKDIR/.pre-install" << 'EOF'
#!/bin/sh
# Stop running service if present
if [ -f /etc/init.d/phtunnel ]; then
    /etc/init.d/phtunnel stop >/dev/null 2>&1 || true
fi
exit 0
EOF

# Generate .post-install script
cat > "$WORKDIR/.post-install" << 'EOF'
#!/bin/sh
# Enable service
if [ -f /etc/init.d/phtunnel ]; then
    /etc/init.d/phtunnel enable
fi
exit 0
EOF

# Make scripts executable
chmod +x "$WORKDIR/.pre-install" "$WORKDIR/.post-install"

# Create APK package (tar.gz format)
APK_FILE="${OUTPUT_DIR}/${PKG_NAME}_${PKG_VERSION}-r${PKG_RELEASE}_${PKG_ARCH}.apk"
mkdir -p "$OUTPUT_DIR"

# Create directory structure for apk
cd "$WORKDIR"
mkdir -p "$(basename "$APK_FILE" .apk)"
mv .PKGINFO "$(basename "$APK_FILE" .apk)/"
mv .pre-install "$(basename "$APK_FILE" .apk)/"
mv .post-install "$(basename "$APK_FILE" .apk)/"
cp -r apk-root/* "$(basename "$APK_FILE" .apk)/"

# Create the APK file
tar -czf "$(basename "$APK_FILE")" "$(basename "$APK_FILE" .apk)"
mv "$(basename "$APK_FILE")" "$(basename "$APK_FILE")" "$OUTPUT_DIR/"

echo "APK package created: $APK_FILE"
