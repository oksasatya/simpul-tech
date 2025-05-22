# syntax=docker/dockerfile:1

# =========================
# Base Stage
# =========================
ARG RUBY_VERSION=3.4.4
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl libjemalloc2 libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# =========================
# Build Stage
# =========================
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential git libpq-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy gemspec first for layer caching
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy all source files
COPY . .

# Precompile bootsnap and assets (if needed)
RUN bundle exec bootsnap precompile app/ lib/

# =========================
# Final Stage
# =========================
FROM base

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Create user and give permissions
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp && \
    chmod +x /rails/bin/docker-entrypoint

USER 1000:1000

# Set entrypoint and start command
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 80
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
