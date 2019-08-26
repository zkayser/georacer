defmodule GeoRacerWeb.RaceLive do
  @moduledoc false
  use Phoenix.LiveView

  @topic "position_updates:"
  @id_generator Application.get_env(:geo_racer, :id_generator)

  def render(assigns) do
    Phoenix.View.render(GeoRacerWeb.RaceView, "show.html", assigns)
  end

  def mount(_session, socket) do
    identifier = @id_generator.()
    GeoRacerWeb.Endpoint.subscribe(@topic <> identifier)

    {:ok, assign(socket, position: nil, identifier: identifier)}
  end

  def handle_info(%{event: "update", payload: position}, socket) do
    {:noreply, put_position(socket, position)}
  end

  defp put_position(socket, position) do
    assign(socket, position: position)
  end
end
