# Goals

## Primary goals

1. **Eliminate the Python + Jinja2 layer** — the `configure` script and all `*.j2` templates are replaced
   by a Go binary that generates the same config files using Go's stdlib `text/template`.

2. **Single build config file** — `config.yml` replaces `parameters.yml` and contains everything:
   products, output targets, languages, PDF themes, branding paths, site URLs.
   No more per-language generated Makefiles.

3. **Single orchestration file** — `Taskfile.yml` replaces `Makefile`, `Makefile.en`, `Makefile.ja`,
   `Makefile.ko`, `Makefile.zh_CN`, `Makefile.lang`, `Makefile.lang.target`,
   and `Makefile.section.functions`.

4. **Trivially extensible languages** — adding a new language is a single block added to the
   `languages:` list in `config.yml`. No template regeneration, no new Makefile fragments.

5. **Canonical URLs generated correctly** — per-language site URLs (e.g.
   `https://documentation.suse.com/multi-linux-manager/5.2/ja/`) are written directly into the
   generated `site.yml` by the Go binary. No sed post-processing.

6. **All four output targets supported** — `uyuni-website`, `uyuni-webui`, `mlm-dsc`, `mlm-webui`
   each have their own supplemental UI and OBS packaging behaviour, driven entirely by `config.yml`.

7. **OBS packaging preserved** — `task obs:mlm` and `task obs:uyuni` produce the same tar.gz
   artifact layout as the current `obs-packages-*` Make targets.

8. **English source at `en/modules/`** — positions the repo for the future AI translation workflow
   where per-language source directories (`ja/modules/`, `ko/modules/`, etc.) will sit alongside it.

## Non-goals

- **Translation workflow changes** — `l10n-weblate/*.po`, `*.pot`, `.cfg` files, `make_pot.sh`,
  and `use_po.sh` are not touched. po4a removal is a separate future project gated on the AI
  translation tool being fully operational.

- **UI bundle changes** — branding directory contents, PDF themes, fonts, and Handlebars templates
  are out of scope.

- **Content changes** — AsciiDoc page content is not modified; only the directory is renamed.

- **New language additions** — the system will support adding languages easily, but no new languages
  are added as part of this migration.

- **`lang="en"` HTML attribute fix** — non-English builds currently get `lang="en"` in the HTML
  element because the UI bundle hardcodes it. Fixing this requires UI bundle changes and is deferred.

## Success criteria

- [x] `task build:mlm-dsc` produces identical HTML output to `make antora-mlm-en` (DSC branding)
- [x] `task build:mlm-webui` produces identical HTML output with `webui-2025` supplemental UI
- [x] `task build:uyuni-website` produces identical HTML output to `make antora-uyuni-en`
- [x] `task pdf:mlm` produces all 8 PDFs for all 4 languages with correct CJK themes
- [x] `task pdf:uyuni` produces all 8 PDFs for all 4 languages with correct CJK themes
- [x] `task obs:mlm` produces `susemanager-docs_{lang}.tar.gz` and `susemanager-docs_{lang}-pdf.tar.gz` in `build/packages/`
- [x] `task obs:uyuni` produces `uyuni-docs_{lang}.tar.gz` and `uyuni-docs_{lang}-pdf.tar.gz` in `build/packages/`
- [x] All non-English HTML builds include the language selector in `header-content.hbs`
- [x] Adding a new language requires only a single entry in `config.yml`
- [x] No Python, no Make, no Jinja2 required on the host (only Go and Task)
- [x] `l10n-weblate/` directory is byte-for-byte identical before and after migration (`.cfg` paths updated for `en/modules/`)

## Additional goals achieved

- [x] Container image `uyuni-docs-builder` — contributors need only Podman/Docker, zero local toolchain
  - Published to `ghcr.io/uyuni-project/uyuni-docs-builder` via `publish_builder_image.yml`
  - `GITHUB_TOKEN` only — no PAT, no stored secrets
  - Image signed and pinned by commit SHA for supply-chain safety
- [x] `task --list` curated — 25 user-facing targets visible, plumbing hidden
- [x] `task container:*` targets — every publish command available via container without local toolchain
- [x] `publish_builder_image.yml` workflow — triggers on `Dockerfile.custom` changes to master; pushes `latest` + `sha-<commit>` tags
