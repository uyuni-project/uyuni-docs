LANGCODE_ES=es
LANGDIR_ES=translations/$(LANGCODE_ES)
LOCALE_ES=es_ES.UTF-8
GNUDATEFORMAT_ES=%e de %B de %Y

HTML_BUILD_DIR_ES := $(CURDIR)/build/$(LANGCODE_ES)
PDF_BUILD_DIR_ES := $(CURDIR)/build/$(LANGCODE_ES)/pdf

# SUMA OBS Tarball Filenames
HTML_OUTPUT_SUMA_ES ?= susemanager-docs_es
PDF_OUTPUT_SUMA_ES ?= susemanager-docs_es-pdf

# UYUNI OBS Tarball Filenames
HTML_OUTPUT_UYUNI_ES ?= uyuni-docs_es
PDF_OUTPUT_UYUNI_ES ?= uyuni-docs_es-pdf

# Clean up build artifacts
.PHONY: clean-$(LANGCODE_ES)
clean-$(LANGCODE_ES): ## Remove build artifacts from output directory (Antora and PDF)
	$(call clean-function,$(LANGDIR_ES),$(LANGCODE_ES))

.PHONY: validate-suma-$(LANGCODE_ES)
validate-suma-$(LANGCODE_ES):
	$(call validate-product,$(LANGDIR_ES),suma-site.yml)

.PHONY: pdf-tar-suma-$(LANGCODE_ES)
pdf-tar-suma-$(LANGCODE_ES):
	$(call pdf-tar-product,$(LANGCODE_ES),$(PDF_OUTPUT_SUMA_ES),$(PDF_BUILD_DIR_ES))

.PHONY: prepare-antora-suma-$(LANGCODE_ES)
prepare-antora-suma-$(LANGCODE_ES):
	-mkdir -p $(LANGDIR_ES) && \
	cp -a antora.yml $(LANGDIR_ES)/antora.yml && \
	sed "s/\.\/branding/\.\.\/\.\.\/branding/;\
	s/\-\ url\:\ \./\-\ url\:\ \.\.\/\.\.\//;\
	s/start_path\:\ \./\start_path\:\ translations\/$(LANGCODE_ES)/;\
	s/dir:\ \.\/build\/en/dir:\ \.\.\/\.\.\/build\/$(LANGCODE_ES)/;" suma-site.yml > $(LANGDIR_ES)/suma-site.yml && \
	cd $(LANGDIR_ES) && \
	if [ ! -e branding ]; then ln -s ../../branding; fi && \
	cp -a $(CURDIR)/modules/ROOT/pages/common_gfdl1.2_i.adoc $(CURDIR)/$(LANGDIR_ES)/modules/ROOT/pages/

.PHONY: antora-suma-$(LANGCODE_ES)
antora-suma-$(LANGCODE_ES): clean-$(LANGCODE_ES) pdf-all-suma-$(LANGCODE_ES) pdf-tar-suma-$(LANGCODE_ES)
#	$(call enable-suma-in-antorayml,.)
	$(call antora-suma-function,$(LANGDIR_ES),$(LANGCODE_CS))

.PHONY: obs-packages-suma-$(LANGCODE_ES)
obs-packages-suma-$(LANGCODE_ES): clean-$(LANGCODE_ES) pdf-all-suma-$(LANGCODE_ES) antora-suma-$(LANGCODE_ES) ## Generate SUMA OBS tar files
	$(call obs-packages-product,$(LANGCODE_ES),$(LANGCODE_ES)/pdf,$(HTML_OUTPUT_SUMA_ES),$(PDF_OUTPUT_SUMA_ES))

# Generate PDF versions of all SUMA books
.PHONY: pdf-all-suma-$(LANGCODE_ES)
pdf-all-suma-$(LANGCODE_ES):  translations prepare-antora-suma-$(LANGCODE_ES) pdf-install-suma-$(LANGCODE_ES) pdf-client-configuration-suma-$(LANGCODE_ES) pdf-upgrade-suma-$(LANGCODE_ES) pdf-reference-suma-$(LANGCODE_ES) pdf-administration-suma-$(LANGCODE_ES) pdf-salt-suma-$(LANGCODE_ES) pdf-retail-suma-$(LANGCODE_ES) pdf-quickstart-public-cloud-suma-$(LANGCODE_ES) pdf-large-deployment-suma-$(LANGCODE_ES) ##pdf-architecture-suma-webui-$(LANGCODE_ES)

