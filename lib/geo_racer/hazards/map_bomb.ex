defmodule GeoRacer.Hazards.MapBomb do
  @moduledoc """
  Implements the Hazard behaviour for
  MapBombs.
  """
  alias GeoRacer.Hazards.Hazard
  @behaviour Hazard

  @doc """
  Returns a plain text explanation of the
  Map Bomb's effect on opponents.
  """
  @impl Hazard
  @spec explain() :: String.t()
  def explain do
    "Throw an opposing team's map into disarray for 60 seconds."
  end

  @doc """
  Returns a plain test explanation of the
  Map Bomb's effect to affected parties.
  """
  @impl Hazard
  @spec description() :: String.t()
  def description do
    "Your map will go wild for the next 60 seconds."
  end

  @doc """
  Returns the string "Map Bomb"
  """
  @impl Hazard
  @spec display_name() :: String.t()
  def display_name, do: "Map Bomb"

  @doc """
  Returns a String represention an image
  fill for the Map Bomb.
  """
  @impl Hazard
  @spec image() :: String.t()
  def image, do: "map-bomb.svg"
end
