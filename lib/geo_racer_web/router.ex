defmodule GeoRacerWeb.Router do
  use GeoRacerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug Phoenix.LiveView.Flash
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GeoRacerWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/style-guide", StyleGuideController, :show
    get "/terms-of-service", TermsOfServiceController, :show
    get "/about", LandingPageController, :show
    get "/join-race", JoinRaceController, :show
    post "/staging-area", JoinRaceController, :create
    resources "/courses", CourseController

    resources "/races", RaceController, only: [:show] do
      resources "/hazards", HazardController, only: [:index]
    end

    get "/races/:race_id/notifications/:hazard/:attacking_team", RaceController, :notifications
    get "/races/:course_id/:race_code", RaceController, :show
    live "/race", RaceLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", GeoRacerWeb do
  #   pipe_through :api
  # end
end
