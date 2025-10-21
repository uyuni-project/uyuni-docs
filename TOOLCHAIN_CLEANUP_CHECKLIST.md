# Toolchain Cleanup and Reorganization Checklist

## Overview
This checklist organizes the cleanup of the uyuni-docs repository root by moving toolchain files into a dedicated `tools/` directory structure while keeping essential system files in the root.

## Files Remaining in Root (Essential System Files)
- ✅ `Makefile` - Primary build system entry point
- ✅ `Dockerfile.custom` - Container configuration
- ✅ `parameters.yml` - Build configuration parameters
- ✅ `use_po.sh` - PO file processing
- ✅ `antora.yml` - Antora documentation configuration
- ✅ `site.yml` - Site configuration
- ✅ `.gitignore`, `LICENSE`, `README.adoc`, `CODE_OF_CONDUCT.md`, `CHANGELOG.md`

---

## Phase 1: Create Tools Directory Structure
**Status:** Not Started

### Tasks:
- [ ] Create `tools/` directory
- [ ] Create `tools/templates/` for Jinja2 templates
- [ ] Create `tools/scripts/` for bash/python scripts
- [ ] Create `tools/generated/` for auto-generated Makefiles

### Commands:
```bash
mkdir -p tools/{templates,scripts,generated}
touch tools/generated/.gitkeep
```

---

## Phase 2: Move Jinja2 Templates
**Status:** Not Started

### Files to Move to `tools/templates/`:
- [ ] `Makefile.j2`
- [ ] `Makefile.lang.target.j2`
- [ ] `Makefile.section.functions.j2`
- [ ] `site.yml.j2`
- [ ] `site.yml.common.j2`
- [ ] `antora.yml.j2`
- [ ] `entities.adoc.j2`
- [ ] `entities.specific.adoc.j2`

### Commands:
```bash
mv *.j2 tools/templates/
```

### Files Affected:
- `configure` - Update template loader path

---

## Phase 3: Move Scripts to tools/scripts/
**Status:** Not Started

### Files to Move to `tools/scripts/`:
- [ ] `configure` - Python configuration script (generates Makefiles and config files)
- [ ] `cleanup_pdfs.sh` - Script to clean PDF build artifacts
- [ ] `extract-release-notes.sh` - Release notes extraction utility
- [ ] `make_pot.sh` - POT file generation for translations
- [ ] `enforcing_checkstyle` - Python style checker
- [ ] `find_unused` - Bash script to find unused files

### Commands:
```bash
mv configure cleanup_pdfs.sh extract-release-notes.sh make_pot.sh tools/scripts/
mv enforcing_checkstyle find_unused tools/scripts/
```

### Files Affected:
- `Makefile` - Update configure and script references
- Scripts themselves may need path updates

---

## Phase 4: Move Generated Makefiles
**Status:** Not Started

### Files to Move to `tools/generated/`:
- [ ] `Makefile.en` - Generated English Makefile
- [ ] `Makefile.ja` - Generated Japanese Makefile
- [ ] `Makefile.ko` - Generated Korean Makefile
- [ ] `Makefile.zh_CN` - Generated Chinese Makefile
- [ ] `Makefile.lang` - Generated language includes
- [ ] `Makefile.lang.target` - Generated language targets
- [ ] `Makefile.section.functions` - Generated section functions

### Commands:
```bash
mv Makefile.{en,ja,ko,zh_CN,lang,lang.target,section.functions} tools/generated/
```

### Files Affected:
- `configure` - Update output paths for generated files
- `Makefile` - Update include paths

---

## Phase 5: Update Configure Script
**Status:** Not Started

### Changes Required in `tools/scripts/configure`:

#### Template Loader Path:
```python
# Old:
env = Environment(loader = FileSystemLoader('./'), ...)

# New:
env = Environment(loader = FileSystemLoader('./tools/templates/'), ...)
```

#### Output Paths for Generated Makefiles:
```python
# Old:
with open('Makefile.' + i["langcode"], 'w') as f:

# New:
with open('tools/generated/Makefile.' + i["langcode"], 'w') as f:
```

#### Update All Generated File Paths:
- [ ] Language-specific Makefiles → `tools/generated/Makefile.*`
- [ ] `Makefile.lang` → `tools/generated/Makefile.lang`
- [ ] `Makefile.lang.target` → `tools/generated/Makefile.lang.target`
- [ ] `Makefile.section.functions` → `tools/generated/Makefile.section.functions`

### Note:
Keep `site.yml`, `antora.yml`, and `branding/locale/entities.specific.adoc` in their current locations as they are required by Antora in the root.

---

## Phase 6: Update Main Makefile
**Status:** Not Started

### Changes Required:

#### Include Path Updates:
```makefile
# Old:
-include Makefile.lang
include Makefile.section.functions
include Makefile.lang.target

# New:
-include tools/generated/Makefile.lang
include tools/generated/Makefile.section.functions
include tools/generated/Makefile.lang.target
```

#### Script Reference Updates:
```makefile
# Old:
./configure mlm
$(current_dir)/make_pot.sh
./enforcing_checkstyle --filename {} --ifeval

# New:
./tools/scripts/configure mlm
$(current_dir)/tools/scripts/make_pot.sh
./tools/scripts/enforcing_checkstyle --filename {} --ifeval
```

### Files to Update:
- [ ] Update `configure` script call (e.g., in configure-mlm, configure-uyuni targets)
- [ ] Update include paths for generated Makefiles
- [ ] Update `make_pot.sh` reference
- [ ] Update `enforcing_checkstyle` references (appears 4+ times)
- [ ] Verify any other script references

