defmodule Argonaut.Reservation do
  use Argonaut.Web, :model

  @derive {Poison.Encoder, only: [:id, :user, :application, :environment, :reserved_at]}

  schema "reservations" do
    field :reserved_at, Ecto.DateTime

    belongs_to :user, Argonaut.User
    belongs_to :environment, Argonaut.Environment
    belongs_to :application, Argonaut.Application

    @required_fields ~w(user_id environment_id application_id reserved_at)

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields)
    #|> validate_required(@required_fields)
  end
end
