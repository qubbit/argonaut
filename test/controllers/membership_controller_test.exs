defmodule Argonaut.MembershipControllerTest do
  use ArgonautWeb.ConnCase

  alias Argonaut.Membership

  @valid_attrs %{
    is_admin: true,
    join_date: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}
  }
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get(conn, membership_path(conn, :index))
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    membership = Repo.insert!(%Membership{})
    conn = get(conn, membership_path(conn, :show, membership))

    assert json_response(conn, 200)["data"] == %{
             "id" => membership.id,
             "join_date" => membership.join_date,
             "user_id" => membership.user_id,
             "team_id" => membership.team_id,
             "is_admin" => membership.is_admin
           }
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent(404, fn ->
      get(conn, membership_path(conn, :show, -1))
    end)
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post(conn, membership_path(conn, :create), membership: @valid_attrs)
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Membership, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post(conn, membership_path(conn, :create), membership: @invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    membership = Repo.insert!(%Membership{})
    conn = put(conn, membership_path(conn, :update, membership), membership: @valid_attrs)
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Membership, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    membership = Repo.insert!(%Membership{})
    conn = put(conn, membership_path(conn, :update, membership), membership: @invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    membership = Repo.insert!(%Membership{})
    conn = delete(conn, membership_path(conn, :delete, membership))
    assert response(conn, 204)
    refute Repo.get(Membership, membership.id)
  end
end
