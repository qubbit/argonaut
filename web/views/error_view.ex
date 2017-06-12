defmodule Argonaut.ErrorView do
  use Argonaut.Web, :view

  @status_message_map %{"401" => "Hmm it looks like you can't do that.",
    "403" => "Forbidden. This probably means you supplied an incorrect token.",
    "404" => "It could be you, or it could be us, but there's no page here.",
    "500" => "Something's broken and it's my fault. I will look at it later."
  }

  def render(<<status::bytes-size(3)>> <> ".json", _assigns) do
    %Argonaut.ApiError{message: @status_message_map[status]}
  end

  def render(<<status::bytes-size(3)>> <> ".html", _assigns) do
    @status_message_map[status]
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end
end
