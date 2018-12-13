defmodule ArgonautWeb.TeamView do
  use Argonaut.Web, :view

  def render("index.json", %{teams: teams}) do
    %{
      data: render_many(teams, ArgonautWeb.TeamView, "team.json"),
      pagination: Argonaut.PaginationHelpers.pagination(teams)
    }
  end

  def render("show.json", %{team: team}) do
    %{data: render_one(team, ArgonautWeb.TeamView, "team.json")}
  end

  def render("team.json", %{team: team}) do
    %{
      id: team.id,
      name: team.name,
      description: team.description,
      logo_url: team.logo_url,
      owner_id: team.owner_id
    }
  end
end
