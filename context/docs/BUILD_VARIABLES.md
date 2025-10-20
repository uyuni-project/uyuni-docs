# Build Variables Reference

**Version:** 1.0  
**Last Updated:** October 20, 2025

## Overview

This document describes all configuration variables used in the uyuni-docs Makefile system.

## Product Variables

### MLM Product Configuration

```makefile
PRODUCTNAME_MLM ?= 'SUSE Multi-Linux Manager'
```
**Purpose:** Full product name for MLM  
**Used In:** PDF generation, AsciiDoc attribute  
**Appears As:** `{productname}` in documentation

```makefile
FILENAME_MLM ?= suse_multi_linux_manager
```
**Purpose:** Filename prefix for MLM PDFs  
**Used In:** PDF output names  
**Example:** `suse_multi_linux_manager_administration_guide.pdf`

```makefile
MLM_CONTENT ?= true
```
**Purpose:** Enable MLM-specific content  
**Used In:** AsciiDoc conditional directives  
**Example:** `ifdef::mlm-content[]` ... `endif::[]`

### Uyuni Product Configuration

```makefile
PRODUCTNAME_UYUNI ?= 'Uyuni'
```
**Purpose:** Full product name for Uyuni  
**Used In:** PDF generation, AsciiDoc attribute

```makefile
FILENAME_UYUNI ?= uyuni
```
**Purpose:** Filename prefix for Uyuni PDFs  
**Example:** `uyuni_administration_guide.pdf`

```makefile
UYUNI_CONTENT ?= true
```
**Purpose:** Enable Uyuni-specific content  
**Used In:** AsciiDoc conditional directives  
**Example:** `ifdef::uyuni-content[]` ... `endif::[]`

## PDF Configuration Variables

### PDF Resource Locations

```makefile
PDF_FONTS_DIR ?= branding/pdf/fonts
```
**Purpose:** Directory containing PDF fonts  
**Contains:**
- Open Sans (regular, bold, italic)
- Noto Sans CJK (for Japanese, Chinese, Korean)
- Droid Sans Fallback

**Used By:** asciidoctor-pdf `-a pdf-fontsdir`

```makefile
PDF_THEME_DIR ?= branding/pdf/themes
```
**Purpose:** Directory containing PDF themes  
**Contains:**
- `suse.yml` - SUSE theme (English)
- `suse-jp.yml` - SUSE theme (Japanese)
- `suse-sc.yml` - SUSE theme (Simplified Chinese)
- `suse-ko.yml` - SUSE theme (Korean)
- `uyuni.yml` - Uyuni theme
- `uyuni-cjk.yml` - Uyuni theme (CJK languages)
- `uyuni-draft.yml` - Uyuni draft theme

**Used By:** asciidoctor-pdf `-a pdf-themesdir`

### PDF Theme Selection

```makefile
PDF_THEME_UYUNI ?= uyuni
```
**Purpose:** Default Uyuni PDF theme  
**Options:**
- `uyuni` - Production theme
- `uyuni-draft` - Draft with watermark

```makefile
PDF_THEME_UYUNI_CJK ?= uyuni-cjk
```
**Purpose:** Uyuni theme for CJK languages  
**Used For:** Japanese, Chinese, Korean PDFs  
**Features:** CJK font support, proper character spacing

**Language-Specific Themes (from parameters.yml):**
```yaml
languages:
  - langcode: "en"
    pdf_theme_mlm: "suse"
    pdf_theme_uyuni: "uyuni"
  - langcode: "ja"
    pdf_theme_mlm: "suse-jp"
    pdf_theme_uyuni: "uyuni-cjk"
  - langcode: "zh_CN"
    pdf_theme_mlm: "suse-sc"
    pdf_theme_uyuni: "uyuni-cjk"
  - langcode: "ko"
    pdf_theme_mlm: "suse-ko"
    pdf_theme_uyuni: "uyuni-cjk"
```

## Build Directory Variables

```makefile
HTML_BUILD_DIR := build
```
**Purpose:** Root directory for all build output  
**Structure:**
```
build/
├── en/
├── ja/
├── zh_CN/
├── ko/
└── packages/
```

