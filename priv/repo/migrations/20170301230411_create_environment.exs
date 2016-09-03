defmodule Argonaut.Repo.Migrations.CreateEnvironment do
  use Ecto.Migration

  def change do
    create table(:environments) do
      add :name, :string
      add :description, :string
      add :owning_team, :string

      timestamps()
    end

  end
end
