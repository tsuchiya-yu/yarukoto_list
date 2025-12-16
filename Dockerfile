# syntax=docker/dockerfile:1.7

ARG RUBY_VERSION=3.3.1
ARG NODE_MAJOR=20
ARG DEBIAN_DISTRO=bookworm

FROM ruby:${RUBY_VERSION} as base

ARG NODE_MAJOR
ARG DEBIAN_DISTRO

ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_BIN=/usr/local/bundle/bin \
    GEM_HOME=/usr/local/bundle \
    PATH=/app/bin:/app/node_modules/.bin:$BUNDLE_BIN:$PATH \
    RAILS_ENV=development \
    NODE_ENV=development

WORKDIR /app

RUN apt-get update -qq \
  && apt-get install --no-install-recommends -y build-essential curl git gnupg ca-certificates libpq-dev postgresql-client \
  && install -d /etc/apt/keyrings \
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
  && apt-get update -qq \
  && apt-get install --no-install-recommends -y nodejs \
  && corepack enable \
  && corepack prepare yarn@1.22.22 --activate \
  && rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .

EXPOSE 3400 5173 13714

ENTRYPOINT ["./bin/docker-entrypoint"]
