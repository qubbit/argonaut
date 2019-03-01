defmodule Argonaut.Reservations do
  import Ecto.Query

  alias Argonaut.Application
  alias Argonaut.Environment
  alias Argonaut.Repo
  alias Argonaut.Reservation
  alias Argonaut.Reminder

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

  defp reservations_with_users(team_id) do
    from(
      reservation in Reservation,
      where: reservation.team_id == ^team_id,
      left_join: user in assoc(reservation, :user),
      left_join: environment in assoc(reservation, :environment),
      left_join: application in assoc(reservation, :application),
      preload: [user: user, application: application, environment: environment]
    ) |> Repo.all
  end

  def list_team_info(%{"name_or_id" => name_or_id}) do
    team_id = case Integer.parse(name_or_id) do
      {id, ""} -> id
      _ -> Repo.get_by(Team, name: name_or_id).id
    end
    list = reservations_with_users(team_id)
    header = ["app:env", "User", "Since"]
    rows = Enum.map(list, fn r ->
      [
        "#{r.environment.name}:#{r.application.name}",
        r.user.username,
        Timex.from_now(r.reserved_at)
      ]
    end)
    table = TableRex.quick_render!(rows, header)
    %{success: true, message: "```\n#{table}\n```"}
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

  def reservation_with_associations(reservation_id) do
    query =
      from(
        r in Reservation,
        where: r.id == ^reservation_id,
        join: a in assoc(r, :application),
        join: e in assoc(r, :environment),
        join: u in assoc(r, :user),
        preload: [application: a, environment: e, user: u]
      )

    query |> Repo.one()
  end

  defp environment_by_name(name) do
    environment = Repo.one(from(env in Environment, where: env.name == ^name))

    if environment do
      {:ok, environment}
    else
      {:error, :no_such_environment}
    end
  end

  # The table can have multiple applications with same name so we need to find
  # the correct application the user is ending to release, renew or reserve.
  # The only way to know this is by associated the application with the same
  # team_id as the corresponding environment
  defp application_by_name_and_team(name, team_id) do
    application = (from app in Application,
      where: app.name == ^name,
      where: app.team_id == ^team_id) |> Repo.one

    if application do
      {:ok, application}
    else
      {:error, :no_such_application_for_team}
    end
  end

  def create_reservation(%{"app" => app, "env" => env}, current_user) do
    with {:ok, environment } <- environment_by_name(env),
         {:ok, application } <- application_by_name_and_team(app, environment.team_id),
         {:ok, _ } <- decide_and_reserve(application, environment, current_user)
    do
      %{success: true, message: ":sparkles: Reserved #{env}:#{app}"}
    else
      {:error, :no_such_environment} ->
        %{success: false, message: "*#{env}*: No such environment found"}
      {:error, :no_such_application_for_team} ->
        %{success: false, message: "*#{app}*: No such application found"}
      {:error, :already_reserved_by_you} ->
        %{success: true, message: "*#{env}:#{app}*: You are already using that environment"}
      {:error, :already_reserved_by_someone} ->
        %{success: false, message: "*#{env}:#{app}*: Someone else is using that environment"}
      _ ->
        %{success: false, message: "Hmm... something is wrong :thinking_face:"}
    end
  end

  def reservation_by_app_env(application, environment) do
    reservation = from(
      r in Reservation,
      where: r.application_id == ^application.id,
      where: r.environment_id == ^environment.id
    ) |> Repo.one()

    if reservation do
      {:ok, reservation}
    else
      {:error, nil}
    end
  end

  defp decide_and_reserve(application, environment, user) do
    {_, reservation} = reservation_by_app_env(application, environment)
    user_id = user.id

    case reservation do
      nil ->
        new_reservation = Repo.insert!(%Reservation{
          user: user,
          environment: environment,
          application: application,
          team_id: environment.team_id,
          reserved_at: DateTime.utc_now()
        })
        ArgonautWeb.Endpoint.broadcast("teams:#{environment.team_id}", "reservation_created", new_reservation)
        {:ok, new_reservation}
      %Reservation{user_id: ^user_id} ->
        {:error, :already_reserved_by_you}
      _ ->
        {:error, :already_reserved_by_someone}
    end
  end

  def reservation_by_app_env_name(%{"app" => app, "env" => env}) do
    from(
      reservation in Reservation,
      left_join: user in assoc(reservation, :user),
      left_join: environment in assoc(reservation, :environment),
      left_join: application in assoc(reservation, :application),
      where: environment.name == ^env,
      where: application.name == ^app,
      preload: [
        user: user,
        application: application,
        environment: environment
      ]
    ) |> Repo.one()
  end

  def reservation_info(params) do
    r = reservation_by_app_env_name(params)

    case r do
      %Reservation{} ->
        %{success: true, message: "#{r.environment.name}:#{r.application.name} is in use by #{r.user.username}"}
      nil ->
        %{success: true, message: "Nobody is using that environment currently."}
    end
  end

  def delete_reservation(%Reservation{} = reservation, current_user) do
    if reservation.user_id == current_user.id do
      Repo.delete(reservation)
      {:ok, reservation}
    else
      {:error, :reservation_does_not_belong_to_user}
    end
  end

  def delete_reservation(%{"app" => app, "env" => env}, current_user) do
    with {:ok, environment } <- environment_by_name(env),
         {:ok, application } <- application_by_name_and_team(app, environment.team_id),
         {:ok, reservation } <- reservation_by_app_env(application, environment),
         {:ok, deleted_reservation } <- delete_reservation(reservation, current_user)
    do
      ArgonautWeb.Endpoint.broadcast("teams:#{environment.team_id}",
        "reservation_deleted",
        %{reservation_id: deleted_reservation.id}
      )
      %{success: true, message: ":wastebasket: Reservation deleted on #{env}:#{app}"}
    else
      {:error, :no_such_environment} ->
        %{success: false, message: "*#{env}*: No such environment found"}
      {:error, :no_such_application_for_team} ->
        %{success: false, message: "*#{app}*: No such application found"}
      {:error, :reservation_does_not_belong_to_user} ->
        %{success: false, message: "*#{env}:#{app}*: Someone else is using that environment"}
      _ ->
        %{success: false, message: "Hmm... something is wrong :thinking_face:"}
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
end
