defmodule Argonaut.UserView do
  use Argonaut.Web, :view

  def render("user.json", %{user: user}) do
    user
  end

end
