defmodule ArgonautWeb.PageController do
  use Argonaut.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
