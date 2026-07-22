# mitigate-dev GitHub Actions runner image.
#
# Based on the official ARC runner (so it stays compatible with the
# gha-runner-scale-set chart / run.sh) plus a build toolchain, common headers so
# native gem extensions (bigdecimal, psych, pg, nokogiri, ...) compile, the
# shared libraries headless Chrome needs (setup-chrome, system tests), and node
# + corepack-managed yarn/pnpm — so workflows don't have to bootstrap any of it
# at job time.
FROM ghcr.io/actions/actions-runner:latest

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
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
      fonts-liberation \
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

USER runner
