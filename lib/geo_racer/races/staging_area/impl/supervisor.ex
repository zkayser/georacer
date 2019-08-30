defmodule GeoRacer.Races.StagingArea.Supervisor do
  @moduledoc """
  A DynamicSupervisor that creates staging area processes
  used for setting up races.
  """
  alias GeoRacer.Races.StagingArea
  use DynamicSupervisor

  @valid_name_regex ~r/(?<course_id>\d+):(?<race_code>[\d+\w+]{8})/

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
  Starts a new staging area process. Requires a string in the format:
  `course_id:race_code` where race_code is an 8-character alphanumeric
  string
  """
  @spec create_staging_area(String.t()) ::
          {:ok, String.t()} | {:error, :invalid_name} | {:error, term()}
  def create_staging_area(identifier) when is_binary(identifier) do
    with %{"course_id" => course_id, "race_code" => race_code} <-
           Regex.named_captures(@valid_name_regex, identifier) do
      spec = %{
        id: StagingArea,
        start: {StagingArea, :new, [course_id, race_code]},
        restart: :transient
      }

      case DynamicSupervisor.start_child(__MODULE__, spec) do
        {:ok, pid} when is_pid(pid) ->
          {:ok, course_id <> ":" <> race_code}

        {:error, {:already_started, _pid}} ->
          {:ok, course_id <> ":" <> race_code}

        other ->
          {:error, other}
      end
    else
      nil -> {:error, :invalid_name}
      {:error, error} -> {:error, error}
    end
  end

  def create_staging_area(_), do: {:error, :invalid_name}

  @doc """
  Terminates the process, if it exists, for the identifier
  """
  @spec stop_staging_area(String.t()) :: :ok
  def stop_staging_area(identifier) do
    case GenServer.whereis(name_for(identifier)) do
      nil -> :ok
      pid -> DynamicSupervisor.terminate_child(__MODULE__, pid)
    end
  end

  @doc """
  Returns true if the process with the given
  identifier is currently running.
  """
  @spec started?(String.t()) :: boolean()
  def started?(identifier) do
    case get_pid(identifier) do
      {:error, :not_started} -> false
      _ -> true
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

  @doc """
  Returns the name identifier for a staging area process tagged
  with :global inside a tuple
  """
  @spec name_for(String.t(), String.t()) :: {:global, String.t()}
  def name_for(course_id, race_code) do
    {:global, course_id <> ":" <> race_code}
  end

  def name_for(identifier), do: {:global, identifier}
end
