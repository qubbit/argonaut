defmodule Argonaut.Team do
  use Argonaut.Web, :model

  alias Argonaut.{Membership, User}

  schema "teams" do
    field :name, :string
    field :description, :string
    field :logo_url, :string

    belongs_to :owner, User, foreign_key: :owner_id
    many_to_many :members, User, join_through: "membership"

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :logo_url])
    |> validate_required([:name, :description, :logo_url])
  end
end
