# Architecture

## Overview

```
l10n-weblate/{lang}.po
    │
    ▼
scripts/use_po.sh  (po4a)
    │  reads l10n-weblate/*.cfg
    │  applies .po files to en/modules/**
    │
    └──► translations/{lang}/modules/**/*.adoc   (translated AsciiDoc)

en/modules/**/*.adoc  ──► cp -an (no-clobber fallback for untranslated pages)
    │
    ▼
translations/{lang}/modules/**/*.adoc  (translated + English fallback)

config.yml
    │
    ▼
cmd/docbuild/main.go  (Go binary)
    │  reads config.yml
    │  renders Go text/templates
    │
    ├──► translations/{lang}/{output}.site.yml   (per output-target, per language)
    ├──► translations/{lang}/antora.yml          (per product, per language)
    ├──► translations/{lang}/branding/pdf/entities.adoc  (per product, per language)
    ├──► translations/{lang}/modules/{book}/nav-{book}-guide.pdf.{lang}.adoc
    └──► .bin/xref-converter.rb                 (embedded Ruby extension)
                                  │
                                  ▼
                           Taskfile.yml
                               │
               ┌───────────────┼──────────────────┐
               ▼               ▼                  ▼
            antora      asciidoctor-pdf         zip/tar
           (HTML)           (PDF)            (OBS packages)
    translations/{lang}/   build/{lang}/pdf/   build/packages/
    {output}.site.yml      {product}_{book}_guide.pdf
```

### HTML build pipeline (`build:mlm-dsc`, `build:uyuni-website`, etc.)

```
task build:mlm-dsc
  1. task setup      → compile .bin/docbuild from Go source
  2. task translations → po4a: l10n-weblate/*.po → translations/{lang}/modules/
  3. for each LANG:
       docbuild gen-site    → translations/{lang}/mlm-dsc.site.yml
       docbuild gen-antora  → translations/{lang}/antora.yml
       cp -an en/modules/.  → translations/{lang}/modules/ (English fallback, no-clobber)
       antora               → build/{lang}/   (HTML output)
```

### PDF build pipeline (`pdf:mlm`, `pdf:uyuni`)

```
task pdf:mlm
  1. task gen        → setup + docbuild gen-all + write .bin/xref-converter.rb
  2. task translations → po4a: l10n-weblate/*.po → translations/{lang}/modules/
  3. for each LANG × BOOK:
       cp -an en/modules/.            → translations/{lang}/modules/ (fallback)
       docbuild gen-pdf-nav           → nav-{book}-guide.pdf.{lang}.adoc
       docbuild gen-entities          → translations/{lang}/branding/pdf/entities.adoc
       asciidoctor-pdf (theme={lang}) → build/{lang}/pdf/{product}_{book}_guide.pdf
```

### Publish pipeline (`publish:dsc`, `publish:uyuni`)

```
task publish:dsc
  1. task build:mlm-dsc     → HTML for all languages (includes translations)
  2. task pdf:mlm           → PDFs for all languages (includes translations, cached)
  3. task pdf-collect:mlm   → build/{lang}/pdf/ → build/pdf/{lang}/
  4. task pdf-zip:mlm       → build/pdf/{lang}/ → build/{lang}/*-pdf.zip
```

## config.yml schema

