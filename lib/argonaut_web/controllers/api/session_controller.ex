defmodule ArgonautWeb.SessionController do
  use Argonaut.Web, :controller

  alias Argonaut.{ApiMessage, User, Mailer}

  def create(conn, params) do
    case authenticate(params) do
      {:ok, user} ->
        new_conn = Argonaut.Guardian.Plug.sign_in(conn, user)
        jwt = Argonaut.Guardian.Plug.current_token(new_conn)

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
    jwt = Argonaut.Guardian.Plug.current_token(conn)
    Argonaut.Guardian.revoke(jwt, %{})

    conn
    |> put_status(:ok)
    |> render("delete.json")
  end

  def refresh(conn, _params) do
    user = Argonaut.Guardian.Plug.current_resource(conn)
    jwt = Argonaut.Guardian.Plug.current_token(conn)

    case Argonaut.Guardian.refresh(jwt, ttl: {30, :days}) do
      {:ok, _, {new_jwt, _new_claims}} ->
        conn
        |> put_status(:ok)
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

  def forgot_password(conn, %{"email" => email} = _params) do
    user = Repo.get_by(User, email: email)

    if user do
      changeset =
        User.forgot_password_changeset(
          user,
          %{password_reset_token: gen_token(), password_reset_sent_at: DateTime.utc_now()}
        )

      user = Repo.update!(changeset)

      Mailer.send_password_reset_email(user)

      conn
      |> json(%ApiMessage{
        success: true,
        status: 200,
        message: "Password reset instructions sent to #{user.email}"
      })
    else
      conn
      |> put_status(:not_found)
      |> json(%ApiMessage{
        success: false,
        status: 404,
        message: "There is no user with that email address"
      })
    end
  end

  def reset_password(conn, %{
        "token" => token,
        "password" => password,
        "password_confirmation" => password_confirmation
      }) do
    user = Repo.get_by(User, password_reset_token: token)

    conn =
      if user && token_valid?(user) do
        password = %{password: password, password_confirmation: password_confirmation}

        changeset = User.reset_password_changeset(user, password)

        if changeset.valid? do
          changeset |> Repo.update!()

          conn
          |> json(%ApiMessage{
            status: 200,
            message: "Successfully created new password",
            success: true
          })
        else
          # TODO: use changeset in the form to show accurate errors
          conn
          |> put_status(:unprocessable_entity)
          |> json(%ApiMessage{status: 422, message: "Could not create new password"})
        end
      else
        conn
        |> put_status(:unprocessable_entity)
        |> json(%ApiMessage{status: 422, message: "Password reset token expired or invalid"})
      end

    conn
  end

  defp authenticate(%{"email" => email, "password" => password}) do
    user = Repo.get_by(User, email: String.downcase(email))

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
    |> Base.encode16()
    |> binary_part(0, length)
    |> String.downcase()
  end

  @seconds_in_a_day 86400

  defp token_valid?(user) do
    token_sent_time = user.password_reset_sent_at
    now = DateTime.utc_now()
    @seconds_in_a_day >= DateTime.diff(now, token_sent_time)
  end
end
