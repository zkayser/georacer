defmodule GeoRacer.Races.Race.ServerTest do
  alias GeoRacer.Races.Race.Supervisor
  use GeoRacer.DataCase

  setup do
    {:ok, race} = GeoRacer.Factories.RaceFactory.insert()

    Supervisor.create_race(race)
    GeoRacerWeb.Endpoint.subscribe("races:#{race.id}")

    {:ok, race: race}
  end

  describe "handle_info -- {:record_finished} callback" do
    test "broadcasts a race_update message to subscribers", %{race: race} do
      team = List.first(Map.keys(race.team_tracker))
      pid = Supervisor.get_pid("#{race.id}")

      send(pid, {:record_finished, team})

      assert_receive %{
        event: "race_update",
        payload: %{"update" => %GeoRacer.Races.Race.Impl{} = race}
      }

      assert team in Enum.map(race.results, fn result -> result.team end)
    end
  end
end
