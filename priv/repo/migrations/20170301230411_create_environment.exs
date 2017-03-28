defmodule Argonaut.Repo.Migrations.CreateEnvironment do
  use Ecto.Migration

  def change do
    create table(:environments) do
      add :name, :string
      add :description, :string

      timestamps()
    end

  end
end
