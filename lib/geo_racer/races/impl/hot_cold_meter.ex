defmodule GeoRacer.Races.Race.HotColdMeter do
  @moduledoc """
  Takes responsibility for calculating how far
  a user is from a Waypoint and detecting if
  the user has reached a Waypoint.
  """
  alias GeoRacer.Courses.Waypoint
  require Logger
  @type coordinates :: %{lat: Float.t(), lng: Float.t()}
  @geo_calc Application.get_env(:geo_racer, :geo_calc_module) || Geocalc

  @doc """
  Determines on a scale of 0-8 how close
  a user is from a Waypoint, with 8 being
  the closest.
  """
  @spec level(Waypoint.t(), coordinates, Float.t()) :: non_neg_integer
  def level(waypoint, coordinates, boundary) do
    distance = @geo_calc.distance_between(Waypoint.to_coordinates(waypoint), coordinates)
    Logger.debug("Distance between waypoint and current location: #{inspect(distance)}")

    score_for_level(
      (boundary - distance) /
        boundary
    )
  end

  defp score_for_level(score) when score < 0.125, do: 1
  defp score_for_level(score) when score >= 0.125 and score < 0.25, do: 2
  defp score_for_level(score) when score >= 0.25 and score < 0.375, do: 3
  defp score_for_level(score) when score >= 0.375 and score < 0.5, do: 4
  defp score_for_level(score) when score >= 0.5 and score < 0.625, do: 5
  defp score_for_level(score) when score >= 0.625 and score < 0.75, do: 6
  defp score_for_level(score) when score >= 0.75 and score < 0.875, do: 7
  defp score_for_level(score) when score >= 0.875 and score < 0.95, do: 8
  defp score_for_level(score) when score > 0.95, do: 9
end
