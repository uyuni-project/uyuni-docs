# Korean Translation Table Fixes

## Issue Summary
Korean translation builds were failing with "dropping cells from incomplete row detected end of table" errors, causing actual content loss in the documentation.

## Root Cause
Korean `.po` files contained table rows with incorrect column counts, causing AsciiDoc table parsing errors.

## Errors Fixed (October 2025)

### 1. Alibaba Table (2-column table)
**File**: `l10n-weblate/client-configuration/ko.po` (~line 15082)
**Problem**: Extra column in 2-column table
**Fix**: Remove extra `"| {cross}\n"` column

### 2. Administration Monitoring Table  
**File**: `l10n-weblate/administration/ko.po` (~line 10094)
**Problem**: Double pipe `||` instead of single pipe `|`
**Original**: `"||{salt} 대기열 당 생성된 스레드의 수"`
**Fixed**: `"| {salt} 대기열 당 생성된 스레드의 수"`

### 3. CentOS Table (2-column table)
**File**: `l10n-weblate/client-configuration/ko.po` (~line 16701)
**Problem**: "Product migration" split into 3 columns instead of 2
**Original**:
```
"| 제품 마이그레이션\n"
"| {star}\n" 
"| {check}\n"
```
**Fixed**:
```
"| 제품 마이그레이션 {star}\n"
"| {check}\n"
```

### 4. AlmaLinux Table (3-column table)
**File**: `l10n-weblate/client-configuration/ko.po` (~line 15479)
**Problem**: "Product migration" split into 4 columns instead of 3
**Original**:
```
"| 제품 마이그레이션\n"
"| {star}\n"
"| {check}\n"
"| {check}\n"
```
**Fixed**:
```
"| 제품 마이그레이션 {star}\n"
"| {check}\n"
"| {check}\n"
```

## Diagnosis Process

### 1. Identify Errors
```bash
make antora-mlm-ko 2>&1 | grep -E "(dropping cells|ERROR)"
```

### 2. Search for Table Issues
```bash
# Look for specific feature tables in Korean .po files
grep -n "제품 마이그레이션" l10n-weblate/*/ko.po
grep -n "||" l10n-weblate/*/ko.po
```

### 3. Compare with English Source
Check corresponding English `.adoc` files to understand correct table structure:
- `modules/client-configuration/pages/supported-features-*.adoc`
- `modules/administration/pages/*.adoc`

### 4. Fix Pattern
Korean translations often incorrectly split feature names with symbols:
- `"Feature {symbol}"` should stay as one column
- Don't split into `"Feature"` + `"{symbol}"` separate columns

## Testing
```bash
# Test Korean build
make antora-mlm-ko

# Verify no errors
make antora-mlm-ko 2>&1 | grep -E "(dropping cells|ERROR)" | wc -l
# Should return: 0

# Check exit code
echo $?
# Should return: 0
```

## Files to Check for Similar Issues

### Korean .po Files:
- `l10n-weblate/administration/ko.po`
- `l10n-weblate/client-configuration/ko.po`
- `l10n-weblate/installation-and-upgrade/ko.po`
- `l10n-weblate/reference/ko.po`
- `l10n-weblate/specialized-guides/ko.po`

### Common Problem Patterns:
1. **Double pipes**: `||` instead of `|`
2. **Split feature names**: Feature names with symbols split across multiple columns
3. **Missing columns**: Rows with fewer columns than table header defines
4. **Extra columns**: Rows with more columns than table header defines

### Table Types to Watch:
- OS feature compatibility tables (usually 2-3 columns)
- Configuration parameter tables
- Monitoring metrics tables
- Product migration tables

## Prevention
- When translating tables, maintain exact column structure of English source
- Keep feature names with symbols (like `{star}`, `{check}`) in single columns
- Test Korean builds regularly: `make antora-mlm-ko`
- Monitor for "dropping cells" errors which indicate content loss

## Branch Application
These fixes may need to be applied to:
- 5.0 branch
- 4.3 branch  
- Other release branches with Korean translations

Always test after applying fixes to ensure clean builds with exit code 0.
