defmodule Argonaut.BaseController do
  use Argonaut.Web, :controller

  def not_found(conn, _params) do
    conn
    |> put_status(:not_found)
    |> html(Argonaut.ErrorView.render("404.html"))
  end
end
