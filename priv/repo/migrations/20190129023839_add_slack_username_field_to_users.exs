defmodule Argonaut.Repo.Migrations.AddSlackUsernameFieldToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:slack_username, :string, size: 21)
    end

    create(unique_index(:users, [:slack_username]))
  end
end
