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
- [ ] Diff generated output vs. current Jinja2 output

## Phase 3 — Task build system

- [x] `task setup`
- [x] `task gen`
- [x] `task build:{output}` (all four)
- [x] `task build:all`
- [x] `task pdf` (single book via CLI args)
- [x] `task pdf:mlm` / `task pdf:uyuni` / `task pdf:all`
- [x] `task pdf-tar:mlm` / `task pdf-tar:uyuni`
- [x] `task obs:mlm` / `task obs:uyuni`
- [x] `task validate:mlm` / `task validate:uyuni`
- [x] `task translations`
- [x] `task clean`
- [ ] Verify Task output matches Make output (requires content migration first)

## Phase 4 — Content migration

- [ ] Rename `modules/` → `en/modules/`
- [ ] Update config and generated path references
- [ ] Update `l10n-weblate/update-cfg-files` path
- [ ] Run `update-cfg-files` and verify
- [ ] Smoke test `make_pot.sh` / `use_po.sh`
- [ ] Full build test

## Phase 5 — Testing and validation

- [ ] HTML: all 4 output targets × 4 languages
- [ ] PDF: all 8 books × 2 products × 4 languages
- [ ] OBS: mlm + uyuni packages
- [ ] Weblate/po4a compatibility

## Phase 6 — Cleanup

- [ ] Remove old `Makefile*` files
- [ ] Remove Python/Jinja2 files
- [ ] Remove `parameters.yml`
- [ ] Update `Dockerfile.custom`
- [ ] Update `README.adoc`
- [ ] Final build verification
