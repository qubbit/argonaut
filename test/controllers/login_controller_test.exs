defmodule Argonaut.LoginControllerTest do
  use Argonaut.ConnCase

  alias Argonaut.Login
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, login_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing login"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, login_path(conn, :new)
    assert html_response(conn, 200) =~ "New login"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, login_path(conn, :create), login: @valid_attrs
    assert redirected_to(conn) == login_path(conn, :index)
    assert Repo.get_by(Login, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, login_path(conn, :create), login: @invalid_attrs
    assert html_response(conn, 200) =~ "New login"
  end

  test "shows chosen resource", %{conn: conn} do
    login = Repo.insert! %Login{}
    conn = get conn, login_path(conn, :show, login)
    assert html_response(conn, 200) =~ "Show login"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, login_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    login = Repo.insert! %Login{}
    conn = get conn, login_path(conn, :edit, login)
    assert html_response(conn, 200) =~ "Edit login"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    login = Repo.insert! %Login{}
    conn = put conn, login_path(conn, :update, login), login: @valid_attrs
    assert redirected_to(conn) == login_path(conn, :show, login)
    assert Repo.get_by(Login, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    login = Repo.insert! %Login{}
    conn = put conn, login_path(conn, :update, login), login: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit login"
  end

  test "deletes chosen resource", %{conn: conn} do
    login = Repo.insert! %Login{}
    conn = delete conn, login_path(conn, :delete, login)
    assert redirected_to(conn) == login_path(conn, :index)
    refute Repo.get(Login, login.id)
  end
end
