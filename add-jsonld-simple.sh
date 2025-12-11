#!/bin/bash

# Simple script to add JSON-LD metadata attributes
# Adds page-author, page-image, page-product-name, and page-product-version

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# Detect branch and set product info
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "master")

case "$BRANCH" in
    manager-4.3*|*-4.3-*|*-43-*) PRODUCT_NAME="SUSE Manager"; PRODUCT_VERSION="4.3" ;;
    manager-5.0*|*-5.0-*|*-50-*) PRODUCT_NAME="SUSE Manager"; PRODUCT_VERSION="5.0" ;;
    manager-5.1*|*-5.1-*|*-51-*) PRODUCT_NAME="SUSE Multi-Linux Manager"; PRODUCT_VERSION="5.1" ;;
    *) PRODUCT_NAME="SUSE Multi-Linux Manager"; PRODUCT_VERSION="5.2" ;;
esac

print_info "Branch: $BRANCH"
print_info "Product: $PRODUCT_NAME $PRODUCT_VERSION"
echo ""

# Process each module
for module_dir in modules/*/; do
    module_name=$(basename "$module_dir")
    print_info "Processing module: $module_name"
    
    # Find all pages (excluding partials)
    find "$module_dir" -type f -name "*.adoc" -path "*/pages/*" ! -path "*/partials/*" | while read -r file; do
        # Check if file needs updating
        if grep -q "^:page-author:" "$file" && \
           grep -q "^:page-image:" "$file" && \
           grep -q "^:page-product-name:" "$file" && \
           grep -q "^:page-product-version:" "$file"; then
            continue
        fi
        
        # Process file
        awk -v author="SUSE Product & Solution Documentation Team" \
            -v image="https://www.suse.com/assets/img/suse-white-logo-green.svg" \
            -v pname="$PRODUCT_NAME" \
            -v pversion="$PRODUCT_VERSION" '
        BEGIN { found_attrs=0; inserted=0 }
        /^:/ { found_attrs=1; print; next }
        found_attrs==1 && inserted==0 && !/^:/ {
            if (!seen_author) print ":page-author: " author
            if (!seen_image) print ":page-image: " image
            if (!seen_pname) print ":page-product-name: " pname
            if (!seen_pversion) print ":page-product-version: " pversion
            inserted=1
            print
            next
        }
        /^:page-author:/ { seen_author=1 }
        /^:page-image:/ { seen_image=1 }
        /^:page-product-name:/ { seen_pname=1 }
        /^:page-product-version:/ { seen_pversion=1 }
        { print }
        ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
        
        echo "  ✓ $file"
    done
done

print_info "Complete!"
print_info "Review changes with: git diff"
