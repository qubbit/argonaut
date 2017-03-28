defmodule Argonaut.ProfileController do
  use Argonaut.Web, :controller

  alias Argonaut.User

  def show(conn, _params) do
    current_user = User.current_user(conn)
    render(conn, "show.html", user: current_user)
  end

  def edit(conn, _params) do
    current_user = User.current_user(conn)
    changeset = User.profile_changeset(current_user)
    render(conn, "edit.html", user: current_user, changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    current_user = User.current_user(conn)
    changeset = User.profile_changeset(current_user, user_params)

    case Repo.update(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Profile updated successfully.")
        #|> redirect(to: profile_path(conn, :show))
      {:error, changeset} ->
        render(conn, "edit.html", user: current_user, changeset: changeset)
    end
  end
end
