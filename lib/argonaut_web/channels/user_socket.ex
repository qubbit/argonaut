defmodule ArgonautWeb.UserSocket do
  use Phoenix.Socket

  channel "teams:*", Argonaut.TeamChannel

  transport :websocket, Phoenix.Transports.WebSocket, timeout: 45_000

  def connect(%{"guardian_token" => token}, socket) do
    case Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        case Argonaut.GuardianSerializer.from_token(claims["sub"]) do
          {:ok, user} ->
            {:ok, assign(socket, :current_user, user)}
          {:error, _reason} ->
            :error
        end
      {:error, _reason} ->
        :error
    end
  end

  def connect(_params, _socket), do: :error

  def id(socket), do: "users_socket:#{socket.assigns.current_user.id}"
end
