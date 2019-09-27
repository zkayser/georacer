defmodule GeoRacer.Repo.Migrations.AddIsPublicAndUserUUIDToCourses do
  use Ecto.Migration

  def change do
    alter table(:courses) do
      add :is_public, :boolean, default: false
      add :user_uuid, :string
    end

    create index(:courses, :user_uuid)
  end
end
