defmodule GeoRacerWeb.PageController do
  use GeoRacerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
