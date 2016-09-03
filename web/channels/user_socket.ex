defmodule Argonaut.UserSocket do
  use Phoenix.Socket
  import Guardian.Phoenix.Socket

  channel "reservations:lobby", Argonaut.ReservationsChannel

  transport :websocket, Phoenix.Transports.WebSocket,
    timeout: 45_000

  def connect(%{"guardian_token" => jwt}, socket) do
    case sign_in(socket, jwt) do
      {:ok, authorized_socket, _} -> {:ok, authorized_socket}
      _ -> :error
    end
  end

  def id(_socket), do: nil
end
