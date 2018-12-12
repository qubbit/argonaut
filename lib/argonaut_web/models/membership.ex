defmodule Argonaut.Membership do
  use Argonaut.Web, :model

  schema "membership" do
    field :join_date, :utc_datetime
    field :is_admin, :boolean, default: false

    belongs_to :user, Argonaut.User
    belongs_to :team, Argonaut.Team

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :team_id, :join_date, :is_admin])
    |> validate_required([:user_id, :team_id, :join_date, :is_admin])
  end
end
