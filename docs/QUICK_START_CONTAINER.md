# Quick Start: Container Build (2 Minutes)

The fastest way to build Uyuni documentation as a contributor.

## Prerequisites
- Podman or Docker installed
- Git

## Steps

### 1. Clone and Enter
```bash
git clone https://github.com/uyuni-project/uyuni-docs.git
cd uyuni-docs
```

### 2. Build Container (First Time Only)
```bash
task container:build
# OR: podman build -t uyuni-docs:latest -f Containerfile .
```
⏱️ Takes ~5 minutes first time (downloads base image + installs dependencies)

### 3. Build Documentation
```bash
task container:html
# OR: podman run --rm -v $(pwd):/workspace:Z uyuni-docs:latest task html
```
⏱️ Takes ~30 seconds for HTML build

### 4. View Results
```bash
firefox build/en/index.html
# OR: open build/en/index.html
```

## Common Commands

```bash
# English HTML (fastest)
task container:html

# Japanese HTML
task container:html LANG=ja

# Korean HTML  
task container:html LANG=ko

# Chinese HTML
task container:html LANG=zh_CN

# Build everything (HTML + all PDFs)
podman run --rm -v $(pwd):/workspace:Z uyuni-docs:latest task build:all

# Interactive development shell
task container:shell
# Inside container: task html, task build, etc.

# Show all available commands
podman run --rm -v $(pwd):/workspace:Z uyuni-docs:latest task help
```

## File Locations

| What | Where |
|------|-------|
| Source files | `modules/*/pages/*.adoc` |
| Build output | `build/<lang>/` |
| Container definition | `Containerfile` |
| Build commands | `Taskfile.yml` |

## Troubleshooting

### "Permission denied" errors
Add `:Z` to volume mount for SELinux:
```bash
-v $(pwd):/workspace:Z
```

### Container not found
Rebuild the container:
```bash
task container:build
```

### Need to update dependencies
Edit `Containerfile`, then:
```bash
task container:build  # Rebuild
```

## Why Use Containers?

✅ **No local dependencies** - Everything is pre-installed in the container  
✅ **Consistent builds** - Same environment for everyone  
✅ **Clean separation** - Container is isolated from your system  
✅ **Easy updates** - Just rebuild the container  
✅ **Works everywhere** - Linux, macOS, Windows (with Podman/Docker)

## Next Steps

- Edit files in `modules/*/pages/`
- Run `task container:html` to rebuild
- Refresh browser to see changes
- See `CONTRIBUTING.md` for more details

**Happy documenting!** 📝
