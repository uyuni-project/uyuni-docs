LANGCODE_CS=cs
LANGDIR_CS=translations/$(LANGCODE_CS)
LOCALE_CS=cs_CZ.UTF-8
GNUDATEFORMAT_CS=%e. %B %Y

HTML_BUILD_DIR_CS := $(CURDIR)/build/$(LANGCODE_CS)
PDF_BUILD_DIR_CS := $(CURDIR)/build/$(LANGCODE_CS)/pdf

# SUMA OBS Tarball Filenames
HTML_OUTPUT_SUMA_CS ?= susemanager-docs_cs
PDF_OUTPUT_SUMA_CS ?= susemanager-docs_cs-pdf

# UYUNI OBS Tarball Filenames
HTML_OUTPUT_UYUNI_CS ?= uyuni-docs_cs
PDF_OUTPUT_UYUNI_CS ?= uyuni-docs_cs-pdf

# Clean up build artifacts
.PHONY: clean-$(LANGCODE_CS)
clean-$(LANGCODE_CS): ## Remove build artifacts from output directory (Antora and PDF)
	$(call clean-function,$(LANGDIR_CS),$(LANGCODE_CS))

.PHONY: validate-suma-$(LANGCODE_CS)
validate-suma-$(LANGCODE_CS):
	$(call validate-product,$(LANGDIR_CS),suma-site.yml)

.PHONY: pdf-tar-suma-$(LANGCODE_CS)
pdf-tar-suma-$(LANGCODE_CS):
	$(call pdf-tar-product,$(LANGCODE_CS),$(PDF_OUTPUT_SUMA_CS),$(PDF_BUILD_DIR_CS))

.PHONY: prepare-antora-suma-$(LANGCODE_CS)
prepare-antora-suma-$(LANGCODE_CS):
	-mkdir -p $(LANGDIR_CS) && \
	cp -a antora.yml $(LANGDIR_CS)/antora.yml && \
	sed "s/\.\/branding/\.\.\/\.\.\/branding/;\
	s/\-\ url\:\ \./\-\ url\:\ \.\.\/\.\.\//;\
	s/start_path\:\ \./\start_path\:\ translations\/$(LANGCODE_CS)/;\
	s/dir:\ \.\/build\/en/dir:\ \.\.\/\.\.\/build\/$(LANGCODE_CS)/;" suma-site.yml > $(LANGDIR_CS)/suma-site.yml && \
	cd $(LANGDIR_CS) && \
	if [ ! -e branding ]; then ln -s ../../branding; fi && \
	cp -a $(CURDIR)/modules/ROOT/pages/common_gfdl1.2_i.adoc $(CURDIR)/$(LANGDIR_CS)/modules/ROOT/pages/

.PHONY: antora-suma-$(LANGCODE_CS)
antora-suma-$(LANGCODE_CS): clean-$(LANGCODE_CS) pdf-all-suma-$(LANGCODE_CS) pdf-tar-suma-$(LANGCODE_CS)
#	$(call enable-suma-in-antorayml,.)
	$(call antora-suma-function,$(LANGDIR_CS),$(LANGCODE_CS))

.PHONY: obs-packages-suma-$(LANGCODE_CS)
obs-packages-suma-$(LANGCODE_CS): clean-$(LANGCODE_CS) pdf-all-suma-$(LANGCODE_CS) antora-suma-$(LANGCODE_CS) ## Generate SUMA OBS tar files
	$(call obs-packages-product,$(LANGCODE_CS),$(LANGCODE_CS)/pdf,$(HTML_OUTPUT_SUMA_CS),$(PDF_OUTPUT_SUMA_CS))

# Generate PDF versions of all SUMA books
.PHONY: pdf-all-suma-$(LANGCODE_CS)
pdf-all-suma-$(LANGCODE_CS):  translations prepare-antora-suma-$(LANGCODE_CS) pdf-install-suma-$(LANGCODE_CS) pdf-client-configuration-suma-$(LANGCODE_CS) pdf-upgrade-suma-$(LANGCODE_CS) pdf-reference-suma-$(LANGCODE_CS) pdf-administration-suma-$(LANGCODE_CS) pdf-salt-suma-$(LANGCODE_CS) pdf-retail-suma-$(LANGCODE_CS) pdf-quickstart-public-cloud-suma-$(LANGCODE_CS) pdf-large-deployment-suma-$(LANGCODE_CS) ##pdf-architecture-suma-webui-$(LANGCODE_CS)

