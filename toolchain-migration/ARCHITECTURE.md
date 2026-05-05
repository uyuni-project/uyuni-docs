# Architecture

## Overview

```
config.yml
    │
    ▼
cmd/docbuild/main.go  (Go binary)
    │  reads config.yml
    │  renders Go text/templates
    │
    ├──► translations/{lang}/site.yml        (per output-target, per language)
    ├──► translations/{lang}/antora.yml      (per product, per language)
    └──► branding/pdf/entities.adoc          (per product, per language)
                                  │
                                  ▼
                           Taskfile.yml
                               │
                    ┌──────────┼──────────┐
                    ▼          ▼          ▼
                 antora   asciidoctor-pdf  zip/tar
                (HTML)      (PDF)        (OBS packages)
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
| `docbuild gen-site --output <output-target> --lang <code>` | `translations/{lang}/{output}.site.yml` | `Makefile.j2` sed block + `site.yml.j2` |
| `docbuild gen-antora --product <product> --lang <code>` | `translations/{lang}/antora.yml` | `antora.yml.j2` |
| `docbuild gen-entities --product <product> --lang <code>` | `branding/pdf/entities.adoc` | `entities.adoc.j2` + `entities.specific.adoc.j2` |
| `docbuild gen-all` | All of the above for all configured languages | `configure` Python script |
| `docbuild inject-lang-selector --output <output-target> --lang <code>` | Patches `header-content.hbs` in place | `enable-html-language-selector` Make macro |

**Dependencies:** Go stdlib only (`text/template`, `os`, `flag`, `gopkg.in/yaml.v3`).

**Templates** (embedded via `//go:embed`):
- `templates/site.yml.tmpl`
- `templates/antora.yml.tmpl`
- `templates/entities.adoc.tmpl`

## Taskfile.yml — target reference

```
task setup                         Build the Go binary
task gen                           Run docbuild gen-all (regenerate all configs)

task build:mlm-dsc                 HTML for all languages — MLM, DSC branding
task build:mlm-webui               HTML for all languages — MLM, WebUI branding
task build:uyuni-website           HTML for all languages — Uyuni website
task build:uyuni-webui             HTML for all languages — Uyuni WebUI
task build:all                     All four HTML output targets

task pdf:mlm                       All 8 books × 4 languages — MLM
task pdf:uyuni                     All 8 books × 4 languages — Uyuni
task pdf:all                       Both products
task pdf:{book}:{product}:{lang}   Single book  e.g. task pdf:administration:mlm:en

task obs:mlm                       HTML + PDF tarballs for MLM → build/packages/
task obs:uyuni                     HTML + PDF tarballs for Uyuni → build/packages/

task validate:mlm                  Antora validation run — MLM
task validate:uyuni                Antora validation run — Uyuni

task translations                  Run use_po.sh to apply .po files → translations/
task clean                         Remove build/ and translations/
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
