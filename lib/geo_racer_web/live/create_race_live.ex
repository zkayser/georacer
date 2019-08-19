defmodule GeoRacerWeb.CreateRaceLive do
  @moduledoc false
  use Phoenix.LiveView

  @topic "position_updates"

  def render(assigns) do
    Phoenix.View.render(GeoRacerWeb.PositionView, "show.html", assigns)
  end

  def mount(_session, socket) do
    GeoRacerWeb.Endpoint.subscribe(@topic)

    {:ok, assign(socket, position: nil)}
  end

  def handle_info(%{event: "update", payload: position}, socket) do
    {:noreply, put_position(socket, position)}
  end

  defp put_position(socket, position) do
    assign(socket, position: position)
  end
end
