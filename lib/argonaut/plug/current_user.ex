defmodule Argonaut.Plug.CurrentUser do
  import Plug.Conn

  alias Argonaut.User

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    assign_current_user(conn)
  end

  defp assign_current_user(conn = %Plug.Conn{}) do
    current_user = conn.assigns[:current_user] || Guardian.Plug.current_resource(conn)
    assign_current_user(conn, current_user)
  end

  defp assign_current_user(conn, user = %User{}) do
    assign(conn, :current_user, user)
  end

  defp assign_current_user(conn, _), do: redirect_to_sign_in(conn)

  defp redirect_to_sign_in(conn), do: Argonaut.CookieToken.unauthenticated(conn, %{})

end
