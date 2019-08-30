defmodule GeoRacer.Races.StagingArea do
  @moduledoc """
  Exposes a client API for driving a StagingArea GenServer
  process.
  """
  alias GeoRacer.Races.StagingArea.{Server, Supervisor}

  @name &Supervisor.name_for/2

  ################################
  # GEN_SERVER PROCESS FUNCTIONS #
  ################################

  @doc """
  Starts a new `StagingArea` GenServer process.
  """
  @spec new(String.t(), String.t()) :: GenServer.on_start()
  def new(course_id, race_code) do
    GenServer.start_link(Server, course_id <> ":" <> race_code, name: @name.(course_id, race_code))
  end

  @doc """
  Stops the `StagingArea` GenServer process with the
  given identifier.
  """
  @spec stop(String.t()) :: :ok
  def stop(identifier) do
    Supervisor.stop_staging_area(identifier)
  end

  ##############
  # CLIENT API #
  ##############

  @doc """
  Adds a new team to the `StagingArea` state.
  """
  @spec put_team(String.t(), String.t()) :: :ok
  def put_team(identifier, team_name) do
    GenServer.cast({:global, identifier}, {:put_team, team_name})
  end

  @doc """
  Returns true if `team_name` has already been taken.
  """
  @spec team_name_taken?(String.t(), String.t()) :: boolean()
  def team_name_taken?(identifier, team_name) do
    case Supervisor.started?(identifier) do
      false -> false
      true -> GenServer.call({:global, identifier}, {:team_name_taken?, team_name})
    end
  end

  @doc """
  Removes a team from the `StagingArea` state.
  """
  @spec drop_team(String.t(), String.t()) :: :ok
  def drop_team(identifier, team_name) do
    GenServer.cast({:global, identifier}, {:drop_team, team_name})
  end

  @doc """
  Returns the current state of the `StagingArea` process.
  """
  @spec state(String.t()) :: __MODULE__.Impl.t()
  def state(identifier) do
    GenServer.call({:global, identifier}, :get_state)
  end

  @doc """
  Subscribes to updates on the `StagingArea`
  """
  @spec subscribe_to_updates(String.t(), String.t()) :: :ok
  def subscribe_to_updates(course_id, code) do
    GeoRacerWeb.Endpoint.subscribe("staging_area:#{course_id}:#{code}")
  end

  @doc """
  Broadcasts updates to the staging_area:course_id:code PubSub topic
  """
  @spec broadcast_update(String.t(), __MODULE__.Impl.t()) :: :ok
  def broadcast_update(identifier, update) do
    GeoRacerWeb.Endpoint.broadcast("staging_area:#{identifier}", "update", update)
  end
end
