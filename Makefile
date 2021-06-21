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

# PDF Publishing Themes, draft uses a draft watermark.
# SUMA PDF Themes
# Available Choices set variable
# suse-draft
# suse

PDF_THEME_SUMA ?= suse-draft

# SUMA Chinese PDF Theme
PDF_THEME_SUMA_CJK ?= suse-cjk

# UYUNI PDF Themes
# Available Choices set variable
# uyuni-draft
# uyuni

PDF_THEME_UYUNI ?= uyuni

# UYUNI Chinese PDF Theme
PDF_THEME_UYUNI_CJK ?= uyuni-cjk

H := \#supplemental_files
SUPPLEMENTAL_FILES_SUMA=$(shell grep supplemental_files suma-site.yml | grep -v '$H' | cut -d ':' -f 2 | sed "s, ,,g")/partials/header-content.hbs
SUPPLEMENTAL_FILES_UYUNI=$(shell grep supplemental_files uyuni-site.yml | grep -v '$H' | cut -d ':' -f 2 | sed "s, ,,g")/partials/header-content.hbs
	
#REVDATE ?= "$(shell date +'%B %d, %Y')"
CURDIR ?= .

# Build directories for TAR
HTML_BUILD_DIR := build

# Determine root directory
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(dir $(mkfile_path))

# Function definition
define validate-product
	cd ./$(1)
	NODE_PATH="$(npm -g root)" antora --generator @antora/xref-validator $(2)
endef

define enable-suma-in-antorayml
#	$(call reset-html-language-selector-suma)
	cd ./$(1) && \
	sed -i "s/^ # *\(name: *suse-manager\)/\1/;\
	s/^ # *\(title: *SUSE Manager\)/\1/;\
	s/^ *\(title: *Uyuni\)/#\1/;\
	s/^ *\(name: *uyuni\)/#\1/;" $(current_dir)/$(1)/antora.yml
endef

define antora-suma-function
	$(call enable-suma-in-antorayml,$(1)) && \
	DOCSEARCH_ENABLED=true DOCSEARCH_ENGINE=lunr LANG=$(2) LC_ALL=$(2) LC_ALL=$(2) antora $(current_dir)/$(1)/suma-site.yml --generator antora-site-generator-lunr
endef

define enable-uyuni-in-antorayml
#	$(call reset-html-language-selector-uyuni)
	cd ./$(1) && \
	sed -i "s/^ *\(name: *suse-manager\)/#\1/;\
	s/^ *\(title: *SUSE Manager\)/#\1/;\
	s/^ *# *\(title: *Uyuni\)/\1/;\
	s/^ *# *\(name: *uyuni\)/\1/;" $(current_dir)/$(1)/antora.yml
endef

define antora-uyuni-function
	$(call enable-uyuni-in-antorayml,$(1)) && \
	DOCSEARCH_ENABLED=true DOCSEARCH_ENGINE=lunr LANG=$(2) LC_ALL=$(2) LC_ALL=$(2) antora $(current_dir)/$(1)/uyuni-site.yml --generator antora-site-generator-lunr
endef

define fix-lunr-search-in-suma-translation
	$(call fix-lunr-search-in-translation,suse-manager,$(1))
endef

define fix-lunr-search-in-uyuni-translation
	$(call fix-lunr-search-in-translation,uyuni,$(1))
endef

define fix-lunr-search-in-translation
	$(shell sed -i s,\/$(1)\/,\/$(2)\/$(1)\/,g $(CURDIR)/$(HTML_BUILD_DIR)/$(2)/search-index.js)
endef

