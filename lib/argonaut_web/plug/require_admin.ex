defmodule Argonaut.Plug.RequireAdmin do
  import Plug.Conn
  import Phoenix.Controller

  alias Argonaut.User

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = User.current_user(conn)
    require_admin(current_user, conn)
  end

  def require_admin(%{is_admin: true}, conn), do: conn
  def require_admin(_, conn) do
    conn
    |> put_status(:unauthorized)
    |> render(Argonaut.ErrorView, "401.json")
    |> halt
  end
end
