ExUnit.start()

# Ecto.Adapters.SQL.Sandbox.mode(Argonaut.Repo, :manual)
Ecto.Adapters.SQL.Sandbox.mode(Argonaut.Repo, {:shared, self()})

{:ok, _} = Application.ensure_all_started(:ex_machina)
