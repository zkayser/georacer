defmodule GeoRacer.Repo.Migrations.CreateWaypoints do
  use Ecto.Migration

  def up do
    create table(:waypoints) do
      add :course_id, references(:courses, on_delete: :nothing)

      timestamps()
    end

    execute("SELECT AddGeometryColumn ('waypoints', 'point', 4326, 'POINT', 2)")
    create index(:waypoints, [:course_id])
  end

  def down do
    drop table(:waypoints)
  end
end
