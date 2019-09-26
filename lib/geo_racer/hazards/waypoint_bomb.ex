defmodule GeoRacer.Hazards.WaypointBomb do
  @moduledoc """
  Implements the Hazard behaviour for
  WaypointBombs.
  """

  @behaviour Hazard

  @doc """
  Returns a plain text explanation of the
  Waypoint Bomb's effect on opponents.
  """
  @impl true
  @spec explain() :: String.t()
  def explain do
    "Change an opposing team's next waypoint."
  end

  @doc """
  Returns a plain test explanation of the
  Waypoint Bomb's effect to affected parties.
  """
  @impl true
  @spec description() :: String.t()
  def description do
    "Your meter is now sending you to a different waypoint."
  end

  @doc """
  Returns the string "Waypoing Bomb"
  """
  @impl true
  @spec display_name() :: String.t()
  def display_name, do: "Waypoint Bomb"

  @doc """
  Returns a String represention an image
  fill for the Waypoint Bomb.
  """
  @impl true
  @spec image() :: String.t()
  def image, do: "waypoint-bomb.svg"
end
