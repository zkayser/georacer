defmodule GeoRacer.FakeCalc do
  @moduledoc """
  Fake module to replace Geocalc library
  in tests.
  """

  def distance_between(_waypoint, %{"level" => 9}), do: 30
  def distance_between(_waypoint, %{"level" => 8}), do: 35
  def distance_between(_waypoint, %{"level" => 7}), do: 40
  def distance_between(_waypoint, %{"level" => 6}), do: 45
  def distance_between(_waypoint, %{"level" => 5}), do: 50
  def distance_between(_waypoint, %{"level" => 4}), do: 55
  def distance_between(_waypoint, %{"level" => 3}), do: 60
  def distance_between(_waypoint, %{"level" => 2}), do: 65
  def distance_between(_waypoint, %{"level" => 1}), do: 70
  def distance_between(_, _), do: 0
end
