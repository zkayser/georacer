defmodule GeoRacer.Races.Race.SupervisorTest do
  use GeoRacer.DataCase
  alias GeoRacer.Races.Race.Supervisor

  setup do
    {:ok, race} = GeoRacer.Factories.RaceFactory.insert()

    {:ok, race: race}
  end

  describe "create_race/1" do
    test "only takes strings of format :id", %{race: race} do
      assert {:error, :invalid_name} = Supervisor.create_race("some_rando_string")
      assert {:ok, _pid} = Supervisor.create_race(race)
    end

    test "handles bad input" do
      assert {:error, :invalid_name} = Supervisor.create_race(nil)
      assert {:error, :invalid_name} = Supervisor.create_race(1)
    end

    test "initiates a process with the given identifier", %{race: race} do
      assert {:ok, identifier} = Supervisor.create_race(race)

      assert identifier
             |> Supervisor.get_pid()
             |> Process.alive?()
    end

    test "returns the name identifier for the process if it has already been started", %{
      race: race
    } do
      Supervisor.create_race(race)
      assert {:ok, "#{race.id}"} == Supervisor.create_race(race)
    end

    test "prevents multiple processes with the same identifier from being started", %{race: race} do
      assert {:ok, identifier} = Supervisor.create_race(race)

      pid = Supervisor.get_pid(identifier)
      assert {:ok, identifier} == Supervisor.create_race(race)
      assert pid == Supervisor.get_pid(identifier)
    end

    test "creates different processes for staging areas with different identifiers", %{race: race} do
      assert {:ok, identifier_1} = Supervisor.create_race(race)

      {:ok, other_race} = GeoRacer.Factories.RaceFactory.insert()

      assert {:ok, identifier_2} = Supervisor.create_race(other_race)

      refute Supervisor.get_pid(identifier_1) == Supervisor.get_pid(identifier_2)
    end
  end

  describe "stop_race/1" do
    test "terminates the staging area process for the given identifier", %{race: race} do
      assert {:ok, identifier} = Supervisor.create_race(race)

      pid = Supervisor.get_pid(identifier)
      assert Process.alive?(pid)
      assert :ok = Supervisor.stop_race(identifier)
      assert {:error, :not_started} = Supervisor.get_pid(identifier)
    end
  end
end
