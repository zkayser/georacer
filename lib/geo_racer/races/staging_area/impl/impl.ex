defmodule GeoRacer.Races.StagingArea.Impl do
  @moduledoc """
  Implements a struct encapsulating data for a
  staging area.
  """

  defstruct teams: MapSet.new(), identifier: nil

  @type t :: %__MODULE__{
          teams: Mapset.t(String.t()),
          identifier: String.t() | nil
        }

  @doc """
  Takes an identifier and returns a new
  `Impl` struct.
  """
  @spec from_identifier(String.t()) :: t()
  def from_identifier(identifier), do: %__MODULE__{identifier: identifier}

  @doc """
  Puts the given team in the list of
  team names.
  """
  @spec put_team(t(), String.t()) :: t()
  def put_team(%__MODULE__{teams: teams} = staging_area, team) do
    %__MODULE__{staging_area | teams: MapSet.put(teams, team)}
  end

  @doc """
  Removes the given team from the list of
  team names.
  """
  @spec drop_team(t(), String.t()) :: t()
  def drop_team(%__MODULE__{teams: teams} = staging_area, team) do
    %__MODULE__{staging_area | teams: MapSet.delete(teams, team)}
  end
end
