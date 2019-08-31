defmodule GeoRacer.Races.Race do
  @moduledoc """
  Exposes a client API for driving Race GenServer processes.
  """
  alias GeoRacer.Races.Race.{Server, Supervisor}
  require Logger

  @name &Supervisor.name_for/1

  ################################
  # GEN SERVER PROCESS FUNCTIONS #
  ################################

  @doc """
  Starts a new Race GenServer process
  """
  def new(id) do
    GenServer.start_link(Server, "#{id}", name: @name.(id))
  end

  @doc """
  Stops the `StagingArea` GenServer process with the
  given identifier.
  """
  @spec stop(String.t()) :: :ok
  def stop(identifier) do
    Supervisor.stop_race(identifier)
  end
end
