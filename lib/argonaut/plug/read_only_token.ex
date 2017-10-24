defmodule Argonaut.Plug.ReadOnlyToken do
  import Plug.Conn
  import Phoenix.Controller

  alias Argonaut.{User, Repo}

  def init(opts), do: opts

  def call(conn, _opts) do
    %{ "token" => token } = conn.params

    current_user = Repo.get_by(User, api_token: token)

    if current_user == nil do
      conn
      |> put_status(:forbidden)
      |> render(Argonaut.ErrorView, "403.json")
      |> halt
    end

    conn
    # |> Plug.Conn.put_session(:user_id, current_user.id)
    |> Plug.Conn.assign(:current_user, current_user)
  end
end
