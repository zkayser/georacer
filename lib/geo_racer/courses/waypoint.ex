defmodule GeoRacer.Courses.Waypoint do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @srid 4326

  schema "waypoints" do
    field :point, Geo.PostGIS.Geometry

    belongs_to :course, GeoRacer.Courses.Course, on_replace: :delete
    timestamps()
  end

  @doc false
  def changeset(waypoint, attrs) do
    waypoint
    |> change(point: convert_to_geometry(attrs))
    |> validate_required([:point])
  end

  defp convert_to_geometry(%{latitude: lat, longitude: lng}) do
    %Geo.Point{
      coordinates: {lng, lat},
      srid: @srid
    }
  end

  defp convert_to_geometry(attrs), do: attrs
end
