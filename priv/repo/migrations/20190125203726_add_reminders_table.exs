defmodule Argonaut.Repo.Migrations.AddRemindersTable do
  use Ecto.Migration

  def change do
    create table(:reminders) do
      add(:reminded_at, :utc_datetime)
      add(:reservation_id, references(:reservations, on_delete: :delete_all), null: false)
    end
  end
end
