defmodule Argonaut.Repo.Migrations.CreateReservation do
  use Ecto.Migration

  def change do
    create table(:reservations) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:environment_id, references(:environments, on_delete: :delete_all), null: false)
      add(:application_id, references(:applications, on_delete: :delete_all), null: false)
      add(:team_id, references(:teams, on_delete: :delete_all), null: false)
      add(:reserved_at, :utc_datetime_usec)

      timestamps()
    end

    create(unique_index(:reservations, [:user_id, :environment_id, :application_id, :team_id]))

    create(index(:reservations, [:user_id]))
    create(index(:reservations, [:environment_id]))
    create(index(:reservations, [:application_id]))
    create(index(:reservations, [:team_id]))
  end
end
