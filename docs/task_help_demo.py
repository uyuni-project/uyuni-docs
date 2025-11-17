#!/usr/bin/env python3
"""
Demo of Task help output compared to Make
"""

print("""
╔════════════════════════════════════════════════════════════════════════════════╗
║                         TASK BUILT-IN HELP OUTPUT                              ║
╔════════════════════════════════════════════════════════════════════════════════╗

$ task --list

task: Available tasks for this project:

* build:                     Complete build - HTML and PDFs for a language
* build:all:                 Complete build for ALL languages
* checkstyle:                Check AsciiDoc style compliance
* checkstyle:fix:            Auto-fix AsciiDoc style issues
* clean:                     Remove build artifacts for a language
* clean:all:                 Remove ALL build artifacts
* clean:branding:            Remove branding files
* configure:mlm:             Configure for SUSE Multi-Linux Manager builds
* configure:uyuni:           Configure for Uyuni builds
* dev:                       Start development server with live reload
* full:                      Full HTML + PDF build (alias)
* html:                      Build HTML documentation (fast, no PDFs)
* list:                      List all available build targets
* package:                   Create OBS packages for distribution
* package:all:               Create OBS packages for ALL languages
* pdf:all:                   Build ALL PDF guides for a language
* pdf:section:               Build a single PDF guide
* quick:                     Quick HTML-only build for development (alias)
* translate:                 Sync translations with Weblate/po4a
* validate:                  Validate documentation structure and links

──────────────────────────────────────────────────────────────────────────────────

$ task --summary html

task: html
  
Builds HTML documentation for specified product and language(s).
This is the fastest build option - use for development/preview.

Variables:
  PRODUCT=uyuni|mlm  (default: uyuni)
  LANG=en|ja|ko|zh_CN  (default: en)
  LANGS="en ja ko"     (build multiple languages)

Examples:
  task html                    # Build Uyuni HTML (English)
  task html LANG=ja            # Build Japanese
  task html LANGS="en ja ko"   # Build multiple languages
  task html PRODUCT=mlm        # Build MLM instead

──────────────────────────────────────────────────────────────────────────────────

$ task pdf:section --help

Task allows you to specify which variables to use:

  task pdf:section SECTION=administration LANG=ja PRODUCT=uyuni

Available sections:
  - installation-and-upgrade
  - client-configuration
  - administration
  - reference
  - retail
  - common-workflows
  - specialized-guides
  - legal

──────────────────────────────────────────────────────────────────────────────────

$ task --dry html LANG=ja

task: [html:lang] python3 scripts/build_html.py uyuni ja

Shows exactly what would run without executing it!

╔════════════════════════════════════════════════════════════════════════════════╗
║                     COMPARISON TO YOUR CURRENT MAKE                            ║
╔════════════════════════════════════════════════════════════════════════════════╗

$ make help

============================================
   Uyuni Documentation Build System
============================================

CONFIGURATION: (Run this first to configure your product)
  configure-uyuni                Configure for Uyuni builds
  configure-mlm                  Configure for SUSE MLM builds

QUICK START EXAMPLES:
  make html-uyuni                Build Uyuni HTML for ALL languages (fast)
  make html-uyuni-en             Build Uyuni HTML only (fast, single language)
  make antora-uyuni-en           Build Uyuni HTML + PDFs (complete, single language)
  make obs-packages-uyuni        Build complete Uyuni for ALL languages + packaging
  make clean-en                  Clean English build artifacts

HTML DOCUMENTATION BUILDS:
  html-uyuni-<lang>              Build Uyuni HTML only (fast development)
  html-mlm-<lang>                Build SUSE MLM HTML only (fast development)
  antora-uyuni-<lang>            Build Uyuni HTML + PDF (complete build)
  antora-mlm-<lang>              Build SUSE MLM HTML + PDF (complete build)

PDF DOCUMENTATION BUILDS:
  pdf-all-uyuni-<lang>           Build ALL Uyuni PDF guides
  pdf-all-mlm-<lang>             Build ALL SUSE MLM PDF guides
  pdf-<section>-uyuni-<lang>     Build single Uyuni PDF guide
  pdf-<section>-mlm-<lang>       Build single SUSE MLM PDF guide

COMPLETE BUILD + PACKAGING:
  obs-packages-uyuni             Complete Uyuni build for ALL languages
  obs-packages-mlm               Complete SUSE MLM build for ALL languages
  obs-packages-uyuni-<lang>      Complete Uyuni build (single language)
  obs-packages-mlm-<lang>        Complete SUSE MLM build (single language)

VALIDATION & QUALITY:
  validate-uyuni-<lang>          Validate Uyuni documentation structure
  validate-mlm-<lang>            Validate SUSE MLM documentation structure
  checkstyle                     Check AsciiDoc style compliance
  checkstyle-autofix             Auto-fix AsciiDoc style issues

MAINTENANCE & CLEANUP:
  clean-<lang>                   Remove build artifacts for specific language
  clean                          Remove all build artifacts
  clean-branding                 Remove all branding files

DEBUG & DEVELOPMENT:
  debug-help                     Show debug usage and test colors
  test-colors                    Test color output functionality
  list-targets                   List all available build targets

AVAILABLE LANGUAGES:
  <lang> = en | ja | ko | zh_CN

──────────────────────────────────────────────────────────────────────────────────

╔════════════════════════════════════════════════════════════════════════════════╗
║                               KEY ADVANTAGES                                   ║
╔════════════════════════════════════════════════════════════════════════════════╗

TASK ADVANTAGES:
✓ Built-in help - no custom printf code needed
✓ --summary shows detailed help for any task
✓ --list automatically formatted and sorted
✓ --dry shows exact commands before running
✓ Tab completion out of the box (bash/zsh/fish)
✓ Variables clearly shown in help text
✓ Self-documenting from Taskfile
✓ No manual maintenance of help text

MAKE ADVANTAGES:
✓ Your custom help is very well organized!
✓ Shows examples with actual target names
✓ Color-coded output (nice touch)

MAKE DISADVANTAGES:
✗ ~50 lines of printf code to maintain
✗ Help text separate from target definitions
✗ Can get out of sync with actual targets
✗ No way to get help for individual targets
✗ No --dry-run to preview commands

╔════════════════════════════════════════════════════════════════════════════════╗
║                        YOU CAN HAVE BOTH!                                      ║
╔════════════════════════════════════════════════════════════════════════════════╗

Option 1: Keep Make as wrapper (transition period)

  Makefile:
    help:
        @task --list
    
    html-uyuni-en:
        @task html PRODUCT=uyuni LANG=en
    
    # Users can use either:
    make html-uyuni-en   (familiar)
    task html LANG=en    (new way)

Option 2: Add 'task help' with custom formatting

  Taskfile.yml:
    help:
      desc: Show detailed help (same as 'task --list')
      cmds:
        - python3 scripts/show_help.py  # Your custom formatted help
        - echo ""
        - echo "Or use 'task --list' for standard format"

Option 3: Pure Task with rich descriptions

  Just use task's built-in help - it's actually quite good!
  Add detailed 'summary:' fields to tasks that need them.

""")

print("""
╔════════════════════════════════════════════════════════════════════════════════╗
║                    BONUS: Interactive Shell Completion                         ║
╔════════════════════════════════════════════════════════════════════════════════╗

$ task <TAB><TAB>
build           checkstyle      clean           configure       dev
html            package         pdf             translate       validate

$ task html <TAB>
LANG=    LANGS=   PRODUCT=

$ task pdf:section SECTION=<TAB>
administration           client-configuration     common-workflows
installation-and-upgrade reference               retail
specialized-guides       legal

This just works - no custom completion scripts needed!
""")
