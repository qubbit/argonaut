defmodule Argonaut.SessionController do
  use Argonaut.Web, :controller

  alias Argonaut.{User, Mailer}

  def create(conn, params) do
    case authenticate(params) do
      {:ok, user} ->
        new_conn = Guardian.Plug.api_sign_in(conn, user, :access)
        jwt = Guardian.Plug.current_token(new_conn)

        new_conn
        |> put_status(:created)
        |> render("show.json", user: user, jwt: jwt)
      :error ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json")
    end
  end

  def delete(conn, _) do
    jwt = Guardian.Plug.current_token(conn)
    Guardian.revoke!(jwt)

    conn
    |> put_status(:ok)
    |> render("delete.json")
  end

  def refresh(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    jwt = Guardian.Plug.current_token(conn)
    {:ok, claims} = Guardian.Plug.claims(conn)

    case Guardian.refresh!(jwt, claims, %{ttl: {30, :days}}) do
      {:ok, new_jwt, _new_claims} ->
        conn
        |> put_status(:ok)
        #|> render("show.json", user: Argonaut.UserView.render("all.json", user), jwt: new_jwt)
        |> render("show.json", user: user, jwt: new_jwt)
      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> render("forbidden.json", error: "Not authenticated")
    end
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(:forbidden)
    |> render(Argonaut.SessionView, "forbidden.json", error: "Not Authenticated")
  end

  def forgot_password(conn, %{"email" => email } = params) do
      user = Repo.get_by(User, email: email)

      if user do
        changeset = User.forgot_password_changeset(user, %{password_reset_token: gen_token(), password_reset_sent_at: DateTime.utc_now })
        user = Repo.update!(changeset)
        Mailer.send_password_reset_email(user)

        conn |> json(%Argonaut.ApiError{success: true, message: "Password reset instructions sent to #{user.email}"})
      else
        conn
        |> put_status(:not_found)
        |> json(%Argonaut.ApiError{success: false, message: "There is no user with that email address"})
      end
    end

  defp authenticate(%{"email" => email, "password" => password}) do
    user = Repo.get_by(Argonaut.User, email: String.downcase(email))

    case check_password(user, password) do
      true -> {:ok, user}
      _ -> :error
    end
  end

  defp check_password(user, password) do
    case user do
      nil -> Comeonin.Bcrypt.dummy_checkpw()
      _ -> Comeonin.Bcrypt.checkpw(password, user.password_hash)
    end
  end

  # TODO: Move this to utils module
  defp gen_token(length \\ 64) do
    :crypto.strong_rand_bytes(length)
      |> Base.encode16
      |> binary_part(0, length)
      |> String.downcase
  end
end