.PHONY: modules/installation/nav-installation-guide.pdf.$(LANGCODE_CS).adoc
modules/installation/nav-installation-guide.pdf.$(LANGCODE_CS).adoc:
	$(call pdf-book-create-index,$(LANGDIR_CS),installation,$(LANGCODE_CS))

## Generate PDF version of the SUMA Installation Guide
.PHONY: pdf-install-suma-$(LANGCODE_CS)
pdf-install-suma-$(LANGCODE_CS): modules/installation/nav-installation-guide.pdf.$(LANGCODE_CS).adoc
	$(call pdf-install-product,$(LANGDIR_CS),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))


.PHONY: modules/client-configuration/nav-client-configuration-guide.pdf.$(LANGCODE_CS).adoc
modules/client-configuration/nav-client-configuration-guide.pdf.$(LANGCODE_CS).adoc:
	$(call pdf-book-create-index,$(LANGDIR_CS),client-configuration,$(LANGCODE_CS))

## Generate PDF version of the SUMA Client Configuration Guide
.PHONY: pdf-client-configuration-suma-$(LANGCODE_CS)
pdf-client-configuration-suma-$(LANGCODE_CS): modules/client-configuration/nav-client-configuration-guide.pdf.$(LANGCODE_CS).adoc
	$(call pdf-client-configuration-product,$(LANGDIR_CS),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))

.PHONY: modules/upgrade/nav-upgrade-guide.pdf.$(LANGCODE_CS).adoc
modules/upgrade/nav-upgrade-guide.pdf.$(LANGCODE_CS).adoc:
	$(call pdf-book-create-index,$(LANGDIR_CS),upgrade,$(LANGCODE_CS))

## Generate PDF version of the SUMA Upgrade Guide
.PHONY: pdf-upgrade-suma-$(LANGCODE_CS)
pdf-upgrade-suma-$(LANGCODE_CS): modules/upgrade/nav-upgrade-guide.pdf.$(LANGCODE_CS).adoc
	$(call pdf-upgrade-product,$(LANGDIR_CS),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))

.PHONY: modules/reference/nav-reference-guide.pdf.$(LANGCODE_CS).adoc
modules/reference/nav-reference-guide.pdf.$(LANGCODE_CS).adoc:
	$(call pdf-book-create-index,$(LANGDIR_CS),reference,$(LANGCODE_CS))

## Generate PDF version of the SUMA Reference Manual
.PHONY: pdf-reference-suma-$(LANGCODE_CS)
pdf-reference-suma-$(LANGCODE_CS): modules/reference/nav-reference-guide.pdf.$(LANGCODE_CS).adoc
	$(call pdf-reference-product,$(LANGDIR_CS),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))

.PHONY: modules/administration/nav-administration-guide.pdf.$(LANGCODE_CS).adoc
modules/administration/nav-administration-guide.pdf.$(LANGCODE_CS).adoc:
	$(call pdf-book-create-index,$(LANGDIR_CS),administration,$(LANGCODE_CS))

.PHONY: pdf-administration-suma-$(LANGCODE_CS)
## Generate PDF version of the SUMA Administration Guide
pdf-administration-suma-$(LANGCODE_CS): modules/administration/nav-administration-guide.pdf.$(LANGCODE_CS).adoc
	$(call pdf-administration-product,$(LANGDIR_CS),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))

.PHONY: modules/salt/nav-salt-guide.pdf.$(LANGCODE_CS).adoc
modules/salt/nav-salt-guide.pdf.$(LANGCODE_CS).adoc:
	$(call pdf-book-create-index,$(LANGDIR_CS),salt,$(LANGCODE_CS))

.PHONY: pdf-salt-suma-$(LANGCODE_CS)
## Generate PDF version of the SUMA Salt Guide
pdf-salt-suma-$(LANGCODE_CS): modules/salt/nav-salt-guide.pdf.$(LANGCODE_CS).adoc
	$(call pdf-salt-product,$(LANGDIR_CS),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))

