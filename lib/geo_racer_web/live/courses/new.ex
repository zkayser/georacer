defmodule GeoRacerWeb.Live.Courses.New do
  @moduledoc false
  use Phoenix.LiveView
  alias GeoRacer.Courses
  alias GeoRacer.Courses.Course
  alias GeoRacerWeb.Router.Helpers, as: Routes

  @topic "position_updates"

  def render(assigns) do
    Phoenix.View.render(GeoRacerWeb.CourseView, "new.html", assigns)
  end

  def mount(_session, socket) do
    GeoRacerWeb.Endpoint.subscribe(@topic)

    {:ok, assign(socket, position: nil, waypoints: [], race_name: "")}
  end

  def handle_info(%{event: "update", payload: position}, socket) do
    {:noreply, put_position(socket, position)}
  end

  def handle_event("update_race_name", %{"race_name" => race_name}, socket) do
    {:noreply, assign(socket, :race_name, race_name)}
  end

  def handle_event("create_course", _value, %{assigns: %{waypoints: waypoints}} = socket) do
    with {:ok, course} <-
           Courses.create_course(%{
             waypoints: waypoints,
             center: Course.calculate_center(waypoints),
             name: socket.assigns.race_name
           }) do
      {:stop, socket |> redirect(to: Routes.course_path(GeoRacerWeb.Endpoint, :show, course))}
    else
      {:error, %Ecto.Changeset{} = changeset} -> {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("set_waypoint", _value, %{assigns: %{waypoints: waypoints}} = socket) do
    case socket.assigns.position do
      nil ->
        {:noreply, socket}

      position ->
        {:noreply, assign(socket, waypoints: [position | waypoints])}
    end
  end

  def handle_event("delete_waypoint", value, socket) do
    with {index, _} <- Integer.parse(value) do
      {:noreply, delete_waypoint(socket, index)}
    else
      _ ->
        {:noreply, socket}
    end
  end

  defp put_position(socket, position) do
    assign(socket, position: position)
  end

  defp delete_waypoint(socket, index) do
    assign(socket, waypoints: List.delete_at(socket.assigns.waypoints, index))
  end
end
