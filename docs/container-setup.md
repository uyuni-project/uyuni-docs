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

**openSUSE / SLES:**
```bash
sudo zypper install go-task
```

**Ubuntu:**
```bash
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

Verify:
```bash
task --version
```

---

## 4. Build the container image

This step builds the `uyuni-docs-builder` image locally from `Dockerfile.custom`.
It takes a few minutes and only needs to be done once (or after `Dockerfile.custom` changes).

```bash
task container:build
```

The image includes: Go, Task, Antora, Asciidoctor-PDF, po4a, and zip.

---

## 5. Build targets

Every build target has a `container:` prefixed equivalent.
Your local repository is mounted at `/docs` inside the container — output lands in `build/` on your host.

### HTML builds
```bash
task container:build:mlm-dsc          # MLM HTML — documentation.suse.com branding
task container:build:mlm-webui        # MLM HTML — product WebUI branding
task container:build:uyuni-website    # Uyuni HTML — website
task container:build:uyuni-webui      # Uyuni HTML — product WebUI
task container:build:all              # All four HTML targets
```

### PDF builds
```bash
task container:pdf:mlm                # All MLM PDFs — all books, all languages
task container:pdf:uyuni              # All Uyuni PDFs — all books, all languages
task container:pdf:all                # All PDFs
```

### Full publish (HTML + PDFs + zips)
```bash
task container:publish:dsc            # MLM — documentation.suse.com
task container:publish:uyuni          # Uyuni — website
task container:publish:webui-mlm      # MLM WebUI
task container:publish:webui-uyuni    # Uyuni WebUI
```

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

### Escape hatch
```bash
task container:run -- <any-task>
# Example:
task container:run -- build:mlm-dsc
```

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

**Rebuilding the image after a `Dockerfile.custom` change**
```bash
task container:build
```
This replaces the existing `uyuni-docs-builder:latest` image.