.PHONY: modules/installation/nav-installation-guide.pdf.$(LANGCODE_ES).adoc
modules/installation/nav-installation-guide.pdf.$(LANGCODE_ES).adoc:
	$(call pdf-book-create-index,$(LANGDIR_ES),installation,$(LANGCODE_ES))

## Generate PDF version of the SUMA Installation Guide
.PHONY: pdf-install-suma-$(LANGCODE_ES)
pdf-install-suma-$(LANGCODE_ES): modules/installation/nav-installation-guide.pdf.$(LANGCODE_ES).adoc
	$(call pdf-install-product,$(LANGDIR_ES),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))


.PHONY: modules/client-configuration/nav-client-configuration-guide.pdf.$(LANGCODE_ES).adoc
modules/client-configuration/nav-client-configuration-guide.pdf.$(LANGCODE_ES).adoc:
	$(call pdf-book-create-index,$(LANGDIR_ES),client-configuration,$(LANGCODE_ES))

## Generate PDF version of the SUMA Client Configuration Guide
.PHONY: pdf-client-configuration-suma-$(LANGCODE_ES)
pdf-client-configuration-suma-$(LANGCODE_ES): modules/client-configuration/nav-client-configuration-guide.pdf.$(LANGCODE_ES).adoc
	$(call pdf-client-configuration-product,$(LANGDIR_ES),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))

.PHONY: modules/upgrade/nav-upgrade-guide.pdf.$(LANGCODE_ES).adoc
modules/upgrade/nav-upgrade-guide.pdf.$(LANGCODE_ES).adoc:
	$(call pdf-book-create-index,$(LANGDIR_ES),upgrade,$(LANGCODE_ES))

## Generate PDF version of the SUMA Upgrade Guide
.PHONY: pdf-upgrade-suma-$(LANGCODE_ES)
pdf-upgrade-suma-$(LANGCODE_ES): modules/upgrade/nav-upgrade-guide.pdf.$(LANGCODE_ES).adoc
	$(call pdf-upgrade-product,$(LANGDIR_ES),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))

.PHONY: modules/reference/nav-reference-guide.pdf.$(LANGCODE_ES).adoc
modules/reference/nav-reference-guide.pdf.$(LANGCODE_ES).adoc:
	$(call pdf-book-create-index,$(LANGDIR_ES),reference,$(LANGCODE_ES))

## Generate PDF version of the SUMA Reference Manual
.PHONY: pdf-reference-suma-$(LANGCODE_ES)
pdf-reference-suma-$(LANGCODE_ES): modules/reference/nav-reference-guide.pdf.$(LANGCODE_ES).adoc
	$(call pdf-reference-product,$(LANGDIR_ES),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))

.PHONY: modules/administration/nav-administration-guide.pdf.$(LANGCODE_ES).adoc
modules/administration/nav-administration-guide.pdf.$(LANGCODE_ES).adoc:
	$(call pdf-book-create-index,$(LANGDIR_ES),administration,$(LANGCODE_ES))

.PHONY: pdf-administration-suma-$(LANGCODE_ES)
## Generate PDF version of the SUMA Administration Guide
pdf-administration-suma-$(LANGCODE_ES): modules/administration/nav-administration-guide.pdf.$(LANGCODE_ES).adoc
	$(call pdf-administration-product,$(LANGDIR_ES),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))

.PHONY: modules/salt/nav-salt-guide.pdf.$(LANGCODE_ES).adoc
modules/salt/nav-salt-guide.pdf.$(LANGCODE_ES).adoc:
	$(call pdf-book-create-index,$(LANGDIR_ES),salt,$(LANGCODE_ES))

.PHONY: pdf-salt-suma-$(LANGCODE_ES)
## Generate PDF version of the SUMA Salt Guide
pdf-salt-suma-$(LANGCODE_ES): modules/salt/nav-salt-guide.pdf.$(LANGCODE_ES).adoc
	$(call pdf-salt-product,$(LANGDIR_ES),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))

