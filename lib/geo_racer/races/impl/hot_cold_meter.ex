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
  @waypoint_radius Application.get_env(:geo_racer, :waypoint_radius) || 25
  @level_increment_in_meters 5

  @level_9 @waypoint_radius + @level_increment_in_meters
  @level_8 @waypoint_radius + @level_increment_in_meters * 2
  @level_7 @waypoint_radius + @level_increment_in_meters * 3
  @level_6 @waypoint_radius + @level_increment_in_meters * 4
  @level_5 @waypoint_radius + @level_increment_in_meters * 5
  @level_4 @waypoint_radius + @level_increment_in_meters * 6
  @level_3 @waypoint_radius + @level_increment_in_meters * 7
  @level_2 @waypoint_radius + @level_increment_in_meters * 8

  @doc """
  Interface for HotColdMeter implementations
  """
  @callback level(Waypoint.t(), coordinates) :: non_neg_integer

  @doc """
  Determines on a scale of 1-9 how close
  a user is from a Waypoint, with 9 being
  the closest.
  """
  @spec level(Waypoint.t(), coordinates) :: non_neg_integer
  def level(waypoint, coordinates) do
    distance = @geo_calc.distance_between(Waypoint.to_coordinates(waypoint), coordinates)
    Logger.debug("Distance between waypoint and current location: #{inspect(distance)}")

    distance
    |> adjust_for_accuracy(coordinates["accuracy"])
    |> score_for_level()
  end

  defp score_for_level(distance) when distance <= @level_9, do: 9
  defp score_for_level(distance) when distance <= @level_8, do: 8
  defp score_for_level(distance) when distance <= @level_7, do: 7
  defp score_for_level(distance) when distance <= @level_6, do: 6
  defp score_for_level(distance) when distance <= @level_5, do: 5
  defp score_for_level(distance) when distance <= @level_4, do: 4
  defp score_for_level(distance) when distance <= @level_3, do: 3
  defp score_for_level(distance) when distance <= @level_2, do: 2
  defp score_for_level(_distance), do: 1

  defp adjust_for_accuracy(distance, nil), do: distance

  defp adjust_for_accuracy(distance, accuracy) do
    case accuracy <= @waypoint_radius + @level_increment_in_meters do
      true ->
        distance

      false ->
        distance - (accuracy - (@waypoint_radius + @level_increment_in_meters))
    end
  end
end
