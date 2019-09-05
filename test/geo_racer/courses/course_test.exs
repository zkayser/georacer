defmodule GeoRacer.Courses.CourseTest do
  use ExUnit.Case
  use GeoRacer.DataCase
  alias GeoRacer.Courses.Course
  alias GeoRacer.Factories.CourseFactory

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

    test "boundary_for/2 returns a bounding box around the center of the course plus 1000 meters (by default)" do
      {:ok, course} = CourseFactory.insert()

      max_dist_from_center =
        course.waypoints
        |> Enum.reduce([], fn waypoint, acc ->
          %{coordinates: {lng, lat}} = waypoint.point
          %{coordinates: {center_lng, center_lat}} = course.center

          [
            Geocalc.distance_between(%{latitude: lat, longitude: lng}, %{
              latitude: center_lat,
              longitude: center_lng
            })
            | acc
          ]
        end)
        |> Enum.max()

      assert Course.boundary_for(course) == max_dist_from_center + 1000
    end

    test "bounding_box/2 returns a map with :southwest and :northeast keys" do
      {:ok, course} = CourseFactory.insert()

      assert %{southwest: %{lat: lat, lng: lng}, northeast: %{lat: ne_lat, lng: ne_lng}} =
               Course.bounding_box(course)
    end
  end
end
