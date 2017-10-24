defmodule Argonaut.Router do
  use Argonaut.Web, :router

  pipeline :admin do
    plug Argonaut.Plug.RequireAdmin
  end

  pipeline :anonymous do
    plug :accepts, ["json"]
  end

  pipeline :api do
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.EnsureAuthenticated, handler: Argonaut.ApiToken
    plug Guardian.Plug.LoadResource
  end

  pipeline :readonly do
    plug Argonaut.Plug.ReadOnlyToken
  end

  scope "/api/admin", Argonaut do
    pipe_through [:anonymous, :api, :admin]
    resources "/mails", MailController
  end

  # TODO: readonly is not true anymore, rename it to something else
  scope "/api/readonly", Argonaut do
    # the verb_noun routes are all RPC style
    # they have their RESTful analogues

    pipe_through [:anonymous, :readonly]

    # id of the team to fetch the current status
    get "/teams/:name_or_id/reservations", TeamController, :table
    get "/show_team_status/:name_or_id", TeamController, :table

    # id of the team to create a reservation on
    post "/reservations", TeamController, :create_reservation
    post "/create_reservation", TeamController, :create_reservation

    # id of the team to create a reservation on
    delete "/reservations", TeamController, :delete_reservation
    delete "/delete_reservation", TeamController, :delete_reservation

    # show all teams
    get "/teams", TeamController, :index
    get "/get_teams", TeamController, :index
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
    pipe_through [:anonymous, :api]

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
    get "/teams/:name_or_id/table", TeamController, :table

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
