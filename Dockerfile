# Multi-stage build for faster rebuilds
FROM elixir:1.15-otp-26 as deps

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

# Copy only dependency files
COPY mix.exs mix.lock ./
RUN mix deps.get
RUN mix deps.compile

# Build stage
FROM deps as builder

# Copy application code
COPY . .

# Setup and compile assets
RUN mix assets.setup
RUN mix assets.build

# Compile the application
RUN mix compile

# Runtime stage
FROM elixir:1.15-otp-26-slim as runtime

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
    postgresql-client \
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