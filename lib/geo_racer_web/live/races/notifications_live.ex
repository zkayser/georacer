defmodule GeoRacerWeb.Race.NotificationsLive do
  @moduledoc false
  alias GeoRacer.Hazards
  alias GeoRacerWeb.Router.Helpers, as: Routes
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(GeoRacerWeb.RaceView, "notifications.html", assigns)
  end

  def mount(session, socket) do
    case Hazards.from_string(session.hazard) do
      {:ok, hazard} ->
        socket =
          socket
          |> assign(
            race_id: session.race_id,
            hazard: hazard,
            attacking_team: URI.decode(session.attacking_team)
          )

        {:ok, socket}

      {:error, :invalid_hazard} ->
        {:stop,
         redirect(socket, to: Routes.race_path(GeoRacerWeb.Endpoint, :show, session.race_id))}
    end
  end

  def handle_event("return_to_race", _, %{assigns: %{race_id: race_id}} = socket) do
    {:stop, redirect(socket, to: Routes.race_path(GeoRacerWeb.Endpoint, :show, race_id))}
  end
end
