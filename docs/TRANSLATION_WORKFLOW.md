# Translation Workflow Documentation

## Overview

The uyuni-docs project uses **po4a** (PO for Anything) to manage translations. Translation strings are maintained in `.po` files within the `l10n-weblate/` directory, which are synced with Weblate for translator collaboration.

## Directory Structure

```
uyuni-docs/
├── modules/                    # Source English documentation
│   ├── ROOT/
│   ├── administration/
│   ├── client-configuration/
│   └── ...
├── l10n-weblate/              # Translation files (managed by Weblate)
│   ├── ROOT/
│   │   ├── ROOT.pot           # Translation template
│   │   ├── ja.po              # Japanese translations
│   │   ├── ko.po              # Korean translations
│   │   ├── zh_CN.po           # Chinese translations
│   │   └── assets-*/          # Localized screenshots
│   ├── ROOT.cfg               # po4a config for ROOT module
│   ├── administration/
│   ├── administration.cfg
│   └── ...
├── translations/              # Generated translated .adoc files
│   ├── en/                    # English (copied from modules/)
│   ├── ja/                    # Japanese (generated from .po)
│   ├── ko/                    # Korean (generated from .po)
│   └── zh_CN/                 # Chinese (generated from .po)
└── branding/                  # UI themes and styling
```

## Translation Scripts

### 1. `make_pot.sh` - Extract Translatable Strings

**Purpose**: Extracts translatable strings from English `.adoc` files and creates/updates `.pot` and `.po` files.

**What it does**:
- Scans all `modules/` directories
- Creates `.pot` (Portable Object Template) files with all translatable strings
- Updates existing `.po` files with new/changed strings
- Copies English screenshots to language-specific asset directories

**Usage**:
```bash
./make_pot.sh
```

**Output**:
- Updates `l10n-weblate/*/MODULE.pot`
- Updates `l10n-weblate/*/*.po` files
- Syncs `l10n-weblate/*/assets-LANG/` directories

**When to run**: After making significant changes to English documentation that need translation.

### 2. `use_po.sh` - Generate Translated Documentation

**Purpose**: Converts `.po` translation files into translated `.adoc` files.

**What it does**:
- Reads `.po` files from `l10n-weblate/`
- Generates translated `.adoc` files in `translations/LANG/modules/`
- Copies localized screenshots to appropriate locations
- Only generates files with sufficient translation completeness (configurable threshold)

**Usage**:
```bash
./use_po.sh
```

**Output**:
- Creates `translations/ja/modules/*/` with translated `.adoc` files
- Creates `translations/ko/modules/*/` with translated `.adoc` files
- Creates `translations/zh_CN/modules/*/` with translated `.adoc` files
- Copies assets from `l10n-weblate/*/assets-LANG/` to `translations/LANG/modules/*/assets/`

**When to run**: Before building documentation in languages other than English.

## Build Workflow Per Language

### English (en) Build Process

1. **Copy branding**:
   ```makefile
   mkdir -p translations/
   cp -a branding/ translations/
   mkdir -p translations/en/
   cp -a branding/ translations/en/
   ```

2. **Copy modules** (English is always source):
   ```makefile
   cp -a modules/ translations/en/modules/
   ```

3. **Configure Antora**:
   - Copy `antora.yml` → `translations/en/antora.yml`
   - Generate `translations/en/site.yml` with language-specific paths
   - Modify URLs to include `/en/` path segment

4. **Build HTML/PDF** from `translations/en/`

### Translated Language (ja, ko, zh_CN) Build Process

1. **Generate translations first**:
   ```bash
   ./use_po.sh  # Creates translations/LANG/modules/ from .po files
   ```

2. **Copy branding**:
   ```makefile
   mkdir -p translations/
   cp -a branding/ translations/
   mkdir -p translations/LANG/
   cp -a branding/ translations/LANG/
   ```

3. **Modules are already translated** by `use_po.sh`:
   ```
   translations/ja/modules/ROOT/
   translations/ja/modules/administration/
   translations/ja/modules/client-configuration/
   ...
   ```

4. **Configure Antora**:
   - Copy `antora.yml` → `translations/LANG/antora.yml`
   - Generate `translations/LANG/site.yml` with language-specific paths
   - Modify URLs to include `/LANG/` path segment (e.g., `/ja/`)

5. **Build HTML/PDF** from `translations/LANG/`

## Configuration Files (.cfg)

Each module has a `.cfg` file in `l10n-weblate/` that tells po4a:

**Example** (`l10n-weblate/ROOT.cfg`):
```ini
[po4a_langs] cs es ja ko pt_BR sk zh_CN
[po4a_paths] l10n-weblate/ROOT/ROOT.pot $lang:l10n-weblate/ROOT/$lang.po

[type: asciidoc] modules/ROOT/_attributes.adoc $lang:translations/$lang/modules/ROOT/_attributes.adoc
[type: asciidoc] modules/ROOT/nav.adoc $lang:translations/$lang/modules/ROOT/nav.adoc
```

