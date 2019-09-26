defmodule GeoRacerWeb.HazardsLive do
  @moduledoc false
  alias GeoRacer.Hazards
  alias GeoRacer.Races.Race
  alias GeoRacerWeb.Router.Helpers, as: Routes
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(GeoRacerWeb.HazardView, "index.html", assigns)
  end

  def mount(%{race_id: race_id, team_name: team_name}, socket) do
    race = GeoRacer.Races.get_race!(race_id)

    teams =
      race.team_tracker
      |> Map.keys()
      |> Enum.reject(fn team -> team == team_name end)

    {:ok,
     assign(socket,
       race_id: race_id,
       team_name: team_name,
       teams: teams,
       hazard: Enum.random(Hazards.all()),
       selected_team: nil,
       errors: MapSet.new()
     )}
  end

  def handle_event("use_hazard", _, %{assigns: %{selected_team: selected_team}} = socket)
      when is_nil(selected_team) or selected_team == "" do
    socket =
      socket
      |> assign(errors: MapSet.put(socket.assigns.errors, :team_not_selected))

    {:noreply, socket}
  end

  def handle_event(
        "use_hazard",
        _,
        %{
          assigns: %{
            hazard: hazard,
            team_name: attacker,
            selected_team: selected_team,
            race_id: race_id
          }
        } = socket
      ) do
    Race.put_hazard(GeoRacer.Races.get_race!(race_id),
      on: selected_team,
      by: attacker,
      type: String.replace(hazard.display_name(), ~r(\s+), "")
    )

    {:stop,
     redirect(socket, to: Routes.race_path(GeoRacerWeb.Endpoint, :show, socket.assigns.race_id))}
  end

  def handle_event("select_team", %{"selected" => team}, socket) do
    {:noreply,
     assign(socket,
       selected_team: team,
       errors: MapSet.delete(socket.assigns.errors, :team_not_selected)
     )}
  end
end
