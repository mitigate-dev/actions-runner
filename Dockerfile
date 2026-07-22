# mitigate-dev GitHub Actions runner image.
#
# Based on the official ARC runner (so it stays compatible with the
# gha-runner-scale-set chart / run.sh) plus a build toolchain and common headers
# so native gem extensions (bigdecimal, psych, pg, nokogiri, ...) compile without
# each workflow having to apt-get them at job time.
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
      libxml2-dev \
      libxslt1-dev \
      libvips \
    && rm -rf /var/lib/apt/lists/*

USER runner
