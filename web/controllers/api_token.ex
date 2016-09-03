defmodule Argonaut.ApiToken do
  use Argonaut.Web, :controller

  def unauthenticated(conn, _params) do
   conn
   |> put_status(:unauthorized)
   |> json(%{ error: "Authorization required" })
  end
end
