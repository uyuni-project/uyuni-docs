# Makefile for SUSE Manager/Uyuni Documentation
# Author: Joseph Cayouette
# Inspired/modified from Owncloud's documentation Makefile written by Matthew Setter

SHELL = bash
FONTS_DIR ?= pdf-constructor/fonts
STYLES_DIR ?= pdf-constructor/resources/themes
#TODO speak with java dev about creating a wildcard for the WebUI. For specific branches antora should only have 1 branch see: suma-site.yml
#TODO allow setting the style, productname, and output filename prefix from the CLI
STYLE ?= draft
#STYLE ?= suse
#PRODUCTNAME ?= 'SUSE Manager'
#FILENAME ?= suse_manager
PRODUCTNAME ?= Uyuni
FILENAME ?= uyuni

REVDATE ?= "$(shell date +'%B %d, %Y')"
CURDIR ?= .
# Build directories for TAR
HTML_BUILD_DIR ?= build
PDF_BUILD_DIR ?= build/pdf
# OBS Filenames
HTML_OUTPUT ?= susemanager-docs_en
PDF_OUTPUT ?= susemanager-docs_en-pdf



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


.PHONY: clean
clean: ## Remove build artifacts from output directory (Antora and PDF)
	-rm -rf build/ .cache/ public/

# To build for suma or uyuni you need to comment out the correct name/title in the antora.yml file. (TODO remove this manual method.)
.PHONY: antora-suma
antora-suma: ## Build the Antora static site (Requires Docker, you must modify the antora.yml file see comments for uyuni/suma)
	docker run -u 1000 -v `pwd`:/antora --rm -t antora/antora:1.1.1 suma-site.yml --stacktrace

.PHONY: antora-uyuni
antora-uyuni: ## Build the Antora static site (Requires Docker, you must modify the antora.yml file see comments for uyuni/suma)
	docker run -u 1000 -v `pwd`:/antora --rm -t antora/antora:1.1.1 uyuni-site.yml --stacktrace


.PHONY: pdf-all
pdf-all: pdf-install pdf-client-config pdf-upgrade pdf-reference pdf-administration pdf-salt pdf-retail pdf-architecture ## Generate PDF versions of all books


.PHONY: pdf-install
pdf-install: ## Generate PDF version of the Installation Guide
	asciidoctor-pdf \
		-a pdf-stylesdir=$(STYLES_DIR)/ \
		-a pdf-style=$(STYLE) \
		-a pdf-fontsdir=$(FONTS_DIR) \
		-a productname=$(PRODUCTNAME) \
		-a examplesdir=modules/installation/examples \
		-a imagesdir=modules/installation/assets/images \
		-a revdate=$(REVDATE) \
		--base-dir . \
		--out-file $(PDF_BUILD_DIR)/$(FILENAME)_installation_guide.pdf \
		modules/installation/nav-installation-guide.adoc


.PHONY: pdf-client-config
pdf-client-config: ## Generate PDF version of the Client Configuraiton Guide
	asciidoctor-pdf \
		-a pdf-stylesdir=$(STYLES_DIR)/ \
		-a pdf-style=$(STYLE) \
		-a pdf-fontsdir=$(FONTS_DIR) \
		-a productname=$(PRODUCTNAME) \
		-a examplesdir=modules/client-configuration/examples \
		-a imagesdir=modules/client-configuration/assets/images \
		-a revdate=$(REVDATE) \
		--base-dir . \
		--out-file $(PDF_BUILD_DIR)/$(FILENAME)_client_configuration_guide.pdf \
		modules/client-configuration/nav-client-config-guide.adoc


.PHONY: pdf-upgrade
pdf-upgrade: ## Generate PDF version of the Upgrade Guide
	asciidoctor-pdf \
		-a pdf-stylesdir=$(STYLES_DIR)/ \
		-a pdf-style=$(STYLE) \
		-a pdf-fontsdir=$(FONTS_DIR) \
		-a productname=$(PRODUCTNAME) \
		-a examplesdir=modules/upgrade/examples \
		-a imagesdir=modules/upgrade/assets/images \
		-a revdate=$(REVDATE) \
		--base-dir . \
		--out-file $(PDF_BUILD_DIR)/$(FILENAME)_upgrade_guide.pdf \
		modules/upgrade/nav-upgrade-guide.adoc


