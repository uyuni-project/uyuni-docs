# Roadmap

## Phase 1 — Foundation ✅ complete

**Goal:** Planning documents in place, Go module scaffolded, `config.yml` written.

- [x] Create `toolchain-migration/` planning documents (README, GOALS, ARCHITECTURE, ROADMAP, PROGRESS)
- [x] Initialise Go module at repo root (`go.mod`, `go.sum`)
- [x] Create `cmd/docbuild/` directory structure
- [x] Write `config.yml` replacing `parameters.yml`
- [x] Verify `config.yml` covers all attributes currently in `site.yml` and `parameters.yml`

**Exit criteria:** `go build ./cmd/docbuild/` succeeds. ✅

---

## Phase 2 — Config generation ✅ complete

**Goal:** Go binary generates all config files that the Python + Jinja2 layer currently produces.

- [x] Implement `internal/config` — load and validate `config.yml`
- [x] Implement `gen-antora` — generate `translations/{lang}/antora.yml` per product + language
- [x] Implement `gen-site` — generate `translations/{lang}/{output}.site.yml` per output-target + language
- [x] Implement `gen-entities` — generate `branding/pdf/entities.adoc` per product + language
- [x] Implement `gen-pdf-nav` — generate PDF nav file from Antora nav per book/lang
- [x] Implement `collect-pdfs` — move PDFs from `build/{lang}/pdf/` → `build/pdf/{lang}/` (replaces `cleanup_pdfs.sh`)
- [x] Implement `gen-all` subcommand running the above for all configured languages
- [x] Embedded Go templates (inline in `internal/generate/templates.go`)
- [x] xref-converter.rb embedded as Go const; written to `.bin/` at gen time (replaces `extensions/` dependency)
- [x] Diff generated output against current Jinja2 output — verified equivalent

**Exit criteria:** `docbuild gen-all` produces files equivalent to running the current `configure` script. ✅

---

## Phase 3 — Task build system ✅ complete

**Goal:** `Taskfile.yml` fully replaces all `Makefile*` files.

- [x] `task setup`, `task gen`
- [x] `task build:{output}` for all four output targets + `task build:all`
- [x] `task pdf` (single book), `task pdf:mlm`, `task pdf:uyuni`, `task pdf:all`
- [x] `task pdf-collect:mlm/uyuni`, `task pdf-zip:mlm/uyuni`, `task pdf-tar:mlm/uyuni`
- [x] `task obs:mlm`, `task obs:uyuni`
- [x] `task publish:dsc`, `task publish:uyuni`, `task publish:webui-mlm`, `task publish:webui-uyuni`
- [x] `task validate:mlm`, `task validate:uyuni`
- [x] `task translations`, `task pot`
- [x] `task clean` (build/, translations/, .cache/)
- [x] `task --list` curated — 25 user-facing targets, plumbing hidden
- [x] `task container:*` — all publish targets runnable via container (no local toolchain needed)

**Exit criteria:** Full build with Taskfile produces equivalent output to the current Makefile build. ✅

---

## Phase 4 — Content migration ✅ complete

**Goal:** English source moves to `en/modules/`; build system references updated.

- [x] Rename `modules/` → `en/modules/`
- [x] Update `config.yml` content source path to `en/modules/`
- [x] Update generated `antora.yml` nav paths to `en/modules/`
- [x] Update `l10n-weblate/update-cfg-files` scan path: `modules/$GUIDE/` → `en/modules/$GUIDE/`
- [x] Run `l10n-weblate/update-cfg-files` to regenerate `.cfg` file entries
- [x] `make_pot.sh` and `use_po.sh` moved to `scripts/`, `CURRENT_DIR` fixed to repo root, `modules/` → `en/modules/`
- [x] Full build test with `task build:all`

**Exit criteria:** All four HTML outputs and all PDF builds succeed from `en/modules/`. ✅

---

## Phase 5 — Testing and validation ✅ complete

**Goal:** All 4 output targets × 4 languages × HTML + PDF validated.

- [x] `task build:mlm-dsc` — all 4 languages
- [x] `task build:mlm-webui` — all 4 languages
- [x] `task build:uyuni-website` — all 4 languages
- [x] `task build:uyuni-webui` — all 4 languages
- [x] PDF: MLM 32/32 (8 books × 4 langs) — Exit 0
- [x] PDF: Uyuni 32/32 (8 books × 4 langs) — Exit 0
- [x] OBS: `obs:mlm` — 8 tarballs, Exit 0
- [x] OBS: `obs:uyuni` — 8 tarballs, Exit 0
- [x] Container: `publish:dsc` end-to-end inside Podman — Exit 0
- [ ] Weblate/po4a compatibility smoke test

**Exit criteria:** All items above pass (po4a smoke test deferred pending translation cycle). ✅

---

## Phase 6 — Cleanup ✅ complete

**Goal:** Remove all old toolchain files; harden container image.

- [x] Old `Makefile*` files (11) + Python/Jinja2 files + `parameters.yml` moved to `docs/legacy-toolchain/`
- [x] `extensions/` moved to `docs/legacy-toolchain/` (xref-converter.rb embedded in Go binary)
- [x] Utility scripts reorganised into `scripts/`
- [x] GitHub Actions workflows updated for new script paths
- [x] `linting.yml` and `.vale.ini` removed (broken/unused)
- [x] `Dockerfile.custom` rewritten — full self-contained toolchain image (Go, Task, Antora, Asciidoctor-PDF, po4a, zip)
- [x] `publish_builder_image.yml` — publishes `ghcr.io/uyuni-project/uyuni-docs-builder` via `GITHUB_TOKEN`
  - Triggers on `Dockerfile.custom` changes merged to `master` + `workflow_dispatch`
  - Pushes `latest` + immutable `sha-<commit>` tag
  - `permissions: packages: write` scoped to job only — no PAT, no stored secrets
  - Action pins are commit-hash pinned to prevent supply-chain tag-move attacks
  - **Org-level step required:** GitHub org settings → Packages → Actions access policy → allow `uyuni-docs` repo to push packages
- [x] `README.adoc` Build section updated with container and local toolchain commands

**Exit criteria:** Repo builds cleanly with only Go + Task. No Python, no Make, no Jinja2. ✅

---

## Phase 7 — Backports

**Gate: Phase 5/6 fully verified on master before backporting.**

Branches: `manager-5.1`, `manager-5.0`, `manager-4.3`

**Model:** No branch detection in the Taskfile. Each branch carries its own `config.yml` tuned for
that release. Contributors checkout the branch and build — correct version attributes are already in
`config.yml`.

**`config.yml` values that differ per branch:**
- `currentversion`, `productchartversion`, `gitchartsbranch`
- `sp-version`, `sp-version-number`, `bci-mlm`, `bci-uyuni`, `opensuse-version`
- Canonical URLs (`mlm-dsc.url`, `uyuni-website.url`)

**Pre-backport parity check (per branch):**
```bash
git worktree add ../uyuni-docs-51 manager-5.1
cd ../uyuni-docs-51
task build:mlm-dsc
diff -r --brief ../uyuni-docs-reference/build/ build/
```

- [ ] `manager-5.1` — adjust `config.yml`, full build test, parity check, merge
- [ ] `manager-5.0` — adjust `config.yml`, full build test, parity check, merge
- [ ] `manager-4.3` — adjust `config.yml`, full build test, parity check, merge

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
