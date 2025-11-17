# PDF Build Process - Technical Documentation

## Overview

PDF generation in uyuni-docs uses a **two-phase transformation** of Antora navigation files:

1. **Transform Phase**: Convert Antora nav lists (xref links) to AsciiDoc includes
2. **Build Phase**: Run asciidoctor-pdf with product-specific attributes

This allows a **single source file** (nav-*.adoc) to serve both:
- Antora HTML navigation (sidebar TOC)
- PDF book generation (complete document with all pages)

## The Magic: Nav File Transformation

### Source Format (Antora Navigation)

Navigation files use Antora's xref syntax with nested bullet lists:

```asciidoc
// modules/installation-and-upgrade/nav-installation-and-upgrade-guide.adoc

ifdef::backend-pdf[]
= {productname} {productnumber}: Installation and Upgrade Guide
include::./branding/pdf/entities.adoc[]
:doctype: book
endif::[]

ifeval::[{mlm-content} == true]
* xref:installation-and-upgrade-overview.adoc[Installation and Upgrade Guide]
endif::[]

** Requirements
*** xref:general-requirements.adoc[General Requirements]
*** xref:hardware-requirements.adoc[Hardware Requirements]
**** xref:hardware-req-server.adoc[Server]
**** xref:hardware-req-proxy.adoc[Proxy]
```

**For HTML (Antora)**:
- Bullet lists become sidebar navigation
- xref links are clickable
- Nesting shows hierarchy

**For PDF (asciidoctor-pdf)**:
- Need to include actual content files
- Bullet lists must become section headings
- xref links must become include directives

### Transformed Format (PDF Generation)

The `pdf-book-create-index` Make function transforms this with `sed`:

```asciidoc
// translations/en/modules/installation-and-upgrade/nav-installation-and-upgrade-guide.pdf.en.adoc

ifdef::backend-pdf[]
= {productname} {productnumber}: Installation and Upgrade Guide
include::./branding/pdf/entities.adoc[]
:doctype: book
endif::[]

ifeval::[{mlm-content} == true]
include::modules/installation-and-upgrade/pages/installation-and-upgrade-overview.adoc[leveloffset=+0]
endif::[]

== Requirements
include::modules/installation-and-upgrade/pages/general-requirements.adoc[leveloffset=+2]
include::modules/installation-and-upgrade/pages/hardware-requirements.adoc[leveloffset=+2]
include::modules/installation-and-upgrade/pages/hardware-req-server.adoc[leveloffset=+3]
include::modules/installation-and-upgrade/pages/hardware-req-proxy.adoc[leveloffset=+3]
```

## Transformation Rules

The `pdf-book-create-index` function in Makefile (lines 171-185):

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

### Transformation Logic

**Parameters**:
- `$(1)` = translations directory (e.g., `translations/en`)
- `$(2)` = section name (e.g., `installation-and-upgrade`)
- `$(3)` = language code (e.g., `en`)

**Replacements** (in order):

1. **5-star bullets with xref** → `include` with leveloffset +4
   ```
   ***** xref:file.adoc[Title]
   →
   include::modules/SECTION/pages/file.adoc[leveloffset=+4]
   ```

2. **4-star bullets with xref** → `include` with leveloffset +3
3. **3-star bullets with xref** → `include` with leveloffset +2
4. **2-star bullets with xref** → `include` with leveloffset +1
5. **1-star bullets with xref** → `include` with leveloffset +0

6. **Plain bullets (no xref)** → Section headings
   ```
   ** Requirements  → == Requirements
   *** General      → === General
   **** Server      → ==== Server
   ```

### Leveloffset Explained

`leveloffset` shifts heading levels in included files:

```asciidoc
// Original file (hardware-req-server.adoc):
= Server Hardware Requirements    ← Level 0
== CPU Requirements                ← Level 1
=== Intel CPUs                     ← Level 2

// With leveloffset=+3:
==== Server Hardware Requirements ← Level 3 (0 + 3)
===== CPU Requirements            ← Level 4 (1 + 3)
====== Intel CPUs                 ← Level 5 (2 + 3)
```

This creates proper hierarchy when assembling the PDF book.

## ifdef/ifeval Magic

Navigation files use AsciiDoc conditionals for product-specific content:

### backend-pdf Directive

```asciidoc
ifdef::backend-pdf[]
= {productname} {productnumber}: Installation Guide
include::./branding/pdf/entities.adoc[]
:doctype: book
:title-page:
endif::[]
```

