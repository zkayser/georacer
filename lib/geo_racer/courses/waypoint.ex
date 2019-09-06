defmodule GeoRacer.Courses.Waypoint do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @srid 4326

  @type t :: %{point: Geo.PostGIS.Geometry.t()}

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

  @doc """
  Returns a map with :lat and :lng keys from
  a Waypoint.
  """
  @spec to_coordinates(t()) :: %{lat: Float.t(), lng: Float.t()}
  def to_coordinates(%__MODULE__{point: %{coordinates: {lng, lat}}}) do
    %{lat: lat, lng: lng}
  end

  @doc """
  Returns true if Waypoint and `coordinates`
  are within `radius` of each other.
  """
  @spec within_radius?(t(), %{lat: Float.t(), lng: Float.t()}, non_neg_integer()) :: boolean()
  def within_radius?(%__MODULE__{} = waypoint, coords, radius \\ 3) do
    waypoint
    |> to_coordinates()
    |> Geocalc.distance_between(coords)
    |> Kernel.<=(radius)
  end

  defp convert_to_geometry(%{latitude: lat, longitude: lng}) do
    %Geo.Point{
      coordinates: {lng, lat},
      srid: @srid
    }
  end

  defp convert_to_geometry(attrs), do: attrs
end
