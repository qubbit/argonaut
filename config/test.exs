use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :argonaut, Argonaut.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :argonaut, Argonaut.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "developer",
  password: "banana2017!",
  database: "argonaut_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :comeonin, :bcrypt_log_rounds, 4
config :comeonin, :pbkdf2_rounds, 1
