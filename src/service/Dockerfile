FROM elixir:1.17.3

# clean dependencies
RUN apt-get clean

# prepare work dir
WORKDIR /app

# install phoenix packages
RUN mix local.hex --force
RUN mix local.rebar --force

# copy files
COPY . /app

# compile application
RUN  mix deps.get
RUN mix deps.compile
RUN mix compile



