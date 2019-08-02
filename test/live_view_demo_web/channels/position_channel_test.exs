defmodule LiveViewDemoWeb.PositionChannelTest do
  use LiveViewDemoWeb.ChannelCase
  alias LiveViewDemoWeb.Endpoint

  @lat "39.10"
  @lng "84.51"
  @topic "position_updates"

  setup do
    {:ok, _, socket} =
      socket(LiveViewDemoWeb.UserSocket, "user_id", %{some: :assign})
      |> subscribe_and_join(LiveViewDemoWeb.PositionChannel, "position:lobby")

    Endpoint.subscribe(@topic)

    {:ok, socket: socket}
  end

  describe "PositionChannel" do
    test "broadcasts position updates when it receives update messages", %{socket: socket} do
      push(socket, "update", %{"latitude" => @lat, "longitude" => @lng})
      assert_receive %{event: "update", payload: %{latitude: @lat, longitude: @lng}}
    end
  end
end
