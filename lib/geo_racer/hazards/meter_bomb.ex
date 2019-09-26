defmodule GeoRacer.Hazards.MeterBomb do
  @moduledoc """
  An alternative implementation of the standard HotColdMeter.
  Implements the GeoRacer.Races.Race.HotColdMeter behaviour.
  """
  alias GeoRacer.Courses.Waypoint
  alias GeoRacer.Hazards.Hazard
  alias GeoRacer.Races.Race.HotColdMeter
  @behaviour HotColdMeter
  @behaviour Hazard
  @hot_cold_range 0..9

  @doc """
  Randomly returns a number from 0 to 9.
  """
  @impl HotColdMeter
  @spec level(Waypoint.t(), HotColdMeter.coordinates()) :: non_neg_integer
  def level(_waypoint, _coords), do: Enum.random(@hot_cold_range)

  @doc """
  Returns a plain text explanation of the
  Meter Bomb's effect on opponents.
  """
  @impl Hazard
  @spec explain() :: String.t()
  def explain do
    "Make your opponent's hot/cold meter go haywire for 60 seconds."
  end

  @doc """
  Returns a plain text explanation of the
  Meter Bomb's effect to affected parties.
  """
  @impl Hazard
  @spec description() :: String.t()
  def description do
    "Your hot/cold meter will be dysfunctional for the next 60 seconds."
  end

  @doc """
  Returns the string "Meter Bomb"
  """
  @impl Hazard
  @spec display_name() :: String.t()
  def display_name, do: "Meter Bomb"

  @doc """
  Returns a String representing an image
  file for the Meter Bomb.
  """
  @impl Hazard
  @spec image() :: String.t()
  def image, do: "meter-bomb.svg"
end
