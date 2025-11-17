# Python Build Scripts - Phase 2 Implementation

The Python build scripts replace Make logic with modern, maintainable Python code.

## Overview

The build system is transitioning from Make to Python + Task:

| Component | Old (Make) | New (Python) | Status |
|-----------|------------|--------------|--------|
| Configuration | `./configure` + Jinja2 templates | `scripts/setup.py` | ✅ Complete |
| HTML builds | `make html-*` | `scripts/build_html.py` | ✅ Complete |
| PDF builds | `make pdf-*` | `scripts/build_pdf.py` | ✅ Complete |
| Config management | `parameters.yml` + templates | `scripts/build_config.py` | ✅ Complete |

## Python Scripts

### 1. `scripts/build_config.py`

**Purpose**: Central configuration management  
**Features**:
- Loads and parses `parameters.yml`
- Provides type-safe access to products, languages, sections
- Handles CJK language detection
- Manages build directory paths

**Usage**:
```python
from build_config import get_config

config = get_config()
product = config.get_product('uyuni')
lang = config.get_language('ja')
print(f"Building {product.productname} in {lang.name}")
```

**CLI**:
```bash
python3 scripts/build_config.py  # Show configuration
```

### 2. `scripts/setup.py`

**Purpose**: Replace `./configure` script  
**Features**:
- Configure for specific products
- Verify dependencies
- Show configuration information
- Generate site.yml files (if templates exist)

**Usage**:
```bash
# Show configuration
python3 scripts/setup.py info

# Verify dependencies
python3 scripts/setup.py verify

# Configure for a product
python3 scripts/setup.py configure uyuni
python3 scripts/setup.py configure mlm
```

**Task Integration**:
```bash
task py:info            # Show config
task py:verify          # Check dependencies
task py:configure       # Configure for default product
task py:configure PRODUCT=mlm
```

### 3. `scripts/build_html.py`

**Purpose**: Build HTML documentation with Antora  
**Features**:
- Product and language validation
- Automatic translation preparation
- Clean build support
- Site file detection

**Usage**:
```bash
# Build English Uyuni HTML
python3 scripts/build_html.py --product uyuni --lang en

# Build Japanese with clean
python3 scripts/build_html.py --product uyuni --lang ja --clean

# Build MLM
python3 scripts/build_html.py --product mlm --lang en
```

**Task Integration**:
```bash
task py:html                      # Uyuni English
task py:html LANG=ja              # Japanese
task py:html PRODUCT=mlm          # MLM
task py:html CLEAN=true           # Clean build
```

### 4. `scripts/build_pdf.py`

**Purpose**: Build PDF documentation with Asciidoctor-PDF  
**Features**:
- CJK language support (automatic)
- PDF theme selection
- Font directory management
- Locale handling
- Build all sections or specific sections

**Usage**:
```bash
# Build all PDFs for English
python3 scripts/build_pdf.py --product uyuni --lang en --all

# Build specific section
python3 scripts/build_pdf.py --product uyuni --lang ja --section installation-and-upgrade

# Build all Japanese PDFs
python3 scripts/build_pdf.py --product uyuni --lang ja --all
```

**Task Integration**:
```bash
task py:pdf                          # All English PDFs
task py:pdf LANG=ja                  # All Japanese PDFs
task py:pdf SECTION=administration   # One section
task py:pdf:all                      # All PDFs (alias)
```

## Architecture

### Class Hierarchy

```
BuildConfig (build_config.py)
├── ProductConfig
│   ├── product_id (str)
│   ├── productname (str)
│   ├── sections (List[str])
│   └── asciidoc_attributes (Dict)
└── LanguageConfig
    ├── langcode (str)
    ├── name (str)
    ├── locale (str)
    ├── is_cjk (bool property)
    └── pdf_flags (str property)

HTMLBuilder (build_html.py)
├── check_antora()
├── prepare_translations()
└── build(product, lang, clean)

PDFBuilder (build_pdf.py)
├── check_asciidoctor()
├── get_theme_file()
├── build_section_pdf()
└── build_all_pdfs()

SetupManager (setup.py)
├── configure(product)
├── verify_dependencies()
└── show_info()
```

### Data Flow

```
parameters.yml
    ↓
BuildConfig.load_config()
    ↓
┌─────────────────┬──────────────────┬──────────────────┐
│                 │                  │                  │
SetupManager   HTMLBuilder      PDFBuilder
    ↓                ↓                 ↓
Configure      Antora          Asciidoctor-PDF
    ↓                ↓                 ↓
site-*.yml     build/*/        build/*/pdf/
```

## Comparison: Make vs Python

### Configuration

