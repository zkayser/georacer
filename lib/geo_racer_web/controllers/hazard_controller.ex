defmodule GeoRacerWeb.HazardController do
  use GeoRacerWeb, :controller
  alias Phoenix.LiveView
  alias GeoRacerWeb.Plugs.FetchTeamName

  plug FetchTeamName when action in [:index]

  def index(conn, %{"race_id" => race_id} = _params) do
    LiveView.Controller.live_render(
      conn,
      GeoRacerWeb.HazardsLive,
      session: %{race_id: race_id, team_name: conn.assigns[:team_name]}
    )
  end

  def show(conn, _params) do
    LiveView.Controller.live_render(
      conn,
      GeoRacerWeb.WeaponsLive,
      session: %{}
    )
  end
end
