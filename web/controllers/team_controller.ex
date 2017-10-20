defmodule Argonaut.TeamController do
  use Argonaut.Web, :controller

  alias Argonaut.{Reservation, Team, Repo, Application, Environment, ApiMessage}

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

        assoc_changeset = Argonaut.Membership.changeset(
          %Argonaut.Membership{},
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

    if check_membership(current_user, team) do
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

  def check_membership(user, team) do
    Argonaut.Membership |> where([m], m.user_id == ^user.id and m.team_id == ^team.id) |> Repo.one
  end

  def update(conn, %{"id" => id, "description" => description}) do
    current_user = Guardian.Plug.current_resource(conn)
    team = Repo.get!(Team, id)

    if check_membership(current_user, team) do
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

    changeset = Argonaut.Membership.changeset(
      %Argonaut.Membership{},
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
    membership = Repo.get_by(Argonaut.Membership, team_id: team.id, user_id: current_user.id)

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

    if check_membership(current_user, team) do
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
      {:ok, _application} ->
        conn
        |> json(_application)
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
    if check_membership(current_user, team) do
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
      {:ok, _environment} ->
        conn
        |> json(_environment)
      {:error, changeset} ->
        conn
        |> json(%{})
    end
  end
end
