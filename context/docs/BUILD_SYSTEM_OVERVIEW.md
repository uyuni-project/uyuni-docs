# Build System Overview

**Version:** 1.0  
**Last Updated:** October 20, 2025

## Introduction

The uyuni-docs build system is a sophisticated, modular documentation generation system that produces **multi-language, multi-product, multi-format** documentation from a single source repository.

## Products

The system builds documentation for **two products**:

### SUSE Multi-Linux Manager (MLM)
- **Type:** Commercial product
- **URL:** https://documentation.suse.com/multi-linux-manager/5.1/
- **Component:** `docs`
- **Branding:** SUSE corporate branding
- **Target Audience:** Enterprise customers

### Uyuni
- **Type:** Open-source upstream
- **URL:** https://www.uyuni-project.org/uyuni-docs/
- **Component:** `uyuni`
- **Branding:** Uyuni project branding
- **Target Audience:** Open-source community

## Output Formats

### HTML Documentation
- **Generator:** Antora
- **Features:**
  - Multi-language navigation
  - Client-side search (Lunr.js)
  - Responsive design
  - Component-based architecture
- **Output:** `build/<lang>/`

### PDF Documentation
- **Generator:** asciidoctor-pdf
- **Features:**
  - Professional typesetting
  - CJK font support
  - Custom themes per product
  - Bookmarks and cross-references
- **Output:** `build/<lang>/pdf/`

## Supported Languages

| Language | Code | Locale | Status |
|----------|------|--------|--------|
| English | en | en_US.utf8 | Complete (source) |
| Japanese | ja | ja_JP.UTF-8 | Translated |
| Chinese (Simplified) | zh_CN | zh_CN.UTF-8 | Translated |
| Korean | ko | ko_KR.UTF-8 | Translated |
| Czech | cs | cs_CZ.UTF-8 | In progress |
| Spanish | es | es_ES.UTF-8 | In progress |

## Documentation Modules

The documentation is organized into **9 modules**:

1. **ROOT** - Landing page and index
2. **installation-and-upgrade** - Installation and upgrade procedures
3. **client-configuration** - Client setup and management
4. **administration** - System administration
5. **reference** - API and CLI reference
6. **retail** - Retail-specific features
7. **common-workflows** - Common use cases
8. **specialized-guides** - Advanced topics
9. **legal** - Legal notices and licenses

## Build System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│ CONFIGURATION                                                   │
│ - parameters.yml (central configuration)                        │
│ - configure script (generates build files)                      │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ TRANSLATION SYSTEM                                              │
│ - po4a (extract/apply translations)                             │
│ - Weblate (translation platform)                                │
│ - PO/POT files (translation storage)                            │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ BUILD ORCHESTRATION                                             │
│ - Makefile (main orchestrator)                                  │
│ - Language-specific Makefiles                                   │
│ - Section-specific Makefiles                                    │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ├───────────────────┬─────────────────┐
                            ▼                   ▼                 ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ HTML GENERATION  │  │ PDF GENERATION   │  │ PACKAGING        │
│ - Antora         │  │ - asciidoctor    │  │ - OBS packages   │
│ - Per language   │  │ - Per guide      │  │ - Distribution   │
└──────────────────┘  └──────────────────┘  └──────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ OUTPUT                                                          │
│ build/en/, build/ja/, build/zh_CN/, build/ko/                  │
└─────────────────────────────────────────────────────────────────┘
```

## Key Technologies

### Build Tools
- **GNU Make** - Build orchestration
- **Python 3 + Jinja2** - Configuration generation
- **Bash** - Utility scripts

### Documentation Tools
- **Antora** - Static site generator for technical documentation
- **AsciiDoc** - Lightweight markup language
- **asciidoctor-pdf** - PDF generation from AsciiDoc

### Translation Tools
- **po4a** - Translation extraction/application
- **Weblate** - Web-based translation management
- **Gettext (PO/POT)** - Industry-standard translation format

### Packaging
- **Open Build Service (OBS)** - Package distribution system
- **tar/gzip** - Archive formats

## Directory Structure

```
uyuni-docs/
├── modules/                    # Source documentation (English)
│   ├── administration/
│   ├── client-configuration/
│   ├── common-workflows/
│   ├── installation-and-upgrade/
│   ├── legal/
│   ├── reference/
│   ├── retail/
│   ├── ROOT/
│   └── specialized-guides/
│
├── l10n-weblate/              # Translation files (PO/POT)
│   ├── administration/
│   │   ├── administration.pot
│   │   ├── ja.po
│   │   ├── zh_CN.po
│   │   └── ko.po
│   └── ... (per module)
│
├── translations/              # Generated translated content
│   ├── ja/modules/
│   ├── zh_CN/modules/
│   └── ko/modules/
│
├── build/                     # Build output
│   ├── en/
│   ├── ja/
│   ├── zh_CN/
│   └── ko/
│
├── branding/                  # Themes and UI customization
│   ├── pdf/
│   ├── supplemental-ui/
│   └── locale/
│
├── Makefile                   # Main build orchestrator
├── Makefile.en, Makefile.ja   # Language-specific (generated)
├── configure                  # Configuration generator
├── parameters.yml             # Central configuration
├── site.yml                   # Antora site configuration
└── antora.yml                 # Antora component configuration
```

## Build Workflow Overview

### 1. Configuration Phase
```bash
./configure mlm      # or ./configure uyuni
```
- Reads `parameters.yml`
- Generates language-specific Makefiles
- Creates product-specific configurations

### 2. Translation Phase (Optional)
```bash
make update-cfg-files
make pot
# [Translators work in Weblate]
make translations
```
- Extracts translatable strings
- Translators work in Weblate
- Applies translations to create localized content

### 3. Build Phase
```bash
make antora-mlm      # Builds all languages for MLM
# or
make antora-uyuni    # Builds all languages for Uyuni
```
- Generates HTML documentation for all languages
- Creates search indexes
- Applies branding and themes

### 4. PDF Generation Phase
```bash
make pdf-all-mlm     # Generates all PDFs
```
- Builds PDF guides for each module
- Supports CJK languages with special fonts
- Applies product-specific themes

### 5. Packaging Phase
```bash
make obs-packages-mlm
```
- Creates distribution packages
- Generates OBS-compatible tarballs
- Ready for deployment

## Quick Start

### First-Time Setup
```bash
# Clone repository
git clone https://github.com/uyuni-project/uyuni-docs.git
cd uyuni-docs

