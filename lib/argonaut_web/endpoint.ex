defmodule ArgonautWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :argonaut

  socket "/socket", ArgonautWeb.UserSocket, websocket: true

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_argonaut_key",
    signing_salt: "3v$WM57q@*%5ulZ67QmbH1y*n%9vN5ai"

  plug Corsica, allow_headers: ~w(Accept Content-Type Authorization Origin)

  plug ArgonautWeb.Router
end
