defmodule Argonaut.Endpoint do
  use Phoenix.Endpoint, otp_app: :argonaut

  socket "/socket", Argonaut.UserSocket

  plug Plug.Static,
    at: "/", from: :argonaut, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
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

  plug Argonaut.Router
end
