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

# Color definitions
CYAN := $(shell tput setaf 6)
GREEN := $(shell tput setaf 2)
YELLOW := $(shell tput setaf 3)
BLUE := $(shell tput setaf 4)
MAGENTA := $(shell tput setaf 5)
RED := $(shell tput setaf 1)
RESET := $(shell tput sgr0)
BOLD := $(shell tput bold)

# Default target - show help
.DEFAULT_GOAL := help

# Help Menu
.PHONY: help
help:
	@printf "$(CYAN)============================================$(RESET)\n"
	@printf "$(BOLD)   Uyuni Documentation Build System$(RESET)\n"
	@printf "$(CYAN)============================================$(RESET)\n"
	@printf "\n"
	@printf "$(GREEN)CONFIGURATION:$(RESET) $(YELLOW)(Run this first to configure your product)$(RESET)\n"
	@printf "  $(CYAN)configure-uyuni$(RESET)                Configure for Uyuni builds\n"
	@printf "  $(CYAN)configure-mlm$(RESET)                  Configure for SUSE MLM builds\n"
	@printf "\n"
	@printf "$(GREEN)QUICK START EXAMPLES:$(RESET)\n"
	@printf "  $(CYAN)make html-uyuni$(RESET)                Build Uyuni HTML for ALL languages (fast)\n"
	@printf "  $(CYAN)make html-uyuni-en$(RESET)             Build Uyuni HTML only (fast, single language)\n"
	@printf "  $(CYAN)make antora-uyuni-en$(RESET)           Build Uyuni HTML + PDFs (complete, single language)\n"
	@printf "  $(CYAN)make obs-packages-uyuni$(RESET)        Build complete Uyuni for ALL languages + packaging\n"
	@printf "  $(CYAN)make clean-en$(RESET)                  Clean English build artifacts\n"
	@printf "\n"
	@printf "$(GREEN)HTML DOCUMENTATION BUILDS:$(RESET)\n"
	@printf "  $(CYAN)html-uyuni-<lang>$(RESET)              Build Uyuni HTML only (fast development)\n"
	@printf "  $(CYAN)html-mlm-<lang>$(RESET)                Build SUSE MLM HTML only (fast development)\n"
	@printf "  $(CYAN)antora-uyuni-<lang>$(RESET)            Build Uyuni HTML + PDF (complete build)\n"
	@printf "  $(CYAN)antora-mlm-<lang>$(RESET)              Build SUSE MLM HTML + PDF (complete build)\n"
	@printf "\n"
	@printf "$(GREEN)PDF DOCUMENTATION BUILDS:$(RESET)\n"
	@printf "  $(CYAN)pdf-all-uyuni-<lang>$(RESET)           Build ALL Uyuni PDF guides\n"
	@printf "  $(CYAN)pdf-all-mlm-<lang>$(RESET)             Build ALL SUSE MLM PDF guides\n"
	@printf "  $(CYAN)pdf-<section>-uyuni-<lang>$(RESET)     Build single Uyuni PDF guide\n"
	@printf "  $(CYAN)pdf-<section>-mlm-<lang>$(RESET)       Build single SUSE MLM PDF guide\n"
	@printf "\n"
	@printf "$(GREEN)COMPLETE BUILD + PACKAGING:$(RESET)\n"
	@printf "  $(CYAN)obs-packages-uyuni$(RESET)             Complete Uyuni build for ALL languages\n"
	@printf "  $(CYAN)obs-packages-mlm$(RESET)               Complete SUSE MLM build for ALL languages\n"
	@printf "  $(CYAN)obs-packages-uyuni-<lang>$(RESET)      Complete Uyuni build (single language)\n"
	@printf "  $(CYAN)obs-packages-mlm-<lang>$(RESET)        Complete SUSE MLM build (single language)\n"
	@printf "\n"
	@printf "$(GREEN)VALIDATION & QUALITY:$(RESET)\n"
	@printf "  $(CYAN)validate-uyuni-<lang>$(RESET)          Validate Uyuni documentation structure\n"
	@printf "  $(CYAN)validate-mlm-<lang>$(RESET)            Validate SUSE MLM documentation structure\n"
	@printf "  $(CYAN)checkstyle$(RESET)                     Check AsciiDoc style compliance\n"
	@printf "  $(CYAN)checkstyle-autofix$(RESET)             Auto-fix AsciiDoc style issues\n"
	@printf "\n"
	@printf "$(GREEN)MAINTENANCE & CLEANUP:$(RESET)\n"
	@printf "  $(CYAN)clean-<lang>$(RESET)                   Remove build artifacts for specific language\n"
	@printf "  $(CYAN)clean$(RESET)                          Remove all build artifacts\n"
	@printf "  $(CYAN)clean-branding$(RESET)                 Remove all branding files\n"
	@printf "\n"
	@printf "$(GREEN)DEBUG & DEVELOPMENT:$(RESET)\n"
	@printf "  $(CYAN)debug-help$(RESET)                     Show debug usage and test colors\n"
	@printf "  $(CYAN)test-colors$(RESET)                    Test color output functionality\n"
	@printf "  $(CYAN)list-targets$(RESET)                   List all available build targets\n"
	@printf "\n"
	@printf "$(GREEN)AVAILABLE LANGUAGES:$(RESET)\n"
	@printf "  $(YELLOW)en$(RESET) (English)    $(YELLOW)ja$(RESET) (Japanese)    $(YELLOW)ko$(RESET) (Korean)    $(YELLOW)zh_CN$(RESET) (Chinese)\n"
	@printf "\n"
	@printf "$(GREEN)AVAILABLE PDF SECTIONS:$(RESET)\n"
	@printf "  $(YELLOW)installation-and-upgrade$(RESET)      $(YELLOW)client-configuration$(RESET)      $(YELLOW)administration$(RESET)\n"
	@printf "  $(YELLOW)reference$(RESET)                     $(YELLOW)retail$(RESET)                    $(YELLOW)common-workflows$(RESET)\n"
	@printf "  $(YELLOW)specialized-guides$(RESET)            $(YELLOW)legal$(RESET)\n"
	@printf "\n"
	@printf "$(GREEN)DEBUG OPTIONS:$(RESET)\n"
	@printf "  $(CYAN)DEBUG=1 <target>$(RESET)               Enable verbose build output\n"
	@printf "  $(CYAN)VERBOSE_LOG=1 <target>$(RESET)         Enable colored progress messages\n"
	@printf "\n"

