defmodule Argonaut.Reservation do
  use Argonaut.Web, :model

  @derive {Jason.Encoder, only: [:id, :user, :application, :environment, :reserved_at]}

  schema "reservations" do
    field(:reserved_at, :utc_datetime)

    belongs_to(:user, Argonaut.User)
    belongs_to(:environment, Argonaut.Environment)
    belongs_to(:application, Argonaut.Application)
    belongs_to(:team, Argonaut.Team)

    timestamps()
  end

  @required_fields ~w(user_id environment_id application_id team_id reserved_at)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
