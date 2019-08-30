defmodule GeoRacerWeb.Live.Courses.Show do
  @moduledoc false
  alias GeoRacer.Races.StagingArea
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(GeoRacerWeb.CourseView, "show.html", assigns)
  end

  def mount(session, socket) do
    StagingArea.put_team("#{session.course.id}:#{session.code}", session.current_team)
    StagingArea.subscribe_to_updates(session.course.id, session.code)
    send(self(), {:setup, session})
    {:ok, assign(socket, code: session.code, course: session.course, teams: [])}
  end

  def handle_info({:setup, %{course: course, code: code} = session}, socket) do
    %{teams: teams} = StagingArea.state("#{course.id}:#{code}")

    socket =
      socket
      |> assign(:current_team, session.current_team)
      |> assign(:teams, teams)

    {:noreply, socket}
  end

  def handle_info(%{event: "update", payload: %StagingArea.Impl{} = staging_area}, socket) do
    {:noreply, assign(socket, :teams, staging_area.teams)}
  end
end
