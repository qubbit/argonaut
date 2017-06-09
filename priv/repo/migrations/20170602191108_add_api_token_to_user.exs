defmodule Argonaut.Repo.Migrations.AddApiTokenToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :api_token, :string, size: 64
    end
  end
end
