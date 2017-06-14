defmodule Argonaut.TeamController do
  use Argonaut.Web, :controller

  alias Argonaut.{Reservation, Team, Repo, Application, Environment}

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

  def update(conn, %{"id" => id, "description" => description}) do
    team = Repo.get!(Team, id)
    changeset = Team.changeset(team, %{"description" => description})

    case Repo.update(changeset) do
      {:ok, team} ->
        render(conn, "show.json", team: team)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Argonaut.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    team = Repo.get!(Team, id)
    Repo.delete!(team)
    conn |> json(%{ id: team.id })
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
  def table(conn, %{"id" => team_id}) do
    # current_user = Guardian.Plug.current_resource(conn)
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

    if team.owner_id != current_user.id do
      conn |> json(%{"success" => false})
    else
      application = Repo.get(Application, application_id)
      Repo.delete!(application)
      conn |> json(%{"success" => true, "application_id" => application_id})
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

    if team.owner_id != current_user.id do
      conn |> json(%{"success" => false})
    else
      environment = Repo.get(Environment, environment_id)
      Repo.delete!(environment)
      conn |> json(%{"success" => true, "environment_id" => environment_id})
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
