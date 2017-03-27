defmodule Argonaut.Membership do
  use Argonaut.Web, :model

  schema "membership" do
    field :join_date, Ecto.DateTime

    belongs_to :user, Argonaut.User
    belongs_to :team, Argonaut.Team

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:join_date])
    |> validate_required([:join_date])
  end
end
