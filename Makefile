# Makefile for SUSE Manager/Uyuni Documentation
# Author: Joseph Cayouette, Pau Garcia Quiles
# Inspired/modified from Owncloud's documentation Makefile
SHELL = bash

# SUMA Productname and file replacement
PRODUCTNAME_SUMA ?= 'SUSE Manager'
FILENAME_SUMA ?= suse_manager
SUMA_CONTENT ?= true

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

SUPPLEMENTAL_FILES_SUMA=$(shell grep supplemental_files site.yml | cut -d ':' -f 2 | sed "s, ,,g")/partials/header-content.hbs
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

define enable-suma-in-antorayml
	$(call reset-html-language-selector-suma)
	cd ./$(1) && \
	sed -i "s/^ # *\(name: *suse-manager\)/\1/;\
	s/^ # *\(title: *SUSE Manager\)/\1/;\
	s/^ *\(title: *Uyuni\)/#\1/;\
	s/^ *\(name: *uyuni\)/#\1/;" $(current_dir)/$(1)/antora.yml
	cd $(current_dir)
endef

define antora-suma-function
	cd $(current_dir)
	$(call enable-suma-in-antorayml,$(1)) && \
	cd $(current_dir)/$(1) && DOCSEARCH_ENABLED=true SITE_SEARCH_PROVIDER=lunr LANG=$(2) LC_ALL=$(2) LC_ALL=$(2) npx antora $(current_dir)/$(1)/suma-site.yml --stacktrace
endef

define enable-uyuni-in-antorayml
	$(call reset-html-language-selector-uyuni)
	cd $(current_dir)/$(1) && \
	sed -i "s/^ *\(name: *suse-manager\)/#\1/;\
	s/^ *\(title: *SUSE Manager\)/#\1/;\
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

define enable-suma-html-language-selector
	$(call enable-html-language-selector,$(1),$(2),$(3),$(4),$(SUPPLEMENTAL_FILES_SUMA))
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

# SUMA Book Builder
define pdf-book-create
	cd $(current_dir)/$(1) && LANG=$(9) LC_ALL=$(9) LC_TYPE=$(9) asciidoctor-pdf \
		-r $(current_dir)/extensions/xref-converter.rb \
		-a lang=$(8) \
		-a pdf-themesdir=$(PDF_THEME_DIR)/ \
		-a pdf-theme=$(2) \
		-a pdf-fontsdir=$(PDF_FONTS_DIR) \
		-a productname=$(3) \
		-a suma-content=$(4) \
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

# Help Menu
PHONY: help
help: ## Prints a basic help menu about available targets
	@IFS=$$'\n' ; \
	help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/:/'`); \
	printf "%-30s %s\n" "target" "help" ; \
	printf "%-30s %s\n" "------" "----" ; \
	for help_line in $${help_lines[@]}; do \
		IFS=$$':' ; \
		help_split=($$help_line) ; \
		help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
		help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
		printf '\033[36m'; \
		printf "%-30s %s" $$help_command ; \
		printf '\033[0m'; \
		printf "%s\n" $$help_info; \
	done

.PHONY: configure-suma
configure-suma:
	./configure suma

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

.PHONY: configure-suma-branding-dsc
configure-suma-branding-dsc:
	sed -i -e 's|supplemental_files: ./branding/supplemental-ui/suma/.*|supplemental_files: ./branding/supplemental-ui/suma/susecom-2023|' site.yml
	cat site.yml

.PHONY: configure-suma-branding-webui
configure-suma-branding-webui:
	sed -i -e 's|supplemental_files: ./branding/supplemental-ui/suma/.*|supplemental_files: ./branding/supplemental-ui/suma/webui-2023|' site.yml
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

.PHONY: antora-suma-for-publication
antora-suma-for-publication: for-publication antora-suma

.PHONY: antora-uyuni-for-publication
antora-uyuni-for-publication: for-publication antora-uyuni

.PHONY: set-html-language-selector-suma
set-html-language-selector-suma:
	cd $(current_dir)
	$(call enable-suma-html-language-selector,zh_CN,china,china,中文)
	$(call enable-suma-html-language-selector,ja,jaFlag,japan,日本語)
	$(call enable-suma-html-language-selector,ko,koFlag,korea,한국어)

.PHONY: set-html-language-selector-uyuni
set-html-language-selector-uyuni:
	cd $(current_dir)
	$(call enable-uyuni-html-language-selector,zh_CN,china,china,中文)
	$(call enable-uyuni-html-language-selector,ja,jaFlag,japan,日本語)
	$(call enable-uyuni-html-language-selector,ko,koFlag,korea,한국어)

.PHONY: all-suma
all-suma: configure-suma obs-packages-suma

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
