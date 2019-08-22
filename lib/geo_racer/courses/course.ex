defmodule GeoRacer.Courses.Course do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias GeoRacer.Courses.Waypoint

  @default_bounds_in_meters 1000
  @srid 4326

  schema "courses" do
    field :name, :string
    field :center, Geo.PostGIS.Geometry

    has_many :waypoints, Waypoint, on_delete: :delete_all, on_replace: :delete
    timestamps()
  end

  @doc false
  def changeset(race, attrs) do
    race
    |> cast(attrs, [:name, :center])
    |> cast_assoc(:waypoints, with: &Waypoint.changeset/2)
    |> validate_required([:name, :center, :waypoints])
    |> validate_non_empty(:waypoints)
  end

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

  defp validate_non_empty(changeset, :waypoints) do
    case changeset.changes[:waypoints] do
      nil -> add_error(changeset, :waypoints, "Must have at least one waypoint")
      [] -> add_error(changeset, :waypoints, "Must have at least one waypoint")
      _ -> changeset
    end
  end
end
