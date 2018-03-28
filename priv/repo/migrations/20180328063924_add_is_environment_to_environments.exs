defmodule Argonaut.Repo.Migrations.AddIsEnvironmentToEnvironments do
  use Ecto.Migration

  def change do
    alter table(:environments) do
      add :is_integration, :boolean, default: false
    end
  end
end
