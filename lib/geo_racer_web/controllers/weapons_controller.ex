defmodule GeoRacerWeb.WeaponsController do
  use GeoRacerWeb, :controller
  alias Phoenix.LiveView

  def show(conn, _params) do
    LiveView.Controller.live_render(
      conn,
      GeoRacerWeb.WeaponsLive,
      session: %{}
    )
  end
end
