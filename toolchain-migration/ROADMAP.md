# Roadmap

## Phase 1 — Foundation ✦ current

**Goal:** Planning documents in place, Go module scaffolded, `config.yml` written.

- [ ] Create `toolchain-migration/` planning documents (README, GOALS, ARCHITECTURE, ROADMAP, PROGRESS)
- [ ] Initialise Go module at repo root (`go.mod`, `go.sum`)
- [ ] Create `cmd/docbuild/` directory structure
- [ ] Write `config.yml` replacing `parameters.yml`
- [ ] Verify `config.yml` covers all attributes currently in `site.yml` and `parameters.yml`

**Exit criteria:** `go build ./cmd/docbuild/` succeeds (even if binary does nothing yet).

---

## Phase 2 — Config generation

**Goal:** Go binary generates all config files that the Python + Jinja2 layer currently produces.

- [ ] Implement `internal/config` — load and validate `config.yml`
- [ ] Implement `gen-antora` — generate `translations/{lang}/antora.yml` per product + language
- [ ] Implement `gen-site` — generate `translations/{lang}/{output}.site.yml` per output-target + language
  - Canonical URL written directly (e.g. `https://documentation.suse.com/multi-linux-manager/5.2/ja/`)
  - Content source path, start_path, output dir all computed from config — no sed needed
- [ ] Implement `gen-entities` — generate `branding/pdf/entities.adoc` per product + language
- [ ] Implement `gen-all` subcommand running the above for all configured languages
- [ ] Write embedded Go templates (`templates/*.tmpl`)
- [ ] Diff generated output against current Jinja2 output to verify correctness

**Exit criteria:** `docbuild gen-all` produces files equivalent to running the current `configure` script.

---

## Phase 3 — Task build system

**Goal:** `Taskfile.yml` fully replaces all `Makefile*` files.

- [ ] Write `Taskfile.yml` with `task setup` (builds Go binary)
- [ ] Implement `task gen` (calls `docbuild gen-all`)
- [ ] Implement `task build:{output}` for all four output targets
  - Copies branding, injects language selector (via `docbuild inject-lang-selector`)
  - Runs `npx antora` with correct environment (`DOCSEARCH_ENABLED`, `LANG`, `LC_ALL`)
- [ ] Implement `task build:all`
- [ ] Implement `task pdf:{book}:{product}:{lang}` — single book
  - Correct PDF theme per product + language (CJK themes for ja, ko, zh_CN)
  - `scripts=cjk` attribute for CJK languages
  - Locale-formatted revdate via `date` command
  - xref-converter.rb extension
- [ ] Implement `task pdf:mlm`, `task pdf:uyuni`, `task pdf:all`
- [ ] Implement `task obs:mlm`, `task obs:uyuni`
  - HTML tar.gz: `{obs_name}_{lang}.tar.gz`
  - PDF tar.gz: `{obs_name}_{lang}-pdf.tar.gz`
  - PDF zip: `{tar_name}_{lang}-pdf.zip`
  - All output to `build/packages/`
- [ ] Implement `task validate:{product}`
- [ ] Implement `task translations` (calls `use_po.sh`)
- [ ] Implement `task clean`
- [ ] Verify all Task targets produce equivalent output to their Make counterparts

**Exit criteria:** Full build with Taskfile produces identical output to the current Makefile build.

---

## Phase 4 — Content migration

**Goal:** English source moves to `en/modules/`; build system references updated.

- [ ] Rename `modules/` → `en/modules/`
- [ ] Update `config.yml` content source path to `en/modules/`
- [ ] Update generated `antora.yml` nav paths to `en/modules/`
- [ ] Update `l10n-weblate/update-cfg-files` scan path: `modules/$GUIDE/` → `en/modules/$GUIDE/`
- [ ] Run `l10n-weblate/update-cfg-files` to regenerate `.cfg` file entries
- [ ] Verify `.cfg` files correctly reflect new paths
- [ ] Verify `make_pot.sh` and `use_po.sh` still work with updated paths (smoke test)
- [ ] Full build test with `task build:all`

**Exit criteria:** All four HTML outputs and all PDF builds succeed from `en/modules/`.

---

## Phase 5 — Testing and validation

**Goal:** All 4 output targets × 4 languages × HTML + PDF validated.

### HTML builds
- [ ] `task build:mlm-dsc` — all 4 languages, susecom-2025 branding
- [ ] `task build:mlm-webui` — all 4 languages, webui-2025 branding, language selector present
- [ ] `task build:uyuni-website` — all 4 languages
- [ ] `task build:uyuni-webui` — all 4 languages, language selector present

### PDF builds
- [ ] MLM: all 8 books × en, ja (suse-jp), ko (suse-ko), zh_CN (suse-sc)
- [ ] Uyuni: all 8 books × en, ja (uyuni-jp), ko (uyuni-ko), zh_CN (uyuni-sc)

### OBS packaging
- [ ] `task obs:mlm` — correct tar.gz + zip in `build/packages/` for all 4 languages
- [ ] `task obs:uyuni` — correct tar.gz + zip in `build/packages/` for all 4 languages

### Compatibility
- [ ] Weblate/po4a smoke test — `make_pot.sh` and `use_po.sh` still function
- [ ] Confirm `l10n-weblate/` is byte-for-byte unchanged (except `.cfg` paths from Phase 4)

**Exit criteria:** All items above pass.

---

## Phase 6 — Cleanup

**Goal:** Remove all old toolchain files.

- [ ] Remove `configure` (Python script)
- [ ] Remove `Makefile`, `Makefile.en`, `Makefile.ja`, `Makefile.ko`, `Makefile.zh_CN`
- [ ] Remove `Makefile.j2`, `Makefile.lang`, `Makefile.lang.target`, `Makefile.lang.target.j2`
- [ ] Remove `Makefile.section.functions`, `Makefile.section.functions.j2`
- [ ] Remove `site.yml.j2`, `site.yml.common.j2`, `antora.yml.j2`
- [ ] Remove `entities.adoc.j2`, `entities.specific.adoc.j2`
- [ ] Remove `parameters.yml`
- [ ] Update `Dockerfile.custom` — bump to latest Antora, add Go build stage
- [ ] Update `README.adoc` build instructions
- [ ] Final full build verification after cleanup

**Exit criteria:** Repo builds cleanly with only Go + Task. No Python, no Make, no Jinja2.

---

## Deferred (out of scope for this migration)

- **`lang="en"` HTML attribute** — UI bundle hardcodes `lang="en"` in the HTML element; fixing
  requires UI bundle changes.
- **po4a removal** — `make_pot.sh`, `use_po.sh`, and `l10n-weblate/*.cfg` are untouched until
  the AI translation tool is fully operational and Weblate native AsciiDoc workflow is verified.
- **Per-language source directories** (`ja/modules/`, `ko/modules/` etc.) — future state once AI
  translation tool integration model is confirmed.
- **Uyuni WebUI distinct stylesheet** — currently both `uyuni-website` and `uyuni-webui` share
  `uyuni-2023`. A separate `uyuni-webui-2025` supplemental UI is a future UI task.
