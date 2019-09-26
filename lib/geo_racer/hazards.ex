defmodule GeoRacer.Hazards do
  @moduledoc """
  Exposes functions for manipulating and working with Hazards.
  """
  import Ecto.Query, warn: false
  alias GeoRacer.Repo
  alias GeoRacer.Races.Race.Impl, as: Race
  alias GeoRacer.Hazards.{Hazard, MeterBomb, WaypointBomb, MapBomb}

  @typedoc """
  Any of the available Hazards in the game.
  """
  @type hazard :: MeterBomb | WaypointBomb | MapBomb

  @doc """
  Returns a list of the available hazards in the game.
  """
  @spec all() :: list(hazard)
  def all, do: [MeterBomb, WaypointBomb, MapBomb]

  @doc """
  Creates a Hazard.

  ## Examples

      iex> create_hazard(%{field: value})
      {:ok, %Hazard{}}

      iex> create_hazard(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_hazard(attrs \\ %{}) do
    %Hazard{}
    |> Hazard.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a Hazard.

  ## Examples

      iex> delete_hazard(hazard)
      {:ok, %Hazard{}}

      iex> delete_hazard(hazard)
      {:error, %Ecto.Changeset{}}

  """
  def delete_hazard(%Hazard{} = hazard) do
    Repo.delete(hazard)
  end

  @doc """
  Returns a list of Hazards in effect for
  `targeted` team in the Race represented by
  `race_id`.

  ## Examples

      iex> by_targeted(race_id, targeted)
      [%Hazard{}]

      iex> by_targeted(race_id, targeted)
      []
  """
  @spec by_targeted(non_neg_integer, String.t()) :: list(Hazard.t())
  def by_targeted(race_id, targeted) do
    race_id
    |> Hazard.by_targeted(targeted)
    |> Repo.all()
  end

  @doc """
  Returns a string representing `hazard`.
  """
  @spec name_for(hazard) :: String.t()
  def name_for(MapBomb), do: "MapBomb"
  def name_for(MeterBomb), do: "MeterBomb"
  def name_for(WaypointBomb), do: "WaypointBomb"

  @doc """
  Returns the hazard matching `string`.
  If the `string` passed in does not match
  an available hazard, returns `{:error, :invalid_hazard}`
  """
  @spec from_string(String.t()) :: {:ok, hazard} | {:error, :invalid_hazard}
  def from_string("MapBomb"), do: {:ok, MapBomb}
  def from_string("Map Bomb"), do: {:ok, MapBomb}
  def from_string("MeterBomb"), do: {:ok, MeterBomb}
  def from_string("Meter Bomb"), do: {:ok, MeterBomb}
  def from_string("WaypointBomb"), do: {:ok, WaypointBomb}
  def from_string("Waypoint Bomb"), do: {:ok, WaypointBomb}
  def from_string(_), do: {:error, :invalid_hazard}

  @doc """
  Calculates the expiration value by adding `seconds`
  number of seconds to the `time` value passed in.
  """
  @spec calculate_expiration(Keyword.t(), non_neg_integer) :: non_neg_integer
  def calculate_expiration([for: "MeterBomb"], time), do: time + 60
  def calculate_expiration([for: "MapBomb"], time), do: time + 60
  def calculate_expiration(_, _), do: 0

  @doc """
  Takes a hazard and a race and applies
  the hazard to the affected team in race.
  """
  @spec apply(Hazard.t(), Race.t()) :: Race.t()
  def apply(
        %Hazard{name: "WaypointBomb", affected_team: affected_team},
        %Race{team_tracker: team_tracker} = race
      ) do
    with true <- length(team_tracker[affected_team]) > 1,
         {:ok, new_race} <- Race.shuffle_waypoints(race, affected_team) do
      new_race
    else
      _ -> race
    end
  end

  def apply(_, %Race{} = race), do: race

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking hazard changes.

  ## Examples

      iex> change_hazard(hazard)
      %Ecto.Changeset{source: %Hazard{}}

  """
  def change_hazard(%Hazard{} = hazard) do
    Hazard.changeset(hazard, %{})
  end
end
