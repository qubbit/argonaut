defmodule Argonaut.UserControllerTest do
  use Argonaut.ConnCase

  alias Argonaut.User

  @valid_attrs %{email: "hpotter@example.com", password: "12345678", username: "hpotter"}
  @invalid_attrs %{}

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), @valid_attrs

    assert %{"data" => %{"username" => "hpotter", "email" => "hpotter@example.com"}, "meta" => %{}} = json_response(conn, 201)
    assert Repo.get_by(User, username: "hpotter")
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), @invalid_attrs

    assert %{
      "errors" => %{
        "email" => ["can't be blank"],
        "password" => ["can't be blank"],
        "username" => ["can't be blank"]
      }
    } = json_response(conn, 422)
  end
end
