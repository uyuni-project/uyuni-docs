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

# UYUNI PDF Themes
# Available Choices set variable
# uyuni-draft
# uyuni

PDF_THEME_UYUNI ?= uyuni

REVDATE ?= "$(shell date +'%B %d, %Y')"
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
	cd ./$(1) && \
	sed -i "s/^ # *\(name: *suse-manager\)/\1/;\
	s/^ # *\(title: *SUSE Manager\)/\1/;\
	s/^ *\(title: *Uyuni\)/#\1/;\
	s/^ *\(name: *uyuni\)/#\1/;" $(current_dir)/$(1)/antora.yml
endef

define antora-suma-function
	$(call enable-suma-in-antorayml,$(1)) && \
	DOCSEARCH_ENABLED=true DOCSEARCH_ENGINE=lunr antora $(current_dir)/$(1)/suma-site.yml --generator antora-site-generator-lunr
endef

define enable-uyuni-in-antorayml
	cd ./$(1) && \
	sed -i "s/^ *\(name: *suse-manager\)/#\1/;\
	s/^ *\(title: *SUSE Manager\)/#\1/;\
	s/^ *# *\(title: *Uyuni\)/\1/;\
	s/^ *# *\(name: *uyuni\)/\1/;" $(current_dir)/$(1)/antora.yml
endef

define antora-uyuni-function
	$(call enable-uyuni-in-antorayml,$(1)) && \
	DOCSEARCH_ENABLED=true DOCSEARCH_ENGINE=lunr antora $(current_dir)/$(1)/uyuni-site.yml --generator antora-site-generator-lunr
endef

define clean-function
	if [ -d ./$(1) ]; then \
		cd ./$(1) && rm -rf build/ \
		.cache/ \
		public/ \
		modules/installation/nav-installation-guide.pdf.$(2).adoc \
		modules/client-configuration/nav-client-configuration-guide.pdf.$(2).adoc \
		modules/upgrade/nav-upgrade-guide.pdf.$(2).adoc \
		modules/reference/nav-reference-guide.pdf.$(2).adoc \
		modules/administration/nav-administration-guide.pdf.$(2).adoc \
		modules/salt/nav-salt-guide.pdf.$(2).adoc \
		modules/retail/nav-retail-guide.pdf.$(2).adoc \
		modules/architecture/nav-architecture-guide.pdf.$(2).adoc \
		modules/quickstart-public-cloud/nav-quickstart-public-cloud-guide.pdf.$(2).adoc \
		modules/large-deployments/nav-large-deployments.pdf.$(2).adoc; \
	fi
endef

# Create tar of PDF files
define pdf-tar-product
#	cd ./$(1) && tar -czvf $(2).tar.gz $(3) && mv $(2).tar.gz build/
	tar -czvf $(2).tar.gz -C $(HTML_BUILD_DIR) $(3) && mv $(2).tar.gz build/$(1)/
endef

# Generate OBS tar files
define obs-packages-product
	tar --exclude='$(2)' -czvf $(3).tar.gz -C $(CURDIR) $(HTML_BUILD_DIR)/$(1) && tar -czvf $(4).tar.gz -C $(CURDIR) $(HTML_BUILD_DIR)/$(2)
	mkdir -p build/packages
	mv $(3).tar.gz $(4).tar.gz build/packages
endef

# SUMA Book Builder
define pdf-book-create
	cd ./$(1) && asciidoctor-pdf \
		-r $(current_dir)/extensions/xref-converter.rb \
		-a pdf-stylesdir=$(PDF_THEME_DIR)/ \
		-a pdf-style=$(2) \
		-a pdf-fontsdir=$(PDF_FONTS_DIR) \
		-a productname=$(3) \
		-a suma-content=$(4) \
		-a examplesdir=modules/$(6)/examples \
		-a imagesdir=modules/$(6)/assets/images \
		-a revdate=$(REVDATE) \
		--base-dir . \
		--out-file $(7)/$(5)_$(6)_guide.pdf \
		modules/$(6)/nav-$(6)-guide.pdf.$(8).adoc
