defmodule Argonaut.Repo.Migrations.CreateUniqueIndices do
  use Ecto.Migration

  def change do
    create unique_index(:teams, ["(lower(name))"], name: "teams__lower_name_index")
    create unique_index(:environments, ["(lower(name))"], name: "environments__lower_name_index")
  end
end