---

## Phase 7: Update Script Paths
**Status:** Not Started

### Scripts to Review and Update:

#### `configure`:
```python
# Update template loader to use relative path from script location
# Old:
env = Environment(loader = FileSystemLoader('./'), ...)

# New (relative to script location):
import os
script_dir = os.path.dirname(os.path.abspath(__file__))
repo_root = os.path.dirname(script_dir)  # Go up from tools/scripts to root
env = Environment(loader = FileSystemLoader(os.path.join(repo_root, 'tools/templates')), ...)

# Update all output paths to write to repo_root
```

#### `make_pot.sh`:
```bash
# Line 12 - Verify CURRENT_DIR works correctly from new location
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# May need to add: REPO_ROOT="$(cd "$CURRENT_DIR/../.." && pwd)"
```

#### `find_unused`:
```bash
# Line 3 - Verify CURRENT_DIR works correctly from new location
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# May need to add: REPO_ROOT="$(cd "$CURRENT_DIR/../.." && pwd)"
```

#### `enforcing_checkstyle`:
- [ ] Check for any hardcoded paths
- [ ] Verify it works from new location

### Tasks:
- [ ] Update `configure` script to find templates and output to correct locations
- [ ] Test each script from new location
- [ ] Update any absolute path references
- [ ] Ensure CURRENT_DIR logic still works

---

## Phase 8: Update .gitignore
**Status:** Not Started

### Add to .gitignore:
```gitignore
# Generated files from configure script
tools/generated/*
!tools/generated/.gitkeep
```

### Review:
- [ ] Verify generated files aren't accidentally committed
- [ ] Keep `.gitkeep` to preserve directory structure
- [ ] Check if current `.gitignore` already handles these files

---

## Phase 9: Testing
**Status:** Not Started

### Test Sequence:

#### Clean and Configure:
```bash
# Clean any existing generated files
rm -rf tools/generated/*
git checkout tools/generated/.gitkeep

# Test MLM configuration
make configure-mlm

# Verify generated files exist in tools/generated/
ls -la tools/generated/

# Test build
make html-mlm
```

#### Test UYUNI:
```bash
# Clean
rm -rf tools/generated/*
git checkout tools/generated/.gitkeep

# Configure
make configure-uyuni

# Build
make html-uyuni
```

#### Test Other Targets:
- [ ] `make pot` - Verify make_pot.sh works
- [ ] `make vale` - Verify checkstyle works
- [ ] `make vale-fix` - Verify checkstyle with fix works

### Validation Checklist:
- [ ] All generated files appear in `tools/generated/`
- [ ] HTML builds successfully for MLM
- [ ] HTML builds successfully for Uyuni
- [ ] POT generation works
- [ ] Style checking works
- [ ] No broken script references
- [ ] Clean root directory

---

## Phase 10: Update Documentation
**Status:** Not Started

### Files to Update:

#### README.adoc:
- [ ] Document new `tools/` directory structure
- [ ] Explain generated files location
- [ ] Update build instructions to use `./tools/scripts/configure [product]`
- [ ] Add note about running `configure` before build

#### Consider Adding:
- [ ] `tools/README.md` explaining the toolchain structure
- [ ] Comments in scripts about their purpose

### Structure to Document:
```
tools/
├── scripts/          # Build and utility scripts
│   ├── configure     # Main configuration script (generates Makefiles)
│   ├── make_pot.sh
│   └── ...
├── templates/        # Jinja2 templates for configure script
│   ├── Makefile.j2
│   ├── antora.yml.j2
│   └── ...
└── generated/        # Auto-generated files (git-ignored)
    ├── Makefile.en
    ├── Makefile.lang
    └── ...
```

---

## Verification Checklist

### Root Directory Should Only Contain:
- [x] `Makefile` (main entry point)
- [x] `Dockerfile.custom`
- [x] `parameters.yml`
- [x] `use_po.sh`
- [x] `antora.yml` (generated, but needed in root)
- [x] `site.yml` (generated, but needed in root)
- [x] Standard meta files (README, LICENSE, etc.)
- [x] `branding/`, `modules/`, `extensions/`, etc. (existing directories)

### Root Directory Should NOT Contain:
- [ ] ❌ `configure` (moved to tools/scripts/)
- [ ] ❌ `*.j2` files (moved to tools/templates/)
- [ ] ❌ `Makefile.en`, `Makefile.ja`, etc. (moved to tools/generated/)
- [ ] ❌ `Makefile.lang*` (moved to tools/generated/)
- [ ] ❌ `cleanup_pdfs.sh`, `make_pot.sh`, etc. (moved to tools/scripts/)
- [ ] ❌ `enforcing_checkstyle`, `find_unused` (moved to tools/scripts/)

---

## Notes and Considerations

### Git Workflow:
- Consider creating a feature branch for this work
- Make atomic commits for each phase
- Test after each phase before proceeding

### Backward Compatibility:
- Document breaking changes if any
- Consider if CI/CD needs updates
- Check if any external tools/scripts reference moved files

### Future Improvements:
- Could add `tools/tests/` for testing scripts
- Could add `tools/docs/` for toolchain documentation
- Consider creating a `tools/Makefile` for tool-specific tasks

---

## Completion Criteria
- [ ] All phases completed
- [ ] All tests passing
- [ ] Clean root directory
- [ ] Documentation updated
- [ ] Changes committed to git
- [ ] CI/CD (if any) verified working
