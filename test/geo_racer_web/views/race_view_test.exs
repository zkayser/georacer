defmodule GeoRacerWeb.RaceViewTest do
  alias GeoRacerWeb.RaceView
  use GeoRacer.DataCase

  setup do
    {:ok, race} = GeoRacer.Factories.RaceFactory.insert()

    {:ok, race: race}
  end

  describe "standings/1" do
    test "returns ordered standings parititioned by finished and in_progress teams", %{
      race: race
    } do
      team_3 = GeoRacer.StringGenerator.random_string()
      race = %GeoRacer.Races.Race.Impl{race | time: 60}
      [team_1, team_2] = Map.keys(race.team_tracker)

      GeoRacer.Races.Race.Impl.record_finished(race, team_2)

      race = %GeoRacer.Races.Race.Impl{race | time: 120}
      GeoRacer.Races.Race.Impl.record_finished(race, team_1)

      race = GeoRacer.Races.get_race!(race.id)

      race = %GeoRacer.Races.Race.Impl{
        race
        | team_tracker: %{team_1 => [], team_2 => [], team_3 => [1, 2]}
      }

      assert %{
               finished: [
                 {1, %GeoRacer.Races.Race.Result{team: ^team_2, time: "01:00"}},
                 {2, %GeoRacer.Races.Race.Result{team: ^team_1, time: "02:00"}}
               ],
               in_progress: [{3, ^team_3}]
             } = RaceView.standings(race)
    end
  end
end
