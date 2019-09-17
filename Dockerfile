FROM elixir:1.9.0-alpine AS builder

ENV MIX_ENV=prod

WORKDIR /usr/local/geo_racer

# This step installs all the build tools we'll need
RUN apk update \
  && apk upgrade --no-cache \
  && apk add --no-cache \
  nodejs-npm \
  alpine-sdk \
  openssl-dev \
  && mix local.rebar --force \
  && mix local.hex --force

# Copies our app source code into the build container
COPY . .

# Compile Elixir
RUN mix do deps.get, deps.compile, compile

# Compile Javascript
RUN cd assets \
  && npm install \
  && ./node_modules/webpack/bin/webpack.js --mode production \
  && cd .. \
  && mix phx.digest

# Build Release
RUN mkdir -p /opt/release \
  && mix release \
  && mv _build/${MIX_ENV}/rel/geo_racer /opt/release

# Create the runtime container
FROM erlang:22-alpine as runtime

# Install runtime dependencies
RUN apk update \
  && apk upgrade --no-cache \
  && apk add --no-cache gcc

WORKDIR /usr/local/geo_racer

COPY --from=builder /opt/release/geo_racer .

CMD [ "bin/geo_racer", "start" ]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=2 \
  CMD nc -vz -w 2 localhost 4000 || exit 1