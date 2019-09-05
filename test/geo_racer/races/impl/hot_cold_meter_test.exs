defmodule GeoRacer.Races.Race.HotColdMeterTest do
  use GeoRacer.DataCase
  alias GeoRacer.Races.Race.HotColdMeter

  @boundary 8

  setup do
    {:ok, course} = GeoRacer.Factories.CourseFactory.insert()

    {:ok, %{waypoint: List.first(course.waypoints)}}
  end

  describe "level/3" do
    test "returns the level scores between 1 and 9 based on distance relative to boundary", %{
      waypoint: waypoint
    } do
      Enum.each(0..7, fn x ->
        assert HotColdMeter.level(waypoint, x, @boundary) == x + 1 ||
                 HotColdMeter.level(waypoint, x, @boundary) == x
      end)
    end
  end
end
