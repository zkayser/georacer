defmodule GeoRacerWeb.CourseController do
  use GeoRacerWeb, :controller
  alias GeoRacerWeb.Live.Courses.{New, Show}
  alias Phoenix.LiveView

  def index(conn, _) do
    render(conn, "index.html", %{})
  end

  def new(conn, _) do
    LiveView.Controller.live_render(conn, New, session: %{})
  end

  def show(conn, %{"id" => id}) do
    LiveView.Controller.live_render(conn, Show, session: %{id: id})
  end
end
