defmodule Argonaut.Repo.Migrations.CreateReservation do
  use Ecto.Migration

  def change do
    create table(:reservations) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :environment_id, references(:environments, on_delete: :delete_all)
      add :application_id, references(:applications, on_delete: :delete_all)
      add :reserved_at, :utc_datetime

      timestamps()
    end
    create unique_index(:reservations, [:user_id, :environment_id, :application_id])

    create index(:reservations, [:user_id])
    create index(:reservations, [:environment_id])
    create index(:reservations, [:application_id])
  end
end
