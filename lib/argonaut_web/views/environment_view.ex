defmodule Argonaut.EnvironmentView do
  use Argonaut.Web, :view

  def render("index.json", %{environments: environments}) do
    render_many(environments, Argonaut.EnvironmentView, "environment.json")
  end

  def render("show.json", %{environment: environment}) do
    render_one(environment, Argonaut.EnvironmentView, "environment.json")
  end

  def render("environment.json", %{environment: environment}) do
    %{id: environment.id, name: environment.name}
  end
end