define clean-function
	if [ -d ./$(1) ]; then \
		cd ./$(1) && rm -rf build/ \
		translations/ \
		.cache/ \
		public/ \
		modules/installation/nav-installation-guide.pdf.$(2).adoc \
		modules/client-configuration/nav-client-configuration-guide.pdf.$(2).adoc \
		modules/upgrade/nav-upgrade-guide.pdf.$(2).adoc \
		modules/reference/nav-reference-guide.pdf.$(2).adoc \
		modules/administration/nav-administration-guide.pdf.$(2).adoc \
		modules/salt/nav-salt-guide.pdf.$(2).adoc \
		modules/retail/nav-retail-guide.pdf.$(2).adoc \
		modules/quickstart-public-cloud/nav-quickstart-public-cloud-guide.pdf.$(2).adoc \
		modules/large-deployments/nav-large-deployments-guide.pdf.$(2).adoc \
		modules/quickstart-sap/nav-quickstart-sap-guide.pdf.$(2).adoc \
		modules/quickstart-uyuni/nav-quickstart-uyuni-guide.pdf.$(2).adoc; \
	fi
endef

# Enable HTML language selector
# Parameters
# $(1) language code, e. g. "en", "es", "zh_CN"
# $(2) filename with the flag, e. g. "espFlag". Without extension, .svg will be appended.
# $(3) name of the icon in the fonticon, e. g. "english", "spanish". Depends on the font.
# $(4) language name as the user will see it in the selector
# $(5) supplemental files directory (theme directory)
define enable-html-language-selector
	sed -n -i 'p; s,<\!--\ LANGUAGESELECTOR\ -->,<a role=\"button\" class=\"navbar-item\" id=\"$(1)\" onclick="selectLanguage(this.id)"><img src="{{uiRootPath}}/img/$(2).svg" class="langIcon $(3)">\&nbsp;$(4)</a>,p' $(5)
endef

define enable-suma-html-language-selector
	$(call enable-html-language-selector,$(1),$(2),$(3),$(4),$(SUPPLEMENTAL_FILES_SUMA))
endef

define enable-uyuni-html-language-selector
	$(call enable-html-language-selector,$(1),$(2),$(3),$(4),$(SUPPLEMENTAL_FILES_UYUNI))
endef

# Create tar of PDF files
define pdf-tar-product
#	cd ./$(HTML_BUILD_DIR) && tar -czvf $(2).tar.gz $(shell realpath --relative-to=`pwd`/$(HTML_BUILD_DIR) $(3)) && mv $(2).tar.gz $(1)/
	cd ./$(HTML_BUILD_DIR) && zip -r9 $(2).zip $(shell realpath --relative-to=`pwd`/$(HTML_BUILD_DIR) $(3)) && mv $(2).zip $(1)/
endef

# Generate OBS tar files
define obs-packages-product
	tar --exclude='$(2)' -czvf $(3).tar.gz -C $(CURDIR) $(HTML_BUILD_DIR)/$(1) && tar -czvf $(4).tar.gz -C $(CURDIR) $(HTML_BUILD_DIR)/$(2)
	mkdir -p build/packages
	mv $(3).tar.gz $(4).tar.gz build/packages
endef

# SUMA Book Builder
define pdf-book-create
	cd ./$(1) && LANG=$(9) LC_ALL=$(9) LC_TYPE=$(9) asciidoctor-pdf \
		-r $(current_dir)/extensions/xref-converter.rb \
		-a lang=$(8) \
		-a pdf-stylesdir=$(PDF_THEME_DIR)/ \
		-a pdf-style=$(2) \
		-a pdf-fontsdir=$(PDF_FONTS_DIR) \
		-a productname=$(3) \
		-a suma-content=$(4) \
		-a examplesdir=modules/$(6)/examples \
		-a imagesdir=modules/$(6)/assets/images \
		-a revdate="$(shell LANG=$(9) LC_ALL=$(9) LC_TYPE=$(9) date +'$(10)')" \
		--base-dir . \
		--out-file $(7)/$(5)_$(6)_guide.pdf \
		modules/$(6)/nav-$(6)-guide.pdf.$(8).adoc
endef

