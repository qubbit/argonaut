defmodule ArgonautWeb.UserSocket do
  use Phoenix.Socket

  channel "teams:*", ArgonautWeb.TeamChannel

  def connect(%{"guardian_token" => token}, socket) do
    case Argonaut.Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        case Argonaut.Guardian.resource_from_claims(claims) do
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
