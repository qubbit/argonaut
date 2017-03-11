defmodule Argonaut.Router do
  use Argonaut.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.EnsureAuthenticated, handler: Argonaut.CookieToken
    plug Guardian.Plug.LoadResource
  end

  pipeline :admin do
    plug Argonaut.Plug.RequireAdmin
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.EnsureAuthenticated, handler: Argonaut.ApiToken
    plug Guardian.Plug.LoadResource
  end

  scope "/", Argonaut do
    pipe_through [:browser]
    get "/login", LoginController, :index
    post "/login", LoginController, :authenticate

    get "/signup", LoginController, :signup
    post "/signup", LoginController, :handle_signup

    get "/logout", LoginController, :logout
  end

  scope "/", Argonaut do
    pipe_through [:browser, :browser_auth]

    get "/", PageController, :index, as: :index

    get "/profile", ProfileController, :show
    get "/profile/edit", ProfileController, :edit
    put "/profile/update", ProfileController, :update
  end

  scope "/", Argonaut do
    pipe_through [:browser, :browser_auth, :admin]

    get "/admin", AdminController, :index, as: :index
    resources "/admin/users", UserController
    resources "/admin/applications", ApplicationController
    resources "/admin/environments", EnvironmentController
  end

  scope "/api", Argonaut do
    pipe_through :api
    resources "/reservations", ReservationController, except: [:new, :edit]
    get "/applications", ApplicationController, :application_json
    get "/environments", EnvironmentController, :environment_json
    get "/gravatar", GravatarController, :get_url
  end
end
