defmodule GeoRacer.Races.Race.Supervisor do
  @moduledoc """
  A DynamicSupervisor that creates race processes
  used for setting up races.
  """
  alias GeoRacer.Races.Race
  use DynamicSupervisor

  ########################
  # SUPERVISOR CALLBACKS #
  ########################

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  ##############
  # CLIENT API #
  ##############

  @doc """
  Starts a new race process given a
  Race.Impl struct
  """
  @spec create_race(Race.Impl.t()) ::
          {:ok, String.t()} | {:error, :invalid_name} | {:error, term()}
  def create_race(%Race.Impl{} = race) do
    start_supervisor(race)
  end

  def create_race(_), do: {:error, :invalid_name}

  @doc """
  Terminates the process, if it exists, for the identifier
  """
  @spec stop_race(String.t()) :: :ok
  def stop_race(identifier) do
    case GenServer.whereis(name_for(identifier)) do
      nil -> :ok
      pid -> DynamicSupervisor.terminate_child(__MODULE__, pid)
    end
  end

  @doc """
  Returns the pid, if it exists, for the identifier
  """
  @spec get_pid(String.t()) :: pid() | {:error, :not_started}
  def get_pid(identifier) do
    case GenServer.whereis(name_for(identifier)) do
      nil -> {:error, :not_started}
      pid -> pid
    end
  end

  def name_for(identifier) do
    {:global, "race:#{identifier}"}
  end

  def start_supervisor(race) do
    spec = %{
      id: Race,
      start: {Race, :new, [race]},
      restart: :transient
    }

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, pid} when is_pid(pid) ->
        {:ok, "#{race.id}"}

      {:error, {:already_started, _pid}} ->
        {:ok, "#{race.id}"}

      other ->
        {:error, other}
    end
  end
end
