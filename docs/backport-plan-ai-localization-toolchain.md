# Backport Plan: AI Localization Toolchain → master, manager-5.2

**Status:** Draft — for use when backporting from `manager-5.1`  
**Branch this was written from:** `localization-ai-updates-first-commit-jcayouette`  
**Primary landing branch:** `manager-5.1` (5.1 only at time of writing)

---

## Purpose

This document records the **toolchain changes** on the AI localization branch so they can be
backported to `master` and `manager-5.2` later.

It covers build orchestration, config generation, CI, container image, and branding/tooling
updates only.

**It does not cover localized AsciiDoc content.** Translation directories (`ja/`, `ko/`, `zh/`,
`translations/`, `l10n-weblate/`) are **out of scope** for this backport. Localized docs will
be delivered separately by the translation team and committed on each target branch when ready.

For day-to-day migration tracking, see also [L10N-AI-MIGRATION.md](../L10N-AI-MIGRATION.md) and
the [toolchain-migration/](toolchain-migration/) docs.

For the earlier Go + Task migration (Make → `docbuild` + `Taskfile.yml`), see
[backport-plan-legacy-branches.md](backport-plan-legacy-branches.md).

---

## Summary of toolchain changes

The build no longer depends on po4a/Weblate output during `task draft:*`, `task pdf:*`, or
`task publish:*`. Instead:

1. **Committed translation trees** at the repo root (`{content_dir}/modules/`) are merged with
   English at build time.
2. **`task stage-content`** copies `en/modules/` as a base, then overlays
   `{content_dir}/modules/` for non-English languages into gitignored `translations/{lang}/`.
3. **`config.yml`** maps build language codes to content directories (notably `zh_CN` → `zh`).
4. **`docbuild get-content-dir`** resolves the content directory for a language code.
5. **PDF builds** stage from `{content_dir}/modules/` instead of only copying English as fallback.
6. **`task translations`** and **`task pot`** remain as deprecated aliases/warnings; po4a is
   removed from the builder container image.
