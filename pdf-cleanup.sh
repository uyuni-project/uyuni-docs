#!/bin/bash

# This script cleans up the POST-build PDF directories for documentation.suse.com.
# Execute this script after running 'make antora-mlm' to ensure proper directory structure.
# This task should be automated in the future.

# Define directories
BUILD_DIR="build"
PDF_DIR="$BUILD_DIR/pdf"
EN_PDF_DIR="$BUILD_DIR/en/pdf"
LOCALES=("ko" "ja" "zh_CN")

# List of files to keep
KEEP_FILES=(
    "suse_multi_linux_manager_administration_guide.pdf"
    "suse_multi_linux_manager_client-configuration_guide.pdf"
    "suse_multi_linux_manager_installation-and-upgrade_guide.pdf"
    "suse_multi_linux_manager_specialized-guides_guide.pdf"
)

# Check if the build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: The build directory does not exist. Have the docs been built?"
    exit 1
fi

# Ensure target pdf directory exists
mkdir -p "$PDF_DIR/en"

# Step 1: Copy all files from build/en/pdf/ to build/pdf/en/
if [ -d "$EN_PDF_DIR" ]; then
    cp -r "$EN_PDF_DIR/"* "$PDF_DIR/en/"
    echo "Copied English PDFs to $PDF_DIR/en/"
else
    echo "Warning: English PDF directory not found. Skipping copy."
fi

# Step 2 & 3: Process ko, ja, and zh_CN directories
for locale in "${LOCALES[@]}"; do
    SRC_LOCALE_PDF="$BUILD_DIR/$locale/pdf"
    DEST_LOCALE_PDF="$PDF_DIR/$locale"

    if [ -d "$SRC_LOCALE_PDF" ]; then
        mkdir -p "$DEST_LOCALE_PDF"

        # Move only the allowed files
        for file in "$SRC_LOCALE_PDF"/*; do
            filename=$(basename "$file")

            if [[ " ${KEEP_FILES[@]} " =~ " ${filename} " ]]; then
                mv "$file" "$DEST_LOCALE_PDF/"
            else
                echo "Removing $file (not in keep list)"
                rm -f "$file"
            fi
        done

        # Remove the now empty pdf directory
        rmdir "$SRC_LOCALE_PDF" 2>/dev/null
    fi
done

# Step 4: Remove build/en/pdf, build/ko/pdf, build/ja/pdf, build/zh_CN/pdf after moving
rm -rf "$EN_PDF_DIR"
for locale in "${LOCALES[@]}"; do
    rm -rf "$BUILD_DIR/$locale/pdf"
done

echo "PDF processing complete."
