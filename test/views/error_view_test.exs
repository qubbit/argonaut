defmodule ArgonautWeb.ErrorViewTest do
  use ArgonautWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.html" do
    assert render_to_string(ArgonautWeb.ErrorView, "404.html", []) ==
           "It could be you, or it could be us, but there&#39;s no page here."
  end

  test "render 500.html" do
    assert render_to_string(ArgonautWeb.ErrorView, "500.html", []) ==
           "Something&#39;s broken and it&#39;s my fault. I will look at it later."
  end

  test "render any other" do
    assert render_to_string(ArgonautWeb.ErrorView, "505.html", []) ==
           "Hmm...🤔"
  end
end
