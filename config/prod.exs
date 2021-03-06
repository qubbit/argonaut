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
config :argonaut, ArgonautWeb.Endpoint,
  http: [port: {:system, "PORT"}],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  # super important for making websockets work in production
  # your config should have comma separated list of origins
  # this URL is superate from what phoenix uses, it's for email resets... I think
  url: [host: System.get_env("APP_NAME"), port: 80],
  check_origin: ~w(#{System.get_env("WS_ALLOWED_ORIGINS")})

# config :logger, level: :info

# tell logger to load a LoggerFileBackend processes
config :logger,
  backends: [{LoggerFileBackend, :error_log}]

# configuration for the {LoggerFileBackend, :error_log} backend
config :logger, :error_log,
  path: "log/production.log",
  level: :info

config :argonaut,
  argonaut_token_for_slack: System.get_env("ARGONAUT_TOKEN_FOR_SLACK"),
  slack_bot_oauth_token: System.get_env("SLACK_BOT_OAUTH_TOKEN")

config :mailgun,
  domain: System.get_env("MAILGUN_DOMAIN"),
  key: System.get_env("MAILGUN_KEY"),
  sender: System.get_env("MAILGUN_SENDER"),
  mode: :prod

config :argonaut, Argonaut.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true

config :guardian, Guardian,
  allowed_algos: ["HS512"],
  secret_key: System.get_env("GUARDIAN_JWK")

config :argonaut, Argonaut.Scheduler,
  timezone: "America/New_York",
  jobs: [
    phoenix_job: [
      # schedule: "0 * * * *", # every hour
      # M-F 9am-5pm, hourly
      schedule: "0 9-16 * * 1-5",
      task: {Argonaut.SlackNotifier, :work, []}
    ]
  ]
