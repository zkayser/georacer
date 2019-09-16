defmodule GeoRacer.Repo.Migrations.CreateHazards do
  use Ecto.Migration

  def change do
    create table(:hazards) do
      add :name, :string, null: false
      add :affected_team, :string, null: false
      add :attacking_team, :string, null: false
      add :expiration, :integer, null: false
      add :race_id, references(:races)
    end
  end
end
