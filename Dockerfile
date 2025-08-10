# Use the official Elixir image with OTP 26 and Debian
FROM elixir:1.15-otp-26

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    inotify-tools \
    postgresql-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy dependency files
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get

# Copy application code
COPY . .

# Update dependencies after copying full source
RUN mix deps.get

# Setup and compile assets (Phoenix handles this via esbuild/tailwind)
RUN mix assets.setup
RUN mix assets.build

# Compile the application
RUN mix compile

# Expose port
EXPOSE 4000

# Start the application
CMD ["mix", "phx.server"]