define pdf-book-create-uyuni
	cd ./$(1) && LANG=$(9) LC_ALL=$(9) LC_TYPE=$(9) asciidoctor-pdf \
		-r $(current_dir)/extensions/xref-converter.rb \
		-a lang=$(8) \
		-a pdf-stylesdir=$(PDF_THEME_DIR)/ \
		-a pdf-style=$(2) \
		-a pdf-fontsdir=$(PDF_FONTS_DIR) \
		-a productname=$(3) \
		-a uyuni-content=$(4) \
		-a examplesdir=modules/$(6)/examples \
		-a imagesdir=modules/$(6)/assets/images \
		-a revdate="$(shell LANG=$(9) LC_ALL=$(9) LC_TYPE=$(9) date +'$(10)')" \
		--base-dir . \
		--out-file $(7)/$(5)_$(6)_guide.pdf \
		modules/$(6)/nav-$(6)-guide.pdf.$(8).adoc
endef

# Create an Index
define pdf-book-create-index
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

# SUMA PDF Books
# Generate PDF version of the Installation Guide
define pdf-install-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),installation,$(6),$(7),$(8),$(9))
endef

# Generate PDF version of the Client Configuration Guide
define pdf-client-configuration-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),client-configuration,$(6),$(7),$(8),$(9))
endef

# Generate PDF version of the Upgrade Guide
define pdf-upgrade-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),upgrade,$(6),$(7),$(8),$(9))
endef

# Generate PDF version of the Reference Guide
define pdf-reference-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),reference,$(6),$(7),$(8),$(9))
endef

# Generate PDF version of the Administration Guide
define pdf-administration-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),administration,$(6),$(7),$(8),$(9))
endef

# Generate PDF version of the Salt Guide
define pdf-salt-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),salt,$(6),$(7),$(8),$(9))
endef

# Generate PDF version of the Retail Guide
define pdf-retail-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),retail,$(6),$(7),$(8),$(9))
endef

# Generate PDF version of the Architecture Guide
#define pdf-architecture-product
#	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),architecture,$(6),$(7),$(8),$(9))
#endef

# Generate PDF version of the Public Cloud Guide
define pdf-quickstart-public-cloud-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),quickstart-public-cloud,$(6),$(7),$(8),$(9))
endef

# Generate PDF version of the SAP Guide
define pdf-quickstart-sap-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),quickstart-sap,$(6),$(7),$(8),$(9))
endef

# Generate PDF version of the Large Deployment Guide
define pdf-large-deployment-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),large-deployments,$(6),$(7),$(8),$(9))
endef

# UYUNI PDF Books
# Generate PDF version of the Installation Guide
define pdf-install-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),installation,$(6),$(7),$(8),$(9))
endef

# Generate PDF version of the Client Configuration Guide
define pdf-client-configuration-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),client-configuration,$(6),$(7),$(8),$(9))
endef

# Generate PDF version of the Upgrade Guide
define pdf-upgrade-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),upgrade,$(6),$(7),$(8),$(9))
endef

# Generate PDF version of the Reference Guide
define pdf-reference-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),reference,$(6),$(7),$(8),$(9))
endef

# Generate PDF version of the Administration Guide
define pdf-administration-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),administration,$(6),$(7),$(8),$(9))
endef

# Generate PDF version of the Salt Guide
define pdf-salt-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),salt,$(6),$(7),$(8),$(9))
endef

# Generate PDF version of the Retail Guide
define pdf-retail-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),retail,$(6),$(7),$(8),$(9))
endef

# Generate PDF version of the Architecture Guide
#define pdf-architecture-product-uyuni
#	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),architecture,$(6),$(7),$(8),$(9))
#endef

# Generate PDF version of the Public Cloud Guide
define pdf-quickstart-public-cloud-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),quickstart-public-cloud,$(6),$(7),$(8),$(9))
endef

# Generate PDF version of the SAP Guide
define pdf-quickstart-sap-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),quickstart-sap,$(6),$(7),$(8),$(9))
endef

# Generate PDF version of the Uyuni Guide
define pdf-quickstart-uyuni-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),quickstart-uyuni,$(6),$(7),$(8),$(9))
endef

# Generate PDF version of the Large Deployment Guide
define pdf-large-deployment-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),large-deployments,$(6),$(7),$(8),$(9))
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

