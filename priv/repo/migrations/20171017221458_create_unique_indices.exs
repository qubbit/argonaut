defmodule Argonaut.Repo.Migrations.CreateUniqueIndices do
  use Ecto.Migration

  def change do
    create unique_index(:teams, ["(lower(name))"])
    create unique_index(:environments, ["(lower(name))"])
  end
end
