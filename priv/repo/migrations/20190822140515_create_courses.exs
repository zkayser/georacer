defmodule GeoRacer.Repo.Migrations.CreateCourses do
  use Ecto.Migration

  def up do
    create table(:courses) do
      add :name, :string
      timestamps()
    end

    execute("SELECT AddGeometryColumn ('courses', 'center', 4326, 'POINT', 2)")
    execute("CREATE INDEX courses_center_index on courses USING gist (center)")
  end

  def down do
    drop table(:courses)
  end
end
