defmodule Argonaut.LoginController do
  use Argonaut.Web, :controller

  alias Argonaut.{User, Mailer}

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

  def show_forgot_password(conn, _params) do
    render conn, "forgot_password.html"
  end

  def forgot_password(conn, params) do
    email = Map.get(params, "email")
    user = Repo.get_by(User, email: email)

    if user do
      changeset = User.forgot_password_changeset(user, %{password_reset_token: gen_token(), password_reset_sent_at: DateTime.utc_now })
      user = Repo.update!(changeset)
      Mailer.send_password_reset_email(user)

      conn |> put_flash(:info, "We have sent the password reset URL to #{user.email}")
           |> redirect(to: login_path(conn, :index))
    else
      conn |> put_flash(:error, "There is no user with that email")
           |> render("forgot_password.html")
    end
  end

  def show_reset_password(conn, %{"token" => token}) do
    user = Repo.get_by(User, password_reset_token: token)

    if !user || !token_valid?(user) do
      conn |> put_flash(:error, "Password reset token expired or invalid")
           |> redirect(to: login_path(conn, :show_forgot_password))
    end

    render conn, "reset_password.html", token: user.password_reset_token
  end

  defp token_valid?(user) do
    {:ok, sent_at } = Calendar.DateTime.from_erl(Ecto.DateTime.to_erl(user.password_reset_sent_at), "Etc/UTC")
    now = Calendar.DateTime.now_utc

    {:ok, seconds, _, _} = Calendar.DateTime.diff(now, sent_at)
    (seconds / 86400) <= 1
  end

  def reset_password(conn, %{"token" => token, "password" => password, "password_confirmation" =>  password_confirmation}) do
    user = Repo.get_by(User, password_reset_token: token)

    conn = if user && token_valid?(user) do
      password = %{password: password, password_confirmation: password_confirmation}

      changeset = User.reset_password_changeset(user, password)

      if changeset.valid? do

        changeset |> Repo.update!

        conn |> put_flash(:info, "Successfully reset password")
             |> redirect(to: login_path(conn, :index))
      else
        # REFACTOR: use changeset in the form to show accurate errors
        conn |> put_flash(:error, "Could not change password. You know what you did.")
             |> render("reset_password.html", token: token)
      end
    else
      conn |> put_flash(:error, "Password reset token expired or invalid")
           |> render("reset_password.html", token: "")
    end

    conn
  end

  def gen_token(length \\ 64) do
    :crypto.strong_rand_bytes(length)
      |> Base.encode16
      |> binary_part(0, length)
      |> String.downcase
  end
end