This defines:
- Which languages are supported
- Source `.adoc` files to translate
- Where to write translated `.adoc` files

## Integration with Make

### Makefile Functions

```makefile
# Copy branding to language directory
define copy-branding
    mkdir -p $(current_dir)/translations/$(1)
    cp -a $(current_dir)/branding $(current_dir)/translations/$(1)/
endef

# Prepare Antora build for a language
define prepare-antora-<product>-<lang>
    # 1. Copy branding
    # 2. Set up language selector in UI
    # 3. Copy/generate modules
    # 4. Create language-specific site.yml
endef
```

### Makefile Targets

```makefile
# Run translation generation
.PHONY: translations
translations:
	./use_po.sh

# Copy base branding
.PHONY: copy-branding
copy-branding:
	mkdir -p translations/
	cp -a branding/ translations/

# Language-specific branding copy
.PHONY: copy-branding-ja
copy-branding-ja: copy-branding
	$(call copy-branding,ja)

# Full build preparation
.PHONY: prepare-antora-mlm-ja
prepare-antora-mlm-ja: copy-branding-ja set-html-language-selector-mlm-ja
	# Set up translations/ja/ for Antora build
```

## Future Task Integration

When migrating to Task-only workflow, implement:

### Task Definition

```yaml
translate:
  desc: Generate translated documentation from .po files
  cmds:
    - ./use_po.sh

translate:pot:
  desc: Extract translatable strings from English sources
  cmds:
    - ./make_pot.sh

html:
  desc: Build HTML for a language
  vars:
    LANG: '{{.LANG | default "en"}}'
  deps:
    - task: translate
      when: '{{ne .LANG "en"}}'  # Only run for non-English
  cmds:
    - task: copy-branding
    - task: prepare-antora
    - npx antora translations/{{.LANG}}/site.yml

copy-branding:
  internal: true
  cmds:
    - mkdir -p translations/
    - cp -a branding/ translations/
    - mkdir -p translations/{{.LANG}}/
    - cp -a branding/ translations/{{.LANG}}/
```

### Container Integration

The container already has `po4a` installed, so translation scripts work identically:

```yaml
container:translate:
  desc: Generate translations inside container
  cmds:
    - podman run --rm --userns=keep-id -v $(pwd):/workspace:Z -w /workspace uyuni-docs:latest ./use_po.sh

container:html:ja:
  desc: Build Japanese documentation in container
  deps:
    - container:translate
  cmds:
    - podman run --rm --userns=keep-id -v $(pwd):/workspace:Z -w /workspace uyuni-docs:latest task html LANG=ja
```

## Translation Completeness Thresholds

Defined in `use_po.sh`:

```bash
TRANSLATION_THRESHOLD_STRINGS=0      # Minimum untranslated strings
TRANSLATION_THRESHOLD_PERCENTAGE=0   # po4a threshold (0 = allow partial)
```

These control:
- Whether partially translated files are included
- Fallback behavior (currently disabled - would copy English)

## Available Languages

Currently supported (as defined in `.cfg` files):

- **cs** - Czech
- **es** - Spanish  
- **ja** - Japanese
- **ko** - Korean
- **mk** - Macedonian
- **pt_BR** - Brazilian Portuguese
- **ru** - Russian
- **sk** - Slovak
- **zh_CN** - Simplified Chinese

## Best Practices

1. **Always run `use_po.sh` before building non-English docs**:
   ```bash
   ./use_po.sh
   task html LANG=ja
   ```

2. **Run `make_pot.sh` after English content changes**:
   ```bash
   # Edit English docs
   ./make_pot.sh
   # Commit updated .pot/.po files
   # Translators update via Weblate
   ```

3. **Don't edit files in `translations/` manually** - they're generated

4. **Don't commit `translations/` directory** - it's in `.gitignore`

5. **Commit `l10n-weblate/` changes** - these are the source of truth for translations

## Troubleshooting

### "No such file or directory" when building translated docs

**Problem**: Build tries to access `translations/ja/modules/...` but files don't exist

**Solution**: Run `./use_po.sh` first to generate translated `.adoc` files

### Translations are outdated

**Problem**: `.po` files have new English strings but translations not updated

**Solution**: 
1. Run `./make_pot.sh` to extract new strings
2. Translators update via Weblate
3. Pull updated `.po` files
4. Run `./use_po.sh` to regenerate documentation

### Missing screenshots in translated docs

**Problem**: Images show English text in translated documentation

**Solution**: 
1. Create localized screenshots
2. Place in `l10n-weblate/MODULE/assets-LANG/images/`
3. Run `./use_po.sh` to copy to `translations/LANG/modules/MODULE/assets/`
