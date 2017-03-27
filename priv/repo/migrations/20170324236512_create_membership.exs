defmodule Argonaut.Repo.Migrations.CreateMembership do
  use Ecto.Migration

  def change do
    create table(:membership) do
      add :join_date, :datetime
      add :user_id, references(:users, on_delete: :nothing)
      add :team_id, references(:teams, on_delete: :nothing)

      timestamps()
    end
    create index(:membership, [:user_id])
    create index(:membership, [:team_id])

  end
end
