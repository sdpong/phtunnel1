#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${OUTPUT_DIR:-$SCRIPT_DIR/../release}"
SUMMARY_FILE="${SUMMARY_FILE:-$OUTPUT_DIR/build-summary.md}"

echo "=========================================="
echo "Build Summary Generator"
echo "=========================================="
echo ""

if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Error: Output directory not found: $OUTPUT_DIR"
    exit 1
fi

cd "$OUTPUT_DIR"

cat > "$SUMMARY_FILE" << 'HEADER'
# PHTunnel Build Summary

Build Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')

## Package Statistics

HEADER

total_size=0
total_count=0

echo "| Architecture | Package Name | Size (MB) | Format |" >> "$SUMMARY_FILE"
echo "|--------------|--------------|-----------|--------|" >> "$SUMMARY_FILE"

find . -type f \( -name "*.apk" -o -name "*.ipk" \) -print0 | sort -z | while IFS= read -r -d '' pkg; do
    filename=$(basename "$pkg")
    arch=$(echo "$filename" | grep -oE '(x86_64|aarch64_cortex-a53|aarch64_generic|arm_cortex-a[79]|mipsel?_24kc|all)' || echo "unknown")
    
    size_bytes=$(stat -c%s "$pkg" 2>/dev/null || stat -f%z "$pkg")
    size_mb=$(awk "BEGIN {printf \"%.2f\", $size_bytes / 1048576}")
    
    format=$(echo "$filename" | grep -oE '\.(apk|ipk)' | tr -d '.')
    
    echo "| $arch | \`$filename\` | $size_mb | $format |" >> "$SUMMARY_FILE"
    
    total_count=$((total_count + 1))
    total_size=$((total_size + size_bytes))
done

total_size_mb=$(awk "BEGIN {printf \"%.2f\", $total_size / 1048576}")

cat >> "$SUMMARY_FILE" << MIDDLE

## Summary

- **Total Packages:** $total_count
- **Total Size:** $total_size_mb MB

## Installation Instructions

### For OpenWrt 25.12.x (APK format)

```bash
# 1. Upload packages to your router
scp phtunnel_*.apk luci-app-phtunnel_*.apk root@<router-ip>:/tmp/

# 2. SSH into your router
ssh root@<router-ip>

# 3. Install packages
cd /tmp
apk add phtunnel_*.apk luci-app-phtunnel_*.apk

# 4. Enable and start the service
/etc/init.d/phtunnel enable
/etc/init.d/phtunnel start
```

### For OpenWrt 25.11.x and earlier (IPK format)

```bash
# 1. Upload packages to your router
scp phtunnel_*.ipk luci-app-phtunnel_*.ipk root@<router-ip>:/tmp/

# 2. SSH into your router
ssh root@<router-ip>

# 3. Install packages
cd /tmp
opkg install phtunnel_*.ipk luci-app-phtunnel_*.ipk

# 4. Enable and start the service
/etc/init.d/phtunnel enable
/etc/init.d/phtunnel start
```

## Configuration

After installation:

1. Access LuCI: `http://<router-ip>/cgi-bin/luci`
2. Go to **Services → PHTunnel**
3. Enable the service
4. Configure as needed

## Troubleshooting

### Check service status

```bash
/etc/init.d/phtunnel status
```

### View logs

```bash
cat /var/log/oraybox/phtunnel.log
```

### Restart service

```bash
/etc/init.d/phtunnel restart
```

## Supported Architectures

| Architecture | Description | Example Devices |
|--------------|-------------|-----------------|
| x86_64 | Intel/AMD 64-bit | PC, Server, VM |
| aarch64_cortex-a53 | ARM 64-bit, Cortex-A53 | Raspberry Pi 4, Rockchip |
| aarch64_generic | ARM 64-bit, Generic | Other ARM64 devices |
| arm_cortex-a7 | ARM 32-bit, Cortex-A7 | Raspberry Pi 2/3, Orange Pi |
| arm_cortex-a9 | ARM 32-bit, Cortex-A9 | Older routers |
| mips_24kc | MIPS 32-bit, 24KC | MT7620/MT7628 routers |
| mipsel_24kc | MIPSel 32-bit, 24KC | MT7620/MT7621 routers |

## Version Information

- **Package Version:** 1.0.0-3
- **OpenWrt Version:** 25.12.x
- **Package Format:** APK

---

Generated on: $(date)
MIDDLE

echo "Summary generated: $SUMMARY_FILE"
echo ""
echo "Summary contents:"
head -20 "$SUMMARY_FILE"