.PHONY: pdf-reference
pdf-reference: ## Generate PDF version of the Reference Manual
	asciidoctor-pdf \
		-a pdf-stylesdir=$(STYLES_DIR)/ \
		-a pdf-style=$(STYLE) \
		-a pdf-fontsdir=$(FONTS_DIR) \
		-a productname=$(PRODUCTNAME) \
		-a examplesdir=modules/reference/examples \
		-a imagesdir=modules/reference/assets/images \
		-a revdate=$(REVDATE) \
		--base-dir . \
		--out-file $(PDF_BUILD_DIR)/$(FILENAME)_reference_manual.pdf \
		pdf-constructor/product_reference_manual.adoc


.PHONY: pdf-administration
pdf-administration: ## Generate PDF version of the Administration Guide
	asciidoctor-pdf \
		-a pdf-stylesdir=$(STYLES_DIR)/ \
		-a pdf-style=$(STYLE) \
		-a pdf-fontsdir=$(FONTS_DIR) \
		-a productname=$(PRODUCTNAME) \
		-a examplesdir=modules/administration/examples \
		-a imagesdir=modules/administration/assets/images \
		-a revdate=$(REVDATE) \
		--base-dir . \
		--out-file $(PDF_BUILD_DIR)/$(FILENAME)_administration_guide.pdf \
		modules/administration/nav-administration-guide.adoc


.PHONY: pdf-salt
pdf-salt: ## Generate PDF version of the Salt Guide
	asciidoctor-pdf \
		-a pdf-stylesdir=$(STYLES_DIR)/ \
		-a pdf-style=$(STYLE) \
		-a pdf-fontsdir=$(FONTS_DIR) \
		-a productname=$(PRODUCTNAME) \
		-a examplesdir=modules/salt/examples \
		-a imagesdir=modules/salt/assets/images \
		-a revdate=$(REVDATE) \
		--base-dir . \
		--out-file $(PDF_BUILD_DIR)/$(FILENAME)_salt_guide.pdf \
		modules/salt/nav-salt-guide.adoc



.PHONY: pdf-retail
pdf-retail: ## Generate PDF version of the Retail Guide
	asciidoctor-pdf \
		-a pdf-stylesdir=$(STYLES_DIR)/ \
		-a pdf-style=$(STYLE) \
		-a pdf-fontsdir=$(FONTS_DIR) \
		-a productname=$(PRODUCTNAME) \
		-a examplesdir=modules/retail/examples \
		-a imagesdir=modules/retail/assets/images \
		-a revdate=$(REVDATE) \
		--base-dir . \
		--out-file $(PDF_BUILD_DIR)/$(FILENAME)_retail_guide.pdf \
		modules/retail/nav-retail.adoc


.PHONY: pdf-architecture
pdf-architecture: ## Generate PDF version of the Architecture Guide
	asciidoctor-pdf \
		-a productname=$(PRODUCTNAME) \
		-a pdf-stylesdir=$(STYLES_DIR)/ \
		-a pdf-style=$(STYLE) \
		-a pdf-fontsdir=$(FONTS_DIR) \
		-a productname=$(PRODUCTNAME) \
		-a examplesdir=modules/architecture/examples \
		-a imagesdir=modules/architecture/assets/images \
		-a revdate=$(REVDATE) \
		--base-dir $(CURDIR) \
	 	--out-file $(PDF_BUILD_DIR)/$(FILENAME)_architecture.pdf \
		modules/architecture/nav-architecture-components-guide.adoc

# UYUNI
.PHONY: obs-packages-uyuni
obs-packages-uyuni: pdf-all antora-uyuni ## Generate tar files for the SUSE/OpenSUSE build service
	tar --exclude='$(PDF_BUILD_DIR)' -czvf $(HTML_OUTPUT).tar.gz $(HTML_BUILD_DIR)
	tar -czvf $(PDF_OUTPUT).tar.gz $(PDF_BUILD_DIR)
	mkdir build/packages
	mv $(HTML_OUTPUT).tar.gz $(PDF_OUTPUT).tar.gz build/packages

# SUMA
.PHONY: obs-packages-suma
obs-packages-suma: pdf-all antora-suma ## Generate tar files for the SUSE/OpenSUSE build service
	tar --exclude='$(PDF_BUILD_DIR)' -czvf $(HTML_OUTPUT).tar.gz $(HTML_BUILD_DIR)
	tar -czvf $(PDF_OUTPUT).tar.gz $(PDF_BUILD_DIR)
	mkdir build/packages
	mv $(HTML_OUTPUT).tar.gz $(PDF_OUTPUT).tar.gz build/packages

