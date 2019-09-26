defmodule GeoRacer.Hazards.MeterBombTest do
  use ExUnit.Case
  alias GeoRacer.Courses.Waypoint
  alias GeoRacer.Hazards.MeterBomb

  describe "level/3" do
    test "returns a number between 0 and 9" do
      assert MeterBomb.level(%Waypoint{}, %{}) in 0..9
    end
  end

  describe "explain/0" do
    test "returns a description of the hazard's affect" do
      assert MeterBomb.explain() ==
               "Make your opponent's hot/cold meter go haywire for 60 seconds."
    end
  end

  describe "description/0" do
    test "returns a description of the hazard for affected parties" do
      assert MeterBomb.description() ==
               "Your hot/cold meter will be dysfunctional for the next 60 seconds."
    end
  end

  describe "display_name/0" do
    test "returns the string 'Meter Bomb'" do
      assert "Meter Bomb" == MeterBomb.display_name()
    end
  end

  describe "image/0" do
    test "returns a string representing an image file for the hazard" do
      assert "meter-bomb.svg" == MeterBomb.image()
    end
  end
end
