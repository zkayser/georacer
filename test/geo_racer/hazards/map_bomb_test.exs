defmodule GeoRacer.Hazards.MapBombbTest do
  use ExUnit.Case
  alias GeoRacer.Hazards.MapBomb

  describe "explain/0" do
    test "returns a description of the hazard's affect" do
      assert MapBomb.explain() ==
               "Throw an opposing team's map into disarray for 60 seconds."
    end
  end

  describe "description/0" do
    test "returns a description of the hazard for affected parties" do
      assert MapBomb.description() ==
               "Your map will go wild for the next 60 seconds."
    end
  end

  describe "display_name/0" do
    test "returns the string 'Map Bomb'" do
      assert "Map Bomb" == MapBomb.display_name()
    end
  end

  describe "image/0" do
    test "returns a string representing an image file for the hazard" do
      assert "map-bomb.svg" == MapBomb.image()
    end
  end
end
