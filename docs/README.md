# Uyuni Documentation Build System - Task Migration

This directory contains documentation for the modernized build system using Task (go-task) instead of Make.

## 📚 Documentation Index

### Quick Start
- **[QUICK_START_CONTAINER.md](QUICK_START_CONTAINER.md)** - ⭐ **Start here!** 2-minute guide for contributors using containers
- **[READY_TO_USE.md](READY_TO_USE.md)** - Activation guide for the hybrid Task system

### Container Build
- **[CONTAINER_BUILD_SUCCESS.md](CONTAINER_BUILD_SUCCESS.md)** - ✅ Verification that container build is working
- **[../CONTRIBUTING.md](../CONTRIBUTING.md)** - Main contributor guide with container instructions
- **[../Containerfile](../Containerfile)** - Container definition with all build dependencies

### Task System Details
- **[MIGRATION_PLAN.md](MIGRATION_PLAN.md)** - Complete 4-phase migration strategy from Make to Task
- **[PYTHON_BUILD_SCRIPTS.md](PYTHON_BUILD_SCRIPTS.md)** - ⭐ Python scripts replacing Make (Phase 2)
- **[MODULAR_TASKFILE.md](MODULAR_TASKFILE.md)** - How the Taskfile is organized into modules
- **[TASK_COLORIZATION.md](TASK_COLORIZATION.md)** - Colorized help system and output formatting

### Development Setup
- **[VSCODE_TASKFILE_SCHEMA.md](VSCODE_TASKFILE_SCHEMA.md)** - VS Code integration for YAML schema validation

## 🚀 Getting Started

### For Contributors (Recommended)
1. Read: [QUICK_START_CONTAINER.md](QUICK_START_CONTAINER.md)
2. Build container: `task container:build`
3. Build docs: `task container:html`
4. Done! 🎉

### For Maintainers
1. Read: [READY_TO_USE.md](READY_TO_USE.md)
2. Read: [MIGRATION_PLAN.md](MIGRATION_PLAN.md)
3. Understand: [MODULAR_TASKFILE.md](MODULAR_TASKFILE.md)

## 📊 Current Status

| Component | Status | Description |
|-----------|--------|-------------|
| Task Runner | ✅ Active | Installed and configured (v3.45.4) |
| Hybrid Taskfile | ✅ Active | `Taskfile.yml` wraps existing Make targets |
| Container Build | ✅ Working | `uyuni-docs:latest` image built and tested |
| Colorized Help | ✅ Working | `task help` shows organized, colored menu |
| VS Code Integration | ✅ Working | YAML schema provides autocomplete |
| Documentation | ✅ Complete | 10 files covering all aspects |

## 🎯 What This Achieves

### Original Goals (From Conversation)
1. ✅ **Simplify build system**: 1,531 lines of Make → ~450 lines of Task YAML (70% reduction)
2. ✅ **Maintain Weblate integration**: No changes to translation workflow
3. ✅ **Container for contributors**: Podman container eliminates dependency installation
4. ✅ **Better UX**: Colorized help, clear task names, faster builds

### Technical Improvements
- **Hybrid approach**: Task wraps Make (no breaking changes)
- **Modular design**: 8 logical task modules (html, pdf, translate, etc.)
- **Modern tooling**: Task 3.45.4 with YAML syntax
- **Container-first**: Contributors don't install dependencies locally
- **Incremental migration**: Can continue replacing Make targets gradually

## 📈 Comparison: Make vs Task

### Before (Make)
```bash
make html-uyuni-en          # Build English HTML
make pdf-uyuni-all-en       # Build English PDFs
make clean-en               # Clean English build
./configure uyuni           # Configure product
make help                   # Show help (basic)
```
- 1,531 lines across multiple generated Makefiles
- Complex Jinja2 templating
- Hard to read/maintain
- No container support

### After (Task)
```bash
task html                   # Build English HTML (default)
task html LANG=ja           # Build Japanese HTML
task pdf                    # Build English PDFs
task clean                  # Clean build artifacts
task configure:uyuni        # Configure product
task help                   # Show colorized help
```
- 450 lines of readable YAML
- Clear task names and descriptions
- Built-in help and --list
- Container-first design
- Still calls Make targets during transition

