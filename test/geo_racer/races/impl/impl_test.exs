defmodule GeoRacer.Races.Race.ImplTest do
  use GeoRacer.DataCase
  alias GeoRacer.Races.Race.Impl, as: Race
  alias GeoRacer.Races.Race.Result
  alias GeoRacer.Races.StagingArea.Supervisor
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

    test "spins down the staging area process", %{course: course} do
      {:ok, identifier} =
        Supervisor.create_staging_area("#{course.id}:#{GeoRacer.Races.generate_code()}")

      staging_area = GeoRacer.Races.StagingArea.state(identifier)
      pid = Supervisor.get_pid(identifier)
      assert Process.alive?(pid)

      {:ok, %Race{}} = Race.from_staging_area(staging_area)

      refute Process.alive?(pid)
    end
  end

  describe "next_waypoint/2" do
    test "returns the next waypoint for the given team", %{race: race} do
      team = race.team_tracker |> Map.keys() |> hd()
      waypoint = Race.next_waypoint(race, team)

      assert waypoint.id == Enum.at(race.team_tracker[team], 0)
    end

    test "returns :finished when the team has no more waypoints left", %{race: race} do
      team = race.team_tracker |> Map.keys() |> hd()
      race = %{race | team_tracker: %{race.team_tracker | team => []}}
      assert :finished = Race.next_waypoint(race, team)
    end
  end

  describe "drop_waypoint/2" do
    test "drops a single waypoint for the given team", %{race: race} do
      team = race.team_tracker |> Map.keys() |> hd()
      initial_remaining = length(race.team_tracker[team])
      assert {:ok, updated_race} = Race.drop_waypoint(race, team)

      refute initial_remaining == length(updated_race.team_tracker[team])
    end

    test "returns an error tuple if the given team is not participating in the race", %{
      race: race
    } do
      assert {:error, :invalid_team} = Race.drop_waypoint(race, "non-participating-team")
    end
  end

  describe "record_finished/2" do
    test "records the time when team finished", %{race: race} do
      race = %Race{race | time: 60}
      team = List.first(Map.keys(race.team_tracker))
      {:ok, _race} = Race.record_finished(race, team)

      race = GeoRacer.Races.get_race!(race.id)

      assert %Result{} = result = List.first(race.results)
      assert result.team == team
      assert result.time == "01:00"
    end

    test "returns {:error, :invalid_team} if the team is not participating in the race", %{
      race: race
    } do
      assert {:error, :invalid_team} = Race.record_finished(race, "sdasdasdas")
    end
  end

  describe "hot_cold_meter/2" do
    test "returns MeterBomb if team is affected by a MeterBomb", %{race: race} do
      affected_team = List.first(Map.keys(race.team_tracker))

      {:ok, _hazard} =
        GeoRacer.Factories.HazardFactory.insert(race, %{
          name: GeoRacer.Hazards.name_for(GeoRacer.Hazards.MeterBomb),
          expiration: 60
        })

      race = GeoRacer.Races.get_race!(race.id)

      assert GeoRacer.Hazards.MeterBomb == Race.hot_cold_meter(race, affected_team)
    end

    test "returns HotColdMeter if team is not affected by any hazards", %{race: race} do
      team = List.first(Map.keys(race.team_tracker))
      assert GeoRacer.Races.Race.HotColdMeter == Race.hot_cold_meter(race, team)
    end

    test "returns HotColdMeter instead of MeterBomb if MeterBomb hazards have been expired", %{
      race: race
    } do
      affected_team = List.first(Map.keys(race.team_tracker))

      {:ok, _hazard} =
        GeoRacer.Factories.HazardFactory.insert(race, %{
          name: GeoRacer.Hazards.name_for(GeoRacer.Hazards.MeterBomb),
          expiration: 60
        })

      race = GeoRacer.Races.get_race!(race.id)
      race = %Race{race | time: 61}
      assert GeoRacer.Races.Race.HotColdMeter == Race.hot_cold_meter(race, affected_team)
    end
  end
end
