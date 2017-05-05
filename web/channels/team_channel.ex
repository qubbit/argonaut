defmodule Argonaut.TeamChannel do
  use Argonaut.Web, :channel
  alias Argonaut.Reservation

  def join("teams:" <> team_id, _params, socket) do
    team = Repo.get!(Argonaut.Team, team_id)

    page =
      Reservation
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

  def handle_in("delete_reservation", %{"reservation_id" => id} = payload, socket) do
    reservation = Repo.get!(Reservation, id)

    case Repo.delete(reservation) do
      {:ok, res} ->
        broadcast_reservation(socket, res)
        {:reply, res, socket}
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
        broadcast_reservation(socket, reservation)
        {:reply, reservation, socket}
      {:error, changeset} ->
        {:reply, {:error, Phoenix.View.render(Argonaut.ChangesetView, "error.json", changeset: changeset)}, socket}
    end
  end

  def terminate(_reason, socket) do
    {:ok, socket}
  end

  defp broadcast_reservation(socket, reservation) do
    reservation = Repo.preload(reservation, :user)
    rendered_reservation = Phoenix.View.render_one(reservation, Argonaut.ReservationView, "reservation.json")
    broadcast!(socket, "reservation_created", rendered_reservation)
  end
end