.PHONY: modules/retail/nav-retail-guide.pdf.$(LANGCODE_ES).adoc
modules/retail/nav-retail-guide.pdf.$(LANGCODE_ES).adoc:
	$(call pdf-book-create-index,$(LANGDIR_ES),retail,$(LANGCODE_ES))

.PHONY: pdf-retail-suma-$(LANGCODE_ES)
## Generate PDF version of the SUMA Retail Guide
pdf-retail-suma-$(LANGCODE_ES): modules/retail/nav-retail-guide.pdf.$(LANGCODE_ES).adoc
	$(call pdf-retail-product,$(LANGDIR_ES),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))

.PHONY: modules/large-deployments/nav-large-deployments.pdf.$(LANGCODE_ES).adoc
modules/large-deployments/nav-large-deployments.pdf.$(LANGCODE_ES).adoc:
	$(call pdf-book-create-index,$(LANGDIR_ES),large-deployments,$(LANGCODE_ES))

.PHONY: pdf-large-deployment-suma-$(LANGCODE_ES)
## Generate PDF version of the SUMA Large Deployment Guide
pdf-large-deployment-suma-$(LANGCODE_ES): modules/large-deployments/nav-large-deployments.pdf.$(LANGCODE_ES).adoc
	$(call pdf-large-deployment-product,$(LANGDIR_ES),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))


#.PHONY: modules/architecture/nav-architecture-guide.pdf.$(LANGCODE_ES).adoc
#modules/architecture/nav-architecture-guide.pdf.$(LANGCODE_ES).adoc:
#	$(call pdf-book-create-index,$(LANGDIR_ES),architecture,$(LANGCODE_ES))

#.PHONY: pdf-architecture-suma-$(LANGCODE_ES)
### Generate PDF version of the SUMA Architecture Guide
#pdf-architecture-suma-$(LANGCODE_ES): modules/architecture/nav-architecture-guide.pdf.$(LANGCODE_ES).adoc
#	$(call pdf-architecture-product,$(LANGDIR_ES),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES))

.PHONY: modules/quickstart-public-cloud/nav-quickstart-public-cloud-guide.pdf.$(LANGCODE_ES).adoc
modules/quickstart-public-cloud/nav-quickstart-public-cloud-guide.pdf.$(LANGCODE_ES).adoc:
	$(call pdf-book-create-index,$(LANGDIR_ES),quickstart-public-cloud,$(LANGCODE_ES))

.PHONY: pdf-quickstart-public-cloud-suma-$(LANGCODE_ES)
## Generate PDF version of the SUMA Quickstart Guide for Public Cloud
pdf-quickstart-public-cloud-suma-$(LANGCODE_ES): modules/quickstart-public-cloud/nav-quickstart-public-cloud-guide.pdf.$(LANGCODE_ES).adoc
	$(call pdf-quickstart-public-cloud-product,$(LANGDIR_ES),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))

.PHONY: modules/quickstart-sap/nav-quickstart-sap-guide.pdf.$(LANGCODE_ES).adoc
modules/quickstart-sap/nav-quickstart-sap-guide.pdf.$(LANGCODE_ES).adoc:
	$(call pdf-book-create-index,$(LANGDIR_ES),quickstart-sap,$(LANGCODE_ES))

.PHONY: pdf-quickstart-sap-suma-$(LANGCODE_ES)
## Generate PDF version of the SUMA Quickstart Guide for SAP
pdf-quickstart-sap-suma-$(LANGCODE_ES): modules/quickstart-sap/nav-quickstart-sap-guide.pdf.$(LANGCODE_ES).adoc
	$(call pdf-quickstart-sap-product,$(LANGDIR_ES),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))

.PHONY: modules/quickstart-uyuni/nav-quickstart-uyuni-guide.pdf.$(LANGCODE_ES).adoc
modules/quickstart-uyuni/nav-quickstart-uyuni-guide.pdf.$(LANGCODE_ES).adoc:
	$(call pdf-book-create-index,$(LANGDIR_ES),quickstart-uyuni,$(LANGCODE_ES))

# UYUNI

