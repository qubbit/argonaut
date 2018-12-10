defmodule ArgonautWeb.PageView do
  use Argonaut.Web, :view

  def current_user(conn) do
    Plug.Conn.get_session(conn, :username)
  end
end
