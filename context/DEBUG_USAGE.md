# Debug Usage Guide

## Overview
The enhanced Uyuni documentation build system now includes colored output and debug functionality to improve the build experience and troubleshooting capabilities.

## Enhanced Build Features (CI/CD Safe)

### Key Principles
- **All existing commands work identically** - no breaking changes
- **Colors auto-disabled** in CI/CD environments (Docker, GitHub Actions)
- **Enhanced features are opt-in only** - default behavior preserved
- **Environment detection** automatically handles CI vs interactive use

### Enhanced Logging (Opt-in)
```bash
# Enable colored status messages (only in interactive terminals)
make VERBOSE_LOG=1 <target>

# Enable debug command output (verbose mode)
make DEBUG=1 <target>

# Combine both features
make DEBUG=1 VERBOSE_LOG=1 <target>

# Examples:
make VERBOSE_LOG=1 antora-uyuni-en      # Colored progress messages
make DEBUG=1 pdf-all-uyuni-ja           # Full command output
make DEBUG=1 VERBOSE_LOG=1 clean-ko     # Both debug and colors
```

### Automatic Environment Detection

#### CI/CD Environments (Automatic)
- GitHub Actions, Jenkins, Docker builds detected automatically
- Colors automatically disabled (empty color codes)
- Default output remains exactly the same
- No impact on existing automation

#### Interactive Terminals
- Colors enabled when TTY detected and not in CI
- Enhanced logging available via VERBOSE_LOG=1
- Debug output available via DEBUG=1

#### Manual Override
```bash
# Force disable colors (useful for scripting)
CI=1 make antora-uyuni-en

# Force enable colors (if auto-detection fails)  
INTERACTIVE=1 make VERBOSE_LOG=1 antora-uyuni-en
```

### What Each Mode Provides

#### Default Mode (Unchanged)
- Exactly same output as before
- No colors, no extra messages
- Works identically in CI/CD
- Compatible with all existing scripts

#### Verbose Logging (VERBOSE_LOG=1)
- Colored status messages: [INFO], [SUCCESS], [WARN], [ERROR]
- Progress indicators for long operations
- Only in interactive terminals
- Safe for local development use

#### Debug Mode (DEBUG=1)  
- Full command output from all tools
- Detailed build steps and file operations
- Complete error messages and stack traces
- Available in both CI and interactive environments

## Color Coding System

### Log Levels
| Color | Level | Usage | Example |
|-------|-------|-------|---------|
| **CYAN** | `[INFO]` | General build information | "Building Uyuni documentation (en)" |
| **BLUE** | `[BUILD]` | Command execution details | "Running: npx antora site.yml" |
| **GREEN** | `[SUCCESS]` | Successful completion | "PDF created: uyuni_administration_guide.pdf" |
| **YELLOW** | `[WARN]` | Non-critical warnings | "Missing image reference" |
| **RED** | `[ERROR]` | Critical build failures | "asciidoctor-pdf failed to generate PDF" |

### Help System Colors
- **CYAN** - Section headers and titles
- **GREEN** - Available commands and targets
- **YELLOW** - Language codes, sections, and options
- **BLUE** - Debug and development commands
- **BOLD** - Important headings and emphasis

## Command Categories

### HTML Documentation
```bash
# Build HTML documentation for single language
make antora-uyuni-en        # English Uyuni docs
make antora-mlm-ja          # Japanese SUSE MLM docs
make DEBUG=1 antora-uyuni-ko # Korean with verbose output
```

### PDF Documentation

#### All PDFs for Language
```bash
make pdf-all-uyuni-en       # All English Uyuni PDFs
make pdf-all-mlm-zh_CN      # All Chinese SUSE MLM PDFs
make DEBUG=1 pdf-all-uyuni-ja # All Japanese PDFs with debug
```

#### Single PDF Guide
```bash
make pdf-administration-uyuni-en        # Single guide
make pdf-installation-and-upgrade-mlm-ja # MLM installation guide
make DEBUG=1 pdf-reference-uyuni-ko     # With debug output
```