.PHONY: validate-uyuni-$(LANGCODE_ES)
validate-uyuni-$(LANGCODE_ES):
	$(call validate-product,$(LANGDIR_ES),uyuni-site.yml)

.PHONY: pdf-tar-uyuni-$(LANGCODE_ES)
pdf-tar-uyuni-$(LANGCODE_ES):
	$(call pdf-tar-product,$(LANGCODE_ES),$(PDF_OUTPUT_UYUNI_ES),$(PDF_BUILD_DIR_ES))

.PHONY: prepare-antora-uyuni-$(LANGCODE_ES)
prepare-antora-uyuni-$(LANGCODE_ES):
	-mkdir -p $(LANGDIR_ES) && \
	cp antora.yml $(LANGDIR_ES)/antora.yml && \
	sed "s/\.\/branding/\.\.\/\.\.\/branding/;\
	s/\-\ url\:\ \./\-\ url\:\ \.\.\/\.\.\//;\
	s/start_path\:\ \./\start_path\:\ translations\/$(LANGCODE_ES)/;\
	s/dir:\ \.\/build\/en/dir:\ \.\.\/\.\.\/build\/$(LANGCODE_ES)/;" uyuni-site.yml > $(LANGDIR_ES)/uyuni-site.yml && \
	cd $(LANGDIR_ES) && \
	if [ ! -e branding ]; then ln -s ../../branding; fi && \
	cp -a $(CURDIR)/modules/ROOT/pages/common_gfdl1.2_i.adoc $(CURDIR)/$(LANGDIR_ES)/modules/ROOT/pages/

.PHONY: antora-uyuni-$(LANGCODE_ES)
antora-uyuni-$(LANGCODE_ES): clean-$(LANGCODE_ES) pdf-all-uyuni-$(LANGCODE_ES) pdf-tar-uyuni-$(LANGCODE_ES)
	$(call antora-uyuni-function,$(LANGDIR_ES),$(LANGCODE_CS))

.PHONY: obs-packages-uyuni-$(LANGCODE_ES)
obs-packages-uyuni-$(LANGCODE_ES): clean-$(LANGCODE_ES) pdf-all-uyuni-$(LANGCODE_ES) antora-uyuni-$(LANGCODE_ES) ## Generate UYUNI OBS tar files
	$(call obs-packages-product,$(LANGCODE_ES),$(LANGCODE_ES)/pdf,$(HTML_OUTPUT_UYUNI_ES),$(PDF_OUTPUT_UYUNI_ES))

# Generate PDF versions of all UYUNI books
.PHONY: pdf-all-uyuni-$(LANGCODE_ES)
pdf-all-uyuni-$(LANGCODE_ES): translations prepare-antora-uyuni-$(LANGCODE_ES) pdf-install-uyuni-$(LANGCODE_ES) pdf-client-configuration-uyuni-$(LANGCODE_ES) pdf-upgrade-uyuni-$(LANGCODE_ES) pdf-reference-uyuni-$(LANGCODE_ES) pdf-administration-uyuni-$(LANGCODE_ES) pdf-salt-uyuni-$(LANGCODE_ES) pdf-retail-uyuni-$(LANGCODE_ES) pdf-quickstart-public-cloud-uyuni-$(LANGCODE_ES) pdf-quickstart-uyuni-uyuni-$(LANGCODE_ES) pdf-large-deployment-uyuni-$(LANGCODE_ES) ##pdf-architecture-uyuni-webui-$(LANGCODE_ES)

## Generate PDF version of the UYUNI Installation Guide
.PHONY: pdf-install-uyuni-$(LANGCODE_ES)
pdf-install-uyuni-$(LANGCODE_ES): modules/installation/nav-installation-guide.pdf.$(LANGCODE_ES).adoc
	$(call pdf-install-product-uyuni,$(LANGDIR_ES),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))

## Generate PDF version of the UYUNI Client Configuration Guide
.PHONY: pdf-client-configuration-uyuni-$(LANGCODE_ES)
pdf-client-configuration-uyuni-$(LANGCODE_ES): modules/client-configuration/nav-client-configuration-guide.pdf.$(LANGCODE_ES).adoc
	$(call pdf-client-configuration-product-uyuni,$(LANGDIR_ES),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))

