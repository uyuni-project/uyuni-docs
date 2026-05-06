# Progress

## Phase 1 — Foundation

- [x] Create `toolchain-migration/` planning documents
- [x] Initialise Go module (`go.mod`)
- [x] Create `cmd/docbuild/` directory structure
- [x] Write `config.yml`
- [x] Verify `config.yml` covers all attributes in `site.yml` and `parameters.yml`

## Phase 2 — Config generation

- [x] `internal/config` — load and validate `config.yml`
- [x] `gen-antora` subcommand
- [x] `gen-site` subcommand (canonical URL written directly, no sed)
- [x] `gen-entities` subcommand
- [x] `gen-all` subcommand
- [x] Go templates (inline in `internal/generate/templates.go`)
- [x] `internal/generate/xrefext.go` — embed `xref-converter.rb` as Go const; write to `.bin/` at gen time (replaces `extensions/` dependency)
- [x] `internal/generate/collectpdfs.go` — move PDFs from `build/{lang}/pdf/` → `build/pdf/{lang}/` (replaces `cleanup_pdfs.sh`)
- [x] Diff generated output vs. current Jinja2 output — verified equivalent

## Phase 3 — Task build system

- [x] `task setup`
- [x] `task gen`
- [x] `task build:{output}` (all four)
- [x] `task build:all`
- [x] `task pdf` (single book via CLI args)
- [x] `task pdf:mlm` / `task pdf:uyuni` / `task pdf:all`
- [x] `task pdf-collect:mlm` / `task pdf-collect:uyuni`
- [x] `task pdf-zip:mlm` / `task pdf-zip:uyuni`
- [x] `task pdf-tar:mlm` / `task pdf-tar:uyuni`
- [x] `task obs:mlm` / `task obs:uyuni`
- [x] `task publish:dsc` / `task publish:uyuni` / `task publish:webui-mlm` / `task publish:webui-uyuni`
- [x] `task validate:mlm` / `task validate:uyuni`
- [x] `task translations` / `task pot`
- [x] `task clean` (includes `build/`, `translations/`, `.cache/`)
- [x] Build output verified equivalent to Make output

## Phase 4 — Content migration

- [x] Rename `modules/` → `en/modules/`
- [x] Update config and generated path references
- [x] Update `l10n-weblate/update-cfg-files` path
- [x] Run `update-cfg-files` and verify all `.cfg` files regenerated
- [x] `make_pot.sh` / `use_po.sh` moved to `scripts/`, `CURRENT_DIR` fixed to repo root, `modules/` → `en/modules/`
- [x] Full build test — all 4 HTML targets building correctly

## Phase 5 — Testing and validation

- [x] HTML: all 4 output targets × 4 languages — Exit 0
- [x] PDF: 32/32 MLM PDFs (8 books × 4 langs) — Exit 0
- [x] PDF: 32/32 Uyuni PDFs (8 books × 4 langs) — Exit 0
- [x] OBS: `obs:mlm` — 8 tarballs (~31M each) — Exit 0
- [x] OBS: `obs:uyuni` — 8 tarballs (31M PDF / 52M HTML) — Exit 0
- [x] Container smoke test: `uyuni-docs-builder:test` — `task gen` + `task build:mlm-dsc` pass inside Podman
- [x] `publish:dsc` full end-to-end in container — Exit 0 (`task container:publish:dsc`)
- [ ] Weblate/po4a compatibility smoke test

## Phase 6 — Cleanup

