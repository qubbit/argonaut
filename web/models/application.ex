defmodule Argonaut.Application do
  use Argonaut.Web, :model

  @derive {Poison.Encoder, only: [:name, :ping, :id, :repo]}

  schema "applications" do
    field :name, :string
    field :ping, :string
    field :repo, :string

    belongs_to :team, Argonaut.Team

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :ping, :repo])
    |> validate_required([:name, :ping, :repo])
  end
end