### Container Builds
```bash
# New capability - didn't exist before
task container:build        # Build container once
task container:html         # Build in container
task container:shell        # Interactive development
```

## 🔄 Migration Status

### Phase 1: Foundation (✅ COMPLETE)
- ✅ Task installed and configured
- ✅ Hybrid Taskfile created and activated
- ✅ Container built and tested
- ✅ Documentation complete

### Phase 2: Python Scripts (✅ COMPLETE)
- ✅ Port Make functions to Python scripts (build_config.py, build_html.py, build_pdf.py, setup.py)
- ✅ Task integration with py:* commands
- ⏳ Add live reload dev server

### Phase 3: Pure Task (📅 FUTURE)
- 📅 Remove Make dependencies
- 📅 Use modular Taskfile structure
- 📅 Optimize for parallel builds

### Phase 4: Cleanup (📅 FUTURE)
- 📅 Archive old Makefiles
- 📅 Remove Jinja2 templates
- 📅 Update CI/CD pipelines

## 🛠️ Key Files

### Active Build System
- `Taskfile.yml` - Main entry point (hybrid mode)
- `Makefile.lang` - Legacy Make targets (still used)
- `scripts/show_help.py` - Colorized help menu
- `Containerfile` - Build environment container

### Future Structure (Ready but Not Active)
- `tasks/Taskfile.*.yml` - 8 modular task files
- `Taskfile.modular.yml` - Pure Task example

### Configuration
- `.vscode/settings.json` - VS Code YAML schema
- `.vscode/extensions.json` - Recommended extensions
- `.containerignore` - Container build exclusions

## 💡 Key Concepts

### Hybrid Mode
The current system wraps existing Make targets with Task commands:
```yaml
html:
  cmds:
    - make html-{{.PRODUCT}}-{{.LANG}}
```
This allows gradual migration without breaking existing workflows.

### Variables
```yaml
PRODUCT: uyuni|mlm          # Product to build
LANG: en|ja|ko|zh_CN        # Language to build
LANGS_ALL: en ja ko zh_CN   # All supported languages
```

### Container Architecture
```
Host Machine → Podman → Container (OpenSUSE Leap 15.6)
                         ├── Task 3.45.4
                         ├── Node.js 20 (Antora)
                         ├── Ruby 2.5 (Asciidoctor)
                         ├── Python 3 (Build scripts)
                         └── All dependencies pre-installed
```

## 🎓 Learning Resources

### Task Documentation
- Official: https://taskfile.dev/
- Schema: https://taskfile.dev/schema.json
- Examples: See `Taskfile.yml` and `tasks/Taskfile.*.yml`

### Container Documentation
- Podman: https://podman.io/
- Containerfile: See inline comments in `../Containerfile`
- Usage: See [QUICK_START_CONTAINER.md](QUICK_START_CONTAINER.md)

### Project Documentation
- Antora: https://antora.org/
- Asciidoctor: https://asciidoctor.org/
- Weblate: https://weblate.org/

## 🤝 Contributing

See [../CONTRIBUTING.md](../CONTRIBUTING.md) for:
- Setting up your environment
- Building documentation
- Submitting changes
- Troubleshooting

## 📝 Questions?

### "Which build method should I use?"
**Container** (recommended for contributors) - No setup needed  
**Local** (optional for maintainers) - Faster iteration if you have dependencies

### "Does this break existing workflows?"
**No** - The hybrid system maintains backward compatibility. All existing Make commands still work.

### "When will Make be removed?"
**Not yet** - We're in Phase 1 (hybrid mode). Make will be phased out gradually over Phases 2-3.

### "How do I update the container?"
Edit `Containerfile`, run `task container:build`, test with `task container:html`.

### "Can I still use Make?"
**Yes** - All Make commands continue to work during the transition.

## 📞 Support

- Check documentation in this directory first
- Read [TROUBLESHOOTING] section in [READY_TO_USE.md](READY_TO_USE.md)
- Ask in project channels if still stuck

---

**Last Updated**: 2024 (Task 3.45.4, Container build verified)
**Status**: Production-ready for contributors ✅
