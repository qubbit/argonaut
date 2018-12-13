defmodule ArgonautWeb.EnvironmentController do
  use Argonaut.Web, :controller

  alias Argonaut.Environment

  def index(conn, _params) do
    environments = Repo.all(Environment)
    render(conn, "index.html", environments: environments)
  end

  def new(conn, _params) do
    changeset = Environment.changeset(%Environment{})
    render(conn, "new.html", changeset: changeset)
  end

  def environment_json(conn, _params) do
    query = Environment |> order_by(asc: :name)
    render(conn, "index.json", environments: Repo.all(query))
  end

  def create(conn, %{"environment" => environment_params}) do
    changeset = Environment.changeset(%Environment{}, environment_params)

    case Repo.insert(changeset) do
      {:ok, _environment} ->
        conn
        |> put_flash(:info, "Environment created successfully.")
        |> redirect(to: environment_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    environment = Repo.get!(Environment, id)
    render(conn, "show.html", environment: environment)
  end

  def edit(conn, %{"id" => id}) do
    environment = Repo.get!(Environment, id)
    changeset = Environment.changeset(environment)
    render(conn, "edit.html", environment: environment, changeset: changeset)
  end

  def update(conn, %{"id" => id, "environment" => environment_params}) do
    environment = Repo.get!(Environment, id)
    changeset = Environment.changeset(environment, environment_params)

    case Repo.update(changeset) do
      {:ok, environment} ->
        conn
        |> put_flash(:info, "Environment updated successfully.")
        |> redirect(to: environment_path(conn, :show, environment))

      {:error, changeset} ->
        render(conn, "edit.html", environment: environment, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    environment = Repo.get!(Environment, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(environment)

    conn
    |> put_flash(:info, "Environment deleted successfully.")
    |> redirect(to: environment_path(conn, :index))
  end
end
