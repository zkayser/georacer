defmodule GeoRacer.Races.StagingAreaTest do
  alias GeoRacer.Races.StagingArea
  alias StagingArea.Supervisor
  use ExUnit.Case

  describe "new/2" do
    test "creates a new staging area process" do
      course_id = "#{round(:rand.uniform() * 100)}"
      race_code = "#{GeoRacer.Races.generate_code()}"
      StagingArea.new(course_id, race_code)

      assert (course_id <> ":" <> race_code)
             |> Supervisor.get_pid()
             |> Process.alive?()
    end
  end

  describe "stop/1" do
    test "stops the process with the given identifier" do
      {:ok, identifier} = Supervisor.create_staging_area(identifier())
      assert identifier |> Supervisor.get_pid() |> Process.alive?()
      :ok = StagingArea.stop(identifier)
      assert {:error, :not_started} = Supervisor.get_pid(identifier)
    end
  end

  describe "put_team/2" do
    test "broadcasts an update message to staging_area:identifier topic" do
      {:ok, identifier} = Supervisor.create_staging_area(identifier())
      GeoRacerWeb.Endpoint.subscribe("staging_area:#{identifier}")

      StagingArea.put_team(identifier, "My team")

      assert_receive %Phoenix.Socket.Broadcast{
        event: "update",
        payload: %StagingArea.Impl{identifier: ^identifier, teams: teams}
      }

      assert "My team" in teams
    end
  end

  describe "drop_team/2" do
    test "broadcasts an update message to staging_area:identifier topic if team is removed from state" do
      {:ok, identifier} = Supervisor.create_staging_area(identifier())
      GeoRacerWeb.Endpoint.subscribe("staging_area:#{identifier}")

      StagingArea.put_team(identifier, "My team")
      StagingArea.drop_team(identifier, "My team")
      expected = MapSet.new()

      assert_receive %Phoenix.Socket.Broadcast{
        event: "update",
        payload: %StagingArea.Impl{identifier: ^identifier, teams: ^expected}
      }
    end

    test "does not broadcast a message if the team being removed is not actually in state" do
      {:ok, identifier} = Supervisor.create_staging_area(identifier())
      GeoRacerWeb.Endpoint.subscribe("staging_area:#{identifier}")
      StagingArea.drop_team(identifier, "My team")
      refute_receive %Phoenix.Socket.Broadcast{}
    end
  end

  describe "team_name_taken?/2" do
    test "returns false if there is no process running for the given identifier" do
      refute StagingArea.team_name_taken?(identifier(), "blah blah team")
    end

    test "returns false if the team name has not been taken" do
      {:ok, identifier} = Supervisor.create_staging_area(identifier())
      refute StagingArea.team_name_taken?(identifier, "my team")
    end

    test "returns true if the team name has already been taken" do
      {:ok, identifier} = Supervisor.create_staging_area(identifier())
      StagingArea.put_team(identifier, "My team")
      assert StagingArea.team_name_taken?(identifier, "My team")
    end
  end

  describe "state/1" do
    test "returns the current state of the staging area process" do
      {:ok, identifier} = Supervisor.create_staging_area(identifier())
      StagingArea.put_team(identifier, "My team")

      assert %StagingArea.Impl{
               identifier: identifier,
               teams: MapSet.new() |> MapSet.put("My team")
             } ==
               StagingArea.state(identifier)
    end
  end

  defp identifier() do
    "#{round(:rand.uniform() * 100)}:#{GeoRacer.Races.generate_code()}"
  end
end
