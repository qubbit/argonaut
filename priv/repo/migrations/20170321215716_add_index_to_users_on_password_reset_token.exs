defmodule Argonaut.Repo.Migrations.AddIndexToUsersOnPasswordResetToken do
  use Ecto.Migration

  def change do
    create index(:users, [:password_reset_token])
  end
end
