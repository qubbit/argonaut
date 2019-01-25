defmodule Argonaut.Reservations do
  import Ecto.Query
  import Argonaut.Utils

  alias Argonaut.Application
  alias Argonaut.Environment
  alias Argonaut.Membership
  alias Argonaut.Repo
  alias Argonaut.Reservation
  alias Argonaut.Reminder
  alias Argonaut.Team
  alias Argonaut.User

  # TODO: Use ecto query composition in the below functions

  def reminders do
    Repo.all(
      from(
        reminder in Reminder,
        inner_join: reservation in assoc(reminder, :reservation)
      )
    )
  end

  def everything do
    from(
      reservation in Reservation,
      left_join: user in assoc(reservation, :user),
      left_join: environment in assoc(reservation, :environment),
      left_join: application in assoc(reservation, :application),
      left_join: reminder in assoc(reservation, :reminder),
      preload: [
        user: user,
        application: application,
        environment: environment,
        reminder: reminder
      ]
    )
  end

  def reservations_for_team(team_id) do
    from(
      reservation in everything(),
      where: reservation.team_id == ^team_id
    )
  end

  def reservations_by_user(user_id) do
    from(
      reservation in Reservation,
      where: reservation.user_id == ^user_id,
      join: environment in assoc(reservation, :environment),
      join: application in assoc(reservation, :application),
      preload: [application: application, environment: environment]
    )
  end

  # TODO: These are copied from team_controller.ex. Keep them in one place
  # Actions
  # create_reservation and delete_reservation: These are different than the
  # ones implemented in the channel file in that they take application name and
  # environment name instead of ids now that an environment can be uniquely
  # named and owned by one team, it will be easy to make reservations using
  # just three pieces of info: user, application, environment
  def create_reservation(%{"app" => app, "env" => env}, current_user) do
    environment = Repo.one(from(env in Environment, where: env.name == ^env))

    application =
      Repo.one(
        from(
          app in Application,
          where: app.name == ^app,
          where: app.team_id == ^environment.team_id
        )
      )

    {status, reason} =
      satisfies?("", [
        fn _ ->
          if environment == nil, do: {:error, "No such environment #{env}"}, else: {:ok, ""}
        end,
        fn _ ->
          if application == nil, do: {:error, "No such application #{app}"}, else: {:ok, ""}
        end,
        fn _ ->
          if user_member_of_team?(current_user.id, environment.team_id),
            do: {:ok, ""},
            else: {:error, "None of the teams you are member of own the environment #{env}"}
        end,
        fn _ ->
          if decide_and_reserve!(environment, application, current_user),
            do: {:ok, ""},
            else: {:error, "Someone else is using that environment currently"}
        end
      ])

    if status == :ok do
      %{success: true, message: "Reserved #{app}:#{env}"}
    else
      %{success: false, message: reason}
    end
  end

  defp decide_and_reserve!(
         environment = %Environment{},
         application = %Application{},
         user = %User{}
       ) do
    reservation =
      from(
        r in Reservation,
        where: r.application_id == ^application.id,
        where: r.environment_id == ^environment.id
      )
      |> Repo.one()

    if can_reserve?(reservation, user) do
      if reservation do
        Repo.delete(reservation)
      end

      new_reservation = Repo.insert!(%Reservation{
        user_id: user.id,
        environment_id: environment.id,
        application_id: application.id,
        team_id: environment.team_id,
        reserved_at: DateTime.utc_now()
      })

      with_user = Repo.preload(new_reservation, :user)
      ArgonautWeb.Endpoint.broadcast("teams:#{environment.team_id}", "reservation_created", with_user)

      true
    else
      false
    end
  end

  defp can_reserve?(nil, _), do: true
  defp can_reserve?(_, _), do: false

  defp can_release?(nil, _), do: false
  defp can_release?(%Reservation{user_id: user_id}, %User{id: id}), do: user_id == id

  def delete_reservation(%{"app" => app, "env" => env}, current_user) do
    environment = Repo.one(from(env in Environment, where: env.name == ^env))

    application =
      Repo.one(
        from(
          app in Application,
          where: app.name == ^app,
          where: app.team_id == ^environment.team_id
        )
      )

    reservation =
      from(
        r in Reservation,
        where: r.application_id == ^application.id,
        where: r.environment_id == ^environment.id
      )
      |> Repo.one()

    if can_release?(reservation, current_user) do
      Repo.delete(reservation)

      %{message: "Deleted your reservation on #{env}:#{app}", success: true}
    else
      %{message: "Could not delete reservation on #{env}:#{app}", success: false}
    end
  end

  def find_application(%{"app" => app}) do
    applications =
      from(
        a in Application,
        where: a.name == ^app,
        join: r in Reservation,
        on: a.id == r.application_id,
        join: e in Environment,
        on: e.id == r.environment_id,
        preload: [reservations: a]
      )
      |> Repo.all()

    applications
    |> Enum.map(fn x -> %{application: x.application.name, environment: x.environment.name} end)
  end

  def clear_user_reservations(current_user) do
    {deleted_count, _} =
      from(r in Reservation, where: r.user_id == ^current_user.id) |> Repo.delete_all()

    %{success: true, message: "Cleared all (#{deleted_count}) reservations"}
  end

  def list_user_reservations(current_user) do
    reservations =
      reservations_by_user(current_user.id)
      |> Repo.all()
      |> Enum.map(fn r ->
        %{
          environment: r.environment.name,
          application: r.application.name,
          reserved_at: r.reserved_at
        }
      end)

    %{
      success: true,
      message: "List of reservations made by you (#{current_user.username})",
      data: reservations
    }
  end

  defp user_member_of_team?(%User{} = user, %Team{} = team) do
    Membership |> where([m], m.user_id == ^user.id and m.team_id == ^team.id) |> Repo.one() != nil
  end

  defp user_member_of_team?(user_id, team_id) do
    Membership |> where([m], m.user_id == ^user_id and m.team_id == ^team_id) |> Repo.one() != nil
  end
end
