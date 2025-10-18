# Makefile for SUSE Multi Linux Manager/Uyuni Documentation
# Author: Joseph Cayouette, Pau Garcia Quiles
SHELL = bash

# MLM Productname and file replacement
PRODUCTNAME_MLM ?= 'SUSE Multi-Linux Manager'
FILENAME_MLM ?= suse_multi_linux_manager
MLM_CONTENT ?= true

# UYUNI Productname and file replacement
PRODUCTNAME_UYUNI ?= 'Uyuni'
FILENAME_UYUNI ?= uyuni
UYUNI_CONTENT ?= true

# PDF Resource Locations
PDF_FONTS_DIR ?= branding/pdf/fonts
PDF_THEME_DIR ?= branding/pdf/themes

# UYUNI PDF Themes
# Available Choices set variable
# uyuni-draft
# uyuni

PDF_THEME_UYUNI ?= uyuni

# UYUNI Chinese PDF Theme
PDF_THEME_UYUNI_CJK ?= uyuni-cjk

SUPPLEMENTAL_FILES_MLM=$(shell grep supplemental_files site.yml | cut -d ':' -f 2 | sed "s, ,,g")/partials/header-content.hbs
SUPPLEMENTAL_FILES_UYUNI=$(shell grep supplemental_files site.yml | cut -d ':' -f 2 | sed "s, ,,g")/partials/header-content.hbs

#REVDATE ?= "$(shell date +'%B %d, %Y')"
CURDIR ?= .

# Build directories for TAR
HTML_BUILD_DIR := build

# Determine root directory
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(dir $(mkfile_path))

# Function definition
define validate-product
	cd $(current_dir)/$(1)
	NODE_PATH="$(npm -g root)" antora --generator @antora/xref-validator $(2)
endef

define enable-mlm-in-antorayml
	$(call reset-html-language-selector-mlm)
	cd ./$(1) && \
	sed -i "s/^ # *\(name: *docs\)/\1/;\
	s/^ # *\(title: *docs\)/\1/;\
	s/^ *\(title: *Uyuni\)/#\1/;\
	s/^ *\(name: *uyuni\)/#\1/;" $(current_dir)/$(1)/antora.yml
	cd $(current_dir)
endef

define antora-mlm-function
	cd $(current_dir)
	$(call enable-mlm-in-antorayml,$(1)) && \
	cd $(current_dir)/$(1) && DOCSEARCH_ENABLED=true SITE_SEARCH_PROVIDER=lunr LANG=$(2) LC_ALL=$(2) LC_ALL=$(2) npx antora $(current_dir)/$(1)/mlm-site.yml --stacktrace
endef

define enable-uyuni-in-antorayml
	$(call reset-html-language-selector-uyuni)
	cd $(current_dir)/$(1) && \
	sed -i "s/^ *\(name: *docs\)/#\1/;\
	s/^ *\(title: *Docs\)/#\1/;\
	s/^ *# *\(title: *Uyuni\)/\1/;\
	s/^ *# *\(name: *uyuni\)/\1/;" $(current_dir)/$(1)/antora.yml
endef

define antora-uyuni-function
	cd $(current_dir)
	$(call enable-uyuni-in-antorayml,$(1)) && \
	cd $(current_dir)/$(1) && DOCSEARCH_ENABLED=true SITE_SEARCH_PROVIDER=lunr LANG=$(2) LC_ALL=$(2) LC_ALL=$(2) npx antora $(current_dir)/$(1)/uyuni-site.yml
endef

define clean-function
	cd $(current_dir)
	rm -rf build/$(2)  #e.g. build/en
	rm -rf $(1)        #e.g. translations/en
	rm -rf Makefile.$(2)
	find . -name "*pdf.$(2).adoc" -type f -exec rm -f {} \;
endef

# Enable HTML language selector
# Parameters
# $(1) language code, e. g. "en", "es", "zh_CN"
# $(2) filename with the flag, e. g. "espFlag". Without extension, .svg will be appended.
# $(3) name of the icon in the fonticon, e. g. "english", "spanish". Depends on the font.
# $(4) language name as the user will see it in the selector
# $(5) supplemental files directory (theme directory)
define enable-html-language-selector
	cd $(current_dir)
	sed -n -i 'p; s,<\!--\ LANGUAGESELECTOR\ -->,<a role=\"button\" class=\"navbar-item\" id=\"$(1)\" onclick="selectLanguage(this.id)"><img src="{{uiRootPath}}/img/$(2).svg" class="langIcon $(3)">\&nbsp;$(4)</a>,p' translations/$(5)
endef

define enable-mlm-html-language-selector
	$(call enable-html-language-selector,$(1),$(2),$(3),$(4),$(SUPPLEMENTAL_FILES_MLM))
endef

define enable-uyuni-html-language-selector
	$(call enable-html-language-selector,$(1),$(2),$(3),$(4),$(SUPPLEMENTAL_FILES_UYUNI))
endef

# Create tar of PDF files
define pdf-tar-product
	cd $(current_dir)/$(HTML_BUILD_DIR) && zip -r9 $(2).zip $(shell realpath --relative-to=`pwd`/$(HTML_BUILD_DIR) $(3)) && mv $(2).zip $(1)/ && cd $(current_dir)
endef

# Generate OBS tar files
define obs-packages-product
	cd $(current_dir)
	tar --exclude='$(2)' -czvf $(3).tar.gz -C $(current_dir) $(HTML_BUILD_DIR)/$(1) && tar -czvf $(4).tar.gz -C $(current_dir) $(HTML_BUILD_DIR)/$(2)
	mkdir -p build/packages
	mv $(3).tar.gz $(4).tar.gz build/packages
endef

