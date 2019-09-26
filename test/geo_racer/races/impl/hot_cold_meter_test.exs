defmodule GeoRacer.Races.Race.HotColdMeterTest do
  use GeoRacer.DataCase
  alias GeoRacer.Races.Race.HotColdMeter

  setup do
    {:ok, course} = GeoRacer.Factories.CourseFactory.insert()

    {:ok, %{waypoint: List.first(course.waypoints)}}
  end

  describe "level/3" do
    test "returns the level scores between 1 and 9 based on distance relative to boundary", %{
      waypoint: waypoint
    } do
      Enum.each(1..9, fn x ->
        assert HotColdMeter.level(waypoint, %{"level" => x}) == x
      end)
    end
  end
end