**Purpose**: Only active when building PDF, ignored by Antora HTML
**Effect**: Adds title page and document metadata

### Product-Specific Content

```asciidoc
ifeval::[{mlm-content} == true]
* xref:mlm-specific-page.adoc[MLM Feature]
endif::[]

ifeval::[{uyuni-content} == true]
* xref:uyuni-specific-page.adoc[Uyuni Feature]
endif::[]
```

**Purpose**: Include content only for specific product
**Set by**: asciidoctor-pdf `-a` flags during build

## PDF Build Pipeline

### Phase 1: Generate Nav Index (Transform)

**Jinja2 Template** (`Makefile.section.functions.j2`):
```jinja
.PHONY: pdf-{{ section.name }}-index-{{ language.langcode }}
pdf-{{ section.name }}-index-{{ language.langcode }}:
	$(call pdf-book-create-index,translations/{{ language.langcode }},{{ section.name }},{{ language.langcode }})
```

**Generated Target** (e.g., `pdf-installation-and-upgrade-index-en`):
```makefile
.PHONY: pdf-installation-and-upgrade-index-en
pdf-installation-and-upgrade-index-en:
	$(call pdf-book-create-index,translations/en,installation-and-upgrade,en)
```

**Result**: Creates `translations/en/modules/installation-and-upgrade/nav-installation-and-upgrade-guide.pdf.en.adoc`

### Phase 2: Build PDF with asciidoctor-pdf

**Jinja2 Template**:
```jinja
.PHONY: pdf-{{ section.name }}-mlm-{{ language.langcode }}
pdf-{{ section.name }}-mlm-{{ language.langcode }}: translations prepare-antora-mlm-{{ language.langcode }} pdf-{{ section.name }}-index-{{ language.langcode }}
	$(call pdf-{{ section.name }}-product,translations/{{ language.langcode }},{{ language.pdf_theme_mlm }},$(PRODUCTNAME_MLM),$(MLM_CONTENT),$(FILENAME_MLM),$(current_dir)/build/{{ language.langcode }}/pdf,{{ language.langcode }},{{ language.locale }},{{ language.gnudateformat }},{{ language.asciidoctor_pdf_additional_attributes }})
```

**Make Function** (`pdf-book-create`):
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

**Asciidoctor-PDF Attributes**:
- `-a mlm-content=true` or `-a uyuni-content=true` → Controls ifeval conditionals
- `-a productname="SUSE Multi-Linux Manager"` → Product branding
- `-a pdf-theme=mlm` → Styling theme
- `-a lang=en` → Language for localization
- `-a imagesdir=...` → Image paths
- `--base-dir .` → Resolve includes from translations/LANG/

**Output**: `build/en/pdf/suse_multi_linux_manager_installation-and-upgrade_guide.pdf`

## Dependency Chain

```makefile
# Full chain for MLM English PDF
pdf-installation-and-upgrade-mlm-en:
  ├─ translations              # Run use_po.sh (if non-English)
  ├─ prepare-antora-mlm-en     # Copy branding, modules, create site.yml
  ├─ pdf-installation-and-upgrade-index-en   # Transform nav → PDF index
  └─ asciidoctor-pdf           # Build actual PDF
```

## Language-Specific Configuration

From `parameters.yml`:

```yaml
languages:
  - langcode: en
    locale: en_US.UTF-8
    gnudateformat: "%B %d, %Y"
    pdf_theme_mlm: mlm
    pdf_theme_uyuni: uyuni
    asciidoctor_pdf_additional_attributes: ""
    
  - langcode: ja
    locale: ja_JP.UTF-8
    gnudateformat: "%Y年%m月%d日"
    pdf_theme_mlm: mlm-cjk
    pdf_theme_uyuni: uyuni-cjk
    asciidoctor_pdf_additional_attributes: "-a scripts=cjk"
```

**Key Points**:
- CJK languages use special themes (`mlm-cjk`, `uyuni-cjk`)
- CJK languages need `-a scripts=cjk` for font rendering
- Date formats vary by locale

## Python Implementation Requirements

To replace Make's PDF build in Python:

### 1. Nav File Transformation