```makefile
CURDIR ?= .
```
**Purpose:** Current directory (usually project root)  
**Default:** `.` (current directory)

```makefile
current_dir := $(dir $(mkfile_path))
```
**Purpose:** Absolute path to directory containing Makefile  
**Calculation:**
```makefile
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(dir $(mkfile_path))
```
**Result:** Full path like `/home/user/uyuni-docs/`

## Branding Variables

### Supplemental Files

```makefile
SUPPLEMENTAL_FILES_MLM=$(shell grep supplemental_files site.yml | cut -d ':' -f 2 | sed "s, ,,g")/partials/header-content.hbs
```
**Purpose:** Path to MLM header template for language selector  
**Dynamically Extracted From:** `site.yml`  
**Example Value:** `./branding/supplemental-ui/mlm/susecom-2025/partials/header-content.hbs`

**How It Works:**
1. `grep supplemental_files site.yml` - Find the line
2. `cut -d ':' -f 2` - Extract path after colon
3. `sed "s, ,,g"` - Remove spaces
4. Append `/partials/header-content.hbs`

```makefile
SUPPLEMENTAL_FILES_UYUNI=$(shell grep supplemental_files site.yml | cut -d ':' -f 2 | sed "s, ,,g")/partials/header-content.hbs
```
**Purpose:** Path to Uyuni header template  
**Example Value:** `./branding/supplemental-ui/uyuni/uyuni-2023/partials/header-content.hbs`

**Used By:** Language selector injection

## Language Configuration Variables

Defined in `parameters.yml` and used by generated Makefiles:

### English (en)

```yaml
langcode: "en"
locale: "en_US.utf8"
gnudateformat: "%B %d %Y"
pdf_theme_mlm: "suse"
pdf_theme_uyuni: "uyuni"
```

### Japanese (ja)

```yaml
langcode: "ja"
locale: "ja_JP.UTF-8"
gnudateformat: "%Y年%m月%e日"
pdf_theme_mlm: "suse-jp"
pdf_theme_uyuni: "uyuni-cjk"
flag_svg_without_ext: "jaFlag"
nation_in_eng: "japan"
language_in_orig: "日本語"
asciidoctor_pdf_additional_attributes: "-a scripts=cjk"
```

**Language Selector Variables:**
- `flag_svg_without_ext` - Flag icon filename (without .svg)
- `nation_in_eng` - CSS class name
- `language_in_orig` - Display name in native language

### Chinese Simplified (zh_CN)

```yaml
langcode: "zh_CN"
locale: "zh_CN.UTF-8"
gnudateformat: "%Y年%m月%e日"
pdf_theme_mlm: "suse-sc"
pdf_theme_uyuni: "uyuni-cjk"
flag_svg_without_ext: "china"
nation_in_eng: "china"
language_in_orig: "中文"
asciidoctor_pdf_additional_attributes: "-a scripts=cjk"
```

### Korean (ko)

```yaml
langcode: "ko"
locale: "ko_KR.UTF-8"
gnudateformat: "%Y년%m월%e일"
pdf_theme_mlm: "suse-ko"
pdf_theme_uyuni: "uyuni-cjk"
flag_svg_without_ext: "koFlag"
nation_in_eng: "korea"
language_in_orig: "한국어"
asciidoctor_pdf_additional_attributes: "-a scripts=cjk"
```

## Environment Variables

### Antora Build Environment

Set when running Antora:

```makefile
DOCSEARCH_ENABLED=true
```
**Purpose:** Enable search functionality  
**Effect:** Generates search indexes

```makefile
SITE_SEARCH_PROVIDER=lunr
```
**Purpose:** Search engine to use  
**Value:** `lunr` (Lunr.js client-side search)

```makefile
LANG=<locale>
LC_ALL=<locale>
```
**Purpose:** Set locale for proper character handling  
**Examples:**
- `LANG=en LC_ALL=en_US.utf8` (English)
- `LANG=ja LC_ALL=ja_JP.UTF-8` (Japanese)
- `LANG=zh_CN LC_ALL=zh_CN.UTF-8` (Chinese)
- `LANG=ko LC_ALL=ko_KR.UTF-8` (Korean)

### PDF Build Environment

Set when running asciidoctor-pdf:

