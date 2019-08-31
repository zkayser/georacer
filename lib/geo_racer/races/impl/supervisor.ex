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
  Starts a new race process. Requires a string in the format:
  `race:course_id:race_code` where race_code is an 8-character alphanumeric
  string
  """
  @spec create_race(String.t()) ::
          {:ok, String.t()} | {:error, :invalid_name} | {:error, term()}
  def create_race(identifier) when is_binary(identifier) do
    case Regex.match?(~r(\d+), identifier) do
      true -> start_supervisor(identifier)
      false -> {:error, :invalid_name}
    end
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

  def name_for(course_id, race_code) do
    {:global, "race:#{course_id}:#{race_code}"}
  end

  def name_for(identifier) do
    {:global, "race:#{identifier}"}
  end

  def start_supervisor(identifier) do
    case GeoRacer.Repo.get(Race.Impl, Regex.replace(~r(\D+), identifier, "")) do
      %Race.Impl{} = race ->
        spec = %{
          id: Race,
          start: {Race, :new, [race.id]},
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

      nil ->
        {:error, :invalid_name}
    end
  end
end