**Make (Old)**:
```bash
./configure uyuni
# Generates Makefile.en, Makefile.ja, etc via Jinja2
# Complex templating, hard to debug
```

**Python (New)**:
```bash
task py:configure PRODUCT=uyuni
# Pure Python, easy to debug
# Type-safe configuration objects
```

### HTML Build

**Make (Old)**:
```makefile
html-uyuni-en: translations prepare-antora-uyuni-en
	antora --fetch site.yml
```

**Python (New)**:
```python
builder = HTMLBuilder()
builder.build(product='uyuni', lang='en')
# Automatic validation, better error messages
```

### PDF Build

**Make (Old)**:
```makefile
pdf-installation-and-upgrade-uyuni-ja: translations prepare-antora-uyuni-ja
	$(call pdf-installation-and-upgrade-product-uyuni,translations/ja,uyuni-jp,...)
# 10+ parameters, complex macro expansion
```

**Python (New)**:
```python
builder = PDFBuilder()
builder.build_section_pdf(
    product='uyuni',
    lang='ja',
    section='installation-and-upgrade'
)
# Clear parameter names, automatic CJK detection
```

## Benefits of Python Scripts

### 1. **Readability**
- Clear function names and parameters
- No macro expansion magic
- Self-documenting code

### 2. **Type Safety**
- Configuration objects with validation
- Compile-time error detection (with type hints)
- IDE autocomplete support

### 3. **Error Handling**
- Better error messages
- Try/except blocks with context
- Validation before execution

### 4. **Maintainability**
- 300 lines of Python vs 1,531 lines of Make
- Easy to add new features
- No Jinja2 template generation

### 5. **Testing**
- Unit testable (can be added)
- Mock-able dependencies
- Easier to debug

### 6. **Container Compatibility**
- Same scripts work locally and in containers
- No PATH or environment issues
- Python 3.6+ is universal

## Migration Strategy

### Phase 1: ✅ COMPLETE
- Created Python scripts
- Added Task integration
- Documented usage

### Phase 2: 🚧 IN PROGRESS (Current)
- Test Python scripts in parallel with Make
- Fix edge cases and bugs
- Update documentation

### Phase 3: 📅 PLANNED
- Switch default tasks to Python scripts
- Mark Make tasks as deprecated
- Update CI/CD to use Python

### Phase 4: 📅 FUTURE
- Remove Make completely
- Archive old Makefiles
- Remove Jinja2 templates

## Testing the Python Scripts

### Basic Tests

```bash
# 1. Test configuration loading
task py:info

# 2. Verify dependencies
task py:verify

# 3. Test HTML build
task py:html

# 4. Test PDF build (one section)
task py:pdf SECTION=installation-and-upgrade

# 5. Test all PDFs
task py:pdf:all
```

### Comparison Tests

Run both Make and Python versions and compare output:

```bash
# Make version
task html                  # Uses make html-uyuni-en
ls -lh build/en/

# Python version
task py:html               # Uses scripts/build_html.py
ls -lh build/en/

# Should produce identical output
```

## Troubleshooting

### Import Errors

**Problem**: `ModuleNotFoundError: No module named 'yaml'`  
**Solution**: Install PyYAML:
```bash
pip3 install --user pyyaml
# OR in container:
pip3 install pyyaml
```

### Path Issues

**Problem**: `FileNotFoundError: parameters.yml not found`  
**Solution**: Run from project root:
```bash
cd /home/scribe/projects/work/uyuni-docs
python3 scripts/build_html.py
```

### Antora Not Found

**Problem**: `ERROR: Antora not found`  
**Solution**: Install Antora or use container:
```bash
npm install -g @antora/cli
# OR
task container:html
```

## Next Steps

1. **Test thoroughly**: Run Python scripts alongside Make
2. **Report issues**: Document any differences in output
3. **Add features**: Live reload, watch mode, better caching
4. **Update CI/CD**: Switch automated builds to Python
5. **Remove Make**: Once Python scripts are proven stable

## Questions?

- **Q: Can I use both Make and Python?**  
  A: Yes! They work in parallel. Use `task html` (Make) or `task py:html` (Python).

- **Q: Which should I use?**  
  A: Python scripts are recommended. Make is for backward compatibility.

- **Q: What if Python scripts have bugs?**  
  A: Fall back to Make: `task html` instead of `task py:html`.

- **Q: How do I contribute?**  
  A: Edit files in `scripts/`, test with `task py:*`, submit PR.

---

**Status**: Python scripts are ready for testing in parallel with Make  
**Recommendation**: Try `task py:html` and `task py:pdf` for new builds  
**Support**: See `docs/MIGRATION_PLAN.md` for full migration strategy
