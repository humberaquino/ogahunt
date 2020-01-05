## Builder
# FROM bitwalker/alpine-elixir-phoenix:1.6.6 as builder

FROM elixir:1.9.1 as builder

# install phoenix
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix archive.install --force hex phx_new 1.4.9
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs

ENV MIX_ENV=prod

WORKDIR /app

# Add the files to the image
ADD ./mix.exs /app
ADD ./mix.lock /app
ADD ./VERSION /app

# Cache Elixir deps
RUN HEX_HTTP_CONCURRENCY=2 HEX_HTTP_TIMEOUT=240 mix deps.get --only prod
RUN mix deps.compile

# Assets
RUN mkdir -p /app/assets

ADD ./assets/package.json /app/assets
ADD ./assets/package-lock.json /app/assets

WORKDIR /app/assets
RUN npm install

ADD ./assets /app/assets

RUN ./node_modules/.bin/webpack --mode production

# Add and compile the app
WORKDIR /app

ADD ./secrets/gcs-service-account.json /app/secrets/gcs-service-account.json
ADD ./priv /app/priv
ADD ./rel /app/rel
ADD ./config /app/config

ADD ./lib /app/lib
# ADD ./test /app/test

# Compile app
RUN mix compile
RUN mix phx.digest

# Generate release
RUN MIX_ENV=prod mix release

## Runtime
# FROM erlang:20.3.8
FROM elixir:1.9.1

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
  dpkg-reconfigure --frontend=noninteractive locales && \
  update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8

COPY --from=builder /app/secrets/gcs-service-account.json /app/secrets/gcs-service-account.json
COPY --from=builder /app/_build/prod/rel/ogahunt /app

ENV MIX_ENV=prod
ENV PORT=5000

ENTRYPOINT ["/app/bin/ogahunt", "start"]
