# AI Translation Build Migration

Tracking document for migrating uyuni-docs from po4a/Weblate-generated translations to
committed per-language AsciiDoc source trees.

**Related PR:** [uyuni-project/uyuni-docs#5090](https://github.com/uyuni-project/uyuni-docs/pull/5090)

## Goal

Build documentation from committed translation directories at the repo root:

```
en/modules/   ← English source (canonical)
ja/modules/   ← Japanese AI translation
ko/modules/   ← Korean AI translation
zh/modules/   ← Chinese AI translation (build code: zh_CN)
```

The build no longer calls po4a or Weblate automation. Scripts and `l10n-weblate/` remain in
the repo but are not used by the build pipeline.

## Architecture

```
Committed source trees          Build staging (gitignored)       Output (gitignored)
─────────────────────          ──────────────────────────       ───────────────────
en/modules/  ──┐
ja/modules/  ──┼──► task stage-content ──► translations/{lang}/modules/
ko/modules/  ──┤         (en base + lang overlay)
zh/modules/  ──┘

config.yml ──► docbuild gen-* ──► translations/{lang}/antora.yml, *.site.yml, branding/

translations/{lang}/ ──► npx antora ──► build/{lang}/ HTML
translations/{lang}/ ──► asciidoctor-pdf ──► build/{lang}/pdf/
```

### Language code vs content directory

| Build code | Content directory | Notes |
|------------|-------------------|-------|
| `en` | `en/` | English source |
| `ja` | `ja/` | |
| `ko` | `ko/` | |
| `zh_CN` | `zh/` | URLs and build output stay `zh_CN` |

Configured via optional `content_dir` in `config.yml` (defaults to `code` when omitted).

## PR #5090 content status

Initial AI translations from Vistatech cover **3 of 9 Antora components**:

- `administration`
- `client-configuration`
- `installation-and-upgrade`

Missing (filled from English at build time):

- `ROOT`, `reference`, `retail`, `common-workflows`, `specialized-guides`, `legal`
- ~800 assets/pages per language

## What is retained (not removed)

- `l10n-weblate/` — Weblate `.po`, `.pot`, `.cfg` files
- `scripts/make_pot.sh`, `scripts/use_po.sh` — po4a scripts (deprecated in build)
- po4a removed from the builder container image (`Dockerfile.bci`); legacy scripts remain in repo

## What is deprecated

- `task translations`, `task pot` (and container variants)
- `.github/workflows/update_translation_files.yml` push triggers (manual dispatch only)
- `workflow_run` coupling in `build_and_archive_devel_docs.yml`

## Implementation checklist

- [x] Create this tracking file
- [x] Merge PR #5090 `ja/`, `ko/`, `zh/modules/` trees
- [x] Add `content_dir` to `config.yml` and `docbuild get-content-dir`
- [x] Implement `task stage-content`; wire into draft/pdf targets
- [x] Deprecate po4a task targets and Weblate CI workflow
- [x] Container validation: stage-content, draft (en, ja), PDF (ja, ko, zh_CN administration)
- [ ] Full build matrix (all 4 langs × 4 HTML targets, full PDF batch, publish, obs — run in CI)
- [x] Update `docs/toolchain-migration/` and `docs/local-toolchain-setup.md`

## Validation commands

```bash
task setup && task gen
task stage-content
task draft:mlm-dsc LANGUAGES="en ja ko zh_CN"
task pdf BOOK=administration PRODUCT=mlm LANG=ja
task pdf:mlm LANGUAGES="ja ko zh_CN"
task publish:dsc LANGUAGES=en
task validate:mlm LANGUAGES=en
```

### Success criteria

- HTML builds for all 4 languages without po4a installed
- CJK PDFs build (matches `test_pdf_translations.yml`)
- Untranslated sections render English content (fallback)
- Translated pages (e.g. `ja/modules/administration/pages/actions.adoc`) render Japanese

## CI expectations

These workflows should continue working after migration:

- `tests.yml` — PR validation
- `test_pdf_translations.yml` — CJK PDF regression gate
- `build_and_archive_devel_docs.yml` — devel HTML/PDF archives (no longer triggered by po4a commits)
- `build_and_archive_release_docs.yml` — release OBS packages
