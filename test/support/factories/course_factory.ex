defmodule GeoRacer.Factories.CourseFactory do
  @moduledoc """
  Exposes an insert function to create new courses
  for use in testing.
  """

  alias GeoRacer.StringGenerator
  alias GeoRacer.Courses

  @valid_attrs %{
    name: StringGenerator.random_string("Course:"),
    waypoints: [
      %{
        latitude: Float.round(39 + :rand.uniform(), 6),
        longitude: Float.round(-84 - :rand.uniform(), 6)
      },
      %{
        latitude: Float.round(39 + :rand.uniform(), 6),
        longitude: Float.round(-84 - :rand.uniform(), 6)
      }
    ],
    center: %Geo.Point{
      coordinates: {Float.round(-84 - :rand.uniform(), 6), Float.round(39 + :rand.uniform(), 6)},
      srid: 4326
    },
    user_uuid: UUID.uuid4(),
    is_public: false
  }

  def insert(extra_attrs \\ %{}) do
    @valid_attrs
    |> Map.merge(extra_attrs)
    |> Courses.create_course()
  end
end