```yaml
# Global AsciiDoc attributes shared across all products and languages
asciidoc:
  attributes:
    saltversion: '3006.0'
    postgresql-version: 16
    # ... all shared attributes from current site.yml

# Product definitions
products:
  mlm:
    antora:
      name: docs
      title: SUSE Multi-Linux Manager Guides
    asciidoc:
      attributes:
        productname: SUSE Multi-Linux Manager
        productnumber: "5.2 Beta 2"
        mlm-content: true
        uyuni-content: false
        # ... product-specific attributes
    sections:
      - installation-and-upgrade
      - client-configuration
      - administration
      - reference
      - retail
      - common-workflows
      - specialized-guides
      - legal
    pdf:
      tar_name: suse-multi-linux-manager-docs   # → suse-multi-linux-manager-docs_{lang}-pdf.zip
      obs_name: susemanager-docs                # → susemanager-docs_{lang}.tar.gz
    ui:
      bundle: ./branding/default-ui/mlm/ui-bundle.zip
    # Per output-target site configuration
    outputs:
      mlm-dsc:
        site:
          title: SUSE Multi-Linux Manager 5.2 Documentation
          url: https://documentation.suse.com/multi-linux-manager/5.2/
          start_page: docs::index.adoc
        supplemental_files: ./branding/supplemental-ui/mlm/susecom-2025
        language_selector: false
        obs: false
      mlm-webui:
        site:
          title: SUSE Multi-Linux Manager 5.2 Documentation
          url: /
          start_page: docs::index.adoc
        supplemental_files: ./branding/supplemental-ui/mlm/webui-2025
        language_selector: true
        obs: true

  uyuni:
    antora:
      name: uyuni
      title: Uyuni 2026.04
    asciidoc:
      attributes:
        productname: Uyuni
        productnumber: "2026.04"
        mlm-content: false
        uyuni-content: true
    sections:
      - installation-and-upgrade
      - client-configuration
      - administration
      - reference
      - retail
      - common-workflows
      - specialized-guides
      - legal
    pdf:
      tar_name: uyuni-docs
      obs_name: uyuni-docs
    ui:
      bundle: ./branding/default-ui/uyuni/ui-bundle.zip
    outputs:
      uyuni-website:
        site:
          title: Uyuni Documentation
          url: https://www.uyuni-project.org/uyuni-docs/
          start_page: uyuni::index.adoc
        supplemental_files: ./branding/supplemental-ui/uyuni/uyuni-2023
        language_selector: false
        obs: true
      uyuni-webui:
        site:
          title: Uyuni Documentation
          url: /
          start_page: uyuni::index.adoc
        supplemental_files: ./branding/supplemental-ui/uyuni/uyuni-2023
        language_selector: true
        obs: true

# Active languages — add a new block here to enable a new language
languages:
  - code: en
    locale: en_US.utf8
    date_format: "%B %d %Y"
    pdf_theme:
      mlm: suse
      uyuni: uyuni

  - code: ja
    locale: ja_JP.UTF-8
    date_format: "%Y年%m月%e日"
    pdf_theme:
      mlm: suse-jp
      uyuni: uyuni-jp
    cjk: true
    flag_svg: jaFlag
    nation: japan
    label: 日本語

  - code: zh_CN
    locale: zh_CN.UTF-8
    date_format: "%Y年%m月%e日"
    pdf_theme:
      mlm: suse-sc
      uyuni: uyuni-sc
    cjk: true
    flag_svg: china
    nation: china
    label: 中文

  - code: ko
    locale: ko_KR.UTF-8
    date_format: "%Y년%m월%e일"
    pdf_theme:
      mlm: suse-ko
      uyuni: uyuni-ko
    cjk: true
    flag_svg: koFlag
    nation: korea
    label: 한국어

# Antora extensions (applied to all builds)
antora:
  extensions:
    - '@antora/lunr-extension'

# AsciiDoc extensions (applied to all builds)
asciidoc_extensions:
  - '@asciidoctor/tabs'
```

## Go binary — cmd/docbuild/

**Entry point:** `cmd/docbuild/main.go`

**Subcommands:**

