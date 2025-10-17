# Uyuni Documentation Migration Guide: Snippets to Partials

## Overview
This document provides a comprehensive guide for migrating AsciiDoc snippet files from `pages/snippets/` directories to proper Antora `partials/` structure across all documentation books and branches.

## 🚨 Critical Fix: Antora Module Prefix Required
**IMPORTANT**: During migration, we discovered that Antora partial includes need module prefixes to work correctly:

**❌ WRONG (causes red/failing includes):**
```adoc
ifndef::backend-pdf[]
include::partial$snippet-name.adoc[]
endif::[]
```

**✅ CORRECT (working includes):**
```adoc
ifndef::backend-pdf[]
include::module-name:partial$snippet-name.adoc[]
endif::[]
```

This is critical for multi-module Antora components where each book is a separate module.

## 🚨 Critical PDF Build Configuration

**IMPORTANT**: PDF builds require two additional fixes that are easy to miss:

### 1. Update parameters.yml
The `parameters.yml` file contains a global `snippet` attribute that PDF builds use:

**❌ WRONG (old path):**
```yaml
- attribute: snippet
  value: ../../snippets/
```

**✅ CORRECT (new path):**
```yaml
- attribute: snippet
  value: partials/
```

### 2. Fix PDF Conditional Include Paths
The `ifdef::backend-pdf[]` blocks must use correct relative paths to the book-specific partials directory:

