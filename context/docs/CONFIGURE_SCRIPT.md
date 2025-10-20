# Configure Script Documentation

**File:** `configure`  
**Language:** Python 3  
**Version:** 1.0  
**Last Updated:** October 20, 2025

## Table of Contents
1. [Overview](#overview)
2. [Purpose](#purpose)
3. [Usage](#usage)
4. [How It Works](#how-it-works)
5. [Input Files](#input-files)
6. [Output Files](#output-files)
7. [Template Processing](#template-processing)
8. [Configuration Data Structure](#configuration-data-structure)
9. [Examples](#examples)
10. [Troubleshooting](#troubleshooting)

---

## Overview

The `configure` script is a **Python 3 code generator** that uses **Jinja2 templates** to create product-specific build files from a central configuration. It's the first step in the build process and must be run before any documentation builds.

**Key Responsibilities:**
1. Reads product configuration from `parameters.yml`
2. Processes Jinja2 templates (`.j2` files)
3. Generates language-specific Makefiles
4. Creates product-specific configuration files
5. Sets up the build environment

**Technology Stack:**
- Python 3
- Jinja2 (template engine)
- PyYAML (YAML parsing)

---

## Purpose

### Why This Script Exists

The uyuni-docs repository builds documentation for **two products** (MLM and Uyuni) in **four languages** (English, Japanese, Chinese, Korean). Without the configure script, we would need:

- **8 hand-maintained Makefile variants** (2 products × 4 languages)
- **2 hand-maintained site.yml files**
- **2 hand-maintained antora.yml files**
- Constant manual synchronization when adding languages or sections

**With the configure script:**
- ✅ Single source of truth (`parameters.yml`)
- ✅ Automatic generation of all variants
- ✅ Consistent configuration across products
- ✅ Easy addition of new languages

### What Problems It Solves

1. **Product Switching** - Quickly switch between MLM and Uyuni builds
2. **Multi-language Support** - Automatically creates targets for all configured languages
3. **Configuration Management** - Centralized product settings (versions, URLs, attributes)
4. **Maintainability** - Changes to build structure only require updating templates
5. **Consistency** - Ensures all language builds use the same patterns

---

## Usage

### Basic Usage

```bash
./configure <product>
```

**Where `<product>` is one of:**
- `mlm` - SUSE Multi-Linux Manager
- `uyuni` - Uyuni Project

### Examples

#### Configure for MLM

```bash
./configure mlm
```

**Output:**
```
Config file loaded successfully
Creating Makefile for each language..
Makefiles successfully created
Including new Makefiles in Makefile.lang
Creating new target using books target..
Creating new target using language target..
Creating entities.adoc
Creating parameters specific for mlm for entities file..
Creating site.yml.
Creating parameters specific for mlm in site.yml
Creating parameters specific for mlm in antora.yml
Configuration Completed!
```

#### Configure for Uyuni

```bash
./configure uyuni
```

**Output:** Same messages but with product-specific values.

### When to Run

**Always run configure:**
- Before building for the first time
- When switching between MLM and Uyuni
- After modifying `parameters.yml`
- After updating template files (`.j2`)
- After adding a new language
- After pulling updates from git (if templates changed)

**You do NOT need to rerun configure:**
- When editing documentation content (`.adoc` files)
- When changing translations (PO files)
- Between successive builds of the same product

---

## How It Works

### Execution Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. INITIALIZATION                                               │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │ Load parameters.yml             │
          │ - Parse YAML structure          │
          │ - Validate product parameter    │
          └─────────────────────────────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │ Extract Product Configuration   │
          │ - Get product-specific settings │
          │ - Merge with common settings    │
          │ - Add language configurations   │
          └─────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 2. LANGUAGE-SPECIFIC MAKEFILE GENERATION                        │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │ Load Makefile.j2 Template       │
          └─────────────────────────────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │ FOR EACH Language in parameters │
          │   (en, ja, zh_CN, ko)           │
          └─────────────────────────────────┘
                            │
                            ├──────────────────┬──────────────┐
                            ▼                  ▼              ▼
          ┌──────────────────────┐  ┌─────────────┐  ┌─────────────┐
          │ Render Makefile.j2   │  │ Render for  │  │ Render for  │
          │ with en variables    │  │ ja vars     │  │ zh_CN vars  │
          └──────────────────────┘  └─────────────┘  └─────────────┘
                            │                  │              │
                            ▼                  ▼              ▼
          ┌──────────────────────┐  ┌─────────────┐  ┌─────────────┐
          │ Write Makefile.en    │  │ Makefile.ja │  │ Makefile... │
          └──────────────────────┘  └─────────────┘  └─────────────┘
                            │
                            └─────────┬────────────────────────┘
                                      │
                                      ▼
          ┌─────────────────────────────────────────────────┐
          │ Update Makefile.lang                            │
          │ -include Makefile.en                            │
          │ -include Makefile.ja                            │
          │ -include Makefile.zh_CN                         │
          │ -include Makefile.ko                            │
          └─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 3. SECTION FUNCTIONS GENERATION                                 │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │ Load Makefile.section.          │
          │      functions.j2               │
          └─────────────────────────────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │ Render with Product Config      │
          │ - sections: [installation,      │
          │   client-config, admin, ...]    │
          └─────────────────────────────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │ Generate PDF targets for each:  │
          │ - Section (e.g., installation)  │
          │ - Language (en, ja, zh_CN, ko)  │
          │ - Product (MLM, Uyuni)          │
          └─────────────────────────────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │ Write Makefile.section.         │
          │       functions                 │
          └─────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 4. LANGUAGE TARGET GENERATION                                   │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │ Load Makefile.lang.target.j2    │
          └─────────────────────────────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │ Generate Multi-Language Targets │
          │ - antora-mlm depends on:        │
          │   antora-mlm-en, antora-mlm-ja, │
          │   antora-mlm-zh_CN, etc.        │
          └─────────────────────────────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │ Write Makefile.lang.target      │
          └─────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 5. CONFIGURATION FILE GENERATION                                │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ├──────────────────┬────────────────┐
                            ▼                  ▼                ▼
          ┌────────────────────┐  ┌──────────────┐  ┌──────────────┐
          │ Generate           │  │ Generate     │  │ Generate     │
          │ entities.adoc      │  │ site.yml     │  │ antora.yml   │
          └────────────────────┘  └──────────────┘  └──────────────┘
                            │                  │                │
                            ▼                  ▼                ▼
          ┌────────────────────┐  ┌──────────────┐  ┌──────────────┐
          │ branding/locale/   │  │ site.yml     │  │ antora.yml   │
          │ entities.          │  │ (root)       │  │ (root)       │
          │ specific.adoc      │  │              │  │              │
          │                    │  │              │  │              │
          │ branding/pdf/      │  │              │  │              │
          │ entities.adoc      │  │              │  │              │
          └────────────────────┘  └──────────────┘  └──────────────┘
                            │
                            └──────────┬───────────────────────┘
                                       │
                                       ▼
          ┌─────────────────────────────────────────────────┐
          │ Configuration Completed!                        │
          └─────────────────────────────────────────────────┘
```

### Code Walkthrough

#### 1. Import Dependencies

```python
from jinja2 import Environment, FileSystemLoader
import pathlib
import sys
import yaml
```

#### 2. Load Configuration

```python
config_data = yaml.load(open('./parameters.yml'), Loader=yaml.FullLoader)
```

**Result:** `config_data` contains the entire YAML structure.

#### 3. Validate Product Parameter

```python
avaiable_products = config_data["products"].keys()  # ['mlm', 'uyuni']

if len(sys.argv) != 2:
    print("ERROR: ./configure requires one parameter [product]")
    # ... print available products
    sys.exit(1)

param_product = sys.argv[1]  # 'mlm' or 'uyuni'

if param_product not in avaiable_products:
    print(f"ERROR: {param_product} is not defined in parameters.yaml")
    sys.exit(1)
```

#### 4. Extract and Enrich Product Configuration

```python
products = config_data["products"]
product = products[param_product]  # Get 'mlm' or 'uyuni' section

# Add common configuration
common_dict = {}
common_dict["languages"] = config_data["languages"]
product.update(common_dict)
```

**Result:** `product` now contains:
- Product-specific settings (antora, asciidoc, sections, site, ui)
- Common language configurations

#### 5. Generate Language-Specific Makefiles

```python
env = Environment(loader=FileSystemLoader('./'), 
                  trim_blocks=True, 
                  lstrip_blocks=True)
template_lang = env.get_template('Makefile.j2')

for i in config_data["languages"]:
    with open('Makefile.' + i["langcode"], 'w') as f:
        print(template_lang.render(i), file=f)
```

**For each language:**
- Loads `Makefile.j2`
- Renders with language variables (langcode, locale, pdf_theme, etc.)
- Writes `Makefile.en`, `Makefile.ja`, etc.

**Template Variables Available:**
- `{{ langcode }}` - "en", "ja", "zh_CN", "ko"
- `{{ locale }}` - "en_US.utf8", "ja_JP.UTF-8", etc.
- `{{ gnudateformat }}` - "%B %d %Y", "%Y年%m月%e日", etc.
- `{{ pdf_theme_mlm }}` - "suse", "suse-jp", "suse-sc", "suse-ko"
- `{{ pdf_theme_uyuni }}` - "uyuni", "uyuni-cjk"
- `{{ flag_svg_without_ext }}` - "jaFlag", "china", "koFlag"
- `{{ nation_in_eng }}` - "japan", "china", "korea"
- `{{ language_in_orig }}` - "日本語", "中文", "한국어"
- `{{ asciidoctor_pdf_additional_attributes }}` - "-a scripts=cjk"

#### 6. Create Makefile.lang

```python
with open('Makefile.lang', 'a') as f:
    f.truncate(0)  # Clear file
    for i in config_data["languages"]:
        f.write('-include ' + 'Makefile.' + i["langcode"] + '\n')
```

**Output (`Makefile.lang`):**
```makefile
-include Makefile.en
-include Makefile.ja
-include Makefile.zh_CN
-include Makefile.ko
```

#### 7. Generate Section Functions

```python
template_target = env.get_template('Makefile.section.functions.j2')
with open('Makefile.section.functions', 'w') as f:
    print(template_target.render(product), file=f)
```

**Template receives:** Product configuration including sections array

**Generates:** PDF build targets for each section × language × product combination

#### 8. Generate Language Targets

```python
template_target = env.get_template('Makefile.lang.target.j2')
with open('Makefile.lang.target', 'w') as f:
    print(template_target.render(config_data), file=f)
```

**Generates:** Multi-language orchestration targets (e.g., `antora-mlm` depends on all language variants)

#### 9. Generate Entity Files

```python
# Product-specific entities
pathlib.Path("branding/locale/").mkdir(parents=True, exist_ok=True)
with open('branding/locale/entities.specific.adoc', 'w') as f:
    template_target = env.get_template('entities.specific.adoc.j2')
    print(template_target.render(product), file=f)

# Common entities
pathlib.Path("branding/pdf/").mkdir(parents=True, exist_ok=True)
with open('branding/pdf/entities.adoc', 'w') as f:
    template_target = env.get_template('entities.adoc.j2')
    print(template_target.render(config_data), file=f)
```

#### 10. Generate site.yml

```python
with open('site.yml', 'w') as f:
    # Common configuration
    template_target = env.get_template('site.yml.common.j2')
    print(template_target.render(config_data), file=f)
    
    # Product-specific configuration
    template_target = env.get_template('site.yml.j2')
    print(template_target.render(product), file=f)
```

#### 11. Generate antora.yml

```python
with open('antora.yml', 'w') as f:
    template_target = env.get_template('antora.yml.j2')
    print(template_target.render(product), file=f)
```

---

## Input Files

### Primary Configuration File

#### `parameters.yml`

**Location:** Project root

**Purpose:** Central configuration for all products, languages, and build settings

**Structure:**
```yaml
products:
  mlm:
    antora: { ... }           # Antora component settings
    asciidoc:
      attributes: [ ... ]     # AsciiDoc attributes
    sections: [ ... ]         # Documentation sections/guides
    site: [ ... ]             # Site-level settings
    ui:
      bundle: [ ... ]         # UI bundle configuration
      supplemental_files: ... # Branding path
  
  uyuni:
    # Same structure as MLM

languages:
  - langcode: "en"
    locale: "en_US.utf8"
    gnudateformat: "%B %d %Y"
    pdf_theme_mlm: "suse"
    pdf_theme_uyuni: "uyuni"
  - langcode: "ja"
    # ... Japanese settings
  # ... more languages

targets:
  - name: validate-mlm
    pre_lang_prerequisite: configure-mlm
  # ... more targets

antora:
  extensions: [ ... ]         # Antora extensions

asciidoc:
  extensions: [ ... ]         # AsciiDoc extensions
  attributes: [ ... ]         # Common AsciiDoc attributes
```

### Template Files

All templates use **Jinja2 syntax** (`.j2` extension):

1. **`Makefile.j2`** - Language-specific Makefile targets
2. **`Makefile.section.functions.j2`** - PDF generation functions per section
3. **`Makefile.lang.target.j2`** - Multi-language orchestration targets
4. **`entities.adoc.j2`** - Common AsciiDoc entities
5. **`entities.specific.adoc.j2`** - Product-specific entities
6. **`site.yml.common.j2`** - Common Antora site configuration
7. **`site.yml.j2`** - Product-specific Antora site configuration
8. **`antora.yml.j2`** - Antora component configuration

---

## Output Files

### Generated Makefiles

| File | Purpose | Generated From |
|------|---------|---------------|
| `Makefile.en` | English build targets | `Makefile.j2` |
| `Makefile.ja` | Japanese build targets | `Makefile.j2` |
| `Makefile.zh_CN` | Chinese build targets | `Makefile.j2` |
| `Makefile.ko` | Korean build targets | `Makefile.j2` |
| `Makefile.lang` | Include directives for language Makefiles | (generated directly) |
| `Makefile.section.functions` | PDF section builders | `Makefile.section.functions.j2` |
| `Makefile.lang.target` | Multi-language targets | `Makefile.lang.target.j2` |

### Generated Configuration Files

| File | Purpose | Generated From |
|------|---------|---------------|
| `site.yml` | Antora site configuration | `site.yml.common.j2` + `site.yml.j2` |
| `antora.yml` | Antora component configuration | `antora.yml.j2` |
| `branding/locale/entities.specific.adoc` | Product-specific AsciiDoc entities | `entities.specific.adoc.j2` |
| `branding/pdf/entities.adoc` | Common AsciiDoc entities | `entities.adoc.j2` |

### File Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│ TEMPLATE FILES (.j2)                                            │
│ - Version controlled in git                                     │
│ - Modified by developers                                        │
│ - Define structure and patterns                                 │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼ (./configure)
┌─────────────────────────────────────────────────────────────────┐
│ GENERATED FILES                                                 │
│ - NOT version controlled (.gitignore'd)                         │
│ - Regenerated on each ./configure run                           │
│ - Product and language specific                                 │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼ (make)
┌─────────────────────────────────────────────────────────────────┐
│ BUILD OUTPUT                                                    │
│ - build/ directory                                              │
│ - translations/ directory                                       │
│ - HTML and PDF documentation                                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Template Processing

### Jinja2 Syntax Overview

#### Variable Substitution

```jinja2
# Template
.PHONY: clean-{{ langcode }}

# With langcode="en"
.PHONY: clean-en

# With langcode="ja"
.PHONY: clean-ja
```

#### Loops

```jinja2
# Template
{% for section in sections %}
- {{ section.name }}
{% endfor %}

# Output
- installation-and-upgrade
- client-configuration
- administration
```

#### Conditionals

```jinja2
{% if entity.attribute == 'productname' %}
  {{ entity.attribute }}: "{{ entity.value }}"
{% else %}
  {{ entity.attribute }}: {{ entity.value }}
{% endif %}
```

#### Filters

```jinja2
{% filter indent(2, true) %}
- {{ entity.extension }}
{% endfilter %}
```

### Template Examples

#### Example 1: Makefile.j2 Language Substitution

**Template:**
```makefile
.PHONY: antora-mlm-{{ langcode }}
antora-mlm-{{ langcode }}: prepare-antora-mlm-{{ langcode }} pdf-all-mlm-{{ langcode }}
	$(call antora-mlm-function,translations/{{ langcode }},{{ locale }})
```

**Variables (English):**
```yaml
langcode: "en"
locale: "en_US.utf8"
```

**Output (Makefile.en):**
```makefile
.PHONY: antora-mlm-en
antora-mlm-en: prepare-antora-mlm-en pdf-all-mlm-en
	$(call antora-mlm-function,translations/en,en_US.utf8)
```

**Variables (Japanese):**
```yaml
langcode: "ja"
locale: "ja_JP.UTF-8"
```

**Output (Makefile.ja):**
```makefile
.PHONY: antora-mlm-ja
antora-mlm-ja: prepare-antora-mlm-ja pdf-all-mlm-ja
	$(call antora-mlm-function,translations/ja,ja_JP.UTF-8)
```

#### Example 2: site.yml.j2 Product Configuration

**Template (site.yml.j2):**
```jinja2
site:
{% for i in site -%}
  {{ i.attribute }}: {{ i.value }}
{% endfor %}
```

**Variables (MLM):**
```yaml
site:
  - attribute: title
    value: "SUSE Multi-Linux Manager 5.1 Documentation"
  - attribute: start_page
    value: docs::index.adoc
  - attribute: url
    value: https://documentation.suse.com/multi-linux-manager/5.1/
```

**Output (site.yml):**
```yaml
site:
  title: SUSE Multi-Linux Manager 5.1 Documentation
  start_page: docs::index.adoc
  url: https://documentation.suse.com/multi-linux-manager/5.1/
```

#### Example 3: Section Loop

**Template (Makefile.section.functions.j2):**
```jinja2
{% for section in sections %}
define pdf-{{ section.name }}-product
	cd $(current_dir)
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),{{ section.name }},$(6),$(7),$(8),$(9),$(10))
endef
{% endfor %}
```

**Variables:**
```yaml
sections:
  - name: "installation-and-upgrade"
  - name: "client-configuration"
  - name: "administration"
```

**Output:**
```makefile
define pdf-installation-and-upgrade-product
	cd $(current_dir)
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),installation-and-upgrade,$(6),$(7),$(8),$(9),$(10))
endef

define pdf-client-configuration-product
	cd $(current_dir)
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),client-configuration,$(6),$(7),$(8),$(9),$(10))
endef

define pdf-administration-product
	cd $(current_dir)
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),administration,$(6),$(7),$(8),$(9),$(10))
endef
```

#### Example 4: Conditional Attributes

**Template (entities.adoc.j2):**
```jinja2
{% for entity in asciidoc.attributes -%}
{% if entity.attribute in ['productnumber', 'productname'] %}
:{{ entity.attribute }}: "{{ entity.value }}"
{% else %}
:{{ entity.attribute }}: {{ entity.value }}
{% endif %}
{% endfor %}
```

**Variables:**
```yaml
asciidoc:
  attributes:
    - attribute: productname
      value: "Uyuni"
    - attribute: productnumber
      value: "2025.10"
    - attribute: uyuni-content
      value: true
```

**Output:**
```asciidoc
:productname: "Uyuni"
:productnumber: "2025.10"
:uyuni-content: true
```

---

## Configuration Data Structure

### Complete Data Flow

```
parameters.yml
├── products
│   ├── mlm
│   │   ├── antora
│   │   │   ├── name: "docs"
│   │   │   └── title: "SUSE Multi-Linux Manager Guides"
│   │   ├── asciidoc
│   │   │   └── attributes: [...]
│   │   ├── sections: [...]
│   │   ├── site: [...]
│   │   └── ui: [...]
│   └── uyuni
│       └── (same structure)
├── languages
│   ├── - langcode: "en"
│   │     locale: "en_US.utf8"
│   │     gnudateformat: "%B %d %Y"
│   │     pdf_theme_mlm: "suse"
│   │     pdf_theme_uyuni: "uyuni"
│   ├── - langcode: "ja"
│   │     locale: "ja_JP.UTF-8"
│   │     gnudateformat: "%Y年%m月%e日"
│   │     pdf_theme_mlm: "suse-jp"
│   │     pdf_theme_uyuni: "uyuni-cjk"
│   │     flag_svg_without_ext: "jaFlag"
│   │     nation_in_eng: "japan"
│   │     language_in_orig: "日本語"
│   │     asciidoctor_pdf_additional_attributes: "-a scripts=cjk"
│   └── (zh_CN, ko)
├── targets: [...]
├── antora
│   └── extensions: [...]
└── asciidoc
    ├── extensions: [...]
    └── attributes: [...]
```

### Product Configuration Merging

**Before enrichment:**
```python
product = {
    'antora': {...},
    'asciidoc': {...},
    'sections': [...],
    'site': [...],
    'ui': {...}
}
```

**After enrichment (product.update(common_dict)):**
```python
product = {
    'antora': {...},
    'asciidoc': {...},
    'sections': [...],
    'site': [...],
    'ui': {...},
    'languages': [...]  # ← Added from common config
}
```

---

## Examples

### Example 1: First-Time Setup

```bash
# Clone repository
git clone https://github.com/uyuni-project/uyuni-docs.git
cd uyuni-docs

# Install dependencies
pip3 install jinja2 pyyaml

# Configure for Uyuni
./configure uyuni

# Verify generated files
ls -l Makefile.* site.yml antora.yml
```

### Example 2: Switch from Uyuni to MLM

```bash
# Currently configured for Uyuni
# ... built documentation ...

# Switch to MLM
./configure mlm

# Check what changed
git diff site.yml antora.yml
```

### Example 3: Add a New Language

**Step 1: Edit parameters.yml**

```yaml
languages:
  # ... existing languages ...
  - langcode: "es"
    locale: "es_ES.UTF-8"
    gnudateformat: "%e de %B de %Y"
    pdf_theme_mlm: "suse"
    pdf_theme_uyuni: "uyuni"
    flag_svg_without_ext: "espFlag"
    nation_in_eng: "spain"
    language_in_orig: "Español"
```

**Step 2: Run configure**

```bash
./configure mlm
```

**Step 3: Verify new files**

```bash
ls -l Makefile.es
cat Makefile.lang
# Should include: -include Makefile.es
```

**Step 4: Build new language**

```bash
make translations  # Apply Spanish translations
make antora-mlm-es
```

### Example 4: Add a New Documentation Section

**Step 1: Edit parameters.yml**

```yaml
products:
  mlm:
    sections:
      - name: "installation-and-upgrade"
      - name: "client-configuration"
      # ... existing sections ...
      - name: "troubleshooting"  # ← NEW
```

**Step 2: Reconfigure**

```bash
./configure mlm
```

**Step 3: Check generated targets**

```bash
grep "pdf-troubleshooting" Makefile.section.functions
# Should find PDF generation targets for new section
```

### Example 5: Test Template Changes

**Scenario:** Modified `Makefile.j2` to add new target

```bash
# Edit template
vim Makefile.j2

# Regenerate
./configure mlm

# Check one generated file
vim Makefile.en

# Test build
make clean
make antora-mlm-en
```

### Example 6: Verify Configuration Before Build

```bash
# Configure
./configure mlm

# Check site.yml looks correct
cat site.yml | grep "title:"
# Expected: title: SUSE Multi-Linux Manager 5.1 Documentation

# Check antora.yml
cat antora.yml | grep "name:"
# Expected: name: docs

# Check entities
cat branding/locale/entities.specific.adoc | grep "productname"
# Expected: :productname: SUSE Multi-Linux Manager
```

---

## Troubleshooting

### Error: "Config file loaded successfully" not appearing

**Cause:** Script execution failed immediately

**Solutions:**

1. **Check Python version:**
```bash
python3 --version
# Need Python 3.6+
```

2. **Check file permissions:**
```bash
ls -l configure
# Should be executable
chmod +x configure
```

3. **Check file exists:**
```bash
ls -l parameters.yml
# Must exist in current directory
```

### Error: "ERROR: ./configure requires one parameter"

**Cause:** Missing or extra parameters

**Solution:**
```bash
# Wrong
./configure

# Wrong
./configure mlm uyuni

# Correct
./configure mlm
```

### Error: "ERROR: xxx is not defined in parameters.yaml"

**Cause:** Invalid product name

**Solution:**
```bash
# Check available products
grep -A1 "^products:" parameters.yml

# Use valid product
./configure mlm   # or ./configure uyuni
```

### Error: "ModuleNotFoundError: No module named 'jinja2'"

**Cause:** Missing Python dependencies

**Solution:**
```bash
# Install Jinja2
pip3 install jinja2

# Or use requirements file if available
pip3 install -r requirements.txt
```

### Error: "ModuleNotFoundError: No module named 'yaml'"

**Cause:** Missing PyYAML

**Solution:**
```bash
pip3 install pyyaml
```

### Error: Template rendering fails

**Symptoms:**
```
jinja2.exceptions.UndefinedError: 'dict object' has no attribute 'xxx'
```

**Cause:** Template references non-existent variable

**Solution:**

1. **Check parameters.yml structure:**
```bash
# Validate YAML syntax
python3 -c "import yaml; yaml.load(open('parameters.yml'), Loader=yaml.FullLoader)"
```

2. **Check template variable names:**
```bash
# Find template references
grep "{{ xxx }}" *.j2
```

3. **Compare with parameters.yml:**
```bash
# Ensure variable exists in config
grep "xxx:" parameters.yml
```

### Error: Generated files look wrong

**Cause:** Template or configuration issue

**Debug Process:**

1. **Check template file:**
```bash
cat Makefile.j2 | less
# Look for obvious syntax errors
```

2. **Test render manually:**
```python
from jinja2 import Environment, FileSystemLoader
import yaml

config = yaml.load(open('parameters.yml'), Loader=yaml.FullLoader)
env = Environment(loader=FileSystemLoader('./'))
template = env.get_template('Makefile.j2')
print(template.render(config['languages'][0]))
```

3. **Compare generated vs expected:**
```bash
diff Makefile.en Makefile.ja
# Check for expected differences
```

### Error: "FileNotFoundError: [Errno 2] No such file or directory: 'Makefile.j2'"

**Cause:** Running configure from wrong directory

**Solution:**
```bash
# Must run from repository root
cd /path/to/uyuni-docs
./configure mlm
```

### Warning: Site builds fail after configure

**Cause:** Cached or stale files

**Solution:**
```bash
# Clean everything
make clean
rm -rf build/ translations/

# Reconfigure
./configure mlm

# Rebuild
make antora-mlm
```

### Tip: Dry-Run Testing

Before committing template changes:

```bash
# Backup current generated files
mkdir /tmp/backup
cp Makefile.* site.yml antora.yml /tmp/backup/

# Make template changes
vim Makefile.j2

# Regenerate
./configure mlm

# Compare
diff /tmp/backup/Makefile.en Makefile.en

# If satisfied, commit both template and regenerated files
git add Makefile.j2 Makefile.en
git commit -m "Update makefile template"
```

---

## Related Documentation

- [MAKEFILE_REFERENCE.md](MAKEFILE_REFERENCE.md) - Complete Makefile documentation
- [DOCUMENTATION_PHASES.md](DOCUMENTATION_PHASES.md) - Documentation project plan
- [TEMPLATE_SYSTEM.md](TEMPLATE_SYSTEM.md) - Detailed template documentation (Phase 2)

---

## Next Steps

After running `./configure`, you typically want to:

1. **Build HTML documentation:**
```bash
make antora-mlm    # or make antora-uyuni
```

2. **Generate PDFs:**
```bash
make pdf-all-mlm   # or make pdf-all-uyuni
```

3. **Create packages:**
```bash
make obs-packages-mlm   # or make obs-packages-uyuni
```

See [MAKEFILE_REFERENCE.md](MAKEFILE_REFERENCE.md) for complete build target documentation.

---

**End of Configure Script Documentation**
