PDF_BUILD_DIR_ES := $(CURDIR)/build/pdf/es

# SUMA OBS Tarball Filenames
HTML_OUTPUT_SUMA_ES ?= susemanager-docs_es
PDF_OUTPUT_SUMA_ES ?= susemanager-docs_es-pdf

# UYUNI OBS Tarball Filenames
HTML_OUTPUT_UYUNI_ES ?= uyuni-docs_es
PDF_OUTPUT_UYUNI_ES ?= uyuni-docs_es-pdf

# Clean up build artifacts
.PHONY: clean-es
clean-es: ## Remove build artifacts from output directory (Antora and PDF)
	$(call clean-function,translations/es)

.PHONY: validate-suma-es
validate-suma-es:
	$(call validate-product,translations/es,suma-site.yml)

.PHONY: pdf-tar-suma-es
pdf-tar-suma-es:
	$(call pdf-tar-product,translations/es,$(PDF_OUTPUT_SUMA_ES),$(PDF_BUILD_DIR_ES))

# TODO Translate suma-site.yml
# antora-suma-es: clean-es pdf-all-suma-es pdf-tar-suma-es
.PHONY: prepare-antora-suma-es
prepare-antora-suma-es:
	-mkdir -p translations/es && \
	cp antora.yml translations/es/antora.yml && \
	sed "s/\.\/branding/\.\.\/\.\.\/branding/;\
	s/\-\ url\:\ \./\-\ url\:\ \.\.\/\.\.\//;\
	s/start_path\:\ \./\start_path\:\ translations\/es/;\
	s/dir:\ \.\/build\/en/dir:\ \.\.\/\.\.\/build\/es/;" suma-site.yml > translations/es/suma-site.yml && \
	cd translations/es && \
	if [ ! -e branding ]; then ln -s ../../branding; fi

.PHONY: antora-suma-es
antora-suma-es:	clean-es prepare-antora-suma-es translations pdf-all-suma-es pdf-tar-suma-es
	$(call enable-suma-in-antorayml,.)
	$(call antora-suma-function,translations/es)

.PHONY: obs-packages-suma-es
obs-packages-suma-es: clean-es pdf-all-suma-es antora-suma-es ## Generate SUMA OBS tar files
	$(call obs-packages-product,translations/es,$(PDF_BUILD_DIR_ES),$(HTML_OUTPUT_SUMA_ES),$(PDF_OUTPUT_SUMA_ES))

# Generate PDF versions of all SUMA books
.PHONY: pdf-all-suma-es
pdf-all-suma-es: pdf-install-suma-es pdf-client-configuration-suma-es pdf-upgrade-suma-es pdf-reference-suma-es pdf-administration-suma-es pdf-salt-suma-es pdf-retail-suma-es pdf-quickstart-public-cloud-suma-es pdf-large-deployment-suma-es ##pdf-architecture-suma-webui-es

.PHONY: modules/installation/nav-installation-guide.pdf.es.adoc
modules/installation/nav-installation-guide.pdf.es.adoc:
	$(call pdf-book-create-index,translations/es,installation)

## Generate PDF version of the SUMA Installation Guide
.PHONY: pdf-install-suma-es
pdf-install-suma-es: modules/installation/nav-installation-guide.pdf.es.adoc
	$(call pdf-install-product,translations/es,$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES))


.PHONY: modules/client-configuration/nav-client-configuration-guide.pdf.es.adoc
modules/client-configuration/nav-client-configuration-guide.pdf.es.adoc:
	$(call pdf-book-create-index,translations/es,client-configuration)

## Generate PDF version of the SUMA Client Configuration Guide
.PHONY: pdf-client-configuration-suma-es
pdf-client-configuration-suma-es: modules/client-configuration/nav-client-configuration-guide.pdf.es.adoc
	$(call pdf-client-configuration-product,translations/es,$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES))

.PHONY: modules/upgrade/nav-upgrade-guide.pdf.es.adoc
modules/upgrade/nav-upgrade-guide.pdf.es.adoc:
	$(call pdf-book-create-index,translations/es,upgrade)

## Generate PDF version of the SUMA Upgrade Guide
.PHONY: pdf-upgrade-suma-es
pdf-upgrade-suma-es: modules/upgrade/nav-upgrade-guide.pdf.es.adoc
	$(call pdf-upgrade-product,translations/es,$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES))

.PHONY: modules/reference/nav-reference-guide.pdf.es.adoc
modules/reference/nav-reference-guide.pdf.es.adoc:
	$(call pdf-book-create-index,translations/es,reference)

