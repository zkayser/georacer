defmodule GeoRacer.Courses.WaypointTest do
  use GeoRacer.DataCase
  alias GeoRacer.Courses.Waypoint

  setup do
    {:ok, course} = GeoRacer.Factories.CourseFactory.insert()

    {:ok, course: course}
  end

  describe "to_coordinates/1" do
    test "returns a map with :lat and :lng keys from the waypoint", %{course: course} do
      %Waypoint{} = waypoint = List.first(course.waypoints)
      assert %{lat: lat, lng: lng} = Waypoint.to_coordinates(waypoint)
    end
  end
end
