use Mix.Config

# For production, we configure the host to read the PORT
# from the system environment. Therefore, you will need
# to set PORT=80 before running your server.
#
# You should also configure the url host to something
# meaningful, we use this information when generating URLs.
#
# Finally, we also include the path to a manifest
# containing the digested version of static files. This
# manifest is generated by the mix phoenix.digest task
# which you typically run after static files are built.
config :argonaut, Argonaut.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: ~s(#{System.get_env("HEROKU_APP_NAME")}.herokuapp.com), port: 80],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/manifest.json",
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  # super important for making websockets work in production
  # your config should have comma separated list of origins
  check_origin: ~w(#{System.get_env("WS_ALLOWED_ORIGINS")})

config :logger, level: :info

config :argonaut,
  git_sha: System.get_env("HEROKU_SLUG_COMMIT")

config :mailgun,
  domain: System.get_env("MAILGUN_DOMAIN"),
  key: System.get_env("MAILGUN_KEY"),
  sender: System.get_env("MAILGUN_SENDER"),
  mode: :prod

config :argonaut, Argonaut.Repo,
  # adapter: Ecto.Adapters.Postgres,
  # url: System.get_env("DATABASE_URL"),
  # pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  # ssl: true
  adapter: Ecto.Adapters.Postgres,
  database: "argonaut",
  username: "developer@argonaut-development",
  password: "banana2017!",
  hostname: "argonaut-development.postgres.database.azure.com",
  pool_size: 10,
  ssl: true

config :guardian, Guardian,
  allowed_algos: ["HS512"],
  secret_key: System.get_env("GUARDIAN_JWK")
