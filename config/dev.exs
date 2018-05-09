use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :argonaut, Argonaut.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# database URL is overridden in production by the value of DATABASE_URL environment variable
config :argonaut, Argonaut.Repo,
  adapter: Ecto.Adapters.Postgres,
  hostname: System.get_env("DB_HOST") || "localhost",
  username: System.get_env("DB_USER") || "postgres",
  password: System.get_env("DB_PASS") || "postgres",
  database: "argonaut_dev",
  pool_size: 10

config :mailgun,
  domain: "whatever",
  key: "whatever",
  mode: :test,
  sender: "no-reply@argonaut.io",
  test_file_path: "/tmp/mailgun.json"
