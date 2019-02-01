defmodule Argonaut.Repo.Migrations.RenameSlackUsernameToSlackUserId do
  use Ecto.Migration

  def change do
    rename(table(:users), :slack_username, to: :slack_user_id)
  end
end
