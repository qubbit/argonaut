defmodule Argonaut.Router do
  use Argonaut.Web, :router

  pipeline :admin do
    plug Argonaut.Plug.RequireAdmin
  end

  pipeline :readonly do
    plug Argonaut.Plug.ReadOnlyToken
  end

  pipeline :api do
    plug :accepts, ["json"]

    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.EnsureAuthenticated, handler: Argonaut.ApiToken
    plug Guardian.Plug.LoadResource
  end

  pipeline :anonymous do
    plug :accepts, ["json"]
  end

  scope "/api/readonly", Argonaut do
    pipe_through :readonly

    # id of the team to fetch
    get "/teams/:id/reservations", TeamController, :table
    get "/teams", TeamController, :index
  end

  # these are paths that do not require authentication
  scope "/api/anonymous", Argonaut do
    pipe_through :anonymous

    post "/forgot_password", SessionController, :forgot_password
    post "/reset_password", SessionController, :reset_password
    post "/sessions", SessionController, :create
    resources "/users", UserController, only: [:create]
  end

  scope "/api", Argonaut do
    pipe_through :api

    resources "/reservations", ReservationController, except: [:new, :edit]
    get "/applications", ApplicationController, :application_json
    get "/environments", EnvironmentController, :environment_json
    get "/gravatar", GravatarController, :get_url

    delete "/sessions", SessionController, :delete
    post "/sessions/refresh", SessionController, :refresh

    resources "/membership", MembershipController, except: [:new, :edit]

    get "/users/:id/teams", UserController, :teams
    post "/users/:id/vacation", UserController, :delete_all_user_reservations

    resources "/teams", TeamController, only: [:index, :create, :update] do
      resources "/reservations", ReservationController, only: [:index]
    end

    post "/teams/:id/join", TeamController, :join
    delete "/teams/:id", TeamController, :delete
    delete "/teams/:id/leave", TeamController, :leave
    get "/teams/:id/table", TeamController, :table

    post "/teams/:id/applications", TeamController, :new_team_application
    get "/teams/:id/applications", TeamController, :show_team_applications
    delete "/teams/:id/applications/:application_id", TeamController, :delete_team_application

    # TODO: revisit this later, might want to use nested resources
    patch "/teams/:team_id/applications/:id", TeamController, :update_team_application
    patch "/teams/:team_id/environments/:id", TeamController, :update_team_environment

    delete "/teams/:id/environments/:environment_id", TeamController, :delete_team_environment

    post "/teams/:id/environments", TeamController, :new_team_environment
    get "/teams/:id/environments", TeamController, :show_team_environments

    patch "/profile", ProfileController, :update
  end

  scope "/", Argonaut do
    get "/*path", BaseController, :not_found
  end
end
