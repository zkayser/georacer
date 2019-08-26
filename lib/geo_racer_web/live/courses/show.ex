defmodule GeoRacerWeb.Live.Courses.Show do
  @moduledoc false
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(GeoRacerWeb.CourseView, "show.html", assigns)
  end

  def mount(session, socket) do
    {:ok, assign(socket, course: session.course)}
  end
end