.PHONY: pot
pot:
	(cd l10n-weblate && ./update-cfg-files)
	$(current_dir)/make_pot.sh

.PHONY: translations
translations:
	$(current_dir)/use_po.sh

.PHONY: clean
clean: clean-en clean-zh_CN clean-ja clean-ko # clean-es clean-cs

.PHONY: validate-suma
validate-suma: validate-suma-en validate-suma-zh_CN validate-suma-ja validate-suma-ko # validate-suma-es validate-suma-cs

.PHONY: pdf-tar-suma
pdf-tar-suma: pdf-tar-suma-en pdf-tar-suma-zh_CN pdf-tar-suma-ja pdf-tar-suma-ko # pdf-tar-suma-es pdf-tar-suma-cs

.PHONY: antora-suma
antora-suma: set-html-language-selector-suma antora-suma-en antora-suma-zh_CN antora-suma-ja antora-suma-ko fix-lunr-search-in-suma-translations reset-html-language-selector-suma # antora-suma-es antora-suma-cs

.PHONY: for-publication
for-publication:
	touch $(CURDIR)/for-publication

.PHONY: fix-lunr-search-in-suma-translations
fix-lunr-search-in-suma-translations:
	$(call fix-lunr-search-in-suma-translation,en)
	$(call fix-lunr-search-in-suma-translation,zh_CN)
	$(call fix-lunr-search-in-suma-translation,ja)
	$(call fix-lunr-search-in-suma-translation,ko)

.PHONY: set-html-language-selector-suma
set-html-language-selector-suma:
	$(call enable-suma-html-language-selector,zh_CN,china,china,中国人)
	$(call enable-suma-html-language-selector,ja,jaFlag,japan,日本語)
	$(call enable-suma-html-language-selector,ko,koFlag,korea,한국어)

.PHONY: reset-html-language-selector-suma
reset-html-language-selector-suma:
	[ -d ".git" ] && git checkout $(SUPPLEMENTAL_FILES_SUMA)

.PHONY: fix-lunr-search-in-uyuni-translations
fix-lunr-search-in-uyuni-translations:
	$(call fix-lunr-search-in-uyuni-translation,en)
	$(call fix-lunr-search-in-uyuni-translation,zh_CN)
	$(call fix-lunr-search-in-uyuni-translation,ja)
	$(call fix-lunr-search-in-uyuni-translation,ko)

.PHONY: set-html-language-selector-uyuni
set-html-language-selector-uyuni:
	$(call enable-uyuni-html-language-selector,zh_CN,china,china,Chinese)

.PHONY: reset-html-language-selector-uyuni
reset-html-language-selector-uyuni:
	[ -d ".git" ] && git checkout $(SUPPLEMENTAL_FILES_UYUNI)

.PHONY: antora-suma-for-publication
antora-suma-for-publication: for-publication antora-suma

.PHONY: obs-packages-suma
obs-packages-suma: obs-packages-suma-en obs-packages-suma-zh_CN obs-packages-suma-ja obs-packages-suma-ko # obs-packages-suma-es obs-packages-suma-cs

.PHONY: pdf-all-suma
pdf-all-suma: pdf-all-suma-en pdf-all-suma-zh_CN pdf-all-suma-ja pdf-all-suma-ko # pdf-all-suma-es pdf-all-suma-cs

.PHONY: pdf-install-suma
pdf-install-suma: pdf-install-suma-en pdf-install-suma-zh_CN pdf-install-suma-ja pdf-install-suma-ko # pdf-install-suma-es pdf-install-suma-cs 

.PHONY: pdf-client-configuration-suma
pdf-client-configuration-suma: pdf-client-configuration-suma-en pdf-client-configuration-suma-zh_CN pdf-client-configuration-suma-ja pdf-client-configuration-suma-ko # pdf-client-configuration-suma-es pdf-client-configuration-suma-cs 

.PHONY: pdf-upgrade-suma
pdf-upgrade-suma: pdf-upgrade-suma-en pdf-upgrade-suma-zh_CN pdf-upgrade-suma-ja pdf-upgrade-suma-ko # pdf-upgrade-suma-es pdf-upgrade-suma-cs 

