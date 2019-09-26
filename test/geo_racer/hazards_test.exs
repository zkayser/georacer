defmodule GeoRacer.HazardsTest do
  alias GeoRacer.Hazards
  alias GeoRacer.Hazards.Hazard
  use GeoRacer.DataCase

  setup do
    {:ok, race} = GeoRacer.Factories.RaceFactory.insert()

    {:ok, race: race}
  end

  @valid_hazards ["MeterBomb", "WaypointBomb", "MapBomb"]

  describe "hazards" do
    test "create_hazard/1 with valid data creates a hazard", %{race: race} do
      assert {:ok, %Hazard{}} =
               Hazards.create_hazard(%{
                 name: random_hazard(),
                 attacking_team: attacking_team(race),
                 affected_team: affected_team(race),
                 expiration: 60,
                 race_id: race.id
               })
    end

    test "create_hazard/1 with invalid hazard name returns error changeset", %{race: race} do
      assert {:error, %Ecto.Changeset{}} =
               Hazards.create_hazard(%{
                 name: "Blah blah blah I don't actually exist",
                 attacking_team: attacking_team(race),
                 affected_team: affected_team(race),
                 expiration: 60,
                 race_id: race.id
               })
    end

    test "create_hazard/1 returns an error changeset if any attribute is nil", %{race: race} do
      assert {:error, %Ecto.Changeset{}} = Hazards.create_hazard(%{race_id: race.id})
    end

    test "by_targeted/2 returns a list of all hazards in effect for the given affected team", %{
      race: race
    } do
      hazards =
        for _ <- 1..3 do
          hazard_fixture(race)
        end

      assert hazards == Hazards.by_targeted(race.id, affected_team(race))
    end

    test "by_targeted/2 returns an empty list when given a team not participating in race", %{
      race: race
    } do
      assert [] == Hazards.by_targeted(race.id, "blah. I am not actually a team in this race.")
    end

    test "delete_hazard/1 deletes the hazard", %{race: race} do
      hazard = hazard_fixture(race)

      assert {:ok, %Hazard{}} = Hazards.delete_hazard(hazard)
      assert_raise Ecto.NoResultsError, fn -> GeoRacer.Repo.get!(Hazard, hazard.id) end
    end

    test "change_hazard/1 returns a race changeset", %{race: race} do
      assert %Ecto.Changeset{} = Hazards.change_hazard(hazard_fixture(race))
    end

    test "calculate_expiration/2 adds 60 (one minute) to the given time val for MeterBomb hazards" do
      assert Hazards.calculate_expiration([for: "MeterBomb"], 0) == 60
    end

    test "calculate_expiration/2 adds 60 (one minute) to the given time val for MapBomb hazards" do
      assert Hazards.calculate_expiration([for: "MapBomb"], 0) == 60
    end

    test "all/0 returns a list of all the hazards available" do
      assert Hazards.all() == [Hazards.MeterBomb, Hazards.WaypointBomb, Hazards.MapBomb]
    end

    test "name_for/1 returns the string name representing the hazard" do
      assert "MeterBomb" == Hazards.name_for(Hazards.MeterBomb)
      assert "WaypointBomb" == Hazards.name_for(Hazards.WaypointBomb)
      assert "MapBomb" == Hazards.name_for(Hazards.MapBomb)
    end

    test "from_string/1 returns an ok tuple with a hazard derived from the given string" do
      assert {:ok, Hazards.MapBomb} = Hazards.from_string("MapBomb")
      assert {:ok, Hazards.MapBomb} = Hazards.from_string("Map Bomb")
      assert {:ok, Hazards.MeterBomb} = Hazards.from_string("MeterBomb")
      assert {:ok, Hazards.MeterBomb} = Hazards.from_string("Meter Bomb")
      assert {:ok, Hazards.WaypointBomb} = Hazards.from_string("WaypointBomb")
      assert {:ok, Hazards.WaypointBomb} = Hazards.from_string("Waypoint Bomb")
    end

    test "from_string/1 returns an error tuple when given an invalid hazard string" do
      assert {:error, :invalid_hazard} = Hazards.from_string("This is not even a real hazard.")
    end

    test "apply/2 returns a new race with affected teams waypoints shuffled if hazard is a waypoint bomb",
         %{
           race: race
         } do
      old_waypoint_list = race.team_tracker[affected_team(race)]
      new_race = Hazards.apply(hazard_fixture(race, "WaypointBomb"), race)
      refute old_waypoint_list == new_race.team_tracker[affected_team(race)]
    end

    test "apply/2 returns the same race if hazard is not a waypoint bomb", %{
      race: race
    } do
      old_waypoint_list = race.team_tracker[affected_team(race)]
      new_race = Hazards.apply(hazard_fixture(race, "MeterBomb"), race)
      assert old_waypoint_list == new_race.team_tracker[affected_team(race)]
    end
  end

  defp hazard_fixture(race, hazard_type \\ nil) do
    name = if hazard_type, do: hazard_type, else: random_hazard()

    attrs = %{
      name: name,
      attacking_team: attacking_team(race),
      affected_team: affected_team(race),
      expiration: 60,
      race_id: race.id
    }

    {:ok, hazard} =
      %Hazard{}
      |> Hazard.changeset(attrs)
      |> Repo.insert()

    hazard
  end

  defp random_hazard, do: Enum.random(@valid_hazards)

  defp attacking_team(race) do
    race.team_tracker
    |> Map.keys()
    |> List.first()
  end

  defp affected_team(race) do
    race.team_tracker
    |> Map.keys()
    |> Enum.at(1)
  end
end
