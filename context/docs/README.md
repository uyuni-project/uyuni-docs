# Build System Documentation

This directory contains comprehensive documentation for the uyuni-docs build system.

## 📚 Documentation Precedence & Reading Order

```
┌─────────────────────────────────────────────────────────────┐
│  READING ORDER (Follow the numbers)                         │
└─────────────────────────────────────────────────────────────┘

  START HERE
      ↓
  ┌─────────────────────────────────────────────┐
  │ 1️⃣  BUILD_SYSTEM_OVERVIEW.md              │  ← Introduction & Architecture
  │    (What is this? How does it work?)       │
  └─────────────────────────────────────────────┘
                    ↓
  ┌─────────────────────────────────────────────┐
  │ 2️⃣  BUILD_TARGETS.md                       │  ← What can I build?
  │    (Quick reference: make commands)         │
  └─────────────────────────────────────────────┘
                    ↓
         ┌──────────────────────┐
         │ Need to customize?   │
         └──────────────────────┘
                    ↓
  ┌─────────────────────────────────────────────┐
  │ 3️⃣  BUILD_VARIABLES.md                     │  ← Configuration options
  │    (How do I configure builds?)             │
  └─────────────────────────────────────────────┘
                    ↓
         ┌──────────────────────┐
         │ Need to debug/extend?│
         └──────────────────────┘
                    ↓
  ┌─────────────────────────────────────────────┐
  │ 4️⃣  BUILD_FUNCTIONS.md                     │  ← Internal functions
  │    (How does the Makefile work?)            │
  └─────────────────────────────────────────────┘
                    ↓
  ┌─────────────────────────────────────────────┐
  │ 5️⃣  BUILD_WORKFLOWS.md                     │  ← Step-by-step guides
  │    (Daily tasks & troubleshooting)          │
  └─────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  SPECIALIZED TOPICS (Read as needed)                        │
└─────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────┐
  │ 6️⃣  TRANSLATION_SYSTEM.md                  │  ← For translators
  │    (How does translation work?)             │
  └─────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────┐
  │ 7️⃣  CONFIGURE_SCRIPT.md                    │  ← For system developers
  │    (How does configuration work?)           │
  └─────────────────────────────────────────────┘
```

## Quick Start

**New to the build system?** Start here:
1. [BUILD_SYSTEM_OVERVIEW.md](BUILD_SYSTEM_OVERVIEW.md) - Architecture and introduction
2. [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) - Common usage patterns
3. [BUILD_TARGETS.md](BUILD_TARGETS.md) - Quick reference for make commands

## Documentation Index

### Core Documentation (Modular - Wiki-Ready)

**📖 Reading Order / Precedence:**

These documents are numbered in recommended reading order. Start with #1 for introduction, progress to #2-4 for reference material, and use #5 for practical guidance.

| # | Document | Purpose | Audience | When to Read |
|---|----------|---------|----------|--------------|
| **1** | [BUILD_SYSTEM_OVERVIEW.md](BUILD_SYSTEM_OVERVIEW.md) | High-level introduction, architecture, technologies | Everyone | **START HERE** - First time users |
| **2** | [BUILD_TARGETS.md](BUILD_TARGETS.md) | Make target reference and usage | Everyone | After overview - Learn what you can build |
| **3** | [BUILD_VARIABLES.md](BUILD_VARIABLES.md) | Configuration variables reference | Developers, DevOps | When customizing configuration |
| **4** | [BUILD_FUNCTIONS.md](BUILD_FUNCTIONS.md) | Make function reference with examples | Developers | When modifying Makefile or debugging |
| **5** | [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) | Step-by-step workflow guides | Everyone | Daily reference for common tasks |

### Infrastructure Documentation

**📖 Supplementary Reading:**

These provide deeper dives into specific subsystems:

| # | Document | Purpose | Audience | Priority |
|---|----------|---------|----------|----------|
| **6** | [TRANSLATION_SYSTEM.md](TRANSLATION_SYSTEM.md) | Complete translation workflow | Translators, Developers | When working with translations |
| **7** | [CONFIGURE_SCRIPT.md](CONFIGURE_SCRIPT.md) | Configuration script documentation | Developers | When modifying configuration system |

