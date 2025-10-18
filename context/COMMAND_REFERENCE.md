# Major Uyuni Documentation Build Commands

## Quick Reference Card

### 🚀 Fast Development Commands (HTML Only)
```bash
# Super fast HTML-only builds for ALL languages (no PDFs)
make html-uyuni             # Uyuni HTML for ALL languages
make html-mlm               # SUSE MLM HTML for ALL languages

# Fast HTML-only builds (no PDFs) - single language for focused development
make html-uyuni-en          # English Uyuni HTML only
make html-uyuni-ja          # Japanese Uyuni HTML only  
make html-uyuni-ko          # Korean Uyuni HTML only
make html-uyuni-zh_CN       # Chinese Uyuni HTML only

make html-mlm-en            # English SUSE MLM HTML only
make html-mlm-ja            # Japanese SUSE MLM HTML only
make html-mlm-ko            # Korean SUSE MLM HTML only
make html-mlm-zh_CN         # Chinese SUSE MLM HTML only
```

### 📚 Complete Documentation Builds (HTML + PDF)
```bash
# Complete builds with HTML and all PDFs for ALL languages
make antora-uyuni           # Uyuni (HTML + all PDFs) - ALL languages
make antora-mlm             # SUSE MLM (HTML + all PDFs) - ALL languages

# Complete builds with HTML and all PDFs - single language
make antora-uyuni-en        # English Uyuni (HTML + all PDFs)
make antora-uyuni-ja        # Japanese Uyuni (HTML + all PDFs)
make antora-uyuni-ko        # Korean Uyuni (HTML + all PDFs)  
make antora-uyuni-zh_CN     # Chinese Uyuni (HTML + all PDFs)

make antora-mlm-en          # English SUSE MLM (HTML + all PDFs)
make antora-mlm-ja          # Japanese SUSE MLM (HTML + all PDFs)
make antora-mlm-ko          # Korean SUSE MLM (HTML + all PDFs)
make antora-mlm-zh_CN       # Chinese SUSE MLM (HTML + all PDFs)
```

### 📖 Individual PDF Builds
```bash
# Build single PDF guides (replace <lang> with en, ja, ko, zh_CN)
make pdf-installation-and-upgrade-uyuni-<lang>
make pdf-client-configuration-uyuni-<lang>  
make pdf-administration-uyuni-<lang>
make pdf-reference-uyuni-<lang>
make pdf-retail-uyuni-<lang>
make pdf-common-workflows-uyuni-<lang>
make pdf-specialized-guides-uyuni-<lang>
make pdf-legal-uyuni-<lang>

# Same pattern for MLM (replace uyuni with mlm)
make pdf-administration-mlm-<lang>
# ... etc
```

### 📦 Production Builds (Complete with Packaging)
```bash
# Complete production builds with HTML, PDFs, and OBS packaging
make obs-packages-uyuni-en      # Complete English Uyuni build
make obs-packages-uyuni-ja      # Complete Japanese Uyuni build
make obs-packages-uyuni-ko      # Complete Korean Uyuni build
make obs-packages-uyuni-zh_CN   # Complete Chinese Uyuni build

make obs-packages-mlm-en        # Complete English SUSE MLM build  
make obs-packages-mlm-ja        # Complete Japanese SUSE MLM build
make obs-packages-mlm-ko        # Complete Korean SUSE MLM build
make obs-packages-mlm-zh_CN     # Complete Chinese SUSE MLM build
```

### 🔧 Configuration & Setup
```bash
make configure-uyuni            # Configure build system for Uyuni
make configure-mlm              # Configure build system for SUSE MLM  
make translations               # Update translation files
make pot                        # Generate translation templates
```

### 🧹 Cleanup Commands  
```bash
make clean                      # Clean all build artifacts
make clean-en                   # Clean English artifacts only
make clean-ja                   # Clean Japanese artifacts only
make clean-ko                   # Clean Korean artifacts only
make clean-zh_CN                # Clean Chinese artifacts only
make clean-branding             # Clean branding files
```

### ✅ Validation & Quality
```bash
make validate-uyuni-en          # Validate English Uyuni docs
make validate-mlm-ja            # Validate Japanese MLM docs
make checkstyle                 # Check AsciiDoc style compliance
make checkstyle-autofix         # Auto-fix AsciiDoc style issues
```

### 🐛 Debug & Development Tools
```bash
make help                       # Beautiful organized help (auto-adapts: colors in terminal, plain in CI)
make debug-help                 # Debug usage information
make test-colors                # Test color output
make list-targets               # List all available targets

# Debug modes for troubleshooting
make DEBUG=1 html-uyuni-en      # HTML build with verbose output
make VERBOSE_LOG=1 html-uyuni-en # HTML build with colored progress
make DEBUG=1 VERBOSE_LOG=1 antora-uyuni-en # Full debug + colors

# Force colors on/off
make FORCE_COLOR=1 help         # Force colors even in non-interactive environments
make NO_COLOR=1 help            # Disable colors even in interactive environments
```

## 🎯 Recommended Workflows

### Content Development (Fast Iteration)
```bash
# 1. Configure for your product
make configure-uyuni

# 2. Fast HTML-only builds during writing
make html-uyuni-en              # Quick preview of changes

# 3. Test specific PDF when needed  
make pdf-administration-uyuni-en

# 4. Clean when switching languages
make clean-en
```

### Quality Assurance
```bash
# 1. Validate structure
make validate-uyuni-en

# 2. Check style compliance  
make checkstyle

# 3. Build complete documentation
make antora-uyuni-en

# 4. Review all outputs
ls -la build/en/
```

### Production Release  
```bash
# 1. Configure for product
make configure-uyuni

# 2. Update translations
make translations

# 3. Build all languages for production
make obs-packages-uyuni-en &
make obs-packages-uyuni-ja &  
make obs-packages-uyuni-ko &
make obs-packages-uyuni-zh_CN &
wait

# 4. Package and distribute
ls -la build/packages/
```

## ⚡ Performance Tips

### Fast Development Cycle
- Use `html-*` targets during content development
- Only build PDFs when you need to review formatting  
- Use language-specific clean targets (`clean-en`) vs full clean
- Run parallel builds for different languages with `&`

### Troubleshooting Builds
- Use `DEBUG=1` to see full command output and error details
- Use `VERBOSE_LOG=1` for colored progress messages  
- Check individual PDF builds if complete build fails
- Use `validate-*` targets to check document structure

### CI/CD Optimizations
- Default commands work identically in Docker containers
- Colors automatically disabled in CI environments  
- Use `make obs-packages-*` for complete automated builds
- Exit codes properly propagate for build failure detection
