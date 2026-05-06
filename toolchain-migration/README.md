# Toolchain Migration

Tracking the replacement of the GNU Make + Python + Jinja2 build system with Go + Task.

## What is changing

| Concern | Current | New |
|---|---|---|
| Build orchestration | GNU Make + per-language `Makefile.*` files | `Taskfile.yml` (single file) |
| Config generation | Python `configure` script + Jinja2 `*.j2` templates | Go binary (`cmd/docbuild/`) |
| Product/language config | `parameters.yml` + 6 `*.j2` templates | `config.yml` (single file) |
| English source path | `modules/` | `en/modules/` |
| HTML build | Antora 3.1.5 | Antora (latest) |
| PDF build | Asciidoctor-PDF | Asciidoctor-PDF (latest) |

## What is NOT changing

- `branding/` — all UI bundles, supplemental UI, PDF themes, and fonts are untouched
- `l10n-weblate/` — all `.po`, `.pot`, and `.cfg` files are untouched (see note on `update-cfg-files` below)
- `extensions/` — xref-converter.rb stays as-is
- `modules/` content — only the directory is renamed to `en/modules/`; file content is unchanged
- `translations/` — still the output directory for non-English builds during this migration

## Output targets

Four named HTML output targets replace the current product-switching-via-sed approach:

| Target | Product | Supplemental UI | OBS packaged |
|---|---|---|---|
| `uyuni-website` | Uyuni | `uyuni-2023` | Yes |
| `uyuni-webui` | Uyuni | `uyuni-2023` | Yes |
| `mlm-dsc` | MLM | `susecom-2025` | No |
| `mlm-webui` | MLM | `webui-2025` | Yes |

## Languages

Active: `en`, `ja`, `ko`, `zh_CN`. Adding a new language is a single entry in `config.yml`.

## Quick start

### Option A — Container (recommended, only requires Podman or Docker)

```bash
# Build the image once
task container:build

# Publish builds
task container:publish:dsc         # Full MLM publish — HTML + PDFs + zips
task container:publish:uyuni       # Full Uyuni publish — HTML + PDFs + zips
task container:publish:webui-mlm   # MLM WebUI publish
task container:publish:webui-uyuni # Uyuni WebUI publish

# Individual targets
task container:build:mlm-dsc
task container:pdf:mlm
task container:obs:mlm
task container:obs:uyuni

# Interactive shell
task container:shell
```

### Option B — Local toolchain (Go + Task + Antora + Asciidoctor-PDF)

```bash
# First-time setup
task setup    # Build the Go docbuild binary
task gen      # Regenerate Antora/site configs from config.yml

# Publish builds
task publish:dsc          # Full MLM publish — HTML + PDFs + zips
task publish:uyuni        # Full Uyuni publish
task publish:webui-mlm    # MLM WebUI publish
task publish:webui-uyuni  # Uyuni WebUI publish

# Individual targets
task build:mlm-dsc
task pdf:mlm
task obs:mlm
task obs:uyuni
task validate:mlm

task clean    # Remove build/, translations/, .cache/
```

Run `task --list` to see all 25 user-facing targets.

## Repository layout

```
en/modules/                  ← English AsciiDoc source (moved from modules/)
translations/{lang}/modules/ ← Generated translated AsciiDoc (unchanged)
branding/                    ← UI bundles, PDF themes (unchanged)
l10n-weblate/                ← Weblate .po/.pot/.cfg files (unchanged)
scripts/                     ← enforcing_checkstyle, find_unused, make_pot.sh, use_po.sh
legacy-toolchain/            ← Old Makefile*, *.j2, configure, parameters.yml (preserved)
config.yml                   ← Single build configuration file
Taskfile.yml                 ← All build targets
Dockerfile.custom            ← uyuni-docs-builder image (published to ghcr.io/uyuni-project/)
cmd/docbuild/                ← Go binary source
  main.go
go.mod
go.sum
build/                       ← Build output
  {lang}/                    ← HTML per language
  pdf/{lang}/                ← Collected PDFs
  packages/                  ← OBS tarballs
```

## Note on l10n-weblate/update-cfg-files

After `modules/` is renamed to `en/modules/`, the `update-cfg-files` script needs a one-line
path update so it continues to correctly track added/renamed AsciiDoc files. This is routine
maintenance of the cfg files, not a translation data change. See ROADMAP.md Phase 4.

## Documents in this directory

| File | Purpose |
|---|---|
| `README.md` | This file — overview and quick start |
| `GOALS.md` | Goals, non-goals, and success criteria |
| `ARCHITECTURE.md` | Go binary design, `config.yml` schema, Task target reference |
| `ROADMAP.md` | Phased implementation plan |
| `PROGRESS.md` | Living checklist — updated as work lands |
