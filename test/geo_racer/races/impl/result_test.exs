defmodule GeoRacer.Races.Race.ResultTest do
  alias GeoRacer.Races.Race.Impl, as: Race
  alias GeoRacer.Races.Race.{Result, Time}
  use GeoRacer.DataCase

  setup do
    {:ok, race} = GeoRacer.Factories.RaceFactory.insert()

    {:ok, race: race}
  end

  describe "create/2" do
    test "stores a result associated with the race ", %{race: race} do
      team = GeoRacer.StringGenerator.random_string()
      time = round(:rand.uniform() * 100)
      race = %Race{race | time: time}
      time_as_string = Time.render(time)

      assert {:ok, %Result{team: ^team, time: ^time_as_string}} = Result.create(team, race)
    end

    test "returns an error if team is blank", %{race: race} do
      race = %Race{race | time: round(:rand.uniform() * 100)}

      assert {:error, %Ecto.Changeset{}} = Result.create("", race)
    end

    test "returns an error if an attempt is made to add same team twice", %{race: race} do
      team = GeoRacer.StringGenerator.random_string()
      time_1 = round(:rand.uniform() * 100)
      time_2 = round(:rand.uniform() * 100)

      assert {:ok, _} = Result.create(team, %Race{race | time: time_1})

      assert {:error, %Ecto.Changeset{errors: errors}} =
               Result.create(team, %Race{race | time: time_2})

      assert [{:team, {"has already been taken", _}}] = errors
    end
  end
end