## Generate PDF version of the UYUNI Upgrade Guide
.PHONY: pdf-upgrade-uyuni-$(LANGCODE_ES)
pdf-upgrade-uyuni-$(LANGCODE_ES): modules/upgrade/nav-upgrade-guide.pdf.$(LANGCODE_ES).adoc
	$(call pdf-upgrade-product-uyuni,$(LANGDIR_ES),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))

## Generate PDF version of the UYUNI Reference Manual
.PHONY: pdf-reference-uyuni-$(LANGCODE_ES)
pdf-reference-uyuni-$(LANGCODE_ES): modules/reference/nav-reference-guide.pdf.$(LANGCODE_ES).adoc
	$(call pdf-reference-product-uyuni,$(LANGDIR_ES),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))

.PHONY: pdf-administration-uyuni-$(LANGCODE_ES)
## Generate PDF version of the UYUNI Administration Guide
pdf-administration-uyuni-$(LANGCODE_ES): modules/administration/nav-administration-guide.pdf.$(LANGCODE_ES).adoc
	$(call pdf-administration-product-uyuni,$(LANGDIR_ES),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))

.PHONY: pdf-salt-uyuni-$(LANGCODE_ES)
## Generate PDF version of the UYUNI Salt Guide
pdf-salt-uyuni-$(LANGCODE_ES): modules/salt/nav-salt-guide.pdf.$(LANGCODE_ES).adoc
	$(call pdf-salt-product-uyuni,$(LANGDIR_ES),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))

.PHONY: pdf-retail-uyuni-$(LANGCODE_ES)
## Generate PDF version of the UYUNI Retail Guide
pdf-retail-uyuni-$(LANGCODE_ES): modules/retail/nav-retail-guide.pdf.$(LANGCODE_ES).adoc
	$(call pdf-retail-product-uyuni,$(LANGDIR_ES),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))

.PHONY: pdf-large-deployment-uyuni-$(LANGCODE_ES)
## Generate PDF version of the UYUNI Large Deployment Guide
pdf-large-deployment-uyuni-$(LANGCODE_ES): modules/large-deployments/nav-large-deployments.pdf.$(LANGCODE_ES).adoc
	$(call pdf-large-deployment-product-uyuni,$(LANGDIR_ES),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))

#.PHONY: pdf-architecture-uyuni-$(LANGCODE_ES)
### Generate PDF version of the UYUNI Architecture Guide
#pdf-architecture-uyuni-$(LANGCODE_ES): modules/architecture/nav-architecture-guide.pdf.$(LANGCODE_ES).adoc
#	$(call pdf-architecture-product-uyuni,$(LANGDIR_ES),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))

.PHONY: pdf-quickstart-public-cloud-uyuni-$(LANGCODE_ES)
## Generate PDF version of the UYUNI Quickstart Guide for Public Cloud
pdf-quickstart-public-cloud-uyuni-$(LANGCODE_ES): modules/quickstart-public-cloud/nav-quickstart-public-cloud-guide.pdf.$(LANGCODE_ES).adoc
	$(call pdf-quickstart-public-cloud-product-uyuni,$(LANGDIR_ES),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))

.PHONY: pdf-quickstart-sap-uyuni-$(LANGCODE_ES)
## Generate PDF version of the UYUNI Quickstart Guide for SAP
pdf-quickstart-sap-uyuni-$(LANGCODE_ES): modules/quickstart-sap/nav-quickstart-sap-guide.pdf.$(LANGCODE_ES).adoc
	$(call pdf-quickstart-sap-product-uyuni,$(LANGDIR_ES),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))

.PHONY: pdf-quickstart-uyuni-uyuni-$(LANGCODE_ES)
## Generate PDF version of the UYUNI Quickstart Guide for Uyuni
pdf-quickstart-uyuni-uyuni-$(LANGCODE_ES): modules/quickstart-uyuni/nav-quickstart-uyuni-guide.pdf.$(LANGCODE_ES).adoc
	$(call pdf-quickstart-uyuni-product-uyuni,$(LANGDIR_ES),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES),$(LANGCODE_ES),$(LOCALE_ES),$(GNUDATEFORMAT_ES))
