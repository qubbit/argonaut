defmodule ArgonautWeb.BaseController do
  use Argonaut.Web, :controller

  def not_found(conn, _params) do
    conn
    |> put_status(:not_found)
    |> json(Argonaut.ErrorView.render("404.json"))
  end
end
