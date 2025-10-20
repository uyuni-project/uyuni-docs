# Build Workflows Guide

**Version:** 1.0  
**Last Updated:** October 20, 2025

## Overview

This guide provides step-by-step workflows for common build scenarios in the uyuni-docs build system.

## Table of Contents

1. [First-Time Setup](#first-time-setup)
2. [Daily Development Workflows](#daily-development-workflows)
3. [Translation Workflows](#translation-workflows)
4. [Release Workflows](#release-workflows)
5. [Troubleshooting Workflows](#troubleshooting-workflows)
6. [CI/CD Integration](#cicd-integration)

---

## First-Time Setup

### Initial Build Environment Setup

**Goal:** Set up a working build environment from scratch.

```bash
# 1. Clone repository
git clone https://github.com/uyuni-project/uyuni-docs.git
cd uyuni-docs

# 2. Install dependencies
# Node.js (for Antora)
npm install -g @antora/cli @antora/site-generator-default

# Ruby (for asciidoctor-pdf)
gem install asciidoctor-pdf
gem install rouge  # Syntax highlighting

# Python 3 (for configure script)
# Already installed on most systems

# Jinja2 (for template processing)
pip3 install jinja2

# po4a (for translations)
sudo apt-get install po4a  # Debian/Ubuntu
# or
sudo dnf install po4a      # Fedora/RHEL

# 3. Configure build system
make configure

# 4. Verify configuration
ls Makefile.en Makefile.ja  # Should exist

# 5. Build English documentation
make antora-mlm-en

# 6. View result
firefox build/en/index.html
```

**Time:** ~15-30 minutes (depending on download speeds)

**Disk Space Required:** ~5 GB

---

## Daily Development Workflows

### Workflow 1: Edit Source Documentation

**Scenario:** You're editing English source documentation.

```bash
# 1. Edit source files
vim modules/administration/pages/actions.adoc

# 2. Preview changes (quick HTML build)
make clean-en
make antora-mlm-en

# 3. View in browser
firefox build/en/docs/administration/actions.html

# 4. Validate links
make validate-mlm-en

# 5. Check style
make checkstyle-en

# 6. Commit if all passes
git add modules/administration/pages/actions.adoc
git commit -m "Update actions documentation"
git push
```

**Time:** 5-10 minutes per iteration

### Workflow 2: Preview Both Products (MLM & Uyuni)

**Scenario:** Verify content appears correctly in both MLM and Uyuni.

```bash
# 1. Build MLM version
make antora-mlm-en

# 2. Build Uyuni version
make antora-uyuni-en

# 3. Compare outputs
# MLM: build/en/ (uses "docs" component)
# Uyuni: build/en/ (uses "uyuni" component, overwrites)

# Better: Build to separate directories (modify site.yml)
# Or view MLM first, then Uyuni

firefox build/en/index.html  # MLM
# Review, then rebuild
make clean-en
make antora-uyuni-en
firefox build/en/index.html  # Uyuni
```

**Note:** Both products overwrite `build/en/`. Best practice: build and test one at a time.

### Workflow 3: Test PDF Generation

**Scenario:** Verify PDF renders correctly with new content.

```bash
# 1. Build single PDF guide
make pdf-administration-mlm-en

# 2. View PDF
evince build/en/pdf/suse_multi_linux_manager_administration_guide.pdf

# 3. Check for issues:
#    - Missing images
#    - Broken cross-references
#    - Formatting problems
#    - Page breaks

# 4. If issues found, edit source
vim modules/administration/pages/problematic-file.adoc

# 5. Rebuild just that PDF
make pdf-administration-mlm-en

# 6. Verify fix
evince build/en/pdf/suse_multi_linux_manager_administration_guide.pdf
```

**Time:** 2-5 minutes per PDF

### Workflow 4: Quick Content Search

**Scenario:** Find where a term is documented.

```bash
# Search in source English files
grep -r "user management" modules/*/pages/

# Search in specific module
grep -r "system groups" modules/administration/pages/

# Search in navigation files
grep -r "xref:.*users" modules/*/nav-*.adoc

# Search in built HTML
grep -r "administrator" build/en/docs/

# Search with context
grep -C 3 "authentication" modules/administration/pages/users.adoc
```

---

## Translation Workflows

### Workflow 5: Update Translation Files (POT)

**Scenario:** Source English documentation has changed; update POT files for translators.

```bash
# 1. Make changes to source
vim modules/administration/pages/actions.adoc
git commit -am "Add new action types"

# 2. Extract updated strings to POT
make pot

# 3. Verify POT files updated
ls -l l10n-weblate/administration/pot/actions.adoc.pot

# 4. Check what changed
git diff l10n-weblate/administration/pot/actions.adoc.pot

# 5. Commit POT files
git add l10n-weblate/
git commit -m "Update POT files after actions documentation changes"

# 6. Push to trigger Weblate sync
git push
```

**Time:** 2-5 minutes

**Weblate Sync:** Automatic (within minutes of push)

### Workflow 6: Apply Updated Translations

**Scenario:** Translators have completed Japanese translations in Weblate.

```bash
# 1. Pull latest PO files from Weblate
git pull

# 2. Verify PO files updated
ls -l l10n-weblate/administration/ja/

# 3. Apply translations to generate Japanese AsciiDoc
make translations-ja

# 4. Verify translated files created
ls translations/ja/modules/administration/pages/

# 5. Build Japanese HTML
make antora-mlm-ja

# 6. Review Japanese site
firefox build/ja/index.html

# 7. Build Japanese PDFs
make pdf-all-mlm-ja

# 8. Verify PDFs
evince build/ja/pdf/suse_multi_linux_manager_administration_guide.pdf
```

**Time:** 15-30 minutes (all Japanese translations)

### Workflow 7: Add New Language

**Scenario:** Adding Czech (cs) language support.

```bash
# 1. Edit parameters.yml
vim parameters.yml

# Add Czech to languages section:
languages:
  cs:
    locale: cs_CZ.UTF-8
    pdf_theme: suse
    date_format: "%-d. %B %Y"
    display_name: "Čeština"
    flag_icon: czech
    flag_class: czech

# 2. Regenerate Makefiles
make configure

# 3. Verify new Makefile created
ls Makefile.cs

# 4. Create PO directories (if not from Weblate)
mkdir -p l10n-weblate/administration/cs/
# ... for all modules

# 5. Apply empty translations (creates structure)
make translations-cs

# 6. Add Czech flag icon
cp czech-flag.svg branding/supplemental-ui/mlm/img/czech.svg

# 7. Add Czech to language selector
# Edit Makefile to add Czech language selector call

# 8. Test build
make antora-mlm-cs

# 9. View result
firefox build/cs/index.html
```

**Time:** 1-2 hours (includes testing)

### Workflow 8: Translation Statistics

**Scenario:** Check translation completion status.

```bash
# 1. Check PO file statistics (msgfmt)
for po in l10n-weblate/administration/ja/*.po; do
    echo "=== $po ==="
    msgfmt --statistics "$po" 2>&1
done

# Example output:
# === l10n-weblate/administration/ja/actions.adoc.po ===
# 45 translated messages, 3 fuzzy translations, 2 untranslated messages.

# 2. Generate report for all modules
for module in ROOT administration client-configuration reference; do
    echo "=== $module ==="
    for po in l10n-weblate/$module/ja/*.po; do
        msgfmt --statistics "$po" 2>&1 | grep -oP '\d+ translated'
    done
done

# 3. Find untranslated strings
for po in l10n-weblate/administration/ja/*.po; do
    msggrep --no-wrap --untranslated "$po" -o /tmp/untranslated.po
    if [ -s /tmp/untranslated.po ]; then
        echo "Untranslated in: $po"
        msgcat --no-wrap /tmp/untranslated.po | grep '^msgid' | head -5
    fi
done
```

---

## Release Workflows

### Workflow 9: Full Release Build (All Languages)

**Scenario:** Building documentation for official release.

```bash
#!/bin/bash
set -e  # Exit on error

echo "=== Starting full release build ==="

# 1. Verify clean state
make clean
make configure

# 2. Extract latest strings
echo "=== Extracting POT files ==="
make pot

# 3. Apply all translations
echo "=== Applying translations ==="
make translations

# 4. Build HTML for all languages (MLM)
echo "=== Building MLM HTML ==="
make antora-mlm-en
make antora-mlm-ja
make antora-mlm-zh_CN
make antora-mlm-ko

# 5. Build HTML for all languages (Uyuni)
echo "=== Building Uyuni HTML ==="
make antora-uyuni-en
make antora-uyuni-ja

# 6. Build PDFs for all languages (MLM)
echo "=== Building MLM PDFs ==="
make pdf-all-mlm-en
make pdf-all-mlm-ja
make pdf-all-mlm-zh_CN
make pdf-all-mlm-ko

# 7. Build PDFs for all languages (Uyuni)
echo "=== Building Uyuni PDFs ==="
make pdf-all-uyuni-en
make pdf-all-uyuni-ja

# 8. Validate all builds
echo "=== Validating builds ==="
make validate-mlm-en
make validate-uyuni-en

# 9. Create packages
echo "=== Creating packages ==="
make obs-packages-mlm-en
make obs-packages-mlm-ja
make obs-packages-mlm-zh_CN
make obs-packages-mlm-ko
make obs-packages-uyuni-en
make obs-packages-uyuni-ja

# 10. Verify packages
echo "=== Verifying packages ==="
ls -lh build/packages/

echo "=== Build complete ==="
```

**Time:** 2-4 hours (all languages, all products, all formats)

**Output:** 
- HTML sites: `build/en/`, `build/ja/`, `build/zh_CN/`, `build/ko/`
- PDF files: `build/*/pdf/*.pdf`
- Packages: `build/packages/*.tar.gz`

### Workflow 10: Hotfix Release

**Scenario:** Critical fix needed in production documentation.

```bash
# 1. Create hotfix branch
git checkout -b hotfix/security-update production

# 2. Make minimal change
vim modules/administration/pages/security.adoc

# 3. Quick validation
make pot
make translations-en
make antora-mlm-en
make validate-mlm-en

# 4. Build only affected language
make pdf-administration-mlm-en

# 5. Create package
make obs-packages-mlm-en

# 6. Commit and tag
git add .
git commit -m "Security documentation hotfix"
git tag -a v4.3.1-hotfix -m "Security update"

# 7. Push
git push origin hotfix/security-update
git push origin v4.3.1-hotfix

# 8. Deploy immediately
./deploy-hotfix.sh build/packages/susemanager-docs_en.tar.gz

# 9. Merge back to main
git checkout main
git merge hotfix/security-update
git push
```

**Time:** 30 minutes - 1 hour

---

## Troubleshooting Workflows

### Workflow 11: Debugging Build Failures

**Scenario:** Build fails with unclear error.

```bash
# 1. Enable verbose output
make antora-mlm-en V=1 2>&1 | tee build.log

# 2. Check for common issues

# Missing files
grep "File not found" build.log
grep "No such file" build.log

# Syntax errors
grep "ERROR" build.log
grep "WARN" build.log

# Broken xrefs
make validate-mlm-en 2>&1 | tee validate.log

# 3. Verify prerequisites
which antora
which asciidoctor-pdf
npm list -g @antora/cli

# 4. Check file permissions
ls -la translations/en/modules/*/pages/

# 5. Verify branding files
ls -la translations/en/branding/

# 6. Clean and retry
make clean-en
make translations-en
make branding-mlm-en
make antora-mlm-en

# 7. If still failing, check specific module
cd translations/en
npx antora mlm-site.yml --stacktrace
```

### Workflow 12: Fixing Broken Cross-References

**Scenario:** Validation reports broken xrefs.

```bash
# 1. Run validation
make validate-mlm-en 2>&1 | tee xref-errors.log

# Example output:
# modules/admin/pages/actions.adoc:45 → xref:missing.adoc[Link]

# 2. Find the broken reference
grep -n "missing.adoc" modules/administration/pages/actions.adoc

# 3. Determine correct reference
find modules/administration/pages/ -name "*.adoc" | grep -i missing

# 4. Fix the reference
vim modules/administration/pages/actions.adoc
# Change: xref:missing.adoc[Link]
# To: xref:actual-file.adoc[Link]

# 5. Verify fix
make validate-mlm-en

# 6. Rebuild and test
make clean-en
make antora-mlm-en
firefox build/en/docs/administration/actions.html
```

### Workflow 13: PDF Font Issues (CJK)

**Scenario:** Japanese/Chinese/Korean PDFs have missing characters.

```bash
# 1. Verify font files exist
ls -l branding/pdf/fonts/ | grep -i noto

# Should see:
# NotoSans-Bold.ttf
# NotoSans-BoldItalic.ttf
# NotoSans-Italic.ttf
# NotoSans-Regular.ttf
# NotoSansMono-Bold.ttf
# NotoSansMono-Regular.ttf
# NotoSerifCJK-Bold.ttc
# NotoSerifCJK-Regular.ttc

# 2. Verify fonts copied to translation directory
ls -l translations/ja/branding/pdf/fonts/

# 3. If missing, re-copy branding
make clean-branding-ja
make branding-mlm-ja

# 4. Verify PDF theme references fonts correctly
cat branding/pdf/themes/suse-jp.yml | grep font

# Should see:
# font:
#   catalog:
#     NotoSans:
#       ...
#     NotoSerifCJK:
#       ...

# 5. Test PDF generation with debug
cd translations/ja
asciidoctor-pdf \
  -a pdf-fontsdir=branding/pdf/fonts \
  -a pdf-theme=suse-jp \
  -a scripts=cjk \
  modules/administration/nav-administration-guide.pdf.ja.adoc \
  --trace

# 6. If successful, rebuild via make
cd ../..
make pdf-administration-mlm-ja
```

### Workflow 14: Language Selector Not Showing

**Scenario:** Language selector buttons missing in HTML.

```bash
# 1. Check supplemental UI file
cat translations/en/branding/supplemental-ui/mlm/partials/header-content.hbs | grep LANGUAGESELECTOR

# Should contain:
# <!-- LANGUAGESELECTOR -->

# 2. Check if language selector was added
cat translations/en/branding/supplemental-ui/mlm/partials/header-content.hbs | grep "selectLanguage"

# Should see JavaScript language selector code

# 3. If missing, check Makefile has language selector calls
grep "enable-mlm-html-language-selector" Makefile

# Should see multiple calls for each language

# 4. Clean and rebuild with fresh branding
make clean-branding-en
make clean-en
make branding-mlm-en
make antora-mlm-en

# 5. Verify in browser
firefox build/en/index.html
# Check top-right corner for language flags
```

---

## CI/CD Integration

### Workflow 15: GitHub Actions Pipeline

**Scenario:** Automated builds on every push.

```yaml
# .github/workflows/build-docs.yml
name: Build Documentation

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
    
    - name: Setup Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: '3.0'
    
    - name: Install dependencies
      run: |
        npm install -g @antora/cli @antora/site-generator-default
        gem install asciidoctor-pdf rouge
        sudo apt-get update
        sudo apt-get install -y po4a
        pip3 install jinja2
    
    - name: Configure build
      run: make configure
    
    - name: Validate style
      run: make checkstyle-en
    
    - name: Build HTML
      run: make antora-mlm-en
    
    - name: Validate links
      run: make validate-mlm-en
    
    - name: Build PDFs
      run: make pdf-all-mlm-en
    
    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: documentation
        path: |
          build/en/**
```

### Workflow 16: Jenkins Pipeline

**Scenario:** Enterprise CI/CD with Jenkins.

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    stages {
        stage('Setup') {
            steps {
                sh 'make configure'
            }
        }
        
        stage('Validate') {
            parallel {
                stage('Style Check') {
                    steps {
                        sh 'make checkstyle-en'
                    }
                }
                stage('Link Validation') {
                    steps {
                        sh 'make validate-mlm-en'
                    }
                }
            }
        }
        
        stage('Build HTML') {
            steps {
                sh 'make antora-mlm-en'
                sh 'make antora-uyuni-en'
            }
        }
        
        stage('Build PDFs') {
            steps {
                sh 'make pdf-all-mlm-en'
                sh 'make pdf-all-uyuni-en'
            }
        }
        
        stage('Package') {
            steps {
                sh 'make obs-packages-mlm-en'
                sh 'make obs-packages-uyuni-en'
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh './deploy-to-obs.sh'
            }
        }
    }
    
    post {
        always {
            archiveArtifacts artifacts: 'build/packages/*.tar.gz'
            publishHTML target: [
                reportDir: 'build/en',
                reportFiles: 'index.html',
                reportName: 'Documentation'
            ]
        }
    }
}
```

---

## Performance Optimization

### Workflow 17: Parallel Builds

**Scenario:** Speed up builds using parallel make.

```bash
# Build multiple languages in parallel
make -j4 antora-mlm-en antora-mlm-ja antora-mlm-zh_CN antora-mlm-ko

# Build multiple PDFs in parallel
make -j4 \
  pdf-administration-mlm-en \
  pdf-client-configuration-mlm-en \
  pdf-reference-mlm-en \
  pdf-retail-mlm-en

# CAUTION: Don't parallelize MLM and Uyuni builds
# They both modify antora.yml and will conflict

# Safe parallel build:
make -j4 antora-mlm-en antora-mlm-ja  # OK - same product
make -j2 antora-mlm-en antora-uyuni-en  # DANGEROUS - different products
```

**Speed Improvement:** 2-4x faster with `-j4` on quad-core CPU

### Workflow 18: Incremental Builds

**Scenario:** Only rebuild what changed.

```bash
# 1. Find what changed
git diff --name-only HEAD~1 HEAD

# Example output:
# modules/administration/pages/actions.adoc

# 2. Determine affected builds
# Changed file in: modules/administration/
# Affects: HTML build (all pages linked)
# Affects: PDF - administration guide only

# 3. Rebuild only affected artifacts
make clean-en
make antora-mlm-en  # Full rebuild needed (Antora rebuilds all)
make pdf-administration-mlm-en  # Only one PDF needed

# 4. Skip unaffected builds
# No need to rebuild:
# - Other language translations (if only English changed)
# - Other PDF guides
# - Uyuni build (if only MLM content changed)
```

---

## Related Documentation

- [BUILD_SYSTEM_OVERVIEW.md](BUILD_SYSTEM_OVERVIEW.md) - System architecture
- [BUILD_VARIABLES.md](BUILD_VARIABLES.md) - Configuration reference
- [BUILD_FUNCTIONS.md](BUILD_FUNCTIONS.md) - Make function reference
- [BUILD_TARGETS.md](BUILD_TARGETS.md) - Make target reference
- [TRANSLATION_SYSTEM.md](TRANSLATION_SYSTEM.md) - Translation details

---

**Last Updated:** October 20, 2025
