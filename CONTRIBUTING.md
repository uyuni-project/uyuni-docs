# Contributing to Uyuni Documentation

Thank you for contributing! This guide will help you set up your environment and build the documentation.

## Quick Start (Recommended for Contributors)

### Option 1: Using Container (Easiest)

No local dependencies needed! Everything runs in a container.

```bash
# 1. Clone the repository
git clone https://github.com/uyuni-project/uyuni-docs.git
cd uyuni-docs

# 2. Build the container image (first time only)
task container:build
# OR: podman build -t uyuni-docs:latest -f Containerfile .

# 3. Build HTML documentation
task container:html
# OR: podman run --rm -v $(pwd):/workspace:Z uyuni-docs:latest task html

# 4. Open interactive shell (for development)
task container:shell
# Inside container: task html, task build, etc.
```

**That's it!** The container has everything pre-installed.

### Option 2: Local Build (Advanced)

If you prefer building locally, you need to install dependencies.

#### Prerequisites

- **Python 3.6+** with PyYAML, Jinja2
- **Ruby 2.5+** with asciidoctor, asciidoctor-pdf
- **Node.js 18+** with Antora, npm packages
- **Task** (go-task) - optional but recommended
- **Make** - for legacy build system
- **po4a** - for translations

Install Task:
```bash
sh -c "$(curl -fsSL https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin
```

#### Build Commands

```bash
# Configure for your product (Uyuni or MLM)
task configure:uyuni

# Build HTML (fast, for development)
task html                    # English
task html LANG=ja            # Japanese
task html PRODUCT=mlm        # MLM instead of Uyuni

# Build PDFs
task pdf                     # All PDFs
task pdf:section SECTION=administration  # Single PDF

# Complete build (HTML + PDFs)
task build                   # One language
task build:all               # All languages

# Check quality
task validate                # Check links
task checkstyle              # Style checking

# Clean up
task clean                   # One language
task clean:all               # Everything
```

## Workflow for Contributors

### 1. **Fork and Clone**
```bash
git clone https://github.com/YOUR-USERNAME/uyuni-docs.git
cd uyuni-docs
```

### 2. **Make Changes**
Edit `.adoc` files in `modules/*/pages/`

### 3. **Build and Preview**
```bash
# Quick HTML build to check your changes
task html

# Or in container
task container:html

# View output
open build/en/index.html
```

### 4. **Validate**
```bash
# Check for broken links
task validate

# Check style
task checkstyle
```

### 5. **Submit PR**
Push to your fork and create a Pull Request.

## Container Details

### Why Use Containers?

✅ **No dependency installation** - Everything is pre-installed  
✅ **Consistent environment** - Same build on all machines  
✅ **Isolated** - Doesn't affect your system  
✅ **Works everywhere** - Linux, Mac, Windows  

### Container Commands

```bash
# Build the image
task container:build

# Interactive shell (recommended for development)
task container:shell
# Inside: task html, task build, etc.

# One-off builds
task container:html          # Build HTML
task container:html LANG=ja  # Japanese

# With podman/docker directly
podman run --rm -it -v $(pwd):/workspace:Z uyuni-docs:latest bash
podman run --rm -v $(pwd):/workspace:Z uyuni-docs:latest task html
```

### Container Volume Mounting

The container mounts your local directory:
- Changes to source files are immediately available in container
- Build outputs appear in your local `build/` directory
- You can edit with your local IDE while building in container

## Task vs Make

Both work! Task is newer and cleaner, Make is the legacy system.

```bash
# Task (recommended)
task html LANG=ja
task build
task clean

# Make (still works)
make html-uyuni-ja
make antora-uyuni-en
make clean-ja
```

## Translation Workflow

If you're working on translations:

```bash
# Sync translations from Weblate
task translate

# Build translated docs
task html LANG=ja            # Japanese
task html LANG=ko            # Korean
task html LANG=zh_CN         # Chinese
```

## Troubleshooting

### Container build fails
```bash
# Try clearing cache
podman system prune -a
task container:build
```

### Build fails locally
```bash
# Clean and rebuild
task clean:all
task configure:uyuni
task html
```

### Changes not appearing
```bash
# Clear Task cache
rm -rf .task/
task html
```

## File Organization

```
uyuni-docs/
├── modules/                    # Documentation source
│   ├── ROOT/                   # Main pages
│   ├── administration/         # Administration guide
│   ├── client-configuration/   # Client config guide
│   └── ...                     # Other guides
├── build/                      # Build outputs (gitignored)
├── Taskfile.yml               # Task definitions
├── Makefile                    # Legacy Make (still works)
├── Containerfile              # Container definition
└── parameters.yml              # Build configuration
```

## Getting Help

- **Documentation issues**: Open an issue on GitHub
- **Build problems**: Check the troubleshooting section above
- **Questions**: Ask in the Uyuni community channels

## Advanced Topics

### Adding a New Page

1. Create `.adoc` file in `modules/*/pages/`
2. Add to navigation in `modules/*/nav.adoc`
3. Build and test: `task html`

### Working with PDFs

```bash
# Build single section PDF
task pdf:section SECTION=administration

# Build all PDFs
task pdf

# PDFs are in: build/en/pdf/
```

### Running Validation

```bash
# Validate links and structure
task validate

# Auto-fix style issues
task checkstyle:fix
```

## Migration Status

We're transitioning from Make to Task:
- ✅ Task commands work (call Make underneath)
- ✅ Make commands still work (backward compatible)
- ✅ Container support ready
- 🚧 Pure Task implementation (in progress)

Both systems work - use whichever you prefer!
