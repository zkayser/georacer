defmodule GeoRacerWeb.RaceLive do
  @moduledoc false
  use Phoenix.LiveView
  alias GeoRacer.Races.Race
  alias GeoRacerWeb.RaceView.ViewModel
  alias GeoRacerWeb.Router.Helpers, as: Routes
  require Logger

  @topic "position_updates:"
  @time_topic "race_time:"
  @view_model_operations [
    :set_next_waypoint,
    :waypoint_reached,
    :refresh_race,
    :set_hot_cold_level
  ]

  @spec render([{any, any}] | map) :: any
  def render(assigns) do
    Phoenix.View.render(GeoRacerWeb.RaceView, "show.html", assigns)
  end

  def mount(
        %{identifier: identifier, team_name: team_name, race: race} = session,
        socket
      ) do
    case team_name not in Map.keys(race.team_tracker) do
      true ->
        {:stop, redirect(socket, to: Routes.course_path(GeoRacerWeb.Endpoint, :index))}

      false ->
        Race.Supervisor.create_race(race)
        GeoRacerWeb.Endpoint.subscribe(@topic <> identifier)
        GeoRacerWeb.Endpoint.subscribe("#{@time_topic}#{race.id}")
        send(self(), :set_next_waypoint)

        {:ok, assign(socket, view_model: ViewModel.from_session(session))}
    end
  end

  def handle_info(
        %{event: "update", payload: position},
        %{assigns: %{view_model: view_model}} = socket
      ) do
    {:noreply, assign(socket, :view_model, ViewModel.maybe_update_position(view_model, position))}
  end

  def handle_info(
        %{event: "tick", payload: %{"clock" => clock}},
        %{assigns: %{view_model: view_model}} = socket
      ) do
    {:noreply, assign(socket, view_model: ViewModel.set_timer(view_model, clock))}
  end

  def handle_info({operation, extra_arg}, %{assigns: %{view_model: view_model}} = socket)
      when operation in @view_model_operations do
    {:noreply, assign(socket, view_model: apply(ViewModel, operation, [view_model, extra_arg]))}
  end

  def handle_info(operation, %{assigns: %{view_model: view_model}} = socket)
      when operation in @view_model_operations do
    {:noreply, assign(socket, view_model: apply(ViewModel, operation, [view_model]))}
  end

  def handle_event("shield_yourself", _, socket) do
    {:stop, redirect(socket, to: Routes.weapons_path(GeoRacerWeb.Endpoint, :show, %{}))}
  end
end
