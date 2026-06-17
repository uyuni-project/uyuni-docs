# Backport Plan: Go Toolchain → manager-5.1, manager-5.0, manager-4.3

**Status:** Draft — for review before testing begins  
**Branch this was written from:** `golang-task-migration-jcayouette` (master)

---

## Design Decision

**The Go binary (`docbuild`) is already product-agnostic.** It reads product keys, output keys, and branding paths directly from `config.yml` — no code changes are needed per branch.

The per-branch adaptation work is:
1. **`config.yml`** — created fresh per branch by translating `parameters.yml` values into the Go config schema. Product key, version attributes, branding paths, and output URLs all come from here.
2. **`Taskfile.yml`** — adapted per branch to use the correct product/output key names (`mlm-dsc` vs `suma-dsc`). Everything else in the Taskfile is identical.
3. **Branding paths** — `config.yml` points to `branding/supplemental-ui/suma/` on 5.0/4.3 vs `mlm/` on 5.1/master. No directory renames needed; just correct config.

The Go source (`cmd/`, `internal/`), `go.mod`, `go.sum`, `Dockerfile.bci`, and GHA workflows are **copied verbatim** from master to all branches.

---

## Branch Overview

| Branch | Product key | Branding dir | Taskfile changes vs master |
|---|---|---|---|
| `manager-5.1` | `mlm` | `mlm/` | None — identical to master |
| `manager-5.0` | `suma` | `suma/` | `mlm` → `suma` in task names and help text |
| `manager-4.3` | `suma` | `suma/` | Same as 5.0 |

---

## Key Constraint

Do not modify `l10n-weblate/` directly. Only `update-cfg-files` may touch those files.

---

## Translation System: Safe — No Action Required

**The translation system is not affected by this backport.**

The `l10n-weblate/*.cfg` files map source paths to translation output paths:

```
[type: asciidoc] en/modules/administration/pages/foo.adoc  $lang:translations/$lang/modules/administration/pages/foo.adoc
```

- `en/modules/` source structure is unchanged
- `translations/$lang/modules/` output structure is unchanged
- The Go toolchain only generates Antora/site configs into `translations/{lang}/` — it never touches source `.adoc` files
- `scripts/make_pot.sh` and `scripts/use_po.sh` are unchanged and still called by `task pot` and `task translations`

`update_translation_files.yml` runs `bash scripts/make_pot.sh` only. It has no dependency on Make or Task and is unaffected on all three branches.

### One verification step after backport

```bash
cd l10n-weblate && bash update-cfg-files
```

If the script produces no diff, nothing has changed and no commit is needed.

---

## GitHub Actions: Replace uyuni-docs-helper with Container + Task

The existing workflows call `uyuni-docs-helper`, which invokes legacy Makefile targets. **The helper is dropped entirely.** Each branch gets updated workflows that pull the pre-built container and call `task` directly.

### Replacement pattern

Remove the `uyuni-docs-helper` checkout step. Replace the build steps with:

```yaml
- name: Build HTML documentation
  run: |
    podman run --rm \
      -v ${{ github.workspace }}:/docs:Z \
      -w /docs \
      ghcr.io/uyuni-project/uyuni-docs-builder:latest \
      sh -c "task setup && task gen && task publish:dsc"

- name: Build OBS packages
  run: |
    podman run --rm \
      -v ${{ github.workspace }}:/docs:Z \
      -w /docs \
      ghcr.io/uyuni-project/uyuni-docs-builder:latest \
      sh -c "task setup && task gen && task obs:mlm"
      # Use obs:suma on manager-5.0 and manager-4.3
```

For PR checks (`tests.yml`):
```yaml
- name: Build documentation (PR check)
  run: |
    podman run --rm \
      -v ${{ github.workspace }}:/docs:Z \
      -w /docs \
      ghcr.io/uyuni-project/uyuni-docs-builder:latest \
      sh -c "task setup && task gen && task draft:mlm-dsc"
      # Use draft:suma-dsc on manager-5.0 and manager-4.3
```