# mlm Book Builder
define pdf-book-create
	cd $(current_dir)/$(1) && LANG=$(9) LC_ALL=$(9) LC_TYPE=$(9) asciidoctor-pdf \
		-r $(current_dir)/extensions/xref-converter.rb \
		-a lang=$(8) \
		-a pdf-themesdir=$(PDF_THEME_DIR)/ \
		-a pdf-theme=$(2) \
		-a pdf-fontsdir=$(PDF_FONTS_DIR) \
		-a productname=$(3) \
		-a mlm-content=$(4) \
		-a examplesdir=modules/$(6)/examples \
		-a imagesdir=modules/$(6)/assets/images \
		-a revdate="$(shell LANG=$(9) LC_ALL=$(9) LC_TYPE=$(9) date +'$(10)')" \
		$(11) \
		--base-dir . \
		--out-file $(7)/$(5)_$(6)_guide.pdf \
		modules/$(6)/nav-$(6)-guide.pdf.$(8).adoc \
		--trace
endef

define pdf-book-create-uyuni
	cd $(current_dir)/$(1) && LANG=$(9) LC_ALL=$(9) LC_TYPE=$(9) asciidoctor-pdf \
		-r $(current_dir)/extensions/xref-converter.rb \
		-a lang=$(8) \
		-a pdf-themesdir=$(PDF_THEME_DIR)/ \
		-a pdf-theme=$(2) \
		-a pdf-fontsdir=$(PDF_FONTS_DIR) \
		-a productname=$(3) \
		-a uyuni-content=$(4) \
		-a examplesdir=modules/$(6)/examples \
		-a imagesdir=modules/$(6)/assets/images \
		-a revdate="$(shell LANG=$(9) LC_ALL=$(9) LC_TYPE=$(9) date +'$(10)')" \
		$(11) \
		--base-dir . \
		--out-file $(7)/$(5)_$(6)_guide.pdf \
		modules/$(6)/nav-$(6)-guide.pdf.$(8).adoc \
		--trace
endef

define clean-branding
	cd $(current_dir)
        rm -rf $(current_dir)/translations/$(1)/branding
endef

define copy-branding
	cd $(current_dir)
        mkdir -p $(current_dir)/translations/$(1)
        cp -a $(current_dir)/branding $(current_dir)/translations/$(1)/
endef

# Create an Index
define pdf-book-create-index
	cd $(current_dir)
	sed -E  -e 's/\*\*\*\*\*\ xref\:(.*)\.adoc\[(.*)\]/include\:\:modules\/$(2)\/pages\/\1\.adoc\[leveloffset\=\+4\]/' \
		-e 's/\*\*\*\*\ xref\:(.*)\.adoc\[(.*)\]/include\:\:modules\/$(2)\/pages\/\1\.adoc\[leveloffset\=\+3\]/' \
		-e 's/\*\*\*\ xref\:(.*)\.adoc\[(.*)\]/include\:\:modules\/$(2)\/pages\/\1\.adoc\[leveloffset\=\+2\]/' \
		-e 's/\*\*\ xref\:(.*)\.adoc\[(.*)\]/include\:\:modules\/$(2)\/pages\/\1\.adoc\[leveloffset\=\+1\]/' \
		-e 's/\*\ xref\:(.*)\.adoc\[(.*)\]/include\:\:modules\/$(2)\/pages\/\1\.adoc\[leveloffset\=\+0\]/' \
		-e 's/\*\*\*\*\ (.*)/==== \1/' \
		-e 's/\*\*\*\ (.*)/=== \1/' \
		-e 's/\*\*\ (.*)/== \1/' \
		-e 's/\*\ (.*)/= \1/' \
		$(1)/modules/$(2)/nav-$(2)-guide.adoc > $(1)/modules/$(2)/nav-$(2)-guide.pdf.$(3).adoc
endef

# Color definitions - safer detection with manual override
# Check for explicit CI environments
CI_ENV := $(shell [ -n "$$CI" -o -n "$$GITHUB_ACTIONS" -o -n "$$JENKINS_URL" -o -n "$$GITLAB_CI" ] && echo 1 || echo 0)
# Check for color support (can be overridden with FORCE_COLOR=1)
FORCE_COLOR ?= 0
NO_COLOR ?= 0

# Determine if we should use colors
USE_COLORS := 0
ifeq ($(CI_ENV),0)
    ifeq ($(NO_COLOR),0)
        ifeq ($(FORCE_COLOR),1)
            USE_COLORS := 1
        else
            # Check if terminal supports colors (more permissive check)
            USE_COLORS := $(shell [ -t 1 -o -n "$$TERM" ] && echo 1 || echo 0)
        endif
    endif
endif

