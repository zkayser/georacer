defmodule GeoRacer.RacesTest do
  use ExUnit.Case
  alias GeoRacer.Races

  describe "generate_code/0" do
    test "generates an 8-character code" do
      assert Races.generate_code() =~ ~r([\d\w]{8})
    end
  end
end
