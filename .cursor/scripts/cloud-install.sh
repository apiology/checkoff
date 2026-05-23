#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

if ! command -v ruby >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y --no-install-recommends \
    ruby-full \
    bundler \
    build-essential \
    pkg-config \
    libssl-dev \
    zlib1g-dev \
    libreadline-dev \
    libyaml-dev \
    git \
    ca-certificates
fi

# Ensure user-installed gem executables are available.
USER_GEM_BIN="$(ruby -r rubygems -e 'print Gem.user_dir')/bin"
export PATH="${USER_GEM_BIN}:${PATH}"

# Match lockfile bundler so downstream tools (rbs/tapioca/sorbet) activate cleanly.
export BUNDLER_VERSION=2.6.9

# Keep gems project-local so installs work in locked-down images.
bundle config set --local path vendor/bundle

# Align with lockfile's bundler (install if missing, then continue).
if ! bundle "_${BUNDLER_VERSION}_" -v >/dev/null 2>&1; then
  gem install bundler -v "${BUNDLER_VERSION}" --no-document --user-install
fi

bundle "_${BUNDLER_VERSION}_" install --jobs 4 --retry 3

# Sorbet config includes a machine-specific cache file.
if [ -d sorbet ] && [ ! -f sorbet/machine_specific_config ]; then
  mkdir -p "${HOME}/.sorbet-cache"
  printf '%s\n' "--cache-dir=${HOME}/.sorbet-cache" > sorbet/machine_specific_config
fi
