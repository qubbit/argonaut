defmodule Argonaut.Repo.Migrations.CreateMail do
  use Ecto.Migration

  def change do
    create table(:mails) do
      add :to, :string
      add :from, :string
      add :subject, :string
      add :message, :text
      add :is_html, :boolean, default: true, null: false

      timestamps()
    end

  end
end