```python
import re

def transform_nav_to_pdf(nav_file: Path, section: str, lang: str) -> Path:
    """Transform Antora nav file to PDF index file"""
    
    with open(nav_file, 'r') as f:
        content = f.read()
    
    # Replacements (same order as Make sed)
    replacements = [
        (r'\*{5}\s+xref:(.+?)\.adoc\[.*?\]', 
         rf'include::modules/{section}/pages/\1.adoc[leveloffset=+4]'),
        (r'\*{4}\s+xref:(.+?)\.adoc\[.*?\]', 
         rf'include::modules/{section}/pages/\1.adoc[leveloffset=+3]'),
        (r'\*{3}\s+xref:(.+?)\.adoc\[.*?\]', 
         rf'include::modules/{section}/pages/\1.adoc[leveloffset=+2]'),
        (r'\*{2}\s+xref:(.+?)\.adoc\[.*?\]', 
         rf'include::modules/{section}/pages/\1.adoc[leveloffset=+1]'),
        (r'\*{1}\s+xref:(.+?)\.adoc\[.*?\]', 
         rf'include::modules/{section}/pages/\1.adoc[leveloffset=+0]'),
        (r'\*{4}\s+(.+)', r'==== \1'),
        (r'\*{3}\s+(.+)', r'=== \1'),
        (r'\*{2}\s+(.+)', r'== \1'),
        (r'\*{1}\s+(.+)', r'= \1'),
    ]
    
    for pattern, replacement in replacements:
        content = re.sub(pattern, replacement, content)
    
    output_file = nav_file.parent / f"{nav_file.stem}.pdf.{lang}.adoc"
    with open(output_file, 'w') as f:
        f.write(content)
    
    return output_file
```

### 2. Asciidoctor-PDF Execution

```python
def build_pdf(self, product: str, lang: str, section: str):
    """Build PDF for a section"""
    
    lang_config = self.config.get_language(lang)
    product_config = self.config.get_product(product)
    
    # Phase 1: Transform nav file
    nav_file = Path(f"translations/{lang}/modules/{section}/nav-{section}-guide.adoc")
    pdf_index = transform_nav_to_pdf(nav_file, section, lang)
    
    # Phase 2: Build PDF
    theme = lang_config.pdf_theme_mlm if product == 'mlm' else lang_config.pdf_theme_uyuni
    content_flag = 'mlm-content' if product == 'mlm' else 'uyuni-content'
    
    cmd = [
        'asciidoctor-pdf',
        '-r', 'extensions/xref-converter.rb',
        '-a', f'lang={lang}',
        '-a', f'pdf-theme={theme}',
        '-a', f'productname={product_config.productname}',
        '-a', f'{content_flag}=true',
        '-a', f'imagesdir=modules/{section}/assets/images',
        *lang_config.asciidoctor_pdf_additional_attributes.split(),
        '--base-dir', '.',
        '--out-file', f'build/{lang}/pdf/{product_config.filename}_{section}_guide.pdf',
        str(pdf_index)
    ]
    
    subprocess.run(cmd, cwd=f'translations/{lang}', check=True)
```

### 3. Integration with Build Pipeline

```python
def build_all_pdfs(product: str, lang: str):
    """Build all PDFs for a product/language"""
    
    # Ensure translations exist for non-English
    if lang != 'en':
        run_use_po_sh()
    
    # Prepare antora environment
    prepare_antora(product, lang)
    
    # Build each section
    for section in get_sections(product):
        build_pdf(product, lang, section)
```

## Testing Considerations

When comparing Make vs Python PDF builds:

### Expected Differences (OK)

1. **Timestamp in PDF** - Date generation may differ slightly
2. **File paths in metadata** - Absolute vs relative paths

### Must Be Identical

1. **PDF structure** - Same number of pages, same headings
2. **Content** - All text must match exactly
3. **Images** - All images present in same locations
4. **TOC** - Table of contents must be identical

### Test Command

```bash
# Extract text from PDFs for comparison
pdftotext build-make/en/pdf/mlm_installation_guide.pdf make.txt
pdftotext build-python/en/pdf/mlm_installation_guide.pdf python.txt
diff make.txt python.txt
```

## Summary

The PDF build process is a **clever reuse** of Antora navigation files:

1. ✅ **Single source of truth** - Nav files serve both HTML and PDF
2. ✅ **Product-specific content** - ifeval conditionals filter by product
3. ✅ **Proper hierarchy** - leveloffset creates correct heading structure
4. ✅ **Language support** - Locale-specific themes and attributes

**Python implementation**: Straightforward regex replacements + subprocess call to asciidoctor-pdf. No complex logic needed.