`publish_builder_image.yml` is copied verbatim from master to each branch — it keeps the `ghcr.io` image current whenever `Dockerfile.bci` changes on that branch.

---

## What to Copy Verbatim from Master

The following are **identical across all branches** — copy without modification:

| Path | Notes |
|---|---|
| `cmd/` | Go CLI source |
| `internal/` | Go library source |
| `go.mod`, `go.sum` | Go module files |
| `Dockerfile.bci` | Builder image |
| `Dockerfile.bookworm` | Comparison image |
| `scripts/` | Verify present; no changes |
| `docs/` | Contributor documentation (optional) |
| `.github/workflows/publish_builder_image.yml` | Image publish workflow |

---

## Phase 1: manager-5.1

**Effort: Low.** Product key is `mlm`, branding is `mlm/`, Taskfile is identical to master.

### Steps

1. Copy all files from the "copy verbatim" table above
2. Copy `Taskfile.yml` verbatim
3. Create `config.yml` from master's copy, then update version-specific values from `manager-5.1`'s `parameters.yml`:

```yaml
products:
  mlm:
    asciidoc:
      attributes:
        productnumber: "5.1"
        productchartversion: "5.1.x"      # match parameters.yml exactly
        gitchartsbranch: Manager-5.1
        currentversion: ""                # remove beta label if 5.1 is GA
    outputs:
      mlm-dsc:
        site:
          title: SUSE Multi-Linux Manager 5.1 Documentation
          url: https://documentation.suse.com/multi-linux-manager/5.1/
  uyuni:
    # Remove this product block entirely if uyuni is not built from manager-5.1
```

Also diff the shared `asciidoc:` attributes block against `manager-5.1` `parameters.yml` and align:
- `sp-version`, `sp-base`, `bci-mlm`
- `sles-base-os-documentation` URL
- `smrproductnumber`

4. Update the GHA build/test workflows to use `podman run ... task` (use `mlm` task names)

### Smoke test

```bash
task setup && task gen
task draft:mlm-dsc
task pdf BOOK=administration PRODUCT=mlm LANG=en
```

---

## Phase 2: manager-5.0

**Effort: Medium.** Product key is `suma`. Taskfile needs `mlm` → `suma` substitution throughout. Branding is under `suma/`.

### Steps

1. Copy all files from the "copy verbatim" table above
2. Copy `Taskfile.yml` from master, then substitute `mlm` → `suma` throughout:
   - Task names: `draft:mlm-dsc` → `draft:suma-dsc`, `draft:mlm-webui` → `draft:suma-webui`
   - Container mirrors: `container:draft:mlm-dsc` → `container:draft:suma-dsc`, etc.
   - `pdf:mlm` → `pdf:suma`, `obs:mlm` → `obs:suma`
   - The `default` task help text echo lines
   - Any `PRODUCT=mlm` variable defaults
3. Create `config.yml` based on `manager-5.0` `parameters.yml`:

```yaml
products:
  suma:                                        # product key
    antora:
      name: docs                               # verify against parameters.yml
      title: SUSE Manager Guides               # verify exact title
    asciidoc:
      attributes:
        productname: SUSE Manager
        productnumber: "5.0"
        productchartversion: "5.0.x"           # from parameters.yml
        gitchartsbranch: Manager-5.0
        copyrightdate: "2011–2024"             # verify year
        suma-content: "true"                   # check what flag 5.0 used
        uyuni-content: "false"
    sections:
      # copy list from parameters.yml — may differ from master
    pdf:
      tar_name: suse-manager-docs              # from parameters.yml
      obs_name: susemanager-docs
    ui:
      bundle: ./branding/default-ui/suma/ui-bundle.zip
    outputs:
      suma-dsc:
        site:
          title: SUSE Manager 5.0 Documentation
          url: https://documentation.suse.com/suma/5.0/   # verify URL pattern
          start_page: docs::index.adoc
        supplemental_files: ./branding/supplemental-ui/suma/susecom-2025
        # If susecom-2025 did not exist on 5.0, use susecom-2023
        language_selector: false
        obs: false
      suma-webui:
        site:
          title: SUSE Manager 5.0 Documentation
          url: /
          start_page: docs::index.adoc
        supplemental_files: translations/{lang}/supplemental-ui
        language_selector: true
        obs: true
  uyuni:
    # Remove if uyuni is not built from manager-5.0
```

