defmodule Argonaut.UserTest do
  use Argonaut.ModelCase

  alias Argonaut.User

  @valid_attrs %{avatar_url: "https://example.com/image.jpg",
    email: "bob@example.com",
    username: "bob",
    password: "supersecret"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
