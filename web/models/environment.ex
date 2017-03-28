defmodule Argonaut.Environment do
  use Argonaut.Web, :model

  @derive {Poison.Encoder, only: [:name, :id]}

  schema "environments" do
    field :name, :string
    field :description, :string

    belongs_to :team, Argonaut.Team

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description])
    |> validate_required([:name, :description])
  end
end
