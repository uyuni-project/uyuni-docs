# Local Toolchain Setup

This guide installs everything needed to build the documentation directly on your machine without a container.

**Supported platforms:** openSUSE Leap 15.6 / SUSE Linux Enterprise 15 SP6, openSUSE Tumbleweed, Ubuntu 24.04 LTS

---

## 1. Install Task

[Task](https://taskfile.dev) is the build runner that replaces Make.

```bash
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin
```

The installer places the `task` binary in `~/.local/bin`. Make sure that directory is on your `$PATH`:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

> **openSUSE Leap 15.6 / Leap 16:** Do not install Task via `zypper` — the packaged version is too old (2.x).
> Always use the install script above.

Verify:
```bash
task --version
# Task version: v3.43.3 (or newer)
```

---

## 2. Install Go

The build system includes a Go binary (`cmd/docbuild`) that generates Antora configuration files.

**openSUSE / SLES:**
```bash
sudo zypper install go
```

**Ubuntu:**
```bash
sudo apt-get install -y golang-go
```

Or install the upstream binary (recommended for latest version):
```bash
GO_VERSION=1.24.3
curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz | sudo tar -C /usr/local -xz
echo 'export PATH="/usr/local/go/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

Verify:
```bash
go version
# go version go1.24.3 linux/amd64 (or newer)
```

---

## 3. Install Node.js and Antora

Antora requires Node.js 18 or newer. Node.js 22 LTS is recommended.

**openSUSE / SLES:**
```bash
sudo zypper install nodejs22 npm22
```

**Ubuntu:**
```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs
```

Install Antora and extensions globally:
```bash
npm install -g \
    @antora/cli \
    @antora/site-generator \
    @antora/lunr-extension \
    @asciidoctor/tabs
```

Verify:
```bash
antora --version
```

---

## 4. Install Ruby and Asciidoctor PDF

**openSUSE / SLES:**
```bash
sudo zypper install ruby ruby-devel gcc make
```

**Ubuntu:**
```bash
sudo apt-get install -y ruby ruby-dev build-essential
```

Install Asciidoctor PDF and the Rouge syntax highlighter:
```bash
gem install asciidoctor-pdf rouge --no-document
```

Verify:
```bash
asciidoctor-pdf --version
```

---

## 5. po4a (legacy — not required for builds)

The build no longer uses po4a or Weblate. Translations are committed as AsciiDoc under
`{lang}/modules/` at the repo root. See [L10N-AI-MIGRATION.md](../L10N-AI-MIGRATION.md).

po4a is not included in the builder container image. Install locally only if you need to
run the deprecated `scripts/make_pot.sh` manually:

**openSUSE / SLES:**
```bash
sudo zypper install po4a
```

**Ubuntu:**
```bash
sudo apt-get install -y po4a
```

---

## 6. Build the Go binary and generate configs

After cloning the repository, run these once:

```bash
task setup    # Compiles cmd/docbuild → .bin/docbuild
task gen      # Generates all Antora/site configs from config.yml
```

---

## 7. Build targets

Run `task` (no arguments) to see all available targets grouped by category.

```bash
# Full publish (HTML + PDFs + zips)
task publish:dsc            # MLM — documentation.suse.com
task publish:uyuni          # Uyuni — website
task publish:webui-mlm      # MLM WebUI
task publish:webui-uyuni    # Uyuni WebUI

# PDF builds
task pdf:mlm                # All MLM PDFs — all books, all languages
task pdf:uyuni              # All Uyuni PDFs — all books, all languages
task pdf:all                # All PDFs

# OBS packages
task obs:mlm                # OBS source packages for MLM
task obs:uyuni              # OBS source packages for Uyuni

# Validation
task validate:mlm           # Antora xref validation — MLM
task validate:uyuni         # Antora xref validation — Uyuni

# Cleanup
task clean                  # Remove build/, translations/, .cache/
```

### Build a single PDF book

Use the `pdf` task with `BOOK=`, `PRODUCT=`, and `LANG=` variables:

```bash
# Build the Administration Guide for MLM in English
task pdf BOOK=administration PRODUCT=mlm LANG=en

# Build the Installation and Upgrade Guide for Uyuni in Japanese
task pdf BOOK=installation-and-upgrade PRODUCT=uyuni LANG=ja
```

Available books: `installation-and-upgrade` `client-configuration` `administration` `reference` `retail` `common-workflows` `specialized-guides` `legal`

Available languages: `en` `ja` `zh_CN` `ko`

Output is written to `build/{lang}/pdf/`.

---

## Troubleshooting

**`antora: command not found`**
npm global binaries are not in your PATH. Add the npm global bin directory:
```bash
echo 'export PATH="$(npm -g bin):$PATH"' >> ~/.bashrc && source ~/.bashrc
```

**`asciidoctor-pdf: command not found`**
Ruby gem binaries are not in your PATH. Add:
```bash
echo 'export PATH="$(ruby -e "puts Gem.user_dir")/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

**Go build fails with `go.mod` errors**
Ensure you are at least on Go 1.22:
```bash
go version
```
If your distro ships an older version, install from [go.dev/dl](https://go.dev/dl/).
