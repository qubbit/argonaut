defmodule Argonaut.Repo.Migrations.AddTeamToApplication do
  use Ecto.Migration

  def up do
    alter table(:applications) do
      add :team_id, references(:teams, on_delete: :delete_all)
    end

    create index(:applications, [:team_id])
  end

  def down do
    alter table(:applications) do
      drop index(:applications, [:team_id])
    end

    drop :team_id
  end

end