| Command | Output | Replaces |
|---|---|---|
| `docbuild gen-all [-content-dir <dir>]` | All configs for all languages | `configure` Python script |
| `docbuild gen-site -product <p> -output <o> -lang <code>` | `translations/{lang}/{output}.site.yml` | `site.yml.j2` + sed block in `Makefile.j2` |
| `docbuild gen-antora -product <p> -lang <code> [-content-dir <dir>]` | `translations/{lang}/antora.yml` | `antora.yml.j2` |
| `docbuild gen-entities -product <p> -lang <code>` | `translations/{lang}/branding/pdf/entities.adoc` | `entities.adoc.j2` + `entities.specific.adoc.j2` |
| `docbuild gen-pdf-nav -book <b> -lang <code> -dir <path>` | `{path}/nav-{book}-guide.pdf.{lang}.adoc` | PDF nav generation in `Makefile.section.functions` |
| `docbuild inject-lang-selector -hbs <path>` | Modifies `header-content.hbs` in-place with language selector | Language selector inject in `Makefile.j2` |
| `docbuild collect-pdfs -product <p> [-src <path>] [-dest <path>] [-langs "<list>"]` | Moves `build/{lang}/pdf/` → `build/pdf/{lang}/` | `cleanup_pdfs.sh` |

**Dependencies:** Go stdlib + `gopkg.in/yaml.v3` only.

**Templates:** Embedded inline in `internal/generate/templates.go` via `//go:embed`.

**xref-converter.rb:** Embedded as a Go const in `internal/generate/xrefext.go`; written to `.bin/xref-converter.rb` at gen time. The `extensions/` directory is no longer needed at runtime.

## Taskfile.yml — target reference

```
task setup                         Build the Go binary (.bin/docbuild)
task gen                           Run docbuild gen-all + write .bin/xref-converter.rb
task translations                  Run use_po.sh (po4a) → translations/{lang}/modules/

task build:mlm-dsc                 MLM HTML — documentation.suse.com branding (all languages)
task build:mlm-webui               MLM HTML — WebUI branding with language selector (all languages)
task build:uyuni-website           Uyuni HTML — website branding (all languages)
task build:uyuni-webui             Uyuni HTML — WebUI branding with language selector (all languages)
task build:all                     All four HTML output targets (sequential)

task pdf BOOK=<b> PRODUCT=<p> LANG=<l>   Single book PDF
task pdf:mlm                       All 8 books × 4 languages — MLM (runs translations first)
task pdf:uyuni                     All 8 books × 4 languages — Uyuni (runs translations first)
task pdf:all                       Both products

task publish:dsc                   Full MLM publish — HTML + PDFs + zip archives
task publish:uyuni                 Full Uyuni publish — HTML + PDFs + zip archives
task publish:webui-mlm             MLM WebUI publish — HTML + PDFs + zip archives
task publish:webui-uyuni           Uyuni WebUI publish — HTML + PDFs + zip archives

task obs:mlm                       OBS packages for MLM → build/packages/
task obs:uyuni                     OBS packages for Uyuni → build/packages/

task validate:mlm                  Antora xref validation — MLM
task validate:uyuni                Antora xref validation — Uyuni

task clean                         Remove build/, translations/, .cache/
```

## Key design decisions

### No sed, no shell string replacement
All config values that previously required sed (canonical URL, start_path, content source path,
supplemental_files) are written directly into the generated YAML by the Go binary. The template
receives the final computed value.

### Language selector injection
The `<!-- LANGUAGESELECTOR -->` comment in `header-content.hbs` is replaced by the Go binary's
`inject-lang-selector` subcommand rather than the Makefile's `sed -n -i` pattern. The binary
operates on the copy of the supplemental UI in `translations/{lang}/` so the originals in
`branding/` are never modified.

### Four output targets as first-class config
Each output target is a named entry under `products.{product}.outputs` in `config.yml`. The
supplemental UI path, site URL, language selector flag, and OBS packaging flag are all explicit
fields — no runtime switching.

### Go module layout
```
go.mod
go.sum
cmd/
  docbuild/
    main.go
internal/
  config/
    config.go        Config struct and YAML loader
  generate/
    site.go          site.yml generator
    antora.go        antora.yml generator
    entities.go      entities.adoc generator
    selector.go      language selector injector
  templates/
    site.yml.tmpl
    antora.yml.tmpl
    entities.adoc.tmpl
```
