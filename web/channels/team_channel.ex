defmodule Argonaut.TeamChannel do
  use Argonaut.Web, :channel
  alias Argonaut.Reservation

  # returns a team after the team channel is joined
  def join("teams:" <> team_id, _params, socket) do
    team = Repo.get!(Argonaut.Team, team_id)
    response = %{
      team: Phoenix.View.render_one(team, Argonaut.TeamView, "team.json")
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

  def handle_in("delete_reservation", %{"reservation_id" => id} = payload, socket) do
    reservation = reservation_with_associations(id)

    case Repo.delete(reservation) do
      {:ok, res} ->
        broadcast_reservation_deletion(socket, id)
        {:reply, {:ok, reservation}, socket}
      {:error, changeset} ->
        {:reply, {:error, Phoenix.View.render(Argonaut.ChangesetView, "error.json", changeset: changeset)}, socket}
    end
  end

  def handle_in("new_reservation", payload, socket) do
    changeset =
      socket.assigns.team
      |> build_assoc(:reservations, user_id: socket.assigns.current_user.id)
      |> Reservation.changeset(payload)
      |> Ecto.Changeset.put_change(:reserved_at, Ecto.DateTime.utc)

    case Repo.insert(changeset) do
      {:ok, reservation} ->
        reservation_tree = reservation_with_associations(reservation.id)
        broadcast_reservation_creation(socket, reservation_tree)
        {:reply, {:ok, reservation_tree}, socket}
      {:error, changeset} ->
        {:reply, {:error, Phoenix.View.render(Argonaut.ChangesetView, "error.json", changeset: changeset)}, socket}
    end
  end

  def terminate(_reason, socket) do
    {:ok, socket}
  end

  defp broadcast_reservation_deletion(socket, id) do
    broadcast!(socket, "reservation_deleted", %{reservation_id: id})
  end

  defp broadcast_reservation_creation(socket, reservation) do
    broadcast!(socket, "reservation_created", reservation)
  end

  # TODO: move this somewhere else
  defp reservation_with_associations(reservation_id) do
    query = from r in Reservation,
    where: r.id == ^reservation_id,
    join: a in assoc(r, :application),
    join: e in assoc(r, :environment),
    join: u in assoc(r, :user),
    preload: [application: a, environment: e, user: u]

    query |> Repo.one
  end
end
