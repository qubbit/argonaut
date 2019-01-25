defmodule Argonaut.Reminder do
  use Argonaut.Web, :model
  alias Argonaut.Reservation

  @derive {Jason.Encoder, only: [:id, :reservation_id, :reminded_at]}

  schema "reminders" do
    field(:reservation_id, :integer)
    field(:reminded_at, :utc_datetime_usec)
    has_one(:reservation, Reservation, foreign_key: :id)
  end

  @required_fields ~w(reservation_id reminded_at)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
