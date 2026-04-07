#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${OUTPUT_DIR:-$SCRIPT_DIR/../release}"

echo "=========================================="
echo "PHTunnel Package Verification Script"
echo "=========================================="
echo ""

if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Error: Output directory not found: $OUTPUT_DIR"
    exit 1
fi

cd "$OUTPUT_DIR"

total_errors=0

check_apk_package() {
    local pkg="$1"
    local errors=0
    
    echo "Checking: $pkg"
    
    if [ ! -f "$pkg" ]; then
        echo "  ❌ File does not exist"
        return 1
    fi
    
    local size=$(stat -c%s "$pkg" 2>/dev/null || stat -f%z "$pkg")
    
    if [ "$size" -lt 1000 ]; then
        echo "  ❌ Package is too small ($size bytes)"
        errors=$((errors + 1))
    fi
    
    if ! tar -tzf "$pkg" > /dev/null 2>&1; then
        echo "  ❌ Invalid tar.gz format"
        errors=$((errors + 1))
    fi
    
    if ! tar -xzf "$pkg" .PKGINFO -O 2>/dev/null | grep -q "pkgname"; then
        echo "  ⚠️  Missing or invalid .PKGINFO file"
        errors=$((errors + 1))
    fi
    
    if [ $errors -eq 0 ]; then
        echo "  ✓ Package is valid"
    fi
    
    return $errors
}

check_ipk_package() {
    local pkg="$1"
    local errors=0
    
    echo "Checking: $pkg"
    
    if [ ! -f "$pkg" ]; then
        echo "  ❌ File does not exist"
        return 1
    fi
    
    local size=$(stat -c%s "$pkg" 2>/dev/null || stat -f%z "$pkg")
    
    if [ "$size" -lt 1000 ]; then
        echo "  ❌ Package is too small ($size bytes)"
        errors=$((errors + 1))
    fi
    
    if ! tar -tzf "$pkg" > /dev/null 2>&1; then
        echo "  ❌ Invalid tar.gz format"
        errors=$((errors + 1))
    fi
    
    if ! tar -xzf "$pkg" ./control.tar.gz -O 2>/dev/null | tar -xOzf - ./control > /dev/null 2>&1; then
        echo "  ⚠️  Missing or invalid control file"
        errors=$((errors + 1))
    fi
    
    if [ $errors -eq 0 ]; then
        echo "  ✓ Package is valid"
    fi
    
    return $errors
}

echo "Found packages:"
echo ""

for pkg in *.apk *.ipk 2>/dev/null; do
    [ -f "$pkg" ] || continue
    
    case "$pkg" in
        *.apk)
            check_apk_package "$pkg" || total_errors=$((total_errors + 1))
            ;;
        *.ipk)
            check_ipk_package "$pkg" || total_errors=$((total_errors + 1))
            ;;
    esac
    echo ""
done

echo "=========================================="
echo "Verification Summary"
echo "=========================================="

if [ $total_errors -eq 0 ]; then
    echo "✓ All packages verified successfully!"
    exit 0
else
    echo "❌ Found $total_errors error(s)"
    exit 1
fi
