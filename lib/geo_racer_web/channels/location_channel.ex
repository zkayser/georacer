defmodule GeoRacerWeb.LocationChannel do
  @moduledoc false
  use Phoenix.Channel
  alias GeoRacerWeb.Endpoint

  @topic "position_updates:"

  def join("location:" <> identifier, _params, socket) do
    {:ok, %{}, assign(socket, :identifier, identifier)}
  end

  def handle_in("update", params, socket) do
    state = %{latitude: params["latitude"], longitude: params["longitude"]}
    :ok = Endpoint.broadcast!(@topic <> socket.assigns.identifier, "update", state)

    {:noreply, socket}
  end
end
