defmodule Argonaut.ErrorView do
  use Argonaut.Web, :view

  def render("404.html", _assigns) do
    "It could be you, or it could be us, but there's no page here."
  end

  def render("500.html", _assigns) do
    "Internal server error"
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end
end
