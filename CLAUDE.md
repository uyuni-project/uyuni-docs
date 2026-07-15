# uyuni-docs — Agent Instructions

## Repo nature

AsciiDoc documentation for **Uyuni** and **SUSE Multi-Linux Manager (MLM)**. Not an application.

## Quick commands (Taskfile.yml)

```bash
task                              # show all targets
task setup                        # build the Go toolchain binary (.bin/docbuild)
task gen                          # regenerate site configs and xref-converter (needs setup first)

# Draft HTML preview — container recommended (no local toolchain)
task container:draft:uyuni-website LANGUAGES=en    # Uyuni website branding, English only
task container:draft:mlm-dsc LANGUAGES="en ja"     # MLM documentation.suse.com branding

# Local HTML draft (Go + Antora + asciidoctor-pdf installed)
task draft:uyuni-website LANGUAGES=en

# Single PDF — local toolchain only
task pdf BOOK=administration PRODUCT=uyuni LANG=en

# Validate cross-references
task validate:uyuni
task container:validate:mlm

# Translations
task pot                          # regenerate .pot/.po templates from en/modules
task translations                 # apply .po files → translations/ (generated AsciiDoc)
```

## Content structure

- `en/modules/{book}/` — source AsciiDoc (the only content you should directly edit)
- `l10n-weblate/{book}/` — `.po` translation files (edit these for translations)
- `translations/` — generated, **gitignored**, produced by `task translations`
- `config.yml` — single source of truth: products, languages, Asciidoc attributes, output branding
- `branding/pdf/themes/` and `branding/pdf/fonts/` — PDF styling

## Books (per `config.yml`)

installation-and-upgrade, client-configuration, administration, reference, retail, common-workflows, specialized-guides, legal

## Key constraints

- **Commit signing required** (GPG or SSH) — see CONTRIBUTING.md
- **CHANGELOG.md** — add entry at top for every PR, include bsc# number if applicable
- **Two products**: `mlm` (SUSE Multi-Linux Manager) and `uyuni`
- **Active branches**: `master`, `manager-5.1`, `manager-5.0`, `manager-4.3`
- **Default languages**: en, ja, zh_CN, ko
- Translations fall back to `en/modules/` — do not remove English source content
- Generated files are gitignored: `site.yml`, `antora.yml`, `translations/`, `build/`, `.bin/`
- CJK builds need special locale setup; PDF themes differ per product+language (see `config.yml:languages`)

## Translation workflow

1. Edit `en/modules/{book}/{page}.adoc`
2. `task pot` — update `.pot/.po` templates
3. Translate `.po` files in `l10n-weblate/{book}/`
4. `task translations` — apply `.po` → `translations/{lang}/modules/{book}/`
5. Preview: `task container:draft:uyuni-website LANGUAGES=en`

## Build artifacts

Output lands in `build/{lang}/html/` (HTML) and `build/{lang}/pdf/` (PDF). Both gitignored.
PDF zips go to `build/{lang}/`.

## Go toolchain (docbuild)

`.bin/docbuild` — Go CLI built from `cmd/docbuild/` + `internal/generate/`.
Run `task setup` to build it. All `gen-*` and `pdf` targets depend on it.
Config is parsed from `config.yml` (YAML).

## CI

- `.github/workflows/tests.yml` — general tests
- `.github/workflows/build_and_archive_devel_docs.yml` — build from dev branches
- `.github/workflows/test_pdf_translations.yml` — PDF build tests for translations
- `.github/workflows/update_translation_files.yml` — translation template updates
- `.github/workflows/find_unused_files.yml` — unused file detection
- `.github/workflows/enforced_checkstyle.yml` — content style enforcement

## Code Search

Use `semble search` to find code by describing what it does or naming a symbol/identifier, instead of grep:

​```bash
semble search "authentication flow" ./my-project
semble search "save_pretrained" ./my-project
semble search "save model to disk" ./my-project --top-k 10
​```

Use `semble find-related` to discover code similar to a known location (pass `file_path` and `line` from a prior search result):

​```bash
semble find-related src/auth.py 42 ./my-project
​```

`path` defaults to the current directory when omitted; git URLs are accepted.

If `semble` is not on `$PATH`, use `uvx --from "semble[mcp]" semble` in its place.

## Workflow

1. Start with `semble search` to find relevant chunks.
2. Inspect full files only when the returned chunk is not enough context.
3. Optionally use `semble find-related` with a promising result's `file_path` and `line` to discover related implementations.
4. Use grep only when you need exhaustive literal matches or quick confirmation of an exact string.


