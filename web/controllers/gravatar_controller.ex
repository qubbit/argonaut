defmodule Argonaut.GravatarController do
  use Argonaut.Web, :controller

  def get_url(conn, params) do
    conn |> text(gravatar_url(params["email"]))
  end

  defp gravatar_url(email) do
    md5_hash = :crypto.hash(:md5, email) |> Base.encode16(case: :lower)
    "https://www.gravatar.com/avatar/#{md5_hash}"
  end
end