.PHONY: modules/retail/nav-retail-guide.pdf.$(LANGCODE_CS).adoc
modules/retail/nav-retail-guide.pdf.$(LANGCODE_CS).adoc:
	$(call pdf-book-create-index,$(LANGDIR_CS),retail,$(LANGCODE_CS))

.PHONY: pdf-retail-suma-$(LANGCODE_CS)
## Generate PDF version of the SUMA Retail Guide
pdf-retail-suma-$(LANGCODE_CS): modules/retail/nav-retail-guide.pdf.$(LANGCODE_CS).adoc
	$(call pdf-retail-product,$(LANGDIR_CS),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))

.PHONY: modules/large-deployments/nav-large-deployments.pdf.$(LANGCODE_CS).adoc
modules/large-deployments/nav-large-deployments.pdf.$(LANGCODE_CS).adoc:
	$(call pdf-book-create-index,$(LANGDIR_CS),large-deployments,$(LANGCODE_CS))

.PHONY: pdf-large-deployment-suma-$(LANGCODE_CS)
## Generate PDF version of the SUMA Large Deployment Guide
pdf-large-deployment-suma-$(LANGCODE_CS): modules/large-deployments/nav-large-deployments.pdf.$(LANGCODE_CS).adoc
	$(call pdf-large-deployment-product,$(LANGDIR_CS),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))


#.PHONY: modules/architecture/nav-architecture-guide.pdf.$(LANGCODE_CS).adoc
#modules/architecture/nav-architecture-guide.pdf.$(LANGCODE_CS).adoc:
#	$(call pdf-book-create-index,$(LANGDIR_CS),architecture,$(LANGCODE_CS))

#.PHONY: pdf-architecture-suma-$(LANGCODE_CS)
### Generate PDF version of the SUMA Architecture Guide
#pdf-architecture-suma-$(LANGCODE_CS): modules/architecture/nav-architecture-guide.pdf.$(LANGCODE_CS).adoc
#	$(call pdf-architecture-product,$(LANGDIR_CS),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))

.PHONY: modules/quickstart-public-cloud/nav-quickstart-public-cloud-guide.pdf.$(LANGCODE_CS).adoc
modules/quickstart-public-cloud/nav-quickstart-public-cloud-guide.pdf.$(LANGCODE_CS).adoc:
	$(call pdf-book-create-index,$(LANGDIR_CS),quickstart-public-cloud,$(LANGCODE_CS))

.PHONY: pdf-quickstart-public-cloud-suma-$(LANGCODE_CS)
## Generate PDF version of the SUMA Quickstart Guide for Public Cloud
pdf-quickstart-public-cloud-suma-$(LANGCODE_CS): modules/quickstart-public-cloud/nav-quickstart-public-cloud-guide.pdf.$(LANGCODE_CS).adoc
	$(call pdf-quickstart-public-cloud-product,$(LANGDIR_CS),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))

.PHONY: modules/quickstart-sap/nav-quickstart-sap-guide.pdf.$(LANGCODE_CS).adoc
modules/quickstart-sap/nav-quickstart-sap-guide.pdf.$(LANGCODE_CS).adoc:
	$(call pdf-book-create-index,$(LANGDIR_CS),quickstart-sap,$(LANGCODE_CS))

.PHONY: pdf-quickstart-sap-suma-$(LANGCODE_CS)
## Generate PDF version of the SUMA Quickstart Guide for SAP
pdf-quickstart-sap-suma-$(LANGCODE_CS): modules/quickstart-sap/nav-quickstart-sap-guide.pdf.$(LANGCODE_CS).adoc
	$(call pdf-quickstart-sap-product,$(LANGDIR_CS),$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))

.PHONY: modules/quickstart-uyuni/nav-quickstart-uyuni-guide.pdf.$(LANGCODE_CS).adoc
modules/quickstart-uyuni/nav-quickstart-uyuni-guide.pdf.$(LANGCODE_CS).adoc:
	$(call pdf-book-create-index,$(LANGDIR_CS),quickstart-uyuni,$(LANGCODE_CS))

# UYUNI

