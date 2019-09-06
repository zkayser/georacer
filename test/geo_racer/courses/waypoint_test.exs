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

  describe "within_radius?/3" do
    test "returns true if the distance between Waypoint and coordinate is within radius" do
      waypoint = %Waypoint{point: %{coordinates: {-84.51, 39.10}}}
      coordinates = %{lat: 39.10001, lng: -84.51001}
      # meters
      radius = 10
      assert Waypoint.within_radius?(waypoint, coordinates, radius)
    end

    test "returns false if distance between Waypoint and coordinate is not with radius" do
      waypoint = %Waypoint{point: %{coordinates: {-84.51, 39.10}}}
      coordinates = %{lat: 39.1001, lng: -84.5101}
      # 3 meter radius by default
      refute Waypoint.within_radius?(waypoint, coordinates)
    end
  end
end
