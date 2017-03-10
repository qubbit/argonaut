defmodule Argonaut.CookieToken do
  use Argonaut.Web, :controller

  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, "You must be signed in to access this page")
    |> redirect(to: login_path(conn, :index))
  end
end
