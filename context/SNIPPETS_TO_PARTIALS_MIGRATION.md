# Snippets to Partials Migration Guide

## Overview

This document outlines the process for migrating from `pages/snippets/` to proper Antora `partials/` structure for reusable content blocks. This migration ensures compatibility with both Antora HTML builds and PDF generation.

## Problem Statement

- **Original Structure**: Snippets were stored in `modules/<book>/pages/snippets/`
- **Issue**: Antora expects partials to be in `modules/<book>/partials/` (at module root level)
- **Impact**: Include statements using `snippets/` path didn't work properly in Antora HTML builds
- **PDF Requirement**: PDF builds need relative paths to work correctly

## Solution Architecture

### Directory Structure Change
```
# BEFORE
modules/<book>/pages/snippets/filename.adoc

# AFTER  
modules/<book>/partials/filename.adoc
```

### Include Statement Changes
```asciidoc
# BEFORE
include::snippets/filename.adoc[]

# AFTER
ifndef::backend-pdf[]
include::partial$filename.adoc[]
endif::[]

ifdef::backend-pdf[]
include::../partials/filename.adoc[]
endif::[]
```

## Step-by-Step Migration Process

### Phase 1: Setup and Testing

1. **Create partials directory**:
   ```bash
   mkdir -p modules/<book>/partials/
   ```

2. **Choose one frequently-used snippet for testing**:
   - Pick a snippet that appears in many files for clear testing results
   - Example: `check_sync_webui_mlm.adoc` (appeared in ~20 files)

3. **Move the test file**:
   ```bash
   mv modules/<book>/pages/snippets/test-file.adoc modules/<book>/partials/test-file.adoc
   ```

4. **Find all references**:
   ```bash
   grep -r "include::snippets/test-file.adoc\[\]" modules/<book>/pages/*.adoc
   ```

5. **Update all references using script**:
   ```bash
   cd modules/<book>/pages
   for file in *.adoc; do
     if grep -q "include::snippets/test-file.adoc\[\]" "$file"; then
       echo "Updating $file"
       sed -i 's|include::snippets/test-file.adoc\[\]|ifndef::backend-pdf[]\ninclude::partial$test-file.adoc[]\nendif::[]\n\nifdef::backend-pdf[]\ninclude::../partials/test-file.adoc[]\nendif::[]|g' "$file"
     fi
   done
   ```

6. **Test both builds**:
   - Build Antora HTML: `make antora-<product>-en`
   - Build PDF: `make pdf-<book>-<product>-en`
   - Verify content appears correctly in both outputs

### Phase 2: Systematic Migration

Once testing confirms the approach works:

1. **Get complete list of remaining snippets**:
   ```bash
   ls modules/<book>/pages/snippets/
   ```

2. **Process each file individually**:
   ```bash
   # For each snippet file:
   SNIPPET_FILE="filename.adoc"
   
   # Move file
   mv modules/<book>/pages/snippets/$SNIPPET_FILE modules/<book>/partials/$SNIPPET_FILE
   
   # Find references
   grep -r "include::snippets/$SNIPPET_FILE\[\]" modules/<book>/pages/*.adoc
   
   # Update references
   cd modules/<book>/pages
   for file in *.adoc; do
     if grep -q "include::snippets/$SNIPPET_FILE\[\]" "$file"; then
       echo "Updating $file"
       PARTIAL_NAME=$(basename "$SNIPPET_FILE" .adoc)
       sed -i "s|include::snippets/$SNIPPET_FILE\[\]|ifndef::backend-pdf[]\ninclude::partial\$$PARTIAL_NAME.adoc[]\nendif::[]\n\nifdef::backend-pdf[]\ninclude::../partials/$SNIPPET_FILE[]\nendif::[]|g" "$file"
     fi
   done
   
   # Verify changes
   for file in *.adoc; do
     if grep -q "include::snippets/$SNIPPET_FILE\[\]" "$file"; then
       echo "$file still has old reference"
     elif grep -q "partial\$$PARTIAL_NAME.adoc" "$file"; then
       echo "$file updated successfully"
     fi
   done
   ```

3. **Test after each file migration** (recommended for large migrations)

### Phase 3: Cleanup

1. **Verify no old references remain**:
   ```bash
   grep -r "include::snippets/" modules/<book>/pages/*.adoc
   ```

2. **Remove empty snippets directory**:
   ```bash
   rmdir modules/<book>/pages/snippets/
   ```

3. **Final build test**:
   - Full Antora HTML build
   - Full PDF build
   - Verify all content appears correctly

## Example Migration (Client Configuration Book)

### Files Processed
- `check_sync_webui_mlm.adoc` (20+ references)
- `check_sync_webui_uyuni.adoc` (21+ references)
- `check_sync_cli.adoc`
- `addchannels_novendor_cli.adoc`
- `addchannels_novendor_cli_multiarch.adoc`
- `addchannels_vendor_cli.adoc`
- `addchannels_vendor_webui.adoc`
- `arch-other-note.adoc`
- `create_bootstrap_repo_register.adoc`
- `eol-clients.adoc`
- `managing_appstreams.adoc`
- `manual_associate.adoc`
- `manual_channels.adoc`
- `manual_repos.adoc`
- `trust_gpg.adoc`

### Impact
- **Files affected**: ~100+ include statements across 20+ client pages
- **Build compatibility**: Both Antora HTML and PDF builds work correctly
- **Structure**: Proper Antora partials structure implemented

## Technical Notes

### Why `ifndef::backend-pdf[]` Works Better Than `ifdef::env-antora[]`

- `backend-pdf` is a well-established, reliable conditional
- `env-antora` was problematic and didn't work consistently
- The negative conditional approach (`ifndef`) is cleaner and more reliable

### Include Statement Logic

1. **Default case** (Antora HTML): Uses `include::partial$filename.adoc[]`
2. **PDF override**: Uses `include::../partials/filename.adoc[]` when `backend-pdf` is defined
3. **Fallback**: If neither works, the content simply won't appear (fail gracefully)

## Books That Need This Migration

Apply this process to all documentation books:
- `administration/`
- `client-configuration/` ✅ (completed)
- `installation-and-upgrade/`
- `reference/`
- `retail/`
- `specialized-guides/`
- `common-workflows/`
- `legal/`

## Troubleshooting

### Common Issues

1. **Content doesn't appear in HTML build**:
   - Check that file is in `partials/` directory
   - Verify `partial$` syntax is correct
   - Ensure no typos in filename

2. **Content doesn't appear in PDF build**:
   - Check that `../partials/` path is correct
   - Verify relative path from pages to partials directory

3. **Build errors**:
   - Look for missing files
   - Check for syntax errors in conditional statements
   - Verify all old `snippets/` references are removed

### Verification Commands

```bash
# Check for remaining old references
grep -r "include::snippets/" modules/<book>/pages/*.adoc

# Check for new partial references
grep -r "include::partial\$" modules/<book>/pages/*.adoc

# List files in partials directory
ls modules/<book>/partials/

# Verify specific file migration
grep -n "partial\$filename.adoc" modules/<book>/pages/*.adoc
```

## Benefits After Migration

1. **Proper Antora structure**: Follows Antora best practices
2. **Dual compatibility**: Works with both HTML and PDF builds
3. **Maintainability**: Easier to manage shared content
4. **Consistency**: Standardized approach across all books
5. **Future-proof**: Compatible with Antora updates

---

*Document created during migration of client-configuration book (October 2025)*
*Branch: testing-correct-partial-use-jcayouette*
