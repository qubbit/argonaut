defmodule Argonaut.ApplicationView do
  use Argonaut.Web, :view

  def render("index.json", %{applications: applications}) do
    render_many(applications, Argonaut.ApplicationView, "application.json")
  end

  def render("show.json", %{application: application}) do
    render_one(application, Argonaut.ApplicationView, "application.json")
  end

  def render("application.json", %{application: application}) do
    %{id: application.id, name: application.name, repo: application.repo, ping: application.ping}
  end
end
