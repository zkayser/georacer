defmodule GeoRacer.Races.StagingArea.ServerTest do
  alias GeoRacer.Races.StagingArea
  use ExUnit.Case

  @identifier "1:ABCD1234"

  describe "StagingArea.Server" do
    test "the process shuts down when it receives a :close message" do
      {:ok, id} = StagingArea.Supervisor.create_staging_area(@identifier)

      pid = StagingArea.Supervisor.get_pid(id)

      assert Process.alive?(pid)

      send(pid, :close)

      Process.sleep(50)

      refute pid == StagingArea.Supervisor.get_pid(id)
      assert {:error, :not_started} = StagingArea.Supervisor.get_pid(id)
    end
  end
end
