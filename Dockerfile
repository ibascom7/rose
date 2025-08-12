# Multi-stage build for development and production
FROM elixir:1.15-otp-26 as builder

# Build arguments
ARG MIX_ENV=dev
ARG BUILD_TYPE=dev

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    inotify-tools \
    postgresql-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set environment
ENV MIX_ENV=${MIX_ENV}

# Copy dependency files
COPY mix.exs mix.lock ./

# Install dependencies based on environment
RUN if [ "$MIX_ENV" = "prod" ]; then \
        mix deps.get --only=prod; \
    else \
        mix deps.get; \
    fi

RUN mix deps.compile

# Copy application code
COPY . .

# Setup and compile assets
RUN mix assets.setup

# Deploy assets for production, build for development
RUN if [ "$MIX_ENV" = "prod" ]; then \
        mix assets.deploy; \
    else \
        mix assets.build; \
    fi

# Compile the application
RUN mix compile

# Create release for production
RUN if [ "$MIX_ENV" = "prod" ]; then \
        mix release; \
    fi

# Production runtime stage
FROM debian:bookworm-slim as production

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    openssl \
    ncurses-bin \
    locales \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Create app user
RUN useradd --create-home app
WORKDIR /app
USER app

# Copy release from builder
COPY --from=builder --chown=app:app /app/_build/prod/rel/rose ./

EXPOSE 4000
CMD ["./bin/rose", "start"]

# Development runtime stage
FROM elixir:1.15-otp-26-slim as development

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    inotify-tools \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy compiled code and dependencies
COPY --from=builder /app/_build /app/_build
COPY --from=builder /app/deps /app/deps
COPY --from=builder /app/priv /app/priv
COPY --from=builder /app/config /app/config
COPY --from=builder /app/lib /app/lib
COPY --from=builder /app/mix.exs /app/mix.exs

EXPOSE 4000
CMD ["mix", "phx.server"]

# Default to development stage
FROM development