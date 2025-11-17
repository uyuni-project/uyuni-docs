# Containerfile (Podman/Docker)
# Build environment for Uyuni documentation
# Includes all dependencies: Node.js, Antora, Asciidoctor, Python, po4a, etc.

FROM opensuse/leap:15.6

# Metadata
LABEL maintainer="Uyuni Project"
LABEL description="Uyuni Documentation Build Environment"
LABEL version="1.0"

# ==============================================================================
# SYSTEM PACKAGES
# ==============================================================================

RUN zypper --non-interactive refresh && \
    zypper --non-interactive install -y \
    # Core build tools
    make \
    git \
    curl \
    tar \
    gzip \
    gzip \
    findutils \
    # Python 3.9 for modern build scripts (has dataclasses, better performance)
    python39 \
    # Ruby build dependencies (we'll install Ruby 3.3+ from source)
    gcc \
    gcc-c++ \
    automake \
    bison \
    libyaml-devel \
    libffi-devel \
    readline-devel \
    zlib-devel \
    openssl-devel \
    # Node.js for Antora
    nodejs20 \
    npm20 \
    # Translation tools
    gettext-tools \
    po4a \
    # Fonts for PDF generation (CJK support)
    liberation-fonts \
    google-noto-sans-cjk-fonts \
    # Cleanup
    && zypper clean --all

# ==============================================================================
# RUBY INSTALLATION (Latest stable - Ruby 3.3)
# ==============================================================================

# Install Ruby 3.3 from source (Leap 15.6 only has Ruby 2.5)
ENV RUBY_VERSION=3.3.7
RUN curl -fsSL https://cache.ruby-lang.org/pub/ruby/3.3/ruby-${RUBY_VERSION}.tar.gz | tar xz && \
    cd ruby-${RUBY_VERSION} && \
    ./configure --disable-install-doc --enable-shared && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf ruby-${RUBY_VERSION} && \
    gem update --system --no-document

# ==============================================================================
# RUBY GEMS (Asciidoctor ecosystem)
# ==============================================================================

# Install asciidoctor and asciidoctor-pdf (latest versions work with Ruby 3.3)
RUN gem install --no-document asciidoctor asciidoctor-pdf

# ==============================================================================
# NODE.JS PACKAGES (Antora ecosystem)
# ==============================================================================

# Install Antora and related tools globally
# Note: @antora/site-generator-default provides the implementation
# and @antora/site-generator is required as a dependency
RUN npm install -g --no-fund --no-audit \
    @antora/cli \
    @antora/site-generator \
    @antora/site-generator-default \
    @antora/lunr-extension \
    @asciidoctor/tabs \
    lunr

# ==============================================================================
# TASK RUNNER
# ==============================================================================

# Install Task (go-task) - modern build automation
RUN sh -c "$(curl -fsSL https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

# ==============================================================================
# PYTHON PACKAGES (for build scripts)
# ==============================================================================

# Bootstrap pip for Python 3.9 and install packages
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.9 && \
    python3.9 -m pip install --no-cache-dir \
        pyyaml \
        jinja2 \
        click \
        colorama

# Create python3 symlink to python3.9 for convenience
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 100

# ==============================================================================
# ENVIRONMENT SETUP
# ==============================================================================

# Set working directory
WORKDIR /workspace

# Set environment variables
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    NODE_PATH=/usr/lib/node_modules

# Default user (non-root for security)
RUN useradd -m -u 1000 -s /bin/bash builder
USER builder

# ==============================================================================
# ENTRY POINT
# ==============================================================================

# Default to bash shell, but can override to run task commands
CMD ["/bin/bash"]

# ==============================================================================
# USAGE EXAMPLES
# ==============================================================================
# Build the image:
#   podman build -t uyuni-docs:latest -f Containerfile .
#
# Run interactive shell:
#   podman run --rm -it -v $(pwd):/workspace:Z uyuni-docs:latest
#
# Build HTML in container:
#   podman run --rm -v $(pwd):/workspace:Z uyuni-docs:latest task html
#
# Build everything:
#   podman run --rm -v $(pwd):/workspace:Z uyuni-docs:latest task build:all
