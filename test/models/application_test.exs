defmodule Argonaut.ApplicationTest do
  use Argonaut.ModelCase

  alias Argonaut.Application

  @valid_attrs %{name: "some content", ping: "some content", repo: "some content", team_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Application.changeset(%Application{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Application.changeset(%Application{}, @invalid_attrs)
    refute changeset.valid?
  end
end
