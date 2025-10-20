# Build Functions Reference

**Version:** 1.0  
**Last Updated:** October 20, 2025

## Overview

This document describes all Make functions defined in the uyuni-docs Makefile system. These functions are the building blocks used by make targets to perform build operations.

## Table of Contents

1. [Validation Functions](#validation-functions)
2. [Antora Configuration Functions](#antora-configuration-functions)
3. [Antora Build Functions](#antora-build-functions)
4. [Language Selector Functions](#language-selector-functions)
5. [PDF Generation Functions](#pdf-generation-functions)
6. [Cleanup Functions](#cleanup-functions)
7. [Packaging Functions](#packaging-functions)

---

## Validation Functions

### validate-product

**Purpose:** Validates cross-references in documentation using Antora's xref validator.

**Definition:**
```makefile
define validate-product
	cd $(current_dir)/$(1)
	NODE_PATH="$(npm -g root)" antora --generator @antora/xref-validator $(2)
endef
```

**Parameters:**
- `$(1)` - Translation directory (e.g., `translations/en`)
- `$(2)` - Site configuration file (e.g., `mlm-site.yml`)

**Usage:**
```makefile
$(call validate-product,translations/en,mlm-site.yml)
```

**What It Does:**
1. Changes to translation directory
2. Sets NODE_PATH for Antora modules
3. Runs Antora with xref-validator generator
4. Checks all cross-references (xref:) are valid
5. Reports broken links

**Example Output:**
```
✓ Validated 1234 cross-references
✗ Found 3 broken references:
  - modules/admin/pages/actions.adoc:45 → missing-file.adoc
  - modules/client/pages/setup.adoc:12 → invalid#anchor
```

**When Used:**
- `make validate-mlm` / `make validate-uyuni`
- Before publication to catch broken links

---

## Antora Configuration Functions

### enable-mlm-in-antorayml

**Purpose:** Modifies `antora.yml` to enable MLM component and disable Uyuni component.

**Definition:**
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

**Parameters:**
- `$(1)` - Translation directory (e.g., `translations/en`)

**sed Operations:**
1. `s/^ # *\(name: *docs\)/\1/` - Uncomment `name: docs`
2. `s/^ # *\(title: *docs\)/\1/` - Uncomment `title: docs`
3. `s/^ *\(title: *Uyuni\)/#\1/` - Comment out `title: Uyuni`
4. `s/^ *\(name: *uyuni\)/#\1/` - Comment out `name: uyuni`

**Before:**
```yaml
# name: docs
# title: docs
title: Uyuni
name: uyuni
```

**After:**
```yaml
name: docs
title: docs
# title: Uyuni
# name: uyuni
```

**Usage:**
```makefile
$(call enable-mlm-in-antorayml,translations/en)
```

### enable-uyuni-in-antorayml

**Purpose:** Opposite of above - enables Uyuni, disables MLM.

**Definition:**
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

**Parameters:**
- `$(1)` - Translation directory

**Result:**
```yaml
# name: docs
# title: Docs
title: Uyuni
name: uyuni
```

---

## Antora Build Functions

### antora-mlm-function

**Purpose:** Executes Antora build for MLM documentation with full locale support.

**Definition:**
```makefile
define antora-mlm-function
	cd $(current_dir)
	$(call enable-mlm-in-antorayml,$(1)) && \
	cd $(current_dir)/$(1) && DOCSEARCH_ENABLED=true SITE_SEARCH_PROVIDER=lunr LANG=$(2) LC_ALL=$(2) LC_ALL=$(2) npx antora $(current_dir)/$(1)/mlm-site.yml --stacktrace
endef
```

**Parameters:**
- `$(1)` - Translation directory (e.g., `translations/ja`)
- `$(2)` - Locale (e.g., `ja_JP.UTF-8`)

**Environment Variables Set:**
- `DOCSEARCH_ENABLED=true` - Enables search
- `SITE_SEARCH_PROVIDER=lunr` - Uses Lunr.js
- `LANG=$(2)` - Sets language
- `LC_ALL=$(2)` - Sets locale (twice for redundancy)

**Usage:**
```makefile
$(call antora-mlm-function,translations/ja,ja_JP.UTF-8)
```

**What It Does:**
1. Enables MLM component in antora.yml
2. Changes to translation directory
3. Sets locale environment variables
4. Runs Antora with MLM site configuration
5. Generates HTML documentation
6. Creates search index

**Output:** `build/ja/` (or other language)

### antora-uyuni-function

**Purpose:** Same as MLM function but for Uyuni product.

**Definition:**
```makefile
define antora-uyuni-function
	cd $(current_dir)
	$(call enable-uyuni-in-antorayml,$(1)) && \
	cd $(current_dir)/$(1) && DOCSEARCH_ENABLED=true SITE_SEARCH_PROVIDER=lunr LANG=$(2) LC_ALL=$(2) LC_ALL=$(2) npx antora $(current_dir)/$(1)/uyuni-site.yml
endef
```

**Difference from MLM:**
- Uses `enable-uyuni-in-antorayml`
- Uses `uyuni-site.yml` instead of `mlm-site.yml`
- No `--stacktrace` flag

---

## Language Selector Functions

### enable-html-language-selector

**Purpose:** Injects language selector buttons into HTML navigation header.

**Definition:**
```makefile
define enable-html-language-selector
	cd $(current_dir)
	sed -n -i 'p; s,<\!--\ LANGUAGESELECTOR\ -->,<a role=\"button\" class=\"navbar-item\" id=\"$(1)\" onclick="selectLanguage(this.id)"><img src="{{uiRootPath}}/img/$(2).svg" class="langIcon $(3)">\&nbsp;$(4)</a>,p' translations/$(5)
endef
```

**Parameters:**
- `$(1)` - Language code (e.g., `zh_CN`, `ja`)
- `$(2)` - Flag icon filename without extension (e.g., `china`, `jaFlag`)
- `$(3)` - CSS class name (e.g., `china`, `japan`)
- `$(4)` - Display name (e.g., `中文`, `日本語`)
- `$(5)` - Supplemental files path

**How It Works:**

**sed Explanation:**
- `-n` - Suppress automatic printing
- `-i` - Edit file in-place
- `'p; s,PATTERN,REPLACEMENT,p'` - Print original line, then print replaced line

**Input (header-content.hbs):**
```html
<nav class="navbar">
  <!-- LANGUAGESELECTOR -->
</nav>
```

**After Calling for Japanese:**
```html
<nav class="navbar">
  <!-- LANGUAGESELECTOR -->
  <a role="button" class="navbar-item" id="ja" onclick="selectLanguage(this.id)">
    <img src="{{uiRootPath}}/img/jaFlag.svg" class="langIcon japan">&nbsp;日本語
  </a>
</nav>
```

**After Calling for Chinese:**
```html
<nav class="navbar">
  <!-- LANGUAGESELECTOR -->
  <a role="button" class="navbar-item" id="ja" onclick="selectLanguage(this.id)">
    <img src="{{uiRootPath}}/img/jaFlag.svg" class="langIcon japan">&nbsp;日本語
  </a>
  <a role="button" class="navbar-item" id="zh_CN" onclick="selectLanguage(this.id)">
    <img src="{{uiRootPath}}/img/china.svg" class="langIcon china">&nbsp;中文
  </a>
</nav>
```

**Usage:**
```makefile
$(call enable-html-language-selector,zh_CN,china,china,中文,$(SUPPLEMENTAL_FILES_MLM))
```

### enable-mlm-html-language-selector

**Purpose:** Wrapper that calls `enable-html-language-selector` with MLM supplemental files path.

**Definition:**
```makefile
define enable-mlm-html-language-selector
	$(call enable-html-language-selector,$(1),$(2),$(3),$(4),$(SUPPLEMENTAL_FILES_MLM))
endef
```

**Usage:**
```makefile
$(call enable-mlm-html-language-selector,ja,jaFlag,japan,日本語)
```

### enable-uyuni-html-language-selector

**Purpose:** Wrapper for Uyuni product.

**Definition:**
```makefile
define enable-uyuni-html-language-selector
	$(call enable-html-language-selector,$(1),$(2),$(3),$(4),$(SUPPLEMENTAL_FILES_UYUNI))
endef
```

---

## PDF Generation Functions

### pdf-book-create

**Purpose:** Generates a single PDF guide for MLM using asciidoctor-pdf.

**Definition:**
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
1. `$(1)` - Translation directory
2. `$(2)` - PDF theme name
3. `$(3)` - Product name
4. `$(4)` - MLM content flag (true/false)
5. `$(5)` - Filename prefix
6. `$(6)` - Module name
7. `$(7)` - Output directory
8. `$(8)` - Language code
9. `$(9)` - System locale
10. `$(10)` - Date format string
11. `$(11)` - Additional asciidoctor attributes

**asciidoctor-pdf Options:**
- `-r extensions/xref-converter.rb` - Load custom xref handler
- `-a lang=<code>` - Document language
- `-a pdf-themesdir` - Theme directory
- `-a pdf-theme` - Theme file (without .yml)
- `-a pdf-fontsdir` - Font directory
- `-a productname` - Product name attribute
- `-a mlm-content` - Enable MLM content
- `-a examplesdir` - Examples directory for includes
- `-a imagesdir` - Images directory
- `-a revdate` - Revision date (formatted)
- `--base-dir .` - Base directory for includes
- `--out-file` - Output PDF path
- `--trace` - Show full stack trace on errors

**Usage:**
```makefile
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

**Output:**
```
build/ja/pdf/suse_multi_linux_manager_administration_guide.pdf
```

### pdf-book-create-uyuni

**Purpose:** Same as `pdf-book-create` but for Uyuni (uses `uyuni-content` instead of `mlm-content`).

**Definition:**
```makefile
define pdf-book-create-uyuni
	cd $(current_dir)/$(1) && LANG=$(9) LC_ALL=$(9) LC_TYPE=$(9) asciidoctor-pdf \
		-r $(current_dir)/extensions/xref-converter.rb \
		-a lang=$(8) \
		-a pdf-themesdir=$(PDF_THEME_DIR)/ \
		-a pdf-theme=$(2) \
		-a pdf-fontsdir=$(PDF_FONTS_DIR) \
		-a productname=$(3) \
		-a uyuni-content=$(4) \
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

**Key Difference:**
```makefile
-a uyuni-content=$(4)  # Instead of: -a mlm-content=$(4)
```

### pdf-book-create-index

**Purpose:** Converts Antora navigation file to PDF-suitable index file.

**Definition:**
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
- `$(1)` - Translation directory
- `$(2)` - Module name
- `$(3)` - Language code

**Transformation Rules:**

1. **Convert xrefs to includes** (with level offsets):
   ```
   ***** xref:file.adoc[Title]  →  include::modules/mod/pages/file.adoc[leveloffset=+4]
   **** xref:file.adoc[Title]   →  include::modules/mod/pages/file.adoc[leveloffset=+3]
   *** xref:file.adoc[Title]    →  include::modules/mod/pages/file.adoc[leveloffset=+2]
   ** xref:file.adoc[Title]     →  include::modules/mod/pages/file.adoc[leveloffset=+1]
   * xref:file.adoc[Title]      →  include::modules/mod/pages/file.adoc[leveloffset=+0]
   ```

2. **Convert bullet headings to AsciiDoc headings**:
   ```
   **** Text  →  ==== Text
   *** Text   →  === Text
   ** Text    →  == Text
   * Text     →  = Text
   ```

**Example Input (nav-administration-guide.adoc):**
```asciidoc
* xref:admin-overview.adoc[Administration Guide]
** xref:actions.adoc[Actions]
** xref:organizations.adoc[Organizations]
*** xref:org-create.adoc[Creating Organizations]
```

**Output (nav-administration-guide.pdf.en.adoc):**
```asciidoc
= Administration Guide
include::modules/administration/pages/admin-overview.adoc[leveloffset=+0]

== Actions
include::modules/administration/pages/actions.adoc[leveloffset=+1]

== Organizations
include::modules/administration/pages/organizations.adoc[leveloffset=+1]

=== Creating Organizations
include::modules/administration/pages/org-create.adoc[leveloffset=+2]
```

**Why This Is Needed:**

Antora uses `xref:` for web navigation. PDFs need:
- **Full content inclusion** (not links)
- **Proper heading hierarchy** (leveloffset)
- **Sequential reading order**

**Usage:**
```makefile
$(call pdf-book-create-index,translations/en,administration,en)
```

---

## Cleanup Functions

### clean-function

**Purpose:** Removes all build artifacts for a specific language.

**Definition:**
```makefile
define clean-function
	cd $(current_dir)
	rm -rf build/$(2)          # e.g. build/en
	rm -rf $(1)                # e.g. translations/en
	rm -rf Makefile.$(2)
	find . -name "*pdf.$(2).adoc" -type f -exec rm -f {} \;
endef
```

**Parameters:**
- `$(1)` - Translation directory (e.g., `translations/en`)
- `$(2)` - Language code (e.g., `en`)

**What It Removes:**
1. Build output: `build/<lang>/`
2. Translations: `translations/<lang>/`
3. Generated Makefile: `Makefile.<lang>`
4. PDF index files: `*pdf.<lang>.adoc`

**Usage:**
```makefile
$(call clean-function,translations/ja,ja)
```

**Example:**
```bash
# Removes:
# - build/ja/
# - translations/ja/
# - Makefile.ja
# - modules/*/nav-*-guide.pdf.ja.adoc
```

### clean-branding

**Purpose:** Removes branding files from translation directory.

**Definition:**
```makefile
define clean-branding
	cd $(current_dir)
	rm -rf $(current_dir)/translations/$(1)/branding
endef
```

**Parameters:**
- `$(1)` - Language code

**Usage:**
```makefile
$(call clean-branding,ja)
```

**Removes:** `translations/ja/branding/`

### copy-branding

**Purpose:** Copies branding files to translation directory.

**Definition:**
```makefile
define copy-branding
	cd $(current_dir)
	mkdir -p $(current_dir)/translations/$(1)
	cp -a $(current_dir)/branding $(current_dir)/translations/$(1)/
endef
```

**Parameters:**
- `$(1)` - Language code

**Usage:**
```makefile
$(call copy-branding,ja)
```

**Copies:**
```
branding/ → translations/ja/branding/
```

**Includes:**
- UI bundle
- Supplemental UI files
- PDF themes
- PDF fonts
- Locale attributes

---

## Packaging Functions

### pdf-tar-product

**Purpose:** Creates ZIP archive of PDF files for distribution.

**Definition:**
```makefile
define pdf-tar-product
	cd $(current_dir)/$(HTML_BUILD_DIR) && zip -r9 $(2).zip $(shell realpath --relative-to=`pwd`/$(HTML_BUILD_DIR) $(3)) && mv $(2).zip $(1)/ && cd $(current_dir)
endef
```

**Parameters:**
- `$(1)` - Language directory (e.g., `en`)
- `$(2)` - Archive name (e.g., `suse-multi-linux-manager-docs_en-pdf`)
- `$(3)` - Source directory (e.g., `$(current_dir)/build/en/pdf`)

**zip Options:**
- `-r` - Recursive
- `-9` - Maximum compression

**Usage:**
```makefile
$(call pdf-tar-product,ja,suse-multi-linux-manager-docs_ja-pdf,$(current_dir)/build/ja/pdf)
```

**Result:**
```
build/ja/suse-multi-linux-manager-docs_ja-pdf.zip
```

**Contains:**
```
suse_multi_linux_manager_administration_guide.pdf
suse_multi_linux_manager_client-configuration_guide.pdf
... (all PDFs)
```

### obs-packages-product

**Purpose:** Creates OBS (Open Build Service) packages for distribution.

**Definition:**
```makefile
define obs-packages-product
	cd $(current_dir)
	tar --exclude='$(2)' -czvf $(3).tar.gz -C $(current_dir) $(HTML_BUILD_DIR)/$(1) && tar -czvf $(4).tar.gz -C $(current_dir) $(HTML_BUILD_DIR)/$(2)
	mkdir -p build/packages
	mv $(3).tar.gz $(4).tar.gz build/packages
endef
```

**Parameters:**
- `$(1)` - Language directory (e.g., `en`)
- `$(2)` - PDF subdirectory to exclude from HTML tarball (e.g., `en/pdf`)
- `$(3)` - HTML tarball name (e.g., `susemanager-docs_en`)
- `$(4)` - PDF tarball name (e.g., `susemanager-docs_en-pdf`)

**tar Options:**
- `--exclude='<path>'` - Exclude PDF directory from HTML tarball
- `-c` - Create archive
- `-z` - Compress with gzip
- `-v` - Verbose output
- `-f` - Output filename
- `-C` - Change to directory before archiving

**Usage:**
```makefile
$(call obs-packages-product,ja,ja/pdf,susemanager-docs_ja,susemanager-docs_ja-pdf)
```

**Creates:**
1. `build/packages/susemanager-docs_ja.tar.gz` - HTML files (without PDF)
2. `build/packages/susemanager-docs_ja-pdf.tar.gz` - PDF files only

**Why Two Tarballs?**
- HTML and PDF are often deployed separately
- HTML updates more frequently than PDFs
- Separate packages reduce deployment size

---

## Function Call Examples

### Example 1: Complete PDF Build

```makefile
# Build Japanese administration PDF
make pdf-administration-mlm-ja

# Internally calls:
$(call pdf-book-create-index,translations/ja,administration,ja)
# Creates: translations/ja/modules/administration/nav-administration-guide.pdf.ja.adoc

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
# Creates: build/ja/pdf/suse_multi_linux_manager_administration_guide.pdf
```

### Example 2: Complete HTML Build

```makefile
# Build Japanese HTML
make antora-mlm-ja

# Internally calls:
$(call copy-branding,ja)
# Copies branding to translations/ja/

$(call enable-mlm-html-language-selector,ja,jaFlag,japan,日本語)
$(call enable-mlm-html-language-selector,zh_CN,china,china,中文)
$(call enable-mlm-html-language-selector,ko,koFlag,korea,한국어)
# Adds language selector buttons

$(call antora-mlm-function,translations/ja,ja_JP.UTF-8)
# Builds HTML documentation
```

### Example 3: Validation

```makefile
# Validate MLM English docs
make validate-mlm-en

# Internally calls:
$(call validate-product,translations/en,mlm-site.yml)
# Checks all xrefs are valid
```

### Example 4: Packaging

```makefile
# Create OBS packages for Japanese
make obs-packages-mlm-ja

# Internally calls:
$(call obs-packages-product,ja,ja/pdf,susemanager-docs_ja,susemanager-docs_ja-pdf)
# Creates HTML and PDF tarballs
```

## Related Documentation

- [BUILD_SYSTEM_OVERVIEW.md](BUILD_SYSTEM_OVERVIEW.md) - Build system introduction
- [BUILD_VARIABLES.md](BUILD_VARIABLES.md) - Configuration variables
- [BUILD_TARGETS.md](BUILD_TARGETS.md) - Make target reference
- [PDF_BUILD_PROCESS.md](PDF_BUILD_PROCESS.md) - PDF generation details

---

**Next:** See [BUILD_TARGETS.md](BUILD_TARGETS.md) for complete target reference.
