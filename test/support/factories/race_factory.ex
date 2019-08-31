defmodule GeoRacer.Factories.RaceFactory do
  @moduledoc """
  Exposes an insert function to create new Races
  for use in testing.
  """

  alias GeoRacer.StringGenerator
  alias GeoRacer.Races

  def insert do
    {:ok, course} = GeoRacer.Factories.CourseFactory.insert()
    {team_1, team_2} = {StringGenerator.random_string(), StringGenerator.random_string()}

    Races.create_race(%{
      code: Races.generate_code(),
      team_tracker: %{
        team_1 => waypoint_list(course.waypoints),
        team_2 => waypoint_list(course.waypoints)
      },
      status: "started",
      course_id: course.id
    })
  end

  defp waypoint_list(waypoints) do
    waypoints
    |> Enum.map(fn waypoint -> waypoint.id end)
    |> Enum.shuffle()
  end
end
