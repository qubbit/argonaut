defmodule Argonaut.EnvironmentControllerTest do
  use ArgonautWeb.ConnCase

  alias Argonaut.Environment
  @valid_attrs %{description: "some content", name: "some content", owning_team: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get(conn, environment_path(conn, :index))
    assert html_response(conn, 200) =~ "Listing environments"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get(conn, environment_path(conn, :new))
    assert html_response(conn, 200) =~ "New environment"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post(conn, environment_path(conn, :create), environment: @valid_attrs)
    assert redirected_to(conn) == environment_path(conn, :index)
    assert Repo.get_by(Environment, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post(conn, environment_path(conn, :create), environment: @invalid_attrs)
    assert html_response(conn, 200) =~ "New environment"
  end

  test "shows chosen resource", %{conn: conn} do
    environment = Repo.insert!(%Environment{})
    conn = get(conn, environment_path(conn, :show, environment))
    assert html_response(conn, 200) =~ "Show environment"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent(404, fn ->
      get(conn, environment_path(conn, :show, -1))
    end)
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    environment = Repo.insert!(%Environment{})
    conn = get(conn, environment_path(conn, :edit, environment))
    assert html_response(conn, 200) =~ "Edit environment"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    environment = Repo.insert!(%Environment{})
    conn = put(conn, environment_path(conn, :update, environment), environment: @valid_attrs)
    assert redirected_to(conn) == environment_path(conn, :show, environment)
    assert Repo.get_by(Environment, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    environment = Repo.insert!(%Environment{})
    conn = put(conn, environment_path(conn, :update, environment), environment: @invalid_attrs)
    assert html_response(conn, 200) =~ "Edit environment"
  end

  test "deletes chosen resource", %{conn: conn} do
    environment = Repo.insert!(%Environment{})
    conn = delete(conn, environment_path(conn, :delete, environment))
    assert redirected_to(conn) == environment_path(conn, :index)
    refute Repo.get(Environment, environment.id)
  end
end
