FROM elixir:1.6

RUN mkdir /code
WORKDIR /code
ADD . /code/

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get

EXPOSE 4000 2222
CMD mix phoenix.server
