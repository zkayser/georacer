defmodule GeoRacerWeb.CourseController do
  use GeoRacerWeb, :controller
  alias Phoenix.LiveView

  def new(conn, _) do
    LiveView.Controller.live_render(conn, GeoRacerWeb.CourseLive, session: %{view: "new.html"})
  end
end
