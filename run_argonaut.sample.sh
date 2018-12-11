#!/usr/bin/env bash

export DATABASE_URL="postgres://argonaut:password@localhost:5432/argonaut"
export GUARDIAN_JWK="random_token_here"
export APP_NAME="api.argonaut.ninja"
export MAILGUN_DOMAIN="https://api.mailgun.net/v3/domain.com"
export MAILGUN_KEY="mailgun-key"
export MAILGUN_SENDER="argonaut@domain.com"
export POOL_SIZE="100"
export SECRET_KEY_BASE="secret_here"
export PORT="4000"
export WS_ALLOWED_ORIGINS="list of allowed domains"

# If first run, uncomment the following line and comment it after running it
# MIX_ENV=prod mix ecto.migrate

MIX_ENV=prod elixir --detached -S mix phx.server