# Install dependencies (example for openSUSE)
sudo zypper install make python3-Jinja2 python3-PyYAML po4a
npm install

# Configure for your product
./configure mlm      # or ./configure uyuni

# Build English documentation
make antora-mlm-en
```

### Development Build
```bash
# After modifying documentation
make configure-mlm
make antora-mlm-en
firefox build/en/index.html
```

### Full Production Build
```bash
# Complete build with all languages
make all-mlm         # or make all-uyuni
```

## Key Concepts

### Product Switching
The same source repository builds **different documentation** for MLM vs Uyuni using:
- Conditional content (`ifdef::mlm-content[]`)
- Product-specific attributes
- Different component names
- Different URLs and branding

### Language Support
Each language has:
- **Independent build** - Builds run in parallel
- **Translated content** - Full documentation translated
- **Localized assets** - Screenshots in target language
- **Native search** - Search indexes in target language
- **Language selector** - Easy switching between languages

### Modular Architecture
The Makefile system is **highly modular**:
- **Main Makefile** - Core functions and orchestration
- **Language Makefiles** - Per-language targets (generated)
- **Section Makefiles** - PDF generation functions (generated)
- **Target Makefiles** - Multi-language aggregation (generated)

This modularity enables:
- Adding languages without modifying core files
- Building specific combinations
- Parallel builds
- Easy maintenance

## Performance Characteristics

### Build Times (Approximate)
| Task | Time | Notes |
|------|------|-------|
| Configure | <1s | Fast |
| make pot | 30s | Extracts all strings |
| make translations | 2min | Applies all translations |
| make antora-mlm-en | 5min | Single language HTML |
| make antora-mlm | 20min | All languages HTML |
| make pdf-all-mlm-en | 30min | All English PDFs |
| make pdf-all-mlm | 2hr | All PDFs all languages |
| make all-mlm | 3hr | Complete production build |

*Times vary based on hardware*

### Resource Requirements
- **Disk Space:** ~10GB for complete build
- **RAM:** 8GB recommended (4GB minimum)
- **CPU:** Multi-core benefits parallel builds
- **Network:** Required for npm packages, Antora

## Quality Assurance

### Validation
```bash
make validate-mlm    # Check cross-references
make checkstyle      # Check documentation style
```

### Testing
- **Cross-reference validation** - Ensures all links work
- **Style enforcement** - Consistent formatting
- **Build testing** - Catch errors early

## Deployment

### Documentation.suse.com (MLM)
```bash
make configure-mlm-branding-dsc
make obs-packages-mlm
# Upload to OBS
```

### Uyuni-project.org (Uyuni)
```bash
make obs-packages-uyuni
# Upload to OBS
```

## Related Documentation

- [BUILD_VARIABLES.md](BUILD_VARIABLES.md) - Configuration variables reference
- [BUILD_FUNCTIONS.md](BUILD_FUNCTIONS.md) - Make function reference
- [BUILD_TARGETS.md](BUILD_TARGETS.md) - Make target reference
- [CONFIGURE_SCRIPT.md](CONFIGURE_SCRIPT.md) - Configuration generator
- [TRANSLATION_SYSTEM.md](TRANSLATION_SYSTEM.md) - Translation workflow
- [HTML_BUILD_PROCESS.md](HTML_BUILD_PROCESS.md) - Antora HTML generation
- [PDF_BUILD_PROCESS.md](PDF_BUILD_PROCESS.md) - PDF generation
- [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) - Quick start for contributors

---

**Next:** Read [BUILD_VARIABLES.md](BUILD_VARIABLES.md) to understand configuration options.