# Color codes (conditional based on USE_COLORS)
ifeq ($(USE_COLORS),1)
    RED := \033[0;31m
    YELLOW := \033[0;33m
    GREEN := \033[0;32m
    BLUE := \033[0;34m
    CYAN := \033[0;36m
    BOLD := \033[1m
    NC := \033[0m
else
    RED := 
    YELLOW := 
    GREEN := 
    BLUE := 
    CYAN := 
    BOLD := 
    NC := 
endif

# Debug mode control (opt-in only, doesn't affect CI/CD)
DEBUG ?= 0
VERBOSE_LOG ?= 0
QUIET := $(if $(filter 1,$(DEBUG)),,@)

# Safe logging functions - only show enhanced output if explicitly enabled
define log_info
	$(if $(filter 1,$(VERBOSE_LOG)),$(QUIET)echo -e "$(CYAN)[INFO]$(NC) $(1)",)
endef

define log_success
	$(if $(filter 1,$(VERBOSE_LOG)),$(QUIET)echo -e "$(GREEN)[SUCCESS]$(NC) $(1)",)
endef

define log_warn
	$(if $(filter 1,$(VERBOSE_LOG)),$(QUIET)echo -e "$(YELLOW)[WARN]$(NC) $(1)",)
endef

define log_error
	$(if $(filter 1,$(VERBOSE_LOG)),$(QUIET)echo -e "$(RED)[ERROR]$(NC) $(1)",)
endef

define log_build
	$(if $(filter 1,$(DEBUG)),$(QUIET)printf "$(BLUE)[BUILD]$(NC) %s\n" "$(1)",)
endef

# Real-time progress bar system for builds
define start_build_progress
	$(if $(filter 1,$(VERBOSE_LOG)),,$(QUIET)echo -e "$(BLUE)⟲$(NC) $(1)")
endef

define run_with_progress
	$(if $(filter 1,$(DEBUG)), \
		$(MAKE) $(3), \
		$(if $(filter 1,$(VERBOSE_LOG)), \
			$(SILENT_MAKE) $(3) $(if $(4),> /dev/null 2>&1,), \
			@bash -c ' \
		logfile="/tmp/build_$(shell echo $(2) | tr "/" "_").log"; \
		echo -ne "$(CYAN)$(1)$(NC) [$(2)] "; \
		for i in {1..40}; do echo -n "▒"; done; \
		echo -ne "\r$(CYAN)$(1)$(NC) [$(2)] "; \
		( $(SILENT_MAKE) $(3) > "$$logfile" 2>&1 ) & \
		BUILD_PID=$$!; \
		i=0; \
		while kill -0 $$BUILD_PID 2>/dev/null; do \
			sleep 0.5; \
			i=$$((i + 1)); \
			bars=$$((i % 30 + 1)); \
			echo -ne "\r$(CYAN)$(1)$(NC) [$(2)] "; \
			for ((j=1; j<=bars; j++)); do \
				if [ $$j -le $$((bars/3)) ]; then \
					echo -ne "$(GREEN)█$(NC)"; \
				elif [ $$j -le $$((bars*2/3)) ]; then \
					echo -ne "$(YELLOW)█$(NC)"; \
				else \
					echo -ne "$(BLUE)█$(NC)"; \
				fi; \
			done; \
			for ((j=bars+1; j<=40; j++)); do echo -n "▒"; done; \
		done; \
		wait $$BUILD_PID; \
		BUILD_EXIT=$$?; \
		if [ $$BUILD_EXIT -eq 0 ]; then \
			echo -ne "\r$(CYAN)$(1)$(NC) [$(2)] "; \
			for i in {1..40}; do echo -ne "$(GREEN)█$(NC)"; done; \
			echo -e " $(GREEN)✓$(NC)"; \
			warnings=$$(grep -i -E "(warning|warn)" "$$logfile" 2>/dev/null); \
			if [ -n "$$warnings" ]; then \
				echo "$$warnings" | while read line; do \
					printf "  \033[0;33m⚠\033[0m  %s\n" "$$line"; \
				done; \
			fi; \
		else \
			echo -ne "\r$(CYAN)$(1)$(NC) [$(2)] "; \
			for i in {1..40}; do echo -ne "$(RED)█$(NC)"; done; \
			echo -e " $(RED)✗$(NC)"; \
			echo "Build failed. Recent errors:"; \
			grep -i -E "(error|fail)" "$$logfile" 2>/dev/null | tail -5 | while read line; do printf "  \033[0;31m⚠\033[0m  %s\n" "$$line"; done; \
			exit $$BUILD_EXIT; \
		fi; \
		rm -f "$$logfile"'))
endef

define finish_build_progress
	$(if $(filter 1,$(VERBOSE_LOG)),,$(QUIET)echo -e "$(GREEN)✓$(NC) $(1)")
endef

# Silent make for clean output
SILENT_MAKE := $(MAKE) --no-print-directory

# Main Help Menu (organized and colored)
.PHONY: help
help: ## Show comprehensive help with command categories and colors
	@printf "\n"
	@printf "$(CYAN)==========================================\n"  
	@printf "$(BOLD)$(CYAN)  Uyuni Documentation Build System\n"
	@printf "$(CYAN)==========================================$(NC)\n"
	@printf "\n"
	@printf "$(BOLD)$(GREEN)QUICK START EXAMPLES:$(NC)\n"
	@printf "  $(GREEN)make html-uyuni$(NC)                  Build Uyuni HTML for ALL languages (fast)\n"
	@printf "  $(GREEN)make html-uyuni-en$(NC)               Build Uyuni HTML only (fast, single language)\n"
	@printf "  $(GREEN)make antora-uyuni-en$(NC)             Build Uyuni HTML + PDFs (complete, single language)\n" 
	@printf "  $(GREEN)make obs-packages-uyuni$(NC)          Build complete Uyuni for ALL languages + packaging\n"
	@printf "  $(GREEN)make clean-en$(NC)                    Clean English build artifacts\n"
	@printf "\n"
	@printf "$(BOLD)$(CYAN)HTML DOCUMENTATION BUILDS:$(NC)\n"
	@printf "  $(GREEN)html-uyuni-<lang>$(NC)                Build Uyuni HTML only (fast development)\n"
	@printf "  $(GREEN)html-mlm-<lang>$(NC)                  Build SUSE MLM HTML only (fast development)\n"
	@printf "  $(GREEN)antora-uyuni-<lang>$(NC)              Build Uyuni HTML + PDF (complete build)\n"
	@printf "  $(GREEN)antora-mlm-<lang>$(NC)                Build SUSE MLM HTML + PDF (complete build)\n"
	@printf "\n"
	@printf "$(BOLD)$(CYAN)PDF DOCUMENTATION BUILDS:$(NC)\n"
	@printf "  $(GREEN)pdf-all-uyuni-<lang>$(NC)             Build ALL Uyuni PDF guides\n"
	@printf "  $(GREEN)pdf-all-mlm-<lang>$(NC)               Build ALL SUSE MLM PDF guides\n"
	@printf "  $(GREEN)pdf-<section>-uyuni-<lang>$(NC)       Build single Uyuni PDF guide\n"
	@printf "  $(GREEN)pdf-<section>-mlm-<lang>$(NC)         Build single SUSE MLM PDF guide\n"
	@printf "\n"
	@printf "$(BOLD)$(CYAN)COMPLETE BUILD + PACKAGING:$(NC)\n"
	@printf "  $(GREEN)obs-packages-uyuni$(NC)               Complete Uyuni build for ALL languages\n"
	@printf "  $(GREEN)obs-packages-mlm$(NC)                 Complete SUSE MLM build for ALL languages\n"
	@printf "  $(GREEN)obs-packages-uyuni-<lang>$(NC)        Complete Uyuni build (single language)\n"
	@printf "  $(GREEN)obs-packages-mlm-<lang>$(NC)          Complete SUSE MLM build (single language)\n"
	@printf "\n"
	@printf "$(BOLD)$(CYAN)VALIDATION & QUALITY:$(NC)\n"
	@printf "  $(GREEN)validate-uyuni-<lang>$(NC)            Validate Uyuni documentation structure\n"
	@printf "  $(GREEN)validate-mlm-<lang>$(NC)              Validate SUSE MLM documentation structure\n"
	@printf "  $(GREEN)checkstyle$(NC)                       Check AsciiDoc style compliance\n"
	@printf "  $(GREEN)checkstyle-autofix$(NC)               Auto-fix AsciiDoc style issues\n"
	@printf "\n"
	@printf "$(BOLD)$(CYAN)MAINTENANCE & CLEANUP:$(NC)\n"
	@printf "  $(GREEN)clean-<lang>$(NC)                     Remove build artifacts for specific language\n"
	@printf "  $(GREEN)clean$(NC)                            Remove all build artifacts\n"
	@printf "  $(GREEN)clean-branding$(NC)                   Remove all branding files\n"
	@printf "\n"
	@printf "$(BOLD)$(BLUE)DEBUG & DEVELOPMENT:$(NC)\n"
	@printf "  $(BLUE)debug-help$(NC)                       Show debug usage and test colors\n"
	@printf "  $(BLUE)test-colors$(NC)                      Test color output functionality\n"  
	@printf "  $(BLUE)list-targets$(NC)                     List all available build targets\n"
	@printf "\n"
	@printf "$(BOLD)$(YELLOW)AVAILABLE LANGUAGES:$(NC)\n"
	@printf "  $(YELLOW)en$(NC) (English)    $(YELLOW)ja$(NC) (Japanese)    $(YELLOW)ko$(NC) (Korean)    $(YELLOW)zh_CN$(NC) (Chinese)\n"
	@printf "\n"
	@printf "$(BOLD)$(YELLOW)AVAILABLE PDF SECTIONS:$(NC)\n"
	@printf "  $(YELLOW)installation-and-upgrade$(NC)    $(YELLOW)client-configuration$(NC)    $(YELLOW)administration$(NC)\n"
	@printf "  $(YELLOW)reference$(NC)                   $(YELLOW)retail$(NC)                   $(YELLOW)common-workflows$(NC)\n"
	@printf "  $(YELLOW)specialized-guides$(NC)          $(YELLOW)legal$(NC)\n"
	@printf "\n"
	@printf "$(BOLD)$(BLUE)DEBUG OPTIONS:$(NC)\n"
	@printf "  $(BLUE)DEBUG=1 <target>$(NC)                 Enable verbose build output\n"
	@printf "  $(BLUE)VERBOSE_LOG=1 <target>$(NC)           Enable colored progress messages\n"
	@printf "\n"
	@printf "$(BOLD)$(CYAN)CONFIGURATION:$(NC)\n"
	@printf "  $(GREEN)configure-uyuni$(NC)                  Configure for Uyuni builds\n"
	@printf "  $(GREEN)configure-mlm$(NC)                    Configure for SUSE MLM builds\n"
	@printf "  $(GREEN)translations$(NC)                     Update translation files\n"
	@printf "  $(GREEN)pot$(NC)                              Generate translation templates\n"
	@printf "\n"

# Colored Help Menu (for terminals with good ANSI support)
.PHONY: help-color
help-color: ## Show help with colors (for compatible terminals)
	@printf "\n"
	@printf "$(CYAN)==========================================\n"
	@printf "$(BOLD)  Uyuni Documentation Build System\n"
	@printf "$(CYAN)==========================================$(NC)\n"
	@printf "\n"
	@printf "$(BOLD)$(GREEN)QUICK START EXAMPLES:$(NC)\n"
	@printf "  $(GREEN)make html-uyuni-en$(NC)               Build Uyuni HTML only (fast)\n"
	@printf "  $(GREEN)make antora-uyuni-en$(NC)             Build Uyuni HTML + PDFs (complete)\n"
	@printf "  $(GREEN)make pdf-all-uyuni-en$(NC)            Build all Uyuni PDFs only\n"
	@printf "  $(GREEN)make clean-en$(NC)                    Clean English build artifacts\n"
	@printf "\n"
	@printf "$(BOLD)$(CYAN)HTML DOCUMENTATION BUILDS:$(NC)\n"
	@printf "  $(GREEN)html-uyuni-<lang>$(NC)                Build Uyuni HTML only (fast development)\n"
	@printf "  $(GREEN)html-mlm-<lang>$(NC)                  Build SUSE MLM HTML only (fast development)\n"
	@printf "  $(GREEN)antora-uyuni-<lang>$(NC)              Build Uyuni HTML + PDF (complete build)\n"
	@printf "  $(GREEN)antora-mlm-<lang>$(NC)                Build SUSE MLM HTML + PDF (complete build)\n"
	@printf "\n"
	@printf "$(BOLD)$(CYAN)PDF DOCUMENTATION BUILDS:$(NC)\n"
	@printf "  $(GREEN)pdf-all-uyuni-<lang>$(NC)             Build ALL Uyuni PDF guides\n"
	@printf "  $(GREEN)pdf-all-mlm-<lang>$(NC)               Build ALL SUSE MLM PDF guides\n"
	@printf "  $(GREEN)pdf-<section>-uyuni-<lang>$(NC)       Build single Uyuni PDF guide\n"
	@printf "  $(GREEN)pdf-<section>-mlm-<lang>$(NC)         Build single SUSE MLM PDF guide\n"
	@printf "\n"
	@printf "$(BOLD)$(BLUE)DEBUG & DEVELOPMENT:$(NC)\n"
	@printf "  $(BLUE)debug-help$(NC)                       Show debug usage and test colors\n"
	@printf "  $(BLUE)test-colors$(NC)                      Test color output functionality\n"
	@printf "  $(BLUE)list-targets$(NC)                     List all available build targets\n"
	@printf "\n"
	@printf "$(BOLD)$(YELLOW)AVAILABLE LANGUAGES:$(NC)\n"  
	@printf "  $(YELLOW)en$(NC) (English)    $(YELLOW)ja$(NC) (Japanese)    $(YELLOW)ko$(NC) (Korean)    $(YELLOW)zh_CN$(NC) (Chinese)\n"
	@printf "\n"



.PHONY: debug-help
debug-help: ## Show debug usage and test color output (development tool)
	@echo "$(BOLD)$(CYAN)Debug Mode Usage$(NC)"
	@echo "$(CYAN)================$(NC)"
	@echo ""
	@echo "$(BOLD)Build Output Modes:$(NC)"
	@echo "  $(GREEN)Default$(NC)                          - Clean progress bar with estimated time"
	@echo "  $(BLUE)make VERBOSE_LOG=1 <target>$(NC)       - Enable colored status messages"
	@echo "  $(BLUE)make DEBUG=1 <target>$(NC)             - Enable verbose command output"
	@echo "  $(BLUE)make DEBUG=1 VERBOSE_LOG=1 <target>$(NC) - Enable both debug and colored logs"
	@echo ""
	@echo "$(BOLD)Examples:$(NC)"
	@echo "  $(GREEN)make html-uyuni$(NC)                        - Clean progress with timing"
	@echo "  $(GREEN)make VERBOSE_LOG=1 antora-uyuni$(NC)        - Build with colored status logs"
	@echo "  $(GREEN)make DEBUG=1 pdf-administration-uyuni-en$(NC) - Build PDF with full command output"
	@echo "  $(GREEN)make DEBUG=1 VERBOSE_LOG=1 clean-en$(NC)     - Clean with full verbose logging"
	@echo ""
	@echo "$(BOLD)CI/CD Compatibility:$(NC)"
	@echo "  • Default behavior unchanged for automated builds"
	@echo "  • Colors automatically disabled in CI environments"
	@echo "  • Enhanced features are opt-in only"
	@echo ""
	@echo "$(BOLD)Color Test (if enabled):$(NC)"
	@printf "$(CYAN)[INFO]$(NC) This is an INFO message\n"
	@printf "$(BLUE)[BUILD]$(NC) This is a BUILD message (debug mode)\n"
	@printf "$(GREEN)[SUCCESS]$(NC) This is a SUCCESS message\n"
	@printf "$(YELLOW)[WARN]$(NC) This is a WARNING message\n"
	@printf "$(RED)[ERROR]$(NC) This is an ERROR message\n"

.PHONY: test-colors
test-colors: ## Test color output functionality (development tool)
	@echo "$(BOLD)$(CYAN)Color Output Test$(NC)"
	@echo "$(CYAN)=================$(NC)"
	@echo "Environment Detection:"
	@echo "  CI_ENV: $(CI_ENV)"
	@echo "  USE_COLORS: $(USE_COLORS)"
	@echo "  FORCE_COLOR: $(FORCE_COLOR)"
	@echo "  NO_COLOR: $(NO_COLOR)"
	@echo "  TTY: $(shell [ -t 1 ] && echo "yes" || echo "no")"
	@echo "  TERM: $$TERM"
	@echo ""
	@printf "Color Test:\n"
	@printf "$(CYAN)[INFO]$(NC) Testing INFO level - build information\n"
	@printf "$(BLUE)[BUILD]$(NC) Testing BUILD level - command details\n"
	@printf "$(GREEN)[SUCCESS]$(NC) Testing SUCCESS level - completed ops\n"
	@printf "$(YELLOW)[WARN]$(NC) Testing WARNING level - non-critical\n"
	@printf "$(RED)[ERROR]$(NC) Testing ERROR level - build failures\n"
	@echo ""
	@echo "$(GREEN)✓ Color test completed$(NC)"
	@echo ""
	@echo "To force colors: make FORCE_COLOR=1 test-colors"
	@echo "To disable colors: make NO_COLOR=1 test-colors"

.PHONY: list-targets
list-targets: ## List all available build targets organized by type
	@echo "$(BOLD)$(CYAN)Available Build Targets$(NC)"
	@echo "$(CYAN)========================$(NC)"
	@echo ""
	@echo "$(BOLD)$(GREEN)HTML Targets (Development - Fast):$(NC)"
	@echo "  html-uyuni-{en,ja,ko,zh_CN}    (HTML only, no PDFs)"
	@echo "  html-mlm-{en,ja,ko,zh_CN}      (HTML only, no PDFs)"
	@echo ""
	@echo "$(BOLD)$(GREEN)HTML Targets (Complete - HTML + PDF):$(NC)"
	@echo "  antora-uyuni-{en,ja,ko,zh_CN}  (HTML + all PDFs)"
	@echo "  antora-mlm-{en,ja,ko,zh_CN}    (HTML + all PDFs)"
	@echo ""
	@echo "$(BOLD)$(GREEN)PDF Targets (All Guides):$(NC)"
	@echo "  pdf-all-uyuni-{en,ja,ko,zh_CN}"
	@echo "  pdf-all-mlm-{en,ja,ko,zh_CN}"
	@echo ""
	@echo "$(BOLD)$(GREEN)PDF Targets (Individual Sections):$(NC)"
	@echo "  pdf-{installation-and-upgrade,client-configuration,administration}-{uyuni,mlm}-{en,ja,ko,zh_CN}"
	@echo "  pdf-{reference,retail,common-workflows,specialized-guides,legal}-{uyuni,mlm}-{en,ja,ko,zh_CN}"
	@echo ""
	@echo "$(BOLD)$(GREEN)Complete Build Targets:$(NC)"  
	@echo "  obs-packages-uyuni-{en,ja,ko,zh_CN}"
	@echo "  obs-packages-mlm-{en,ja,ko,zh_CN}"
	@echo ""
	@echo "$(BOLD)$(GREEN)Validation Targets:$(NC)"
	@echo "  validate-uyuni-{en,ja,ko,zh_CN}"
	@echo "  validate-mlm-{en,ja,ko,zh_CN}"
	@echo ""
	@echo "$(BOLD)$(GREEN)Cleanup Targets:$(NC)"
	@echo "  clean-{en,ja,ko,zh_CN}"
	@echo "  clean, clean-branding"

.PHONY: configure-mlm
configure-mlm:
	./configure mlm

.PHONY: configure-uyuni
configure-uyuni:
	./configure uyuni

.PHONY: update-cfg-files
update-cfg-files:
	(cd $(current_dir)/l10n-weblate && ./update-cfg-files)

.PHONY: pot
pot: update-cfg-files
	$(current_dir)/make_pot.sh

.PHONY: translations
translations:
	@echo -e "$(BLUE)⟲$(NC) Processing translations (this may take a moment)..."
	@bash -c ' \
		$(current_dir)/use_po.sh & \
		PO_PID=$$!; \
		echo -ne "$(CYAN)Processing$(NC) "; \
		while kill -0 $$PO_PID 2>/dev/null; do \
			echo -n "."; \
			sleep 1; \
		done; \
		wait $$PO_PID; \
		echo -e " $(GREEN)✓$(NC) Translation processing complete"'

.PHONY: copy-branding
copy-branding:
	cd $(current_dir)
	mkdir -p $(current_dir)/translations
	cp -a $(current_dir)/branding $(current_dir)/translations/

.PHONY: configure-mlm-branding-dsc
configure-mlm-branding-dsc:
	sed -i -e 's|supplemental_files: ./branding/supplemental-ui/mlm/.*|supplemental_files: ./branding/supplemental-ui/mlm/susecom-2025|' site.yml
	cat site.yml

.PHONY: configure-mlm-branding-webui
configure-mlm-branding-webui:
	sed -i -e 's|supplemental_files: ./branding/supplemental-ui/mlm/.*|supplemental_files: ./branding/supplemental-ui/mlm/webui-2025|' site.yml
	cat site.yml

.PHONY: clean-branding
clean-branding:
	rm -rf $(current_dir)/translations/*

.PHONY: clean
clean: clean-branding
	rm -rf $(current_dir)/build/*

.PHONY: for-publication
for-publication:
	touch $(current_dir)/for-publication

.PHONY: antora-mlm-for-publication
antora-mlm-for-publication: for-publication antora-mlm

.PHONY: antora-uyuni-for-publication
antora-uyuni-for-publication: for-publication antora-uyuni

.PHONY: set-html-language-selector-mlm
set-html-language-selector-mlm:
	cd $(current_dir)
	$(call enable-mlm-html-language-selector,zh_CN,china,china,中文)
	$(call enable-mlm-html-language-selector,ja,jaFlag,japan,日本語)
	$(call enable-mlm-html-language-selector,ko,koFlag,korea,한국어)

.PHONY: set-html-language-selector-uyuni
set-html-language-selector-uyuni:
	cd $(current_dir)
	$(call enable-uyuni-html-language-selector,zh_CN,china,china,中文)
	$(call enable-uyuni-html-language-selector,ja,jaFlag,japan,日本語)
	$(call enable-uyuni-html-language-selector,ko,koFlag,korea,한국어)

.PHONY: all-mlm
all-mlm: clean configure-mlm obs-packages-mlm

# HTML All Languages Targets
.PHONY: html-uyuni
html-uyuni: clean configure-uyuni ## Build Uyuni HTML documentation for all languages (fast, no PDFs)
	$(call log_info,Building Uyuni HTML for all languages)
	$(call start_build_progress,Building Uyuni HTML documentation for 4 languages)
	@start_time=$$(date +%s)
	$(call run_with_progress,English    ,1/4,html-uyuni-en,silent)
	$(call run_with_progress,Japanese   ,2/4,html-uyuni-ja,silent)
	$(call run_with_progress,Korean     ,3/4,html-uyuni-ko,silent)  
	$(call run_with_progress,Chinese    ,4/4,html-uyuni-zh_CN,silent)
	@end_time=$$(date +%s); \
	duration=$$((end_time - start_time)); \
	echo -e "$(GREEN)✓$(NC) All languages completed in $${duration}s"
	$(call log_success,Uyuni HTML built for all languages)

.PHONY: html-mlm
html-mlm: clean configure-mlm ## Build SUSE MLM HTML documentation for all languages (fast, no PDFs)
	$(call log_info,Building SUSE MLM HTML for all languages)
	$(call start_build_progress,Building SUSE MLM HTML documentation for 4 languages)
	@start_time=$$(date +%s)
	$(call run_with_progress,English    ,1/4,html-mlm-en,silent)
	$(call run_with_progress,Japanese   ,2/4,html-mlm-ja,silent)
	$(call run_with_progress,Korean     ,3/4,html-mlm-ko,silent)
	$(call run_with_progress,Chinese    ,4/4,html-mlm-zh_CN,silent)
	@end_time=$$(date +%s); \
	duration=$$((end_time - start_time)); \
	echo -e "$(GREEN)✓$(NC) All languages completed in $${duration}s"
	$(call log_success,SUSE MLM HTML built for all languages)

# Complete All Languages Targets  
.PHONY: antora-uyuni
antora-uyuni: clean configure-uyuni ## Build complete Uyuni documentation for all languages (HTML + PDFs)
	$(call log_info,Building complete Uyuni documentation for all languages)
	$(call start_build_progress,Building complete Uyuni documentation with PDFs for 4 languages)
	@start_time=$$(date +%s)
	$(call run_with_progress,English    ,1/4,antora-uyuni-en,silent)
	$(call run_with_progress,Japanese   ,2/4,antora-uyuni-ja,silent)
	$(call run_with_progress,Korean     ,3/4,antora-uyuni-ko,silent)
	$(call run_with_progress,Chinese    ,4/4,antora-uyuni-zh_CN,silent)
	@end_time=$$(date +%s); \
	duration=$$((end_time - start_time)); \
	echo -e "$(GREEN)✓$(NC) Complete documentation with PDFs completed in $${duration}s"
	$(call log_success,Complete Uyuni documentation built for all languages)

.PHONY: antora-mlm
antora-mlm: clean configure-mlm ## Build complete SUSE MLM documentation for all languages (HTML + PDFs)
	$(call log_info,Building complete SUSE MLM documentation for all languages)
	$(call start_build_progress,Building complete SUSE MLM documentation with PDFs for 4 languages)
	@start_time=$$(date +%s)
	$(call run_with_progress,English    ,1/4,antora-mlm-en,silent)
	$(call run_with_progress,Japanese   ,2/4,antora-mlm-ja,silent)
	$(call run_with_progress,Korean     ,3/4,antora-mlm-ko,silent)
	$(call run_with_progress,Chinese    ,4/4,antora-mlm-zh_CN,silent)
	@end_time=$$(date +%s); \
	duration=$$((end_time - start_time)); \
	echo -e "$(GREEN)✓$(NC) Complete documentation with PDFs completed in $${duration}s"
	$(call log_success,Complete SUSE MLM documentation built for all languages)

.PHONY: pdf-all-uyuni-progress
pdf-all-uyuni-progress: configure-uyuni ## Build all Uyuni PDF documentation for all languages (with progress bars)
	$(call log_info,Building all Uyuni PDF documentation for all languages)
	$(call start_build_progress,Building all Uyuni PDF documentation for 4 languages (8 guides each))
	@start_time=$$(date +%s)
	@echo -e "$(CYAN)English [1/4]$(NC) Building all PDF guides..."
	$(call run_with_progress,Installation    ,1.1/8,pdf-installation-and-upgrade-uyuni-en,silent)
	$(call run_with_progress,Client Config   ,1.2/8,pdf-client-configuration-uyuni-en,silent)
	$(call run_with_progress,Administration  ,1.3/8,pdf-administration-uyuni-en,silent)
	$(call run_with_progress,Reference       ,1.4/8,pdf-reference-uyuni-en,silent)
	$(call run_with_progress,Retail          ,1.5/8,pdf-retail-uyuni-en,silent)
	$(call run_with_progress,Common Workflows,1.6/8,pdf-common-workflows-uyuni-en,silent)
	$(call run_with_progress,Special Guides  ,1.7/8,pdf-specialized-guides-uyuni-en,silent)
	$(call run_with_progress,Legal           ,1.8/8,pdf-legal-uyuni-en,silent)
	@echo -e "$(CYAN)Japanese [2/4]$(NC) Building all PDF guides..."
	$(call run_with_progress,Installation    ,2.1/8,pdf-installation-and-upgrade-uyuni-ja,silent)
	$(call run_with_progress,Client Config   ,2.2/8,pdf-client-configuration-uyuni-ja,silent)
	$(call run_with_progress,Administration  ,2.3/8,pdf-administration-uyuni-ja,silent)
	$(call run_with_progress,Reference       ,2.4/8,pdf-reference-uyuni-ja,silent)
	$(call run_with_progress,Retail          ,2.5/8,pdf-retail-uyuni-ja,silent)
	$(call run_with_progress,Common Workflows,2.6/8,pdf-common-workflows-uyuni-ja,silent)
	$(call run_with_progress,Special Guides  ,2.7/8,pdf-specialized-guides-uyuni-ja,silent)
	$(call run_with_progress,Legal           ,2.8/8,pdf-legal-uyuni-ja,silent)
	@echo -e "$(CYAN)Korean [3/4]$(NC) Building all PDF guides..."
	$(call run_with_progress,Installation    ,3.1/8,pdf-installation-and-upgrade-uyuni-ko,silent)
	$(call run_with_progress,Client Config   ,3.2/8,pdf-client-configuration-uyuni-ko,silent)
	$(call run_with_progress,Administration  ,3.3/8,pdf-administration-uyuni-ko,silent)
	$(call run_with_progress,Reference       ,3.4/8,pdf-reference-uyuni-ko,silent)
	$(call run_with_progress,Retail          ,3.5/8,pdf-retail-uyuni-ko,silent)
	$(call run_with_progress,Common Workflows,3.6/8,pdf-common-workflows-uyuni-ko,silent)
	$(call run_with_progress,Special Guides  ,3.7/8,pdf-specialized-guides-uyuni-ko,silent)
	$(call run_with_progress,Legal           ,3.8/8,pdf-legal-uyuni-ko,silent)
	@echo -e "$(CYAN)Chinese [4/4]$(NC) Building all PDF guides..."
	$(call run_with_progress,Installation    ,4.1/8,pdf-installation-and-upgrade-uyuni-zh_CN,silent)
	$(call run_with_progress,Client Config   ,4.2/8,pdf-client-configuration-uyuni-zh_CN,silent)
	$(call run_with_progress,Administration  ,4.3/8,pdf-administration-uyuni-zh_CN,silent)
	$(call run_with_progress,Reference       ,4.4/8,pdf-reference-uyuni-zh_CN,silent)
	$(call run_with_progress,Retail          ,4.5/8,pdf-retail-uyuni-zh_CN,silent)
	$(call run_with_progress,Common Workflows,4.6/8,pdf-common-workflows-uyuni-zh_CN,silent)
	$(call run_with_progress,Special Guides  ,4.7/8,pdf-specialized-guides-uyuni-zh_CN,silent)
	$(call run_with_progress,Legal           ,4.8/8,pdf-legal-uyuni-zh_CN,silent)
	@end_time=$$(date +%s); \
	duration=$$((end_time - start_time)); \
	echo -e "$(GREEN)✓$(NC) All PDF documentation completed in $${duration}s"
	$(call log_success,Uyuni PDF documentation built for all languages)

.PHONY: pdf-all-mlm-progress  
pdf-all-mlm-progress: configure-mlm ## Build all SUSE MLM PDF documentation for all languages (with progress bars)
	$(call log_info,Building all SUSE MLM PDF documentation for all languages)
	$(call start_build_progress,Building all SUSE MLM PDF documentation for 4 languages (8 guides each))
	@start_time=$$(date +%s)
	$(call run_with_pdf_progress,English    ,mlm,en,1/4)
	$(call run_with_pdf_progress,Japanese   ,mlm,ja,2/4)
	$(call run_with_pdf_progress,Korean     ,mlm,ko,3/4)  
	$(call run_with_pdf_progress,Chinese    ,mlm,zh_CN,4/4)
	@end_time=$$(date +%s); \
	duration=$$((end_time - start_time)); \
	echo -e "$(GREEN)✓$(NC) All PDF documentation completed in $${duration}s"
	$(call log_success,SUSE MLM PDF documentation built for all languages)

.PHONY: obs-packages-uyuni-progress
obs-packages-uyuni-progress: clean configure-uyuni ## Build complete Uyuni OBS packages for all languages (with progress bars)
	$(call log_info,Building complete Uyuni OBS packages for all languages)
	$(call start_build_progress,Building complete Uyuni OBS packages for 4 languages)
	@start_time=$$(date +%s)
	$(call run_with_progress,English    ,1/4,obs-packages-uyuni-en,silent)
	$(call run_with_progress,Japanese   ,2/4,obs-packages-uyuni-ja,silent)
	$(call run_with_progress,Korean     ,3/4,obs-packages-uyuni-ko,silent)  
	$(call run_with_progress,Chinese    ,4/4,obs-packages-uyuni-zh_CN,silent)
	@end_time=$$(date +%s); \
	duration=$$((end_time - start_time)); \
	echo -e "$(GREEN)✓$(NC) All OBS packages completed in $${duration}s"
	$(call log_success,Uyuni OBS packages built for all languages)

.PHONY: obs-packages-mlm-progress
obs-packages-mlm-progress: clean configure-mlm ## Build complete SUSE MLM OBS packages for all languages (with progress bars)
	$(call log_info,Building complete SUSE MLM OBS packages for all languages)
	$(call start_build_progress,Building complete SUSE MLM OBS packages for 4 languages)
	@start_time=$$(date +%s)
	$(call run_with_progress,English    ,1/4,obs-packages-mlm-en,silent)
	$(call run_with_progress,Japanese   ,2/4,obs-packages-mlm-ja,silent)
	$(call run_with_progress,Korean     ,3/4,obs-packages-mlm-ko,silent)  
	$(call run_with_progress,Chinese    ,4/4,obs-packages-mlm-zh_CN,silent)
	@end_time=$$(date +%s); \
	duration=$$((end_time - start_time)); \
	echo -e "$(GREEN)✓$(NC) All OBS packages completed in $${duration}s"
	$(call log_success,SUSE MLM OBS packages built for all languages)

.PHONY: all-uyuni
all-uyuni: clean configure-uyuni obs-packages-uyuni

.PHONY: checkstyle
checkstyle:
	cd $(current_dir)
	find -name "*\.adoc" -type f  | xargs -I {} ./enforcing_checkstyle --filename {} --ifeval
	find -name "nav*\.adoc" -type f  | xargs -I {} ./enforcing_checkstyle --filename {} --comment

.PHONY: checkstyle-autofix
checkstyle-autofix:
	cd $(current_dir)
	find -name "*\.adoc" -type f  | xargs -I {} ./enforcing_checkstyle --filename {} --ifeval --fixmode
	find -name "nav*\.adoc" -type f  | xargs -I {} ./enforcing_checkstyle --filename {} --comment --fixmode

-include Makefile.section.functions
-include Makefile.lang
-include Makefile.lang.target
