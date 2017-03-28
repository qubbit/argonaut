defmodule Argonaut.Repo.Migrations.CreateTeam do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :description, :string
      add :logo_url, :string
      add :owner_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
    create index(:teams, [:owner_id])

  end
end
