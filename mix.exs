defmodule Argonaut.Mixfile do
  use Mix.Project

  def project do
    [
      app: :argonaut,
      version: "0.0.1",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Argonaut, []},
      applications: [
        :phoenix,
        :phoenix_pubsub,
        :phoenix_html,
        :cowboy,
        :logger,
        :gettext,
        :phoenix_ecto,
        :httpoison,
        :ecto_sql,
        :postgrex,
        :scrivener_ecto,
        :corsica,
        :comeonin,
        :calendar
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:ecto_sql, "~> 3.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:excoveralls, "~> 0.10", only: :test},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.0"},
      {:comeonin, "~> 3.0"},
      {:guardian, "~> 1.1.1"},
      {:mustachex, "~> 0.0.1"},
      {:calendar, "~> 0.17"},
      {:corsica, "~> 0.5"},
      {:scrivener_ecto, "~> 2.0"},
      {:jason, "~> 1.0"},
      {:mailgun, github: "qubbit/mailgun"},
      {:httpoison, "~> 1.4"},
      {:logger_file_backend, "~> 0.0.10"},
      {:quantum, "~> 2.3"},
      {:timex, "~> 3.0"},
      {:ex_machina, "~> 2.2", only: :test},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