## Generate PDF version of the SUMA Reference Manual
.PHONY: pdf-reference-suma-es
pdf-reference-suma-es: modules/reference/nav-reference-guide.pdf.es.adoc
	$(call pdf-reference-product,translations/es,$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES))

.PHONY: modules/administration/nav-administration-guide.pdf.es.adoc
modules/administration/nav-administration-guide.pdf.es.adoc:
	$(call pdf-book-create-index,translations/es,administration)

.PHONY: pdf-administration-suma-es
## Generate PDF version of the SUMA Administration Guide
pdf-administration-suma-es: modules/administration/nav-administration-guide.pdf.es.adoc
	$(call pdf-administration-product,translations/es,$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES))

.PHONY: modules/salt/nav-salt-guide.pdf.es.adoc
modules/salt/nav-salt-guide.pdf.es.adoc:
	$(call pdf-book-create-index,translations/es,salt)

.PHONY: pdf-salt-suma-es
## Generate PDF version of the SUMA Salt Guide
pdf-salt-suma-es: modules/salt/nav-salt-guide.pdf.es.adoc
	$(call pdf-salt-product,translations/es,$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES))

.PHONY: modules/retail/nav-retail-guide.pdf.es.adoc
modules/retail/nav-retail-guide.pdf.es.adoc:
	$(call pdf-book-create-index,translations/es,retail)

.PHONY: pdf-retail-suma-es
## Generate PDF version of the SUMA Retail Guide
pdf-retail-suma-es: modules/retail/nav-retail-guide.pdf.es.adoc
	$(call pdf-retail-product,translations/es,$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES))

.PHONY: modules/large-deployments/nav-large-deployments.pdf.es.adoc
modules/large-deployments/nav-large-deployments.pdf.es.adoc:
	$(call pdf-book-create-index,translations/es,large-deployments)

.PHONY: pdf-large-deployment-suma-es
## Generate PDF version of the SUMA Large Deployment Guide
pdf-large-deployment-suma-es: modules/large-deployments/nav-large-deployments.pdf.es.adoc
	$(call pdf-large-deployment-product,translations/es,$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES))


.PHONY: modules/architecture/nav-architecture-guide.pdf.es.adoc
modules/architecture/nav-architecture-guide.pdf.es.adoc:
	$(call pdf-book-create-index,translations/es,architecture)

.PHONY: pdf-architecture-suma-es
## Generate PDF version of the SUMA Architecture Guide
pdf-architecture-suma-es: modules/architecture/nav-architecture-guide.pdf.es.adoc
	$(call pdf-architecture-product,translations/es,$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES))

.PHONY: modules/quickstart-public-cloud/nav-quickstart-public-cloud-guide.pdf.es.adoc
modules/quickstart-public-cloud/nav-quickstart-public-cloud-guide.pdf.es.adoc:
	$(call pdf-book-create-index,translations/es,quickstart-public-cloud)

.PHONY: pdf-quickstart-public-cloud-suma-es
## Generate PDF version of the SUMA Quickstart Guide for Public Cloud
pdf-quickstart-public-cloud-suma-es: modules/quickstart-public-cloud/nav-quickstart-public-cloud-guide.pdf.es.adoc
	$(call pdf-quickstart-public-cloud-product,translations/es,$(PDF_THEME_SUMA),$(PRODUCTNAME_SUMA),$(SUMA_CONTENT),$(FILENAME_SUMA),$(PDF_BUILD_DIR_ES))


# UYUNI

.PHONY: validate-uyuni-es
validate-uyuni-es:
	$(call validate-product,translations/es,uyuni-site.yml)

.PHONY: pdf-tar-uyuni-es
pdf-tar-uyuni-es:
	$(call pdf-tar-product,translations/es,$(PDF_OUTPUT_UYUNI_ES),$(PDF_BUILD_DIR_ES))

# TODO Translate uyuni-site.yml
# antora-uyuni-es: clean-es pdf-all-uyuni-es pdf-tar-uyuni-es
.PHONY: prepare-antora-uyuni-es
prepare-antora-uyuni-es:
	-mkdir -p translations/es && \
	cp antora.yml translations/es/antora.yml && \
	sed "s/\.\/branding/\.\.\/\.\.\/branding/;\
	s/\-\ url\:\ \./\-\ url\:\ \.\.\/\.\.\//;\
	s/start_path\:\ \./\start_path\:\ translations\/es/;\
	s/dir:\ \.\/build\/en/dir:\ \.\.\/\.\.\/build\/es/;" uyuni-site.yml > translations/es/uyuni-site.yml && \
	cd translations/es && \
	if [ ! -e branding ]; then ln -s ../../branding; fi