endef

define pdf-book-create-uyuni
	cd ./$(1) && asciidoctor-pdf \
		-r $(current_dir)/extensions/xref-converter.rb \
		-a pdf-stylesdir=$(PDF_THEME_DIR)/ \
		-a pdf-style=$(2) \
		-a pdf-fontsdir=$(PDF_FONTS_DIR) \
		-a productname=$(3) \
		-a uyuni-content=$(4) \
		-a examplesdir=modules/$(6)/examples \
		-a imagesdir=modules/$(6)/assets/images \
		-a revdate=$(REVDATE) \
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
		modules/$(2)/nav-$(2)-guide.adoc > $(1)/modules/$(2)/nav-$(2)-guide.pdf.$(3).adoc
endef

# SUMA PDF Books
# Generate PDF version of the Installation Guide
define pdf-install-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),installation,$(6),$(7))
endef

# Generate PDF version of the Client Configuration Guide
define pdf-client-configuration-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),client-configuration,$(6),$(7))
endef

# Generate PDF version of the Upgrade Guide
define pdf-upgrade-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),upgrade,$(6),$(7))
endef

# Generate PDF version of the Reference Guide
define pdf-reference-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),reference,$(6),$(7))
endef

# Generate PDF version of the Administration Guide
define pdf-administration-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),administration,$(6),$(7))
endef

# Generate PDF version of the Salt Guide
define pdf-salt-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),salt,$(6),$(7))
endef

# Generate PDF version of the Retail Guide
define pdf-retail-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),retail,$(6),$(7))
endef

# Generate PDF version of the Architecture Guide
define pdf-architecture-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),architecture,$(6),$(7))
endef

# Generate PDF version of the Public Cloud Guide
define pdf-quickstart-public-cloud-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),quickstart-public-cloud,$(6),$(7))
endef

# Generate PDF version of the SAP Guide
define pdf-quickstart-sap-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),quickstart-sap,$(6),$(7))
endef

# Generate PDF version of the Large Deployment Guide
define pdf-large-deployment-product
	$(call pdf-book-create,$(1),$(2),$(3),$(4),$(5),large-deployments,$(6),$(7))
endef

# UYUNI PDF Books
# Generate PDF version of the Installation Guide
define pdf-install-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),installation,$(6),$(7))
endef

# Generate PDF version of the Client Configuration Guide
define pdf-client-configuration-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),client-configuration,$(6),$(7))
endef

# Generate PDF version of the Upgrade Guide
define pdf-upgrade-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),upgrade,$(6),$(7))
endef

# Generate PDF version of the Reference Guide
define pdf-reference-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),reference,$(6),$(7))
endef

# Generate PDF version of the Administration Guide
define pdf-administration-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),administration,$(6),$(7))
endef

# Generate PDF version of the Salt Guide
define pdf-salt-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),salt,$(6),$(7))
endef

# Generate PDF version of the Retail Guide
define pdf-retail-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),retail,$(6),$(7))
endef

# Generate PDF version of the Architecture Guide
define pdf-architecture-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),architecture,$(6),$(7))
endef

# Generate PDF version of the Public Cloud Guide
define pdf-quickstart-public-cloud-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),quickstart-public-cloud,$(6),$(7))
endef

# Generate PDF version of the SAP Guide
define pdf-quickstart-sap-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),quickstart-sap,$(6),$(7))
endef

# Generate PDF version of the Large Deployment Guide
define pdf-large-deployment-product-uyuni
	$(call pdf-book-create-uyuni,$(1),$(2),$(3),$(4),$(5),large-deployments,$(6),$(7))
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
	$(shell $(current_dir)/make_pot.sh)

.PHONY: translations
translations:
	$(shell $(current_dir)/use_po.sh)

.PHONY: clean
clean: clean-en clean-es

.PHONY: validate-suma
validate-suma: validate-suma-es validate-suma-en

.PHONY: pdf-tar-suma
pdf-tar-suma: pdf-tar-suma-en pdf-tar-suma-es

