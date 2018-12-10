defmodule Argonaut.ProfileControllerTest do
  use ArgonautWeb.ConnCase

  alias Argonaut.User
  @valid_attrs %{avatar_url: "some content", email: "some content", first_name: "some content", last_name: "some content", password: "some content", password_confirmation: "some content", time_zone: "some content", username: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, profile_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing profiles"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, profile_path(conn, :new)
    assert html_response(conn, 200) =~ "New profile"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, profile_path(conn, :create), profile: @valid_attrs
    assert redirected_to(conn) == profile_path(conn, :index)
    assert Repo.get_by(User, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, profile_path(conn, :create), profile: @invalid_attrs
    assert html_response(conn, 200) =~ "New profile"
  end

  test "shows chosen resource", %{conn: conn} do
    profile = Repo.insert! %User{}
    conn = get conn, profile_path(conn, :show, profile)
    assert html_response(conn, 200) =~ "Show profile"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, profile_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    profile = Repo.insert! %User{}
    conn = get conn, profile_path(conn, :edit, profile)
    assert html_response(conn, 200) =~ "Edit profile"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    profile = Repo.insert! %User{}
    conn = put conn, profile_path(conn, :update, profile), profile: @valid_attrs
    assert redirected_to(conn) == profile_path(conn, :show, profile)
    assert Repo.get_by(User, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    profile = Repo.insert! %User{}
    conn = put conn, profile_path(conn, :update, profile), profile: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit profile"
  end

  test "deletes chosen resource", %{conn: conn} do
    profile = Repo.insert! %User{}
    conn = delete conn, profile_path(conn, :delete, profile)
    assert redirected_to(conn) == profile_path(conn, :index)
    refute Repo.get(User, profile.id)
  end
end
