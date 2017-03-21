defmodule Argonaut.Repo.Migrations.AddPasswordResetToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password_reset_token, :string
      add :password_reset_sent_at, :datetime
      add :confirmation_token, :string
      add :confirmation_sent_at, :datetime
      add :confirmed_at, :datetime
    end
  end
end
