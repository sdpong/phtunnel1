#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/../version"

show_usage() {
    cat << USAGE
Usage: $0 [COMMAND] [OPTIONS]

Commands:
  get           Get current version
  set <VERSION> Set version
  bump [type]   Bump version (major, minor, or patch, default: patch)
  tag           Create git tag for current version

Options:
  -h, --help    Show this help message

Examples:
  $0 get                    # Get current version
  $0 set 1.1.0             # Set version to 1.1.0
  $0 bump patch             # Bump patch version (1.0.0 -> 1.0.1)
  $0 bump minor             # Bump minor version (1.0.0 -> 1.1.0)
  $0 bump major             # Bump major version (1.0.0 -> 2.0.0)
  $0 tag                    # Create git tag v1.0.0-3

USAGE
}

get_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "1.0.0-3"
    fi
}

set_version() {
    local version="$1"
    
    if ! echo "$version" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+-[0-9]+$'; then
        echo "Error: Invalid version format. Expected: X.Y.Z-N"
        exit 1
    fi
    
    echo "$version" > "$VERSION_FILE"
    echo "Version set to: $version"
}

bump_version() {
    local bump_type="${1:-patch}"
    local version=$(get_version)
    local major minor patch release
    
    IFS='.-' read -r major minor patch release <<< "$version"
    
    case "$bump_type" in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            release=1
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            release=1
            ;;
        patch)
            patch=$((patch + 1))
            release=$((release + 1))
            ;;
        *)
            echo "Error: Unknown bump type: $bump_type"
            echo "Valid types: major, minor, patch"
            exit 1
            ;;
    esac
    
    local new_version="${major}.${minor}.${patch}-${release}"
    set_version "$new_version"
}

create_tag() {
    local version=$(get_version)
    local tag="v${version}"
    
    if git rev-parse "$tag" >/dev/null 2>&1; then
        echo "Error: Tag $tag already exists"
        exit 1
    fi
    
    echo "Creating git tag: $tag"
    git tag -a "$tag" -m "Release version $version"
    echo "Tag created: $tag"
    echo ""
    echo "To push the tag:"
    echo "  git push origin $tag"
}

case "${1:-}" in
    get)
        get_version
        ;;
    set)
        if [ -z "$2" ]; then
            echo "Error: Version argument required"
            show_usage
            exit 1
        fi
        set_version "$2"
        ;;
    bump)
        bump_version "${2:-patch}"
        ;;
    tag)
        create_tag
        ;;
    ""|"-h"|"--help")
        show_usage
        ;;
    *)
        echo "Error: Unknown command: $1"
        show_usage
        exit 1
        ;;
esac