```makefile
LANG=<locale>
LC_ALL=<locale>
LC_TYPE=<locale>
```
**Purpose:** Locale for date formatting and character handling

## Make Function Parameters

### Common Parameters

Most build functions accept these standard parameters:

**$(1) - Translation Directory**
- Example: `translations/en`, `translations/ja`
- Purpose: Source directory for content

**$(2) - PDF Theme**
- Example: `suse`, `suse-jp`, `uyuni-cjk`
- Purpose: PDF theme to apply

**$(3) - Product Name**
- Example: `'SUSE Multi-Linux Manager'`, `'Uyuni'`
- Purpose: Product name for title pages

**$(4) - Product Content Flag**
- Example: `true`, `false`
- Purpose: Enable product-specific content

**$(5) - Filename Prefix**
- Example: `suse_multi_linux_manager`, `uyuni`
- Purpose: Output filename prefix

**$(6) - Module Name**
- Example: `administration`, `client-configuration`
- Purpose: Documentation module to build

**$(7) - Output Directory**
- Example: `$(current_dir)/build/en/pdf`
- Purpose: Where to write PDF files

**$(8) - Language Code**
- Example: `en`, `ja`, `zh_CN`, `ko`
- Purpose: Language identifier

**$(9) - System Locale**
- Example: `en_US.utf8`, `ja_JP.UTF-8`
- Purpose: Locale for date formatting

**$(10) - Date Format**
- Example: `%B %d %Y`, `%Y年%m月%e日`
- Purpose: GNU date format string

**$(11) - Additional Attributes**
- Example: `-a scripts=cjk`
- Purpose: Extra asciidoctor options

## Variable Overrides

All variables can be overridden:

### From Command Line

```bash
# Override product name
make antora-mlm PRODUCTNAME_MLM='My Custom Product'

# Override PDF theme
make pdf-all-uyuni-en PDF_THEME_UYUNI=uyuni-draft

# Override build directory
make antora-mlm HTML_BUILD_DIR=/tmp/build
```

### From Environment

```bash
# Set in environment
export PDF_FONTS_DIR=/usr/share/fonts/pdf
export PDF_THEME_DIR=/custom/themes

# Run make
make pdf-all-mlm
```

### In Makefile

Edit `Makefile` to change defaults:

```makefile
# Change default theme
PDF_THEME_UYUNI ?= uyuni-draft  # Add watermark

# Change product name
PRODUCTNAME_UYUNI ?= 'Uyuni Project'
```

## Variable Precedence

Order of precedence (highest to lowest):

1. **Command-line override** - `make VAR=value`
2. **Environment variable** - `export VAR=value`
3. **Makefile assignment** - `VAR ?= default`
4. **Makefile default** - Hard-coded in Makefile

**Example:**

```bash
# Precedence demonstration
export PDF_THEME_UYUNI=theme1           # Environment: theme1
make pdf-all-uyuni-en                    # Uses: theme1
make pdf-all-uyuni-en PDF_THEME_UYUNI=theme2  # Uses: theme2 (command-line wins)
```

## Common Variable Patterns

### Language-Specific Variables

Variables often have language suffixes:

```makefile
# Pattern: <base>_<langcode>
pdf-theme_mlm_en=suse
pdf-theme_mlm_ja=suse-jp
pdf-theme_mlm_zh_CN=suse-sc
pdf-theme_mlm_ko=suse-ko
```

### Product-Specific Variables

Variables often have product suffixes:

```makefile
# Pattern: <base>_<product>
PRODUCTNAME_MLM='SUSE Multi-Linux Manager'
PRODUCTNAME_UYUNI='Uyuni'
FILENAME_MLM=suse_multi_linux_manager
FILENAME_UYUNI=uyuni
```

### Path Variables

Directory paths typically use absolute paths:

```makefile
# Generated at runtime
current_dir = /home/user/uyuni-docs/
HTML_BUILD_DIR = build
FULL_BUILD_PATH = $(current_dir)/$(HTML_BUILD_DIR)
# Result: /home/user/uyuni-docs/build/
```

## Variable Usage Examples

### Example 1: PDF Generation

