# mitigate-dev GitHub Actions runner image.
#
# Based on the official ARC runner (so it stays compatible with the
# gha-runner-scale-set chart / run.sh) plus a build toolchain, common headers so
# native gem extensions (bigdecimal, psych, pg, nokogiri, ...) compile, the
# shared libraries and fonts headless Chrome needs (setup-chrome, system tests),
# and node + corepack-managed yarn/pnpm — so workflows don't have to bootstrap
# any of it at job time.
FROM ghcr.io/actions/actions-runner:latest

USER root

# Canonical's mirrors (archive/security.ubuntu.com) are blackholed from the
# office network these runners live on — TCP connects but no data flows, so
# apt-get stalls at job time. Point apt at the regional Latvian mirror
# (koyanet.lv), which serves both the main and security pockets at full speed.
RUN sed -i 's|http://archive.ubuntu.com/ubuntu|http://lv.archive.ubuntu.com/ubuntu|g; s|http://security.ubuntu.com/ubuntu|http://lv.archive.ubuntu.com/ubuntu|g' \
      /etc/apt/sources.list.d/ubuntu.sources

RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      git-lfs \
      zstd \
      pkg-config \
      libyaml-dev \
      libssl-dev \
      zlib1g-dev \
      libffi-dev \
      libgmp-dev \
      libpq-dev \
      postgresql-client \
      libxml2-dev \
      libxslt1-dev \
      libvips \
      imagemagick \
      libmagickwand-dev \
      fonts-liberation \
      fonts-dejavu-core \
      fonts-noto-core \
      fonts-noto-color-emoji \
      libasound2t64 \
      libatk-bridge2.0-0t64 \
      libatk1.0-0t64 \
      libatspi2.0-0t64 \
      libcairo2 \
      libcups2t64 \
      libdbus-1-3 \
      libdrm2 \
      libexpat1 \
      libgbm1 \
      libglib2.0-0t64 \
      libgtk-3-0t64 \
      libnspr4 \
      libnss3 \
      libpango-1.0-0 \
      libx11-6 \
      libxcb1 \
      libxcomposite1 \
      libxdamage1 \
      libxext6 \
      libxfixes3 \
      libxi6 \
      libxkbcommon0 \
      libxrandr2 \
      libxtst6 \
      libu2f-udev \
      libvulkan1 \
      xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# Node (bootstrap) + corepack-managed yarn/pnpm, so setup-node's built-in cache
# works on the first call and workflows match GitHub-hosted behavior. setup-node
# still installs each repo's pinned version (.nvmrc) on top.
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && corepack enable \
    && rm -rf /var/lib/apt/lists/*

# Let ACTIONS_RESULTS_URL be set from the environment, so the runners can be
# pointed at our own GitHub Actions cache server (see ci.mitigate.dev/runner.yml)
# instead of GitHub's cloud cache. The worker hardcodes the variable name and
# overwrites whatever we set, so we rename the constant in the binary
# (ACTIONS_RESULTS_URL -> ACTIONS_RESULTS_ORL, same length) and it stops looking.
# This is the patch documented at
# https://gha-cache-server.falcondev.io/getting-started#binary-patch
#
# Safe against runner self-update, which would restore the stock binary: ARC's
# scale-set controller always registers runners with --disableupdate. Keeping the
# image current is on us (GitHub stops queueing jobs to runners ~30 days behind).
#
# The grep is not optional: if an upstream runner build ever changes that string
# the sed silently matches nothing, and caching would quietly stop working with
# no error anywhere. Fail the build instead. (strings comes from binutils, pulled
# in by build-essential above; -el reads 16-bit little-endian strings.)
RUN sed -i 's/\x41\x00\x43\x00\x54\x00\x49\x00\x4F\x00\x4E\x00\x53\x00\x5F\x00\x52\x00\x45\x00\x53\x00\x55\x00\x4C\x00\x54\x00\x53\x00\x5F\x00\x55\x00\x52\x00\x4C\x00/\x41\x00\x43\x00\x54\x00\x49\x00\x4F\x00\x4E\x00\x53\x00\x5F\x00\x52\x00\x45\x00\x53\x00\x55\x00\x4C\x00\x54\x00\x53\x00\x5F\x00\x4F\x00\x52\x00\x4C\x00/g' \
      /home/runner/bin/Runner.Worker.dll \
    && strings -el /home/runner/bin/Runner.Worker.dll | grep -q ACTIONS_RESULTS_ORL

USER runner
