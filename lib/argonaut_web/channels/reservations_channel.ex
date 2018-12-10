defmodule ArgonautWeb.ReservationsChannel do
  use Argonaut.Web, :channel

  alias Argonaut.Reservation

  defmodule ReservationResponse do
    defstruct status: "failure", reservation: %Reservation{}
  end

  def join("reservations:lobby", _payload, socket) do
    if authorized?(socket) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def reservation_for_environment_app(application_id, environment_id) do
    query = from reservation in Reservation,
      where: reservation.application_id == ^application_id,
      where: reservation.environment_id == ^environment_id,
      left_join: user in assoc(reservation, :user),
      left_join: environment in assoc(reservation, :environment),
      left_join: application in assoc(reservation, :application),
      preload: [user: user, application: application, environment: environment]

    query |> Repo.one
  end


  def reserve(reservation, user, application_id, environment_id) do
    reservation = if can_reserve?(reservation, user) do
      Repo.insert!(%Reservation{
        user_id: user.id,
        environment_id: environment_id,
        application_id: application_id,
        reserved_at: Ecto.DateTime.utc
      })
    end
    reservation_for_environment_app(reservation.application_id, reservation.environment_id)
  end

  def release(reservation, user, _application_id, _environment_id) do
    reservation = if can_release?(reservation, user) do
      Repo.delete!(reservation)
    end
    reservation
  end

  def handle_in("action:" <> action, payload, socket) do
    %{"application_id" => application_id, "environment_id" => environment_id} = payload
    user = current_user(socket)
    reservation = reservation_for_environment_app(application_id, environment_id)

    answer = case action do
      "reserve" ->
        reserve(reservation, user, application_id, environment_id)
      "release" ->
        release(reservation, user, application_id, environment_id)
      _ ->
        nil
    end

    status = if answer == nil do
      "failure"
    else
      "success"
    end

    reservation_response = %ReservationResponse{
                              status: status,
                              reservation: answer
                            }

    broadcast! socket, "action:" <> action, reservation_response

    {:noreply, socket}
  end

  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  defp can_release?(reservation, user) do
    user.is_admin or has_reservation?(reservation, user)
  end

  defp has_reservation?(reservation, user) do
    cond do
      reservation == nil ->
        false
      user.id != reservation.user_id ->
        false
      user.id == reservation.user_id ->
        true
    end
  end

  defp can_reserve?(reservation, user) do
    cond do
      reservation == nil ->
        true
      reservation.user_id != user.id ->
        false
      user.is_admin == true ->
        true
    end
  end

  defp current_user(socket) do
    Guardian.Phoenix.Socket.current_resource(socket)
  end

  defp authorized?(socket) do
    current_user(socket) != nil
  end
end
