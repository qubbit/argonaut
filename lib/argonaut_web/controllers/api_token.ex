defmodule Argonaut.ApiToken do
  use Argonaut.Web, :controller

  @whitelisted_method_paths ["POST /api/sessions",
                             "POST /api/forgot_password",
                             "POST /api/reset_password"
                            ]

  def unauthenticated(conn, _params) do
    # TODO: make this work for allowing anonymous auth

    # path = conn.path_info |> Enum.map(fn x -> "/" <> x end) |> Enum.join
    # method_path = "#{conn.method} #{path}"

    # if not method_path in @whitelisted_method_paths do
    # end
    # conn
    conn
    |> put_status(:unauthorized)
    |> json(%{ error: "Authorization required" })
  end
end