.PHONY: test-colors
test-colors:
	@printf "$(CYAN)Testing color output:$(RESET)\n"
	@printf "$(GREEN)✓ Green text (success)$(RESET)\n"
	@printf "$(YELLOW)⚠ Yellow text (warning)$(RESET)\n"
	@printf "$(BLUE)ℹ Blue text (info)$(RESET)\n"
	@printf "$(MAGENTA)✦ Magenta text (special)$(RESET)\n"
	@printf "$(CYAN)➜ Cyan text (commands)$(RESET)\n"
	@printf "$(BOLD)Bold text$(RESET)\n"

.PHONY: debug-help
debug-help:
	@printf "$(CYAN)============================================$(RESET)\n"
	@printf "$(BOLD)   Debug and Development Help$(RESET)\n"
	@printf "$(CYAN)============================================$(RESET)\n"
	@printf "\n"
	@printf "$(GREEN)Available Debug Options:$(RESET)\n"
	@printf "  $(CYAN)DEBUG=1$(RESET)          Enable verbose output for troubleshooting\n"
	@printf "  $(CYAN)VERBOSE_LOG=1$(RESET)    Enable colored progress messages during build\n"
	@printf "\n"
	@printf "$(GREEN)Examples:$(RESET)\n"
	@printf "  $(YELLOW)make DEBUG=1 html-uyuni-en$(RESET)         Build with verbose output\n"
	@printf "  $(YELLOW)make VERBOSE_LOG=1 antora-uyuni$(RESET)    Build with colored progress\n"
	@printf "\n"

.PHONY: list-targets
list-targets:
	@printf "$(CYAN)============================================$(RESET)\n"
	@printf "$(BOLD)   All Available Make Targets$(RESET)\n"
	@printf "$(CYAN)============================================$(RESET)\n"
	@printf "\n"
	@$(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | \
		awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | \
		sort | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$' | \
		pr -t -w 80 -4

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
	$(current_dir)/use_po.sh

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
all-mlm: configure-mlm obs-packages-mlm

.PHONY: all-uyuni
all-uyuni: configure-uyuni obs-packages-uyuni

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
