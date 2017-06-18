defmodule Argonaut.MembershipView do
  use Argonaut.Web, :view

  def render("index.json", %{membership: membership}) do
    %{data: render_many(membership, Argonaut.MembershipView, "membership.json")}
  end

  def render("show.json", %{membership: membership}) do
    %{data: render_one(membership, Argonaut.MembershipView, "membership.json")}
  end

  def render("membership.json", %{membership: membership}) do
    %{id: membership.id,
      join_date: membership.join_date,
      user_id: membership.user_id,
      team_id: membership.team_id,
      is_admin: membership.is_admin}
  end
end
