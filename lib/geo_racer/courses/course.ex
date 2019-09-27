defmodule GeoRacer.Courses.Course do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias GeoRacer.Courses.Waypoint

  @default_bounds_in_meters 1000
  @srid 4326
  @cache :boundary_cache

  @type distance :: number()
  @type t :: %__MODULE__{
          name: String.t(),
          center: Geo.PostGIS.Geometry.t(),
          waypoints: list(Waypoint.t())
        }

  schema "courses" do
    field :name, :string
    field :center, Geo.PostGIS.Geometry
    field :is_public, :boolean, default: false
    field :user_uuid, :string

    has_many :waypoints, Waypoint, on_delete: :delete_all, on_replace: :delete
    timestamps()
  end

  @doc false
  def changeset(race, attrs) do
    race
    |> cast(attrs, [:name, :center, :is_public, :user_uuid])
    |> cast_assoc(:waypoints, with: &Waypoint.changeset/2)
    |> validate_required([:name, :center, :waypoints])
    |> validate_non_empty(:waypoints)
  end

  @doc """
  Calculates the geographic center of a list of waypoint coordinates.
  """
  @spec calculate_center(list(Waypoint.t())) :: Geo.Point.t() | nil
  def calculate_center([]), do: nil

  def calculate_center([waypoint]) do
    [_, [northeast_lat, northeast_lng]] =
      Geocalc.bounding_box(waypoint, @default_bounds_in_meters)

    [center_lat, center_lng] =
      Geocalc.geographic_center([waypoint, %{latitude: northeast_lat, longitude: northeast_lng}])

    %Geo.Point{
      coordinates: {center_lng, center_lat},
      srid: @srid
    }
  end

  def calculate_center(waypoints) when is_list(waypoints) do
    [center_lat, center_lng] = Geocalc.geographic_center(waypoints)

    %Geo.Point{
      coordinates: {center_lng, center_lat},
      srid: @srid
    }
  end

  @doc """
  Returns a bounding box (southwest lat/lng coordinates + northeast lat/lng coordinates)
  for a Course based on the center point.
  """
  @spec bounding_box(t(), non_neg_integer()) :: %{
          southwest: %{lat: Float.t(), lng: Float.t()},
          northeast: %{lat: Float.t(), lng: Flat.t()}
        }
  def bounding_box(%{center: %{coordinates: {lat, lng}}}, distance \\ 1000) do
    [[sw_lat, sw_lng], [ne_lat, ne_lng]] = Geocalc.bounding_box([lat, lng], distance)

    %{
      southwest: %{
        lat: sw_lat,
        lng: sw_lng
      },
      northeast: %{
        lat: ne_lat,
        lng: ne_lng
      }
    }
  end

  @doc """
  Calculates a boundary in meters given a center point.
  Finds the waypoint located farthest away from the center
  and adds an extra _distance_ meters to that distance so that
  the waypoint located farthest from the center is contained
  within the boundary. _distance_ can be adjusted, but defaults
  to 1000 meters.
  """
  @spec boundary_for(%{center: Geo.PostGIS.Geometry.t(), waypoints: [Waypoint.t()]}, distance()) ::
          distance()
  def boundary_for(course, distance \\ 1000) do
    case :ets.lookup(@cache, course.id) do
      [{_, boundary}] ->
        boundary

      [] ->
        boundary = calculate_boundary(course, distance)
        :ets.insert(@cache, {course.id, boundary})
        boundary
    end
  end

  defp calculate_boundary(%{center: %{coordinates: {center_lng, center_lat}}} = course, distance) do
    course.waypoints
    |> Enum.reduce([], fn %{point: %{coordinates: {lng, lat}}}, acc ->
      [
        Geocalc.distance_between(%{latitude: lat, longitude: lng}, %{
          latitude: center_lat,
          longitude: center_lng
        })
        | acc
      ]
    end)
    |> Enum.max()
    |> Kernel.+(distance)
  end

  defp validate_non_empty(changeset, :waypoints) do
    case changeset.changes[:waypoints] do
      nil -> add_error(changeset, :waypoints, "Must have at least one waypoint")
      [] -> add_error(changeset, :waypoints, "Must have at least one waypoint")
      _ -> changeset
    end
  end
end
