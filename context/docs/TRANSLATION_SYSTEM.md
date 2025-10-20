# Translation and Localization System Documentation

**Version:** 1.0  
**Last Updated:** October 20, 2025

## Table of Contents
1. [Overview](#overview)
2. [Translation Architecture](#translation-architecture)
3. [Tools and Technologies](#tools-and-technologies)
4. [Directory Structure](#directory-structure)
5. [Translation Workflow](#translation-workflow)
6. [Scripts Reference](#scripts-reference)
7. [Weblate Configuration](#weblate-configuration)
8. [How antora-mlm/uyuni Generates Localized Versions](#how-antora-mlmuyuni-generates-localized-versions)
9. [File Format Details](#file-format-details)
10. [Examples](#examples)
11. [Troubleshooting](#troubleshooting)

---

## Overview

The uyuni-docs project uses a **professional translation management system** based on:
- **po4a** - Translation extraction and application tool
- **Weblate** - Web-based collaborative translation platform
- **Gettext format** (PO/POT files) - Industry-standard translation format

**Supported Languages:**
- English (en) - Source language
- Japanese (ja)
- Chinese Simplified (zh_CN)
- Korean (ko)
- Czech (cs)
- Spanish (es)
- Macedonian (mk)

**Translation Coverage:**
The system translates **all documentation content** including:
- Documentation pages (`.adoc` files)
- Navigation files
- Attributes files
- Partial/include files
- All 9 documentation modules

---

## Translation Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│ SOURCE CONTENT (English)                                        │
│ modules/*/pages/*.adoc                                          │
│ modules/*/nav-*.adoc                                            │
│ modules/*/_attributes.adoc                                      │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ EXTRACTION (make pot)                                           │
│ Script: make_pot.sh                                             │
│ Tool: po4a                                                      │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ TRANSLATABLE STRINGS (POT Files)                                │
│ l10n-weblate/administration/administration.pot                  │
│ l10n-weblate/client-configuration/client-configuration.pot      │
│ l10n-weblate/*/module.pot (one per module)                      │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ WEBLATE (Translation Platform)                                  │
│ https://l10n.opensuse.org/projects/uyuni/                       │
│ - Translators work online                                       │
│ - Review and approve translations                               │
│ - Generate PO files per language                                │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ TRANSLATED STRINGS (PO Files)                                   │
│ l10n-weblate/administration/ja.po                               │
│ l10n-weblate/administration/zh_CN.po                            │
│ l10n-weblate/administration/ko.po                               │
│ (one PO file per module per language)                           │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ APPLICATION (make translations)                                 │
│ Script: use_po.sh                                               │
│ Tool: po4a                                                      │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ TRANSLATED CONTENT (Localized AsciiDoc)                         │
│ translations/ja/modules/*/pages/*.adoc                          │
│ translations/zh_CN/modules/*/pages/*.adoc                       │
│ translations/ko/modules/*/pages/*.adoc                          │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ BUILD (make antora-mlm / make antora-uyuni)                     │
│ Antora reads from translations/<lang>/modules/                  │
│ Generates HTML to build/<lang>/                                 │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ OUTPUT (Localized Documentation Sites)                          │
│ build/en/    - English HTML                                     │
│ build/ja/    - Japanese HTML                                    │
│ build/zh_CN/ - Chinese HTML                                     │
│ build/ko/    - Korean HTML                                      │
└─────────────────────────────────────────────────────────────────┘
```

### Key Concepts

**POT (Portable Object Template)**
- **What:** Master template containing all translatable strings
- **Language:** Source language only (English)
- **Purpose:** Distributed to translators as the basis for translation
- **Location:** `l10n-weblate/*/module.pot`

**PO (Portable Object)**
- **What:** Translation file containing source strings + translated strings
- **Language:** One PO file per target language
- **Purpose:** Stores actual translations
- **Location:** `l10n-weblate/*/langcode.po` (e.g., `ja.po`, `zh_CN.po`)

**po4a (PO for Anything)**
- **What:** Tool for extracting and applying translations
- **Purpose:** Converts between AsciiDoc ↔ PO format
- **Supports:** AsciiDoc, Markdown, XML, and many other formats

**Weblate**
- **What:** Web-based translation management platform
- **URL:** https://l10n.opensuse.org/projects/uyuni/
- **Purpose:** Collaborative translation interface for translators
- **Features:** Translation memory, quality checks, glossary, version control integration

---

## Tools and Technologies

### po4a (PO for Anything)

**Version Required:** > 0.58

**Installation:**
```bash
# Debian/Ubuntu
sudo apt-get install po4a

# RHEL/CentOS/OpenSUSE
sudo zypper install po4a

# From source
git clone https://github.com/mquinson/po4a.git
cd po4a
# Set PERLLIB when running scripts
```

**Usage in This Project:**
- Extract translatable strings from AsciiDoc → POT files
- Apply translations from PO files → Translated AsciiDoc

**Key Options:**
- `-k 0` - Translation threshold (0% = all strings must be translated)
- `-M utf-8` - Master document encoding
- `-L utf-8` - Localized document encoding
- `--no-translations` - Extract only, don't generate translated docs
- `--no-update` - Apply only, don't update POT/PO files
- `-o nolinting` - Disable format linting

### Gettext Format (PO/POT)

**Industry Standard:** Used by thousands of projects (GNOME, KDE, WordPress, etc.)

**File Structure:**
```po
# Comment
#: source-file.adoc:line-number
msgid "Source text in English"
msgstr "Translated text in target language"
```

**Benefits:**
- Human-readable text format
- Version control friendly
- Tool ecosystem (poedit, lokalize, etc.)
- Translation memory support
- Fuzzy matching for changed strings

### Weblate

**Platform:** https://l10n.opensuse.org/

**Projects:**
- uyuni/docs-administration-master
- uyuni/docs-client-configuration-master
- uyuni/docs-common-workflows-master
- uyuni/docs-installation-and-upgrade-master
- uyuni/docs-legal-master
- uyuni/docs-reference-master
- uyuni/docs-retail-master
- uyuni/docs-root-master
- uyuni/docs-specialized-guides-master

**Workflow Integration:**
1. Developers run `make pot` → generates POT files
2. POT files committed to git
3. Weblate automatically imports POT files
4. Translators translate online
5. Weblate commits PO files back to git
6. Developers run `make translations` → generates translated docs

---

## Directory Structure

### Source Content

```
modules/
├── administration/
│   ├── _attributes.adoc
│   ├── nav-administration-guide.adoc
│   ├── pages/
│   │   ├── actions.adoc
│   │   ├── ansible-integration.adoc
│   │   └── ... (100+ files)
│   ├── partials/
│   └── assets/
│       └── images/
├── client-configuration/
├── common-workflows/
├── installation-and-upgrade/
├── legal/
├── reference/
├── retail/
├── ROOT/
└── specialized-guides/
```

### Translation Files (l10n-weblate/)

```
l10n-weblate/
├── administration/
│   ├── administration.cfg           # po4a configuration
│   ├── administration.pot           # Master template
│   ├── ja.po                        # Japanese translations
│   ├── zh_CN.po                     # Chinese translations
│   ├── ko.po                        # Korean translations
│   ├── cs.po                        # Czech translations
│   ├── es.po                        # Spanish translations
│   ├── assets-ja/                   # Japanese screenshots (if any)
│   ├── assets-zh_CN/                # Chinese screenshots
│   └── assets-ko/                   # Korean screenshots
├── client-configuration/
│   ├── client-configuration.cfg
│   ├── client-configuration.pot
│   ├── ja.po
│   └── ... (same structure)
├── common-workflows/
├── installation-and-upgrade/
├── legal/
├── reference/
├── retail/
├── ROOT/
├── specialized-guides/
├── administration.cfg               # Top-level config (symlink)
├── client-configuration.cfg
└── update-cfg-files                 # Config generator script
```

### Translated Content (translations/)

```
translations/
├── ja/
│   ├── antora.yml
│   ├── mlm-site.yml (or uyuni-site.yml)
│   ├── branding/
│   └── modules/
│       ├── administration/
│       │   ├── _attributes.adoc         # Translated
│       │   ├── nav-administration-guide.adoc  # Translated
│       │   ├── pages/
│       │   │   ├── actions.adoc         # Translated
│       │   │   └── ... (all files)
│       │   └── assets/
│       │       └── images/              # Localized screenshots
│       ├── client-configuration/
│       └── ... (all modules)
├── zh_CN/
│   └── ... (same structure)
├── ko/
│   └── ... (same structure)
└── en/
    └── ... (copy of source, generated during build)
```

### Build Output (build/)

```
build/
├── en/
│   ├── index.html
│   ├── docs/                        # or uyuni/ for Uyuni
│   │   ├── administration/
│   │   ├── client-configuration/
│   │   └── ...
│   └── pdf/
│       ├── suse_multi_linux_manager_administration_guide.pdf
│       └── ...
├── ja/
│   ├── index.html                   # Localized
│   ├── docs/                        # Localized content
│   └── pdf/                         # Localized PDFs
├── zh_CN/
└── ko/
```

---

## Translation Workflow

### Complete Translation Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 1: CONTENT DEVELOPMENT                                    │
└─────────────────────────────────────────────────────────────────┘

Developer writes/updates English documentation
    └─> modules/*/pages/*.adoc

┌─────────────────────────────────────────────────────────────────┐
│ PHASE 2: EXTRACTION                                             │
└─────────────────────────────────────────────────────────────────┘

make update-cfg-files
    └─> Updates po4a configuration files
    └─> Scans for new/deleted .adoc files
    └─> Updates l10n-weblate/*.cfg

make pot
    └─> Runs make_pot.sh
    └─> Executes po4a for each module
    └─> Generates/updates POT files
    └─> Copies screenshots to assets-<lang>/ directories
    └─> Output: l10n-weblate/*/module.pot

Git commit POT files
    └─> git add l10n-weblate/
    └─> git commit -m "Update POT files"
    └─> git push

┌─────────────────────────────────────────────────────────────────┐
│ PHASE 3: TRANSLATION (Weblate)                                  │
└─────────────────────────────────────────────────────────────────┘

Weblate automatically detects updated POT files
    └─> Imports new strings
    └─> Marks changed strings as "fuzzy"
    └─> Preserves existing translations

Translators work in Weblate
    ├─> Translate new strings
    ├─> Review fuzzy strings
    ├─> Use translation memory
    └─> Quality checks (format, placeholders, etc.)

Weblate commits translations
    └─> Creates PO files: l10n-weblate/*/ja.po, zh_CN.po, ko.po
    └─> Commits to git repository
    └─> Automatically syncs with main branch

┌─────────────────────────────────────────────────────────────────┐
│ PHASE 4: APPLICATION                                            │
└─────────────────────────────────────────────────────────────────┘

Developer pulls latest translations
    └─> git pull origin master

make translations
    └─> Runs use_po.sh
    └─> Executes po4a for each module × language
    └─> Applies PO files to source AsciiDoc
    └─> Generates translated .adoc files
    └─> Copies localized screenshots
    └─> Output: translations/<lang>/modules/

┌─────────────────────────────────────────────────────────────────┐
│ PHASE 5: BUILD                                                  │
└─────────────────────────────────────────────────────────────────┘

make configure-mlm (or configure-uyuni)
    └─> Generates language-specific Makefiles

make antora-mlm (or antora-uyuni)
    └─> For each language (en, ja, zh_CN, ko):
        ├─> prepare-antora-<lang>
        │   ├─> Copy branding
        │   ├─> Set language selector
        │   ├─> Copy modules to translations/<lang>/
        │   └─> Create site.yml
        ├─> npx antora <lang>-site.yml
        │   ├─> Reads translations/<lang>/modules/
        │   ├─> Processes translated .adoc files
        │   ├─> Generates HTML
        │   └─> Creates search index
        └─> Output: build/<lang>/

┌─────────────────────────────────────────────────────────────────┐
│ PHASE 6: PUBLICATION                                            │
└─────────────────────────────────────────────────────────────────┘

make obs-packages-mlm (or obs-packages-uyuni)
    └─> Creates distribution packages
    └─> Output: build/packages/*.tar.gz
    └─> Ready for deployment
```

### Quick Reference Commands

```bash
# 1. After updating documentation
make update-cfg-files        # Update configuration
make pot                     # Extract translatable strings

# 2. Commit POT files
git add l10n-weblate/
git commit -m "Update translations"
git push

# 3. [Translators work in Weblate]

# 4. Pull translations and build
git pull                     # Get latest PO files
make translations            # Generate translated .adoc
make configure-mlm           # Configure build
make antora-mlm              # Build all languages
```

---

## Scripts Reference

### make_pot.sh - Extract Translatable Strings

**Purpose:** Extracts translatable content from source AsciiDoc files into POT (Portable Object Template) files.

**Location:** Project root

**Command:**
```bash
make pot                     # Via Makefile
./make_pot.sh               # Direct execution
```

**Dependencies:**
- `po4a` (version > 0.58)
- Configuration files: `l10n-weblate/*.cfg`

**What It Does:**

1. **Process Configuration Files**
```bash
for f in `ls $CURRENT_DIR/$PO_DIR/*.cfg`; do
    po4a -v --srcdir $CURRENT_DIR --destdir $CURRENT_DIR \
         -k 0 -M utf-8 -L utf-8 --no-translations -o nolinting $f
done
```

- Loops through all `.cfg` files in `l10n-weblate/`
- Runs `po4a` with:
  - `--no-translations` - Only extract, don't generate translated docs
  - `-k 0` - Translation threshold 0% (all strings must be translated)
  - `-M utf-8` - Master (source) encoding
  - `-L utf-8` - Localized (target) encoding
  - `-o nolinting` - Disable format linting

2. **Copy Screenshots**
```bash
for module in $(find $CURRENT_DIR/$PO_DIR -mindepth 1 -maxdepth 1 -type d -printf "%f\n"); do
    for langpo in $(find $CURRENT_DIR/$PO_DIR/$module -mindepth 1 -maxdepth 1 -type f -name "*.po" -printf "%f\n"); do
        if [ -e $CURRENT_DIR/$SRCDIR_MODULE/$module/assets/images ]; then
            lang=`basename $langpo .po`
            rsync -u --inplace -a --delete $CURRENT_DIR/$SRCDIR_MODULE/$module/assets/* \
                  $CURRENT_DIR/$PO_DIR/$module/assets-$lang/
        fi
    done
done
```

- For each module and each language
- Copies assets (images/screenshots) from source to language-specific directories
- Uses `rsync` with:
  - `-u` - Update only (skip if destination is newer)
  - `--inplace` - Update files in place
  - `-a` - Archive mode (preserve permissions, timestamps, etc.)
  - `--delete` - Delete files that no longer exist in source

**Input:**
- Source AsciiDoc files: `modules/*/pages/*.adoc`
- Configuration: `l10n-weblate/*.cfg`

**Output:**
- POT files: `l10n-weblate/*/module.pot`
- Copied screenshots: `l10n-weblate/*/assets-<lang>/`

**Example Output:**
```
Config file loaded successfully
Updating l10n-weblate/administration/administration.pot
Updating l10n-weblate/client-configuration/client-configuration.pot
... (one per module)
Copying assets to l10n-weblate/administration/assets-ja/
Copying assets to l10n-weblate/administration/assets-zh_CN/
...
```

**When to Use:**
- After adding new documentation files
- After modifying existing documentation
- Before uploading to Weblate for translation

### use_po.sh - Apply Translations

**Purpose:** Applies translations from PO files to generate localized AsciiDoc files.

**Location:** Project root

**Command:**
```bash
make translations            # Via Makefile
./use_po.sh                 # Direct execution
```

**Dependencies:**
- `po4a` (version > 0.54)
- PO files: `l10n-weblate/*/<lang>.po`
- Configuration files: `l10n-weblate/*.cfg`

**What It Does:**

1. **Generate Translated AsciiDoc**
```bash
for f in $(ls $CURRENT_DIR/$PO_DIR/*.cfg); do
    po4a --srcdir $CURRENT_DIR --destdir $CURRENT_DIR \
         -k $TRANSLATION_THRESHOLD_PERCENTAGE \
         -M utf-8 -L utf-8 --no-update -o nolinting $f
done
```

- Loops through all configuration files
- Runs `po4a` with:
  - `--no-update` - Don't update POT/PO files, only generate output
  - `-k 0` - Translation threshold 0% (default)
  - Reads PO files and applies translations to source AsciiDoc
  - Generates translated .adoc files in `translations/<lang>/modules/`

2. **Copy Localized Screenshots**
```bash
for module in $(find $CURRENT_DIR/$PO_DIR -mindepth 1 -maxdepth 1 -type d -printf "%f\n"); do
    for langpo in $(find $CURRENT_DIR/$PO_DIR/$module -mindepth 1 -maxdepth 1 -type f -name "*.po" -printf "%f\n"); do
        lang=`basename $langpo .po`
        if [ -e $CURRENT_DIR/$PO_DIR/$module/assets-$lang ]; then
            mkdir -p $CURRENT_DIR/$PUB_DIR/$lang/modules/$module/assets/images && \
            cp -a $CURRENT_DIR/$PO_DIR/$module/assets-$lang/* \
                  $CURRENT_DIR/$PUB_DIR/$lang/modules/$module/assets/
        fi
    done
done
```

- For each module and language
- Copies localized screenshots from `l10n-weblate/*/assets-<lang>/`
- To `translations/<lang>/modules/*/assets/`

**Input:**
- PO files: `l10n-weblate/*/ja.po`, `zh_CN.po`, `ko.po`, etc.
- Source AsciiDoc: `modules/*/pages/*.adoc`
- Configuration: `l10n-weblate/*.cfg`

**Output:**
- Translated AsciiDoc: `translations/<lang>/modules/*/pages/*.adoc`
- Localized assets: `translations/<lang>/modules/*/assets/`

**Example Output:**
```
Processing administration module for ja
Processing administration module for zh_CN
Processing administration module for ko
Processing client-configuration module for ja
...
Copying localized screenshots
```

**When to Use:**
- After receiving updated translations from Weblate
- Before building localized documentation
- After pulling translation updates from git

**Translation Threshold:**

The script includes commented-out code for handling incomplete translations:

```bash
# If translation < threshold, fall back to English
# Currently disabled (commented out)
```

This feature would overwrite incomplete translations with English content for publication. Currently, all translations are used regardless of completion percentage.

### update-cfg-files - Update Configuration

**Purpose:** Automatically updates po4a configuration files when documentation structure changes.

**Location:** `l10n-weblate/update-cfg-files`

**Command:**
```bash
make update-cfg-files                    # Via Makefile
cd l10n-weblate && ./update-cfg-files   # Direct execution
```

**What It Does:**

```bash
for GUIDE in `for I in *.cfg; do basename $I .cfg; done`; do
    cd $CURRENT_DIR/.. && \
    { 
      # Keep header (non-file lines)
      grep -v "\[type: asciidoc\]" l10n-weblate/$GUIDE.cfg && \
      
      # Find all .adoc files in module
      find modules/$GUIDE/ -type f -name "*.adoc" \
           ! -name "*.pdf.en.adoc" | \
           grep -v \.pdf\.en\.adoc | \
           grep -v gfdl | \
           sort | \
      
      # Generate [type: asciidoc] lines
      while read line; do 
        echo "[type: asciidoc] $line \$lang:translations/\$lang/$line"
      done
    } > l10n-weblate/$GUIDE.cfg.tmp && \
    mv l10n-weblate/$GUIDE.cfg.tmp l10n-weblate/$GUIDE.cfg
done
```

**Process:**
1. For each module configuration file
2. Extract header configuration (languages, paths, options)
3. Scan module directory for all `.adoc` files
4. Exclude PDF-specific files and GFDL license
5. Sort files alphabetically
6. Generate new `[type: asciidoc]` entries
7. Write updated configuration

**Example Before:**
```properties
[po4a_langs] cs es ja ko zh_CN
[po4a_paths] l10n-weblate/administration/administration.pot $lang:l10n-weblate/administration/$lang.po

[type: asciidoc] modules/administration/pages/actions.adoc $lang:translations/$lang/modules/administration/pages/actions.adoc
[type: asciidoc] modules/administration/pages/old-file.adoc $lang:translations/$lang/modules/administration/pages/old-file.adoc
```

**Example After:**
```properties
[po4a_langs] cs es ja ko zh_CN
[po4a_paths] l10n-weblate/administration/administration.pot $lang:l10n-weblate/administration/$lang.po

[type: asciidoc] modules/administration/pages/actions.adoc $lang:translations/$lang/modules/administration/pages/actions.adoc
[type: asciidoc] modules/administration/pages/new-file.adoc $lang:translations/$lang/modules/administration/pages/new-file.adoc
# old-file.adoc removed automatically
```

**When to Use:**
- After adding new documentation files
- After deleting documentation files
- After moving/renaming documentation files
- Before running `make pot`

**Important:** Always run `update-cfg-files` before `make pot` to ensure all files are included in translation.

---

## Weblate Configuration

### Configuration Files (*.cfg)

Each module has a configuration file that tells po4a:
- Which languages to support
- Where POT/PO files are located
- Which source files to translate
- Where to output translated files

**File:** `l10n-weblate/administration.cfg`

```properties
# Supported languages
[po4a_langs] cs es ja ko zh_CN

# POT template path and PO file path pattern
# $lang is replaced with language code (ja, zh_CN, etc.)
[po4a_paths] l10n-weblate/administration/administration.pot $lang:l10n-weblate/administration/$lang.po

# Define asciidoc type with encoding options
[po4a_alias:adoc] adoc opt:"-M UTF-8 -L UTF-8"

# Global options - use counter for line references
[options] opt:"--porefs=counter"

# Source → Translation mappings
# For each .adoc file:
[type: asciidoc] modules/administration/_attributes.adoc $lang:translations/$lang/modules/administration/_attributes.adoc
[type: asciidoc] modules/administration/nav-administration-guide.adoc $lang:translations/$lang/modules/administration/nav-administration-guide.adoc
[type: asciidoc] modules/administration/pages/actions.adoc $lang:translations/$lang/modules/administration/pages/actions.adoc
# ... (one line per file)
```

**Configuration Sections:**

1. **`[po4a_langs]`** - Space-separated list of language codes
2. **`[po4a_paths]`** - POT file location and PO file pattern
3. **`[po4a_alias:adoc]`** - Define custom file type with options
4. **`[options]`** - Global po4a options
5. **`[type: asciidoc]`** - File mappings (source → translated)

### Weblate Project Structure

**URL:** https://l10n.opensuse.org/projects/uyuni/

**Components:**
- docs-administration-master
- docs-client-configuration-master
- docs-common-workflows-master
- docs-installation-and-upgrade-master
- docs-legal-master
- docs-reference-master
- docs-retail-master
- docs-root-master
- docs-specialized-guides-master

**Per Component:**
- **Source:** POT file from git repository
- **Languages:** ja, zh_CN, ko, cs, es (and others)
- **Translation Files:** PO files committed back to git
- **Format:** Gettext PO
- **File Mask:** `l10n-weblate/<module>/*.po`
- **Template:** `l10n-weblate/<module>/<module>.pot`

### Integration with Git

**Workflow:**

1. **POT Upload (Developer → Weblate)**
   ```bash
   make pot
   git add l10n-weblate/
   git commit -m "Update POT files"
   git push
   # Weblate detects changes automatically
   ```

2. **Translation Work (Translator → Weblate)**
   - Translators log into Weblate
   - Select language and component
   - Translate strings in web interface
   - Weblate saves to PO files

3. **PO Download (Weblate → Developer)**
   ```bash
   # Weblate commits PO files to git
   git pull origin master
   # PO files in l10n-weblate/ are updated
   ```

---

## How antora-mlm/uyuni Generates Localized Versions

This is the **key question** you asked about! Here's the complete explanation:

### Complete Build Flow with Translation

```
┌─────────────────────────────────────────────────────────────────┐
│ STEP 1: TRANSLATION PREPARATION                                 │
└─────────────────────────────────────────────────────────────────┘

make translations
    └─> use_po.sh
        ├─> For each module (administration, client-configuration, etc.)
        │   ├─> For each language (ja, zh_CN, ko)
        │   │   ├─> Read: l10n-weblate/<module>/<lang>.po
        │   │   ├─> Read: modules/<module>/pages/*.adoc (source)
        │   │   ├─> Apply translations using po4a
        │   │   └─> Write: translations/<lang>/modules/<module>/pages/*.adoc
        │   │
        │   └─> Copy localized screenshots
        │       └─> l10n-weblate/<module>/assets-<lang>/ → translations/<lang>/modules/<module>/assets/
        │
        └─> Result: Complete translated documentation tree per language

Directory Structure After make translations:
translations/
├── ja/
│   └── modules/
│       ├── administration/
│       │   ├── _attributes.adoc          ← Translated from ja.po
│       │   ├── nav-administration-guide.adoc ← Translated
│       │   ├── pages/
│       │   │   ├── actions.adoc          ← Translated
│       │   │   └── ...                   ← All translated
│       │   └── assets/
│       │       └── images/               ← Localized screenshots
│       ├── client-configuration/
│       └── ...                           ← All modules translated
├── zh_CN/
│   └── modules/                          ← Same structure, Chinese
└── ko/
    └── modules/                          ← Same structure, Korean

┌─────────────────────────────────────────────────────────────────┐
│ STEP 2: CONFIGURATION                                           │
└─────────────────────────────────────────────────────────────────┘

make configure-mlm  (or configure-uyuni)
    └─> Generates language-specific Makefiles
        ├─> Makefile.en
        ├─> Makefile.ja
        ├─> Makefile.zh_CN
        └─> Makefile.ko

┌─────────────────────────────────────────────────────────────────┐
│ STEP 3: ANTORA BUILD ORCHESTRATION                             │
└─────────────────────────────────────────────────────────────────┘

make antora-mlm
    ├─> Calls: antora-mlm-en
    ├─> Calls: antora-mlm-ja
    ├─> Calls: antora-mlm-zh_CN
    └─> Calls: antora-mlm-ko

Each language target (example: antora-mlm-ja):

┌─────────────────────────────────────────────────────────────────┐
│ STEP 4: LANGUAGE-SPECIFIC BUILD (antora-mlm-ja)                │
└─────────────────────────────────────────────────────────────────┘

4a. prepare-antora-mlm-ja
    ├─> copy-branding-ja
    │   └─> Copy branding files to translations/ja/
    │
    ├─> set-html-language-selector-mlm-ja
    │   └─> Inject language selector buttons (EN, JA, ZH, KO flags)
    │
    ├─> Copy antora.yml
    │   └─> cp antora.yml translations/ja/antora.yml
    │
    ├─> Generate ja-specific site.yml
    │   └─> sed "s/url: https:\/\/documentation.suse.com\/multi-linux-manager\/5.1\//url: https:\/\/documentation.suse.com\/multi-linux-manager\/5.1\/ja\//; \
    │            s/start_path: \./start_path: translations\/ja/; \
    │            s/dir: \.\/build\/en/dir: \.\.\/\.\.\/build\/ja/" \
    │            site.yml > translations/ja/mlm-site.yml
    │
    │   Result: translations/ja/mlm-site.yml contains:
    │       - url: https://documentation.suse.com/multi-linux-manager/5.1/ja/
    │       - start_path: translations/ja
    │       - output: ../../build/ja
    │
    ├─> Copy modules
    │   └─> cp -a modules translations/ja/
    │       (But translated files already exist from make translations!)
    │
    └─> Copy license file
        └─> cp modules/ROOT/pages/common_gfdl1.2_i.adoc translations/ja/modules/ROOT/pages/

4b. Build PDFs (pdf-all-mlm-ja)
    └─> Generates Japanese PDFs with:
        - Japanese locale (ja_JP.UTF-8)
        - Japanese date format (%Y年%m月%e日)
        - CJK PDF theme (suse-jp)
        - CJK fonts support (-a scripts=cjk)
        - Reading from: translations/ja/modules/

4c. Package PDFs (pdf-tar-mlm-ja)
    └─> Creates ZIP of Japanese PDFs

4d. Run Antora (antora-mlm-function)
    └─> cd translations/ja && \
        DOCSEARCH_ENABLED=true \
        SITE_SEARCH_PROVIDER=lunr \
        LANG=ja \
        LC_ALL=ja_JP.UTF-8 \
        npx antora mlm-site.yml --stacktrace

    Antora Process:
    ├─> Reads: translations/ja/antora.yml
    ├─> Reads: translations/ja/mlm-site.yml
    │   - start_path: translations/ja
    │   - output: ../../build/ja
    │
    ├─> Scans: translations/ja/modules/
    │   ├─> administration/ (Japanese .adoc files)
    │   ├─> client-configuration/ (Japanese)
    │   └─> ... (all modules in Japanese)
    │
    ├─> Processes each .adoc file:
    │   ├─> Parse AsciiDoc (Japanese text)
    │   ├─> Apply attributes (productname, productnumber, etc.)
    │   ├─> Resolve xrefs (cross-references)
    │   ├─> Process includes
    │   ├─> Generate HTML
    │   └─> Apply UI theme (with Japanese language selector)
    │
    ├─> Generate search index:
    │   └─> lunr.js index with Japanese text
    │
    └─> Write output: build/ja/
        ├── index.html (Japanese)
        ├── docs/
        │   ├── administration/
        │   │   ├── actions.html (Japanese)
        │   │   └── ... (all pages in Japanese)
        │   ├── client-configuration/
        │   └── ...
        └── _/
            └── js/site/search-index.js (Japanese search terms)

┌─────────────────────────────────────────────────────────────────┐
│ RESULT: LOCALIZED DOCUMENTATION SITE                            │
└─────────────────────────────────────────────────────────────────┘

build/
├── en/
│   ├── index.html           (English navigation)
│   └── docs/                (English content)
│
├── ja/
│   ├── index.html           (日本語ナビゲーション)
│   └── docs/                (日本語コンテンツ)
│       ├── administration/
│       │   └── actions.html (日本語で書かれています)
│       └── ...
│
├── zh_CN/
│   ├── index.html           (中文导航)
│   └── docs/                (中文内容)
│
└── ko/
    ├── index.html           (한국어 탐색)
    └── docs/                (한국어 콘텐츠)
```

### Key Points

1. **`make translations`** is the critical step that converts PO → translated AsciiDoc

2. **Antora** doesn't know about translations - it just reads whatever .adoc files exist in `translations/<lang>/modules/`

3. **Each language is independent** - built in parallel with its own:
   - Source directory (`translations/<lang>/`)
   - Output directory (`build/<lang>/`)
   - Site configuration (`translations/<lang>/mlm-site.yml`)
   - Locale settings (`LANG=ja`, etc.)

4. **Language selector works** because each language build includes buttons linking to other languages (`/en/`, `/ja/`, `/zh_CN/`, `/ko/`)

5. **Search is localized** - Lunr.js indexes Japanese/Chinese/Korean text separately per language

### The Magic is in the Preparation

The real "magic" happens in `prepare-antora-mlm-<lang>`:

```bash
# This sed command modifies site.yml for Japanese:
sed "s/\(url: https://documentation.suse.com/multi-linux-manager/5.1/\)/\1ja\//; \
     s/start_path: \./start_path: translations\/ja/; \
     s/dir: \.\/build\/en/dir: \.\.\/\.\.\/build\/ja/" \
     site.yml > translations/ja/mlm-site.yml
```

**Before (site.yml):**
```yaml
url: https://documentation.suse.com/multi-linux-manager/5.1/
start_path: .
output:
  dir: ./build/en
```

**After (translations/ja/mlm-site.yml):**
```yaml
url: https://documentation.suse.com/multi-linux-manager/5.1/ja/
start_path: translations/ja
output:
  dir: ../../build/ja
```

This tells Antora:
- **start_path: translations/ja** - Read content from this directory
- **dir: ../../build/ja** - Write output here
- **url: .../ja/** - Base URL includes language code

---

## File Format Details

### POT File Format

**Example:** `l10n-weblate/administration/administration.pot`

```po
# SOME DESCRIPTIVE TITLE
# Copyright (C) YEAR Free Software Foundation, Inc.
# This file is distributed under the same license as the PACKAGE package.
# FIRST AUTHOR <EMAIL@ADDRESS>, YEAR.
#
#, fuzzy
msgid ""
msgstr ""
"Project-Id-Version: PACKAGE VERSION\n"
"POT-Creation-Date: 2025-10-20 09:58+0000\n"
"PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE\n"
"Last-Translator: FULL NAME <EMAIL@ADDRESS>\n"
"Language-Team: LANGUAGE <LL@li.org>\n"
"Language: \n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=utf-8\n"
"Content-Transfer-Encoding: 8bit\n"

#. type: Title =
#: modules/administration/nav-administration-guide.adoc:1
#, no-wrap
msgid "[.title]#{productname} {productnumber}#: Administration Guide"
msgstr ""

#. type: Plain text
#: modules/administration/nav-administration-guide.adoc:2
msgid "xref:admin-overview.adoc[Administration Guide]"
msgstr ""
```

**Components:**
- **Header:** Metadata (encoding, creation date, project info)
- **Comments:** `#.` = extracted comment, `#:` = source location, `#,` = flags
- **msgid:** Source string (English)
- **msgstr:** Translation (empty in POT, filled in PO files)

### PO File Format

**Example:** `l10n-weblate/administration/ja.po`

```po
# Japanese translation header
msgid ""
msgstr ""
"Project-Id-Version: PACKAGE VERSION\n"
"POT-Creation-Date: 2025-10-20 09:58+0000\n"
"PO-Revision-Date: 2025-10-09 16:01+0000\n"
"Last-Translator: anonymous <noreply@weblate.org>\n"
"Language-Team: Japanese <https://l10n.opensuse.org/projects/uyuni/docs-administration-master/ja/>\n"
"Language: ja\n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"
"Plural-Forms: nplurals=1; plural=0;\n"
"X-Generator: Weblate 5.13.3\n"

#. type: Title =
#: modules/administration/nav-administration-guide.adoc:1
#, no-wrap
msgid "[.title]#{productname} {productnumber}#: Administration Guide"
msgstr "[.title]#{productname} {productnumber}#: 管理者ガイド"

#. type: Plain text
#: modules/administration/nav-administration-guide.adoc:2
msgid "xref:admin-overview.adoc[Administration Guide]"
msgstr "xref:admin-overview.adoc[管理者ガイド]"
```

**Differences from POT:**
- **Language:** Set to target language (`ja`)
- **msgstr:** Contains actual translations
- **PO-Revision-Date:** Last translation update
- **Last-Translator:** Who translated
- **X-Generator:** Tool used (Weblate)

### Fuzzy Translations

```po
#. type: Plain text
#: modules/administration/nav-administration-guide.adoc:3
#, fuzzy
#| msgid "xref:admin-overview.adoc[Administration Guide]"
msgid "xref:uyuni-admin-overview.adoc[Administration Guide]"
msgstr "xref:admin-overview.adoc[管理者ガイド]"
```

**Fuzzy Flag (`#, fuzzy`):**
- Indicates source text changed since translation
- Shows old source with `#|`
- Translation may be outdated
- Translator should review and update
- Not used in builds (treated as untranslated by default)

---

## Examples

### Example 1: Complete Translation Workflow

**Scenario:** Developer adds new documentation page

```bash
# 1. Developer adds new file
vim modules/administration/pages/new-feature.adoc
git add modules/administration/pages/new-feature.adoc
git commit -m "Add new feature documentation"

# 2. Update configuration to include new file
make update-cfg-files
# Result: l10n-weblate/administration.cfg updated with new-feature.adoc

# 3. Extract translatable strings
make pot
# Result: l10n-weblate/administration/administration.pot updated

# 4. Commit POT file
git add l10n-weblate/
git commit -m "Update POT files with new feature"
git push

# 5. [Weblate automatically imports new strings]

# 6. [Translators work in Weblate]
#    - Japanese translator translates new strings
#    - Chinese translator translates new strings
#    - Korean translator translates new strings

# 7. [Weblate commits PO files]
#    - l10n-weblate/administration/ja.po updated
#    - l10n-weblate/administration/zh_CN.po updated
#    - l10n-weblate/administration/ko.po updated

# 8. Developer pulls translations
git pull origin master

# 9. Apply translations
make translations
# Result: translations/*/modules/administration/pages/new-feature.adoc created

# 10. Build localized docs
make configure-mlm
make antora-mlm
# Result: build/ja/, build/zh_CN/, build/ko/ all contain new feature
```

### Example 2: Test Single Language Build

```bash
# Apply translations
make translations

# Configure
make configure-mlm

# Build only Japanese
make antora-mlm-ja

# Check output
ls -l build/ja/docs/administration/
firefox build/ja/index.html
```

### Example 3: Check Translation Status

```bash
# Check Japanese translation completeness
pocount l10n-weblate/administration/ja.po

# Output example:
# Translated: 1234 strings (95%)
# Fuzzy: 45 strings (3%)
# Untranslated: 23 strings (2%)

# Check all languages for one module
for lang in ja zh_CN ko; do
    echo "=== $lang ==="
    pocount l10n-weblate/administration/$lang.po
done
```

### Example 4: Extract Strings from Single Module

```bash
# Extract only from administration module
po4a -v --srcdir . --destdir . -k 0 -M utf-8 -L utf-8 \
     --no-translations -o nolinting \
     l10n-weblate/administration.cfg

# Result: l10n-weblate/administration/administration.pot updated
```

### Example 5: Apply Translations for Single Module and Language

```bash
# Apply only Japanese translations for administration
po4a --srcdir . --destdir . -k 0 -M utf-8 -L utf-8 \
     --no-update -o nolinting \
     l10n-weblate/administration.cfg

# Check output
ls -l translations/ja/modules/administration/pages/
```

### Example 6: Compare Source and Translation

```bash
# View source
cat modules/administration/pages/actions.adoc | head -20

# View Japanese translation
cat translations/ja/modules/administration/pages/actions.adoc | head -20

# View PO entry
grep -A 3 "pages/actions.adoc" l10n-weblate/administration/ja.po | head -20
```

### Example 7: Adding a New Language

**Step 1: Update parameters.yml**
```yaml
languages:
  # ... existing languages ...
  - langcode: "de"
    locale: "de_DE.UTF-8"
    gnudateformat: "%e. %B %Y"
    pdf_theme_mlm: "suse"
    pdf_theme_uyuni: "uyuni"
    flag_svg_without_ext: "deFlag"
    nation_in_eng: "germany"
    language_in_orig: "Deutsch"
```

**Step 2: Update Weblate configuration**
```bash
# Edit each module's .cfg file
vim l10n-weblate/administration.cfg

# Add 'de' to language list
[po4a_langs] cs es ja ko zh_CN de
```

**Step 3: Reconfigure**
```bash
./configure mlm
# Generates Makefile.de with German targets

make update-cfg-files
make pot
# Creates German PO files
```

**Step 4: Build**
```bash
make translations
make antora-mlm-de
```

---

## Troubleshooting

### Issue: "make translations" produces empty files

**Symptoms:**
```bash
make translations
ls translations/ja/modules/administration/pages/
# Files exist but are empty or very small
```

**Causes:**
1. PO files don't exist or are empty
2. PO files not synchronized with POT
3. Translation threshold too high

**Solutions:**

```bash
# 1. Check PO files exist
ls -lh l10n-weblate/administration/*.po
# Should see ja.po, zh_CN.po, ko.po with reasonable size

# 2. Check PO files have translations
head -100 l10n-weblate/administration/ja.po
# Should see msgstr entries with Japanese text

# 3. Check for PO file corruption
msgfmt --check l10n-weblate/administration/ja.po
# Reports any format errors

# 4. Re-run with verbose output
cd /tmp
po4a -v --srcdir /path/to/uyuni-docs --destdir /path/to/uyuni-docs \
     -k 0 -M utf-8 -L utf-8 --no-update -o nolinting \
     /path/to/uyuni-docs/l10n-weblate/administration.cfg
```

### Issue: New files not included in translations

**Cause:** Configuration files not updated

**Solution:**
```bash
make update-cfg-files
make pot
# Then proceed with normal workflow
```

### Issue: Translations not appearing in build

**Symptoms:**
```bash
make antora-mlm-ja
# But build/ja/ shows English content
```

**Debugging:**

```bash
# 1. Check translations were applied
ls -l translations/ja/modules/administration/pages/
cat translations/ja/modules/administration/pages/actions.adoc
# Should be in Japanese

# 2. Check Antora is reading from correct location
cat translations/ja/mlm-site.yml | grep start_path
# Should be: start_path: translations/ja

# 3. Check build output language
cat build/ja/docs/administration/actions.html | head -50
# Should contain Japanese text

# 4. Rebuild with clean slate
make clean
make translations
make configure-mlm
make antora-mlm-ja
```

### Issue: po4a version too old

**Symptoms:**
```
po4a: Unknown option: no-translations
```

**Cause:** po4a version < 0.54

**Solution:**
```bash
# Check version
po4a --version

# Install newer version
# Debian/Ubuntu
sudo apt-get install po4a

# Or from source
git clone https://github.com/mquinson/po4a.git
cd po4a
# Follow installation instructions
```

### Issue: Encoding problems (garbled characters)

**Symptoms:**
- Japanese/Chinese/Korean characters appear as `?` or `�`
- PDF generation fails with encoding errors

**Solutions:**

```bash
# 1. Check locale is installed
locale -a | grep -E '(ja_JP|zh_CN|ko_KR)'

# 2. Install missing locales (Debian/Ubuntu)
sudo apt-get install language-pack-ja language-pack-zh-hans language-pack-ko

# 3. Set environment before building
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8
make antora-mlm-ja

# 4. Check file encoding
file translations/ja/modules/administration/pages/actions.adoc
# Should report: UTF-8 Unicode text
```

### Issue: Missing screenshots in translations

**Cause:** Screenshots not copied

**Solutions:**

```bash
# 1. Check source screenshots exist
ls modules/administration/assets/images/

# 2. Check screenshot staging area
ls l10n-weblate/administration/assets-ja/images/

# 3. Manually copy if needed
rsync -av modules/administration/assets/ \
         l10n-weblate/administration/assets-ja/

# 4. Re-run translations
make translations
```

### Issue: POT file not updating

**Cause:** Configuration doesn't include new files

**Solution:**
```bash
# Always run this before make pot
make update-cfg-files

# Verify new files are listed
grep "new-file.adoc" l10n-weblate/administration.cfg

# Then extract
make pot
```

### Issue: Fuzzy translations not updating

**Symptom:** Old translations used even though source changed

**Explanation:** Fuzzy translations indicate source changed but translation hasn't been updated yet.

**Solution:**

Option 1: Update in Weblate (recommended)
- Translator reviews fuzzy strings
- Updates translation
- Saves

Option 2: Accept fuzzy translations
```bash
# Edit use_po.sh, change threshold
TRANSLATION_THRESHOLD_PERCENTAGE=0  # Accept fuzzy
```

Option 3: Remove fuzzy flag manually
```bash
# Edit PO file
vim l10n-weblate/administration/ja.po
# Find fuzzy entry, remove `#, fuzzy` line
```

### Debug: Trace po4a execution

```bash
# Run po4a with maximum verbosity
po4a -v -v -v -v --srcdir . --destdir . -k 0 -M utf-8 -L utf-8 \
     --no-update -o nolinting \
     l10n-weblate/administration.cfg 2>&1 | tee po4a-debug.log

# Check log for errors
less po4a-debug.log
```

---

## Summary: Translation System at a Glance

| Component | Purpose | Location | Format |
|-----------|---------|----------|--------|
| **Source Content** | Original English documentation | `modules/*/pages/*.adoc` | AsciiDoc |
| **POT Files** | Translatable string templates | `l10n-weblate/*/*.pot` | Gettext POT |
| **PO Files** | Translated strings | `l10n-weblate/*/<lang>.po` | Gettext PO |
| **Configuration** | po4a file mappings | `l10n-weblate/*.cfg` | po4a config |
| **Translated Content** | Localized AsciiDoc | `translations/<lang>/modules/` | AsciiDoc |
| **Build Output** | Final HTML/PDF | `build/<lang>/` | HTML/PDF |

| Script | Command | Purpose |
|--------|---------|---------|
| **update-cfg-files** | `make update-cfg-files` | Update po4a configurations |
| **make_pot.sh** | `make pot` | Extract strings → POT files |
| **use_po.sh** | `make translations` | Apply PO files → Translated docs |
| **configure** | `make configure-mlm` | Generate language Makefiles |
| **Makefile** | `make antora-mlm` | Build all languages |

| Makefile Target | What It Builds | Output |
|-----------------|----------------|--------|
| `make pot` | POT files | `l10n-weblate/*/*.pot` |
| `make translations` | Translated AsciiDoc | `translations/<lang>/modules/` |
| `make antora-mlm-ja` | Japanese HTML | `build/ja/` |
| `make antora-mlm` | All languages HTML | `build/en/`, `build/ja/`, `build/zh_CN/`, `build/ko/` |
| `make pdf-all-mlm-ja` | Japanese PDFs | `build/ja/pdf/` |

---

## Related Documentation

- [MAKEFILE_REFERENCE.md](MAKEFILE_REFERENCE.md) - Complete Makefile documentation
- [CONFIGURE_SCRIPT.md](CONFIGURE_SCRIPT.md) - Configuration generator
- [DOCUMENTATION_PHASES.md](DOCUMENTATION_PHASES.md) - Project documentation plan
- [HTML_BUILD_PROCESS.md](HTML_BUILD_PROCESS.md) - Antora build details (Phase 4)
- [PDF_BUILD_PROCESS.md](PDF_BUILD_PROCESS.md) - PDF generation (Phase 5)

---

**End of Translation System Documentation**
