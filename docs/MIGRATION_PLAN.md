# Migration Plan: Make → Task + Containers

## Current Status

✅ **Phase 1 Complete: Hybrid System Ready**

### What's Been Created:

1. **Taskfile.hybrid.yml** - Wraps existing Make targets
   - All your current Make commands work through Task
   - Colorful output with emojis for better UX
   - No changes to existing build logic (safe!)

2. **Container Files** - Ready for contributors
   - `Containerfile` (Podman)
   - `Dockerfile` (Docker)
   - Pre-installs: Antora, Asciidoctor, Task, Python, po4a, fonts, etc.
   - Runs as non-root user for security

3. **CONTRIBUTING.md** - Contributor guide
   - Container-first workflow
   - Task command examples
   - Troubleshooting guide

4. **Modular Taskfiles** - Future structure
   - `tasks/Taskfile.*.yml` modules
   - VS Code schema support configured
   - Ready for Phase 2

## Quick Start (Testing)

### 1. Try the Hybrid System

```bash
# Activate hybrid Taskfile
cp Taskfile.hybrid.yml Taskfile.yml

# Test it (calls your existing Make targets)
task configure:uyuni
task html
task html LANG=ja
task validate
task clean
```

### 2. Build the Container

```bash
# Build image (takes a few minutes first time)
podman build -t uyuni-docs:latest -f Containerfile .

# Test container
podman run --rm -v $(pwd):/workspace:Z uyuni-docs:latest task --list
```

### 3. Contributor Workflow

```bash
# Interactive shell
podman run --rm -it -v $(pwd):/workspace:Z uyuni-docs:latest bash

# Inside container
task configure:uyuni
task html
task validate
```

## Migration Phases

### ✅ Phase 1: Hybrid System (DONE)
- Task wraps existing Make
- Container with all dependencies
- Documentation for contributors
- **Status**: Ready to use today!

### 🚧 Phase 2: Python Scripts (NEXT)
Create Python scripts to replace Make logic:

```python
# scripts/setup.py - Replace ./configure
# scripts/build_html.py - Replace make html-*
# scripts/build_pdf.py - Replace make pdf-*
# scripts/sync_translations.py - Replace po4a workflow
# scripts/validate.py - Replace make validate-*
# scripts/package.py - Replace make obs-packages-*
```

**Benefits:**
- Easier to maintain than shell/Make functions
- Better error messages
- Cross-platform (Windows support)
- Works in containers and locally
- Can add features (progress bars, colored output, etc.)

### 📋 Phase 3: Pure Task Implementation
- Update Taskfile to call Python scripts instead of Make
- Keep Make as legacy fallback
- Full modular structure

### 🎯 Phase 4: Complete Migration
- Make becomes optional
- Task is primary build system
- Clean, maintainable codebase

## What Each File Does

```
Taskfile.hybrid.yml          # Wraps Make (use this now!)
Taskfile.modular.yml         # Future structure (Phase 3)
Taskfile.yml                 # Current prototype (don't use yet)

Containerfile                # Podman container definition
Dockerfile                   # Docker container definition
.containerignore            # Files to exclude from container

CONTRIBUTING.md              # Contributor guide (container-first)

tasks/                       # Modular task files (Phase 3)
  Taskfile.config.yml       # Configuration tasks
  Taskfile.html.yml         # HTML builds
  Taskfile.pdf.yml          # PDF builds
  ... etc ...

scripts/                     # Python build scripts (Phase 2)
  show_help.py              # ✅ Done - colorized help
  setup.py                  # TODO - replace configure
  build_html.py             # TODO - replace make html-*
  build_pdf.py              # TODO - replace make pdf-*
  ... etc ...
```

## Decision Points

### Choice 1: When to Switch to Hybrid Taskfile?

**Option A: Now (Recommended)**
```bash
mv Taskfile.yml Taskfile.old.yml
mv Taskfile.hybrid.yml Taskfile.yml
git add Taskfile.yml CONTRIBUTING.md Containerfile
git commit -m "Add Task wrapper and container support"
```

**Benefits:**
- Contributors can use containers immediately
- Cleaner interface than Make
- Everything still works (calls Make underneath)
- Can test with team before full migration

**Option B: After Testing**
- Test with a few people first
- Get feedback
- Then commit

### Choice 2: Container Base Image?

**Current: OpenSUSE Leap 15.6** (matches your project)

Alternatives:
- `opensuse/tumbleweed` - rolling release
- `fedora:latest` - more recent packages
- `ubuntu:24.04` - wider user base

**Recommendation**: Stick with Leap 15.6

### Choice 3: Migration Speed?

**Gradual (Recommended)**:
1. Use hybrid now
2. Port to Python over weeks/months
3. Team learns Task gradually
4. Low risk

**Fast Track**:
1. Port all to Python immediately
2. Switch to pure Task
3. Higher risk but done faster

**Recommendation**: Gradual approach

## Immediate Next Steps

### For You (Maintainer)

1. **Test Hybrid System**
   ```bash
   cp Taskfile.hybrid.yml Taskfile.yml
   task configure:uyuni
   task html
   ```

2. **Build Container**
   ```bash
   podman build -t uyuni-docs:latest -f Containerfile .
   podman run --rm -it -v $(pwd):/workspace:Z uyuni-docs:latest task html
   ```

3. **Commit if Happy**
   ```bash
   git add Taskfile.yml Containerfile Dockerfile CONTRIBUTING.md .containerignore
   git commit -m "Add Task build system and container support"
   ```

### For Contributors

Update your README to mention:
```markdown
## Building Documentation

### Using Container (Recommended)
```bash
podman build -t uyuni-docs -f Containerfile .
podman run --rm -v $(pwd):/workspace:Z uyuni-docs task html
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.
```

## Benefits You Get Today

1. **Cleaner Interface**
   - `task html LANG=ja` vs `make html-uyuni-ja`
   - Colored output with status emojis
   - Better help system

2. **Container Support**
   - Contributors don't install dependencies
   - Consistent build environment
   - Works on any OS

3. **Future Ready**
   - Structure ready for Python scripts
   - Modular organization prepared
   - Easy to enhance

4. **Backward Compatible**
   - Make still works
   - No breaking changes
   - Safe to test

## Questions to Decide

1. **Container runtime**: Podman (recommended) or Docker or both?
2. **When to switch**: Now or after testing?
3. **Migration speed**: Gradual or fast?
4. **Make support**: Keep forever or phase out?

## Summary

✅ **Ready to use today:**
- Hybrid Taskfile wraps Make
- Container with all dependencies
- Contributor documentation

🚧 **Next phase (optional):**
- Python scripts to replace Make
- Pure Task implementation
- Retire Make eventually

**Recommendation**: Start using hybrid system now with containers. It works today and sets you up for future improvements!
