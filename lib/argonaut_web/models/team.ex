defmodule Argonaut.Team do
  use Argonaut.Web, :model

  # These aliases are absolutely necessary even if the compiler complains them
  # as being unused. They are used in line 18-20
  # removing these aliases will result in failure at Ecto's level
  alias Argonaut.{Reservation, Membership, User, Environment, Application}

  @derive {Jason.Encoder,
           only: [
             :name,
             :id,
             :description,
             :owner_id,
             :logo_url,
             :reservations,
             :environments,
             :applications
           ]}

  schema "teams" do
    field(:name, :string)
    field(:description, :string)
    field(:logo_url, :string)

    belongs_to(:owner, User, foreign_key: :owner_id)
    many_to_many(:members, User, join_through: "membership")

    has_many(:environments, Environment)
    has_many(:applications, Application)
    has_many(:reservations, Reservation)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :logo_url])
    |> validate_required([:name])
    |> unique_constraint(
      :name,
      name: :teams__lower_name_index,
      message: "Team name is already taken"
    )
  end
end
