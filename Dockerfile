# syntax=docker/dockerfile:1

ARG RUBY_VERSION=4.0.2
FROM ruby:${RUBY_VERSION}-slim AS base

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl ca-certificates git build-essential libpq-dev pkg-config && \
    curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    corepack enable && \
    corepack prepare yarn@1.22.22 --activate && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV BUNDLE_PATH="/usr/local/bundle" \
    PATH="/rails/bin:${PATH}"

FROM base AS build

ENV RAILS_ENV="production" \
    NODE_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_WITHOUT="development:test"

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential git libpq-dev pkg-config

# Copy dependency manifests first for efficient Docker layer caching.
COPY Gemfile Gemfile.lock .ruby-version ./
RUN gem install bundler && \
    bundle install --jobs 4 --retry 3 && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .

# Compile assets at build time without requiring production credentials.
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

FROM base AS production

ENV RAILS_ENV="production" \
    NODE_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_WITHOUT="development:test" \
    MALLOC_ARENA_MAX="2" \
    RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="1"

# Run the app as a non-root user.
RUN groupadd --system --gid 1000 rails && \
    useradd --system --uid 1000 --gid 1000 --create-home --shell /usr/sbin/nologin rails

COPY --from=build --chown=rails:rails /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=rails:rails /rails /rails

USER rails:rails

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

FROM base AS development

ENV RAILS_ENV="development" \
    NODE_ENV="development" \
    BUNDLE_DEPLOYMENT="0" \
    BUNDLE_WITHOUT=""

# Development keeps build tools for native gems and live dependency changes.
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential git libpq-dev pkg-config

RUN groupadd --system --gid 1000 rails && \
    useradd --system --uid 1000 --gid 1000 --create-home --shell /bin/bash rails && \
    chown -R rails:rails /rails /usr/local/bundle

USER rails:rails

COPY --chown=rails:rails Gemfile Gemfile.lock .ruby-version ./
RUN gem install bundler && bundle install --jobs 4 --retry 3

COPY --chown=rails:rails package.json yarn.lock ./
RUN yarn install --frozen-lockfile

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
