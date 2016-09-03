defmodule Argonaut.Environment do
  use Argonaut.Web, :model

  schema "environments" do
    field :name, :string
    field :description, :string
    field :owning_team, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :owning_team])
    |> validate_required([:name, :description, :owning_team])
  end
end
