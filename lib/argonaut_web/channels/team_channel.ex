defmodule ArgonautWeb.TeamChannel do
  use Argonaut.Web, :channel

  alias Argonaut.Membership
  alias Argonaut.Reservation
  alias Argonaut.Reservations

  # TODO: testing https://github.com/hassox/phoenix_guardian/blob/ueberauth-guardian/test/channels/authorized_channel_test.exs

  # returns a team after the team channel is joined
  def join("teams:" <> team_id, _params, socket) do
    team = Repo.get!(Argonaut.Team, team_id)

    response = %{
      team: Phoenix.View.render_one(team, ArgonautWeb.TeamView, "team.json")
    }

    send(self(), :after_join)
    {:ok, response, assign(socket, :team, team)}
  end

  def handle_info(:after_join, socket) do
    Argonaut.Presence.track(socket, socket.assigns.current_user.id, %{
      user:
        Phoenix.View.render_one(socket.assigns.current_user, ArgonautWeb.UserView, "user.json")
    })

    push(socket, "presence_state", Argonaut.Presence.list(socket))
    {:noreply, socket}
  end

  def handle_in("delete_reservation", %{"reservation_id" => id} = _payload, socket) do
    reservation = Reservations.reservation_with_associations(id)

    case Repo.delete(reservation) do
      {:ok, _res} ->
        broadcast_reservation_deletion(socket, id)
        {:reply, {:ok, reservation}, socket}

      {:error, changeset} ->
        {:reply,
         {:error,
          Phoenix.View.render(ArgonautWeb.ChangesetView, "error.json", changeset: changeset)},
         socket}
    end
  end

  def check_membership(user, team) do
    Membership |> where([m], m.user_id == ^user.id and m.team_id == ^team.id) |> Repo.one()
  end

  def handle_in("new_reservation", payload, socket) do
    if check_membership(socket.assigns.current_user, socket.assigns.team) do
      payload = Map.put(payload, "reserved_at", DateTime.utc_now())

      changeset =
        socket.assigns.team
        |> build_assoc(:reservations, user_id: socket.assigns.current_user.id)
        |> Reservation.changeset(payload)

      case Repo.insert(changeset) do
        {:ok, reservation} ->
          reservation_tree = Reservations.reservation_with_associations(reservation.id)
          broadcast_reservation_creation(socket, reservation_tree)
          {:reply, {:ok, reservation_tree}, socket}

        {:error, changeset} ->
          {:reply,
           {:error,
            Phoenix.View.render(ArgonautWeb.ChangesetView, "error.json", changeset: changeset)},
           socket}
      end
    else
      {:noreply, socket}
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
end