```makefile
# When calling pdf-book-create function:
$(call pdf-book-create,
    translations/ja,              # $(1) Translation dir
    suse-jp,                      # $(2) PDF theme
    'SUSE Multi-Linux Manager',   # $(3) Product name
    true,                         # $(4) MLM content flag
    suse_multi_linux_manager,     # $(5) Filename prefix
    administration,               # $(6) Module name
    $(current_dir)/build/ja/pdf,  # $(7) Output dir
    ja,                           # $(8) Language code
    ja_JP.UTF-8,                  # $(9) Locale
    %Y年%m月%e日,                  # $(10) Date format
    -a scripts=cjk                # $(11) Additional attrs
)
```

**Result:**
```
Output: build/ja/pdf/suse_multi_linux_manager_administration_guide.pdf
Theme: branding/pdf/themes/suse-jp.yml
Fonts: branding/pdf/fonts/
Locale: ja_JP.UTF-8
Date: 2025年10月20日
```

### Example 2: Antora Build

```makefile
# When calling antora-mlm-function:
$(call antora-mlm-function,
    translations/ja,    # $(1) Translation dir
    ja                  # $(2) Language code
)
```

**Expands To:**
```bash
cd translations/ja && \
DOCSEARCH_ENABLED=true \
SITE_SEARCH_PROVIDER=lunr \
LANG=ja \
LC_ALL=ja_JP.UTF-8 \
npx antora mlm-site.yml --stacktrace
```

### Example 3: Variable Substitution in Templates

**Jinja2 Template (`Makefile.j2`):**
```makefile
.PHONY: pdf-administration-mlm-{{ langcode }}
pdf-administration-mlm-{{ langcode }}: prepare-antora-mlm-{{ langcode }}
	$(call pdf-administration-product,
	    translations/{{ langcode }},
	    {{ pdf_theme_mlm }},
	    $(PRODUCTNAME_MLM),
	    $(MLM_CONTENT),
	    $(FILENAME_MLM),
	    $(current_dir)/build/{{ langcode }}/pdf,
	    {{ langcode }},
	    {{ locale }},
	    {{ gnudateformat }},
	    {{ asciidoctor_pdf_additional_attributes if asciidoctor_pdf_additional_attributes else '' }}
	)
```

**Generated for Japanese (`Makefile.ja`):**
```makefile
.PHONY: pdf-administration-mlm-ja
pdf-administration-mlm-ja: prepare-antora-mlm-ja
	$(call pdf-administration-product,
	    translations/ja,
	    suse-jp,
	    $(PRODUCTNAME_MLM),
	    $(MLM_CONTENT),
	    $(FILENAME_MLM),
	    $(current_dir)/build/ja/pdf,
	    ja,
	    ja_JP.UTF-8,
	    %Y年%m月%e日,
	    -a scripts=cjk
	)
```

## Troubleshooting Variables

### Check Current Values

```bash
# Print variable value
make -n antora-mlm-en | grep PRODUCTNAME_MLM

# Print all variables
make -p | grep "^PDF_"

# Debug specific variable
make --eval='$(info PDF_THEME_UYUNI=$(PDF_THEME_UYUNI))' antora-uyuni-en
```

### Common Issues

**Issue: Wrong PDF theme applied**

Check:
```bash
make -n pdf-all-mlm-ja | grep pdf-theme
# Should show: suse-jp
```

**Issue: Wrong product name in output**

Check:
```bash
grep "PRODUCTNAME_MLM" Makefile
# Should show: PRODUCTNAME_MLM ?= 'SUSE Multi-Linux Manager'
```

**Issue: Wrong locale/encoding**

Check:
```bash
make -n antora-mlm-ja | grep "LANG="
# Should show: LANG=ja
```

## Related Documentation

- [BUILD_SYSTEM_OVERVIEW.md](BUILD_SYSTEM_OVERVIEW.md) - Build system introduction
- [BUILD_FUNCTIONS.md](BUILD_FUNCTIONS.md) - Make function reference
- [BUILD_TARGETS.md](BUILD_TARGETS.md) - Make target reference
- [CONFIGURE_SCRIPT.md](CONFIGURE_SCRIPT.md) - Configuration generator

---

**Next:** See [BUILD_FUNCTIONS.md](BUILD_FUNCTIONS.md) for function definitions.
