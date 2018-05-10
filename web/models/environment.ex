defmodule Argonaut.Environment do
  use Argonaut.Web, :model

  @derive {Poison.Encoder, only: [:id, :name, :is_integration, :description, :team_id]}

  schema "environments" do
    field :name, :string
    field :description, :string
    field :is_integration, :boolean

    belongs_to :team, Argonaut.Team

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :is_integration, :team_id])
    |> validate_required([:name, :description, :team_id])
  end
end
