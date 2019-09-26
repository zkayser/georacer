defmodule GeoRacer.Hazards.WaypointBombTest do
  use ExUnit.Case
  alias GeoRacer.Hazards.WaypointBomb

  describe "explain/0" do
    test "returns a description of the hazard's affect" do
      assert WaypointBomb.explain() ==
               "Change an opposing team's next waypoint."
    end
  end

  describe "description/0" do
    test "returns a description of the hazard for affected parties" do
      assert WaypointBomb.description() ==
               "Your meter is now sending you to a different waypoint."
    end
  end

  describe "display_name/0" do
    test "returns the string 'Waypoint Bomb'" do
      assert "Waypoint Bomb" == WaypointBomb.display_name()
    end
  end

  describe "image/0" do
    test "returns a string representing an image file for the hazard" do
      assert "waypoint-bomb.svg" == WaypointBomb.image()
    end
  end
end
