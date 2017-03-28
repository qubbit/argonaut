defmodule Argonaut.Repo.Migrations.AddTeamToEnvironment do
  use Ecto.Migration

  def change do
    alter table(:environments) do
      add :team_id, references(:teams, on_delete: :nothing)
    end
  end
end
