defmodule Argonaut.Repo.Migrations.AddTeamToEnvironment do
  use Ecto.Migration

  def up do
    alter table(:environments) do
      add :team_id, references(:teams, on_delete: :nothing)
    end
  end

  def down do
    alter table(:environments) do
      drop :team_id
    end
  end
end
