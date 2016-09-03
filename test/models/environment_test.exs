defmodule Argonaut.EnvironmentTest do
  use Argonaut.ModelCase

  alias Argonaut.Environment

  @valid_attrs %{description: "some content", name: "some content", owning_team: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Environment.changeset(%Environment{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Environment.changeset(%Environment{}, @invalid_attrs)
    refute changeset.valid?
  end
end