> Verify all values against the actual `parameters.yml` on `manager-5.0`. Pay attention to the content flag name — 5.0 likely uses `suma-content` rather than `mlm-content`.

4. Confirm branding directories exist at `suma/` paths:

```bash
ls branding/default-ui/suma/
ls branding/supplemental-ui/suma/
```

If they are still under `mlm/` (partial migration), rename them. If already `suma/`, nothing to do.

5. Audit `susecom-2025` (or `susecom-2023`) for hardcoded `mlm` / `multi-linux-manager` strings:

```bash
grep -rl "mlm\|multi-linux-manager" branding/supplemental-ui/suma/ \
  --include="*.html" --include="*.hbs" --include="*.css"
```

Replace with the correct SUSE Manager / `suma` URL patterns for this branch.

6. Update the GHA build/test workflows using `suma` task names

### Smoke test

```bash
task setup && task gen
task draft:suma-dsc
task pdf BOOK=administration PRODUCT=suma LANG=en
```

---

## Phase 3: manager-4.3

**Effort: Medium.** Same approach as Phase 2 with version 4.3 specifics.

Follow all steps from Phase 2, then additionally check:

### Version-specific attributes

- `productnumber: "4.3"`
- SLES base version (likely 15 SP4 or SP5) — update `sp-version`, `bci-suma`, and `sles-base-os-documentation` URL
- Remove any shared attributes added in 5.x that do not exist in 4.3 content to avoid undefined attribute warnings

### Supplemental UI

`susecom-2025` almost certainly does not exist on manager-4.3. Use `susecom-2023`:

```yaml
supplemental_files: ./branding/supplemental-ui/suma/susecom-2023
```

### Language set

Check the `[po4a_langs]` header in any `l10n-weblate/*.cfg` file. If manager-4.3 includes `cs` and `es` (which master dropped), add those language blocks to `config.yml`. Verify each added language produces acceptable output before pushing.

### Smoke test

```bash
task setup && task gen
task draft:suma-dsc
task pdf BOOK=administration PRODUCT=suma LANG=en
```

---

## Recommended Testing Order

1. **manager-5.1 first** — identical product naming to master; lowest risk; validates the copy mechanism
2. **manager-5.0 second** — validates suma rename, branding path check, and Taskfile substitution
3. **manager-4.3 last** — validates older version attributes and supplemental UI fallback

Do not push to any branch until the local smoke test passes.

---

## Checklist Per Branch

```
[ ] Go source (cmd/, internal/, go.mod, go.sum) copied verbatim
[ ] Dockerfile.bci and Dockerfile.bookworm copied verbatim
[ ] publish_builder_image.yml copied verbatim
[ ] config.yml created from parameters.yml values (product key, versions, URLs, branding paths)
[ ] config.yml supplemental_files paths point to correct suma/ or mlm/ directories
[ ] Taskfile.yml adapted: mlm → suma substitution where applicable (5.0/4.3 only)
[ ] Taskfile.yml default task help text updated to match product
[ ] Branding directories confirmed at expected paths (suma/ or mlm/)
[ ] susecom HTML/HBS templates audited for hardcoded mlm/multi-linux-manager references
[ ] GHA build/test workflows updated: uyuni-docs-helper removed, podman + task added
[ ] task setup && task gen runs without error
[ ] task draft:<product>-dsc produces valid HTML output
[ ] task pdf BOOK=administration PRODUCT=<product> LANG=en produces a PDF
[ ] cd l10n-weblate && bash update-cfg-files → no unexpected diff
```
