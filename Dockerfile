# syntax=docker/dockerfile:1.7

ARG RUBY_VERSION=3.3.10
ARG NODE_MAJOR=20

FROM ruby:${RUBY_VERSION} as base

ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_BIN=/usr/local/bundle/bin \
    GEM_HOME=/usr/local/bundle \
    PATH=/app/bin:/app/node_modules/.bin:$BUNDLE_BIN:$PATH \
    RAILS_ENV=development \
    NODE_ENV=development

WORKDIR /app

RUN apt-get update -qq \
  && apt-get install --no-install-recommends -y build-essential curl git libpq-dev postgresql-client \
  && curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - \
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
