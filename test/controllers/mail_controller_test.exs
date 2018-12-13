defmodule Argonaut.MailControllerTest do
  use ArgonautWeb.ConnCase

  alias Argonaut.Mail

  @valid_attrs %{
    from: "some content",
    is_html: true,
    message: "some content",
    subject: "some content",
    to: "some content"
  }
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get(conn, mail_path(conn, :index))
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    mail = Repo.insert!(%Mail{})
    conn = get(conn, mail_path(conn, :show, mail))

    assert json_response(conn, 200)["data"] == %{
             "id" => mail.id,
             "to" => mail.to,
             "from" => mail.from,
             "subject" => mail.subject,
             "message" => mail.message,
             "is_html" => mail.is_html
           }
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent(404, fn ->
      get(conn, mail_path(conn, :show, -1))
    end)
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post(conn, mail_path(conn, :create), mail: @valid_attrs)
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Mail, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post(conn, mail_path(conn, :create), mail: @invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    mail = Repo.insert!(%Mail{})
    conn = put(conn, mail_path(conn, :update, mail), mail: @valid_attrs)
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Mail, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    mail = Repo.insert!(%Mail{})
    conn = put(conn, mail_path(conn, :update, mail), mail: @invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    mail = Repo.insert!(%Mail{})
    conn = delete(conn, mail_path(conn, :delete, mail))
    assert response(conn, 204)
    refute Repo.get(Mail, mail.id)
  end
end
