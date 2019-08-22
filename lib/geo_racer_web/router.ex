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
    get "/join-race", JoinRaceController, :show
    get "/race-list", RaceListController, :show
    resources "/courses", CourseController
    live "/start-race", StartRaceLive
    live "/position", PositionLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", GeoRacerWeb do
  #   pipe_through :api
  # end
end
