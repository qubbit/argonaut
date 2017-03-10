defmodule Argonaut.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :username, :string, unique: true
      add :password_hash, :string
      add :avatar_url, :string
      add :email, :string, unique: true
      add :is_admin, :boolean, default: false
      add :time_zone, :string, default: "America/New_York"
      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:username])
  end
end
