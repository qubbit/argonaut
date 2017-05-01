 defmodule Argonaut.UserController do
   use Argonaut.Web, :controller

   alias Argonaut.User

   plug Guardian.Plug.EnsureAuthenticated, [handler: Argonaut.SessionController] when action in [:teams]

   def create(conn, params) do
     changeset = User.registration_changeset(%User{}, params)

     case Repo.insert(changeset) do
       {:ok, user} ->
         new_conn = Guardian.Plug.api_sign_in(conn, user, :access)
         jwt = Guardian.Plug.current_token(new_conn)

         new_conn
         |> put_status(:created)
         |> render(Argonaut.SessionView, "show.json", user: user, jwt: jwt)
       {:error, changeset} ->
         conn
         |> put_status(:unprocessable_entity)
         |> render(Argonaut.ChangesetView, "error.json", changeset: changeset)
     end
   end

   def teams(conn, params) do
     current_user = Guardian.Plug.current_resource(conn)

     page =
       assoc(current_user, :teams)
       |> Repo.paginate(params)
     render(conn, Argonaut.TeamView, "index.json", teams: page)
   end
 end
