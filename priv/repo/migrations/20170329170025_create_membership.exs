defmodule Argonaut.Repo.Migrations.CreateMembership do
  use Ecto.Migration

  def change do
    create table(:membership) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :team_id, references(:teams, on_delete: :delete_all)
      add :is_admin, :boolean, default: false, null: false
      add :join_date, :datetime, null: false

      timestamps()
    end
    create index(:membership, [:user_id])
    create index(:membership, [:team_id])

    create unique_index(:membership, [:user_id, :team_id])
  end
end
