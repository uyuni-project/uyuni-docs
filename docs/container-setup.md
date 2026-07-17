# Container Build Setup

This guide lets you build the documentation using a container image.
**You only need Podman or Docker** — no Go, Node.js, Ruby, or other tools required on your machine.

---

## 1. Install Podman or Docker

**openSUSE Leap 15.6 / SLES 15:**
```bash
sudo zypper install podman
```

**openSUSE Tumbleweed:**
```bash
sudo zypper install podman
```

**Ubuntu 24.04 LTS:**
```bash
sudo apt-get install -y podman
```

Or install Docker instead:
```bash
# Ubuntu
sudo apt-get install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER   # log out and back in after this
```

Verify:
```bash
podman --version
# or
docker --version
```

---

## 2. Clone the repository

```bash
git clone https://github.com/uyuni-project/uyuni-docs.git
cd uyuni-docs
```

---

## 3. Install Task

Task is the only tool you need on the host — it drives the container for you.

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
```

---

## 4. Build the container image

This step builds the `uyuni-docs-builder` image locally from `Dockerfile.bci`.
It takes a few minutes and only needs to be done once (or after `Dockerfile.bci` changes).

```bash
task container:build
```

The image includes: Go, Task, Antora, Asciidoctor-PDF, and zip.

Translations are staged from committed `{lang}/modules/` trees (`task stage-content`).
po4a is not installed in the builder image. Legacy po4a scripts remain in the repo under
`scripts/` for manual use only.

---

## 5. Build targets

Run `task` (no arguments) to see all available targets grouped by category.

Every build target has a `container:` prefixed equivalent.
Your local repository is mounted at `/docs` inside the container — output lands in `build/` on your host.

### Full publish (HTML + PDFs + zips)
```bash
task container:publish:dsc            # MLM — documentation.suse.com
task container:publish:uyuni          # Uyuni — website
task container:publish:webui-mlm      # MLM WebUI
task container:publish:webui-uyuni    # Uyuni WebUI
```

### PDF builds
```bash
task container:pdf:mlm                # All MLM PDFs — all books, all languages
task container:pdf:uyuni              # All Uyuni PDFs — all books, all languages
task container:pdf:all                # All PDFs
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

### OBS packages
```bash
task container:obs:mlm                # OBS source packages for MLM
task container:obs:uyuni              # OBS source packages for Uyuni
```

### Validation
```bash
task container:validate:mlm           # Antora xref validation — MLM
task container:validate:uyuni         # Antora xref validation — Uyuni
```

### Interactive shell
```bash
task container:shell                  # Open a bash shell inside the container
```

Use this to debug builds, inspect generated files, or run one-off commands inside the toolchain environment.

---

## 6. Find your build output

After a build, output is written to your local `build/` directory:

```
build/{lang}/          ← HTML output per language
build/pdf/{lang}/      ← Collected PDFs per language
build/packages/        ← OBS source tarballs
```

---

## Troubleshooting

**`Error: short-name "uyuni-docs-builder:latest" did not resolve`**
You haven't built the image yet. Run `task container:build` first.

**Permission denied on `build/` files (SELinux / rootless Podman)**
The volume mount uses the `:Z` flag which handles SELinux relabelling automatically.
If you still see permission errors, check that your working directory is not on a filesystem
that blocks relabelling (e.g. NFS, network shares).

**`ERRO[0000] ... crun: ... permission denied`**
You may need to configure rootless Podman user namespaces:
```bash
sudo sysctl -w kernel.unprivileged_userns_clone=1   # temporary
# or permanently:
echo 'kernel.unprivileged_userns_clone=1' | sudo tee /etc/sysctl.d/99-userns.conf
```

**Docker users: `:Z` flag not needed**
If you use Docker instead of Podman, the `:Z` SELinux label flag is harmless but may produce a
warning. The `CONTAINER_CMD` variable in `Taskfile.yml` auto-detects `podman` first, then `docker`.

**Rebuilding the image after a `Dockerfile.bci` change**
```bash
task container:build
```
This replaces the existing `uyuni-docs-builder:latest` image.
