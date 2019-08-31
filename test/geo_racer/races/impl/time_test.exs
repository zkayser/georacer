defmodule GeoRacer.Races.Race.TimeTest do
  use ExUnit.Case
  alias GeoRacer.Races.Race.Time

  describe "render/1" do
    test "returns 00:00 when given 0 seconds" do
      assert Time.render(0) == "00:00"
    end

    test "00:01 for 1 second" do
      assert Time.render(1) == "00:01"
    end

    test "returns 01:00 for 1 minute" do
      assert Time.render(60) == "01:00"
    end

    test "returns 01:00:00 for 1 hour" do
      assert Time.render(60 * 60) == "01:00:00"
    end
  end

  describe "update/2" do
    test "broadcasts a new time value on the race_time:id pubsub topic" do
      identifier = GeoRacer.StringGenerator.random_string()
      GeoRacerWeb.Endpoint.subscribe("race_time:#{identifier}")
      seconds = 24
      25 = Time.update(seconds, identifier)

      assert_receive %Phoenix.Socket.Broadcast{event: "tick", payload: %{"clock" => "00:25"}}
    end
  end
end
