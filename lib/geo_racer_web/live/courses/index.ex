defmodule GeoRacerWeb.Live.Courses.Index do
  @moduledoc false
  use Phoenix.LiveView
  alias GeoRacer.Courses
  require Logger

  @topic "position_updates:"

  def render(assigns) do
    Phoenix.View.render(GeoRacerWeb.CourseView, "index.html", assigns)
  end

  def mount(%{identifier: identifier, courses: courses} = session, socket) do
    :ok = GeoRacerWeb.Endpoint.subscribe(@topic <> identifier)
    selected_tab = if Enum.empty?(courses), do: :public, else: :private

    {:ok,
     assign(socket,
       position: nil,
       courses: %{private: courses, public: session.public_courses},
       identifier: identifier,
       selected_tab: selected_tab
     )}
  end

  def handle_info(%{event: "update", payload: position}, socket) do
    {:noreply, assign(socket, position: position)}
  end

  def handle_event("select_private", _, socket) do
    {:noreply, assign(socket, selected_tab: :private)}
  end

  def handle_event("select_public", _, socket) do
    {:noreply, assign(socket, selected_tab: :public)}
  end
end