### Reference Documentation

**📖 Optional/Historical:**

| Document | Purpose | Status | Notes |
|----------|---------|--------|-------|
| [MAKEFILE_REFERENCE.md](MAKEFILE_REFERENCE.md) | Original comprehensive Makefile doc | Complete (superseded) | Use modular docs #1-5 instead |
| [DOCUMENTATION_PHASES.md](DOCUMENTATION_PHASES.md) | Documentation project plan | In Progress | For documentation contributors |

---

## Reading Paths by Experience Level

### 🎯 Path 1: Complete Beginner
**Goal:** Understand and use the build system

1. **Start:** [BUILD_SYSTEM_OVERVIEW.md](BUILD_SYSTEM_OVERVIEW.md) - Read "Overview" through "Quick Start"
2. **Try it:** [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) - Workflow 1: First-Time Setup
3. **Practice:** [BUILD_TARGETS.md](BUILD_TARGETS.md) - Try the Quick Reference commands
4. **Daily Use:** [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) - Workflows 2-4 as needed

### 🔧 Path 2: Developer/Technical Writer
**Goal:** Build and validate documentation

1. **Overview:** [BUILD_SYSTEM_OVERVIEW.md](BUILD_SYSTEM_OVERVIEW.md) - Skim entire document
2. **Common Tasks:** [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) - Workflows 1-4, 11-14
3. **Quick Reference:** [BUILD_TARGETS.md](BUILD_TARGETS.md) - Bookmark for daily use
4. **Deep Dive:** [BUILD_FUNCTIONS.md](BUILD_FUNCTIONS.md) - When debugging or extending

### 🌍 Path 3: Translator
**Goal:** Understand translation pipeline

1. **Context:** [BUILD_SYSTEM_OVERVIEW.md](BUILD_SYSTEM_OVERVIEW.md) - "Supported Languages" section
2. **Translation System:** [TRANSLATION_SYSTEM.md](TRANSLATION_SYSTEM.md) - Read completely
3. **Translation Workflows:** [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) - Workflows 5-8
4. **Commands:** [BUILD_TARGETS.md](BUILD_TARGETS.md) - Translation Targets section

### ⚙️ Path 4: DevOps/Build Engineer
**Goal:** Configure, optimize, and automate builds

1. **Architecture:** [BUILD_SYSTEM_OVERVIEW.md](BUILD_SYSTEM_OVERVIEW.md) - Read completely
2. **Configuration:** [BUILD_VARIABLES.md](BUILD_VARIABLES.md) + [CONFIGURE_SCRIPT.md](CONFIGURE_SCRIPT.md)
3. **Functions:** [BUILD_FUNCTIONS.md](BUILD_FUNCTIONS.md) - Understand internals
4. **Automation:** [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) - Workflows 15-18
5. **All Targets:** [BUILD_TARGETS.md](BUILD_TARGETS.md) - Complete reference

### 📦 Path 5: Release Manager
**Goal:** Package and deploy documentation

1. **Quick Orientation:** [BUILD_SYSTEM_OVERVIEW.md](BUILD_SYSTEM_OVERVIEW.md) - "Build Workflow Overview"
2. **Release Process:** [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) - Workflows 9-10
3. **Packaging:** [BUILD_TARGETS.md](BUILD_TARGETS.md) - Packaging Targets section
4. **Validation:** [BUILD_TARGETS.md](BUILD_TARGETS.md) - Validation Targets section

---

## Documentation Organization

### By User Type

**Documentation Writers:**
- Start with: [BUILD_SYSTEM_OVERVIEW.md](BUILD_SYSTEM_OVERVIEW.md)
- Common tasks: [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) → Workflows 1-4
- Building docs: [BUILD_TARGETS.md](BUILD_TARGETS.md) → HTML Build Targets

