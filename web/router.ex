defmodule Argonaut.Router do
  use Argonaut.Web, :router

  pipeline :admin do
    plug Argonaut.Plug.RequireAdmin
  end

  pipeline :api do
    plug :accepts, ["json"]

    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
  end

  scope "/api", Argonaut do
    pipe_through :api

    resources "/reservations", ReservationController, except: [:new, :edit]
    get "/applications", ApplicationController, :application_json
    get "/environments", EnvironmentController, :environment_json
    get "/gravatar", GravatarController, :get_url

    post "/sessions", SessionController, :create
    delete "/sessions", SessionController, :delete
    post "/sessions/refresh", SessionController, :refresh

    resources "/users", UserController, only: [:create]

    resources "/membership", MembershipController, except: [:new, :edit]

    get "/users/:id/teams", UserController, :teams

    resources "/teams", TeamController, only: [:index, :create, :update] do
      resources "/reservations", ReservationController, only: [:index]
    end
    post "/teams/:id/join", TeamController, :join
    get "/teams/:id/table", TeamController, :table

    post "/teams/:id/applications", TeamController, :new_team_application
    get "/teams/:id/applications", TeamController, :show_team_applications

    post "/teams/:id/environments", TeamController, :new_team_environment
    get "/teams/:id/environments", TeamController, :show_team_environments
  end


  scope "/", Argonaut do
    get "/*path", ApplicationController, :not_found
  end

end
