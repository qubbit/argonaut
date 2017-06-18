defmodule Argonaut.MembershipTest do
  use Argonaut.ModelCase

  alias Argonaut.Membership

  @valid_attrs %{is_admin: true, join_date: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, user_id: 1, team_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Membership.changeset(%Membership{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Membership.changeset(%Membership{}, @invalid_attrs)
    refute changeset.valid?
  end
end
