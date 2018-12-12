defmodule ArgonautWeb.ProfileController do
  use Argonaut.Web, :controller

  alias Argonaut.User

  def show(conn, _params) do
    current_user = User.current_user(conn)
    current_user
  end

  def update(conn, user_params) do
    current_user = User.current_user(conn)
    changeset = User.profile_changeset(current_user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> json(user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ArgonautWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
