defmodule Argonaut.Repo.Migrations.AddBackgroundUrlToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :background_url, :string
    end
  end

end
