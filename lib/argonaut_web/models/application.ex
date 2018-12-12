defmodule Argonaut.Application do
  use Argonaut.Web, :model

  @derive {Jason.Encoder, only: [:name, :ping, :id, :repo, :team_id]}

  schema "applications" do
    field :name, :string
    field :ping, :string
    field :repo, :string

    belongs_to :team, Argonaut.Team
    has_many :reservations, Argonaut.Reservation

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :ping, :repo, :team_id])
    |> validate_required([:name, :ping, :repo, :team_id])
  end
end
