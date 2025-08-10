# Use the official Elixir image with OTP 26 and Debian
FROM elixir:1.15-otp-26

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    inotify-tools \
    postgresql-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js for asset compilation
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Create app directory
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy dependency files
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get

# Copy assets configuration
COPY assets/package.json assets/package-lock.json* ./assets/
RUN cd assets && npm install

# Copy application code
COPY . .

# Compile assets
RUN cd assets && npm run build
RUN mix assets.deploy

# Compile the application
RUN mix compile

# Expose port
EXPOSE 4000

# Start the application
CMD ["mix", "phx.server"]