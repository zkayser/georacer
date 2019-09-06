defmodule GeoRacerWeb.RaceLive do
  @moduledoc false
  use Phoenix.LiveView
  alias GeoRacer.Courses.{Course, Waypoint}
  alias GeoRacer.Races.Race
  alias Race.HotColdMeter
  alias GeoRacerWeb.Router.Helpers, as: Routes
  require Logger

  @topic "position_updates:"
  @time_topic "race_time:"

  def render(assigns) do
    Phoenix.View.render(GeoRacerWeb.RaceView, "show.html", assigns)
  end

  def mount(
        %{identifier: identifier, team_name: team_name, race: race},
        socket
      ) do
    case team_name not in Map.keys(race.team_tracker) do
      true ->
        {:stop, redirect(socket, to: Routes.course_path(GeoRacerWeb.Endpoint, :index))}

      false ->
        Race.Supervisor.create_race(race)
        GeoRacerWeb.Endpoint.subscribe(@topic <> identifier)
        GeoRacerWeb.Endpoint.subscribe("#{@time_topic}#{race.id}")
        send(self(), :setup)

        socket =
          socket
          |> assign(:position, nil)
          |> assign(:identifier, identifier)
          |> assign(:team_name, team_name)
          |> assign(:race, race)
          |> assign(:number_waypoints, length(race.course.waypoints))
          |> assign(:team_data, %{})
          |> assign(:hot_cold_level, 0)
          |> assign(:has_reached_waypoint?, false)
          |> assign(:bounding_box, Course.bounding_box(race.course))
          |> assign(:timer, "00:00")

        {:ok, assign(socket, position: nil, identifier: identifier)}
    end
  end

  def handle_info(:setup, socket) do
    %{assigns: %{team_name: team_name, race: race, team_data: team_data}} = socket
    team_data = Map.put(team_data, :current_waypoint, Race.next_waypoint(race, team_name))
    {:noreply, assign(socket, :team_data, team_data)}
  end

  def handle_info(%{event: "update"}, %{assigns: %{has_reached_waypoint?: true}} = socket) do
    {:noreply, socket}
  end

  def handle_info(%{event: "update", payload: position}, socket) do
    case socket.assigns.team_data do
      map when map_size(map) == 0 ->
        {:noreply, put_position(socket, position)}

      %{current_waypoint: %Waypoint{} = waypoint} ->
        view_pid = self()
        run_checks(view_pid, waypoint, position, socket)
        {:noreply, put_position(socket, position)}

      _ ->
        {:noreply, put_position(socket, position)}
    end

    {:noreply, put_position(socket, position)}
  end

  def handle_info(:reached_waypoint, socket) do
    %{team_name: team_name, race: race} = socket.assigns
    Race.drop_waypoint(race, team_name)
    send(self(), :refresh_race_state)
    {:noreply, assign(socket, :has_reached_waypoint?, true)}
  end

  def handle_info(:refresh_race_state, socket) do
    socket =
      socket
      |> assign(:race, GeoRacer.Races.get_race!(socket.assigns.race.id))
      |> assign(
        :current_waypoint,
        Race.next_waypoint(socket.assigns.race, socket.assigns.team_name)
      )

    {:noreply, socket}
  end

  def handle_info({:hot_cold_level, level}, socket) do
    Logger.debug("Receiving hot_cold_level update with #{inspect(level)}")
    {:noreply, assign(socket, :hot_cold_level, level)}
  end

  def handle_info(%{event: "tick", payload: %{"clock" => clock}}, socket) do
    {:noreply, assign(socket, :timer, clock)}
  end

  def handle_event("shield_yourself", _, socket) do
    {:stop, redirect(socket, to: Routes.weapons_path(GeoRacerWeb.Endpoint, :show, %{}))}
  end

  defp put_position(socket, position) do
    assign(socket, position: position)
  end

  defp run_checks(view_pid, waypoint, position, socket) do
    Task.start(fn ->
      if Waypoint.within_radius?(waypoint, position) do
        send(view_pid, :reached_waypoint)
      end
    end)

    Task.start(fn ->
      Logger.debug("Sending hot_cold_level update")

      send(
        view_pid,
        {:hot_cold_level,
         HotColdMeter.level(
           waypoint,
           position,
           Course.boundary_for(socket.assigns.race.course)
         )}
      )
    end)
  end
end
