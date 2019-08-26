defmodule GeoRacer.Races.StagingArea.SupervisorTest do
  use ExUnit.Case
  alias GeoRacer.Races.StagingArea.Supervisor

  test "it exists" do
    assert Supervisor |> Process.whereis() |> Process.alive?()
  end

  describe "create_staging_area/1" do
    test "only takes strings of format {course_id}:{race_code}" do
      assert {:error, :invalid_name} = Supervisor.create_staging_area("some_rando_string")
      assert {:ok, _pid} = Supervisor.create_staging_area("2:#{GeoRacer.Races.generate_code()}")
    end

    test "handles bad input" do
      assert {:error, :invalid_name} = Supervisor.create_staging_area(nil)
      assert {:error, :invalid_name} = Supervisor.create_staging_area(1)
    end

    test "initiates a process with the given identifier" do
      assert {:ok, identifier} =
               Supervisor.create_staging_area("2:#{GeoRacer.Races.generate_code()}")

      assert identifier
             |> Supervisor.get_pid()
             |> Process.alive?()
    end

    test "returns the name identifier for the process if it has already been started" do
      identifier = "2:#{GeoRacer.Races.generate_code()}"
      Supervisor.create_staging_area(identifier)
      assert {:ok, identifier} == Supervisor.create_staging_area(identifier)
    end

    test "prevents multiple processes with the same identifier from being started" do
      assert {:ok, identifier} =
               Supervisor.create_staging_area("2:#{GeoRacer.Races.generate_code()}")

      pid = Supervisor.get_pid(identifier)
      assert {:ok, identifier} == Supervisor.create_staging_area(identifier)
      assert pid == Supervisor.get_pid(identifier)
    end

    test "creates different processes for staging areas with different identifiers" do
      assert {:ok, identifier_1} =
               Supervisor.create_staging_area("2:#{GeoRacer.Races.generate_code()}")

      assert {:ok, identifier_2} =
               Supervisor.create_staging_area("2:#{GeoRacer.Races.generate_code()}")

      refute Supervisor.get_pid(identifier_1) == Supervisor.get_pid(identifier_2)
    end
  end

  describe "stop_staging_area/1" do
    test "terminates the staging area process for the given identifier" do
      assert {:ok, identifier} =
               Supervisor.create_staging_area("2:#{GeoRacer.Races.generate_code()}")

      pid = Supervisor.get_pid(identifier)
      assert Process.alive?(pid)
      assert :ok = Supervisor.stop_staging_area(identifier)
      assert {:error, :not_started} = Supervisor.get_pid(identifier)
    end
  end

  describe "started?/1" do
    test "returns false if the process is not running" do
      refute Supervisor.started?("2:#{GeoRacer.Races.generate_code()}")
    end

    test "returns true if the process is running" do
      assert {:ok, identifier} =
               Supervisor.create_staging_area("2:#{GeoRacer.Races.generate_code()}")

      assert Supervisor.started?(identifier)
    end
  end

  describe "get_pid/1" do
    test "returns {:error, :not_started} if the process does not exist" do
      assert {:error, :not_started} = Supervisor.get_pid("2:#{GeoRacer.Races.generate_code()}")
    end

    test "returns the pid of the process associated with the identifier if it exists" do
      {:ok, identifier} = Supervisor.create_staging_area("2:#{GeoRacer.Races.generate_code()}")
      assert is_pid(Supervisor.get_pid(identifier))
    end
  end
end