**Translators:**
- Translation process: [TRANSLATION_SYSTEM.md](TRANSLATION_SYSTEM.md)
- Translation workflows: [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) → Workflows 5-8
- Language setup: [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) → Workflow 7

**Build Engineers/DevOps:**
- Architecture: [BUILD_SYSTEM_OVERVIEW.md](BUILD_SYSTEM_OVERVIEW.md)
- Configuration: [BUILD_VARIABLES.md](BUILD_VARIABLES.md) + [CONFIGURE_SCRIPT.md](CONFIGURE_SCRIPT.md)
- Functions: [BUILD_FUNCTIONS.md](BUILD_FUNCTIONS.md)
- CI/CD: [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) → Workflows 15-16

**Release Managers:**
- Release process: [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) → Workflows 9-10
- Packaging: [BUILD_TARGETS.md](BUILD_TARGETS.md) → Packaging Targets
- Validation: [BUILD_TARGETS.md](BUILD_TARGETS.md) → Validation Targets

### By Topic

**Getting Started:**
1. [BUILD_SYSTEM_OVERVIEW.md](BUILD_SYSTEM_OVERVIEW.md) - What is this build system?
2. [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) - Workflow 1: First-Time Setup
3. [BUILD_TARGETS.md](BUILD_TARGETS.md) - Quick Reference

**Configuration:**
- [BUILD_VARIABLES.md](BUILD_VARIABLES.md) - All configuration variables
- [CONFIGURE_SCRIPT.md](CONFIGURE_SCRIPT.md) - How configuration is generated
- [BUILD_SYSTEM_OVERVIEW.md](BUILD_SYSTEM_OVERVIEW.md) - Key Concepts section

**Building HTML:**
- [BUILD_TARGETS.md](BUILD_TARGETS.md) - HTML Build Targets section
- [BUILD_FUNCTIONS.md](BUILD_FUNCTIONS.md) - Antora Build Functions section
- [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) - Workflows 1-2

**Building PDFs:**
- [BUILD_TARGETS.md](BUILD_TARGETS.md) - PDF Build Targets section
- [BUILD_FUNCTIONS.md](BUILD_FUNCTIONS.md) - PDF Generation Functions section
- [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) - Workflow 3

**Translation:**
- [TRANSLATION_SYSTEM.md](TRANSLATION_SYSTEM.md) - Complete translation documentation
- [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) - Translation Workflows (5-8)
- [BUILD_TARGETS.md](BUILD_TARGETS.md) - Translation Targets section

**Troubleshooting:**
- [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) - Troubleshooting Workflows (11-14)
- [BUILD_TARGETS.md](BUILD_TARGETS.md) - Troubleshooting Targets section
- [BUILD_VARIABLES.md](BUILD_VARIABLES.md) - Troubleshooting section

## Documentation Standards

### Document Structure

Each document follows this structure:

```markdown
# Title

**Version:** X.X
**Last Updated:** Date

## Overview
Brief description of what this document covers

## Table of Contents
(if document is long)

## Main Content Sections

## Related Documentation
Links to related documents

---
**Last Updated:** Date
```

### Cross-References

Documents link to each other using relative paths:
```markdown
See [BUILD_TARGETS.md](BUILD_TARGETS.md) for make target reference.
```

### Code Examples

All examples include:
- Actual commands (not pseudo-code)
- Expected output
- Context (when to use)
- Time estimates where applicable

## Build System Components

### Key Files Documented

```
uyuni-docs/
├── Makefile                    # Main build orchestrator
├── configure                   # Configuration generator
├── parameters.yml              # Central configuration
├── make_pot.sh                 # POT extraction
├── use_po.sh                   # Translation application
└── l10n-weblate/              # Translation files
    ├── *.cfg                  # po4a configuration
    └── */pot/*.pot            # Translatable strings
```

### Generated Files

```
Makefile.en                     # English build targets
Makefile.ja                     # Japanese build targets
Makefile.zh_CN                  # Chinese build targets
Makefile.ko                     # Korean build targets
```

### Build Output