.PHONY: antora-uyuni-es
antora-uyuni-es: clean-es prepare-antora-uyuni-es translations pdf-all-uyuni-es pdf-tar-uyuni-es
	$(call antora-uyuni-function,translations/es)

.PHONY: obs-packages-uyuni-es
obs-packages-uyuni-es: clean-es pdf-all-uyuni-es antora-uyuni-es ## Generate UYUNI OBS tar files
	$(call obs-packages-product,$(PDF_BUILD_DIR_ES),translations/es,$(HTML_OUTPUT_UYUNI_ES),$(PDF_OUTPUT_UYUNI_ES))

# Generate PDF versions of all UYUNI books
.PHONY: pdf-all-uyuni-es
pdf-all-uyuni-es: pdf-install-uyuni-es pdf-client-configuration-uyuni-es pdf-upgrade-uyuni-es pdf-reference-uyuni-es pdf-administration-uyuni-es pdf-salt-uyuni-es pdf-retail-uyuni-es pdf-quickstart-public-cloud-uyuni-es pdf-large-deployment-uyuni-es ##pdf-architecture-uyuni-webui-es

## Generate PDF version of the UYUNI Installation Guide
.PHONY: pdf-install-uyuni-es
pdf-install-uyuni-es: modules/installation/nav-installation-guide.pdf.es.adoc
	$(call pdf-install-product-uyuni,translations/es,$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES))

## Generate PDF version of the UYUNI Client Configuration Guide
.PHONY: pdf-client-configuration-uyuni-es
pdf-client-configuration-uyuni-es: modules/client-configuration/nav-client-configuration-guide.pdf.es.adoc
	$(call pdf-client-configuration-product-uyuni,translations/es,$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES))

## Generate PDF version of the UYUNI Upgrade Guide
.PHONY: pdf-upgrade-uyuni-es
pdf-upgrade-uyuni-es: modules/upgrade/nav-upgrade-guide.pdf.es.adoc
	$(call pdf-upgrade-product-uyuni,translations/es,$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES))

## Generate PDF version of the UYUNI Reference Manual
.PHONY: pdf-reference-uyuni-es
pdf-reference-uyuni-es: modules/reference/nav-reference-guide.pdf.es.adoc
	$(call pdf-reference-product-uyuni,translations/es,$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES))

.PHONY: pdf-administration-uyuni-es
## Generate PDF version of the UYUNI Administration Guide
pdf-administration-uyuni-es: modules/administration/nav-administration-guide.pdf.es.adoc
	$(call pdf-administration-product-uyuni,translations/es,$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES))

.PHONY: pdf-salt-uyuni-es
## Generate PDF version of the UYUNI Salt Guide
pdf-salt-uyuni-es: modules/salt/nav-salt-guide.pdf.es.adoc
	$(call pdf-salt-product-uyuni,translations/es,$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES))

.PHONY: pdf-retail-uyuni-es
## Generate PDF version of the UYUNI Retail Guide
pdf-retail-uyuni-es: modules/retail/nav-retail-guide.pdf.es.adoc
	$(call pdf-retail-product-uyuni,translations/es,$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES))

.PHONY: pdf-large-deployment-uyuni-es
## Generate PDF version of the UYUNI Large Deployment Guide
pdf-large-deployment-uyuni-es: modules/large-deployments/nav-large-deployments.pdf.es.adoc
	$(call pdf-large-deployment-product-uyuni,translations/es,$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES))

.PHONY: pdf-architecture-uyuni-es
## Generate PDF version of the UYUNI Architecture Guide
pdf-architecture-uyuni-es: modules/architecture/nav-architecture-guide.pdf.es.adoc
	$(call pdf-architecture-product-uyuni,translations/es,$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES))

.PHONY: pdf-quickstart-public-cloud-uyuni-es
## Generate PDF version of the UYUNI Quickstart Guide for Public Cloud
pdf-quickstart-public-cloud-uyuni-es: modules/quickstart-public-cloud/nav-quickstart-public-cloud-guide.pdf.es.adoc
	$(call pdf-quickstart-public-cloud-product-uyuni,translations/es,$(PDF_THEME_UYUNI),$(PRODUCTNAME_UYUNI),$(UYUNI_CONTENT),$(FILENAME_UYUNI),$(PDF_BUILD_DIR_ES))
