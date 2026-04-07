#!/bin/bash
set -e

PKG_NAME="${PKG_NAME:-phtunnel}"
PKG_VERSION="${PKG_VERSION:-1.0.0}"
PKG_RELEASE="${PKG_RELEASE:-3}"
PKG_ARCH="${PKG_ARCH}"
PKG_DESC="${PKG_DESC:-PHTunnel is core component of HSK intranet penetration}"
PKG_URL="${PKG_URL:-https://hsk.oray.com/}"
PKG_MAINTAINER="${PKG_MAINTAINER:-Oray <developer@oray.com>}"
PKG_LICENSE="${PKG_LICENSE:-Proprietary}"
BUILD_DIR="${BUILD_DIR:-.}"
OUTPUT_DIR="${OUTPUT_DIR:-./apk}"

if [ -z "$PKG_ARCH" ]; then
    echo "Error: PKG_ARCH is required"
    echo "Usage: PKG_ARCH=<arch> $0 [build_dir] [output_dir]"
    exit 1
fi

WORKDIR=$(mktemp -d)
trap "rm -rf $WORKDIR" EXIT

APK_ROOT="$WORKDIR/apk-root"
mkdir -p "$APK_ROOT"

if [ -d "$BUILD_DIR" ]; then
    cp -r "$BUILD_DIR"/. "$APK_ROOT/"
fi

PKG_SIZE=$(du -sb "$APK_ROOT" 2>/dev/null | cut -f1 || echo "0")
BUILD_DATE=$(date -u +%Y%m%d%H%M%S)

cat > "$WORKDIR/.PKGINFO" << EOF
pkgname = $PKG_NAME
pkgver = ${PKG_VERSION}-r${PKG_RELEASE}
pkgdesc = $PKG_DESC
url = $PKG_URL
builddate = $BUILD_DATE
packager = OpenWrt Build System
size = $PKG_SIZE
arch = $PKG_ARCH
license = $PKG_LICENSE
maintainer = $PKG_MAINTAINER
origin = openwrt
EOF

cat > "$WORKDIR/.pre-install" << 'EOF'
#!/bin/sh
if [ -x /etc/init.d/phtunnel ]; then
    /etc/init.d/phtunnel stop 2>/dev/null || true
fi
exit 0
EOF

cat > "$WORKDIR/.post-install" << 'EOF'
#!/bin/sh
if [ -x /etc/init.d/phtunnel ]; then
    /etc/init.d/phtunnel enable 2>/dev/null || true
fi
exit 0
EOF

chmod +x "$WORKDIR/.pre-install" "$WORKDIR/.post-install"

APK_FILENAME="${PKG_NAME}_${PKG_VERSION}-r${PKG_RELEASE}_${PKG_ARCH}.apk"
PKG_DIR="$WORKDIR/${APK_FILENAME%.apk}"

mkdir -p "$PKG_DIR"
mv "$WORKDIR/.PKGINFO" "$PKG_DIR/.PKGINFO"
mv "$WORKDIR/.pre-install" "$PKG_DIR/.pre-install"
mv "$WORKDIR/.post-install" "$PKG_DIR/.post-install"
cp -r "$APK_ROOT"/* "$PKG_DIR/"

mkdir -p "$OUTPUT_DIR"
cd "$WORKDIR"
tar -czf "$OUTPUT_DIR/$APK_FILENAME" "$PKG_DIR"

echo "APK package created: $OUTPUT_DIR/$APK_FILENAME"
ls -lh "$OUTPUT_DIR/$APK_FILENAME"
