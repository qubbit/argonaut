defmodule ArgonautWeb.CleanupCase do
  use ExUnit.CaseTemplate

  setup do
    Argonaut.Repo.delete_all(Argonaut.Environment)
    Argonaut.Repo.delete_all(Argonaut.Application)
    Argonaut.Repo.delete_all(Argonaut.Team)
    Argonaut.Repo.delete_all(Argonaut.User)
    :ok
  end
end
