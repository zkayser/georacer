defmodule GeoRacer.Races.Race.ImplTest do
  use GeoRacer.DataCase
  alias GeoRacer.Races.Race.Impl, as: Race
  alias GeoRacer.Races.StagingArea.Impl, as: StagingArea

  setup do
    {:ok, course} = GeoRacer.Factories.CourseFactory.insert()
    {:ok, race} = GeoRacer.Factories.RaceFactory.insert()
    {:ok, course: course, race: race}
  end

  describe "from_staging_area/1" do
    test "derives a Race.Impl struct from a valid StagingArea struct", %{course: course} do
      staging_area = StagingArea.from_identifier("#{course.id}:#{GeoRacer.Races.generate_code()}")
      staging_area = %StagingArea{staging_area | teams: ["team 1", "team 2", "team 3"]}

      assert {:ok, %Race{} = race} = Race.from_staging_area(staging_area)
      assert race.course == course

      assert race.status == "started"

      assert Enum.all?(staging_area.teams, fn team -> team in Map.keys(race.team_tracker) end)
    end
  end

  describe "next_waypoint/2" do
    test "returns the next waypoint for the given team", %{race: race} do
      team = race.team_tracker |> Map.keys() |> hd()
      waypoint = Race.next_waypoint(race, team)

      assert waypoint.id == Enum.at(race.team_tracker[team], 0)
    end

    test "returns nil if the team is finished", %{race: race} do
      team = race.team_tracker |> Map.keys() |> hd()
      race = %{race | team_tracker: %{race.team_tracker | team => []}}
      refute Race.next_waypoint(race, team)
    end
  end
end
