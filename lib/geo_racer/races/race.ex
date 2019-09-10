defmodule GeoRacer.Races.Race do
  @moduledoc """
  Exposes a client API for driving Race GenServer processes.
  """
  alias GeoRacer.Courses.Waypoint
  alias GeoRacer.Races.Race.{Server, Supervisor, Impl}
  require Logger

  @name &Supervisor.name_for/1
  @races_topic_prefix "races:"

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

  @doc """
  Drops a waypoint from `team`'s list of
  remaining waypoints.
  """
  @spec drop_waypoint(Impl.t(), String.t()) :: :ok
  def drop_waypoint(race, team_name) do
    GenServer.cast(@name.(race.id), {:drop_waypoint, team_name})
  end

  @doc """
  Returns the HotColdMeter implementation for the race/team
  combination. If team is affected by an outstanding MeterBomb
  Hazard, this function will return MeterBomb. Otherwise, it
  will return the standard HotColdMeter implementation.
  """
  @spec hot_cold_meter(Impl.t(), Keyword.t()) :: HotColdMeter | MeterBomb
  def hot_cold_meter(race, for: team) do
    GenServer.call(@name.(race.id), {:hot_cold_meter, team})
  end

  @doc """
  Creates a hazard and updates race state with the new hazard.
  """
  @spec put_hazard(Impl.t(), Keyword.t()) :: :ok
  def put_hazard(race, opts) do
    GenServer.cast(
      @name.(race.id),
      {:put_hazard,
       %{name: opts[:type], affected_team: opts[:on], attacking_team: opts[:by], race_id: race.id}}
    )
  end

  @doc """
  Broadcasts updates to subscribers.
  """
  @spec broadcast_update(map()) :: :ok
  def broadcast_update(
        %{
          "update" => race,
          "hazard_deployed" => %{"name" => _name, "on" => _affected, "by" => _}
        } = payload
      ) do
    GeoRacerWeb.Endpoint.broadcast("#{@races_topic_prefix}#{race.id}", "race_update", payload)
  end
end
