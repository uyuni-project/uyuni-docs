# Makefile Enhancements Plan

## Overview
This document tracks the planned enhancements to the Uyuni documentation build system to add:
1. Colored output for different log levels (Green/Yellow/Red)
2. Debug mode with verbose output control
3. Enhanced help system with clear command categories
4. Better error handling and progress tracking

## Current Architecture Analysis
- **Main Makefile**: Core functions and definitions
- **Language Makefiles**: Generated from Jinja2 templates (en, ja, ko, zh_CN)
- **Jinja2 Templates**: 
  - `Makefile.j2` - Language-specific targets template
  - `Makefile.section.functions.j2` - PDF section targets template
- **parameters.yml**: Configuration for languages, sections, products
- **configure script**: Python/Jinja2 generator for makefiles

## Files to Modify

### 1. Main Makefile (`/home/scribe/projects/uyuni-docs/Makefile`)
**Changes:**
- Add TTY detection for color output (only in interactive terminals)
- Add color definitions with CI/CD safety (RED, YELLOW, GREEN, BLUE, CYAN, NC)
- Add DEBUG variable and QUIET control (opt-in only)
- Add logging functions with environment detection
- Enhanced help system (new `help-enhanced` target, keep original `help`)
- **NO CHANGES** to core functions: `antora-uyuni-function`, `antora-mlm-function`
- **NO CHANGES** to PDF functions: `pdf-book-create-uyuni`, `pdf-book-create`
- Add new optional targets: `debug-help`, `list-targets`, `test-colors`

### 2. Jinja2 Template (`/home/scribe/projects/uyuni-docs/Makefile.j2`)
**Changes:**
- Update targets to use new logging functions
- Add progress indicators for build steps
- Enhanced error handling in target definitions

### 3. Section Functions Template (`/home/scribe/projects/uyuni-docs/Makefile.section.functions.j2`)
**Changes:**
- Add progress tracking for PDF generation (X/Y step indicators)
- Use logging functions in PDF targets
- Better error reporting for PDF creation failures

### 4. New Debug Documentation (`/home/scribe/projects/uyuni-docs/context/DEBUG_USAGE.md`)
**Changes:**
- Create documentation for debug usage
- Examples of colored output
- Troubleshooting guide

## Command Categories for Enhanced Help

### HTML Build Commands
- `html-uyuni-<lang>` - Build HTML-only documentation for Uyuni (fast, for development)
- `html-mlm-<lang>` - Build HTML-only documentation for MLM (fast, for development) 
- `antora-uyuni-<lang>` - Build HTML + PDF documentation for Uyuni (complete build)
- `antora-mlm-<lang>` - Build HTML + PDF documentation for MLM (complete build)

### PDF Build Commands  
- `pdf-all-uyuni-<lang>` - Build all PDF guides for Uyuni (single language)
- `pdf-all-mlm-<lang>` - Build all PDF guides for MLM (single language)
- `pdf-<section>-uyuni-<lang>` - Build single PDF guide (e.g., pdf-administration-uyuni-en)
- `pdf-<section>-mlm-<lang>` - Build single PDF guide for MLM

### Complete Build Commands
- `obs-packages-uyuni-<lang>` - Complete build with HTML + PDF + packaging
- `obs-packages-mlm-<lang>` - Complete MLM build with packaging

### Utility Commands
- `clean-<lang>` - Clean build artifacts for language
- `clean` - Clean all build artifacts
- `validate-uyuni-<lang>` - Validate Uyuni documentation
- `validate-mlm-<lang>` - Validate MLM documentation

## Color Coding Scheme

### Log Levels
- **CYAN [INFO]** - General information, build steps
- **BLUE [BUILD]** - Command execution details (debug mode)  
- **GREEN [SUCCESS]** - Successful completion
- **YELLOW [WARN]** - Warnings, non-critical issues
- **RED [ERROR]** - Errors, build failures

### Help Categories (Proposed)
- **CYAN** - Category headers (HTML Builds, PDF Builds, etc.)
- **GREEN** - Available commands
- **YELLOW** - Language codes and examples
- **BLUE** - Debug and utility commands

## Debug Mode Features

### Normal Mode (Default)
- Clean, minimal output
- Only show progress and results
- Hide verbose command output
- Color-coded status messages

### Debug Mode (DEBUG=1)
- Full command output visible
- Detailed build steps
- All asciidoctor-pdf and antora output
- Command line echoing

## Implementation Steps (CI/CD Safe)

1. **Phase 1**: Add environment detection and color system (additive only)
2. **Phase 2**: Add new optional help and debug targets (no existing changes)
3. **Phase 3**: Add opt-in logging functions (default behavior unchanged)
4. **Phase 4**: Test in Docker container to ensure CI compatibility
5. **Phase 5**: Document safe usage patterns and environment handling

### Core Principle: Zero Breaking Changes
- **NO modifications** to existing `antora-uyuni-function` or `antora-mlm-function`
- **NO modifications** to existing `pdf-book-create` functions  
- **NO changes** to default command output or behavior (build commands)
- **Enhanced help as default** - beautiful, organized help with colors
- **CI/CD fallback available** - `make help-basic` for simple output
- **ALL build enhancements** are purely additive and opt-in
- **FULL backwards compatibility** with Docker containers and CI/CD

## Languages Supported
- `en` - English (en_US.utf8)
- `ja` - Japanese (ja_JP.UTF-8) 
- `ko` - Korean (ko_KR.UTF-8)
- `zh_CN` - Chinese Simplified (zh_CN.UTF-8)

## Products Supported
- **uyuni** - Uyuni open-source project documentation
- **mlm** - SUSE Multi-Linux Manager commercial documentation

## Sections Available
- `installation-and-upgrade`
- `client-configuration` 
- `administration`
- `reference`
- `retail`
- `common-workflows`
- `specialized-guides`
- `legal`

## Testing Plan
- Test normal builds: `make antora-uyuni-en`
- Test debug builds: `make DEBUG=1 antora-uyuni-en` 
- Test PDF builds: `make DEBUG=1 pdf-administration-uyuni-en`
- Test help system: `make help`
- Test color output: `make test-colors`
- Test error handling: Intentional failures
- Test all languages: en, ja, ko, zh_CN

## Backwards Compatibility & CI/CD Constraints

### Critical Requirements
- **Docker Container Compatibility**: Must work in GitHub Actions Docker containers
- **Existing Command Preservation**: All current commands must work identically
- **No Output Changes**: Default output must remain the same for CI parsing
- **Environment Detection**: Auto-disable colors in non-interactive environments

### CI/CD Considerations
- GitHub Actions uses Docker containers for builds
- Automated scripts expect consistent output format
- Color codes can break log parsing and artifact processing
- Commands like `antora-uyuni-en`, `pdf-all-uyuni-en` must remain unchanged

### Safe Enhancement Approach
- Colors only enabled in interactive terminals (TTY detection)
- DEBUG mode is purely additive (opt-in only)
- Default behavior remains exactly the same
- CI environments automatically get plain output

## Success Criteria
1. ✅ Clear colored output distinguishing info/warn/error
2. ✅ Debug mode shows full build details when needed
3. ✅ Enhanced help clearly categorizes commands by purpose
4. ✅ Progress indicators for long-running operations
5. ✅ Better error messages with context
6. ✅ All existing workflows remain functional