.PHONY: validate-uyuni-$(LANGCODE_CS)
validate-uyuni-$(LANGCODE_CS):
	$(call validate-product,$(LANGDIR_CS),uyuni-site.yml)

.PHONY: pdf-tar-uyuni-$(LANGCODE_CS)
pdf-tar-uyuni-$(LANGCODE_CS):
	$(call pdf-tar-product,$(LANGCODE_CS),$(PDF_OUTPUT_UYUNI_CS),$(PDF_BUILD_DIR_CS))

.PHONY: prepare-antora-uyuni-$(LANGCODE_CS)
prepare-antora-uyuni-$(LANGCODE_CS):
	-mkdir -p $(LANGDIR_CS) && \
	cp antora.yml $(LANGDIR_CS)/antora.yml && \
	sed "s/\.\/branding/\.\.\/\.\.\/branding/;\
	s/\-\ url\:\ \./\-\ url\:\ \.\.\/\.\.\//;\
	s/start_path\:\ \./\start_path\:\ translations\/$(LANGCODE_CS)/;\
	s/dir:\ \.\/build\/en/dir:\ \.\.\/\.\.\/build\/$(LANGCODE_CS)/;" uyuni-site.yml > $(LANGDIR_CS)/uyuni-site.yml && \
	cd $(LANGDIR_CS) && \
	if [ ! -e branding ]; then ln -s ../../branding; fi && \
	cp -a $(CURDIR)/modules/ROOT/pages/common_gfdl1.2_i.adoc $(CURDIR)/$(LANGDIR_CS)/modules/ROOT/pages/

.PHONY: antora-uyuni-$(LANGCODE_CS)
antora-uyuni-$(LANGCODE_CS): clean-$(LANGCODE_CS) pdf-all-uyuni-$(LANGCODE_CS) pdf-tar-uyuni-$(LANGCODE_CS)
	$(call antora-uyuni-function,$(LANGDIR_CS),$(LANGCODE_CS))

.PHONY: obs-packages-uyuni-$(LANGCODE_CS)
obs-packages-uyuni-$(LANGCODE_CS): clean-$(LANGCODE_CS) pdf-all-uyuni-$(LANGCODE_CS) antora-uyuni-$(LANGCODE_CS) ## Generate UYUNI OBS tar files
	$(call obs-packages-product,$(LANGCODE_CS),$(LANGCODE_CS)/pdf,$(HTML_OUTPUT_UYUNI_CS),$(PDF_OUTPUT_UYUNI_CS))

# Generate PDF versions of all UYUNI books
.PHONY: pdf-all-uyuni-$(LANGCODE_CS)
pdf-all-uyuni-$(LANGCODE_CS): translations prepare-antora-uyuni-$(LANGCODE_CS) pdf-install-uyuni-$(LANGCODE_CS) pdf-client-configuration-uyuni-$(LANGCODE_CS) pdf-upgrade-uyuni-$(LANGCODE_CS) pdf-reference-uyuni-$(LANGCODE_CS) pdf-administration-uyuni-$(LANGCODE_CS) pdf-salt-uyuni-$(LANGCODE_CS) pdf-retail-uyuni-$(LANGCODE_CS) pdf-quickstart-public-cloud-uyuni-$(LANGCODE_CS) pdf-quickstart-uyuni-uyuni-$(LANGCODE_CS) pdf-large-deployment-uyuni-$(LANGCODE_CS) ##pdf-architecture-uyuni-webui-$(LANGCODE_CS)

## Generate PDF version of the UYUNI Installation Guide
.PHONY: pdf-install-uyuni-$(LANGCODE_CS)
pdf-install-uyuni-$(LANGCODE_CS): modules/installation/nav-installation-guide.pdf.$(LANGCODE_CS).adoc
	$(call pdf-install-product-uyuni,$(LANGDIR_CS),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))

## Generate PDF version of the UYUNI Client Configuration Guide
.PHONY: pdf-client-configuration-uyuni-$(LANGCODE_CS)
pdf-client-configuration-uyuni-$(LANGCODE_CS): modules/client-configuration/nav-client-configuration-guide.pdf.$(LANGCODE_CS).adoc
	$(call pdf-client-configuration-product-uyuni,$(LANGDIR_CS),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))

