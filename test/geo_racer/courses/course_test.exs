defmodule GeoRacer.Courses.CourseTest do
  use ExUnit.Case
  alias GeoRacer.Courses.Course

  @default_bounds_in_meters 1000
  @srid 4326

  describe "Course" do
    test "calculate_center/1 returns the geographic center of a list of points" do
      waypoints = [%{latitude: 39.0, longitude: -84.5}, %{latitude: 39.5, longitude: -85.0}]
      [center_lat, center_lng] = Geocalc.geographic_center(waypoints)

      assert %Geo.Point{coordinates: {center_lng, center_lat}, srid: @srid} ==
               Course.calculate_center(waypoints)
    end

    test "calculate_center/1 returns nil when given an empty list" do
      refute Course.calculate_center([])
    end

    test "calculate_center/1 with one point sets a bounding box of 1 km around the point and determines center point given one point from the bounding box" do
      waypoint = %{latitude: 39.0, longitude: -84.5}

      [_southwest_coords, northeast_coords] =
        Geocalc.bounding_box(waypoint, @default_bounds_in_meters)

      [center_lat, center_lng] = Geocalc.geographic_center([waypoint, northeast_coords])

      assert %Geo.Point{coordinates: {center_lng, center_lat}, srid: @srid} ==
               Course.calculate_center([waypoint])
    end
  end
end