.PHONY: pdf-reference-suma
pdf-reference-suma: pdf-reference-suma-en pdf-reference-suma-zh_CN pdf-reference-suma-ja pdf-reference-suma-ko # pdf-reference-suma-es pdf-reference-suma-cs 

.PHONY: pdf-administration-suma
pdf-administration-suma: pdf-administration-suma-en pdf-administration-suma-zh_CN pdf-administration-suma-ja pdf-administration-suma-ko # pdf-administration-suma-es pdf-administration-suma-cs 

.PHONY: pdf-salt-suma
pdf-salt-suma: pdf-salt-suma-en pdf-salt-suma-zh_CN pdf-salt-suma-ja pdf-salt-suma-ko # pdf-salt-suma-es pdf-salt-suma-cs

.PHONY: pdf-retail-suma
pdf-retail-suma: pdf-retail-suma-en pdf-retail-suma-zh_CN pdf-retail-suma-ja pdf-retail-suma-ko # pdf-retail-suma-es pdf-retail-suma-cs

.PHONY: pdf-large-deployment-suma
pdf-large-deployment-suma: pdf-large-deployment-suma-en pdf-large-deployment-suma-zh_CN pdf-large-deployment-suma-ja pdf-large-deployment-suma-ko # pdf-large-deployment-suma-es pdf-large-deployment-suma-cs

#.PHONY: pdf-architecture-suma
#pdf-architecture-suma: pdf-architecture-suma-en pdf-architecture-suma-es pdf-architecture-suma-zh_CN pdf-architecture-suma-cs

.PHONY: pdf-quickstart-public-cloud-suma
pdf-quickstart-public-cloud-suma: pdf-quickstart-public-cloud-suma-en pdf-quickstart-public-cloud-suma-zh_CN pdf-quickstart-public-cloud-suma-ja pdf-quickstart-public-cloud-suma-ko # pdf-quickstart-public-cloud-suma-es pdf-quickstart-public-cloud-suma-cs

.PHONY: pdf-quickstart-sap-suma
pdf-quickstart-sap-suma: pdf-quickstart-sap-suma-en pdf-quickstart-sap-suma-zh_CN pdf-quickstart-sap-suma-ja pdf-quickstart-sap-suma-ko # pdf-quickstart-sap-suma-es pdf-quickstart-sap-suma-cs

.PHONY: validate-uyuni
validate-uyuni: validate-uyuni-en validate-uyuni-zh_CN validate-uyuni-ja validate-uyuni-ko # validate-uyuni-es validate-uyuni-cs

.PHONY: pdf-tar-uyuni
pdf-tar-uyuni: pdf-tar-uyuni-en pdf-tar-uyuni-zh_CN pdf-tar-uyuni-ja pdf-tar-uyuni-ko # pdf-tar-uyuni-es pdf-tar-uyuni-cs

.PHONY: antora-uyuni
antora-uyuni: set-html-language-selector-uyuni antora-uyuni-en antora-uyuni-zh_CN  antora-uyuni-ja antora-uyuni-ko fix-lunr-search-in-uyuni-translations reset-html-language-selector-uyuni # antora-uyuni-es antora-uyuni-cs

.PHONY: antora-uyuni-for-publication
antora-uyuni-for-publication: for-publication antora-uyuni

.PHONY: obs-packages-uyuni
obs-packages-uyuni: obs-packages-uyuni-en obs-packages-uyuni-zh_CN obs-packages-uyuni-ja obs-packages-uyuni-ko # obs-packages-uyuni-es obs-packages-uyuni-cs

.PHONY: pdf-all-uyuni
pdf-all-uyuni: pdf-all-uyuni-en pdf-all-uyuni-zh_CN pdf-all-uyuni-ja pdf-all-uyuni-ko # pdf-all-uyuni-es pdf-all-uyuni-cs

