defmodule GeoRacerWeb.RaceLive do
  @moduledoc false
  use Phoenix.LiveView
  alias GeoRacer.Races.Race
  alias GeoRacerWeb.Router.Helpers, as: Routes

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
        Race.Supervisor.create_race("#{race.id}")
        GeoRacerWeb.Endpoint.subscribe(@topic <> identifier)
        GeoRacerWeb.Endpoint.subscribe("#{@time_topic}#{race.id}")

        socket =
          socket
          |> assign(:position, nil)
          |> assign(:identifier, identifier)
          |> assign(:team_name, team_name)
          |> assign(:race, race)
          |> assign(:timer, "00:00")

        {:ok, assign(socket, position: nil, identifier: identifier)}
    end
  end

  def handle_info(%{event: "update", payload: position}, socket) do
    {:noreply, put_position(socket, position)}
  end

  def handle_info(%{event: "tick", payload: %{"clock" => clock}}, socket) do
    {:noreply, assign(socket, :timer, clock)}
  end

  defp put_position(socket, position) do
    assign(socket, position: position)
  end
end