### Complete Builds
```bash
make obs-packages-uyuni-en  # Complete build: HTML + PDF + packaging
make obs-packages-mlm-ja    # Complete MLM build
```

## Troubleshooting

### Common Issues

#### Build Failures
```bash
# Use debug mode to see full error details
make DEBUG=1 antora-uyuni-en

# Check for missing dependencies
npm list -g antora
which asciidoctor-pdf
```

#### PDF Generation Issues  
```bash
# Debug PDF creation with full asciidoctor output
make DEBUG=1 pdf-administration-uyuni-en

# Check theme and font availability
ls -la branding/pdf/themes/
ls -la branding/pdf/fonts/
```

#### Missing Colors
- Ensure your terminal supports ANSI color codes
- Try a different terminal (bash, zsh, modern terminals)
- Colors may not appear in some CI/CD environments

### Debug Commands

#### Test System
```bash
make test-colors            # Test color output
make debug-help             # Show debug usage
make list-targets           # List all available targets
```

#### Validation
```bash
make validate-uyuni-en      # Validate documentation structure  
make validate-mlm-ja        # Validate MLM docs
make checkstyle             # Check AsciiDoc compliance
```

## Examples

### Regular Build Workflow
```bash
# Configure for Uyuni
make configure-uyuni

# Build English HTML documentation
make antora-uyuni-en

# Build all English PDFs  
make pdf-all-uyuni-en

# Clean when done
make clean-en
```

### Debug Build Workflow
```bash
# Configure with debug info
make DEBUG=1 configure-uyuni

# Build with full output to diagnose issues
make DEBUG=1 antora-uyuni-en

# Check specific PDF with verbose asciidoctor output
make DEBUG=1 pdf-administration-uyuni-en
```

### Multi-Language Build
```bash
# Build HTML for all languages
make antora-uyuni-en antora-uyuni-ja antora-uyuni-ko antora-uyuni-zh_CN

# Build PDFs for all languages (can run in parallel)
make pdf-all-uyuni-en & \
make pdf-all-uyuni-ja & \
make pdf-all-uyuni-ko & \
make pdf-all-uyuni-zh_CN &
wait
```

## Performance Tips

### Parallel Builds
- PDF generation for different languages can run in parallel
- Use `&` to background processes and `wait` to synchronize
- Don't run parallel builds for same language (file conflicts)

### Incremental Builds
- Use language-specific clean targets: `make clean-en` vs `make clean`
- Only rebuild changed sections when possible
- Keep translation directories when only updating source content

### Debug Efficiency  
- Use debug mode only when troubleshooting
- Normal mode is faster for regular builds
- Target specific sections when debugging PDFs

## Integration with CI/CD

### Automatic CI/CD Safety
The build system automatically detects CI/CD environments and adjusts behavior:

```bash
# These work identically in CI and locally (no changes needed)
make antora-uyuni-en
make pdf-all-uyuni-ja  
make obs-packages-uyuni-ko
make clean-zh_CN
```

### Environment Detection
- **GitHub Actions**: Detected via `$GITHUB_ACTIONS` environment variable
- **Jenkins**: Detected via `$JENKINS_URL` environment variable  
- **General CI**: Detected via `$CI` environment variable
- **Docker**: Auto-detected when TTY not available
- **Non-interactive**: Colors disabled when not running in terminal

### Docker Container Compatibility
```dockerfile
# In Dockerfile - works exactly as before
RUN make antora-uyuni-en

# GitHub Actions - no changes needed  
- name: Build docs
  run: make obs-packages-uyuni-en
```

### Manual Control (if needed)
```bash
# Force CI mode (disable all enhancements)
CI=1 make antora-uyuni-en

# Force debug in CI (for troubleshooting)
DEBUG=1 make antora-uyuni-en

# The verbose logging is automatically disabled in CI
# (VERBOSE_LOG=1 has no effect in CI environments)
```

### Error Detection (Unchanged)
- Exit codes properly propagate build failures (same as before)
- Standard error output preserved for CI parsing  
- DEBUG mode provides additional details when needed
- No changes to existing error handling workflows
