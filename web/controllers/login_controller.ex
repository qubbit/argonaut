defmodule Argonaut.LoginController do
  use Argonaut.Web, :controller

  alias Argonaut.User

  plug :scrub_params, "user" when action in [:create]

  def index(conn, _params) do
    unless User.current_user(conn) do
      render(conn, "login.html")
    end

    redirect(conn, to: "/")
  end

  def signup(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "signup.html", changeset: changeset)
  end

  def logout(conn, _) do
    conn
    |> clear_session
    |> redirect(to: login_path(conn, :index))
  end

  def authenticate(conn, params) do
    case User.find_and_confirm_password(params) do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> redirect(to: "/")
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Login failed!")
        |> render("login.html", changeset: changeset)
    end
  end

  def handle_signup(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully registered and logged in 🙂")
        |> Guardian.Plug.sign_in(user)
        |> redirect(to: user_path(conn, :show, user.id))
      {:error, changeset} ->
        render conn, "signup.html", changeset: changeset
    end
  end
end
