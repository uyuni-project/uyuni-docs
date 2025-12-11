# JSON-LD Metadata Script

This script adds JSON-LD metadata attributes to all AsciiDoc pages in the `modules/*/pages` directories.

## Usage

```bash
./add-jsonld-simple.sh
```

The script automatically:
- Detects the current branch
- Sets the appropriate product name and version based on the branch
- Adds four metadata attributes to all page files (excluding partials)
- Skips files that already have all required attributes

## Attributes Added

The script adds the following attributes to each page:

```asciidoc
:page-author: SUSE Product & Solution Documentation Team
:page-image: https://www.suse.com/assets/img/suse-white-logo-green.svg
:page-product-name: <PRODUCT_NAME>
:page-product-version: <VERSION>
```

**Note:** The `page-` prefix is required for custom attributes to be accessible in Antora UI templates.

## Product Names and Versions by Branch

| Branch | Product Name | Version |
|--------|--------------|---------|
| manager-4.3 | SUSE Manager | 4.3 |
| manager-5.0 | SUSE Manager | 5.0 |
| manager-5.1 | SUSE Multi-Linux Manager | 5.1 |
| master | SUSE Multi-Linux Manager | 5.2 |

## Requirements

- Git repository (to detect branch)
- AWK (for text processing)
- Bash shell

## What it does

1. Detects the current Git branch
2. Determines product name and version based on branch
3. Finds all `.adoc` files in `modules/*/pages` directories
4. Skips files in `modules/*/partials` directories
5. Checks if files already have the required attributes
6. Inserts missing attributes after existing document attributes
7. Shows progress as it processes files

## Running on Maintenance Branches

To run the script on a maintenance branch:

```bash
# Checkout the branch
git checkout manager-5.1

# Run the script
./add-jsonld-simple.sh

# Review changes
git diff

# Commit changes
git add modules/
git commit -m "Add JSON-LD metadata attributes"
git push
```

## Example Output

```
[INFO] Branch: json-ld-jcayouette
[INFO] Product: SUSE Multi-Linux Manager 5.2

[INFO] Processing module: administration
  ✓ modules/administration/pages/admin-overview.adoc
  ✓ modules/administration/pages/support.adoc
  ...

[INFO] Processing module: client-configuration
  ✓ modules/client-configuration/pages/client-proxy.adoc
  ...

[INFO] Complete!
[INFO] Review changes with: git diff
```

## Files Modified

On the current master branch, the script processes approximately 557 AsciiDoc files across all module directories.

## Integration with JSON-LD Template

These attributes are used by the Handlebars template in:
```
branding/supplemental-ui/mlm/susecom-2025/partials/head-meta.hbs
```

The template generates JSON-LD structured data for search engines when `page-description` is present:

```json
{
  "@context": "http://schema.org",
  "@type": "TechArticle",
  "headline": "{{page.title}}",
  "description": "{{page.attributes.page-description}}",
  "author": {
    "@type": "Organization",
    "name": "{{page.attributes.page-author}}"
  },
  "mentions": [
    {
      "@type": "SoftwareApplication",
      "name": "{{page.attributes.product-name}}",
      "softwareVersion": "{{page.attributes.product-version}}"
    }
  ]
}
```
