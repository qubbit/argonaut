defmodule Argonaut.ApiToken do
  use Argonaut.Web, :controller

  @whitelisted_method_paths [
    "POST /api/sessions",
    "POST /api/forgot_password",
    "POST /api/reset_password"
  ]

  def auth_error(conn, {failure_type, reason}, opts) do
    # TODO: make this work for allowing anonymous auth

    # path = conn.path_info |> Enum.map(fn x -> "/" <> x end) |> Enum.join
    # method_path = "#{conn.method} #{path}"

    # if not method_path in @whitelisted_method_paths do
    # end
    # conn
    IO.inspect({failure_type, reason, opts}, label: "auth_error")

    conn
    |> put_status(500)
    |> json(%{error: "lol Auth error"})
  end
end
