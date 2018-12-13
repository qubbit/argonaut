defmodule Argonaut.TeamControllerTest do
  use ArgonautWeb.ConnCase
  alias Argonaut.{Repo, Team, User}

  @valid_attrs %{description: "some content", logo_url: "some content", name: "some content"}
  @invalid_attrs %{}

  @admin_user_attrs %{
    token: "abc",
    username: "hpotter",
    password: "12345678",
    email: "hpotter@example.com",
    is_admin: true
  }

  setup %{conn: conn} do
    changeset = User.changeset(%User{}, @admin_user_attrs)
    {:ok, admin} = Repo.insert(changeset)
    {:ok, token, _} = Guardian.encode_and_sign(admin, %{}, %{})

    authed_conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", token)

    {:ok, conn: authed_conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get(conn, team_path(conn, :index, %{token: "abc"}))

    assert %{
             "data" => [],
             "pagination" => %{
               "page_number" => 1,
               "page_size" => 25,
               "total_entries" => 0,
               "total_pages" => 1
             }
           } = json_response(conn, 200)
  end

  test "shows chosen resource", %{conn: conn} do
    team = Repo.insert!(%Team{})
    conn = get(conn, team_path(conn, :show, team))

    assert json_response(conn, 200)["data"] == %{
             "id" => team.id,
             "name" => team.name,
             "description" => team.description,
             "logo_url" => team.logo_url,
             "owner_id" => team.owner_id
           }
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post(conn, team_path(conn, :create), team: @valid_attrs)
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Team, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post(conn, team_path(conn, :create), team: @invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    team = Repo.insert!(%Team{})
    conn = put(conn, team_path(conn, :update, team), team: @valid_attrs)
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Team, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    team = Repo.insert!(%Team{})
    conn = put(conn, team_path(conn, :update, team), team: @invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    team = Repo.insert!(%Team{})
    conn = delete(conn, team_path(conn, :delete, team))
    assert response(conn, 200)
    refute Repo.get(Team, team.id)
  end
end
