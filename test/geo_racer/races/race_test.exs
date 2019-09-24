defmodule GeoRacer.Races.RaceTest do
  alias GeoRacer.Races.Race
  use GeoRacer.DataCase

  setup do
    {:ok, race} = GeoRacer.Factories.RaceFactory.insert()
    Race.Supervisor.create_race(race)
    {:ok, race: race}
  end

  describe "broadcast_update/1" do
    test "broadcasts an update_race event to subscribers", %{race: race} do
      GeoRacerWeb.Endpoint.subscribe("races:#{race.id}")

      Race.broadcast_update(%{
        "update" => race,
        "hazard_deployed" => %{
          "on" => List.first(Map.keys(race.team_tracker)),
          "name" => "MeterBomb",
          "by" => Enum.at(Map.keys(race.team_tracker), 1)
        }
      })

      assert_receive %{
        event: "race_update",
        payload: %{"update" => ^race, "hazard_deployed" => _}
      }
    end
  end

  describe "put_hazard/2" do
    test "creates a hazard and broadcast the resulting race update", %{race: race} do
      GeoRacerWeb.Endpoint.subscribe("races:#{race.id}")
      affected_team = List.first(Map.keys(race.team_tracker))
      attacking_team = Enum.at(Map.keys(race.team_tracker), 1)

      Race.put_hazard(race,
        type: "MeterBomb",
        on: affected_team,
        by: attacking_team
      )

      assert_receive %{
        event: "race_update",
        payload: %{
          "update" => new_race,
          "hazard_deployed" => %{
            "name" => "MeterBomb",
            "on" => ^affected_team,
            "by" => ^attacking_team
          }
        }
      }

      assert [hazard] = new_race.hazards
      assert hazard.name == "MeterBomb"
    end
  end

  describe "stop_race/1" do
    test "saves the race state when the server process is terminated", %{race: race} do
      affected_team = List.first(Map.keys(race.team_tracker))
      attacking_team = Enum.at(Map.keys(race.team_tracker), 1)

      Race.put_hazard(race,
        type: "MeterBomb",
        on: affected_team,
        by: attacking_team
      )

      Race.stop("race:#{race.id}")

      Process.sleep(50)

      new_race = GeoRacer.Races.get_race!(race.id)

      refute race == new_race
    end
  end
end
