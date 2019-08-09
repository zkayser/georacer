defmodule LiveViewDemoWeb.PositionChannel do
  use Phoenix.Channel
  alias LiveViewDemoWeb.Endpoint

  @topic "position_updates"

  def join("position:" <> _, _params, socket) do
    {:ok, %{}, socket}
  end

  def handle_in("update", params, socket) do
    state = %{latitude: params["latitude"], longitude: params["longitude"]}
    Endpoint.broadcast(@topic, "update", state)

    {:noreply, assign(socket, :state, state)}
  end
end
