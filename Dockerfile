# Alternative Dockerfile (for Docker users)
# This is identical to Containerfile but uses standard Docker conventions

FROM opensuse/leap:15.6

# Metadata
LABEL maintainer="Uyuni Project"
LABEL description="Uyuni Documentation Build Environment"
LABEL version="1.0"

# System packages
RUN zypper --non-interactive refresh && \
    zypper --non-interactive install -y \
    make git curl tar gzip findutils \
    python3 python3-pip python3-PyYAML python3-Jinja2 \
    ruby ruby-devel \
    nodejs20 npm20 \
    gettext-tools po4a \
    liberation-fonts \
    google-noto-sans-cjk-fonts \
    && zypper clean --all

# Ruby gems
RUN gem install --no-document asciidoctor asciidoctor-pdf rouge pygments.rb

# Node.js packages
RUN npm install -g --no-fund --no-audit \
    @antora/cli @antora/site-generator-default @antora/xref-validator lunr

# Task runner
RUN sh -c "$(curl -fsSL https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

# Python packages
RUN pip3 install --no-cache-dir pyyaml jinja2 click colorama

# Setup
WORKDIR /workspace
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 NODE_PATH=/usr/lib/node_modules

# Non-root user
RUN useradd -m -u 1000 -s /bin/bash builder
USER builder

CMD ["/bin/bash"]