.PHONY: pdf-install-uyuni
pdf-install-uyuni: pdf-install-uyuni-en pdf-install-uyuni-zh_CN pdf-install-uyuni-ja pdf-install-uyuni-ko # pdf-install-uyuni-es pdf-install-uyuni-cs

.PHONY: pdf-client-configuration-uyuni
pdf-client-configuration-uyuni: pdf-client-configuration-uyuni-en pdf-client-configuration-uyuni-zh_CN pdf-client-configuration-uyuni-ja pdf-client-configuration-uyuni-ko # pdf-client-configuration-uyuni-es pdf-client-configuration-uyuni-cs

.PHONY: pdf-upgrade-uyuni
pdf-upgrade-uyuni: pdf-upgrade-uyuni-en pdf-upgrade-uyuni-zh_CN pdf-upgrade-uyuni-ja pdf-upgrade-uyuni-ko # pdf-upgrade-uyuni-es pdf-upgrade-uyuni-cs

.PHONY: pdf-reference-uyuni
pdf-reference-uyuni: pdf-reference-uyuni-en pdf-reference-uyuni-zh_CN pdf-reference-uyuni-ja pdf-reference-uyuni-ko # pdf-reference-uyuni-es pdf-reference-uyuni-cs

.PHONY: pdf-administration-uyuni
pdf-administration-uyuni: pdf-administration-uyuni-en pdf-administration-uyuni-zh_CN pdf-administration-uyuni-ja pdf-administration-uyuni-ko # pdf-administration-uyuni-es pdf-administration-uyuni-cs

.PHONY: pdf-salt-uyuni
pdf-salt-uyuni: pdf-salt-uyuni-en pdf-salt-uyuni-zh_CN pdf-salt-uyuni-ja pdf-salt-uyuni-ko # pdf-salt-uyuni-es pdf-salt-uyuni-cs

.PHONY: pdf-retail-uyuni
pdf-retail-uyuni: pdf-retail-uyuni-en pdf-retail-uyuni-zh_CN pdf-retail-uyuni-ja pdf-retail-uyuni-ko # pdf-retail-uyuni-es pdf-retail-uyuni-cs

.PHONY: pdf-large-deployment-uyuni
pdf-large-deployment-uyuni: pdf-large-deployment-uyuni-en pdf-large-deployment-uyuni-zh_CN pdf-large-deployment-uyuni-ja pdf-large-deployment-uyuni-ko # pdf-large-deployment-uyuni-es pdf-large-deployment-uyuni-cs

#.PHONY: pdf-architecture-uyuni
#pdf-architecture-uyuni: pdf-architecture-uyuni-en pdf-architecture-uyuni-es pdf-architecture-uyuni-cs

.PHONY: pdf-quickstart-public-cloud-uyuni
pdf-quickstart-public-cloud-uyuni: pdf-quickstart-public-cloud-uyuni-en pdf-quickstart-public-cloud-uyuni-zh_CN pdf-quickstart-public-cloud-uyuni-ja pdf-quickstart-public-cloud-uyuni-ko # pdf-quickstart-public-cloud-uyuni-es pdf-quickstart-public-cloud-uyuni-cs

.PHONY: pdf-quickstart-sap-uyuni
pdf-quickstart-sap-uyuni: pdf-quickstart-sap-uyuni-en pdf-quickstart-sap-uyuni-zh_CN pdf-quickstart-sap-uyuni-ja pdf-quickstart-sap-uyuni-ko # pdf-quickstart-sap-uyuni-es pdf-quickstart-sap-uyuni-cs

.PHONY: pdf-quickstart-uyuni-uyuni
pdf-quickstart-uyuni-uyuni: pdf-quickstart-uyuni-uyuni-en pdf-quickstart-uyuni-uyuni-zh_CN pdf-quickstart-uyuni-uyuni-ja pdf-quickstart-uyuni-uyuni-ko # pdf-quickstart-uyuni-uyuni-es pdf-quickstart-uyuni-uyuni-cs

include Makefile.en
#include Makefile.es
include Makefile.zh_CN
#include Makefile.cs
include Makefile.ja
include Makefile.ko
