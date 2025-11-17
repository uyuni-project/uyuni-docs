# Language Selector - Legacy Feature

## Status: DEPRECATED ❌

The language selector is **no longer used** in the documentation website. The official documentation at `documentation.suse.com` now uses a **shared header** that provides language selection across all SUSE documentation.

## Historical Context

### What It Was

The language selector was a JavaScript-based dropdown menu that appeared in the documentation navigation header. It allowed users to switch between different language versions of the documentation (English, Japanese, Korean, Chinese).

**Location**: Navigation header in each doc page
**Implementation**: 
- JavaScript: `branding/supplemental-ui/*/js/vendor/langSelection.js`
- Header template: `branding/supplemental-ui/*/partials/header-content.hbs`
- Build-time injection: Make targets `set-html-language-selector-*`

### How It Worked

1. **Build time**: Make script modified `header-content.hbs` using `sed` commands
2. **Injected HTML**: Language links added at `<!-- LANGUAGESELECTOR -->` placeholder
3. **Runtime**: JavaScript function `selectLanguage()` changed URL path (e.g., `/en/` → `/ja/`)

### Build Process (Legacy)

```makefile
# Make function to inject language selector
define enable-html-language-selector
	sed -n -i 'p; s,<\!--\ LANGUAGESELECTOR\ -->,<a role=\"button\" class=\"navbar-item\" id=\"$(1)\" onclick="selectLanguage(this.id)"><img src="{{uiRootPath}}/img/$(2).svg" class="langIcon $(3)">\&nbsp;$(4)</a>,p' translations/$(5)
endef

# Per-language targets
set-html-language-selector-mlm:
	$(call enable-mlm-html-language-selector,zh_CN,china,china,中文)
	$(call enable-mlm-html-language-selector,ja,jaFlag,japan,日本語)
	$(call enable-mlm-html-language-selector,ko,koFlag,korea,한국어)
```

Each language build included dependencies like:
```makefile
prepare-antora-mlm-en: copy-branding-en set-html-language-selector-mlm-en
```

## Why It's Deprecated

1. **Shared Header**: documentation.suse.com uses a unified header across all products
2. **Centralized Management**: Language switching handled at the portal level, not per-doc
3. **Maintenance**: Reduces build complexity by removing sed manipulation
4. **Consistency**: All SUSE docs have the same language switching experience

## Impact on Build System

### What Can Be Removed

✅ **Make Targets** (safe to remove):
- `set-html-language-selector-mlm`
- `set-html-language-selector-uyuni`
- `set-html-language-selector-mlm-{lang}`
- `set-html-language-selector-uyuni-{lang}`

✅ **Make Functions** (safe to remove):
- `enable-html-language-selector`
- `enable-mlm-html-language-selector`
- `enable-uyuni-html-language-selector`

✅ **Dependencies** (can be removed from `prepare-antora-*` targets):
- `set-html-language-selector-mlm-{lang}` 
- `set-html-language-selector-uyuni-{lang}`

### What Stays

❌ **DO NOT REMOVE**:
- `<!-- LANGUAGESELECTOR -->` placeholder in header templates (harmless, ignored)
- `langSelection.js` files (unused but don't break anything)
- Flag images (`.svg` files) in branding assets

**Reason**: These are part of the UI bundle and don't hurt anything by existing.

## Verification: No Other Dependencies

Checked for language selector usage in the toolchain:

```bash
# Only references found:
# 1. Make targets (deprecated)
# 2. Header templates (placeholder, unused)
# 3. JavaScript files (never executed)
```

**Conclusion**: Language selector targets are **purely cosmetic** in the current workflow. They modify header files that are deployed to d.s.c but the functionality is never used because the shared header overrides it.

## Migration to Python/Task

When moving from Make to Python/Task:

### Do NOT Port These Features ✅

1. Language selector injection (sed commands)
2. `set-html-language-selector-*` targets
3. Language selector dependencies in prepare-antora

### Simplified prepare-antora Flow

**Old (Make)**:
```makefile
prepare-antora-mlm-en: copy-branding-en set-html-language-selector-mlm-en
	# Copy modules, create site.yml, etc.
```

**New (Python/Task)**:
```python
def prepare_antora(product: str, lang: str):
    copy_branding(lang)
    # NO language selector injection!
    copy_modules(lang)
    create_site_yml(product, lang)
```

### Build Simplification

**Before**: 
- 8 language selector targets per product
- sed command complexity
- Dependency chain: copy-branding → set-language-selector → prepare-antora

**After**:
- Direct: copy-branding → prepare-antora
- ~100 lines of Make code removed
- Faster builds (no sed processing)

## Testing Notes

When testing Python vs Make builds, **ignore language selector differences**:

```bash
# These differences are expected and OK:
# - header-content.hbs: Make version has injected language links, Python doesn't
# - Both work identically on d.s.c (shared header wins)
```

## Documentation References

- Official docs: https://documentation.suse.com/multi-linux-manager/5.1/
- Shared header: Managed by documentation.suse.com infrastructure
- Language switching: Happens at portal level, not doc level

## Summary

**Language selector = legacy code from when docs were standalone**

Now that docs are part of d.s.c portal:
- ✅ Can safely skip in Python/Task implementation
- ✅ Simplifies build process significantly  
- ✅ No functional impact on users
- ✅ Reduces maintenance burden

**Bottom line**: Don't port it to the new system! 🎉