## Generate PDF version of the UYUNI Upgrade Guide
.PHONY: pdf-upgrade-uyuni-$(LANGCODE_CS)
pdf-upgrade-uyuni-$(LANGCODE_CS): modules/upgrade/nav-upgrade-guide.pdf.$(LANGCODE_CS).adoc
	$(call pdf-upgrade-product-uyuni,$(LANGDIR_CS),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))

## Generate PDF version of the UYUNI Reference Manual
.PHONY: pdf-reference-uyuni-$(LANGCODE_CS)
pdf-reference-uyuni-$(LANGCODE_CS): modules/reference/nav-reference-guide.pdf.$(LANGCODE_CS).adoc
	$(call pdf-reference-product-uyuni,$(LANGDIR_CS),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))

.PHONY: pdf-administration-uyuni-$(LANGCODE_CS)
## Generate PDF version of the UYUNI Administration Guide
pdf-administration-uyuni-$(LANGCODE_CS): modules/administration/nav-administration-guide.pdf.$(LANGCODE_CS).adoc
	$(call pdf-administration-product-uyuni,$(LANGDIR_CS),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))

.PHONY: pdf-salt-uyuni-$(LANGCODE_CS)
## Generate PDF version of the UYUNI Salt Guide
pdf-salt-uyuni-$(LANGCODE_CS): modules/salt/nav-salt-guide.pdf.$(LANGCODE_CS).adoc
	$(call pdf-salt-product-uyuni,$(LANGDIR_CS),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))

.PHONY: pdf-retail-uyuni-$(LANGCODE_CS)
## Generate PDF version of the UYUNI Retail Guide
pdf-retail-uyuni-$(LANGCODE_CS): modules/retail/nav-retail-guide.pdf.$(LANGCODE_CS).adoc
	$(call pdf-retail-product-uyuni,$(LANGDIR_CS),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))

.PHONY: pdf-large-deployment-uyuni-$(LANGCODE_CS)
## Generate PDF version of the UYUNI Large Deployment Guide
pdf-large-deployment-uyuni-$(LANGCODE_CS): modules/large-deployments/nav-large-deployments.pdf.$(LANGCODE_CS).adoc
	$(call pdf-large-deployment-product-uyuni,$(LANGDIR_CS),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))

#.PHONY: pdf-architecture-uyuni-$(LANGCODE_CS)
### Generate PDF version of the UYUNI Architecture Guide
#pdf-architecture-uyuni-$(LANGCODE_CS): modules/architecture/nav-architecture-guide.pdf.$(LANGCODE_CS).adoc
#	$(call pdf-architecture-product-uyuni,$(LANGDIR_CS),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))

.PHONY: pdf-quickstart-public-cloud-uyuni-$(LANGCODE_CS)
## Generate PDF version of the UYUNI Quickstart Guide for Public Cloud
pdf-quickstart-public-cloud-uyuni-$(LANGCODE_CS): modules/quickstart-public-cloud/nav-quickstart-public-cloud-guide.pdf.$(LANGCODE_CS).adoc
	$(call pdf-quickstart-public-cloud-product-uyuni,$(LANGDIR_CS),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))

.PHONY: pdf-quickstart-sap-uyuni-$(LANGCODE_CS)
## Generate PDF version of the UYUNI Quickstart Guide for SAP
pdf-quickstart-sap-uyuni-$(LANGCODE_CS): modules/quickstart-sap/nav-quickstart-sap-guide.pdf.$(LANGCODE_CS).adoc
	$(call pdf-quickstart-sap-product-uyuni,$(LANGDIR_CS),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))

.PHONY: pdf-quickstart-uyuni-uyuni-$(LANGCODE_CS)
## Generate PDF version of the UYUNI Quickstart Guide for Uyuni
pdf-quickstart-uyuni-uyuni-$(LANGCODE_CS): modules/quickstart-uyuni/nav-quickstart-uyuni-guide.pdf.$(LANGCODE_CS).adoc
	$(call pdf-quickstart-uyuni-product-uyuni,$(LANGDIR_CS),$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_CS),$(LANGCODE_CS),$(LOCALE_CS),$(GNUDATEFORMAT_CS))