7. **CI** decouples devel doc archives from Weblate/po4a push automation.
8. **PDF themes and the `task pdf` pipeline** are updated for AI-staged CJK builds (see
   [PDF toolchain changes](#pdf-toolchain-changes) below).
9. **OBS packaging tasks** (`task obs:mlm`, `task obs:uyuni`) inherit the new staging model
   through their dependencies — no separate OBS task edits were required in
   [#5103](https://github.com/uyuni-project/uyuni-docs/pull/5103) (see
   [OBS packaging](#obs-packaging) below).

### Build flow (after migration)

```
en/modules/  ──┐
ja/modules/  ──┼──► task stage-content ──► translations/{lang}/modules/
ko/modules/  ──┤         (en base + lang overlay)
zh/modules/  ──┘

config.yml ──► docbuild gen-* ──► translations/{lang}/antora.yml, *.site.yml, entities

translations/{lang}/ ──► Antora / asciidoctor-pdf ──► build/{lang}/
```

### Language code vs content directory

| Build code | Content directory (`content_dir`) | Notes |
|------------|-----------------------------------|-------|
| `en` | `en` | English source |
| `ja` | `ja` | |
| `ko` | `ko` | |
| `zh_CN` | `zh` | URLs and build output stay `zh_CN` |

---

## PDF toolchain changes

These PDF changes are part of the backport and are required for translated PDF builds to work
with committed `{content_dir}/modules/` trees instead of po4a output under `translations/`.

### `Taskfile.yml` — PDF task pipeline

| Task | Change |
|------|--------|
| `pdf` | Before `gen-pdf-nav`, stages content per language: copies `en/modules/` as base, then overlays `{content_dir}/modules/` via `docbuild get-content-dir`. Replaces the old `cp -an en/modules/.` English-only fallback. |
| `pdf:mlm`, `pdf:uyuni` | Depend on `task stage-content` instead of `task translations` (po4a). |
| `pdf-collect:mlm`, `pdf-collect:uyuni` | Unchanged; still gather `build/{lang}/pdf/` into `build/pdf/{lang}/`. |

Single-book PDF flow (unchanged steps after staging):

1. Resolve theme from `PRODUCT:LANG` (MLM: `suse` / `suse-jp` / `suse-sc` / `suse-ko`; Uyuni: `uyuni` or `uyuni-cjk` for CJK)
2. `docbuild gen-pdf-nav` → `nav-{book}-guide.pdf.{lang}.adoc`
3. `docbuild gen-entities` → `translations/{lang}/branding/pdf/entities.adoc`
4. `asciidoctor-pdf` with `-a scripts=cjk` for ja / zh_CN / ko

CJK locale, date format, and revdate handling in the `pdf` task are unchanged.

### `config.yml` — PDF theme mapping

Each language block includes `pdf_theme.mlm` and `pdf_theme.uyuni` (e.g. `suse-sc` for
`zh_CN` MLM, `uyuni-cjk` for all Uyuni CJK languages). These must stay aligned with the theme
files under `branding/pdf/themes/`.

### PDF theme files (`branding/pdf/themes/`)

Backport the full theme directory delta, not just the MLM CJK files.

| Path | Change |
|------|--------|
| `suse-theme.yml` | Minor YAML/formatting fixes |
| `suse-jp-theme.yml` | CJK font fallback and YAML structure fixes |
| `suse-ko-theme.yml` | CJK font fallback and YAML structure fixes |
| `suse-sc-theme.yml` | CJK font fallback and YAML structure fixes (Simplified Chinese) |
| `uyuni-theme.yml` | English Uyuni theme: font catalog reverted to Free Serif / Montserrat (from SUSE 2025 family on master) |
| `uyuni-cjk-theme.yml` | Shared Uyuni CJK theme for ja, ko, zh_CN; YAML/color fixes |
| `uyuni-jp-theme.yml` | **Deleted** — use `uyuni-cjk` instead |
| `uyuni-ko-theme.yml` | **Deleted** — use `uyuni-cjk` instead |
| `uyuni-sc-theme.yml` | **Deleted** — use `uyuni-cjk` instead |
| `images/salt-flats.png` | **Deleted** |
| `images/uyuni-logo.svg` | **Deleted** |
| `images/uyuni-logo-notext.svg` | **Deleted** |

The `Taskfile.yml` theme selector already maps all Uyuni CJK languages to `uyuni-cjk`:

```yaml
uyuni:ja)    THEME=uyuni-cjk ;;
uyuni:zh_CN) THEME=uyuni-cjk ;;
uyuni:ko)    THEME=uyuni-cjk ;;
```

Do **not** delete the per-language MLM themes (`suse-jp`, `suse-ko`, `suse-sc`); those remain
in use for MLM CJK PDFs.

### PDF CI

| Path | Change |
|------|--------|
| `.github/workflows/test_pdf_translations.yml` | Builds MLM and Uyuni PDFs for `ja`, `ko`, `zh_CN` via `task pdf:mlm` / `task pdf:uyuni` (which now run `stage-content` first). Adds `manager-5.1` to push branches and `if` conditions alongside `master`. |

### PDF-related Go tooling (unchanged on this branch)

These come from the base Go toolchain and do not need separate changes for AI localization,
but the PDF backport is incomplete without them already present on the target branch:

| Path | Role |
|------|------|
| `internal/generate/pdfnav.go` | `docbuild gen-pdf-nav` |
| `cmd/docbuild/main.go` | `gen-entities`, `get-pdf-prefix`, `collect-pdfs` |
| `.bin/xref-converter.rb` | Asciidoctor-PDF xref extension |
| `branding/pdf/fonts/` | Font files referenced by themes (unchanged) |

### PDF validation after backport

```bash
# English smoke test
task pdf BOOK=client-configuration PRODUCT=mlm LANG=en

# CJK — requires translation trees on the branch (or English fallback where missing)
task stage-content LANGUAGES="ja ko zh_CN"
task pdf BOOK=client-configuration PRODUCT=mlm LANG=zh_CN
task pdf:mlm LANGUAGES="ja ko zh_CN"
task pdf-collect:mlm LANGUAGES="ja ko zh_CN"
```

Confirm `test_pdf_translations.yml` passes on the target branch after theme and Taskfile changes
are merged.

---

## OBS packaging

PR [#5103](https://github.com/uyuni-project/uyuni-docs/pull/5103) did **not** change the
`obs:mlm` or `obs:uyuni` task definitions themselves. OBS builds are covered because those tasks
call draft and PDF targets that were updated to use `stage-content`:

| Task | Depends on | Staging path |
|------|------------|--------------|
| `obs:mlm` | `draft:mlm-webui`, `pdf:mlm` | Both run `stage-content` before build |
| `obs:uyuni` | `draft:uyuni-website`, `pdf:uyuni` | Both run `stage-content` before build |

After HTML and PDF builds complete, OBS tasks package the same artifact layout as before:

- MLM: `susemanager-docs_{lang}.tar.gz` (HTML) and `susemanager-docs_{lang}-pdf.tar.gz` (PDFs
  renamed to `suse_multi_linux_manager_*` prefix)
- Uyuni: `uyuni-docs_{lang}.tar.gz` and `uyuni-docs_{lang}-pdf.tar.gz`

Output targets are selected by `config.yml` `outputs.*.obs: true` (`mlm-webui` for MLM,
`uyuni-website` for Uyuni). The `obs_name` fields under `products.*.pdf` are unchanged.

### OBS CI

| Path | Change |
|------|--------|
| `.github/workflows/build_and_archive_release_docs.yml` | **No Taskfile changes needed** — still runs `task obs:mlm` / `task obs:uyuni` on release-branch pushes. Inherits `stage-content` once draft/pdf deps are backported. |

Container wrappers (`container:obs:mlm`, `container:obs:uyuni`) delegate to the same local tasks.

### OBS validation after backport

```bash
# English-only smoke test (works without translation trees)
task obs:mlm LANGUAGES=en
task obs:uyuni LANGUAGES=en

# CJK — requires committed {lang}/modules/ trees on the branch
task obs:mlm LANGUAGES="ja ko zh_CN"
task obs:uyuni LANGUAGES="ja ko zh_CN"
```

Confirm tarballs land in `build/packages/` with the expected names and that CJK HTML/PDF content
inside reflects staged `{content_dir}/modules/` overlays, not po4a output under
`l10n-weblate/`.

---

## What to backport (toolchain only)

Copy or merge these paths from `manager-5.1` (this branch) into `master` and `manager-5.2`.
Treat the list as a manifest; resolve conflicts against each target branch’s existing Go/Task
toolchain (both targets already have the base migration from
[backport-plan-legacy-branches.md](backport-plan-legacy-branches.md)).

### Core build system

| Path | Change |
|------|--------|
| `Taskfile.yml` | Replace `task translations` with `task stage-content` in draft/pdf/publish deps; add `stage-content` task; deprecate `translations` / `pot`; **PDF task stages `{content_dir}/modules/` overlay** (see [PDF toolchain changes](#pdf-toolchain-changes)); **`obs:mlm` / `obs:uyuni` unchanged but inherit staging via draft/pdf deps** (see [OBS packaging](#obs-packaging)) |
| `config.yml` | Add `content_dir` per language block |
| `cmd/docbuild/main.go` | Add `get-content-dir` subcommand |
| `internal/config/config.go` | Add `ContentDir` field and `Language.ContentPath()` helper |
| `L10N-AI-MIGRATION.md` | Root tracking file for the migration (new) |

### Container

| Path | Change |
|------|--------|
| `Dockerfile.bci` | Remove po4a and related Leap repo packages; update header comment |
| `Dockerfile.bookworm` | Align with BCI image (po4a removal) |

### CI / GitHub Actions

| Path | Change |
|------|--------|
| `.github/workflows/update_translation_files.yml` | Mark deprecated; **manual `workflow_dispatch` only**; remove push triggers |
| `.github/workflows/build_and_archive_devel_docs.yml` | Remove `workflow_run` coupling to translation updates; add `manager-5.1` to push branches (adjust per target branch) |
| `.github/workflows/build_and_archive_release_docs.yml` | No obs-task changes — verify `task obs:mlm` / `task obs:uyuni` still run on release branches after draft/pdf staging backport |
| `.github/workflows/test_pdf_translations.yml` | CJK PDF regression for `ja`/`ko`/`zh_CN`; runs `pdf:mlm`/`pdf:uyuni` (with `stage-content`); add target branch to push/`if` conditions |
| `.github/workflows/tests.yml` | PR validation updates |
| `.github/workflows/publish_builder_image.yml` | Builder image without po4a |
| `.github/workflows/enforced_checkstyle.yml` | Path updates (`en/modules/`) |
| `.github/workflows/find_unused_files.yml` | Path updates |

### Branding — HTML supplemental UI

| Path | Change |
|------|--------|
| `branding/supplemental-ui/mlm/susecom-2025/` | Language switcher JS, `langFromUrl.js`, head-meta/title/toolbar partials |

### Branding — PDF themes

See [PDF toolchain changes](#pdf-toolchain-changes) for the full theme file list, deletions, and
`Taskfile.yml` theme mapping. At minimum backport:

| Path | Change |
|------|--------|
| `branding/pdf/themes/suse-theme.yml` | YAML fixes |
| `branding/pdf/themes/suse-jp-theme.yml` | MLM Japanese PDF theme |
| `branding/pdf/themes/suse-ko-theme.yml` | MLM Korean PDF theme |
| `branding/pdf/themes/suse-sc-theme.yml` | MLM Simplified Chinese PDF theme |
| `branding/pdf/themes/uyuni-theme.yml` | English Uyuni PDF theme (font catalog change) |
| `branding/pdf/themes/uyuni-cjk-theme.yml` | Shared Uyuni CJK PDF theme |
| `branding/pdf/themes/uyuni-{jp,ko,sc}-theme.yml` | **Delete** on target branch if present |
| `branding/pdf/themes/images/` | Remove obsolete Uyuni logo assets if deleted on this branch |

### Documentation and housekeeping

| Path | Change |
|------|--------|
| `docs/toolchain-migration/` | Update ARCHITECTURE, GOALS, PROGRESS, README, ROADMAP for `stage-content` |
| `docs/container-setup.md` | Document staged translations |
| `docs/local-toolchain-setup.md` | Remove po4a as build requirement |
| `README.adoc` | Build quick-start updates |
| `CHANGELOG.md` | Record migration entries |
| `.gitignore` | Ignore legacy Makefile fragments from 4.3 branch builds |
| `scripts/find_unused` | Search under `en/modules/` |

---

## What NOT to backport

Do **not** copy these as part of the toolchain backport:

| Path | Reason |
|------|--------|
| `ja/modules/` | Localized content — from translation team |
| `ko/modules/` | Localized content — from translation team |
| `zh/modules/` | Localized content — from translation team |
| `translations/` | Gitignored build staging — generated locally/CI |
| `l10n-weblate/` | Weblate `.po` / `.cfg` — separate translation workflow |
| `build/` | Build output |

The backported toolchain must **build successfully with English only** when translation
directories are absent. Non-English builds overlay whatever committed translation trees exist on
the target branch at the time.

See [Localized content directories](#localized-content-directories) for known content bugs,
translation-team fixes, and how they interact with the new staging model.

---

## Localized content directories

### Policy

| Directory | Role | Backport? |
|-----------|------|-----------|
| `ja/modules/` | Committed Japanese AsciiDoc | **No** — translation team |
| `ko/modules/` | Committed Korean AsciiDoc | **No** — translation team |
| `zh/modules/` | Committed Chinese AsciiDoc (build code `zh_CN`) | **No** — translation team |
| `translations/` | Gitignored staging (`task stage-content` output) | **No** — generated at build time |
| `l10n-weblate/` | Legacy Weblate `.po` / `.cfg` | **No** — not used by new build |

On branches that still use the **old po4a workflow**, translated AsciiDoc may live under
`translations/{lang}/modules/` (generated, often committed on legacy branches). When migrating those
branches to the new toolchain, **do not copy old `translations/` trees forward** — have the
translation team commit `{lang}/modules/` instead, or rely on English fallback until they do.

### How staging interacts with localized files

`task stage-content` (and the inline staging inside `task pdf`) does:

1. Copy `en/modules/` → `translations/{lang}/modules/`
2. Overlay `{content_dir}/modules/` on top (e.g. `zh/modules/` for `zh_CN`)

If a localized file exists, it **replaces the entire English file** for that path — not a
per-paragraph merge. Structural bugs in a localized page therefore override a fixed English
source for that page until the translation team updates or removes the localized copy.

**Workaround until a localized file is corrected:** delete the broken file from `{lang}/modules/`
so the build falls back to the English version for that page only.

### AsciiDoc rules (discovered during PDF validation)

AsciiDoc **does not support nested preprocessor conditionals** (`ifdef` / `ifndef` / `ifeval`).
Product-specific blocks must be **sibling** pairs:

```asciidoc
ifeval::[{mlm-content} == true]
... MLM-only content ...
endif::[]

ifeval::[{uyuni-content} == true]
... Uyuni-only content ...
endif::[]

... content common to both products ...
```

Do not open a second `ifeval` before closing the first. An `endif::[]` inside the wrong block
—or missing between sibling blocks—can surface as a PDF error at the **end of the nav file**
(e.g. `unterminated preprocessor conditional directive: ifeval::[{mlm-content} == true]` at the
last line of `nav-*-guide.pdf.{lang}.adoc`), even though the nav file itself is balanced.

### Known bugs — English source (fix on all branches)

These are **English** fixes. Backport them to `master` and `manager-5.2` separately from the
toolchain manifest. The translation team should then re-sync or drop affected localized files.

| File | Symptom | Root cause | Fix |
|------|---------|------------|-----|
| `en/modules/client-configuration/pages/clients-sleses.adoc` | PDF build fails at EOF of client-configuration nav; `unterminated … ifeval::[{mlm-content} == true]` | CLI channel tables section used overlapping / incorrectly closed `ifeval` blocks. On `master`, a third `ifeval::[{mlm-content} == true]` wrapped only the partial includes after the Uyuni table. | **Fixed on this branch:** after the MLM CLI table, add `endif::[]`; after the Uyuni CLI table, add `endif::[]`; move `addchannels_novendor_cli` partial includes **outside** both blocks (same pattern as the “Check synchronization status” section later in the file). |
| `en/modules/installation-and-upgrade/pages/container-management/storage-scripts.adoc` | Missing bullet text in CJK HTML/PDF | po4a extraction failed on bullet lists inside table cells | **Fixed on this branch (CHANGELOG):** reformat the “Additional tool-specific behavior” table to use plain paragraphs instead of nested bullet lists. Re-translate affected locales after English change. |
| Various `en/modules/**/*.adoc` | Broken UI/menu literals in translations | Double-backtick AsciiDoc (`[guimenu]``Label``) was written as `` `` `` or similar, which po4a/AI mishandles | **Fixed in #5065:** convert to standard single-backtick menu/button literals in English. Search localized trees for leftover ``\\`` `` or ``\`` `` escapes after translation updates. |

### Known bugs — localized trees on this branch (translation team)

Initial AI translations under `ja/`, `ko/`, and `zh/modules/` were generated before some English
structural fixes landed. Do **not** backport these directories; instead apply the fixes below when
the translation team updates content.

| File | Issue | Impact on MLM build | Recommended fix |
|------|-------|---------------------|-------------------|
| `{ja,ko,zh}/modules/client-configuration/pages/clients-sleses.adoc` | Partial includes (`addchannels_novendor_cli`) sit **inside** `ifeval::[{uyuni-content} == true]` | MLM PDF/HTML omits channel-setup partials for that language because the whole Uyuni block is skipped when `uyuni-content=false` | Re-sync structure from fixed English: close Uyuni block after its table; place partial includes after both `ifeval` blocks. **Or** delete the localized file to use English until re-translated. |
| `zh/modules/administration/pages/patch-management.adoc` | Escaped double backticks (`\\``…``) | Garbled inline literals in HTML/PDF | Replace with correct `[literal]` or menu markup matching the English source pattern. |
| `zh/modules/installation-and-upgrade/partials/snippet-ensure-proxy-prerequisites.adoc` | Escaped ``\\``podman`` `` in heading | Broken package label in heading | Same as above — align with English `[package]` markup. |
| `{ja,ko,zh}/modules/**` (general) | `[guimenu]``…`` / btn:[…]` patterns copied from pre-#5065 English | May render incorrectly; varies by page | Glossary pass: compare against fixed English; fix menu/button literals. |

Partial coverage: only **3 of 9** Antora components are translated initially (`administration`,
`client-configuration`, `installation-and-upgrade`). All other components fall back to English at
build time — see [L10N-AI-MIGRATION.md](../L10N-AI-MIGRATION.md).

### Legacy Weblate / po4a trees (other branches)

Branches still on po4a may have preprocessor damage in **generated** files under
`translations/{lang}/modules/` (not the new `{lang}/modules/` trees):

- **`ifeval` / `endif` lines dropped or merged** during `.po` merge → same unterminated-conditional PDF errors as above.
- **Nav files** (`nav-*-guide.adoc`) — preprocessor lines must stay byte-for-byte intact; only xref labels are translated.

When migrating such a branch: stop committing po4a output; fix **English** source; regenerate or
replace with committed `{lang}/modules/` from the translation team.

### How to find and verify issues on another branch

**1. Preprocessor balance check** (unclosed / extra `endif`):

```bash
# Run from repo root — flags UNCLOSED ifeval/ifdef in a file
python3 - <<'PY'
import re, sys, pathlib
OPEN = re.compile(r'^(?:ifndef|ifdef)::([^[]+)\[\]\s*$|ifeval::\[([^\]]*)\]\s*$')
path = pathlib.Path(sys.argv[1])
stack = []
for i, line in enumerate(path.read_text().splitlines(), 1):
    s = line.strip()
    if s.startswith('//'): continue
    if OPEN.match(s): stack.append(i); continue
    if 'ifeval::[' in s and 'endif::[]' in s: continue
    if s == 'endif::[]':
        if stack: stack.pop()
        else: print(f'  line {i}: extra endif')
for ln in stack:
    print(f'  line {ln}: UNCLOSED')
PY en/modules/client-configuration/pages/clients-sleses.adoc
```

Repeat for suspect files under `{ja,ko,zh}/modules/` if present.

**2. PDF smoke test** (after toolchain backport):

```bash
task setup && task gen
task stage-content LANGUAGES=zh_CN
task pdf BOOK=client-configuration PRODUCT=mlm LANG=zh_CN
```

**3. Compare structure to English** when a localized page exists for the same path:

```bash
diff -u en/modules/client-configuration/pages/clients-sleses.adoc \
        zh/modules/client-configuration/pages/clients-sleses.adoc | rg 'ifeval|endif|include::'
```

### Translation team checklist (per affected file)

1. Fix **English** source on the target branch first (or confirm fix is already merged).
2. Update localized file structure to match English preprocessor layout (sibling `ifeval` blocks).
3. Re-translate prose only where needed; do not move `ifeval`, `ifdef`, or `include::` lines unless English changed.
4. If a quick unblock is needed before re-translation: **remove** the localized file so English fallback is used.
5. Run `task stage-content LANGUAGES=<lang>` and build one PDF book that includes the page.

---

## Per-target branch notes

### `manager-5.1` (current)

This branch lands here first. No further backport action until merged.

After merge, translation team commits `ja/`, `ko/`, and `zh/modules/` independently.

### `master`

1. Ensure the base Go + Task toolchain from [backport-plan-legacy-branches.md](backport-plan-legacy-branches.md) is present (it should be on current `master`).
2. Cherry-pick or merge the **toolchain manifest** files listed above.
3. Do **not** cherry-pick AI translation content commits.
4. Update `build_and_archive_devel_docs.yml` push branches for `master` (not `manager-5.1`).
5. Rebuild and publish the builder image (`publish_builder_image.yml`) so CI picks up the po4a-free image.

Compare against this branch:

```bash
git diff master..manager-5.1 -- \
  Taskfile.yml config.yml cmd/ internal/ \
  Dockerfile.bci L10N-AI-MIGRATION.md \
  .github/workflows/ branding/pdf/themes/ \
  branding/supplemental-ui/mlm/susecom-2025/ docs/
```

### `manager-5.2`

Same procedure as `master`:

1. Base Go + Task toolchain must already be on the branch.
2. Apply the same toolchain manifest; skip localized directories.
3. Set CI push branches to `manager-5.2` (and MU branches if applicable).
4. Translation content arrives via separate commits from the translation team.

At time of writing, the toolchain delta vs `manager-5.2` matches the delta vs `master` for the
files in the manifest above.

---

## Deprecated but retained

These remain in the repo for reference or manual use but are **not** invoked by the build:

| Item | Notes |
|------|-------|
| `scripts/make_pot.sh`, `scripts/use_po.sh` | Legacy po4a scripts |
| `l10n-weblate/` | Weblate project files |
| `task translations`, `task pot` | Print deprecation warning; `translations` delegates to `stage-content` |
| `.github/workflows/update_translation_files.yml` | Manual dispatch only |

---

## Validation after backport

Run on the target branch after applying toolchain changes (English-only smoke test):

```bash
task setup && task gen
task stage-content LANGUAGES=en
task draft:mlm-dsc LANGUAGES=en
task pdf BOOK=administration PRODUCT=mlm LANG=en
task validate:mlm LANGUAGES=en
```

When translation directories are present on the branch:

```bash
task stage-content
task draft:mlm-dsc LANGUAGES="ja ko zh_CN"
task pdf BOOK=administration PRODUCT=mlm LANG=ja
task container:publish:dsc    # full container smoke test
task obs:mlm LANGUAGES="ja ko zh_CN"
task obs:uyuni LANGUAGES="ja ko zh_CN"
```

### Success criteria

- Builds complete **without po4a installed**
- `translations/{lang}/modules/` is populated by `stage-content`, not by `use_po.sh`
- Missing translation files fall back to English content
- CJK PDF builds pass `test_pdf_translations.yml`
- `task obs:mlm` and `task obs:uyuni` produce expected tarballs in `build/packages/` (HTML +
  PDF) with staged translation content
- `update_translation_files.yml` does not run on push

---

## Checklist

Use when opening backport PRs to `master` or `manager-5.2`:

- [ ] Toolchain manifest files merged; no `ja/`, `ko/`, `zh/` content included
- [ ] English source fixes backported where applicable (`clients-sleses.adoc`, `storage-scripts.adoc`, double-backtick cleanup)
- [ ] Translation team briefed on [Localized content directories](#localized-content-directories) known issues
- [ ] `config.yml` `content_dir` entries present for all four build languages
- [ ] `docbuild get-content-dir -lang zh_CN` prints `zh`
- [ ] `task stage-content LANGUAGES=en` succeeds
- [ ] English HTML + PDF build succeeds
- [ ] CJK PDF smoke test: `task pdf BOOK=administration PRODUCT=mlm LANG=zh_CN`
- [ ] OBS smoke test: `task obs:mlm LANGUAGES=en` and `task obs:uyuni LANGUAGES=en` (CJK when translation trees present)
- [ ] `test_pdf_translations.yml` passes (Uyuni theme consolidation: delete `uyuni-{jp,ko,sc}-theme.yml` if present)
- [ ] CI workflows updated for correct branch names
- [ ] Builder container image rebuilt and published
- [ ] Translation team notified to commit localized trees on their schedule
