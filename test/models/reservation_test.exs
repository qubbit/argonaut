defmodule Argonaut.ReservationTest do
  use Argonaut.ModelCase

  alias Argonaut.Reservation

  @valid_attrs %{application_id: 42, environment_id: 42, reserved_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, username: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Reservation.changeset(%Reservation{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Reservation.changeset(%Reservation{}, @invalid_attrs)
    refute changeset.valid?
  end
end
