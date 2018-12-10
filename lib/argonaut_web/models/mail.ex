defmodule Argonaut.Mail do
  use Argonaut.Web, :model

  schema "mails" do
    field :to, :string
    field :from, :string
    field :subject, :string
    field :message, :string
    field :is_html, :boolean, default: true

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:to, :from, :subject, :message, :is_html])
    |> validate_required([:to, :from, :subject, :message, :is_html])
  end
end
