defmodule GeoRacerWeb.CourseController do
  use GeoRacerWeb, :controller
  alias GeoRacer.Courses
  alias GeoRacerWeb.Live.Courses.{New, Show}
  alias Phoenix.LiveView

  def index(conn, _params) do
    render(conn, "index.html", courses: Courses.list_courses())
  end

  def new(conn, _) do
    LiveView.Controller.live_render(conn, New, session: %{})
  end

  def show(conn, %{"id" => id}) do
    LiveView.Controller.live_render(conn, Show, session: %{course: Courses.get_course!(id)})
  end
end
