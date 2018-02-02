defmodule Argonaut.TeamController do
  use Argonaut.Web, :controller

  @behaviour ApiBehaviour
  import Argonaut.Utils

  alias Argonaut.{Membership, Reservation, Team, Repo, Application, Environment, ApiMessage, User}

  def api_response(conn, result), do: conn |> json(result)

  def index(conn, params) do
    page = Team
            |> order_by([asc: :id])
            |> Repo.paginate(params)

    render(conn, "index.json", teams: page)
  end

  def create(conn, team_params) do
    current_user = Guardian.Plug.current_resource(conn)
    changeset = Team.changeset(%Team{owner_id: current_user.id}, team_params)

    case Repo.insert(changeset) do
      {:ok, team} ->
        assoc_changeset = Membership.changeset(
          %Membership{},
          %{join_date: Ecto.DateTime.utc, user_id: current_user.id, is_admin: true, team_id: team.id}
        )
        Repo.insert!(assoc_changeset)

        conn
        |> put_status(:created)
        |> render("show.json", team: team)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Argonaut.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    team = Repo.get!(Team, id)
    render(conn, "show.json", team: team)
  end

  def new_reservation(conn, %{"team_id" => id, "application_id" => application_id, "environment_id" => environment_id} = params) do
    team = Repo.get!(Team, id)
    current_user = Guardian.Plug.current_resource(conn)

    if user_member_of_team?(current_user, team) do
      params = Map.put(params, "reserved_at", Ecto.DateTime.utc)

      changeset =
        team
        |> build_assoc(:reservations, user_id: current_user.id)
        |> Reservation.changeset(params)

      case Repo.insert(changeset) do
        {:ok, reservation} ->
          conn |> json(reservation)
        {:error, changeset} ->
          conn |> json(%{message: "Nope"})
      end
    else
      conn |> json(%{message: "Nayyy!"})
    end
  end

  def new_team_environment(conn, params) do
    changeset = Environment.changeset(%Environment{}, params)

    case Repo.insert(changeset) do
      {:ok, environment} ->
        conn
        |> put_status(:created)
        |> json(environment)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Argonaut.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show_team_environments(conn, %{"id" => id}) do
    environments = Environment |> where(team_id: ^id) |> Repo.all
    conn |> json(environments)
  end

  def new_team_application(conn, application_params) do
    changeset = Application.changeset(%Application{}, application_params)

    case Repo.insert(changeset) do
      {:ok, application} ->
        conn
        |> put_status(:created)
        |> json(application)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Argonaut.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show_team_applications(conn, %{"id" => id}) do
    applications = Application |> where(team_id: ^id) |> Repo.all
    conn |> json(applications)
  end

  defp user_member_of_team?(%User{} = user, %Team{} = team) do
    (Membership |> where([m], m.user_id == ^user.id and m.team_id == ^team.id) |> Repo.one) != nil
  end

  defp user_member_of_team?(user_id, team_id) do
    (Membership |> where([m], m.user_id == ^user_id and m.team_id == ^team_id) |> Repo.one) != nil
  end

  def update(conn, %{"id" => id, "description" => description}) do
    current_user = Guardian.Plug.current_resource(conn)
    team = Repo.get!(Team, id)

    if user_member_of_team?(current_user, team) do
      changeset = Team.changeset(team, %{"description" => description})

      case Repo.update(changeset) do
        {:ok, team} ->
          render(conn, "show.json", team: team)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(Argonaut.ChangesetView, "error.json", changeset: changeset)
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%ApiMessage{ status: 403, message: "Permission denied" })
    end
  end

  # create_reservation and delete_reservation

  # These are different than the ones implemented in the channel file
  # in that they take application name and environment name instead of ids
  # now that an environment can be uniquely named and owned by one team, it will be easy to
  # make reservations using just three pieces of info: user, application, environment
  def create_reservation(conn, %{"application_name" => app_name, "environment_name" => env_name}) do
    current_user = conn.assigns.current_user

    environment = Repo.one(from env in Environment, where: env.name == ^env_name)
    application = Repo.one(from app in Application, where: app.name == ^app_name, where: app.team_id == ^environment.team_id)

    { status, reason } = satisfies?("", [
      fn(reason) -> if environment == nil, do: { :error, "No such environment #{env_name}" }, else: { :ok, "" } end,
      fn(reason) -> if application == nil, do: { :error, "No such application #{app_name}" }, else: { :ok, "" } end,
      fn(reason) -> if user_member_of_team?(current_user.id, environment.team_id), do: { :ok, "" }, else: { :error, "None of the teams which you are member of own environment #{env_name}" } end,
      fn(reason) -> if decide_and_reserve!(environment, application, current_user), do: { :ok, "" }, else: { :error, "Someone else is using that environment currently" } end
    ])

    if status == :ok do
      conn |> api_response(%ApiMessage{ success: true, message: "Reserved #{app_name}:#{env_name}" })
    else
      conn |> api_response(%ApiMessage{ success: false, message: reason })
    end
  end

  defp decide_and_reserve!(environment = %Environment{}, application = %Application{}, user = %User{}) do
    reservation = (from r in Reservation,
      where: r.application_id == ^application.id,
      where: r.environment_id == ^environment.id) |> Repo.one

    if can_reserve?(reservation, user) do
      if reservation do
        Repo.delete reservation
      end

      Repo.insert!(%Reservation{
        user_id: user.id,
        environment_id: environment.id,
        application_id: application.id,
        team_id: environment.team_id,
        reserved_at: Ecto.DateTime.utc
      })
      true
    else
      false
    end
  end

  defp can_reserve?(nil, _), do: true
  defp can_reserve?(_, %User{ is_admin: true }), do: true
  defp can_reserve?(_, _), do: false

  defp can_release?(nil, _), do: false
  defp can_release(_, %User{ is_admin: true }), do: true
  defp can_release?(%Reservation{ user_id: user_id }, %User{ id: id }), do: user_id == id
  defp can_release(_, _), do: false

  def delete_reservation(conn, %{"application_name" => app_name, "environment_name" => env_name}) do
    current_user = conn.assigns.current_user

    environment = Repo.one(from env in Environment, where: env.name == ^env_name)
    application = Repo.one(from app in Application,
      where: app.name == ^app_name,
      where: app.team_id == ^environment.team_id)


    reservation = (from r in Reservation,
      where: r.application_id == ^application.id,
      where: r.environment_id == ^environment.id) |> Repo.one

    if can_release?(reservation, current_user) do
      Repo.delete reservation
      conn |> api_response(%{ message: "Deleted your reservation on #{env_name}:#{app_name}", success: true })
    else
      conn |> api_response(%{ message: "Could not delete reservation on #{env_name}:#{app_name}", success: false })
    end
  end

  def find_application(conn, %{ "application_name" => app_name }) do
    applications = (from a in Application,
      where: a.name == ^app_name,
      join: r in Reservation, on: a.id == r.application_id,
      join: e in Environment, on: e.id == r.environment_id,
      preload: [reservations: a ]) |> Repo.all
      # require IEx; IEx.pry

    conn |> json(applications |> Enum.map(fn x -> %{ application: x.application.name, environment: x.environment.name} end))
  end

  def clear_user_reservations(conn, params) do
    current_user = conn.assigns.current_user

    { deleted_count, _ } = (from r in Reservation, where: r.user_id == ^current_user.id) |> Repo.delete_all
    conn |> api_response %ApiMessage{ success: true, status: 200, message: "Cleared all (#{deleted_count}) reservations" }
  end

  def list_user_reservations(conn, params) do
    current_user = conn.assigns.current_user

    reservations = reservations_by_user(current_user.id)
      |> Repo.all
      |> Enum.map(fn r -> %{ environment: r.environment.name, application: r.application.name, reserved_at: r.reserved_at } end)

    conn |> api_response(%ApiMessage{ message: "List of reservations made by you (#{current_user.username})", status: 200, success: true, data: reservations })
  end

  def delete(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)
    team = Repo.get!(Team, id)

    if team.owner_id == current_user.id do
      Repo.delete!(team)
      conn |> json(%{ id: team.id })
    else
      conn
      |> put_status(:forbidden)
      |> json(%ApiMessage{ status: 403, message: "Permission denied" })
    end
  end

  defp reservations_by_user(user_id) do
    from reservation in Reservation,
    where: reservation.user_id == ^user_id,
    join: environment in assoc(reservation, :environment),
    join: application in assoc(reservation, :application),
    preload: [application: application, environment: environment]
  end

  defp reservations_with_users(team_id) do
    from reservation in Reservation,
    where: reservation.team_id == ^team_id,
    left_join: user in assoc(reservation, :user),
    left_join: environment in assoc(reservation, :environment),
    left_join: application in assoc(reservation, :application),
    preload: [user: user, application: application, environment: environment]
  end

  def team_table(team_id) do
    applications = Application |> where([a], a.team_id == ^team_id)
                                |> order_by(asc: :name)
                                |> Repo.all
    environments = Environment |> where([e], e.team_id == ^team_id)
                                |> order_by(asc: :name)
                                |> Repo.all

    %{reservations: reservations_with_users(team_id) |> Repo.all,
      applications: applications,
      environments: environments
    }
  end

  # returns all the apps, environments and reservations for a team
  def table(conn, %{"name_or_id" => team_name_or_id}) do
    team_id = case Integer.parse(team_name_or_id) do
      {id, ""} -> id
      _  -> Repo.get_by(Team, name: team_name_or_id).id
    end
    data = team_table(team_id)
    conn |> json(data)
  end

  def join(conn, %{"id" => team_id}) do
    current_user = Guardian.Plug.current_resource(conn)
    team = Repo.get(Team, team_id)

    changeset = Membership.changeset(
      %Membership{},
      %{team_id: team.id, user_id: current_user.id, is_admin: false, join_date: Ecto.DateTime.utc}
    )

    case Repo.insert(changeset) do
      {:ok, _user_team} ->
        conn
        |> put_status(:created)
        |> render("show.json", %{team: team})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Argonaut.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def leave(conn, %{"id" => team_id}) do
    current_user = Guardian.Plug.current_resource(conn)
    team = Repo.get(Team, team_id)
    membership = Repo.get_by(Membership, team_id: team.id, user_id: current_user.id)

    case Repo.delete(membership) do
      {:ok, _} ->
        conn
        |> render("show.json", %{team: team})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Argonaut.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete_team_application(conn, %{"id" => team_id, "application_id" => application_id}) do
    current_user = Guardian.Plug.current_resource(conn)
    team = Repo.get(Team, team_id)

    # if team.owner_id != current_user.id do
    #   conn |> json(%{"success" => false})
    # else

    if user_member_of_team?(current_user, team) do
      application = Repo.get(Application, application_id)
      Repo.delete!(application)
      conn |> json(%{success: true, application_id: application_id})
    else
      conn |> json(%{success: false, message: "Permission denied"})
    end

    conn
  end

  def update_team_application(conn, params) do
    application = Repo.get!(Application, params["id"])
    changeset = Application.changeset(application, params)

    case Repo.update(changeset) do
      {:ok, app} ->
        conn
        |> json(app)
      {:error, changeset} ->
        conn
        |> json(%{})
    end
  end

  def delete_team_environment(conn, %{"id" => team_id, "environment_id" => environment_id}) do
    current_user = Guardian.Plug.current_resource(conn)
    team = Repo.get(Team, team_id)

    # only team owners can delete an environment
    # if team.owner_id != current_user.id do
    #   conn |> json(%{"success" => false})
    # else

    # only allow team members to delete a team's environment
    if user_member_of_team?(current_user, team) do
      environment = Repo.get(Environment, environment_id)
      Repo.delete!(environment)
      conn |> json(%{success: true, environment_id: environment_id})
    else
      conn
      |> put_status(:forbidden)
      |> json(%ApiMessage{status: 403, message: "Permission denied"})
    end

    conn
  end

  def update_team_environment(conn, params) do
    environment = Repo.get!(Environment, params["id"])
    changeset = Environment.changeset(environment, params)

    case Repo.update(changeset) do
      {:ok, env} ->
        conn
        |> json(env)
      {:error, changeset} ->
        conn
        |> json(%{})
    end
  end
end
