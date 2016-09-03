defmodule Argonaut.Repo.Migrations.CreateApplication do
  use Ecto.Migration

  def change do
    create table(:applications) do
      add :name, :string
      add :ping, :string
      add :repo, :string

      timestamps()
    end

  end
end
