# Build System Documentation Phases

## Overview
This document outlines the phased approach to documenting the uyuni-docs build system, which uses Antora for HTML generation, asciidoctor-pdf for PDF creation, and Weblate for translation management.

## Phase 1: Core Build Infrastructure (Foundation)
**Status:** ✅ Complete (Modularized)

### 1.1 Main Makefile (`Makefile`)
- [x] Document structure and organization
- [x] Document product configuration (MLM vs Uyuni)
- [x] Document build variables and customization
- [x] Document make functions and their purposes
- [x] Document target dependencies and execution flow

**Original Documentation:** [MAKEFILE_REFERENCE.md](MAKEFILE_REFERENCE.md) ✅ (Comprehensive monolithic document)

**Modular Documentation (Wiki-Optimized):**
- [BUILD_SYSTEM_OVERVIEW.md](BUILD_SYSTEM_OVERVIEW.md) ✅ - High-level introduction and architecture
- [BUILD_VARIABLES.md](BUILD_VARIABLES.md) ✅ - Configuration variables reference
- [BUILD_FUNCTIONS.md](BUILD_FUNCTIONS.md) ✅ - Make function reference with examples
- [BUILD_TARGETS.md](BUILD_TARGETS.md) ✅ - Make target reference with usage
- [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) ✅ - Common workflow patterns

### 1.2 Configuration Script (`configure`)
- [x] Document purpose and usage
- [x] Document product-specific configuration logic
- [x] Document generated files and their purpose

**Documentation:** [CONFIGURE_SCRIPT.md](CONFIGURE_SCRIPT.md) ✅

## Phase 2: Template System (Jinja2)
**Status:** Pending

### 2.1 Template Files
- [ ] `antora.yml.j2` - Antora configuration template
- [ ] `entities.adoc.j2` - AsciiDoc entities template
- [ ] `entities.specific.adoc.j2` - Product-specific entities
- [ ] `Makefile.j2` - Makefile generation template
- [ ] `Makefile.lang.target.j2` - Language-specific target template
- [ ] `Makefile.section.functions.j2` - Section functions template
- [ ] `site.yml.j2` - Site configuration template
- [ ] `site.yml.common.j2` - Common site configuration

### 2.2 Template Processing
- [ ] Document how templates are processed
- [ ] Document variable substitution
- [ ] Document conditional logic
- [ ] Document product-specific variations

## Phase 3: Translation and Localization System
**Status:** ✅ Complete

### 3.1 Translation Pipeline Overview
- [x] Document the complete translation workflow
- [x] Document source → POT → PO → translated content flow
- [x] Document Weblate integration points

### 3.2 Weblate Configuration (`l10n-weblate/`)
- [x] Document directory structure
- [x] Document `.cfg` files for each module
- [x] Document `update-cfg-files` script
- [x] Document PO file organization per language

### 3.3 Translation Scripts
- [x] `make_pot.sh` - POT file generation
- [x] `use_po.sh` - PO file application to generate translated content
- [x] Document how translations are applied to AsciiDoc files

### 3.4 Translation Build Process
- [x] Document `make pot` - Extract translatable strings
- [x] Document `make translations` - Apply translations
- [x] Document language-specific builds (ja, ko, zh_CN)
- [x] Document how `antora-mlm` and `antora-uyuni` generate localized sites
- [x] Document language selector mechanism

**Documentation:** [TRANSLATION_SYSTEM.md](TRANSLATION_SYSTEM.md) ✅

## Phase 4: HTML Generation (Antora)
**Status:** Pending

### 4.1 Antora Configuration
- [ ] Document `site.yml` structure
- [ ] Document `antora.yml` per-module configuration
- [ ] Document component and version management

### 4.2 HTML Build Process
- [ ] Document `antora-mlm` target
- [ ] Document `antora-uyuni` target
- [ ] Document multilingual site generation
- [ ] Document search integration (lunr)
- [ ] Document UI bundle and branding

### 4.3 Branding and Theming
- [ ] Document `branding/` directory structure
- [ ] Document UI customization
- [ ] Document supplemental files
- [ ] Document language-specific branding

## Phase 5: PDF Generation (asciidoctor-pdf)
**Status:** Pending

### 5.1 PDF Configuration
- [ ] Document PDF themes (uyuni, uyuni-cjk)
- [ ] Document font configuration
- [ ] Document PDF-specific entities

### 5.2 PDF Build Process
- [ ] Document `pdf-all-mlm` and `pdf-all-uyuni` targets
- [ ] Document per-guide PDF generation
- [ ] Document language-specific PDF generation
- [ ] Document index generation for PDFs
- [ ] Document custom xref-converter extension

## Phase 6: Utility Scripts
**Status:** Pending

### 6.1 Content Management Scripts
- [ ] `extract-release-notes.sh` - Release notes extraction
- [ ] `cleanup_pdfs.sh` - PDF cleanup
- [ ] `find_unused` - Find unused assets
- [ ] `enforcing_checkstyle` - Style enforcement

### 6.2 Module Scripts
- [ ] `modules/revdate.sh` - Revision date management
- [ ] `modules/revdate-cleanup.sh` - Revision date cleanup

## Phase 7: Packaging and Distribution
**Status:** Pending

### 7.1 OBS Package Creation
- [ ] Document `obs-packages-mlm` target
- [ ] Document `obs-packages-uyuni` target
- [ ] Document TAR/ZIP creation for distribution

### 7.2 Publication Process
- [ ] Document `for-publication` marker
- [ ] Document publication-ready builds
- [ ] Document validation process

## Phase 8: Development and Testing
**Status:** Pending

### 8.1 Development Workflow
- [ ] Document setup for new contributors
- [ ] Document local build testing
- [ ] Document validation tools

### 8.2 CI/CD Integration
- [ ] Document Docker build process (`Dockerfile.custom`)
- [ ] Document automated builds
- [ ] Document quality checks (`checkstyle`)

## Documentation Standards

### For Each Component:
1. **Purpose**: What does it do?
2. **Usage**: How to use it? (command examples)
3. **Inputs**: What files/variables does it read?
4. **Outputs**: What files does it create?
5. **Dependencies**: What other components does it depend on?
6. **Flow Diagram**: Visual representation where helpful
7. **Examples**: Real-world usage examples
8. **Troubleshooting**: Common issues and solutions

### File Naming Convention:
- `BUILD_SYSTEM_OVERVIEW.md` - High-level architecture
- `MAKEFILE_REFERENCE.md` - Complete Makefile documentation
- `TEMPLATE_SYSTEM.md` - Jinja2 template documentation
- `TRANSLATION_SYSTEM.md` - Complete translation workflow
- `HTML_BUILD_PROCESS.md` - Antora HTML generation
- `PDF_BUILD_PROCESS.md` - PDF generation process
- `SCRIPTS_REFERENCE.md` - All utility scripts
- `PACKAGING_DISTRIBUTION.md` - OBS and distribution
- `DEVELOPER_GUIDE.md` - Quick start for contributors

## Success Criteria
- [ ] All build files documented
- [ ] Translation workflow fully explained
- [ ] New contributors can build locally without assistance
- [ ] Maintainers can understand and modify build system
- [ ] Visual diagrams for complex workflows
- [ ] Examples for all common tasks

## Next Steps
1. **Review this phasing document** - Ensure all components are covered
2. **Start Phase 1** - Document the main Makefile
3. **Progress sequentially** - Build understanding incrementally
4. **Test documentation** - Verify examples work
5. **Iterate** - Refine based on feedback

---

**Note**: This is a living document. Update phase status and checkboxes as work progresses.