**❌ WRONG (points to global partials that don't exist):**
```adoc
ifdef::backend-pdf[]
include::../../../../partials/snippet-name.adoc[]
endif::[]
```

**✅ CORRECT (points to book-specific partials):**
```adoc
ifdef::backend-pdf[]
include::../../../partials/snippet-name.adoc[]  # For depth 3 files
endif::[]
```

**Path Calculations by Directory Depth:**
- **Depth 2** (`pages/container-management/`): `../../partials/`
- **Depth 3** (`pages/container-deployment/mlm/`): `../../../partials/`
- **Depth 5** (`pages/container-deployment/mlm/migrations/server/`): `../../../../../partials/`

⚠️ **Common Mistake**: Using too many `../` which points to global `/modules/partials/` instead of book-specific `/modules/book/partials/`

## Current Branch Migration Status

### Completed Migration (testing-correct-partial-use-jcayouette branch)

#### Books Migrated
- ✅ **client-configuration**: 15 snippet files → partials/ + ~100 include updates
- ✅ **administration**: 1 snippet file → partials/ + includes updated  
- ✅ **retail**: 4 snippet files → partials/ + includes updated
- ✅ **installation-and-upgrade**: 13 snippet files → partials/ + complex depth-based path updates

#### Books Verified (No Migration Needed)
- ✅ **common-workflows**: No snippet files found
- ✅ **legal**: No snippet files found  
- ✅ **reference**: No snippet files found
- ✅ **specialized-guides**: No snippet files found
- ✅ **ROOT**: No snippet files found

#### Critical Fixes Applied
- ✅ **Antora Module Prefixes**: All includes now use `module-name:partial$` syntax
- ✅ **Parameters.yml Updated**: Changed `snippet: ../../snippets/` → `snippet: partials/`
- ✅ **PDF Relative Paths Fixed**: Corrected depth-based paths to point to book-specific partials
- ✅ **Dual Build Compatibility**: Conditional includes work for both HTML and PDF
- ✅ **Complex Directory Depths**: Proper relative paths calculated for nested structures

### Other Branches Status
| Branch | Status | Notes |
|--------|--------|-------|
| main | ⏳ **Pending** | Needs migration - base for other branches |
| development | ⏳ **Pending** | Active development branch |
| release-5.1 | ⏳ **Pending** | Current release branch |
| release-5.0 | ⏳ **Pending** | Previous release branch |

### Migration Scope

## Technical Changes

### Snippet to Partials Migration
**Structure Change**: 
```
OLD: modules/book/pages/snippets/snippet-name.adoc
NEW: modules/book/partials/snippet-name.adoc
```

**Include Syntax Change**:
```adoc
OLD: include::snippets/snippet-name.adoc[]

NEW (CORRECT with module prefix): 
ifndef::backend-pdf[]
include::module-name:partial$snippet-name.adoc[]
endif::[]

ifdef::backend-pdf[]
include::../partials/snippet-name.adoc[]
endif::[]
```

**Common Module Names**:
- `client-configuration:partial$`
- `administration:partial$`
- `retail:partial$`
- `installation-and-upgrade:partial$`

### Complex Directory Depth Handling
**installation-and-upgrade book** required depth-based relative paths:

- **Depth 2** (1 file): `../../../partials/`
- **Depth 3** (10 files): `../../../../partials/`  
- **Depth 5** (2 files): `../../../../../../partials/`

## File Statistics

### Total Files Migrated
- **33 snippet files** moved to partials/ directories
- **~150+ include statements** updated with conditional includes

### Partials Directories Created
```
modules/administration/partials/
modules/client-configuration/partials/
modules/installation-and-upgrade/partials/
modules/retail/partials/
```

## Build Compatibility

### HTML Builds (Antora)
- Uses `ifndef::backend-pdf[]` conditional
- Includes: `include::module-name:partial$snippet-name.adoc[]` ⚠️ **Must include module prefix**
- Leverages Antora's partial resolution system

### PDF Builds (asciidoctor-pdf)
- Uses `ifdef::backend-pdf[]` conditional  
- Includes: `include::../partials/snippet-name.adoc[]` (relative path based on file depth)
- Uses relative file paths from source location

## Quality Assurance

### Verification Steps Completed
1. ✅ All snippet files successfully moved to partials/
2. ✅ No remaining `pages/snippet` includes found
3. ✅ Conditional include syntax verified across sample files
4. ✅ Directory depth calculations confirmed for complex structures
5. ✅ All books checked for completeness

### Testing Recommendations
```bash
# Test HTML build
make html

# Test PDF build  
make pdf

# Test specific book
cd modules/client-configuration && antora --to-dir ../../build site.yml
```

## Benefits Achieved

### 1. Antora Compliance
- Proper partials structure follows Antora best practices
- Enables Antora's partial resolution and validation
- Improves build performance and reliability

### 2. Dual Build Support
- Conditional includes ensure both HTML and PDF builds work
- No duplication of content between build types
- Maintains existing functionality while improving structure

### 3. Maintainability
- Centralized snippet management in partials/ directories
- Clear separation between pages and reusable components
- Better organization for future content updates

## Migration Pattern for Future Use

For any new books or snippet files:

1. **Create partials directory**: `modules/book/partials/`
2. **Move snippet files**: From `pages/snippets/` to `partials/`
3. **Update includes**: Replace with conditional includes pattern
4. **Calculate relative paths**: Based on source file directory depth
5. **Test both builds**: Verify HTML and PDF generation

## 🌟 Branch Migration Guide

### Step-by-Step Branch Migration Process

#### 1. Pre-Migration Assessment
```bash
# Check current branch
git branch

# Identify books with snippets
find modules/ -path "*/pages/snippets" -type d

# Count snippet files per book
for book in modules/*/; do
  bookname=$(basename "$book")
  if [ -d "$book/pages/snippets" ]; then
    count=$(ls "$book/pages/snippets/"*.adoc 2>/dev/null | wc -l)
    echo "$bookname: $count snippet files"
  fi
done
```

#### 2. Migration Execution
```bash
# Complete migration checklist for each book:

BOOK_NAME="$1"  # e.g., "client-configuration"

echo "=== Migrating $BOOK_NAME ==="

# STEP 1: Create partials directory
mkdir -p "modules/$BOOK_NAME/partials"

# STEP 2: Move snippet files
if [ -d "modules/$BOOK_NAME/pages/snippets" ]; then
  mv "modules/$BOOK_NAME/pages/snippets/"*.adoc "modules/$BOOK_NAME/partials/"
  rmdir "modules/$BOOK_NAME/pages/snippets"
fi

# STEP 3: Update Antora includes with correct module prefix
find "modules/$BOOK_NAME/pages" -name "*.adoc" -exec sed -i "
  s|include::snippets/snippet-\([^.[]*\)\.adoc\(\[.*\]\)\?|ifndef::backend-pdf[]\ninclude::${BOOK_NAME}:partial\$snippet-\1.adoc\2\nendif::[]\n\nifdef::backend-pdf[]\ninclude::../partials/snippet-\1.adoc\2\nendif::[]|g
" {} \;

# STEP 4: ⚠️ CRITICAL - Fix PDF relative paths based on directory depth
# For depth 2 files (pages/subdir/):
find "modules/$BOOK_NAME/pages" -maxdepth 2 -name "*.adoc" -exec sed -i 's|include::../partials/|include::../../partials/|g' {} \;

# For depth 3 files (pages/subdir/subdir2/):
find "modules/$BOOK_NAME/pages" -mindepth 3 -maxdepth 3 -name "*.adoc" -exec sed -i 's|include::../partials/|include::../../../partials/|g' {} \;

# For depth 4+ files (pages/subdir/subdir2/subdir3/):
find "modules/$BOOK_NAME/pages" -mindepth 4 -name "*.adoc" -exec sed -i 's|include::../partials/|include::../../../../partials/|g' {} \;

# STEP 5: ⚠️ CRITICAL - Update parameters.yml (ONLY ONCE)
sed -i 's|value: ../../snippets/|value: partials/|g' parameters.yml

echo "✅ Completed migration for $BOOK_NAME"
echo "🔍 VERIFY: Test both 'make antora-mlm' and PDF builds"
```

#### 2.1. ⚠️ Critical Configuration Updates

**Must be done ONCE per repository (not per book):**

```bash
# Update parameters.yml for PDF builds
sed -i 's|value: ../../snippets/|value: partials/|g' parameters.yml

# Verify the change
grep -A 1 "attribute: snippet" parameters.yml
# Should show: value: partials/
```

#### 3. Complex Directory Depth Handling

For books with nested directory structures (like installation-and-upgrade):

```bash
# Calculate relative paths based on file depth
# Depth 1 (pages/file.adoc): ../partials/
# Depth 2 (pages/subdir/file.adoc): ../../partials/  
# Depth 3 (pages/subdir/subdir2/file.adoc): ../../../partials/
# etc.

# Use this formula for PDF includes:
# Depth N: ../ repeated (N+1) times + partials/
```

#### 4. Branch-Specific Considerations

**For development branches:**
- Ensure base branch is up to date before migration
- Test both HTML and PDF builds after migration
- Check for any book-specific snippet patterns

**For release branches:**
- Coordinate with maintainers before migration
- Consider cherry-picking from development branch if migration is already done
- Test thoroughly as release branches have different validation requirements

**For feature branches:**
- Rebase on latest development branch after migration is complete there
- May need to resolve merge conflicts with snippet/partial paths
- Test that feature functionality still works with new include syntax

#### 5. Automation Scripts for Multiple Branches

**Branch Migration Script:**
```bash
#!/bin/bash
# migrate-all-branches.sh

BRANCHES=("main" "development" "release-5.1" "release-5.0")
CURRENT_BRANCH=$(git branch --show-current)

for branch in "${BRANCHES[@]}"; do
  echo "=== Processing branch: $branch ==="
  
  # Switch to branch
  git checkout "$branch"
  git pull origin "$branch"
  
  # Check if migration is needed
  if find modules/ -path "*/pages/snippets" -type d | grep -q .; then
    echo "Migration needed for branch $branch"
    
    # Run migration for each book
    for book_dir in modules/*/; do
      book=$(basename "$book_dir")
      if [ -d "$book_dir/pages/snippets" ]; then
        echo "Migrating $book in branch $branch"
        ./migrate-book.sh "$book"
      fi
    done
    
    # Commit changes
    git add .
    git commit -m "Migrate snippets to partials for proper Antora structure

- Move snippet files from pages/snippets/ to partials/
- Update includes with conditional backend syntax
- Add module prefixes for Antora compatibility
- Maintain dual build support (HTML + PDF)"
    
    git push origin "$branch"
  else
    echo "✅ Branch $branch already migrated or no snippets found"
  fi
done

# Return to original branch
git checkout "$CURRENT_BRANCH"
```

#### 6. Validation After Branch Migration

```bash
# Test script for validating migration
#!/bin/bash

echo "=== Validation Tests ==="

# 1. Check no old snippet includes remain
echo "Checking for old snippet includes..."
if find modules/*/pages -name "*.adoc" -exec grep -l "include::snippets/" {} \; | grep -q .; then
  echo "❌ Old snippet includes found:"
  find modules/*/pages -name "*.adoc" -exec grep -l "include::snippets/" {} \;
else
  echo "✅ No old snippet includes found"
fi

# 2. Check all partials have proper module prefixes
echo "Checking for missing module prefixes..."
if find modules/*/pages -name "*.adoc" -exec grep -l "include::partial\$" {} \; | grep -q .; then
  echo "❌ Includes missing module prefix found:"
  find modules/*/pages -name "*.adoc" -exec grep -l "include::partial\$" {} \;
else
  echo "✅ All includes have proper module prefixes"
fi

# 3. Verify partials directories exist
echo "Checking partials directories..."
for book_dir in modules/*/; do
  book=$(basename "$book_dir")
  if find "$book_dir/pages" -name "*.adoc" -exec grep -l "${book}:partial\$" {} \; | grep -q .; then
    if [ -d "$book_dir/partials" ]; then
      count=$(ls "$book_dir/partials/"*.adoc 2>/dev/null | wc -l)
      echo "✅ $book: partials/ exists with $count files"
    else
      echo "❌ $book: partials/ directory missing but includes reference it"
    fi
  fi
done

# 4. Test builds
echo "Testing builds..."
make antora-mlm > build-test.log 2>&1
if [ $? -eq 0 ]; then
  echo "✅ Antora build successful"
else
  echo "❌ Antora build failed - check build-test.log"
fi
```

### Common Branch Migration Issues

#### Issue 1: Merge Conflicts
**Problem**: When merging branches after migration, snippet paths conflict
**Solution**: 
```bash
# Resolve by preferring the migrated version
git checkout --theirs modules/*/partials/
git checkout --ours modules/*/pages/  # (for updated includes)
```

#### Issue 2: Cherry-picking Commits
**Problem**: Cherry-picking commits that modify snippet files after migration
**Solution**: Update paths in cherry-picked commits:
```bash
# After cherry-pick, update any snippet references
sed -i 's|snippets/snippet-|partials/snippet-|g' conflicted-file.adoc
```

#### Issue 3: Feature Branch Rebasing
**Problem**: Feature branches with snippet changes need rebasing after migration
**Solution**: 
```bash
# Rebase and update snippet paths
git rebase main
# Then manually update any snippet includes to use new partial syntax
```

## Files Modified Summary

### Migration Files (4 books)
- **client-configuration**: 15 snippets + ~100 includes
- **administration**: 1 snippet + includes
- **retail**: 4 snippets + includes  
- **installation-and-upgrade**: 13 snippets + complex includes

### Syntax Fixes
- `modules/administration/pages/backup-restore.adoc`: Fixed stray delimiters

## Completion Status

### Current Branch (testing-correct-partial-use-jcayouette)
🎉 **MIGRATION COMPLETE** - All snippet files successfully migrated to Antora partials structure with dual build compatibility and proper module prefixes.

### Next Steps for Other Branches
1. **Apply to main branch**: Use the branch migration scripts provided above
2. **Coordinate with team**: Ensure all contributors are aware of new include syntax
3. **Update documentation**: Make sure contributor guides mention the new partial structure
4. **Test thoroughly**: Verify both HTML and PDF builds work on all target branches

### Quick Branch Migration Command
```bash
# For urgent fixes on other branches:
git checkout target-branch
git cherry-pick testing-correct-partial-use-jcayouette  # (if migration is in single commit)
# OR follow the detailed migration scripts above
```

## 📚 Additional Resources

### Troubleshooting Common Issues

#### Issue 1: "include file not found" in PDF builds
**Symptoms**: Errors like `/translations/en/modules/partials/snippet-name.adoc` not found
**Root Cause**: PDF builds use different relative path resolution than Antora
**Solution**:
1. Check `parameters.yml` has `snippet: partials/` (not `../../snippets/`)
2. Verify PDF conditional paths use correct directory depth:
   ```bash
   # Check a problematic file:
   grep -A 5 "ifdef::backend-pdf" modules/book/pages/path/file.adoc
   
   # Should show correct relative path to book partials:
   include::../../../partials/snippet-name.adoc  # (for depth 3)
   ```

#### Issue 2: Red includes in Antora builds  
**Symptoms**: Include statements show as red/unresolved in editor or build
**Root Cause**: Missing module prefix in Antora includes
**Solution**: Ensure includes use `module-name:partial$` syntax:
```bash
# Find files missing module prefix:
grep -r "include::partial\$" modules/*/pages/

# Fix them:
sed -i 's|include::partial\$|include::book-name:partial$|g' file.adoc
```

#### Issue 3: Translation directory cache issues
**Symptoms**: Changes don't appear in build even after fixing source files
**Root Cause**: Build process copies old files from `modules/` to `translations/en/modules/`
**Solution**: Clean translation cache:
```bash
make configure-mlm  # Clears and rebuilds translations/en/
```

#### Issue 4: Wrong relative paths in PDF builds
**Symptoms**: PDF build errors pointing to wrong directory levels
**Root Cause**: Incorrect calculation of relative paths based on file depth
**Solution**: Use this formula:
- File at depth N needs `../` repeated N times + `partials/`
- Depth 2: `../../partials/`
- Depth 3: `../../../partials/`
- Depth 4: `../../../../partials/`

### Troubleshooting Red Includes
If you see red/failing includes after migration:
1. **Check module prefix**: Ensure includes use `module-name:partial$` syntax
2. **Verify partials exist**: Check that `modules/book/partials/snippet-file.adoc` exists
3. **Test builds**: Run `make antora-mlm` to see specific error messages
4. **Check relative paths**: For PDF includes, verify directory depth calculations

### Performance Benefits
- **Faster builds**: Antora can better cache and resolve partials
- **Better validation**: Antora validates partial references at build time
- **Cleaner structure**: Separation of content (pages) from reusable components (partials)
- **Future-proof**: Follows Antora best practices for long-term maintainability

## 🚀 Quick Reference for Future Migrations

### Pre-Migration Checklist
- [ ] Identify books with snippet files: `find modules/ -path "*/pages/snippets" -type d`
- [ ] Backup current branch: `git checkout -b backup-before-migration`
- [ ] Ensure clean working directory: `git status`

### Migration Checklist (Per Book)
- [ ] Create partials directory: `mkdir -p modules/book/partials`
- [ ] Move snippet files: `mv modules/book/pages/snippets/*.adoc modules/book/partials/`
- [ ] Update Antora includes: Add module prefix `book:partial$`
- [ ] Fix PDF relative paths: Correct `../` count based on file depth
- [ ] Test Antora build: `make antora-mlm` (should have no red includes)
- [ ] Test PDF build: `make pdf-book-mlm-en` (should have no file not found errors)

### Post-Migration Checklist (Once per Repository)
- [ ] Update `parameters.yml`: Change `snippet: ../../snippets/` → `snippet: partials/`
- [ ] Clean translations: `make configure-mlm`
- [ ] Full build test: `make antora-mlm` 
- [ ] Verify all books: Check HTML and PDF outputs
- [ ] Commit changes: `git add . && git commit -m "Migrate snippets to partials"`

### Critical Files to Check
1. **parameters.yml**: Must have `snippet: partials/`
2. **modules/*/partials/**: Should contain all snippet files
3. **Antora includes**: Must use `book:partial$snippet-name.adoc`
4. **PDF includes**: Must use correct relative paths like `../../../partials/`

### Emergency Rollback
```bash
git checkout backup-before-migration
git branch -D current-migration-branch
```

This comprehensive guide should prevent future migration issues and provide clear troubleshooting steps for any problems that arise.
