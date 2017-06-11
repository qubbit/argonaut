defmodule Argonaut.Plug.ReadOnlyToken do
  import Plug.Conn
  import Phoenix.Controller

  alias Argonaut.{User, Repo}

  def init(opts), do: opts

  def call(conn, _opts) do
    # If there is a user with a matching token, given them the
    # data they asked for. Probably don't need to check for team
    # membership for read-only access.

    %{ "id" => team_id, "token" => token } = conn.params

    current_user = Repo.get_by(User, api_token: token)

    if current_user == nil do
      conn
      |> put_status(:forbidden)
      |> render(Argonaut.ErrorView, "403.json")
      |> halt
    end

    conn
  end

end