- [x] Old `Makefile*` files (11) moved to `legacy-toolchain/`
- [x] Python/Jinja2 files (`*.j2`, `configure`) moved to `legacy-toolchain/`
- [x] `parameters.yml`, `antora.yml`, `site.yml`, `cleanup_pdfs.sh` moved to `legacy-toolchain/`
- [x] `extensions/` moved to `legacy-toolchain/` (xref-converter.rb embedded in Go binary)
- [x] Utility scripts reorganised into `scripts/` (`enforcing_checkstyle`, `find_unused`, `make_pot.sh`, `use_po.sh`)
- [x] GitHub Actions workflows updated: `update_translation_files.yml`, `enforced_checkstyle.yml`, `find_unused_files.yml`
- [x] `linting.yml` and `.vale.ini` removed (broken/unused)
- [x] `Dockerfile.custom` rewritten — full toolchain image (Go, Task, Antora, Asciidoctor-PDF, po4a, zip)
- [x] `CoCo` attribute added to `config.yml` global asciidoc map
- [x] `container:*` Task targets added — all user-facing publish commands available via container
- [x] `task --list` curated — utility/plumbing tasks hidden, 25 user-facing targets shown
- [x] `README.adoc` Build section updated with container and local toolchain commands
- [x] `publish_builder_image.yml` GitHub Actions workflow created
  - Registry: `ghcr.io/uyuni-project/uyuni-docs-builder` (GitHub Container Registry)
  - Auth: `GITHUB_TOKEN` only — no PAT, no stored secrets; token expires when run ends
  - Permissions: `packages: write + contents: read` scoped to this job only
  - Triggers: push to `master` when `Dockerfile.custom` changes + `workflow_dispatch` for maintainers
  - Tags pushed: `latest` (always current master) + `sha-<commit>` (immutable, safe for pinning)
  - Action pins: all three actions pinned by commit SHA to prevent supply-chain tag-move attacks
  - **Org prerequisite:** GitHub org settings → Packages → Actions access policy → allow `uyuni-docs` repo to push packages
- [ ] Publish `uyuni-docs-builder` image — pending PR merge to master (workflow will fire automatically)
- [ ] Write `publish-image.yml` GitHub Actions workflow
- [ ] Update `uyuni-docs-helper` or deprecate in favour of container image
- [ ] Final build verification on clean clone

## Phase 7 — Backports

**Gate: all Phase 5/6 tests must pass and build output must be verified equivalent before backporting.**

Branches to backport to: `manager-5.1`, `manager-5.0`, `manager-4.3`

### Backport model

No branch detection in the Taskfile. Each branch carries its own `config.yml` tuned for that release.
Contributors just checkout + build — the correct version attributes, URLs, and chart branches are
already in `config.yml` on the target branch.

Files that need per-branch adjustment in `config.yml`:
- `currentversion` / `productchartversion` / `gitchartsbranch`
- `sp-version`, `sp-version-number`, `bci-mlm`, `bci-uyuni`, `opensuse-version`
- Canonical URLs (`mlm-dsc.url`, `uyuni-website.url`)
- Any product-specific attributes that differ between releases

### Pre-backport parity check (per branch)

Use `git worktree` to build both old and new toolchain side-by-side without re-cloning:

```bash
# Add a worktree for the target branch
git worktree add ../uyuni-docs-51 manager-5.1
cd ../uyuni-docs-51

# Build with new toolchain
task build:mlm-dsc

# Diff HTML output against a reference build from the same branch using the old Makefile
diff -r --brief ../uyuni-docs-reference/build/ build/
```

Output must be functionally equivalent (attribute values, xref resolution, PDF structure) before merging.

### Backport checklist (repeat per branch)

- [ ] `manager-5.1` — adjust `config.yml` for 5.1 release values
- [ ] `manager-5.1` — full build test: HTML, PDF, OBS packages
- [ ] `manager-5.1` — parity check vs. existing Makefile output
- [ ] `manager-5.1` — merge and tag

- [ ] `manager-5.0` — adjust `config.yml` for 5.0 release values
- [ ] `manager-5.0` — full build test: HTML, PDF, OBS packages
- [ ] `manager-5.0` — parity check vs. existing Makefile output
- [ ] `manager-5.0` — merge and tag

- [ ] `manager-4.3` — adjust `config.yml` for 4.3 release values
- [ ] `manager-4.3` — full build test: HTML, PDF, OBS packages
- [ ] `manager-4.3` — parity check vs. existing Makefile output
- [ ] `manager-4.3` — merge and tag

