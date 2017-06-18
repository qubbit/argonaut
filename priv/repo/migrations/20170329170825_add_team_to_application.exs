defmodule Argonaut.Repo.Migrations.AddTeamToApplication do
  use Ecto.Migration

  def change do
    alter table(:applications) do
      add :team_id, references(:teams, on_delete: :delete_all), null: false
    end

    create index(:applications, [:team_id])
  end
end
