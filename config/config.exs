# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :phoenix, :json_library, Jason

config :argonaut, Argonaut.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "argonaut_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"


# General application configuration
config :argonaut,
  ecto_repos: [Argonaut.Repo],
  git_sha: String.trim(elem(System.cmd("git", ["rev-parse", "HEAD"]), 0))

# Configures the endpoint
config :argonaut, ArgonautWeb.Endpoint,
  url: [host: "localhost:4000"],
  # this is overridden in production by the value of SECRET_KEY_BASE environment variable
  secret_key_base: "5zZvSUCd+1zgUxUZvrIxMXdmvJZhIyNv3LJgOc9wZ6Fhln95e8tm7NxKsoZL5Uri",
  render_errors: [view: ArgonautWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Argonaut.PubSub,
           adapter: Phoenix.PubSub.PG2]


# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "MyApp",
  ttl: { 30, :days },
  allowed_drift: 2000,
  verify_issuer: true, # optional
  # this is overridden in production by the value of GUARDIAN_JWK environment variable
  secret_key: "potato",
  serializer: Argonaut.GuardianSerializer


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
