defmodule GeoRacer.Races.Race do
  @moduledoc """
  Exposes a client API for driving Race GenServer processes.
  """
  alias GeoRacer.Courses.Waypoint
  alias GeoRacer.Races.Race.{Server, Supervisor, Impl}
  require Logger

  @name &Supervisor.name_for/1

  ################################
  # GEN SERVER PROCESS FUNCTIONS #
  ################################

  @doc """
  Starts a new Race GenServer process
  """
  @spec new(Impl.t()) :: :ok
  def new(%Impl{} = race) do
    GenServer.start_link(Server, race, name: @name.(race.id))
  end

  @doc """
  Stops the `StagingArea` GenServer process with the
  given identifier.
  """
  @spec stop(String.t()) :: :ok
  def stop(identifier) do
    Supervisor.stop_race(identifier)
  end

  @doc """
  Gets the next waypoint for `team`.
  """
  @spec next_waypoint(Impl.t(), String.t()) :: Waypoint.t()
  def next_waypoint(race, team_name) do
    GenServer.call(@name.(race.id), {:next_waypoint, team_name})
  end
end
