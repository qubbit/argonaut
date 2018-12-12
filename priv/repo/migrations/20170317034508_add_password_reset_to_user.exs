defmodule Argonaut.Repo.Migrations.AddPasswordResetToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password_reset_token, :string
      add :password_reset_sent_at, :utc_datetime_usec
      add :confirmation_token, :string
      add :confirmation_sent_at, :utc_datetime_usec
      add :confirmed_at, :utc_datetime_usec
    end
  end
end
