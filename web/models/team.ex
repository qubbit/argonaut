defmodule Argonaut.Team do
  use Argonaut.Web, :model

  alias Argonaut.{Reservation, Membership, User, Environment, Application}

  @derive {Poison.Encoder, only: [:name, :id, :reservations, :environments, :applications]}

  schema "teams" do
    field :name, :string
    field :description, :string
    field :logo_url, :string

    belongs_to :owner, User, foreign_key: :owner_id
    many_to_many :members, User, join_through: "membership"

    has_many :environments, Environment
    has_many :applications, Application
    has_many :reservations, Reservation

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :logo_url])
    |> validate_required([:name])
  end
end
