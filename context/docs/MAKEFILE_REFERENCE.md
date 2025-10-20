# Makefile Reference Documentation

**Version:** 1.0  
**Last Updated:** October 20, 2025  
**Authors:** Joseph Cayouette, Pau Garcia Quiles

## Table of Contents
1. [Overview](#overview)
2. [File Structure](#file-structure)
3. [Configuration Variables](#configuration-variables)
4. [Make Functions](#make-functions)
5. [Public Targets](#public-targets)
6. [Language-Specific Targets](#language-specific-targets)
7. [Build Flow](#build-flow)
8. [Examples](#examples)
9. [Troubleshooting](#troubleshooting)

---

## Overview

The uyuni-docs build system uses a modular Makefile architecture to generate documentation for two products:
- **SUSE Multi-Linux Manager (MLM)** - Commercial product
- **Uyuni** - Open-source upstream project

The system supports:
- **Multi-language builds** (English, Japanese, Chinese, Korean)
- **Multiple output formats** (HTML via Antora, PDF via asciidoctor-pdf)
- **Translation management** (Weblate integration)
- **OBS package generation** for distribution

### Makefile Architecture

```
Makefile (main)
├── Makefile.section.functions  (PDF generation functions per section)
├── Makefile.lang               (Language includes)
│   ├── Makefile.en
│   ├── Makefile.ja
│   ├── Makefile.zh_CN
│   └── Makefile.ko
└── Makefile.lang.target        (Multi-language orchestration targets)
```

**Build Process:**
1. `configure` script generates language-specific Makefiles from templates
2. Main `Makefile` provides core functions and orchestration
3. `Makefile.lang` includes all language-specific Makefiles
4. `Makefile.lang.target` provides multi-language umbrella targets
5. `Makefile.section.functions` defines PDF generation per documentation module

---

## File Structure

### Source Files (Templates)
- `Makefile.j2` - Template for language-specific Makefiles
- `Makefile.section.functions.j2` - Template for PDF section builders
- `Makefile.lang.target.j2` - Template for multi-language targets

### Generated Files
- `Makefile.en`, `Makefile.ja`, `Makefile.zh_CN`, `Makefile.ko` - Language-specific Makefiles
- `Makefile.section.functions` - PDF builder functions
- `Makefile.lang` - Language includes
- `Makefile.lang.target` - Multi-language orchestration

### Configuration Files
- `site.yml` - Antora site configuration
- `antora.yml` - Component configuration
- `l10n-weblate/*.cfg` - Weblate translation configuration

---

## Configuration Variables

### Product Configuration

```makefile
# MLM Product Settings
PRODUCTNAME_MLM ?= 'SUSE Multi-Linux Manager'
FILENAME_MLM ?= suse_multi_linux_manager
MLM_CONTENT ?= true

# Uyuni Product Settings
PRODUCTNAME_UYUNI ?= 'Uyuni'
FILENAME_UYUNI ?= uyuni
UYUNI_CONTENT ?= true
```

**Usage:** These variables control conditional content in AsciiDoc files via `ifdef` directives.

### PDF Configuration

```makefile
# PDF Resource Locations
PDF_FONTS_DIR ?= branding/pdf/fonts
PDF_THEME_DIR ?= branding/pdf/themes

# PDF Themes
PDF_THEME_UYUNI ?= uyuni            # Standard Uyuni theme
PDF_THEME_UYUNI_CJK ?= uyuni-cjk    # CJK (Chinese, Japanese, Korean) theme
```

**PDF Theme Selection:**
- English: `uyuni` or `suse`
- Japanese: `suse-jp` or `uyuni-cjk`
- Chinese: `suse-sc` or `uyuni-cjk`
- Korean: `suse-ko` or `uyuni-cjk`

### Build Directories

```makefile
HTML_BUILD_DIR := build              # Root build directory
CURDIR ?= .                          # Current directory
current_dir := $(dir $(mkfile_path)) # Absolute path to Makefile directory
```

**Directory Structure:**
```
build/
├── en/
│   ├── (HTML files from Antora)
│   └── pdf/
├── ja/
│   ├── (HTML files from Antora)
│   └── pdf/
├── zh_CN/
└── ko/
```

### Supplemental Files

```makefile
SUPPLEMENTAL_FILES_MLM=$(shell grep supplemental_files site.yml | cut -d ':' -f 2 | sed "s, ,,g")/partials/header-content.hbs
SUPPLEMENTAL_FILES_UYUNI=$(shell grep supplemental_files site.yml | cut -d ':' -f 2 | sed "s, ,,g")/partials/header-content.hbs
```

**Purpose:** Dynamically extracts the supplemental files path from `site.yml` for UI customization (branding, language selectors).

---

## Make Functions

### Product Validation

```makefile
define validate-product
	cd $(current_dir)/$(1)
	NODE_PATH="$(npm -g root)" antora --generator @antora/xref-validator $(2)
endef
```

**Parameters:**
1. Translation directory (e.g., `translations/en`)
2. Site configuration file (e.g., `mlm-site.yml`)

**Purpose:** Validates cross-references (xrefs) in documentation using Antora's validator.

**Usage:**
```makefile
$(call validate-product,translations/en,mlm-site.yml)
```

### Antora Configuration

#### Enable MLM in antora.yml

```makefile
define enable-mlm-in-antorayml
	$(call reset-html-language-selector-mlm)
	cd ./$(1) && \
	sed -i "s/^ # *\(name: *docs\)/\1/;\
	s/^ # *\(title: *docs\)/\1/;\
	s/^ *\(title: *Uyuni\)/#\1/;\
	s/^ *\(name: *uyuni\)/#\1/;" $(current_dir)/$(1)/antora.yml
	cd $(current_dir)
endef
```

**Purpose:** Modifies `antora.yml` to enable MLM component and disable Uyuni component.

**sed Operations:**
- Uncomment `name: docs` and `title: docs` (MLM component)
- Comment out `name: uyuni` and `title: Uyuni` (Uyuni component)

#### Enable Uyuni in antora.yml

```makefile
define enable-uyuni-in-antorayml
	$(call reset-html-language-selector-uyuni)
	cd $(current_dir)/$(1) && \
	sed -i "s/^ *\(name: *docs\)/#\1/;\
	s/^ *\(title: *Docs\)/#\1/;\
	s/^ *# *\(title: *Uyuni\)/\1/;\
	s/^ *# *\(name: *uyuni\)/\1/;" $(current_dir)/$(1)/antora.yml
endef
```

**Purpose:** Opposite of above - enables Uyuni, disables MLM.

### Antora Build Functions

#### MLM Antora Build

```makefile
define antora-mlm-function
	cd $(current_dir)
	$(call enable-mlm-in-antorayml,$(1)) && \
	cd $(current_dir)/$(1) && DOCSEARCH_ENABLED=true SITE_SEARCH_PROVIDER=lunr LANG=$(2) LC_ALL=$(2) LC_ALL=$(2) npx antora $(current_dir)/$(1)/mlm-site.yml --stacktrace
endef
```

**Parameters:**
1. Translation directory (e.g., `translations/en`)
2. Locale (e.g., `en`, `ja_JP.UTF-8`)

**Environment Variables:**
- `DOCSEARCH_ENABLED=true` - Enables search functionality
- `SITE_SEARCH_PROVIDER=lunr` - Uses Lunr.js for client-side search
- `LANG`, `LC_ALL` - Sets locale for proper character handling

**Purpose:** Builds MLM HTML documentation with Antora.

#### Uyuni Antora Build

```makefile
define antora-uyuni-function
	cd $(current_dir)
	$(call enable-uyuni-in-antorayml,$(1)) && \
	cd $(current_dir)/$(1) && DOCSEARCH_ENABLED=true SITE_SEARCH_PROVIDER=lunr LANG=$(2) LC_ALL=$(2) LC_ALL=$(2) npx antora $(current_dir)/$(1)/uyuni-site.yml
endef
```

**Purpose:** Same as MLM but for Uyuni product.

### Language Selector Functions

```makefile
define enable-html-language-selector
	cd $(current_dir)
	sed -n -i 'p; s,<\!--\ LANGUAGESELECTOR\ -->,<a role=\"button\" class=\"navbar-item\" id=\"$(1)\" onclick="selectLanguage(this.id)"><img src="{{uiRootPath}}/img/$(2).svg" class="langIcon $(3)">\&nbsp;$(4)</a>,p' translations/$(5)
endef
```

**Parameters:**
1. Language code (e.g., `zh_CN`)
2. Flag icon filename (e.g., `china`)
3. CSS class for icon (e.g., `china`)
4. Display name (e.g., `中文`)
5. Supplemental files path

**Purpose:** Injects language selector buttons into the HTML navigation bar.

**How It Works:**
- Finds the `<!-- LANGUAGESELECTOR -->` placeholder in `header-content.hbs`
- Duplicates the line and replaces the comment with an HTML button
- Each language gets its own button with flag icon

### PDF Generation Functions

#### PDF Book Creation (MLM)

```makefile
define pdf-book-create
	cd $(current_dir)/$(1) && LANG=$(9) LC_ALL=$(9) LC_TYPE=$(9) asciidoctor-pdf \
		-r $(current_dir)/extensions/xref-converter.rb \
		-a lang=$(8) \
		-a pdf-themesdir=$(PDF_THEME_DIR)/ \
		-a pdf-theme=$(2) \
		-a pdf-fontsdir=$(PDF_FONTS_DIR) \
		-a productname=$(3) \
		-a mlm-content=$(4) \
		-a examplesdir=modules/$(6)/examples \
		-a imagesdir=modules/$(6)/assets/images \
		-a revdate="$(shell LANG=$(9) LC_ALL=$(9) LC_TYPE=$(9) date +'$(10)')" \
		$(11) \
		--base-dir . \
		--out-file $(7)/$(5)_$(6)_guide.pdf \
		modules/$(6)/nav-$(6)-guide.pdf.$(8).adoc \
		--trace
endef
```

**Parameters:**
1. Translation directory
2. PDF theme name
3. Product name
4. Product content flag (true/false)
5. Output filename prefix
6. Module name (e.g., `installation-and-upgrade`)
7. Output directory
8. Language code
9. System locale for date formatting
10. Date format string
11. Additional asciidoctor options (e.g., `-a scripts=cjk`)

**Purpose:** Generates a single PDF guide for a specific module.

**Example Output:** `build/en/pdf/suse_multi_linux_manager_installation-and-upgrade_guide.pdf`

#### PDF Book Creation (Uyuni)

```makefile
define pdf-book-create-uyuni
	# Same as pdf-book-create but uses -a uyuni-content instead of -a mlm-content
endef
```

#### PDF Index Generation

```makefile
define pdf-book-create-index
	cd $(current_dir)
	sed -E  -e 's/\*\*\*\*\*\ xref\:(.*)\.adoc\[(.*)\]/include\:\:modules\/$(2)\/pages\/\1\.adoc\[leveloffset\=\+4\]/' \
		-e 's/\*\*\*\*\ xref\:(.*)\.adoc\[(.*)\]/include\:\:modules\/$(2)\/pages\/\1\.adoc\[leveloffset\=\+3\]/' \
		-e 's/\*\*\*\ xref\:(.*)\.adoc\[(.*)\]/include\:\:modules\/$(2)\/pages\/\1\.adoc\[leveloffset\=\+2\]/' \
		-e 's/\*\*\ xref\:(.*)\.adoc\[(.*)\]/include\:\:modules\/$(2)\/pages\/\1\.adoc\[leveloffset\=\+1\]/' \
		-e 's/\*\ xref\:(.*)\.adoc\[(.*)\]/include\:\:modules\/$(2)\/pages\/\1\.adoc\[leveloffset\=\+0\]/' \
		-e 's/\*\*\*\*\ (.*)/==== \1/' \
		-e 's/\*\*\*\ (.*)/=== \1/' \
		-e 's/\*\*\ (.*)/== \1/' \
		-e 's/\*\ (.*)/= \1/' \
		$(1)/modules/$(2)/nav-$(2)-guide.adoc > $(1)/modules/$(2)/nav-$(2)-guide.pdf.$(3).adoc
endef
```

**Parameters:**
1. Translation directory
2. Module name
3. Language code

**Purpose:** Converts Antora navigation files to PDF-suitable index files.

**Transformation:**
- Converts `xref:` links to `include::` directives for full content inclusion
- Converts list bullets to heading levels
- Adjusts heading levels based on nesting depth

**Example:**
```asciidoc
# Input (nav-installation-and-upgrade-guide.adoc):
* xref:install-intro.adoc[Introduction]
** xref:install-requirements.adoc[Requirements]

# Output (nav-installation-and-upgrade-guide.pdf.en.adoc):
= Introduction
include::modules/installation-and-upgrade/pages/install-intro.adoc[leveloffset=+0]
== Requirements
include::modules/installation-and-upgrade/pages/install-requirements.adoc[leveloffset=+1]
```

### Cleanup Functions

```makefile
define clean-function
	cd $(current_dir)
	rm -rf build/$(2)          # e.g. build/en
	rm -rf $(1)                # e.g. translations/en
	rm -rf Makefile.$(2)
	find . -name "*pdf.$(2).adoc" -type f -exec rm -f {} \;
endef

define clean-branding
	cd $(current_dir)
	rm -rf $(current_dir)/translations/$(1)/branding
endef

define copy-branding
	cd $(current_dir)
	mkdir -p $(current_dir)/translations/$(1)
	cp -a $(current_dir)/branding $(current_dir)/translations/$(1)/
endef
```

### Packaging Functions

```makefile
define pdf-tar-product
	cd $(current_dir)/$(HTML_BUILD_DIR) && zip -r9 $(2).zip $(shell realpath --relative-to=`pwd`/$(HTML_BUILD_DIR) $(3)) && mv $(2).zip $(1)/ && cd $(current_dir)
endef

define obs-packages-product
	cd $(current_dir)
	tar --exclude='$(2)' -czvf $(3).tar.gz -C $(current_dir) $(HTML_BUILD_DIR)/$(1) && tar -czvf $(4).tar.gz -C $(current_dir) $(HTML_BUILD_DIR)/$(2)
	mkdir -p build/packages
	mv $(3).tar.gz $(4).tar.gz build/packages
endef
```

**Purpose:** Creates distribution packages for Open Build Service (OBS).

---

## Public Targets

### Configuration Targets

#### `make configure-mlm`
**Purpose:** Generates MLM-specific build files from Jinja2 templates.

**What It Does:**
```bash
./configure mlm
```

**Generated Files:**
- `Makefile.en`, `Makefile.ja`, `Makefile.zh_CN`, `Makefile.ko`
- `Makefile.section.functions`
- `Makefile.lang`
- `Makefile.lang.target`
- Language-specific `antora.yml` files

**When to Use:** Before any MLM build.

#### `make configure-uyuni`
**Purpose:** Generates Uyuni-specific build files.

```bash
./configure uyuni
```

**When to Use:** Before any Uyuni build.

### Translation Targets

#### `make update-cfg-files`
**Purpose:** Updates Weblate configuration files.

**Command:**
```bash
cd l10n-weblate && ./update-cfg-files
```

**When to Use:** When documentation structure changes (new files, moved files).

#### `make pot`
**Purpose:** Extracts translatable strings into POT (Portable Object Template) files.

**Dependencies:** `update-cfg-files`

**Command:**
```bash
./make_pot.sh
```

**What It Creates:**
```
l10n-weblate/
├── administration/
│   └── *.pot files
├── client-configuration/
│   └── *.pot files
└── ... (one directory per module)
```

**When to Use:** 
- After adding/modifying documentation content
- Before uploading to Weblate for translation

#### `make translations`
**Purpose:** Applies PO files to generate translated AsciiDoc content.

**Command:**
```bash
./use_po.sh
```

**What It Does:**
1. Reads PO files from `l10n-weblate/<lang>/`
2. Applies translations to source AsciiDoc files
3. Creates translated files in `translations/<lang>/modules/`

**Input:** `l10n-weblate/ja/*.po`, `l10n-weblate/zh_CN/*.po`, etc.

**Output:** `translations/ja/modules/`, `translations/zh_CN/modules/`, etc.

**When to Use:** After receiving updated translations from Weblate.

### Branding Targets

#### `make copy-branding`
**Purpose:** Copies branding files to translations directory.

```bash
mkdir -p translations
cp -a branding translations/
```

#### `make configure-mlm-branding-dsc`
**Purpose:** Configures MLM branding for documentation.suse.com.

**What It Does:**
```bash
sed -i -e 's|supplemental_files: ./branding/supplemental-ui/mlm/.*|supplemental_files: ./branding/supplemental-ui/mlm/susecom-2025|' site.yml
```

#### `make configure-mlm-branding-webui`
**Purpose:** Configures MLM branding for WebUI embedding.

```bash
sed -i -e 's|supplemental_files: ./branding/supplemental-ui/mlm/.*|supplemental_files: ./branding/supplemental-ui/mlm/webui-2025|' site.yml
```

### Language Selector Targets

#### `make set-html-language-selector-mlm`
**Purpose:** Adds language selector buttons to MLM HTML navigation.

**Languages Added:**
- Chinese (`zh_CN`)
- Japanese (`ja`)
- Korean (`ko`)

**Visual Result:** Flag icons in top navigation bar for language switching.

#### `make set-html-language-selector-uyuni`
**Purpose:** Same as above but for Uyuni.

### Build Targets

#### `make antora-mlm`
**Purpose:** Builds complete MLM HTML documentation for all languages.

**Dependencies:**
- `configure-mlm`
- `copy-branding`
- `antora-mlm-en`
- `antora-mlm-ja`
- `antora-mlm-zh_CN`
- `antora-mlm-ko`

**What It Builds:**
```
build/
├── en/
│   └── (MLM HTML docs)
├── ja/
│   └── (MLM HTML docs)
├── zh_CN/
│   └── (MLM HTML docs)
└── ko/
    └── (MLM HTML docs)
```

**When to Use:** To generate complete MLM documentation site.

**Time:** ~10-30 minutes depending on system.

#### `make antora-uyuni`
**Purpose:** Builds complete Uyuni HTML documentation for all languages.

**Similar to:** `antora-mlm` but for Uyuni product.

#### `make pdf-all-mlm`
**Purpose:** Generates all MLM PDF guides for all languages.

**What It Builds:**
```
build/
├── en/pdf/
│   ├── suse_multi_linux_manager_installation-and-upgrade_guide.pdf
│   ├── suse_multi_linux_manager_client-configuration_guide.pdf
│   ├── suse_multi_linux_manager_administration_guide.pdf
│   └── ... (all guides)
├── ja/pdf/
├── zh_CN/pdf/
└── ko/pdf/
```

**Time:** 30-60 minutes depending on system.

#### `make pdf-all-uyuni`
**Purpose:** Generates all Uyuni PDF guides for all languages.

### Packaging Targets

#### `make obs-packages-mlm`
**Purpose:** Creates OBS (Open Build Service) distribution packages for MLM.

**Dependencies:**
- `configure-mlm`
- `clean`
- `obs-packages-mlm-en`
- `obs-packages-mlm-ja`
- `obs-packages-mlm-zh_CN`
- `obs-packages-mlm-ko`

**What It Creates:**
```
build/packages/
├── susemanager-docs_en.tar.gz       # HTML docs
├── susemanager-docs_en-pdf.tar.gz   # PDF docs
├── susemanager-docs_ja.tar.gz
├── susemanager-docs_ja-pdf.tar.gz
├── ... (all languages)
```

**When to Use:** For production release builds.

#### `make obs-packages-uyuni`
**Purpose:** Same as above but for Uyuni.

**Output:**
```
build/packages/
├── uyuni-docs_en.tar.gz
├── uyuni-docs_en-pdf.tar.gz
├── ... (all languages)
```

### Validation Targets

#### `make validate-mlm`
**Purpose:** Validates all cross-references in MLM documentation.

**What It Checks:**
- Broken `xref:` links
- Missing pages
- Invalid anchor references

**Languages:** All (en, ja, zh_CN, ko)

**When to Use:** Before committing changes, after restructuring.

#### `make validate-uyuni`
**Purpose:** Same as above but for Uyuni.

### Quality Targets

#### `make checkstyle`
**Purpose:** Enforces documentation style guidelines.

**What It Checks:**
- `ifeval` directive usage
- Comment formatting in navigation files
- Style compliance

**When to Use:** Before committing changes.

#### `make checkstyle-autofix`
**Purpose:** Automatically fixes style issues.

**Warning:** Review changes before committing.

### Cleanup Targets

#### `make clean`
**Purpose:** Removes all build artifacts.

**What It Removes:**
- `build/` directory (all HTML and PDF output)
- `translations/` directory (all translated content)

**When to Use:** 
- Before a clean rebuild
- To free disk space
- When troubleshooting build issues

#### `make clean-branding`
**Purpose:** Removes only branding files from translations.

### Complete Build Targets

#### `make all-mlm`
**Purpose:** Complete MLM build from configuration to packaging.

**Equivalent to:**
```bash
make configure-mlm
make obs-packages-mlm
```

**When to Use:** For full production builds.

#### `make all-uyuni`
**Purpose:** Complete Uyuni build.

### Publication Targets

#### `make antora-mlm-for-publication`
**Purpose:** Builds MLM documentation marked for publication.

**What It Does:**
1. Creates `for-publication` marker file
2. Runs `antora-mlm`

**Effect:** May enable/disable certain build features for production.

#### `make antora-uyuni-for-publication`
**Purpose:** Same as above for Uyuni.

---

## Language-Specific Targets

Each language has its own set of targets following this pattern:

### English (`-en`)

```makefile
make antora-mlm-en              # Build MLM HTML (English)
make antora-uyuni-en            # Build Uyuni HTML (English)
make pdf-all-mlm-en             # Build all MLM PDFs (English)
make pdf-all-uyuni-en           # Build all Uyuni PDFs (English)
make obs-packages-mlm-en        # Create MLM OBS packages (English)
make obs-packages-uyuni-en      # Create Uyuni OBS packages (English)
make validate-mlm-en            # Validate MLM docs (English)
make validate-uyuni-en          # Validate Uyuni docs (English)
make clean-en                   # Clean English build artifacts
```

### Japanese (`-ja`)

```makefile
make antora-mlm-ja              # Build MLM HTML (Japanese)
make antora-uyuni-ja            # Build Uyuni HTML (Japanese)
# ... (same pattern as English)
```

**Locale:** `ja_JP.UTF-8`

**Date Format:** `%Y年%m月%e日` (e.g., "2025年10月20日")

**PDF Theme:** `suse-jp`, `uyuni-cjk` (supports CJK fonts)

**Additional Options:** `-a scripts=cjk`

### Chinese (`-zh_CN`)

```makefile
make antora-mlm-zh_CN           # Build MLM HTML (Chinese)
make antora-uyuni-zh_CN         # Build Uyuni HTML (Chinese)
# ... (same pattern)
```

**Locale:** `zh_CN.UTF-8`

**Date Format:** `%Y年%m月%e日`

**PDF Theme:** `suse-sc`, `uyuni-cjk`

### Korean (`-ko`)

```makefile
make antora-mlm-ko              # Build MLM HTML (Korean)
make antora-uyuni-ko            # Build Uyuni HTML (Korean)
# ... (same pattern)
```

**Locale:** `ko_KR.UTF-8`

**Date Format:** `%Y년%m월%e일` (e.g., "2025년10월20일")

**PDF Theme:** `suse-ko`, `uyuni-cjk`

---

## Build Flow

### Complete Build Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. CONFIGURATION PHASE                                          │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │ make configure-mlm (or -uyuni)  │
          └─────────────────────────────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │ ./configure mlm                 │
          │ - Reads *.j2 templates          │
          │ - Generates language Makefiles  │
          │ - Creates function definitions  │
          └─────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 2. TRANSLATION PHASE (Optional - for non-English)               │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │ make update-cfg-files           │
          │ - Updates Weblate configs       │
          └─────────────────────────────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │ make pot                        │
          │ - Extracts strings → POT files  │
          └─────────────────────────────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │ [MANUAL: Upload to Weblate]     │
          │ [MANUAL: Translators work]      │
          │ [MANUAL: Download PO files]     │
          └─────────────────────────────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │ make translations               │
          │ - Applies PO → translated .adoc │
          │ - Creates translations/<lang>/  │
          └─────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 3. HTML BUILD PHASE                                             │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │ make antora-mlm (or -uyuni)     │
          └─────────────────────────────────┘
                            │
                            ├──────────────────────────────┐
                            │                              │
                            ▼                              ▼
          ┌─────────────────────────────┐  ┌─────────────────────────┐
          │ make antora-mlm-en          │  │ make antora-mlm-ja      │
          └─────────────────────────────┘  └─────────────────────────┘
                            │                              │
                            ▼                              ▼
          ┌─────────────────────────────────┐  ┌─────────────────────────┐
          │ prepare-antora-mlm-en           │  │ prepare-antora-mlm-ja   │
          │ - Copy branding                 │  │ - Copy branding         │
          │ - Set language selector         │  │ - Set language selector │
          │ - Copy modules                  │  │ - Copy modules          │
          │ - Create site.yml               │  │ - Create site.yml       │
          └─────────────────────────────────┘  └─────────────────────────┘
                            │                              │
                            ▼                              ▼
          ┌─────────────────────────────────┐  ┌─────────────────────────┐
          │ npx antora mlm-site.yml         │  │ npx antora mlm-site.yml │
          │ - Generates HTML                │  │ - Generates HTML        │
          │ - Creates search index          │  │ - Creates search index  │
          └─────────────────────────────────┘  └─────────────────────────┘
                            │                              │
                            └──────────┬───────────────────┘
                                       │
                                       ▼
          ┌─────────────────────────────────────────────────┐
          │ Output: build/en/, build/ja/, build/zh_CN/, ... │
          └─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 4. PDF BUILD PHASE                                              │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │ make pdf-all-mlm (or -uyuni)    │
          └─────────────────────────────────┘
                            │
                            ├──────────────────────────────┐
                            │                              │
                            ▼                              ▼
          ┌─────────────────────────────┐  ┌─────────────────────────┐
          │ make pdf-all-mlm-en         │  │ make pdf-all-mlm-ja     │
          └─────────────────────────────┘  └─────────────────────────┘
                            │                              │
                            ├──────────┬──────────┐        │
                            ▼          ▼          ▼        ▼
          ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
          │ pdf-    │  │ pdf-    │  │ pdf-    │  │ pdf-    │
          │ install │  │ client  │  │ admin   │  │ retail  │
          │ guide   │  │ guide   │  │ guide   │  │ guide   │
          └─────────┘  └─────────┘  └─────────┘  └─────────┘
                            │                              │
                            ▼                              ▼
          ┌─────────────────────────────────┐  ┌─────────────────────────┐
          │ pdf-book-create-index           │  │ pdf-book-create-index   │
          │ - Converts nav to includes      │  │ - Converts nav to incl. │
          └─────────────────────────────────┘  └─────────────────────────┘
                            │                              │
                            ▼                              ▼
          ┌─────────────────────────────────┐  ┌─────────────────────────┐
          │ asciidoctor-pdf                 │  │ asciidoctor-pdf         │
          │ - Applies theme                 │  │ - Applies CJK theme     │
          │ - Generates PDF                 │  │ - Generates PDF         │
          └─────────────────────────────────┘  └─────────────────────────┘
                            │                              │
                            └──────────┬───────────────────┘
                                       │
                                       ▼
          ┌─────────────────────────────────────────────────┐
          │ Output: build/*/pdf/*.pdf                       │
          └─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 5. PACKAGING PHASE                                              │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │ make obs-packages-mlm           │
          └─────────────────────────────────┘
                            │
                            ├──────────────────────────────┐
                            ▼                              ▼
          ┌─────────────────────────────┐  ┌─────────────────────────┐
          │ Create HTML tarball         │  │ Create PDF ZIP          │
          │ susemanager-docs_en.tar.gz  │  │ docs_en-pdf.tar.gz      │
          └─────────────────────────────┘  └─────────────────────────┘
                            │                              │
                            └──────────┬───────────────────┘
                                       │
                                       ▼
          ┌─────────────────────────────────────────────────┐
          │ Output: build/packages/*.tar.gz                 │
          └─────────────────────────────────────────────────┘
```

### Typical Developer Workflows

#### Workflow 1: Build English MLM HTML Only

```bash
make configure-mlm
make antora-mlm-en
```

**Output:** `build/en/` (HTML files)

**Time:** ~5 minutes

#### Workflow 2: Build All Languages MLM HTML

```bash
make configure-mlm
make antora-mlm
```

**Output:** `build/en/`, `build/ja/`, `build/zh_CN/`, `build/ko/`

**Time:** ~15-30 minutes

#### Workflow 3: Full MLM Production Build

```bash
make all-mlm
```

**Equivalent to:**
```bash
make configure-mlm
make obs-packages-mlm
  # Which internally runs:
  #   clean, pdf-all-mlm-*, antora-mlm-*, packaging
```

**Output:** 
- `build/*/` (all HTML)
- `build/*/pdf/` (all PDFs)
- `build/packages/*.tar.gz` (distribution packages)

**Time:** 1-2 hours

#### Workflow 4: Update Translations

```bash
# 1. Extract strings
make pot

# 2. [MANUAL] Upload to Weblate, translate, download PO files

# 3. Apply translations
make translations

# 4. Build with translations
make configure-mlm
make antora-mlm
```

#### Workflow 5: Test PDF Generation for One Guide

```bash
make configure-mlm
make translations  # If using non-English
make pdf-installation-and-upgrade-mlm-en
```

**Output:** `build/en/pdf/suse_multi_linux_manager_installation-and-upgrade_guide.pdf`

**Time:** ~2-5 minutes

#### Workflow 6: Clean Rebuild

```bash
make clean
make configure-mlm
make antora-mlm
```

---

## Examples

### Example 1: Quick English Build

```bash
# Start fresh
make clean

# Configure for MLM
make configure-mlm

# Build English HTML only
make antora-mlm-en

# View output
ls -lh build/en/
```

### Example 2: Validate Documentation

```bash
# Configure first
make configure-mlm

# Validate all cross-references
make validate-mlm

# Or validate single language
make validate-mlm-en
```

### Example 3: Generate Single PDF

```bash
# Configure
make configure-mlm

# Ensure translations exist (if not English)
make translations

# Generate single PDF guide
make pdf-administration-mlm-en

# View output
ls -lh build/en/pdf/suse_multi_linux_manager_administration_guide.pdf
```

### Example 4: Build with Custom Branding

```bash
# Configure MLM
make configure-mlm

# Switch to WebUI branding
make configure-mlm-branding-webui

# Build
make antora-mlm-en
```

### Example 5: Translation Workflow

```bash
# 1. Update configuration files for Weblate
make update-cfg-files

# 2. Extract translatable strings
make pot
# Output: l10n-weblate/administration/*.pot, etc.

# 3. [MANUAL STEP] 
#    - Upload POT files to Weblate
#    - Translators work in Weblate
#    - Download completed PO files to l10n-weblate/ja/, etc.

# 4. Apply translations
make translations
# Output: translations/ja/modules/, translations/zh_CN/modules/, etc.

# 5. Build translated documentation
make configure-mlm
make antora-mlm-ja

# View output
ls -lh build/ja/
```

### Example 6: Check for Style Issues

```bash
# Check for style violations
make checkstyle

# If issues found, auto-fix them
make checkstyle-autofix

# Review changes
git diff

# Commit if acceptable
git add .
git commit -m "Fix style issues"
```

### Example 7: Test CJK PDF Generation

```bash
# Configure
make configure-mlm

# Ensure translations exist
make translations

# Build Japanese PDF (uses CJK theme)
make pdf-all-mlm-ja

# View output
ls -lh build/ja/pdf/
```

### Example 8: Create Distribution Packages

```bash
# Full production build
make configure-mlm

# Generate all content
make clean
make obs-packages-mlm

# View packages
ls -lh build/packages/
# Output:
#   susemanager-docs_en.tar.gz
#   susemanager-docs_en-pdf.tar.gz
#   susemanager-docs_ja.tar.gz
#   susemanager-docs_ja-pdf.tar.gz
#   ... (all languages)
```

---

## Troubleshooting

### Issue: "make: *** No rule to make target 'antora-mlm-en'"

**Cause:** Language-specific Makefiles not generated.

**Solution:**
```bash
make configure-mlm
```

### Issue: PDF generation fails with font errors

**Cause:** Missing CJK fonts for Japanese/Chinese/Korean.

**Solution:**
- Check `branding/pdf/fonts/` directory
- Ensure CJK fonts are installed
- Verify PDF_FONTS_DIR path in Makefile

### Issue: Antora build fails with "Component not found"

**Cause:** `antora.yml` not properly configured for product.

**Solution:**
```bash
# Ensure you've configured the right product
make configure-mlm  # or configure-uyuni

# Check antora.yml
cat antora.yml
```

### Issue: Translations not appearing in build

**Cause:** `make translations` not run, or PO files missing.

**Solution:**
```bash
# Check if PO files exist
ls -l l10n-weblate/ja/

# Apply translations
make translations

# Verify translated files created
ls -l translations/ja/modules/
```

### Issue: "sed: no such file or directory"

**Cause:** Running on macOS with BSD sed instead of GNU sed.

**Solution:**
```bash
# Install GNU sed
brew install gnu-sed

# Add to PATH
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
```

### Issue: PDF build hangs or takes forever

**Cause:** Large documentation set, slow disk I/O.

**Solution:**
- Build single guides instead of all at once
- Use SSD storage
- Increase available RAM

### Issue: Language selector not appearing in HTML

**Cause:** `set-html-language-selector-*` not run.

**Solution:**
```bash
# This is normally automatic, but can be run manually
make set-html-language-selector-mlm

# Rebuild
make antora-mlm
```

### Issue: "LANG: command not found"

**Cause:** Locale environment variable issues.

**Solution:**
```bash
# Check available locales
locale -a

# If missing, install required locales (Debian/Ubuntu)
sudo apt-get install language-pack-ja language-pack-zh-hans language-pack-ko

# Or on RHEL/CentOS
sudo dnf install glibc-langpack-ja glibc-langpack-zh glibc-langpack-ko
```

### Issue: OBS package creation fails

**Cause:** Missing build output.

**Solution:**
```bash
# Ensure all build steps completed
make configure-mlm
make pdf-all-mlm
make antora-mlm

# Then create packages
make obs-packages-mlm
```

### Debug Tips

1. **Verbose Make Output:**
```bash
make -d antora-mlm-en 2>&1 | tee build.log
```

2. **Check What Will Run:**
```bash
make -n antora-mlm  # Dry run
```

3. **Check Dependencies:**
```bash
make -p | grep "^antora-mlm:"
```

4. **Test Single Language:**
```bash
# Instead of full build, test one language
make antora-mlm-en
```

---

## Related Documentation

- [DOCUMENTATION_PHASES.md](DOCUMENTATION_PHASES.md) - Complete documentation project plan
- [TEMPLATE_SYSTEM.md](TEMPLATE_SYSTEM.md) - Jinja2 template documentation (Phase 2)
- [TRANSLATION_SYSTEM.md](TRANSLATION_SYSTEM.md) - Translation workflow (Phase 3)
- [HTML_BUILD_PROCESS.md](HTML_BUILD_PROCESS.md) - Antora details (Phase 4)
- [PDF_BUILD_PROCESS.md](PDF_BUILD_PROCESS.md) - PDF generation (Phase 5)

---

**End of Makefile Reference Documentation**
