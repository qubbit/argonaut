defmodule Argonaut.ReservationView do
  use Argonaut.Web, :view

  def render("index.json", %{reservations: reservations}) do
    render_many(reservations, Argonaut.ReservationView, "reservation.json")
  end

  def render("show.json", %{reservation: reservation}) do
    render_one(reservation, Argonaut.ReservationView, "reservation.json")
  end

  def render("reservation.json", %{reservation: reservation}) do
    %{id: reservation.id,
      user: reservation.user,
      application: reservation.application,
      environment: reservation.environment,
      reserved_at: reservation.reserved_at
    }
  end
end
