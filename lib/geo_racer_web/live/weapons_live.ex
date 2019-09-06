defmodule GeoRacerWeb.WeaponsLive do
  @moduledoc false
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(GeoRacerWeb.WeaponsView, "show.html", assigns)
  end

  def mount(_session, socket) do
    {:ok, socket}
  end

  def handle_event("shield_yourself", _, socket) do
    {:noreply, assign(socket, :show_waypoint_overlay?, false)}
  end
end
