defmodule GeoRacerWeb.PositionChannelTest do
  use GeoRacerWeb.ChannelCase
  alias GeoRacerWeb.Endpoint

  @lat "39.10"
  @lng "84.51"
  @topic "position_updates"

  setup do
    {:ok, _, socket} =
      GeoRacerWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(GeoRacerWeb.PositionChannel, "position:lobby")

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
