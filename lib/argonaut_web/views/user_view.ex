defmodule ArgonautWeb.UserView do
  use Argonaut.Web, :view

  def render("user.json", %{user: user}) do
    user
  end

  # this will show all the information about
  # the user... even the api_token
  def render("all.json", %{user: user}) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      username: user.username,
      avatar_url: user.avatar_url,
      email: user.email,
      is_admin: user.is_admin,
      time_zone: user.time_zone,
      background_url: user.background_url,
      api_token: user.api_token
    }
  end
end
