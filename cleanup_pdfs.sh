#!/bin/bash
set -e

# Define directories and variables
BUILD_DIR="build"
PDF_DIR="$BUILD_DIR/pdf"
EN_PDF_DIR="$BUILD_DIR/en/pdf"
LOCALES="ko ja zh_CN"
KEEP_FILES="suse_multi_linux_manager_administration_guide.pdf suse_multi_linux_manager_client-configuration_guide.pdf suse_multi_linux_manager_installation-and-upgrade_guide.pdf suse_multi_linux_manager_specialized-guides_guide.pdf"

echo "Starting PDF cleanup..."
echo "BUILD_DIR is set to: $BUILD_DIR"
echo "PDF_DIR is set to: $PDF_DIR"
echo "EN_PDF_DIR is set to: $EN_PDF_DIR"

# Ensure the target directory exists
mkdir -p "$PDF_DIR/en"

# Copy English PDFs if they exist
if [ -d "$EN_PDF_DIR" ]; then
    echo "Copying English PDFs to $PDF_DIR/en/"
    cp -r "$EN_PDF_DIR/"* "$PDF_DIR/en/" 2>/dev/null || true
else
    echo "Warning: English PDF directory not found. Skipping copy."
fi

# Process each locale
for locale in $LOCALES; do
    SRC_LOCALE_PDF="$BUILD_DIR/$locale/pdf"
    DEST_LOCALE_PDF="$PDF_DIR/$locale"
    if [ -d "$SRC_LOCALE_PDF" ]; then
        echo "Processing PDFs for locale: $locale"
        mkdir -p "$DEST_LOCALE_PDF"
        for file in "$SRC_LOCALE_PDF"/*; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                if echo "$KEEP_FILES" | grep -q "$filename"; then
                    echo "Keeping $file"
                    mv "$file" "$DEST_LOCALE_PDF/"
                else
                    echo "Removing $file (not in keep list)"
                    rm -f "$file"
                fi
            fi
        done
        # Remove the now empty pdf directory
        rmdir "$SRC_LOCALE_PDF" 2>/dev/null || true
    else
        echo "Locale awaiting build...: $locale"
    fi
done

echo "Cleaning up leftover PDF directories..."
rm -rf "$EN_PDF_DIR"
for locale in $LOCALES; do
    rm -rf "$BUILD_DIR/$locale/pdf"
done

echo "PDF cleanup complete."
