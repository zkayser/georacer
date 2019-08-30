defmodule GeoRacer.Races.StagingArea.ImplTest do
  use ExUnit.Case
  alias GeoRacer.Races.StagingArea.Impl, as: StagingArea

  @staging_area %StagingArea{
    identifier: "#{round(:rand.uniform() * 2)}:#{GeoRacer.Races.generate_code()}"
  }
  @team "My team"

  describe "put_team/1" do
    test "adds the given team to the staging area" do
      assert @team in StagingArea.put_team(@staging_area, @team).teams
    end
  end

  describe "drop_team/1" do
    test "removes the given team from the staging area" do
      staging_area = StagingArea.put_team(@staging_area, @team)
      refute @team in StagingArea.drop_team(staging_area, @team).teams
    end

    test "is a no-op if the team has not been added to the staging area" do
      assert @staging_area == StagingArea.drop_team(@staging_area, "Blah blah team")
    end
  end
end