```
build/
├── en/                        # English HTML
├── ja/                        # Japanese HTML
├── zh_CN/                     # Chinese HTML
├── ko/                        # Korean HTML
└── packages/                  # Distribution packages
translations/
├── en/                        # Translated English AsciiDoc
├── ja/                        # Translated Japanese AsciiDoc
├── zh_CN/                     # Translated Chinese AsciiDoc
└── ko/                        # Translated Korean AsciiDoc
```

## Technologies Documented

- **GNU Make** - Build orchestration
- **Antora** - HTML site generation
- **asciidoctor-pdf** - PDF generation
- **po4a** - Translation extraction/application
- **Weblate** - Translation management platform
- **Jinja2** - Template processing
- **Python 3** - Configuration script

## Common Questions

### Q: How do I build English HTML only?
```bash
make antora-mlm-en
```
See: [BUILD_TARGETS.md](BUILD_TARGETS.md) - HTML Build Targets

### Q: How do I update translation files?
```bash
make pot                # Extract strings
# (Weblate handles translation)
git pull                # Get translated PO files
make translations-ja    # Apply Japanese translations
```
See: [TRANSLATION_SYSTEM.md](TRANSLATION_SYSTEM.md)

### Q: How do I add a new language?
See: [BUILD_WORKFLOWS.md](BUILD_WORKFLOWS.md) - Workflow 7: Add New Language

### Q: How do I build all PDFs?
```bash
make pdf-all-mlm-en     # English PDFs
make pdf-all-mlm-ja     # Japanese PDFs
```
See: [BUILD_TARGETS.md](BUILD_TARGETS.md) - PDF Build Targets

### Q: How do I validate my documentation?
```bash
make validate-mlm-en    # Check cross-references
make checkstyle-en      # Check style
```
See: [BUILD_TARGETS.md](BUILD_TARGETS.md) - Validation Targets

### Q: What's the difference between MLM and Uyuni?
- **MLM** (SUSE Multi-Linux Manager) - Commercial product
- **Uyuni** - Open source upstream

See: [BUILD_SYSTEM_OVERVIEW.md](BUILD_SYSTEM_OVERVIEW.md) - Products section

## Contributing to Documentation

### Updating Documentation

1. Edit the relevant markdown file
2. Update "Last Updated" date
3. Test any code examples
4. Update cross-references if document structure changes
5. Commit with descriptive message

### Adding New Documentation

1. Check [DOCUMENTATION_PHASES.md](DOCUMENTATION_PHASES.md) for planned topics
2. Follow document structure standards (see above)
3. Add entry to this README
4. Add cross-references from related documents
5. Update [DOCUMENTATION_PHASES.md](DOCUMENTATION_PHASES.md)

### Documentation Priorities

See [DOCUMENTATION_PHASES.md](DOCUMENTATION_PHASES.md) for:
- Completed phases
- In-progress work
- Planned documentation
- Priority order

## Documentation History

### Phase 1: Core Build Infrastructure ✅
- Comprehensive Makefile documentation
- Configuration script documentation
- Modular documentation created (wiki-ready)

### Phase 3: Translation System ✅
- Complete translation workflow
- Weblate integration
- Translation scripts

### Current: Phase 4
- HTML build process (Antora)
- Template system documentation

### Upcoming: Phase 5-8
- PDF build process
- Utility scripts
- Packaging and distribution
- Development workflow

## Getting Help

1. **Check this README** - Find the right document for your question
2. **Search documentation** - Use grep or your editor's search
3. **Check examples** - Most documents include working examples
4. **Ask the team** - If documentation is unclear, ask and help us improve it

## Maintenance

This documentation is maintained by the uyuni-docs team.

**Last Major Update:** October 20, 2025 (Phase 1 modularization complete)

---

**Quick Links:**
- [Overview](BUILD_SYSTEM_OVERVIEW.md)
- [Workflows](BUILD_WORKFLOWS.md)
- [Targets](BUILD_TARGETS.md)
- [Variables](BUILD_VARIABLES.md)
- [Functions](BUILD_FUNCTIONS.md)
- [Translation](TRANSLATION_SYSTEM.md)
