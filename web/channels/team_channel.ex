defmodule Argonaut.TeamChannel do
  use Argonaut.Web, :channel

  def join("teams:" <> team_id, _params, socket) do
    team = Repo.get!(Argonaut.Team, team_id)

    page =
      Argonaut.Reservation
      |> where([r], r.team_id == ^team.id)
      |> order_by([desc: :inserted_at, desc: :id])
      |> preload(:user)
      |> preload(:application)
      |> preload(:environment)
      |> Argonaut.Repo.paginate()

    applications = Argonaut.Application
                    |> where([a], a.team_id == ^team.id)
                    |> order_by(asc: :name)
                    |> Repo.all

    environments = Argonaut.Environment
                    |> where([e], e.team_id == ^team.id)
                    |> order_by(asc: :name)
                    |> Repo.all

    response = %{
      team: Phoenix.View.render_one(team, Argonaut.TeamView, "team.json"),
      applications: applications,
      environments: environments,
      reservations: Phoenix.View.render_many(page.entries, Argonaut.ReservationView, "reservation.json"),
      pagination: Argonaut.PaginationHelpers.pagination(page)
    }

    send(self, :after_join)
    {:ok, response, assign(socket, :team, team)}
  end

  def handle_info(:after_join, socket) do
    Argonaut.Presence.track(socket, socket.assigns.current_user.id, %{
      user: Phoenix.View.render_one(socket.assigns.current_user, Argonaut.UserView, "user.json")
    })
    push(socket, "presence_state", Argonaut.Presence.list(socket))
    {:noreply, socket}
  end

  def handle_in("new_message", params, socket) do
    changeset =
      socket.assigns.team
      |> build_assoc(:reservations, user_id: socket.assigns.current_user.id)
      |> Argonaut.Reservation.changeset(params)

    case Repo.insert(changeset) do
      {:ok, message} ->
        broadcast_message(socket, message)
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, Phoenix.View.render(Argonaut.ChangesetView, "error.json", changeset: changeset)}, socket}
    end
  end

  def terminate(_reason, socket) do
    {:ok, socket}
  end

  defp broadcast_message(socket, message) do
    message = Repo.preload(message, :user)
    rendered_message = Phoenix.View.render_one(message, Argonaut.MessageView, "message.json")
    broadcast!(socket, "message_created", rendered_message)
  end
end