.PHONY: antora-suma
antora-suma: antora-suma-en antora-suma-es

.PHONY: obs-packages-suma
obs-packages-suma: obs-packages-suma-en obs-packages-suma-es

.PHONY: pdf-all-suma
pdf-all-suma: pdf-all-suma-en pdf-all-suma-es

.PHONY: pdf-install-suma
pdf-install-suma: pdf-install-suma-en pdf-install-suma-es

.PHONY: pdf-client-configuration-suma
pdf-client-configuration-suma: pdf-client-configuration-suma-en pdf-client-configuration-suma-es

.PHONY: pdf-upgrade-suma
pdf-upgrade-suma: pdf-upgrade-suma-en pdf-upgrade-suma-es

.PHONY: pdf-reference-suma
pdf-reference-suma: pdf-reference-suma-en pdf-reference-suma-es

.PHONY: pdf-administration-suma
pdf-administration-suma: pdf-administration-suma-en pdf-administration-suma-es

.PHONY: pdf-salt-suma
pdf-salt-suma: pdf-salt-suma-en pdf-salt-suma-es

.PHONY: pdf-retail-suma
pdf-retail-suma: pdf-retail-suma-en pdf-retail-suma-es

.PHONY: pdf-large-deployment-suma
pdf-large-deployment-suma: pdf-large-deployment-suma-en pdf-large-deployment-suma-es

.PHONY: pdf-architecture-suma
pdf-architecture-suma: pdf-architecture-suma-en pdf-architecture-suma-es

.PHONY: pdf-quickstart-public-cloud-suma
pdf-quickstart-public-cloud-suma: pdf-quickstart-public-cloud-suma-en pdf-quickstart-public-cloud-suma-es

.PHONY: validate-uyuni
validate-uyuni: validate-uyuni-en validate-uyuni-es

.PHONY: pdf-tar-uyuni
pdf-tar-uyuni: pdf-tar-uyuni-en pdf-tar-uyuni-es

.PHONY: antora-uyuni
antora-uyuni: antora-uyuni-en antora-uyuni-es

.PHONY: obs-packages-uyuni
obs-packages-uyuni: obs-packages-uyuni-en obs-packages-uyuni-es

.PHONY: pdf-all-uyuni
pdf-all-uyuni: pdf-all-uyuni-en pdf-all-uyuni-es

.PHONY: pdf-install-uyuni
pdf-install-uyuni: pdf-install-uyuni-en pdf-install-uyuni-es

.PHONY: pdf-client-configuration-uyuni
pdf-client-configuration-uyuni: pdf-client-configuration-uyuni-en pdf-client-configuration-uyuni-es

.PHONY: pdf-upgrade-uyuni
pdf-upgrade-uyuni: pdf-upgrade-uyuni-en pdf-upgrade-uyuni-es

.PHONY: pdf-reference-uyuni
pdf-reference-uyuni: pdf-reference-uyuni-en pdf-reference-uyuni-es

.PHONY: pdf-administration-uyuni
pdf-administration-uyuni: pdf-administration-uyuni-en pdf-administration-uyuni-es

.PHONY: pdf-salt-uyuni
pdf-salt-uyuni: pdf-salt-uyuni-en pdf-salt-uyuni-es

.PHONY: pdf-retail-uyuni
pdf-retail-uyuni: pdf-retail-uyuni-en pdf-retail-uyuni-es

.PHONY: pdf-large-deployment-uyuni
pdf-large-deployment-uyuni: pdf-large-deployment-uyuni-en pdf-large-deployment-uyuni-es

.PHONY: pdf-architecture-uyuni
pdf-architecture-uyuni: pdf-architecture-uyuni-en pdf-architecture-uyuni-es

.PHONY: pdf-quickstart-public-cloud-uyuni
pdf-quickstart-public-cloud-uyuni: pdf-quickstart-public-cloud-uyuni-en pdf-quickstart-public-cloud-uyuni-es

include Makefile.en
include Makefile.es
