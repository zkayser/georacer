defmodule GeoRacer.FakeCalc do
  @moduledoc """
  Fake module to replace Geocalc library
  in tests.
  """

  def distance_between(_map, 0), do: 9
  def distance_between(_map, 1), do: 8
  def distance_between(_map, 2), do: 7
  def distance_between(_map, 3), do: 6
  def distance_between(_map, 4), do: 5
  def distance_between(_map, 5), do: 4
  def distance_between(_map, 6), do: 3
  def distance_between(_map, 7), do: 2
  def distance_between(_map, 8), do: 1
  def distance_between(_, _), do: 0
end
