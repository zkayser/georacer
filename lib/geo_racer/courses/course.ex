defmodule GeoRacer.Courses.Course do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "courses" do
    field :name, :string
    field :center, Geo.PostGIS.Geometry

    timestamps()
  end

  @doc false
  def changeset(race, attrs) do
    race
    |> cast(attrs, [:name, :center])
    |> validate_required([:name, :center])
  end
end
