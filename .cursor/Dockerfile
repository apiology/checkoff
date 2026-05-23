FROM ruby:3.2-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    libreadline-dev \
    libssl-dev \
    libyaml-dev \
    pkg-config \
    zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*
