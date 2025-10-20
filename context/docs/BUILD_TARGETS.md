# Build Targets Reference

**Version:** 1.0  
**Last Updated:** October 20, 2025

## Overview

This document describes all make targets in the uyuni-docs build system. Targets are organized by category for easy navigation.

## Quick Reference

```bash
# Configuration
make configure               # Generate language-specific Makefiles

# HTML Builds - MLM
make antora-mlm              # All MLM languages
make antora-mlm-en           # English only
make antora-mlm-ja           # Japanese only
make antora-mlm-zh_CN        # Chinese only
make antora-mlm-ko           # Korean only

# HTML Builds - Uyuni
make antora-uyuni            # All Uyuni languages
make antora-uyuni-en         # English only
make antora-uyuni-ja         # Japanese only

# PDF Builds - MLM
make pdf-all-mlm-en          # All English PDFs
make pdf-administration-mlm-en  # Single guide

# Validation
make validate-mlm-en         # Validate cross-references
make checkstyle-en           # Check AsciiDoc style

# Translation
make pot                     # Extract strings to POT
make translations            # Apply PO translations

# Packaging
make obs-packages-mlm-en     # OBS packages

# Cleanup
make clean                   # Clean all
make clean-en                # Clean English only
```

## Table of Contents

1. [Configuration Targets](#configuration-targets)
2. [Translation Targets](#translation-targets)
3. [Branding Targets](#branding-targets)
4. [HTML Build Targets](#html-build-targets)
5. [PDF Build Targets](#pdf-build-targets)
6. [Validation Targets](#validation-targets)
7. [Quality Targets](#quality-targets)
8. [Packaging Targets](#packaging-targets)
9. [Cleanup Targets](#cleanup-targets)
10. [Meta Targets](#meta-targets)

---

## Configuration Targets

### configure

**Purpose:** Generates all language-specific Makefiles from templates.

**Command:**
```bash
make configure
```

**What It Does:**
1. Runs `./configure` Python script
2. Reads `parameters.yml`
3. Processes Jinja2 templates:
   - `Makefile.j2` → `Makefile.en`, `Makefile.ja`, etc.
   - `Makefile.section.functions.j2` → PDF functions
   - `Makefile.lang.target.j2` → Language-specific targets
4. Generates:
   - `Makefile.en`
   - `Makefile.ja`
   - `Makefile.zh_CN`
   - `Makefile.ko`
   - (Other configured languages)

**When to Run:**
- After modifying `parameters.yml`
- After editing `.j2` template files
- After `git pull` with template changes
- When adding new languages

**Output:**
```
Generating Makefile.en
Generating Makefile.ja
Generating Makefile.zh_CN
Generating Makefile.ko
Configuration complete.
```

**Related Files:**
- `configure` - Generator script
- `parameters.yml` - Configuration
- `Makefile.j2` - Main template
- `Makefile.section.functions.j2` - PDF functions template
- `Makefile.lang.target.j2` - Language targets template

---

## Translation Targets

### pot

**Purpose:** Extracts translatable strings from source AsciiDoc to POT files.

**Command:**
```bash
make pot
```

**What It Does:**
1. Runs `make_pot.sh` script
2. Calls `l10n-weblate/update-cfg-files`
3. Runs `po4a` for each module:
   ```bash
   po4a --no-translations l10n-weblate/ROOT.cfg
   po4a --no-translations l10n-weblate/administration.cfg
   # ... all modules
   ```
4. Creates/updates POT files:
   ```
   l10n-weblate/ROOT/pot/nav.adoc.pot
   l10n-weblate/administration/pot/admin-overview.adoc.pot
   ... (all source files)
   ```

**When to Run:**
- After editing source English documentation
- Before sending to Weblate
- Before generating translation statistics

**Time:** ~2-5 minutes (processes all 9 modules)

**Output Files:**
```
l10n-weblate/ROOT/pot/*.pot
l10n-weblate/administration/pot/*.pot
l10n-weblate/client-configuration/pot/*.pot
l10n-weblate/common-workflows/pot/*.pot
l10n-weblate/installation-and-upgrade/pot/*.pot
l10n-weblate/legal/pot/*.pot
l10n-weblate/reference/pot/*.pot
l10n-weblate/retail/pot/*.pot
l10n-weblate/specialized-guides/pot/*.pot
```

**Related:**
- `make_pot.sh` - Extraction script
- `l10n-weblate/update-cfg-files` - Config generator
- `l10n-weblate/*.cfg` - po4a configuration

### translations

**Purpose:** Applies PO translations to generate translated AsciiDoc files.

**Command:**
```bash
make translations
```

**Dependencies:**
- POT files must exist (`make pot`)
- PO files must exist in `l10n-weblate/*/ja/*.po` (from Weblate)

**What It Does:**
1. Ensures POT files exist (runs `make pot` if needed)
2. Runs `use_po.sh` for each language
3. Calls `po4a` to apply translations:
   ```bash
   po4a l10n-weblate/ROOT.cfg
   po4a l10n-weblate/administration.cfg
   # ... all modules
   ```
4. Creates translated files:
   ```
   translations/ja/modules/administration/pages/admin-overview.adoc
   translations/zh_CN/modules/administration/pages/admin-overview.adoc
   ... (all pages, all languages)
   ```

**Time:** ~10-20 minutes (all languages, all modules)

**Output:**
```
translations/
├── ja/
│   ├── antora.yml
│   ├── mlm-site.yml
│   ├── uyuni-site.yml
│   └── modules/
│       └── (all translated pages)
├── zh_CN/
│   └── (all translated pages)
└── ko/
    └── (all translated pages)
```

**Related:**
- `use_po.sh` - Translation application script
- `l10n-weblate/*/ja/*.po` - Japanese translations
- `l10n-weblate/*/zh_CN/*.po` - Chinese translations
- `l10n-weblate/*/ko/*.po` - Korean translations

### translations-LANG

**Purpose:** Apply translations for specific language only.

**Commands:**
```bash
make translations-ja      # Japanese only
make translations-zh_CN   # Chinese only
make translations-ko      # Korean only
```

**Faster than `make translations` when working on single language.**

---

## Branding Targets

Branding targets copy branding files (UI bundle, themes, fonts) to translation directories.

### branding-mlm-LANG

**Purpose:** Copy branding to MLM language translation directory.

**Commands:**
```bash
make branding-mlm-en
make branding-mlm-ja
make branding-mlm-zh_CN
make branding-mlm-ko
```

**What It Does:**
```bash
$(call copy-branding,ja)
```

**Creates:**
```
translations/ja/branding/
├── ui-bundle.zip
├── pdf/
│   ├── fonts/
│   └── themes/
└── supplemental-ui/
    └── mlm/
        └── partials/
            └── header-content.hbs
```

### clean-branding-LANG

**Purpose:** Remove branding from translation directory.

**Commands:**
```bash
make clean-branding-en
make clean-branding-ja
```

**What It Does:**
```bash
$(call clean-branding,ja)
```

**Removes:** `translations/ja/branding/`

---

## HTML Build Targets

### MLM HTML Targets

#### antora-mlm

**Purpose:** Build MLM HTML for all configured languages.

**Command:**
```bash
make antora-mlm
```

**Equivalent To:**
```bash
make antora-mlm-en antora-mlm-ja antora-mlm-zh_CN antora-mlm-ko
```

**Time:** ~30-60 minutes (all languages)

#### antora-mlm-LANG

**Purpose:** Build MLM HTML for specific language.

**Commands:**
```bash
make antora-mlm-en      # English
make antora-mlm-ja      # Japanese
make antora-mlm-zh_CN   # Chinese Simplified
make antora-mlm-ko      # Korean
```

**What It Does:**

**For English:**
```makefile
antora-mlm-en: translations-en branding-mlm-en
	$(call enable-mlm-html-language-selector,ja,jaFlag,japan,日本語)
	$(call enable-mlm-html-language-selector,zh_CN,china,china,中文)
	$(call enable-mlm-html-language-selector,ko,koFlag,korea,한국어)
	$(call antora-mlm-function,translations/en,en_US.UTF-8)
```

**Steps:**
1. **Dependencies:** Ensures translations and branding exist
2. **Language Selector:** Adds buttons for all languages
3. **Antora Build:**
   - Enables MLM component in `antora.yml`
   - Sets locale environment
   - Runs Antora with `mlm-site.yml`
   - Generates search index
4. **Output:** `build/en/`

**Output Structure:**
```
build/en/
├── index.html
├── docs/
│   ├── administration/
│   ├── client-configuration/
│   ├── installation-and-upgrade/
│   └── ... (all modules)
├── _/
│   ├── css/
│   ├── js/
│   └── img/
└── search-index.json
```

**Time:** ~5-10 minutes per language

### Uyuni HTML Targets

#### antora-uyuni

**Purpose:** Build Uyuni HTML for all languages.

**Command:**
```bash
make antora-uyuni
```

#### antora-uyuni-LANG

**Purpose:** Build Uyuni HTML for specific language.

**Commands:**
```bash
make antora-uyuni-en
make antora-uyuni-ja
make antora-uyuni-zh_CN
make antora-uyuni-ko
```

**Difference from MLM:**
- Uses `enable-uyuni-in-antorayml` (not `enable-mlm-in-antorayml`)
- Uses `uyuni-site.yml` (not `mlm-site.yml`)
- Uses `SUPPLEMENTAL_FILES_UYUNI` branding

**Output:** `build/en/` (same structure)

---

## PDF Build Targets

### MLM PDF Targets

#### pdf-all-mlm-LANG

**Purpose:** Build all PDF guides for specific language.

**Commands:**
```bash
make pdf-all-mlm-en      # All English PDFs
make pdf-all-mlm-ja      # All Japanese PDFs
make pdf-all-mlm-zh_CN   # All Chinese PDFs
```

**Equivalent To:**
```bash
make pdf-all-mlm-en
# Same as:
make pdf-administration-mlm-en \
     pdf-client-configuration-mlm-en \
     pdf-common-workflows-mlm-en \
     pdf-installation-and-upgrade-mlm-en \
     pdf-reference-mlm-en \
     pdf-retail-mlm-en \
     pdf-specialized-guides-mlm-en \
     pdf-ROOT-mlm-en
```

**Time:** ~15-30 minutes (all guides)

**Output:**
```
build/en/pdf/
├── suse_multi_linux_manager_administration_guide.pdf
├── suse_multi_linux_manager_client-configuration_guide.pdf
├── suse_multi_linux_manager_common-workflows_guide.pdf
├── suse_multi_linux_manager_installation-and-upgrade_guide.pdf
├── suse_multi_linux_manager_reference_guide.pdf
├── suse_multi_linux_manager_retail_guide.pdf
├── suse_multi_linux_manager_specialized-guides_guide.pdf
└── suse_multi_linux_manager_ROOT_guide.pdf
```

#### pdf-MODULE-mlm-LANG

**Purpose:** Build single PDF guide.

**Commands:**
```bash
# English
make pdf-administration-mlm-en
make pdf-client-configuration-mlm-en
make pdf-common-workflows-mlm-en
make pdf-installation-and-upgrade-mlm-en
make pdf-reference-mlm-en
make pdf-retail-mlm-en
make pdf-specialized-guides-mlm-en
make pdf-ROOT-mlm-en

# Japanese
make pdf-administration-mlm-ja
make pdf-client-configuration-mlm-ja
# ... etc

# Chinese
make pdf-administration-mlm-zh_CN
# ... etc
```

**What It Does:**

**Example: `make pdf-administration-mlm-ja`**

```makefile
pdf-administration-mlm-ja: translations-ja branding-mlm-ja
	$(call pdf-book-create-index,translations/ja,administration,ja)
	$(call pdf-book-create,
		translations/ja,
		suse-jp,
		'SUSE Multi-Linux Manager',
		true,
		suse_multi_linux_manager,
		administration,
		$(current_dir)/build/ja/pdf,
		ja,
		ja_JP.UTF-8,
		%Y年%m月%e日,
		-a scripts=cjk
	)
```

**Steps:**
1. **Dependencies:** Ensures translations and branding exist
2. **Create Index:** Converts `nav-administration-guide.adoc` to PDF format
3. **Generate PDF:**
   - Runs `asciidoctor-pdf`
   - Uses CJK fonts for Japanese
   - Applies Japanese PDF theme
   - Sets locale for date formatting
   - Includes all pages via index

**Time:** ~2-5 minutes per guide

**Language-Specific Parameters:**

| Language | Theme | Locale | Date Format | Extra Args |
|----------|-------|--------|-------------|------------|
| English | `suse` | `en_US.UTF-8` | `%B %d, %Y` | - |
| Japanese | `suse-jp` | `ja_JP.UTF-8` | `%Y年%m月%e日` | `-a scripts=cjk` |
| Chinese | `suse-zh_CN` | `zh_CN.UTF-8` | `%Y年%m月%d日` | `-a scripts=cjk` |
| Korean | `suse-ko` | `ko_KR.UTF-8` | `%Y년%m월%e일` | `-a scripts=cjk` |

### Uyuni PDF Targets

#### pdf-all-uyuni-LANG

**Commands:**
```bash
make pdf-all-uyuni-en
make pdf-all-uyuni-ja
```

#### pdf-MODULE-uyuni-LANG

**Commands:**
```bash
make pdf-administration-uyuni-en
make pdf-client-configuration-uyuni-ja
# ... etc
```

**Difference from MLM:**
- Uses `pdf-book-create-uyuni` (sets `uyuni-content=true`)
- Output: `uyuni_MODULE_guide.pdf` (not `suse_multi_linux_manager_`)

---

## Validation Targets

### validate-mlm-LANG / validate-uyuni-LANG

**Purpose:** Validate all cross-references (xref:) are valid.

**Commands:**
```bash
make validate-mlm-en      # Validate MLM English
make validate-mlm-ja      # Validate MLM Japanese
make validate-uyuni-en    # Validate Uyuni English
```

**What It Does:**
```bash
$(call validate-product,translations/en,mlm-site.yml)
```

**Runs:**
```bash
NODE_PATH="$(npm -g root)" antora \
  --generator @antora/xref-validator \
  mlm-site.yml
```

**Output Examples:**

**Success:**
```
✓ Validated 1,234 cross-references
  No broken references found.
```

**Errors:**
```
✗ Found 3 broken references:

modules/administration/pages/actions.adoc:45
  → xref:missing-file.adoc[Missing Page]
  Target file does not exist

modules/client/pages/setup.adoc:12
  → xref:overview.adoc#invalid-anchor[Invalid Anchor]
  Anchor 'invalid-anchor' not found

modules/reference/pages/api.adoc:89
  → xref:another-module:deleted-page.adoc[Deleted]
  Target module:page not found
```

**When to Run:**
- Before publishing
- After restructuring documentation
- In CI/CD pipeline
- When reviewing PRs

**Time:** ~30 seconds - 2 minutes

---

## Quality Targets

### checkstyle-LANG

**Purpose:** Check AsciiDoc style and formatting.

**Commands:**
```bash
make checkstyle-en
make checkstyle-ja
```

**What It Does:**
```bash
./enforcing_checkstyle translations/en
```

**Checks:**
- Line length
- Trailing whitespace
- Heading levels
- Attribute usage
- Link formats
- Code block markers

**Output Example:**
```
Checking: modules/administration/pages/actions.adoc
  Line 45: Line too long (>120 characters)
  Line 67: Trailing whitespace
  
Checking: modules/client/pages/setup.adoc
  Line 23: Invalid heading level (skipped from == to ====)

Summary: 3 issues found in 2 files
```

**Return Code:**
- `0` - No issues
- `1` - Issues found

**Use in CI:**
```bash
make checkstyle-en || exit 1
```

---

## Packaging Targets

### obs-packages-mlm-LANG / obs-packages-uyuni-LANG

**Purpose:** Create OBS (Open Build Service) packages for distribution.

**Commands:**
```bash
make obs-packages-mlm-en
make obs-packages-mlm-ja
make obs-packages-uyuni-en
```

**Dependencies:**
- HTML build must be complete
- PDF build must be complete

**What It Does:**

**For MLM English:**
```makefile
obs-packages-mlm-en: antora-mlm-en pdf-all-mlm-en
	$(call obs-packages-product,en,en/pdf,susemanager-docs_en,susemanager-docs_en-pdf)
```

**Steps:**
1. Creates HTML tarball (excludes PDF directory):
   ```bash
   tar --exclude='en/pdf' -czvf susemanager-docs_en.tar.gz -C . build/en
   ```
2. Creates PDF tarball:
   ```bash
   tar -czvf susemanager-docs_en-pdf.tar.gz -C . build/en/pdf
   ```
3. Moves to `build/packages/`:
   ```
   build/packages/susemanager-docs_en.tar.gz
   build/packages/susemanager-docs_en-pdf.tar.gz
   ```

**Output Files:**

| Language | HTML Tarball | PDF Tarball |
|----------|-------------|-------------|
| English | `susemanager-docs_en.tar.gz` | `susemanager-docs_en-pdf.tar.gz` |
| Japanese | `susemanager-docs_ja.tar.gz` | `susemanager-docs_ja-pdf.tar.gz` |
| Chinese | `susemanager-docs_zh_CN.tar.gz` | `susemanager-docs_zh_CN-pdf.tar.gz` |

**Sizes (approximate):**
- HTML: 50-100 MB (compressed)
- PDF: 20-40 MB (compressed)

### obs-packages-mlm / obs-packages-uyuni

**Purpose:** Package all languages.

**Commands:**
```bash
make obs-packages-mlm      # All MLM languages
make obs-packages-uyuni    # All Uyuni languages
```

---

## Cleanup Targets

### clean

**Purpose:** Clean all build artifacts for all languages.

**Command:**
```bash
make clean
```

**Equivalent To:**
```bash
make clean-en clean-ja clean-zh_CN clean-ko
```

**Removes:**
- `build/` (all HTML and PDF output)
- `translations/` (all translated AsciiDoc)
- `Makefile.en`, `Makefile.ja`, etc.
- `*pdf.*.adoc` (PDF index files)

**Time:** ~10 seconds

**Disk Space Freed:** 2-5 GB

### clean-LANG

**Purpose:** Clean specific language only.

**Commands:**
```bash
make clean-en      # Clean English
make clean-ja      # Clean Japanese
make clean-zh_CN   # Clean Chinese
```

**What It Does:**
```bash
$(call clean-function,translations/ja,ja)
```

**Removes:**
- `build/ja/`
- `translations/ja/`
- `Makefile.ja`
- `*pdf.ja.adoc`

### clean-branding-LANG

**Purpose:** Remove branding files only.

**Commands:**
```bash
make clean-branding-en
make clean-branding-ja
```

**Removes:** `translations/LANG/branding/`

**When to Use:**
- When branding files are updated
- Before re-copying branding
- To save disk space

### cleanup_all_pdf_files

**Purpose:** Remove all generated PDF files and indexes.

**Command:**
```bash
make cleanup_all_pdf_files
```

**Runs:**
```bash
./cleanup_pdfs.sh
```

**Removes:**
- `build/*/pdf/*.pdf`
- `**/nav-*-guide.pdf.*.adoc`

**Time:** ~1 second

---

## Meta Targets

### .PHONY Declarations

All targets are declared as `.PHONY` to ensure they always run:

```makefile
.PHONY: configure clean antora-mlm antora-uyuni validate-mlm-en ...
```

**Why `.PHONY`?**
- Targets don't produce files matching their names
- Ensures targets run even if file exists
- Prevents make from checking timestamps

### Default Target

The default target (when running `make` with no arguments) depends on Makefile version:

**Main Makefile:**
```makefile
.DEFAULT_GOAL := configure
```
Running `make` → runs `make configure`

**Language-specific Makefiles:**
```makefile
# Makefile.en, Makefile.ja, etc.
# No default target - must specify explicitly
```

---

## Common Workflows

### Complete Build from Scratch

```bash
# 1. Configure
make configure

# 2. Extract translations
make pot

# 3. Apply translations
make translations

# 4. Build HTML
make antora-mlm-en antora-mlm-ja

# 5. Build PDFs
make pdf-all-mlm-en pdf-all-mlm-ja

# 6. Validate
make validate-mlm-en validate-mlm-ja

# 7. Package
make obs-packages-mlm-en obs-packages-mlm-ja
```

### Rebuild After Source Changes

```bash
# Update POT files
make pot

# Update translations
make translations-en

# Rebuild HTML
make clean-en
make antora-mlm-en

# Rebuild PDFs if needed
make pdf-all-mlm-en
```

### Quick HTML Preview

```bash
# Just English, no translations needed
make antora-mlm-en

# View in browser
firefox build/en/index.html
```

### Test Single PDF Guide

```bash
# Build just one guide for testing
make pdf-administration-mlm-en

# View PDF
evince build/en/pdf/suse_multi_linux_manager_administration_guide.pdf
```

### Update Branding

```bash
# 1. Update branding files in branding/
# 2. Clean old branding
make clean-branding-en clean-branding-ja

# 3. Copy new branding
make branding-mlm-en branding-mlm-ja

# 4. Rebuild
make antora-mlm-en antora-mlm-ja
```

### CI/CD Pipeline

```bash
#!/bin/bash
set -e

# Configure
make configure

# Validate
make validate-mlm-en || exit 1
make checkstyle-en || exit 1

# Build
make antora-mlm-en
make pdf-all-mlm-en

# Package
make obs-packages-mlm-en

# Upload packages
./deploy-to-obs.sh build/packages/
```

---

## Target Dependencies

### Dependency Chains

Understanding dependencies helps optimize builds:

```
obs-packages-mlm-en
├── antora-mlm-en
│   ├── translations-en
│   │   └── pot
│   └── branding-mlm-en
└── pdf-all-mlm-en
    ├── translations-en (already done)
    ├── branding-mlm-en (already done)
    └── pdf-MODULE-mlm-en (for each module)
        ├── translations-en (already done)
        └── branding-mlm-en (already done)
```

### Parallel Builds

Some targets can run in parallel:

```bash
# Parallel HTML builds (different languages)
make -j4 antora-mlm-en antora-mlm-ja antora-mlm-zh_CN antora-mlm-ko

# Parallel PDF builds (different guides)
make -j4 pdf-administration-mlm-en pdf-client-configuration-mlm-en \
         pdf-reference-mlm-en pdf-retail-mlm-en

# DON'T run in parallel (shared state):
# make -j2 antora-mlm-en antora-uyuni-en  # BAD: both modify antora.yml
```

---

## Troubleshooting Targets

### Target Fails with "No rule to make target"

**Error:**
```
make: *** No rule to make target 'antora-mlm-ja'. Stop.
```

**Solution:**
```bash
make configure  # Regenerate Makefiles
```

### Target Hangs During Build

**Problem:** Antora or asciidoctor-pdf appears stuck

**Debug:**
```bash
# Check what's running
ps aux | grep node
ps aux | grep ruby

# Kill stuck process
kill <PID>

# Try again with verbose output
make antora-mlm-en V=1
```

### Target Fails with Missing Files

**Error:**
```
ERROR: File not found: translations/ja/modules/administration/pages/actions.adoc
```

**Solution:**
```bash
# Ensure translations exist
make translations-ja

# Or just that language
make translations-ja
```

### PDF Target Fails with Font Errors

**Error:**
```
asciidoctor-pdf: ERROR: could not locate font: NotoSansCJK-Regular
```

**Solution:**
```bash
# Check fonts exist
ls -l branding/pdf/fonts/

# Verify branding copied
ls -l translations/ja/branding/pdf/fonts/

# Re-copy branding
make clean-branding-ja
make branding-mlm-ja
```

---

## Related Documentation

- [BUILD_SYSTEM_OVERVIEW.md](BUILD_SYSTEM_OVERVIEW.md) - System introduction
- [BUILD_VARIABLES.md](BUILD_VARIABLES.md) - Configuration variables
- [BUILD_FUNCTIONS.md](BUILD_FUNCTIONS.md) - Make functions
- [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) - Common workflows
- [TRANSLATION_SYSTEM.md](TRANSLATION_SYSTEM.md) - Translation process

---

**Last Updated:** October 20, 2025
