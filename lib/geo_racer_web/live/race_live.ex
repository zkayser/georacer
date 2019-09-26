defmodule GeoRacerWeb.RaceLive do
  @moduledoc false
  use Phoenix.LiveView
  alias GeoRacer.Races.Race
  alias GeoRacerWeb.RaceView.ViewModel
  alias GeoRacerWeb.Router.Helpers, as: Routes
  require Logger

  @topic "position_updates:"
  @time_topic "race_time:"
  @race_topic_prefix "races:"
  @view_model_operations [
    :set_next_waypoint,
    :waypoint_reached,
    :refresh_race,
    :set_hot_cold_level,
    :set_hot_cold_meter
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
        GeoRacerWeb.Endpoint.subscribe("#{@race_topic_prefix}#{race.id}")
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

  def handle_info(
        %{
          event: "race_update",
          payload: %{
            "update" => new_race,
            "hazard_deployed" => %{
              "on" => team,
              "name" => hazard_name,
              "by" => attacking_team
            }
          }
        },
        %{assigns: %{view_model: view_model}} = socket
      ) do
    case team == view_model.team_name do
      true ->
        {:stop,
         redirect(socket,
           to:
             Routes.race_path(
               GeoRacerWeb.Endpoint,
               :notifications,
               view_model.race.id,
               hazard_name,
               attacking_team
             )
         )}

      false ->
        {:noreply, assign(socket, view_model: ViewModel.update_race(view_model, new_race))}
    end
  end

  def handle_info(%{event: "race_update", payload: %{"update" => new_race}}, socket) do
    {:noreply,
     assign(socket, view_model: ViewModel.update_race(socket.assigns.view_model, new_race))}
  end

  def handle_info({operation, extra_arg}, %{assigns: %{view_model: view_model}} = socket)
      when operation in @view_model_operations do
    {:noreply, assign(socket, view_model: apply(ViewModel, operation, [view_model, extra_arg]))}
  end

  def handle_info(operation, %{assigns: %{view_model: view_model}} = socket)
      when operation in @view_model_operations do
    {:noreply, assign(socket, view_model: apply(ViewModel, operation, [view_model]))}
  end

  def handle_event("use_hazard", _, socket) do
    {:stop,
     redirect(socket,
       to: Routes.race_hazard_path(GeoRacerWeb.Endpoint, :index, socket.assigns.view_model.race)
     )}
  end
end
