defmodule Argonaut.SlackNotifier do
  require Logger

  alias Argonaut.Reservations
  alias Argonaut.Reservation
  alias Argonaut.Reminder
  alias Argonaut.Repo
  alias Argonaut.SlackApi

  # Entry point
  def work do
    within_work_hours?() |> work
  end

  def work(false) do
    Logger.info("[SlackNotifier] Exiting, current time is outside of work hours: #{now()}")
  end

  # Returns the number of reminders that were sent out
  def work(true) do
    Logger.info("[SlackNotifier] Started worker at #{now()}")

    Reservations.everything()
    |> Repo.all()
    |> Enum.map(&maybe_notify/1)
    |> Enum.sum()
  end

  defp create_or_update_reminder(%Reminder{} = reminder, _) do
    reminder
    |> Reminder.changeset(%{reminded_at: DateTime.utc_now()})
    |> Repo.update()
  end

  defp create_or_update_reminder(_, %Reservation{} = reservation) do
    reminder = %Reminder{reservation_id: reservation.id, reminded_at: DateTime.utc_now()}
    Repo.insert(reminder)
  end

  def maybe_notify(%Reservation{reminder: reminder} = reservation) do
    %{application: app, environment: env, user: user} = reservation

    if length_exceeded?(reservation.reserved_at) && grace_period_exceeded?(reminder) do
      message = "Are you still using *#{env.name}:#{app.name}*?"
      {:ok, new_reminder} = create_or_update_reminder(reminder, reservation)

      Logger.info(
        "Sending notification to user: #{user.username}, message: #{message}, reservation: #{
          reservation.id
        }, reminder: #{new_reminder.id}"
      )

      SlackApi.send_notification(message, "@#{user.username}", new_reminder.id, reservation.id)
      1
    else
      0
    end
  end

  @default_timezone "America/New_York"

  defp tz do
    Timex.timezone(@default_timezone, Timex.now())
  end

  defp now do
    tz() |> Timex.now()
  end

  defp weekend? do
    day_name =
      now()
      |> Timex.weekday()
      |> Timex.day_name()

    day_name in ["Saturday", "Sunday"]
  end

  defp within_work_hours? do
    %DateTime{hour: hour} = now()
    # works until 4:59pm
    nine_to_five = hour in 9..16
    nine_to_five && !weekend?()
  end

  @seconds_in_a_day 86400
  @seconds_in_two_hours 7200

  # We don't want to nag the user incessantly, instead give them grace period
  # of 2 hours and ask again. This date comparison is fine because it's
  # operating on two UTC times
  def grace_period_exceeded?(%Reminder{reminded_at: reminded_at}) do
    now = DateTime.utc_now()
    DateTime.diff(now, reminded_at) > @seconds_in_two_hours
  end

  def grace_period_exceeded?(nil), do: true

  # After a user has checked out an environment for more than a day ask them if
  # they're still using it. This date comparison is fine because it's
  # operating on two UTC times
  def length_exceeded?(reserved_at) do
    now = DateTime.utc_now()
    DateTime.diff(now, reserved_at) > @seconds_in_a_day
  end
end
