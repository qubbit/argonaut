defmodule Argonaut.ApiToken do
  use Argonaut.Web, :controller

  def auth_error(conn, {failure_type, reason}, opts) do
    conn
    |> put_status(500)
    |> json(%{error: "Auth error"})
  end
end
